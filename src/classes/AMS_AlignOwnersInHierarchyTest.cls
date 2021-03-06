@isTest
private class AMS_AlignOwnersInHierarchyTest {

	@testSetup static void setup(){

		Date myDate1 = Date.newInstance(2016, 2, 17);

		Id ownerRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');

		ID rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		IATA_ISO_Country__c portugal = new IATA_ISO_Country__c(Name='Portugal', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Portugal');
		insert portugal;

		// create test account1
		Account account1 = new Account(
								Name = 'Test account 1',
								IATACode__c = '1234567',
								Type = 'IATA Travel Agent',
								Sector__c = AMS_Utils.SECTOR_PASSENGER,
								Category__c = AMS_Utils.CATEGORY_TOUR_OPERATOR,
								BillingCity = 'Lisboa',
								BillingCountry = 'Portugal',
								BillingStreet = 'some street',
								Location_Type__c = 'HO',
								Accreditation_date__c = myDate1,
								recordTypeId = rtAgency,
								IATA_ISO_Country__c = portugal.Id,
								Location_Class__c = 'P',
								Purge_Flag__c = false
		);
		insert account1;

		AMS_Agencies_Hierarchy__c h1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'H1');
		insert h1;
		AMS_Agencies_Hierarchy__c h2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'H2');
		insert h2;

		// create test account2
		Account account2 = new Account(
								Name = 'Test account 2',
								IATACode__c = '1234789',
								Type = 'IATA Travel Agent',
								Sector__c = AMS_Utils.SECTOR_PASSENGER,
								Category__c = AMS_Utils.CATEGORY_TOUR_OPERATOR,
								BillingCity = 'Lisboa',
								BillingCountry = 'Portugal',
								BillingStreet = 'some street',
								Location_Type__c = 'HO',
								Accreditation_date__c = myDate1,
								recordTypeId = rtAgency,
								IATA_ISO_Country__c = portugal.Id,
								Location_Class__c = 'P',
								Purge_Flag__c = false
		);
		insert account2;

		// create test account3
		Account account3 = new Account(
								Name = 'Test account 3',
								IATACode__c = '12347890',
								Type = 'IATA Travel Agent',
								Sector__c = AMS_Utils.SECTOR_PASSENGER,
								Category__c = AMS_Utils.CATEGORY_TOUR_OPERATOR,
								BillingCity = 'Lisboa',
								BillingCountry = 'Portugal',
								BillingStreet = 'some street',
								Location_Type__c = 'HO',
								Accreditation_date__c = myDate1,
								recordTypeId = rtAgency,
								IATA_ISO_Country__c = portugal.Id,
								Location_Class__c = 'P',
								Purge_Flag__c = false
		);
		insert account3;

		List<Account> brAccounts = new List<Account>();

		//List<AMS_Agencies_relationhip__c> relations = new List<AMS_Agencies_relationhip__c>();

		for(integer i=0 ; i < 4 ; i++){

			Account acct = new Account(
								Name = 'Test account 2',
								IATACode__c = '123478'+i,
								Type = 'IATA Travel Agent',
								Sector__c = AMS_Utils.SECTOR_PASSENGER,
								Category__c = AMS_Utils.CATEGORY_TOUR_OPERATOR,
								BillingCity = 'Lisboa',
								BillingCountry = 'Portugal',
								BillingStreet = 'some street',
								Location_Type__c = 'BR',
								ParentId = account1.Id,
								Accreditation_date__c = myDate1,
								RecordTypeId = rtAgency,
								IATA_ISO_Country__c = portugal.Id,
								Location_Class__c = 'P',
								Purge_Flag__c = false
			);


			brAccounts.add(acct);
		}

		for(integer i=0 ; i < 4 ; i++){

			Account acct = new Account(
								Name = 'Test account 2',
								IATACode__c = '12347'+i+i,
								Type = 'IATA Travel Agent',
								Sector__c = AMS_Utils.SECTOR_PASSENGER,
								Category__c = AMS_Utils.CATEGORY_TOUR_OPERATOR,
								BillingCity = 'Lisboa',
								BillingCountry = 'Portugal',
								BillingStreet = 'some street',
								Location_Type__c = 'BR',
								ParentId = account2.Id,
								Accreditation_date__c = myDate1,
								RecordTypeId = rtAgency,
								IATA_ISO_Country__c = portugal.Id,
								Location_Class__c = 'P',
								Purge_Flag__c = false
			);
			brAccounts.add(acct);
		}


		system.debug('Will insert this accounts:' +brAccounts);

		insert brAccounts;

		List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();

		for(Account acct: brAccounts){

			AMS_Agencies_relationhip__c rel;

			if(acct.ParentId == account1.Id)
				rel = new AMS_Agencies_relationhip__c(Hierarchy__c = h1.Id, Parent_Account__c = account1.Id , Child_account__c = acct.Id);
			else
				rel = new AMS_Agencies_relationhip__c(Hierarchy__c = h2.Id, Parent_Account__c = account2.Id , Child_account__c = acct.Id);

				rels.add(rel);
		}

		insert rels;

		List<AMS_Account_Role__c> rolesToInsert = new List<AMS_Account_Role__c>();

		for(integer i=0 ; i < 4 ; i++){

			AMS_Account_Role__c acctRole = new AMS_Account_Role__c();
			acctRole.RecordTypeId = ownerRecTypeId;
			acctRole.Account__c = account1.Id;
			acctRole.Legacy_External_ID__c = '12345678'+i;
			acctRole.Owner_Name__c = 'NAME 12345678'+i;
			acctRole.Legacy_System__c = 'AIMS2';
			acctRole.Percentage__c = 25;
			rolesToInsert.add(acctRole);

		}

