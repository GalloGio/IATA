public class EF_BillingAgreementHandler 
{
    private static boolean run = true;   
    
    // Submits E&F Billing Agreements for approval processing if the helper field is set to TRUE
    public static void startApprovalProcesses(List<EF_Billing_Agreement__c> baList)
    {
        for(EF_Billing_Agreement__c ba : baList)
        {
            if(ba.Require_Approval__c)
            {
                EF_BaContractApprovalHelper.submitForApproval(ba.Id, UserInfo.getUserId(), '');
            }
        }
    }

    // Identifies and handles both Approved, Rejected and Recalled approvals 
    public static void handleApprovedAndRejectedApprovals(List<EF_Billing_Agreement__c> newValues, Map<Id, EF_Billing_Agreement__c> oldValues)
    {
        // Find the Custom Setting values for "Approval Required" fields and...
        List<EF_Approve_Fields__c> fieldList = [select id, name, Billing_Agreement_Fields__c from EF_Approve_Fields__c where Name = 'BillingAgreement'];
        List<String> fields = new List<String>();
        if(fieldList.size() > 0)
            fields = fieldList.get(0).Billing_Agreement_Fields__c.split(',');
        else
            fields.add('Id');
        List<EF_Billing_Agreement__c> approvedList = EF_BaContractApprovalHelper.identifyApprovedRecords(newValues, oldValues);
        List<EF_Billing_Agreement__c> rejectedList = EF_BaContractApprovalHelper.identifyRejectedOrRecalledRecords(newValues, oldValues);
        if(approvedList.size() > 0)
        {
            // If approval occurred, copies the approved values from temporary storage onto the record itself
            EF_BaContractApprovalHelper.copyValuesFromTempStorageOnRecordApproval(approvedList, fields, 'EF_Billing_Agreement__c');
            for(EF_Billing_Agreement__c approved : approvedList)
            {
                approved.Requested_Changes__c = '';
            }
        }
        if(rejectedList.size() > 0)
        {
            // Or if rejected or recalled, simply ignore the changes and get rid of the temp storage record
            EF_BaContractApprovalHelper.removeTempStorageRecordOnRecordRejection(rejectedList, 'EF_Billing_Agreement__c');
            for(EF_Billing_Agreement__c rejected : rejectedList)
            {
                rejected.Requested_Changes__c = '';
            }
        }
    }

    // Queries for any Contracts that do only allow Billing Agreements to be updated with approval
    public static void handleWithApprovalContractUpdates(Map<Id, EF_Billing_Agreement__c> newAgreements, Map<Id, EF_Billing_Agreement__c> oldAgreements)
    {
        Set<Id> contractIds = new Set<Id>();
        for(EF_Billing_Agreement__c ba : newAgreements.values())
        {
            // add both Client and Customer (Airline) into the Set, so that both will be queried for
            contractIds.add(ba.Contract__c);
        }

        Map<Id, Contract> contractsInvolved = new Map<Id, Contract>([select id, EF_Allow_Billing_Agreements__c from Contract where Id in :contractIds and EF_Allow_Billing_Agreements__c = 'Allowed with Approval']);
        if(contractsInvolved.size() > 0)
        {
            List<EF_Billing_Agreement__c> agreementsToApprove = new List<EF_Billing_Agreement__c>();
            for(EF_Billing_Agreement__c allAgreements : newAgreements.values())
            {
                if(contractsInvolved.get(allAgreements.Contract__c) != null && !allAgreements.Skip_Approval__c)
                    agreementsToApprove.add(allAgreements);
            }

            // Create a list of EF Approval records that will be stored in the system to contain the UPDATED versions of Billing Agreements
            List<EF_Approval__c> approvalStorageList = new List<EF_Approval__c>();
            // Get the list of fields that require Approval from Custom Settings and place them in a List
            List<EF_Approve_Fields__c> fieldList = [select id, name, Billing_Agreement_Fields__c from EF_Approve_Fields__c where Name = 'BillingAgreement'];
            List<String> editFields = fieldList.get(0).Billing_Agreement_Fields__c.split(',');

            List<String> fields = new List<String>();
            for(String f : editFields)
            {
                if(f.equals('EF_Location_ID__c'))
                    f = 'EF_Location_ID_Name__c';
                if(f.equals('Airline__c'))
                    f = 'Airline_Name__c';

                fields.add(f);
            }

            // If there are any Billing Agreements that require approval, start the process to temporarily store them into another object
            for(EF_Billing_Agreement__c ba : agreementsToApprove)
            {
                if(EF_BaContractApprovalHelper.identifyRecordChanges(ba, oldAgreements.get(ba.Id), fields, false))
                {
                    EF_Approval__c approval = EF_BaContractApprovalHelper.fillTemporaryApprovalStorage(new EF_Approval__c(), ba, editFields, 'EF_Billing_Agreement__c');
                    ba.Require_Approval__c = true;
                    approvalStorageList.add(approval);
                    EF_BaContractApprovalHelper.rollbackPreviousValues(ba, oldAgreements.get(ba.Id), editFields);
                }
            }

            if(approvalStorageList.size() > 0)
            {
                insert approvalStorageList;
            }
        }
    }

    // For after insert trigger to find out if any of the attached Accounts is set to "Allow Billing Agreements with Approval"
    public static Set<Id> findIdsOfWithApprovalBillingAgreements(List<EF_Billing_Agreement__c> agreementList)
    {
        Set<Id> contractIds = new Set<Id>();
        for(EF_Billing_Agreement__c ba : agreementList)
        {
            if(!ba.Skip_Approval__c)
            {
                contractIds.add(ba.Contract__c);
            }
        }

        Set<Id> withApprovalIds = new Set<Id>();
        Map<Id, Contract> contractsInvolved = new Map<Id, Contract>([select id, EF_Allow_Billing_Agreements__c from Contract where Id in :contractIds and EF_Allow_Billing_Agreements__c = 'Allowed with Approval']);
        for(EF_Billing_Agreement__c ba : agreementList)
        {
            if(contractsInvolved.get(ba.Contract__c) != null)
                withApprovalIds.add(ba.Id);
        }
        return withApprovalIds;
    }

    // Queries for any Accounts that do only allow Billing Agreements to be created with approval
    public static void handleWithApprovalContractInserts(List<EF_Billing_Agreement__c> agreementList)
    {
        Set<Id> contractIds = new Set<Id>();
        for(EF_Billing_Agreement__c ba : agreementList)
        {
            // add both Client and Customer (Airline) into the Set, so that both will be queried for
            contractIds.add(ba.Contract__c);
        }

        // Find if any of the related accounts doesn't allow billing agreements to be created without approval and force-start an approval process
        Map<Id, Contract> contractsInvolved = new Map<Id, Contract>([select id, EF_Allow_Billing_Agreements__c from Contract where Id in :contractIds and EF_Allow_Billing_Agreements__c = 'Allowed with Approval']);
        
        // Get the list of fields that require Approval from Custom Settings and place them in a List
        List<EF_Approve_Fields__c> fieldList = [select id, name, Billing_Agreement_Fields__c from EF_Approve_Fields__c where Name = 'BillingAgreement'];
        List<String> editFields = fieldList.get(0).Billing_Agreement_Fields__c.split(',');
        
        List<String> fields = new List<String>();
            for(String f : editFields)
            {
                if(f.equals('EF_Location_ID__c'))
                    f = 'EF_Location_ID_Name__c';
                if(f.equals('Airline__c'))
                    f = 'Airline_Name__c';

                fields.add(f);
            }

        // If there are any Billing Agreements that require approval, start the process to temporarily store them into another object
        for(EF_Billing_Agreement__c ba : agreementList)
        {
            if(contractsInvolved.get(ba.Contract__c) != null)
            {
                ba.Require_Approval__c = true;
                ba.EF_Status__c = 'Inactive';
                EF_BaContractApprovalHelper.identifyRecordChanges(ba, null, fields, true);
            }
        }
    }

    //checks if location chosen has been set in Contract Location Currency.
    public static void checkLocationCurrency (List<EF_Billing_Agreement__c> relationshipList){

        //check if relationship records have location.
        List <EF_Billing_Agreement__c> relWithLocation = new List <EF_Billing_Agreement__c>();

        for(EF_Billing_Agreement__c rel: relationshipList){
            if(rel.EF_Location_ID__c!=null && !rel.Skip_Approval__c){
                relWithLocation.add(rel);
            }
        }

        Set <Id> contractIdSet = new Set <Id>();

        if(!relWithLocation.isEmpty()){

            for(EF_Billing_Agreement__c r: relWithLocation){
                contractIdSet.add(r.Contract__c);
            }

            Map <Id, Contract> contractMap = new Map <Id, Contract>([Select Id, (Select Id, Location_ID__c, Location_ID__r.Name, Contract__c, EF_Billing_Currency__c from EF_Locations_Currencies__r),
            (select Id, EF_Location_ID__c, EF_Location_ID__r.Name, Contract__c, Billing_Currency__c from EF_Relationships__r) from Contract where Id in: contractIdSet]);
            
            //create a map in which we store all the locations present in contract
            Map <Id, EF_Location_Currency__c> mapLocationsInLocationCurrency = new Map <Id, EF_Location_Currency__c> ();
            
            for(Contract c: contractMap.values()){
                for(EF_Location_Currency__c lc: c.EF_Locations_Currencies__r){
                    mapLocationsInLocationCurrency.put(lc.Location_ID__c, lc);
                }
            }

            //create a map in which we store all the billing agreements already present in contract
            Map <Id, EF_Billing_Agreement__c> mapRelationshipsInContract = new Map <Id, EF_Billing_Agreement__c> ();
            for(Contract c: contractMap.values()){
                for(EF_Billing_Agreement__c r: c.EF_Relationships__r){
                    mapRelationshipsInContract.put(r.EF_Location_ID__c, r);
                }
            }
           
            //check if location chosen in relationship is present in Contract Location Currencies
            for(EF_Billing_Agreement__c r: relWithLocation){
                if(mapLocationsInLocationCurrency.isEmpty() && r.EF_Location_ID__c!=null){
                   r.EF_Location_ID__c.addError('Please set before location currencies on contract.');
                }else{
                    if(!mapLocationsInLocationCurrency.containsKey(r.EF_Location_ID__c)){
                        r.EF_Location_ID__c.addError('Location chosen is not allowed. It has not been defined in Contract as a valid location.');
                    }else{
                            for(EF_Location_Currency__c lc: contractMap.get(r.Contract__c).EF_Locations_Currencies__r){
                                //System.debug('#### REL loc Id ' + r.EF_Location_ID__c + r.EF_Location_ID__r.Name + ' --- location Currency ' + lc.Location_ID__c + lc.Location_ID__r.Name);
                                if(r.EF_Location_ID__c== lc.Location_ID__c){
                                    // set currency in relationship as the one defined on the locationCurrency
                                    r.Billing_Currency__c = lc.EF_Billing_Currency__c;
                                }
                            }
                       
                    }
                }
            }
        }// end if relationship has location
    }
    
    //checks if currencies chosen has been set in Contract Currencies.
    public static void checkCurrencyFromContract (List<EF_Billing_Agreement__c> relationshipList, Map<Id,EF_Billing_Agreement__c> relationshipOldMap){
        
        String errorMessage = Label.EF_Currency_Not_In_Contract_Error;
        List<EF_Billing_Agreement__c> workdata = new List<EF_Billing_Agreement__c>();
        Set<Id> contractIdSet = new Set<Id>();

        for (EF_Billing_Agreement__c rel : relationshipList) {
            
            EF_Billing_Agreement__c oldRel = (relationshipOldMap != null && relationshipOldMap.containsKey(rel.Id) ? relationshipOldMap.get(rel.Id) : new EF_Billing_Agreement__c());
            
            if ((rel.Data_Currency__c != null && rel.Data_Currency__c != oldRel.Data_Currency__c) ||
                (rel.Payment_Currency__c != null && rel.Payment_Currency__c != oldRel.Payment_Currency__c)) {
                
                workdata.add(rel);
                contractIdSet.add(rel.Contract__c);
            }
        }
        
        if (workdata.size() > 0) {
            
            Map <Id, Contract> contractMap = new Map <Id, Contract>([Select Id, EF_Data_Currency__c, EF_Payment_Currency__c from Contract where Id in: contractIdSet]);
            Contract cont;
            Set<String> values;
            
            for (EF_Billing_Agreement__c rel : workdata) {
                
                cont = contractMap.get(rel.Contract__c);
                
                // Data_Currency__c validation
                if (rel.Data_Currency__c != null) {
                    
                    if (cont.EF_Data_Currency__c != null) {
                        
                        values = new Set<String>(cont.EF_Data_Currency__c.split(';'));
                    } else {
                        
                        values = new Set<String>();
                    }
                    
                    if (values.contains(rel.Data_Currency__c) == false) {
                        
                        rel.Data_Currency__c.addError(errorMessage);
                    }
                }
                
                values = null;
                
                // Payment_Currency__c validation
                if (rel.Payment_Currency__c != null) {
                    
                    if (cont.EF_Payment_Currency__c != null) {
                        
                        values = new Set<String>(cont.EF_Payment_Currency__c.split(';'));
                    } else {
                        
                        values = new Set<String>();
                    }
                    
                    if (values.contains(rel.Payment_Currency__c) == false) {
                        
                        rel.Payment_Currency__c.addError(errorMessage);
                    }   
                }
            }
        }
    }

    public static void revertSkipApprovalIfNecessary(List<EF_Billing_Agreement__c> newList, Map<Id,EF_Billing_Agreement__c> oldMap)
    {
        for(EF_Billing_Agreement__c ba : newList)
        {
            if(ba.Skip_Approval__c && !oldMap.get(ba.Id).Skip_Approval__c)
            {
                ba.Skip_Approval__c = false;
            }
        }
    }

    // helper method to stop Billing Agreement Trigger from running more than once per update
    public static boolean runOnce()
    {
        if(run)
        {
            run = false;
            return true;
        }
        else
        {
            return run;
        }
    }
    
    public static void setClientFromRelatedContract(List<EF_Billing_Agreement__c> agreementList) {

        Set <Id> contractIdSet = new Set <Id> ();
        for(EF_Billing_Agreement__c ba: agreementList){
            contractIdSet.add(ba.Contract__c);
        }

        Map<Id, Contract> contractMap = new Map<Id, Contract> ([select Id, AccountId from Contract where Id in: contractIdSet]);

        for(EF_Billing_Agreement__c ba : agreementList) {
            if(contractMap.containsKey(ba.Contract__c)){
                ba.Client__c = contractMap.get(ba.Contract__c).AccountId;
            }            

        }
    }

    //E&F Notification of fields identified as critical. List of fields set on custom setting.
    public static void manageCriticalFieldChanges(List<EF_Billing_Agreement__c> bas, Map<Id,EF_Billing_Agreement__c> oldMap){
        List<EF_Critical_Field_Notification__c> fieldList = EF_Utilities.getCriticalFields();

        List  <String> criticalBAFieldList = new List <String> ();
        if(!fieldList.isEmpty()){
            for(EF_Critical_Field_Notification__c cfn: fieldList){
                criticalBAFieldList= cfn.Airline_Billing_Agreement_Fields__c.split(',');                     
            }
            
            Map <Id,EF_Billing_Agreement__c> basNoti = new Map <Id,EF_Billing_Agreement__c>();
           
            Map<String, Schema.SobjectField> fields = bas.getSObjectType().getDescribe().fields.getMap();

            //loop over Billing Agreements to check if any of them need to trigger a notification.
            for(EF_Billing_Agreement__c ba: bas){           
                //check fields for Billing Agreement
                for(String s: criticalBAFieldList){                    
                        if(ba.get(s)!=oldMap.get(ba.Id).get(s)){                       
                            basNoti.put(ba.Id, ba);
                        }
                    }            
            }

            if(!basNoti.isEmpty()){
                notifyOnCriticalFields(basNoti, oldMap, criticalBAFieldList);
            
            }
        }
        
    }

    public static void notifyOnCriticalFields (Map <Id, EF_Billing_Agreement__c> newBAs, Map <Id,EF_Billing_Agreement__c> oldBAMap, List <String> criticalFieldList ) {

        Set <Id> contractIdSet = new Set <Id>();
        for(EF_Billing_Agreement__c ba: newBAs.values()){
            contractIdSet.add(ba.Contract__c);
        }
        Map <Id, Contract> contractMap = new Map <Id, Contract>([select Id, EF_DT_Specialist__c, EF_IA_Specialist__c, EF_DT_Specialist_Email__c, EF_IA_Specialist_Email__c from Contract where id in: contractIdSet]);

        Map<String, Schema.SobjectField> fields = newBAs.getSObjectType().getDescribe().fields.getMap();
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for(EF_Billing_Agreement__c ba: newBAs.values()){
            String emailBody = 'Dear team member, <br/><br/>the following Airline Billing Agreement values been UPDATED:<br/><br/>';
            emailBody = emailBody + '<table width="600px" border="1"><tr border="1"><th border="1">Contract</th><th border="1">Field:</th><th border="1">New Value:</th><th border="1">Old Value:</th></tr>';
        
           for(String s: criticalFieldList){              
                if(ba.get(s)!=oldBAMap.get(ba.Id).get(s)){
                    emailBody = emailBody + '<tr><td border="1"><a href="'+baseUrl+'/'+ba.Id+'">'+ba.BillingAgreement_Name__c+'</a></td><td border="1">'+s+'</td><td border="1">'+ba.get(s)+'</td><td border="1">'+oldBAMap.get(ba.Id).get(s)+'</td></tr>';
                }
           }
           emailBody = emailBody + '</table>';
           if(contractMap.containsKey(ba.Contract__c) &&  contractMap.get(ba.Contract__c).EF_DT_Specialist__c!=null && contractMap.get(ba.Contract__c).EF_IA_Specialist__c!=null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSaveAsActivity(false);
                mail.setToAddresses(new List <String> {contractMap.get(ba.Contract__c).EF_DT_Specialist_Email__c, contractMap.get(ba.Contract__c).EF_IA_Specialist_Email__c, 'efs@iata.org'}); 
                mail.setSubject('E&F Airline Billing Agreement Critical Changes Notification');
                mail.setBccSender(false);
                mail.setUseSignature(false);       
                mail.setHtmlBody(emailBody);
                mails.add(mail);
                //Utility.sendEmail(new List <String> {contractMap.get(ba.Contract__c).EF_DT_Specialist_Email__c, contractMap.get(ba.Contract__c).EF_IA_Specialist_Email__c, 'efs@iata.org'}, 'E&F Airline Billing Agreement Critical Changes Notification ', emailBody, true, null);
           }else if(contractMap.containsKey(ba.Contract__c) && contractMap.get(ba.Contract__c).EF_DT_Specialist__c==null && contractMap.get(ba.Contract__c).EF_IA_Specialist__c!=null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSaveAsActivity(false);
                mail.setToAddresses(new List <String> {contractMap.get(ba.Contract__c).EF_DT_Specialist_Email__c, 'efs@iata.org'}); 
                mail.setSubject('E&F Airline Billing Agreement Critical Changes Notification');
                mail.setBccSender(false);
                mail.setUseSignature(false);       
                mail.setHtmlBody(emailBody);
                mails.add(mail);
                //Utility.sendEmail(new List <String> {contractMap.get(ba.Contract__c).EF_IA_Specialist_Email__c, 'efs@iata.org'}, 'E&F Airline Billing Agreement Critical Changes Notification ', emailBody, true, null);
           }else if(contractMap.containsKey(ba.Contract__c) && contractMap.get(ba.Contract__c).EF_DT_Specialist__c!=null && contractMap.get(ba.Contract__c).EF_IA_Specialist__c==null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSaveAsActivity(false);
                mail.setToAddresses(new List <String> {contractMap.get(ba.Contract__c).EF_DT_Specialist_Email__c, 'efs@iata.org'}); 
                mail.setSubject('E&F Airline Billing Agreement Critical Changes Notification');
                mail.setBccSender(false);
                mail.setUseSignature(false);       
                mail.setHtmlBody(emailBody);
                mails.add(mail);
                //Utility.sendEmail(new List <String> {contractMap.get(ba.Contract__c).EF_DT_Specialist_Email__c, 'efs@iata.org'}, 'E&F Airline Billing Agreement Critical Changes Notification ', emailBody, true, null);
           }else{
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSaveAsActivity(false);
                mail.setToAddresses(new List <String> {'efs@iata.org'}); 
                mail.setSubject('E&F Airline Billing Agreement Critical Changes Notification');
                mail.setBccSender(false);
                mail.setUseSignature(false);       
                mail.setHtmlBody(emailBody);
                mails.add(mail);
                //Utility.sendEmail(new List <String> {'efs@iata.org'}, 'E&F Airline Billing Agreement Critical Changes Notification ', emailBody, true, null);
           }
        } 

        if(!mails.isEmpty()){
            Messaging.sendEmail(mails);
        }            
              
    }
    
    public static void deactivateBillingAgreement(List<EF_Billing_Agreement__c> agreementList){
    	for(EF_Billing_Agreement__c ba : agreementList){
    		ba.EF_Status__c = 'Inactive';
    	}
    }
    
	public static void checkIfBillingAgreementDeactivationRequired(Map<Id,EF_Billing_Agreement__c> agreementMap){
		Set<Id> involvedBas = agreementMap.keySet();
		
		// Retrieve the list of Billing Agreement for which there is at least one active Material Line Item
    	AggregateResult[] activableBAs = [Select EF_Relationship__c FROM EF_Material_Line_Item__c WHERE EF_Relationship__c IN :involvedBAs AND EF_Status__c = 'Active' GROUP BY EF_Relationship__c];

		// For each involved Billing Agreement, check if it still has a Material Line Item
		List<EF_Billing_Agreement__c> withoutItemBAs = new List<EF_Billing_Agreement__c>();
		for(Id involvedBa : involvedBAs){
			Boolean baHasItem = false;

			for(AggregateResult activableBA : activableBAs){
				if(activableBA.get('EF_Relationship__c') == involvedBa){
					baHasItem = true;
					break;
				}
			}
			
			if(!baHasItem){
				withoutItemBAs.add(agreementMap.get(involvedBa));
			}
		}

		deactivateBillingAgreement(withoutItemBAs);
    }
}