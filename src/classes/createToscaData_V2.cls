public with sharing class createToscaData_V2 {

    public String selectedTest                                  {get;set;}
    public String usedEmail                                     {get;set;}
    public String strDocURL                                     {get;set;}
    public List<toscaWrapper> wrapperList                       {get;set;}
    public String checkAccNr = '0';
    public AMS_Agencies_Hierarchy__c agHierarchy                {get;set;}
    public Boolean isAccredited                                 {get;set;}
    
    public Boolean firstOscar                                   {get;set;}
    public Boolean iataCode                                     {get;set;}
    public Boolean dueDeligence                                 {get;set;}
    public Boolean agencyFees                                   {get;set;} 
    public Boolean appProcessing                                {get;set;}
    public Boolean validation                                   {get;set;}
    public Boolean appFinalization                              {get;set;}

    public Boolean showSidra                                    {get;set;}
    public Boolean showAccredit                                 {get;set;}
    public Boolean showAccredit2                                {get;set;}
    public Boolean fromSidra                                    {get;set;}
    public Boolean fromSidraLikeRB                              {get;set;}
    public Boolean isLimitedCompany                             {get;set;}
    public Boolean accreditp2                                   {get;set;}
    public String parentAccount                                 {get;set;}
    public String sidraChoosed                                  {get;set;}
    public Boolean updateRisk                                   {get;set;}
    public Boolean isCargoChild                                 {get;set;} 
    public Boolean isTocreateOscarCase                          {get;set;}
    public Boolean fromCreateOscarBtn                           {get;set;}
    public Boolean givePermissions                              {get;set;}
    public Boolean sendInvitation                               {get;set;}
    public Boolean showURL                                      {get;set;}
    public String communityURL                                  {get;set;}
    public String firstSelection                                {get;set;}
    public String qCountry                                      {get;set;}    

    public Account parentAcc  {get;set;} 
    public Contact contact {get;set;} 
    public User user {get;set;}
    public AMS_Accreditation_Contact__c accreditationContact    {get;set;}
    public Invitation__c fredInvitation                         {get;set;}

    private List<String> requireCASS_Number = new List<String>{'C','R','I','Q','G'};
    
    Account pAccount;
    public IATA_ISO_Country__c country {get;set;}    
    IATA_ISO_State__c isoState;    
    Map<String,Object> fieldsOfObject;    
    Account childAcc;      
    Portal_Applications__c portalApplications;
    AMS_Settlement_System__c settlementSystem;
    AMS_Operation__c operationCode;
    ANG_BSP_Attributes__c bspAttributes;
    ANG_BSP_Attributes__c newBSPattribute4times;
    ANG_BSP_Attributes__c newBSPattributeMonthly;
    ANG_BSP_Attributes__c newBSPattributeCode5d;
    Agency_Authorization__c agencyAuthorization;
    public AMS_Pax_Accreditation_Form__c theAccreditation;
    public Case oscarCase;
    public AMS_OSCAR__c oscar;
    ANG_Agency_Risk_Event__c riskevent;
    Case sidraCase;
    Agency_Applied_Change_code__c chCode;
    AMS_Account_Role__c accountRole;
    AMS_Agencies_relationhip__c ageRelationship;
    String username;
    String typeOfProcess = '';
        
    Boolean showActionButton = false;

/****************************************************************************************************************************************************************
  
                                                                    Action buttons                                                 
                                                                            
****************************************************************************************************************************************************************/ 

    public pageReference createData(){

        wrapperList = new List<toscaWrapper>();
        
        List<Integer> toDelete = new List<Integer>();

        system.debug(LoggingLevel.ERROR,'aqui firstSelection 1 ** ' + firstSelection + ' -- selectedTest -- ' + selectedTest + ' qCountry ' + qCountry);
        if(firstSelection == null){
            firstSelection = selectedTest;
        }
        system.debug(LoggingLevel.ERROR,'aqui firstSelection ' + firstSelection + ' -- selectedTest -- ' + selectedTest);
        if(firstSelection != '' && firstSelection != selectedTest){
            wrapperList.clear();
            system.debug(LoggingLevel.ERROR,'aqui wrapperList ' + wrapperList.size());
        }

        if(String.isBlank(usedEmail)){            
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please fill the email to be used'));
            return null;      
        }

        if((selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT || selectedTest == TOSCAUTILS.CREATE_RISK_EVENT) && String.isBlank(parentAccount)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please fill the parent account with the IATA code of the Account to be used has a Parent or Risk Account'));
            return null;      
        }

        if (selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT || selectedTest == TOSCAUTILS.NEW_HE_CASH || selectedTest == TOSCAUTILS.NEW_HE_CASHLESS || selectedTest == TOSCAUTILS.NEW_HO_PASSENGER || selectedTest == TOSCAUTILS.NEW_HO_CARGO || selectedTest == TOSCAUTILS.NEW_HE_STANDARD || selectedTest == TOSCAUTILS.NEW_HO_TIDS || selectedTest == TOSCAUTILS.NEW_AIRLINE_AIRCRAFT_OPERATOR || selectedTest == TOSCAUTILS.NEW_AIRLINE_MEMBER_STATE){
            
            createEssentialData();                      
            createAccount();
            createContact();
            createPortalUser();
            addPortalService();
        }

        if(selectedTest == TOSCAUTILS.CREATE_RISK_EVENT){
            checkRiskAccount();
        }
        
        buildWrapperList();

        showSidra = false;
        isTocreateOscarCase = (selectedTest != TOSCAUTILS.NEW_AIRLINE_AIRCRAFT_OPERATOR && selectedTest != TOSCAUTILS.NEW_AIRLINE_MEMBER_STATE);
        
        return null;
    }


/****************************************************************************************************************************************************************
  
                                                            CREATE ESSENTIAL DATA           
                                                    create data that can be missed on the sandbox                                                     
                                                                            
****************************************************************************************************************************************************************/ 

    public void createEssentialData() {

        Id settlementRTId = AMS_Utils.RECTYPE_BSP;
        //CHECK IATA ISO COUNTRY
        system.debug('aqui qCountry'+ qCountry);
        system.debug('aqui selectedTest'+ selectedTest);
        if(selectedTest.contains('HE')){
            if(qCountry == '--None--' || String.isBlank(qCountry))
                qCountry = 'United Kingdom';
        }else if(selectedTest.contains('HO')){
            if(qCountry == '--None--' || String.isBlank(qCountry))
                qCountry = 'Jamaica';
        }else if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT && qCountry == '--None--'){
            pAccount = TOSCAUTILS.fetchParentAccount(parentAccount);
            IATA_ISO_Country__c pCountry = [SELECT Name FROM IATA_ISO_Country__c WHERE Name = :pAccount.IATA_ISO_Country__r.Name];
            qCountry = pCountry.Name;
            system.debug('Child Country ' + qCountry);
        }

        if(selectedTest == TOSCAUTILS.NEW_HE_CASH || selectedTest == TOSCAUTILS.NEW_HE_CASHLESS || selectedTest == TOSCAUTILS.NEW_HE_STANDARD){
             country = [SELECT Id, Name,ISO_Code__c, ANG_Enable_NewGen__c FROM IATA_ISO_Country__c WHERE Name LIKE :qCountry AND ANG_Enable_NewGen__c = true];
             isoState = [SELECT id, IATA_ISO_Country__c FROM IATA_ISO_State__c WHERE IATA_ISO_Country__c =:country.Id LIMIT 1];            
        }else{
            country = [SELECT Id, Name, ANG_Enable_NewGen__c FROM IATA_ISO_Country__c WHERE NAME = :qCountry LIMIT 1];
            isoState = [SELECT id, IATA_ISO_Country__c FROM IATA_ISO_State__c WHERE IATA_ISO_Country__c =:country.Id LIMIT 1];
        }

        //CHECK TOSCA AGENCY HIERARCHY
        agHierarchy = TOSCAUTILS.fetchToscaAgenciedHierarchy();

        if(agHierarchy == null && selectedTest != TOSCAUTILS.NEW_HE_CHILD_ACCOUNT){
            fieldsOfObject = new Map<String,Object>();
            fieldsOfObject.put('Hierarchy_Name__c', 'Tosca hierarchy');

            agHierarchy = new AMS_Agencies_Hierarchy__c();
            agHierarchy = ANG_EntityCreator.createAgenciesHierarchy(fieldsOfObject);
            insert agHierarchy;
        }

        //CHECK PORTAL SERVICE
        portalApplications = TOSCAUTILS.fetchPortalApplication();

        if(portalApplications == null){
            fieldsOfObject = new Map<String,Object>();
            fieldsOfObject.put('Name','IATA Accreditation & Changes');
            fieldsOfObject.put('Critical_Service__c',true);
            fieldsOfObject.put('Agency__c',true);

            portalApplications = TOSCAUTILS.createPortalApplication(fieldsOfObject);
            insert portalApplications;
        }

        //CHECK AMS SETTLEMENT SYSTEM
        settlementSystem = TOSCAUTILS.fetchAmsSettlementSystem();

        if(settlementSystem == null){
            fieldsOfObject = new Map<String,Object>();
            fieldsOfObject.put('Name','BSP-FR');
            fieldsOfObject.put('RecordTypeId',settlementRTId);
            fieldsOfObject.put('DPC_System__c','CASSLINK');
            fieldsOfObject.put('BSP_Billing__c','FR');

            settlementSystem = TOSCAUTILS.createAMSSettlementSystem(fieldsOfObject);
            insert settlementSystem;
        }

        //CHECK AMS OPPERATION CODE
        operationCode = TOSCAUTILS.fetchOperationCode(country.Id);

        if(operationCode == null){
            fieldsOfObject = new Map<String,Object>();
            fieldsOfObject.put('Name','FR_BSP_Y_EUR_I');
            fieldsOfObject.put('Settlement__c',settlementSystem.Id);
            fieldsOfObject.put('Country__c',country.Id);
            fieldsOfObject.put('Market__c','Internation');

            operationCode = TOSCAUTILS.amsOperationCode(fieldsOfObject);
            insert operationCode;
        }

        //CHECK BSP ATTRIBUTES REMITTANCE FREQUENCY 4 TIMES PER MONTH
        newBSPattribute4times = TOSCAUTILS.fecthBspAttributes4Times(operationCode.Id);

        if(newBSPattribute4times == null){
            fieldsOfObject = new Map<String,Object>();
            fieldsOfObject.put('Class_Type__c','P');
            fieldsOfObject.put('Remittance_Frequency__c', 'W');
            fieldsOfObject.put('Operation__c',operationCode.Id);

            newBSPattribute4times = TOSCAUTILS.angBSPAttributes(fieldsOfObject);
            insert newBSPattribute4times;
        }

        //CHECK BSP ATTRIBUTES REMITTANCE FREQUENCY MONTHLY
        newBSPattributeMonthly = TOSCAUTILS.fecthBspAttributesMontly(operationCode.Id);
        
        if(newBSPattributeMonthly == null){
            fieldsOfObject = new Map<String,Object>();
            fieldsOfObject.put('Class_Type__c','P');
            fieldsOfObject.put('Remittance_Frequency__c', 'M');
            fieldsOfObject.put('Operation__c',operationCode.Id);

            newBSPattributeMonthly = TOSCAUTILS.angBSPAttributes(fieldsOfObject);
            insert newBSPattributeMonthly;
        }

        //CHECK BSP ATTRIBUTES REMITTANCE FREQUENCY EVERY 5 DAYS
        newBSPattributeCode5d = TOSCAUTILS.fecthBspAttributes5days(operationCode.Id);
        
        if(newBSPattributeCode5d == null){
            fieldsOfObject = new Map<String,Object>();
            fieldsOfObject.put('Class_Type__c','P');
            fieldsOfObject.put('Remittance_Frequency__c', 'S');
            fieldsOfObject.put('Operation__c',operationCode.Id);

            newBSPattributeCode5d = TOSCAUTILS.angBSPAttributes(fieldsOfObject);
            insert newBSPattributeCode5d;
        }
    }




