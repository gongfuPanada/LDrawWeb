package kr.influx.ldrawweb.client;

import java.util.ArrayList;

import kr.influx.ldrawweb.shared.models.Model;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("submissions")
public interface SubmissionList extends RemoteService {
	ArrayList<Model> getSubmissionList(int startOffset, int count);
	ArrayList<Model> getSubmissionList(int startOffset, int count, String emailid);
	void postSubmission(Model item);
}
