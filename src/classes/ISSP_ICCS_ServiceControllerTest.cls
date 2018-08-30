@isTest
public class ISSP_ICCS_ServiceControllerTest {

    private static User createPartnerUser(String serviceStatus, String userRole, Boolean caseBelongsToAccount, String caseOrigin){
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

        Account a1 = New Account(
            Recordtypeid = aRTMap.get('Airline Headquarters').getRecordtypeid(), 
            Name = 'TestPortalAccount 1',
			Airline_designator__c = 'LX',
			IATACode__c = '724',
            ICCS_Membership_Status__c = serviceStatus);
        
        Account a2 = New Account(
            Recordtypeid = aRTMap.get('Airline Headquarters').getRecordtypeid(), 
            Name = 'TestPortalAccount 2');
        
        insert new List<Account>{a1, a2};

        List<Folder> folders = [select Id from Folder where DeveloperName = 'ICCS_Portal_Service'];
        
        Document doc = new Document(
            Name = 'test ICCS document',
            Body = Blob.valueOf('test'),
            FolderId = folders[0].id,
            IsPublic = true
        );
        
        insert doc;

        Contact c1 = New Contact(
            FirstName = 'Portal', 
            LastName = 'Test 1', 
            Email = 'test@test1.tes',
            User_Portal_Status__c = ISSP_ICCS_Utils.PORTAL_STATUS_APPROVED,
            AccountID = a1.id);
        
        Contact c2 = New Contact(
            FirstName = 'Portal', 
            LastName = 'Test 2', 
            Email = 'test@test2.tes',
            AccountID = a2.id);
        
        insert new List<Contact>{c1,c2};

		Portal_Application_Right__c userRights = new Portal_Application_Right__c(
			ANG_Portal_Service_Role__c = userRole,
			Portal_Application__c = ISSP_ICCS_Utils.getIccsPortalApplication().Id,
			Contact__c = c1.Id,			
			Right__c = 'Access Granted'
		);
		
		insert userRights;


		if(caseBelongsToAccount){
			Case cse1 = new Case(Status = 'Open', Origin = caseOrigin, AccountId = a1.Id, Contact = c1, RecordTypeId =  ISSP_ICCS_Utils.CASE_RECORD_TYPE_MEMBERSHIP);
			insert cse1;
		}
		else{
			Case cse1 = new Case(Status = 'Open', Origin = caseOrigin, AccountId = a2.Id, Contact = c2, RecordTypeId =  ISSP_ICCS_Utils.CASE_RECORD_TYPE_MEMBERSHIP);
			insert cse1;
		}

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
            ContactID = c1.id
            );
        
        insert u;