/****************************************************************************************************************************************************************
  
                                                            CREATE ACCOUNT
                                                                            
****************************************************************************************************************************************************************/ 
    public void createAccount(){//oscarAccounts
system.debug(LoggingLevel.ERROR, 'aqui selectedTest ' + selectedTest + ' parentAccount ' + parentAccount);
//system.debug(LoggingLevel.ERROR, 'aqui wrapperList ' + wrapperList.size());

        Id accountRT;

        if(selectedTest == TOSCAUTILS.NEW_AIRLINE_AIRCRAFT_OPERATOR || selectedTest == TOSCAUTILS.NEW_AIRLINE_MEMBER_STATE){
            accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Verifiers');
            givePermissions = true;
            isTocreateOscarCase = false;
        }
        else{
            accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
            givePermissions = false;
        }
        Id accountagency = AMS_Utils.RECTYPE_IATAAGENCY;
        parentAcc = new Account();      
        childAcc = new Account();

        Integer accNumberIncrement = 0;
        Integer toscaChild = 0;
        Integer hierarchySize;
        Account checkAccount = TOSCAUTILS.fetchToscaAccounts();

        if(checkAccount != null)        
            checkAccNr = checkAccount.Name.replaceAll('\\D+','');
            
        accNumberIncrement = Integer.valueOf(checkAccNr)+1;
        if(selectedTest != TOSCAUTILS.NEW_HE_CHILD_ACCOUNT){
            system.debug(LoggingLevel.ERROR, 'aqui dentro e não devia');

            fieldsOfObject = new Map<String,Object>();
            fieldsOfObject.put('Name','Tosca Account ' + accNumberIncrement);
            fieldsOfObject.put('Short_Name__c','ToscaAccount');                        
            fieldsOfObject.put('Remittance_frequency__c','M');
            fieldsOfObject.put('Reason_for_creation__c','Account is missing');                        
            fieldsOfObject.put('BillingCity','Tosca City');
            fieldsOfObject.put('BillingPostalCode','11111');        
            //fieldsOfObject.put('Type','IATA Passenger Sales Agent');
            fieldsOfObject.put('Is_PCI_compliant__c','Yes');       
            fieldsOfObject.put('Email__c','tosca@f3434.com');
            fieldsOfObject.put('Phone','123123123');

            if(isLimitedCompany == true)
                fieldsOfObject.put('Company_Type__c','L'); 

            if(selectedTest == TOSCAUTILS.NEW_HO_PASSENGER){
                fieldsOfObject.put('Category__c','Non-IATA Passenger Agent');
                fieldsOfObject.put('Sector__c','Travel Agent');
                fieldsOfObject.put('Location_Type__c','HO');
                fieldsOfObject.put('Location_Class__c','P');    
                fieldsOfObject.put('BillingCountry','Jamaica');
                fieldsOfObject.put('BillingStreet','Jamaica Street');  
               
                parentAcc = ANG_EntityCreator.createAccount(accountRT, country.Id, fieldsOfObject);
                insert parentAcc;                   
            }
            else if(selectedTest == TOSCAUTILS.NEW_HO_CARGO){
                fieldsOfObject.put('Sector__c','Cargo Agent');
                fieldsOfObject.put('Category__c','Non-IATA Cargo Agent');
                fieldsOfObject.put('Location_Type__c','HO');
                fieldsOfObject.put('Location_Class__c','C');
                fieldsOfObject.put('BillingCountry','Jamaica');
                fieldsOfObject.put('BillingStreet','Jamaica Street');

                parentAcc = ANG_EntityCreator.createAccount(accountRT, country.Id, fieldsOfObject);
                insert parentAcc;
            }
            else if(selectedTest == TOSCAUTILS.NEW_HO_TIDS){
                fieldsOfObject.put('Category__c','TIDS Agent');
                fieldsOfObject.put('Sector__c','Travel Agent');
                fieldsOfObject.put('Location_Type__c','HO');
                fieldsOfObject.put('Location_Class__c','T');
                fieldsOfObject.put('BillingCountry','Jamaica');
                fieldsOfObject.put('BillingStreet','Jamaica Street');
                parentAcc = ANG_EntityCreator.createAccount(accountRT, country.Id, fieldsOfObject);
                insert parentAcc;
            }
            else if(selectedTest == TOSCAUTILS.NEW_AIRLINE_AIRCRAFT_OPERATOR || selectedTest == TOSCAUTILS.NEW_AIRLINE_MEMBER_STATE){
                fieldsOfObject.put('Name','Tosca Account ' + accNumberIncrement);
                fieldsOfObject.put('BillingCity','Tosca City');
                fieldsOfObject.put('BillingStreet','Tosca Avenue');
                fieldsOfObject.put('BillingPostalCode','11111');
                fieldsOfObject.put('Sector__c','Airline');     
                fieldsOfObject.put('Email__c','tosca@f3434.com');
                fieldsOfObject.put('Phone','123123123');
                fieldsOfObject.put('fredp_aircraftoperator_eligibility__c',true);
                parentAcc = ANG_EntityCreator.createAccount(accountRT, country.Id, fieldsOfObject);
                insert parentAcc;

            }
            else{
                fieldsOfObject.put('Location_Class__c','P');
                fieldsOfObject.put('Company_Type__c','C');
                fieldsOfObject.put('Category__c','Non-IATA Passenger Agent');
                fieldsOfObject.put('Sector__c','Travel Agent');
                fieldsOfObject.put('Location_Type__c','HE');
                fieldsOfObject.put('BillingCountry','United Kingdom');
                fieldsOfObject.put('BillingStreet','Chelsea Street');

                parentAcc = ANG_EntityCreator.createAccount(accountRT, country.Id, fieldsOfObject);
                insert parentAcc; 
            }        
        }

        if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT && parentAccount != null){

            system.debug(LoggingLevel.ERROR,'aqui parentAccount ' + parentAccount);

            pAccount = TOSCAUTILS.fetchParentAccount(parentAccount);
            Account childAccount = TOSCAUTILS.fetchChildAccount();

            if(childAccount != null)        
                checkAccNr = childAccount.Name.replaceAll('\\D+','');

            accNumberIncrement = Integer.valueOf(checkAccNr)+1;
            system.debug(LoggingLevel.ERROR,'aqui pAccount ' + pAccount);
            system.debug(LoggingLevel.ERROR,'aqui accountRT ' + accountRT);
            system.debug(LoggingLevel.ERROR,'aqui country.Id ' + country.Id);

            fieldsOfObject = new Map<String,Object>();
            fieldsOfObject.put('ParentId',pAccount.Id);
            fieldsOfObject.put('Name','Tosca Child Account' + ' - ' + accNumberIncrement);
            fieldsOfObject.put('Location_Class__c',pAccount.Location_Class__c);                            
            fieldsOfObject.put('Sector__c',pAccount.sector__c);
            fieldsOfObject.put('Category__c','Non-IATA Passenger Agent');
            fieldsOfObject.put('Reason_for_creation__c','Account is missing');
            fieldsOfObject.put('Company_Type__c', pAccount.Company_Type__c);
            fieldsOfObject.put('Remittance_frequency__c','M');
            //fieldsOfObject.put('IATACode__c','100000');

            if(pAccount.Location_Type__c == 'HO'){
                fieldsOfObject.put('Location_Type__c','BR');
                fieldsOfObject.put('BillingCity','Tosca City');
                fieldsOfObject.put('BillingCountry','Jamaica');
                fieldsOfObject.put('BillingStreet','Jamaica Street');
                fieldsOfObject.put('BillingPostalCode','11111');
                fieldsOfObject.put('Email__c','tosca@f3434.com');
                fieldsOfObject.put('Phone','123123123');
                fieldsOfObject.put('Sector__c', pAccount.Sector__c);
                fieldsOfObject.put('Category__c', pAccount.Location_Class__c == 'C' ? 'Non-IATA Cargo Agent' : 'Non-IATA Passenger Agent');
                typeOfProcess = 'NEW.BR';
                isCargoChild = true;
            }
            else if(pAccount.Location_Type__c == 'BR'){
                fieldsOfObject.put('BillingCity','Tosca City');
                fieldsOfObject.put('BillingCountry','Jamaica');
                fieldsOfObject.put('BillingStreet','Jamaica Street');
                fieldsOfObject.put('BillingPostalCode','11111');
                fieldsOfObject.put('Location_Type__c','SA');
                fieldsOfObject.put('Email__c','tosca@f3434.com');
                fieldsOfObject.put('Phone','123123123');
                typeOfProcess = AMS_RecordCreatorWebservice.NEWSA_PV;
            }
            else{
                fieldsOfObject.put('BillingCity','Tosca City');
                fieldsOfObject.put('BillingCountry','United Kingdom');
                fieldsOfObject.put('BillingStreet','Chelsea Street');
                fieldsOfObject.put('BillingPostalCode','11111');
                fieldsOfObject.put('Email__c','tosca@f3434.com');
                fieldsOfObject.put('Phone','123123123');        
                fieldsOfObject.put('Location_Type__c','AE');
                typeOfProcess = AMS_RecordCreatorWebservice.NEWNAE;
            }

            system.debug(LoggingLevel.ERROR,'aqui getDMLRows ' + Limits.getDMLRows());

            if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT && (pAccount.Location_Type__c == 'BR' || pAccount.Location_Type__c == 'HO'))
                childAcc = ANG_EntityCreator.createAccount(accountagency, pAccount.IATA_ISO_Country__c, fieldsOfObject);
            else
                childAcc = ANG_EntityCreator.createAccount(accountagency, pAccount.IATA_ISO_Country__c, fieldsOfObject);
            insert childAcc;           
        }       
    }



