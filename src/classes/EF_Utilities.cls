public with sharing class EF_Utilities
{
	public EF_Utilities() {		
	}

	public static void storeUpdateComments(List<sObject> objectList)
	{
		for(sObject o : objectList)
		{
			if(o.get('EF_Comments__c') != null)
			{
				String currentTime = System.now().format('dd MMM yyyy HH:mm ');
				String currentUser = UserInfo.getName();
				String comments = (String) o.get('EF_Comments__c');
				String commentsHistory = (String) o.get('EF_History__c');
				String oldHistory = '';
				if(commentsHistory == null)
					commentsHistory = '';
				oldHistory = commentsHistory;
				commentsHistory = currentTime + ' by ' + currentUser + ': ' + comments.trim() + '\n';
				commentsHistory = commentsHistory + oldHistory.trim();
				
				o.put('EF_History__c', commentsHistory);
				o.put('EF_Comments__c', '');
			}
		}
	}
}