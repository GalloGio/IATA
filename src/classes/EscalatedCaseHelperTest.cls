@isTest
private class EscalatedCaseHelperTest {

	//static final String KALE_SUPPORT_EMAIL = 'servicedesk@kaleconsultants.com';
    static final String KALE_SUPPORT_EMAIL = 'johnsonk@iata.org';	// ITS test
    //static final String KALE_SUPPORT_EMAIL = 'kaleuser@yahoo.com';	// Business UAT

    static testMethod void testCaseHasBeenEscalatedToKale() {
        
        // test cases
        Case case1 = new Case();
        case1.Subject = 'Your request has been logged with SCP request ID ##1732## and SF No. 2069551';
        case1.SuppliedEmail = KALE_SUPPORT_EMAIL;
        Case case2 = new Case();
        case2.Subject = 'asdf';
        case2.SuppliedEmail = KALE_SUPPORT_EMAIL;

        //system.assert(EscalatedCaseHelper.caseHasBeenEscalatedToKale(case1) == true);
        system.assert(EscalatedCaseHelper.caseHasBeenEscalatedToKale(case2) == false);
        EscalatedCaseHelper.caseHasBeenEscalatedToKale(case2);
        EscalatedCaseHelper.caseHasNewCommentByKale(case2);
        EscalatedCaseHelper.caseHasBeenResolvedByKale(case2);
        EscalatedCaseHelper.caseHasBeenClosedByKale(case2);
        EscalatedCaseHelper.caseStatusHasBeenUpdatedByKale(case2);
    }
    
    static testMethod void testCaseHasBeenUpdatedCommentedOrResolved() {
        
        // test cases
        Case case1 = new Case();
        case1.Subject = 'SCP Incident No: ##4242## raised by you was updated - SF No. 1980094';
        case1.SuppliedEmail = KALE_SUPPORT_EMAIL;
        
        Case case2 = new Case();
        case2.Subject = 'Re: [Request ID :##4242##] : Excel SIS usage report is missing headers - SF Incident No. 02023138';
        case2.SuppliedEmail = KALE_SUPPORT_EMAIL;
        
        Case case3 = new Case();
        case3.Subject = 'Your Request with ID :##4242## has been Resolved - SF No. 02023138';
        case3.SuppliedEmail = KALE_SUPPORT_EMAIL;
        
        Case case4 = new Case();
        case4.Subject = 'Request : ##4242## raised by you was closed - SF No. 02023138';
        case4.SuppliedEmail = KALE_SUPPORT_EMAIL;
        
        Case case5 = new Case();
        case5.Subject = 'asdf';
        case5.SuppliedEmail = KALE_SUPPORT_EMAIL;

        //system.assert(EscalatedCaseHelper.caseStatusHasBeenUpdatedByKale(case1) == true);
        //system.assert(EscalatedCaseHelper.caseHasNewCommentByKale(case2) == true);
        /*system.assert(EscalatedCaseHelper.caseHasBeenResolvedByKale(case3) == true);
        system.assert(EscalatedCaseHelper.caseHasBeenClosedByKale(case4) == true);
        
        system.assert(EscalatedCaseHelper.caseStatusHasBeenUpdatedByKale(case5) == false);
        system.assert(EscalatedCaseHelper.caseHasNewCommentByKale(case5) == false);
        system.assert(EscalatedCaseHelper.caseHasBeenResolvedByKale(case5) == false);
        system.assert(EscalatedCaseHelper.caseHasBeenClosedByKale(case5) == false);*/
    }
       