/****************************************************************************************************************************************************************
  
                                                                        SEARCH ACCOUNT TO ADD RISK EVENT
                                                                        
                                                                        selected test = CREATE_RISK_EVENT

****************************************************************************************************************************************************************/ 

    public void checkRiskAccount(){
        if(parentAccount != null){
            parentAcc = new Account();
            parentAcc = TOSCAUTILS.fetchParentAccountById(parentAccount);
            system.debug(LoggingLevel.ERROR,'aqui parentAccount ' + parentAcc);
            firstOscar = false;
            updateRisk = false;
            showAccredit = false;
            showAccredit2 = false;
            showSidra = true;
            buildWrapperList();
        }
    }

/****************************************************************************************************************************************************************
  
                                                                        CREATE CONTACT
                                                                          Contact
  
****************************************************************************************************************************************************************/ 
    public void createContact(){
        
        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        contact = new Contact();
        String checkConNr = '0';
        Integer conNumberIncrem = 0;

        Contact checkContact = TOSCAUTILS.fetchToscaContacts();

        if(checkContact != null){
            checkConNr = checkContact.LastName.replaceAll('\\D+','');
            conNumberIncrem = integer.valueOf(checkConNr) +1; 
        }

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('FirstName', 'Tosca');
        fieldsOfObject.put('LastName', 'Contact' + conNumberIncrem);       
        fieldsOfObject.put('Phone', '9898989');
        fieldsOfObject.put('User_Portal_Status__c', 'Approved Admin');
        fieldsOfObject.put('Community__c', 'ISS Customer Portal');
        
        if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT){
            contact = ANG_EntityCreator.createContact(accountRT, childAcc.Id, fieldsOfObject);
        }
        else{
            contact = ANG_EntityCreator.createContact(accountRT, parentAcc.Id, fieldsOfObject);
        }       
        
        insert contact;
        system.debug(LoggingLevel.ERROR,'aqui getDMLRows 3 - ' + Limits.getDMLRows());
        //system.debug(LoggingLevel.ERROR,'aqui parent account location type 3 ' + pAccount.Location_Type__c);

    }

/****************************************************************************************************************************************************************
  
                                                                        CREATE PORTAL USER                                                                        
  
****************************************************************************************************************************************************************/ 
    public void createPortalUser(){
        Profile profile = [Select Name, Id From Profile where Name = 'ISS Portal Agency Delegated Admin User'];
        user = new User();

        system.debug('aqui contact.LastName ' + contact.LastName);
        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Email', usedEmail);
        fieldsOfObject.put('Emailencodingkey', 'UTF-8');
        fieldsOfObject.put('Alias', IECUserManager.createAliasFromName(contact.LastName));
        fieldsOfObject.put('FirstName', contact.FirstName);
        fieldsOfObject.put('LastName', contact.LastName);
        fieldsOfObject.put('LocaleSidKey', 'en_US');
        fieldsOfObject.put('CommunityNickname', contact.Name + IECUtil.NewGuid().substring(0, 8) + '@iata.org');
        fieldsOfObject.put('ProfileId', profile.Id);
        fieldsOfObject.put('LanguageLocaleKey', 'en_US');
        fieldsOfObject.put('Timezonesidkey', 'America/New_York');
        fieldsOfObject.put('ContactId', contact.Id);
        fieldsOfObject.put('IsActive', true);
        fieldsOfObject.put('ReceivesAdminInfoEmails', false);
        fieldsOfObject.put('ReceivesInfoEmails', false);
        System.debug('[createToscaData_V2]: Username = ' +contact.LastName + 'Test@tosca.com');
        fieldsOfObject.put('Username', contact.LastName + 'Test@tosca.com');

        user = TOSCAUTILS.createPortalUser(fieldsOfObject);
        insert user;
        system.debug(LoggingLevel.ERROR,'aqui getDMLRows 4 - ' + Limits.getDMLRows());
        System.setPassword(user.Id, TOSCAUTILS.PASSWORD);
    }

/****************************************************************************************************************************************************************
  
                                                                        ADD PORTAL SERVICE TO CONTACT
                                                                         Portal_Application_Right__c 
  
****************************************************************************************************************************************************************/ 
    public void addPortalService(){
        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Contact__c',contact.Id);
        fieldsOfObject.put('Right__c','Access Granted');
        fieldsOfObject.put('Portal_Application__c',portalApplications.Id);

        Portal_Application_Right__c applicationRight = TOSCAUTILS.createPortalApplicationRight(fieldsOfObject);
        insert applicationRight;

        system.debug(LoggingLevel.ERROR,'aqui getDMLRows 5 - ' + Limits.getDMLRows());

        if(selectedTest != TOSCAUTILS.NEW_HE_STANDARD)
            isTocreateOscarCase = true;
    }


/****************************************************************************************************************************************************************
  
                                                                        CREATE OSCAR
                                                                        AMS_OSCAR__c 
  
****************************************************************************************************************************************************************/ 
    public void createOscar(){
        ID oscarNewHeRt = AMS_Utils.RECTYPE_NEWHE;
        ID oscarNewAERt = AMS_Utils.RECTYPE_NEWAE;
        ID oscarNewRT = AMS_Utils.RECTYPE_NEW;

        oscar = new AMS_OSCAR__c();
        
        fieldsOfObject = new Map<String,Object>();
        if(selectedTest == TOSCAUTILS.NEW_HE_CASHLESS){
            fieldsOfObject.put('Process__c',AMS_Utils.NEWHELITE);    
        }
        else if(selectedTest == TOSCAUTILS.NEW_HE_CASH){
                fieldsOfObject.put('Process__c',AMS_Utils.NEWHESTANDARD);            
        }
        else if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT && pAccount.Location_Type__c == 'HO'){
                fieldsOfObject.put('Process__c',AMS_Utils.new_BR);
        }
        else if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT && pAccount.Location_Type__c == 'BR'){
                fieldsOfObject.put('Process__c',AMS_Utils.new_SA);
        }
        else if(selectedTest == TOSCAUTILS.NEW_HO_CARGO || selectedTest == TOSCAUTILS.NEW_HO_PASSENGER){
                fieldsOfObject.put('Process__c',AMS_Utils.new_HO);

        }else if(selectedTest == TOSCAUTILS.NEW_HO_TIDS){
                fieldsOfObject.put('Process__c',AMS_Utils.new_TIDS);
        }
        else{
             fieldsOfObject.put('Process__c',AMS_Utils.NEWAE);
        }
        
        fieldsOfObject.put('Is_using_credit_card__c',true); 
        /*fieldsOfObject.put('Status__c','Open');
        fieldsOfObject.put('STEP6__c','Passed');
        fieldsOfObject.put('Is_PCI_compliant__c','Yes');
        fieldsOfObject.put('Create_Agency_Authorization__c',true);       
        fieldsOfObject.put('Update_BSPLink__c',true);
        fieldsOfObject.put('STEP10__c','Passed');*/
        system.debug(LoggingLevel.ERROR,'aqui selectedTest ' + selectedTest);
        //system.debug(LoggingLevel.ERROR,'aqui pAccount.Location_Type__c ' + pAccount.Location_Type__c);  

        if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT && pAccount.Location_Type__c == 'HE'){
            fieldsOfObject.put('Account__c',childAcc.Id);
            oscar = ANG_EntityCreator.createOscar(oscarNewAERt,childAcc.Id,fieldsOfObject);
        }
        else if(selectedTest == TOSCAUTILS.NEW_HO_CARGO){
        system.debug(LoggingLevel.ERROR,'aqui fieldsOfObject createOs ' + selectedTest);            
            oscar = ANG_EntityCreator.createOscar(oscarNewRT,parentAcc.Id,fieldsOfObject);
        }
              
        else if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT && (pAccount.Location_Type__c == 'BR' ||pAccount.Location_Type__c == 'HO')){
            system.debug(LoggingLevel.ERROR,'aqui hey  childAcc ' + childAcc);
            oscar = ANG_EntityCreator.createOscar(oscarNewRT,childAcc.Id,fieldsOfObject);   
        }
        else{
            fieldsOfObject.put('Account__c',parentAcc.Id);
            oscar = ANG_EntityCreator.createOscar(oscarNewHeRt,parentAcc.Id,fieldsOfObject);    
        }
        
        insert oscar;
    }


