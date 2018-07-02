public class EF_ContractHandler 
{
    private static boolean run = true;
    

    // Ensure's that any changes to Contract's Currency fields won't cause data-inconsistency for Billing Agreements
    public static void validateContractCurrencyRemoval(List<Contract> newLines, Map<Id, Contract> contractOldMap)
    {
        // Ignore new inserts and only activate code on Update or Deletion
        
        
        
        if(contractOldMap != null)
        {
            List<EF_Billing_Agreement__c> baList = [select id, name, Billing_Currency__c, Data_Currency__c, Payment_Currency__c, Contract__c from EF_Billing_Agreement__c where EF_Status__c = 'Active' and Contract__c in :contractOldMap.keySet()];
            
            Set<String> dataCurrencies = new Set<String>();
            Set<String> billingCurrencies = new Set<String>();
            Set<String> paymentCurrencies = new Set<String>();


            Map<Id, Set<String>> contractDataCurrenciesMap = new Map<Id, Set<String>>();
            Map<Id, Set<String>> contractBillingCurrenciesMap = new Map<Id, Set<String>>();
            Map<Id, Set<String>> contractPaymentCurrenciesMap = new Map<Id, Set<String>>();

            Map<Id, List<String>> errorDataCurrencyListingMap = new Map<Id, List<String>>();
            Map<Id, List<String>> errorBillingCurrencyListingMap = new Map<Id, List<String>>();
            Map<Id, List<String>> errorPaymentCurrencyListingMap = new Map<Id, List<String>>();

            for(EF_Billing_Agreement__c ba : baList)
            {
                if(contractDataCurrenciesMap.containsKey(ba.Contract__c))
                {
                    if(ba.Data_Currency__c != null)
                        contractDataCurrenciesMap.get(ba.Contract__c).addAll(ba.Data_Currency__c.split(';'));
                }
                else
                {
                    if(ba.Data_Currency__c != null)
                    {
                        dataCurrencies.addAll(ba.Data_Currency__c.split(';'));
                        contractDataCurrenciesMap.put(ba.Contract__c, dataCurrencies);
                    }
                }

                if(contractBillingCurrenciesMap.containsKey(ba.Contract__c))
                {
                    if(ba.Billing_Currency__c != null)
                       contractBillingCurrenciesMap.get(ba.Contract__c).addAll(ba.Billing_Currency__c.split(';'));
                }
                else
                {
                    if(ba.Billing_Currency__c != null)
                    {
                        billingCurrencies.addAll(ba.Billing_Currency__c.split(';'));
                        contractBillingCurrenciesMap.put(ba.Contract__c, billingCurrencies);
                    }
                }
                if(contractPaymentCurrenciesMap.containsKey(ba.Contract__c))
                {
                    if(ba.Payment_Currency__c != null)
                        contractPaymentCurrenciesMap.get(ba.Contract__c).addAll(ba.Payment_Currency__c.split(';'));
                }
                else
                {
                    if(ba.Payment_Currency__c != null)
                    {
                        paymentCurrencies.addAll(ba.Payment_Currency__c.split(';'));
                        contractPaymentCurrenciesMap.put(ba.Contract__c, paymentCurrencies);
                    }
                }
            }

            
            for(Contract c : newLines)
            {
                Set<String> currentDataCurrencies = new Set<String>();
                if(c.EF_Data_Currency__c != null)
                    currentDataCurrencies.addAll(c.EF_Data_Currency__c.split(';'));
                Set<String> currentBillingCurrencies = new Set<String>();
                if(c.EF_Billing_Currency__c != null)
                    currentBillingCurrencies.addAll(c.EF_Billing_Currency__c.split(';'));
                Set<String> currentPaymentCurrencies = new Set<String>();
                if(c.EF_Payment_Currency__c != null)
                    currentPaymentCurrencies.addAll(c.EF_Payment_Currency__c.split(';'));
                
                if(contractDataCurrenciesMap.get(c.Id) != null)
                {
                    for(String baDataCurrency : contractDataCurrenciesMap.get(c.Id))
                    {
                        if(!currentDataCurrencies.contains(baDataCurrency))
                        {
                            if(errorDataCurrencyListingMap.containsKey(c.Id))
                            {
                                errorDataCurrencyListingMap.get(c.Id).add(baDataCurrency);
                            }
                            else
                            {
                                List<String> errorList = new List<String>();
                                errorList.add(baDataCurrency);
                                errorDataCurrencyListingMap.put(c.Id, errorList);
                            }
                        }
                    }
                }

                if(contractBillingCurrenciesMap.get(c.Id) != null)
                {
                    for(String baBillingCurrency : contractBillingCurrenciesMap.get(c.Id))
                    {
                        if(!currentBillingCurrencies.contains(baBillingCurrency))
                        {
                            if(errorBillingCurrencyListingMap.containsKey(c.Id))
                            {
                                errorBillingCurrencyListingMap.get(c.Id).add(baBillingCurrency);
                            }
                            else
                            {
                                List<String> errorList = new List<String>();
                                errorList.add(baBillingCurrency);
                                errorBillingCurrencyListingMap.put(c.Id, errorList);
                            }
                        }
                    }
                }

                if(contractPaymentCurrenciesMap.get(c.Id) != null)
                {
                    for(String baPaymentCurrency : contractPaymentCurrenciesMap.get(c.Id))
                    {
                        if(!currentPaymentCurrencies.contains(baPaymentCurrency))
                        {
                            if(errorPaymentCurrencyListingMap.containsKey(c.Id))
                            {
                                errorPaymentCurrencyListingMap.get(c.Id).add(baPaymentCurrency);
                            }
                            else
                            {
                                List<String> errorList = new List<String>();
                                errorList.add(baPaymentCurrency);
                                errorPaymentCurrencyListingMap.put(c.Id, errorList);
                            }
                        }
                    }
                }
            }

            for(Contract c : newLines)
            {   
                if(errorDataCurrencyListingMap.get(c.Id) != null)
                {
                    c.EF_Data_Currency__c.addError('Can not update Data Currency list, because the following currencies are used in Billing Agreements: '+errorDataCurrencyListingMap.get(c.Id));
                }
                if(errorBillingCurrencyListingMap.get(c.Id) != null)
                {
                    // c.EF_Billing_Currency__c.addError('Can not update Billing Currency list, because the following currencies are used in Billing Agreements: '+errorBillingCurrencyListingMap.get(c.Id));
                }
                if(errorPaymentCurrencyListingMap.get(c.Id) != null)
                {
                    c.EF_Payment_Currency__c.addError('Can not update Payment Currency list, because the following currencies are used in Billing Agreements: '+errorPaymentCurrencyListingMap.get(c.Id));
                }
            }
        }
    }


     // Submits E&F Contracts for approval processing if the helper field is set to TRUE
    public static void startApprovalProcesses(List<Contract> cList)
    {
        for(Contract c : cList)
        {
            if(c.EF_Require_Approval__c)
            {
                EF_BaContractApprovalHelper.submitForApproval(c.Id, UserInfo.getUserId(), '');
            }
        }
    }

    // Identifies and handles both Approved, Rejected and Recalled approvals 
    public static void handleApprovedAndRejectedApprovals(List<Contract> newValues, Map<Id, Contract> oldValues)
    {
        // Find the Custom Setting values for "Approval Required" fields and...
        List<EF_Approve_Fields__c> fieldList = [select id, name, Contract_Fields__c from EF_Approve_Fields__c where Name = 'Contract'];
        List<String> fields = new List<String>();
        if(fieldList.size() > 0)
            fields = fieldList.get(0).Contract_Fields__c.split(',');
        else
            fields.add('Id');
        List<Contract> approvedList = EF_BaContractApprovalHelper.identifyApprovedRecords(newValues, oldValues);
        List<Contract> rejectedList = EF_BaContractApprovalHelper.identifyRejectedOrRecalledRecords(newValues, oldValues);
        if(approvedList.size() > 0)
        {
            // If approval occurred, copies the approved values from temporary storage onto the record itself
            EF_BaContractApprovalHelper.copyValuesFromTempStorageOnrecordApproval(approvedList, fields, 'Contract__c');
        }
        if(rejectedList.size() > 0)
        {
            // Or if rejected or recalled, simply ignore the changes and get rid of the temp storage record
            EF_BaContractApprovalHelper.removeTempStorageRecordOnRecordRejection(rejectedList, 'Contract__c');
        }
    }

    
    public static void handleWithApprovalAccountUpdates(Map<Id, Contract> newContracts, Map<Id, Contract> oldContracts)
    {
        // Find if the User belongs to CS Specialist group, because that is the only group requiring special attention
        if(isUserCsSpecialist())
        {
            // Create a list of EF Approval records that will be stored in the system to contain the UPDATED versions of Contract
            List<EF_Approval__c> approvalStorageList = new List<EF_Approval__c>();
            // Get the list of fields that require Approval from Custom Settings and place them in a List
            List<EF_Approve_Fields__c> fieldList = [select id, name, Contract_Fields__c from EF_Approve_Fields__c where Name = 'Contract'];
            List<String> fields = fieldList.get(0).Contract_Fields__c.split(',');

            // If there are any Contracts that require approval, start the process to temporarily store them into another object
            for(Contract c : newContracts.values())
            {
                if(EF_BaContractApprovalHelper.identifyRecordChanges(c, oldContracts.get(c.Id), fields, false))
                {
                    EF_Approval__c approval = EF_BaContractApprovalHelper.fillTemporaryApprovalStorage(new EF_Approval__c(), c, fields, 'Contract__c');
                    c.EF_Require_Approval__c = true;
                    approvalStorageList.add(approval);
                    EF_BaContractApprovalHelper.rollbackPreviousValues(c, oldContracts.get(c.Id), fields);
                }
            }

            if(approvalStorageList.size() > 0)
            {
                insert approvalStorageList;
            }
        }
    }

    // // If user is a CS Specialist, make the Contract inactive and require approval
    // public static void handleWithApprovalAccountInserts(List<Contract> contractList)
    // {
    //     if(isUserCsSpecialist())
    //     {
    //         // Get the list of fields that require Approval from Custom Settings and place them in a List
    //         List<EF_Approve_Fields__c> fieldList = [select id, name, Contract_Fields__c from EF_Approve_Fields__c where Name = 'Contract'];
    //         List<String> fields = fieldList.get(0).Contract_Fields__c.split(',');
    //
    //         for(Contract c : contractList)
    //         {
    //             c.EF_Require_Approval__c = true;
    //             c.EF_Status__c = 'Inactive';
    //             EF_BaContractApprovalHelper.identifyRecordChanges(c, null, fields, true);
    //         }
    //     }
    // }

    // Used to identify is the running user belongs to Client Services Specialists role inside E&F
    public static boolean isUserCsSpecialist()
    {
        Id userId = UserInfo.getUserId();
        List<User> currentUsers = [select id, EF_User_Role__c from User where Id = :userId];
        if(currentUsers.size() > 0)
        {
            User currentUser = currentUsers.get(0);
            if(currentUser.EF_User_Role__c != null)
            {
                if(currentUser.EF_User_Role__c.equalsIgnoreCase('Client Services Specialists'))
                    return true;
            }
        }
        return false;
    }

    //E&F Notification of fields identified as critical. List of fields set on custom setting.
    public static void manageCriticalFieldChanges(List<Contract> contracts, Map<Id,Contract> oldMap){
        List<EF_Critical_Field_Notification__c> fieldList = EF_Utilities.getCriticalFields();

        List  <String> criticalContractFieldList = new List <String> ();
        if(!fieldList.isEmpty()){
            for(EF_Critical_Field_Notification__c cfn: fieldList){
            criticalContractFieldList= cfn.Contract_Fields__c.split(',');                     
            }
            
            Map <Id,Contract> contractsNoti = new Map <Id,Contract>();
           
            Map<String, Schema.SobjectField> fields = contracts.getSObjectType().getDescribe().fields.getMap();

            //loop over accounts to check if any of them need to trigger a notification.
            for(Contract c: contracts){
                //check fields for Clients
                if(c.RecordTypeId==RecordTypeSingleton.getInstance().getRecordTypeId('Contract', 'EF_Client_Agreement')){
                    
                    for(String s: criticalContractFieldList){
                        SObjectField f = fields.get(s);                 
                            if(c.get(s)!=oldMap.get(c.Id).get(s)){                       
                                contractsNoti.put(c.Id, c);
                            }
                    }
                }
            }

            if(!contractsNoti.isEmpty()){
                notifyOnCriticalFields(contractsNoti, oldMap, criticalContractFieldList);
            
            }

        }
    }

    public static void notifyOnCriticalFields (Map <Id, Contract> newContracts, Map <Id,Contract> oldContractMap, List <String> criticalFieldList ) {

        Map<String, Schema.SobjectField> fields = newContracts.getSObjectType().getDescribe().fields.getMap();
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(Contract c: newContracts.values()){
            String emailBody = 'Dear team member, <br/><br/>the following Contract values been UPDATED:<br/><br/>';
            emailBody = emailBody + '<table width="600px" border="1"><tr border="1"><th border="1">Contract</th><th border="1">Field:</th><th border="1">New Value:</th><th border="1">Old Value:</th></tr>';
        
           for(String s: criticalFieldList){
                SObjectField f = fields.get(s);                 
                if(c.get(s)!=oldContractMap.get(c.Id).get(s)){
                    emailBody = emailBody + '<tr><td border="1"><a href="'+baseUrl+'/'+c.Id+'">'+c.Name+'</a></td><td border="1">'+s+'</td><td border="1">'+c.get(s)+'</td><td border="1">'+oldContractMap.get(c.Id).get(s)+'</td></tr>';
                }
           }
           emailBody = emailBody + '</table>';
           if(c.EF_DT_Specialist__c!=null && c.EF_IA_Specialist__c!=null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSaveAsActivity(false);
                mail.setToAddresses(new List <String> {c.EF_DT_Specialist_Email__c, c.EF_IA_Specialist_Email__c, 'efs@iata.org'}); 
                mail.setSubject('E&F Contract Critical Changes Notification');
                mail.setBccSender(false);
                mail.setUseSignature(false);       
                mail.setHtmlBody(emailBody);
                mails.add(mail);
                //Utility.sendEmail(new List <String> {c.EF_DT_Specialist_Email__c, c.EF_IA_Specialist_Email__c, 'efs@iata.org'}, 'E&F Contract Critical Changes Notification ', emailBody, true, null);
           }else if(c.EF_DT_Specialist__c==null && c.EF_IA_Specialist__c!=null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSaveAsActivity(false);
                mail.setToAddresses(new List <String> {c.EF_IA_Specialist_Email__c, 'efs@iata.org'}); 
                mail.setSubject('E&F Contract Critical Changes Notification');
                mail.setBccSender(false);
                mail.setUseSignature(false);       
                mail.setHtmlBody(emailBody);
                mails.add(mail);
                //Utility.sendEmail(new List <String> {c.EF_IA_Specialist_Email__c, 'efs@iata.org'}, 'E&F Contract Critical Changes Notification ', emailBody, true, null);
           }else if(c.EF_DT_Specialist__c!=null && c.EF_IA_Specialist__c==null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSaveAsActivity(false);
                mail.setToAddresses(new List <String> {c.EF_DT_Specialist_Email__c, 'efs@iata.org'}); 
                mail.setSubject('E&F Contract Critical Changes Notification');
                mail.setBccSender(false);
                mail.setUseSignature(false);       
                mail.setHtmlBody(emailBody);
                mails.add(mail);
                //Utility.sendEmail(new List <String> {c.EF_DT_Specialist_Email__c, 'efs@iata.org'}, 'E&F Contract Critical Changes Notification ', emailBody, true, null);
           }else{
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSaveAsActivity(false);
                mail.setToAddresses(new List <String> {'efs@iata.org'}); 
                mail.setSubject('E&F Contract Critical Changes Notification');
                mail.setBccSender(false);
                mail.setUseSignature(false);       
                mail.setHtmlBody(emailBody);
                mails.add(mail);
                //Utility.sendEmail(new List <String> {'efs@iata.org'}, 'E&F Contract Critical Changes Notification ', emailBody, true, null);
           }
           
        }
        
         if(!mails.isEmpty()){
                Messaging.sendEmail(mails);
        }  
              
    }

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
    
}