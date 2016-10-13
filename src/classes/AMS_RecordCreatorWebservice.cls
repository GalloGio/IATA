global without sharing class AMS_RecordCreatorWebservice {

    private Static Map<string, Id> oscarRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_OSCAR__c'}).get('AMS_OSCAR__c');

    private static String NEWBR_PV = 'NEW.BR';
    private static String NEWHO_PV = 'NEW.HO.1.0';
    private static String BANK_ACCOUNT_CHANGES_PV = 'BANK.ACCOUNT.CHANGES';
    private static String MAJOR_CHANGES_PV = 'MAJOR.CHANGES';
    private static String DGR_DGA_PV = 'DGR.DGA';
    private static String NEWBRABRD_PV= 'NEW.BR.ABROAD';
    private static String NEWSA_PV = 'NEW.SA.1.0'; 
    private static String VMFR_PV = 'VMFR Setup/Update';


    /**
        Creates an Oscar (AMS_OSCAR__c) given an Account Id, an Accreditation Id and the Type of Process
    **/
    webservice static String createAccreditation(String accountId, String accreditationId, String typeOfProcess, String caseId){

        // Create a savepoint
        Savepoint sp = Database.setSavepoint();
        String oscarId = null;

        try{
            
            List<String> fieldsToValidate = new List<String>();

            fieldsToValidate.add(accountId);
            fieldsToValidate.add(accreditationId);
            fieldsToValidate.add(typeOfProcess);

            if(isSomethingEmpyOrNull(fieldsToValidate))
                throw new CalloutException('Arguments cannot be null.');

            String oscarRecordType = fetchOscarRecordType(typeOfProcess);

            if(String.isBlank(oscarRecordType))
                throw new CalloutException('Could not find any record type matching the type of process ' + typeOfProcess + '.Please check the logs or contact the System Administrator.');
                //return 'Could not find any record type matching the type of process ' + typeOfProcess + '.Please check the logs or contact the System Administrator.';

            String realAccountId = fetchRealAccountId(typeOfProcess,accountId,caseId);

            if(realAccountId == null){
                //throw new CalloutException('For new BR Accounts, the communication case must have a concern account filled.');
                realAccountId = accountId;
            }

            List<Case> cases = [SELECT Id, Account_Concerned__c, AccountId, Account.Location_Type__c, Account.Category__c, OSCAR__c, OwnerId from CASE where Id = :caseId LIMIT 1];

            Id ownerId = null;

            if(!cases.isEmpty()){
                ownerId = cases.get(0).OwnerId;
            }

            oscarId = createOscar(realAccountId,  typeOfProcess, oscarRecordType ,  'Open',  accreditationId, ownerId);

            if(String.isBlank(oscarId))
                throw new CalloutException('There was an error on OSCAR object creation. Please check the logs or contact the System Administrator.');
                //return 'There was an error on OSCAR object creation. Please check the logs or contact the System Administrator.';



            if(typeOfProcess.equalsIgnoreCase(NEWBR_PV) || typeOfProcess.equalsIgnoreCase(NEWBRABRD_PV) || typeOfProcess.equalsIgnoreCase(NEWSA_PV)){
                if(!createHierarchy(realAccountId)){
                    Database.rollback(sp);
                    throw new CalloutException('There was an error on hierarchy object creation (does the account have a parent ?) . Please check the logs or contact the System Administrator.');
                    //return 'There was an error on hierarchy object creation (does the account have a parent ?) . Please check the logs or contact the System Administrator.';
                }
            }

            

            if(!cases.isEmpty()){

                Case oscarCase = cases.get(0);
           
                oscarCase.OSCAR__c = oscarId;

                if(typeOfProcess.equalsIgnoreCase(NEWBR_PV) || typeOfProcess.equalsIgnoreCase(NEWBRABRD_PV) || typeOfProcess.equalsIgnoreCase(MAJOR_CHANGES_PV) || typeOfProcess.equalsIgnoreCase(NEWSA_PV) || typeOfProcess.equalsIgnoreCase(VMFR_PV))
                    if(oscarCase.AccountId != realAccountId)
                        oscarCase.AccountId = realAccountId;

                String typeOfCustomer = AMS_Utils.fetchTypeOfCustomer(oscarCase.Account.Location_Type__c,oscarCase.Account.Category__c);

                if(typeOfCustomer != null)
                    oscarCase.Type_of_Customer__c = typeOfCustomer;

                update oscarCase;
             }

        }
        catch(Exception e){
            System.debug('DML exception: ' + e);
            Database.rollback(sp);
            throw e;
            //return 'There was an error on OSCAR object creation. Please check the logs or contact the System Administrator.';
        }

        return oscarId;

        // Rollback to the previous null value


    }

    private static String fetchRealAccountId(String typeOfProcess,String accountId,String caseId){

        if(!(typeOfProcess.equalsIgnoreCase(NEWBR_PV) || typeOfProcess.equalsIgnoreCase(NEWBRABRD_PV) || typeOfProcess.equalsIgnoreCase(MAJOR_CHANGES_PV) || typeOfProcess.equalsIgnoreCase(NEWSA_PV) || typeOfProcess.equalsIgnoreCase(VMFR_PV)))
            return accountId;

        List<Case> cases = [SELECT Id, Account_Concerned__c from CASE where Id = :caseId LIMIT 1];

        if(!cases.isEmpty())
            return cases.get(0).Account_Concerned__c;

        return null;
    }

    private static boolean createHierarchy(String accountId){

        Account account = new Account(Id = accountId);

        System.debug('Account to create hierarchy is ' + account.Id);

        List<Account> parentIdLst = [SELECT Id, ParentId from Account where Id = :account.Id LIMIT 1];

        if(parentIdLst.isEmpty()){
            System.debug('There is no Parent Id to create an Hierarchy.');
            return false;
        }

        System.debug('Parent account to create hierarchy is ' + parentIdLst.get(0).ParentId);

        Id parentId = parentIdLst.get(0).ParentId;

        Account parentAccount = new Account(Id = ParentId);

        List<AMS_Agencies_relationhip__c> existingRelations = [SELECT Id, Hierarchy__c from AMS_Agencies_relationhip__c where Parent_Account__c =:parentAccount.Id LIMIT 1];

        AMS_Agencies_Hierarchy__c hierarchy = null;

        if(existingRelations.isEmpty()){ // create a new hierarchy

            System.debug('Did not find any hierarchy, creating new one.');

            hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy');
            
            insert hierarchy;

        }else{
            System.debug('Already has an hierarchy with id:' + existingRelations.get(0).Id );

            hierarchy = new AMS_Agencies_Hierarchy__c(Id = existingRelations.get(0).Hierarchy__c); 
        }

        System.debug('Creating relationship with parent ' + parentAccount.Id + ' and child ' + account.Id);

        AMS_Agencies_relationhip__c relationship = new AMS_Agencies_relationhip__c(Child_Account__c = account.Id, Parent_Account__c = parentAccount.Id, Hierarchy__c = hierarchy.Id);

        insert relationship;

        return true;

    }  

    private static String fetchOscarRecordType(String typeOfProcess){

        if(typeOfProcess.equalsIgnoreCase(NEWBR_PV) || typeOfProcess.equalsIgnoreCase(NEWHO_PV) || typeOfProcess.equalsIgnoreCase(NEWBRABRD_PV) || typeOfProcess.equalsIgnoreCase(NEWSA_PV))
            return oscarRT.get('NEW');

        if(typeOfProcess.equalsIgnoreCase(BANK_ACCOUNT_CHANGES_PV) || typeOfProcess.equalsIgnoreCase(MAJOR_CHANGES_PV) || typeOfProcess.equalsIgnoreCase(DGR_DGA_PV) || typeOfProcess.equalsIgnoreCase(VMFR_PV))
            return oscarRT.get('CHANGE');

        return null;
    
    }

    private static boolean isSomethingEmpyOrNull(List<String> fieldsToValidate){

        if(fieldsToValidate.isEmpty())
            return false;



        for(String elem: fieldsToValidate){
            if(String.isBlank(elem) || String.isEmpty(elem))
                return true;
        }

        return false;

    } 

    private Static String createOscar(String accountId, String processType, String recordTypeId, String oscarStatus, String accreditationId, Id owner){

        AMS_OSCAR__c oscar;
        AMS_Pax_Accreditation_Form__c accreditationObj;
 
        if(owner == null)
            oscar = new AMS_OSCAR__c(Account__c = accountId, Process__c = processType, RecordTypeId =recordTypeId, Status__c = oscarStatus, AMS_Online_Accreditation__c = accreditationId );
        else
            oscar = new AMS_OSCAR__c(Account__c = accountId, Process__c = processType, RecordTypeId =recordTypeId, Status__c = oscarStatus, AMS_Online_Accreditation__c = accreditationId, OwnerId = owner );

        if(processType.equalsIgnoreCase(MAJOR_CHANGES_PV) || processType.equalsIgnoreCase(VMFR_PV)){

            accreditationObj = fetchAccreditationObject(accreditationId);

            handleOwners(accreditationObj);

            String typeOfChange = getFormatedTypeOfChange(processType,accreditationObj);

            oscar.Type_of_change__c = typeOfChange;

        }
        
        insert oscar;

        if(processType.equalsIgnoreCase(MAJOR_CHANGES_PV)){
            processOscarProcessDetail(oscar,accreditationObj,accountId);
        }

        return oscar.id;
    }

    private static void handleOwners(AMS_Pax_Accreditation_Form__c accreditationObj){

        // The accreditation Contacts have two types : previous and current.
        // The business rule is the following:
        // if the accreditation form doesn't have current contact, just clone the previous contacts into current contacts.
        // if the accreditation form has current contacts, don't clone nothing.

        Map<String,String> previousContactTypes = new Map<String,String>();


        previousContactTypes.put('Previous_Company_Owner','Current Company Owner');
        previousContactTypes.put('Previous_Owner','Current Owner');
      
        List<AMS_Accreditation_Contact__c> idsToClone = new List<AMS_Accreditation_Contact__c>();

        List<AMS_Accreditation_Contact__c> accContacts = [SELECT Id, RecordType.DeveloperName, Last_name__c, AMS_Pax_Accreditation_Form__c from AMS_Accreditation_Contact__c where AMS_Pax_Accreditation_Form__c = :accreditationObj.Id];

        for(AMS_Accreditation_Contact__c con: accContacts){
            if(previousContactTypes.get(con.RecordType.DeveloperName) != null){
                idsToClone.add(con);
            }
        }

        if(!accContacts.isEmpty() && accContacts.size() == idsToClone.size()){
            cloneContacts(idsToClone,previousContactTypes);
        }


    }

    private static void cloneContacts(List<AMS_Accreditation_Contact__c> contacts, Map<String,String> previousContactTypes){

       // public sObject clone(Boolean preserveId, Boolean isDeepClone, Boolean preserveReadonlyTimestamps, Boolean preserveAutonumber)
        List<AMS_Accreditation_Contact__c> toInsert = new List<AMS_Accreditation_Contact__c>();

        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName();

       for(AMS_Accreditation_Contact__c contact: contacts){

            AMS_Accreditation_Contact__c contactCloned = contact.clone(false,false,false,false);

            String newRecordTypeDevName = previousContactTypes.get(contact.RecordType.DeveloperName);

            ID newRecordType = rtMapByName.get(newRecordTypeDevName).getRecordTypeId();

            contactCloned.recordTypeId = newRecordType;

            toInsert.add(contactCloned);

       }
       
       if(!toInsert.isEmpty())
        insert toInsert;
    
    }

    private static AMS_Pax_Accreditation_Form__c fetchAccreditationObject(String accreditationId){

        return [select Id, Notify_Change_Legal_Details__c, Notify_Change_Location__c, Notify_Change_Ownership__c, Scope_of_Change__c, Agency_Codes_Concerned__c, Effective_Date_Of_Change__c from AMS_Pax_Accreditation_Form__c where Id = :accreditationId LIMIT 1];

    }

    private static void processOscarProcessDetail(AMS_OSCAR__c oscar, AMS_Pax_Accreditation_Form__c accreditationObj, String accountFromOscar){

        if(accreditationObj.Scope_of_Change__c == null || accreditationObj.Scope_of_Change__c == 'HO Only')
            return;

        if(accreditationObj.Scope_of_Change__c == 'HO - All Branches'){
            AMS_HierarchyHelper.createProcessDetailForFullHierarchy(oscar.Id, oscar.Account__c);
            return ;
        }

        if(accreditationObj.Scope_of_Change__c == 'HO - Selected Branches' || accreditationObj.Scope_of_Change__c == 'Selected Branches Only'){
            
            List<String> iataCodes = accreditationObj.Agency_Codes_Concerned__c.split(',');

            List<Account> accountsToCreate = [SELECT Id from Account where IATACode__c in :iataCodes];

            List<AMS_Process_Detail__c> detailsToInsert = new List<AMS_Process_Detail__c>();

            ID rtAgencyInvolved = Schema.SObjectType.AMS_Process_Detail__c.getRecordTypeInfosByName().get('Agency Involved').getRecordTypeId();

            for(Account acct: accountsToCreate){

                if(acct.Id <> accountFromOscar){

                    System.debug('Oscar Account Id is ' + oscar.Account__r.Id + ' and account Id is ' + acct.Id);
                    
                    AMS_Process_Detail__c  detail = new AMS_Process_Detail__c(Account__c = acct.Id , OSCAR__c = oscar.Id, RecordTypeId = rtAgencyInvolved);

                    detailsToInsert.add(detail);
                }
            }

            if(!detailsToInsert.isEmpty())
                insert detailsToInsert;
        }


        return;

    }

    private static String getFormatedTypeOfChange(String processType, AMS_Pax_Accreditation_Form__c accreditationObj){

        String typeOfChange = '';

        if(accreditationObj.Notify_Change_Legal_Details__c)
            typeOfChange += 'Name;';
        if(accreditationObj.Notify_Change_Location__c)
            typeOfChange += 'Location;';
        if(accreditationObj.Notify_Change_Ownership__c)
            typeOfChange += 'Ownership to non-IATA Agent;';

        if(typeOfChange != '')
            typeOfChange = typeOfChange.removeEnd(';');
        else
            return null;
            
        return typeOfChange;

    }

    public static boolean containsTradeName(List<AMS_RecordCreatorWebservice.AccountChanges> accountChanges){
        for(AMS_RecordCreatorWebservice.AccountChanges achange: accountChanges){
            if(achange.accountFieldAPI.equalsIgnoreCase('TradeName__c'))
                return true;
        }
        return false;
    }

    /**
        Creates an Change Code object, based on a pre-defined message, and alerts the Owner of the Account
    **/
    webservice static void createMinorChangesChangeCode(String accountId, List<AMS_RecordCreatorWebservice.AccountChanges> accountChanges){

        // get the Account and creates a change code (Agency_Applied_Change_code__c)
        // Notify the Agent via email using predefined email template
        
        Boolean processedTN = false;

        List<Account> accountsToProcess = new List<Account>();
        List<AMS_OSCAR_JSON.ChangeCode> changeCodesToProcess = new List<AMS_OSCAR_JSON.ChangeCode>();
        List<AMS_OSCAR__c> oscarsToProcess = new List<AMS_OSCAR__c>();

        AMS_OSCAR_JSON.ChangeCode changeCodeTN = null;
        AMS_OSCAR_JSON.ChangeCode changeCode = null;

        if(accountId == null)
            throw new CalloutException('Account Id must be filled.');

        Account account = new Account(Id = accountId);

        if(account == null)
            throw new CalloutException('Account could not be found.');

        if(containsTradeName(accountChanges)){
                  
            changeCodeTN = generateChangeCodeTN(accountChanges, account.Status__c == 'Approved');

            accountsToProcess.add(account);
            changeCodesToProcess.add(changeCodeTN);
            oscarsToProcess.add(null);

            processedTN = true;
        }

        if(accountChanges.size() > 1 ||  ( accountChanges.size() == 1 && !processedTN)){

            changeCode = generateChangeCode(accountChanges);
            
            accountsToProcess.add(account);
            changeCodesToProcess.add(changeCode);
            oscarsToProcess.add(null);
        }

        AMS_Utils.createAAChangeCodes(changeCodesToProcess, oscarsToProcess, accountsToProcess, false);

        // for now we shouldn't sent any notification.
        //sendNotification(accountId,accountChanges);

    }

    public static void testsendNotification(String accountId,List<AMS_RecordCreatorWebservice.AccountChanges> accountChanges ){
        sendNotification(accountId, accountChanges );
    }

    private static void sendNotification(String accountId,List<AMS_RecordCreatorWebservice.AccountChanges> accountChanges ){

        String name = '';
        String userEmail = '';
        String alias = '';

        Account acct = [SELECT Id, OwnerId, Name from Account where Id = :accountId];

        if(acct == null)
            throw new CalloutException('Account could not be found.');

        List<User> usrLst = [select Id, Alias, FirstName, LastName, Email from USER where Id = :acct.OwnerId];

        if(!usrLst.isEmpty()){
            name = usrLst.get(0).FirstName + ' ' + usrLst.get(0).LastName;
            userEmail = usrLst.get(0).Email;
        }
       
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        EmailTemplate et = [Select Id, Subject, Body, HtmlValue from EmailTemplate where Name = 'AMS Minor Changes Notification'];
        String subject = et.Subject;
        String plainBody = et.Body;
        String htmlBody = et.HtmlValue;

        String memoText = createMemoText(accountChanges);

        String accountURL = System.URL.getSalesforceBaseURL().toExternalForm() + '/' + acct.Id;
        
        plainBody = plainBody.replace('#USERFULLNAME',name);
        plainBody = plainBody.replace('#ACCOUNTNAME',acct.Name);
        plainBody = plainBody.replace('#ACCOUNTCHANGES', memoText);

        memoText = memoText.replaceAll('\r\n', '<br>');

        htmlBody = htmlBody.replace('#USERFULLNAME',name);
        htmlBody = htmlBody.replace('#ACCOUNTNAME',acct.Name);
        htmlBody = htmlBody.replace('#ACCOUNTCHANGES', memoText);
        htmlBody = htmlBody.replace('#HTMLPAGE', accountURL);

        mail.setHtmlBody(htmlBody);
        mail.setPlainTextBody(plainBody);
        mail.subject = ' IATA - AMS Minor Changes Notification';
        
        // set users
        List<String> emails = new List<String>{userEmail};
        mail.setToAddresses(emails);

        List<String> emailsCC = new List<String>{'goncalvesd@iata.org'};
        mail.setCcAddresses(emailsCC);

        // Sends the email
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    public static AMS_OSCAR_JSON.ChangeCode generateChangeCode(List<AMS_RecordCreatorWebservice.AccountChanges> accountChanges){

        AMS_OSCAR_JSON.ChangeCode toReturn = new AMS_OSCAR_JSON.ChangeCode();

        toReturn.name = 'CAD';
        toReturn.reasonCode = 'Change data';
        toReturn.memoText = 'Minor Changes';//createMemoText(accountChanges);
        toReturn.reasonDesc  = 'Accredited-Meets Criteria.';
        toReturn.status  = null;

        return toReturn;
    }

    public static AMS_OSCAR_JSON.ChangeCode generateChangeCodeTN(List<AMS_RecordCreatorWebservice.AccountChanges> accountChanges,Boolean isToChangeStatus){

        AMS_OSCAR_JSON.ChangeCode toReturn = new AMS_OSCAR_JSON.ChangeCode();

        toReturn.name = 'CTA';
        toReturn.reasonCode = 'Change data';
        toReturn.memoText = 'Change of trade name';//createMemoText(accountChanges);
        toReturn.reasonDesc  = 'Accredited-Meets Criteria.';
        
        if(isToChangeStatus)
            toReturn.status  = '8'; // Accredited

        return toReturn;
    }

    private static String createMemoText(List<AMS_RecordCreatorWebservice.AccountChanges> accountChanges){

        String type='Account';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        String bulletinInformation = 'Changes requested via Portal with the following values: \r\n\r\n';

        for(AMS_RecordCreatorWebservice.AccountChanges change: accountChanges){

            String label = fieldMap.get(change.accountFieldAPI).getDescribe().getLabel();

            bulletinInformation += 'Field:'+label+' || Old Value:'+change.oldValue+ ' || New Value:' +change.newValue + '\r\n\r\n';

        }

        return bulletinInformation;
    }


    global class AccountChanges {

        webservice String accountFieldAPI{get;set;}
        webservice String oldValue{get;set;}
        webservice String newValue{get;set;}

        public AccountChanges(String accountFieldAPI, String oldValue, String newValue){

            this.accountFieldAPI = accountFieldAPI;
            this.oldValue = oldValue;
            this.newValue = newValue;
        }

    }


}