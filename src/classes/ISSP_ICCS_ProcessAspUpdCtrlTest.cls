@isTest(SeeAllData=true)
public class ISSP_ICCS_ProcessAspUpdCtrlTest {

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

        Account a = New Account(
            Recordtypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'), 
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

    static testMethod void testAspUpdateProcess() {
        User partnerUser = createPartnerUser('');

        Test.startTest();

		// Create page controller
        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

		// Set the necessary Component controllers
        ISSP_ICCS_HomepageController homepageController = new ISSP_ICCS_HomepageController();
		homepageController.pageController = pageController;
		
		pageController.previousComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.PROFILE;
        ISSP_ICCS_ProfileController profileController = new ISSP_ICCS_ProfileController();
		profileController.pageController = pageController;

		pageController.previousComponent = ISSP_ICCS_Utils.Page.PROFILE;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CASES;
        ISSP_ICCS_CasesController casesController = new ISSP_ICCS_CasesController();
		casesController.pageController = pageController;

		pageController.previousComponent = ISSP_ICCS_Utils.Page.CASES;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CASE_PROCESSES;
        ISSP_ICCS_CaseProcessesController caseProcessesController = new ISSP_ICCS_CaseProcessesController();
		caseProcessesController.pageController = pageController;

		// Set the necessary Case Process controllers
		pageController.currentCaseProcessType = ISSP_ICCS_Utils.CaseProcessType.ASP_UPD;
		ISSP_ICCS_ProcessAspUpdController aspUpdateController = new ISSP_ICCS_ProcessAspUpdController();
        aspUpdateController.caseProcessesController = caseProcessesController;

		// Set the necessary Typed Document controllers
        ISSP_ICCS_TypedDocumentController asp = new ISSP_ICCS_TypedDocumentController();
		asp.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_ASP;
		asp.caseProcessController = aspUpdateController;

		// Set the File upload controller
        ISSP_ICCS_FileUploadController uploadController = new ISSP_ICCS_FileUploadController();
        uploadController.caseProcessesController = caseProcessesController;

		// Back to the Homepage
		pageController.currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentCaseProcessType = null;


		// Navigate to Profile
        pageController.navigateToProfile();
		
		// Update ASP
		profileController.updateASP();

		String caseProcessName = caseProcessesController.caseProcessName;
		Boolean b = caseProcessesController.singleStep;
		List<Integer> stepNumbers = caseProcessesController.stepNumbers;
		b = caseProcessesController.displayPrevious & caseProcessesController.displayNext & caseProcessesController.displaySaveAndLeave & caseProcessesController.displaySubmit;

		// Check that current component is CASE_PROCESSES
		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CASE_PROCESSES);
		
		// Check that current Case Process is ASP_UPD		
		System.assertEquals(pageController.currentCaseProcessType, ISSP_ICCS_Utils.CaseProcessType.ASP_UPD);
		
        List<SelectOption> typesOfChange = aspUpdateController.typesOfChange;
        
        System.assert(aspUpdateController.typesOfChange.size() > 0);

        // submit should fail
        System.assert(!aspUpdateController.validateStep());

        aspUpdateController.caseProcessesController.submit();

        System.assert(typesOfChange.size() > 0);
        
        aspUpdateController.selectedTypeOfChange = typesOfChange[1].getValue();
        aspUpdateController.description = 'Desc';

        caseProcessesController.next();

        asp.showFileUploadComponent();
        uploadController.filename = 'test';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();
                
        // Save Draft Case
        caseProcessesController.saveAndLeave();
        caseProcessesController.saveAttachmentsToAmazon();
        caseProcessesController.closePage();
        

        pageController.navigateToCases();

		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CASES);

		// Retrieve case Id
		casesController.userCasesOnly = true;
		
		Case cse = casesController.cases[0];

        // Open Draft Case
        casesController.pageController.caseIdParameter = cse.Id;
		casesController.pageController.navigateToCase();
       
		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CASE_PROCESSES);
		System.assertEquals(pageController.currentCaseProcessType, ISSP_ICCS_Utils.CaseProcessType.ASP_UPD);

        caseProcessesController.next();

        // Submit Draft Case
        caseProcessesController.submit();
        caseProcessesController.saveAttachmentsToAmazon();
        caseProcessesController.closePage();

		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CASES);

        // Open Submitted Case
        casesController.pageController.caseIdParameter = cse.Id;
		casesController.pageController.navigateToCase();
		
		b = caseProcessesController.newAttachmentUploaded;

        aspUpdateController.caseProcessesController.portalUserComment.CommentBody = 'New comment';        

		caseProcessesController.resetSubmitFailed();

        // Submit submitted Case
        caseProcessesController.submit();
        caseProcessesController.saveAttachmentsToAmazon();
        caseProcessesController.closePage();


        Test.stopTest();
    }
}