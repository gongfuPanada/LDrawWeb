package kr.influx.ldrawweb.tests;

import kr.influx.ldrawweb.client.meshgen.MainModel;
import kr.influx.ldrawweb.client.meshgen.Model;
import kr.influx.ldrawweb.shared.DataBundle;
import kr.influx.ldrawweb.shared.DependencyResolver;
import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.LDrawModelMultipart;

public class LocalReadTest {
	static public void main(String[] args) {
		if (args.length == 0) {
			System.err.println("Insufficient arguments.");
			return;
		}
		
		new LocalReadTest(args[0]);
	}
	
	public LocalReadTest(String filename) {
		LocalResolver resolver = new LocalResolver(new DependencyResolver.OnResult() {
			@Override
			public void onPartLoaded(DependencyResolver loader, LDrawModel part) {
				System.out.println("Loaded part: " + part.getName());
			}
			
			@Override
			public void onPartFailed(DependencyResolver loader, String partid) {
				System.out.println("Failed loading part: " + partid);
			}
			
			@Override
			public void onModelLoaded(DependencyResolver loader,
					LDrawModelMultipart model) {
				System.out.println("Loaded model: " + model.getMainModel().getName());
			}
			
			@Override
			
			public void onModelFailed(DependencyResolver loader, String what) {
				System.out.println("Failed loading model: " + what);
			}
			
			@Override
			public void onComplete(DependencyResolver loader, DataBundle bundle) {
				System.out.println("Done loading.");
				
				processData(bundle);
			}
		});
		
		resolver.start(filename);
		resolver.readUntilDone();
	}
	
	private void processData(DataBundle bundle) {
		MainModel m = new MainModel();
		m.build(bundle);
	}
}
