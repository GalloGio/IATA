global without sharing class AMS_RecordCreatorWebservice {

    private Static Map<string, Id> oscarRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_OSCAR__c'}).get('AMS_OSCAR__c');

    private static String NEWBR_PV = 'NEW.BR';
    private static String NEWHO_PV = 'NEW.HO.1.0';
    private static String BANK_ACCOUNT_CHANGES_PV = 'BANK.ACCOUNT.CHANGES';
    private static String MAJOR_CHANGES_PV = 'MAJOR.CHANGES';
    private static String DGR_DGA_PV = 'DGR.DGA';
    private static String NEWBRABRD_PV= 'NEW.BR.ABROAD';
    private static String NEWTIDS_PV= 'NEW.TIDS.1.0';
    private static String NEWCORRECTION_PV = 'CORRECTION.1.0';
    private static String NEWDGR_PV = 'CERTIFICATION.1.0';
    private static String NEWVR_PV = 'VR.1.0'; 
    private static String NEWVRCA_PV = 'VR.1.0.CA';

    private static String EMPTYACCREDITATIONID = 'EMPTY';

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

            if(typeOfProcess.equalsIgnoreCase(NEWBR_PV) || typeOfProcess.equalsIgnoreCase(NEWBRABRD_PV) || typeOfProcess.equalsIgnoreCase(NEWTIDS_PV) ){
                if(!createHierarchy(realAccountId, typeOfProcess)){
                    Database.rollback(sp);
                    throw new CalloutException('There was an error on hierarchy object creation (does the account have a parent ?) . Please check the logs or contact the System Administrator.');
                    //return 'There was an error on hierarchy object creation (does the account have a parent ?) . Please check the logs or contact the System Administrator.';
                }
            }

            

            if(!cases.isEmpty()){

                Case oscarCase = cases.get(0);
           
                oscarCase.OSCAR__c = oscarId;

                if(typeOfProcess.equalsIgnoreCase(NEWBR_PV) || typeOfProcess.equalsIgnoreCase(NEWBRABRD_PV) || typeOfProcess.equalsIgnoreCase(MAJOR_CHANGES_PV))
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

        if(!(typeOfProcess.equalsIgnoreCase(NEWBR_PV) || typeOfProcess.equalsIgnoreCase(NEWBRABRD_PV) || typeOfProcess.equalsIgnoreCase(MAJOR_CHANGES_PV)))
            return accountId;

        List<Case> cases = [SELECT Id, Account_Concerned__c from CASE where Id = :caseId LIMIT 1];

        if(!cases.isEmpty())
            return cases.get(0).Account_Concerned__c;

        return null;
    }

    private static boolean createHierarchy(String accountId, String typeOfProcess){

        Account account = new Account(Id = accountId);

        System.debug('Account to create hierarchy is ' + account.Id);

        List<Account> parentIdLst = [SELECT Id, ParentId, Location_Type__c from Account where Id = :account.Id LIMIT 1];

        if((!parentIdLst.isEmpty()) && typeOfProcess.equalsIgnoreCase(NEWTIDS_PV) && parentIdLst.get(0).Location_Type__c != 'BR'){
            System.debug('There is no Parent Id to create an Hierarchy but its a TIDS so lets assume its an HO.');
            return true;
        }

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

        if(typeOfProcess.equalsIgnoreCase(NEWBR_PV) || typeOfProcess.equalsIgnoreCase(NEWHO_PV) || typeOfProcess.equalsIgnoreCase(NEWBRABRD_PV) || typeOfProcess.equalsIgnoreCase(NEWTIDS_PV))
            return oscarRT.get('NEW');

        if(typeOfProcess.equalsIgnoreCase(BANK_ACCOUNT_CHANGES_PV) || typeOfProcess.equalsIgnoreCase(MAJOR_CHANGES_PV) || typeOfProcess.equalsIgnoreCase(DGR_DGA_PV))
            return oscarRT.get('CHANGE');

        if(typeOfProcess.equalsIgnoreCase(NEWCORRECTION_PV))
            return oscarRT.get('CORRECTION');

        if(typeOfProcess.equalsIgnoreCase(NEWDGR_PV))
            return oscarRT.get('CERTIFICATION');

        if(typeOfProcess.equalsIgnoreCase(NEWVR_PV) || typeOfProcess.equalsIgnoreCase(NEWVRCA_PV))
            return oscarRT.get('VOLUNTARY_RELINQUISHMENT');

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
            oscar = new AMS_OSCAR__c(Account__c = accountId, Process__c = processType, RecordTypeId =recordTypeId, Status__c = oscarStatus);
        else
            oscar = new AMS_OSCAR__c(Account__c = accountId, Process__c = processType, RecordTypeId =recordTypeId, Status__c = oscarStatus, OwnerId = owner );

        if(processType != NEWVR_PV && processType != NEWVRCA_PV){
            oscar.AMS_Online_Accreditation__c = accreditationId;
        }

        if(processType.equalsIgnoreCase(MAJOR_CHANGES_PV)){

            accreditationObj = fetchAccreditationObject(accreditationId);

            handleOwners(accreditationObj);

            String typeOfChange = getFormatedTypeOfChange(processType,accreditationObj);

            oscar.Type_of_change__c = typeOfChange;

        }
        
        insert oscar;

        if(processType.equalsIgnoreCase(MAJOR_CHANGES_PV) && processType != NEWVR_PV && processType != NEWVRCA_PV){
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

        //AMS_ChangeCodesHelper.createAAChangeCodes(changeCodesToProcess, oscarsToProcess, accountsToProcess, false);
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




    /*AMSFTS
    webservice static String createAgency(String countryName, String accountId, String recordType, String typeOfLocation, String companyType, String legalName, String tradingName, String licenseNumber, List<String> GDS, String language, String site, String numberVAT, Boolean atAirport, String cargoIATACode){
        AMS_Agency__c newAgency = null;

        //|| accountId == null || licenseNumber == null || tradingName == null 
        if(countryName == null || recordType == null || typeOfLocation == null || companyType == null || legalName == null || GDS == null || language == null || numberVAT == null)
            return 'Arguments cannot be null.';
        
        if(atAirport == null)
            atAirport = false;

        String locClass = '';

        if(recordType == 'Travel Agent - Branch' || recordType == 'Travel Agent - HO'){
            recordType = 'PASSENGER';
            locClass = 'P';
        }else if(recordType == 'Cargo Agent - Branch' || recordType == 'Cargo Agent - HO'){
            recordType = 'CARGO';
            locClass = 'C';
        }else{
            return 'Invalid record type of agency.';
        }

        List<IATA_ISO_Country__c> country = [select id from IATA_ISO_Country__c where ISO_Code__c =: countryName];
        if(country.size() == 0)
            return 'No Country was found.';

        if(companyType == 'Association')
            companyType = 'A';
        else if(companyType == 'Corporation')
            companyType = 'C';
        else if(companyType == 'State Owned Enterprise') //Government Owned Enterprise
            companyType = 'E';
        else if(companyType == 'Other' || companyType == 'Joint Venture' || companyType == 'Limited Company')
            companyType = 'O';
        else if(companyType == 'Partnership')
            companyType = 'P';
        else if(companyType == 'Limited Partnership')
            companyType = 'R';
        else if(companyType == 'Sole Proprietorship')
            companyType = 'S';
        else if(companyType == 'Trust Company')
            companyType = 'T';
        else if(companyType == 'Co-operative')
            companyType = 'V';
        else
            return 'Company Type does not exist.';

        Map<string, Id> agencyRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        String listOfGDS = String.join(GDS, ';');

        List<AMS_Agency__c> cargoAgency = [select id from AMS_Agency__c where IATACode__c =: cargoIATACode];
        String cargoAgencyId = cargoAgency.size()==0?null:cargoAgency.get(0).id;
        
        String theAccountID = null;
        List<Account> acc = new List<Account>();
        if(accountId != null){
        acc = [select id, Location_Type__c, Preferred_Language__c from Account where id =: accountId];
            if(acc.size() == 0)
                return 'No account was found.';
            else{
                theAccountID = acc.get(0).id;
                acc.get(0).Location_Type__c = typeOfLocation;
                acc.get(0).Preferred_Language__c = language;
            }
        }

        newAgency = new AMS_Agency__c(recordTypeId=agencyRT.get(recordType),
                                        Company_Type__c=companyType,
                                        Name=legalName,
                                        Legal_Name_1__c=legalName,
                                        Trading_Name_1__c=tradingName,
                                        License_Number__c=licenseNumber,
                                        GDS__c=listOfGDS,
                                        Agency_Site__c=site,
                                        Tax_Reference_Number__c=numberVAT,
                                        In_a_Airport__c=atAirport,
                                        Cargo_Agency__c=cargoAgencyId,
                                        Account__c=theAccountID,
                                        Country__c=country.get(0).id,
                                        Site_Type__c=typeOfLocation,
                                        Location_Class__c=locClass);

        try{
            insert newAgency;
            if(acc.size() == 0)
                update acc;
        }catch(Exception e){
            return 'DML exception: ' + e;
        }

        return newAgency.Id;
    }*/

    /*
        #AMSFTS This method helps to create an AMS_OSCAR__c object, based on its Account Id 
    
    webservice static String createLifecycleRequest(String agencyId){
        AMS_OSCAR__c newOscar = null;

        if(agencyId == null)
            return 'Arguments cannot be null.';

        List<Account> agency = [select id from Account where id = :agencyId];
        if(agency.size() == 0)
            return 'No agency was found.';

        Map<string, Id> oscarRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_OSCAR__c'}).get('AMS_OSCAR__c');

        //String queueid = [select Id from Group where Name = 'Accreditation - Lifecycle Request' and Type = 'Queue'].id;

        newOscar = new AMS_OSCAR__c(recordTypeId = oscarRT.get('NEW'),Account__c=agencyId,Status__c='Open');//, OwnerId=queueid

        try{
            insert newOscar;
        }catch(Exception e){
            return 'DML exception.';
        }
        
        return newOscar.id;
    }
    */

    /*AMSFTS
    webservice static String createEmployee(String agencyId, String fName, String lName, String phone, String fax, String email, String address, String mobile, String position, Date dateJoined, String contactId){
        AMS_Person__c newPerson = null;
        AMS_Employee__c newEmployee = null;
        AMS_Address__c newAddress = null;
        AMS_Agent_Locations_crossobject__c newRelation = null;
        List<Contact> theContact = null;

        if(agencyId == null || fName == null || lName == null)
            return 'Agency, First Name and Last Name cannot be null.';

        List<AMS_Agency__c> agency = [select id, Primary_address__r.Country__c from AMS_Agency__c where id = :agencyId];
        if(agency.size() == 0)
            return 'No Agency was found.';

        if(contactId == null){
            List<AMS_Person__c> person = [select id from AMS_Person__c where Lastname__c =:lName AND First_Name__c =:fName AND Phone__c =: phone AND Email__c =: email];
            if(person.size() == 0){
                newPerson = new AMS_Person__c(Name=fName + ' ' + lName,
                                                First_Name__c=fName,
                                                Lastname__c=lName,
                                                Email__c=email,
                                                Phone__c=phone);

                try{
                    insert newPerson;
                }catch(Exception e){
                    return 'DML exception: ' + e;
                }

                newAddress = new AMS_Address__c(Address_1__c=address,
                                                Email__c=email,
                                                Fax__c=fax,
                                                Mobile__c=mobile,
                                                Telephone__c=phone,
                                                Address_Type__c = 'Personal',
                                                Country__c=agency.get(0).Primary_address__r.Country__c);

                try{
                    insert newAddress;
                }catch(Exception e){
                    return 'DML exception: ' + e;
                }

                newRelation = new AMS_Agent_Locations_crossobject__c(Address__c=newAddress.id,Agent__c=newPerson.id);

                try{
                    insert newRelation;
                }catch(Exception e){
                    return 'DML exception: ' + e;
                }
            }else{
                newPerson = person.get(0);
            }

            List<AMS_Employee__c> existingEmployee = [select id from AMS_Employee__c where Agency__c = :agencyId AND Person__c =:newPerson.id];

            if(existingEmployee.size() > 0)
                return 'Employee already existing in this agency';


            newEmployee = new AMS_Employee__c(Name=fName + ' ' + lName,
                                              Agency__c=agencyId,
                                                Person__c=newPerson.id,
                                                Position__c=position,
                                                Registration_Date__c=dateJoined);

            try{
                insert newEmployee;
            }catch(Exception e){
                return 'DML exception: ' + e;
            }
            
            newEmployee = [select id, Contact__c from AMS_Employee__c where id =:newEmployee.id];
            theContact = [select id, MobilePhone, Phone, Fax from Contact where id =: newEmployee.Contact__c];
            theContact.get(0).Phone = phone;
            theContact.get(0).MobilePhone = mobile;
            theContact.get(0).Fax = fax;
            
            try{
                update theContact;
            }catch(Exception e){
                return 'DML exception: ' + e;
            }
        }else{//new requirement on the portal side; the records can be updated
            theContact = [select id, MobilePhone, Phone, Fax, Person__c from Contact where id =: contactId];
            if(theContact.size() == 0)
                return 'No Contact was found.';

            if(theContact.get(0).Person__c == null)
                return 'The contact does not have a Person associated.';

            theContact.get(0).Phone = phone;
            theContact.get(0).MobilePhone = mobile;
            theContact.get(0).Fax = fax;

            newPerson = [select id, Name, First_Name__c, Lastname__c, Email__c, Phone__c from AMS_Person__c where id =: theContact.get(0).Person__c];
            newPerson.Name=fName + ' ' + lName;
            newPerson.First_Name__c=fName;
            newPerson.Lastname__c=lName;
            newPerson.Email__c=email;
            newPerson.Phone__c=phone;

            newAddress = [select id,Address_1__c,Email__c,Fax__c,Mobile__c,Telephone__c from AMS_Address__c where id IN (select Address__c from AMS_Agent_Locations_crossobject__c where Agent__c =: theContact.get(0).Person__c)];
            newAddress.Address_1__c=address;
            newAddress.Email__c=email;
            newAddress.Fax__c=fax;
            newAddress.Mobile__c=mobile;
            newAddress.Telephone__c=phone;
            
            try{
                newEmployee = [select id, Name, Position__c, Registration_Date__c from AMS_Employee__c where Agency__c =:agencyId and Person__c=:theContact.get(0).Person__c];
            }catch(Exception e){
                return 'The agency as no employees with the provided contact.';
            }
            newEmployee.Name = fName + ' ' + lName;
            newEmployee.Position__c=position;
            newEmployee.Registration_Date__c=dateJoined;

            try{
                update theContact;
                update newPerson;
                update newAddress;
                update newEmployee;
            }catch(Exception e){
                return 'DML exception: ' + e;
            }
        }
        
        return theContact.get(0).id;
    }*/

    /*
        #AMSFTS This method helps to create an AMS_Address__c object, based on its Account Id (agencyId)
   
    webservice static String createAddress(String address, String phone, String fax, String email, String website, String countryName, String agencyId){
        AMS_Address__c newAddress = null;

        if(agencyId == null || address == null || countryName == null)
            return 'Agency, address and Country cannot be null.';

        List<Account> agency = [select id from Account where id = :agencyId];
        if(agency.size() == 0)
            return 'No Agency was found.';

        List<IATA_ISO_Country__c> country = [select id from IATA_ISO_Country__c where ISO_Code__c =: countryName];
        if(country.size() == 0)
            return 'No Country was found.';

        newAddress = new AMS_Address__c(Address_1__c=address,
                                        Account__c=agencyId,
                                        Country__c=country.get(0).id,
                                        Telephone__c=phone,
                                        Fax__c=fax,
                                        Email__c=email,
                                        Website__c=website);

        try{
            insert newAddress;
        }catch(Exception e){
            return 'DML exception.';
        }

        return newAddress.id;
    }
 **/
    /*
        #AMSFTS This method helps to create an Account Owner 
    
    webservice static String createOwnerCompany(String legalName, String iataCode, String agencyId, Decimal finInterest, String ownershipId){
        AMS_Owner__c newOwner = null;
        AMS_Agency_Ownership__c newOwnership = null;
        List<AMS_Agency_Ownership__c> theOwnership = null;
        List<Account> account = new List<Account>();
        Account acc = null;

        if(legalName == null || agencyId == null) // || iataCode == null
            return 'Account Name and Agency cannot be null.'; 

        List<Account> agency = [select id from Account where id = :agencyId];
        if(agency.size() == 0)
            return 'No Agency was found.';
        
        if(ownershipId == null){
            
            if(iataCode != null){
                account = [select id, Name from Account where Name = :legalName AND IATACode__c = :iataCode];
            }
            
            if(account.size() == 0){
                acc = new Account(Name = legalName, IATACode__c = iataCode);
                try{
                    insert acc;
                }catch(Exception e){
                    return 'DML Exception.';
                }
            }else
                acc = account.get(0);

            List<AMS_Owner__c> owner = [select id from AMS_Owner__c where Name =: acc.Name and Account__c =: acc.Id];
            if(owner.size() == 0){
                newOwner = new AMS_Owner__c(Name=acc.Name,Account__c=acc.Id);
                try{
                    insert newOwner;
                }catch(Exception e){
                    return 'DML exception.';
                }
            }else{
                newOwner = owner.get(0);
            }

            newOwnership = new AMS_Agency_Ownership__c(Agency__c=agencyId,Percentage__c=finInterest,AMS_Agency_Owner__c=newOwner.id);

            try{
                insert newOwnership;
            }catch(Exception e){
                return 'DML exception.';
            }
        }else{
            theOwnership = [select id,Percentage__c,AMS_Agency_Owner__c,Agency__c from AMS_Agency_Ownership__c where id =:ownershipId];

            if(theOwnership.size() == 0)
                return 'No Ownership was found.';

            newOwnership = theOwnership.get(0);
            newOwnership.Percentage__c=finInterest;
            newOwnership.Agency__c=agencyId;
            //TODO update the rest of the related records
            if(iataCode != null){
                account = [select id, Name from Account where Name = :legalName AND IATACode__c = :iataCode];
            }
            
            if(account.size() == 0){
                acc = new Account(Name = legalName, IATACode__c = iataCode);
                try{
                    insert acc;
                }catch(Exception e){
                    return 'DML Exception.';
                }
            }else
                acc = account.get(0);

            List<AMS_Owner__c> owner = [select id,Name,Account__c from AMS_Owner__c where id =: newOwnership.AMS_Agency_Owner__c];
            newOwner = owner.get(0);
            newOwner.Account__c=acc.id;
            newOwner.Name=legalName;

            try{
                update newOwnership;
                update newOwner;
            }catch(Exception e){
                return 'DML exception: ' + e;
            }
        }

        return newOwnership.id;
    }
**/

/* #AMSFTS 
    webservice static String createOwnerPerson(String agencyId, String fName, String lName, String phone, String fax, String email, String address, String mobile, String position, Date dateJoined, Decimal finInterest, String ownershipId){
        AMS_Person__c newPerson = null;
        AMS_Address__c newAddress = null;
        AMS_Agent_Locations_crossobject__c newRelation = null;
        AMS_Owner__c newOwner = null;
        AMS_Agency_Ownership__c newOwnership = null;
        List<AMS_Agency_Ownership__c> theOwnership = null;

        if(agencyId == null || fName == null || lName == null)
            return 'Agency, First Name and Last Name cannot be null.';

        List<AMS_Agency__c> agency = [select id from AMS_Agency__c where id = :agencyId];
        if(agency.size() == 0)
            return 'No Agency was found.';

        if(ownershipId == null){
            List<AMS_Person__c> person = [select id from AMS_Person__c where Lastname__c =:lName AND First_Name__c =:fName AND Phone__c =: phone AND Email__c =: email];
            if(person.size() == 0){
                newPerson = new AMS_Person__c(Name=fName + ' ' + lName,
                                                Lastname__c=lName,
                                                First_Name__c=fName,
                                                Email__c=email,
                                                Phone__c=phone);

                try{
                    insert newPerson;
                }catch(Exception e){
                    return 'DML exception.';
                }

                newAddress = new AMS_Address__c(Address_1__c=address,
                                                Email__c=email,
                                                Fax__c=fax,
                                                Mobile__c=mobile,
                                                Telephone__c=phone,
                                                Address_Type__c = 'Personal');

                try{
                    insert newAddress;
                }catch(Exception e){
                    return 'DML exception.';
                }

                newRelation = new AMS_Agent_Locations_crossobject__c(Address__c=newAddress.id,Agent__c=newPerson.id);

                try{
                    insert newRelation;
                }catch(Exception e){
                    return 'DML exception.';
                }
            }else{
                newPerson = person.get(0);
            }

            newOwner = new AMS_Owner__c(Name=lName,Person__c=newPerson.id);

            try{
                insert newOwner;
            }catch(Exception e){
                return 'DML exception.';
            }

            newOwnership = new AMS_Agency_Ownership__c(Agency__c=agencyId,Percentage__c=finInterest,AMS_Agency_Owner__c=newOwner.id);

            try{
                insert newOwnership;
            }catch(Exception e){
                return 'DML exception.';
            }
        }else{
            theOwnership = [select id,Percentage__c,AMS_Agency_Owner__c from AMS_Agency_Ownership__c where id =:ownershipId];

            if(theOwnership.size() == 0)
                return 'No Ownership was found.';

            newOwnership = theOwnership.get(0);
            newOwnership.Percentage__c=finInterest;

            newOwner = [select id, Name, Person__c from AMS_Owner__c where id =: newOwnership.AMS_Agency_Owner__c];
            newOwner.Name=lName;

            newPerson = [select id,Name, First_Name__c,Email__c,Phone__c,Lastname__c from AMS_Person__c where id =: newOwner.Person__c];
            newPerson.Name = fName + ' ' + lName;
            newPerson.First_Name__c=fName;
            newPerson.Lastname__c=lName;
            newPerson.Email__c=email;
            newPerson.Phone__c=phone;

            newAddress = [select id,Address_1__c,Email__c,Fax__c,Mobile__c,Telephone__c from AMS_Address__c where id IN (select Address__c from AMS_Agent_Locations_crossobject__c where Agent__c =: newPerson.id)];
            newAddress.Address_1__c=address;
            newAddress.Email__c=email;
            newAddress.Fax__c=fax;
            newAddress.Mobile__c=mobile;
            newAddress.Telephone__c=phone;

            try{
                update newOwnership;
                update newPerson;
                update newAddress;
                update newOwner;
            }catch(Exception e){
                return 'DML exception: ' + e;
            }
        }

        return newOwnership.id;
    }

    */

    /*webservice static Boolean attachDocToLifecycle(String attachId, String requestId){
        List<Attachment> attachmentsToInsert = new List<Attachment>();
        List<Attachment> attachmentsToDelete = new List<Attachment>();
        Attachment tempAtt;
        Boolean result = false;
        if(attachId == null || requestId == null)
            return result;

        List<Attachment> attachment = [Select SystemModstamp, ParentId, OwnerId, Name, LastModifiedDate, LastModifiedById, 
                                        IsPrivate, IsDeleted, Id, Description, CreatedDate, CreatedById, ContentType, 
                                        BodyLength, Body From Attachment where Id=:attachId];
        if(attachment.size() == 0)
            return result;

        List<AMS_SALM__c> request = [select id from AMS_SALM__c where id =: requestId];
        if(request.size() == 0)
            return result;

        tempAtt=attachment.get(0).clone(false,false);
        tempAtt.ParentId = requestId;
        attachmentstoInsert.add(tempAtt);
        attachmentsToDelete.add(attachment.get(0));

        try{
            insert attachmentstoInsert;
            delete attachmentsToDelete;
        }catch(Exception e){
            return result;
        }

        result = true;
        return result;
    }*/
}