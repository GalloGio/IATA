/*************************************************************************************************************
 * @name			CW_EmailTemplateDataTest
 * @author			Bea <beatriz.menendez@next-link.ch>
 * @created			22 / 09 / 2020
 * @description		Test class for CW_EmailTemplateData class
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2020-09-22		Bea						Test creation
 *
**************************************************************************************************************/
@isTest
public with sharing class CW_EmailTemplateDataTest {
	@testSetup 
	static void setup() {
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
		
		Product2 prd = new Product2(Name = 'TestVeh', IsActive = true, CurrencyIsoCode = 'CLP');
		insert prd;

		Pricebook2 standardPB = new Pricebook2(Id = Test.getStandardPricebookId());
		
		PricebookEntry pricebookEntry = new PricebookEntry(IsActive = true, Product2Id = prd.Id, UnitPrice = 10600000, Pricebook2Id = standardPB.Id);
		insert pricebookEntry;
		
		Order testOrder = new Order(AccountId = acc.Id, EffectiveDate = System.today().addDays(1), Status = 'New', Pricebook2Id = standardPB.Id);
		insert testOrder;

		OrderItem testOrderItem = new OrderItem(OrderId = testOrder.Id, PricebookEntryId = pricebookEntry.Id, UnitPrice= 100, Quantity = 2);
		insert testOrderItem;

		ICG_Certification__c certi = CW_TestDataFactory.newCertification();
		insert certi;
 
		ICG_Capability_Assignment_Group__c capabilityGroup = CW_TestDataFactory.createIcgCapabilityAssignmentGroupCertification(accRoleDetail.Id, certi.Id);
		insert capabilityGroup;
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			22 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getRequestedByCompanyAddress 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getRequestedByCompanyAddressTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();
		emailCtrl.contactRoleDetailId = [SELECT Id FROM ICG_Contact_Role_Detail__c LIMIT 1].Id;

		Test.startTest();
			String requestedAddress = emailCtrl.getRequestedByCompanyAddress();
		Test.stopTest();

		System.assertEquals('Test Street, 000000, Madrid, Spain', requestedAddress,'CW_EmailTemplateDataTest wrong requestedAddress: ' + requestedAddress);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			22 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getStationManagersContactRoleDetails 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getStationManagersContactRoleDetailsTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();

		Test.startTest();
			List<ICG_Contact_Role_Detail__c> managersContactRoleDetailsLst = emailCtrl.getStationManagersContactRoleDetails();
		Test.stopTest();

		System.assert(managersContactRoleDetailsLst.isEmpty(),'CW_EmailTemplateDataTest wrong managersContactRoleDetailsLst: ' + managersContactRoleDetailsLst);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			22 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getAccountToApproveUrl 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getAccountToApproveUrlTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();
		emailCtrl.stationId = [SELECT Id FROM ICG_Account_Role_Detail__c LIMIT 1].Id;

		Test.startTest();
			String approveURL = emailCtrl.getAccountToApproveUrl();
		Test.stopTest();
		
		String accId = [SELECT Id FROM Account LIMIT 1].Id;
		System.assertEquals('null' + accId, approveURL,'CW_EmailTemplateDataTest wrong approveURL: ' + approveURL);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			22 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getContactRoleDetailContactAccountAddress 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getContactRoleDetailContactAccountAddressTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();
		emailCtrl.contactRoleDetailId = [SELECT Id FROM ICG_Contact_Role_Detail__c LIMIT 1].Id;

		Test.startTest();
			String contactAccountAddress = emailCtrl.getContactRoleDetailContactAccountAddress();
		Test.stopTest();

		System.assertEquals('', contactAccountAddress,'CW_EmailTemplateDataTest wrong contactAccountAddress: ' + contactAccountAddress);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			22 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getDuplicatedStations 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getDuplicatedStationsTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();

		Test.startTest();
			List<ICG_Account_Role_Detail__c> duplicatedList = emailCtrl.getDuplicatedStations();
		Test.stopTest();

		System.assertEquals(null, duplicatedList,'CW_EmailTemplateDataTest wrong duplicatedList value: ' + duplicatedList);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			22 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getOperationalHierarchyFromRequestor 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getOperationalHierarchyFromRequestorTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();

		Test.startTest();
			String operationalHierarchy = emailCtrl.getOperationalHierarchyFromRequestor();
		Test.stopTest();

		System.assertEquals('N/A', operationalHierarchy,'CW_EmailTemplateDataTest wrong operationalHierarchy: ' + operationalHierarchy);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			22 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getOperationalHierarchyFromCrdOrStation 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getOperationalHierarchyFromCrdOrStationTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();

		Test.startTest();
			String operationalHierarchy = emailCtrl.getOperationalHierarchyFromCrdOrStation();
		Test.stopTest();

		System.assertEquals('N/A', operationalHierarchy,'CW_EmailTemplateDataTest wrong operationalHierarchy: ' + operationalHierarchy);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			22 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getApproveUrl 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getApproveUrlTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();

		Test.startTest();
			String approveUrl = emailCtrl.getApproveUrl();
		Test.stopTest();

		System.assertEquals('https://theurl.com/s/private-area', approveUrl,'CW_EmailTemplateDataTest wrong approveUrl: ' + approveUrl);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			22 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getRejectUrl 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getRejectUrlTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();

		Test.startTest();
			String rejectUrl = emailCtrl.getRejectUrl();
		Test.stopTest();

		System.assertEquals('https://theurl.com/s/private-area', rejectUrl,'CW_EmailTemplateDataTest wrong rejectUrl: ' + rejectUrl);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			22 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getStationUrl 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getStationUrlTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();

		Test.startTest();
			String stationUrl = emailCtrl.getStationUrl();
		Test.stopTest();

		System.assertEquals('https://theurl.com/s/private-area/#ID:', stationUrl,'CW_EmailTemplateDataTest wrong stationUrl: ' + stationUrl);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			22 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getPublicStationUrl 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getPublicStationUrlTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();

		Test.startTest();
			String publicStationUrl = emailCtrl.getPublicStationUrl();
		Test.stopTest();

		System.assertEquals('https://theurl.com/s/station-profile', publicStationUrl,'CW_EmailTemplateDataTest wrong publicStationUrl: ' + publicStationUrl);        
	}
 
	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			22 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getManageCompanyAdminsUrl 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getManageCompanyAdminsUrlTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();

		Test.startTest();
			String companyAdminUrl = emailCtrl.getManageCompanyAdminsUrl();
		Test.stopTest();
		
		System.assert(companyAdminUrl.contains('#Company%20Admins'),'CW_EmailTemplateDataTest wrong companyAdminUrl: ' + companyAdminUrl);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			22 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getIataManageRequest 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getIataManageRequestTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();
		emailCtrl.contactRoleDetailId = [SELECT Id FROM ICG_Contact_Role_Detail__c LIMIT 1].Id;

		Test.startTest();
			String iataManageReq = emailCtrl.getIataManageRequest();
		Test.stopTest();

		System.assertEquals('null' + emailCtrl.contactRoleDetailId, iataManageReq,'CW_EmailTemplateDataTest wrong iataManageReq: ' + iataManageReq);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			23 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getCompanyAdminContacts 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getCompanyAdminContactsTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();
		emailCtrl.stationId = [SELECT Id FROM ICG_Account_Role_Detail__c LIMIT 1].Id;

		Test.startTest();
			List<Contact> contactLst = emailCtrl.getCompanyAdminContacts();
		Test.stopTest();

		System.assert(contactLst.isEmpty(),'CW_EmailTemplateDataTest wrong contactLst: ' + contactLst);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			23 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getApproverAddress 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getApproverAddressTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();
		emailCtrl.stationId = [SELECT Id FROM ICG_Account_Role_Detail__c LIMIT 1].Id;

		Test.startTest();
			String approverAddress = emailCtrl.getApproverAddress();
		Test.stopTest();

		System.assertEquals('', approverAddress,'CW_EmailTemplateDataTest wrong approverAddress: ' + approverAddress);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			23 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getContactRoleDetailUserAddress 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getContactRoleDetailUserAddressTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();
		emailCtrl.contactRoleDetailId = [SELECT Id FROM ICG_Contact_Role_Detail__c LIMIT 1].Id;

		Test.startTest();
			String contactRoleAddress = emailCtrl.getContactRoleDetailUserAddress();
		Test.stopTest();

		System.assertEquals('', contactRoleAddress,'CW_EmailTemplateDataTest wrong contactRoleAddress: ' + contactRoleAddress);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			23 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getApproverOpsHierarchy 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getApproverOpsHierarchyTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();
		emailCtrl.contactRoleDetailId = [SELECT Id FROM ICG_Contact_Role_Detail__c LIMIT 1].Id;

		Test.startTest();
			String approverHierarchy = emailCtrl.getApproverOpsHierarchy();
		Test.stopTest();

		System.assertEquals('', approverHierarchy,'CW_EmailTemplateDataTest wrong approverHierarchy: ' + approverHierarchy);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			23 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getRemoteValidationLink 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getRemoteValidationLinkTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();
		emailCtrl.isPurchaseRemoteValidation = True;

		Test.startTest();
			String remoteLink = emailCtrl.getRemoteValidationLink();
		Test.stopTest();

		System.assertEquals('https://theurl.com/s/private-area#Purchase%20Remote%20Validation', remoteLink,'CW_EmailTemplateDataTest wrong remoteLink: ' + remoteLink);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			23 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getRemoteValidationLink 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getRemoteValidationURLTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();
		emailCtrl.isPurchaseRemoteValidation = False;

		Test.startTest();
			String remoteURL = emailCtrl.getRemoteValidationLink();
		Test.stopTest();

		System.assertEquals('https://theurl.com/s/private-area#Open%20Remote%20Validations', remoteURL,'CW_EmailTemplateDataTest wrong remoteURL: ' + remoteURL);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			23 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getCommunityUrl 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getCommunityUrlTest(){
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();

		Test.startTest();
			String communityURL = emailCtrl.getCommunityUrl();
		Test.stopTest();

		System.assertEquals('https://theurl.com/s/', communityURL,'CW_EmailTemplateDataTest wrong remoteURL: ' + communityURL);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			23 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getCommunityUrlForResources 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getCommunityUrlForResourcesTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();

		Test.startTest();
			String communityURL = emailCtrl.getCommunityUrlForResources();
		Test.stopTest();

		System.assertEquals('https://theurl.com/', communityURL,'CW_EmailTemplateDataTest wrong remoteURL: ' + communityURL);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			23 / 09 / 2020
	 * @description		Test CW_EmailTemplateData.getRejectReason 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getRejectReasonTest(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();
		emailCtrl.stationId = [SELECT Id FROM ICG_Account_Role_Detail__c LIMIT 1].Id;

		Test.startTest();
			String rejectedReason = emailCtrl.getRejectReason();
		Test.stopTest();
		
		System.assertEquals('No Reason Provided', rejectedReason,'CW_EmailTemplateDataTest wrong rejectedReason: ' + rejectedReason);        
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			02 / 10 / 2020
	 * @description		Test CW_EmailTemplateData.getRejectReason 
	 * @param			
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void getCertificationGroups(){        
		CW_EmailTemplateData emailCtrl = new CW_EmailTemplateData();
		emailCtrl.stationId = [SELECT Id FROM ICG_Account_Role_Detail__c LIMIT 1].Id;

		Test.startTest();
			List<ICG_Capability_Assignment_Group__c> ICGCapabilityGroups = emailCtrl.getICGCapabilityAssignmentGroups();
		Test.stopTest();
		
		System.assert(!ICGCapabilityGroups.isEmpty(),'CW_EmailTemplateDataTest list cannot be null: ' + ICGCapabilityGroups);        
	}
}