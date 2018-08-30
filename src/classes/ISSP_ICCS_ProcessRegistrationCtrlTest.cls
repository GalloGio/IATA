@isTest(SeeAllData=true)
public class ISSP_ICCS_ProcessRegistrationCtrlTest {

    private static User createPartnerUser(String serviceStatus){
    	// Create ICCS portal application if it doesn't exist
    	if(ISSP_ICCS_Utils.getIccsPortalApplication() == null){
			insert new Portal_Applications__c(Name = 'ICCS');
    	}
    	
    	// Create missing ICCS Notification Templates
		List<Notification_Template__c> missingNotificationTemplates = new List<Notification_Template__c>();
		for(String templateIdentifier : ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.keySet()){
			if(ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.get(templateIdentifier) == null){
				missingNotificationTemplates.add(new Notification_Template__c(
					Identifier__c = templateIdentifier,
					Expire_in_days__c = 2
				));
			}
		}
		
		if(!missingNotificationTemplates.isEmpty()){			
			insert missingNotificationTemplates;
			for(Notification_Template__c template : [select Name, Identifier__c from Notification_Template__c where Identifier__c in : ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.keySet()]){
				ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.put(template.Identifier__c, template.Name);
			}
		}

		// Create missing ICCS roles
		Map<String, Connected_App_Roles__c> existingRoles = Connected_App_Roles__c.getAll();
		
		Set<String> requiredRoles = new Set<String>{ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY, ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1, ISSP_ICCS_Utils.ICCS_ROLE_READ_ONLY, ISSP_ICCS_Utils.ICCS_ROLE_REGISTRATION};
		
        Connected_App_Roles__c signatory = new Connected_App_Roles__c(Name = ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY, Description__c = 'ICCS Service', Role__c = ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY);

		List<Connected_App_Roles__c> newRoles = new List<Connected_App_Roles__c>();

		for(String requiredRole : requiredRoles){
			if(! existingRoles.keySet().contains(requiredRole)){
				newRoles.add(new Connected_App_Roles__c(Name = requiredRole, Description__c = 'ICCS Service', Role__c = requiredRole));
			}
		}
        insert newRoles;

        Profile p = [Select ID, Name from Profile Where Name = 'ISS Portal (Partner)'];

        Map<String,Schema.RecordtypeInfo> aRtMap = Account.sObjectType.getDescribe().getRecordtypeinfosbyname();

        Account a = New Account(
            Recordtypeid = aRTMap.get('Airline Headquarters').getRecordtypeid(), 
            Name = 'TestPortalAccount',
			Airline_designator__c = 'LX',
			IATACode__c = '724',
            ICCS_Membership_Status__c = serviceStatus);
        
        insert a;

        List<Folder> folders = [select Id from Folder where DeveloperName = 'ICCS_Portal_Service'];
        
        Document doc = new Document(
            Name = 'test ICCS document',
            Body = Blob.valueOf('test'),
            FolderId = folders[0].id,
            IsPublic = true
        );
        
        insert doc;

        Contact c = New Contact(
            FirstName = 'Portal', 
            LastName = 'Test', 
            Email = 'test@test.tes',
            AccountID = a.id);
        
        insert c;

        user u = New User(
            UserName = 'test_' + math.random() + '@test.com',
            FirstName = 'Test-First',
            LastName = 'Test-Last',
            Alias = 'test',
            email = 'test' + math.random() + '@test.com',
            CommunityNickName = string.valueOf(math.random()).substring(0,6),
            ProfileID = p.id,
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            ContactID = c.id

            );
        
        insert u;
        
        return u;
    }
    
