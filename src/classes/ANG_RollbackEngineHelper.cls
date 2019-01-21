global without sharing class ANG_RollbackEngineHelper implements Queueable{

    private Map<String,List<String>> technicalLogsMap;

    private Id oscarId;

    private String oscarName;
    
    private List<String> typesOfChange;

    private Set<Id> accountsRelated;

    private Id newParentHierarchyId;

    private boolean isHierarchyChange;

    public void execute(QueueableContext context){
        executeAdhoc();
    }

    public void setNewParentHierarchyId(Id newParentHierarchyId){
        this.newParentHierarchyId = newParentHierarchyId;
    }
    
    public void executeAdhoc(){

   		System.SavePoint sp;

        try{
            sp = Database.setSavePoint();
            AMS_AgencyRelationshipTriggerHandler.AMS_HierarchyProcess = true;
            AMS_AccountTriggerHandler.processMinorChangesValidationFlag = false; 
            System.debug('Initiating Rollback.');
            rollbackData();
            System.debug('Rollback finished.');
            AMS_OscarChangesHelper.createInternalCase(new Set<Id>{oscarId});
            sendEmailConfirmation(null);
            AMS_AgencyRelationshipTriggerHandler.AMS_HierarchyProcess = false;
            AMS_AccountTriggerHandler.processMinorChangesValidationFlag = true;
            generateAgencyEvents(oscarId);

        }catch(Exception e){
            System.debug('Something went wrong with the Rollback process:'+e.getStackTraceString());
            Database.rollback(sp);
            sendEmailConfirmation(e);
        }
    }

    public ANG_RollbackEngineHelper(Id oscarId){

        this.oscarId = oscarId;
        this.technicalLogsMap = new Map<String,List<String>>();
        fetchTechnicalLogs(oscarId);

        AMS_OSCAR__c oscar = [Select Name, Account__c,New_parent__c, ANG_Type_Of_Change__c from AMS_OSCAR__c where Id =:oscarId];

        accountsRelated = new Set<Id>();
        accountsRelated.addAll(fetchHierarchySelection(oscar.Account__c));
		accountsRelated.add(oscar.account__c);

        this.typesOfChange = new List<String>();
        if (oscar.ANG_Type_Of_Change__c.contains(';')) this.typesOfChange.addAll(oscar.ANG_Type_Of_Change__c.split(';'));
        else this.typesOfChange.add(oscar.ANG_Type_Of_Change__c);

        this.oscarName = oscar.Name;

        this.newParentHierarchyId = oscar.New_parent__c;

        isHierarchyChange = oscar.ANG_Type_Of_Change__c.contains(AMS_Utils.ANG_HIERARCHY);

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
        
        if(technicalLogsMap.isEmpty()){
            System.System.debug('There is nothing to rollback, doing nothing here.');
            return;
        }

        For(String entity: technicalLogsMap.keySet()){

            if(entity == 'Account')
                processRollbackAccounts(technicalLogsMap.get(entity));
            if(entity == 'Contact')
                processRollbackContacts(technicalLogsMap.get(entity));
            if(entity == 'AMS_Account_Role__c')
                processRollbackRoles(technicalLogsMap.get(entity));
            if(entity == 'Agency_Authorization__c')
                processRollbackFops(technicalLogsMap.get(entity));
            if(entity == 'ANG_RHC_Information__c')
                processRollbackRHCs(technicalLogsMap.get(entity));
            if(entity == 'Financial_Security__c')
                processRollbackFSs(technicalLogsMap.get(entity));
            if(entity == 'ANG_Agency_Risk_Event__c')
                processRollbackREs(technicalLogsMap.get(entity));
            if(entity == 'Portal_Application_Right__c')
                processRollbackPortalAppRights(technicalLogsMap.get(entity));
        }

        if(technicalLogsMap.get('AMS_Agencies_Hierarchy__c') != null || technicalLogsMap.get('AMS_Agencies_relationhip__c') != null || isHierarchyChange)
            processRollbackHierarchy(technicalLogsMap.get('AMS_Agencies_Hierarchy__c'),technicalLogsMap.get('AMS_Agencies_relationhip__c'));



    }

    private void processRollbackAccounts(List<String> accountList){
        Map<Id, Account> accountsToRollback = new Map<Id, Account>();

        for(String acctStr: accountList) {
            Account a = (Account) JSON.deserialize(acctStr, Account.class);
            accountsToRollback.put(a.Id, a);
        }

        if (this.typesOfChange.contains(AMS_Utils.ANG_ACCREDITATION_TYPE)) {
            delete [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c IN (SELECT Id FROM Account WHERE ID IN :accountsToRollback.keySet() AND ANG_Accreditation_model__c = 'Cash')];
        }

        if(!accountsToRollback.isEmpty()){
            upsert accountsToRollback.values();
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

    private void processRollbackPortalAppRights(List<String> parList) {
        Map<Id, Portal_Application_Right__c> parsToRollback = new Map<Id, Portal_Application_Right__c>();

        for(String parString: parList){
            Portal_Application_Right__c par = (Portal_Application_Right__c) JSON.deserialize(parString, Portal_Application_Right__c.class);

            parsToRollback.put(par.Id, par);
        }

        Map<Id, Portal_Application_Right__c> existingPARs = new Map<Id, Portal_Application_Right__c>([SELECT Id FROM Portal_Application_Right__c WHERE Id IN :parsToRollback.keySet()]);

        for (Id parId: parsToRollback.keySet()) {
            if (!existingPARs.keySet().contains(parId)) {
                parsToRollback.get(parId).Id = null;
            }
        }

        delete [Select Id from Portal_Application_Right__c where Account__c in:accountsRelated and Id not in: parsToRollback.keySet()];

        if(!parsToRollback.values().isEmpty()){
            upsert parsToRollback.values();
        }
    }
    
    private void processRollbackRHCs(List<String> RHCList){
        Map<Id, ANG_RHC_Information__c> RHCsToRollback = new Map<Id, ANG_RHC_Information__c>();

        for(String RHCstring: RHCList){
            ANG_RHC_Information__c rhc = (ANG_RHC_Information__c) JSON.deserialize(RHCstring, ANG_RHC_Information__c.class);
            RHCsToRollback.put(rhc.Id, rhc);
        }

        Map<Id, ANG_RHC_Information__c> existingRHCs = new Map<Id, ANG_RHC_Information__c>([SELECT Id FROM ANG_RHC_Information__c WHERE Id IN :RHCsToRollback.keySet()]);

        for (Id rhcId: RHCsToRollback.keySet()) {
            if (!existingRHCs.keySet().contains(rhcId)) {
                RHCsToRollback.get(rhcId).Id = null;
            }
        }

        delete [Select Id from ANG_RHC_Information__c where ANG_AccountId__c in:accountsRelated and Id not in: RHCsToRollback.keySet()];

        if(!RHCsToRollback.values().isEmpty()){
            upsert RHCsToRollback.values();
        }
    }

    private void processRollbackFSs(List<String> FSsList){

        List<Financial_Security__c> FSsToRollback = new List<Financial_Security__c>();
        Set<Id> FSids = new Set<Id>();

        for(String fsStr: FSsList){
            
            Financial_Security__c fs = (Financial_Security__c) JSON.deserialize(fsStr, Financial_Security__c.class);
            FSids.add(fs.Id);

            FSsToRollback.add(fs);
        }

        delete [Select Id from Financial_Security__c where Account__c in:accountsRelated and Id not in: FSids];

        if(!FSsToRollback.isEmpty()){
            upsert FSsToRollback;
        }   
    }

    private void processRollbackREs(List<String> REList){
    
        List<ANG_Agency_Risk_Event__c> REToRollback = new List<ANG_Agency_Risk_Event__c>();
        Set<Id> reIdSet = new Set<Id>();

        for(String reStr: REList){
            
            ANG_Agency_Risk_Event__c re = (ANG_Agency_Risk_Event__c) JSON.deserialize(reStr, ANG_Agency_Risk_Event__c.class);
            reIdSet.add(re.Id);

            REToRollback.add(re);
        }

        delete [Select Id from ANG_Agency_Risk_Event__c where ANG_AccountId__c in:accountsRelated and Id not in: reIdSet];

        if(!REToRollback.isEmpty()){
            upsert REToRollback;
        }       

    }

    private void processRollbackHierarchy(List<String> hierarchyList, List<String> relationshipList){

        if(accountsRelated.isEmpty())   throw new AMS_ApplicationException('[ANG_RollbackEngineHelper] [processRollbackHierarchy] - List of Accounts cannot be empty.');

        //now we need to delete all relations and hierarchy to restore them completly

        Set<Id> accountsRelatedList = new Set<Id>();
        accountsRelatedList.addAll(accountsRelated);

        if(newParentHierarchyId != null)
            accountsRelatedList.add(newParentHierarchyId);

        System.debug('accountsRelatedList to rollback is:'+accountsRelatedList);

        Set<Id> hierarchiesToDeleteIds = new Set<Id>();
        Set<Id> relationsToDelete = new Set<Id>();

        for(AMS_Agencies_relationhip__c rel : [Select Id, Hierarchy__c from AMS_Agencies_relationhip__c where Child_Account__c in:accountsRelatedList or Parent_Account__c in:accountsRelatedList]){
            relationsToDelete.add(rel.Id);
            hierarchiesToDeleteIds.add(rel.Hierarchy__c);
        }

        System.debug('relationsToDelete are:'+relationsToDelete);

        if(!relationsToDelete.isEmpty())
            delete [Select Id from AMS_Agencies_relationhip__c where Id in :relationsToDelete];
        
        if(!hierarchiesToDeleteIds.isEmpty())
            delete [Select Id from AMS_Agencies_Hierarchy__c where Id in :hierarchiesToDeleteIds];

        if(hierarchyList == null && relationshipList == null)
            return;

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


/*
    private Set<Id> fetchHierarchySelection(Id oscarId){

        Set<Id> accountIds = new Set<Id>();

        for(AMS_Process_Detail__c pd: [Select Id, Account__c from AMS_Process_Detail__c where OSCAR__c =:oscarId])
            accountIds.add(pd.Account__c);
    
        return accountIds;
    }
*/

	private Set<Id> fetchHierarchySelection(Id accountOscar){

		Set<Id> accountIds = new Set<Id>();
/*
		Account acct = [Select Id, Location_Type__c, ParentId from Account where Id =:accountOscar];
		Id accountId = acct.Id;
		
		if(acct.Location_Type__c <> AMS_Utils.HE)
			accountId = acct.ParentId;

		for(Account acctToSearch: [Select Id from Account where ParentId =:accountId])
			accountIds.add(acctToSearch.Id);
	
		accountIds.add(accountId);
*/
        if(technicalLogsMap.size() > 0) {
            System.debug('technicalLogsMap are:'+technicalLogsMap);
            
            for(String acctStr : technicalLogsMap.get('Account')){

                Account a = (Account) JSON.deserialize(acctStr, Account.class);

                accountIds.add(a.Id);
            }
        }
        
		return accountIds;
	}

    private void sendEmailConfirmation(Exception e){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;

        //below code will send an email to User about the status
        mail.setToAddresses( new String[] {userEmail} );
        mail.setSenderDisplayName('Apex Newgen - Rollback process');
        mail.setSubject('Apex Newgen - Rollback process');

        String toReturnBody;

        if(e ==null)
            toReturnBody = 'The rollback process for Oscar Case '+oscarName+' has been completed.\n\n';
        else {
           toReturnBody = 'There was an error with the rollback process regarding Oscar Case '+oscarName+'.\n\n';
           toReturnBody+= 'Message:'+e.getMessage()+'\n\n';
           toReturnBody+= 'Stacktrace:'+e.getStackTraceString()+'\n\n';
           toReturnBody+= 'Please contact app support for further assistance';
        }

        mail.setPlainTextBody(toReturnBody);

         if(Test.isRunningTest()){
            return;
         }

        Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});

    }

    private void generateAgencyEvents(Id oscarId){

        List<Agency_Applied_Change_code__c> changeCodes = new List<Agency_Applied_Change_code__c>([SELECT Id, Change_Code__c, Account__c FROM Agency_Applied_Change_code__c WHERE OSCAR__c = :oscarId AND Change_Code__c = 'CWD']);
        
        if(!changeCodes.isEmpty())
            new ANG_AgencyEventsGenerator(changeCodes ,null,'ChangeCode','account__c').run(true);
        
    }
}