package queries;

import lrs.vendors.LLAccess;
import lrs.vendors.LearninLocker;
import mongo.queries.Agregator;

/**
 * ...
 * @author bb
 */
class QastAgreggator extends Agregator 
{

	public function new() 
	{
		super(new LLAccess(new LearninLocker("qook", "https://qast.salt.ch", "", "", "Basic ZDZkNGM3NDJmNTMxYjBjYjM4NDhjZTVlMTQ4YWRjMzIyNmUwOWEyMTowZDJjYTE4OGM1MWY4MmUxMTU1ZGI0ZTZjMWJhMjI0NWIzOWQ4NWY3", aggregation_sync)));
		
	}
	
}