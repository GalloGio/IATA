public with sharing class NewGen_PortalRightTriggerHandler {
	public void OnAfterUpdate(Portal_Application_Right__c[] oldRight, Portal_Application_Right__c[] updatedRight, Map <Id, Portal_Application_Right__c> oldRightMap) {
		
		Set <Id> rightSet = new Set <Id>();
		Set <Id> appSet = new Set <Id>();

		for (Portal_Application_Right__c right : updatedRight) {
			if((oldRightMap.get(right.Id).Right__c != right.Right__c) && (right.Right__c == 'Access Granted')){
				rightSet.add(right.Contact__c);
				appSet.add(right.Portal_Application__c);
			}
		}

		List<Portal_Applications__c> appList = new List<Portal_Applications__c>([SELECT Id, Name
                                                 FROM Portal_Applications__c 
                                                 WHERE Id IN :appSet
                                                 ]);


        List<User> userList = new List<User> ([SELECT Id
                                                 FROM User 
                                                 WHERE ContactId IN :rightSet  
                                                 ORDER BY ContactId
                                                 ]);

        Set<String> userIdSet = new Set <String>();

        for( User u : userList){
        	userIdSet.add(u.Id);
        }

        for (Portal_Application_Right__c right : updatedRight) {
			if((oldRightMap.get(right.Id).Right__c != right.Right__c) && (right.Right__c == 'Access Granted')){
				for(Portal_Applications__c app: appList){

					if(app.Id == right.Portal_Application__c){
						NewGen_Account_Statement_Helper.sendPushNotification(userIdSet, Label.NewGenApp_ServiceAccepted, new List <String> { app.Name, String.valueOf(right.Right__c) });
					}
				}  
			}
		}
	}
}