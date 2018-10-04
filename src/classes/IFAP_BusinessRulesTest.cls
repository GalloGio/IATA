@isTest
public class IFAP_BusinessRulesTest {

    /**IFAP_BusinessRulesTest.createIsoCountry
     * Test the method IFAP_BusinessRules.isCountryValid()
     */

    @isTest
    static void testCountryValidation() {
        System.debug('##');
        //create IATA_ISO_Country__c
        createIsoCountry();

        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

        // create test account
        Account account1 = createAccount();
        insert account1;

        // create test contact
        Contact contact1 = createContact(account1);
        insert contact1;

        Case case1 = createCase(contact1, account1);
        insert case1;

        Map<id, Account> accountMap = new Map<id, Account>();
        accountMap.put(case1.id, account1);

        /////////////////////////
        // Positive test case #1
        system.assertEquals(IFAP_BusinessRules.isCountryValid(case1, accountMap), true);

        /////////////////////////
        // Negative test case #1

        account1.BillingCountry = 'Rohan';
        update account1;
        
        //system.assertEquals(IFAP_BusinessRules.isCountryValid(case1,accountMap), false);
    }

    /**
     *
     */
    @isTest
    static void testAgentType() {

        //create IATA_ISO_Country__c
        createIsoCountry();

        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        // create test account
        Account account1 = createAccount();
        insert account1;

        // create test contact
        Contact contact1 = createContact(account1);
        insert contact1;

        Case case1 = createCase(contact1, account1);
        insert case1;

        Map<id, Contact> contactMap = new Map<id, Contact>();
        contactMap.put(case1.id, contact1);

        /////////////////////////
        // Positive test case #1

        system.assertEquals(IFAP_BusinessRules.isAgentTypeValid(case1), false);


        /////////////////////////
        // Positive test case #2

        account1.Type = 'IATA Cargo Agent';
        update account1;
        system.assertEquals(IFAP_BusinessRules.isAgentTypeValid(case1), false);


        /////////////////////////
        // Negative test case #1

        account1.Type = 'Jedi Agent';   // inexisting account type
        update account1;
        system.assertEquals(IFAP_BusinessRules.isAgentTypeValid(case1), false);


        /////////////////////////
        // Negative test case #2

        account1.Type = 'Other1';
        update account1;
        system.assertEquals(IFAP_BusinessRules.isAgentTypeValid(case1), false);


    }

    /**
     *
     */
    @isTest
    static void testAgentCode() {

        //create IATA_ISO_Country__c
        createIsoCountry();

        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        // create test account
        Account account1 = createAccount();
        insert account1;

        // create test contact
        Contact contact1 = createContact(account1);
        insert contact1;

        Case case1 = createCase(contact1, account1);
        insert case1;

        Map<id, Account> accountMap = new Map<id, Account>();
        accountMap.put(case1.id, account1);


        system.assertEquals(IFAP_BusinessRules.isAgentCodeValid(case1, accountMap), true);



    }

    /**
     *
     */
    @isTest
    static void testCaseMassCreation() {

        //create IATA_ISO_Country__c
        createIsoCountry();

        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        List<string> contactIds = new List<string>();
        List<Case> cList = new List<Case>();
        string status = 'Agent Notified';
        string subject = 'Test case';
        string description = 'Test case desc';
        string reviewType = 'Annual';
        date deadline = date.today() + 7;
        String finYear = '2012';
        String finMonth = '';
        // create test account
        Account account1 = createAccount();
        insert account1;

        // create test BatchNumber
        BatchNumber__c batch = new BatchNumber__c();
        insert batch;

        // create contact
        for (Integer i = 0; i < 4; i++) {

            Contact c = new Contact();
            c.FirstName = 'Dummy';
            c.LastName = 'Contact' + i.format();
            c.Type_of_Contact__c = 'IFAP Contact';
            c.AccountId = account1.Id;
            c.Email = 'some' + i.format() + '@email.org';
            insert c;

            Case aCase = new Case();
            aCase.ContactId = c.Id;
            aCase.AccountId = c.accountId;
            aCase.RecordTypeId = IFAPcaseRecordTypeID;
            aCase.Origin = 'Agent Financial Review Notification';
            aCase.BatchNumber__c = batch.Id;
            aCase.Status = status;
            aCase.Subject = subject;
            aCase.Description = description;
            aCase.Financial_Review_Type__c = reviewType;
            aCase.Deadline_Date__c = deadline ;

            // aCase.EmailTemplate__c = 'CA CASS Annual EN';

            cList.add(aCase);

            contactIds.add(c.Id);
        }

        EmailTemplate__c template = new EmailTemplate__c(name = 'test');
        insert template;

        // insert inexisting contact id
        //contactIds.add('321asdf5sdf25');

        Test.startTest();

        IFAP_BusinessRules.massCreateCase(contactIds, batch.Id, status, subject, description, reviewType, deadline, template.Id, finYear, finMonth, 'E-0001', '', false);

        Test.stopTest();

    }

