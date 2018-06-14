global class ISSP_Create_External_Users implements Schedulable {

	global static void scheduleName(String name, String cron) {
		ISSP_Create_External_Users cls = new ISSP_Create_External_Users();
		System.schedule(name, cron, cls);
	}

	global static void scheduleIt() {
		
		ISSP_Create_External_Users cls = new ISSP_Create_External_Users();
		System.schedule('Create External Users 1', '0 02 * * * ? ', cls); 
		System.schedule('Create External Users 2', '0 04 * * * ? ', cls);
		System.schedule('Create External Users 3', '0 06 * * * ? ', cls); 
		System.schedule('Create External Users 4', '0 08 * * * ? ', cls);
		System.schedule('Create External Users 5', '0 10 * * * ? ', cls); 
		System.schedule('Create External Users 6', '0 12 * * * ? ', cls);
		System.schedule('Create External Users 7', '0 14 * * * ? ', cls); 
		System.schedule('Create External Users 8', '0 16 * * * ? ', cls);
		System.schedule('Create External Users 9', '0 18 * * * ? ', cls); 
		System.schedule('Create External Users 10', '0 20 * * * ? ', cls);
		System.schedule('Create External Users 11', '0 22 * * * ? ', cls); 
		System.schedule('Create External Users 12', '0 24 * * * ? ', cls);
		System.schedule('Create External Users 13', '0 26 * * * ? ', cls); 
		System.schedule('Create External Users 14', '0 28 * * * ? ', cls);
		System.schedule('Create External Users 15', '0 30 * * * ? ', cls); 
		System.schedule('Create External Users 16', '0 32 * * * ? ', cls); 
		System.schedule('Create External Users 17', '0 34 * * * ? ', cls);
		System.schedule('Create External Users 18', '0 36 * * * ? ', cls); 
		System.schedule('Create External Users 19', '0 38 * * * ? ', cls);
		System.schedule('Create External Users 20', '0 40 * * * ? ', cls); 
		System.schedule('Create External Users 21', '0 42 * * * ? ', cls);
		System.schedule('Create External Users 22', '0 44 * * * ? ', cls); 
		System.schedule('Create External Users 23', '0 46 * * * ? ', cls);
		System.schedule('Create External Users 24', '0 48 * * * ? ', cls); 
		System.schedule('Create External Users 25', '0 50 * * * ? ', cls);
		System.schedule('Create External Users 26', '0 52 * * * ? ', cls); 
		System.schedule('Create External Users 27', '0 54 * * * ? ', cls);
		System.schedule('Create External Users 28', '0 56 * * * ? ', cls); 
		System.schedule('Create External Users 29', '0 58 * * * ? ', cls);
	}
	
	global static String scheduleIt(String cron) {	
		
	   	ISSP_Create_External_Users cls = new ISSP_Create_External_Users();

		return System.schedule('Create External Users', cron, cls);
    }
    
    global void execute(SchedulableContext sc){
    	Set <Id> contactIds = new Set <Id>();
    	Map <Id, Id> userIds = new Map <Id, Id>();
    	List<ISSP_CASSLink_Users__c> userList = [SELECT Id, Contact__c, Email__c
										FROM ISSP_CASSLink_Users__c
										WHERE User__c = null 
										AND Contact__c != null
										AND To_Create_New_User__c = true
										ORDER BY Email__c
										LIMIT 3];
		if (!userList.isEmpty()){
			system.debug('ON EXECUTE: ' + userList);
			for (ISSP_CASSLink_Users__c thisUser : userList){
				contactIds.add(thisUser.Contact__c);
				if(!Test.isRunningTest()){
					ISSP_PortalUserStatusChange.runAction(thisUser.Contact__c,thisUser.Email__c, 'CreateNewUserWithCustomerProfile', 'Approved User', null, null);
				}
			}
			List <User> realUserList = [SELECT Id, ContactId FROM User WHERE ContactId IN :contactIds];
			for (User thisUser : realUserList){
				userIds.put(thisUser.ContactId, thisUser.Id);
			}
			List <ISSP_CASSLink_Users__c> newUserList = [SELECT Id, Contact__c, Email__c	FROM ISSP_CASSLink_Users__c
														WHERE Contact__c IN :contactIds];
			for (ISSP_CASSLink_Users__c thisUser : newUserList){
				if (userIds.containsKey(thisUser.Contact__c)){
					thisUser.User__c = userIds.get(thisUser.Contact__c);
					thisUser.Created_New_User__c = true;
				}
			}
			update newUserList;
		}
	}

}