/****************************************************************************************************************************************************************
  
                                                                CREATE OSCAR COMMUNICATION CASE 
                                                                            CASE 
  
****************************************************************************************************************************************************************/     
    public void createCaseOscarCommunication(){
        system.debug(LoggingLevel.ERROR,'aqui start OSCAR_Communication ' + selectedTest);

        Id caseRT = AMS_Utils.RECTYPE_OSCARCOMM;
        oscarCase = new Case();

        fieldsOfObject = new Map<String,Object>();
        if(selectedTest != TOSCAUTILS.NEW_HE_CHILD_ACCOUNT)
            fieldsOfObject.put('Oscar__c',oscar.Id);
        
        fieldsOfObject.put('ContactId',contact.Id);
         
        //fieldsOfObject.put('Subject','New Head Office - ' + 'Travel Agent - ' + country.Name);       
        fieldsOfObject.put('Origin','Portal');
        fieldsOfObject.put('CaseArea__c','Accreditation Process');
        fieldsOfObject.put('Region__c','Europe');
        fieldsOfObject.put('BSPCountry__c','United Kingdom');

        if(selectedTest == TOSCAUTILS.NEW_HE_CASHLESS){
            fieldsOfObject.put('Reason1__c','New HE lite');
            oscarCase = ANG_EntityCreator.createCase(caseRT, parentAcc.Id, fieldsOfObject);
        }
        else if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT && pAccount.Location_Type__c == 'HE'){
                fieldsOfObject.put('Reason1__c','New AE');
                oscarCase = ANG_EntityCreator.createCase(caseRT, childAcc.Id, fieldsOfObject);
        }
        else if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT && pAccount.Location_Type__c == 'HO'){
                fieldsOfObject.put('Region__c','Asia');
                fieldsOfObject.put('BSPCountry__c','Jamaica');
                fieldsOfObject.put('Reason1__c','New BR / IP');
                oscarCase = ANG_EntityCreator.createCase(caseRT, childAcc.Id, fieldsOfObject);
        }
        else if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT && pAccount.Location_Type__c == 'BR'){ //CREATE SA OSCAR CASE
                fieldsOfObject.put('Reason1__c','New SA / CHV – New Code');
                fieldsOfObject.put('Region__c','Asia');
                fieldsOfObject.put('BSPCountry__c','Jamaica');
                oscarCase = ANG_EntityCreator.createCase(caseRT, childAcc.Id, fieldsOfObject);
        }
        else if(selectedTest == TOSCAUTILS.NEW_HE_CASH || selectedTest == TOSCAUTILS.NEW_HE_CASHLESS ){
                fieldsOfObject.put('Reason1__c','New HE standard');
                oscarCase = ANG_EntityCreator.createCase(caseRT, parentAcc.Id, fieldsOfObject);  
        }
        else if(selectedTest == TOSCAUTILS.NEW_HO_CARGO){
                fieldsOfObject.put('Reason1__c','New HO');
                fieldsOfObject.put('Type_of_customer__c','Non-IATA Cargo Agent');
                fieldsOfObject.put('Region__c','Asia');
                fieldsOfObject.put('BSPCountry__c','Jamaica');
                oscarCase = ANG_EntityCreator.createCase(caseRT, parentAcc.Id, fieldsOfObject);  
        }
        else if(selectedTest == TOSCAUTILS.NEW_HO_PASSENGER){
                fieldsOfObject.put('Reason1__c','New HO');
                fieldsOfObject.put('Type_of_customer__c','Non-IATA Travel Agent');
                oscarCase = ANG_EntityCreator.createCase(caseRT, parentAcc.Id, fieldsOfObject); 
        }
        else if(selectedTest == TOSCAUTILS.NEW_HO_TIDS){
                fieldsOfObject.put('Reason1__c','New TIDS');
                fieldsOfObject.put('Type_of_customer__c','TIDS');
                fieldsOfObject.put('Region__c','Asia');
                fieldsOfObject.put('BSPCountry__c','Jamaica');
                oscarCase = ANG_EntityCreator.createCase(caseRT, parentAcc.Id, fieldsOfObject);
        }        

        insert oscarCase;

        Attachment attach = new Attachment();
        attach.Name = 'Tosca Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Tosca Attachment Body');
        attach.body=bodyBlob;
        attach.ParentId = oscarCase.Id;
        insert attach;

    }



/****************************************************************************************************************************************************************
  
                                                                CREATE ACCREDITATION FORM 
                                                              AMS_Pax_Accreditation_Form__c 
  
****************************************************************************************************************************************************************/     

    public void createAccreditationForm(){
        Id accreditationFormRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Head_Entity_Standard_with_Cash');
        Id accreditationFormAE = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Associate_Entity');
        Id accreditationFormBranch = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Branch');

        theAccreditation = new AMS_Pax_Accreditation_Form__c();
        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('ISSP_AMS_Legal_Status__c','Association');        
        fieldsOfObject.put('Branch_Office_Email__c','tosca@f3434.com');
        fieldsOfObject.put('Branch_Office_Phone__c','123123123');
        fieldsOfObject.put('ISSP_AMS_Premises_located_at_airport__c','No');
        fieldsOfObject.put('Abbreviated_name__c','tosca');
        fieldsOfObject.put('Abbreviated_Address__c','Tosca Street');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Solicitation_Flag__c',false);
        
        if(isLimitedCompany == true)
            fieldsOfObject.put('ISSP_AMS_Legal_Status__c','Limited Company');

        if(selectedTest == TOSCAUTILS.NEW_HO_CARGO)
            fieldsOfObject.put('CASS_Number__c','456');

        if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT  && pAccount.Location_Type__c == 'HE'){
            fieldsOfObject.put('Account_Name__c',childAcc.Name);
            fieldsOfObject.put('Location_Type__c','AE');
            fieldsOfObject.put('Remittance_frequency__c','M');
            fieldsOfObject.put('Branch_Office_Country__c', country.Id);
            fieldsOfObject.put('IATA_ISO_State__c',isoState.Id);
            fieldsOfObject.put('Branch_Office_Street_name_number__c','Branch Tosca Street');
            fieldsOfObject.put('Branch_Office_City__c','Tosca City');
            fieldsOfObject.put('Location_Class__c',childAcc.Location_Class__c);

            theAccreditation = ANG_EntityCreator.createStagingArea(accreditationFormAE, childAcc.Id, oscarCase.Id, fieldsOfObject);
        }
        else if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT && pAccount.Location_Type__c == 'HO'){
            fieldsOfObject.put('Account_Name__c',childAcc.Name);
            fieldsOfObject.put('Location_Type__c','BR');
            fieldsOfObject.put('Branch_Office_Country__c', country.Id);
            fieldsOfObject.put('IATA_ISO_State__c',isoState.Id);
            fieldsOfObject.put('Branch_Office_Country__c', country.Id);
            fieldsOfObject.put('Branch_Office_Street_name_number__c','Branch Tosca Street');
            fieldsOfObject.put('Branch_Office_City__c','Tosca City');
            fieldsOfObject.put('Location_Class__c',childAcc.Location_Class__c);

            if(pAccount.Location_Class__c == 'C' || pAccount.Location_Class__c == 'I' || pAccount.Location_Class__c == 'R' || pAccount.Location_Class__c == 'Q' || pAccount.Location_Class__c == 'G')
                fieldsOfObject.put('CASS_Number__c','456');
            
            theAccreditation = ANG_EntityCreator.createStagingArea(accreditationFormAE, childAcc.Id, oscarCase.Id, fieldsOfObject);
        }
        else if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT && pAccount.Location_Type__c == 'BR'){
            fieldsOfObject.put('Account_Name__c',childAcc.Name);
            fieldsOfObject.put('Location_Type__c','SA');
            fieldsOfObject.put('Branch_Office_Country__c', country.Id);
            fieldsOfObject.put('IATA_ISO_State__c',isoState.Id);
            fieldsOfObject.put('Remittance_frequency__c','M');
            fieldsOfObject.put('Branch_Office_Country__c', country.Id);
            fieldsOfObject.put('Branch_Office_Street_name_number__c','Jamaica Tosca Street');
            fieldsOfObject.put('Branch_Office_City__c','Jamaica City');
            fieldsOfObject.put('Location_Class__c',childAcc.Location_Class__c);

            if(pAccount.Location_Class__c == 'C' || pAccount.Location_Class__c == 'I' || pAccount.Location_Class__c == 'R' || pAccount.Location_Class__c == 'Q' || pAccount.Location_Class__c == 'G')
                fieldsOfObject.put('CASS_Number__c','456');
            
            theAccreditation = ANG_EntityCreator.createStagingArea(accreditationFormBranch, childAcc.Id, oscarCase.Id, fieldsOfObject);
        }

        else if(selectedTest == TOSCAUTILS.NEW_HE_CASH || selectedTest == TOSCAUTILS.NEW_HE_CASHLESS || selectedTest == TOSCAUTILS.NEW_HE_STANDARD){
            fieldsOfObject.put('Account_Name__c',parentAcc.Name);    
            fieldsOfObject.put('Location_Type__c','HE');
            fieldsOfObject.put('Remittance_frequency__c','M');
            fieldsOfObject.put('Branch_Office_Country__c', country.Id);
            fieldsOfObject.put('IATA_ISO_State__c',isoState.Id);
            fieldsOfObject.put('Branch_Office_Street_name_number__c','Branch Tosca Street');
            fieldsOfObject.put('Branch_Office_City__c','Tosca City');
            fieldsOfObject.put('Location_Class__c',parentAcc.Location_Class__c);
            
            theAccreditation = ANG_EntityCreator.createStagingArea(accreditationFormRT, parentAcc.Id, oscarCase.Id, fieldsOfObject);
        }
        else if(selectedTest == TOSCAUTILS.NEW_HO_CARGO || selectedTest == TOSCAUTILS.NEW_HO_PASSENGER || selectedTest == TOSCAUTILS.NEW_HO_TIDS){
            fieldsOfObject.put('Account_Name__c',parentAcc.Name);
            fieldsOfObject.put('Location_Type__c','HO');            
            fieldsOfObject.put('Remittance_frequency__c','M');
            fieldsOfObject.put('Branch_Office_Country__c', country.Id);
            fieldsOfObject.put('IATA_ISO_State__c',isoState.Id);
            fieldsOfObject.put('Branch_Office_Street_name_number__c','Branch Tosca Street');
            fieldsOfObject.put('Branch_Office_City__c','Tosca City');
            fieldsOfObject.put('Location_Class__c',parentAcc.Location_Class__c);
            
            if(selectedTest == TOSCAUTILS.NEW_HO_CARGO)
                fieldsOfObject.put('CASS_Number__c','123');
                
            theAccreditation = ANG_EntityCreator.createStagingArea(accreditationFormRT, parentAcc.Id, oscarCase.Id, fieldsOfObject);
            System.debug('[THE ACCREDITATION] - '+theAccreditation);
        }
            
        //theAccreditation = ANG_EntityCreator.createStagingArea(accreditationFormRT, parentAcc.Id, oscarCase.Id, fieldsOfObject);
        insert theAccreditation;
    }