    static testMethod void testRegistrationProcessDiscard(){
        User partnerUser = createPartnerUser('');

        Test.startTest();

		// Create page controller
        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

		// Set the necessary Component controllers
        ISSP_ICCS_HomepageController homepageController = new ISSP_ICCS_HomepageController();
		homepageController.pageController = pageController;
		
		pageController.previousComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CASES;
        ISSP_ICCS_CasesController casesController = new ISSP_ICCS_CasesController();
		casesController.pageController = pageController;

		pageController.previousComponent = ISSP_ICCS_Utils.Page.CASES;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CASE_PROCESSES;
        ISSP_ICCS_CaseProcessesController caseProcessesController = new ISSP_ICCS_CaseProcessesController();
		caseProcessesController.pageController = pageController;

		// Set the necessary Case Process controllers
		pageController.currentCaseProcessType = ISSP_ICCS_Utils.CaseProcessType.REGISTRATION;
		ISSP_ICCS_ProcessRegistrationController registrationController = new ISSP_ICCS_ProcessRegistrationController();
        registrationController.caseProcessesController = caseProcessesController;

		// Set the File upload controller
        ISSP_ICCS_FileUploadController uploadController = new ISSP_ICCS_FileUploadController();
        uploadController.caseProcessesController = caseProcessesController;

		// Back to the Homepage
		pageController.currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentCaseProcessType = null;
		
		// Register to ICCS
        homepageController.registerToICCS();

        caseProcessesController.saveAndLeave();
		caseProcessesController.saveAttachmentsToAmazon();
        caseProcessesController.closePage();

		homepageController.discardRegistrationCase();    
    }
    

    static testMethod void testRegistrationProcess() {

        System.assertEquals(0, Limits.getDMLStatements());

        User partnerUser = createPartnerUser('');

		// Create page controller
        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

		// Set the necessary Component controllers
        ISSP_ICCS_HomepageController homepageController = new ISSP_ICCS_HomepageController();
		homepageController.pageController = pageController;
		
		pageController.previousComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CASES;
        ISSP_ICCS_CasesController casesController = new ISSP_ICCS_CasesController();
		casesController.pageController = pageController;

		pageController.previousComponent = ISSP_ICCS_Utils.Page.CASES;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CASE_PROCESSES;
        ISSP_ICCS_CaseProcessesController caseProcessesController = new ISSP_ICCS_CaseProcessesController();
		caseProcessesController.pageController = pageController;

		// Set the necessary Case Process controllers
		pageController.currentCaseProcessType = ISSP_ICCS_Utils.CaseProcessType.REGISTRATION;
		ISSP_ICCS_ProcessRegistrationController registrationController = new ISSP_ICCS_ProcessRegistrationController();
        registrationController.caseProcessesController = caseProcessesController;

		// Set the necessary Typed Document controllers
        ISSP_ICCS_TypedDocumentController formA = new ISSP_ICCS_TypedDocumentController();
		formA.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_FORM_A;
		formA.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController formK = new ISSP_ICCS_TypedDocumentController();
		formK.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_FORM_K;
		formK.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController participations = new ISSP_ICCS_TypedDocumentController();
		participations.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_JOIN_PARTICIPATION;
		participations.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController bankAccounts = new ISSP_ICCS_TypedDocumentController();
		bankAccounts.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS;
		bankAccounts.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController asp = new ISSP_ICCS_TypedDocumentController();
		asp.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_ASP;
		asp.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController aml = new ISSP_ICCS_TypedDocumentController();
		aml.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_AML;
		aml.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController contract = new ISSP_ICCS_TypedDocumentController();
		contract.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_MEMBERSHIP;
		contract.caseProcessController = registrationController;

		// Set the File upload controller
        ISSP_ICCS_FileUploadController uploadController = new ISSP_ICCS_FileUploadController();
        uploadController.caseProcessesController = caseProcessesController;

		// Back to the Homepage
		pageController.currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentCaseProcessType = null;

        Test.startTest();

		// Register to ICCS
        homepageController.registerToICCS();

        System.assertEquals(caseProcessesController.currentStep, 1);

        caseProcessesController.next();

        System.assertEquals(caseProcessesController.currentStep, 2);

        caseProcessesController.previous();
        caseProcessesController.next();
        caseProcessesController.next();

        System.assertEquals(caseProcessesController.currentStep, 3);

        System.assert(!caseProcessesController.showFileUploadComponent);

        // upload Form K file
		formK.showFileUploadComponent();
        uploadController.filename = 'Form K 1';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();

        // upload Bank Accounts file
        bankAccounts.showFileUploadComponent();
        uploadController.filename = 'Bank Accounts 1';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();
        
        // Try to submit and check that submit fails because expected date is missing
        caseProcessesController.submit();

        System.assert(!registrationController.validateStep());

        caseProcessesController.saveAndLeave();
		caseProcessesController.saveAttachmentsToAmazon();
        caseProcessesController.closePage();

		// Navigate to Cases
        pageController.navigateToCases();

		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CASES);

