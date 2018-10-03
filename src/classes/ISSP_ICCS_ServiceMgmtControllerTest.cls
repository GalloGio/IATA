@isTest
public class ISSP_ICCS_ServiceMgmtControllerTest {

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
    
    static testMethod void testServiceManagement(){
    	
        User partnerUser = createPartnerUser('');

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
		pageController.currentComponent = ISSP_ICCS_Utils.Page.SI_EDIT;
        ISSP_ICCS_SiEditController siEditController = new ISSP_ICCS_SiEditController();
		siEditController.pageController = pageController;

		// Back to the Homepage
		pageController.currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;

		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.HOMEPAGE);

		// Navigate to Cases
        pageController.navigateToServiceMgmt();
        
		List<ISSP_ICCS_Utils.ParticipationRow> participationRows = serviceMgmtController.participationRows;

		System.assert(participationRows.size() > 0);

		Boolean isParticipationTableExpandable = serviceMgmtController.isParticipationTableExpandable;

		serviceMgmtController.expandCollapseParticipationTable();
        
		participationRows = serviceMgmtController.participationRows;

//		ISSP_ICCS_Utils.ParticipationTable participationTable = serviceMgmtController.participationTable;
		
//		System.assert(participationTable.participationRows.size() > 0);
		
		// select a participation
//		ISSP_ICCS_Utils.ParticipationRow participationRow = participationTable.participationRows[0];		
		ISSP_ICCS_Utils.ParticipationRow participationRow = participationRows[0];		
		
		// show the selected participation settlement instructions
		participationRow.showSettlementInstructions();

		System.assert(participationRow.settlementInstructionRows.size() > 0);

		// select a settlement instruction
		ISSP_ICCS_Utils.SettlementInstructionRow settlementInstructionRow = participationRow.settlementInstructionRows[0];

		serviceMgmtController.settlementInstructionTypeParameter = ISSP_ICCS_Utils.SI_STANDARD;
		serviceMgmtController.settlementInstructionIdParameter = settlementInstructionRow.settlementInstructionId;
		serviceMgmtController.editSettlementInstruction();
		
		pageController.cancel();

		// hide the selected participation settlement instructions
		participationRow.hideSettlementInstructions();		
		
		ISSP_ICCS_ServiceMgmtController.BankAccountTable bankAccountTable = serviceMgmtController.bankAccountTable;
		
		System.assert(bankAccountTable.bankAccountBlocks.size() > 0);
		
		Boolean isBankAccountTableExpandable = serviceMgmtController.isBankAccountTableExpandable;

		serviceMgmtController.expandCollapseBankAccountTable();
		
		bankAccountTable = serviceMgmtController.bankAccountTable;
		
		
		// Select a BankAccountBlock
		ISSP_ICCS_ServiceMgmtController.BankAccountBlock bankAccountBlock = bankAccountTable.bankAccountBlocks[0];

		System.assert(bankAccountBlock.hasChildRows);
		
		bankAccountBlock.parentRow.showChildRows();

		System.assert(bankAccountTable.rowsToDisplay.size() > 0);
		
		bankAccountBlock.parentRow.hideChildRows();


		pageController.navigateToHomepage();

		pageController.navigateToServiceMgmt();

		
//		bankAccountBlock.parentRow.updateBankAccount();

//		serviceMgmtController.createBankAccount();
        
        Test.stopTest();
    }
}