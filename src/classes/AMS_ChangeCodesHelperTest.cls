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
		Account acc = [SELECT ID, Status__c, Location_Class__c from Account LIMIT 1];

		String JSONOscar = JSON.serialize(new Map<String, Object>{
			'Process__c' => AMS_Utils.VOLRELINQUISH,
			'Account__c' => acc.Id,
			'Termination_Date__c' => System.today()+30,
			'Change_Effective_as_of__c' => system.today(),
			'Business_Process__c' => 'AMS'
		});
		AMS_OSCAR__c oscar = (AMS_OSCAR__c)JSON.deserialize(JSONOscar, AMS_OSCAR__c.class);

		insert new Agency_Applied_Change_Code__c(Reason_code__c = '91', Reason_Description__c = 'ACCREDITED-MEET-STANDARDS', Account__c = acc.Id);

		List<Account> accounts = [SELECT ID, Status__c, Location_Class__c, (SELECT Id, Account__c, Reason_Code__c, Reason_Description__c, Bulletin_Information__c FROM Agencies_Applied_Change_codes__r) from Account LIMIT 1];
		Agency_Applied_Change_code__c aacc = accounts[0].Agencies_Applied_Change_codes__r[0];


		Test.startTest();

		AMS_utils.Container sanityCheck = AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.SANITYCHECK, oscar, accounts);
		AMS_utils.Container suspension = AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.SUSPENSION, oscar, accounts);
		AMS_utils.Container termination = AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.TERMINATION, oscar, accounts);


		AMS_utils.Container sanityCheckWithDrawal = AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.WITHDRAWAL, oscar, accounts);
		oscar.Suspension_result__c = AMS_Utils.PASSED;
		AMS_utils.Container suspensionWithdrawal = AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.WITHDRAWAL, oscar, accounts);
		acc.Status__c = AMS_Utils.ACC_S8_CHANGESPROCESSED;
		AMS_utils.Container suspensionWithdrawalChanges = AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.WITHDRAWAL, oscar, accounts);
		oscar.Termination_result__c = AMS_Utils.PASSED;
		AMS_utils.Container terminationWithdrawal = AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.WITHDRAWAL, oscar, accounts);

		Test.stopTest();

		System.assertEquals('VRR', sanityCheck.changeCodes[0].name);
		System.assertEquals('NOT', suspension.changeCodes[0].name);
		System.assertEquals('CLO', termination.changeCodes[0].name);
		System.assertEquals('VRW', sanityCheckWithDrawal.changeCodes[0].name);
		System.assertEquals('NTW', suspensionWithdrawal.changeCodes[0].name);
		System.assertEquals('REI', terminationWithdrawal.changeCodes[0].name);

		System.assertEquals(aacc.Reason_Code__c, suspensionWithdrawalChanges.changeCodes[0].reasonCode);
	}

    static testMethod void TestChangesCodesCreation() {


        List<Account> accountLst = [SELECT ID, Status__c, CNS_Agency__c from Account ];

        if(accountLst.isEmpty())
            System.assert(true,false);

		Test.startTest();

        if(accountLst.isEmpty())
            System.assert(true,false);

        Account acc1 = accountLst.get(0);
        Account acc2 = accountLst.get(0);

		AMS_OSCAR_JSON.ChangeCode changeCode1 = new AMS_OSCAR_JSON.ChangeCode();
		AMS_OSCAR_JSON.ChangeCode changeCode2 = new AMS_OSCAR_JSON.ChangeCode();

		changeCode1.name = 'CTA';
		changeCode1.reasonCode = 'Change data';
		changeCode1.memoText = 'Minor Changes';//createMemoText(accountChanges);
		changeCode1.reasonDesc  = 'Accredited-Meets Criteria.';
		changeCode1.status  = null;

		changeCode2.name = 'CAD';
		changeCode2.reasonCode = 'Change data';
		changeCode2.memoText = 'Minor Changes';//createMemoText(accountChanges);
		changeCode2.reasonDesc  = 'Accredited-Meets Criteria.';
		changeCode2.status  = null;

		AMS_ChangeCodesHelper.ObjectChange objChange1 = new AMS_ChangeCodesHelper.ObjectChange('Account','Name','new Value Name' ,'old Value Name' );
		AMS_ChangeCodesHelper.ObjectChange objChange2 = new AMS_ChangeCodesHelper.ObjectChange('Case','Name','new Value Name Case','old Value Name Case' );

		AMS_ChangeCodesHelper.ObjectChange objChange3 = new AMS_ChangeCodesHelper.ObjectChange('Account','Name2','new Value Name 2' ,'old Value Name 2' );
		AMS_ChangeCodesHelper.ObjectChange objChange4 = new AMS_ChangeCodesHelper.ObjectChange('Case','Name2','new Value Name Case 2','old Value Name Case 2' );

		List <AMS_ChangeCodesHelper.ObjectChange> objChangeList = new List <AMS_ChangeCodesHelper.ObjectChange>{objChange1,objChange2};

		AMS_ChangeCodesHelper.ObjectChangesStruct objChangeListStruct1 = new AMS_ChangeCodesHelper.ObjectChangesStruct(new List <AMS_ChangeCodesHelper.ObjectChange>{objChange1,objChange2});
		AMS_ChangeCodesHelper.ObjectChangesStruct objChangeListStruct2 = new AMS_ChangeCodesHelper.ObjectChangesStruct(new List <AMS_ChangeCodesHelper.ObjectChange>{objChange3,objChange4});


		AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_ChangeCodesHelper.ObjectChangesStruct> {objChangeListStruct1,objChangeListStruct2},
		                                          new List <AMS_OSCAR_JSON.ChangeCode> {changeCode1,changeCode2},new List<AMS_OSCAR__c>{null,null},
		                                          new List<Account> {acc1,acc2},
		                                          false);


        Test.stopTest();

        /*****************************/
        /******** Assert Equals ******/
        /*****************************/

        //System.assertEquals();


	}
}
