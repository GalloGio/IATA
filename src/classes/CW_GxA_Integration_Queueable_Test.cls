/*************************************************************************************************************
 * @name			CW_GxA_Integration_Queueable_Test
 * @author			Bea <beatriz.menendez@adesso.es>
 * @created			23 / 09 / 2020
 * @description		Test class for CW_GxA_Integration_Queueable class
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2020-09-23		Bea						Class creation
 *
**************************************************************************************************************/
@isTest
global with sharing class CW_GxA_Integration_Queueable_Test {
	@testSetup 
	static void setup() {
		ICG_GxA_Integration_Settings__c gxaSettings = new ICG_GxA_Integration_Settings__c(Base_Path__c = 'SmartFacilityRemoteValidations/', Named_Credential__c = 'API_GetObject', Index_File__c = 'Result.json', Bucket__c = 'pwc-dev-0f0a94bcb834b69f');
		insert gxaSettings;
		
		ISSP_CS__c icgid = new ISSP_CS__c(Name = 'ICG_URL_Base', Value__c = 'https://theurl.com/s/'); 
		insert icgid;
		
		IATA_ISO_Country__c isoCode = CW_TestDataFactory.newISOCountry();
		insert isoCode;

		Account acc = CW_TestDataFactory.TestAccount(isoCode.Id);
		acc.Business_Street__c = 'Test Street';
		acc.Business_Postal_Code__c = '000000';
		insert acc;        

		Airport_Detail__c airport = CW_TestDataFactory.newAirport(isoCode.Id, acc.Id);
		insert airport;

		Contact con1 = CW_TestDataFactory.testContact(acc.id);
		insert con1;
		
		Profile profile = [Select Id from profile where Name LIKE '%IATA Customer Community User%' limit 1];
		
		String orgId = UserInfo.getOrganizationId();
		
		String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
		
		Integer RandomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
		
		String uniqueName = orgId + dateString + RandomId;
		
		User testUser = CW_TestDataFactory.testUser('Name', 'Last', uniqueName, orgId, profile.Id, con1.id);
		insert testUser;

		Account_Role__c accRole = CW_TestDataFactory.testAccountRole(acc.Id, 'Test');
		insert accRole;

		ICG_Account_Role_Detail__c accRoleDetail = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		insert accRoleDetail;

		Account_Contact_Role__c accountContactRole = CW_TestDataFactory.testAccountContactRole(accRole.Id, acc.Id, con1.Id);
		insert accountContactRole;

		ICG_Contact_Role_Detail__c contactRoleDetail = CW_TestDataFactory.testICGContactRoleDetail(accountContactRole.Id, accRoleDetail.Id);
		contactRoleDetail.Account_Role__c = accRole.Id;
		contactRoleDetail.Contact_Role_Remove_Requestor__c = testUser.Id;
		insert contactRoleDetail;
		
		Product2 prd = new Product2(Name = 'TestVeh', IsActive = true, CurrencyIsoCode = 'CLP', Smart_Facility_Remote_Validation__c = True);
		insert prd;

		Pricebook2 standardPB = new Pricebook2(Id = Test.getStandardPricebookId());
		
		PricebookEntry pricebookEntry = new PricebookEntry(IsActive = true, Product2Id = prd.Id, UnitPrice = 10600000, Pricebook2Id = standardPB.Id);
		insert pricebookEntry;
		
		Order testOrder = new Order(AccountId = acc.Id, EffectiveDate = System.today().addDays(1), Status = 'New', Pricebook2Id = standardPB.Id);
		insert testOrder;

		OrderItem testOrderItem = new OrderItem(OrderId = testOrder.Id, PricebookEntryId = pricebookEntry.Id, UnitPrice= 100, Quantity = 2, Station__c = accRoleDetail.Id);
		insert testOrderItem;
		
		Id remoteValidationRtId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');
		Id ardId = [SELECT Id FROM ICG_Account_Role_Detail__c Limit 1].Id;
		List<Order> currentOrder = [SELECT Id, (SELECT Id FROM Orderitems WHERE Station__c != null AND Product2.Smart_Facility_Remote_Validation__c = true) FROM Order];
		
		ICG_Capability_Assignment_Group__c assigmentGroup = new ICG_Capability_Assignment_Group__c();
		assigmentGroup.Expiration_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup.Issue_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup.GxA_Result_Json__c = '{"SubmittedDate": "2020-05-20T11:07:43.013Z","SalesforceCaseNumber": "09991143","Files": [{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/TA UI Screens_9ea59f93-656f-48c7-a31b-b905013c2002.pdf"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/Lufthansa SF16_291c5153-4adc-48a6-a348-b119b19a307e.pdf"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/1000770-09991143-50.pdf"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/2020-04-02_152038_e2a63e09-4c75-4efa-9935-c070412fe727.png"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/Lufthansa SF16_74dfd987-5e05-4aa0-b7d6-68c96d129897.pdf"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/2020-04-02_152022_3b45dc1e-5b7f-4a75-a08b-3be359dbb867.jpg"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/2020-04-02_152022_729f11a2-99f1-40e2-9a8d-48218c21748e.jpg"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/Lufthansa SF18_b5596511-ec07-48fb-91bc-5f94c285cba3.pdf"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/Cold Rooms 2 to 25_41.pdf"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/SF_Ecllipse14_1000770_1000770-09991143-50_IATA_Cargo_v13_General_Information22_05_2020.json"}]}';
		assigmentGroup.ICG_Account_Role_Detail__c = ardId;
		assigmentGroup.RecordTypeId = remoteValidationRtId;
		assigmentGroup.Order_Product__c = currentOrder[0].OrderItems[0].Id;
		insert assigmentGroup;
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			23 / 09 / 2020
	 * @description		Test  integrationQueueable class
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void integrationQueueableTest(){   
		List<Id> orderLst = new List<Id>();
		for(Order currentOrder : [SELECT Id FROM Order]){
			orderLst.add(currentOrder.Id);
		}                
		// Set mock callout class	
		Test.setMock(HttpCalloutMock.class, new CW_AmazonMockHttpResponseGenerator('IntegrationQueuable', 'OK'));  
		CW_GxA_Integration_Queueable queuable = new CW_GxA_Integration_Queueable(orderLst);
		
		Test.startTest();            
			System.enqueueJob(queuable);                 		
		Test.stopTest();        
	}
	
}