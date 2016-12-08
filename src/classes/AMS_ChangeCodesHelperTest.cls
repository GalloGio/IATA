@isTest
private class AMS_ChangeCodesHelperTest {
	
	@testSetup 
	static void setup(){

		String SECTORPAX = 'Travel Agent';
		String CATEGORYPAX = 'IATA Passenger Sales Agent';
		String LOCCLASSPAX = 'P';

		String SECTORCASS = 'Cargo Agent';
		String CATEGORYCASS = 'IATA Cargo Sales Agent';
		String LOCCLASSCASS = 'C';

		String CHANGELOCATIONTYPE = 'Location type';
		String CHANGEOWNERSHIPIATA= 'Ownership to IATA Agent';
		String CHANGEOWNERSHIPNONIATA= 'Ownership to non-IATA Agent';

		Boolean isPax = true;

		ID rtAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
		IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
		insert italy;
		

	  
		Account HO1 = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATAcode__c = '1111110', IATA_ISO_Country__c = italy.id, 
						 Sector__c = (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'HO', Status__c = 'Approved',
						 Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com'
						 );
	  
		insert HO1;

		Account HO2 = new Account(RecordTypeId = rtAgency, Name = 'My Travels 2', IATAcode__c = '1111112', IATA_ISO_Country__c = italy.id, 
						 Sector__c = (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'HO', Status__c = 'Approved',
						 Short_Name__c = 'Short name 2 ', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe4.com'
						 );
	  
		insert HO2;
		


	}

	static testMethod void VR_Change_Codes() {
		List<Account> accountLst = [SELECT ID, Status__c, Location_Class__c from Account ];
		
		Account acc = accountLst.get(0);
		Set<Id> accountsInvolved = new Set<Id>{acc.Id};
		Map<Id, Account> accounts = new Map<Id, Account>{acc.Id => acc};

		AMS_OSCAR__c oscar = new AMS_Oscar__c(Process__c = AMS_Utils.VOLRELINQUISH, Account__c = acc.Id, Termination_Date__c = System.today()+30);

		Agency_Applied_Change_Code__c aacc = new Agency_Applied_Change_Code__c(Reason_code__c = '91', Reason_Description__c = 'ACCREDITED-MEET-STANDARDS');

		Map<Id, Agency_Applied_Change_Code__c> accountsChangeCode = new Map<Id, Agency_Applied_Change_Code__c>{acc.Id => aacc};

		Test.startTest();

		AMS_utils.Container sanityCheck = AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.SANITYCHECK, oscar, accountsInvolved, accounts, accountsChangeCode);
		AMS_utils.Container suspension = AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.SUSPENSION, oscar, accountsInvolved, accounts, accountsChangeCode);
		AMS_utils.Container termination = AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.TERMINATION, oscar, accountsInvolved, accounts, accountsChangeCode);


		AMS_utils.Container sanityCheckWithDrawal = AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.WITHDRAWAL, oscar, accountsInvolved, accounts, accountsChangeCode);
		oscar.Suspension_result__c = AMS_Utils.PASSED;
		AMS_utils.Container suspensionWithdrawal = AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.WITHDRAWAL, oscar, accountsInvolved, accounts, accountsChangeCode);
		acc.Status__c = AMS_Utils.ACC_S8_CHANGESPROCESSED;
		AMS_utils.Container suspensionWithdrawalChanges = AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.WITHDRAWAL, oscar, accountsInvolved, accounts, accountsChangeCode);
		oscar.Termination_result__c = AMS_Utils.PASSED;
		AMS_utils.Container terminationWithdrawal = AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.WITHDRAWAL, oscar, accountsInvolved, accounts, accountsChangeCode);

		Test.stopTest();

		System.assertEquals('VRR', sanityCheck.changeCodes[0].name);
		System.assertEquals('NOT', suspension.changeCodes[0].name);
		System.assertEquals('CLO', termination.changeCodes[0].name);
		System.assertEquals('VRW', sanityCheckWithDrawal.changeCodes[0].name);
		System.assertEquals('NTW', suspensionWithdrawal.changeCodes[0].name);
		System.assertEquals('REI', terminationWithdrawal.changeCodes[0].name);
		
		System.assertEquals(aacc.Reason_Code__c, suspensionWithdrawalChanges.changeCodes[0].reasonCode);
	}
}