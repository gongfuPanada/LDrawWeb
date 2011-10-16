package kr.influx.ldrawweb.server;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.NoSuchElementException;
import java.util.StringTokenizer;

import kr.influx.ldrawweb.shared.elements.Line0;
import kr.influx.ldrawweb.shared.elements.Line1;
import kr.influx.ldrawweb.shared.elements.Line2;
import kr.influx.ldrawweb.shared.elements.Line3;
import kr.influx.ldrawweb.shared.elements.Line4;
import kr.influx.ldrawweb.shared.elements.Line5;
import kr.influx.ldrawweb.shared.elements.MetaBfc;
import kr.influx.ldrawweb.shared.elements.MetaClear;
import kr.influx.ldrawweb.shared.elements.MetaCommandBase;
import kr.influx.ldrawweb.shared.elements.MetaPause;
import kr.influx.ldrawweb.shared.elements.MetaSave;
import kr.influx.ldrawweb.shared.elements.MetaStep;
import kr.influx.ldrawweb.shared.elements.MetaWrite;
import kr.influx.ldrawweb.shared.exceptions.InvalidFileFormat;
import kr.influx.ldrawweb.shared.LDrawElementBase;
import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.LDrawModelMultipart;
import kr.influx.ldrawweb.shared.Matrix4;
import kr.influx.ldrawweb.shared.Vector4;

public class LDrawReader {
	private BufferedReader br;

	private String filename = null;

	private LDrawModel model;
	private LDrawModelMultipart modelMultipart;

	private boolean parsed;

	public LDrawReader(InputStream stream) {
		br = new BufferedReader(new InputStreamReader(stream));

		parsed = false;

		modelMultipart = null;
		model = null;
	}

	public LDrawReader(String filename, InputStream stream) {
		br = new BufferedReader(new InputStreamReader(stream));

		this.filename = filename;

		parsed = false;

		modelMultipart = null;
		model = null;
	}

	public boolean isParsed() {
		return parsed;
	}

	public LDrawModel getModel() {
		if (!parsed)
			return null;

		return model;
	}

	public LDrawModelMultipart getMultipartModel() {
		if (!parsed)
			return null;

		if (modelMultipart == null)
			return new LDrawModelMultipart(model);

		return modelMultipart;
	}

	public boolean isMultipart() {
		if (!parsed)
			return false;

		if (modelMultipart != null)
			return true;
		else
			return false;
	}

	public boolean parse(boolean parseOnly) throws InvalidFileFormat {
		int l = 0, lc = 0, idx = 0;

		parsed = false;

		model = null;
		modelMultipart = null;

		String fn = null;
		LDrawModel currentModel = null;
		ArrayList<LDrawElementBase> elements = null;

		if (!parseOnly) {
			currentModel = new LDrawModel();
			elements = currentModel.getElements();
		}

		boolean multipart = false;

		try {
			String line = br.readLine();

			while (line != null) {
				LDrawElementBase e = parseLine(line);

				if (e != null) {
					if (parseOnly) {
						++l;
						continue;
					}

					elements.add(e);

					if (e instanceof Line0) {
						String comment = ((Line0) e).getString();
						String commentlc = comment.toLowerCase();

						if (commentlc.startsWith("file "))
							lc = 0;
						else if (lc > 3) {
							line = br.readLine();
							++l;
							continue;
						}

						if (commentlc.startsWith("author: "))
							currentModel.setAuthor(comment.substring(8));
						else if (commentlc.startsWith("name: "))
							currentModel.setName(comment.substring(6));
						else if (commentlc.startsWith("file ")) {
							multipart = true;

							if (modelMultipart == null) {
								modelMultipart = new LDrawModelMultipart();
							}

							/* next subpart */
							if (idx > 0) {
								if (idx == 1) {
									modelMultipart.setMainModel(currentModel);
								} else {
									modelMultipart.putSubpart(fn, currentModel,
											true);
								}

								currentModel = new LDrawModel();
								elements = currentModel.getElements();
							}

							fn = comment.substring(5);

							++idx;
						} else if (commentlc.startsWith("bfc")) {
							if (commentlc.equals("certify"))
								currentModel.setBfcCertification(MetaBfc.CERTIFY);
							else if (commentlc.equals("certify cw"))
								currentModel.setBfcCertification(MetaBfc.CERTIFY_CW);
							else if (commentlc.equals("certify ccw"))
								currentModel.setBfcCertification(MetaBfc.CERTIFY_CCW);
						} else if (lc < 2) {
							currentModel.setDescription(comment);
						} else {
							line = br.readLine();
							++l;
							continue;
						}

						++lc;
					}
				}

				line = br.readLine();
				++l;
			}
		} catch (IOException e) {
			e.printStackTrace();

			return false;
		}

		if (multipart && idx > 0 && !parseOnly) {
			if (idx == 1) {
				if (filename != null)
					currentModel.setName(filename);
				modelMultipart.setMainModel(currentModel);
			} else {
				modelMultipart.putSubpart(fn, currentModel, true);
			}
		} else if (!multipart && !parseOnly) {
			if (filename != null)
				currentModel.setName(filename);
			model = currentModel;
		}

		if (l == 0)
			return false;

		parsed = true;

		return true;
	}

