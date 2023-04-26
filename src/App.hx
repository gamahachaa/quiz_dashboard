package;
import haxe.Json;
import haxe.ui.Toolkit;
import haxe.ui.animation.AnimationTools;
import haxe.ui.containers.TableView;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.MessageBox;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import http.XapiHelper;
import js.Browser;
import number.NumerbUtils;
import queries.QastAgreggator;
import queries.QueryQuestionsAvg;
import queries.QuizResults;
import roles.Actor;
import roles.Coach;
using Lambda;
using StringTools;
//import http.MailHelper;
//import http.XapiHelper;

/**
 * ...
 * @author bb
 */
class App extends AppBase
{
	static inline var MONTHLY_QUIZ_PATH =  "/01.customer_operations/06.Monthly_Test/";
	static inline var ROOT_WEB = "https://learningcenter.salt.ch";
	static inline var ROOT_DIR = "/home/qook/app/learningcenter";
	static inline var ROOT_QUIZZES:String = "https://learningcenter.salt.ch/[[QUIZZ]]/quiz/";
	static inline var ROOT_QUIZZES_WEB:String = ROOT_WEB + MONTHLY_QUIZ_PATH +  "[[QUIZZ]]/quiz/";
	static inline var SEARCH:String = "[[QUIZZ]]";
	var directoryReader: QuizDirectoryListing;
	var agregator:QastAgreggator;
	var _mainActor:roles.Coach;
	var dashboard:DashBoard;
	//var qAudience:String;
	//var qType:String;
	var singleDR:Actor;
	var quizResultQuery:queries.QuizResults;
	var quizQuestionsQuery:queries.QueryQuestionsAvg;
	var stage:Stage;
	var withDirectReports:Bool;
	var questionList:Array<Dynamic>;
	var actorHAsChangd:Bool;
	var gifLoader:GifLoader;
	var isAdmin:Bool;
	var quizTester:Array<Actor>;
	public function new()
	{
		//super(mailerClass, xapiHelper, appName, mainUserDirectRports);
		Toolkit.theme = "dark";

		//super(null, null, "quiz_dashboard", true,true);
		super(null, XapiHelper, "quiz_dashboard", true,true);
		quizTester = [
			new Actor({mail:"bruno.baudry@salt.ch", samaccountname:"bbaudry"}),
			new Actor({mail:"mailto:aron.peter@salt.ch",samaccountname:"apeter"})];
		isAdmin = false;
		Main._mainDebug = AppBase.ROOT.indexOf("test.salt.ch") > -1 || AppBase.APPLICATION.indexOf("_test") > -1 ;
		comonLibs = "https://qook.salt.ch/commonlibs/";
		this.whenAppReady = loadContent;
		this.logger.searchSignal.add( onMainActorFound );
		//this.logger.manySignal.add( onManyActorFound );
		//dashboard.qAudience = dashboard.qType = "";
		singleDR = null;
		questionList = [];
		actorHAsChangd = false;
		init();
	}

	function onMainActorFound(learner:Coach)
	{
		//trace(learner, learner);
		if (learner.authorised)
		{
			_mainActor = learner;

			//gifLoader.showDialog(true);
			launchqueries();
		}
		else
		{
			gifLoader.hide();

			this.showTmpErrorDialog('I did not find ${dashboard.actorTxt}');
		}
	}
	override function loadContent()
	{
		if (loginApp != null) app.removeComponent(loginApp);
		gifLoader= new GifLoader();
		stage = initial;
		quizResultQuery = new QuizResults();
		quizQuestionsQuery = new QueryQuestionsAvg();
		dashboard = new DashBoard();
		dashboard.querySignal.add( onqueryselected );
		dashboard.downloadSignal.add( onDownLoad );
		dashboard.langSignal.add( onLangChanged );
		dashboard.learnerSignal.add( onLearnerSelected );
		app.addComponent( dashboard );
		directoryReader = new QuizDirectoryListing( comonLibs + "dirlisting/" );
		directoryReader.successSignal.add( onDirListed );
		agregator = new QastAgreggator();
		agregator.signal.add(onQueryFetched);
		//agregator = new Agregator();
		_mainActor = this.monitoringData.coach;

		var reportersADgroup = [	"Customer Operations - Knowledge - Management",
									"Customer Operations - Training",
									"Customer Operations - Translation - Share",
									"Customer Operations - Knowledge - Team"];
		if (_mainActor.isManyMember(reportersADgroup))
		{
			dashboard.actorTFdisabled = false;
			isAdmin = _mainActor.isManyMember(["Customer Operations - Knowledge - Management", "Customer Operations - Knowledge - Team"]);
		}
		dashboard.loggedActorText = this.monitoringData.coach.firstName + " " + this.monitoringData.coach.sirName;
		dashboard.actorTxt = this.monitoringData.coach.sAMAccountName;
		directoryReader.getList();

	}

