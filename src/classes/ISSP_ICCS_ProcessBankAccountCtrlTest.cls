@isTest(SeeAllData=true)
public class ISSP_ICCS_ProcessBankAccountCtrlTest {

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
    
    static testMethod void testAddBankAccount(){
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
		pageController.currentCaseProcessType = ISSP_ICCS_Utils.CaseProcessType.BANK_ACCOUNT;
		ISSP_ICCS_ProcessBankAccountController bankAccountController = new ISSP_ICCS_ProcessBankAccountController();
        bankAccountController.caseProcessesController = caseProcessesController;

		// Set the necessary Typed Document controllers
        ISSP_ICCS_TypedDocumentController bankAccounts = new ISSP_ICCS_TypedDocumentController();
		bankAccounts.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS;
		bankAccounts.caseProcessController = bankAccountController;

		// Set the File upload controller
        ISSP_ICCS_FileUploadController uploadController = new ISSP_ICCS_FileUploadController();
        uploadController.caseProcessesController = caseProcessesController;

		// Back to the Homepage
		pageController.currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentCaseProcessType = null;


		// Navigate to Service Management
        pageController.navigateToServiceMgmt();

		// Create Bank Account
        serviceMgmtController.createBankAccount();

		// Check that current component is CASE_PROCESSES
		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CASE_PROCESSES);
		
		// Check that current Case Process is ASP_UPD		
		System.assertEquals(pageController.currentCaseProcessType, ISSP_ICCS_Utils.CaseProcessType.BANK_ACCOUNT);

/*        ISSP_ICCS_TypedDocumentController bankAccounts = new ISSP_ICCS_TypedDocumentController();
		bankAccounts.documentType = 'Bank Accounts';
		bankAccounts.isMandatory = true;
		bankAccounts.caseProcessController = bankAccountController;

        ISSP_ICCS_FileUploadController uploadController = new ISSP_ICCS_FileUploadController();
        uploadController.caseProcessesController = caseProcessesController;*/
        
        bankAccounts.showFileUploadComponent();
        uploadController.filename = 'test';
        uploadController.filebody = Blob.valueOf('test');        
        uploadController.upload();

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
		System.assertEquals(pageController.currentCaseProcessType, ISSP_ICCS_Utils.CaseProcessType.BANK_ACCOUNT);

        caseProcessesController.submit();
		caseProcessesController.saveAttachmentsToAmazon();
		caseProcessesController.closePage();
		
        Test.stopTest();
    }

    static testMethod void testUpdateBankAccount(){
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
		pageController.currentCaseProcessType = ISSP_ICCS_Utils.CaseProcessType.BANK_ACCOUNT;
		ISSP_ICCS_ProcessBankAccountController bankAccountController = new ISSP_ICCS_ProcessBankAccountController();
        bankAccountController.caseProcessesController = caseProcessesController;

		// Set the necessary Typed Document controllers
        ISSP_ICCS_TypedDocumentController bankAccounts = new ISSP_ICCS_TypedDocumentController();
		bankAccounts.documentType = ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS;
		bankAccounts.caseProcessController = bankAccountController;

		// Set the File upload controller
        ISSP_ICCS_FileUploadController uploadController = new ISSP_ICCS_FileUploadController();
        uploadController.caseProcessesController = caseProcessesController;

		// Back to the Homepage
		pageController.currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentCaseProcessType = null;

		// Navigate to Service Management
        pageController.navigateToServiceMgmt();

		ISSP_ICCS_ServiceMgmtController.BankAccountTable bankAccountTable = serviceMgmtController.bankAccountTable;

		System.assert(bankAccountTable.bankAccountBlocks.size() > 0);

		// Select a BankAccountBlock
		ISSP_ICCS_ServiceMgmtController.BankAccountBlock bankAccountBlock = bankAccountTable.bankAccountBlocks[0];
		
		// Update it
		bankAccountBlock.parentRow.updateBankAccount();

		bankAccountController.selectedReason = 'Change Request';
		// not successfull
		caseProcessesController.submit();
		
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
		System.assertEquals(pageController.currentCaseProcessType, ISSP_ICCS_Utils.CaseProcessType.BANK_ACCOUNT);

		// not successfull
		bankAccountController.selectedReason = ISSP_ICCS_Utils.NONE;
		caseProcessesController.submit();

		// not successfull
		bankAccountController.selectedReason = 'Add Bank Account Codes';
		bankAccountController.additionalBankAccountCodes = '';
		caseProcessesController.submit();

		// not successfull
		bankAccountController.additionalBankAccountCodes = 'not an integer';
		caseProcessesController.submit();

		// successfull
		bankAccountController.additionalBankAccountCodes = '1';
		caseProcessesController.submit();
		caseProcessesController.saveAttachmentsToAmazon();
		caseProcessesController.closePage();
        
        Test.stopTest();
    }
}