@isTest
private class ANG_HierarchyTriggerTest {

	@isTest static void ANG_HierarchyTriggerTestValidateRT() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US',ANG_Enable_NewGen__c=true)  ;
		insert ctry ;

		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HE',Name='Agency HE',Short_Name__c='Agency HE', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

		insert new List<Account>{a1};

		AMS_Agencies_Hierarchy__c hierarchyPreEmpty0 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');
		AMS_Agencies_Hierarchy__c hierarchyPreEmpty1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchyPreEmpty0,hierarchyPreEmpty1};

		//Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1', Main_account__c = a1.Id);
		AMS_Agencies_Hierarchy__c hierarchy2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 2');

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy,hierarchy2};

		Test.startTest();

		AMS_Agencies_Hierarchy__c hToConfirm = [Select ID , RecordTypeId from AMS_Agencies_Hierarchy__c].get(0);

		Id rtMain = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Agencies_Hierarchy__c', 'MAIN');

		System.assertEquals(rtMain, hToConfirm.recordTypeId,'There hierarchy should have the record type ' +rtMain );

		Test.stopTest();

	}

	@isTest static void ANG_HierarchyTriggerTestValidateUniqueness() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US',ANG_Enable_NewGen__c=true)  ;
		insert ctry ;

		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HE',Name='Agency HE',Short_Name__c='Agency HE', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

		insert new List<Account>{a1};

		//Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1', Main_account__c = a1.Id);

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy};

		Test.startTest();

		//Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 2', Main_account__c = a1.Id);

		try{

			insert new list<AMS_Agencies_Hierarchy__c>{hierarchy2};

		}catch(Exception e){
			Boolean expectedExceptionThrown =  e.getMessage().contains('There can be only one Hierarchy with the Main Account ' + a1.Id) ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
			return;
		}

		System.assertEquals(true,false);

		Test.stopTest();

	}

	@isTest static void ANG_HierarchyTriggerTestValidateUniqueness2() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US',ANG_Enable_NewGen__c=true)  ;
		insert ctry ;

		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HE',Name='Agency HE',Short_Name__c='Agency HE', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
		Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='HE',Name='Agency HE',Short_Name__c='Agency HE', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

		insert new List<Account>{a1,a2};

		//Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1', Main_account__c = a1.Id);
		AMS_Agencies_Hierarchy__c hierarchy2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 2', Main_account__c = a2.Id);

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy1,hierarchy2};

		Test.startTest();

		try{

			hierarchy2.Main_account__c = a1.Id;
			update hierarchy2;

		}catch(Exception e){
			Boolean expectedExceptionThrown =  e.getMessage().contains('There can be only one Hierarchy with the Main Account ' + a1.Id) ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
			return;
		}

		System.assertEquals(true,false);

		Test.stopTest();

	}

	@isTest static void ANG_HierarchyTriggerTestValidateUniqueness3() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US',ANG_Enable_NewGen__c=true)  ;
		insert ctry ;

		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HE',Name='Agency HE',Short_Name__c='Agency HE', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
		Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='HE',Name='Agency HE',Short_Name__c='Agency HE', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

		insert new List<Account>{a1,a2};

		//Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1', Main_account__c = a1.Id);
		AMS_Agencies_Hierarchy__c hierarchy2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 2', Main_account__c = a2.Id);

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy1,hierarchy2};

		Test.startTest();

		hierarchy2.Main_account__c = a1.Id;
		hierarchy1.Main_account__c = a2.Id;

		update new list<AMS_Agencies_Hierarchy__c>{hierarchy1,hierarchy2};

		Test.stopTest();

	}

	@isTest static void ANG_HierarchyTriggerTestValidateUniqueness4() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US',ANG_Enable_NewGen__c=true)  ;
		insert ctry ;

		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HE',Name='Agency HE',Short_Name__c='Agency HE', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
		Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='HE',Name='Agency HE',Short_Name__c='Agency HE', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
		Account a3 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='HE',Name='Agency HE',Short_Name__c='Agency HE', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

		insert new List<Account>{a1,a2,a3};

		//Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1', Main_account__c = a1.Id);
		AMS_Agencies_Hierarchy__c hierarchy2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 2', Main_account__c = a2.Id);

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy1,hierarchy2};

		Test.startTest();

		boolean validated = false;

		try{

			AMS_Agencies_Hierarchy__c hierarchy3 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1', Main_account__c = a3.Id);
			AMS_Agencies_Hierarchy__c hierarchy4 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 2', Main_account__c = a1.Id);

			insert new list<AMS_Agencies_Hierarchy__c>{hierarchy3,hierarchy4};

		}catch(Exception e){
			Boolean expectedExceptionThrown =  e.getMessage().contains('There can be only one Hierarchy with the Main Account ' + a1.Id) ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
			validated = true;

		}

		System.AssertEquals(validated, true);

		try{

			AMS_Agencies_Hierarchy__c hierarchy5 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1', Main_account__c = a1.Id);
			AMS_Agencies_Hierarchy__c hierarchy6 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 2', Main_account__c = a1.Id);

			insert new list<AMS_Agencies_Hierarchy__c>{hierarchy5,hierarchy6};

		}catch(Exception e){
			Boolean expectedExceptionThrown =  e.getMessage().contains('There can be only one Hierarchy with the Main Account ' + a1.Id) ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
			return;
		}

		System.assertEquals(true,false);

		Test.stopTest();

	}

	@isTest static void ANG_HierarchyTriggerTestValidateUniqueness5() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US',ANG_Enable_NewGen__c=true)  ;
		insert ctry ;

		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HE',Name='Agency HE',Short_Name__c='Agency HE', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
		Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='HE',Name='Agency HE',Short_Name__c='Agency HE', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
		Account a3 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='HE',Name='Agency HE',Short_Name__c='Agency HE', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

		insert new List<Account>{a1,a2,a3};

		//Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1', Main_account__c = a1.Id);
		AMS_Agencies_Hierarchy__c hierarchy2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 2', Main_account__c = a2.Id);

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy1,hierarchy2};

		Test.startTest();


		try{

			hierarchy1.Main_account__c = a3.Id;
			hierarchy2.Main_account__c = a3.Id;

			update new list<AMS_Agencies_Hierarchy__c>{hierarchy1,hierarchy2};

		}catch(Exception e){
			Boolean expectedExceptionThrown =  e.getMessage().contains('There can be only one Hierarchy with the Main Account ' + a3.Id) ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
			return;
		}

		System.assertEquals(true,false);

		Test.stopTest();

	}

}
