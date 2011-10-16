package kr.influx.ldrawweb.shared;

import java.util.HashMap;

import kr.influx.ldrawweb.shared.materials.*;

public class LDrawColorTable {
	public final static ColorRgba DEFAULT_EDGE_COLOR = new ColorRgba(0x33, 0x33, 0x33);
	
	private static LDrawMaterialBase materialList[];
	private static HashMap<Integer, LDrawMaterialBase> materialTable;
	
	static {
		/* one big material list */
		materialList = new LDrawMaterialBase[] {
			/* Meta */
			new DefaultColor(),
			new EdgeColor(),
				
			/* Solid materials */
			new Solid(  0, "Black"                 , new ColorRgba(0x21, 0x21, 0x21), new ColorRgba(0x59, 0x59, 0x59)),
			new Solid(  1, "Blue"                  , new ColorRgba(0x00, 0x33, 0xb2), DEFAULT_EDGE_COLOR),
			new Solid(  2, "Green"                 , new ColorRgba(0x00, 0x8c, 0x14), DEFAULT_EDGE_COLOR),
			new Solid(  3, "Dark Turquoise"        , new ColorRgba(0x00, 0x99, 0x9f), DEFAULT_EDGE_COLOR),
			new Solid(  4, "Red"                   , new ColorRgba(0xc4, 0x00, 0x26), DEFAULT_EDGE_COLOR),
			new Solid(  5, "Dark Pink"             , new ColorRgba(0xdf, 0x66, 0x95), DEFAULT_EDGE_COLOR),
			new Solid(  6, "Brown"                 , new ColorRgba(0x5c, 0x20, 0x00), DEFAULT_EDGE_COLOR),
			new Solid(  7, "Light Gray"            , new ColorRgba(0x9c, 0x99, 0x99), DEFAULT_EDGE_COLOR),
			new Solid(  8, "Dark Gray"             , new ColorRgba(0x63, 0x5f, 0x52), DEFAULT_EDGE_COLOR),
			new Solid(  9, "Light Blue"            , new ColorRgba(0x6b, 0xab, 0xdc), DEFAULT_EDGE_COLOR),
			new Solid( 10, "Bright Green"          , new ColorRgba(0x6b, 0xee, 0x90), DEFAULT_EDGE_COLOR),
			new Solid( 11, "Light Turquoise"       , new ColorRgba(0x33, 0xa6, 0xa7), DEFAULT_EDGE_COLOR),
			new Solid( 12, "Salmon"                , new ColorRgba(0xff, 0x85, 0x7a), DEFAULT_EDGE_COLOR),
			new Solid( 13, "Pink"                  , new ColorRgba(0xf9, 0xa4, 0xc6), DEFAULT_EDGE_COLOR),
			new Solid( 14, "Yellow"                , new ColorRgba(0xff, 0xdc, 0x00), DEFAULT_EDGE_COLOR),
			new Solid( 15, "White"                 , new ColorRgba(0xff, 0xff, 0xff), DEFAULT_EDGE_COLOR),
			new Solid( 17, "Light Green"           , new ColorRgba(0xba, 0xff, 0xce), DEFAULT_EDGE_COLOR),
			new Solid( 18, "Light Yellow"          , new ColorRgba(0xfd, 0xe8, 0x96), DEFAULT_EDGE_COLOR),
			new Solid( 19, "Tan"                   , new ColorRgba(0xe8, 0xcf, 0xa1), DEFAULT_EDGE_COLOR),
			new Solid( 20, "Light Violet"          , new ColorRgba(0xd7, 0xc4, 0xe6), DEFAULT_EDGE_COLOR),
			new Solid( 22, "Purple"                , new ColorRgba(0x81, 0x00, 0x7b), DEFAULT_EDGE_COLOR),
			new Solid( 23, "Dark Blue Violet"      , new ColorRgba(0x47, 0x32, 0xb0), new ColorRgba(0x1e, 0x1e, 0x1e)),
			new Solid( 25, "Orange"                , new ColorRgba(0xf9, 0x60, 0x00), DEFAULT_EDGE_COLOR),
			new Solid( 26, "Magenta"               , new ColorRgba(0xd8, 0x1b, 0x6d), DEFAULT_EDGE_COLOR),
			new Solid( 27, "Lime"                  , new ColorRgba(0xd7, 0xf0, 0x00), DEFAULT_EDGE_COLOR),
			new Solid( 28, "Dark Tan"              , new ColorRgba(0xc5, 0x97, 0x50), DEFAULT_EDGE_COLOR),
			new Solid( 29, "Bright Pink"           , new ColorRgba(0xe4, 0xad, 0xc8), DEFAULT_EDGE_COLOR),
			new Solid( 68, "Very Light Orange"     , new ColorRgba(0xf3, 0xcf, 0x9b), DEFAULT_EDGE_COLOR),
			new Solid( 69, "Light Purple"          , new ColorRgba(0xcd, 0x62, 0x98), DEFAULT_EDGE_COLOR),
			new Solid( 70, "Reddish Brown"         , new ColorRgba(0x69, 0x40, 0x27), DEFAULT_EDGE_COLOR),
			new Solid( 71, "Light Bluish Gray"     , new ColorRgba(0xa3, 0xa2, 0xa4), DEFAULT_EDGE_COLOR),
			new Solid( 72, "Dark Bluish Gray"      , new ColorRgba(0x63, 0x5f, 0x61), DEFAULT_EDGE_COLOR),
			new Solid( 73, "Medium Blue"           , new ColorRgba(0x6e, 0x99, 0xc9), DEFAULT_EDGE_COLOR),
			new Solid( 74, "Medium Green"          , new ColorRgba(0xa1, 0xc4, 0x8b), DEFAULT_EDGE_COLOR),
			new Solid( 77, "Light Pink"            , new ColorRgba(0xfe, 0xcc, 0xcc), DEFAULT_EDGE_COLOR),
			new Solid( 78, "Light Flesh"           , new ColorRgba(0xfa, 0xd7, 0xc3), DEFAULT_EDGE_COLOR),
			new Solid( 85, "Dark Purple"           , new ColorRgba(0x34, 0x2b, 0x75), new ColorRgba(0x1e, 0x1e, 0x1e)),
			new Solid( 86, "Dark Flesh"            , new ColorRgba(0x7c, 0x5c, 0x45), DEFAULT_EDGE_COLOR),
			new Solid( 89, "Blue Violet"           , new ColorRgba(0x6c, 0x81, 0xb7), DEFAULT_EDGE_COLOR),
			new Solid( 92, "Flesh"                 , new ColorRgba(0xcc, 0x8e, 0x68), DEFAULT_EDGE_COLOR),
			new Solid(100, "Light Salmon"          , new ColorRgba(0xee, 0xc4, 0xb6), DEFAULT_EDGE_COLOR),
			new Solid(110, "Violet"                , new ColorRgba(0x43, 0x54, 0x93), DEFAULT_EDGE_COLOR),
			new Solid(112, "Medium Violet"         , new ColorRgba(0x68, 0x74, 0xac), DEFAULT_EDGE_COLOR),
			new Solid(115, "Medium Lime"           , new ColorRgba(0xc7, 0xd2, 0x3c), DEFAULT_EDGE_COLOR),
			new Solid(118, "Aqua"                  , new ColorRgba(0xb7, 0xd7, 0xd5), DEFAULT_EDGE_COLOR),
			new Solid(120, "Light Lime"            , new ColorRgba(0xd9, 0xe4, 0xa7), DEFAULT_EDGE_COLOR),
			new Solid(125, "Light Orange"          , new ColorRgba(0xea, 0xb8, 0x91), DEFAULT_EDGE_COLOR),
			new Solid(151, "Very Light Bluish Gray", new ColorRgba(0xe5, 0xe4, 0xde), DEFAULT_EDGE_COLOR),
			new Solid(191, "Bright Light Orange"   , new ColorRgba(0xe8, 0xab, 0x2d), DEFAULT_EDGE_COLOR),
			new Solid(212, "Bright Light Blue"     , new ColorRgba(0x9f, 0xc3, 0xe9), DEFAULT_EDGE_COLOR),
			new Solid(216, "Rust"                  , new ColorRgba(0x8f, 0x4c, 0x2a), DEFAULT_EDGE_COLOR),
			new Solid(226, "Bright Light Yellow"   , new ColorRgba(0xfd, 0xea, 0x8c), DEFAULT_EDGE_COLOR),
			new Solid(232, "Sky Blue"              , new ColorRgba(0x7d, 0xbb, 0xdd), DEFAULT_EDGE_COLOR),
			new Solid(272, "Dark Blue"             , new ColorRgba(0x00, 0x1d, 0x68), new ColorRgba(0x1e, 0x1e, 0x1e)),
			new Solid(288, "Dark Green"            , new ColorRgba(0x27, 0x46, 0x2c), DEFAULT_EDGE_COLOR),
			new Solid(308, "Dark Brown"            , new ColorRgba(0x35, 0x21, 0x00), new ColorRgba(0x00, 0x00, 0x00)),
			new Solid(313, "Maersk Blue"           , new ColorRgba(0x35, 0xa2, 0x8d), DEFAULT_EDGE_COLOR),
			new Solid(320, "Dark Red"              , new ColorRgba(0x78, 0x00, 0x1c), new ColorRgba(0x59, 0x59, 0x59)),
			new Solid(335, "Sand Red"              , new ColorRgba(0xbf, 0x87, 0x82), DEFAULT_EDGE_COLOR),
			new Solid(366, "Earth Orange"          , new ColorRgba(0xd1, 0x83, 0x04), DEFAULT_EDGE_COLOR),
			new Solid(373, "Sand Purple"           , new ColorRgba(0x84, 0x5e, 0x84), DEFAULT_EDGE_COLOR),
			new Solid(378, "Sand Green"            , new ColorRgba(0xa0, 0xbc, 0xac), DEFAULT_EDGE_COLOR),
			new Solid(379, "Sand Blue"             , new ColorRgba(0x6a, 0x7a, 0x96), DEFAULT_EDGE_COLOR),
			new Solid(462, "Medium Orange"         , new ColorRgba(0xfe, 0x9f, 0x06), DEFAULT_EDGE_COLOR),
			new Solid(484, "Dark Orange"           , new ColorRgba(0xb3, 0x3e, 0x00), DEFAULT_EDGE_COLOR),
			new Solid(503, "Very Light Gray"       , new ColorRgba(0xe6, 0xe3, 0xda), DEFAULT_EDGE_COLOR),
			
			/* Transparent materials */
			new Transparent( 32, "Trans Dark Black"             , new ColorRgba(0x00, 0x00, 0x00, 220), new ColorRgba(0x00, 0x00, 0x00)),
			new Transparent( 33, "Trans Dark Blue"              , new ColorRgba(0x00, 0x20, 0xa0, 128), new ColorRgba(0x00, 0x00, 0x64)),
			new Transparent( 34, "Trans Green"                  , new ColorRgba(0x06, 0x64, 0x32, 128), new ColorRgba(0x00, 0x28, 0x00)),
			new Transparent( 36, "Trans Red"                    , new ColorRgba(0xc4, 0x00, 0x26, 128), new ColorRgba(0x88, 0x00, 0x00)),
			new Transparent( 37, "Trans Purple"                 , new ColorRgba(0x64, 0x00, 0x61, 128), new ColorRgba(0x28, 0x00, 0x25)),
			new Transparent( 40, "Trans Black"                  , new ColorRgba(0x63, 0x5f, 0x52, 128), new ColorRgba(0x27, 0x23, 0x16)),
			new Transparent( 41, "Trans Light Blue"             , new ColorRgba(0xae, 0xef, 0xec, 128), new ColorRgba(0x72, 0xb3, 0xb0)),
			new Transparent( 42, "Trans Neon Green"             , new ColorRgba(0xc0, 0xff, 0x00, 128), new ColorRgba(0x84, 0xc3, 0x00)),
			new Transparent( 43, "Trans Very Light Blue"        , new ColorRgba(0xc1, 0xdf, 0xf0, 128), new ColorRgba(0x85, 0xa3, 0xb4)),
			new Transparent( 45, "Trans Dark Pink"              , new ColorRgba(0xdf, 0x66, 0x95, 128), new ColorRgba(0xa3, 0x2a, 0x59)),
			new Transparent( 46, "Trans Yellow"                 , new ColorRgba(0xca, 0xb0, 0x00, 128), new ColorRgba(0x8e, 0x74, 0x00)),
			new Transparent( 47, "Trans Clear"                  , new ColorRgba(0xff, 0xff, 0xff, 128), new ColorRgba(0xc3, 0xc3, 0xc3)),
			new Transparent( 57, "Trans Neon Orange"            , new ColorRgba(0xf9, 0x60, 0x00, 128), new ColorRgba(0xbd, 0x24, 0x00)),
			new Transparent(143, "Trans Neon Blue"              , new ColorRgba(0xcf, 0xe2, 0xf7, 128), new ColorRgba(0x93, 0xa6, 0xbb)),
			new Transparent(157, "Trans Neon Yellow"            , new ColorRgba(0xff, 0xf6, 0x7b, 128), new ColorRgba(0xc3, 0xba, 0x3f)),
			new Transparent(182, "Trans Orange"                 , new ColorRgba(0xe0, 0x98, 0x64, 128), new ColorRgba(0xa4, 0x5c, 0x28)),
			new Transparent(227, "Trans Bright Green"           , new ColorRgba(0xd9, 0xe4, 0xa7, 128), new ColorRgba(0x9d, 0xa8, 0x6b)),
			new Transparent(228, "Trans Medium Blue"            , new ColorRgba(0x55, 0xa5, 0xaf, 128), new ColorRgba(0x19, 0x69, 0x73)),
			new Transparent(230, "Trans Pink"                   , new ColorRgba(0xe4, 0xad, 0xc8, 128), new ColorRgba(0xa8, 0x71, 0x8c)),
			new Transparent(231, "Trans Light Orange"           , new ColorRgba(0xe8, 0xab, 0x2d, 128), new ColorRgba(0xac, 0x6f, 0x00)),
			new Transparent(234, "Trans Light Yellow"           , new ColorRgba(0xf9, 0xd6, 0x2e, 128), new ColorRgba(0xbd, 0x9a, 0x00)),
			new Transparent(236, "Trans Light Purple"           , new ColorRgba(0x96, 0x70, 0x9f, 128), new ColorRgba(0x5a, 0x34, 0x63)),
			new Transparent(284, "TLG Transparent Reddish Lilac", new ColorRgba(0xe0, 0xd0, 0xe5, 128), new ColorRgba(0xa4, 0x94, 0xa9)),
			
			/* Glitter materials */
			new Glitter(114, "Glitter Trans Dark Pink"   , new ColorRgba(0xdf, 0x66, 0x95, 128), new ColorRgba(0x9a, 0x2a, 0x66), new ColorRgba(0x92, 0x39, 0x78), 0.17f, 0.2f, 1.0f),
			new Glitter(117, "Glitter Trans Clear"       , new ColorRgba(0xff, 0xff, 0xff, 128), new ColorRgba(0xc3, 0xc3, 0xc3), new ColorRgba(0xff, 0xff, 0xff), 0.08f, 0.1f, 1.0f),
			new Glitter(129, "Glitter Trans Trans Purple", new ColorRgba(0x64, 0x00, 0x61, 128), new ColorRgba(0x28, 0x00, 0x25), new ColorRgba(0x8c, 0x00, 0xff), 0.3f , 0.4f, 1.0f),
			
			/* Milky materials */
			new Milky( 21, "Glow In Dark Opaque", new ColorRgba(0xe0, 0xff, 0xb0, 250), new ColorRgba(0xa4, 0xc3, 0x74), 15.0f),
			new Milky( 79, "Milky White"        , new ColorRgba(0xff, 0xff, 0xff, 224), new ColorRgba(0xc3, 0xc3, 0xc3),  0.0f),
			new Milky(294, "Glow In Dark Trans" , new ColorRgba(0xbd, 0xc6, 0xad, 250), new ColorRgba(0x81, 0x8a, 0x71), 15.0f),
			
			/* Pearl materials */
			new Pearl(134, "Copper"               , new ColorRgba(0xae, 0x7a, 0x59), DEFAULT_EDGE_COLOR),
			new Pearl(135, "Pearl Light Gray"     , new ColorRgba(0x9c, 0xa3, 0xa8), DEFAULT_EDGE_COLOR),
			new Pearl(137, "Metal Blue"           , new ColorRgba(0x79, 0x88, 0xa1), DEFAULT_EDGE_COLOR),
			new Pearl(142, "Pearl Light Gold"     , new ColorRgba(0xdc, 0xbc, 0x81), DEFAULT_EDGE_COLOR),
			new Pearl(148, "Pearl Dark Gray"      , new ColorRgba(0x57, 0x58, 0x57), DEFAULT_EDGE_COLOR),
			new Pearl(150, "Pearl Very Light Gray", new ColorRgba(0xab, 0xad, 0xac), DEFAULT_EDGE_COLOR),
			new Pearl(178, "Flat Dark Gold"       , new ColorRgba(0xb4, 0x84, 0x55), DEFAULT_EDGE_COLOR),
			new Pearl(179, "Flat Silver"          , new ColorRgba(0x89, 0x87, 0x88), DEFAULT_EDGE_COLOR),
			new Pearl(183, "Pearl White"          , new ColorRgba(0xf2, 0xf3, 0xf2), DEFAULT_EDGE_COLOR),
			new Pearl(297, "Pearl Gold"           , new ColorRgba(0xaa, 0x7f, 0x2e), DEFAULT_EDGE_COLOR),
			
			/* Chrome materials */
			new Chrome( 60, "Chrome Antique Brass", new ColorRgba(0x64, 0x5a, 0x4c), new ColorRgba(0x28, 0x1e, 0x10)),
			new Chrome( 61, "Chrome Blue"         , new ColorRgba(0x5c, 0x66, 0xa4), new ColorRgba(0x20, 0x2a, 0x68)),
			new Chrome( 62, "Chrome Green"        , new ColorRgba(0x3c, 0xb3, 0x71), new ColorRgba(0x00, 0x77, 0x35)),
			new Chrome( 63, "Chrome Pink"         , new ColorRgba(0xaa, 0x4d, 0x8e), new ColorRgba(0x6e, 0x11, 0x52)),
			new Chrome( 64, "Chrome Black"        , new ColorRgba(0x1b, 0x2a, 0x34), new ColorRgba(0x00, 0x00, 0x00)),
			new Chrome(334, "Chrome Gold"         , new ColorRgba(0xe1, 0x6e, 0x13), new ColorRgba(0xa5, 0x32, 0x00)),
			new Chrome(383, "Chrome Silver"       , new ColorRgba(0xe0, 0xe0, 0xe0), new ColorRgba(0xa4, 0xa4, 0xa4)),
			
			/* Metal core materials */
			new MetalCore(494, "Electric Contact Alloy" , new ColorRgba(0xd0, 0xd0, 0xd0), new ColorRgba(0x6e, 0x6e, 0x6e)),
			new MetalCore(495, "Electric Contact Copper", new ColorRgba(0xae, 0x7a, 0x59), new ColorRgba(0x72, 0x3e, 0x1d)),
			
			/* Metallic materials */
			new Metallic(147, "Metallic Gold"  , new ColorRgba(0x93, 0x87, 0x67), DEFAULT_EDGE_COLOR),
			new Metallic(186, "Metallic Green" , new ColorRgba(0x28, 0x7f, 0x46), DEFAULT_EDGE_COLOR),
			new Metallic(496, "Metallic Silver", new ColorRgba(0xc0, 0xc0, 0xc0), DEFAULT_EDGE_COLOR),
			
			/* Rubber materials */
			new Rubber( 65, "Rubber Yellow"      , new ColorRgba(0xf5, 0xcd, 0x2f, 255), DEFAULT_EDGE_COLOR),
			new Rubber( 66, "Rubber Trans Yellow", new ColorRgba(0xca, 0xb0, 0x00, 128), new ColorRgba(0x8e, 0x74, 0x00)),
			new Rubber( 67, "Rubber Trans Clear" , new ColorRgba(0xff, 0xff, 0xff, 128), new ColorRgba(0xc3, 0xc3, 0xc3)),
			new Rubber(256, "Rubber Black"       , new ColorRgba(0x21, 0x21, 0x21, 255), DEFAULT_EDGE_COLOR),
			new Rubber(273, "Rubber Blue"        , new ColorRgba(0x00, 0x33, 0xb2, 255), DEFAULT_EDGE_COLOR),
			new Rubber(324, "Rubber Red"         , new ColorRgba(0xc4, 0x00, 0x26, 255), DEFAULT_EDGE_COLOR),
			new Rubber(375, "Rubber Light Gray"  , new ColorRgba(0xc1, 0xc2, 0xc1, 255), DEFAULT_EDGE_COLOR),
			new Rubber(511, "Rubber White"       , new ColorRgba(0xff, 0xff, 0xff, 255), DEFAULT_EDGE_COLOR),
			
			/* Speckle materials */
			new Speckle( 75, "Speckle Black Copper"           , new ColorRgba(0x00, 0x00, 0x00), new ColorRgba(0x59, 0x59, 0x59), new ColorRgba(0xae, 0x7a, 0x59), 0.4f, 1.0f, 3.0f),
			new Speckle( 76, "Speckle Dark Bluish Gray Silver", new ColorRgba(0x63, 0x5f, 0x61), new ColorRgba(0x59, 0x59, 0x59), new ColorRgba(0x59, 0x59, 0x59), 0.4f, 1.0f, 3.0f),
			new Speckle(132, "Speckle Black Copper"           , new ColorRgba(0x00, 0x00, 0x00), new ColorRgba(0x59, 0x59, 0x59), new ColorRgba(0x59, 0x59, 0x59), 0.4f, 1.0f, 3.0f),
		};
		
		/* insert into global material lookup table */
		materialTable = new HashMap<Integer, LDrawMaterialBase>();
		for (LDrawMaterialBase lm : materialList)
			materialTable.put(lm.getId(), lm);
	}
	
	public static LDrawMaterialBase lookup(int id) {
		if (!materialTable.containsKey(id))
			return null;
		
		return materialTable.get(id);
	}
}
