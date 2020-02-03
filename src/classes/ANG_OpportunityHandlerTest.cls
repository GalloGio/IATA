@isTest
public class ANG_OpportunityHandlerTest {
	
	@testSetup
	public static void setup() {
		List<ANG_CalloutMapping__c> customsettings = new List<ANG_CalloutMapping__c>();
		customsettings.add(new ANG_CalloutMapping__c(Name = 'ENDORS_CERT', CalloutClass__c = 'ANG_RME_Alert_Service', Action__c = 'GET',
			Event_Type__C = 'WebService', Credential__c = '/v1/agencies/{agencyId}/offer/{offerId}/endorsement', Named_Credential__c = 'Mulesoft_Credential_Masterdata',
			Type__c = 'Button'));
		insert customsettings;
		
		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c(Name = 'US', ISO_Code__c = 'US', ANG_Enable_NewGen__c = true);
		insert ctry;
		
		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name = 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
		insert stt;
		
		Account account = new Account();
		account.Name = 'Main HE Account H1';
		account.Sector__c = 'Travel Agent';
		account.IATACode__c = '12345678';
		account.Category__c = 'IATA Passenger Sales Agent';
		account.Location_Class__c = 'P';
		account.Location_Type__c = 'HE';
		account.ANG_Accreditation_Model__c = 'Cashless';
		account.IATA_ISO_Country__c = ctry.Id;
		account.RecordTypeId = accountAgencyRT;
		account.GDI_Status__c = 'Open';
		
		insert account;
		
		Contact co1 = new Contact(AccountId = account.id, Firstname = 'John', Lastname = 'Rambo', Phone = '666123456', MobilePhone = '911111111',
			Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
		insert co1;
		
		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Process__c = AMS_Utils.NGGDI, Account__c = account.id, RecordTypeId = AMS_Utils.RECTYPE_GDI);
		insert oscar;
		
		ID caseRT = RecordTypeSingleton.getInstance().getRecordTypeID('Case', 'OSCAR_Communication');
		
		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = caseRT);
		oscarCase.AccountId = account.Id;
		oscarCase.ContactId = co1.Id;
		oscarCAse.Reason1__c = 'GDI setup';
		
		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
		oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
		insert oscarCase;
		
		Product2 prod = new Product2(Name = 'Test', IsActive = true);
		insert prod;
		
		ID standardPBID = Test.getStandardPricebookId();
		insert new pricebookentry(UnitPrice = 20, CurrencyIsoCode = 'USD', Product2id = prod.id, IsActive = true, Pricebook2Id = standardPBID);
	}
	
	@isTest
	public static void testCreateOpportunity() {
		Test.startTest();
		
		Opportunity opp = new Opportunity(AccountId = [SELECT Id FROM account LIMIT 1].Id, CloseDate = Date.today(), CurrencyIsoCode = 'USD',
			Name = 'OPP - ', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'GDI_FinancialSecurity'),
			StageName = 'Pending', Related_Oscar__c = [SELECT Id FROM AMS_OSCAR__c LIMIT 1].Id, GDI_Offer_Id__c = '001');
		insert opp;
		
		Test.stopTest();
		
		AMS_OSCAR__c oscar = [SELECT Id, Endorsement_Requested__c, Endorsement_requested_date__c
							  FROM AMS_OSCAR__c
							  LIMIT 1];
		System.assert(oscar.Endorsement_Requested__c, 'Oscar not updated');
		System.assertNotEquals(null, oscar.Endorsement_requested_date__c, 'Oscar not updated');
	}
	
	@isTest
	public static void testUpdateOpportunity() {
		Test.startTest();
		
		Opportunity opp = new Opportunity(AccountId = [SELECT Id FROM account LIMIT 1].Id, CloseDate = Date.today(), CurrencyIsoCode = 'USD',
			Name = 'OPP - ', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'GDI_FinancialSecurity'),
			StageName = 'Pending', Related_Oscar__c = [SELECT Id FROM AMS_OSCAR__c LIMIT 1].Id);
		insert opp;
		
		AMS_OSCAR__c oscar = [SELECT Id, Endorsement_Requested__c, Endorsement_requested_date__c
							  FROM AMS_OSCAR__c
							  LIMIT 1];
		System.assertEquals(false, oscar.Endorsement_Requested__c, 'Oscar shouldn\'t be updated');
		System.assertEquals(null, oscar.Endorsement_requested_date__c, 'Oscar shouldn\'t be updated');
		
		opp = new Opportunity(Id = opp.Id, GDI_Offer_Id__c = '001');
		update opp;
		
		Test.stopTest();
		
		oscar = [SELECT Id, Endorsement_Requested__c, Endorsement_requested_date__c FROM AMS_OSCAR__c LIMIT 1];
		
		System.assert(oscar.Endorsement_Requested__c, 'Oscar not updated');
		System.assertNotEquals(null, oscar.Endorsement_requested_date__c, 'Oscar not updated');
	}
	
	@isTest
	public static void testPendingAccount() {
		Account a = new Account(Id = [SELECT Id FROM Account LIMIT 1].Id, Status__c = AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING);
		update a;
		
		Test.startTest();
		
		Opportunity opp = new Opportunity(Related_Oscar__c = [SELECT Id FROM AMS_OSCAR__c LIMIT 1].Id, CloseDate = Date.today(),
			AccountId = [SELECT Id FROM account LIMIT 1].Id, CurrencyIsoCode = 'USD', Name = 'OPP - ', RecordTypeId = 
			RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'GDI_FinancialSecurity'), StageName = 'Pending', GDI_Offer_Id__c = '001');
		insert opp;
		
		Test.stopTest();
		
		AMS_OSCAR__c oscar = [SELECT Id, Endorsement_Requested__c, Endorsement_requested_date__c
							  FROM AMS_OSCAR__c
							  LIMIT 1];
		System.assertEquals(false, oscar.Endorsement_Requested__c, 'Oscar shouldn\'t be updated');
		System.assertEquals(null, oscar.Endorsement_requested_date__c, 'Oscar shouldn\'t be updated');
	}
}