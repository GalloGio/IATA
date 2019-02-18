@isTest
private class ANG_FinancialSecurityTriggerHandlerTest {
	
	public class MockHttpResponseSuccessGenerator implements HttpCalloutMock {
		// Implement this interface method
		public HTTPResponse respond(HTTPRequest req) {
			// Optionally, only send a mock response for a specific endpoint
			// and method.
			System.assertEquals('PUT', req.getMethod());
			
			// Create a fake response
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setStatusCode(200);
			return res;
		}
	}

	@testSetup static void setup(){
        
		List<ANG_CalloutMapping__c> customsettings = new List<ANG_CalloutMapping__c>();
		customsettings.add(new ANG_CalloutMapping__c(Integration_System__c = 'Mulesoft' , Name = 'FSAMOUNT', Change_Code__c = 'FSFL1', Field__c = 'AMOUNT__C' ,CalloutClass__c = 'ANG_CalloutIEPMasterdata', Action__c = 'PUT', Event_Type__C = 'MS_Update', Credential__c = '/agencies/v1/', Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'Financial_Security__c'));
		customsettings.add(new ANG_CalloutMapping__c(Integration_System__c = 'Mulesoft' , Name = 'FSSTATUS', Change_Code__c = 'FSFL2', Field__c = 'SECURITY_STATUS__C' ,CalloutClass__c = 'ANG_CalloutIEPMasterdata', Action__c = 'PUT', Event_Type__C = 'MS_Update', Credential__c = '/agencies/v1/', Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'Financial_Security__c'));
		insert customsettings;

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true, Region__c = 'Europe')  ;
        insert ctry ;

        Id accountAgencyRT =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HE',Name='Test1 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        
        insert new List<Account>{a1};

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Test2 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');

		insert new List<Account>{a2};
 
        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1 OK');
		
		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy};

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);

        insert new List<AMS_Agencies_relationhip__c>{rel1};
	
    }

	@isTest static void createUpdateStatusonFS() {

		Account a1 = [Select id from Account where ParentId = null];

	    case cc = new case(AccountId = a1.Id);
        insert cc;
        
		Financial_Institution__c FI = new Financial_Institution__c(Name = 'FI1', INSTITUTION_TYPE__C='Bank');
        insert FI;

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessGenerator());

        Financial_Security__c fs = new Financial_Security__c(CURRENCYISOCODE='USD', Account__c=a1.Id, AMOUNT__C=3000, EXPIRY_DATE__C=system.Today().AddDays(100), FINANCIAL_INSTITUTION__c=FI.Id, SECURITY_STATUS__C='Active', Security_Type__c='Bank Guarantee', Region__c ='Europe', Reception_Date__c=system.today(), Reasonforrequest__c='New Application', Reception_Case__c=cc.Id);
        insert FS;

		fs.SECURITY_STATUS__C =  'Expired';
		update fs;

		Test.StopTest();

		List<AMS_Agency_Updates__c> auLst = [select id, Update_Type__c, RelationShip__c, Account__c from AMS_Agency_Updates__c];

		System.assertEquals(2,auLst.size());

	}

	@isTest static void createUpdateAmmountonFS() {

		Account a1 = [Select id from Account where ParentId = null];

	    case cc = new case(AccountId = a1.Id);
        insert cc;
        
		Financial_Institution__c FI = new Financial_Institution__c(Name = 'FI1', INSTITUTION_TYPE__C='Bank');
        insert FI;

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessGenerator());

        Financial_Security__c fs = new Financial_Security__c(CURRENCYISOCODE='USD', Account__c=a1.Id, AMOUNT__C=3000, EXPIRY_DATE__C=system.Today().AddDays(100), FINANCIAL_INSTITUTION__c=FI.Id, SECURITY_STATUS__C='Active', Security_Type__c='Bank Guarantee', Region__c ='Europe', Reception_Date__c=system.today(), Reasonforrequest__c='New Application', Reception_Case__c=cc.Id);
        insert FS;

		fs.AMOUNT__C = 4000;
		update fs;

		Test.StopTest();

		List<AMS_Agency_Updates__c> auLst = [select id, Update_Type__c, RelationShip__c, Account__c from AMS_Agency_Updates__c];

		System.assertEquals(2,auLst.size());

	}

	@isTest static void createDoNotUpdateAmmountonFS() {

		Account a1 = [Select id from Account where ParentId = null];

	    case cc = new case(AccountId = a1.Id);
        insert cc;
        
		Financial_Institution__c FI = new Financial_Institution__c(Name = 'FI1', INSTITUTION_TYPE__C='Bank');
        insert FI;

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessGenerator());

        Financial_Security__c fs = new Financial_Security__c(CURRENCYISOCODE='USD', Account__c=a1.Id, AMOUNT__C=3000, EXPIRY_DATE__C=system.Today().AddDays(100), FINANCIAL_INSTITUTION__c=FI.Id, SECURITY_STATUS__C='Active', Security_Type__c='Bank Guarantee', Region__c ='Europe', Reception_Date__c=system.today(), Reasonforrequest__c='New Application', Reception_Case__c=cc.Id);
        insert FS;

		fs.EXPIRY_DATE__C=system.Today().AddDays(200);
		update fs;

		Test.StopTest();

		List<AMS_Agency_Updates__c> auLst = [select id, Update_Type__c, RelationShip__c, Account__c from AMS_Agency_Updates__c];

		System.assertEquals(1,auLst.size());

	}
}