/****************************************************************************************************************************************************************
  
                                                             CREATE ACCREDITATION CONTACT   
                                                              AMS_Accreditation_Contact__c 
  
****************************************************************************************************************************************************************/ 

    public void createAccreditationContact(){
        Id personRT = AMS_Utils.AccreditationContactPersonRT;
        Id trainedStaffRT = AMS_Utils.AccreditationContactTrainedStaffRT;

        accreditationContact = new AMS_Accreditation_Contact__c();
        String checkAccConNr = '0';
        Integer conNumberIncrem = 0;

        AMS_Accreditation_Contact__c checkAccredContact = TOSCAUTILS.fetchAccreditationContact();

        if(checkAccredContact != null){
            checkAccConNr = checkAccredContact.Last_name__c.replaceAll('\\D+','');
            conNumberIncrem = integer.valueOf(checkAccConNr) +1; 
        }

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('First_name__c','Tosca');
        fieldsOfObject.put('Last_name__c','Accreditation Contact ' + conNumberIncrem);
        fieldsOfObject.put('Agency_owner__c',true);
        fieldsOfObject.put('Email__c',usedEmail);
        fieldsOfObject.put('PhoneNational__c','123123123');
        fieldsOfObject.put('Phone__c','123123123');
        fieldsOfObject.put('Financial_interest__c',100);
        fieldsOfObject.put('Contact__c',contact.Id);

        AMS_Accreditation_Contact__c acontact = ANG_EntityCreator.createAccreditationContact(personRT, theAccreditation.Id, fieldsOfObject);
        insert acontact;

        if(selectedTest == TOSCAUTILS.NEW_HO_CARGO || isCargoChild == true){
            for (Integer i = 0, j = 0; i < 2; i++){
                fieldsOfObject = new Map<String,Object>();
                fieldsOfObject.put('First_name__c','Tosca DGR');
                fieldsOfObject.put('Last_name__c','Accreditation Contact ' + conNumberIncrem);
                fieldsOfObject.put('Training_dangerous_goods_completed__c','No'); 
                fieldsOfObject.put('Valid_until__c',system.today()+100); // the +100 as a result of AMSU-34
                fieldsOfObject.put('AMS_Pax_Accreditation_Form__c',theAccreditation.Id);
                fieldsOfObject.put('Type_Of_Certificate__c','DGR');

                AMS_Accreditation_Contact__c staffContact = ANG_EntityCreator.createAccreditationContact(trainedStaffRT, theAccreditation.Id, fieldsOfObject);
                insert staffContact;

            } 
            
        }

        fieldsOfObject = new Map<String,String>();
        fieldsOfObject.put('AMS_Online_Accreditation__c',theAccreditation.Id);
        
        if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT)
            oscar = TOSCAUTILS.fetchOscar(childAcc.Id);
        oscar = ANG_EntityCreator.updateOscar(oscar,fieldsOfObject);
        update oscar;
    }


/****************************************************************************************************************************************************************
  
                                                             CREATE OSCAR
  
****************************************************************************************************************************************************************/

    public void createOscarCase(){
            fromCreateOscarBtn = true;

             if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT){
                createCaseOscarCommunication();
                createAccreditationForm();
                //createAccreditationContact();
           }else {
                createOscar();
                createCaseOscarCommunication();
                createAccreditationForm();
                createAccreditationContact();
           }
            
            if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT){
                AMS_RecordCreatorWebservice.createAccreditation(childAcc.Id,theAccreditation.Id,typeOfProcess,oscarCase.Id);
                createAccreditationContact();
            }

            buildWrapperList();
            firstOscar = true;
    }

/****************************************************************************************************************************************************************
  
                                                             APPLICATION RECEIPT 
  
****************************************************************************************************************************************************************/
    
    public void appReceipt(){
        system.debug(LoggingLevel.ERROR,'### start performSanityCheck');
        Integer conNumberIncrem = 0;
        Id trainedStaffRT = AMS_Utils.AccreditationContactTrainedStaffRT;
        
        fieldsOfObject = new Map<String,Object>();

        fieldsOfObject.put('Is_using_credit_card__c',true); 
        fieldsOfObject.put('Status__c','Open');
        fieldsOfObject.put('STEP6__c','Passed');        
        fieldsOfObject.put('Create_Agency_Authorization__c',true);       
        fieldsOfObject.put('Update_BSPLink__c',true);        
		fieldsOfObject.put('Payment_requested__c',SYSTEM.TODAY());
		fieldsOfObject.put('Bank_Guarantee_requested__c',SYSTEM.TODAY());

        if(selectedTest != TOSCAUTILS.NEW_HO_CARGO && (selectedTest != TOSCAUTILS.NEW_HE_CHILD_ACCOUNT || pAccount.Location_Type__c == 'HE')){// && (pAccount.Location_Type__c == 'HO' || pAccount.Location_Type__c == 'BR')){
            system.debug(LoggingLevel.ERROR,'aqui selectedTest ' + selectedTest);
            fieldsOfObject.put('Is_PCI_compliant__c','Yes');
            fieldsOfObject.put('ANG_PCI_compliance_expiry_date__c',date.today()+1);
        }  

        if(selectedTest == TOSCAUTILS.NEW_HO_CARGO || selectedTest == TOSCAUTILS.NEW_HO_PASSENGER ||(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT && (pAccount.Location_Type__c == 'HO' || pAccount.Location_Type__c == 'BR'))){
            fieldsOfObject.put('STEP12__c','Passed');
            fieldsOfObject.put('STEP13__c','Passed');
        }
        
        if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT)
            oscar = TOSCAUTILS.fetchOscar(childAcc.Id);

        oscar = ANG_EntityCreator.updateOscar(oscar,fieldsOfObject);        
        update oscar;

        if(selectedTest == TOSCAUTILS.NEW_HO_CARGO){
            for (Integer i = 0, j = 0; i < 2; i++){
                fieldsOfObject = new Map<String,Object>();
                fieldsOfObject.put('First_name__c','Tosca DGR');
                fieldsOfObject.put('Last_name__c','Accreditation Contact ' + conNumberIncrem);
                fieldsOfObject.put('Training_dangerous_goods_completed__c','No'); 
                fieldsOfObject.put('Valid_until__c',system.today());
                fieldsOfObject.put('AMS_Pax_Accreditation_Form__c',theAccreditation.Id);
                fieldsOfObject.put('Type_Of_Certificate__c','DGR');

                AMS_Accreditation_Contact__c staffContact = ANG_EntityCreator.createAccreditationContact(trainedStaffRT, theAccreditation.Id, fieldsOfObject);
                insert staffContact;
            }             
        }

        firstOscar = false;
        iataCode = true;
        buildWrapperList();
    }


/****************************************************************************************************************************************************************
  
                                                             GENERATE IATA CODE
  
****************************************************************************************************************************************************************/

    public void generateIATACode(){
        String[] result;        

        if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT){
            result = ANG_OscarProcessHelper.processIATACodeGeneration(childAcc.Id,theAccreditation.Id,oscar.Id);            
            childAcc.IATACode__c =  TOSCAUTILS.fetchParentAccountById(childAcc.Id).IATACode__c;
        }else{
            
            result = ANG_OscarProcessHelper.processIATACodeGeneration(parentAcc.Id,theAccreditation.Id,oscar.Id);            
            parentAcc.IATACode__c =  TOSCAUTILS.fetchParentAccountById(parentAcc.Id).IATACode__c;             
        }
    
        iataCode = false;

        if(selectedTest == TOSCAUTILS.NEW_HO_TIDS){            
            agencyFees = true;
        }else{
            dueDeligence = true;
        }
            
        buildWrapperList();
    }

/****************************************************************************************************************************************************************
  
                                                             DUE DELIGENCE
  
****************************************************************************************************************************************************************/

    public void dueDeligence(){
        String result;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('STEP17__c','Passed');
        String oscarid = oscar.Id;
        result = AMS_OSCAR_Webservice.createAMLCase(oscarid);

        oscar = ANG_EntityCreator.updateOscar(oscar,fieldsOfObject);  

        /*
         * This update to the account's Due Diligence is happening in order to reverse the status from 'In Progress' to empty.
         * The reason for this change is because it was blocking something on the testers side. The possibilities were, to eliminate the
         * Due Diligence step or re-update the account due diligence status to empty. 
         * Start 
         */
        update new Account(Id = oscar.Account__c, Due_Diligence_Status__c = '');      
        /*End*/
        update oscar;

        dueDeligence = false;
        agencyFees = true;
        buildWrapperList();
    }

/****************************************************************************************************************************************************************
  
                                                             AGENCY FEES
  
****************************************************************************************************************************************************************/

    public void agencyFees(){
        system.debug('## starting agencyFees...');
        String[] result;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('STEP8__c','Passed');
        fieldsOfObject.put('STEP9__c','Passed');
        fieldsOfObject.put('Agreement_requested__c',SYSTEM.TODAY());
        
        if(selectedTest == TOSCAUTILS.NEW_HE_CASH || selectedTest == TOSCAUTILS.NEW_HE_CASHLESS)
            fieldsOfObject.put('STEP14__c','Passed');        

        oscar = ANG_EntityCreator.updateOscar(oscar,fieldsOfObject);        
        update oscar;

        agencyFees = false;
        if(selectedTest != TOSCAUTILS.NEW_HO_TIDS)
            appProcessing = true;

        if(selectedTest == TOSCAUTILS.NEW_HO_TIDS)
            appFinalization = true;

        buildWrapperList();
        system.debug('## finishing agencyFees...');
    }

/****************************************************************************************************************************************************************
  
                                                             APPLICATION PROCESSING
  
****************************************************************************************************************************************************************/
    public void appProcessing(){
        
        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('STEP11__c','Passed');
        fieldsOfObject.put('Send_FS_request__c',true);
        fieldsOfObject.put('STEP34__c','Passed'); 
        fieldsOfObject.put('Received_Bank_Guarantee_amount__c',5000);
        fieldsOfObject.put('Received_Bank_Guarantee_currency__c','EUR');
        fieldsOfObject.put('Requested_Bank_Guarantee_amount__c',5000);
        fieldsOfObject.put('Requested_Bank_Guarantee_currency__c','EUR');
        fieldsOfObject.put('Disapproval_date__c',SYSTEM.TODAY());
		fieldsOfObject.put('Oscar_Communication_Case_Id__c', oscarCase.Id);
        fieldsOfObject.put('STEP35__c','Passed');
                        

        oscar = ANG_EntityCreator.updateOscar(oscar,fieldsOfObject);        
        update oscar;

        appProcessing = false;
        validation = true;
        buildWrapperList();
    }

