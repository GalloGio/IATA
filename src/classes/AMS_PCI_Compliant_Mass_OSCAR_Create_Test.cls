@isTest
private class AMS_PCI_Compliant_Mass_OSCAR_Create_Test {
	
	@isTest static void test_page() {
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
			RecordTypeId= AMS_Utils.RECTYPE_IATAAGENCY,
			Is_PCI_compliant__c = null,
			Location_Type__c = AMS_Utils.HO
			);
		agencylist.add(a1);
		insert agencylist;

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1_1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'testmauz1@testmauz1.com', BSP_CASS_Payment_contact__c = true, User_Portal_Status__c = 'Approved Admin');
		Contact co2 = new Contact(AccountId = a1.id, Firstname = 'teste2_2', Lastname='test2', Phone = '911111112', MobilePhone = '911111112', Email = 'test2mauz2@test2mauz2.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved Admin');
		
		List<Contact> cos = new List<Contact>{co1,co2}; 
		insert cos;

		User testUser1 = createPortalUser(co1);
		co1.OwnerId = testUser1.Id;
		update co1;

		User testUser2 = createPortalUser(co2);
		co2.OwnerId = testUser2.Id;
		update co2;


		Test.startTest();
		AMS_PCI_Compliant_Mass_OSCAR_CreationCtr ctrl = new AMS_PCI_Compliant_Mass_OSCAR_CreationCtr();

		ctrl.operation = 'PCI';
		ctrl.region = 'Americas';
		ctrl.selectedClasses.add(new SelectOption('P','P'));		

		System.assertEquals(1, ctrl.availableCountries.size());
		ctrl.selectedCountries = ctrl.availableCountries;

		System.assertEquals(4, ctrl.availableLocations.size());
		ctrl.selectedLocations = ctrl.availableLocations;

		ctrl.search();

		System.assert(!ctrl.tooMuchResults);
		System.assertEquals(1, ctrl.totalAccounts);
		ctrl.createOSCARs();

		Test.stopTest();
		ctrl.checkBatchStatus();

		for(Integer i = 0; i < 50; i++)
			ctrl.allErrorMessages.add(new AMS_PCI_Compliant_Mass_OSCAR_CreationCtr.jsonError());


		ctrl.setErrorToShow();
		ctrl.Beginning();
		ctrl.Next();
		ctrl.End();
		ctrl.Previous();
		ctrl.getDisablePrevious();
		ctrl.getDisableNext();
		ctrl.getTotal_size();
		ctrl.getPageNumber();
		ctrl.getTotalPages();

	}

	    public static User createPortalUser(Contact con) {
	        String orgId = UserInfo.getOrganizationId();
	        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
	        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
	        String uniqueName = orgId + dateString + con.Firstname;
	        String conId15 = con.Id;
			//conId15 = conId15.substring(0,15);
	        String UserNameStr=uniqueName+ string.valueof(randomInt) + '@test' + orgId + '.org';
	        String ComNickNameStr=con.email.substring(0, con.email.indexOf('@'))+randomInt;//Datetime.now().formatLong().substring(10,15);
	        system.debug('basto1p TEST UserName='+UserNameStr);
	        system.debug('basto1p TEST ComNickNameStr='+ComNickNameStr);
	       User newUser = new User(alias = 'dsfsdfds', 
	                                email = con.email, 
	                                emailencodingkey = 'UTF-8', 
	                                firstname = con.firstName, 
	                                lastname = con.lastname, 
	                                languagelocalekey = 'en_US', 
	                                localesidkey = 'en_US', 
	                                contactId = con.Id,
	                                FederationIdentifier = conId15,
	                                timezonesidkey = 'Asia/Dubai',
	                                Username = con.Email,
	                                PortalRole = 'Manager',
	                                CommunityNickname = ComNickNameStr,
	                                ProfileId = ISSP_Constant.TEST_User_ProfileID,
	                                IsActive = true);
	        insert newUser;
	        return newUser;
	    }

}