package kr.influx.ldrawweb.client;

import java.util.ArrayList;

import kr.influx.ldrawweb.client.renderer.RenderWidget;
import kr.influx.ldrawweb.shared.GoogleSignOnInfo;
import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.LDrawModelMultipart;
import kr.influx.ldrawweb.shared.datamodels.Model;
import kr.influx.ldrawweb.shared.exceptions.NoAdministrativeRights;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.FileUpload;
import com.google.gwt.user.client.ui.FormPanel;
import com.google.gwt.user.client.ui.Hidden;
import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.user.client.ui.PushButton;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.TextArea;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.FormPanel.SubmitCompleteEvent;
import com.google.gwt.user.client.ui.FormPanel.SubmitCompleteHandler;
import com.google.gwt.user.client.ui.FormPanel.SubmitEvent;
import com.google.gwt.user.client.ui.FormPanel.SubmitHandler;

/* Test page */
public class Entrypoint implements EntryPoint {

	native void redirect(String url) /*-{
		$wnd.location.replace(url);
	}-*/;
	
	public void onModuleLoad() {
		final PushButton pb = new PushButton("Login using Google account");
		pb.addClickHandler(new ClickHandler() {
			@Override
			public void onClick(ClickEvent event) {
				GoogleSignOnAsync gso = GWT.create(GoogleSignOn.class);
				gso.signOn(GWT.getHostPageBaseURL(), new AsyncCallback<GoogleSignOnInfo>() {
					@Override
					public void onFailure(Throwable caught) {
						pb.setText(caught.toString());
					}

					@Override
					public void onSuccess(GoogleSignOnInfo result) {
						if (result.isLoggedIn())
							pb.setText("Signed on as " + result.getEmail() + " / " + result.getNickname());
						else
							redirect(result.getLoginUrl());
					}
				});
			}
		});
		
		final TextArea ta = new TextArea();
		
		final PushButton pb2 = new PushButton("Query part");
		final PushButton lbb = new PushButton("Query model");
		final ListBox lb = new ListBox();
		final TextBox tb0 = new TextBox();
		final RenderWidget rw = new RenderWidget();
		final ModelLoader loader = new ModelLoader(5, new ModelLoader.OnResult() {
			@Override
			public void onPartLoaded(ModelLoader loader, LDrawModel part) {
				ta.setText(ta.getText() + "loaded part: " + part.getName() + "\n");
			}
			
			@Override
			public void onPartFailed(ModelLoader loader, String partid) {
				ta.setText(ta.getText() + "failed to load part: " + partid + "\n");
			}
			
			@Override
			public void onModelLoaded(ModelLoader loader, LDrawModelMultipart model) {
				ta.setText(ta.getText() + "main model loaded: " + model.getMainModel().getName() + "\n");
			}
			
			@Override
			public void onModelFailed(ModelLoader loader, String what) {
				ta.setText(ta.getText() + "main model loading failed to load: " + what + "\n");
				
				pb2.setEnabled(true);
			}
			
			@Override
			public void onComplete(ModelLoader loader) {
				ta.setText(ta.getText() + "loading complete.\n");
				
				lbb.setEnabled(true);
				pb2.setEnabled(true);
				
				rw.setData(loader.getBundle());
				rw.start();
			}
		});
		
		pb2.addClickHandler(new ClickHandler() {
			@Override
			public void onClick(ClickEvent event) {
				if (tb0.getText().length() == 0) {
					Window.alert("please input file name.");
					return;
				}
				
				pb2.setEnabled(false);
				lbb.setEnabled(false);
				
				loader.start(tb0.getText());
			}
		});
		
		final TextBox tb1 = new TextBox();
		final TextBox tb2 = new TextBox();
		
		final PushButton pb3 = new PushButton("Rebuild dependency graph");
		pb3.addClickHandler(new ClickHandler() {
			@Override
			public void onClick(ClickEvent event) {
				AdministrativeToolsAsync at = GWT.create(AdministrativeTools.class);
				at.rebuildDependencyGraph(Integer.parseInt(tb1.getText()), Integer.parseInt(tb2.getText()), new AsyncCallback<Integer>() {
					@Override
					public void onFailure(Throwable caught) {
						if (caught instanceof NoAdministrativeRights)
							Window.alert("no admin");
						else
							Window.alert(caught.toString());
					}

					@Override
					public void onSuccess(Integer result) {
						if (result == 0)
							Window.alert("no dependencies found.");
						else
							Window.alert("updated " + result + " items.");
					}
				});
			}
		});
		
		final PushButton pb4 = new PushButton("Wipe all");
		pb4.addClickHandler(new ClickHandler() {
			@Override
			public void onClick(ClickEvent event) {
				AdministrativeToolsAsync at = GWT.create(AdministrativeTools.class);
				at.wipeAll(new AsyncCallback<Void>() {
					@Override
					public void onFailure(Throwable caught) {
						if (caught instanceof NoAdministrativeRights)
							Window.alert("no admin");
						else
							Window.alert(caught.toString());
					}

					@Override
					public void onSuccess(Void unused) {
					}
				});
			}
		});
		
		final FormPanel fp = new FormPanel();		
		final FileUpload fu = new FileUpload();
		
		fp.setEncoding(FormPanel.ENCODING_MULTIPART);
		fp.setMethod(FormPanel.METHOD_POST);
		fp.setAction(GWT.getModuleBaseURL() + "upload/model");
		
		VerticalPanel holder = new VerticalPanel();
		
		fu.setName("upload");
		holder.add(fu);
		holder.add(new Hidden("type", "collection"));
		holder.add(new PushButton("Upload model (you need to sign up)", new ClickHandler() {
			@Override
			public void onClick(ClickEvent event) {
				fp.submit();
			}}
		));
		fp.add(holder);
		
		fp.addSubmitHandler(new SubmitHandler() {
			@Override
			public void onSubmit(SubmitEvent event) {
				if (fu.getFilename() == "")
					event.cancel();
			}}
		);
		
		fp.addSubmitCompleteHandler(new SubmitCompleteHandler() {
			@Override
			public void onSubmitComplete(SubmitCompleteEvent event) {
				Window.alert(event.getResults());
			}
		});
		
		ta.setWidth("480px");
		ta.setHeight("100px");
		
		lb.setVisibleItemCount(10);
		lbb.addClickHandler(new ClickHandler() {
			@Override
			public void onClick(ClickEvent event) {
				if (lb.getSelectedIndex() == -1)
					return;
				
				pb2.setEnabled(false);
				lbb.setEnabled(false);
				
				loader.start(Integer.parseInt(lb.getValue(lb.getSelectedIndex())));
			}
		});
		
		RootPanel rp = RootPanel.get();
		rp.add(pb);
		rp.add(tb0);
		rp.add(pb2);
		rp.add(lb);
		rp.add(lbb);
		rp.add(tb1);
		rp.add(tb2);
		rp.add(pb3);
		rp.add(pb4);
		rp.add(fp);
		rp.add(rw);
		rp.add(ta);
		
		SubmissionListAsync listOp = GWT.create(SubmissionList.class);
		listOp.getSubmissionList(0, 100, new AsyncCallback<ArrayList<Model> >() {
			@Override
			public void onFailure(Throwable caught) {
				Window.alert(caught.toString());
			}

			@Override
			public void onSuccess(ArrayList<Model> result) {
				for (Model m : result) {
					lb.addItem(m.getDescription() + "(" + m.getFilename() + ")", m.getId().toString());
				}
			}
		});
		
	}

}
