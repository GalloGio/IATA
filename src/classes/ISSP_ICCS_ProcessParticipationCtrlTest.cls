@isTest(SeeAllData=true)
public class ISSP_ICCS_ProcessParticipationCtrlTest {

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
    
    static testMethod void testJoinParticipation(){
        
        User partnerUser = createPartnerUser(ISSP_ICCS_Utils.ICCS_MEMBERSHIP_MEMBER);

        Test.startTest();

		// Create page controller
        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

		// Set the necessary Component controllers
        ISSP_ICCS_HomepageController homepageController = new ISSP_ICCS_HomepageController();
		homepageController.pageController = pageController;
		
		pageController.previousComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.SERVICE_MGMT;
        ISSP_ICCS_ServiceMgmtController serviceMgmtController = new ISSP_ICCS_ServiceMgmtController();
		serviceMgmtController.pageController = pageController;

		pageController.previousComponent = ISSP_ICCS_Utils.Page.SERVICE_MGMT;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CASES;
        ISSP_ICCS_CasesController casesController = new ISSP_ICCS_CasesController();
		casesController.pageController = pageController;

		pageController.previousComponent = ISSP_ICCS_Utils.Page.CASES;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CASE_PROCESSES;
        ISSP_ICCS_CaseProcessesController caseProcessesController = new ISSP_ICCS_CaseProcessesController();
		caseProcessesController.pageController = pageController;

		// Set the necessary Case Process controllers
		pageController.currentCaseProcessType = ISSP_ICCS_Utils.CaseProcessType.PART_NEW;
		ISSP_ICCS_ProcessPartNewController joinParticipationController = new ISSP_ICCS_ProcessPartNewController();
        joinParticipationController.caseProcessesController = caseProcessesController;

		// Set the necessary Typed Document controllers
        ISSP_ICCS_TypedDocumentController joinParticipation = new ISSP_ICCS_TypedDocumentController();
		joinParticipation.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_JOIN_PARTICIPATION;
		joinParticipation.caseProcessController = joinParticipationController;

		// Set the File upload controller
        ISSP_ICCS_FileUploadController uploadController = new ISSP_ICCS_FileUploadController();
        uploadController.caseProcessesController = caseProcessesController;

		// Back to the Homepage
		pageController.currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentCaseProcessType = null;


		// Navigate to Serice Management
        pageController.navigateToServiceMgmt();

		// Join participation
        serviceMgmtController.joinParticipation();
        
        List<SelectOption> productTypes = joinParticipationController.categoryFilter;
        List<SelectOption> countries = joinParticipationController.countryFilter;
        List<SelectOption> currencies = joinParticipationController.currencyFilter;

		// Check that we have more than one select option in each list		
        System.assert(productTypes.size() > 1);
        System.assert(countries.size() > 1);
        System.assert(currencies.size() > 1);
        
        // check that we can't pass the first step
        System.assertEquals(caseProcessesController.currentStep, 1);
        System.assert(joinParticipationController.selectedCategory == ISSP_ICCS_Utils.NONE);
        System.assert(joinParticipationController.selectedCountry == ISSP_ICCS_Utils.NONE);
        System.assert(joinParticipationController.selectedCurrency == ISSP_ICCS_Utils.NONE);

        caseProcessesController.next();

        System.assertEquals(caseProcessesController.currentStep, 1);

        joinParticipationController.selectedCategory = productTypes.get(1).getValue();
        joinParticipationController.selectedCountry = countries.get(1).getValue();
        joinParticipationController.selectedCurrency = currencies.get(1).getValue();

        caseProcessesController.next();

        System.assertEquals(caseProcessesController.currentStep, 2);

        // check that we can't pass the first step        
        caseProcessesController.next();

        System.assertEquals(caseProcessesController.currentStep, 2);
        
        caseProcessesController.cse.Expected_Deadline__c = Date.today();
        joinParticipationController.contactForm.Contact_Resp_Salutation__c = 'Mr';
        joinParticipationController.contactForm.Contact_Resp_Phone__c = '123';
        joinParticipationController.contactForm.Contact_Resp_Job_Title__c = 'A';
        joinParticipationController.contactForm.Contact_Resp_Email__c = 'b@c.def';
        
        caseProcessesController.next();

        System.assertEquals(caseProcessesController.currentStep, 3);
        
        // save draft case
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
		System.assertEquals(pageController.currentCaseProcessType, ISSP_ICCS_Utils.CaseProcessType.PART_NEW);

        caseProcessesController.next();
        caseProcessesController.next();

        // check that we can't pass the third step
        caseProcessesController.submit();

        System.assertEquals(caseProcessesController.currentStep, 3);
        
        joinParticipationController.contactForm.Accept_terms_and_conditions__c = true;
        
        joinParticipation.showFileUploadComponent();
        uploadController.filename = 'test';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();
        
        caseProcessesController.portalUserComment.CommentBody = 'New comment';        

        caseProcessesController.submit();
        caseProcessesController.saveAttachmentsToAmazon();
        caseProcessesController.closePage();
        
        Test.stopTest();
    }
    
