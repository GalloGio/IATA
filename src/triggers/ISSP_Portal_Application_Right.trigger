trigger ISSP_Portal_Application_Right on Portal_Application_Right__c (after insert, after update, before delete) {
    
    if(PortalServiceAccessTriggerHandler.avoidAppTrigger) return;
    
    //TF - give permission set automatically for SIS
    system.debug('STARTING TRIGGER');
    Set <Id> contactIdSet = new Set <Id>();
    Set <Id> contactRemoveIdSet = new Set <Id>();
    Set <Id> contactRemove2FAIdSet = new Set <Id>();
    Set <Id> contactFedIdSet = new Set <Id>();
    Map <Id, String> contactFedIdMap = new Map <Id, String>();
    Set <Id> contactBaggageAdd = new Set <Id>();
    Set <Id> contactKaviAdd = new Set <Id>();
    Set <Id> contactBaggageRemove = new Set <Id>();
    Set <Id> manageAccessTDidSet = new Set <Id>();
	Set <Id> ContactDelRightSet = new Set <Id>();
    Set <Id> contactIdIATAAccreditationSet = new Set <Id>();
    Set <Id> contactIdRemoveIATAAccreditationSet = new Set <Id>();
    //ANG project
    ANG_PortalApplicationRightHandler handler = new ANG_PortalApplicationRightHandler();
    if(Trigger.isAfter && Trigger.isInsert) handler.onAfterInsert();
    if(Trigger.isAfter && Trigger.isUpdate) handler.onAfterUpdate();
    if(Trigger.isBefore && Trigger.isDelete) handler.onBeforeDelete();    
	//end of ANG
    
    if (Trigger.isInsert || Trigger.isUpdate) {
        for(Portal_Application_Right__c access : trigger.new){
            system.debug('ONE RECORD');
            system.debug('APP NAME: ' + access.Application_Name__c);
            if (access.Application_Name__c == 'SIS'){
                if (trigger.isInsert && access.Right__c == 'Access Granted'){
                    system.debug('IS INSERT AND GRANTED');
                    contactIdSet.add(access.Contact__c);
                }
                else if (trigger.isUpdate){
                    Portal_Application_Right__c oldAccess = trigger.oldMap.get(access.Id);
                    if (access.Right__c != oldAccess.Right__c){
                        if (access.Right__c == 'Access Granted'){
                            system.debug('IS UPDATE AND GRANTED');
                            contactIdSet.add(access.Contact__c);
                        }
                        else if (access.Right__c == 'Access Denied'){
                            system.debug('IS UPDATE AND DENIED');
                            contactRemoveIdSet.add(access.Contact__c);
                        }
                    }
                }
            }
            else if (access.Application_Name__c.startsWith('Treasury Dashboard')){
            	String tdAppName = '';
            	if (access.Application_Name__c == 'Treasury Dashboard'){
            		tdAppName = 'ISSP_Treasury_Dashboard_Basic';
            	}
            	else{
            		tdAppName = 'ISSP_Treasury_Dashboard_Premium';
            	}
            	if (trigger.isInsert && access.Right__c == 'Access Granted'){
            		system.debug('Adding id from insert');
            		contactFedIdMap.put(access.Contact__c, tdAppName);
            		contactFedIdSet.add(access.Contact__c);
            		manageAccessTDidSet.add(access.Id);
            	}
            	else if (trigger.isUpdate){
                    Portal_Application_Right__c oldAccess = trigger.oldMap.get(access.Id);
                    if (access.Right__c != oldAccess.Right__c){
    		            if (access.Right__c == 'Access Denied'){
    		            	contactRemove2FAIdSet.add(access.Contact__c);
    		            }
    		            else if (access.Right__c == 'Access Granted'){
    		            	system.debug('Adding id from update');
    		            	contactFedIdMap.put(access.Contact__c, tdAppName);
    		            	contactFedIdSet.add(access.Contact__c);
    		            	manageAccessTDidSet.add(access.Id);
    		            }
                    }
            	}else if(Trigger.isDelete){
    				contactRemove2FAIdSet.add(trigger.oldMap.get(access.Id).Contact__c);
    			}
            }
            else if (access.Application_Name__c == 'Baggage Proration'){
                if (trigger.isInsert && access.Right__c == 'Access Granted'){
                    contactBaggageAdd.add(access.Contact__c);
                }
                else if (trigger.isUpdate){
                    Portal_Application_Right__c oldAccess = trigger.oldMap.get(access.Id);
                    if (access.Right__c != oldAccess.Right__c){
                        if (access.Right__c == 'Access Granted'){
                            contactBaggageAdd.add(access.Contact__c);
                        }
                        else if (access.Right__c == 'Access Denied'){
                            contactBaggageRemove.add(access.Contact__c);
                        }
                    }
                }
            }
            else if (access.Application_Name__c == 'Standards Setting Workspace'){
                if (trigger.isInsert && access.Right__c == 'Access Granted'){
                    contactKaviAdd.add(access.Contact__c);
                }
                else if (trigger.isUpdate){
                    Portal_Application_Right__c oldAccess = trigger.oldMap.get(access.Id);
                    if (access.Right__c != oldAccess.Right__c){
                        if (access.Right__c == 'Access Granted'){
                            contactKaviAdd.add(access.Contact__c);
                        }
                    }
                }
            }
            else if (access.Application_Name__c.startsWith('IATA Accreditation')){
                
                if (trigger.isInsert && access.Right__c == 'Access Granted'){
                    system.debug('IS INSERT AND GRANTED');
                    contactIdIATAAccreditationSet.add(access.Contact__c);
                }
                else if (trigger.isUpdate){
                    Portal_Application_Right__c oldAccess = trigger.oldMap.get(access.Id);
                    if (access.Right__c != oldAccess.Right__c){
                        if (access.Right__c == 'Access Granted'){
                            system.debug('IS UPDATE AND GRANTED');
                            contactIdIATAAccreditationSet.add(access.Contact__c);
                        }
                        else if (access.Right__c == 'Access Denied'){
                            system.debug('IS UPDATE AND DENIED');
                            contactIdRemoveIATAAccreditationSet.add(access.Contact__c);
                        }
                    }
                }
            }
            /*
            else if (access.Application_Name__c == 'ASD'){
            	system.debug('IS ASD');
            	if (trigger.isUpdate){
            		system.debug('IS UPDATE');
            		Portal_Application_Right__c oldAccess = trigger.oldMap.get(access.Id);
            		system.debug('CURRENT: ' + access.Right__c);
            		system.debug('OLD: ' + oldAccess.Right__c);
    	        	if (access.Right__c != oldAccess.Right__c){
    	        		system.debug('DIFFERENT RIGHT');
    					if (access.Right__c == 'Access Denied'){
    						system.debug('IS REJECTED');
    						String contactId = String.valueOf(access.Contact__c);
    			        	contactId = contactId.substring(0,15);
    			        	system.debug('To call webservice: ' + contactId);
    			    		ISSP_WS_Utilities.invokeAsdDisableUser(contactId);
    					}
    	            }
            	}
            }
            */
        }
        if (!contactIdSet.isEmpty() || !contactRemoveIdSet.isEmpty()){
            system.debug('WILL START FUTURE METHOD');
            if (!ISSP_UserTriggerHandler.preventTrigger)
            	ISSP_UserTriggerHandler.updateSIS_permissionSet(contactIdSet, contactRemoveIdSet);
            ISSP_UserTriggerHandler.preventTrigger = true;
        }

    	//deleteTwoFactor
        if (!contactRemove2FAIdSet.isEmpty()){
        	ISSP_UserTriggerHandler.deleteTwoFactor(contactRemove2FAIdSet);
        }

    	//update Federation
        if (!contactFedIdMap.isEmpty()){
        	ISSP_UserTriggerHandler.updateFederation(contactFedIdMap);
        }
        
        //Add NonTD Report Permission
        if (!contactFedIdSet.isEmpty()){
        	ISSP_UserTriggerHandler.addNonTdReportSharing(contactFedIdSet);
        }
        
        //Remove  NonTD Report Permission 
        if (!contactRemove2FAIdSet.isEmpty()){
        	ISSP_UserTriggerHandler.removeNonTdReportSharing(contactRemove2FAIdSet);
        }

        if (!contactKaviAdd.isEmpty()){
            string kaviUser = [SELECT Kavi_User__c from Contact where Id in:contactKaviAdd limit 1].Kavi_User__c;
            if (kaviUser != null ){
            ISSP_WS_KAVI.createOrUpdateKaviUsersAccounts('create2',contactKaviAdd);
                }
            else  
            {
                ISSP_WS_KAVI.createOrUpdateKaviUsersAccounts('create',contactKaviAdd);
            }
        }

    	/*
        if (!contactBaggageAdd.isEmpty()){
        	system.debug('calling addBaggageSharing');
        	ISSP_UserTriggerHandler.addBaggageSharing(contactBaggageAdd);
        	ISSP_UserTriggerHandler.giveBaggagePermissionSet(contactBaggageAdd);
        }
        if (!contactBaggageRemove.isEmpty()){
        	system.debug('calling removeBaggageSharing');
        	ISSP_UserTriggerHandler.removeBaggageSharing(contactBaggageRemove);
        	ISSP_UserTriggerHandler.removeBaggagePermissionSet(contactBaggageRemove);
        }
        */
        
        if(!manageAccessTDidSet.isEmpty()){
        	system.debug('To manageAccessTD');
        	PortalServiceAccessTriggerHandler.manageAccessTD(manageAccessTDidSet, contactFedIdSet);
        }
        
        if (!contactIdIATAAccreditationSet.isEmpty() || !contactIdRemoveIATAAccreditationSet.isEmpty()){
            system.debug('WILL START FUTURE METHOD');

            // Validate: Give permission set only to Accounts with record type == 'Standard Account' 
            List<Contact> lsContact = [SELECT Id FROM Contact where Account.recordtype.name ='Standard Account' and id in :contactIdIATAAccreditationSet];
            contactIdIATAAccreditationSet = (new Map<Id,SObject>(lsContact)).keySet(); //Replace current set with the filtered results from the query
                
            if (!ISSP_UserTriggerHandler.preventTrigger)
                ISSP_UserTriggerHandler.updateUserPermissionSet('ISSP_New_Agency_permission_set', contactIdIATAAccreditationSet, contactIdRemoveIATAAccreditationSet);
            ISSP_UserTriggerHandler.preventTrigger = true;
        }

        if(!trigger.isDelete){
            if(Trigger.new.size()>1)
                return;
                
            Portal_Application_Right__c par = Trigger.new.get(0);
            RecordType rt = [select Id from RecordType where developerName=:'Biller_Direct'];
                                             
                if(par.Invoice_Type__c!=null && par.Invoice_Type__c!='' && par.Right__c=='Access Granted' && par.RecordTypeId==rt.Id){
                    User user = [select Id,SAP_Account_Access_1__c,SAP_Account_Access_2__c,SAP_Account_Access_3__c,SAP_Account_Access_4__c from user where ContactId=:par.Contact__c];
                    par = [select Id,Invoice_Type__c,Contact__c,
                                                            Contact__r.AccountId,   Contact__r.Account.Top_Parent__c
                                                                    from Portal_Application_Right__c
                                                                        where Id =: par.Id 
                                                                        limit 1];
                 
                 
                    map<string,string> invoiceTypeSapAccoutId = new map<string,string>();
                    string topParentId = par.Contact__r.Account.Top_Parent__c!=null?
                                            par.Contact__r.Account.Top_Parent__c:
                                            par.Contact__r.AccountId;
                    
                    list<string> invoiceTypeSet = par.Invoice_Type__c.split(';');
                    map<string,string> invoiceTypeMap = new map<string,string>();
                    
                    list<SAP_Account__c> SAPAccountList = [select Id,SAP_Account_type__c,SAP_ID__c from 
                                                                    SAP_Account__c where 
                                                                    SAP_Account_type__c in:invoiceTypeSet
                                                                    and Account__c=:topParentId];                   
                    
                    for(SAP_Account__c sapAcc : SAPAccountList){
                        if(invoiceTypeMap.get(sapAcc.SAP_Account_type__c)==null)
                            invoiceTypeMap.put(sapAcc.SAP_Account_type__c,sapAcc.SAP_ID__c);
                        else
                            Trigger.new.get(0).Invoice_Type__c.addError(Label.ISSP_invoiceType_error.replace('{!invoiceType}',sapAcc.SAP_Account_type__c));
                    }
                    
                    list<string> invoiceTypeList = par.Invoice_Type__c.split(';');
                    
                    for(integer i=0;i<invoiceTypeList.size();i++){
                        string invoiceType = invoiceTypeList.get(i); 
                        string SAPAccountId = invoiceTypeMap.get(invoiceType);
                        if(SAPAccountId == null)
                            Trigger.new.get(0).Invoice_Type__c.addError(Label.ISSP_invoiceType_is_not_available.replace('{!invoiceType}',invoiceType));
                        else
                            user.put('SAP_Account_Access_'+string.valueOf(i+1)+'__c',SAPAccountId); 
                        
                    }
                   
                    update user;
                }
        }
        /*
        else{
            if(Trigger.old.size()>1)
                return;
            Portal_Application_Right__c par = Trigger.old.get(0);
            RecordType rt = [select Id from RecordType where developerName=:'Biller_Direct'];
            if(par.Invoice_Type__c!=null && par.Invoice_Type__c!='' && par.Right__c=='Access Granted' && par.RecordTypeId==rt.Id){
                User user = [select Id,SAP_Account_Access_1__c,SAP_Account_Access_2__c,SAP_Account_Access_3__c,SAP_Account_Access_4__c from user where ContactId=:par.Contact__c];
                for(integer i=0;i<4;i++){
                   user.put('SAP_Account_Access_'+string.valueOf(i+1)+'__c',''); 
                }
            }
        }
        */
    }
}