    @isTest
    static void testCheckFinancialAssessmentContactExist() {
        ID StandardAccountRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        ID StandardContactRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        List<Account> accounts = new List<Account>();

        Account aAccount = new Account();
        aAccount.RecordTypeId = StandardAccountRecordTypeId;
        aAccount.Name = 'UnitTestAccount1';
        aAccount.BillingCity = 'Montreal';
        aAccount.BillingCountry = 'Canada';
        aAccount.Type = 'IATA Cargo Agent';
        aAccount.IATACode__c = '12312312';
        aAccount.Location_Type__c = 'AO';
        accounts.add(aAccount);

        aAccount = new Account();
        aAccount.RecordTypeId = StandardAccountRecordTypeId;
        aAccount.Name = 'UnitTestAccount2';
        aAccount.BillingCity = 'Montreal';
        aAccount.BillingCountry = 'Canada';
        aAccount.Type = 'IATA Passenger Sales Agent';
        aAccount.IATACode__c = '12312314';
        aAccount.Location_Type__c = 'HO';
        accounts.add(aAccount);

        insert accounts;

        Test.startTest();
        Contact aContact;

        for (Account existingAccount : accounts) {
            aContact = new Contact();
            aContact.RecordTypeId = StandardContactRecordTypeId;
            aContact.FirstName = 'Unit';
            aContact.LastName = 'Test Contact';
            aContact.AccountId = existingAccount.Id;
            acontact.Financial_Assessment_Contact__c = true;

            insert aContact;

            aContact = new Contact();
            aContact.RecordTypeId = StandardContactRecordTypeId;
            aContact.FirstName = 'Unit';
            aContact.LastName = 'Test Contact #2';
            aContact.AccountId = existingAccount.Id;
            acontact.Financial_Assessment_Contact__c = true;

            try {
                insert aContact;
            } catch (Exception e) {
                //System.assert(e.getMessage().contains('Only one Contact per Account can be defined as Financial Assessment Contact'));
            }
        }
        Test.stopTest();
    }

    @isTest
    static void testVFEmailTemplateController() {

        Test.startTest();
        //create IATA_ISO_Country__c
        createIsoCountry();

        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
         ID IFAPEmailTemplateRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('EmailTemplate__c', 'IFAP');

        EmailTemplate__c e = new EmailTemplate__c();
        IATA_ISO_Country__c ic = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'XY', AIMS_Area_Name__c = 'Test');
        insert ic;
        ic = [Select id, name, ISO_Code__c from IATA_ISO_Country__c where id = : ic.Id];
        e.RecordTypeId = IFAPEmailTemplateRecordTypeID;
        e.Agent_Types__c = 'IATA Cargo Agent';
        e.Review_Types__c = 'Annual';
        e.Subject__c = 'Financial Review';
        e.Deadline_Date_Required__c = true;
        e.Greeting_Line__c = 'Dear Agent';
        e.IATA_ISO_Country__c = ic.id;
        e.Signature_Details__c = 'Yours Sincerely';
        e.Is_reminder__c = false;
        e.Default_Template__c = false;
        e.Template_Language__c = 'English';
        e.Body_Section_1__c = 'Test Email Template';
        e.Template_Type__c = 'FA - Financial Assessment';
        e.Text_1__c = '';
        e.Text_2__c = '';
        e.Text_3__c = '';
        e.Text_4__c = '';
        e.Text_5__c = '';

        insert e;

        Account account1 = createAccount();
        insert account1;

        Contact contact1 = createContact(account1);
        insert contact1;

        IATA_ISO_Country_Set__c iso = new IATA_ISO_Country_Set__c(Name = 'CA', Country_Name__c = 'Canada');
        insert iso;

        EmailTemplate et = [Select id, name from EmailTemplate where templatetype = 'Visualforce' and name = 'IFAP'];


        Case cObj = new Case();
        cObj.Subject = 'Test FR';
        //cObj.RecordTypeId = IFAPcaseRecordTypeID;
        cObj.ContactId = contact1.Id;
        cObj.IFAP_Financial_Year__c = '2012';
        cObj.IFAP_Country_ISO__c = ic.ISO_Code__c;
        cObj.EmailTemplate__c = e.Id;
        cObj.Deadline_Date__c = Date.today() + 30;
        cObj.Financial_Review_Type__c = 'Adhoc';
        cObj.Status = 'Agent Notified (Mail)';
        cObj.Mass_Case_Creation_Email_Send__c = true;
        //cObj.Mode_of_Assessment__c = 'Express';

        insert cObj;
        VFEmailTemplateController vtc = new VFEmailTemplateController();
        vtc.caseId = cObj.Id;
        vtc.greeting = 'Dear Agent';
        vtc.caseURL = 'http://www.google.com';
        vtc.displayDeadline = true;
        vtc.isEnglish = true;
        vtc.templateName = 'IFAP_FA_Reminder';
        vtc.VFEmailTemplateController();

        cObj.Status = 'Agent Notified';
        cObj.Mass_Case_Creation_Email_Send__c = false;
        cObj.Mass_Email_Send__c = true;
        cObj.Reminder_EmailTemplate__c = e.Id;
        update cObj;
        vtc.VFEmailTemplateController();


        cObj.Status = 'Agent Notified (Tracked Email)';
        cObj.Mass_Case_Creation_Email_Send__c = false;
        cObj.Mass_Email_Send__c = false;
        update cObj;
        vtc.VFEmailTemplateController();


