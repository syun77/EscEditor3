package esc;

class EscFlag {
	public static inline var GAIN_USB_ADAPTER:Int = 12;
	public static inline var GAIN_USB_CABLE:Int = 13;
	public static inline var USB_POWER_ON:Int = 15;
	public static inline var UNLOCK_DOOR:Int = 16;
	static var _tbl:Map<String, Int> = [
		"GAIN_USB_ADAPTER" => 12,
		"GAIN_USB_CABLE" => 13,
		"USB_POWER_ON" => 15,
		"UNLOCK_DOOR" => 16,
	];
	
	public static function get(k:String):Int {
		if(_tbl.exists(k)) {
			return _tbl[k];
		}
		return 0;
	}
	public static function has(k:String):Bool {
		return _tbl.exists(k);
	}
	// 逆引き
	public static function toString(v:Int):String {
		for(k in _tbl.keys()) {
			if(_tbl[k] == v) {
				return k;
			}
		}
		return "";
	}
	
}