/****************************************************************************************************************************************************************
  
                                                             APPLICATION FINALIZATION
  
****************************************************************************************************************************************************************/
    public void appFinalization(){
        
        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Update_Portal_Setup__c',true);
        fieldsOfObject.put('Send_approval_letter__c',true);
        fieldsOfObject.put('Change_effective_as_of__c',date.today()+1); 
        fieldsOfObject.put('STEP1__c', 'Passed');
               
                        

        oscar = ANG_EntityCreator.updateOscar(oscar,fieldsOfObject);        
        update oscar;

        appFinalization = false;
        validation = true;
        buildWrapperList();
    }

/****************************************************************************************************************************************************************

                                                                 VALIDATION

****************************************************************************************************************************************************************/  

    public void validation(){
        String[] result;

        fieldsOfObject = new Map<String,Object>();

        fieldsOfObject.put('ANG_HE_RiskHistoryAssessment__c','Failed');
        if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT)
            childAcc = TOSCAUTILS.fetchParentAccount(childAcc.IATACode__c);
        else
            parentAcc = TOSCAUTILS.fetchParentAccount(parentAcc.IATACode__c);

        if(selectedTest == TOSCAUTILS.NEW_HE_CASHLESS || selectedTest == TOSCAUTILS.NEW_HE_CASHLESS_WITH_HIERARCHY){
            fieldsOfObject.put('ANG_Accreditation_Model__c','Cashless');            
            fieldsOfObject.put('ANG_HE_RiskHistoryAssessment__c','Not Applicable');         
        }else{
            fieldsOfObject.put('ANG_Accreditation_Model__c','Cash');                                                
        }
        if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT){
            childAcc = ANG_EntityCreator.updateAccount(childAcc, fieldsOfObject);
            update childAcc;
        }else{
            system.debug(LoggingLevel.ERROR,'aqui updating parentACC....' + fieldsOfObject);
            parentAcc = ANG_EntityCreator.updateAccount(parentAcc, fieldsOfObject);
            update parentAcc;
        }

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Financial_Assessment_Contact__c', true);
        fieldsOfObject.put('Authorized_Signatory__c', true);
        
        if(selectedTest == TOSCAUTILS.NEW_HE_CASHLESS)
            fieldsOfObject.put('Financial_Assessment_Contact__c', false);

        contact = ANG_EntityCreator.updateContact(contact, fieldsOfObject);
        //update contact;
        
        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Validation_Status__c','Passed');
        fieldsOfObject.put('STEP15__c','Passed');
        fieldsOfObject.put('STEP2__c','Passed');
        fieldsOfObject.put('RPM_Approval__c','Authorize Approval');     

        oscar = ANG_EntityCreator.updateOscar(oscar,fieldsOfObject);        
        update oscar;

        accreditp2 = true;
        createRiskEvent();
        validation = false;
        showSidra = true;
        updateRisk = false;

        buildWrapperList();
    }

/****************************************************************************************************************************************************************

                                                            CREATE RISK EVENT 
                                                          ANG_Risk_Event_Type__c       
    
****************************************************************************************************************************************************************/  
    public void createRiskEvent(){
system.debug(LoggingLevel.ERROR,'aqui createRiskEvent ' + selectedTest);
        riskevent = new ANG_Agency_Risk_Event__c();
        List<ANG_Risk_Event_Type__c> rType = new List<ANG_Risk_Event_Type__c>([SELECT id FROM ANG_Risk_Event_Type__c where NAME = 'Auth. Cash Payment' limit 1]);
        List<ANG_Risk_Event_Type__c> rTypeFail = new List<ANG_Risk_Event_Type__c>([SELECT id FROM ANG_Risk_Event_Type__c where NAME = 'Fail Financial Security' limit 1]);
        List<ANG_Risk_Event_Type__c> rTypeLateShort = new List<ANG_Risk_Event_Type__c>([SELECT id FROM ANG_Risk_Event_Type__c where NAME = 'Late/Short payment' limit 1]);
        
        if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT)
            parentAcc = TOSCAUTILS.fetchParentAccount(parentAccount);

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('ANG_AccountId__c',parentAcc.Id);
        fieldsOfObject.put('ANG_HE_AccountId__c',parentAcc.Id); 
        fieldsOfObject.put('ANG_Issued_Date__c',System.today());
        fieldsOfObject.put('ANG_Event_Status__c','Active');        
        fieldsOfObject.put('ANG_Created_from__c','toscapage');
        //fieldsOfObject.put('ANG_Risk_Type__c',rType[0].Id);

        if(accreditp2 == true){
            fieldsOfObject.put('ANG_Risk_Type__c',rType[0].Id);
            fieldsOfObject.put('ANG_CaseId__c',oscarCase.Id);
        }else{
            fieldsOfObject.put('ANG_CaseId__c',sidraCase.Id);
        }

        if(sidraChoosed == TOSCAUTILS.NEW_RISK_STATUS_B_PASSED)
            fieldsOfObject.put('ANG_Risk_Type__c',rTypeLateShort[0].Id);

        if(sidraChoosed == TOSCAUTILS.NEW_RISK_STATUS_B_PASSED_FAIL_FSECURITY)        
           fieldsOfObject.put('ANG_Risk_Type__c',rTypeFail[0].Id);
           fieldsOfObject.put('ANG_Issued_Date__c',System.today());
    
system.debug(LoggingLevel.ERROR,'aqui insert risk event');
        riskevent = TOSCAUTILS.agRiskEvent(fieldsOfObject);
        insert riskevent;

        if(selectedTest == TOSCAUTILS.NEW_RISK_STATUS_B_PASSED){
            fieldsOfObject = new Map<String,String>();
            fieldsOfObject.put('Financial_Review_Result__c','Unsatisfactory - No action');

            parentAcc = ANG_EntityCreator.updateAccount(parentAcc,fieldsOfObject);

            update parentAcc;
        }
    }


/****************************************************************************************************************************************************************

                                                            CREATE SIDRA B PASSED - FAIL SECURITRY
    
****************************************************************************************************************************************************************/  

     public void createSidraBPassedFailSec(){
        accreditp2 = false;
        sidraChoosed = TOSCAUTILS.NEW_RISK_STATUS_B_PASSED_FAIL_FSECURITY;        
        createSidraCase();
        createRiskEvent();
        fromSidraLikeRB = true;        
        buildWrapperList();
        showSidra = false;
        updateRisk = true;
    }

/***************************************************************************************************************************************************************

                                                            CREATE SIDRA LITE COMMON OWNERSHIP
    
****************************************************************************************************************************************************************/ 

    public void createSidraCommonOwnership(){
        sidraChoosed = TOSCAUTILS.NEW_RISK_SIDRA_LITE_CASE_RISK_B_COMMON_OWNERSHIP;
        createSidraCase();
        fromSidraLikeRB = true;
        buildWrapperList();
    }

/***************************************************************************************************************************************************************

                                                                CREATE SIDRA B PASSED

****************************************************************************************************************************************************************/

    public void createSidraBPassed(){
        sidraChoosed = TOSCAUTILS.NEW_RISK_STATUS_B_PASSED;
        createSidraCase();        
        fromSidra = true;
        buildWrapperList();
        showSidra = false;
        updateRisk = true;
    }

/***************************************************************************************************************************************************************

                                                                CREATE RISK STATUS A - PASSED

****************************************************************************************************************************************************************/

    public void createRiskStatusAPassed(){
        sidraChoosed = TOSCAUTILS.NEW_RISK_STATUS_A_PASSED;
        updateRiskProcess();
        showSidra = false;
    }

/****************************************************************************************************************************************************************

                                                            UPDATE ACCOUNT      ( Last Financial Review Result )
                                                            UPDATE RISK EVENT   ( Inactive_Revoke - Auth. Cash Payment)

****************************************************************************************************************************************************************/  

    public void updateRiskProcess(){

        ANG_Agency_Risk_Event__c fetchriskEvent = TOSCAUTILS.fetchRiskEvent(parentAcc.Id);
        system.debug(LoggingLevel.ERROR,'aqui fetchriskEvent ' + fetchriskEvent);

        fieldsOfObject = new Map<String,Object>();

        //Set data to RISK STATUS A - PASSED
        if(sidraChoosed == TOSCAUTILS.NEW_RISK_STATUS_A_PASSED){
            fieldsOfObject.put('ANG_Event_Status__c','Inactive_Withdrawn');
            fetchriskEvent = TOSCAUTILS.updateRiskEvent(fetchriskEvent,fieldsOfObject);
            update fetchriskEvent;
        }
        else{
            fieldsOfObject.put('ANG_Event_Status__c','Inactive_Revoked');

            fetchriskEvent = TOSCAUTILS.updateRiskEvent(fetchriskEvent,fieldsOfObject);
            update fetchriskEvent;

            fieldsOfObject = new Map<String,Object>();
            fieldsOfObject.put('Financial_Review_Result__c','Unsatisfactory - New Financial Security');

            parentAcc = parentAcc = ANG_EntityCreator.updateAccount(parentAcc,fieldsOfObject);
            update parentAcc;

            update fetchriskEvent;
            updateRisk = false;
       }

    }