        EmailTemplate et1 = [Select id, name from EmailTemplate where templatetype = 'Visualforce' and name = 'IFAP FA Reminder'];
        EmailTemplate__c e1 = new EmailTemplate__c();
        //e1.recordType.Name = 'IFAP';
        e.RecordTypeId = IFAPEmailTemplateRecordTypeID;
        e1.Agent_Types__c = 'IATA Cargo Agent';
        e1.Review_Types__c = 'Annual';
        e1.Subject__c = 'Financial Review reminder';
        e1.Deadline_Date_Required__c = true;
        e1.Greeting_Line__c = 'Dear Agent';
        e1.IATA_ISO_Country__c = ic.id;
        e1.Signature_Details__c = 'Yours Sincerely';
        e1.Is_reminder__c = true;
        e1.Default_Template__c = false;
        e1.Template_Language__c = 'English';
        e1.Body_Section_1__c = 'Test Email Template';
        e1.Template_Type__c = 'FA - Financial Assessment';

        insert e1;
        Test.stopTest();


        Case cObj1 = new Case();
        cObj1.Subject = 'Test FR';
        //cObj1.RecordTypeId = IFAPcaseRecordTypeID;
        cObj1.ContactId = contact1.Id;
        cObj1.IFAP_Financial_Year__c = '2012';
        cObj1.IFAP_Country_ISO__c = ic.ISO_Code__c;
        cObj1.Reminder_EmailTemplate__c = e1.Id;
        cObj1.Deadline_Date__c = Date.today() + 30;
        cObj1.Financial_Review_Type__c = 'Adhoc';

        insert cObj1;
        VFEmailTemplateController vtc1 = new VFEmailTemplateController();
        vtc1.caseId = cObj1.Id;
        vtc1.greeting = 'Dear Agent';
        vtc1.caseURL = 'http://www.google.com';
        vtc1.displayDeadline = true;
        vtc1.isEnglish = true;
        vtc1.templateName = 'IFAP';

        vtc1.VFEmailTemplateController();

        EmailTemplate et2 = [Select id, name from EmailTemplate where templatetype = 'Visualforce' and name = 'IFAP FS Reminder'];
        EmailTemplate__c e2 = new EmailTemplate__c();
        //e2.recordType.Name = 'IFAP';
        e2.RecordTypeId = IFAPEmailTemplateRecordTypeID;
        e2.Agent_Types__c = 'IATA Cargo Agent;IATA Passenger Sales Agent';
        e2.Review_Types__c = 'Annual';
        e2.Subject__c = 'Financial Review reminder';
        e2.Deadline_Date_Required__c = true;
        e2.Greeting_Line__c = 'Dear Agent';
        e2.IATA_ISO_Country__c = ic.id;
        e2.Signature_Details__c = 'Yours Sincerely';
        e2.Is_reminder__c = true;
        e2.Default_Template__c = false;
        e2.Template_Language__c = 'English';
        e2.Body_Section_1__c = 'Test Email Template';
        e2.Template_Type__c = 'FS - Financial Security';
        e2.FA_Result__c = 'Satisfactory - New Financial Security';

        insert e2;

        Case cObj2 = new Case();
        cObj2.Subject = 'Test FR';
        cObj2.ContactId = contact1.Id;
        //cObj2.RecordTypeId = IFAPcaseRecordTypeID;
        cObj2.IFAP_Financial_Year__c = '2012';
        cObj2.Status = 'Financial Security Requested';
        cObj2.Financial_Review_Result__c = 'Satisfactory';
        cObj2.IFAP_Country_ISO__c = ic.ISO_Code__c;
        cObj2.FS_Reminder_EmailTemplate__c = e2.Id;
        cObj2.Deadline_Date__c = Date.today() + 30;
        cObj2.Financial_Review_Type__c = 'Annual';
        cObj2.FS_Mass_Email_Send__c = true;

        insert cObj2;
        VFEmailTemplateController vtc2 = new VFEmailTemplateController();
        vtc2.caseId = cObj2.Id;
        vtc2.greeting = 'Dear Agent';
        vtc2.caseURL = 'http://www.google.com';
        vtc2.displayDeadline = true;
        vtc2.isEnglish = true;
        vtc2.templateName = 'IFAP_FS_Reminder';
        vtc2.VFEmailTemplateController();

        Case cObj3 = new Case();
        cObj3.Subject = 'Test FR';
        cObj3.ContactId = contact1.Id;
        //cObj3.RecordTypeId = IFAPEmailTemplateRecordTypeID;
        cObj3.IFAP_Financial_Year__c = '2012';
        cObj3.Status = 'Financial Security Requested';
        cObj3.Financial_Review_Result__c = 'Satisfactory';
        cObj3.IFAP_Country_ISO__c = ic.ISO_Code__c;
        cObj3.Deadline_Date__c = Date.today() + 30;
        cObj3.Financial_Review_Type__c = 'Annual';
        cObj3.FS_Request_Mass__c = true;
        insert cObj3;

