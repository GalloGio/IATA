@isTest
public class ISSP_ICCS_CycleMgmtControllerTest {

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
    
    static testMethod void testCycleManagement(){
    	
        User partnerUser = createPartnerUser('');

        Test.startTest();
        
		// Create page controller
        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

		// Set the necessary Component controllers
        ISSP_ICCS_HomepageController homepageController = new ISSP_ICCS_HomepageController();
		homepageController.pageController = pageController;
		
		pageController.previousComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CYCLE_MGMT;
        ISSP_ICCS_CycleMgmtController cycleMgmtController = new ISSP_ICCS_CycleMgmtController();
		cycleMgmtController.pageController = pageController;
		
		pageController.previousComponent = ISSP_ICCS_Utils.Page.CYCLE_MGMT;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.SI_EDIT;
        ISSP_ICCS_SiEditController siEditController = new ISSP_ICCS_SiEditController();
		siEditController.pageController = pageController;

		// Back to the Homepage
		pageController.currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;

		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.HOMEPAGE);

		// Navigate to Cases
        pageController.navigateToCycleMgmt();

		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CYCLE_MGMT);

		/* CYCLE */
		
		List<String> adhocCyclesList = cycleMgmtController.adhocCyclesList;

		System.assert(cycleMgmtController.adhocCyclesSize > 1);

		System.assertEquals(cycleMgmtController.selectedAdhocCycle, '');
		System.assertEquals(cycleMgmtController.adhocCycleParticipationTable, null);

		cycleMgmtController.selectedAdhocCycle = adhocCyclesList[0];

		List<ISSP_ICCS_Utils.ParticipationRow> cycleParticipationRows = cycleMgmtController.cycleParticipationRows;

		System.assert(cycleParticipationRows.size() > 0);

		Boolean isCycleParticipationTableExpandable = cycleMgmtController.isCycleParticipationTableExpandable;

		cycleMgmtController.expandCollapseCycleParticipationTable();

		cycleParticipationRows = cycleMgmtController.cycleParticipationRows;
		
		
		ISSP_ICCS_Utils.ParticipationTable cycleParticipationTable = cycleMgmtController.adhocCycleParticipationTable;

//		System.assert(cycleParticipationTable.participationRows.size() > 0);

		// select a participation
//		ISSP_ICCS_Utils.ParticipationRow cycleParticipationRow = cycleParticipationTable.participationRows[0];		
		ISSP_ICCS_Utils.ParticipationRow cycleParticipationRow = cycleParticipationRows[0];		
		
		// show the selected participation settlement instructions
		cycleParticipationRow.showSettlementInstructions();

		System.assert(cycleParticipationRow.settlementInstructionRows.size() > 0);

		// select a settlement instruction
		ISSP_ICCS_Utils.SettlementInstructionRow cycleSettlementInstructionRow = cycleParticipationRow.settlementInstructionRows[0];

		// show and hide the selected settlement instruction instruction lines
		cycleSettlementInstructionRow.showInstructionLines();
		cycleSettlementInstructionRow.hideInstructionLines();

		cycleMgmtController.settlementInstructionIdParameter = cycleSettlementInstructionRow.settlementInstructionId;
		cycleMgmtController.cycleIdParameter = cycleMgmtController.selectedAdhocCycle;
		
		cycleMgmtController.cloneCycleSettlementInstruction();
		
		pageController.cancel();
		
		// hide the selected participation settlement instructions
		cycleParticipationRow.hideSettlementInstructions();
		
		// create a settlement instruction
		cycleMgmtController.settlementInstructionTypeParameter = ISSP_ICCS_Utils.SI_ADHOC;
		cycleMgmtController.participationIdParameter = cycleParticipationRow.participationId;
		cycleMgmtController.cycleIdParameter = cycleMgmtController.selectedAdhocCycle;
		
		cycleMgmtController.createSettlementInstruction();
		
		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.SI_EDIT);
		
		pageController.cancel();
		
		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CYCLE_MGMT);
		
		// Change selected cycle
		cycleMgmtController.selectedAdhocCycle = adhocCyclesList[1];
		cycleParticipationTable = cycleMgmtController.adhocCycleParticipationTable;		
		
		// Simulate Partial reset
		cycleMgmtController.adhocRequiresDataReset = true;
		cycleParticipationTable = cycleMgmtController.adhocCycleParticipationTable;		

		List<SelectOption> adhocCycleFilter = cycleMgmtController.adhocCycleFilter;



		/* FUTURE */

		List<String> futureCyclesList = cycleMgmtController.futureCyclesList;

		System.assert(cycleMgmtController.futureCyclesSize > 1);

		System.assertEquals(cycleMgmtController.selectedFutureCycle, '');
		System.assertEquals(cycleMgmtController.futureCycleParticipationTable, null);

		cycleMgmtController.selectedFutureCycle = futureCyclesList[0];

		List<ISSP_ICCS_Utils.ParticipationRow> futureParticipationRows = cycleMgmtController.futureParticipationRows;

		System.assert(futureParticipationRows.size() > 0);

		Boolean isFutureParticipationTableExpandable = cycleMgmtController.isFutureParticipationTableExpandable;

		cycleMgmtController.expandCollapseFutureParticipationTable();

		futureParticipationRows = cycleMgmtController.futureParticipationRows;
		
		
		ISSP_ICCS_Utils.ParticipationTable futureParticipationTable = cycleMgmtController.futureCycleParticipationTable;