		// Retrieve case Id
		casesController.userCasesOnly = true;
		
		Case cse = casesController.cases[0];

        // Open Draft Case
        casesController.pageController.caseIdParameter = cse.Id;
		casesController.pageController.navigateToCase();
       
		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CASE_PROCESSES);
		System.assertEquals(pageController.currentCaseProcessType, ISSP_ICCS_Utils.CaseProcessType.REGISTRATION);

        System.assertEquals(caseProcessesController.currentStep, 1);

        caseProcessesController.next();
        caseProcessesController.next();
 
        caseProcessesController.cse.Expected_Deadline__c = Date.today();

        Boolean isPanelDisplayed = uploadController.isPanelDisplayed;
        uploadController.displayPanel();        
        uploadController.cancel();
        uploadController.displayPanel();
        
		formK.showFileUploadComponent();
		uploadController.cancel();

        // This upload should not work because we have a file with the same name already stored
		formK.showFileUploadComponent();
        uploadController.filename = 'Form K 1';
        uploadController.filebody = Blob.valueOf('test');
        uploadController.upload();

		uploadController.cancel();

        asp.showFileUploadComponent();
        uploadController.filename = 'test';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();

        // replace the Form K file
		formK.showFileUploadComponent();
        uploadController.filename = 'Form K 2';
        uploadController.filebody = Blob.valueOf('test');
        uploadController.upload();

        // cancel the replacement
        formK.typedDocument.cancelReplacement();
        
        // replace it again
		formK.showFileUploadComponent();
        uploadController.filename = 'Form K 2';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();

		// try to upload a document with the same name than a document about to be uploaded, it should fail
        bankAccounts.showFileUploadComponent();
        uploadController.filename = 'Form K 2';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();
		uploadController.cancel();
        
        // delete the Bank Accounts file
        bankAccounts.typedDocument.deleteDocument();

        // upload ASP file
		asp.showFileUploadComponent();
        uploadController.filename = 'ASP 1';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();

        // Upload AML file
		aml.showFileUploadComponent();
        uploadController.filename = 'AML 1';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();

        // Upload Contract file
		contract.showFileUploadComponent();
        uploadController.filename = 'Contract 1';
        uploadController.filebody = Blob.valueOf('test');
        uploadController.upload();

        // Upload a fourth file
		formA.showFileUploadComponent();
        uploadController.filename = 'Form A 1';
        uploadController.filebody = Blob.valueOf('test');
        uploadController.upload();

        // delete the fourth file
		formA.typedDocument.deleteDocument();

		// Check that the submit fails (missing files)
        caseProcessesController.submit();

		// Upload the missing files
		formA.showFileUploadComponent();
        uploadController.filename = 'Form A 1';
        uploadController.filebody = Blob.valueOf('test');
        uploadController.upload();
		
		bankAccounts.showFileUploadComponent();
        uploadController.filename = 'Bank Accounts 2';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();

		// Check that the submit is successfull
        caseProcessesController.submit();
		caseProcessesController.saveAttachmentsToAmazon();
        caseProcessesController.closePage();

		System.assert(caseProcessesController.cse.Status != 'Draft');

		// Navigate to Cases
        pageController.navigateToCases();

		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CASES);

		// Retrieve case Id
		casesController.userCasesOnly = true;
		
		cse = casesController.cases[0];

        // Open Draft Case
        casesController.pageController.caseIdParameter = cse.Id;
		casesController.pageController.navigateToCase();
       
		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CASE_PROCESSES);
		System.assertEquals(pageController.currentCaseProcessType, ISSP_ICCS_Utils.CaseProcessType.REGISTRATION);

        // replace the Form K file
		formK.showFileUploadComponent();
        uploadController.filename = 'Form K 3';
        uploadController.filebody = Blob.valueOf('test');
        uploadController.upload();

        caseProcessesController.submit();
		caseProcessesController.saveAttachmentsToAmazon();
        caseProcessesController.closePage();

		// Navigate to Cases
        pageController.navigateToCases();

		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CASES);

		// Retrieve case Id
		casesController.userCasesOnly = true;
		
		cse = casesController.cases[0];

        // Open Draft Case
        casesController.pageController.caseIdParameter = cse.Id;
		casesController.pageController.navigateToCase();
       
		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CASE_PROCESSES);
		System.assertEquals(pageController.currentCaseProcessType, ISSP_ICCS_Utils.CaseProcessType.REGISTRATION);

		// retrieve the Amazon files table
		List<ISSP_ICCS_CaseProcessesController.AmazonFileRow> flattenedAmazonFileTable = caseProcessesController.flattenedAmazonFileTable;

		// expand the table
		for(ISSP_ICCS_CaseProcessesController.AmazonFileRow amazonFileRow : flattenedAmazonFileTable){
			if(amazonFileRow != null && amazonFileRow.isExpandable){
				amazonFileRow.isExpanded = true;
				String name = amazonFileRow.name;
				String fullUniqueName = amazonFileRow.fullUniqueName;
				String status = amazonFileRow.status;
				Boolean originalReceived = amazonFileRow.originalReceived;
				String comments = amazonFileRow.comments;
				DateTime createdDate = amazonFileRow.createdDate;
			}
		}
		// retrieve the table again
		flattenedAmazonFileTable = caseProcessesController.flattenedAmazonFileTable;

        // add a comment
        caseProcessesController.showAddComment();
        caseProcessesController.hideAddComment();
        caseProcessesController.showAddComment();
        caseProcessesController.portalUserComment.CommentBody = 'New comment';        
        
        // delete the third file
        contract.typedDocument.deleteDocument();

        // undelete the third file
        contract.typedDocument.cancelDeletion();

        // and delete it again
        contract.typedDocument.deleteDocument();

        // upload new version of the first file
		asp.showFileUploadComponent();
        uploadController.filename = 'ASP 2';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();

        // upload new version of the second file
		aml.showFileUploadComponent();
        uploadController.filename = 'AML 2';
        uploadController.filebody = Blob.valueOf('test');
        uploadController.upload();

        // cancel the replacement of the second file
        aml.typedDocument.cancelReplacement();

        Test.stopTest();
    }
    