	function onLearnerSelected(item:Dynamic)
	{
		if ( item.attemps == "-")
		{
			var quizz = dashboard.qType.replace("/home/qook/app/learningcenter/", "");
			showTmpWarningMessage('${item.who} never attempted $quizz,\nSo I can not fecth questions... ');
		}
		else
		{
			singleDR = _mainActor.findDirectReportBysAMAccountName(item.who);
			stage = question;
			gifLoader.showDialog(true);
			launchqueries();
			//trace(singleDR);
		}

	}

	function onDownLoad(e:String)
	{
		switch (e)
		{
			case "_download_questions" : sendReportFunc( dashboard.questionTableview.dataSource.data);
			case "_download_scores" : sendReportFunc( dashboard.scoresTableview.dataSource.data);
			case _ : return;
		}
	}

	function onQueryFetched(list:Array<Dynamic>)
	{
		#if debug
		trace("App::onQueryFetched::list", list );
		#end

		switch (stage)
		{
			case resultsDirectReport: buildResult(list, false);
			case resultsSelf: buildResult(list, true);
			case question: buildQuestion(list);
			//case questionsSelf: buildQuestion(list, true);
			case initial: gifLoader.hide();
		}
	}

	function langList():Array<Dynamic>
	{
		var l = [];
		var q = "";
		for (i in questionList)
		{

			if ( dashboard.lang == "fr") q = i._id.q_fr;
			else  q = i._id.q_de;
			
			l.push(
			{
				question : q,
				avg : Std.string(NumerbUtils.roundWithPrecision(i.avg, 3) * 100)
			});
		}
		return l;
	}
	function buildQuestion(list:Array<Dynamic>)
	{
		gifLoader.hide();
		stage = initial;
		questionList = list;
		makeTable( dashboard.questionTableview, langList());
	}

	function buildResult(list:Array<Dynamic>, self:Bool)
	{
		stage = question;
		var listFinal:Array<Dynamic> = list.map((e)->
		{
			who : e._id,
			first_score : NumerbUtils.roundWithPrecision(e.first_score,3) * 100,
			last_score  : NumerbUtils.roundWithPrecision(e.last_score,3) * 100,
			max_score : NumerbUtils.roundWithPrecision(e.max_score,3) * 100,
			min_score : NumerbUtils.roundWithPrecision(e.min_score,3) * 100,
			attemps : e.attemps
		});
		#if debug
		trace("App::buildResult::listFinal", listFinal );
		#end
		listFinal = if (self)
		{
			if (list.length == 0)
				[addNullScore(_mainActor.sAMAccountName)];
			else
				listFinal;
		}
		else directReportList(listFinal);

		makeTable( dashboard.scoresTableview, listFinal);
		if (list.length == 0)
		{
			dashboard.questionTableview.dataSource.clear();
			gifLoader.hide();
			stage = initial;
			showTmpWarningMessage('As no result, no questions details report ... ');

		}
		else agregator.fetch( quizQuestionsQuery );
	}

	function makeTable(tableview:haxe.ui.containers.TableView, listFinal:Array<Dynamic>)
	{

		tableview.dataSource.clear();
		for (i in listFinal)
		{
			tableview.dataSource.add(i);
		}
	}
	function directReportList(list:Array<Dynamic> ):Array<Dynamic>
	{
		var l = list;
		for (i in _mainActor.getDirectReportsAMAccountNames())
		{
			if (Lambda.find(list, (j)->(j.who == i)) == null)
				l.push( addNullScore(i) );
		}
		return l;
	}
	function addNullScore(who:String):Dynamic
	{
		return
		{

			//_id : i,
			who : who,
			first_score : "-",
			last_score : "-",
			min_score : "-",
			max_score : "-",
			attemps : "-"
			//max_score : "-"
		};
	}
	function onqueryselected(s:String)
	{
		singleDR = null;
		if ( dashboard.qType == "")
		{
			//ERROR no quiz selected
			showTmpErrorDialog("You did not select a quiz");
		}
		else if ( dashboard.qAudience == "")
		{
			return;
		}
		else
		{
			gifLoader.showDialog(true);
			stage = initial;
			if (_mainActor.sAMAccountName == dashboard.actorTxt || doSearchAll())
				launchqueries();
			else this.logger.searchActorByNT(dashboard.actorTxt, dashboard.qAudience == "_directReports");
			#if debug
			trace("App::onqueryselected::dashboard.qAudience == _directReports", dashboard.qAudience == "_directReports" );
			#end
		}

	}

