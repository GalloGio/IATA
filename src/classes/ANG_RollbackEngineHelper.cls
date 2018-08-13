global without sharing class ANG_RollbackEngineHelper implements Queueable{

    private Map<String,List<String>> technicalLogsMap;

    private Id oscarId;

    private String oscarName;

    private Set<Id> accountsRelated;

    private Id newParentHierarchyId;

    public void execute(QueueableContext context){
        executeAdhoc();
    }

    public void setNewParentHierarchyId(Id newParentHierarchyId){
        this.newParentHierarchyId = newParentHierarchyId;
    }
    
    public void executeAdhoc(){

        fetchTechnicalLogs(oscarId);

        AMS_AgencyRelationshipTriggerHandler.AMS_HierarchyProcess = true;
        AMS_AccountTriggerHandler.processMinorChangesValidationFlag = false; 
        rollbackData();
        AMS_OscarChangesHelper.createInternalCase(new Set<Id>{oscarId});
        sendEmailConfirmation();
        AMS_AgencyRelationshipTriggerHandler.AMS_HierarchyProcess = false;
        AMS_AccountTriggerHandler.processMinorChangesValidationFlag = true;
        generateAgencyEvents(oscarId);


    }

    public ANG_RollbackEngineHelper(Id oscarId){

        this.oscarId = oscarId;
        this.technicalLogsMap = new Map<String,List<String>>();

        accountsRelated = new Set<Id>();
        accountsRelated.addAll(fetchHierarchySelection(oscarId));

        AMS_OSCAR__c oscar = [Select Name, Account__c,New_parent__c from AMS_OSCAR__c where Id =:oscarId];

        this.oscarName = oscar.Name;

        accountsRelated.add(oscar.Account__c);

        this.newParentHierarchyId = oscar.New_parent__c;

    }

    private void fetchTechnicalLogs(Id oscarId){

        for(Technical_Logs__c tl: [SELECT Id, Log__c, Status__c, Record__c, Operation__c
                                    FROM Technical_Logs__c  
                                    WHERE Record__c =:oscarId AND Operation__c = 'Rollback']){
            
            if(technicalLogsMap.get(tl.Status__c) == null)
                technicalLogsMap.put(tl.Status__c,new List<String>{tl.Log__c});
            else
                technicalLogsMap.get(tl.Status__c).add(tl.Log__c);
        }

    }

    private void rollbackData(){


        For(String entity: technicalLogsMap.keySet()){

            if(entity == 'Account')
                processRollbackAccounts(technicalLogsMap.get(entity));
            if(entity == 'Contact')
                processRollbackContacts(technicalLogsMap.get(entity));
            if(entity == 'AMS_Account_Role__c')
                processRollbackRoles(technicalLogsMap.get(entity));
            if(entity == 'Agency_Authorization__c')
                processRollbackFops(technicalLogsMap.get(entity));
            if(entity == 'AMS_Agencies_Hierarchy__c'){
                processRollbackHierarchy(technicalLogsMap.get('AMS_Agencies_Hierarchy__c'),technicalLogsMap.get('AMS_Agencies_relationhip__c'));
            }
        }


    }

    private void processRollbackAccounts(List<String> accountList){

        List<Account> accountsToRollback = new List<Account>();

        for(String acctStr: accountList)
            accountsToRollback.add((Account) JSON.deserialize(acctStr, Account.class));

        if(!accountsToRollback.isEmpty()){
            upsert accountsToRollback;
        }

    }

    private void processRollbackContacts(List<String> contactList){
    
        List<Contact> contactsToRollback = new List<Contact>();
        Set<Id> contactIdSet = new Set<Id>();

        for(String contactStr: contactList){
            
            Contact contact = (Contact) JSON.deserialize(contactStr, Contact.class);
            contactIdSet.add(contact.Id);

            contactsToRollback.add(contact);
        }

        delete [Select Id from Contact where accountId in:accountsRelated and Id not in: contactIdSet];

        if(!contactsToRollback.isEmpty()){
            upsert contactsToRollback;
        }       

    }

    private void processRollbackRoles(List<String> roleList){

        List<AMS_Account_Role__c> rolesToRollback = new List<AMS_Account_Role__c>();
        Set<Id> roleIdSet = new Set<Id>();

        for(String roleStr: roleList){
            
            AMS_Account_Role__c role = (AMS_Account_Role__c) JSON.deserialize(roleStr, AMS_Account_Role__c.class);
            roleIdSet.add(role.Id);

            rolesToRollback.add(role);
        }

        delete [Select Id from AMS_Account_Role__c where Account__c in:accountsRelated and Id not in: roleIdSet];

        if(!rolesToRollback.isEmpty()){
            upsert rolesToRollback;
        }   
    }

    private void processRollbackFops(List<String> formsOfPaymentList){

        List<Agency_Authorization__c> fopsToRollback = new List<Agency_Authorization__c>();
        Set<Id> fopIdSet = new Set<Id>();

        for(String fopStr: formsOfPaymentList){
            
            Agency_Authorization__c fop = (Agency_Authorization__c) JSON.deserialize(fopStr, Agency_Authorization__c.class);
            fopIdSet.add(fop.Id);

            fopsToRollback.add(fop);
        }

        delete [Select Id from Agency_Authorization__c where Account__c in:accountsRelated and Id not in: fopIdSet];

        if(!fopsToRollback.isEmpty()){
            upsert fopsToRollback;
        }   

    }

    private void processRollbackHierarchy(List<String> hierarchyList, List<String> relationshipList){

        if(accountsRelated.isEmpty())   throw new AMS_ApplicationException('[ANG_RollbackEngineHelper] [processRollbackHierarchy] - List of Accounts cannot be empty.');

        //now we need to delete all relations and hierarchy to restore them completly

        Set<Id> accountsRelatedList = new Set<Id>();
        accountsRelatedList.addAll(accountsRelated);

        if(newParentHierarchyId != null)
            accountsRelatedList.add(newParentHierarchyId);

        Set<Id> hierarchiesToDeleteIds = new Set<Id>();
        Set<Id> relationsToDelete = new Set<Id>();

        for(AMS_Agencies_relationhip__c rel : [Select Id, Hierarchy__c from AMS_Agencies_relationhip__c where Child_Account__c in:accountsRelatedList or Parent_Account__c in:accountsRelatedList]){
            relationsToDelete.add(rel.Id);
            hierarchiesToDeleteIds.add(rel.Hierarchy__c);
        }

        if(!relationsToDelete.isEmpty())
            delete [Select Id from AMS_Agencies_relationhip__c where Id in :relationsToDelete];
        
        if(!hierarchiesToDeleteIds.isEmpty())
            delete [Select Id from AMS_Agencies_Hierarchy__c where Id in :hierarchiesToDeleteIds];

        List<AMS_Agencies_relationhip__c> relationsToRollback = new List<AMS_Agencies_relationhip__c>();
        List<AMS_Agencies_Hierarchy__c> hierarchiesToRollback = new List<AMS_Agencies_Hierarchy__c>();

        Map<Id,AMS_Agencies_Hierarchy__c> relationsBetweenHierarchy = new Map<Id,AMS_Agencies_Hierarchy__c>();

        for(String hiearchy: hierarchyList){
            AMS_Agencies_Hierarchy__c hierarchy = (AMS_Agencies_Hierarchy__c) JSON.deserialize(hiearchy, AMS_Agencies_Hierarchy__c.class);

            Id oldHierarchyId = hierarchy.Id;

            hierarchy.Id = null;

            relationsBetweenHierarchy.put(oldHierarchyId,hierarchy);

        }

        if(!relationsBetweenHierarchy.values().isEmpty())
            insert relationsBetweenHierarchy.values();

        for(String relationStr: relationshipList){
            AMS_Agencies_relationhip__c relation = (AMS_Agencies_relationhip__c) JSON.deserialize(relationStr, AMS_Agencies_relationhip__c.class);
            relation.Id = null;
            relation.Hierarchy__c = relationsBetweenHierarchy.get(relation.Hierarchy__c).Id;
            relationsToRollback.add(relation);
        }

        if(!relationsToRollback.isEmpty()){
            upsert relationsToRollback;
        }
    }


    private Set<Id> fetchHierarchySelection(Id oscarId){

        Set<Id> accountIds = new Set<Id>();

        for(AMS_Process_Detail__c pd: [Select Id, Account__c from AMS_Process_Detail__c where OSCAR__c =:oscarId])
            accountIds.add(pd.Account__c);
    
        return accountIds;
    }

    private void sendEmailConfirmation(){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;

        //below code will send an email to User about the status
        mail.setToAddresses( new String[] {userEmail} );
        mail.setSenderDisplayName('Apex Newgen - Rollback process');
        mail.setSubject('Apex Newgen - Rollback process');

        String toReturnBody = 'The rollback process for Oscar Case '+oscarName+' has been completed.\n\n';
        
        mail.setPlainTextBody(toReturnBody);

         if(Test.isRunningTest()){
            return;
         }

        Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});

    }

    private void generateAgencyEvents(Id oscarId){

        ANG_AgencyEventsGenerator.runDelayed = true;
        List<Agency_Applied_Change_code__c> changeCodes = new List<Agency_Applied_Change_code__c>([SELECT Id, Change_Code__c, Account__c FROM Agency_Applied_Change_code__c WHERE OSCAR__c = :oscarId AND Change_Code__c = 'CWD']);
        
        if(!changeCodes.isEmpty())
        	new ANG_AgencyEventsGenerator(changeCodes ,null,'ChangeCode','account__c').run();
        
    }
}