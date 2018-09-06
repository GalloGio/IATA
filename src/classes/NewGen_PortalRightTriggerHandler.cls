public with sharing class NewGen_PortalRightTriggerHandler {
	public void OnAfterUpdate(Portal_Application_Right__c[] oldRight, Portal_Application_Right__c[] updatedRight, Map <Id, Portal_Application_Right__c> oldRightMap) {
		
		Set <Id> contactIdAccessGrantedSet = new Set <Id>();
		Set <Id> appSet = new Set <Id>();
		Set <Id> contactIdAccessRequestForAdminsSet = new Set <Id>();
		Set <Id> accountIdSet = new Set <Id>();

		for (Portal_Application_Right__c right : updatedRight) {
			// If access was granted, send notifications to Contact that requested it.
			if(oldRightMap.get(right.Id).Right__c != right.Right__c && right.Right__c == 'Access Granted'){
				contactIdAccessGrantedSet.add(right.Contact__c);
				appSet.add(right.Portal_Application__c);
			}

			// If access was requested, send notifications to all Portal Administrators of Contact's Account.
			if(ENV.AccessStatusPL.AccessRequested.equalsIgnoreCase(right.Right__c)){
				contactIdAccessRequestForAdminsSet.add(right.Contact__c);
				appSet.add(right.Portal_Application__c);
				accountIdSet.add(right.Account__c);
			}
		}

		Map <Id, Portal_Applications__c> appMap = new Map <Id, Portal_Applications__c>([SELECT 	Id, Name, NewGenAPP_ShortName__c
													                                    FROM 	Portal_Applications__c 
													                                    WHERE 	Id IN :appSet]);

		
        Map <Id, User> userMap = new Map <Id, User> ([SELECT 	Id, ContactId
		                                              FROM 		User 
		                                              WHERE 	ContactId IN :contactIdAccessGrantedSet]);

        List <AccountTeamMember> accountTeamMemberList = new List <AccountTeamMember> ([SELECT 	Id, AccountId, UserId
											                                            FROM 	AccountTeamMember 
											                                            WHERE 	TeamMemberRole = :ENV.TeamMemberRolePL.PortalAdministrator
											                                            AND 	IsDeleted = false
											                                            AND 	AccountId = :accountIdSet]);

        Map <Id, Set <String>> portalAdministratorsMap = new Map <Id, Set <String>>();

        if(accountTeamMemberList != null && !accountTeamMemberList.isEmpty()){
        	for (AccountTeamMember accountTeamMember : accountTeamMemberList){
        		if(portalAdministratorsMap.get(accountTeamMember.AccountId) == null){
        			portalAdministratorsMap.put(accountTeamMember.AccountId, new Set <String> { accountTeamMember.UserId });
        		}
        		else {
        			portalAdministratorsMap.get(accountTeamMember.AccountId).add(accountTeamMember.UserId);
        		}
        	}
        }

        for (Portal_Application_Right__c right : updatedRight) {
        	Id userId;
        	for(User u: userMap.values()){
        		if(u.ContactId == right.Contact__c){
        			userId = u.Id;
        		}
        	}
        	// if the app is NewGen Mobile App (NewGenAPP_ShortName__c not null)
        	if(appMap != null && appMap.get(right.Portal_Application__c) != null && String.isNotEmpty(appMap.get(right.Portal_Application__c).NewGenAPP_ShortName__c)){
        		// If access was granted, send notifications to Contact that requested it.

        		if(oldRightMap.get(right.Id).Right__c != right.Right__c && right.Right__c.equals('Access Granted') && userMap != null && userId != null){
        			System.Debug('ENTROU AQUI2');
					NewGen_Account_Statement_Helper.sendPushNotification(new Set <String> { userId }, Label.NewGenApp_ServiceAccepted, 
						new List <String> { appMap.get(right.Portal_Application__c).Name, String.valueOf(right.Right__c) }, 
						appMap.get(right.Portal_Application__c).NewGenAPP_ShortName__c == NewGen_Account_Statement_Helper.SERVICE_ICE ? NewGen_Account_Statement_Helper.NAVIGATE_TO_SERVICE_REQUEST :
						appMap.get(right.Portal_Application__c).NewGenAPP_ShortName__c == NewGen_Account_Statement_Helper.SERVICE_RHC ? NewGen_Account_Statement_Helper.NAVIGATE_TO_SERVICE_REQUEST : NewGen_Account_Statement_Helper.NAVIGATE_TO_HOME);

				}
				// If access was requested, send notifications to all Portal Administrators of Contact's Account.
				else if(ENV.AccessStatusPL.AccessRequested.equalsIgnoreCase(right.Right__c) &&
					portalAdministratorsMap != null && portalAdministratorsMap.get(right.Account__c) != null && portalAdministratorsMap.get(right.Account__c).size() > 0){

					NewGen_Account_Statement_Helper.sendPushNotification(portalAdministratorsMap.get(right.Account__c), Label.NewGenApp_ServiceRequested, 
						new List <String> { appMap.get(right.Portal_Application__c).Name, String.valueOf(right.Right__c) }, NewGen_Account_Statement_Helper.NAVIGATE_TO_SERVICE_REQUEST_ADMIN);

				}
        	}
		}
	}
}