	function launchqueries()
	{

		withDirectReports = dashboard.qAudience == DashBoard.DR_ID;

		var audience:Array<Actor> = prepareAudience();

		if (withDirectReports && audience.length == 0 )
		{
			gifLoader.hide();
			//ERROR no direct report
			showTmpErrorDialog( _mainActor.sAMAccountName + " has no direct reports...");
		}
		else
		{
			dashboard.shakeInfoText();
			prepareQueriesMatch([ROOT_QUIZZES.replace(SEARCH, dashboard.qType.replace("/home/qook/app/learningcenter/", ""))], audience);

			if (stage == initial)
			{
				stage = withDirectReports? resultsDirectReport : resultsSelf ;
				agregator.fetch( quizResultQuery);
			}
			else if (stage == question && withDirectReports)
			{
				agregator.fetch( quizQuestionsQuery );
			}
			else if (stage == question && !withDirectReports)
			{
				stage = initial;
				gifLoader.hide();
			}
			else
			{
				trace("ERROR query should not have been launched");
				gifLoader.hide();
			}

		}
	}

	function onDirListed(dir:Array<String>)
	{

		dir.sort(function(a, b)
		{

			if (a < b) return -1;
			else if (a > b) return 1;
			else return 0;
		});
		dir.iter((e)->(dashboard.addQuiz({text:e.substring(e.lastIndexOf("/") + 4), value:e})));

	}
	function sendReportFunc(currentList:Array<Dynamic>)
	{
		if (currentList.length == 0 )
		{
			showTmpWarningMessage('Cannot download if the table is empty ... ');
			return;
		}
		var encodedUri = "data:text/csv;charset=utf-8,"+ StringTools.urlEncode(Utils.arrayToCsv(Utils.arrayDynamicToArrayArrayString(currentList),";")) ;

		Browser.window.open(encodedUri,"MyName", "download=MyName");
	}
	override function onLangChanged(e:UIEvent)
	{
		if ( questionList.length > 0)
			makeTable( dashboard.questionTableview, langList());
	}

	inline function doSearchAll():Bool
	{
		return isAdmin && dashboard.actorTxt == "*";
	}

	function showTmpErrorDialog(message:String):Void
	{
		var msg = new MessageBox();
		msg.type = MessageBoxType.TYPE_ERROR;
		msg.title = " ¯\\ (° _o) /¯ ";
		msg.message = message;
		msg.showDialog(true);
	}
	function showTmpWarningMessage(message:String):Void
	{
		var msg = new MessageBox();
		msg.type = MessageBoxType.TYPE_WARNING;
		msg.title = " ( 〃‿〃✿ ) ";
		msg.message = message;
		msg.showDialog(true);
	}

	function prepareAudience():Array<Actor>
	{
		if (withDirectReports)
		{
			if (singleDR == null)
			{
				dashboard.questionInfo = "All  ↴";
				return _mainActor.directReports;
			}
			else
			{

				dashboard.questionInfo = singleDR.getSimpleEmail() + "  ↴";
				return [singleDR];
			}
		}
		else
		{
			dashboard.questionInfo = _mainActor.getSimpleEmail() + "  ↴";
			return [cast(_mainActor, Actor)];
		}
	}

	function prepareQueriesMatch(quiz:Array<String>, whoToFilter:Array<Actor>):Void
	{
		if (doSearchAll())
		{
			// request all *
			quizResultQuery.setMatch(quiz, quizTester, dashboard.dateFrom, dashboard.dateTo, true);
			quizQuestionsQuery.setMatch(quiz, quizTester,dashboard.dateFrom, dashboard.dateTo, true);
		}
		else
		{
			// regular request
			quizResultQuery.setMatch(quiz, whoToFilter,dashboard.dateFrom, dashboard.dateTo);
			quizQuestionsQuery.setMatch(quiz, whoToFilter, dashboard.dateFrom, dashboard.dateTo );
		}
	}

}
enum Stage
{
	initial;
	resultsSelf;
	resultsDirectReport;
	question;
}