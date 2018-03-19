@isTest
private class ISSP_TIP_Home_Controller_Test{

	public static User newUser;

	@testSetup static void setup() {


		//create isocountry
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;


		//create account
		Id rtId = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'TIP_Payment_Provider'][0].Id; 

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtId;
        parent.IATACode__c = '100';
        parent.category__c = 'Payment Provider';
        insert parent;
		

		//create case

		Case newCase = new Case();
    	newcase.RecordTypeid = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('CS_Process_IDFS_ISS');
		newcase.Accountid = parent.id; 
		newcase.Visible_on_ISS_Portal__c = true;
		newcase.Reason = 'Payment Provider Management';
		newcase.CaseArea__c = 'Transparency in Payments (TIP)'; 
		newcase.Status = 'Draft';
		newcase.Subject = 'Request for Enlistment as Payment provider - ' + parent.name;
		newCase.Description = 'Request for Enlistment as Payment provider';
		newcase.Region__c = parent.IATA_ISO_Country__r.region__c;
		newcase.Origin = 'Portal';
		newcase.BSPCountry__c = parent.IATA_ISO_Country__r.Name;
		newcase.Country_concerned_by_the_query__c = parent.IATA_ISO_Country__r.Name;	
		insert newCase;


		//insert contact
		Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

		//insert user

		newUser = new User(alias = 'dsfsdfds', 
                                email = con.email, 
                                emailencodingkey = 'UTF-8', 
                                firstname = con.firstName, 
                                lastname = con.lastname, 
                                languagelocalekey = 'en_US', 
                                localesidkey = 'en_US', 
                                contactId = con.Id,
                                timezonesidkey = 'Asia/Dubai',
                                Username = 'dasdasd',
                                PortalRole = 'Manager',
                                CommunityNickname = 'dasda',
                                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                                IsActive = true);
        insert newUser;
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

	}

	@isTest
	static void testGetCases(){

		System.runAs(newUser){
			ISSP_TIP_Home_Controller controller = new ISSP_TIP_Home_Controller();
			List<Case> cases = controller.getCases();
			System.assertEquals(cases.size(), 1);
		}
	}

}