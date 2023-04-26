package queries;

import mongo.Pipeline;
import mongo.comparaison.GreaterOrEqualThan;
import mongo.comparaison.GreaterThan;
import mongo.comparaison.In;
import mongo.comparaison.InArray;
import mongo.comparaison.LowerThan;
import mongo.conditions.And;
import mongo.conditions.Nor;
import mongo.conditions.Or;
import mongo.operators.group.Avg;
import mongo.queries.IQuery;
import mongo.stages.Group;
import mongo.stages.Match;
import mongo.xapiSingleStmtShortcut.ActivityId;
import mongo.xapiSingleStmtShortcut.ActorMbox;
import mongo.xapiSingleStmtShortcut.ContextActivitiesGroupingId;
import mongo.xapiSingleStmtShortcut.StmtTimestamp;
import mongo.xapiSingleStmtShortcut.VerbId;
import thx.DateTime;
import xapi.Verb;
import roles.Actor;
import xapi.types.ISOdate;

/**
 * ...
 * @author bb
 */
class QueryQuestionsAvg implements IQuery
{
	var group:Group;
	var match:Match;
	var now:thx.DateTime;

	public function new()
	{
		group = new Group(
		{
			_id: {
				q_id: "$statement.object.id",
				q_fr: "$statement.object.definition.name.fr",
				q_de: "$statement.object.definition.name.de"
			},
			avg: new Avg("$statement.result.score.scaled")
		});
		match = null;
		now = DateTime.now();

	}
	public function setMatch(activity:Array<String>, list:Array<Actor>, dateLowerLimit:Date, dateUpperLimit:Date, ?excludeActors:Bool = false)
	{
		match = new Match(
			new And([
						new StmtTimestamp(new GreaterOrEqualThan(ISOdate.fromDate(dateLowerLimit))),
						new StmtTimestamp(new LowerThan(ISOdate.fromDate(dateUpperLimit))),
						new VerbId(
							new InArray([ Verb.answered.id, Verb.waived.id] )
						),
						new ContextActivitiesGroupingId(new InArray(activity)),
						excludeActors? new Nor([for (i in list) new ActorMbox(i.mbox)]): new Or([for (i in list) new ActorMbox(i.mbox)])
					])
		);
	}

	/* INTERFACE mongo.queries.IQuery */

	public function get_pipeline():Pipeline
	{
		return new Pipeline([match, group]);
	}

	public function get_id()
	{
		return Type.getClassName(Type.getClass(this));
	}

}