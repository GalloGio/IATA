global class ISSP_Create_External_Users_ASD implements Schedulable {

	global static void scheduleName(String name, String cron) {
		ISSP_Create_External_Users_ASD cls = new ISSP_Create_External_Users_ASD();
		System.schedule(name, cron, cls);
	}

	global static void scheduleIt() {
		
		ISSP_Create_External_Users_ASD cls = new ISSP_Create_External_Users_ASD();
		System.schedule('Create External Users ASD 1', '0 02 * * * ? ', cls); 
		System.schedule('Create External Users ASD 2', '0 04 * * * ? ', cls);
		System.schedule('Create External Users ASD 3', '0 06 * * * ? ', cls); 
		System.schedule('Create External Users ASD 4', '0 08 * * * ? ', cls);
		System.schedule('Create External Users ASD 5', '0 10 * * * ? ', cls); 
		System.schedule('Create External Users ASD 6', '0 12 * * * ? ', cls);
		System.schedule('Create External Users ASD 7', '0 14 * * * ? ', cls); 
		System.schedule('Create External Users ASD 8', '0 16 * * * ? ', cls);
		System.schedule('Create External Users ASD 9', '0 18 * * * ? ', cls); 
		System.schedule('Create External Users ASD 10', '0 20 * * * ? ', cls);
		System.schedule('Create External Users ASD 11', '0 22 * * * ? ', cls); 
		System.schedule('Create External Users ASD 12', '0 24 * * * ? ', cls);
		System.schedule('Create External Users ASD 13', '0 26 * * * ? ', cls); 
		System.schedule('Create External Users ASD 14', '0 28 * * * ? ', cls);
		System.schedule('Create External Users ASD 15', '0 30 * * * ? ', cls); 
		System.schedule('Create External Users ASD 16', '0 32 * * * ? ', cls); 
		System.schedule('Create External Users ASD 17', '0 34 * * * ? ', cls);
		System.schedule('Create External Users ASD 18', '0 36 * * * ? ', cls); 
		System.schedule('Create External Users ASD 19', '0 38 * * * ? ', cls);
		System.schedule('Create External Users ASD 20', '0 40 * * * ? ', cls); 
		System.schedule('Create External Users ASD 21', '0 42 * * * ? ', cls);
		System.schedule('Create External Users ASD 22', '0 44 * * * ? ', cls); 
		System.schedule('Create External Users ASD 23', '0 46 * * * ? ', cls);
		System.schedule('Create External Users ASD 24', '0 48 * * * ? ', cls); 
		System.schedule('Create External Users ASD 25', '0 50 * * * ? ', cls);
		System.schedule('Create External Users ASD 26', '0 52 * * * ? ', cls); 
		System.schedule('Create External Users ASD 27', '0 54 * * * ? ', cls);
		System.schedule('Create External Users ASD 28', '0 56 * * * ? ', cls); 
		System.schedule('Create External Users ASD 29', '0 58 * * * ? ', cls);
	}
	
	global static String scheduleIt(String cron) {	
		
	   	ISSP_Create_External_Users_ASD cls = new ISSP_Create_External_Users_ASD();

		return System.schedule('Create External Users ASD', cron, cls);
    }
    
    global void execute(SchedulableContext sc){
    	Set <Id> contactIds = new Set <Id>();
    	Map <Id, Id> userIds = new Map <Id, Id>();
    	List<ISSP_ASD_Users__c> userList = [SELECT Id, Contact__c, Email__c
										FROM ISSP_ASD_Users__c
										WHERE User__c = null 
										AND Contact__c != null
										AND To_Create_New_User__c = true
										ORDER BY Email__c
										LIMIT 3];
		if (!userList.isEmpty()){
			system.debug('ON EXECUTE: ' + userList);
			for (ISSP_ASD_Users__c thisUser : userList){
				contactIds.add(thisUser.Contact__c);
				if(!Test.isRunningTest()){
					ISSP_PortalUserStatusChange.runAction(thisUser.Contact__c,thisUser.Email__c, 'CreateNewUserWithCustomerProfile', 'Approved User', null, null);
				}
			}
			List <User> realUserList = [SELECT Id, ContactId FROM User WHERE ContactId IN :contactIds];
			for (User thisUser : realUserList){
				userIds.put(thisUser.ContactId, thisUser.Id);
			}
			List <ISSP_ASD_Users__c> newUserList = [SELECT Id, Contact__c, Email__c	FROM ISSP_ASD_Users__c
														WHERE Contact__c IN :contactIds];
			for (ISSP_ASD_Users__c thisUser : newUserList){
				if (userIds.containsKey(thisUser.Contact__c)){
					thisUser.User__c = userIds.get(thisUser.Contact__c);
					thisUser.Created_New_User__c = true;
				}
			}
			update newUserList;
		}
	}

}