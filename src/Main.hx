package;
import js.Browser;
import js.html.URLSearchParams;

class Main
{

	public static var _mainDebug:Bool = false;
	public static var PARAMS:URLSearchParams;
	public static function main()
	{
		//var s = Browser.location.search;
		PARAMS = new URLSearchParams(Browser.location.search);
		var app = new App();
		//var app = new NewApp();

	}
}
