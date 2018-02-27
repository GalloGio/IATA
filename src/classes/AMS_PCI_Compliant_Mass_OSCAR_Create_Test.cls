@isTest
private class AMS_PCI_Compliant_Mass_OSCAR_Create_Test {
	
	@isTest static void test_method_one() {
		DateTime dt = system.now()+90;
		Date d = date.newinstance(dt.year(), dt.month(), dt.day());
		System.debug('d: ' + d);

		List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', 
															Region__c = 'Americas', 
															Case_BSP_Country__c= 'Canada'
															);
		countrylist.add(isoc1);
		insert countrylist;
		
		List<Account> agencylist = new List<Account>();
		Account a1 = new Account(Name='Test1 Agency',
			IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true, 
			IATACode__c = '12345678', 
			Location_Class__c= AMS_Utils.LC_PASSENGER,
			Status__c= AMS_Utils.ACC_S9_APPROVED,
			RecordTypeId= AMS_PCI_Compliant_Mass_OSCAR_CreationCtr.AGENCY_RECORDTYPE);
		agencylist.add(a1);
		insert agencylist;

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', BSP_CASS_Payment_contact__c = true, User_Portal_Status__c = 'Approved Admin');
		Contact co2 = new Contact(AccountId = a1.id, Firstname = 'teste2', Lastname='test2', Phone = '911111112', MobilePhone = '911111112', Email = 'test2@test.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved Admin');
		
		List<Contact> cos = new List<Contact>{co1,co2}; 
		insert cos;

		Test.startTest();
		AMS_PCI_Compliant_Mass_OSCAR_CreationCtr ctrl = new AMS_PCI_Compliant_Mass_OSCAR_CreationCtr();
		ctrl.searchPreview();
		ctrl.filter.region = 'Americas';
		ctrl.CountrySelected = ctrl.countryNameListSelectOption();
		ctrl.filter.country = new List<String> {isoc1.Id};
		ctrl.searchPreview();
		ctrl.createPCIOscar();
		AMS_PCI_Compliant_Mass_OSCAR_CreationCtr.AccountWrapper aw = new AMS_PCI_Compliant_Mass_OSCAR_CreationCtr.AccountWrapper(a1);
		aw.selected = true;
		ctrl.mapAccounts.put(a1.Id,aw);
		ctrl.createPCIOscar();
		ctrl.checkBatchStatus();
		ctrl.getApprovalButtonLabel();
		List<SelectOption> opts = ctrl.countryNameListSelectOption;
		ctrl.searchCases();
		ctrl.checkLogs();
		List<String> l1 = ctrl.countryList;
		List<AMS_PCI_Compliant_Mass_OSCAR_CreationCtr.AccountWrapper> l2 = ctrl.lstAccountsWrapper;
		Test.stopTest();
	}

	@isTest static void test_method_two() {
		Account a1 = new Account();
		Contact c1 = new Contact(User_Portal_Status__c= 'Approved Admin');
		Contact c2 = new Contact(Financial_Assessment_Contact__c= true);
		Contact c3 = new Contact(BSP_CASS_Payment_contact__c= true);
		List<Contact> contacts = new List<Contact> {c1, c2, c3};
		Map<String, List<Contact>> mapContacts = new Map<String, List<Contact>> {
			'Approved Admin' => new List<Contact>(),
			'Financial contact' => new List<Contact>(),
			'BSP Cass contact' => new List<Contact>()
		};
		Test.startTest();
		AMS_PCI_Compliant_Mass_OSCAR_CreationCtr.populateMapContacts(contacts, mapContacts);
		AMS_PCI_Compliant_Mass_OSCAR_CreationCtr.AccountWrapper aw1 = new  AMS_PCI_Compliant_Mass_OSCAR_CreationCtr.AccountWrapper(a1);
		aw1.setContact(c1);
		aw1.setContact(c2);
		aw1.setContact(c3);
		aw1.setCase(new Case());
		Test.stopTest();
	}	

}