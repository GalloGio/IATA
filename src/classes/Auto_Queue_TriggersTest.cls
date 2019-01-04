@isTest
private class Auto_Queue_TriggersTest {
	
	@isTest
	public static void test()
	{
		Group g= [select Id, Name from Group where Type = 'Queue' limit 1];
		Auto_Queue__c q=new Auto_Queue__c(Name='TESTXX');
		// Test with incorrect Queue Name
		try 
		{
			insert q;
		} 
		catch (Exception e){system.debug('Normal Exception');}
		// Test with correct Queue Name
		q.Name=g.Name;
		insert q;
	}		
	
}