        VFEmailTemplateController vtc3 = new VFEmailTemplateController();
        vtc3.caseId = cObj3.Id;
        vtc3.greeting = 'Dear Agent';
        vtc3.caseURL = 'http://www.google.com';
        vtc3.displayDeadline = true;
        vtc3.isEnglish = true;
        vtc3.templateName = 'IFAP_FS_Request';
        vtc3.checkValue = 'test';
        vtc3.displayReminderContent = false;
        vtc3.reviewType = 'test';
        vtc3.agentType = 'test';
        vtc3.ISOCode = 'test';
        vtc3.VFEmailTemplateController();

    }


    @isTest
    static void testIsStatusCanBeSelected() {

        Id userID = [Select ID from User where ID != : userinfo.getuserid() limit 1][0].id;
        UtilityCS__c util = new UtilityCS__c(name = 'IFAP Bypass Rules', value__c = userID);
        insert util;

        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        Map<ID,Boolean> mapStatusCanBeSelected;
        /*non Sys Admin, non Portal user profile*/
        Profile p = new Profile(Name = 'IFAP Profile');

        List<Case> allIfapCaseStatus = new List<Case>();

        /*0*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Action Needed'));
        /*1*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Agent Notified (Email)'));
        /*2*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Agent Notified (Mail)'));
        /*3*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Agent to be Notified'));
        /*4*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Assessment Cancelled'));
        /*5*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Assessment Performed'));
        /*6*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Closed'));
        /*7*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Financial Security Provided'));
        /*8*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Financial Security Rejected'));
        /*9*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Financial Security Requested'));
        /*10*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Financial Statements Uploaded'));
        /*11*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Quality Issue Rejected'));
        /*12*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Quality Issue Request Approved'));
        /*13*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Quality Issue Requested'));
        /*14*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Quality Issue Request Pending Approval'));
        /*15*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Re-open/ed'));
        /*16*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Sanity Check Failure'));
        /*17*/allIfapCaseStatus.add(new Case(RecordTypeId = IFAPcaseRecordTypeID, Status = 'Submitted'));

        //loop over all cases, instead of having to check each combination individually
        for (Integer i = 0; i < allIfapCaseStatus.size(); i++){
            Map<ID, Case> mapCases = new Map<ID, Case>(allIfapCaseStatus);
            mapCases.put(allIfapCaseStatus[i].ID, allIfapCaseStatus[i]);    
        
            for (Integer j = 0; j < allIfapCaseStatus.size(); j++) {
                if (i == j)
                    continue;
                List<Case> allIfapCases = new List<Case>{allIfapCaseStatus[j]};
                //check only the combinations of allowed changes that have no dependencies on case fields
                if (
                    (i == 0 && (j == 1 || j == 2 || j == 3 || j == 7) ) ||
                    (i == 1 && (j == 2)) ||
                    (i == 2 && (j == 1)) ||
                    (i == 3 && (j == 1 || j == 2)) ||
                    (i == 5 && (j == 14)) ||
                    (i == 8 && (j == 7)) ||
                    (i == 9 && (j == 7 || j == 8 || j == 14)) ||
                    (i == 10 && (j == 1 || j == 2 || j == 16)) ||
                    (i == 11 && (j == 5 || j == 7 || j == 16 || j == 14)) ||
                    (i == 14 && (j == 11 || j == 12)) ||
                    (i == 16 && (j == 14))
                ) {
                    mapStatusCanBeSelected = IFAP_BusinessRules.IsStatusCanBeSelected(false, allIfapCases, mapCases, p, false);
                    System.assert(mapStatusCanBeSelected.values().get(0));
                    continue;
                }

                System.debug('##STATUS CHECK### old status ' + allIfapCaseStatus[i].Status + ' new status ' + allIfapCaseStatus[j].Status);
                //combinations not stated avove should not be allowed
                mapStatusCanBeSelected = IFAP_BusinessRules.IsStatusCanBeSelected(false, allIfapCases, mapCases, p, false);
                System.assert(!mapStatusCanBeSelected.values().get(0));
            }
        }

    }

    @isTest
    static void testFSValidationCheckBox() {
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        Profile p = new Profile();
        p.Name = 'system administrator';
        Case c1 = new Case();
        c1.Status = 'agent notified (email)';
        Case c2 = new Case();
        c2.status = 'closed';
        c2.FS_Submitted_Date__c = Date.today();
        c2.Agent_Name_chkbx__c = false;
        c2.Financial_Security_Amount_chkbx__c = false;
        c2.Financial_Security_Currency_chkbx__c = false;
        c2.Financial_Security_Provider_chkbx__c = false;
        c2.Financial_Security_Template_chkbx__c = false;
        c2.Financial_Security_Type_chkbx__c = false;
        c2.Expiry_Date_chkbx__c = false;



        IFAP_BusinessRules.FSValidationCheckBox(c1, c2, p);
        p.Name = 'ifap customer portal user';
        IFAP_BusinessRules.FSValidationCheckBox(c1, c2, p);
        p.Name = 'TEST';
        IFAP_BusinessRules.FSValidationCheckBox(c1, c2, p);
        c2.Status = 'Financial Security Requested';
        c2.Agent_Name_chkbx__c = true;
        c2.Financial_Security_Amount_chkbx__c = true;
        c2.Financial_Security_Currency_chkbx__c = true;
        c2.Financial_Security_Provider_chkbx__c = true;
        c2.Financial_Security_Template_chkbx__c = true;
        c2.Financial_Security_Type_chkbx__c = true;
        c2.Expiry_Date_chkbx__c = true;
        IFAP_BusinessRules.FSValidationCheckBox(c1, c2, p);

    }

    @isTest
    static void testSetCountryAreaAndISOCode() {

        //create IATA_ISO_Country__c
        createIsoCountry();

        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        // create test account
        Account account1 = createAccount();
        insert account1;

        // create test contact
        Contact contact1 = createContact(account1);
        insert contact1;

        Case case1 = createCase(contact1, account1);
        insert case1;

        Map<id, Account> accountMap = new Map<id, Account>();
        accountMap.put(case1.id, account1);

        IFAP_BusinessRules.setCountryAreaAndISOCode(case1, accountMap);

        //error case
        account1.BillingCountry = 'USA';
        account1.BillingCity = 'New york';
        update account1;
        //IFAP_BusinessRules.setCountryAreaAndISOCode(case1,accountMap);
    }

    @isTest
    static void testEmailTemplateCountryValidation() {
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        ID IFAPEmailTemplateRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('EmailTemplate__c', 'IFAP');
        IATA_ISO_Country__c ic = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'XY', AIMS_Area_Name__c = 'Test');
        insert ic;

        EmailTemplate__c e = new EmailTemplate__c();
        ic = [Select id, name, ISO_Code__c from IATA_ISO_Country__c where id = : ic.Id];
        //e.recordType.Name = 'IFAP';
        e.RecordTypeId = IFAPEmailTemplateRecordTypeID;
        e.Agent_Types__c = 'IATA Cargo Agent';
        e.Review_Types__c = 'Annual';
        e.Subject__c = 'Financial Review';
        e.Deadline_Date_Required__c = true;
        e.Greeting_Line__c = 'Dear Agent';
        e.IATA_ISO_Country__c = ic.id;
        e.Signature_Details__c = 'Yours Sincerely';
        e.Is_reminder__c = false;
        e.Default_Template__c = false;
        e.Template_Language__c = 'English';
        e.Body_Section_1__c = 'Test Email Template';
        insert e;

        // reselect template
        e = [Select et.IATA_ISO_Country__r.Id from EmailTemplate__c et where et.Id = : e.Id and et.recordType.Name = 'IFAP' limit 1];

        // invalid country test
        system.assert(IFAP_BusinessRules.isTemplateCountryValid(e, 'AA') == false);

        // valid country test
        system.assert(IFAP_BusinessRules.isTemplateCountryValid(e, 'XY') == true);
    }

    @isTest
    static void testProcessISSTrigger() {

        //create IATA_ISO_Country__c
        createIsoCountry();

        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

        ///////////////////////////////////
        // create parent case of type IFAP

        // create test account
        Account account1 = createAccount();
        insert account1;

        // create test contact
        Contact contact1 = createContact(account1);
        contact1.Financial_Assessment_Contact__c = true;
        insert contact1;

        Case caseParent = createCase(contact1, account1);
        caseParent.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        caseParent.Status = 'Agent Notified (Mail)';
        caseParent.Origin = 'Agent Financial Review Notification';
        caseParent.FA_Letter_Sent__c = false;
        caseParent.IFAP_Financial_Year__c = '2012';
        caseParent.Financial_Review_Type__c = 'Annual';
        caseParent.IFAP_Financial_Year__c = '2012';
        caseParent.Deadline_Date__c = Date.today().addDays(30);
        insert caseParent;


        /////////////////////////////////////////
        // create child case of type Process ISS

        Case caseChild = createCase(contact1, account1);
        caseChild.Subject = 'Test Case child';
        caseChild.Description = 'Test Case child';
        caseChild.ParentId = caseParent.Id;
        caseChild.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');//SAAM

        Test.startTest();

        // should throw error
        try {
            insert caseChild;
            system.assert(false);
        } catch (Exception ex) {
            system.assert(true);
        }

        caseParent.FA_Letter_Sent__c = true;
        update caseParent;

        // should not throw error
        try {
            insert caseChild;
            system.assert(true);
        } catch (Exception ex) {
            system.assert(false);
        }

        caseParent.FS_Letter_Sent__c = false;
        caseParent.Status = 'Financial Security Requested';
        update caseParent;

        // should throw error
        try {
            update caseChild;
            system.assert(false);
        } catch (Exception ex) {
            system.assert(true);
        }

        caseParent.FS_Letter_Sent__c = true;
        caseParent.Status = 'Financial Security Requested';
        update caseParent;

        // should not throw error
        try {
            update caseChild;
            system.assert(true);
        } catch (Exception ex) {
            system.assert(false);
        }

        Test.stopTest();
    }

    @isTest
    static void testEmailTemplateBusinesRules() {

        //create IATA_ISO_Country__c
        createIsoCountry();

        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        ID IFAPEmailTemplateRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('EmailTemplate__c', 'IFAP');
        IATA_ISO_Country__c[] countryCA = [Select i.Name, i.ISO_Code__c From IATA_ISO_Country__c i where i.ISO_Code__c = 'CA'];
        IATA_ISO_Country__c[] countryFR = [Select i.Name, i.ISO_Code__c From IATA_ISO_Country__c i where i.ISO_Code__c = 'FR'];

        // create test account
        Account account1 = createAccount();
        insert account1;

        // create test contact
        Contact contact1 = createContact(account1);
        contact1.Financial_Assessment_Contact__c = true;
        insert contact1;

        Case case1 = createCase(contact1, account1);
        case1.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        case1.Status = 'Agent Notified (Mail)';
        case1.Origin = 'Agent Financial Review Notification';
        case1.FA_Letter_Sent__c = false;
        case1.IFAP_Financial_Year__c = '2012';
        case1.Financial_Review_Type__c = 'Annual';
        case1.IFAP_Financial_Year__c = '2012';
        case1.Deadline_Date__c = Date.today().addDays(30);

        EmailTemplate__c email1 = new EmailTemplate__c();
        //email1.recordType.Name = 'IFAP';
        email1.RecordTypeId = IFAPEmailTemplateRecordTypeID;
        email1.Name = 'TemplateTest';
        email1.Template_Type__c = 'FA - Financial Assessment';
        email1.Agent_Types__c = 'Domestic Agent';
        email1.IATA_ISO_Country__c = countryFR[0].Id;
        insert email1;

        Test.startTest();

        // test #1 - FA template country does not match case country
        case1.IFAP_Country_ISO__c = countryCA[0].ISO_Code__c;
        case1.EmailTemplate__c = email1.Id;
        try {
            insert case1;
            system.assert(false);
        } catch (Exception ex) {
            system.assert(true);
        }

        // test #2 - FA reminder template does not match case country
        case1.EmailTemplate__c = null;
        case1.Reminder_EmailTemplate__c = email1.Id;
        try {
            insert case1;
            system.assert(false);
        } catch (Exception ex) {
            system.assert(true);
        }

        // test #3 - FS template does not match case country
        case1.EmailTemplate__c = null;
        case1.Reminder_EmailTemplate__c = null;
        case1.FS_EmailTemplate__c = email1.Id;
        try {
            insert case1;
            system.assert(false);
        } catch (Exception ex) {
            system.assert(true);
        }

        // test #4 - FS reminder template does not match case country
        case1.EmailTemplate__c = null;
        case1.Reminder_EmailTemplate__c = null;
        case1.FS_EmailTemplate__c = null;
        case1.FS_Reminder_EmailTemplate__c = email1.Id;
        try {
            insert case1;
            system.assert(false);
        } catch (Exception ex) {
            system.assert(true);
        }

        ////////////////////////////////////////
        // now sames test when updating a case

        case1.EmailTemplate__c = null;
        case1.Reminder_EmailTemplate__c = null;
        case1.FS_EmailTemplate__c = null;
        case1.FS_Reminder_EmailTemplate__c = null;
        insert case1;

        // test #5 - FA template country does not match case country
        case1.IFAP_Country_ISO__c = countryCA[0].ISO_Code__c;
        case1.EmailTemplate__c = email1.Id;
        try {
            update case1;
            system.assert(false);
        } catch (Exception ex) {
            system.assert(true);
        }

        // test #6 - FA reminder template does not match case country
        case1.EmailTemplate__c = null;
        case1.Reminder_EmailTemplate__c = email1.Id;
        try {
            update case1;
            system.assert(false);
        } catch (Exception ex) {
            system.assert(true);
        }

        // test #7 - FS template does not match case country
        case1.EmailTemplate__c = null;
        case1.Reminder_EmailTemplate__c = null;
        case1.FS_EmailTemplate__c = email1.Id;
        try {
            update case1;
            system.assert(false);
        } catch (Exception ex) {
            system.assert(true);
        }

        // test #8 - FS reminder template does not match case country
        case1.EmailTemplate__c = null;
        case1.Reminder_EmailTemplate__c = null;
        case1.FS_EmailTemplate__c = null;
        case1.FS_Reminder_EmailTemplate__c = email1.Id;
        try {
            update case1;
            system.assert(false);
        } catch (Exception ex) {
            system.assert(true);
        }

        Test.stopTest();

    }



    @isTest
    static void testPhase4stuff() {

        //create IATA_ISO_Country__c
        createIsoCountry();

        // get some recordtype IDs
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        Id SAAMcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');

        // create test account1
        Account account1 = createAccount();
        insert account1;

        // create test contact
        Contact contact1 = createContact(account1);
        contact1.Financial_Assessment_Contact__c = true;
        insert contact1;

        Case saamCase = createCase(contact1, account1);
        saamCase.Subject = 'Test SAAM case';
        saamCase.Description = 'Test SAAM case';
        saamCase.Status = 'Open';
        saamCase.RecordTypeId = SAAMcaseRecordTypeId;
        insert saamCase;

        Test.startTest();

        // Test #1 - Saam case has no child IFAP case
//        system.assert(IFAP_BusinessRules.caseHasChildIFAPCases(saamCase.Id) == false);

        Case ifapCase = createCase(contact1, account1);
        ifapCase.ParentId = saamCase.Id;
        ifapCase.Subject = 'Test IFAP case';
        ifapCase.Description = 'Test IFAP case';
        ifapCase.RecordTypeId = IFAPcaseRecordTypeID;
        ifapCase.IFAP_Financial_Year__c = '2013';
        insert ifapCase;

        // Test #2 - Saam case has no child IFAP case
//        system.assert(IFAP_BusinessRules.caseHasChildIFAPCases(saamCase.Id) == true);

        // Test #3 - Test the update of fields from the IFAP case to the SAAM case
        Date submittedDate = Date.today();
        Date assessmentPerformedDate = Date.today().addDays(3);
        String financialReviewResult = 'Satisfactory - Update Financial Security';

        ifapCase.Submitted_Date__c = submittedDate;
        ifapCase.Assessment_Performed_Date__c = assessmentPerformedDate;
        ifapCase.Financial_Review_Result__c = financialReviewResult;
        update ifapCase;

        // reselect the SAAM case
        saamCase = [Select c.Id, c.Financial_Assessment_requested__c, c.Financial_Assessment_deadline__c, c.Financial_Assessment_received__c, c.Financial_Assessment_compliant__c from Case c where c.Id = :saamCase.Id limit 1];

        system.assert(saamCase.Financial_Assessment_requested__c == submittedDate);
        system.assert(saamCase.Financial_Assessment_deadline__c == submittedDate.addDays(5));
        system.assert(saamCase.Financial_Assessment_received__c == assessmentPerformedDate);
        system.assert(saamCase.Financial_Assessment_compliant__c == 'Satisfactory');

        // Test #4 - test if case has reassessments
        IFAP_BusinessRules.caseHasReassesments(ifapCase.Id);

        Test.stopTest();
    }

    @isTest
    static void testGetAssessmentTemplateForAccount() {

        //prepare test data
        Account account1 = createAccount();
        Assessment_Template__c assTemplate = createAssessmentTemplate();
        insert assTemplate;

        Test.startTest();

        account1.Assessment_Template__c = IFAP_BusinessRules.getAssessmentTemplateForAccount(account1);
        system.assertEquals(true, account1.Assessment_Template__c != null);

        Test.stopTest();
    }



    @isTest
    static void testIsReassessmentAccountingIssueLinked() {
        //prepare test data
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

        createIsoCountry();
        IATA_ISO_Country__c country = [SELECT Name, ISO_Code__c FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'CA' LIMIT 1][0];

        Account account1 = createAccount();
        insert account1;

        Contact contact1 = createContact(account1);
        contact1.Financial_Assessment_Contact__c = true;
        insert contact1;

        List<Case> caseList = new List<Case>();
        Case case1 = createCase(contact1, account1);
        case1.RecordTypeId = IFAPcaseRecordTypeID;
        case1.IFAP_Financial_Year__c = '2012';
        case1.Status = 'Financial Security Requested';
        case1.Financial_Review_Result__c = 'Satisfactory - New Financial Security';
        case1.IFAP_Country_ISO__c = country.ISO_Code__c;
        case1.Deadline_Date__c = Date.today() + 30;
        case1.Financial_Review_Type__c = 'Annual';

        caseList.add(case1);
        insert caseList;

        Test.startTest();

        IFAP_Quality_Issue__c qualityIssue1 = createIFAPQualityIssue(caseList[0]);
        qualityIssue1.Missing_value_in_fields__c = true;
        qualityIssue1.Formatting_Issue_details__c = 'test details';
        insert qualityIssue1;

        IFAP_Reassessment_Accounting_Issue__c accountingIssue1 = createIFAPReassessmentAccountingIssue(qualityIssue1);
        insert accountingIssue1;

        system.assertEquals(true, IFAP_BusinessRules.isReassessmentAccountingIssueLinked(qualityIssue1));

        Test.stopTest();
    }

    @isTest
    static void testIsAtLeastOneQualityIssueIsSelected() {
        //prepare test data
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

        createIsoCountry();

        Account account1 = createAccount();
        insert account1;

        Contact contact1 = createContact(account1);
        insert contact1;

        List<Case> caseList = new List<Case>();
        Case case1 = createCase(contact1, account1);

        IFAP_Quality_Issue__c qualityIssue1 = createIFAPQualityIssue(case1);

        Test.startTest();

        system.assertEquals(false, IFAP_BusinessRules.isAtLeastOneQualityIssueIsSelected(qualityIssue1));
        qualityIssue1.Wrong_financial_year__c = true;
        system.assertEquals(true, IFAP_BusinessRules.isAtLeastOneQualityIssueIsSelected(qualityIssue1));

        Test.stopTest();
    }

    @isTest
    static void testIsOtherDetailsFieldRequired() {
        //prepare test data
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

        createIsoCountry();

        Account account1 = createAccount();
        insert account1;

        Contact contact1 = createContact(account1);
        insert contact1;

        List<Case> caseList = new List<Case>();
        Case case1 = createCase(contact1, account1);

        IFAP_Quality_Issue__c qualityIssue1 = createIFAPQualityIssue(case1);

        Test.startTest();

        system.assertEquals(false, IFAP_BusinessRules.isOtherDetailsFieldRequired(qualityIssue1));
        qualityIssue1.Incorrect_sales_used_for_the_assessment__c = true;
        system.assertEquals(true, IFAP_BusinessRules.isOtherDetailsFieldRequired(qualityIssue1));

        Test.stopTest();
    }

    @isTest
    static void testIsFormattingIssueDetailsRequired() {
        //prepare test data
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

        createIsoCountry();

        Account account1 = createAccount();
        insert account1;

        Contact contact1 = createContact(account1);
        insert contact1;

        List<Case> caseList = new List<Case>();
        Case case1 = createCase(contact1, account1);

        IFAP_Quality_Issue__c qualityIssue1 = createIFAPQualityIssue(case1);

        Test.startTest();

        system.assertEquals(false, IFAP_BusinessRules.isFormattingIssueDetailsRequired(qualityIssue1));
        qualityIssue1.Output_is_empty_not_completed_has_errors__c = true;
        system.assertEquals(true, IFAP_BusinessRules.isFormattingIssueDetailsRequired(qualityIssue1));

        Test.stopTest();
    }

    //data creation - private methods:

    /**
     * Creates IATA_ISO_Country__c records for Canada and France
     */

