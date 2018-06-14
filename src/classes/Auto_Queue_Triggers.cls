// *************************************
// Rémi de Jouvencel (sfdc)           
// 27/01/2009                         
// Find Queue Id   
// with Auto Queue Name   
// *************************************
public class Auto_Queue_Triggers 
{
	public static void findId(Auto_Queue__c[] aQueues)
	{
		Group[] aGroups = [select Id, Name from Group where Type = 'Queue'];
		map<string,Group> mQueue;
		mQueue=new map<string,Group>();
		
		for (Group g:aGroups)
			mQueue.put(g.name,g);
			
		// Check that Queue Name already exists and fill Queue Id	
		for (Auto_Queue__c q : aQueues) 
		{
			if (mQueue.get(q.Name)!=null)
				q.Queue_ID__c=mQueue.get(q.Name).Id;
			else
				q.addError('Invalid Queue Name');
		}
	}	
	//******************************************
	// T.E.S.T  M.E.T.H.O.D
	//******************************************
	public static testmethod void test()
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