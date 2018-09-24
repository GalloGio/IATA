/*BRIEF DOCUMENTATION ON CASE TRIGGER AFTER THE CASE TRIGGER OPTIMIZATION PROGRAM (Each part refers to a detailed document)
01 - trgProcessISSCase - ALL: isInsert, isUpdate
02 - trgCase - All: isInsert, isUpdate
03 - trgCaseIFAP - ALL: Common, isInsert, isUpdate
04 - ISSP_CreateNotificationForCase - All: isUpdate
05 - trgCase_BeforeDelete - All: isDelete
06 - UserInfoUpdate - All: Common, isInsert, isUpdate
07 - trgCheckBusinessHoursBeforeInsert - All: Common, isInsert, isUpdate
08 - trgSidraCaseBeforeInsertUpdate - All: isInsert, isUpdate
09 - trgCustomerPortalCaseSharing - ALL: isInsert
10 - trgBeforeInsertUpdate - All: Common
11 - CalculateBusinessHoursAges - All: isUpdate
12 - trgCase_SIS_ICH_AreaVsType - All: Common, isUpdate
13 - trgICCSCaseValidation - All: Common
14 - trgParentCaseUpdate - All: isUpdate
15 - Case_FSM_Handle_NonCompliance_BI_BU - All: Common, isInsert, isUpdate
16 - trgIDCard_Case_BeforeUpdate - All: isUpdate
17 - trgICCS_ASP_Case_Validation - All: Common
18 - trgCreateUpdateServiceRenderedRecord - All: Common
19 - updateAccountFieldBasedOnIATAwebCode - All: Common
20 - CaseBeforInsert - All: isInsert
21 - AMS_OSCARCaseTrigger - All: isInsert, isUpdate
22 - trgAccelyaRequestSetCountry - All: Common, isInsert */

trigger CaseBeforeTrigger on Case (before delete, before insert, before update) {

    /*DEVELOPMENT START/STOP FLAGS*/
    boolean trgProcessISSCase = true;
    boolean trgCase = true;
    boolean trgCaseIFAP = true;
    boolean ISSP_CreateNotificationForCase = true;
    boolean trgCase_BeforeDelete = true;
    boolean UserInfoUpdate = true;
    boolean trgCheckBusinessHoursBeforeInsert = true;
    boolean trgSidraCaseBeforeInsertUpdate = true;
    boolean trgBeforeInsertUpdate = true;
    boolean CalculateBusinessHoursAges = true;
    boolean trgCase_SIS_ICH_AreaVsType = true;
    boolean trgICCSCaseValidation = true;
    boolean trgParentCaseUpdate = true;
    boolean Case_FSM_Handle_NonCompliance_BI_BU = true;
    boolean trgIDCard_Case_BeforeUpdate = true;
    boolean trgICCS_ASP_Case_Validation = true;
    boolean trgCreateUpdateServiceRenderedRecord = true;
    boolean updateAccountFieldBasedOnIATAwebCode = true;
    boolean CaseBeforInsert = true;
    boolean AMS_OSCARCaseTrigger = true;
    boolean trgAccelyaRequestSetCountry = true;
    boolean trgCustomerPortalCaseSharing = true;
    if(!Test.isRunningTest()){
        trgProcessISSCase = GlobalCaseTrigger__c.getValues('BT trgProcessISSCase').ON_OFF__c;                                       //55555555555555
        trgCase = GlobalCaseTrigger__c.getValues('BT trgCase').ON_OFF__c;                                                           //33333333333333
        trgCaseIFAP = GlobalCaseTrigger__c.getValues('BT trgCaseIFAP').ON_OFF__c;                                                   //44444444444444
        ISSP_CreateNotificationForCase = GlobalCaseTrigger__c.getValues('BT ISSP_CreateNotificationForCase').ON_OFF__c;             //11111111111111
        trgCase_BeforeDelete = GlobalCaseTrigger__c.getValues('BT trgCase_BeforeDelete').ON_OFF__c;                                 //11111111111111
        UserInfoUpdate = GlobalCaseTrigger__c.getValues('BT UserInfoUpdate').ON_OFF__c;                                             //22222222222222
        trgCheckBusinessHoursBeforeInsert = GlobalCaseTrigger__c.getValues('BT trgCheckBusinessHoursBeforeInsert').ON_OFF__c;       //55555555555555
        trgSidraCaseBeforeInsertUpdate = GlobalCaseTrigger__c.getValues('BT trgSidraCaseBeforeInsertUpdate').ON_OFF__c;             //22222222222222
        trgBeforeInsertUpdate = GlobalCaseTrigger__c.getValues('BT trgBeforeInsertUpdate').ON_OFF__c;                               //11111111111111
        CalculateBusinessHoursAges = GlobalCaseTrigger__c.getValues('BT CalculateBusinessHoursAges').ON_OFF__c;                     //22222222222222
        trgCase_SIS_ICH_AreaVsType = GlobalCaseTrigger__c.getValues('BT trgCase_SIS_ICH_AreaVsType').ON_OFF__c;                     //11111111111111
        trgICCSCaseValidation = GlobalCaseTrigger__c.getValues('BT trgICCSCaseValidation').ON_OFF__c;                               //22222222222222
        trgParentCaseUpdate = GlobalCaseTrigger__c.getValues('BT trgParentCaseUpdate').ON_OFF__c;                                   //33333333333333
        Case_FSM_Handle_NonCompliance_BI_BU = GlobalCaseTrigger__c.getValues('BT Case_FSM_Handle_NonCompliance_BI_BU').ON_OFF__c;   //22222222222222
        trgIDCard_Case_BeforeUpdate = GlobalCaseTrigger__c.getValues('BT trgIDCard_Case_BeforeUpdate').ON_OFF__c;                   //55555555555555
        trgICCS_ASP_Case_Validation = GlobalCaseTrigger__c.getValues('BT trgICCS_ASP_Case_Validation').ON_OFF__c;                   //11111111111111
        trgCreateUpdateServiceRenderedRecord = GlobalCaseTrigger__c.getValues('BT trgCreateUpdateServiceRendered').ON_OFF__c;       //44444444444444
        updateAccountFieldBasedOnIATAwebCode = GlobalCaseTrigger__c.getValues('BT updateAccountFieldBasedOnIATA').ON_OFF__c;        //22222222222222
        CaseBeforInsert = GlobalCaseTrigger__c.getValues('BT CaseBeforInsert').ON_OFF__c;                                           //33333333333333
        AMS_OSCARCaseTrigger = GlobalCaseTrigger__c.getValues('BT AMS_OSCARCaseTrigger').ON_OFF__c;                                 //55555555555555
        trgAccelyaRequestSetCountry = GlobalCaseTrigger__c.getValues('BT trgAccelyaRequestSetCountry').ON_OFF__c;                   //33333333333333
        trgCustomerPortalCaseSharing = GlobalCaseTrigger__c.getValues('BT trgCustomerPortalCaseSharing').ON_OFF__c;                 //44444444444444
    }

    /**********************************************************************************************************************************/
    /*Record type*/
    ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
    ID ProcessISSPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');//SAAM
    ID SIDRAcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
    ID SIDRABRcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA_BR');
    ID sisHelpDeskCaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_SIS_Help_Desk');
    Id RT_ICCS_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Product_Management');
    Id RT_ICCS_BA_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Bank_Account_Management');
    Id RT_ICCS_CD_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_CitiDirect');
    ID FSMcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Security_Monitoring');
    ID caseRecordType = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');
    Id RT_ICCS_ASP_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ASP_Management');
    ID AirlineCodingRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Coding_Application');
    ID EuropecaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');
    ID AmericacaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesAmericas');
    ID AfricaMEcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesMENA');
    ID AsiaPacificcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ExternalCasesIDFSglobal');
    ID ChinaAsiacaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_China_North_Asia');
    ID InternalcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE');
    ID InvCollectioncaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Invoicing_Collection_Cases');
    ID CSProcesscaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CS_Process_IDFS_ISS');
    ID SEDAcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SEDA');
    ID ISSPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ISS_Portal_New_Case_RT');//TF - SP9-C5
    ID CSRcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'BSPlink_Customer_Service_Requests_CSR');
    ID PortalRecordTypeID  = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'External_Cases_InvoiceWorks');
    /*Record type*/

    /*Variables*/
    Date OneYearAgo = Date.today().addYears(-1);
    Datetime Last24Hours = Datetime.now().addDays(-1);
    final static string SMALLAMOUNT = 'Small Amount (<50USD)';
    final static string MINORPOLICY = 'Minor error policy';
    public static final String PAX = 'Travel Agent';
    public static final String CARGO = 'Cargo Agent';
    public static final String FDS = 'FDS - Create Authorized Signatories Package';

    Profile currentUserProfile;
    Boolean isIfapAuthorizedUser = false;
    Boolean isAccelya = false;
    boolean hasOneSISCase = false;
    /*Variables*/

    /*Maps, Sets, Lists*/
    Set<id> setFSMCaseId = new Set<id>();
   
    //update for New Interaction: if new case a parent case with type = Id Cards: update new interaction fields
    map<String, Case> casePerParentId = new map<String, Case>();
    map<id, Contact> contactMap = new map<id, Contact>();
    map<id, Account> accountMap = new map<id, Account>();

    /*CONTROLLARE IL POPOLAMENTO DELLE SEGUENTI MAPPE QUANDO VIENE CHIAMATA CheckBusinessHoursHelperClass*/
    Map <string, Contact> CBHContactMap = new Map <string, Contact> ();
    Map <string, Account> CBHAccountMap = new Map <string, Account> ();
    Map <ID, Case> mapFSMCases;

    Map<ID, List<Case>> mapSAAMParentIDCase = new Map<ID, List<Case>>();
    Map<ID, List<Case>> mapIFAPParentIDCase = new Map<ID, List<Case>>();
    Map<ID, List<Case>> parentCaseMap = new Map<ID, List<Case>>();

    List<EmailTemplate__c> IFAPemailtemplate = new List<EmailTemplate__c>();

    //get a Set of the Ids of all the Accounts with IFAP Cases linked to the Trigger cases
    Set<Id> IFAPaccountIds = new Set<Id>();
    //get a Set of Parent of Ids of all cases
    Set<ID> IFAPParentID = new Set<ID>();
    /*Maps, Sets, Lists*/
    