	public LDrawElementBase parseLine(String line) throws InvalidFileFormat {
		String trimmed = line.trim();

		if (trimmed.isEmpty())
			return null;

		try {
			StringTokenizer tk = new StringTokenizer(trimmed);
			int linetype = Integer.parseInt(tk.nextToken());
			LDrawElementBase e = null;

			switch (linetype) {
			case 0:
				e = parseLineMeta(new StringTokenizer(trimmed.substring(2)));
				if (e == null)
					e = parseLineType0(tk);
				break;
			case 1:
				e = parseLineType1(tk);
				break;
			case 2:
				e = parseLineType2(tk);
				break;
			case 3:
				e = parseLineType3(tk);
				break;
			case 4:
				e = parseLineType4(tk);
				break;
			case 5:
				e = parseLineType5(tk);
				break;
			default:
				throw new Exception();
			}

			if (e != null)
				return e;
		} catch (Exception e) {
			throw new InvalidFileFormat(line);
		}

		return null;
	}

	public void close() {
		try {
			br.close();
		} catch (IOException e) {
		} // omittable
	}

	private Line0 parseLineType0(final StringTokenizer tk) {
		String output = "";

		while (tk.hasMoreTokens())
			output += tk.nextToken() + " ";

		String outputc = output.trim().toLowerCase();
		if (outputc == "step")
			return new MetaStep();

		return new Line0(output);
	}

	private Line1 parseLineType1(final StringTokenizer tk) {
		int color;
		float[] matrix = new float[12];
		String filename;

		color = Integer.parseInt(tk.nextToken());
		for (int i = 0; i < 12; ++i)
			matrix[i] = Float.parseFloat(tk.nextToken());

		filename = tk.nextToken();
		while (tk.hasMoreTokens())
			/* in case of filename with space(s) */
			filename += " " + tk.nextToken();

		return new Line1(color, new Matrix4(matrix), filename);
	}

	private Line2 parseLineType2(final StringTokenizer tk) {
		int color;
		float[] vec1 = new float[3];
		float[] vec2 = new float[3];

		color = Integer.parseInt(tk.nextToken());
		for (int i = 0; i < 3; ++i)
			vec1[i] = Float.parseFloat(tk.nextToken());
		for (int i = 0; i < 3; ++i)
			vec2[i] = Float.parseFloat(tk.nextToken());

		return new Line2(color, new Vector4(vec1), new Vector4(vec2));
	}

