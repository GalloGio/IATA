public  class CaseChildHelper {
    
    // This method is called by a case trigger.
    // If case has status Assessment performed and the picklist __ is full then I have to create a child case. 
    
    public static boolean noValidationsOnTrgCAseIFAP = false;
    public static List<CustomPermission> customPermissionsList {
        get {
            if(customPermissionsList == null) {
                customPermissionsList = [SELECT Id, DeveloperName,
                    (SELECT Id, Parent.Name, Parent.Profile.Id, Parent.Profile.Name 
                        FROM SetupEntityAccessItems 
                        WHERE Parent.Profile.Id = :UserInfo.getProfileId()
                    )
                FROM CustomPermission
                WHERE DeveloperName = 'IFAP_Can_Bypass_Resubmission_Validation'];
            }
            return customPermissionsList;
        }
        set;
    }
    
    public static boolean CreateChildCase(list<Case> olds, list<Case> news) {
        Id IFAPrt = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
    
        system.debug('---------- DEBUG: CreateChildCase()');
        // If I have not values in news somthing's wrong
        if(news == null || news.size() == 0)
            return false;
        boolean isInsert = (olds == null);
        boolean isBefore = (news[0].id == null);    
    
        Set<String> statuses = new Set<String> {'Assessment Performed', 'Financial Security Requested', 'Financial Assessment Challenged'};    
        List<String> fieldsToCopy = new List<String>{'IFAP_Country_ISO__c','Subject', 'Description','RecordTypeId', 
                                                     'Origin', 'AccountId','ContactId','Region__c','BusinessHoursID',
                                                     'Financial_Review_Type__c','IFAP_Financial_Year__c','FS_Deadline_Date__c',
                                                     'IFAP_Financial_Month__c' //INC270744                                                     
                                                     
                                                     /*'BatchNumber__c','Priority',
                                                     'Status', 'IFAP_Country_ISO__c','Origin', 'ArchivedDate__c',
                                                     'Mass_Email_Send__c', 'Financial_Results_Archived_Date__c','FS_Mass_Email_Send__c', 'BusinessHoursId',
                                                     'Mass_Case_Creation_Email_Send__c', 'Reassessment_rejection_reason__c','FS_Request_Mass__c', 'BounceEmailSubject__c','BounceEmailCounter__c',
                                                     
                                                     'AccountId','ContactId','Region__c',
                                                     'Financial_Review_Type__c', 'IFAP_Financial_Month__c','IFAP_Financial_Year__c', 'Reason_of_rejection_IFAP__c',
                                                     'Deadline_Date__c', 'firstFAnonComplianceDate__c','FA_Second_Deadline_Date__c', 'secondFAnonComplianceDate__c',
                                                     'FA_Third_Deadline_Date__c', 'Third_FA_non_Compliance_Date__c','EmailTemplate__c', 'Submitted_Date__c',
                                                     'FA_Letter_Sent__c','Assessment_Performed_Date__c','Reminder_EmailTemplate__c','Sanity_Check_Failure_Date__c','Financial_Review_Result__c',
                                                     
                                                     'Financial_Security_Amount__c','FS_EmailTemplate__c','Financial_Security_Currency__c','FS_Reminder_EmailTemplate__c',
                                                     'FS_Deadline_Date__c','firstFSnonComplianceDate__c','FS_Second_Deadline_Date__c','secondFSnonComplianceDate__c',
                                                     'FS_Letter_Sent__c','FS_Submitted_Date__c',
                                                     
                                                     'Agent_Name_chkbx__c','Financial_Security_Template_chkbx__c','Financial_Security_Amount_chkbx__c','Financial_Security_Provider_chkbx__c',
                                                     'Financial_Security_Currency_chkbx__c','Expiry_Date_chkbx__c','Financial_Security_Type_chkbx__c',
                                                     'IFAP_CanCreateWhileClosedCase__c'*/
                                                    };    
         
        List<Case> casesToProcess = new List<Case>();
        List<Id> casesId = new List<Id>();
        List<Id> parentCasesIds = new List<Id>();
        Map<Id,Case> idToCases = new Map<id,Case>();    

	    // Generate a child case for all the cases with status "Assessment performed" and a value for Resubmittion of accounts
        // Map: case 1 = father case id -> child case to be inserted
    	//      case 2 = child case id -> father to be updated
        Map<Id,Case> parentIdToChild = new Map<Id,Case>(); //every parent should have max 1 child

        List<CustomPermission> customPermissions = customPermissionsList;
/*
        [SELECT Id, DeveloperName,
            (SELECT Id, Parent.Name, Parent.Profile.Id, Parent.Profile.Name 
                FROM SetupEntityAccessItems 
                WHERE Parent.Profile.Id = :UserInfo.getProfileId()
            )
        FROM CustomPermission
        WHERE DeveloperName = 'IFAP_Can_Bypass_Resubmission_Validation'];
*/
        Boolean userProfileCanBypassValidation = false;
        if(customPermissions != null && customPermissions.size() > 0)
            userProfileCanBypassValidation = customPermissions[0].SetupEntityAccessItems == null || customPermissions[0].SetupEntityAccessItems.isEmpty() ? false : true;
        
	    // Only for cases with record type IATA Financial Review
        // 0) check that user is not deleting parent reference on a child case
        // 1) have no parent case, status "Assessment Performed" and "Resubmission of accounts" != null
        // 2) have the have status "Assessment Performed" and a parent
        for(integer i=0; i < news.size(); i++) {
            // I consider only IFAP cases
            if(news[i].RecordTypeId != IFAPrt) 
                continue;

            // INC196368 - added exception to skip validation for IATA System user profile
            else if(!statuses.contains(news[i].Status) && news[i].status != 'Closed' &&
                    !String.isBlank(news[i].Resubmission_of_accounts__c) && !userProfileCanBypassValidation) {
                news[i].Resubmission_of_accounts__c.addError('Resubmission of accounts can be filled only if the status of the case is "Assessment Performed", "Financial Security Requested" or "Financial Assessment Challenged"');
            // If it is was a child case the parent should not be deleted
            } else if(!isInsert && olds[i].ParentId != null && news[i].ParentId == null) {
                news[i].addError('The selected account already has open IFAP cases.');           
            
            // In order to create a child case FS deadline date must be spcified
            } else if(statuses.contains(news[i].Status) &&
                    !String.isblank(news[i].Resubmission_of_accounts__c) && 
                    news[i].FS_Deadline_Date__c == null) {
                news[i].FS_Deadline_Date__c.addError('To resubmit the account FS deadline date is necessary.');

            // Case for which will be created a child case 
            } else if(//(news[i].ParentId == null)&& 
               statuses.contains(news[i].Status) &&
               !String.isblank(news[i].Resubmission_of_accounts__c) &&
               (isInsert || 
               String.isblank(olds[i].Resubmission_of_accounts__c) /*|| 
               olds[i].Status!=news[i].Status*/)) {
                casesToProcess.add(news[i]);
                casesId.add(news[i].Id);
                idToCases.put(news[i].id,news[i]);
            
            // Cases for which the parent will be closed
            } else if(news[i].ParentId != null && 
                    news[i].Status == 'Assessment Performed' &&
                    (isInsert || olds[i].Status != 'Assessment Performed')) {
                parentCasesIds.add(news[i].ParentId);
                parentIdToChild.put(news[i].ParentId,news[i]);
                idToCases.put(news[i].id,news[i]);
            }
        }
        
        List<Case> casesToUpdate = new List<Case>();
        List<Case> casesToInsert = new List<Case>();
        
        if(casesToProcess.size() > 0) {
            CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;
            
            for(Case c : [SELECT ParentId FROM Case WHERE ParentId = :casesId]) {
                parentIdToChild.put(c.ParentId, c);
                idToCases.put(c.id,c);
            }
            
            for(Case c : casesToProcess) {
                Case nc = new Case(ParentId = c.Id);//parentIdToChild.get(c.id)!=null ? parentIdToChild.get(c.id) : new Case(ParentId = c.Id);
                for(String field : fieldsToCopy)
                    nc.put(field, c.get(field));
                nc.Status = 'Agent Notified (Email)';
                nc.Deadline_Date__c = date.today().addDays(32);
                parentIdToChild.put(nc.ParentId,nc);
                casesToInsert.add(nc);
            }            
        }
        
        // Close all the parents of the cases with status "Assessment performed"
        if(parentCasesIds.size() > 0) {
            CaseChildHelper.noValidationsOnTrgCAseIFAP = true;
            for(Case c : [SELECT Status FROM Case WHERE Id IN :parentCasesIds and recordtypeId =: IFAPrt  ]) {
                c.Status = 'Closed';
                casesToUpdate.add(c);
            }        
        }


        if(casesToInsert.size() > 0) {
            //upsert casesToInsert;
            
            List<database.saveResult> results = database.insert(casesToInsert, false);
            for(integer i=0; i< results.size(); i++){
                database.saveResult res = results[i];
                if(!res.isSuccess()){
                    // If the case upserted is the father I have to print the error on the child otherwise I print the error on the father
                    id IdCaseError = casesToInsert[i].ParentId; 
                    Case CaseError = idToCases.get(IdCaseError);
                    CaseError.addError('Validation error on child case: '+res.getErrors()[0].getMessage());
                }
            }
            
        }


        if(casesToUpdate.size() > 0) {
            //upsert casesToUpdate;
            List<database.saveResult> results = database.update(casesToUpdate,false);
            for(integer i=0; i< results.size(); i++) {
                database.saveResult res = results[i];
                if(!res.isSuccess()) {
                    // If the case upserted is the father I have to print the error on the child otherwise I print the error on the father
                    id IdCaseError =  parentIdToChild.get(casesToUpdate[i].id).id; 
                    Case CaseError = idToCases.get(IdCaseError);
                    CaseError.addError('Validation error on parent case: '+res.getErrors()[0].getMessage());
                }
            }
            
        }
        return true;

    }
    
}