    static testMethod void testUpdateExternalReferenceNumber() {
        
        String sfCaseNumber, kaleCaseNumber;
        
        // create original case and save it
        Case case1 = new Case();
        case1.Subject = 'test case';
        insert case1;
        
        // reselect the case to have its CaseNumber
        case1 = [Select c.CaseNumber, c.Subject From Case c where Id=:case1.Id];
        sfCaseNumber = case1.CaseNumber;
        kaleCaseNumber = '42';
        
        /////////////////////////
        // Positive test case #1
        
        Case emailToCase = new Case();
        emailToCase.Subject = 'Your request has been logged with SCP request ID ##' + kaleCaseNumber + '## and SF No. ' +  sfCaseNumber;
        emailToCase.SuppliedEmail = KALE_SUPPORT_EMAIL;
        emailToCase.Description = 'Dear SIS Customer Support,\nSCP Incident no ' + kaleCaseNumber + ' is Created.\nSF Case No : ' +  sfCaseNumber + '\nSubject : UATP Amount mismatch in Sampling\nSCP Incident No : 1732\nReceived Date : 18-Nov-2011 00:06\nStatus : Open\nDescription : Dear SIS Ops Team';
        
        // update External Reference Number
        EscalatedCaseHelper.updateExternalReferenceNumber(emailToCase);
        
        // get original case
        Case originalCase = [Select c.External_Reference_Number__c, c.Description, c.CaseNumber From Case c where CaseNumber=: sfCaseNumber];

        system.assertEquals(kaleCaseNumber, originalCase.External_Reference_Number__c);
        
        /////////////////////////
        // Negative test case #1
        
        Case emailToCaseFAIL = new Case();
        emailToCaseFAIL.Subject = 'Your request has been logged with request ID ##' + kaleCaseNumber + '##';
        emailToCaseFAIL.SuppliedEmail = KALE_SUPPORT_EMAIL;
        emailToCaseFAIL.Description = 'The title of the request is SIS Case #.No SF Case Number here...';
        
        try {
            // update External Reference Number (supposed to FAIL)
            EscalatedCaseHelper.updateExternalReferenceNumber(emailToCaseFAIL);
            
            // if here, test failed (supposed to throw exception)
            system.assert(false);
        }
        catch (Exception ex) {
            // if here, test succeeded
            system.assert(true);
        }
        
        /////////////////////////
        // Negative test case #2
        
        Case emailToCaseFAIL2 = new Case();
        emailToCaseFAIL2.Subject = 'Your request has been logged with request ID ##' + kaleCaseNumber + '## no SF case number here';
        emailToCaseFAIL2.SuppliedEmail = KALE_SUPPORT_EMAIL;
        emailToCaseFAIL2.Description = 'No SF Case Number here...';
        
        try {
            // update External Reference Number (supposed to FAIL)
            EscalatedCaseHelper.updateExternalReferenceNumber(emailToCaseFAIL2);
            
            // if here, test failed (supposed to throw exception)
            system.assert(false);
        }
        catch (Exception ex) {
            // if here, test succeeded
            system.assert(true);
        }
        
        /////////////////////////
        // Negative test case #3
        
        Case emailToCaseFAIL3 = new Case();
        emailToCaseFAIL3.Subject = 'Your request has been logged with request ID ##' + kaleCaseNumber + '## and SF No. 0042424242';// unexisting case
        emailToCaseFAIL3.SuppliedEmail = KALE_SUPPORT_EMAIL;
        emailToCaseFAIL3.Description = 'Bla bla bla';   
        
        try {
            // update External Reference Number (supposed to FAIL)
            EscalatedCaseHelper.updateExternalReferenceNumber(emailToCaseFAIL3);
            
            // if here, test failed (supposed to throw exception)
            system.assert(false);
        }
        catch (Exception ex) {
            // if here, test succeeded
            system.assert(true);
        }
    }
    
