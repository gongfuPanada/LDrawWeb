package kr.influx.ldrawweb.client.renderer;

import java.util.ArrayList;
import java.util.HashMap;

import kr.influx.ldrawweb.shared.DataBundle;
import kr.influx.ldrawweb.shared.LDrawElement1;
import kr.influx.ldrawweb.shared.LDrawElement3;
import kr.influx.ldrawweb.shared.LDrawElement4;
import kr.influx.ldrawweb.shared.LDrawElementBase;
import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.LDrawModelMultipart;
import kr.influx.ldrawweb.shared.Matrix4;
import kr.influx.ldrawweb.shared.Vector4;

import com.google.gwt.resources.client.TextResource;
import com.google.gwt.user.client.Timer;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.FlexTable;
import com.googlecode.gwtgl.array.Float32Array;
import com.googlecode.gwtgl.binding.WebGLBuffer;
import com.googlecode.gwtgl.binding.WebGLCanvas;
import com.googlecode.gwtgl.binding.WebGLContextAttributes;
import com.googlecode.gwtgl.binding.WebGLProgram;
import com.googlecode.gwtgl.binding.WebGLRenderingContext;
import com.googlecode.gwtgl.binding.WebGLShader;
import com.googlecode.gwtgl.binding.WebGLUniformLocation;

public class RenderWidget extends FlexTable {
	private final WebGLCanvas canvas;
	private final WebGLRenderingContext gl;
	
	private DataBundle data;
	private boolean started;
	
	private WebGLProgram programDefault;
	private WebGLUniformLocation projectionMatrixLocation;
	private WebGLUniformLocation rotationLocation;
	private WebGLBuffer vposBuffer;
	private WebGLBuffer colorBuffer;
	private int count;
	private int vposLocation;
	private int vcolorLocation;
	
	private Matrix4 projectionMatrix;
	private Matrix4 rotationMatrix = new Matrix4();
	
	public RenderWidget() {
		super();
		
		data = null;
		started = false;
		
		WebGLContextAttributes attribs = WebGLContextAttributes.create();
		attribs.setAlpha(true);
		attribs.setAntialias(true);
		
		canvas = new WebGLCanvas(attribs, "640px", "480px");
		gl = canvas.getGlContext();
		gl.viewport(0, 0, 640, 480);
		
		setWidget(0, 0, canvas);
		
		init();
		drawScene();
	}
	
	public void start() {
		if (started)
			return;
		
		started = true;
		
		Timer timer = new Timer() {
			@Override
			public void run() {
				drawScene();
			}
		};
		timer.scheduleRepeating(50);
	}
	
	private void init() {
		gl.viewport(0, 0, 640, 480);
		gl.clearColor(0.0f, 0.0f, 0.0f, 1.0f);
		gl.clearDepth(1.0f);
		
		gl.enable(WebGLRenderingContext.DEPTH_TEST);
		gl.depthFunc(WebGLRenderingContext.LEQUAL);
		
		initShaders();
		
		projectionMatrix = Matrix4.createPerspectiveMatrix(45.0f, 640.0f / 480.0f, 0.1f, 1000.0f);
	}
	
	private void initShaders() {
		WebGLShader vs = getShader(WebGLRenderingContext.VERTEX_SHADER, Shaders.Instance.defaultShaderVertex());
		WebGLShader fs = getShader(WebGLRenderingContext.FRAGMENT_SHADER, Shaders.Instance.defaultShaderFragment());
		
		programDefault = gl.createProgram();
		gl.attachShader(programDefault, vs);
		gl.attachShader(programDefault, fs);
		gl.linkProgram(programDefault);
		
		if (!gl.getProgramParameterb(programDefault, WebGLRenderingContext.LINK_STATUS))
			Window.alert(gl.getProgramInfoLog(programDefault));
		
		gl.useProgram(programDefault);
		projectionMatrixLocation = gl.getUniformLocation(programDefault, "projection");
		rotationLocation = gl.getUniformLocation(programDefault, "rotation");
		vposLocation = gl.getAttribLocation(programDefault, "position");
		vcolorLocation = gl.getAttribLocation(programDefault, "vertexColor");
	}
	
	private void drawScene() {
		if (data == null)
			return;
		
		gl.clear(WebGLRenderingContext.COLOR_BUFFER_BIT | WebGLRenderingContext.DEPTH_BUFFER_BIT);
		
		gl.viewport(0, 0, canvas.getOffsetWidth(), canvas.getOffsetHeight());
		
		gl.useProgram(programDefault);
		gl.uniformMatrix4fv(projectionMatrixLocation, false, projectionMatrix.getData());
		rotationMatrix.rotateByX(3.0f);
		rotationMatrix.rotateByY(3.0f);
		gl.uniformMatrix4fv(rotationLocation, false, rotationMatrix.getData());
		
		gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, vposBuffer);
		gl.vertexAttribPointer(vposLocation, 3, WebGLRenderingContext.FLOAT, false, 0, 0);
		gl.enableVertexAttribArray(vposLocation);
		
		gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, colorBuffer);
		gl.vertexAttribPointer(vcolorLocation, 4, WebGLRenderingContext.FLOAT, false, 0, 0);
		gl.enableVertexAttribArray(vcolorLocation);
		
		gl.drawArrays(WebGLRenderingContext.TRIANGLES, 0, count);
		
		gl.flush();
	}
	
	public void setData(DataBundle data) {
		this.data = data;
		
		initializeModel();
	}
	
	private void initializeModel() {
		ArrayList<Float> triangles = new ArrayList<Float>();
		ArrayList<Float> colors = new ArrayList<Float>();
		
		count = 0;
		traverseModel(data.getModel().getMainModel(), data.getModel(), new Matrix4(), triangles, colors);
		
		if (triangles.size() == 0) {
			data = null;
			return;
		}
		
		if (vposBuffer != null) {
			gl.deleteBuffer(vposBuffer);
			gl.deleteBuffer(colorBuffer);
		}
		
		float[] triarray = new float[triangles.size()];
		float[] colarray = new float[colors.size()];
		
		for (int i = 0; i < triarray.length; ++i)
			triarray[i] = triangles.get(i);
		for (int i = 0; i < colarray.length; ++i)
			colarray[i] = colors.get(i);
		
		vposBuffer = gl.createBuffer();
		gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, vposBuffer);
		gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, Float32Array.create(triarray), WebGLRenderingContext.STATIC_DRAW);
		
		colorBuffer = gl.createBuffer();
		gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, colorBuffer);
		gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, Float32Array.create(colarray), WebGLRenderingContext.STATIC_DRAW);
	}
	
	private void traverseModel(LDrawModel model, LDrawModelMultipart parent, Matrix4 translationMatrix, ArrayList<Float> triangles, ArrayList<Float> colors) {
		float[] color = { (float)Math.random(), (float)Math.random(), (float)Math.random(), 1.0f };
		
		for (LDrawElementBase e : model) {
			if (e instanceof LDrawElement3) {
				LDrawElement3 e3 = (LDrawElement3)e;
				
				Vector4 nv1 = translationMatrix.translate(e3.getVec1());
				Vector4 nv2 = translationMatrix.translate(e3.getVec2());
				Vector4 nv3 = translationMatrix.translate(e3.getVec3());
				
				triangles.add(nv1.x()); triangles.add(nv1.y()); triangles.add(nv1.z()); 
				triangles.add(nv2.x()); triangles.add(nv2.y()); triangles.add(nv2.z());
				triangles.add(nv3.x()); triangles.add(nv3.y()); triangles.add(nv3.z());
				
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				
				count += 3;
			} else if (e instanceof LDrawElement4) {
				LDrawElement4 e4 = (LDrawElement4)e;
				
				Vector4 nv1 = translationMatrix.translate(e4.getVec1());
				Vector4 nv2 = translationMatrix.translate(e4.getVec2());
				Vector4 nv3 = translationMatrix.translate(e4.getVec3());
				Vector4 nv4 = translationMatrix.translate(e4.getVec4());
				
				triangles.add(nv1.x()); triangles.add(nv1.y()); triangles.add(nv1.z()); 
				triangles.add(nv2.x()); triangles.add(nv2.y()); triangles.add(nv2.z());
				triangles.add(nv3.x()); triangles.add(nv3.y()); triangles.add(nv3.z());
				triangles.add(nv1.x()); triangles.add(nv1.y()); triangles.add(nv1.z()); 
				triangles.add(nv3.x()); triangles.add(nv3.y()); triangles.add(nv3.z());
				triangles.add(nv4.x()); triangles.add(nv4.y()); triangles.add(nv4.z());
				
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				
				count += 6;
			} else if (e instanceof LDrawElement1) {
				LDrawModel m = null;
				
				LDrawElement1 e1 = (LDrawElement1)e;
				String nf = e1.getNormalizedPartId();
				
				if (parent != null)
					m = parent.querySubpart(nf);
				if (m == null) {
					HashMap<String, LDrawModel> list = data.getParts();
					
					if (list.containsKey(nf))
						m = list.get(nf);
					
					parent = null;
				}
				
				if (m != null) {
					System.out.println("Found subelement: " + e1.getPartId());
					System.out.println(e1.getMatrix());
					traverseModel(m, parent, translationMatrix.multiply(e1.getMatrix()), triangles, colors);
				}
			}
		}
	}
	
	private WebGLShader getShader(int type, TextResource file) {
		WebGLShader shader = gl.createShader(type);
		
		gl.shaderSource(shader, file.getText());
		gl.compileShader(shader);
		
		if (!gl.getShaderParameterb(shader, WebGLRenderingContext.COMPILE_STATUS)) {
			Window.alert("Failed to compile shader: " + gl.getShaderInfoLog(shader));
			return null;
		}
		
		return shader;
	}
}