/*    static testmethod void testStraightRegistrationProcess(){
        System.assertEquals(0, Limits.getDMLStatements());

        User partnerUser = createPartnerUser('');

		// Create page controller
        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

		// Set the necessary Component controllers
        ISSP_ICCS_HomepageController homepageController = new ISSP_ICCS_HomepageController();
		homepageController.pageController = pageController;
		
		pageController.previousComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CASES;
        ISSP_ICCS_CasesController casesController = new ISSP_ICCS_CasesController();
		casesController.pageController = pageController;

		pageController.previousComponent = ISSP_ICCS_Utils.Page.CASES;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CASE_PROCESSES;
        ISSP_ICCS_CaseProcessesController caseProcessesController = new ISSP_ICCS_CaseProcessesController();
		caseProcessesController.pageController = pageController;

		// Set the necessary Case Process controllers
		pageController.currentCaseProcessType = ISSP_ICCS_Utils.CaseProcessType.REGISTRATION;
		ISSP_ICCS_ProcessRegistrationController registrationController = new ISSP_ICCS_ProcessRegistrationController();
        registrationController.caseProcessesController = caseProcessesController;

		// Set the necessary Typed Document controllers
        ISSP_ICCS_TypedDocumentController formA = new ISSP_ICCS_TypedDocumentController();
		formA.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_FORM_A;
		formA.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController formK = new ISSP_ICCS_TypedDocumentController();
		formK.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_FORM_K;
		formK.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController participations = new ISSP_ICCS_TypedDocumentController();
		participations.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_JOIN_PARTICIPATION;
		participations.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController bankAccounts = new ISSP_ICCS_TypedDocumentController();
		bankAccounts.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS;
		bankAccounts.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController asp = new ISSP_ICCS_TypedDocumentController();
		asp.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_ASP;
		asp.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController aml = new ISSP_ICCS_TypedDocumentController();
		aml.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_AML;
		aml.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController contract = new ISSP_ICCS_TypedDocumentController();
		contract.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_MEMBERSHIP;
		contract.caseProcessController = registrationController;

		// Set the File upload controller
        ISSP_ICCS_FileUploadController uploadController = new ISSP_ICCS_FileUploadController();
        uploadController.caseProcessesController = caseProcessesController;

		// Back to the Homepage
		pageController.currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentCaseProcessType = null;

        Test.startTest();

		// Register to ICCS
        homepageController.registerToICCS();

        System.assertEquals(caseProcessesController.currentStep, 1);

        caseProcessesController.next();

        System.assertEquals(caseProcessesController.currentStep, 2);

        caseProcessesController.next();

        System.assertEquals(caseProcessesController.currentStep, 3);

        System.assert(!caseProcessesController.showFileUploadComponent);

        caseProcessesController.cse.Expected_Deadline__c = Date.today();

        // upload Form K file
		formK.showFileUploadComponent();
        uploadController.filename = 'Form K 1';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();

        // upload Bank Accounts file
        bankAccounts.showFileUploadComponent();
        uploadController.filename = 'Bank Accounts 1';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();

        // upload ASP file
        asp.showFileUploadComponent();
        uploadController.filename = 'test';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();

        // Upload AML file
		aml.showFileUploadComponent();
        uploadController.filename = 'AML 1';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();

        // Upload Contract file
		contract.showFileUploadComponent();
        uploadController.filename = 'Contract 1';
        uploadController.filebody = Blob.valueOf('test');
        uploadController.upload();

        // Upload Form A file
		formA.showFileUploadComponent();
        uploadController.filename = 'Form A 1';
        uploadController.filebody = Blob.valueOf('test');
        uploadController.upload();

		// Check that the submit is successfull
        caseProcessesController.submit();
		caseProcessesController.saveAttachmentsToAmazon();
        caseProcessesController.closePage();

		// Navigate to Cases
        pageController.navigateToCases();

		// Retrieve case Id
		casesController.userCasesOnly = true;
		
		Case cse = casesController.cases[0];

        // Open Draft Case
        casesController.pageController.caseIdParameter = cse.Id;
		casesController.pageController.navigateToCase();
       
		// retrieve the Amazon files table
		List<ISSP_ICCS_CaseProcessesController.AmazonFileRow> flattenedAmazonFileTable = caseProcessesController.flattenedAmazonFileTable;

		// expand the table
		for(ISSP_ICCS_CaseProcessesController.AmazonFileRow amazonFileRow : flattenedAmazonFileTable){
			if(amazonFileRow != null && amazonFileRow.isExpandable){
				amazonFileRow.isExpanded = true;
				String name = amazonFileRow.name;
				String fullUniqueName = amazonFileRow.fullUniqueName;
				String status = amazonFileRow.status;
				Boolean originalReceived = amazonFileRow.originalReceived;
				String comments = amazonFileRow.comments;
				DateTime createdDate = amazonFileRow.createdDate;
			}
		}
		// retrieve the table again
		flattenedAmazonFileTable = caseProcessesController.flattenedAmazonFileTable;

        // add a comment
        caseProcessesController.showAddComment();
        caseProcessesController.hideAddComment();
        caseProcessesController.showAddComment();
        caseProcessesController.portalUserComment.CommentBody = 'New comment';        
        
        // delete the third file
        contract.typedDocument.deleteDocument();

        // undelete the third file
        contract.typedDocument.cancelDeletion();

        // and delete it again
        contract.typedDocument.deleteDocument();

        // upload new version of the first file
		asp.showFileUploadComponent();
        uploadController.filename = 'ASP 2';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();

        // upload new version of the second file
		aml.showFileUploadComponent();
        uploadController.filename = 'AML 2';
        uploadController.filebody = Blob.valueOf('test');
        uploadController.upload();

        // cancel the replacement of the second file
        aml.typedDocument.cancelReplacement();

        // submit the case
        caseProcessesController.submit();
		caseProcessesController.saveAttachmentsToAmazon();
        caseProcessesController.closePage();

        Test.stopTest();
    }*/
    
    
    static testMethod void testRegistrationProcess2() {
        User partnerUser = createPartnerUser('');

        Test.startTest();

		// Create page controller
        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

		// Set the necessary Component controllers
        ISSP_ICCS_HomepageController homepageController = new ISSP_ICCS_HomepageController();
		homepageController.pageController = pageController;
		
		pageController.previousComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CASES;
        ISSP_ICCS_CasesController casesController = new ISSP_ICCS_CasesController();
		casesController.pageController = pageController;

		pageController.previousComponent = ISSP_ICCS_Utils.Page.CASES;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CASE_PROCESSES;
        ISSP_ICCS_CaseProcessesController caseProcessesController = new ISSP_ICCS_CaseProcessesController();
		caseProcessesController.pageController = pageController;

		// Set the necessary Case Process controllers
		pageController.currentCaseProcessType = ISSP_ICCS_Utils.CaseProcessType.REGISTRATION;
		ISSP_ICCS_ProcessRegistrationController registrationController = new ISSP_ICCS_ProcessRegistrationController();
        registrationController.caseProcessesController = caseProcessesController;

		// Set the necessary Typed Document controllers
        ISSP_ICCS_TypedDocumentController formA = new ISSP_ICCS_TypedDocumentController();
		formA.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_FORM_A;
		formA.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController formK = new ISSP_ICCS_TypedDocumentController();
		formK.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_FORM_K;
		formK.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController participations = new ISSP_ICCS_TypedDocumentController();
		participations.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_JOIN_PARTICIPATION;
		participations.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController bankAccounts = new ISSP_ICCS_TypedDocumentController();
		bankAccounts.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS;
		bankAccounts.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController asp = new ISSP_ICCS_TypedDocumentController();
		asp.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_ASP;
		asp.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController aml = new ISSP_ICCS_TypedDocumentController();
		aml.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_AML;
		aml.caseProcessController = registrationController;

        ISSP_ICCS_TypedDocumentController contract = new ISSP_ICCS_TypedDocumentController();
		contract.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_MEMBERSHIP;
		contract.caseProcessController = registrationController;

		// Set the File upload controller
        ISSP_ICCS_FileUploadController uploadController = new ISSP_ICCS_FileUploadController();
        uploadController.caseProcessesController = caseProcessesController;

		// Back to the Homepage
		pageController.currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentCaseProcessType = null;

		
		// Register to ICCS
        homepageController.registerToICCS();

        caseProcessesController.next();        
        caseProcessesController.next();

        // upload AML
		aml.showFileUploadComponent();
        uploadController.filename = 'AML 1';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();
        
        // upload Form A
		formA.showFileUploadComponent();
		uploadController.filename = 'Form A 1';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();
        
        // upload Form K
		formK.showFileUploadComponent();
        uploadController.filename = 'Form K 1';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();
        
        // upload Contract
		contract.showFileUploadComponent();
        uploadController.filename = 'Contract 1';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();
        
        // upload Bank Accounts
		bankAccounts.showFileUploadComponent();
        uploadController.filename = 'Bank Accounts 1';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();
        
        caseProcessesController.cse.Expected_Deadline__c = Date.today();
        
        System.assert(registrationController.validateStep());

		System.assert(caseProcessesController.cse != null);


        caseProcessesController.submit();

		System.assert(caseProcessesController.cse.Id != null);


		caseProcessesController.saveAttachmentsToAmazon();
        caseProcessesController.closePage();
        
		// Navigate to Cases
        pageController.navigateToCases();

		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CASES);

		// Retrieve case Id
		casesController.userCasesOnly = true;
		
		Case cse = casesController.cases[0];

        // CS Management of Registration Case
        
        // User management
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        
        ICCS_PortalUserAccessController userRightsController = new ICCS_PortalUserAccessController(sc);
        
        userRightsController.newUser();
        
        System.assert(userRightsController.contactsSize > 0);
        
        ICCS_PortalUserAccessController.PortalUserWrapper wrappedPortalUser = userRightsController.wrappedPortalUsers[0];

		String status = wrappedPortalUser.portalUserStatus;

        wrappedPortalUser.cancel();
        System.assert(userRightsController.wrappedPortalUsers.size() == 0);

        userRightsController.newUser();
        wrappedPortalUser = userRightsController.wrappedPortalUsers[0];
        
        
        
        wrappedPortalUser.usr.Contact__c = partnerUser.ContactID;
        wrappedPortalUser.usr.Right__c = ISSP_ICCS_Utils.ACCESS_GRANTED;
        wrappedPortalUser.usr.ANG_Portal_Service_Role__c = ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY;

        wrappedPortalUser.save();
        
        wrappedPortalUser.updateUser();
        wrappedPortalUser.cancel();
        
        wrappedPortalUser.updateUser();
        wrappedPortalUser.usr.Right__c = ISSP_ICCS_Utils.ACCESS_DENIED;
        wrappedPortalUser.save();

        userRightsController.newUser();
      
        
        List<SelectOption> ICCSPortalRoles = userRightsController.ICCSPortalRoles;
        
        // Activation /deactivation management
        
        ICCS_MembershipManagementController membershipManagementController = new ICCS_MembershipManagementController(sc);
        
        System.assert(membershipManagementController.canBeSetToActive);
        System.assert(!membershipManagementController.canBeSetToMember);
        System.assert(!membershipManagementController.canBeSetToInactive);
        
        membershipManagementController.setMembershipToActive();
        membershipManagementController.setMembershipToMember();

		List<SelectOption> selectableRoles = ISSP_ICCS_Utils.selectableRoles;

		
		ICCS_CaseAttachmentsController caseAttachmentsController = new ICCS_CaseAttachmentsController(sc);

		System.assert(caseAttachmentsController.wrappedAmazonFiles.size() > 0);
		
		ICCS_CaseAttachmentsController.AttachmentWrapper wrappedAmazonFile = caseAttachmentsController.wrappedAmazonFiles[0];
		
		wrappedAmazonFile.updateAttachment();
		wrappedAmazonFile.cancel();
		wrappedAmazonFile.updateAttachment();
		wrappedAmazonFile.att.Original_Received__c = true;
		wrappedAmazonFile.save();
		
		ICCS_CaseAttachmentsController.getExpiringLink('toto');
		
		Boolean b = pageController.isActivePortalUser &
					pageController.isMembershipSuspended &
					pageController.hasIccsRole &
					pageController.isRegistrationUser &
					pageController.displayHomepage;

        membershipManagementController.setMembershipToInactive();

        Test.stopTest();
    }
}