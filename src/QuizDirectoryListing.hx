package;

import http.DirectoryReader;

/**
 * ...
 * @author bb
 */
class QuizDirectoryListing extends DirectoryReader 
{

	public function new(url:String) 
	{
		super(url);
	}
	public function getList()
	{
		this.fetchQuiz("/home/qook/app/learningcenter/01.customer_operations/06.Monthly_Test");
		this.fetchQuiz("/home/qook/app/learningcenter/01.customer_operations");
		this.fetchQuiz("/home/qook/app/learningcenter/01.customer_operations/01.products_and_services/01.Products");
	}
}