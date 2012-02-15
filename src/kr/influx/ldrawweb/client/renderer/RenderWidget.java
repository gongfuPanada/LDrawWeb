package kr.influx.ldrawweb.client.renderer;

import java.util.ArrayList;
import java.util.Map;
import java.util.Stack;

import kr.influx.ldrawweb.shared.DataBundle;
import kr.influx.ldrawweb.shared.LDrawColorTable;
import kr.influx.ldrawweb.shared.LDrawElementBase;
import kr.influx.ldrawweb.shared.LDrawMaterialBase;
import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.LDrawModelMultipart;
import kr.influx.ldrawweb.shared.Matrix4;
import kr.influx.ldrawweb.shared.Vector3;
import kr.influx.ldrawweb.shared.Vector4;
import kr.influx.ldrawweb.shared.elements.Line1;
import kr.influx.ldrawweb.shared.elements.Line3;
import kr.influx.ldrawweb.shared.elements.Line4;
import kr.influx.ldrawweb.shared.materials.BasicMaterial;
import kr.influx.ldrawweb.shared.materials.DefaultColor;
import kr.influx.ldrawweb.shared.materials.EdgeColor;

import com.google.gwt.canvas.client.Canvas;
import com.google.gwt.resources.client.TextResource;
import com.google.gwt.user.client.Timer;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.FlexTable;
import com.googlecode.gwtgl.array.Float32Array;
import com.googlecode.gwtgl.binding.WebGLBuffer;
import com.googlecode.gwtgl.binding.WebGLContextAttributes;
import com.googlecode.gwtgl.binding.WebGLProgram;
import com.googlecode.gwtgl.binding.WebGLRenderingContext;
import com.googlecode.gwtgl.binding.WebGLShader;
import com.googlecode.gwtgl.binding.WebGLUniformLocation;

public class RenderWidget extends FlexTable {
	private final Canvas canvas;
	private final WebGLRenderingContext gl;
	
	private DataBundle data;
	private boolean started;
	
	private WebGLProgram programDefault;
	private WebGLUniformLocation projectionMatrixLocation;
	private WebGLUniformLocation rotationLocation;
	private WebGLBuffer vposBuffer;
	private WebGLBuffer colorBuffer;
	private WebGLBuffer normalBuffer;
	private int count;
	private int vposLocation;
	private int vcolorLocation;
	private int normalLocation;
	
	private Matrix4 projectionMatrix;
	private Matrix4 rotationMatrix = new Matrix4();
	
	public RenderWidget() {
		super();
		
		data = null;
		started = false;
		
		WebGLContextAttributes attribs = WebGLContextAttributes.create();
		attribs.setAlpha(true);
		attribs.setAntialias(true);
		
		canvas = Canvas.createIfSupported();
		canvas.setCoordinateSpaceWidth(640);
		canvas.setCoordinateSpaceHeight(480);
		gl = (WebGLRenderingContext) canvas.getContext("experimental-webgl");
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
		gl.enable(WebGLRenderingContext.BLEND);
		gl.depthFunc(WebGLRenderingContext.LEQUAL);
		gl.blendFunc(WebGLRenderingContext.SRC_ALPHA, WebGLRenderingContext.ONE_MINUS_SRC_ALPHA);
		
		initShaders();
		
		rotationMatrix.rotateByX(180.0f);
		
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
		normalLocation = gl.getAttribLocation(programDefault, "normal");
	}
	
	private void drawScene() {
		if (data == null)
			return;
		
		gl.clear(WebGLRenderingContext.COLOR_BUFFER_BIT | WebGLRenderingContext.DEPTH_BUFFER_BIT);
		
		gl.viewport(0, 0, canvas.getOffsetWidth(), canvas.getOffsetHeight());
		
		gl.useProgram(programDefault);
		gl.uniformMatrix4fv(projectionMatrixLocation, false, projectionMatrix.getData());
		//rotationMatrix.rotateByX(3.0f);
		rotationMatrix.rotateByY(3.0f);
		gl.uniformMatrix4fv(rotationLocation, false, rotationMatrix.getData());
		
		gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, vposBuffer);
		gl.vertexAttribPointer(vposLocation, 3, WebGLRenderingContext.FLOAT, false, 0, 0);
		gl.enableVertexAttribArray(vposLocation);
		
		gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, colorBuffer);
		gl.vertexAttribPointer(vcolorLocation, 4, WebGLRenderingContext.FLOAT, false, 0, 0);
		gl.enableVertexAttribArray(vcolorLocation);
		
		gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, normalBuffer);
		gl.vertexAttribPointer(normalLocation, 3, WebGLRenderingContext.FLOAT, false, 0, 0);
		gl.enableVertexAttribArray(normalLocation);
		
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
		ArrayList<Float> normals = new ArrayList<Float>();
		Stack<LDrawMaterialBase> colorStack = new Stack<LDrawMaterialBase>();
		
		colorStack.push(LDrawColorTable.lookup(0));
		
		count = 0;
		traverseModel(data.getModel().getMainModel(), data.getModel(), new Matrix4(), triangles, colors, normals, LDrawColorTable.lookup(7), false);
		
		if (triangles.size() == 0) {
			data = null;
			return;
		}
		
		if (vposBuffer != null) {
			gl.deleteBuffer(vposBuffer);
			gl.deleteBuffer(colorBuffer);
			gl.deleteBuffer(normalBuffer);
		}
		
		float[] triarray = new float[triangles.size()];
		float[] colarray = new float[colors.size()];
		float[] normalarray = new float[normals.size()];
		
		for (int i = 0; i < triarray.length; ++i)
			triarray[i] = triangles.get(i);
		for (int i = 0; i < colarray.length; ++i)
			colarray[i] = colors.get(i);
		for (int i = 0; i < normalarray.length; ++i)
			normalarray[i] = normals.get(i);
		
		vposBuffer = gl.createBuffer();
		gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, vposBuffer);
		gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, Float32Array.create(triarray), WebGLRenderingContext.STATIC_DRAW);
		
		colorBuffer = gl.createBuffer();
		gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, colorBuffer);
		gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, Float32Array.create(colarray), WebGLRenderingContext.STATIC_DRAW);
		
		normalBuffer = gl.createBuffer();
		gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, normalBuffer);
		gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, Float32Array.create(normalarray), WebGLRenderingContext.STATIC_DRAW);
		
	}
	
	private Vector3 calculateNormal(Vector4 a, Vector4 b, Vector4 c) {
		Vector3 d1, d2;
		
		d1 = Vector3.sub(b, a);
		d2 = Vector3.sub(c, b);
		
		return Vector3.cross(d1, d2);
	}
	
	private void traverseModel(LDrawModel model, LDrawModelMultipart parent, Matrix4 translationMatrix, ArrayList<Float> triangles, ArrayList<Float> colors, ArrayList<Float> normals, LDrawMaterialBase material, boolean edgeFlag) {
		float[] color;
		
		if (material instanceof BasicMaterial) {
			if (edgeFlag)
				color = ((BasicMaterial)material).getEdgeColor().getArray();
			else
				color = ((BasicMaterial)material).getColor().getArray();
		} else {
			color = new float[] {1.0f, 1.0f, 1.0f, 1.0f};
		}
		
		for (LDrawElementBase e : model) {
			if (e instanceof Line3) {
				Line3 e3 = (Line3)e;
				
				Vector4 nv1 = translationMatrix.translate(e3.getVec1());
				Vector4 nv2 = translationMatrix.translate(e3.getVec2());
				Vector4 nv3 = translationMatrix.translate(e3.getVec3());
				
				Vector3 normal = calculateNormal(nv1, nv2, nv3);
				
				triangles.add(nv1.x()); triangles.add(nv1.y()); triangles.add(nv1.z()); 
				triangles.add(nv2.x()); triangles.add(nv2.y()); triangles.add(nv2.z());
				triangles.add(nv3.x()); triangles.add(nv3.y()); triangles.add(nv3.z());
				
				normals.add(normal.x()); normals.add(normal.y()); normals.add(normal.z());
				normals.add(normal.x()); normals.add(normal.y()); normals.add(normal.z());
				normals.add(normal.x()); normals.add(normal.y()); normals.add(normal.z());
				
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				
				count += 3;
			} else if (e instanceof Line4) {
				Line4 e4 = (Line4)e;
				
				Vector4 nv1 = translationMatrix.translate(e4.getVec1());
				Vector4 nv2 = translationMatrix.translate(e4.getVec2());
				Vector4 nv3 = translationMatrix.translate(e4.getVec3());
				Vector4 nv4 = translationMatrix.translate(e4.getVec4());
				
				Vector3 normal = calculateNormal(nv1, nv2, nv3);
				
				triangles.add(nv1.x()); triangles.add(nv1.y()); triangles.add(nv1.z()); 
				triangles.add(nv2.x()); triangles.add(nv2.y()); triangles.add(nv2.z());
				triangles.add(nv3.x()); triangles.add(nv3.y()); triangles.add(nv3.z());
				triangles.add(nv1.x()); triangles.add(nv1.y()); triangles.add(nv1.z()); 
				triangles.add(nv3.x()); triangles.add(nv3.y()); triangles.add(nv3.z());
				triangles.add(nv4.x()); triangles.add(nv4.y()); triangles.add(nv4.z());
				
				normals.add(normal.x()); normals.add(normal.y()); normals.add(normal.z());
				normals.add(normal.x()); normals.add(normal.y()); normals.add(normal.z());
				normals.add(normal.x()); normals.add(normal.y()); normals.add(normal.z());
				normals.add(normal.x()); normals.add(normal.y()); normals.add(normal.z());
				normals.add(normal.x()); normals.add(normal.y()); normals.add(normal.z());
				normals.add(normal.x()); normals.add(normal.y()); normals.add(normal.z());
				
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				colors.add(color[0]); colors.add(color[1]); colors.add(color[2]); colors.add(color[3]);
				
				count += 6;
			} else if (e instanceof Line1) {
				LDrawModel m = null;
				
				Line1 e1 = (Line1)e;
				String nf = e1.getNormalizedPartId();
				
				if (parent != null)
					m = parent.querySubpart(nf);
				if (m == null) {
					Map<String, LDrawModel> list = data.getParts();
					
					if (list.containsKey(nf))
						m = list.get(nf);
					
					parent = null;
				}
				
				if (m != null) {
					System.out.println("Found subelement: " + e1.getPartId());
					System.out.println(e1.getMatrix());
					
					LDrawMaterialBase mat = e1.getColorObject();
					LDrawMaterialBase cmat;
					boolean edge = false;
					
					if (mat instanceof DefaultColor) {
						cmat = material;
					} else if (mat instanceof EdgeColor) {
						cmat = material;
						edge = true;
					} else {
						cmat = mat;
					}
					
					traverseModel(m, parent, translationMatrix.multiply(e1.getMatrix()), triangles, colors, normals, cmat, edge);
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
