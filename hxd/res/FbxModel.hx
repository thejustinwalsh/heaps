package hxd.res;

class FbxModel extends Resource {

	public static var isLeftHanded = true;

	public function toFbx( ?loader : Loader ) : h3d.fbx.Library {
		var lib = new h3d.fbx.Library();
		switch( entry.getSign() & 0xFF ) {
		case ';'.code: // FBX
			lib.load(h3d.fbx.Parser.parse(entry.getBytes().toString()));
		case 'X'.code, 0x78: // XBX (+ zip)
			var f = new haxe.io.BytesInput(entry.getBytes());
			var xbx = new h3d.fbx.XBXReader(f).read();
			lib.load(xbx);
			f.close();
		case '<'.code: // XTRA
			if( loader == null ) throw "Loader parameter required for XTRA";
			lib = loader.load(entry.path.substr(0, -4) + "FBX").toFbx();
			lib.loadXtra(entry.getBytes().toString());
		case 'H'.code:
			throw "FBX model was converted to HMD : use res.toHmd()";
		default:
			throw "Unsupported model format " + entry.path;
		}
		if( isLeftHanded ) lib.leftHandConvert();
		return lib;
	}

	public function toHmd() : hxd.fmt.hmd.Library {
		var hmd = new hxd.fmt.hmd.Reader(new hxd.fs.FileInput(entry)).readHeader();
		return new hxd.fmt.hmd.Library(entry, hmd);
	}

}