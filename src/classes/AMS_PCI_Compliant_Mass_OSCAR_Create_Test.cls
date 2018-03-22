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
			Location_Type__c = 'HO',
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
		ctrl.selectedLocationTypes.add(new SelectOption('HO', 'HO'));
		ctrl.CountrySelected = ctrl.countryNameListSelectOption();
		ctrl.filter.country = new List<String> {isoc1.Id};
		ctrl.searchPreview();
		ctrl.createPCIOscar();
		ctrl.checkLogs();
		ctrl.checkBatchStatus();
		Integer i = ctrl.srw.totalErrors;
		i = ctrl.srw.totalAccounts;
		List<SelectOption> opts = ctrl.countryNameListSelectOption;
		ctrl.getApprovalButtonLabel();
		Test.stopTest();
	}

}