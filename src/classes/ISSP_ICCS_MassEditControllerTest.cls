@isTest
public class ISSP_ICCS_MassEditControllerTest {

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

	static testMethod void testMassEditAdhoc(){

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
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CYCLE_MGMT;
		ISSP_ICCS_CycleMgmtController cycleMgmtController = new ISSP_ICCS_CycleMgmtController();
		cycleMgmtController.pageController = pageController;

		pageController.previousComponent = ISSP_ICCS_Utils.Page.CYCLE_MGMT;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.MASS_EDIT;

		// Back to the Homepage
		pageController.currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;

		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.HOMEPAGE);
		System.assert(pageController.componentControllersMap.get(pageController.previousComponent)!=null, 'pageController.componentControllersMap ' + pageController.componentControllersMap);


		// Navigate to Service Management
		pageController.navigateToServiceMgmt();

		List<String> adhocCyclesList = cycleMgmtController.adhocCyclesList;

		System.assert(cycleMgmtController.adhocCyclesSize > 1);

		System.assertEquals(cycleMgmtController.selectedAdhocCycle, '');
		System.assertEquals(cycleMgmtController.adhocCycleParticipationTable, null);

		cycleMgmtController.selectedAdhocCycle = adhocCyclesList[0];

		ISSP_ICCS_Utils.ParticipationTable cycleParticipationTable = cycleMgmtController.adhocCycleParticipationTable;

		System.assert(cycleParticipationTable.participationRows.size() > 0);

		// select a participation
		ISSP_ICCS_Utils.ParticipationRow cycleParticipationRow = cycleParticipationTable.participationRows[0];


		// select a settlement instruction
		ISSP_ICCS_Utils.SettlementInstructionRow cycleSettlementInstructionRow = cycleParticipationRow.settlementInstructionRows[0];

		// clone cycle settlement instruction
		cycleMgmtController.settlementInstructionIdParameter = cycleSettlementInstructionRow.settlementInstructionId;
		cycleMgmtController.cycleIdParameter = cycleMgmtController.selectedAdhocCycle;

		// Go to Mass Edit participation with no selected SIs
		cycleMgmtController.massAdHocEditParticipation();
		System.assertEquals(0, cycleMgmtController.selectedAdHocParticipationRow.size());

		// Go to Mass Edit participation with a selected SI
		ISSP_ICCS_Utils.CurrencyRow currencyRow = cycleMgmtController.adhocCycleParticipationTable.CurrencyRows[0];
		ISSP_ICCS_Utils.ParticipationRow participationRow = currencyRow.currencyParticipationRows[0];
		participationRow.selected = true;
		System.assertEquals(1, cycleMgmtController.selectedAdHocParticipationRow.size());
		cycleMgmtController.massAdHocEditParticipation();
		cycleMgmtController.pageController.previousComponent = ISSP_ICCS_Utils.Page.CYCLE_MGMT;

		//Create Mass Edit Page
		ISSP_ICCS_MassEditController massEditController = new ISSP_ICCS_MassEditController();
		massEditController.cleanController();
		massEditController.resetController(cycleMgmtController.pageController);
		massEditController.pageController = pageController;
		List<SelectOption> listOptions = massEditController.instructionLineTypes;
		System.assertEquals(false, listOptions.isEmpty());

		// add and delete an instruction line
		massEditController.addInstructionLine();
		massEditController.instructionLineOrder = 1;
		massEditController.deleteInstructionLine();

		// add a balance instruction line
		massEditController.addInstructionLine();
		massEditController.instructionLineOrder = 1;
		massEditController.listInstruction[0].accountCode.id = massEditController.bankAccountCodesMap.values()[0].id;
		massEditController.listInstruction[0].type.id = massEditController.balanceInstructionLineTypeId;

		massEditController.updateInstructionLinesOrder();

		List<SelectOption> orders = massEditController.orders;

		massEditController.submit();

		Test.stopTest();
	}

	static testMethod void testMassEditCurrency(){

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
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CYCLE_MGMT;
		ISSP_ICCS_CycleMgmtController cycleMgmtController = new ISSP_ICCS_CycleMgmtController();
		cycleMgmtController.pageController = pageController;

		pageController.previousComponent = ISSP_ICCS_Utils.Page.CYCLE_MGMT;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.MASS_EDIT;

		// Back to the Homepage
		pageController.currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;

		System.assertEquals(pageController.currentComponent, ISSP_ICCS_Utils.Page.HOMEPAGE);
		System.assert(pageController.componentControllersMap.get(pageController.previousComponent)!=null, 'pageController.componentControllersMap ' + pageController.componentControllersMap);


		// Navigate to Service Management
		pageController.navigateToServiceMgmt();

		List<String> adhocCyclesList = cycleMgmtController.adhocCyclesList;

		System.assert(cycleMgmtController.adhocCyclesSize > 1);

		System.assertEquals(cycleMgmtController.selectedAdhocCycle, '');
		System.assertEquals(cycleMgmtController.adhocCycleParticipationTable, null);

		cycleMgmtController.selectedAdhocCycle = adhocCyclesList[0];

		ISSP_ICCS_Utils.ParticipationTable cycleParticipationTable = cycleMgmtController.adhocCycleParticipationTable;

		System.assert(cycleParticipationTable.participationRows.size() > 0);

		// select a participation
		ISSP_ICCS_Utils.ParticipationRow cycleParticipationRow = cycleParticipationTable.participationRows[0];

		// select a settlement instruction
		ISSP_ICCS_Utils.SettlementInstructionRow cycleSettlementInstructionRow = cycleParticipationRow.settlementInstructionRows[0];

		// clone cycle settlement instruction
		cycleMgmtController.settlementInstructionIdParameter = cycleSettlementInstructionRow.settlementInstructionId;
		cycleMgmtController.cycleIdParameter = cycleMgmtController.selectedAdhocCycle;

		// Go to Mass Create Currency SI
		cycleMgmtController.massCurrencyEditParticipation();
		cycleMgmtController.pageController.previousComponent = ISSP_ICCS_Utils.Page.CYCLE_MGMT;

		//Create Mass Edit Page
		ISSP_ICCS_MassEditController massEditController = new ISSP_ICCS_MassEditController();
		massEditController.cleanController();
		massEditController.resetController(cycleMgmtController.pageController);
		massEditController.pageController = pageController;

		// Select a currency
		massEditController.settlementInstructionType = ISSP_ICCS_Utils.SI_CURRENCY;
		list<SelectOption> listCurrencyOption = massEditController.availableCurrenciesList;
		System.assert(listCurrencyOption.size()>1, 'There are no currencies ' + listCurrencyOption);
		massEditController.currencyFilter = listCurrencyOption[0].getValue();
		massEditController.cycleId = cycleMgmtController.selectedAdhocCycle;

		// add a balance instruction line
		massEditController.addInstructionLine();
		massEditController.instructionLineOrder = 1;
		massEditController.listInstruction[0].accountCode.id = massEditController.bankAccountCodesMap.values()[0].id;
		massEditController.listInstruction[0].type.id = massEditController.balanceInstructionLineTypeId;

		massEditController.submit();

		Test.stopTest();
	}
}