/***************************************************************************************************************************************************************

                                                                CREATE SIDRA CASE
                                                                      Case

****************************************************************************************************************************************************************/
    public void createSidraCase(){  
        system.debug(LoggingLevel.ERROR,'aqui createSidraCase...' + selectedTest + ' sidraChoosed ' + sidraChoosed);
        sidraCase = new Case();
        Id caseRtSIdra = AMS_Utils.RECTYPE_SIDRA;
        Id caseRtSIdraLite = AMS_Utils.RECTYPE_SIDRALITE;
        Account checkAccount = TOSCAUTILS.fetchParentAccount(parentAcc.IATACode__c);

        system.debug('aqui checkAccount ' + checkAccount);
        Contact checkContact = TOSCAUTILS.fetchToscaContacts();
        User user =[SELECT id, ContactId FROM User where ContactId = :checkContact.Id];

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Subject', 'Tosca Subject');
        fieldsOfObject.put('AccountId', checkAccount.Id);
        fieldsOfObject.put('ContactId', checkContact.Id);
        fieldsOfObject.put('Region__c', 'Europe');
        //fieldsOfObject.put('Update_AIMS_REI_DEFWITH__c', System.today());
        //fieldsOfObject.put('Update_AIMS_DEF__c', System.today());
        fieldsOfObject.put('CS_Rep_Acc_REI__c', user.Id);

        if(sidraChoosed == TOSCAUTILS.NEW_HE_CASH || sidraChoosed == TOSCAUTILS.NEW_HE_CASHLESS){
            fieldsOfObject.put('RecordTypeId', caseRtSIdra);
            fieldsOfObject.put('Reason_for_Default__c', 'Common Ownership'); 
            fieldsOfObject.put('REI_ApprovalRejectin__c', 'Approved'); 
            fieldsOfObject.put('IRR_Approval_Rejection__c','Approved');
            fieldsOfObject.put('Update_AIMS_IRR__c',System.today());
            fieldsOfObject.put('End_of_Grace_Period_Date__c',System.today() + 5);
            //fieldsOfObject.put('Type_of_REI_WD__c', 'DEF/SUS REI');
            //fieldsOfObject.put('Reason_of_REI_WD__c', 'Commissioner decision');

        }else if(sidraChoosed == TOSCAUTILS.NEW_RISK_SIDRA_LITE_CASE_RISK_B_COMMON_OWNERSHIP){ 
                fieldsOfObject.put('RecordTypeId', caseRtSIdraLite);
                fieldsOfObject.put('Reason_for_Default__c', 'Common Ownership'); 
                fieldsOfObject.put('REI_ApprovalRejectin__c', 'Approved');                 
                fieldsOfObject.put('Update_AIMS_DEF__c',System.today());
                fieldsOfObject.put('Type_of_REI_WD__c', 'DEF/SUS REI'); 
                fieldsOfObject.put('Reason_of_REI_WD__c', 'Commissioner decision');

        }else if(sidraChoosed == TOSCAUTILS.NEW_RISK_STATUS_B_PASSED_FAIL_FSECURITY){
                fieldsOfObject.put('RecordTypeId', caseRtSIdraLite); 
                fieldsOfObject.put('SIDRA_Lite_Reason__c', 'Prejudiced Collection of Funds');
                //fieldsOfObject.put('Update_AIMS_DEF__c',System.today());
     
        
        }else if(sidraChoosed == TOSCAUTILS.NEW_RISK_STATUS_B_PASSED){ 
                fieldsOfObject.put('RecordTypeId', caseRtSIdra);
                fieldsOfObject.put('REI_ApprovalRejectin__c', 'Approved');
        }

        sidraCase = TOSCAUTILS.createSidraCase(fieldsOfObject);
        system.debug(LoggingLevel.ERROR,'aqui insert sidra...' + sidraCase);
        insert sidraCase;

        /*if(sidraChoosed == TOSCAUTILS.NEW_RISK_STATUS_B_PASSED_FAIL_FSECURITY)
            updateRiskProcess();*/
    }


/***************************************************************************************************************************************************************

                                                                BUILD WRAPPER LIST

                                                        table where the created data appear

****************************************************************************************************************************************************************/
    public void buildWrapperList(){        
        
        wrapperList = new List<toscaWrapper>();

        if(parentAcc != null && selectedTest != TOSCAUTILS.CREATE_RISK_EVENT && selectedTest != TOSCAUTILS.NEW_HE_CHILD_ACCOUNT && selectedTest != TOSCAUTILS.NEW_HO_PASSENGER && selectedTest != TOSCAUTILS.NEW_HE_STANDARD && selectedTest != TOSCAUTILS.NEW_HO_CARGO && selectedTest != TOSCAUTILS.NEW_HO_TIDS && selectedTest != TOSCAUTILS.NEW_AIRLINE_AIRCRAFT_OPERATOR && selectedTest != TOSCAUTILS.NEW_AIRLINE_MEMBER_STATE){                
            
            username = user.Email;
            username = username.replace('@','.');
            //Case caseToShow = TOSCAUTILS.fecthCommunicationCase(oscarCase.Id);
            
            if(selectedTest == TOSCAUTILS.NEW_HE_CASH || selectedTest == TOSCAUTILS.NEW_HE_CASHLESS ){                    
                wrapperList.add(new toscaWrapper(parentAcc.Name,country.Name,parentAcc.IATACode__c, username+'@partner.iata.org',TOSCAUTILS.PASSWORD,null,null));
                //wrapperList.add(new toscaWrapper(null, null, null, null, null,'Oscar Communication - ' + caseToShow.CaseNumber));  
            }                  
            else{
                wrapperList.add(new toscaWrapper(childAcc.Name,country.Name, childAcc.IATACode__c, username+'@partner.iata.org',TOSCAUTILS.PASSWORD,null,null));                    
            }            
        }

        if(selectedTest == TOSCAUTILS.NEW_HO_PASSENGER || selectedTest == TOSCAUTILS.NEW_HE_STANDARD || selectedTest == TOSCAUTILS.NEW_HO_CARGO || selectedTest == TOSCAUTILS.NEW_HO_TIDS || selectedTest == TOSCAUTILS.NEW_HO_TIDS){
            username = user.Email;
            username = username.replace('@','.');
            wrapperList.add(new toscaWrapper(parentAcc.Name,country.Name, parentAcc.IATACode__c, username+'@partner.iata.org',TOSCAUTILS.PASSWORD,null,null));            
        } 

        if(parentAcc != null && selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT){
            //Case caseToShow = TOSCAUTILS.fecthCommunicationCase(oscarCase.Id);
            username = user.Email;
            username = username.replace('@','.');
            wrapperList.add(new toscaWrapper(childAcc.Name,country.Name, childAcc.IATACode__c, username+'@partner.iata.org',TOSCAUTILS.PASSWORD,null,null));
            //wrapperList.add(new toscaWrapper(null, null,2 null, null, null,'Oscar Communication - ' + caseToShow.CaseNumber));                    
        }
        
        if(fromSidra == true){
            Case sidraToShow = TOSCAUTILS.fecthCommunicationCase(sidraCase.Id);
            system.debug(LoggingLevel.ERROR,'aqui oscarCase ' + sidraToShow);
            wrapperList.add(new toscaWrapper(null,null, null, null, null, null,'Sidra - ' + sidraToShow.CaseNumber));
        }

        if(fromSidraLikeRB == true){
            Case sidraToShow = TOSCAUTILS.fecthCommunicationCase(sidraCase.Id);
            system.debug(LoggingLevel.ERROR,'aqui oscarCase ' + sidraToShow);
            wrapperList.add(new toscaWrapper(null,null, null, null, null, null,'Sidra Lite - ' + sidraToShow.CaseNumber));
        }

        if(fromCreateOscarBtn == true){
            Case caseToShow = TOSCAUTILS.fecthCommunicationCase(oscarCase.Id);
            system.debug(LoggingLevel.ERROR,'aqui oscarCase ' + caseToShow);
            wrapperList.add(new toscaWrapper(null, null,null, null, null, null,'Oscar Communication - ' + caseToShow.CaseNumber));

            isTocreateOscarCase = false;
        }

        if(selectedTest == TOSCAUTILS.CREATE_RISK_EVENT){
            System.debug('[createToscaData] country = '+ country);
            System.debug('[createToscaData] parentAcc = '+ parentAcc);
            wrapperList.add(new toscaWrapper(parentAcc.Name,country.Name, parentAcc.IATACode__c, null,null,null,null));
        }

        if(selectedTest == TOSCAUTILS.NEW_AIRLINE_AIRCRAFT_OPERATOR || selectedTest == TOSCAUTILS.NEW_AIRLINE_MEMBER_STATE){
            username = user.Email;
            username = username.replace('@','.');
            wrapperList.add(new toscaWrapper(parentAcc.Name,country.Name, null, username+'@partner.iata.org', TOSCAUTILS.PASSWORD,null,null));
        }        
    }

    public class toscaWrapper{

        public String accName {get;set;}
        public String iataCode {get;set;}
        public String portalUsername {get;set;}
        public String portalPassword {get;set;}
        public String testSelected {get;set;}
        public String caseNumber {get;set;}
        public String newCase {get;set;}
        public String country {get;set;}        

        public toscaWrapper(String accName, String country, String iataCode, String portalUsername, String portalPassword, String caseNumber, String newCase){
            this.accName = accName;
            this.country = country;
            this.iataCode = iataCode;
            this.portalUsername = portalUsername;
            this.portalPassword = portalPassword;
            this.newCase = newCase;
        }
    }

/***************************************************************************************************************************************************************

                                                                rOPTIONS
    
****************************************************************************************************************************************************************/

    public List<SelectOption> getROptions(){

        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectOption('--None--','--None--'));

        if(selectedTest == null)
            return options;

        if(selectedTest.contains('HE')) {
            for(IATA_ISO_Country__c isoC : [select Id,name from IATA_ISO_Country__c WHERE ANG_Enable_NewGen__c = true ORDER BY Name]){
                options.add(new selectOption(isoC.name,isoC.name));
            }
        } else if(selectedTest.contains(TOSCAUTILS.NEW_HE_CHILD_ACCOUNT)){

            for(IATA_ISO_Country__c isoC : [select Id,name from IATA_ISO_Country__c ORDER BY Name]){
                options.add(new selectOption(isoC.name,isoC.name));
            }
        }else{

            for(IATA_ISO_Country__c isoC : [select Id,name from IATA_ISO_Country__c WHERE ANG_Enable_NewGen__c = false ORDER BY Name]){
                options.add(new selectOption(isoC.name,isoC.name));
            }
        }
        return options;
    }

/***************************************************************************************************************************************************************

                                                                INACTIVATE TOSCA USERS
    
****************************************************************************************************************************************************************/
    public pageReference deleteToscaUsers(){
        List<User> u = new List<User>([SELECT id, Email,IsActive, Name, Username from user where Name like 'Tosca%' and IsActive = true]);
        List<User> tou = new List<User>();

        if(u.size() > 0){
            for(User us : u){
                us.IsActive = false;
                //us.Username = us.Username + 'Inactivate';
                tou.add(us);
            }   
            update tou;
        }else{
            system.debug('aqui message ' + u.size());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No user to Inactivate'));

        }        

        return null;
    }