    static testMethod void testUpdateCaseCommentWithResolution() {
        
        String sfCaseNumber, kaleCaseNumber;
        
        // create original case and save it
        Case case1 = new Case();
        case1.Subject = 'test case';
        insert case1;
        
        // reselect the case to have its CaseNumber
        case1 = [Select c.CaseNumber, c.Subject From Case c where Id=:case1.Id];
        sfCaseNumber = case1.CaseNumber;
        kaleCaseNumber = '42';
        
        /////////////////////////
        // Positive test case #1
        
        Case emailToCase = new Case();
        emailToCase.Subject = 'Request : ##' + kaleCaseNumber + '## raised by you was closed - SF No. ' + sfCaseNumber;
        emailToCase.SuppliedEmail = KALE_SUPPORT_EMAIL;
        emailToCase.Description = 'Bla bla bla \nResolution : use Alt+F4\nsecond line resolution\nthird line resolution\nFor a prompt response, please address your correspondence\nBla Bla Bla';
        
        // udate case resolution
        EscalatedCaseHelper.updateCaseWithResolution(emailToCase);
        
        // get original case
        CaseComment theCaseComment = [Select Id, ParentId, CommentBody from CaseComment where ParentId=:case1.Id order by CreatedDate desc limit 1];

        system.assertEquals('Resolution : use Alt+F4\nsecond line resolution\nthird line resolution', theCaseComment.CommentBody);
        
        /////////////////////////
        // Negative test case #1
        
        Case emailToCaseFAIL = new Case();
        emailToCaseFAIL.Subject = '';   // no subject
        emailToCaseFAIL.SuppliedEmail = KALE_SUPPORT_EMAIL;
        emailToCaseFAIL.Description = 'bla bla bla';
        
        try {
            // update External Reference Number (supposed to FAIL)
            EscalatedCaseHelper.updateCaseWithResolution(emailToCaseFAIL);
            
            // if here, test failed (supposed to throw exception)
            system.assert(false);
        }
        catch (Exception ex) {
            // if here, test succeeded
            system.assert(true);
        }
    }
    
    static testMethod void testUpdateCaseCommentWithKaleComment() {
        
        String sfCaseNumber, kaleCaseNumber;
        
        // create original case and save it
        Case case1 = new Case();
        case1.Subject = 'test case';
        insert case1;
        
        // reselect the case to have its CaseNumber
        case1 = [Select c.CaseNumber, c.Subject From Case c where Id=:case1.Id];
        sfCaseNumber = case1.CaseNumber;
        kaleCaseNumber = '42';
        
        /////////////////////////
        // Positive test case #1
        
        Case emailToCase = new Case();
        emailToCase.Subject = 'Re: [Request ID :##' + kaleCaseNumber + '##] : Excel SIS usage report is missing headers - SF Incident No. ' + sfCaseNumber;
        emailToCase.SuppliedEmail = KALE_SUPPORT_EMAIL;
        emailToCase.Description = 'Blablabla1\nBlablabla2\nBlablabla3\n\nOn 30-Nov-2011 04:53 SIS Customer Support wrote ';
        
        // udate case resolution
        EscalatedCaseHelper.updateCaseWithKaleComment(emailToCase);
        
        // get original case
        CaseComment theCaseComment = [Select Id, ParentId, CommentBody from CaseComment where ParentId=:case1.Id order by CreatedDate desc limit 1];

        system.assertEquals('Blablabla1\nBlablabla2\nBlablabla3', theCaseComment.CommentBody);
        
        /////////////////////////
        // Negative test case #1
        
        Case emailToCaseFAIL = new Case();
        emailToCaseFAIL.Subject = 'Re: [Request ID :##' + kaleCaseNumber + '##] : Excel SIS usage report is missing headers - SF Incident No. ' + sfCaseNumber;
        emailToCaseFAIL.SuppliedEmail = KALE_SUPPORT_EMAIL;
        emailToCaseFAIL.Description = '';
        
        try {
            // update External Reference Number (supposed to FAIL)
            EscalatedCaseHelper.updateCaseWithKaleComment(emailToCaseFAIL);
            
            // if here, test failed (supposed to throw exception)
            system.assert(false);
        }
        catch (Exception ex) {
            // if here, test succeeded
            system.assert(true);
        }
    }
    
