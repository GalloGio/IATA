@isTest
private class ANG_RHCAlertTriggerHandler_test {

	@testSetup static voId setup(){
		
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert new EmailTemplate(
				isActive = true,
				Name = 'emailTemplate',
				DeveloperName = 'emailTemplate',
				TemplateType = 'text',
				FolderId = UserInfo.getUserId()
				);
		}

		insert new Notification_template__c (
			Subject__c = 'Some subject',
			Message__c = 'Some message',
			Type__c = 'Information',
			Notification_color__c = '#FF5E4D',
			Admins_Users__c = 'User',
			Expire_in_days__c = 0,
			Identifier__c = 'notification'
			);
		
		// Create a new ISO Country
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', CNS_Country__c=true);
		IATA_ISO_Country__c defCountry = new IATA_ISO_Country__c(Name = 'All Countries', ISO_Code__c = ANG_RHCAlertTriggerHandler.DEFAULT_CODE);
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

		Agency_Applied_Change_code__c agencyAppliedCC = new Agency_Applied_Change_code__c(
			Account__c = a.Id,
			Reason_Code__c = '11',
			Reason_Description__c = 'CODE ASSIGNED',
			Bulletin_Information__c = 'test test test',
			Active__c = true
			);
		insert agencyAppliedCC;

		// create a reception case
		Case c = new Case(
			Subject = 'rception case', 
			AccountId = a.Id, 
			Status = 'Open', 
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeID('Case', 'InternalCasesEuropeSCE') 
		);
		insert c;


		ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
			ANG_AccountId__c = a.Id,
			CurrencyIsoCode = 'USD',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			ANG_Financial_Security__c = 0
			);
		insert rhcInfo;

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
	}

	private static testmethod void test_sucess_legacy(){

		Test.startTest();

		Contact contact = new Contact(
			FirstName = 'test',
			LastName = 'test', 
			AccountId = [SELECT Id FROM Account][0].Id,
			User_Portal_Status__c = ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM,
			email = 'testiata@yopmail.com'
			);
		insert contact;

		ISSP_ObjectFactory.createPortalUser(contact);

		ANG_RHC_Information__c rhcInfo=[SELECT Id,ANG_AccountId__c FROM ANG_RHC_Information__c LIMIT 1];
		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP,
			ANG_Threshold_Level__c = '50%'
			);

		String processRecorType = RecordTypeSingleton.getInstance().getRecordTypeID('Case', 'CS_Process_IDFS_ISS');

		System.assertEquals(0, [SELECT Id FROM Case WHERE RecordTypeId = :processRecorType].size(), 'No process should be created at this time');
		
		insert ara;


		System.assertEquals(1, [SELECT Id FROM Case WHERE RecordTypeId = :processRecorType].size(), 'There should one Process Case Created');
		Test.stopTest();

		System.assert([SELECT Id,ANG_email_sent__c FROM ANG_Risk_Alert__c LIMIT 1].get(0).ANG_email_sent__c,'Email was not sent');
	}

	private static testmethod voId test_sucess_newgen(){

		Test.startTest();

		IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'FR'];
		country.ANG_Enable_NewGen__c = true;
		update country;

		Contact contact = new Contact(
			FirstName = 'test',
			LastName = 'test', 
			AccountId = [SELECT Id FROM Account][0].Id,
			User_Portal_Status__c = ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM,
			email = 'testiata@yopmail.com'
			);
		insert contact;

		ISSP_ObjectFactory.createPortalUser(contact);

		Portal_Applications__c par = new Portal_Applications__c (Name = ANG_RHCHelper.RISK_PROFILE_AND_RHC_PORTAL_SERVICE);
		insert par;


		insert new Portal_Application_Right__c(Portal_Application__c = par.id, Right__c = 'Access Granted', Contact__c = contact.Id);


		ANG_RHC_Information__c rhcInfo=[SELECT Id,ANG_AccountId__c FROM ANG_RHC_Information__c LIMIT 1];
		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP,
			ANG_Threshold_Level__c = '50%'
			);

		insert ara;

		Test.stopTest();

		System.assert([SELECT Id,ANG_email_sent__c FROM ANG_Risk_Alert__c LIMIT 1].get(0).ANG_email_sent__c,'Email was not sent');
	}

	private static testmethod voId testRiskAlertCreationNoConfigurationMatched(){

		Test.startTest();
		ANG_RHC_Information__c rhcInfo=[SELECT Id,ANG_AccountId__c FROM ANG_RHC_Information__c LIMIT 1];
		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP,
			ANG_Threshold_Level__c = '88%' // no configuration exists with this percentage
			);

		insert ara;

		System.assert(![SELECT Id,ANG_email_sent__c FROM ANG_Risk_Alert__c LIMIT 1].get(0).ANG_email_sent__c,'Email was sent');
		Test.stopTest();
	}