/***************************************************************************************************************************************************************

                                                                    DOWNLOAD PDF
    
****************************************************************************************************************************************************************/

   public String downloadPdf(){
        Document doc = [SELECT Id, Name, body, Description FROM Document WHERE Name = 'Tosca Document' limit 1];

        strDocURL = '/servlet/servlet.FileDownload?file='+doc.Id;
        return strDocURL;
        
    }

/***************************************************************************************************************************************************************

                                                                    PICKLIST SELECTION
    
****************************************************************************************************************************************************************/

    public List<SelectOption> getTestSelection(){
        
        List<SelectOption> testSelection = new List<SelectOption>();
        testSelection.add(new SelectOption('','-- None --'));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_HE_CASH,TOSCAUTILS.NEW_HE_CASH));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_HE_CASHLESS,TOSCAUTILS.NEW_HE_CASHLESS));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_HE_CHILD_ACCOUNT,TOSCAUTILS.NEW_HE_CHILD_ACCOUNT));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_HE_STANDARD,TOSCAUTILS.NEW_HE_STANDARD));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_HO_PASSENGER,TOSCAUTILS.NEW_HO_PASSENGER));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_HO_CARGO,TOSCAUTILS.NEW_HO_CARGO));        
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_HO_TIDS,TOSCAUTILS.NEW_HO_TIDS));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_AIRLINE_AIRCRAFT_OPERATOR,TOSCAUTILS.NEW_AIRLINE_AIRCRAFT_OPERATOR));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_AIRLINE_MEMBER_STATE,TOSCAUTILS.NEW_AIRLINE_MEMBER_STATE));
         

/******************************** FOR FUTURE USE *****************************************************************
        testSelection.add(new SelectOption(TOSCAUTILS.CREATE_RISK_EVENT,TOSCAUTILS.CREATE_RISK_EVENT));//For future use
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_HE_CASH_WITH_HIERARCHY,TOSCAUTILS.NEW_HE_CASH_WITH_HIERARCHY));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_HE_CASHLESS_WITH_HIERARCHY,TOSCAUTILS.NEW_HE_CASHLESS_WITH_HIERARCHY));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_HE_CASH_WITH_MULTIPLE_HIERARCHY,TOSCAUTILS.NEW_HE_CASH_WITH_MULTIPLE_HIERARCHY));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_HE_CASH_LIMITED_COMPANY,TOSCAUTILS.NEW_HE_CASH_LIMITED_COMPANY));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_RISK_SIDRA_LITE_CASE,TOSCAUTILS.NEW_RISK_SIDRA_LITE_CASE));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_RISK_SIDRA_LITE_CASE_RISK_B,TOSCAUTILS.NEW_RISK_SIDRA_LITE_CASE_RISK_B));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_RISK_SIDRA_LITE_CASE_RISK_B_COMMON_OWNERSHIP,TOSCAUTILS.NEW_RISK_SIDRA_LITE_CASE_RISK_B_COMMON_OWNERSHIP));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_RISK_STATUS_B_PASSED,TOSCAUTILS.NEW_RISK_STATUS_B_PASSED));
        testSelection.add(new SelectOption(TOSCAUTILS.NEW_RISK_STATUS_B_PASSED_FAIL_FSECURITY,TOSCAUTILS.NEW_RISK_STATUS_B_PASSED_FAIL_FSECURITY));
        testSelection.add(new SelectOption(TOSCAUTILS.CREATE_RISK_EVENT,TOSCAUTILS.CREATE_RISK_EVENT));
******************************************************************************************************************/
        return testSelection;
    }


    /****************************************************************************************************************************************************************

                                                    CREATE AGENCY AUTHORIZATION 
                                                    Agency_Authorization__c       
    
    *****************************************************************************************************************************************************************/
    
    public void createAgencyAuthorization(){

        Id agencyAuthorizationId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'FormOfPayment');
        agencyAuthorization = TOSCAUTILS.fecthAgencyAuthorization(parentAcc.Id);

        if(agencyAuthorization == null){
            fieldsOfObject = new Map<String,Object>();
            fieldsOfObject.put('Account__c', parentAcc.Id);
            fieldsOfObject.put('Status__c', 'Active');
            fieldsOfObject.put('Email_Used_for_BSP_Creation__c', 'toscaAuthorization@tosca.com');
            fieldsOfObject.put('RecordTypeId', agencyAuthorizationId);
            fieldsOfObject.put('ANG_FormOfPayment_ID__c', 'CC');

            Agency_Authorization__c newAgencyAuthorizationCC = TOSCAUTILS.agencyAuthorization(fieldsOfObject);
            insert newAgencyAuthorizationCC;        
        
            fieldsOfObject = new Map<String,Object>();
            fieldsOfObject.put('Account__c', parentAcc.Id);
            fieldsOfObject.put('Status__c', 'Active');
            fieldsOfObject.put('Email_Used_for_BSP_Creation__c', 'toscaAuthorization@tosca.com');
            fieldsOfObject.put('RecordTypeId', agencyAuthorizationId);
            fieldsOfObject.put('ANG_FormOfPayment_ID__c', 'CA');

            Agency_Authorization__c newAgencyAuthorizationCA = TOSCAUTILS.agencyAuthorization(fieldsOfObject);
            insert newAgencyAuthorizationCA;

            fieldsOfObject = new Map<String,Object>();
            fieldsOfObject.put('Account__c', parentAcc.Id);
            fieldsOfObject.put('Status__c', 'Active');
            fieldsOfObject.put('Email_Used_for_BSP_Creation__c', 'toscaAuthorization@tosca.com');
            fieldsOfObject.put('RecordTypeId', agencyAuthorizationId);
            fieldsOfObject.put('ANG_FormOfPayment_ID__c', 'EP');

            Agency_Authorization__c newAgencyAuthorizationEP = TOSCAUTILS.agencyAuthorization(fieldsOfObject);
            insert newAgencyAuthorizationEP;
        }
    }

/****************************************************************************************************************************************************************

                                                        CREATE CHANGE CODE 
                                                       Agency_Applied_Change_code__c       
    
****************************************************************************************************************************************************************/

    public void createChangeCode(){
        chCode = new Agency_Applied_Change_code__c();

        fieldsOfObject = new Map<String,Object>();        
        fieldsOfObject.put('OSCAR__c', oscar.Id);
        fieldsOfObject.put('AccountNewStatus__c', 'Approved');
        fieldsOfObject.put('Change_Code__c', 'New');
        fieldsOfObject.put('Reason_Description__c', 'NEW APPLICATION');
        fieldsOfObject.put('Reason_Code__c', '21');
        fieldsOfObject.put('To_Publish_in_e_Bulletin__c', true);
        fieldsOfObject.put('Bulletin_Information__c', 'NEW APPLICATION IN PROGRESS');

        if(selectedTest == TOSCAUTILS.NEW_HO_CARGO){
            fieldsOfObject.put('Bulletin_Information__c', 'NEW APPLICATION - HEAD OFFICE IN PROGRESS');        
        }else{
            fieldsOfObject.put('Bulletin_Information__c', 'NEW APPLICATION IN PROGRESS');    
        }
        
        if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT){
            fieldsOfObject.put('Account__c',childAcc.Id);
        }else{
            fieldsOfObject.put('Account__c',parentAcc.Id);    
        }

        Agency_Applied_Change_code__c newChangeCodeNew = TOSCAUTILS.agChangeCodeNew(fieldsOfObject);
        insert newChangeCodeNew;
    }


/****************************************************************************************************************************************************************
  
                                                                CREATE ACCOUNT ROLE
                                                                AMS_Account_Role__c   
  
 /****************************************************************************************************************************************************************/
           
    public void createAccountRole(){
        ID accountRoleRt = AMS_Utils.AccountRoleOwnershipRT;
        accountRole = new AMS_Account_Role__c();

        fieldsOfObject = new Map<String,Object>();        
        fieldsOfObject.put('Contact__c', contact.Id);
        fieldsOfObject.put('RecordTypeId', accountRoleRt);
        fieldsOfObject.put('Percentage__c', 100);

        if(selectedTest == TOSCAUTILS.NEW_HE_CHILD_ACCOUNT){
            fieldsOfObject.put('Account__c',childAcc.Id);
        }else{
            fieldsOfObject.put('Account__c',parentAcc.Id);    
        }

        AMS_Account_Role__c newAccountRole= TOSCAUTILS.accRole(fieldsOfObject);
        insert newAccountRole;
    }
      
/****************************************************************************************************************************************************************
  
                                                                Send Invitation
                                                                    Fred+   
  
 /****************************************************************************************************************************************************************/
  
    public void sendInvitation(){
        
        fredInvitation = new Invitation__c(
                                AccountId__c = parentAcc.Id,
                                Business_Fax__c = '123456789',
                                Business_Phone__c = '123456789',
                                Email__c = 'secundary.' + usedEmail,
                                First_Name__c = contact.FirstName,
                                Job_Function__c = 'Commercial',
                                Job_Title__c = 'tester',
                                Last_Name__c = contact.LastName,
                                Mobile_Phone__c = '123456789',
                                Salutation__c = 'Mr.',
            					Role__c = 'secundary'
        );
        insert fredInvitation;
        
        Network myNetwork = [SELECT Id FROM Network WHERE Name ='identity'];
        ConnectApi.Community myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);
        
        communityURL = Network.getLoginUrl(myCommunity.id) +'/SelfRegister?serviceName=FRED&token=' + fredInvitation.Id;

        showURL = true;
        sendInvitation = false;
    }


/****************************************************************************************************************************************************************
  
                                                                Assign Permissions to User
                                                                    Fred+   
  
 /****************************************************************************************************************************************************************/
  
    public void assignPermissionToUser(){
		
        Id userId = user.Id;
        
        List<PermissionSet> fredPS = [SELECT Id FROM PermissionSet WHERE Name in :TOSCAUTILS.ALL_FRED_PERMISSION_SET AND IsOwnedByProfile = false];
        List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
        for(PermissionSet ps : fredPS){
            psa.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = userId));
        }
        System.debug('PermissionSetAssignment = ' +psa);
        upsert psa;   
        
        givePermissions = false;
        sendInvitation = true;
    }
}