	private Line3 parseLineType3(final StringTokenizer tk) {
		int color;
		float[] vec1 = new float[3];
		float[] vec2 = new float[3];
		float[] vec3 = new float[3];

		color = Integer.parseInt(tk.nextToken());
		for (int i = 0; i < 3; ++i)
			vec1[i] = Float.parseFloat(tk.nextToken());
		for (int i = 0; i < 3; ++i)
			vec2[i] = Float.parseFloat(tk.nextToken());
		for (int i = 0; i < 3; ++i)
			vec3[i] = Float.parseFloat(tk.nextToken());

		return new Line3(color, new Vector4(vec1), new Vector4(vec2),
				new Vector4(vec3));
	}

	private Line4 parseLineType4(final StringTokenizer tk) {
		int color;
		float[] vec1 = new float[3];
		float[] vec2 = new float[3];
		float[] vec3 = new float[3];
		float[] vec4 = new float[3];

		color = Integer.parseInt(tk.nextToken());
		for (int i = 0; i < 3; ++i)
			vec1[i] = Float.parseFloat(tk.nextToken());
		for (int i = 0; i < 3; ++i)
			vec2[i] = Float.parseFloat(tk.nextToken());
		for (int i = 0; i < 3; ++i)
			vec3[i] = Float.parseFloat(tk.nextToken());
		for (int i = 0; i < 3; ++i)
			vec4[i] = Float.parseFloat(tk.nextToken());

		return new Line4(color, new Vector4(vec1), new Vector4(vec2),
				new Vector4(vec3), new Vector4(vec4));
	}

	private Line5 parseLineType5(final StringTokenizer tk) {
		int color;
		float[] vec1 = new float[3];
		float[] vec2 = new float[3];
		float[] vec3 = new float[3];
		float[] vec4 = new float[3];

		color = Integer.parseInt(tk.nextToken());
		for (int i = 0; i < 3; ++i)
			vec1[i] = Float.parseFloat(tk.nextToken());
		for (int i = 0; i < 3; ++i)
			vec2[i] = Float.parseFloat(tk.nextToken());
		for (int i = 0; i < 3; ++i)
			vec3[i] = Float.parseFloat(tk.nextToken());
		for (int i = 0; i < 3; ++i)
			vec4[i] = Float.parseFloat(tk.nextToken());

		return new Line5(color, new Vector4(vec1), new Vector4(vec2),
				new Vector4(vec3), new Vector4(vec4));
	}
	
	private MetaCommandBase parseLineMeta(final StringTokenizer tk) {
		String token = tk.nextToken();
		
		if (token.equals("BFC"))
			return parseLineMetaBfc(tk);
		else if (token.equals("CLEAR"))
			return new MetaClear();
		else if (token.equals("PAUSE"))
			return new MetaPause();
		else if (token.equals("SAVE"))
			return new MetaSave();
		else if (token.equals("STEP"))
			return new MetaStep();
		else if (token.equals("WRITE") || token.equals("PRINT"))
			return parseLineMetaWrite(tk);
		
		return null;
	}
	
	private MetaBfc parseLineMetaBfc(final StringTokenizer tk) {
		int command = 0;
		
		String token = tk.nextToken();
		if (token.equals("CW"))
			command = MetaBfc.CW;
		else if (token.equals("CCW"))
			command = MetaBfc.CCW;
		else if (token.equals("NOCLIP"))
			command = MetaBfc.NOCLIP;
		else if (token.equals("INVERTNEXT"))
			command = MetaBfc.INVERTNEXT;
		else if (token.equals("CLIP")) {
			try {
				String next = tk.nextToken();
				
				if (next.equals("CW"))
					command = MetaBfc.CLIP | MetaBfc.CW;
				else if (next.equals("CCW"))
					command = MetaBfc.CLIP | MetaBfc.CCW;
			} catch (NoSuchElementException e) {
				command = MetaBfc.CLIP;
			}
		}
		
		if (command == 0)
			return null;
		else
			return new MetaBfc(command);
	}
	
	private MetaWrite parseLineMetaWrite(final StringTokenizer tk) {
		String output = "";
		
		while (tk.hasMoreTokens())
			output += tk.nextToken();
		
		return new MetaWrite(output);
	}
}