/*
	private static testmethod voId testRestrictFOPonRiskAlertCreation(){

		Test.startTest();

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

		ANG_RHC_Information__c rhcInfo=[SELECT Id,ANG_AccountId__c FROM ANG_RHC_Information__c LIMIT 1];

		List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();

		ID FormOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');

		authorizations.add(new Agency_Authorization__c(Account__c = rhcInfo.ANG_AccountId__c, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
		authorizations.add(new Agency_Authorization__c(Account__c = rhcInfo.ANG_AccountId__c, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
		authorizations.add(new Agency_Authorization__c(Account__c = rhcInfo.ANG_AccountId__c, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));

		insert authorizations;

		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP,
			ANG_Threshold_Level__c = '100%'
		);

		insert ara;

		System.assertEquals(1,[SELECT ID from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA' and Status__c = 'Non-Active'].Size());
		System.assertEquals(1,[SELECT ID from Agency_Applied_Change_code__c where Account__c = :rhcInfo.ANG_AccountId__c and Change_Code__c = 'PCA' and Active__c = true].Size());

		Test.stopTest();


	}

	private static testmethod voId testRestoreFOPonRiskAlertCreation(){

		Test.startTest();

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

		ANG_RHC_Information__c rhcInfo=[SELECT Id,ANG_AccountId__c FROM ANG_RHC_Information__c LIMIT 1];

		List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();

		ID FormOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');

		authorizations.add(new Agency_Authorization__c(Account__c = rhcInfo.ANG_AccountId__c, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Non-Active', RecordTypeId = FormOfPaymentRT));
		authorizations.add(new Agency_Authorization__c(Account__c = rhcInfo.ANG_AccountId__c, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Non-Active', RecordTypeId = FormOfPaymentRT));
		authorizations.add(new Agency_Authorization__c(Account__c = rhcInfo.ANG_AccountId__c, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Non-Active', RecordTypeId = FormOfPaymentRT));

		insert authorizations;

		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN,
			ANG_Threshold_Level__c = '100%'
		);

		insert ara;

		System.assertEquals(1,[SELECT ID from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA' and Status__c = 'Active'].Size());
		System.assertEquals(1,[SELECT ID from Agency_Applied_Change_code__c where Account__c = :rhcInfo.ANG_AccountId__c and Change_Code__c = 'PCR' and Active__c = true].Size());

		Test.stopTest();


	}

	private static testmethod voId testRestoreFOPonRiskAlertCreation2(){

		Test.startTest();

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

		ANG_RHC_Information__c rhcInfo=[SELECT Id,ANG_AccountId__c FROM ANG_RHC_Information__c LIMIT 1];

		List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();

		ID FormOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');

		authorizations.add(new Agency_Authorization__c(Account__c = rhcInfo.ANG_AccountId__c, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Non-Active', RecordTypeId = FormOfPaymentRT));
		authorizations.add(new Agency_Authorization__c(Account__c = rhcInfo.ANG_AccountId__c, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Non-Active', RecordTypeId = FormOfPaymentRT));
		authorizations.add(new Agency_Authorization__c(Account__c = rhcInfo.ANG_AccountId__c, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Non-Active', RecordTypeId = FormOfPaymentRT));

		insert authorizations;

		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN,
			ANG_Threshold_Level__c = '50%'
		);

		insert ara;

		System.assertEquals(1,[SELECT ID from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA' and Status__c = 'Active'].Size());
		System.assertEquals(1,[SELECT ID from Agency_Applied_Change_code__c where Account__c = :rhcInfo.ANG_AccountId__c and Change_Code__c = 'PCR' and Active__c = true].Size());

		System.assertEquals('RHC Alert',[SELECT ID, Source__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA' and Status__c = 'Active'].get(0).Source__c);

		Test.stopTest();


	}
    
	
	private static testmethod voId testRestoreFOPonRiskAlertCreation3(){

		Test.startTest();

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

		ANG_RHC_Information__c rhcInfo=[SELECT Id,ANG_AccountId__c FROM ANG_RHC_Information__c LIMIT 1];

		List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();

		ID FormOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');

		authorizations.add(new Agency_Authorization__c(Account__c = rhcInfo.ANG_AccountId__c, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Non-Active', RecordTypeId = FormOfPaymentRT));
		authorizations.add(new Agency_Authorization__c(Account__c = rhcInfo.ANG_AccountId__c, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Non-Active', RecordTypeId = FormOfPaymentRT));
		authorizations.add(new Agency_Authorization__c(Account__c = rhcInfo.ANG_AccountId__c, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Non-Active', RecordTypeId = FormOfPaymentRT));

		insert authorizations;

		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN,
			ANG_Threshold_Level__c = '50%'
		);

		insert ara;

		System.assertEquals(0,[SELECT ID from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA' and Status__c = 'Active'].Size());
		System.assertEquals(0,[SELECT ID from Agency_Applied_Change_code__c where Account__c = :rhcInfo.ANG_AccountId__c and Change_Code__c = 'PCR' and Active__c = true].Size());

		//System.assertEquals(null,[SELECT ID, Source__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA'].get(0).Source__c);

		Test.stopTest();


	}
	*/


	private static void createScenario1(){

		/*
			SCENARIO 1: 
		- Accredited HE with accr. model = cash and FoP cash active 
		- A 100% UP risk alert is created so Cash FoP will be deactivated 
		- A 100% DOWN risk alert is created 

		EXPECTED RESULT 
		Cash will be restored 

		*/

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

		Agency_Authorization__c aa = [SELECT ID, Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA'];

		System.assertEquals('Non-Active', aa.Status__c);

		System.assertEquals(1,[SELECT ID from Agency_Applied_Change_code__c where Account__c = :rhcInfo.ANG_AccountId__c and Change_Code__c = 'PCA' and Active__c = true].Size());
		
		ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN,
			ANG_Threshold_Level__c = '100%'
			);

		insert ara;

		aa = [SELECT ID, Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA'];

		System.assertEquals('Active', aa.Status__c);

	}

	private static testmethod voId scenario2Test(){

		/*TEST SCENARIO 2: 
			
			- Accredited HE with accr. model = cash and FoP cash active 
			- A 100% UP risk alert is created so Cash FoP will be deactivated 
			- A 50% DOWN risk alert is created 

			EXPECTED RESULT 
			Cash will be restored 
			*/

			Test.startTest();

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

			Agency_Authorization__c aa = [SELECT ID, Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA'];

			System.assertEquals('Non-Active', aa.Status__c);

			System.assertEquals(1,[SELECT ID from Agency_Applied_Change_code__c where Account__c = :rhcInfo.ANG_AccountId__c and Change_Code__c = 'PCA' and Active__c = true].Size());

			ara = new ANG_Risk_Alert__c(
				ANG_RHC_Information__c = rhcInfo.Id,
				ANG_Account__c = rhcInfo.ANG_AccountId__c,
				ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN,
				ANG_Threshold_Level__c = '50%'
				);

			insert ara;

			aa = [SELECT ID,  Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA'];

			System.assertEquals('Active', aa.Status__c);


			Test.stopTest();

		}

		private static testmethod voId scenario3Test(){

		/*
		SCENARIO 3: 
		- Accredited HE with accr. model = cash and FoP cash active 
		- A 100% UP risk alert is created so Cash FoP will be deactivated 
		- A 75% DOWN risk alert is created 

		EXPECTED RESULT 
		Cash will be restored 
		*/

		Test.startTest();
		
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

		Agency_Authorization__c aa = [SELECT ID, Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA'];

		System.assertEquals('Non-Active', aa.Status__c);

		ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN,
			ANG_Threshold_Level__c = '75%'
			);

		insert ara;

		Agency_Applied_Change_code__c aacc = [SELECT ID, Active__c from Agency_Applied_Change_code__c where Account__c = :rhcInfo.ANG_AccountId__c and Change_Code__c = 'PCR'];

		//System.assertEquals(aacc.Active__c,true);

		aa = [SELECT ID,  Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA'];

		System.assertEquals('Active', aa.Status__c);

		Test.stopTest();

	}

	private static testmethod voId scenario4Test(){

		/*SCENARIO 4: 
		- Accredited HE with accr. model = cash and FoP cash active 
		- A FoP OSCAR case is created and processed to restrict cash 
		- A 100% DOWN risk alert is created 

		EXPECTED RESULT 
		Cash will NOT be restored 
		*/ 

		Test.startTest();

		ANG_RHC_Information__c rhcInfo=[SELECT Id,ANG_AccountId__c FROM ANG_RHC_Information__c LIMIT 1];

		List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();

		ID FormOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeID('Agency_Authorization__c', 'FormOfPayment');

		authorizations.add(new Agency_Authorization__c(Account__c = rhcInfo.ANG_AccountId__c, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));

		insert authorizations;

		AMS_OSCAR__c oscar = createOscarFOP();

		System.debug('OSCAR ::: ' + oscar);

		ANG_OscarProcessHelper.processRestrictFOP(oscar.Id, false ,true);

		Agency_Authorization__c aa = [SELECT ID, Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA'];

		System.assertEquals('Non-Active', aa.Status__c);

		System.assertEquals(1,[SELECT ID from Agency_Applied_Change_code__c where Account__c = :rhcInfo.ANG_AccountId__c and Change_Code__c = 'PCA' and Active__c = true].Size());
		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN,
			ANG_Threshold_Level__c = '100%'
			);

		insert ara;

		aa = [SELECT ID, Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA'];

		System.assertEquals('Non-Active', aa.Status__c);

		Test.stopTest();

	}

	private static testmethod voId scenario5Test(){

		/*	
		SCENARIO 5: 

		- Accredited HE with accr. model = cash and FoP cash active 
		- A FoP OSCAR case is created and processed to restrict cash 
		- A 50% DOWN risk alert is created 
		- A 75% DOWN risk alert is created 
		- A 100% DOWN risk alert is created 

		EXPECTED RESULT 
		Cash will NOT be restored 

		*/ 

		Test.startTest();

		ANG_RHC_Information__c rhcInfo=[SELECT Id,ANG_AccountId__c FROM ANG_RHC_Information__c LIMIT 1];

		List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();

		ID FormOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeID('Agency_Authorization__c', 'FormOfPayment');

		authorizations.add(new Agency_Authorization__c(Account__c = rhcInfo.ANG_AccountId__c, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));

		insert authorizations;
		
		AMS_OSCAR__c oscar = createOscarFOP();

		ANG_OscarProcessHelper.processRestrictFOP(oscar.Id, false ,true);

		Agency_Authorization__c aa = [SELECT ID, Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA'];

		System.assertEquals('Non-Active', aa.Status__c);


		System.assertEquals(1,[SELECT ID from Agency_Applied_Change_code__c where Account__c = :rhcInfo.ANG_AccountId__c and Change_Code__c = 'PCA' and Active__c = true].Size());

		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN,
			ANG_Threshold_Level__c = '50%'
			);

		insert ara;

		ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN,
			ANG_Threshold_Level__c = '75%'
			);

		insert ara;

		ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN,
			ANG_Threshold_Level__c = '100%'
			);

		insert ara;

		aa = [SELECT ID, Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA'];

		System.assertEquals('Non-Active', aa.Status__c);

		Test.stopTest();

	}

	private static testmethod voId scenario6Test(){


		/*
		SCENARIO 6: 
		- Accredited HE with accr. model = cash and FoP cash active 
		- A 100% UP risk alert is created so Cash FoP will be deactivated 
		- A 50% DOWN risk alert is created 
		- Here as in SCENARIO 2 cash is restored 
		- A FoP OSCAR case is created and processed to restrict cash 
		- A 75% DOWN risk alert is created 

		EXPECTED RESULT 
		Cash will NOT be restored (because the previous RHC alert was a 50% down and not a 100% up) 
		*/
		

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


		Agency_Authorization__c aa = [SELECT ID, Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA'];

		System.assertEquals('Non-Active', aa.Status__c);

		Test.startTest();

		ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN,
			ANG_Threshold_Level__c = '50%'
			);

		insert ara;

		aa = [SELECT ID, Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA'];

		System.assertEquals('Active', aa.Status__c);		
        
		AMS_OSCAR__c oscar = createOscarFOP();

		ANG_OscarProcessHelper.processRestrictFOP(oscar.Id, false ,true);


		Test.stopTest();

		aa = [SELECT ID, Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA'];

		System.assertEquals('Non-Active', aa.Status__c);

		ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN,
			ANG_Threshold_Level__c = '75%'
			);

		insert ara;



		aa = [SELECT ID, Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA'];

		System.assertEquals('Non-Active', aa.Status__c);

	}

	private static AMS_OSCAR__c createOscarFOP(){

		Account a1 = [Select id From Account LIMIT 1];
		System.debug('Account to create OSCAR ::: ' + a1);

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Process__c = AMS_Utils.NGFOP, Account__c = a1.id, RecordTypeId = AMS_Utils.RECTYPE_NEWGENFOP);

		insert oscar;

		ID caseRT = RecordTypeSingleton.getInstance().getRecordTypeID('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = caseRT);
		oscarCase.AccountId = a1.Id;
		oscarCase.ContactId = co1.Id;
		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
		oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
		insert oscarCase;
	
		ID rtNew = RecordTypeSingleton.getInstance().getRecordTypeID('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Head_Entity_Standard_no_Cash');

		AMS_Pax_Accreditation_Form__c theAccreditation = new AMS_Pax_Accreditation_Form__c(RecordTypeId = rtNew);

		theAccreditation.Account_Name__c='NEWGEN-559 HE5';
		theAccreditation.ISSP_AMS_Legal_Status__c='Association';
		theAccreditation.Branch_Office_Street_name_number__c='sdfsdf';
		theAccreditation.Branch_Office_City__c='sdfsdfdf';
		theAccreditation.Branch_Office_Email__c='sdfsdfgdg@f3434.com';
		theAccreditation.Branch_Office_Phone__c='123123123';
		theAccreditation.ISSP_AMS_Premises_located_at_airport__c='No';
		theAccreditation.Abbreviated_name__c='NEWGEN-559 HE5';
		theAccreditation.Abbreviated_Address__c='sdfsdf';
		theAccreditation.Remittance_frequency__c='M';
		theAccreditation.Solicitation_Flag__c=false;
		theAccreditation.Location_Class__c='P';
		theAccreditation.Location_Type__c='HE';
		theAccreditation.SAAM_Case__c=oscarCase.Id;
		theAccreditation.Account_Name__c = a1.Id;

		insert theAccreditation;

		ID personRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

		AMS_Accreditation_Contact__c acontact = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = theAccreditation.Id, 
			First_name__c='Bugs', Last_name__c='Bunny', Agency_owner__c = true, Email__c='bugsandbunny@imagsd.com' , PhoneNational__c = '123123123',
			Phone__c='123123123', Contact__c = co1.Id, Financial_interest__c = 100, RecordTypeId=personRT);

		insert acontact;

		oscar.AMS_Online_Accreditation__c = theAccreditation.Id;
		update oscar;

		

		return oscar;
	}

	private static testmethod void testTicketingAuthorityRemoval(){

    	Account a = [Select Id, Remittance_frequency__c from Account limit 1];
    	System.debug('##Account: '+ a.Remittance_frequency__c);

    	AMS_Country_Specific_Attribute__c csa = new AMS_Country_Specific_Attribute__c (
	    	IATA_ISO_Country__c=[select id from IATA_ISO_Country__c where Name = 'France'].id,
	        ANG_RTS_Severity__c='Red',
	        ANG_Send_Email_Agent__c=true ,
	        ANG_Create_Sidra_Lite__c= true, 
	        ANG_Remove_Ticketing_Authority__c= true,
	        recordtypeId=RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_Country_Specific_Attribute__c').get('RTS_Risk_Alert_Notification')
     	);

      	insert csa;

	    AMS_Settlement_System__c iss = new AMS_Settlement_System__c(Name = 'BSP-FR');
	    insert iss;

	    Operational_Calendar__c op = new operational_Calendar__c( ISS_Operation__c = iss.id, 
	    	First_Day__c = Date.today(), Last_Day__c = Date.today(), Frequency_code__c = 'M', Remittance_Day__c = Date.today() );

	    insert op;
	    
	    Contact con = new Contact(LastName = 'ttt', Accountid = a.id);
	    insert con;

	    //NEWGEN-2005
	    insert new RTS_Senior_Manager__c(Name = 'Test', Email__c = 'test.2005@yopmail.com');

	    test.StartTest();

	    ANG_Risk_Alert__c ra = new ANG_Risk_Alert__c(
		    Recordtypeid=Schema.SObjectType.ANG_Risk_Alert__c.getRecordTypeInfosByName().get('Risk Alert RTS').getRecordTypeId(),
		    ang_Severity__c='Red',
		    ANG_Account__c = a.Id
	    );
	    insert ra;

	    test.StopTest();

	    List<Case> c = [Select Id From Case Where AccountId = :a.Id and RecordType.Name='SIDRA Lite' limit 1];
	    System.assertEquals(c.size(), 1, 'Sidra lite case was not created');

	    List<ISSP_Web_Service_Log__c> logs = [Select Id From ISSP_Web_Service_Log__c where Case__c = :c.get(0).Id];
	    System.assertEquals(logs.size(), 1, 'Response was not saved');

  	}

  	private static testmethod void testRedAlertCreationNoConfigurationMatched(){
	    // no configuration for the account country found, so it will use the default one
	    IATA_ISO_Country__c  country2= new IATA_ISO_Country__c(
		    Name = 'Portugal', 
		    ISO_Code__c = 'PT'
	    );

	    insert country2 ;

	    AMS_Country_Specific_Attribute__c csa = new AMS_Country_Specific_Attribute__c (
	        IATA_ISO_Country__c=[select id from IATA_ISO_Country__c where iso_code__C='WW'].id,
	        ANG_Create_Sidra_Lite__c= true, 
	        ANG_Remove_Ticketing_Authority__c= false,
	        ANG_Send_Email_Agent__c=false ,
	        ANG_RTS_Severity__c='Red',
	        recordtypeId=RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_Country_Specific_Attribute__c').get('RTS_Risk_Alert_Notification')
	    );

	    insert csa;

	    Account a = new Account(
	    	name='acc1',
		    Location_Type__c='HE',
		    Location_Class__c='P',
		    IATAcode__c = '0000',
		    Remittance_frequency__c='Monthly',
		    ANG_Accreditation_Model__c ='Cash',
		    IATA_ISO_Country__c = country2.id,
		    RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency')
	    );
	   	insert a;     
	    
	    AMS_Settlement_System__c iss = new AMS_Settlement_System__c(Name = 'BSP-PT');
	    insert iss;

	    operational_Calendar__c op = new operational_Calendar__c( ISS_Operation__c = iss.id, 
	    	First_Day__c = Date.today(), Last_Day__c = Date.today(), Frequency_code__c = 'M', Remittance_Day__c = Date.today() );

	    insert op;
	    
	    Contact con = new Contact(LastName = 'ttt', Accountid = a.id);
	    insert con;

	    //NEWGEN-2005
	    insert new RTS_Senior_Manager__c(Name = 'Test', Email__c = 'test.2005@yopmail.com');
	    
	    test.StartTest();
	    
	    ANG_Risk_Alert__c ra = new ANG_Risk_Alert__c(
		    Recordtypeid=Schema.SObjectType.ANG_Risk_Alert__c.getRecordTypeInfosByName().get('Risk Alert RTS').getRecordTypeId(),
		    ang_Severity__c='Red',
		    ANG_Account__c = a.Id
	    );
	    insert ra;
	    
	    test.StopTest();
	    
	    List<Case> c = [Select Id From Case Where AccountId = :a.Id and RecordType.Name='SIDRA Lite' limit 1];
	    System.assertEquals(c.size(), 1, 'Sidra lite case was not created');
	}

}
