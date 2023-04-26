package queries;
import haxe.Json;
import mongo.Pipeline;
import mongo.comparaison.GreaterOrEqualThan;
import mongo.comparaison.LowerThan;
import mongo.conditions.And;
import mongo.conditions.Nor;
import mongo.conditions.Or;
import mongo.xapiSingleStmtShortcut.StmtTimestamp;
import xapi.types.ISOdate;
//import mongo.operators.arithmetic.Divide;
//import mongo.operators.arithmetic.Multiply;
//import mongo.operators.arithmetic.Modulo;
//import mongo.operators.arithmetic.Substract;
import mongo.operators.group.First;
import mongo.operators.group.Last;
import mongo.operators.group.Max;
import mongo.operators.group.Min;
import mongo.operators.group.Sum;
import mongo.stages.Group;
import mongo.stages.Match;
import mongo.stages.Project;
import mongo.stages.Sort;
import mongo.xapiSingleStmtShortcut.ActivityId;
import mongo.xapiSingleStmtShortcut.ActorMbox;
import roles.Actor;
import xapi.Verb;
//import mongo.xapiSingleStmtShortcut.ActorName;
import mongo.xapiSingleStmtShortcut.VerbId;

import mongo.queries.IQuery;


/**
 * ...
 * @author bb
 */
class QuizResults implements IQuery
{
	var activities:Array<String>;
	var list:Array<Actor>;
	var project:Project;
	var group:Group;
	var match:Match;
	var sort:Sort;


	public function new() 
	{
		//this.list = list;
		//this.activities = activities;
		
		project = new Project(
			{
				_id:0, 
				statement_id:"$statement.id", 
				actor: "$statement.actor.name",
				score:"$statement.result.score.scaled"
			}
		);
		group = new Group(
			{
				_id:"$actor" ,
				//who:new Max("$actor") ,
				first_score: new First("$score"),
				last_score: new Last("$score"),
				max_score: new Max("$score"),
				min_score: new Min("$score"),
				attemps: new Sum(1)
			}
		);
		
		sort = new Sort(
			{
				attempts : -1
			}
		);
		
	}
	public function setMatch(activities:Array<String>, list:Array<Actor>, dateLowerLimit:Date, dateUpperLimit:Date , ?excludeActors:Bool = false)
	{
		match = new Match( new And([
			new StmtTimestamp(new GreaterOrEqualThan(ISOdate.fromDate(dateLowerLimit))),
			new StmtTimestamp(new LowerThan(ISOdate.fromDate(dateUpperLimit))),
			new VerbId(Verb.completed.id),
			new Or([for (i in activities) new ActivityId(i)]),
			excludeActors? new Nor([for (i in list) new ActorMbox(i.mbox)]): new Or([for (i in list) new ActorMbox(i.mbox)])
		]));
	}
	public function get_pipeline():Pipeline
	{
		return new Pipeline([
			match, project, group, sort
		]);
	}
	public function get_id()
	{
		return Type.getClassName(Type.getClass(this));
	}
}