		for(integer i=0 ; i < 4 ; i++){

			AMS_Account_Role__c acctRole = new AMS_Account_Role__c();
			acctRole.RecordTypeId = ownerRecTypeId;
			acctRole.Account__c = account2.Id;
			acctRole.Owner_Name__c = 'NAME 1234567'+i+i;
			acctRole.Legacy_External_ID__c = '1234567'+i+i;
			acctRole.Legacy_System__c = 'AIMS2';
			acctRole.Percentage__c = 25;
			rolesToInsert.add(acctRole);
		}

		integer i = 0;

		for(Account acct : brAccounts){

			i++;
			AMS_Account_Role__c acctRole = new AMS_Account_Role__c();
			acctRole.RecordTypeId = ownerRecTypeId;
			acctRole.Account__c = acct.Id;
			acctRole.Owner_Name__c = 'NAME 1234567'+i+i;
			acctRole.Legacy_External_ID__c = '1234567'+i+i;
			acctRole.Legacy_System__c = 'AIMS2';
			acctRole.Percentage__c = 100;
			rolesToInsert.add(acctRole);

		}

		insert rolesToInsert;

		System.assertEquals(16,rolesToInsert.size());
	}

	@isTest static void test_method_one() {

		List<Account> acctsHO = [SELECT Id , Location_Type__c, ParentId from Account where Location_Type__c = 'HO'];

		Set<Id> accountsHoSet = new Set<Id>();

		for(Account acct: acctsHO)
			accountsHoSet.add(acct.Id);

		AMS_OSCAR__C oscar = new AMS_OSCAR__C(Account__c = acctsHO.get(0).Id);
		insert oscar;

		AMS_OSCAR__C oscar2 = new AMS_OSCAR__C(Account__c = acctsHO.get(1).Id);
		insert oscar2;

		List<Account> acctsChilds1 = [SELECT Id from Account where ParentId = :acctsHO.get(0).Id];

		Set<Id> acctsChilds1Set = new Set<Id>();

		for(Account acct: acctsChilds1)
			acctsChilds1Set.add(acct.Id);

		acctsChilds1Set.add(acctsHO.get(0).Id);

		List<AMS_Account_Role__c> rolesTest1 = [SELECT Id from AMS_Account_Role__c where Account__C in:acctsChilds1 and active__c = true];

		System.assertEquals(4,rolesTest1.size());


		List<Account> acctsChilds2 = [SELECT Id from Account where ParentId = :acctsHO.get(1).Id];

		Set<Id> acctsChilds1Set2 = new Set<Id>();

		List<AMS_Account_Role__c> rolesTest2 = [SELECT Id from AMS_Account_Role__c where Account__C in:acctsChilds2 and active__c = true];

		System.assertEquals(4,rolesTest2.size());

		for(Account acct: acctsChilds2)
			acctsChilds1Set2.add(acct.Id);

		acctsChilds1Set2.add(acctsHO.get(1).Id);

		Map<Id, Set<Id>> oscarAccounts = new  Map<Id, Set<Id>>();

		oscarAccounts.put(oscar.Id, acctsChilds1Set);


		System.assertEquals(false,AMS_HierarchyHelper.checkHierarchyIntegrity(oscarAccounts));

		oscarAccounts = new  Map<Id, Set<Id>>();
		oscarAccounts.put(oscar2.Id, acctsChilds1Set2);

		System.assertEquals(false,AMS_HierarchyHelper.checkHierarchyIntegrity(oscarAccounts));

		Test.startTest();

		AMS_AlignOwnersInHierarchy auxOwners = new AMS_AlignOwnersInHierarchy();

		auxOwners.parentAccountId = acctsHO.get(0).Id;

		auxOwners.alignOwnersInHierarchyByAccountId();

		auxOwners.checkBatchStatus();

		Test.stopTest();

		auxOwners.checkBatchStatus();

		List<AMS_Account_role__c> rolesFromAllAccounts = [Select Id from AMS_Account_role__c]; // should be 10 ...

		// 4 for each HO (8) and 4 for each of the accounts BR's (4*4*2)

		System.assertEquals(28,rolesFromAllAccounts.size());

		oscarAccounts = new  Map<Id, Set<Id>>();
		oscarAccounts.put(oscar.Id, acctsChilds1Set);


		System.assertEquals(true,AMS_HierarchyHelper.checkHierarchyIntegrity(oscarAccounts));

		oscarAccounts = new  Map<Id, Set<Id>>();
		oscarAccounts.put(oscar2.Id, acctsChilds1Set2);

		System.assertEquals(false,AMS_HierarchyHelper.checkHierarchyIntegrity(oscarAccounts));

	}

	@isTest static void test_method_three() {

		Test.startTest();

		AMS_AlignOwnersInHierarchy auxOwners = new AMS_AlignOwnersInHierarchy();

		Account acc = [Select Id from Account Where IATACode__c = '1234567' Limit 1];

		auxOwners.parentAccountId = acc.Id;

		auxOwners.alignOwnersInHierarchyByAccountId();

		Test.stopTest();

		List<AMS_Account_role__c> rolesFromAllAccounts = [Select Id from AMS_Account_role__c];

		// 4 for each HO (8) and 4 for each of the accounts BR's (4*4*2)

		System.assertEquals(28,rolesFromAllAccounts.size());
	}
}