    static testMethod void testLeaveParticipation(){
        
        User partnerUser = createPartnerUser(ISSP_ICCS_Utils.ICCS_MEMBERSHIP_MEMBER);

        Test.startTest();

		// Create page controller
        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

		// Set the necessary Component controllers
        ISSP_ICCS_HomepageController homepageController = new ISSP_ICCS_HomepageController();
		homepageController.pageController = pageController;
		
		pageController.previousComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.SERVICE_MGMT;
        ISSP_ICCS_ServiceMgmtController serviceMgmtController = new ISSP_ICCS_ServiceMgmtController();
		serviceMgmtController.pageController = pageController;

		pageController.previousComponent = ISSP_ICCS_Utils.Page.SERVICE_MGMT;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CASES;
        ISSP_ICCS_CasesController casesController = new ISSP_ICCS_CasesController();
		casesController.pageController = pageController;

		pageController.previousComponent = ISSP_ICCS_Utils.Page.CASES;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CASE_PROCESSES;
        ISSP_ICCS_CaseProcessesController caseProcessesController = new ISSP_ICCS_CaseProcessesController();
		caseProcessesController.pageController = pageController;

		// Set the necessary Case Process controllers
		pageController.currentCaseProcessType = ISSP_ICCS_Utils.CaseProcessType.PART_DEL;
		ISSP_ICCS_ProcessPartDelController leaveParticipationController = new ISSP_ICCS_ProcessPartDelController();
        leaveParticipationController.caseProcessesController = caseProcessesController;

		// Set the necessary Typed Document controllers
        ISSP_ICCS_TypedDocumentController leaveParticipation = new ISSP_ICCS_TypedDocumentController();
		leaveParticipation.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_LEAVE_PARTICIPATION;
		leaveParticipation.caseProcessController = leaveParticipationController;

		// Set the File upload controller
        ISSP_ICCS_FileUploadController uploadController = new ISSP_ICCS_FileUploadController();
        uploadController.caseProcessesController = caseProcessesController;

		// Back to the Homepage
		pageController.currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentCaseProcessType = null;



		// Navigate to Service Management
        pageController.navigateToServiceMgmt();

        ISSP_ICCS_Utils.ParticipationTable participationTable = serviceMgmtController.participationTable;
		
		System.assert(participationTable.participationRows.size() > 0);
		
		// Leave Participation
		serviceMgmtController.participationIdParameter = participationTable.participationRows[0].participationId;
		serviceMgmtController.leaveParticipation();
			
        List<SelectOption> reasonsList = leaveParticipationController.reasonsList;
        
        // check that we can't pass the first step
        System.assertEquals(caseProcessesController.currentStep, 1);
        System.assert(leaveParticipationController.selectedProductType != null);
        System.assert(leaveParticipationController.selectedCountry != null);
        System.assert(leaveParticipationController.selectedCurrency != null);

        caseProcessesController.next();
        System.assertEquals(caseProcessesController.currentStep, 1);

        leaveParticipationController.reason = 'Test';

        caseProcessesController.next();
        System.assertEquals(caseProcessesController.currentStep, 2);

        // check that we can't pass the first step        
        caseProcessesController.next();
        System.assertEquals(caseProcessesController.currentStep, 2);
        
        caseProcessesController.cse.Expected_Deadline__c = Date.today();
        leaveParticipationController.contactForm.Contact_Resp_Salutation__c = 'Mr';
        leaveParticipationController.contactForm.Contact_Resp_Phone__c = '123';
        leaveParticipationController.contactForm.Contact_Resp_Job_Title__c = 'A';
        leaveParticipationController.contactForm.Contact_Resp_Email__c = 'b@c.def';
        
        caseProcessesController.next();
        System.assertEquals(caseProcessesController.currentStep, 3);
        
        // Save draft case
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
		System.assertEquals(pageController.currentCaseProcessType, ISSP_ICCS_Utils.CaseProcessType.PART_DEL);
        
        caseProcessesController.next();
        caseProcessesController.next();

        // check that we can't pass the third step
        caseProcessesController.submit();
        System.assertEquals(caseProcessesController.currentStep, 3);
        
        leaveParticipationController.contactForm.Accept_terms_and_conditions__c = true;

        leaveParticipation.showFileUploadComponent();
        uploadController.filename = 'test';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();
        
        caseProcessesController.portalUserComment.CommentBody = 'New comment';        

        caseProcessesController.submit();
        caseProcessesController.saveAttachmentsToAmazon();
        caseProcessesController.closePage();
        
        Test.stopTest();
    }
}