    static testMethod void testKaleCaseStatusChange() {
        
        String sfCaseNumber, kaleCaseNumber;
        
        // create original case and save it
        Case case1 = new Case();
        case1.Subject = 'test case';
        insert case1;
        
        // reselect the case to have its CaseNumber
        case1 = [Select c.CaseNumber, c.Subject From Case c where Id=:case1.Id];
        sfCaseNumber = case1.CaseNumber;
        kaleCaseNumber = '42';
        
        /////////////////////////
        // Positive test case #1
        
        Case emailToCase = new Case();
        emailToCase.Subject = 'SCP Incident No: ##' + kaleCaseNumber + '## raised by you was updated - SF No. ' + sfCaseNumber;
        emailToCase.SuppliedEmail = KALE_SUPPORT_EMAIL;
        emailToCase.Description = 'Dear SIS Customer Support,\nSCP Incident no 4242 is updated.\nSF Case No : 02023138\nSubject : Excel SIS usage report is missing headers\nSCP Incident No : 4242\nReceived Date : 30-Nov-2011 04:53\nStatus : Open\nDescription : Hi ,';
        
        // udate case comment with the new status
        EscalatedCaseHelper.updateCaseWithKaleSCPStatus(emailToCase);
        
        // get case comment
        CaseComment theCaseComment = [Select Id, ParentId, CommentBody from CaseComment where ParentId=:case1.Id order by CreatedDate desc limit 1];

		system.debug('ALEX - theCaseComment.CommentBody = #' + theCaseComment.CommentBody + '#');
        system.assertEquals('The SCP case status has been updated to Open', theCaseComment.CommentBody.trim());
        
        /////////////////////////
        // Positive test case #2
        
        delete theCaseComment;
        
        Case emailToCase2 = new Case();
        emailToCase2.Subject = 'SCP Incident No: ##' + kaleCaseNumber + '## raised by you was updated - SF No. ' + sfCaseNumber;
        emailToCase2.SuppliedEmail = KALE_SUPPORT_EMAIL;
        emailToCase2.Description = 'Dear SIS Customer Support,\nSCP Incident no 4242 is updated.\nSF Case No : 02023138\nSubject : Excel SIS usage report is missing headers\nSCP Incident No : 4242\nReceived Date : 30-Nov-2011 04:53\nStatus : In Progress\nDescription : Hi ,';
        
        // udate case comment with the new status
        EscalatedCaseHelper.updateCaseWithKaleSCPStatus(emailToCase2);
        
        // get case comment
        CaseComment theCaseComment2 = [Select Id, ParentId, CommentBody from CaseComment where ParentId=:case1.Id order by CreatedDate desc limit 1];

        system.assertEquals('The SCP case status has been updated to In Progress', theCaseComment2.CommentBody);
        
        /////////////////////////
        // Negative test case #1
        
        Case emailToCaseFAIL = new Case();
        emailToCaseFAIL.Subject = 'SCP Incident No: ##' + kaleCaseNumber + '## raised by you was updated - SF No. ' + sfCaseNumber;
        emailToCaseFAIL.SuppliedEmail = KALE_SUPPORT_EMAIL;
        emailToCaseFAIL.Description = '';
        
        try {
            // update External Reference Number (supposed to FAIL)
            EscalatedCaseHelper.updateCaseWithKaleComment(emailToCaseFAIL);
            
            // if here, test failed (supposed to throw exception)
            system.assert(false);
        }
        catch (Exception ex) {
            // if here, test succeeded
            system.assert(true);
        }
    }
    
