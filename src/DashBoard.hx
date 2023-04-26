package;

import date.DateToolsBB;
import haxe.ui.components.DropDown;
import haxe.ui.containers.TableView;
import haxe.ui.containers.VBox;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.MessageBox;
import haxe.ui.events.FocusEvent;
import thx.DateTime;
//import haxe.ui.data.DataSource;
//import haxe.ui.data.IDataItem;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
//import signals.Signal.Signal0;
import signals.Signal1;
using haxe.ui.animation.AnimationTools;

/**
 * ...
 * @author bb
 */

@:build(haxe.ui.ComponentBuilder.build("assets/ui/dashboard.xml"))
class DashBoard extends VBox
{
	public static var DR_ID:String = "_directReports";
	/**
	 * Bindables
	 */
	@:bind(_actor.disabled)
	public var actorTFdisabled:Bool;
	@:bind(_debug.text)
	public var debugTxt:String = "";
	@:bind(_actor.text)
	public var actorTxt:String = "Actor";
	@:bind(_loggedActor.text)
	public var loggedActorText:String;
	@:bind(_questionsInfoLabel.text)
	public var questionInfo:String;
	/**
	 * publics 
	 * @todo make properties
	 */
	public var dateTo:Date;
	public var dateFrom:Date;
	public var deltaDatePositive:Bool;
	public var qAudience:String;
	public var qType:String;
	public var querySignal:Signal1<String>;
	public var downloadSignal:Signal1<String>;
	public var langSignal:Signal1<UIEvent>;
	public var learnerSignal:Signal1<Dynamic>;
	public var mainActorSignal:Signal1<Dynamic>;
	public var questionTableview:TableView;
	public var scoresTableview:TableView;
	public var lang:String;

	public function new()
	{
		super();
		this.qAudience = this.qType = "";
		this._app_title.fadeIn();
		this.questionTableview = _questions;
		this.scoresTableview = this._scores;
		querySignal = new Signal1<String>();
		downloadSignal = new Signal1<String>();
		langSignal = new Signal1<UIEvent>();
		learnerSignal = new Signal1<Dynamic>();
		lang = "fr";
		this._debug.height = 0;
		#if debug
		this._debug.hidden = false;
		#else
		this._debug.hidden = true;
		#end
		var now:DateTime = DateTime.now();
		var twoMonthBefore:DateTime = now.prevMonth().prevMonth();
		dateFrom = this._date_from.value = DateToolsBB.CLONE_DATETIME_TO_DATE(twoMonthBefore);
		dateTo = this._date_to.value = DateToolsBB.CLONE_DATETIME_TO_DATE(now);

	}
	public function addQuiz( item:Dynamic )
	{
		this._quiz.dataSource.add(item);
	}
	public function shakeInfoText()
	{
		this._questionsInfoLabel.shake();
	}

	@:bind(_fetch, MouseEvent.CLICK)
	function onFetchClicked(e:MouseEvent)
	{
		querySignal.dispatch( "click" );
	}
	/**
	 * dropdown
	 */

	@:bind(_quiz, UIEvent.CHANGE)
	function onDDChange(e:UIEvent)
	{
		qType = _quiz.selectedItem.value;
		debugTxt = qType;
	}
	@:bind(_actor, FocusEvent.FOCUS_OUT)
	function onActorChanged(e:FocusEvent)
	{
		debugTxt = _actor.text;
		this._questionsInfoLabel.shake("vertical");
	}
	/**
	 * Radio
	 * @param	e
	 */
	@:bind(_lang, UIEvent.CHANGE)
	function onLangChange(e:UIEvent)
	{
		lang = e.target.id;
		langSignal.dispatch(e);
	}
	/**
	 * Radio
	 * @param	e
	 */
	@:bind(_audience, UIEvent.CHANGE)
	function onAudienceChange(e:UIEvent)
	{
		qAudience = e.target.id;
		debugTxt = e.target.id;
	}
	/**
	* Buttons
	*/
	@:bind(_download_scores, MouseEvent.CLICK)
	@:bind(_download_questions, MouseEvent.CLICK)
	function onDownloadQuestions(e:MouseEvent)
	{
		debugTxt = e.target.id;
		downloadSignal.dispatch(e.target.id);
	}


	/**
	 * SCORES
	 */
	@:bind(_scores, UIEvent.CHANGE)
	function onScoreChanged(e:UIEvent)
	{
		//debugTxt = e.target.id;
	}
	@:bind(_scores, MouseEvent.CLICK)
	function onScoreClicked(e:MouseEvent)
	{

		learnerSignal.dispatch( cast(e.target, TableView ).selectedItem);
	}
	@:bind(_date_from, UIEvent.CHANGE)
	function onDateFromChanged(e:UIEvent)
	{
		trace(this._date_from.value);
		dateFrom = this._date_from.value;
		validateDates();
	}
	@:bind(_date_to, UIEvent.CHANGE)
	function onDateToChanged(e:UIEvent)
	{
		trace(this._date_to.value);
		dateTo = this._date_to.value;
		validateDates();
	}
	function validateDates()
	{
		deltaDatePositive = dateTo.getTime() - dateFrom.getTime() > 0;
		if (!deltaDatePositive)
		{
			var d = new MessageBox();
			d.title = "YO !!!";
			d.message = "From must be inferior to To !";
			d.showDialog(true);
		}

	}

}

//@:structInit
//class QuizDirectoryItem implements IDataItem
//{
//public var text:String;
//@:isVar public var value(get, set):String;
//
//function get_value():String
//{
//return value;
//}
//
//function set_value(value:String):String
//{
//return value = value;
//}
//
//}