//SO_Code__c IN ('EG')])



    public static void createIsoCountry() {

        List<IATA_ISO_Country__c> isoCountriesCA = new List<IATA_ISO_Country__c> {
            new  IATA_ISO_Country__c(
                name = 'Canada',
                ISO_Code__c = 'CA',
                ISO_Code_Numeric__c = 123, //not real code
                CurrencyIsoCode = 'CAD',
                AIMS_Area_ID__c = '1'),
            new  IATA_ISO_Country__c(
                name = 'France',
                ISO_Code__c = 'FR',
                ISO_Code_Numeric__c = 356, //not real code
                currencyIsoCode = 'EUR',
                AIMS_Area_ID__c = '2'),
            new  IATA_ISO_Country__c(
                name = 'Fradsce',
                ISO_Code__c = 'EG',
                ISO_Code_Numeric__c = 456,//not real code
                currencyIsoCode = 'EUR',
                AIMS_Area_ID__c = '2')
        };
        database.insert(isoCountriesCA, false);

    }



    /**
     * Creates an Account record
     */
    private static Account createAccount() {

        Account account = new Account(IATACode__c = '1234567');    // 7 digits
        account.Name = 'Test account';
        account.BillingCity = 'Montreal';
        account.BillingCountry = 'Canada';
        account.BillingStreet = 'some street';
        account.Type = 'IATA Passenger Sales Agent';
        account.Location_Type__c = 'HO';

        return account;
    }

    /**
     * Creates a Contact record
     */
    private static Contact createContact(Account account) {

        Contact contact = new Contact();
        contact.FirstName = 'Dummy';
        contact.LastName = 'Contact';
        contact.Type_of_Contact__c = 'IFAP Contact';
        contact.AccountId = account.Id;
        contact.Email = 'some@email.org';

        return contact;
    }

    /**
     * Creates a Case record
     */
    private static Case createCase(Contact contact, Account account) {

        Case case1 = new Case();
        case1.ContactId = contact.Id;
        case1.AccountId = account.Id;
        case1.Subject = 'Test Case 1';
        case1.Description = 'Test Case 1';
        //case1.RecordTypeId = IFAPcaseRecordTypeID;

        return case1;
    }

    /**
     * Creates an Assessment_Template__c record
     */
    private static Assessment_Template__c createAssessmentTemplate() {

        Assessment_Template__c assTemplate = new Assessment_Template__c();
        assTemplate.Name = 'test Assessment Template';
        assTemplate.Country_ISO_Code__c = 'CA';
        assTemplate.Country_Name__c = 'Canada';
        assTemplate.Template_Code__c = 'tstCode';
        assTemplate.Passenger_Cargo__c = 'P';

        return assTemplate;
    }

    /**
     * Creates a IFAP_Quality_Issue__c record
     */
    private static IFAP_Quality_Issue__c createIFAPQualityIssue(Case case1) {

        IFAP_Quality_Issue__c qualityIssue = new IFAP_Quality_Issue__c();
        qualityIssue.Related_Case__c = case1.id;
        qualityIssue.Challenge_Source__c = 'internal';

        return qualityIssue;
    }

    /**
     * Creates a IFAP_Reassessment_Accounting_Issue__c record
     */
    private static IFAP_Reassessment_Accounting_Issue__c createIFAPReassessmentAccountingIssue(IFAP_Quality_Issue__c qualityIssue) {

        IFAP_Reassessment_Accounting_Issue__c accountingIssue = new IFAP_Reassessment_Accounting_Issue__c();
        accountingIssue.IFAP_Reassessment__c = qualityIssue.id;
        accountingIssue.Value_to_use__c = 'test value to use';
        accountingIssue.Wrong_value__c = 'test wrong value';
        accountingIssue.Comment__c = 'test Comment';
        accountingIssue.Field_Name__c = 'test Field Name';

        return accountingIssue;
    }
}