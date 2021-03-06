@isTest
public with sharing class DAL_WithoutSharingTest {

	public static testMethod void DAL_WithoutSharingTest(){

		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

		Portal_Applications__c easyPay1 = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		easyPay1.Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED;
		easyPay1.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		easyPay1.ANG_Accredited_Agents_Only__c = false;
		easyPay1.Agency__c = true;

		insert easyPay1;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c (
				Name = 'Portugal_test',
				ISO_Code__c = 'PT',
				ANG_Portal_Service__c = easyPay1.id,
				ANG_Enable_NewGen__c = true
			);

		insert country;

		Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account parent = ISSP_ObjectFactory.createNewAccount();
		parent.BillingCity = 'test';
		parent.Name = 'test';
		parent.sector__c = 'Travel Agent';
		parent.Location_Type__c = 'HO';
		parent.RecordTypeId = rtIdBr;
		parent.IATACode__c = '100';
		parent.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASHLESS;
		insert parent;

		Account child = ISSP_ObjectFactory.createNewAccount();
		child.BillingCity = 'GB';
		child.Name = 'GB';
		child.Site = 'headSite';
		child.sector__c = 'Travel Agent';
		child.Top_Parent__c = parent.Id;
		child.IATAcode__c = '1234567';
		child.IATA_ISO_Country__c = country.Id;
		child.RecordTypeId = rtIdBr;
		child.ANG_IEP_Status__c = 'No IEP Account';
		child.Location_Type__c = 'HE';
		child.Location_Class__c = 'P';
		child.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASHLESS;
		insert child;

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId = child.Id;
		con.Email = 'Test@test11.com';
		con.User_Portal_Status__c = 'Approved Admin';
		insert con;

		User newUser = ISSP_ObjectFactory.createPortalUser(con);

		con.OwnerId = newUser.Id;
		update con;

		Map<String,String> newMap = new Map<String,String>();
		Test.startTest();
		System.runAs(newUser) {
			String result = DAL_WithoutSharing.performCheckonPoll('IEP_EdenRed', 0);
			PortalProfileCtrl.CompanyInformationContactsFiltersWrapper searchwrapper = new PortalProfileCtrl.CompanyInformationContactsFiltersWrapper();
			searchwrapper.sortField='name';
			searchwrapper.sortDirection='ASC';
			searchwrapper.searchInput='test';
			searchwrapper.firstLetter='A';

			string searchkey=JSON.serialize(searchwrapper);
			CSP_Utils.PagedResult searchResult= DAL_WithoutSharing.searchForCompanyContacts(searchkey,0,5,child.id);
			newMap = DAL_WithoutSharing.getUserOptions(newUser.id);
			system.AssertEquals(DAL_WithoutSharing.hasAccessToService('asd',con.id),false);
		}

		Test.stopTest();
	}
}