/***********************************************************************************************************************************************************/
    /*Share trigger code*/
    if (Trigger.isInsert || Trigger.isUpdate) {

        /*trgCaseIFAP Trigger*/
        if(trgCaseIFAP){ 
            System.debug('____ [cls CaseBeforeTrigger - trgCaseIFAP]');

            if (!CaseChildHelper.noValidationsOnTrgCAseIFAP){
                Set<Id> contactIds = new Set<Id>();
                
                Map<Id, Contact> contacts;
                Map<Id, Account> accounts;

                for (Case aCase : trigger.New) {
                    if (aCase.RecordTypeId == IFAPcaseRecordTypeID) {
                        system.debug('Contact Id: ' + aCase.contactId  + ' Account ID: ' + aCase.accountId);
                        contactIds.add(aCase.contactId);
                        IFAPaccountIds.add(aCase.accountId);
                    }
                    // Fill a list of ParentIDs of cases
                    IFAPParentID.add(aCase.ParentId);
                }

                //isSAAMCase - Fill a map with all Case Parent ID and list of case related to its Parent Case
                for (Case currentCase : [SELECT Id, Status, Subject, RecordTypeId, ParentId FROM Case WHERE Id IN :IFAPParentID]) {
                    if(currentCase.RecordTypeId == ProcessISSPcaseRecordTypeID){
                        if(!mapSAAMParentIDCase.containsKey(currentCase.ParentId))
                            mapSAAMParentIDCase.put(currentCase.ParentId, new List<Case>{currentCase});
                        else
                            mapSAAMParentIDCase.get(currentCase.ParentId).add(currentCase);
                    }
                    if(currentCase.RecordTypeId == IFAPcaseRecordTypeID){
                        if(!mapIFAPParentIDCase.containsKey(currentCase.ParentId))
                            mapIFAPParentIDCase.put(currentCase.ParentId, new List<Case>{currentCase});
                        else
                            mapIFAPParentIDCase.get(currentCase.ParentId).add(currentCase);
                    }
                }

                if (!contactIds.isEmpty() || !IFAPaccountIds.isEmpty()) {
                    currentUserProfile = getUserProfile(); 
                
                    contacts = new Map<Id, Contact>([SELECT c.Id, c.Agent_Type__c, c.AccountId FROM Contact c WHERE Id IN :contactIds]);
            
                    accounts = new Map<Id, Account>([SELECT a.Id, a.IATACode__c, a.BillingCountry, a.Type, a.RecordType.DeveloperName, a.CNS_Account__c 
                                                    FROM Account a WHERE Id IN : IFAPaccountIds]);
                   
                    //emailtemplate query from isinsert and isupdate to the share code
                    IFAPemailtemplate = [SELECT et.IATA_ISO_Country__r.Id FROM EmailTemplate__c et WHERE et.recordType.Name = 'IFAP'];

                    //Ifap Authorized users have a specific permission set
                    List<PermissionSetAssignment> psaList = [SELECT AssigneeId FROM PermissionSetAssignment 
                                                            WHERE Assignee.IsActive = true AND AssigneeId = :UserInfo.getUserId()
                                                            AND PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name = 'IFAP_Authorized_Users')];
                    if (!psaList.isEmpty()){
                        isIfapAuthorizedUser = true;
                    }

                    // Create Account and contact Map (in order to decrease the number of SOQL queries executed)
                    for (Case aCase : trigger.New) {
                        // Search for the contact related to the case
                        if(contacts.get(aCase.ContactId) != null){
                            contactMap.put(aCase.id, contacts.get(aCase.ContactId));
                        }
                        // Search for the account related to the case
                        Account aAccount = accounts.get(aCase.AccountId);
                        if(aAccount != null){
                            accountMap.put(aCase.id, aAccount);
                            if(aAccount.RecordType.DeveloperName == 'IATA_Agency' && aAccount.CNS_Account__c){
                                aCase.CNSCase__c = true;
                            }
                        }
                  
                    }
                }
            }
        }
        /*trgCaseIFAP Trigger*/

        /*UserInfoUpdate Trigger*/
        if(UserInfoUpdate){ //FLAG
            System.debug('____ [cls CaseBeforeTrigger - UserInfoUpdate]');
            Set<string> caseStatus = new set<string>();
            for(CaseClosedStatus__c cs : CaseClosedStatus__c.getAll().values()) { //RN-INC347705 -> get isclosed cases status from custom Setting to remove a query
                caseStatus.add(cs.name);
            }
            //IMPRO GM END
            // Update L.Faccio ----------------When a case is closed, I save the user who closed the case.
            for (Case c : Trigger.new) { //RN-INC342887 - validation with isClosed
                if ((Trigger.isInsert && caseStatus.contains(c.status)) || (Trigger.isUpdate && caseStatus.contains(c.status)) ) {
                    c.WhoClosedCase__c = UserInfo.getUserId();
                }
                if (Trigger.isUpdate && !caseStatus.contains(c.status)) {
                    c.WhoClosedCase__c = null;
                }
            }
        }// END Update L.Faccio --------------

        /*UserInfoUpdate Trigger*/

        /*trgCheckBusinessHoursBeforeInsert Trigger*/
        if (trgCheckBusinessHoursBeforeInsert) { //FLAG
            System.debug('____ [cls CaseBeforeTrigger - trgCheckBusinessHoursBeforeInsert]');
            List <Contact> ctcIdList = new List < Contact >();
            for (Case newCaseObj : trigger.new) {
                if (((newCaseObj.RecordTypeId != null) && newCaseObj.RecordTypeId == sisHelpDeskCaseRecordTypeID) || ((newCaseObj.description != null)
                        && (newCaseObj.description.contains(Label.Case_Area_ICH) || newCaseObj.description.contains(Label.Case_Area_SIS))) || ((newCaseObj.CaseArea__c != null)
                        && (newCaseObj.CaseArea__c == Label.SIS || newCaseObj.CaseArea__c == Label.ICH))) {
                    hasOneSISCase = true;
                    break;
                }
            }
            if (hasOneSISCase) {
                list < string > AccountNames = new list < string > {'ACH', 'AIA', 'IATA - ICH', 'IATA - iiNET', 'IATA ITS DR Escalations', Label.ICH_Application_Support, Label.ICH_Help_Desk_Agent, 'Kale Application Support', Label.SIS_Help_Desk_Agent, Label.SIS_L2_Customer_Support, Label.SIS_Operations, Label.Trust_Weaver};
                List < Account > accIdList = [SELECT id, Name FROM Account WHERE Name in : AccountNames];
                if (!accIdList.isEmpty()) {
                    for (Account relatedAccount : accIdList) {
                        system.debug('\nRelatedAccount.Name: ' + relatedAccount.Name);
                        CBHAccountMap.put(relatedAccount.Name, relatedAccount);
                    }
                }
                if (!AccountNames.isEmpty()) {
                    ctcIdList = [SELECT id, accountid, email, name FROM Contact WHERE account.Name in : AccountNames ORDER BY accountid];
                }
                if (!ctcIdList.isEmpty()) {
                    //GM - IMPRO - START
                    for (Contact relatedContact : ctcIdList) {
                        CBHContactMap.put(relatedContact.accountid, relatedContact);
                    }
                    //GM - IMPRO - END
                }
            }
        }
        /*trgCheckBusinessHoursBeforeInsert Trigger*/

        /*trgCase_SIS_ICH_AreaVsType Trigger*/
        if (trgCase_SIS_ICH_AreaVsType) { //FLAG
            System.debug('____ [cls CaseBeforeTrigger - trgCase_SIS_ICH_AreaVsType]');

            for (case newCase: Trigger.new) {
                if (newCase.Type != null && newCase.CaseArea__c != null) {
                    if (newCase.CaseArea__c == 'ICH' && (newCase.Type == 'SIS Feature Request' || newCase.Type == 'SIS Technical Problem' || newCase.Type == 'SIS Internal Case'
                                                         || newCase.Type == 'SIS Question/Problem' || newCase.Type == 'SIS Member Profile Update' || newCase.Type == 'SIS Membership'
                                                         || newCase.Type == 'Feature Request' || newCase.Type == 'General Question' || newCase.Type == 'Problem / Issue')) {
                        //system.debug('\n case area:' + newCase.CaseArea__c + ' type: ' + newCase.Type );
                        system.debug('\n Assert error2 caught .......');
                        newCase.addError(Label.HelpDesk_SIS_ICH_Type_Area_Mismatch);
                    }
                    if (newCase.CaseArea__c == 'SIS' && (newCase.Type != 'SIS Feature Request' && newCase.Type != 'SIS Technical Problem' && newCase.Type != 'SIS Internal Case'
                                                         && newCase.Type != 'SIS Question/Problem' && newCase.Type != 'SIS Member Profile Update' && newCase.Type != 'SIS Membership'
                                                         && newCase.Type != 'Feature Request' && newCase.Type != 'General Question' && newCase.Type != 'Problem / Issue')) {
                        //system.debug('\n case area:' + newCase.CaseArea__c + ' type: ' + newCase.Type);
                        system.debug('\n Assert error1 caught .......');
                        newCase.addError(Label.HelpDesk_SIS_ICH_Type_Area_Mismatch);
                    }
                }
            }
        }
        /*trgCase_SIS_ICH_AreaVsType Trigger*/

        /*trgICCSCaseValidation Trigger*/
        /*
        * @author: Constantin BUZDUGA, blue-infinity
        * @description: This trigger is used for validation on ICCS Cases:
        *       For FDS_ICCS_Product_Management cases:
        *       - product choice validation (existing & active product);
        *       - for assignment cases, it checks that the selected product-country-currency is not already active for the airline;
        *       - for removal cases, it checks that the product-country-currency is assigned & active on the airline.
        *       For FDS_ICCS_Bank_Account_Management cases:
        *       - for "delete bank account" cases, it checks that the bank account is not currently assigned to an active PA.
        *
        *       If any of these conditions is not respected, an error is raised and the upsert of the case is blocked.*/

        if (trgICCSCaseValidation) { //FLAG
            System.debug('____ [cls CaseBeforeTrigger - trgICCSCaseValidation]');

             // For FDS_ICCS_Bank_Account_Management, a check is only performed for delete bank account cases
            final string INS = 'ICCS – Assign Product';
            final string UPD = 'ICCS – Update Payment Instructions';
            final string DEL = 'ICCS – Delete Bank Account';
            Boolean ThereAreICCSProductManagementCases = false;
            Boolean ThereAreICCSBankAccountManagementCases = false;
            Boolean ThereAreICCSCaseClosing = false;
            Set<Id> BankAccounts = new Set<Id>();

            // List of trigger-related  ICCS Bank Accounts
            List<Id> lstBankAccountIds = new List<Id>();
            // List of trigger-related accounts
            List<Id> lstAccountIds = new List<Id>();
            List<String> lstProducts = new List<String>();
            List<Product_Assignment__c> productAssignmentActiveList;


            // For FDS_ICCS_CitiDirect I check the condition of workflow "ICCS: CitiDirect Set Status In progress When Doc Received"
            for (Case c : Trigger.new) {
                Case oc = Trigger.isInsert ? new Case() : Trigger.oldMap.get(c.id);

                if (!c.isclosed){

                    if (c.RecordTypeId == RT_ICCS_CD_Id && c.Status == 'Pending customer' && c.Documentation_received__c != null
                        && ((c.CaseArea__c == 'ICCS - Assign CitiDirect Rights' && c.Reason1__c == 'Login & Password' && c.Documentation_received__c.indexOf('CitiDirect Request Form') != -1)
                            || (c.CaseArea__c == 'ICCS - Assign AFRD CitiDirect Rights' && c.Reason1__c == 'User management' && c.Documentation_received__c.indexOf('AFRD - CitiDirect Request Form') != -1)
                            || (c.CaseArea__c == 'ICCS - Remove CitiDirect Rights' && c.Reason1__c == 'Termination' && c.Documentation_received__c.indexOf('CitiDirect Request Form') != -1)
                            )
                        // the same condition should not be true for the old case
                        && !(oc.RecordTypeId == RT_ICCS_CD_Id && oc.Status == 'Pending customer' && oc.Documentation_received__c != null
                             && ((oc.CaseArea__c == 'ICCS - Assign CitiDirect Rights' && oc.Reason1__c == 'Login & Password' && oc.Documentation_received__c.indexOf('CitiDirect Request Form') != -1)
                                 || (oc.CaseArea__c == 'ICCS - Assign AFRD CitiDirect Rights' && oc.Reason1__c == 'User management' && oc.Documentation_received__c.indexOf('AFRD - CitiDirect Request Form') != -1)
                                 || (oc.CaseArea__c == 'ICCS - Remove CitiDirect Rights' && oc.Reason1__c == 'Termination' && oc.Documentation_received__c.indexOf('CitiDirect Request Form') != -1))
                             )
                        ) {
                        c.Status = 'In progress';
                        c.Documentation_Complete__c = Date.today();

                    // I check the condition of workflow "ICCS: BA Creation Set Status In progress When Doc Received"
                    } else if (c.RecordTypeId == RT_ICCS_BA_Id && !String.isBlank(String.valueOf(c.Documentation_Complete__c))
                           && c.CaseArea__c == 'ICCS – Create Bank Account' && c.ICCS_Bank_Account__c != null
                           // the same condition should not be true for the old case
                           && !(oc.RecordTypeId == RT_ICCS_BA_Id && !String.isBlank(String.valueOf(oc.Documentation_Complete__c))
                                && oc.CaseArea__c == 'ICCS – Create Bank Account' && oc.ICCS_Bank_Account__c != null)) {
                        c.Status = 'In progress';
                    }

                    // I check the condition of workflow "Notification to ICCS Contact - CitiDirect standard Case created"
                    if (c.RecordTypeId == RT_ICCS_BA_Id && c.CaseArea__c == 'ICCS - Assign CitiDirect Rights,ICCS - Remove CitiDirect Rights'
                            // the same condition should not be true for the old case
                            && !(oc.RecordTypeId == RT_ICCS_BA_Id && oc.CaseArea__c == 'ICCS - Assign CitiDirect Rights,ICCS - Remove CitiDirect Rights')) {
                        c.Status = 'Pending customer';
                    }
                    // I check the condition of workflow "Notification to ICCS Contact - CitiDirect AFRD Case created"
                    if (c.RecordTypeId == RT_ICCS_BA_Id && c.CaseArea__c == 'ICCS - Assign AFRD CitiDirect Rights'
                            // the same condition should not be true for the old case
                            && !(oc.RecordTypeId == RT_ICCS_BA_Id && oc.CaseArea__c == 'ICCS - Assign AFRD CitiDirect Rights')) {
                        c.Status = 'Pending customer';
                    }

                     // This trigger only handles ICCS cases, so we check there is at least one such case of interest
                    if (c.RecordTypeId == RT_ICCS_Id) {
                        ThereAreICCSProductManagementCases = true;
                        if (c.Status == 'Closed')
                            ThereAreICCSCaseClosing = true;
                    } else if (c.RecordTypeId == RT_ICCS_BA_Id && c.CaseArea__c == DEL) {
                        ThereAreICCSBankAccountManagementCases = true;
                    }
                        lstBankAccountIds.add(c.ICCS_Bank_Account__c);
                        lstAccountIds.add(c.AccountId);
                        lstProducts.add(c.ICCS_Product__c);
                }
            }

            if (ThereAreICCSBankAccountManagementCases || ThereAreICCSProductManagementCases){
                productAssignmentActiveList = [SELECT Id, Account__c, ICCS_Bank_Account__c, ICCS_Product_Currency__c 
                                               FROM Product_Assignment__c 
                                               WHERE Status__c = 'Active' 
                                               AND (ICCS_Bank_Account__c IN :lstBankAccountIds OR Account__c IN :lstAccountIds)]; 
            }

            if (ThereAreICCSBankAccountManagementCases) {
                // Create a map of all active Product Assignments linked to trigger-related Bank Accounts; Key = Bank Account SF Id, Value = PA
                Map<Id, Product_Assignment__c> mapBaPaPerId = new Map<Id, Product_Assignment__c>();

                for (Id bankAccountID : lstBankAccountIds){
                    for (Product_Assignment__c pa : productAssignmentActiveList) {
                        if (pa.ICCS_Bank_Account__c == bankAccountID){
                            mapBaPaPerId.put(pa.ICCS_Bank_Account__c, pa);
                        }
                    }
                }
                for (Case c : Trigger.new) {
                    // Only Cases with the FDS_ICCS_Bank_Account_Management record type
                    if (c.RecordTypeId == RT_ICCS_BA_Id) {
                        // Check that the chosen product combination is valid & active - only for open cases! (combinations used on old cases might have been inactivated)
                        if (mapBaPaPerId.get(c.ICCS_Bank_Account__c) != null && c.CaseArea__c == DEL) {
                            c.ICCS_Bank_Account__c.addError('This Bank Account is linked to active Product Assignments. You cannot remove a Bank Account that is currently in use.');
                        }
                    }
                }
            }
            if (ThereAreICCSProductManagementCases) {
                // Create a map of all active services, with the key [Product-Country-Currency]
                Map<String, ICCS_Product_Currency__c> mapProductCurrencyPerKey = new Map<String, ICCS_Product_Currency__c>();
                
                List<ICCS_Product_Currency__c> lstProdCurr = [SELECT Id, Currency__c, Country__c, Product__c 
                                                            FROM ICCS_Product_Currency__c 
                                                            WHERE Status__c = 'Active' AND Product__c IN :lstProducts];
                for (ICCS_Product_Currency__c pc : lstProdCurr) {
                    mapProductCurrencyPerKey.put(pc.Product__c + '-' + pc.Country__c + '-' + pc.Currency__c, pc);
                }

                // Create a map of active Product Assignments related to the trigger cases' accounts, with the key [ICCS Product Currency ID - Account ID]
                Map<String, Product_Assignment__c> mapProductAssignmentsPerKey = new Map<String, Product_Assignment__c>();

                for (Id accountID : lstAccountIds){
                    for (Product_Assignment__c pa : productAssignmentActiveList) {
                        if(accountID == pa.Account__c){
                            mapProductAssignmentsPerKey.put(String.valueOf(pa.ICCS_Product_Currency__c) + '-' + String.valueOf(pa.Account__c), pa);
                        }
                    }
                }
                Set<Id> CaseWithBalanceOrTotal = new Set<Id>();
                if (ThereAreICCSCaseClosing) {
                    for (ICCS_BankAccount_To_Case__c batc : [SELECT Case__c, Split_Type__c 
                                                            FROM ICCS_BankAccount_To_Case__c 
                                                            WHERE ICCS_Bank_Account__r.Account__c IN :lstAccountIds 
                                                                AND (Split_Type__c = 'Balance' OR Split_Type__c = 'Total')]) {
                        CaseWithBalanceOrTotal.add(batc.Case__c);
                    }
                }
                for (Case c : Trigger.new) {
                    // Only Cases with the FDS_ICCS_Product_Management record type
                    if (c.RecordTypeId == RT_ICCS_Id) {
                        if ((c.CaseArea__c == INS || c.CaseArea__c == UPD) && c.Status == 'Closed' && !CaseWithBalanceOrTotal.contains(c.id)) {
                            c.addError('To close this case it\'s required to add a Bank Account with Split Type = "Balance" or "Total"');
                            continue;
                        }
                        // This check is only performed for product assignment / removal / update cases
                        // Check that the chosen product combination is valid & active - only for open cases! (combinations used on old cases might have been inactivated)
                        if (mapProductCurrencyPerKey.get(c.ICCS_Product__c + '-' + c.ICCS_Country__c + '-' + c.ICCS_Currencies__c) == null &&
                                !(Trigger.isUpdate && Trigger.oldMap.get(c.Id).isClosed) &&
                                (c.CaseArea__c == INS || c.CaseArea__c == UPD || c.CaseArea__c == DEL)) {
                            c.ICCS_Currencies__c.addError('This Product - Country - Currency combination doesn\'t exist or is inactive.');
                        }
                        // Assignment / removal / payment instruction cases checks
                        ICCS_Product_Currency__c tmpProdCurr = mapProductCurrencyPerKey.get(c.ICCS_Product__c + '-' + c.ICCS_Country__c + '-' + c.ICCS_Currencies__c);
                        if (tmpProdCurr != null && c.Status != 'Closed') {
                            Product_Assignment__c tmpPA = mapProductAssignmentsPerKey.get(String.valueOf(tmpProdCurr.Id) + '-' + String.valueOf(c.AccountId)); 

                            // If this is an assignment Case and the product-country-currency is already assigned to the Account, raise an error
                            if (c.CaseArea__c == INS && tmpPA != null) {
                                c.ICCS_Currencies__c.addError(' This Product - Country - Currency combination is already assigned and active on the selected Account.');
                            }
                            // If this is a removal Case and the product-country-currency is NOT assigned & active on the Account, raise an error
                            else if (c.CaseArea__c == DEL && tmpPA == null) {
                                c.ICCS_Currencies__c.addError(' This Product - Country - Currency combination is NOT currently active on the selected Account.');
                            }
                            // If this is an Update Payment Instructions Case
                            else if (c.CaseArea__c == UPD && tmpPA == null) {
                                //If the selected product-country-currency is NOT assigned & active on the Account, raise an error
                                c.ICCS_Currencies__c.addError(' This Product - Country - Currency combination is NOT currently active on the selected Account.');
                            }
                        }
                    } // if (c.RecordTypeId == RT_ICCS.Id)
                } // for
            } // if (ThereAreICCSCases)
        }
        /*trgICCSCaseValidation Trigger*/

        /*Case_FSM_Handle_NonCompliance_BI_BU Trigger*/
        //Run only for non-compliance case. Put parent id (FSM Case) into a set
        if (Case_FSM_Handle_NonCompliance_BI_BU) {
            System.debug('____ [cls CaseBeforeTrigger - Case_FSM_Handle_NonCompliance_BI_BU]');
            for (Case NCCase : trigger.new) {
                if (NCCase.RecordTypeId == ProcessISSPcaseRecordTypeID) {
                    setFSMCaseId.add(NCCase.ParentId);
                }
            }
            if (!setFSMCaseId.isEmpty()) {
                mapFSMCases = new Map<ID, Case>([SELECT Id, Status, RecordTypeId, Account.Industry, FS_Letter_Sent__c, isClosed
                                                 , FS_Deadline_Date__c, FS_Second_Deadline_Date__c, FS_Third_Deadline_Date__c
                                                 , firstFSnonComplianceDate__c, secondFSnonComplianceDate__c, FS_third_non_compliance_date__c
                                                 FROM Case c 
                                                 WHERE Id IN :setFSMCaseId and RecordTypeId = :FSMcaseRecordTypeID]);
            }
        }
        /*Case_FSM_Handle_NonCompliance_BI_BU Trigger*/

        /*trgICCS_ASP_Case_Validation Trigger*/
        /** @author: Constantin BUZDUGA, blue-infinity
        * @description: This trigger only handles ICCS Cases with the "FDS ASP Management" record type and is used to ensure that:
        *       - there is only one open ASP case with the "FDS - Create ... " case area for any given account at any given time;
        *       - no ASP case can be closed unless all related tasks are closed (completed)
        * Since Oct 2015:
        *       - this trigger ensures that there is no more than one open "Airline Coding Application" case per account at the same time*/
        if (trgICCS_ASP_Case_Validation) {
            System.debug('____ [cls CaseBeforeTrigger - trgICCS_ASP_Case_Validation]');
            Set<Id> setRelatedAcctIds = new Set<ID>();
            Set<Id> setClosingCasesIds = new Set<Id>();
            for (Case c : Trigger.new) {

                System.debug(loggingLevel.ERROR, '____ [CaseBeforeTrigger - trgICCS_ASP_Case_Validation] case - ' + c.Previous_case_owner__c + ' owner ' + c.OwnerId);

                if ((c.RecordTypeId == RT_ICCS_ASP_Id && c.CaseArea__c == FDS) || c.RecordTypeId == AirlineCodingRTId )
                    setRelatedAcctIds.add(c.AccountId);
                if ( c.RecordTypeId == RT_ICCS_ASP_Id  && c.Status == 'Closed' && !Trigger.oldMap.get(c.Id).isClosed && c.AccountId != null )
                    setClosingCasesIds.add(c.Id);
            }
            
            // get a map of relevant cases per Account Id
            Map<Id, Case> mapCasesPerAccountId = new Map<Id, Case>(); // for ICCS ASP
            Map<Id, list<Case>> mapACCasesPerAccountId = new Map<Id, list<Case>>(); // for Airline coding, new from Oct 2015

            System.debug(loggingLevel.ERROR, '____ [CaseBeforeTrigger - trgICCS_ASP_Case_Validation] setRelatedAcctIds - ' + setRelatedAcctIds);            
            if (!setRelatedAcctIds.isEmpty()) {
                for (Case c : [SELECT Id, Subject, RecordTypeId, AccountId, IsClosed, CaseArea__c, Reason1__c 
                               FROM Case 
                               WHERE (RecordTypeId = :RT_ICCS_ASP_Id OR RecordTypeId = :AirlineCodingRTId) 
                                AND IsClosed = false AND AccountId IN :setRelatedAcctIds]) {
                    if (c.RecordTypeId == RT_ICCS_ASP_Id) {
                        mapCasesPerAccountId.put(c.AccountId, c);
                    }
                    if (c.RecordTypeId == AirlineCodingRTId  ) {
                        list<Case> listCase = mapACCasesPerAccountId.get(c.AccountId);
                        if (listCase == null) {
                            listCase = new list<Case>();
                        }
                        listCase.add(c);
                        mapACCasesPerAccountId.put(c.AccountId, listCase);
                    }
                }
            
                // Validate one single ASP creation case OR one single
                // only continue if there are new ASP creation cases
                for (Case c : Trigger.new) {
                    // if there's already an open case on the same account, get it
                    Case existingASPCase = mapCasesPerAccountId.get(c.AccountId);
                    // if the case is an ASP case and there already is an open ASP case on the same Account, raise an error
                    if ( c.RecordTypeId == RT_ICCS_ASP_Id  &&  c.CaseArea__c == FDS  
                         && existingASPCase != null && existingASPCase.CaseArea__c == FDS  
                         && existingASPCase.Id != c.Id) {
                        c.addError('There is already an open FDS ASP creation case on the selected Account. There can be only one open case of this type on an Account.');
                    }
                    // New from Oct 2015: if there's already another Airline Coding case open, raise an error
                    // Mod from 2016/04/05: this restriction is only when the case has the same Reason1__c
                    if (c.RecordTypeId == AirlineCodingRTId && mapACCasesPerAccountId.get(c.AccountId) != null) {
                        for (Case cse : mapACCasesPerAccountId.get(c.AccountId) ) {
                            if (cse.Reason1__c == c.Reason1__c && cse.Id != c.Id) {
                                c.addError('There is already an open Airline Coding Application case with Reason "' + c.Reason1__c + '" on the selected Account. There can be only one open case of this type on an Account.');
                            }
                        }
                    }
                }
            }
            // Prevent the closing of the ASP cases if there are related tasks still open
            // only continue if there are ASP cases getting closed
            System.debug(loggingLevel.ERROR, '____ [CaseBeforeTrigger - trgICCS_ASP_Case_Validation] setClosingCasesIds - ' + setClosingCasesIds);
            if (!setClosingCasesIds.isEmpty()) {
                //create a map of open tasks related to the cases
                Map<Id, Task> mapTasksPerCaseId = new Map<Id, Task>();
                for (Task t : [SELECT Id, WhatId FROM Task WHERE IsClosed = false AND WhatId IN :setClosingCasesIds]) {
                    mapTasksPerCaseId.put(t.WhatId, t);
                }
                for (Case c : Trigger.new) {
                    // if the case is being closed and there is a related open task, raise an error and don't allow the ASP case to be closed
                    if (setClosingCasesIds.contains(c.Id) && mapTasksPerCaseId.get(c.Id) != null) {
                        c.addError('You cannot close this case because there is at least one Task related to it that is still open.\nPlease mark all related Tasks as Complete and then try again to close the case.');
                    }
                }
            }
        }
        /*trgICCS_ASP_Case_Validation Trigger*/

        /*trgCreateUpdateServiceRenderedRecord Trigger*/
        //Trigger that creates a Service Rendered record if the Case Area is Airline Joining / Leaving, the case record type is "IDFS Airline Participation Process" and the case is approved
        if (trgCreateUpdateServiceRenderedRecord) {
            System.debug('____ [cls CaseBeforeTrigger - trgCreateUpdateServiceRenderedRecord]');
            string airlineLeaving = 'Airline Leaving';
            string airlineJoining = 'Airline Joining';
            string airlineSuspension = 'Airline Suspension Process';
            String separator = '%%%__%%%';
            Id APCaseRTID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IDFS_Airline_Participation_Process');

            List<Case> casesToTrigger = new List<Case>();
            for (case c: trigger.new) {
                if (!TransformationHelper.triggerOnCaseNSerRen && c.recordtypeId == APCaseRTID && (c.CaseArea__c == airlineJoining || c.CaseArea__c  == airlineLeaving || c.CaseArea__c  == airlineSuspension))
                    casesToTrigger.add(c);
            }
            if (!casesToTrigger.isEmpty()) {
                set<String> ServicesToCheck = new set<String>();
                map<String, Case_Reason_Service__c> ServicesPerReason  = new map<String, Case_Reason_Service__c>();
                list<Case> cases = new list<Case>();
                list<Case> casesValidation = new list<Case>();
                // this custom setting contains the infos regargind the need to reparent the provider to the hq to which the consumer belongs to.
                for (Case_Reason_Service__c ReasonServiceMapping : Case_Reason_Service__c.getall().values()) {
                    ServicesPerReason.put(ReasonServiceMapping.name, ReasonServiceMapping);
                    ServicesToCheck.add(ReasonServiceMapping.name);
                }
                string STC = '';
                for (string s : ServicesToCheck) {
                    STC += s + ', ';
                }
                system.debug('STC: ' + STC);
                //this logic is fired just when the case is inserted but not approved yet we just see if there's the need to reassign the provider by
                //taking a look at the custom setting where we keep this information
                ServiceRenderedCaseLogic.reparentProvider(casesToTrigger, ServicesToCheck, ServicesPerReason);
            }
        }
        /*trgCreateUpdateServiceRenderedRecord Trigger*/

        /*updateAccountFieldBasedOnIATAwebCode Trigger*/
        if (updateAccountFieldBasedOnIATAwebCode) {
            try {
                System.debug('____ [cls CaseBeforeTrigger - updateAccountFieldBasedOnIATAwebCode]');
                // For completing the Account Concerned (airline BR) automatically when the account is an airline and the IATA Country is specified:
                // list of cases where the country is specified and list of related account Ids
                List<Case> lstCasesWithBSPCountry = new List<Case>();
                List<Id> lstAccountIds = new List<Id>();
                // For completing the Account Concerned automatically when a Web IATA Code is specified:
                // Create a map of the search cases per search strings (keys = Web IATA code)
                Map<String, List<Case>> mapCasesPerWebIATACode = new Map<String, List<Case>>();
                // fill this map with the cases of interest and the processed web iata codes
                for (Case aCase : trigger.New) {
                    System.debug('____ [cls CaseBeforeTrigger - updateAccountFieldBasedOnIATAwebCode] RECORD TYPE: ' + aCase.RecordTypeId);
                    // check if correct record type
                    if ((aCase.RecordTypeId == SIDRAcaseRecordTypeID) || (aCase.RecordTypeId == ProcessISSPcaseRecordTypeID) || (aCase.RecordTypeId == EuropecaseRecordTypeID)
                            || (aCase.RecordTypeId == AmericacaseRecordTypeID) || (aCase.RecordTypeId == AfricaMEcaseRecordTypeID) || (aCase.RecordTypeId == AsiaPacificcaseRecordTypeID)
                            || (aCase.RecordTypeId == ChinaAsiacaseRecordTypeID) || (aCase.RecordTypeId == InternalcaseRecordTypeID) || (aCase.RecordTypeId == InvCollectioncaseRecordTypeID)
                            || (aCase.RecordTypeId == CSProcesscaseRecordTypeID) || (aCase.RecordTypeId == SEDAcaseRecordTypeID) || (aCase.RecordTypeId == ISSPcaseRecordTypeID)) {
                        system.debug('isInsert: ' + Trigger.isInsert);
                        system.debug('isUpdate: ' + Trigger.isUpdate);
                        system.debug('Account_Concerned__c: ' + aCase.Account_Concerned__c);
                        system.debug('BSPCountry__c: ' + aCase.BSPCountry__c);
                        system.debug('IATAcode__c: ' + aCase.IATAcode__c);
                        // Preliminary step for completing the Account Concerned when the account is an airline and the IATA Country is specified
                        // get the potentially concerned cases, by choosing those with an IATA Country not null
                        if (aCase.BSPCountry__c != null && ((Trigger.isInsert && aCase.Account_Concerned__c == null) 
                                                            || (Trigger.isUpdate && aCase.BSPCountry__c != Trigger.oldMap.get(aCase.Id).BSPCountry__c))) {
                            System.debug('____ [cls CaseBeforeTrigger - updateAccountFieldBasedOnIATAwebCode] Inside if 1');
                            lstCasesWithBSPCountry.add(aCase);
                            lstAccountIds.add(aCase.AccountId);
                        }
                        // Complete the Account Concerned automatically when a Web IATA Code is specified
                        if ((Trigger.isInsert && aCase.IATAcode__c != null && aCase.Account_Concerned__c == null) || ( Trigger.isUpdate && aCase.IATAcode__c != null && aCase.IATAcode__c != Trigger.oldMap.get(aCase.Id).IATAcode__c)) {
                            System.debug('____ [cls CaseBeforeTrigger - updateAccountFieldBasedOnIATAwebCode] Inside if 2');
                            // this will make sure the IATA code entered by the user would be searched in DB for lengths 7,8,10 and 11
                            String WebIATAcode = aCase.IATAcode__c;
                            String WebIATAcode2 = aCase.IATAcode__c;
                            system.debug('IATA CODE 1: ' + WebIATAcode + ' length: ' + WebIATAcode.length());
                            if (WebIATAcode.length() == 8)
                                WebIATAcode = WebIATAcode.substring(0, 7);
                            if (WebIATAcode.length() == 11)
                                WebIATAcode = WebIATAcode.substring(0, 10);
                            system.debug('IATA CODE 2: ' + WebIATAcode + ' length: ' + WebIATAcode.length());
                            //in case the user enters 7 digits we need to get the 8th digit
                            if (WebIATAcode.length() == 7 && WebIATAcode2.length() == 7 && WebIATAcode.isNumeric() ) {
                                String t = WebIATAcode.trim();
                                Long a = Long.valueof(t);
                                Long remainder = math.mod(a, 7);
                                WebIATAcode = WebIATAcode  + remainder ;
                            }
                            system.debug('IATA CODE 3: ' + WebIATAcode + ' length: ' + WebIATAcode.length());
                            //in case the user enters 10 digits we need to get the 11th digit
                            if (WebIATAcode.length() == 10 && WebIATAcode2.length() == 10 && WebIATAcode.isNumeric() ) {
                                String t = WebIATAcode.trim();
                                Long a = Long.valueof(t);
                                Long remainder = math.mod(a, 7);
                                WebIATAcode = WebIATAcode + remainder ;
                            }
                            system.debug('IATA CODE 4: ' + WebIATAcode + ' length: ' + WebIATAcode.length());
                            // Create an entry in the map for the processed key
                            if  (mapCasesPerWebIATACode.get(WebIATAcode) == null) {
                                mapCasesPerWebIATACode.put(WebIATAcode, new List<Case>());
                            }
                            mapCasesPerWebIATACode.get(WebIATAcode).add(aCase);
                            // and another one for the initial (user-entered, unprocessed) key - if it is different from the processed one
                            if (WebIATAcode2 != WebIATAcode) {
                                if  (mapCasesPerWebIATACode.get(WebIATAcode2) == null) {
                                    mapCasesPerWebIATACode.put(WebIATAcode2, new List<Case>());
                                }
                                mapCasesPerWebIATACode.get(WebIATAcode2).add(aCase);
                            }
                        }
                    }
                }
                // Web IATA Code > Account Concerned
                // Match the processed & unprocessed Web IATA Code with the Account Site on the Account records
                system.debug('mapCasesPerWebIATACode.keyset(): ' + mapCasesPerWebIATACode.keyset());
                if (!mapCasesPerWebIATACode.keyset().isEmpty()) {
                
                    // Update the Cases with the Account or Account Concerned info retrieved from the DB - only if the found Account / Account Concerned is different from the Account in the Case
                    for (Account acc : [SELECT Id, Site FROM Account WHERE Site_Index__c IN :mapCasesPerWebIATACode.keyset()]) {
                        for (Case c : mapCasesPerWebIATACode.get(acc.Site)) {
                            if (c.AccountId != acc.Id) {
                                if ( c.RecordTypeId == EuropecaseRecordTypeID || c.RecordTypeId == AmericacaseRecordTypeID 
                                    || c.RecordTypeId == AfricaMEcaseRecordTypeID || c.RecordTypeId == AsiaPacificcaseRecordTypeID 
                                    || c.RecordTypeId == ChinaAsiacaseRecordTypeID || c.RecordTypeId == ISSPcaseRecordTypeID ) {
                                    // For these record types, set the Account Concerned field
                                    system.debug('FOUND AND SETTING Account Concerned');
                                    c.Account_Concerned__c = acc.Id;
                                } else {
                                    // For the other record types, keep the initial behaviour of the case and set the Account field on the case
                                    system.debug('FOUND AND SETTING Account');
                                    c.AccountId = acc.Id;
                                }
                            }
                        }
                    }
                }
                // Airline & IATA Country > Account Concerned
                if (!lstAccountIds.isEmpty()) {

                    // Get a map of related accounts - only airlines
                    set<String> setAirlineAccountRTs = new set<String> {'IATA_Airline', 'IATA_Airline_BR'};
                    Map<Id, Account> mapRelatedAirlineAccounts 
                        = new Map<Id, Account>([SELECT Id, Airline_designator__c, IATACode__c, IATA_ISO_Country__r.ISO_Code__c, Site 
                                               FROM Account WHERE RecordType.DeveloperName IN :setAirlineAccountRTs]);

                    Map<Id, Account> mapRelatedAirlineAccountsPerId = new Map<Id, Account>();

                    for(ID accID : lstAccountIds){
                        if(mapRelatedAirlineAccounts.containsKey(accID))
                            mapRelatedAirlineAccountsPerId.put(accID, mapRelatedAirlineAccounts.get(accID));
                    }

                    // continue only if there are airline accounts
                    if (!mapRelatedAirlineAccountsPerId.values().isEmpty()) {
                        // Get all the ISO Countries & create a map, using the Case BSP Country as key
                        Map<String, String> mapCountryCodePerBSPName = new Map<String, String>();
                        for (IATA_ISO_Country__c ic : IATAIsoCountryDAO.getIsoCountries()) {
                            mapCountryCodePerBSPName.put(ic.Case_BSP_Country__c, ic.ISO_Code__c);
                        }
                        // Build a search map for accounts concerned: the key is the searched account site (created with the data from the account on the case + the code
                        // of the country on the case), the value is a list of cases
                        map<String, List<Case>> mapCasesListPerAccountSite = new map<String, List<Case>>();
                        for (Case c : lstCasesWithBSPCountry) {
                            // we only look for the account concerned if it's different from the account on the case, which means the country needs to be different
                            if (mapCountryCodePerBSPName.get(c.BSPCountry__c) != mapRelatedAirlineAccountsPerId.get(c.AccountId).IATA_ISO_Country__r.ISO_Code__c) {
                                // Site = related account 2-letter code + related account iata code + country code of the country on the case
                                String searchedAccSite = mapRelatedAirlineAccountsPerId.get(c.AccountId).Airline_designator__c + ' ' + mapRelatedAirlineAccountsPerId.get(c.AccountId).IATACode__c + ' ' + mapCountryCodePerBSPName.get(c.BSPCountry__c);
                                if (mapCasesListPerAccountSite.get(searchedAccSite) == null) {
                                    mapCasesListPerAccountSite.put(searchedAccSite, new List<Case>());
                                }
                                mapCasesListPerAccountSite.get(searchedAccSite).add(c);
                            }
                        }
                        if (!mapCasesListPerAccountSite.keyset().isEmpty()) {

                            // search for accounts with that account site
                            for(Account account : mapRelatedAirlineAccounts.values()){
                                if(mapCasesListPerAccountSite.containsKey(account.Site)) {

                                    // update all the cases with the account concerned
                                    for (Case c : mapCasesListPerAccountSite.get(account.Site)) {
                                        if (c.AccountId != account.Id) {
                                            if (c.RecordTypeId == EuropecaseRecordTypeID || c.RecordTypeId == AmericacaseRecordTypeID 
                                                || c.RecordTypeId == AfricaMEcaseRecordTypeID || c.RecordTypeId == AsiaPacificcaseRecordTypeID 
                                                || c.RecordTypeId == ChinaAsiacaseRecordTypeID || c.RecordTypeId == ISSPcaseRecordTypeID ) {
                                                // For these record types, set the Account Concerned field
                                                system.debug('FOUND AND SETTING Account Concerned');
                                                c.Account_Concerned__c = account.Id;
                                            } else {
                                                // For the other record types, keep the initial behaviour of the case and set the Account field on the case
                                                system.debug('FOUND AND SETTING Account');
                                                c.AccountId = account.Id;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } catch (Exception e) {
                System.debug('____ [cls CaseBeforeTrigger - updateAccountFieldBasedOnIATAwebCode - ERROR: ' + e + ' ]');
            }
        }
        /*updateAccountFieldBasedOnIATAwebCode Trigger*/

        /*trgAccelyaRequestSetCountry Trigger*/
        //GM - IMPRO - START
        //this trigger doesn't work... 
        //the for loop below needs a list to be filled, the loop below does really fire on all the cases or just on the Accelya subset?
        if (trgAccelyaRequestSetCountry) {
            System.debug('____ [cls CaseBeforeTrigger - trgAccelyaRequestSetCountry]');
            for (Case aCase : trigger.New) {
                if (aCase.RecordTypeId == CSRcaseRecordTypeID) {
                    isAccelya = true;
                } else {
                    break;
                }
            }
            if (isAccelya) {
                List<String> bspCountryList = new List<String>();
                for (Case c : trigger.New) {
                    if ((c.Case_Creator_Email__c == null || !(c.Case_Creator_Email__c.contains('@iata.org'))) && c.Accelya_Request_Type__c != null && c.Country_concerned__c != null && c.BSPCountry__c == null) {
                        bspCountryList = c.Country_concerned__c.split(';');
                        c.BSPCountry__c = bspCountryList[0];
                        c.RecordTypeId = CSRcaseRecordTypeID;
                        System.debug('BSP Country ----> ' + c.BSPCountry__c);
                        //GM - IMPRO - END
                    }
                }
            }
        }
        /*trgAccelyaRequestSetCountry Trigger*/

        /*trgBeforeInsertUpdate Trigger*/ 
        /*This trigger assigns the correct group to case based on the Owner Profile, taking it from the Email2CasePremium custom setting*/
        if (trgBeforeInsertUpdate) { //FLAG
            System.debug('____ [cls CaseBeforeTrigger - trgBeforeInsertUpdate]');
            //INC239697
            for (Case cse : Trigger.new) {
                CS_Email2CasePremium__c code;
                if (cse.Groups__c != 'CNS Team') {
                    cse.Groups__c = 'Default';

                    if (cse.OwnerProfile__c != null && cse.OwnerProfile__c != '')
                        code = CS_Email2CasePremium__c.getInstance(cse.OwnerProfile__c);
                    if (code != null) {
                        cse.Groups__c = code.Group__c;
                    }

                    code = CS_Email2CasePremium__c.getInstance(cse.RecordTypeId);
                    if (code != null) {
                        cse.Groups__c = code.Group__c;
                    }
                }
            }
        }
        /*trgBeforeInsertUpdate Trigger*/

        /*trgCustomerPortalCaseSharing Trigger*/
        //Created Date - 14-June-2010 - This trigger is used to call the CaseSharing Class to share the case records to Customer portal users and update the Case Owner field displayed in the Customer Portal
        if (trgCustomerPortalCaseSharing) {
            System.debug('____ [cls CaseBeforeTrigger - trgCustomerPortalCaseSharing]');
            try {
                String CPCcaseRecType;
                BusinessHours bHourObj = new BusinessHours();
                Set<Id> UserIds = new Set<Id>();
                list<User> lstUsers = new List<User>();
                list<QueueSobject> lstQueue = new List<QueueSobject>();
                //GM - IMPRO - START
                //the control on record type has been thought for a single insert only
                for (Case ObjCaseNew : Trigger.New) {
                    CPCcaseRecType = ObjCaseNew.RecordTypeId;
                    UserIds.add(ObjCaseNew.OwnerId);
                }

                if (CPCcaseRecType == PortalRecordTypeID) {
                    lstUsers = [Select Id, Name FROM User WHERE Id IN : UserIds and IsActive = : True];
                    bHourObj = [Select id, name FROM BusinessHours where name = : 'EUR - France'];
                    for (Case ObjCaseNew : Trigger.New) {
                        ObjCaseNew.BusinessHoursId = bHourObj.Id;
                    }
                    if (lstUsers.Size() > 0) {
                        for (Case ObjCaseNew : Trigger.New) {
                            for (Integer i = 0; i < lstUsers.Size(); i++) {
                                if (ObjCaseNew.OwnerId == lstUsers[i].Id) {
                                    ObjCaseNew.Case_Owner_CP__c = lstUsers[i].Name;
                                    System.debug('Owner name: ' + ObjCaseNew.Case_Owner_CP__c);
                                    break;
                                }
                            }
                        }
                    } else {
                        lstQueue = [SELECT Id, Queue.Id, Queue.Name, Queue.Type FROM QueueSobject WHERE Queue.Id IN : UserIds];
                        if (lstQueue.Size() > 0) {
                            for (Case ObjCaseNew : Trigger.New) {
                                for (Integer i = 0; i < lstQueue.Size(); i++) {
                                    if (ObjCaseNew.OwnerId == lstQueue[i].QueueId) {
                                        ObjCaseNew.Case_Owner_CP__c = lstQueue[i].Queue.Name;
                                        break;
                                    }
                                }
                            }
                        } //lstQueue.Size
                    } //else
                } //if CPCcaseRecType
            }//GM - IMPRO - END
            catch (Exception e) {
                System.debug('____ [cls CaseBeforeTrigger - trgCustomerPortalCaseSharing - Error Message: ' + e.getMessage() + ']');
            }
        } //if trgCustomerPortalCaseSharing
        /*trgCustomerPortalCaseSharing Trigger*/

        /*trgProcessISSCase */ 
        if(trgProcessISSCase){
            System.debug('____ [cls CaseBeforeTrigger - trgProcessISSCase]');
            Set<ID> parentId = new Set<ID>();
            for (Case newCase : trigger.new) {
                if (newCase.RecordTypeId == ProcessISSPcaseRecordTypeID){
                    parentId.add(newCase.ParentId);
                }
            }
            for(Case curCase : [SELECT c.Id, c.ParentId, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, 
                                    c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, 
                                    c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c
                                FROM Case c WHERE c.Id IN :parentId]){

                if(!parentCaseMap.containsKey(curCase.ParentId))
                    parentCaseMap.put(curCase.ParentId, new List<Case>{curCase});
                else
                    parentCaseMap.get(curCase.ParentId).add(curCase);
            }
            for (Case newCase : trigger.new) {
                // only process case of type SAAM
                if (newCase.RecordTypeId == ProcessISSPcaseRecordTypeID) {
                    // get parent case
                    Case[] parentCase = parentCaseMap.get(newCase.ParentId);
                    if (parentCase != null && parentCase.size() > 0) {
                        // check if parent case is an IFAP case
                        if (parentCase[0].RecordTypeId == IFAPcaseRecordTypeID) {
                            // first business rule
                            if (parentCase[0].FA_Letter_Sent__c == False && (parentCase[0].Status == 'Agent Notified (Mail)' || parentCase[0].Status == 'Agent Notified (Email)'
                                    || parentCase[0].Status == 'Financial Statements Uploaded' || parentCase[0].Status == 'Sanity Check Failure')) {
                                newCase.addError('The ?FA Letter Sent? check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed.');
                            }
                            // second business rule
                            if (parentCase[0].FS_Letter_Sent__c == False && parentCase[0].Status == 'Financial Security Requested') {
                                newCase.addError('The ?FS Letter Sent? check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed');
                            }
                            // third business rule
                            if (newCase.Status == 'Open' && newCase.Reason1__c == 'FA/ FS Non-Compliance' && (parentCase[0].Status == 'Action Needed'
                                    || parentCase[0].Status == 'Agent to be Notified' || parentCase[0].Status == 'Agent to be notified (Email)'
                                    || parentCase[0].Status == 'Assessment Performed' || parentCase[0].Status == 'Financial Security Provided'
                                    || parentCase[0].Status == 'Re-open/ed' || parentCase[0].Status == 'Submitted'
                                    || parentCase[0].Status == 'Assessment Cancelled' || parentCase[0].Status == 'Closed')) {
                                newCase.addError('A Non-compliance case cannot be updated when the parent case status is ' + parentCase[0].Status);
                            }
                        }
                    }
                }
            }
        }
        /*trgProcessISSCase */ 
    }
/*Share trigger code*/

/************************************************** Trigger.isInsert **************************************************************************************************/
    if (Trigger.isInsert) {

        /*trgCase Trigger.isInsert*/
        if (trgCase) { 
            System.debug('____ [cls CaseBeforeTrigger - trgCase Trigger.isInsert]');
            SidraLiteManager.insertSidraLiteCases(Trigger.new);
        }
        /*trgCase Trigger.isInsert*/

        /*trgProcessISSCase Trigger.isInsert*/
        if (trgProcessISSCase) { 
            System.debug('____ [cls CaseBeforeTrigger - trgProcessISSCase Trigger.isInsert]');
            // loop tru cases to be created
            for (Case newCase : trigger.new) {
                // only process case of type SAAM
                if (newCase.RecordTypeId == ProcessISSPcaseRecordTypeID) {
                    // get parent case
                    Case[] parentCase = parentCaseMap.get(newCase.ParentId);
                    if (parentCase != null && parentCase.size() > 0) {
                        // check if parent case is an IFAP case
                        if (parentCase[0].RecordTypeId == IFAPcaseRecordTypeID) {
                            // Fix for INC054114: 03-July-2013 - assign non-compliance dates
                            if (newCase.CaseArea__c == 'Accreditation Process' && newCase.reason1__c == 'FA/ FS Non-Compliance' && newCase.Origin == 'Internal Case') {
                                // flags
                                Boolean isPassengerDomestic = (parentCase[0].Account.Type == 'IATA Passenger Sales Agent' || parentCase[0].Account.Type == 'Domestic Agent');
                                Boolean isCargoCASS = (parentCase[0].Account.Type == 'IATA Cargo Agent' || parentCase[0].Account.Type == 'CASS Associate');
                                // the deadline date must not be set for Passenger/Domestic Agents
                                if (isPassengerDomestic && newCase.New_IFAP_Deadline_date__c != null) {
                                    newCase.addError('The New IFAP Deadline date must be empty for non-compliance cases on Passenger and Domestic agents');
                                    continue;
                                }
                                //set IFAP case non compliance date
                                //BRD: Item 2.4
                                if (parentCase[0].Status == 'Financial Security Requested') {
                                    //FS non compliance case
                                    if (parentCase[0].firstFSnonComplianceDate__c == null) {
                                        // cannot create a 1st FS non-compliance case if 1st deadline date has not been reached yet
                                        if (parentCase[0].FS_Deadline_Date__c >= Date.today()) {
                                            newCase.addError('Cannot create a 1st FS non-compliance case. The 1st FS Deadline is ' + parentCase[0].FS_Deadline_Date__c.format());
                                            continue;
                                        }
                                        parentCase[0].firstFSnonComplianceDate__c = Date.today();
                                        // set 2nd FS deadline date for PAX and Domestic agents
                                        if (isPassengerDomestic) {
                                            // business rule: 31 days after the non-compliance case is raised
                                            parentCase[0].FS_Second_Deadline_Date__c = parentCase[0].firstFSnonComplianceDate__c.addDays(31);
                           
                                        } else if (isCargoCASS) {
                                            if (newCase.New_IFAP_Deadline_date__c == null) {
                                                newCase.addError('The New IFAP Deadline date is mandatory when creating a 1st non-compliance for Cargo or CASS agents.');
                                                continue;
                                            } else {
                                                // copy deadline date to IFAP case
                                                parentCase[0].FS_Second_Deadline_Date__c = newCase.New_IFAP_Deadline_date__c;
                                            }
                                        }
                                    } else if (parentCase[0].secondFSnonComplianceDate__c == null) {
                                        // cannot create a 2nd FS non-compliance case if 2nd deadline date has not been reached yet
                                        if (parentCase[0].FS_Second_Deadline_Date__c >= Date.today()) {
                                            newCase.addError('Cannot create a 2nd FS non-compliance case. The 2nd FS Deadline is ' + parentCase[0].FS_Second_Deadline_Date__c.format());
                                            continue;
                                        }
                                        parentCase[0].secondFSnonComplianceDate__c = Date.today();
                                        // set 3rd FS deadline date for PAX and Domestic agents
                                        if (isPassengerDomestic) {
                                            // business rule: 31 days after the non-compliance case is raised
                                            Date inTwoMonths = parentCase[0].secondFSnonComplianceDate__c.addMonths(2);
                                            Date newDeadline = Date.newInstance(inTwoMonths.year(), inTwoMonths.month(), 1);
                                            newDeadline = newDeadline.addDays(-1);
                                            parentCase[0].FS_Third_Deadline_Date__c = newDeadline;
                                        } else if (isCargoCASS) {
                                            if (newCase.New_IFAP_Deadline_date__c == null) {
                                                newCase.addError('The New IFAP Deadline date is mandatory when creating a 1st non-compliance for Cargo or CASS agents.');
                                                continue;
                                            } else {
                                                // copy deadline date to IFAP case
                                                parentCase[0].FS_Third_Deadline_Date__c = newCase.New_IFAP_Deadline_date__c;
                                            }
                                        }
                                    } else {
                                        newCase.addError('Cannot create a 3rd FS non-compliance case.');
                                    }
                                } else {
                                    // 1st FA non-compliance case
                                    if (parentCase[0].firstFAnonComplianceDate__c == null) {
                                        // cannot create a 1st FA non-compliance case if 1st deadline date has not been reached yet
                                        if (parentCase[0].Deadline_Date__c >= Date.today()) {
                                            newCase.addError('Cannot create a 1st FA non-compliance case. The 1st FA Deadline is ' + parentCase[0].Deadline_Date__c.format());
                                            continue;
                                        }
                                        parentCase[0].firstFAnonComplianceDate__c = Date.today();
                                        // set 2nd FA deadline date for PAX and Domestic agents
                                        if (isPassengerDomestic) {
                                            // business rule: 31 days after the non-compliance case is raised
                                            parentCase[0].FA_Second_Deadline_Date__c = parentCase[0].firstFAnonComplianceDate__c.addDays(31);
                                        } else if (isCargoCASS) {
                                            if (newCase.New_IFAP_Deadline_date__c == null) {
                                                newCase.addError('The New IFAP Deadline date is mandatory when creating a 1st non-compliance for Cargo or CASS agents.');
                                                continue;
                                            } else {
                                                // copy deadline date to IFAP case
                                                parentCase[0].FA_Second_Deadline_Date__c = newCase.New_IFAP_Deadline_date__c;
                                            }
                                        }
                                    } else if (parentCase[0].secondFAnonComplianceDate__c == null) {
                                        // 2nd FA non-compliance
                                        // cannot create a 2nd FA non-compliance case if 2nd deadline date has not been reached yet
                                        if (parentCase[0].FA_Second_Deadline_Date__c >= Date.today()) {
                                            newCase.addError('Cannot create a 2nd FA non-compliance case. The 2nd FA Deadline is ' + parentCase[0].FA_Second_Deadline_Date__c.format());
                                            continue;
                                        }
                                        parentCase[0].secondFAnonComplianceDate__c = Date.today();
                                        // set 3rd FA deadline date for PAX and Domestic agents
                                        if (isPassengerDomestic) {
                                            // business rule: the last day of the following month after the non-compliance case is raised
                                            Date inTwoMonths = parentCase[0].secondFAnonComplianceDate__c.addMonths(2);
                                            Date newDeadline = Date.newInstance(inTwoMonths.year(), inTwoMonths.month(), 1);
                                            newDeadline = newDeadline.addDays(-1);
                                            parentCase[0].FA_Third_Deadline_Date__c = newDeadline;
                                        } else if (isCargoCASS) {
                                            if (newCase.New_IFAP_Deadline_date__c == null) {
                                                newCase.addError('The New IFAP Deadline date is mandatory when creating a 2nd non-compliance for Cargo or CASS agents.');
                                                continue;
                                            } else {
                                                // copy deadline date to IFAP case
                                                parentCase[0].FA_Third_Deadline_Date__c = newCase.New_IFAP_Deadline_date__c;
                                            }
                                        }
                                    } else if (parentCase[0].Third_FA_non_Compliance_Date__c == null) {
                                        // 3rd FA non-compliance
                                        // cannot create a 3rd FA non-compliance case if 3rd deadline date has not been reached yet
                                        if (parentCase[0].FA_Third_Deadline_Date__c >= Date.today()) {
                                            newCase.addError('Cannot create a 3rd FA non-compliance case. The 3rd FA Deadline is ' + parentCase[0].FA_Third_Deadline_Date__c.format());
                                            continue;
                                        } else {
                                            parentCase[0].Third_FA_non_Compliance_Date__c = Date.today();
                                        }
                                    } else {
                                        // 4th non-compliance is blocked
                                        newCase.addError('Cannot create a 4th FA non-compliance case.');
                                    }
                                }
                                update parentCase[0];
                            }
                        }
                    }
                }
            }
        }
        /*trgProcessISSCase Trigger.isInsert*/

        /*trgCaseIFAP Trigger.isInsert*/
        if (trgCaseIFAP) {
            if (!CaseChildHelper.noValidationsOnTrgCAseIFAP) {
                System.debug('____ [cls CaseBeforeTrigger - trgCaseIFAP Trigger.isInsert]');
                //Get User profile 
                currentUserProfile = getUserProfile();

                Map<ID, List<Case>> mapAccountCases = new Map<ID, List<Case>>();
            
                //accountHasClosedCases
                if(!IFAPaccountIds.isEmpty()){
                    for(Case currentCase : [SELECT c.Status, c.IFAP_Financial_Year__c, c.IFAP_Financial_Month__c, c.AccountId, c.RecordTypeId FROM Case c 
                                            WHERE c.AccountId IN :IFAPaccountIds AND c.Status = 'Closed' AND c.RecordTypeId = : IFAPcaseRecordTypeID]){

                        if(!mapAccountCases.containsKey(currentCase.AccountId))
                            mapAccountCases.put(currentCase.AccountId, new List<Case>{currentCase});
                        else
                            mapAccountCases.get(currentCase.AccountId).add(currentCase);
                    }
                }

                for (Case newCase : Trigger.New) {
                    // only consider IFAP cases
                    if (newCase.RecordTypeId == IFAPcaseRecordTypeID) {
                        // validate the account's country
                        if (!IFAP_BusinessRules.isCountryValid(newCase, accountMap)) { //if false
                            newCase.addError('The account\'s country is not valid.');
                        } else
                            IFAP_BusinessRules.setCountryAreaAndISOCode(newCase, accountMap);
                        // validate the Agent Code if the financial review type is not 'New'
                        if (newCase.Financial_Review_Type__c != 'New applications')
                            //the check on the agent code is done only on number of characters 7<X<11, sure is correct?
                            if (!IFAP_BusinessRules.isAgentCodeValid(newCase, accountMap))
                                newCase.addError('The contact\'s Agent Code is not valid.');

//Check with Gavinho  - Query inside of the for 

                        if (!IFAP_BusinessRules.IsStatusCanBeSelected(true, newCase, null, currentUserProfile, isIfapAuthorizedUser)) {
                            newCase.addError('This following case status cannot be selected: ' + newCase.status);
                        }
                        //GM - IMPRO - START
                        // check if the FA template's country matches the case country
                        if (newCase.EmailTemplate__c != null) {
                            for (EmailTemplate__c EmTe : IFAPemailtemplate) {
                                if (EmTe.Id == newCase.EmailTemplate__c && !IFAP_BusinessRules.isTemplateCountryValid(EmTe, newCase.IFAP_Country_ISO__c)) {
                                    newCase.addError('The selected Initial Request Email Template does not match the case country.');
                                    break;
                                }
                            }
                        }
                        // check if the FA reminder template's country matches the case country
                        if (newCase.Reminder_EmailTemplate__c != null) {
                            for (EmailTemplate__c REmTe : IFAPemailtemplate) {
                                if (REmTe.Id == newCase.Reminder_EmailTemplate__c && !IFAP_BusinessRules.isTemplateCountryValid(REmTe, newCase.IFAP_Country_ISO__c)) {
                                    newCase.addError('The selected Reminder Email Template does not match the case country.');
                                    break;
                                }
                            }
                        }
                        // check if the FS template's country matches the case country
                        if (newCase.FS_EmailTemplate__c != null) {
                            for (EmailTemplate__c FSEmTe : IFAPemailtemplate) {
                                if (FSEmTe.Id == newCase.FS_EmailTemplate__c && !IFAP_BusinessRules.isTemplateCountryValid(FSEmTe, newCase.IFAP_Country_ISO__c)) {
                                    newCase.addError('The selected FS Email Template does not match the case country.');
                                    break;
                                }
                            }
                        }
                        // check if the FS reminder template's country matches the case country
                        if (newCase.FS_Reminder_EmailTemplate__c != null) {
                            for (EmailTemplate__c FSREmTe : IFAPemailtemplate) {
                                if (FSREmTe.Id == newCase.FS_Reminder_EmailTemplate__c && !IFAP_BusinessRules.isTemplateCountryValid(FSREmTe, newCase.IFAP_Country_ISO__c)) {
                                    newCase.addError('The selected FS Reminder Email Template does not match the case country.');
                                    break;
                                }
                            }
                        }
                        //GM - IMPRO - END
                        // Phase 4
                        // check if the agent already has closed case for the same financial year and if the checkbox has been checked
//Check with Gavinho
                        List<Case> caseClosedList = mapAccountCases.get(newCase.AccountId);
                        if (!caseClosedList.isEmpty() && newCase.IFAP_CanCreateWhileClosedCase__c == false && IFAP_BusinessRules.checkIFAPFinancialYear(caseClosedList,newCase.IFAP_Financial_Year__c))
                            newCase.addError('The selected agent already has a closed IFAP case for the financial year ' + newCase.IFAP_Financial_Year__c + '. Please confirm that you really wish to create another IFAP case for this account by checking the confirmation check box at the bottom of this page.');
                        else if (caseClosedList.isEmpty() && newCase.IFAP_CanCreateWhileClosedCase__c && !IFAP_BusinessRules.checkIFAPFinancialYear(caseClosedList,newCase.IFAP_Financial_Year__c))
                            newCase.addError('The selected account does not have any closed IFAP cases. Please uncheck the confirmation check box at the bottom of this page');
                        // check if Parent case already has child IFAP cases
                        List<Case> caseSAAMList = mapSAAMParentIDCase.get(newCase.ParentId);
                        List<Case> caseIFAPList = mapIFAPParentIDCase.get(newCase.ParentId);
                        if (String.valueOf(newCase.ParentId) != '' && (caseSAAMList != null && caseSAAMList.size() > 0) && (caseIFAPList != null && caseIFAPList.size() > 0)) {
                            newCase.addError('The parent SAAM case already has an IFAP case.');
                        }
                    }
                }
            }
        }
        /*trgCaseIFAP Trigger.isInsert*/

        /*UserInfoUpdate Trigger.isInsert*/
        if (UserInfoUpdate) { 
            System.debug('____ [cls CaseBeforeTrigger - UserInfoUpdate Trigger.isInsert]');
            for (Case aCase : Trigger.New) {
                if ((aCase.RecordTypeId == SIDRAcaseRecordTypeID) || (aCase.RecordTypeId == SIDRABRcaseRecordTypeID )) {
                    //check if fields are not null then update name field
                    if (aCase.CS_Contact_Result__c != null)
                        aCase.CS_Rep_Contact_Customer__c = UserInfo.getUserId();
                    if (aCase.Update_AIMS_IRR__c != null)
                        aCase.CS_Rep_Acc_IRR_DEF__c = UserInfo.getUserId();
                    if (aCase.Update_AIMS_DEF__c != null)
                        aCase.CS_Rep_Acc_DEF__c = UserInfo.getUserId();
                    if (aCase.Update_AIMS_IRRWITH__c != null)
                        aCase.CS_Rep_ACC_IRR_Withdrawal__c = UserInfo.getUserId();
                    if (aCase.Update_AIMS_REI_DEFWITH__c != null)
                        aCase.CS_Rep_Acc_REI__c = UserInfo.getUserId();
                    if (aCase.Update_AIMS_TER__c != null)
                        aCase.CS_Rep_ACC_TER__c = UserInfo.getUserId();
                }
            }
        }
        /*UserInfoUpdate Trigger.isInsert*/

        /*trgCheckBusinessHoursBeforeInsert Trigger.isInsert*/
        if (trgCheckBusinessHoursBeforeInsert) {
            System.debug('____ [cls CaseBeforeTrigger - trgCheckBusinessHoursBeforeInsert Trigger.isInsert]');
            if (hasOneSISCase) {
//Check With Gavinho
                CheckBusinessHoursHelperclass.trgCheckBusinessHoursBeforeInsert(Trigger.new, CBHContactMap, CBHAccountMap);
            }
        }
        /*trgCheckBusinessHoursBeforeInsert Trigger.isInsert*/

        /*trgSidraCaseBeforeInsertUpdate Trigger.isInsert*/
        if (trgSidraCaseBeforeInsertUpdate) {
            System.debug('____ [cls CaseBeforeTrigger - trgSidraCaseBeforeInsertUpdate Trigger.isInsert]');
            // automatically fill in the exchange rate using the rate stored in the system for the SIDRA cases
            set<String> setCurrencies = new set<String>();
            for (Case c : trigger.new) {
                if ((c.RecordTypeId == SIDRAcaseRecordTypeID || c.RecordTypeId == SEDAcaseRecordTypeID) && c.Currency__c != null) {
                    setCurrencies.add(c.Currency__c);
                }
                if (c.RecordTypeId == SEDAcaseRecordTypeID) {
                    if (c.Demand_by_Email_Fax__c!=null) {
                        c.CS_Rep_Contact_Customer__c = UserInfo.getUserId();
                    }
                }
            }
            map<String, CurrencyType> mapCurrencyTypePerCurrencyCode = new map<String, CurrencyType>();
            if (! setCurrencies.isEmpty()) {
                for (CurrencyType ct : [SELECT Id, IsoCode, ConversionRate FROM CurrencyType WHERE IsoCode IN :setCurrencies]) {
                    mapCurrencyTypePerCurrencyCode.put(ct.IsoCode, ct);
                }
            }
            if (! mapCurrencyTypePerCurrencyCode.values().isEmpty()) {
                for (Case c : trigger.new) {
                    if (mapCurrencyTypePerCurrencyCode.get(c.Currency__c) != null) {
                        c.CurrencyExchangeRateUSD__c = mapCurrencyTypePerCurrencyCode.get(c.Currency__c).ConversionRate;
                        c.SIDRA_exchange_rate_updated__c = true;
                    }
                }
            }
        }
        /*trgSidraCaseBeforeInsertUpdate Trigger.isInsert*/

        /*Case_FSM_Handle_NonCompliance_BI_BU Trigger.isInsert*/
        if (Case_FSM_Handle_NonCompliance_BI_BU) {
            System.debug('____ [cls CaseBeforeTrigger - Case_FSM_Handle_NonCompliance_BI_BU Trigger.isInsert]');
            //FSM Case(s) found! Proceed with the logic
            if (!setFSMCaseId.isEmpty()) {
                map<Id, Case> mapFSMCaseToUpdate = new map<Id, Case>(); //List of FSM case to update
                //Search Parent Case (FSM)
                for (Case NCCase : trigger.new) {
                    if (NCCase.RecordTypeId == ProcessISSPcaseRecordTypeID && mapFSMCases.keyset().contains(NCCase.ParentId)) {
                        Case FSMCase;
                        if (mapFSMCaseToUpdate.containsKey(NCCase.ParentId))
                            FSMCase = mapFSMCaseToUpdate.get(NCCase.ParentId);
                        else
                            FSMCase = mapFSMCases.get(NCCase.ParentId);
                        string AccntType = FSMCase.Account.Industry;    //Type of account. Cargo Agent / Travel Agent

                        if (Trigger.isInsert) {
                            if (NCCase.CaseArea__c == 'Accreditation Process' && NCCase.reason1__c == 'FA/ FS Non-Compliance' && NCCase.Origin == 'Internal Case') {
                                //1st check: letter must be sent prior non-compliance opening
                                if (FSMCase.FS_Deadline_Date__c != null) {
                                    //Cannot open non-compliance for closed FSM Case
                                    if (FSMCase.isClosed == false) {
                                        string sMsgCargoCheckNewDate = CargoDateValid(NCCase.New_IFAP_Deadline_date__c);
                                        if (FSMCase.firstFSnonComplianceDate__c == null) {
                                            //Cannot create 1st non-compliance if first deadline >= today
                                            if (FSMCase.FS_Deadline_Date__c >= Date.today()) {
                                                NCCase.addError('Cannot create a 1st FS non-compliance case. The 1st FS Deadline is ' + FSMCase.FS_Deadline_Date__c.format());
                                            } else {
                                                //Ok, we can create the 1st non-compliance case. Let's go!
                                                if (AccntType == PAX) {
                                                    //Just to cover some additional lines in test
                                                    if (test.isRunningTest()) {
                                                        date dt = getMondayIfOnWeekend(date.NewInstance(2015, 2, 15));
                                                        dt = getMondayIfOnWeekend(date.NewInstance(2015, 2, 14));
                                                    }
                                                    FSMCase.FS_Second_Deadline_Date__c = getMondayIfOnWeekend(date.Today().addDays(31));
                                                }
                                                if (AccntType == CARGO) {
                                                    if (sMsgCargoCheckNewDate == '')
                                                        FSMCase.FS_Second_Deadline_Date__c = NCCase.New_IFAP_Deadline_date__c;
                                                    else {
                                                        NCCase.addError(sMsgCargoCheckNewDate);
                                                        continue;
                                                    }
                                                }
                                                FSMCase.firstFSnonComplianceDate__c = Date.Today();
                                                mapFSMCaseToUpdate.put(FSMCase.Id, FSMCase);
                                            }
                                        } else if (FSMCase.secondFSnonComplianceDate__c == null) {
                                            if (FSMCase.FS_Second_Deadline_Date__c >= Date.today()) {
                                                NCCase.addError('Cannot create a 2nd FS non-compliance case. The 2nd FS Deadline is ' + FSMCase.FS_Second_Deadline_Date__c.format());
                                            } else {
                                                //Ok, we can create the 2nd non-compliance case. Let's go!
                                                if (AccntType == PAX) {
                                                    //set the date to the last day of the next month. If on weekend, set it to the first monday available
                                                    FSMCase.FS_Third_Deadline_Date__c = getMondayIfOnWeekend(Date.newInstance(Date.today().addMonths(2).year(), Date.today().addMonths(2).month(), 1).addDays(-1));
                                                }
                                                if (AccntType == CARGO) {
                                                    if (sMsgCargoCheckNewDate == '')
                                                        FSMCase.FS_Third_Deadline_Date__c = NCCase.New_IFAP_Deadline_date__c;
                                                    else {
                                                        NCCase.addError(sMsgCargoCheckNewDate);
                                                        continue;
                                                    }
                                                }
                                                FSMCase.secondFSnonComplianceDate__c = Date.Today();
                                                mapFSMCaseToUpdate.put(FSMCase.Id, FSMCase);
                                            }
                                        } else if (FSMCase.FS_third_non_compliance_date__c == null) {
                                            if (FSMCase.FS_Third_Deadline_Date__c >= Date.today()) {
                                                NCCase.addError('Cannot create a 3rd FS non-compliance case. The 3rd FS Deadline is ' + FSMCase.FS_Third_Deadline_Date__c.format());
                                            } else {
                                                //Ok, we can create the 3rd non-compliance case. Let's go!
                                                FSMCase.FS_third_non_compliance_date__c = Date.Today();
                                                mapFSMCaseToUpdate.put(FSMCase.Id, FSMCase);
                                            }
                                        } else { //Cannot open more then 3 non-compliance case
                                            NCCase.addError('Cannot create more than 3 FS non-compliance case.');
                                        }
                                    } else {
                                        NCCase.AddError('A Non-compliance case cannot be created when the FSM case is closed');
                                    }
                                } else {
                                    NCCase.AddError('The FS Request Letter has not been sent. Kindly send the letter before you proceed.');
                                }
                            }
                        }
                        //Commit FSM Cases
                        if (!mapFSMCaseToUpdate.isEmpty()) {
                            update mapFSMCaseToUpdate.values();
                        }
                    }
                }
            }
        }
        /*Case_FSM_Handle_NonCompliance_BI_BU Trigger.isInsert*/

        /*CaseBeforInsert Trigger.isInsert*/
        if (CaseBeforInsert) {
            System.debug('____ [cls CaseBeforeTrigger - CaseBeforInsert Trigger.isInsert]');
            ISSP_Case.preventTrigger = true;
            set<string> CountryNameSet = new set<string>();
            map<string, IATA_ISO_Country__c> IATAISOCountryMap = new map<string, IATA_ISO_Country__c>();
            List<Mapping_for_CSR_Cases__c> CSRCasesMapping = Mapping_for_CSR_Cases__c.getAll().values();
            List<Case> parentAccount;
            List<Contact> accountFromRelatedContact;

            Set<ID> accountIDSet = new Set<ID>();
            Set<ID> parentCaseID = new Set<ID>();
            Map<ID, List<Case>> mapParentIDCase = new Map<ID, List<Case>>();
            List<Account> acc;
            for (Case newCase : trigger.new) {
                CountryNameSet.add(newCase.Country_concerned_by_the_query__c);
                if (newCase.RecordTypeId == FSMcaseRecordTypeID) {
                    accountIDSet.add(newCase.AccountId);
                }
                parentCaseID.add(newCase.ParentId);
                /*
                if(!mapParentIDCase.containsKey(newCase.ParentId)){
                    mapParentIDCase.put(newCase.ParentId, newCase);
                }else{
                    mapParentIDCase.get(newCase.ParentId).add(newCase);
                }
                */

            }
            if(!accountIDSet.isEmpty())
                acc.add([SELECT Id, Sector__c, Category__c, IATA_ISO_Country__c FROM Account WHERE Id IN :accountIDSet limit 1]);

            List<IATA_ISO_Country__c> isoCountryByName = IATAIsoCountryDAO.getIsoCountryByCountriesName(CountryNameSet);
            List<IATA_ISO_Country__c> isoCountryByCaseBSPCountry = IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountries(CountryNameSet);
            Set<IATA_ISO_Country__c> setIsoCountry = new Set<IATA_ISO_Country__c>(isoCountryByName);
            setIsoCountry.addAll(isoCountryByCaseBSPCountry);

            for(IATA_ISO_Country__c iso : setIsoCountry){
                IATAISOCountryMap.put(iso.Name,iso);
            }
            for (Case newCase : trigger.new) {
                if (IATAISOCountryMap.get(newCase.Country_concerned_by_the_query__c) != null) {
                    system.debug('\n\n\n Region__c ' + newCase.Region__c + '\n\n\n');
                    IATA_ISO_Country__c iso = IATAISOCountryMap.get(newCase.Country_concerned_by_the_query__c);
                    newCase.IFAP_Country_ISO__c = iso.ISO_Code__c;
                    newCase.BSPCountry__c = iso.Case_BSP_Country__c;
                    newCase.Region__c = iso.Region__c;
                    system.debug('\n\n\n Region__c ' + newCase.Region__c + '\n\n\n');
                } else {
                    newCase.Country_concerned_by_the_query__c = newCase.BSPCountry__c;
                }
                  
                Financial_Monitoring_Template__c cs = new Financial_Monitoring_Template__c();
                List<String> listCategories = new List<String>();
                String categoryValues;
                Boolean exist = false;
                if (!acc.isEmpty()) {
                    cs = Financial_Monitoring_Template__c.getInstance(acc[0].Sector__c);
                    if (cs != null) { //it means that the sector is in the Custom Setting
                        categoryValues = cs.Category__c;
                        listCategories = categoryValues.split(',');
                        for (String cat : listCategories) {
                            if (cat == acc[0].Category__c)
                                exist = true;
                        }
                    }
                }
//Check with Gavinho
                if (exist == true) {
                    EmailTemplate__c templateToUse = [SELECT id, Name, Agent_Type__c, IATA_ISO_Country__c 
                                                      FROM EmailTemplate__c
                                                      WHERE Agent_Type__c = : cs.Email_Template_Agency_Type__c 
                                                        AND IATA_ISO_Country__c = :acc[0].IATA_ISO_Country__c limit 1];
                    if (templateToUse != null)
                        newCase.Reminder_EmailTemplate__c = templateToUse.Id;
                }

                for (Mapping_for_CSR_Cases__c m : CSRCasesMapping) {
                    String contactId = m.Contact_Id__c;
                    if (m.Record_Type_Id__c == newCase.RecordTypeId && m.DPC_System__c == newCase.DPC_Software__c) {
//Check Gavinho
                        accountFromRelatedContact = [SELECT Id, AccountId FROM Contact WHERE Id = :contactId];
                        parentAccount = [SELECT Id, AccountId from Case where Id = :newCase.ParentId];
                        if (contactId != null)
                            newCase.ContactId = contactId;
                        if (accountFromRelatedContact.size() > 0)
                            newCase.AccountId = accountFromRelatedContact[0].AccountId;
                        if (parentAccount.size() > 0){
                            newCase.Account_Concerned__c = parentAccount[0].AccountId;
                            if (accountFromRelatedContact.size() > 0)
                                newCase.Visible_on_ISS_Portal__c = m.Access_to_portal__c;
                        }        
                    }
                }
            }
        }
        /*CaseBeforInsert Trigger.isInsert*/

        /*AMS_OSCARCaseTrigger Trigger.isInsert*/
        if (AMS_OSCARCaseTrigger) {
            System.debug('____ [cls CaseBeforeTrigger - AMS_OSCARCaseTrigger Trigger.isInsert]');
            if (AMS_TriggerExecutionManager.checkExecution(Case.getSObjectType(), 'CaseBeforeTrigger')) {
                AMS_OscarCaseTriggerHelper.removeOscarFromChild(trigger.New);
                AMS_OscarCaseTriggerHelper.checkIrregularityThreshold();
                AMS_OscarCaseTriggerHelper.copyDataFromOscar();
            }
        }
        /*AMS_OSCARCaseTrigger Trigger.isInsert*/

        /*trgAccelyaRequestSetCountry Trigger.isInsert*/
        if (trgAccelyaRequestSetCountry) {
            System.debug('____ [cls CaseBeforeTrigger - trgAccelyaRequestSetCountry Trigger.isInsert]');
            //GM - IMPRO - START
            //this trigger is based on a flag not working propoerly, needs to be changed (see trgAccelyaRequestSetCountry Trigger)
            if (!isAccelya) {
                for (Case aCase : trigger.New) {
                    if (aCase.Accelya_Request_Type__c != null && aCase.RecordTypeId != CSRcaseRecordTypeID) {
                        aCase.RecordTypeId = CSRcaseRecordTypeID;
                        //GM - IMPRO - END
                    }
                }
            }
        }
        /*trgAccelyaRequestSetCountry Trigger.isInsert*/

    }

/**************************************************** Trigger.isUpdate ************************************************************************************************/

    else if (Trigger.isUpdate) {

        if (trgCase){
            System.debug('____ [cls CaseBeforeTrigger - trgCase Trigger.isUpdate]');
            SidraLiteManager.updateSidraLiteCases(Trigger.new, Trigger.old);
        }

        /*trgProcessISSCase Trigger.isUpdate*/
        if (trgProcessISSCase) {
            System.debug('____ [cls CaseBeforeTrigger - trgProcessISSCase Trigger.isUpdate]');
            Set<Id> caseIds = new Set <Id>();
            // loop tru cases to be update
            for (Case updatedCase : trigger.New) {
                if (updatedCase.Make_All_Attachments_Public__c) {
                    updatedCase.Make_All_Attachments_Public__c = false;
                    caseIds.add(updatedCase.Id);
                }
            }
            if (!system.isFuture() && !caseIds.isEmpty()) {
                AttachmentTriggerHelper.makeAllPublic(caseIds);
            }
        }
        /*trgProcessISSCase Trigger.isUpdate*/

        /*trgCaseIFAP Trigger.isUpdate*/
        if (trgCaseIFAP) {
            System.debug('____ [cls CaseBeforeTrigger - trgCaseIFAP Trigger.isUpdate]');
            if (!CaseChildHelper.noValidationsOnTrgCAseIFAP) {

                for (Case IFAPupdatedCase : Trigger.New) {
                    // ** May 2014 modif: Forbid change of recordtype FROM or TO IFAP case
                    if (IFAPupdatedCase.RecordTypeId == IFAPcaseRecordTypeID && Trigger.oldMap.get(IFAPupdatedCase.ID).RecordTypeId != IFAPcaseRecordTypeID)
                        IFAPupdatedCase.addError('You cannot create an IFAP case by changing the case record type. If you want to create an IFAP case, create the IFAP case as a child case.');
                    if (IFAPupdatedCase.RecordTypeId != IFAPcaseRecordTypeID && Trigger.oldMap.get(IFAPupdatedCase.ID).RecordTypeId == IFAPcaseRecordTypeID)
                        IFAPupdatedCase.addError('You cannot change the record type of an IFAP case.');
                    // ** End May 2014 modif
                    // only consider IFAP cases
                    if (IFAPupdatedCase.RecordTypeId == IFAPcaseRecordTypeID) {
                        Case IFAPoldCase = Trigger.oldMap.get(IFAPupdatedCase.ID);
                        if (IFAPupdatedCase.Country__c <> IFAPoldCase.Country__c) {
                            // validate the account's country
                            if (!IFAP_BusinessRules.isCountryValid(IFAPupdatedCase, accountMap))
                                IFAPupdatedCase.addError('The account\'s country is not valid.');
                        }
                        if (IFAPupdatedCase.IFAP_Agent_Type__c <> IFAPoldCase.IFAP_Agent_Type__c) {
                            // validate the Agent Type
                            if (!IFAP_BusinessRules.isAgentTypeValid(IFAPupdatedCase, contactMap))
                                IFAPupdatedCase.addError('The contact\'s Agent Type is not valid.');
                        }
                        // validate the Agent Code if the financial review type is not 'New'
                        if (IFAPupdatedCase.Financial_Review_Type__c != 'New applications') {
                            if (IFAPupdatedCase.IFAP_Agent_Code__c <> IFAPoldCase.IFAP_Agent_Code__c) {
                                if (!IFAP_BusinessRules.isAgentCodeValid(IFAPupdatedCase, accountMap))
                                    IFAPupdatedCase.addError('The contact\'s Agent Code is not valid.');
                            }
                        }
                        if (IFAPupdatedCase.status != 'Closed' && !TransformationHelper.NoStatusValidation ) {
                            if (IFAPupdatedCase.status <> IFAPoldCase.status) {
                                if (!IFAP_BusinessRules.IsStatusCanBeSelected(false, IFAPupdatedCase, IFAPoldCase , currentUserProfile, isIfapAuthorizedUser)) {
                                    System.debug('IFAP_BusinessRules.IsStatusCanBeSelected............trg');
                                    IFAPupdatedCase.addError('The following case status cannot be selected: ' + IFAPupdatedCase.status);
                                } else if (IFAP_BusinessRules.FSValidationCheckBox(IFAPupdatedCase, IFAPoldCase , currentUserProfile)) {
                                    System.debug('IFAP_BusinessRules.FSValidationCheckBox..........');
                                    IFAPupdatedCase.addError('The case cannot be saved. Tick ALL the Financial Security Validation checkboxes and enter FS Submitted Date to save the case.' );
                                }
                            }
                        }
                        // check if the FA template's country matches the case country
                        if (IFAPupdatedCase.EmailTemplate__c != null && (IFAPupdatedCase.EmailTemplate__c <> IFAPoldCase.EmailTemplate__c)) {
                            for (EmailTemplate__c EmTe : IFAPemailtemplate) {
                                if (EmTe.Id == IFAPupdatedCase.EmailTemplate__c && !IFAP_BusinessRules.isTemplateCountryValid(EmTe, IFAPupdatedCase.IFAP_Country_ISO__c)) {
                                    IFAPupdatedCase.addError('The selected Initial Request Email Template does not match the case country.');
                                    break;
                                }
                            }
                        }
                        // check if the FA reminder template's country matches the case country
                        if (IFAPupdatedCase.Reminder_EmailTemplate__c != null && (IFAPupdatedCase.Reminder_EmailTemplate__c <> IFAPoldCase.Reminder_EmailTemplate__c)) {
                            for (EmailTemplate__c REmTe : IFAPemailtemplate) {
                                if (REmTe.Id == IFAPupdatedCase.Reminder_EmailTemplate__c && !IFAP_BusinessRules.isTemplateCountryValid(REmTe, IFAPupdatedCase.IFAP_Country_ISO__c)) {
                                    IFAPupdatedCase.addError('The selected Reminder Email Template does not match the case country.');
                                    break;
                                }
                            }
                        }
                        // check if the FS template's country matches the case country
                        if (IFAPupdatedCase.FS_EmailTemplate__c != null && (IFAPupdatedCase.FS_EmailTemplate__c <> IFAPoldCase.FS_EmailTemplate__c)) {
                            for (EmailTemplate__c FSEmTe : IFAPemailtemplate) {
                                if (FSEmTe.Id == IFAPupdatedCase.FS_EmailTemplate__c && !IFAP_BusinessRules.isTemplateCountryValid(FSEmTe, IFAPupdatedCase.IFAP_Country_ISO__c)) {
                                    IFAPupdatedCase.addError('The selected FS Email Template does not match the case country.');
                                    break;
                                }
                            }
                        }
                        // check if the FS reminder template's country matches the case country
                        if (IFAPupdatedCase.FS_Reminder_EmailTemplate__c != null && (IFAPupdatedCase.FS_Reminder_EmailTemplate__c <> IFAPoldCase.FS_Reminder_EmailTemplate__c)) {
                            for (EmailTemplate__c FSREmTe : IFAPemailtemplate) {
                                if (FSREmTe.Id == IFAPupdatedCase.FS_Reminder_EmailTemplate__c && !IFAP_BusinessRules.isTemplateCountryValid(FSREmTe, IFAPupdatedCase.IFAP_Country_ISO__c)) {
                                    IFAPupdatedCase.addError('The selected FS Reminder Email Template does not match the case country.');
                                    break;
                                }
                            }
                        }
                        // check if the account country was changed
                        if (IFAP_BusinessRules.AccountCountryHasChanged(IFAPoldCase, IFAPupdatedCase)) {
                            // validate the account's country
                            if (!IFAP_BusinessRules.isCountryValid(IFAPupdatedCase, accountMap))
                                IFAPupdatedCase.addError('The account\'s country is not valid.');
                            else
                                IFAP_BusinessRules.setCountryAreaAndISOCode(IFAPupdatedCase, accountMap);
                        }
                        //check if region is missing
                        if (IFAPupdatedCase.Region__c == '' || IFAPupdatedCase.Region__c == null) {
                            IFAP_BusinessRules.setCountryAreaAndISOCode(IFAPupdatedCase, accountMap);
                        }
                        // Phase 4
                        // check if Parent case is a SAAM case
                        List<Case> caseSAAMList = mapSAAMParentIDCase.get(IFAPupdatedCase.ParentId);
                        if (String.valueOf(IFAPupdatedCase.ParentId) != '' && (caseSAAMList != null && caseSAAMList.size() > 0)) {
                            // check if a new parent SAAM case has been assigned
                            if (IFAPoldCase.ParentId <> IFAPupdatedCase.ParentId) {
                                //INC158616 - changed to list and check if size > 0

//Ask Gavinho                             
                                List<Case> listChildCaseOfParent = [SELECT c.Id, c.CaseNumber, c.RecordTypeId 
                                                                    FROM Case c 
                                                                    WHERE c.ParentId = :IFAPupdatedCase.ParentId 
                                                                        AND c.Id <> :IFAPupdatedCase.Id 
                                                                        AND c.RecordTypeId = : IFAPcaseRecordTypeID LIMIT 1];
                                if (listChildCaseOfParent <> null && listChildCaseOfParent.size() > 0) {
                                    IFAPupdatedCase.addError('The selected parent SAAM case already has a child IFAP case.');
                                }
                            }
                            // update some fields in the parent SAAM case
                            IFAP_BusinessRules.updateParentSAAMCase(IFAPoldCase, IFAPupdatedCase);
                        }
                        //don not allow change of Financial Review Result for unauthorized users
                        if (IFAPupdatedCase.Financial_Review_Result__c <> IFAPoldCase.Financial_Review_Result__c && !isIfapAuthorizedUser && !currentUserProfile.Name.toLowerCase().contains('system administrator')) {
                            IFAPupdatedCase.addError('Your user does not have the permission to change the Financial Review Result field.');
                        }
                    }
                }
            }
        }
        /*trgCaseIFAP Trigger.isUpdate*/

        /*UserInfoUpdate Trigger.isUpdate*/
        if (UserInfoUpdate) { 
            System.debug('____ [cls CaseBeforeTrigger - UserInfoUpdate Trigger.isUpdate]');
            for (Case updateCase : Trigger.New) {
                if ((updateCase.RecordTypeId == SIDRAcaseRecordTypeID) || (updateCase.RecordTypeId == SIDRABRcaseRecordTypeID )) {
                    //compare with old values
                    Case UIUoldCase = Trigger.oldMap.get(updateCase.ID);
                    //update name field if values changed
                    if (updateCase.CS_Contact_Result__c != UIUoldCase.CS_Contact_Result__c)
                        updateCase.CS_Rep_Contact_Customer__c = UserInfo.getUserId();
                    if (updateCase.Update_AIMS_IRR__c != UIUoldCase.Update_AIMS_IRR__c)
                        updateCase.CS_Rep_Acc_IRR_DEF__c = UserInfo.getUserId();
                    if (updateCase.Update_AIMS_DEF__c != UIUoldCase.Update_AIMS_DEF__c)
                        updateCase.CS_Rep_Acc_DEF__c = UserInfo.getUserId();
                    if (updateCase.Update_AIMS_IRRWITH__c != UIUoldCase.Update_AIMS_IRRWITH__c)
                        updateCase.CS_Rep_ACC_IRR_Withdrawal__c = UserInfo.getUserId();
                    if (updateCase.Update_AIMS_REI_DEFWITH__c != UIUoldCase.Update_AIMS_REI_DEFWITH__c)
                        updateCase.CS_Rep_Acc_REI__c = UserInfo.getUserId();
                    if (updateCase.Update_AIMS_TER__c != UIUoldCase.Update_AIMS_TER__c)
                        updateCase.CS_Rep_ACC_TER__c = UserInfo.getUserId();
                }
            }
        }
        /*UserInfoUpdate Trigger.isUpdate*/

        /*trgCheckBusinessHoursBeforeInsert Trigger.isUpdate*/
        if (trgCheckBusinessHoursBeforeInsert) {
            System.debug('____ [cls CaseBeforeTrigger - trgCheckBusinessHoursBeforeInsert Trigger.isUpdate]');
            if (hasOneSISCase) {
                CheckBusinessHoursHelperclass.trgCheckBusinessHoursBeforeUpdate(Trigger.new, Trigger.old, CBHContactMap, CBHAccountMap);
            }
        }
        /*trgCheckBusinessHoursBeforeInsert Trigger.isUpdate*/

        /*trgSidraCaseBeforeInsertUpdate Trigger.isUpdate*/
        if (trgSidraCaseBeforeInsertUpdate) { 
            System.debug('____ [cls CaseBeforeTrigger - trgSidraCaseBeforeInsertUpdate Trigger.isUpdate]');
            Set<Id> accountIds = new Set<Id>();
            system.debug('');
            for (Case aCase : trigger.new) { // Fill a set of Account Ids for the cases select statement
                // Only for Sidra small amount cases, only cases created within the last 24 hours
                system.debug(LoggingLevel.Error, '============== UPDATE analyze ' + aCase.Subject + ' which has IRR_Withdrawal_Reason__c = ' + aCase.IRR_Withdrawal_Reason__c + '================');
                if (aCase.RecordTypeId == SIDRAcaseRecordTypeID && (aCase.IRR_Withdrawal_Reason__c == SMALLAMOUNT || aCase.IRR_Withdrawal_Reason__c == MINORPOLICY) && aCase.CreatedDate >= Last24Hours && aCase.AccountId != null) {
                    // We add the Account id to the set only if the current case is a Sidra Small amount case. Avoid unwanted Case record types
                    accountIds.add(aCase.AccountId);
                }     
                if (aCase.RecordTypeId == SEDAcaseRecordTypeID) {
                    Case aCaseOld = Trigger.oldMap.get(aCase.Id);
                    if (aCase.Demand_by_Email_Fax__c!=aCaseOld.Demand_by_Email_Fax__c) {
                        aCase.CS_Rep_Contact_Customer__c = UserInfo.getUserId();
                    }
                }
            }

            if (accountIds.size() > 0) { // This list should be empty if all of the cases aren't related to the Sidra Small amount process
                // Get a list of all related cases
                List<Case> casesUpd = [SELECT AccountId, Action_needed_Small_Amount__c, Subject, CreatedDate, Propose_Irregularity__c, IRR_Approval_Rejection__c, IRR_Approval_Rejection_Date__c
                                       FROM Case 
                                       WHERE RecordTypeId = : SIDRAcaseRecordTypeID
                                        AND (IRR_Withdrawal_Reason__c = :SMALLAMOUNT OR IRR_Withdrawal_Reason__c = :MINORPOLICY OR Action_needed_Small_Amount__c = true)
                                        AND CreatedDate >= : OneYearAgo AND AccountId <> null AND AccountId IN: accountIds];

                // If there are minor error policy cases, make a list of the latest reinstatement date per Account Id
                map<Id, Datetime> mapReiDatesPerAccountiId = new map<Id, Datetime>();
                if (!casesUpd.isEmpty()) {
                    AggregateResult[] REIDates = [SELECT MAX(Update_AIMS_REI_DEFWITH__c)reinstatement_date, AccountId 
                                                  FROM Case
                                                  WHERE REI_ApprovalRejectin__c = 'Approved'
                                                          AND DEF_Withdrawal_Approval_Rejection__c <> 'Approved'
                                                          AND Update_AIMS_REI_DEFWITH__c <> null
                                                          AND CreatedDate >= : OneYearAgo
                                                          AND AccountId IN: accountIds
                                                          GROUP BY AccountId ];
                    if (!REIDates.isEmpty()) {
                        for (AggregateResult ar : REIDates) {
                            mapReiDatesPerAccountiId.put((Id)ar.get('AccountId'), (Datetime)ar.get('reinstatement_date'));
                        }
                    }
                }
                for (Case mCase : Trigger.new) {
                    // only act on cases that were created within the last 24 hours
                    if (mCase.CreatedDate >= Last24Hours) {
                        integer nbCasesSA = 0;
                        for (Case testCase : casesUpd ) {
                            if (testCase.AccountId == mCase.AccountId && testCase.Id != mCase.Id &&
                                    (mapReiDatesPerAccountiId.get(testCase.AccountId) == null || testCase.CreatedDate > mapReiDatesPerAccountiId.get(testCase.AccountId)) ) {
                                nbCasesSA ++;
                            }
                        }
                        if (nbCasesSA >= 3) {
                            mCase.Action_needed_Small_Amount__c = true;
                            mCase.IRR_Withdrawal_Reason__c = null;
                            mCase.Propose_Irregularity__c = Datetime.now();
                            mCase.IRR_Approval_Rejection__c = 'Approved';
                            mCase.IRR_Approval_Rejection_Date__c = Date.today();
                        } else { mCase.Action_needed_Small_Amount__c = false; }
                    }
                }
            }
        }
        /*trgSidraCaseBeforeInsertUpdate Trigger.isUpdate*/

        /*CalculateBusinessHoursAges Trigger.isUpdate*/
        if (CalculateBusinessHoursAges) { 
            System.debug('____ [cls CaseBeforeTrigger - CalculateBusinessHoursAges Trigger.isUpdate]');
            // Handling of DPC cases - automatic status change
            DPCCasesUtil.HandleStatusUpdate(Trigger.newMap, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
            //INC147754
            for (Case updatedCase : System.Trigger.new) {
                if (updatedCase.First_closure_date__c <> null && updatedCase.First_Business_Day__c <> null) {
                    updatedCase.ClosedSameDay__c =  BusinessDays.compareThisDates( updatedCase.First_Business_Day__c, updatedCase.First_closure_date__c) || (updatedCase.First_closure_date__c < updatedCase.First_Business_Day__c)  ? 'Yes' : 'No';
                }
                //Here we calculate the first contact with client in business hours
                Case oldCase = System.Trigger.oldMap.get(updatedCase.Id);
                if(
                    updatedCase.BusinessHoursId <> null
                    && updatedCase.First_Contact_with_Client__c <> null 
                    && (
                        updatedCase.First_Contact_w_Client_in_Business_Hours__c != oldCase.First_Contact_w_Client_in_Business_Hours__c 
                        || updatedCase.First_Contact_w_Client_in_Business_Hours__c == null
                        || updatedCase.First_Contact_w_Client_in_Business_Hours__c < 0
                    )
                ) {
                    updatedCase.First_Contact_w_Client_in_Business_Hours__c = BusinessHours.diff(updatedCase.BusinessHoursId, updatedCase.CreatedDate, updatedCase.First_Contact_with_Client__c) / 3600000.0;
                }
            }
            if (Trigger.isUpdate && (!transformationHelper.CalculateBusinessHoursAgesGet() || BusinessDays.isAllowedRunTwice)) { // we are on the update so we have the caseIDS!Hurra!!
                //Get the default business hours (we might need it)
                set<id> casesIdSoCalculate = new set<id>();
                map<string, list<Case>> ListCasesIDsperbusinessHourId = new map<string, list<Case>>();
                for (Case updatedCase : System.Trigger.new) {
                    updatedCase.Last_Status_Change__c  = updatedCase.Last_Status_Change__c <> null ? updatedCase.Last_Status_Change__c : System.now();
                    Case oldCase = System.Trigger.oldMap.get(updatedCase.Id);
                    // this very next section is for the kpi
                    if ((oldCase.Status != updatedCase.Status) || (updatedCase.BusinessHoursId <> null && updatedCase.BusinessHoursId <> oldCase.BusinessHoursId)
                        || (oldCase.First_Business_Day__c == null)) {
                        casesIdSoCalculate.add(updatedCase.id);
                    }
                    // the following section is used for the
                    // nex short day , to find the very next business day
                    if (updatedCase.BusinessHoursId <> null && updatedCase.Short_Payment_Date__c <> null ) {
                        if (ListCasesIDsperbusinessHourId.get(updatedCase.BusinessHoursId) == null)
                            ListCasesIDsperbusinessHourId.put(updatedCase.BusinessHoursId, new list<Case>());
                        ListCasesIDsperbusinessHourId.get(updatedCase.BusinessHoursId).add(updatedCase);
                    }
                }
                if (!ListCasesIDsperbusinessHourId.isEmpty()) { // to do this goes to an helper class as well
                    map<Id, Date> nextBusinessDayPerCaseID = BusinessDays.BusinessDaysPerCaseIdCalc(Trigger.newMap);
                    for (Id caseID : nextBusinessDayPerCaseID.keySet()) {
                        System.Trigger.newMap.get(caseID).Short_Payment_Next_Business_Date__c = nextBusinessDayPerCaseID.get(caseID);
                    }
                }
                // we do the logic only if needed.....to avoid any unacessary soql queries....
                // to do...review the logic a bit
                if (!casesIdSoCalculate.isEmpty())
                    BusinessDays.calculateTheKpis(casesIdSoCalculate , Trigger.NewMap, Trigger.OldMap);
                transformationHelper.CalculateBusinessHoursAgesSet();
            }
            // Handling of DPC cases - milestone tracking
            DPCCasesUtil.CreateMilestones(Trigger.newMap, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
        }
        /*CalculateBusinessHoursAges Trigger.isUpdate*/

        /*trgCase_SIS_ICH_AreaVsType Trigger.isUpdate*/
        if (trgCase_SIS_ICH_AreaVsType) { 
            System.debug('____ [cls CaseBeforeTrigger - trgCase_SIS_ICH_AreaVsType Trigger.isUpdate]');

            for (case newCase: Trigger.new) {
                if (newCase.priority != null && newCase.Type != null && newCase.CaseArea__c != null && newCase.CaseArea__c == 'ICH' && newCase.Assigned_To__c == 'ICH Application Support'
                        && newCase.Status == 'Escalated' && newCase.L2_Support_Priority__c == null && newCase.Priority != 'Priority 1 (Showstopper)') {
                    system.debug('\n Assert error3 caught .......');
                    newCase.addError(Label.L2_Support_Priority_escalation_check);
                }
                String oldStatus = trigger.oldMap.get(newCase.id).status;
                String oldPriority = trigger.oldMap.get(newCase.id).priority;
                String oldTeam = trigger.oldMap.get(newCase.id).assigned_to__c;
                if (newCase.priority != null && newCase.Type != null && newCase.CaseArea__c != null && newCase.CaseArea__c == 'ICH' && (((newCase.status != oldStatus || newCase.assigned_to__c != oldTeam)
                        && newCase.status == 'Escalated' && oldPriority != 'Priority 1 (Showstopper)' && newCase.assigned_to__c == 'ICH Application Support') || (oldPriority != newCase.priority
                                && newCase.priority == 'Priority 1 (Showstopper)' && !(oldStatus == 'Escalated' && newCase.assigned_to__c == 'ICH Application Support')))) {
                    if (newCase.L2_Support_Priority__c == null)
                        newCase.L2_Support_Priority__c = '1 - High';
                    if (newCase.Kale_Status__c == null)
                        newCase.Kale_Status__c = 'New';
                }
            }
        }
        /*trgCase_SIS_ICH_AreaVsType Trigger.isUpdate*/

        /*trgParentCaseUpdate Trigger.isUpdate*/
        if (trgParentCaseUpdate) { //FLAG
            System.debug('____ [cls CaseBeforeTrigger - trgParentCaseUpdate Trigger.isUpdate]');
            // Created Date - 16-12-2010
            // TO FUTURE REVIEWER....IT WILL BE NICE TO FIND OUT WHY THIS TRIGGER WAS DEVELOPED AND WHY THE CONDITION ON LINE 18 FOR ALL CASES BUT IFAP
            // PLEASE REVIEW IT...
            Set<Id> CaseIdsNew = new Set<Id>();
            Integer futureLimit = Limits.getFutureCalls();
            System.Debug('futureLimit : ----- ' + futureLimit);
            //get the IFAP case recordtype
            Boolean isIFAPCase = false;
            list<Case> cases = new list<Case>();
            for (Case c : trigger.new) {
                if (c.parentId != null && ! (c.RecordTypeId == IFAPcaseRecordTypeID || c.Reason1__c == 'FA/ FS Non-Compliance') 
                    && ( c.RecordTypeId != FSMcaseRecordTypeID )) {
                    cases.add(c);
                }
            }
            if (!cases.isempty()) {
                if (futureLimit < 10) {
                    if (!FutureProcessorControl.inFutureContext && !System.isBatch()) { // do not execute if in a Batch context - added 2014-12-10 Constantin Buzduga
                        //Passing and calling the class according to the event
                        //Adding the new case records in the List
                        for (Case ObjCaseNew : Trigger.New) {
                            //do not execute for IFAP cases - 2012-01-13 Alexandre McGraw
                            if (ObjCaseNew.RecordTypeId == IFAPcaseRecordTypeID)
                                continue;
                            for (Case ObjCaseOld : Trigger.Old) {
                                if (ObjCaseNew.Status != ObjCaseOld.Status && ObjCaseOld.Status != 'Closed' && ObjCaseNew.Status == 'Closed') {
                                    CaseIdsNew.add(ObjCaseNew.Id);
                                }
                            }
                        }
                        if (CaseIdsNew.Size() > 0) {
                            clsInternalCaseDML.InternalCaseDMLMethod(CaseIdsNew, 'Update');
                        }
                    } //FutureProcessorControl
                } //futureLimit
            }  //!cases.isempty
        }
        /*trgParentCaseUpdate Trigger.isUpdate*/

        /*Case_FSM_Handle_NonCompliance_BI_BU Trigger.isUpdate*/
        if (Case_FSM_Handle_NonCompliance_BI_BU) {
            System.debug('____ [cls CaseBeforeTrigger - Case_FSM_Handle_NonCompliance_BI_BU Trigger.isUpdate]');
            //FSM Case(s) found! Proceed with the logic
            if (!setFSMCaseId.isEmpty()) {
                map<Id, Case> mapFSMCaseToUpdate = new map<Id, Case>(); //List of FSM case to update
                //Search Parent Case (FSM)
                for (Case NCCase : trigger.new) {
                    if (NCCase.RecordTypeId == ProcessISSPcaseRecordTypeID && mapFSMCases.keyset().contains(NCCase.ParentId)) {
                        Case FSMCase;
                        if (mapFSMCaseToUpdate.containsKey(NCCase.ParentId))
                            FSMCase = mapFSMCaseToUpdate.get(NCCase.ParentId);
                        else
                            FSMCase = mapFSMCases.get(NCCase.ParentId);
                        string AccntType = FSMCase.Account.Industry;    //Type of account. Cargo Agent / Travel Agent
                        if (trigger.isUpdate) {
                            system.debug(Logginglevel.ERROR, 'DTULLO trigger is update');
                            if (FSMCase.FS_Deadline_Date__c != null) {
                                if (FSMCase.isClosed == false) {
                                    continue;
                                } else {
                                    NCCase.AddError('A Non-compliance case cannot be created when the FSM case is closed');
                                }
                            } else {
                                NCCase.AddError('The FS Request Letter has not been sent. Kindly send the letter before you proceed.');
                            }
                        }
                        //Commit FSM Cases
                        if (!mapFSMCaseToUpdate.isEmpty()) {
                            update mapFSMCaseToUpdate.values();
                        }
                    }
                }
            }
        }
        /*Case_FSM_Handle_NonCompliance_BI_BU Trigger.isUpdate*/

//CHECK LATER THE CHANGES MADE WITH GAVINHO

        /*trgIDCard_Case_BeforeUpdate Trigger.isUpdate*/ 
        if (trgIDCard_Case_BeforeUpdate) {
            System.debug('____ [cls CaseBeforeTrigger - trgIDCard_Case_BeforeUpdate Trigger.isUpdate]');
            Boolean isCurrentUserProfileInit = false;
            Boolean isAdmin = false;
            Boolean isSiteGuestUser = false;
            currentUserProfile = getUserProfile();

            // Get contactID from Trigger.new to use in the query
            Set<Id> contactIDList = new Set<Id>();
            Set<Id> relatedIDCardAppList = new Set<Id>();
            List<Contact> ContactToUpdate = new List<Contact>(); 
            Contact theContact;

            for (Case aCase : trigger.new) { 
                Case oldCase = Trigger.oldMap.get(aCase.ID);
                if (aCase.RecordTypeId == caseRecordType && aCase.ID_Card_Status__c == IDCardUtil.CASECARDSTATUS_APPROVED && oldCase.ID_Card_Status__c == IDCardUtil.CASECARDSTATUS_PENDING_MNG_APPROVAL) {
                    contactIDList.add(aCase.ContactId);
                    relatedIDCardAppList.add(aCase.Related_ID_Card_Application__c);
                }
            }

            //c.VER_Number__c != Decimal.valueof(application.VER_Number__c)
            Map<Id, Contact> contactMap = 
                new Map<ID, Contact>([SELECT c.Id, c.AgencyShare_Confirmation__c, c.ID_Card_Preferred_Language__c, c.VER_Number__c, c.Title, c.FirstName, c.Middle_Initial__c, c.LastName, c.UIR__c,
                                      c.Account.IATACode__c, c.Hours_per_week__c, c.Duties__c, c.Position__c, c.Solicitation_Flag__c, c.Revenue_Confirmation__c,
                                      (SELECT Id, Card_Status__c, Valid_To_Date__c 
                                        From ID_Cards__r 
                                        where  Card_Status__c = : IDCardUtil.CARDSTATUS_VALID order by CreatedDate desc)
                                      FROM Contact c 
                                      WHERE c.RecordType.Name = : 'Standard' AND id IN :contactIDList]); 

            //get IDCard and Application
            Map<ID, ID_Card_Application__c> idCardAppMap = 
                new Map<ID, ID_Card_Application__c>([SELECT id, VER_Number__c, UIR__c, Type_of_application__c, Title__c, Terms_and_Conditions_Time_Stamp__c, Telephone__c, SystemModstamp, Start_Date_Industry__c,
                                                  Start_Date_Agency_Year__c, Start_Date_Agency_Month__c, Solicitation_Flag__c, Selected_Preferred_Language__c, Revenue_Confirmation__c, Revenue_Confirmation_Validation_Failed__c,
                                                  Renewal_From_Replace__c, Regional_Office__c, Promotion_Code__c, Profit_Center__c, Position_in_Current_Agency__c, Position_Code__c, Photo__c, Payment_Type__c, Payment_Transaction_Number__c,
                                                  Payment_Date__c, Payment_Currency__c, Payment_Credit_Card_Number__c, Payment_Amount__c, Package_of_Travel_Professionals_Course_2__c, Package_of_Travel_Professionals_Course_1__c, OwnerId,
                                                  Name, Middle_Initial__c, Last_Name__c, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, ITDI_Courses_Fee__c, ID_Card_Fee__c, IDCard_Prefered_Language__c,
                                                  IDCard_Expedite_Delivery__c, IDCard_Expedite_Delivery_Fee__c, IATA_numeric_code_previous_employer_4__c, IATA_numeric_code_previous_employer_3__c, IATA_numeric_code_previous_employer_2__c,
                                                  IATA_numeric_code_previous_employer_1__c, IATA_Code_for_previous_agency__c, IATA_Code__c, Hours_worked__c, Hours_Worked_Validation_Failed__c, Hours_Worked_Code__c, Gender__c,
                                                  First_Name__c, Email_admin__c, Duties_in_Current_Agency__c, Duties_Code__c, Displayed_Name__c, Date_of_Birth__c, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId,
                                                  ConnectionReceivedId, Case_Number__c, Approving_Manager_s_Name__c, Approving_Manager_s_Email__c, Applicable_Fee__c, AgencyShare_Confirmation__c, 
                                                  (SELECT Id FROM ID_Cards__r LIMIT 1)
                                                  FROM ID_Card_Application__c
                                                  WHERE ID IN :relatedIDCardAppList]);  
                             
            for (Case aCase : trigger.new) {

                if (aCase.RecordTypeId == caseRecordType) {
                    //R.A 6/17/2013: allow Admins to change the status of ID Card otherwise blocks the change of Approval, Pending Payment and Pending
                    if(!isCurrentUserProfileInit && currentUserProfile != null) {
                        isAdmin = currentUserProfile.Name.toLowerCase().contains('system administrator');
                        isSiteGuestUser = currentUserProfile.Name.toLowerCase().contains('idcard portal profile');
                        isCurrentUserProfileInit = true;
                    }
                
                    if (isCurrentUserProfileInit) {
                        Case oldCase = Trigger.oldMap.get(aCase.ID);
                        if ((!isAdmin && !isSiteGuestUser) || Test.isRunningTest()) {
                            if (oldCase.ID_Card_Status__c == aCase.ID_Card_Status__c) {
                                continue;
                            }
                            if (oldCase.ID_Card_Status__c == IDCardUtil.CASECARDSTATUS_APPROVED && aCase.ID_Card_Status__c != IDCardUtil.CASECARDSTATUS_REJECTED) {
                                aCase.addError('The ID Card Case cannot be updated if the status is ' + oldCase.ID_Card_Status__c);
                                continue;
                            }
                            if (oldCase.ID_Card_Status__c == IDCardUtil.CASECARDSTATUS_REJECTED && aCase.ID_Card_Status__c != IDCardUtil.CASECARDSTATUS_APPROVED) {
                                aCase.addError('The ID Card Case cannot be updated if the status is ' + oldCase.ID_Card_Status__c);
                                continue;
                            }
                            if (oldCase.ID_Card_Status__c == IDCardUtil.CASECARDSTATUS_PENDING_MNG_APPROVAL && (aCase.ID_Card_Status__c != IDCardUtil.CASECARDSTATUS_APPROVED && aCase.ID_Card_Status__c != IDCardUtil.CASECARDSTATUS_REJECTED)) {
                                aCase.addError('The ID Card Case cannot be updated from the status ' + oldCase.ID_Card_Status__c + ' to the status ' + aCase.ID_Card_Status__c);
                                continue;
                            }
                        }
                        //Case For Cheque Payment Manager Approval
                        //Code not bulkied but this trigger runs only in case of cheque payment after the manager approves the case
                        SavePoint sp = database.setSavepoint();

                        try {
                            if (aCase.ID_Card_Status__c == IDCardUtil.CASECARDSTATUS_APPROVED && oldCase.ID_Card_Status__c == IDCardUtil.CASECARDSTATUS_PENDING_MNG_APPROVAL) {
                                ID_Card__c idCard;
                                ID_Card_Application__c application = idCardAppMap.get(aCase.Related_ID_Card_Application__c);

                                // To Avoid Creating Card/Contact more than once
                                if (application.ID_Cards__r.size() == 0) {
                                    //**Create Contact only for new application
                                    if (application.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_NEW){
                                        theContact = IDCardUtil.CreateContactWhenNewCardIsApproved(application);
                                        theContact.Email = application.Email_admin__c; 
                                    }
                                    if (theContact == null) 
                                        throw new IDCardApplicationException(string.format(Label.ID_Card_Contact_Not_found_for_VER, new string[] {application.VER_Number__c}));
                                    
                                    idCard = IDCardUtil.CreateIDCardObjectFromApplication(application, theContact);
                                    if (idCard != null)
                                        insert idCard;
                                }else{

                                    theContact = contactMap.get(aCase.ContactId);
                                    idCard = theContact.id_cards__r[0];

                                    //Update Contact Info
                                    theContact.LastName = application.Last_Name__c;
                                    theContact.ID_Card_Preferred_Language__c = application.IDCard_Prefered_Language__c;
                                    theContact.Phone = application.Telephone__c;
                                    theContact.Email = application.Email_admin__c;    
                                    theContact.Position__c = application.Position_in_Current_Agency__c;
                                    theContact.Duties__c = application.Duties_in_Current_Agency__c;
                                    theContact.Hours_per_week__c = application.Hours_worked__c;
                                    theContact.Solicitation_Flag__c = application.Solicitation_Flag__c;
                                    theContact.Revenue_Confirmation__c = application.Revenue_Confirmation__c;
                                    theContact.AgencyShare_Confirmation__c = application.AgencyShare_Confirmation__c;
                                    
                                    if (application.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REPLACEMENT)
                                        theContact.AccountId = aCase.Account.Id;
                                    //Future action: REMOVE UPDATE from FOR 
                                    update theContact;
                                }

                                // Change the status of the old card to "Cancelled" (only on reissue => Lost/stolen)
                                if (application.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE) {
                                    //find old card to cancel it
                                    if (idCard != null) {
                                        idCard.Card_Status__c = IDCardUtil.CARDSTATUS_CANCELED;
                                        //Future action: REMOVE UPDATE from FOR 
                                        update idCard;
                                    }
                                }
                                // call the cropping tool web service to rename the photo filename (from a GUID to the UIR)
                                IDCardUtil.renameIDCardPhotoOfContact(application.ID, '', UserInfo.getSessionId());
                            }
                        } catch (Exception e) {
                            database.rollback(sp);
                            aCase.addError('** Error ' + e.getMessage() + '  ' + e.getStackTraceString());
                            break;
                        }
                    }
                }else {
                    //if case a now a parent id add it to map for checking
                    if (aCase.ParentID != null )
                        casePerParentId.put(aCase.parentId, acase);
                }
            } // END for (Case aCase : trigger.new)

            //2014-07-17 new interactiuon feature
            if (casePerParentId.size() > 0) {
                //look for parent case which are Id cards type
                List<Case> idCardsParentCases = [SELECT id, CaseNumber, New_interaction__c 
                                                FROM Case WHERE Id in :casePerParentId.keyset() AND RecordTypeId = :caseRecordType];
                //for each of them we update New interaction on child case
                for (Case parentCase : idCardsParentCases) {
                    parentCase.New_interaction__c = 'New Related Case';
                }
                if (!idCardsParentCases.isEmpty())
                    update idCardsParentCases;
            }
        }
        /*trgIDCard_Case_BeforeUpdate Trigger.isUpdate*/

        /*AMS_OSCARCaseTrigger Trigger.isUpdate*/
        if (AMS_OSCARCaseTrigger) {
            System.debug('____ [cls CaseBeforeTrigger - AMS_OSCARCaseTrigger Trigger.isUpdate]');
            if (AMS_TriggerExecutionManager.checkExecution(Case.getSObjectType(), 'CaseBeforeTrigger')) {
                AMS_OscarCaseTriggerHelper.blockForbbidenActions(trigger.New, trigger.oldMap);
                AMS_OscarCaseTriggerHelper.copyDataFromOscar();

                List<AMS_OSCAR__c> oscarsToUpdate = new List<AMS_OSCAR__c>();
                Map<Id, Case> oscarIdcases = new Map<Id, Case>();

                for (Case c : Trigger.new) {
                    if (c.RecordTypeId == IFAPcaseRecordTypeID && c.Oscar__c != null) {
                        oscarIdcases.put(c.Oscar__c, c);
                    }
                }

                for (AMS_OSCAR__C oscar : [SELECT Id, Financial_Assessment_requested__c, Financial_Assessment_deadline__c, Assessment_Performed_Date__c,
                                           Financial_Review_Result__c, Bank_Guarantee_amount__c, Reason_for_change_of_Financial_result__c,
                                           Requested_Bank_Guarantee_amount__c, Bank_Guarantee_Currency__c, Bank_Guarantee_deadline__c
                                           FROM AMS_OSCAR__c WHERE Id in :oscarIdcases.keySet()]) {

                    oscar = AMS_Utils.syncOSCARwithIFAP(trigger.oldMap.get(oscarIdcases.get(oscar.Id).Id), oscarIdcases.get(oscar.Id), oscar, false);
                    if (oscar != null) {
                        oscarsToUpdate.add(oscar);
                    }
                }
                if (!oscarsToUpdate.isEmpty()) {
                    update oscarsToUpdate;
                }

            }
        }
        /*AMS_OSCARCaseTrigger Trigger.isUpdate*/

        /*ISSP_CreateNotificationForCase Trigger.isUpdate*/
        //This trigger updates a field based on a change in the IATA country; it creates also a Notification record
        if (ISSP_CreateNotificationForCase) { 
            System.debug('____ [cls CaseBeforeTrigger - ISSP_CreateNotificationForCase Trigger.isUpdate]');
            system.debug('flag per entrare nel trigger ' + !ISSP_Case.preventTrigger);
            if (!ISSP_Case.preventTrigger) {
                for (Case newCase : trigger.new) {
                    Case oldCase = trigger.oldMap.get(newCase.Id);
                    if (newCase.BSPCountry__c != oldCase.BSPCountry__c) {
                        newCase.Country_concerned_by_the_query__c = newCase.BSPCountry__c;
                    }
                }
            }
            //GM - IMPRO - START
            //create notification__c record based on a value in Notification_template__c field on case. there are not cases with that value
            ISSP_CreateNotification.CreateNotificationForSobjectList(trigger.new);
            //GM - IMPRO - END
        }
        /*ISSP_CreateNotificationForCase Trigger.isUpdate*/

    }
/************************************************************ Trigger.isDelete ****************************************************************************************/
    else if (Trigger.isDelete) {

        /*trgCase_BeforeDelete Trigger.isDelete*/
        //This trigger avoids the deletion of a case with record type "IATA Financial Review"
        if (trgCase_BeforeDelete) { 
            System.debug('____ [cls CaseBeforeTrigger - trgCase_BeforeDelete Trigger.isDelete]');
            for (Case aCase : trigger.old) {
                if (aCase.RecordTypeId == IFAPcaseRecordTypeID)
                    aCase.addError('Deleting an IFAP case is not allowed');
            }
        }
        /*trgCase_BeforeDelete Trigger.isDelete*/
    }

    /*Internal methods Case_FSM_Handle_NonCompliance_BI_BU*/
    private static Date getMondayIfOnWeekend(date deaddate) {
        Date RefDate = date.NewInstance(1900, 1, 7);
        integer dayOfWeek = math.mod(RefDate.daysBetween(deaddate), 7);
        if (dayOfWeek == 0) //Sunday
            return deaddate.addDays(1);
        else if (dayOfWeek == 6) //Saturday
            return deaddate.addDays(2);
        else
            return deaddate;
    }

    private static string CargoDateValid(date dtToCheck) {
        if (dtToCheck == null) {
            return 'The New Deadline date is mandatory when creating a non-compliance for Cargo Agents.';
        } else {
            if (dtToCheck > Date.today()) {
                return '';
            } else {
                return 'The New Deadline date must be greater than today.';
            }
        }
    }
    /*Internal methods Case_FSM_Handle_NonCompliance_BI_BU*/

    /*
     * Get User profile
     */
    private static Profile getUserProfile(){
        if(currentUserProfile == null)
            return [SELECT ID, Name FROM Profile WHERE id = :UserInfo.getUserId() limit 1];
        else
            return currentUserProfile;
    }
}