        return u;
    }

    private static User createPartnerUser(String airlineDesignator, String iataCode){
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

        Account a1 = New Account(
            Recordtypeid = aRTMap.get('Airline Headquarters').getRecordtypeid(), 
            Name = 'TestPortalAccount 1',
			Airline_designator__c = airlineDesignator,
			IATACode__c = iataCode,
            ICCS_Membership_Status__c = 'Member');
        
        insert a1;

        Contact c1 = New Contact(
            FirstName = 'Portal', 
            LastName = 'Test 1', 
            Email = 'test@test1.tes',
            User_Portal_Status__c = ISSP_ICCS_Utils.PORTAL_STATUS_APPROVED,
            AccountID = a1.id);
        
        insert c1;

		Portal_Application_Right__c userRights = new Portal_Application_Right__c(
			ANG_Portal_Service_Role__c = 'Signatory',
			Portal_Application__c = ISSP_ICCS_Utils.getIccsPortalApplication().Id,
			Contact__c = c1.Id,			
			Right__c = 'Access Granted'
		);
		
		insert userRights;

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
            ContactID = c1.id
            );
        
        insert u;

        return u;
    }


    static testMethod void testService() {

        User partnerUser = createPartnerUser('Inactive', 'Signatory', false, 'Email');

        Test.startTest();
        
		// Invalid Case Id

        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id, 'Invalid Case Id');

		// Other Account's Case

		Case cse = [select Id from Case Limit 1];

		pageController = new ISSP_ICCS_ServiceController(partnerUser.Id, cse.Id);

		// Not an ICCS Case
		
		Contact cont = [select Id, AccountId from Contact where Id =: partnerUser.ContactId];

		cse.AccountId = cont.AccountId;
		cse.Contact = cont;
		
		update cse;

		pageController = new ISSP_ICCS_ServiceController(partnerUser.Id, cse.Id);

		// Not an ICCS Member

		cse.Origin = 'Portal';
		update cse;

		pageController = new ISSP_ICCS_ServiceController(partnerUser.Id, cse.Id);

		// Increase code coverage

        Boolean b = pageController.isAgency 
                    | pageController.isAirline 
                    | pageController.isMembershipProspect
                    | pageController.isMembershipWithdrawn
                    | pageController.isMembershipActive
                    | pageController.isMembershipMember
                    | pageController.isMembershipInactive
                    | pageController.isMembershipNone
                    | pageController.isPortalStatusApproved
                    | pageController.isPortalStatusAdmin
                    | pageController.isPortalStatusInactive
                    | pageController.isPortalStatusPending
                    | pageController.isPortalStatusRegAdmin
                    | pageController.isPortalStatusNone
                    | pageController.displayHomepage
                    | pageController.displayProfile
                    | pageController.displayServiceMgmt
                    | pageController.displayCycleMgmt
                    | pageController.displayReports
                    | pageController.displayCases
                    | pageController.displayCaseProcesses
                    | pageController.displaySiEdit
                    | pageController.displayNoa
                    | pageController.displayAccessDenied
                    | pageController.displayRegistration
                    | pageController.displayBankAccount
                    | pageController.displayPartNew
                    | pageController.displayPartDel
					| pageController.displayDeactivation
					| pageController.displayAspUpd;
					
		Integer activeParticipations = pageController.activeParticipations;
		Integer opportunities = pageController.opportunities;
		Integer numberOfBankAccounts = pageController.numberOfBankAccounts;
		
		Map<String, Document> downloadableDocumentsMap = pageController.downloadableDocumentsMap;

		String s = pageController.pricingPolicyFileUniqueName + pageController.fxPolicyFileUniqueName + pageController.registrationZipFileUniqueName;

        Test.stopTest();
    }
    
    static testMethod void testTokenResponseNull(){

        User partnerUser = createPartnerUser('TO', '000');

        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

        Test.startTest();

		try{
			String token = pageController.coreRest.token;
		}
		catch(Exception e){}

		Test.stopTest();
    }

    static testMethod void testTokenResponseInvalid(){

        User partnerUser = createPartnerUser('TO', '400');

        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

        Test.startTest();

		try{
			String token = pageController.coreRest.token;
		}
		catch(Exception e){}

		Test.stopTest();
    }

    static testMethod void testCalloutResponseNull(){

        User partnerUser = createPartnerUser('ER', '000');

        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

        Test.startTest();

		try{
			pageController.coreRest.getCashflows();
		}
		catch(Exception e){}

		Test.stopTest();
    }

    static testMethod void testCalloutResponseError(){

        User partnerUser = createPartnerUser('ER', '400');

        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

        Test.startTest();

		try{
			pageController.coreRest.getCashflows();
		}
		catch(Exception e){}

		Test.stopTest();
    }

    static testMethod void testCalloutResponseOtherStatusErrors(){

        User partnerUser = createPartnerUser('ER', '402');

        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

        Test.startTest();

		try{
			pageController.coreRest.getCashflows();
		}
		catch(Exception e){}

		Test.stopTest();
    }

    static testMethod void testCalloutResponseInvalidJson(){

        User partnerUser = createPartnerUser('JS', '000');

        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

        Test.startTest();

		try{
			pageController.coreRest.getCashflows();
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getCycles(null);
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getInstructionTypes();
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getInstructionLineTypes();
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getReportTypes();
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getParticipations();
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getSettlementInstructions();
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getBankAccountsCodes();
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getParticipation(0);
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getSettlementInstruction(0);
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getCycleCashflows('');
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getCycleParticipations('');
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getCycleBankAccountsCodes('');
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getCycleSettlementInstructions('');
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getCycleSettlementInstruction('', 0);
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getReports(1, 1, '', '', '', '');
		}
		catch(Exception e){}

		try{
			pageController.coreRest.getReport('', '');
		}
		catch(Exception e){}

		Test.stopTest();
    }
}