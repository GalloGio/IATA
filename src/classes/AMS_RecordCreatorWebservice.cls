global without sharing class AMS_RecordCreatorWebservice {

	//Types of processes
    private static String NEWBR_PV = 'NEW.BR';
    private static String NEWHO_PV = 'NEW.HO.1.0';
    private static String BANK_ACCOUNT_CHANGES_PV = 'BANK.ACCOUNT.CHANGES';
    private static String MAJOR_CHANGES_PV = 'MAJOR.CHANGES';
    private static String DGR_DGA_PV = 'DGR.DGA';
    private static String NEWBRABRD_PV= 'NEW.BR.ABROAD';
    private static String NEWTIDS_PV= 'NEW.TIDS.1.0';
    private static String NEWCORRECTION_PV = 'CORRECTION.1.0';
    private static String NEWDGR_PV = 'CERTIFICATION.1.0';
    public static String NEWVR_PV = 'VR.1.0';
    public static String NEWVRCA_PV = 'VR.1.0.CA';
    public static String NEWCER_PV = 'CER.1.0';
    public static String NEWGSA_PV = 'NEW.GSA.1.0';
    public static String NEWAHA_PV = 'NEW.AHA.1.0';
    public static String NEWMSO_PV = 'NEW.MSO.1.0';
    public static String NEWSA_PV = 'NEW.SA.1.0';
    public static String NEWNGLITE = 'ANG.NEW.HE.LITE.1.0';
    public static String NEWNSTANDARD = 'ANG.NEW.HE.STANDARD.1.0';
    public static String NEWNAE = 'ANG.NEW.AE.1.0';
    public static String MCAE = 'ANG.MULTICOUNTRY.AE.1.0';
    public static String MAJOR_CHANGESNEWGEN_PV = 'ANG.MAJOR.CHANGES.1.0';
    public static String NGFOP_PV = 'ANG.FOPMANAGEMENT.1.0';
    public static String IEP_BANK_ACCOUNT_SETUP = 'IEP.BANK.ACCOUNT.SETUP';
    public static String IEP_MODEL_A_ACCOUNT_SETUP = 'IEP.MODEL.A.ACCOUNT.SETUP';
    public static String IEP_MODEL_B_ACCOUNT_SETUP = 'IEP.MODEL.B.ACCOUNT.SETUP';
    public static string OPTINOPTOUT = 'ANG.FS.OPTINOUT';
    public static String PCI_COMPLIANT = 'PCI.COMPLIANT.1.0';
    private static String NEWNGLOBAL = 'ANG.NEW.GE.STANDARD.1.0';


    public static Set<String> accountConcernedProcesses = new Set <String>{NEWBR_PV, NEWBRABRD_PV, MAJOR_CHANGES_PV, NEWSA_PV, NEWNAE, MCAE, MAJOR_CHANGESNEWGEN_PV,IEP_BANK_ACCOUNT_SETUP,IEP_MODEL_A_ACCOUNT_SETUP, IEP_MODEL_B_ACCOUNT_SETUP, NEWVR_PV};

    public static String EMPTYACCREDITATIONID = 'EMPTY';

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

            List<Case> cases = [SELECT Id, Account_Concerned__c, AccountId, Account.Location_Type__c, Account.Category__c, OSCAR__c, OwnerId, Origin from CASE where Id = :caseId LIMIT 1];

            Id ownerId = null;

            if(!cases.isEmpty() && !Test.isRunningTest()){
                ownerId = cases.get(0).OwnerId;
            }


            if(typeOfProcess.equalsIgnoreCase(NEWCER_PV) && cases.get(0).Origin == 'Portal'){

                String selectedAccount = cases.get(0).Account_Concerned__c;
                oscarId = createOscar(selectedAccount,  typeOfProcess, oscarRecordType ,  'Open',  accreditationId, ownerId, caseId,accountId );

            } else {

                oscarId = createOscar(realAccountId,  typeOfProcess, oscarRecordType ,  'Open',  accreditationId, ownerId, caseId, accountId);

            }

            if(String.isBlank(oscarId))
                throw new CalloutException('There was an error on OSCAR object creation. Please check the logs or contact the System Administrator.');
                //return 'There was an error on OSCAR object creation. Please check the logs or contact the System Administrator.';

            if(typeOfProcess.equalsIgnoreCase(NEWBR_PV) || typeOfProcess.equalsIgnoreCase(NEWBRABRD_PV) || typeOfProcess.equalsIgnoreCase(NEWTIDS_PV) || typeOfProcess.equalsIgnoreCase(NEWSA_PV) || typeOfProcess.equalsIgnoreCase(NEWNAE) || typeOfProcess.equalsIgnoreCase(MCAE)){
                if(!createHierarchy(realAccountId, typeOfProcess)){
                    Database.rollback(sp);
                    throw new CalloutException('There was an error on hierarchy object creation (does the account have a parent ?) . Please check the logs or contact the System Administrator.');
                    //return 'There was an error on hierarchy object creation (does the account have a parent ?) . Please check the logs or contact the System Administrator.';
                }
            }



            if(!cases.isEmpty()){

                Case oscarCase = cases.get(0);

                oscarCase.OSCAR__c = oscarId;

                if(typeOfProcess.equalsIgnoreCase(NEWBR_PV) || typeOfProcess.equalsIgnoreCase(NEWBRABRD_PV) || typeOfProcess.equalsIgnoreCase(MAJOR_CHANGES_PV) || typeOfProcess.equalsIgnoreCase(NEWSA_PV) || typeOfProcess.equalsIgnoreCase(MCAE) || typeOfProcess.equalsIgnoreCase(NEWNAE) || typeOfProcess.equalsIgnoreCase(MAJOR_CHANGESNEWGEN_PV) || typeOfProcess.equalsIgnoreCase(NEWVR_PV))
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

        if(!(accountConcernedProcesses.contains(typeOfProcess.toUpperCase())))
            return accountId;

        List<Case> cases = [SELECT Id, Account_Concerned__c from CASE where Id = :caseId LIMIT 1];

        if(!cases.isEmpty()){
                System.debug('Changing the Account to the Account concerned. as the type of process is ' + typeOfProcess);
                return cases.get(0).Account_Concerned__c;

        }else{
            System.debug('NOT Changing the Account as the type of process is ' + typeOfProcess);
        }

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

        if(existingRelations.isEmpty()){ // create a new hierarchy if not SA. If so we need to check something first ...

            // we need to check if the parent is a BR, in that case, he is not parent in any relationship but a child.
            if(typeOfProcess.equalsIgnoreCase(NEWSA_PV)){

               existingRelations = [SELECT Id, Hierarchy__c from AMS_Agencies_relationhip__c where Child_Account__c =:parentAccount.Id LIMIT 1];

               if(existingRelations.isEmpty()){

                    System.debug('Did not find any hierarchy, creating new one.');

                    hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy');

                    insert hierarchy;

               }else{

                System.debug('Already has an hierarchy with id:' + existingRelations.get(0).Id );

                hierarchy = new AMS_Agencies_Hierarchy__c(Id = existingRelations.get(0).Hierarchy__c);

               }


            }else{

                    System.debug('Did not find any hierarchy, creating new one.');

                    hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy');

                    insert hierarchy;
            }

        }else{

            System.debug('Already has an hierarchy with id:' + existingRelations.get(0).Id );

            hierarchy = new AMS_Agencies_Hierarchy__c(Id = existingRelations.get(0).Hierarchy__c);
        }

        System.debug('Creating relationship with parent ' + parentAccount.Id + ' and child ' + account.Id);

        Boolean isNewgenRelation = typeOfProcess.equalsIgnoreCase(NEWNAE);

        AMS_Agencies_relationhip__c relationship = new AMS_Agencies_relationhip__c(Child_Account__c = account.Id, Parent_Account__c = parentAccount.Id, Hierarchy__c = hierarchy.Id, Is_Newgen_Relation__c = isNewgenRelation);

        insert relationship;

        return true;

    }

    private static String fetchOscarRecordType(String typeOfProcess){

        if(typeOfProcess.equalsIgnoreCase(NEWBR_PV) || typeOfProcess.equalsIgnoreCase(NEWHO_PV) || typeOfProcess.equalsIgnoreCase(NEWBRABRD_PV) || typeOfProcess.equalsIgnoreCase(NEWTIDS_PV) || typeOfProcess.equalsIgnoreCase(NEWGSA_PV) || typeOfProcess.equalsIgnoreCase(NEWAHA_PV) || typeOfProcess.equalsIgnoreCase(NEWMSO_PV) || typeOfProcess.equalsIgnoreCase(NEWSA_PV))
            return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'NEW');

        if(typeOfProcess.equalsIgnoreCase(BANK_ACCOUNT_CHANGES_PV) || typeOfProcess.equalsIgnoreCase(MAJOR_CHANGES_PV) || typeOfProcess.equalsIgnoreCase(DGR_DGA_PV))
            return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CHANGE');

        if(typeOfProcess.equalsIgnoreCase(NEWCORRECTION_PV))
            return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CORRECTION');

        if(typeOfProcess.equalsIgnoreCase(NEWDGR_PV) || typeOfProcess.equalsIgnoreCase(PCI_COMPLIANT))
            return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CERTIFICATION');

        if(typeOfProcess.equalsIgnoreCase(NEWVR_PV) || typeOfProcess.equalsIgnoreCase(NEWVRCA_PV))
            return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'VOLUNTARY_RELINQUISHMENT');

        if(typeOfProcess.equalsIgnoreCase(NEWCER_PV))
            return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CERTIFICATE');

        if(typeOfProcess.equalsIgnoreCase(NEWNGLITE))
            return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_New_HE');

        if(typeOfProcess.equalsIgnoreCase(NEWNSTANDARD))
            return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_New_HE');

        if(typeOfProcess.equalsIgnoreCase(NEWNAE))
            return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_New_AE');
            
        if(typeOfProcess.equalsIgnoreCase(MCAE))
            return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Multicountry_AE');

        if(typeOfProcess.equalsIgnoreCase(AMS_Utils.NGCHANGES))
            return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes');

        if(typeOfProcess.equalsIgnoreCase(AMS_Utils.NGFOP))
            return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'NGFormsOfPayment');
 
        if(typeOfProcess.equalsIgnoreCase(OPTINOPTOUT))
            return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_FS_OPTINOUT');

        if(typeOfProcess.equalsIgnoreCase(AMS_Utils.NGCORRECTION))
            return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'NGCORRECTION');

        if(typeOfProcess.equalsIgnoreCase(NEWNGLOBAL)) {
            return AMS_Utils.RECTYPE_NEWGE;
        }
	
        if(typeOfProcess.equalsIgnoreCase(AMS_Utils.NGGDI))
            return AMS_Utils.RECTYPE_GDI;
        
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

    private Static String createOscar(String accountId, String processType, String recordTypeId, String oscarStatus, String accreditationId, Id owner, Id caseId, Id parentAccount){

        AMS_OSCAR__c oscar;
        AMS_Pax_Accreditation_Form__c accreditationObj;

        if(owner == null)
            oscar = new AMS_OSCAR__c(Account__c = accountId, Process__c = processType, RecordTypeId =recordTypeId, Status__c = oscarStatus);
        else
            oscar = new AMS_OSCAR__c(Account__c = accountId, Process__c = processType, RecordTypeId =recordTypeId, Status__c = oscarStatus, OwnerId = owner );

        if(processType != NEWVR_PV && processType != NEWVRCA_PV && processType != NEWCER_PV && processType != NGFOP_PV && processType != OPTINOPTOUT){
            oscar.AMS_Online_Accreditation__c = accreditationId;
        }

        if(processType.equalsIgnoreCase(AMS_Utils.NEWAE) || processType.equalsIgnoreCase(AMS_Utils.MCAE)){
            fillNewAEFieldsFromParent(parentAccount,accountId,accreditationId);
        }

        //Need to check if is a newgen process, cant use the process because voluntary relinquishment shares the same process and record type as AMS
        Account acc = [SELECT ANG_IsNewGenAgency__c, ANG_FA_Opt_out__c FROM Account WHERE Id =:accountId];

        if(processType.equalsIgnoreCase(NEWVR_PV)){
            accreditationObj = fetchAccreditationObject(accreditationId);
            oscar.Form_Effective_Date__c = accreditationObj.Effective_Date_Of_Change__c;
            oscar.Change_effective_as_of__c = accreditationObj.Effective_Date_Of_Change__c;
        }

        //AMSU-140
        //if(processType.equalsIgnoreCase(MAJOR_CHANGES_PV) || processType.equalsIgnoreCase(MAJOR_CHANGESNEWGEN_PV) || processType.equalsIgnoreCase(AMS_Utils.NGFOP)){
        if(processType.equalsIgnoreCase(MAJOR_CHANGES_PV) || processType.equalsIgnoreCase(MAJOR_CHANGESNEWGEN_PV) || processType.equalsIgnoreCase(AMS_Utils.NGFOP) || processType.equalsIgnoreCase(AMS_Utils.COR)){

            accreditationObj = fetchAccreditationObject(accreditationId);

            handleOwners(accreditationObj);

            String typeOfChange = getFormatedTypeOfChange(processType,accreditationObj);

            if(processType.equalsIgnoreCase(MAJOR_CHANGES_PV))
                oscar.Type_of_change__c = typeOfChange;

            if(processType.equalsIgnoreCase(MAJOR_CHANGESNEWGEN_PV)){

                oscar.Change_effective_as_of__c = accreditationObj.Effective_Date_Of_Change__c;
            }
        }

        Set<String> processesToUpdateCaseOnOscar = new Set<String>{AMS_Utils.NEWHESTANDARD,AMS_Utils.NEWGESTANDARD,AMS_Utils.NEWHELITE, AMS_Utils.NEWAE, AMS_Utils.MCAE, AMS_Utils.NGCORRECTION, AMS_Utils.NGCHANGES, AMS_Utils.NGOPTINOUT};
        if(processesToUpdateCaseOnOscar.contains(processType)){
            oscar.Oscar_Communication_Case_Id__c = caseId;
        }

        // this needs to be fetched from Accreditation Object. For now just use this.
        if(processType == NEWNGLITE){
            oscar.Is_using_credit_card__c = true;
        }

        if(processType.equalsIgnoreCase(NEWCER_PV)){
            List<Case> caseList = [SELECT Id, QuantityProduct__c FROM Case WHERE Id = :caseId LIMIT 1];
            if(!caseList.isEmpty()){
                oscar.Certificate_Quantity__c = Integer.valueOf(caseList.get(0).QuantityProduct__c);
            }

        }

        if(processType.equalsIgnoreCase(NGFOP_PV)){
            oscar.STEP38__c = AMS_Utils.NOT_APPLICABLE;
            oscar.STEP39__c = AMS_Utils.NOT_APPLICABLE;
        }

        if(processType.equalsIgnoreCase(OPTINOPTOUT)){

            oscar.ANG_FA_Opt_out__c = acc.ANG_FA_Opt_out__c == true ? 'Opt-In' : 'Opt-Out';
        }
        
        insert oscar;

        //AMSU-140
        //if(( processType.equalsIgnoreCase(MAJOR_CHANGESNEWGEN_PV) || processType.equalsIgnoreCase(MAJOR_CHANGES_PV) || processType.equalsIgnoreCase(NGFOP_PV) || (processType.equalsIgnoreCase(NEWVR_PV) && acc.ANG_IsNewGenAgency__c)) && processType != NEWVRCA_PV && processType != NEWCER_PV){
        if(( processType.equalsIgnoreCase(MAJOR_CHANGESNEWGEN_PV) || processType.equalsIgnoreCase(MAJOR_CHANGES_PV) || processType.equalsIgnoreCase(NGFOP_PV) || (processType.equalsIgnoreCase(NEWVR_PV) || processType.equalsIgnoreCase(AMS_Utils.COR) && acc.ANG_IsNewGenAgency__c)) && processType != NEWVRCA_PV && processType != NEWCER_PV){

            processOscarProcessDetail(oscar,accreditationObj,accountId);
        }

        //commented as per NEWGEN-3265
        /*if(processType.equalsIgnoreCase(OPTINOPTOUT)){
        
            Map<Id, Set<Id>> stagingToAccount = new Map<Id, Set<Id>>();
            stagingToAccount.put(accreditationId, new Set<Id>{accountId});
            AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(stagingToAccount);

        }*/
        
        return oscar.id;
    }

    public static void fillNewAEFieldsFromParent(String parentId, String accountId, String accreditationId){

        //Let's get the parent account
        Account acct = [Select Id, ANG_Accreditation_Model__c, Location_type__c, Remittance_frequency__c, Parent.Remittance_frequency__c from Account where Id = :parentId];

        AMS_Pax_Accreditation_Form__c accredObject = new AMS_Pax_Accreditation_Form__c(Id =accreditationId);

        if(parentId == accountId && acct.Location_Type__c == 'AE'){
            accredObject.Remittance_frequency__c = acct.Parent.Remittance_frequency__c;
        }
        else
            accredObject.Remittance_frequency__c = acct.Remittance_frequency__c;

        update accredObject;

        Account acctChild = new Account(Id = accountId);
        acctChild.ANG_Accreditation_Model__c = acct.ANG_Accreditation_Model__c;

        update acctChild;

    }

    private static void handleOwners(AMS_Pax_Accreditation_Form__c accreditationObj){

        // The accreditation Contacts have two types : previous and current.
        // The business rule is the following:
        // if the accreditation form doesn't have current contact, just clone the previous contacts into current contacts.
        // if the accreditation form has current contacts, don't clone nothing.

        Map<String,String> previousContactTypes = new Map<String,String>();


        previousContactTypes.put('Previous_Company_Owner','Current_Company_Owner');
        previousContactTypes.put('Previous_Owner','Current_Owner');

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

       for(AMS_Accreditation_Contact__c contact: contacts){

            AMS_Accreditation_Contact__c contactCloned = contact.clone(false,false,false,false);

            String newRecordTypeDevName = previousContactTypes.get(contact.RecordType.DeveloperName);

            ID newRecordType = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', newRecordTypeDevName);

            contactCloned.recordTypeId = newRecordType;

            toInsert.add(contactCloned);

       }

       if(!toInsert.isEmpty())
        insert toInsert;

    }

    private static AMS_Pax_Accreditation_Form__c fetchAccreditationObject(String accreditationId){

        return [select Id, Notify_Change_Legal_Details__c, Notify_Change_Location__c, Notify_Change_Ownership__c, Scope_of_Change__c, Agency_Codes_Concerned__c, Effective_Date_Of_Change__c, Remittance_frequency__c, SAAM_Case__r.Reason1__c from AMS_Pax_Accreditation_Form__c where Id = :accreditationId LIMIT 1];

    }

    public static void processOscarProcessDetail(AMS_OSCAR__c oscar, AMS_Pax_Accreditation_Form__c accreditationObj, String accountFromOscar){

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

            ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

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

        Boolean hasTN = containsTradeName(accountChanges);

        List<Account> accountsToProcess = new List<Account>();
        List<AMS_OSCAR_JSON.ChangeCode> changeCodesToProcess = new List<AMS_OSCAR_JSON.ChangeCode>();
        List<AMS_OSCAR__c> oscarsToProcess = new List<AMS_OSCAR__c>();

        AMS_OSCAR_JSON.ChangeCode changeCodeTN = null;
        AMS_OSCAR_JSON.ChangeCode changeCode = null;

        if(accountId == null)
            throw new CalloutException('Account Id must be filled.');

        Account account = new Account(Id = accountId);
        Account a = [SELECT Id, CNS_Agency__c, Location_Class__c, Status__c, (SELECT Reason_Code__c, Reason_Description__c FROM Agencies_Applied_Change_codes__r WHERE Active__c = TRUE) FROM Account WHERE Id = :accountId];

        if(a == null)
            throw new CalloutException('Account could not be found.');

        if(hasTN){
                  
            if(!a.CNS_Agency__c) {
                changeCodeTN = generateChangeCodeTN(accountChanges, account.Status__c == 'Approved');

                if(a.Agencies_Applied_Change_codes__r.size() > 0){
                        changeCodeTN.reasonCode = a.Agencies_Applied_Change_codes__r[0].Reason_Code__c;
                        changeCodeTN.reasonDesc = a.Agencies_Applied_Change_codes__r[0].Reason_Description__c;
                }

                //2080607 DT: switched to A
	            //accountsToProcess.add(account);
	            accountsToProcess.add(a);
                changeCodesToProcess.add(changeCodeTN);
                oscarsToProcess.add(null);
            }
        }

        if(accountChanges.size() > 1 ||  ( accountChanges.size() == 1 && !hasTN )){

            changeCode = generateChangeCode(accountChanges);
            changeCode.publishedOnEBulletin = a.CNS_Agency__c && a.Location_Class__c == 'C'; //CAD change codes for CNS C agencies is published on the ebulletin

            if(a.Agencies_Applied_Change_codes__r.size() > 0){
                    changeCode.reasonCode = a.Agencies_Applied_Change_codes__r[0].Reason_Code__c;
                    changeCode.reasonDesc = a.Agencies_Applied_Change_codes__r[0].Reason_Description__c;
            }

            //2080607 DT: switched to A
            //accountsToProcess.add(account);
            accountsToProcess.add(a);
            changeCodesToProcess.add(changeCode);
            oscarsToProcess.add(null);
        }

        List<AMS_ChangeCodesHelper.ObjectChangesStruct> objectChanges = AMS_ChangeCodesHelper.convertAccountToObjectChanges(accountChanges);

        AMS_ChangeCodesHelper.createAAChangeCodes( objectChanges, changeCodesToProcess, oscarsToProcess, accountsToProcess,false);
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
        AMS_ChangeCodes__c cad = AMS_ChangeCodes__c.getInstance('CADM');

        toReturn.name = cad.Change_Code__c;
        toReturn.memoText = cad.Bulletin_Memo_Text__c;

        return toReturn;
    }

    public static AMS_OSCAR_JSON.ChangeCode generateChangeCodeTN(List<AMS_RecordCreatorWebservice.AccountChanges> accountChanges,Boolean isToChangeStatus){

        AMS_OSCAR_JSON.ChangeCode toReturn = new AMS_OSCAR_JSON.ChangeCode();
        AMS_ChangeCodes__c cta = AMS_ChangeCodes__c.getInstance('CTA');

        toReturn.name = cta.Change_Code__c;
        toReturn.memoText = cta.Bulletin_Memo_Text__c;//createMemoText(accountChanges);

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

    /**
        Creates an Oscar (AMS_OSCAR__c) given an Account Id, an Accreditation Id and the Type of Process
    **/
    webservice static String createAccreditationForSA(String caseId){

        // Create a savepoint
        Savepoint sp = Database.setSavepoint();
        String oscarId = null;

        try{

            Id oscarRecordType = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'NEW');

            Case caseObj = [SELECT Id, Account_Concerned__c, AccountId, Account.Location_Type__c, Account.Category__c, OSCAR__c, OwnerId from CASE where Id = :caseId LIMIT 1];

            Id ownerId = null;

            if(!Test.isRunningTest())
                ownerId = caseObj.OwnerId;

            //Create a new Account for the SA, with the values reported in the below table

            Account parentAccount = [SELECT Id,Name,Short_Name__c,Abbreviated_name__c,IATA_ISO_Shipping_Country__c,TradeName__c,Company_Type__c,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,IATA_ISO_Country__c,Iso_State__c,Abbreviated_address__c,Website,Phone,Fax,Email__c,Top_Parent__c from Account where Id = :caseObj.Account_Concerned__c LIMIT 1];

            Account newSAAccount = createSAAccount(parentAccount);

            String typeOfProcess = 'NEW.SA.1.0';

            AMS_Pax_Accreditation_Form__c accreditationObj = createAccreditationObjectForSA(newSAAccount,caseObj);

            AMS_MigrationToolHelper.createAccreditationContacts(accreditationObj, parentAccount.Id, typeOfProcess);

            oscarId = createOscar(newSAAccount.Id,  typeOfProcess, oscarRecordType ,  'Open',  accreditationObj.ID, ownerId, null, null);

            if(String.isBlank(oscarId))
                throw new CalloutException('There was an error on OSCAR object creation. Please check the logs or contact the System Administrator.');
                //return 'There was an error on OSCAR object creation. Please check the logs or contact the System Administrator.';

            if(!createHierarchy(newSAAccount.Id, typeOfProcess)){
                Database.rollback(sp);
                throw new CalloutException('There was an error on hierarchy object creation (does the account have a parent ?) . Please check the logs or contact the System Administrator.');
            }


            ID rtCommCase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

            caseObj.OSCAR__c = oscarId;
            caseObj.AccountId = newSAAccount.Id;
            caseObj.RecordTypeId = rtCommCase;
            caseObj.Account_Concerned__c = null;

            String typeOfCustomer = AMS_Utils.fetchTypeOfCustomer(caseObj.Account.Location_Type__c,caseObj.Account.Category__c);

            if(typeOfCustomer != null)
                caseObj.Type_of_Customer__c = typeOfCustomer;

            update caseObj;


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

    public static AMS_Pax_Accreditation_Form__c createAccreditationObjectForSA(Account accountSA, Case caseObj){

        AMS_Pax_Accreditation_Form__c accreditationObj = new AMS_Pax_Accreditation_Form__c();

        accreditationObj.SAAM_Case__c = caseObj.Id;
        accreditationObj.Account_Name__c = accountSA.Name;
        accreditationObj.Short_Name__c = accountSA.Short_Name__c;
        accreditationObj.Abbreviated_name__c = accountSA.Abbreviated_name__c;
        accreditationObj.Trade_Name__c = accountSA.TradeName__c;
        accreditationObj.ISSP_AMS_Legal_Status__c = AMS_MigrationToolHelper.decode(accountSA.Company_Type__c);

        accreditationObj.Shipping_City__c = accountSA.ShippingCity;
        accreditationObj.Shipping_Country__c = accountSA.ShippingCountry;
        accreditationObj.Shipping_ISO_Country__c = accountSA.IATA_ISO_Shipping_Country__c;
        accreditationObj.Shipping_ISO_State__c = accountSA.IATA_ISO_Shipping_State__c;
        accreditationObj.Shipping_Postal_Code__c = accountSA.ShippingPostalCode;
        accreditationObj.Shipping_State__c = accountSA.ShippingState;
        accreditationObj.Shipping_Street__c = accountSA.ShippingStreet;

        accreditationObj.Branch_Office_Country__c = accountSA.IATA_ISO_Country__c;
        accreditationObj.ISO_Country__c = accountSA.IATA_ISO_Country__c;
        accreditationObj.IATA_ISO_State__c = accountSA.Iso_State__c;
        accreditationObj.Billing_State__c = accountSA.BillingState;
        accreditationObj.Abbreviated_Address__c = accountSA.Abbreviated_Address__c;
        accreditationObj.Website__c = accountSA.Website;
        accreditationObj.Branch_Office_Phone__c = accountSA.Phone;
        accreditationObj.Branch_Office_Email__c = accountSA.Email__c;
        accreditationObj.Branch_Office_FAX__c = accountSA.Fax;
        accreditationObj.Location_Type__c = 'SA';
        accreditationObj.Location_Class__c = 'P';
        accreditationObj.Branch_Office_Street_name_number__c = accountSA.BillingStreet;
        accreditationObj.Branch_Office_Postal_code__c = accountSA.BillingPostalCode;
        accreditationObj.Branch_Office_City__c = accountSA.BillingCity;
        accreditationObj.Operation_Type__c = accountSA.Sector__c.replace(' ','_');


        insert accreditationObj;

        return accreditationObj;
    }
    
    public static AMS_Pax_Accreditation_Form__c createAccreditationObjectForMC(Account accountMC, Case caseObj){

        AMS_Pax_Accreditation_Form__c accreditationObj = new AMS_Pax_Accreditation_Form__c();

        accreditationObj.SAAM_Case__c = caseObj.Id;
        accreditationObj.Account_Name__c = accountMC.Name;
        accreditationObj.Short_Name__c = accountMC.Short_Name__c;
        accreditationObj.Abbreviated_name__c = accountMC.Abbreviated_name__c;
        accreditationObj.Trade_Name__c = accountMC.TradeName__c;
        accreditationObj.ISSP_AMS_Legal_Status__c = AMS_MigrationToolHelper.decode(accountMC.Company_Type__c);

        accreditationObj.Shipping_City__c = accountMC.ShippingCity;
        accreditationObj.Shipping_Country__c = accountMC.ShippingCountry;
        accreditationObj.Shipping_ISO_Country__c = accountMC.IATA_ISO_Shipping_Country__c;
        accreditationObj.Shipping_ISO_State__c = accountMC.IATA_ISO_Shipping_State__c;
        accreditationObj.Shipping_Postal_Code__c = accountMC.ShippingPostalCode;
        accreditationObj.Shipping_State__c = accountMC.ShippingState;
        accreditationObj.Shipping_Street__c = accountMC.ShippingStreet;

        accreditationObj.Branch_Office_Country__c = accountMC.IATA_ISO_Country__c;
        accreditationObj.ISO_Country__c = accountMC.IATA_ISO_Country__c;
        accreditationObj.IATA_ISO_State__c = accountMC.Iso_State__c;
        accreditationObj.Billing_State__c = accountMC.BillingState;
        accreditationObj.Abbreviated_Address__c = accountMC.Abbreviated_Address__c;
        accreditationObj.Website__c = accountMC.Website;
        accreditationObj.Branch_Office_Phone__c = accountMC.Phone;
        accreditationObj.Branch_Office_Email__c = accountMC.Email__c;
        accreditationObj.Branch_Office_FAX__c = accountMC.Fax;
        accreditationObj.Location_Type__c = accountMC.Location_Type__c;
        accreditationObj.Location_Class__c = accountMC.Location_Class__c;
        accreditationObj.Branch_Office_Street_name_number__c = accountMC.BillingStreet;
        accreditationObj.Branch_Office_Postal_code__c = accountMC.BillingPostalCode;
        accreditationObj.Branch_Office_City__c = accountMC.BillingCity;
        accreditationObj.Operation_Type__c = accountMC.Sector__c.replace(' ','_');


        insert accreditationObj;

        return accreditationObj;
    }


    public static Account createSAAccount(Account parentAccount){

        Account acctSA = new Account();

        acctSA.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        acctSA.Name = parentAccount.Name;
        acctSA.Short_Name__c = parentAccount.Short_Name__c;
        acctSA.Abbreviated_name__c = parentAccount.Abbreviated_name__c;
        acctSA.TradeName__c = parentAccount.TradeName__c;
        acctSA.Company_Type__c = parentAccount.Company_Type__c;

        acctSA.ShippingCity = parentAccount.ShippingCity;
        acctSA.ShippingCountry = parentAccount.ShippingCountry;
        acctSA.ShippingPostalCode = parentAccount.ShippingPostalCode;
        acctSA.ShippingState = parentAccount.ShippingState;
        acctSA.ShippingStreet = parentAccount.ShippingStreet;

        acctSA.BillingCity = parentAccount.BillingCity;
        acctSA.BillingCountry = parentAccount.BillingCountry;
        acctSA.BillingPostalCode = parentAccount.BillingPostalCode;
        acctSA.BillingState = parentAccount.BillingState;
        acctSA.BillingStreet = parentAccount.BillingStreet;

        acctSA.IATA_ISO_Country__c = parentAccount.IATA_ISO_Country__c;
        acctSA.Iso_State__c = parentAccount.Iso_State__c;
        acctSA.Abbreviated_address__c = parentAccount.Abbreviated_address__c;
        acctSA.Website = parentAccount.Website;
        acctSA.Phone = parentAccount.Phone;
        acctSA.Fax = parentAccount.Fax;
        acctSA.Email__c = parentAccount.Email__c;
        acctSA.Location_Type__c ='SA';
        acctSA.Location_Class__c = 'P';
        acctSA.Sector__c = 'Travel Agent';
        acctSA.Category__c = 'Non-IATA Travel Agent';
        acctSA.ParentId = parentAccount.Id;
        acctSA.REASON_FOR_CREATION__C = 'Created by customer';

        if (parentAccount.Top_Parent__c == null) {
            acctSA.Top_Parent__c = parentAccount.Id;
        } else {
                acctSA.Top_Parent__c = parentAccount.Top_Parent__c;
        }

        insert acctSA;

        return acctSA;

    }
}