    /**
     * Test the trigger trgCheckBusinessHoursBeforeInsert 
     */
    static testMethod void testTriggerCheckBusinessHoursBeforeInsert() {
        
        // create test account
        Account testAccount = new Account();
        testAccount.Name = 'Test account';
        testAccount.BillingCity = 'Montreal';
        testAccount.BillingCountry = 'Canada';
        testAccount.BillingStreet = 'some street';
        insert testAccount;
        
        // create test contact
        Contact testContact = new Contact();
        testContact.FirstName = 'Dummy';
        testContact.LastName = 'Contact';
        testContact.Type_of_Contact__c = 'SIS User';
        testContact.AccountId = testAccount.Id;
        testContact.Email = 'some@email.org';
        insert testContact;
        
        Account acc = new Account(Name = 'TestSISAccount',BillingCity='Montreal', BillingCountry='Canada');
        insert acc;
        Contact con = new Contact(FirstName = 'Name', LastName='TestSISContact', AccountId=acc.Id, email='testuser@iata.org');
        insert con;
        
        Account suppAcc = new Account(Name = 'TestSupportAccount',BillingCity='Montreal', BillingCountry='Canada');
        insert suppAcc;
        
        Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_SIS_Help_Desk');
        
        Case case1 = new Case ();
        case1.Subject = 'Test 1';
        case1.Origin = 'Web';
        case1.Status = 'Open';
        case1.Type = 'General Question';
        case1.ContactId = testContact.Id;   
        case1.CaseArea__c = 'SIS';
        case1.Status = 'Escalated';
        case1.SuppliedEmail = 'some@email.com';
        case1.assigned_to__c = testAccount.Name; //'SIS Help Desk Agent';
        //case1.L2_L3_Support_Owner__c = testContact.Id;
        
        //insert case1;
        
        //system.assertEquals(case1.L2_Support_Team_Account__c, clsCheckBusinessHours.getSupportAccountID(case1.Assigned_To__c));
        //system.assertEquals(case1.L2_L3_Support_Owner__c, clsCheckBusinessHours.getSupportOwnerID(case1.L2_Support_Team_Account__c));
        
        Case testCase8 = new Case();
        
        Datetime caseDate = Datetime.now();     
        testCase8.ContactId = con.Id;
        testCase8.Description = 'Case Type: Bug\\n'+'Case Classification: User Access Issue\\n'+'Case Defect/Issue: Users unable to log on to SIS Solution';
        testCase8.Subject = 'Test SIS Help Desk Business Hours3';
        Blob descrip2 = Blob.valueOf(testCase8.Description);
        testCase8.Defect_Issue__c = clsCheckBusinessHours.getWebFieldValue('Defect/Issue', 'Browser type', descrip2);
        testCase8.Type = clsCheckBusinessHours.getWebFieldValue('Case Type', 'Case Classification', descrip2);
        testCase8.classification_SIS__c = clsCheckBusinessHours.getWebFieldValue('Case Classification', 'Case Defect/Issue', descrip2);
        //testCase8.Priority = clsCheckBusinessHours.getCasePriority(testCase8);
        testCase8.Status = 'Open';          
        //insert testCase8;
        
        
        Case testCase9 = new Case();

        testCase9.ContactId = con.Id;
        testCase9.Description = 'Case Type: Problem / Issue\\n'+'Case Classification: Digital Signature Issue\\n'+'Case Defect/Issue: Invoices can not be Digitally Signed';
        testCase9.Subject = 'Test SIS Help Desk Business Hours3';
        Blob descrip3 = Blob.valueOf(testCase9.Description);
        testCase9.Defect_Issue__c = clsCheckBusinessHours.getWebFieldValue('Defect/Issue', 'Browser type', descrip3);
        testCase9.Type = clsCheckBusinessHours.getWebFieldValue('Case Type', 'Case Classification', descrip3);
        testCase9.classification_SIS__c = clsCheckBusinessHours.getWebFieldValue('Case Classification', 'Case Defect/Issue', descrip3);
        //testCase9.Priority = clsCheckBusinessHours.getCasePriority(testCase9.Defect_Issue__c);
        testCase9.Status = 'Open';          
       // insert testCase9;
        
        
        Case testCase10 = new Case();

        //testCase10.ContactId = con.Id;
        testCase10.SuppliedEmail = KALE_SUPPORT_EMAIL;
        testCase10.Origin = 'E-mail to Case - SIS Help Desk';
        testCase10.Description = 'Case Type: Bug\\n'+'Case Classification: Application Error\\n'+'Case Defect/Issue: Functionality not working as expected';
        testCase10.Subject = 'Out Of Office';
        testCase10.RecordTypeId = recTypeId;
        testCase10.Status = 'Open';             
        //insert testCase10;
        
        
        Case testCase11 = new Case();

        testCase11.ContactId = con.Id;
        testCase11.Non_Business_Hours_Case_Creation__c = true;
        testCase11.Description = 'Case Type: Bug\\n'+'Case Classification: Billing Data Issue\\n'+'Case Defect/Issue: Submission of billing data not possible';
        testCase11.Subject = 'Test SIS Help Desk Business Hours3';
        Blob descrip5 = Blob.valueOf(testCase11.Description);
        testCase11.Defect_Issue__c = clsCheckBusinessHours.getWebFieldValue('Defect/Issue', 'Browser type', descrip5);
        testCase11.Type = clsCheckBusinessHours.getWebFieldValue('Case Type', 'Case Classification', descrip5);
        testCase11.classification_SIS__c = clsCheckBusinessHours.getWebFieldValue('Case Classification', 'Case Defect/Issue', descrip5);
        //testCase11.Priority = clsCheckBusinessHours.getCasePriority(testCase11.Defect_Issue__c);
        testCase11.Status = 'Open';             
        //insert testCase11;
        
        
        Case testCase12 = new Case();

        testCase12.ContactId = con.Id;
        testCase12.Description = 'Case Type: Problem / Issue\\n'+'Case Classification: Reporting Issue\\n'+'Case Defect/Issue: Reports cannot be viewed / downloaded';
        testCase12.Subject = 'Test SIS Help Desk Business Hours3';
        Blob descrip6 = Blob.valueOf(testCase12.Description);
        testCase12.Defect_Issue__c = clsCheckBusinessHours.getWebFieldValue('Defect/Issue', 'Browser type', descrip6);
        testCase12.Type = clsCheckBusinessHours.getWebFieldValue('Case Type', 'Case Classification', descrip6);
        testCase12.classification_SIS__c = clsCheckBusinessHours.getWebFieldValue('Case Classification', 'Case Defect/Issue', descrip6);
        //testCase12.Priority = clsCheckBusinessHours.getCasePriority(testCase12.Defect_Issue__c);
        testCase12.Non_Business_Hours_Case_Creation__c = true;
        //String accId =clsCheckBusinessHours.getSupportAccountID('Kale Application Support');                    
        //testCase12.L2_Support_Team_Account__c = accId;
        //testCase12.L2_L3_Support_Owner__c =  clsCheckBusinessHours.getSupportOwnerID(accId);          
        //insert testCase12;
        
        
        Case testCase13 = new Case();

        testCase13.ContactId = con.Id;
        testCase13.Description = 'Case Type: Bug\\n'+'Case Classification: Billing Data Issue\\n'+'Case Defect/Issue: Submission of billing data not possible';
        testCase13.Subject = 'Test SIS Help Desk Business Hours3';
        Blob descrip7 = Blob.valueOf(testCase13.Description);
        testCase13.Defect_Issue__c = clsCheckBusinessHours.getWebFieldValue('Defect/Issue', 'Browser type', descrip7);
        testCase13.Type = clsCheckBusinessHours.getWebFieldValue('Case Type', 'Case Classification', descrip7);
        testCase13.classification_SIS__c = clsCheckBusinessHours.getWebFieldValue('Case Classification', 'Case Defect/Issue', descrip7);
        //testCase13.Priority = clsCheckBusinessHours.getCasePriority(testCase13.Defect_Issue__c);                            
       // insert testCase13;
        
        
        Case testCase14 = new Case();       

        testCase14.ContactId = con.Id;
        testCase14.Description = 'Case Type: Problem / Issue\\n'+'Case Classification: Migration Issue\\n'+'Case Defect/Issue: Unable to send migrated transaction types\\n'+'Browser Type: Opera';
        testCase14.Subject = 'Test SIS Help Desk Business Hours3';
        Blob descrip8 = Blob.valueOf(testCase11.Description);
        testCase14.Defect_Issue__c = clsCheckBusinessHours.getWebFieldValue('Defect/Issue', 'Browser type', descrip8);
        testCase14.Type = clsCheckBusinessHours.getWebFieldValue('Case Type', 'Case Classification', descrip8);
        testCase14.classification_SIS__c = clsCheckBusinessHours.getWebFieldValue('Case Classification', 'Case Defect/Issue', descrip8);
        //testCase14.Priority = clsCheckBusinessHours.getCasePriority(testCase14.Defect_Issue__c);            
       insert testCase14;    
            
        
        Case testCase15 = new Case();
                
        testCase15.ContactId = con.Id;
        testCase15.Description = 'Case Area: SIS\\n'+'Case Type: Bug\\n'+'Case Classification: Output File Issue\\n'+'Case Defect/Issue: Output billing files cannot be created or are incorrect or do not arrive at their destination within SIS';
        Blob descrip9 = Blob.valueOf(testCase15.Description);
        testCase15.Subject = 'Test SIS Help Desk Business Hours3';
        testCase14.Defect_Issue__c = clsCheckBusinessHours.getWebFieldValue('Defect/Issue', 'Browser type', descrip9);
        testCase15.Type = clsCheckBusinessHours.getWebFieldValue('Case Type', 'Case Classification', descrip9);
        testCase15.classification_SIS__c = clsCheckBusinessHours.getWebFieldValue('Case Classification', 'Case Defect/Issue', descrip9);
        //testCase15.Priority = clsCheckBusinessHours.getCasePriority(testCase15.Defect_Issue__c);
        testCase15.Status = 'Open';
       insert testCase15;
        
        
        Case testCase16 = new Case();
                        
        testCase16.ContactId = con.Id;
        testCase16.Description = 'Case Type: Bug\\n'+'Case Classification: Processing Time Issue\\n'+'Case Defect/Issue: Response times for files submitted are greater than expected';
        Blob descrip10 = Blob.valueOf(testCase16.Description);
        testCase16.Subject = 'Test SIS Help Desk Business Hours3';
        testCase16.Defect_Issue__c = clsCheckBusinessHours.getWebFieldValue('Defect/Issue', 'Browser type', descrip10);
        testCase16.Type = clsCheckBusinessHours.getWebFieldValue('Case Type', 'Case Classification', descrip10);
        testCase16.classification_SIS__c = clsCheckBusinessHours.getWebFieldValue('Case Classification', 'Case Defect/Issue', descrip10);
        //testCase16.Priority = clsCheckBusinessHours.getCasePriority(testCase16.Defect_Issue__c);
        testCase16.Status = 'Open';         
        testCase16.Non_Business_Hours_Case_Creation__c = clsCheckBusinessHours.checkBusinessHoursMethod(testCase16);
      //  insert testCase16;
        
        
        Case testCase17 = new Case();
        testCase17.CaseArea__c = 'SIS';     
        testCase17.ContactId = con.Id;
        testCase17.Type = 'Bug';
        testCase17.classification_SIS__c = 'Application Error';
        testCase17.Defect_Issue__c = 'SIS Solution is not working';
        testCase17.Description = null;
        testCase17.Non_Business_Hours_Case_Creation__c = true;
        testCase17.Subject = 'Test SIS Help Desk Business Hours17';
        //testCase17.Status = 'Open';
        //testCase17.L2_Support_Team_Account__c = clsCheckBusinessHours.getSupportAccountID('Kale Application Support');                    
        //testCase17.L2_L3_Support_Owner__c =  clsCheckBusinessHours.getSupportOwnerID(testCase17.L2_Support_Team_Account__c);
        //insert testCase17;
        
        
        Case testCase18 = new Case();

        testCase18.ContactId = con.Id;
        testCase18.Description = 'Case Type: General Question\\n'+'Case Classification: System Related\\n'+'Case Defect/Issue: System Related Question';
        testCase18.Subject = 'Test SIS Help Desk Business Hours3';
        Blob descrip11 = Blob.valueOf(testCase18.Description);
        testCase18.Defect_Issue__c = clsCheckBusinessHours.getWebFieldValue('Defect/Issue', 'Browser type', descrip11);
        testCase18.Type = clsCheckBusinessHours.getWebFieldValue('Case Type', 'Case Classification', descrip11);
        testCase18.classification_SIS__c = clsCheckBusinessHours.getWebFieldValue('Case Classification', 'Case Defect/Issue', descrip11);
        //testCase18.Priority = clsCheckBusinessHours.getCasePriority(testCase18.Defect_Issue__c);                    
       // insert testCase18;
        
        
        Case testCase19 = new Case();
        
        testCase19.ContactId = con.Id;
        testCase19.Description = 'Case Type: Bug\\n'+'Case Classification: Sandbox Issue\\n'+'Case Defect/Issue: Sandbox Issue';
        testCase19.Subject = 'Test SIS Help Desk Business Hours3';
        Blob descrip12 = Blob.valueOf(testCase19.Description);
        testCase19.Defect_Issue__c = clsCheckBusinessHours.getWebFieldValue('Defect/Issue', 'Browser type', descrip12);
        testCase19.Type = clsCheckBusinessHours.getWebFieldValue('Case Type', 'Case Classification', descrip12);
        testCase19.classification_SIS__c = clsCheckBusinessHours.getWebFieldValue('Case Classification', 'Case Defect/Issue', descrip12);
        //testCase19.Priority = clsCheckBusinessHours.getCasePriority(testCase19.Defect_Issue__c);                    
       // insert testCase19;
        
    
        
    }
}