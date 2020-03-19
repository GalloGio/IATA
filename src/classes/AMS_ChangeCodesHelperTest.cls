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

				ID rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
				IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy', ANG_Enable_NewGen__c = true);
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
			'Form_Effective_Date__c' => system.today(),
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


				List<Account> accountLst = [SELECT ID, Status__c, CNS_Agency__c, ANG_IsNewGenAgency__c from Account ];

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

	@isTest
		public static void testGenerateFOPStringForChina() {

		Id accountAgencyRT =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		String changeCode = 'LSP';
		Boolean isNewgen = true;

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='China',ISO_Code__c='CN', ANG_Enable_NewGen__c = true,
			Region__c = 'Asia', BSP_Country_free_text__c = 'CN')  ;
				insert ctry ;

				Account chinaHE = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',
					Location_Type__c='HE', Name='Test1 Agency OK',Short_Name__c='Test1 Agency',
					Sector__c = 'Travel Agent', Location_Class__c = 'P');
				insert ChinaHE;

				Id formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');

		Agency_Authorization__c cashfop = new Agency_Authorization__c(Account__c = chinaHE.id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Authorized', RecordTypeId = formOfPaymentRT);
		insert cashfop;
		Agency_Authorization__c creditCardfop = new Agency_Authorization__c(Account__c = chinaHE.id, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Authorized', RecordTypeId = formOfPaymentRT);
		insert creditCardfop;
		Agency_Authorization__c bopMethod = new Agency_Authorization__c(Account__c = chinaHE.id, ANG_FormOfPayment_ID__c = 'BOP', Status__c = 'Authorized', RecordTypeId = formOfPaymentRT);
		insert bopMethod;

		List<Agency_Authorization__c> listAgencyAuth = [SELECT id, Authority__c, Status__c, ISO_Country__c FROM Agency_Authorization__c];

		Test.startTest();
		String formOfPayments = AMS_ChangeCodesHelper.generateFOPString(listAgencyAuth, isNewgen, changeCode);
		Test.stopTest();

		System.assertEquals('BOP - Cash - Credit Card: Authorized', formOfPayments);
	}
	
	@isTest
	public static void testChangesCodesCreationNewGenContext() {

		List<Account> accountLst = [SELECT ID, Status__c, CNS_Agency__c, ANG_IsNewGenAgency__c from Account ];

		Test.startTest();
			Account acc1 = accountLst.get(0);
			Account acc2 = accountLst.get(0);
			
			Id formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');
			Agency_Authorization__c cashfop = new Agency_Authorization__c(Account__c = acc1.id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Authorized', RecordTypeId = formOfPaymentRT);
			insert cashfop;
			Agency_Authorization__c creditCardfop = new Agency_Authorization__c(Account__c = acc1.id, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Authorized', RecordTypeId = formOfPaymentRT);
			insert creditCardfop;
			Agency_Authorization__c bopMethod = new Agency_Authorization__c(Account__c = acc1.id, ANG_FormOfPayment_ID__c = 'BOP', Status__c = 'Authorized', RecordTypeId = formOfPaymentRT);
			insert bopMethod;
			
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

		for (Agency_Applied_Change_code__c i : [Select id, Forms_Of_Payment__c From Agency_Applied_Change_code__c Where Account__c = :acc1.Id]){
			System.assertNotEquals('Not Applicable', i.Forms_Of_Payment__c, 'Form can not be Not Applicable on new gen context');
		}
	}

	@isTest
	public static void checkChangeCodeForRHCAlert(){

		//Mixed DML Operation without this System.runA
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert new EmailTemplate(
				isActive = true,
				Name = 'emailTemplate',
				DeveloperName = 'emailTemplate',
				TemplateType = 'text',
				FolderId = UserInfo.getUserId()
				);
		}
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		insert new User(FirstName = 'Test1 User', Division = 'UnitTest', License_Cost_Center__c = 'AAA000AA00', Username = 'test1@iata.org.amsdev1', LastName = 'Test1', Email = 'test1@iata.org', Alias = 'Test1', CommunityNickname = 'Test1', TimeZoneSidKey = 'Europe/Brussels', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US');

		insert new Notification_template__c (
			Subject__c = 'Some subject',
			Message__c = 'Some message',
			Type__c = 'Information',
			Notification_color__c = '#FF5E4D',
			Admins_Users__c = 'User',
			Expire_in_days__c = 0,
			Identifier__c = 'notification'
			);

		AMS_Settlement_System__c iss = new AMS_Settlement_System__c(Name = 'BSP-FR');
		insert iss;

		// Create a new ISO Country
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', CNS_Country__c=true, AMS_Settlement_System__c = iss.id, ANG_Enable_NewGen__c = true);
		IATA_ISO_Country__c defCountry = new IATA_ISO_Country__c(Name = 'All Countries', ISO_Code__c = ANG_RHCAlertTriggerHandler.DEFAULT_CODE, ANG_Enable_NewGen__c = true);
		insert new List<IATA_ISO_Country__c>{country, defCountry};

		// Create an Airline HQ account
		Account a = new Account(
			Name = 'acc1',
			Location_Type__c = 'HO',
			Location_Class__c = 'P',
			Remittance_frequency__c = 'M',
			ANG_Accreditation_Model__c = 'Cash',
			IATA_ISO_Country__c = country.Id,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeID('Account', 'IATA_Agency')
		);
		insert a;

		// create a reception case
		Case c = new Case(
			Subject = 'rception case',
			AccountId = a.Id,
			Status = 'Open',
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeID('Case', 'InternalCasesEuropeSCE')
		);
		insert c;


		ANG_RHC_Information__c rhcInfoIn = new ANG_RHC_Information__c(
			ANG_AccountId__c = a.Id,
			CurrencyIsoCode = 'USD',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			ANG_Financial_Security__c = 0
			);
		insert rhcInfoIn;

		// Create a new Financial Institution
		Financial_Institution__c fi = new Financial_Institution__c(
			Name = 'Test',
			Region__c = 'Europe',
			Country__c = 'Portugal',
			Institution_Type__c = 'Bank'
			);
		insert fi;

		Financial_Security__c fs = new Financial_Security__c(
			Region__c = 'Europe',
			Security_status__c = 'Active',
			Account__c = a.Id,
			CurrencyIsoCode = 'EUR',
			Security_Type__c = 'CCG',
			Amount__c = 100,
			Expiry_date__c = Date.today().addYears(2),
			Financial_Institution__c = fi.Id,
			ValIdity_Start_Date__c = Date.today().addDays(-2),
			Reception_Case__c = c.Id,
			Reception_Date__c = Date.today(),
			Reasonforrequest__c = 'New Application'
			);
		insert fs;

		AMS_Country_Specific_Attribute__c att = new AMS_Country_Specific_Attribute__c();
		att.IATA_ISO_Country__c = defCountry.Id;
		att.ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP;
		att.ANG_Percentage__c = '50%';
		att.ANG_Create_Process_Case__c = true;
		att.ANG_EmailTemplate_Legacy__c = 'emailTemplate';
		att.ANG_EmailTemplate_NG__c = 'emailTemplate';
		att.ANG_PortalNotificationTemplate__c = [SELECT Id, Name FROM Notification_template__c LIMIT 1].Name;
		att.RecordTypeId = ANG_RHCHelper.RECTYPE_RHCATTRIBUTE;
		insert att;



		List<AMS_ChangeCodes__c> changeCodeList = new List<AMS_ChangeCodes__c>{
			new AMS_ChangeCodes__c(
				Name = 'FOP', Change_Code__c = 'FOP', Integration_RecId__c = 'C',Bulletin_Memo_Text__c = 'Agent has complied to Agency Rules. Card payment methods are reinstated.'
				),
			new AMS_ChangeCodes__c(
				Name = 'PCA', Change_Code__c = 'PCA', Integration_RecId__c = 'C',Bulletin_Memo_Text__c = 'Agent has complied to Agency Rules. Cash and Card payment methods are reinstated.'
				),
			new AMS_ChangeCodes__c(
				Name = 'PCR', Change_Code__c = 'PCR', Integration_RecId__c = 'C',Bulletin_Memo_Text__c = 'Agent has complied to Agency Rules. Cash payment methods are reinstated.'
				),
			new AMS_ChangeCodes__c(
				Name = 'CCA', Change_Code__c = 'CCA', Integration_RecId__c = 'C',Bulletin_Memo_Text__c = 'Agent is restricted from using Card form of payment method due to <SIDRA Lite Reason>.'
				),
			new AMS_ChangeCodes__c(
				Name = 'CCR', Change_Code__c = 'CCR', Integration_RecId__c = 'C',Bulletin_Memo_Text__c = 'Agent is restricted from using Cash and Card payment methods due to <SIDRA Lite Reason>.'
				),
			new AMS_ChangeCodes__c(
				Name = 'FPR', Change_Code__c = 'FPR', Integration_RecId__c = 'C',Bulletin_Memo_Text__c = 'Agent is restricted from using Cash form of payment method due to <SIDRA Lite Reason>.'
				)
		};

		insert changeCodeList;

		List<String> listAirlineId = new List<String>();
		for (Profile profile: [SELECT Id FROM Profile WHERE Name LIKE 'ISS Portal Airline%']) {
			listAirlineId.add(profile.Id);
		}

		List<String> listAgencyId = new List<String>();
		for (Profile profile: [SELECT Id FROM Profile WHERE Name LIKE 'ISS Portal Agency%']) {
			listAgencyId.add(profile.Id);
		}

		List<ISSP_CS__c> listCs = new list<ISSP_CS__c>();
		listCs.add(new ISSP_CS__c(Name='ISS OperationalCalendar Airline Profil',Value__c=String.join(listAirlineId,',')));
		listCs.add(new ISSP_CS__c(Name='ISS OperationalCalendar Agency Profile',Value__c=String.join(listAgencyId,',')));
		insert listCs;

		ANG_RHC_Information__c rhcInfo=[SELECT Id,ANG_AccountId__c FROM ANG_RHC_Information__c LIMIT 1];

		List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();

		ID FormOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeID('Agency_Authorization__c', 'FormOfPayment');

		authorizations.add(new Agency_Authorization__c(Account__c = rhcInfo.ANG_AccountId__c, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));

		insert authorizations;

		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP,
			ANG_Threshold_Level__c = '100%'
			);

		insert ara;

		System.assertEquals(1,[SELECT ID, Forms_Of_Payment__c from Agency_Applied_Change_code__c where Account__c = :rhcInfo.ANG_AccountId__c and Forms_Of_Payment__c != 'Not Applicable'].Size());
	}
}