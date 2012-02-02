package kr.influx.ldrawweb.shared.elements;

public class MetaBfc extends MetaCommandBase {
	private static final long serialVersionUID = 1L;
	
	static final public int CW         = 1 << 1;
	static final public int CCW        = 1 << 2;
	static final public int CLIP       = 1 << 3;   
	static final public int NOCLIP     = 1 << 4;
	static final public int INVERTNEXT = 1 << 5;
	
	static final public int CERTIFY     = (1 << 3) | CCW;
	static final public int CERTIFY_CCW = CERTIFY;
	static final public int CERTIFY_CW  = (1 << 3) | CW;
	
	private int command;
	
	public MetaBfc() {
		super();
		
		this.command = 0;
		
		updateLine();
	}
	
	public MetaBfc(int command) {
		super();
		
		this.command = command;
		
		updateLine();
	}
	
	public int getCommand() {
		return command;
	}
	
	public void setCommand(int command) {
		this.command = command;
		
		updateLine();
	}
	
	private static String renderLine(int command) {
		switch (command) {
		case 0:
			return "";
		case CW:
			return "BFC CW";
		case CCW:
			return "BFC CCW";
		case CLIP:
			return "BFC CLIP";
		case CLIP | CW:
			return "BFC CLIP CW";
		case CLIP | CCW:
			return "BFC CLIP CCW";
		case NOCLIP:
			return "BFC NOCLIP";
		case INVERTNEXT:
			return "BFC INVERTNEXT";
		default:
			return null;
		}
	}
	
	@Override
	protected void updateLine() {
		setString(renderLine(command));
	}
}
