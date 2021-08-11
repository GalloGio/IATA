@isTest
private class ISSP_AMS_MSO_Controller_Test {

	@isTest static void test_method() {
		Id conRtId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Contact', 'Standard_Contact');
		Id accRtId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account', 'IATA_Airline');
		Id agcRtId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account', 'IATA_Agency');

		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
		insert isoc;

		List<Account> accountList = TestDataFactory_Accounts.createDefaultAccounts(4);

		Account acc = accountList.get(0);
		acc.RecordTypeId = accRtId;
		acc.Name = 'Airline HQ';
		acc.IATACode__c = '012';
		acc.Airline_designator__c = 'HQ';

		Account agencyM =  accountList.get(1);
		agencyM.RecordTypeId = agcRtId;
		agencyM.Name = 'Agency';
		agencyM.Location_Class__c = 'M';
		agencyM.Status__c = 'Approved';

		Account agencyG =  accountList.get(2);
		agencyG.RecordTypeId = agcRtId;
		agencyG.Name = 'Agency';
		agencyG.Location_Class__c = 'G';
		agencyG.Status__c = 'Approved';

		Account agency2 =  accountList.get(3);
		agency2.RecordTypeId = agcRtId;
		agency2.Name = 'Agency2';
		agency2.Location_Class__c = 'G';
		agency2.Status__c = 'Approved';

		insert accountList;

		List<Contact> contactList = TestDataFactory_Contacts.createDefaultContact(acc.id,1);
		Contact con = contactList.get(0);
		con.Email = TestDataFactory_Contacts.DEFAULTEMAIL;
		con.RecordTypeId = conRtId;
		con.LastName = 'portalUser';
		con.FirstName = 'firstname';
		con.Phone = '123456789';
		con.User_Portal_Status__c = 'Approved User';
		insert contactList;

		AMS_Inspection__c app = new AMS_Inspection__c(Airline__c = acc.Id, Account__c = agencyM.Id);
		insert app;

		AMS_Inspection__c appG = new AMS_Inspection__c(Airline__c = acc.Id, Account__c = agencyG.Id);
		insert appG;

		AMS_Territory__c ter = new AMS_Territory__c(Appointment__c = app.Id, ISO_Country__c = isoc.Id);
		insert ter;

		AMS_Accreditation_Organization__c org = new AMS_Accreditation_Organization__c (Name = ISSP_AMS_MSO_Controller.IATAORGNAME);
		insert org;

		AMS_Inspection__c app2 = new AMS_Inspection__c(Airline__c = acc.Id, Account__c = agency2.Id, Accreditation_Endorsement_organisation__c = org.Id);
		insert app2;

		User newUser = TestDataFactory_Users.createPortalUsers(new List<Contact>{con}).get(0);
		insert newUser;
		con.OwnerId = newUser.Id;
		update con;

		Test.startTest();

		System.runAs(newUser){
			Test.setCurrentPage(Page.ISSP_AMS_MSO);
			ISSP_AMS_MSO_Controller ctrl = new ISSP_AMS_MSO_Controller();

			ctrl.searchText = 'dsd';
			ctrl.refreshMsoGsaList();

			ctrl.searchText = '';
			ctrl.refreshMsoGsaList();

			system.assertEquals(false, ctrl.hasNext);
			system.assertEquals(false, ctrl.hasPrevious);
			system.assertEquals(1, ctrl.pageNumber);

			system.assertEquals(5, ctrl.getselectOptionItems().size());

			ctrl.first();
			ctrl.last();
			ctrl.previous();
			ctrl.next();

			system.assertEquals('/ISSP_Homepage', ctrl.checkIfUserHasAccessToService().getUrl());

			Test.setCurrentPage(Page.ISSP_AMS_GSA);
			ctrl = new ISSP_AMS_MSO_Controller();

			ctrl.refreshMsoGsaList();

			ctrl.getCSVHeader();

			ctrl.getData();
			ctrl.ssc =new ApexPages.StandardSetController(new List<AMS_Inspection__c>{app});
			list<ISSP_AMS_MSO_Controller.AppointmentWrapper> a = ctrl.lstDisplayAccounts;
			Integer itotalPages = ctrl.totalPages;
		}
		Test.stopTest();
	}
}