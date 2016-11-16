trigger ISSP_ContactUpdaetPortalUser on Contact (after update) {

    Map<Id, String> conEmailMap = new Map<Id, String>();//TF - SP9-A5
    Set<Id> conEmailIdSet = new Set<Id>();//TF - SP9-A5
    Map<Id, String> conFirstNameMap = new Map<Id, String>();//TF - SP9-A5
	Map<Id, String> conLastNameMap = new Map<Id, String>();//TF - SP9-A5

    set<Id> conIdSet = new set<Id>();
    for(Contact con : trigger.new){
        if(
            (
            con.User_Portal_Status__c == 'Regional Administrator' 
            && 
            trigger.oldMap.get(con.Id).User_Portal_Status__c != 'Regional Administrator'
            )
            ||
            (
            con.User_Portal_Status__c == 'Regional Administrator' 
            && 
            con.Regional_Administrator_Countries__c != trigger.oldMap.get(con.Id).Regional_Administrator_Countries__c
            )
        )
        conIdSet.add(con.Id);
        
        //TF - SP9-A5
        /*
        if ((con.Email != trigger.oldMap.get(con.Id).Email) && con.Email != ''){
            system.debug('ISSP_ContactUpdaetPortalUser, email being changed');
            if (!conEmailMap.containsKey(con.Id)){
                conEmailMap.put(con.Id, con.Email);
                conEmailIdSet.add(con.Id);
            }
        }
        */
        if ((con.Email != '' &&
			(con.Email != trigger.oldMap.get(con.Id).Email
			|| con.FirstName != trigger.oldMap.get(con.Id).FirstName
			|| con.LastName != trigger.oldMap.get(con.Id).LastName
			))){
			system.debug('ISSP_ContactUpdaetPortalUser, email being changed');
			system.debug('Email changed: ' + con.Email != '' && con.Email != trigger.oldMap.get(con.Id).Email);
			system.debug('FirstName changed: ' + con.FirstName != trigger.oldMap.get(con.Id).FirstName);
			system.debug('LastName changed: ' + con.LastName != trigger.oldMap.get(con.Id).LastName);
			system.debug('Email old: ' + con.Email);
			system.debug('Email new: ' + trigger.oldMap.get(con.Id).Email);
			system.debug('FirstName old: ' + con.FirstName);
			system.debug('FirstName new: ' + trigger.oldMap.get(con.Id).FirstName);
			system.debug('LastName old: ' + con.LastName);
			system.debug('LastName new: ' + trigger.oldMap.get(con.Id).LastName);
			if (!conEmailMap.containsKey(con.Id)){
				conEmailMap.put(con.Id, con.Email);
				conEmailIdSet.add(con.Id);
				conFirstNameMap.put(con.Id, con.FirstName);
				conLastNameMap.put(con.Id, con.LastName);
			}
		}
    }
    if(conIdSet.size()>0){
        ISSP_Constant.UserAccountChangeParent = true;
        update [select Id from User where ContactId in:conIdSet];
    }
    
    //TF - SP9-A5
    if (!conEmailMap.isEmpty()){
        system.debug('Going to ISSP_UserTriggerHandler.changeEmailFromContact');
        system.debug('preventTrigger2: ' + ISSP_UserTriggerHandler.preventTrigger);
        if(!ISSP_UserTriggerHandler.preventTrigger)
            ISSP_UserTriggerHandler.changeEmailFromContact (conEmailMap, conFirstNameMap, conLastNameMap, conEmailIdSet);
    }
        
}