//		System.assert(futureParticipationTable.participationRows.size() > 0);

		// select a participation
//		ISSP_ICCS_Utils.ParticipationRow futureParticipationRow = futureParticipationTable.participationRows[0];		
		ISSP_ICCS_Utils.ParticipationRow futureParticipationRow = futureParticipationRows[0];		

		// show the selected participation settlement instructions
		futureParticipationRow.showSettlementInstructions();

		System.assert(futureParticipationRow.settlementInstructionRows.size() > 0);

		// edit a settlement instruction
		ISSP_ICCS_Utils.SettlementInstructionRow futureSettlementInstructionRow = futureParticipationRow.settlementInstructionRows[0];

		cycleMgmtController.settlementInstructionTypeParameter = ISSP_ICCS_Utils.SI_FUTURE;
		cycleMgmtController.settlementInstructionIdParameter = futureSettlementInstructionRow.settlementInstructionId;
		cycleMgmtController.editSettlementInstruction();

		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.SI_EDIT);
		
		pageController.cancel();
		
		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CYCLE_MGMT);
		
		// hide the selected participation settlement instructions
		futureParticipationRow.hideSettlementInstructions();
		
		// create a settlement instruction
		cycleMgmtController.settlementInstructionTypeParameter = ISSP_ICCS_Utils.SI_FUTURE;
		cycleMgmtController.participationIdParameter = futureParticipationRow.participationId;
		cycleMgmtController.cycleIdParameter = cycleMgmtController.selectedFutureCycle;
		cycleMgmtController.createSettlementInstruction();

		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.SI_EDIT);
		
		pageController.cancel();
		
		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.CYCLE_MGMT);

		// delete the future settlement instruction
		cycleMgmtController.settlementInstructionIdParameter = futureSettlementInstructionRow.settlementInstructionId;
		cycleMgmtController.modifiedOnParameter = futureSettlementInstructionRow.settlementInstruction.modifiedOn;
		cycleMgmtController.deleteSettlementInstruction();
		
		// Change selected cycle
		cycleMgmtController.selectedFutureCycle = futureCyclesList[1];
		futureParticipationTable = cycleMgmtController.futureCycleParticipationTable;		
		
		// Simulate Partial reset
		cycleMgmtController.futureRequiresDataReset = true;
		futureParticipationTable = cycleMgmtController.futureCycleParticipationTable;		

		List<SelectOption> futureCycleFilter = cycleMgmtController.futureCycleFilter;

		cycleMgmtController.cleanController();
		cycleMgmtController.resetController(cycleMgmtController.pageController);


		List<ISSP_ICCS_CoreRest.Cycle> cycles = pageController.coreRest.getCycles(new Set<ISSP_ICCS_CoreRest.CYCLE_STATUS> {ISSP_ICCS_CoreRest.CYCLE_STATUS.Created});

		System.assert(cycles != null && cycles.size() > 0);
		
		Integer cycleTypeId = cycles[0].type.id;
		String cycleTypeCode = cycles[0].type.code;
		Integer cycleStatusId = cycles[0].status.id;
		String cycleStatusCode = cycles[0].status.code;
		String startDate = cycles[0].startDate;
		String endDate = cycles[0].endDate;
		String comment = cycles[0].comment;
		
		pageController.setMessage('toto', false);
        Test.stopTest();
    }
}