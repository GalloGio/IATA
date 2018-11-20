@isTest
public class ISSP_ICCS_CoreRestTest {

    private static User createPartnerUser(String airlineDesignator, String iataCode){
        // Create ICCS portal application if it doesn't exist
        if(ISSP_ICCS_Utils.getIccsPortalApplication() == null){
            insert new Portal_Applications__c(Name = 'ICCS');
        }
        
        // Create ICCS Signatory role if missing
        Map<String, Connected_App_Roles__c> existingRoles = Connected_App_Roles__c.getAll();
        if(! existingRoles.keySet().contains(ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY)){
            Connected_App_Roles__c signatoryRole = new Connected_App_Roles__c(Name = ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY, Description__c = 'ICCS Service', Role__c = ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY);
            insert signatoryRole;
        }

        Profile p = [Select ID, Name from Profile Where Name = 'ISS Portal (Partner)'];

        Account a = New Account(
            Recordtypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'), 
            Name = 'TestPortalAccount',
            Airline_designator__c = airlineDesignator,
            IATACode__c = iataCode,
            ICCS_Membership_Status__c = 'Member');
        
        insert a;

        Contact c = New Contact(
            FirstName = 'Portal', 
            LastName = 'Test', 
            Email = 'test@test1.tes',
            User_Portal_Status__c = ISSP_ICCS_Utils.PORTAL_STATUS_APPROVED,
            AccountID = a.id);
        
        insert c;

        Portal_Application_Right__c userRights = new Portal_Application_Right__c(
            ANG_Portal_Service_Role__c = 'Signatory',
            Portal_Application__c = ISSP_ICCS_Utils.getIccsPortalApplication().Id,
            Contact__c = c.Id,         
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
            ContactID = c.id);
        
        insert u;

        return u;
    }

    static testMethod void testExceptions(){
		User partnerUser = createPartnerUser('TO', '000');

		Test.startTest();

		// Test Token Response Null
		
		ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

		try{
			String token = pageController.coreRest.token;
		}
		catch(Exception e){}
		

		// Test Token Response invalid

		pageController.participantId = 'TO400';

		try{
			String token = pageController.coreRest.token;
		}
		catch(Exception e){}


		// Test Callout Response Null

		pageController.participantId = 'ER000';

		try{
			pageController.coreRest.getCashflows();
		}
		catch(Exception e){}


		// Test Callout Response Error

		pageController.participantId = 'ER400';

		try{
			pageController.coreRest.getCashflows();
		}
		catch(Exception e){}


		// Test Callout Response Token Expired

		pageController.participantId = 'TO401';

		try{
			pageController.coreRest.getCashflows();
		}
		catch(Exception e){}


		// Test Callout Response Other Status Error

		pageController.participantId = 'ER402';

		try{
			pageController.coreRest.getCashflows();
		}
		catch(Exception e){}


		// Test Callout Response Invalid Json

		pageController.participantId = 'JS000';

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

/*    static testMethod void testTokenResponseInvalid(){
        User partnerUser = createPartnerUser('TO', '400');

		Test.startTest();

		ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

		try{
			String token = pageController.coreRest.token;
		}
		catch(Exception e){}

		Test.stopTest();
    }
    
    static testMethod void testCalloutResponseNull(){
        User partnerUser = createPartnerUser('ER', '000');

		Test.startTest();

		ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

		try{
			pageController.coreRest.getCashflows();
		}
		catch(Exception e){}

        Test.stopTest();
    }
    
    static testMethod void testCalloutResponseError(){
        User partnerUser = createPartnerUser('ER', '400');

		Test.startTest();

		ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

		try{
			pageController.coreRest.getCashflows();
		}
		catch(Exception e){}

        Test.stopTest();
    }

    static testMethod void testCalloutResponseOtherStatusErrors(){
		User partnerUser = createPartnerUser('ER', '402');

		Test.startTest();

		ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

		try{
			pageController.coreRest.getCashflows();
		}
		catch(Exception e){}

		Test.stopTest();
    }

    static testMethod void testCalloutResponseInvalidJson(){
        User partnerUser = createPartnerUser('JS', '000');

		Test.startTest();

		ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

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
*/
}