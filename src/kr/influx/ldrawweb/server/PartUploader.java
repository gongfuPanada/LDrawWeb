package kr.influx.ldrawweb.server;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.LDrawModelMultipart;
import kr.influx.ldrawweb.shared.datamodels.Part;
import kr.influx.ldrawweb.shared.datamodels.PartData;
import kr.influx.ldrawweb.shared.exceptions.*;

import org.apache.commons.fileupload.FileItemIterator;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import com.google.appengine.api.datastore.Blob;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

public class PartUploader extends HttpServlet {
	private static final long serialVersionUID = -6968436341610163384L;
	
	private static final int size_limit = 1024 * 700;
	
	private static DAO dao;
	static {
		dao = new DAO();
	}

	@Override
	public void doPost(HttpServletRequest request, HttpServletResponse response) {
		response.setContentType("text/plain");
		
		UserService us = UserServiceFactory.getUserService();
		User u = us.getCurrentUser();
		
		if (u == null) {
			JsonHelper.writeToResponse(response, JsonHelper.getFailedResult("Not signed in"));
			return;
		}
		
		ServletFileUpload upload = new ServletFileUpload();
		
		boolean iscollection = true;
		
		try {
			FileItemIterator iter = upload.getItemIterator(request);
			
			if (iscollection) {
				BufferedReader br = new BufferedReader(new InputStreamReader(iter.next().openStream()));
				
				String active = null;
				String fn = "";
				while (true) {
					String line = br.readLine();
					if (line == null)
						break;
					else if (line.startsWith("!")) {
						if (active != null) {
							try {
								parseStream(new ByteArrayInputStream(fn.getBytes()), active);
							} catch (ReadError e) {
								System.out.println(fn);
							}
							fn = "";
						}
						active = line.substring(1).trim();
					} else
						fn = fn.concat(line + "\n");
				}
				
				if (!fn.equals(""))
					parseStream(new ByteArrayInputStream(fn.getBytes()), active);
			} else {
				while (iter.hasNext())
					parseStream(iter.next().openStream(), null);
			}
		} catch (ReadError e) {
			JsonHelper.writeToResponse(response, JsonHelper.getFailedResult(e.toString()));
			return;
		} catch (IOException e) {
			JsonHelper.writeToResponse(response, JsonHelper.getFailedResult(e.toString()));
			return;
		} catch (FileUploadException e) {
			JsonHelper.writeToResponse(response, JsonHelper.getFailedResult(e.toString()));
			return;
		}
	}
	
	private void parseStream(InputStream stream, String filename) throws ReadError, IOException {
		int nlen = 0;
		byte[] array = new byte[size_limit];
		while (true) {
			int len = stream.read(array, nlen, 1024);
			if (len <= 0)
				break;
			else if (len + nlen > size_limit)
				throw new SizeLimitExceeded();
			
			nlen += len;
		}
		byte[] sarray = new byte[nlen];
		System.arraycopy(array, 0, sarray, 0, nlen);
		
		LDrawReader r = new LDrawReader(new ByteArrayInputStream(sarray));
		if (!r.parse(false))
			throw new EmptyDocument();
		
		LDrawModel mm;
		if (r.isMultipart()) {
			LDrawModelMultipart m = r.getMultipartModel();
			mm = m.getMainModel();
		} else {
			LDrawModel m = r.getModel();
			mm = m;
		}
		
		Part p = new Part();
		p.setAuthor(mm.getAuthor());
		p.setName(mm.getDescription());
		if (filename != null)
			p.setPartId(filename);
		else
			p.setPartId(mm.getName());
		p.setOwner(-1L);
		PartData pd = new PartData(new Blob(sarray));
		
		dao.insertPart(p, pd);
	}
}
