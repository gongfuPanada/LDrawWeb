package kr.influx.ldrawweb.server;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Date;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.LDrawModelMultipart;
import kr.influx.ldrawweb.shared.datamodels.Model;
import kr.influx.ldrawweb.shared.datamodels.ModelData;
import kr.influx.ldrawweb.shared.exceptions.*;

import org.apache.commons.fileupload.FileItemIterator;
import org.apache.commons.fileupload.FileItemStream;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import com.google.appengine.api.datastore.Blob;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

public class ModelUploader extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private static final int size_limit = 1024 * 700;
	
	private static DAO dao;
	static {
		dao = new DAO();
	}

	@Override
	public void doPost(HttpServletRequest request, HttpServletResponse response) {
		response.setContentType("application/json");
		
		UserService us = UserServiceFactory.getUserService();
		User u = us.getCurrentUser();
		
		if (u == null) {
			JsonHelper.writeToResponse(response, JsonHelper.getFailedResult(new NotLoggedIn()));
			return;
		}
		
		ServletFileUpload upload = new ServletFileUpload();
		
		try {
			FileItemIterator iter = upload.getItemIterator(request);
			
			while (iter.hasNext()) {
				FileItemStream fileItem = iter.next();
				if (fileItem.getName() == null)
					continue;
				parseStream(u.getUserId(), fileItem.openStream(), fileItem.getName());
			}
		} catch (ReadError e) {
			JsonHelper.writeToResponse(response, JsonHelper.getFailedResult(e));
			return;
		} catch (IOException e) {
			JsonHelper.writeToResponse(response, JsonHelper.getFailedResult(e));
			return;
		} catch (FileUploadException e) {
			JsonHelper.writeToResponse(response, JsonHelper.getFailedResult(e));
			return;
		}
		
		JsonHelper.writeToResponse(response, JsonHelper.getPositiveResult());
	}
	
	private void parseStream(String username, InputStream stream, String filename) throws ReadError, IOException {
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
		
		Model m = new Model();
		m.setAuthor(mm.getAuthor());
		m.setName(mm.getName());
		m.setDescription(mm.getDescription());
		m.setFilename(filename);
		m.setLastModifiedDate(new Date());
		m.setSubmissionDate(new Date());
		m.setOwner(0);
		ModelData md = new ModelData(new Blob(sarray));
		
		dao.insertModel(m, md);
	}
}
