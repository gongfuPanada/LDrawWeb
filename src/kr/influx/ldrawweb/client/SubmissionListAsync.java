package kr.influx.ldrawweb.client;

import java.util.ArrayList;

import kr.influx.ldrawweb.shared.models.Model;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface SubmissionListAsync {
	void getSubmissionList(int startOffset, int count, AsyncCallback<ArrayList<Model> > callback);
	void getSubmissionList(int startOffset, int count, String email, AsyncCallback<ArrayList<Model> > callback);
	void postSubmission(Model item, AsyncCallback<Void> callback);
}
