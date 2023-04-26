package;

import haxe.ui.containers.dialogs.Dialog;
import number.NumerbUtils;

/**
 * ...
 * @author bb
 */
@:build(haxe.ui.ComponentBuilder.build("assets/ui/GifLoaderDialog.xml"))
class GifLoader extends Dialog
{

	public function new()
	{
		super();
		this.destroyOnClose = false;
		this.backgroundColor = 0;
		this.title = "Searching...";
		this.onDialogClosed = (e)->(return );
	}
	override public function showDialog(modal:Bool = true)
	{
		var rnd = NumerbUtils.randomIntFromInterval(0, 5);
		this._imageLaoder.resource = 'images/loaders/${rnd}0.gif';
		super.showDialog(modal);
	}

}