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
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
		IATA_ISO_Country__c defCountry = new IATA_ISO_Country__c(Name = 'All Countries', ISO_Code__c = ANG_RHCAlertTriggerHandler.DEFAULT_CODE);
		insert new List<IATA_ISO_Country__c>{country, defCountry};

		// Create an Airline HQ account
		Account a = new Account(
			Name = 'acc1',
			Location_Type__c = 'HE',
			Location_Class__c = 'P',
			Remittance_frequency__c = 'M',
			ANG_Accreditation_Model__c = 'Cash',
			IATA_ISO_Country__c = country.Id,
			RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency')
		);
		insert a;        

		Contact contact = new Contact(
			FirstName = 'test',
			LastName = 'test', 
			AccountId = a.Id,
			User_Portal_Status__c = ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM,
			email = 'testiata@yopmail.com'
		);
		insert contact;

		ISSP_ObjectFactory.createPortalUser(contact);

		Portal_Applications__c par = new Portal_Applications__c (Name = 'RHC Information');
		insert par;

		insert new Portal_Application_Right__c(Portal_Application__c = par.id, Right__c = 'Access Granted', Contact__c = contact.Id);

		// Create a new Financial Institution
		Financial_Institution__c fi = new Financial_Institution__c(
			Name = 'Test', 
			Region__c = 'Europe', 
			Country__c = 'Portugal', 
			Institution_Type__c = 'Bank'
		);
		insert fi;
		
		// create a reception case
		Case c = new Case(
			Subject = 'rception case', 
			AccountId = a.Id, 
			Status = 'Open', 
			RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('InternalCasesEuropeSCE') 
		);
		insert c;


		ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
			ANG_AccountId__c = a.Id,
			CurrencyIsoCode = 'USD',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			ANG_Financial_Security__c = 0
		);
		insert rhcInfo;

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

		ANG_RHC_Alert_Templates__c rat = new ANG_RHC_Alert_Templates__c(
			name = 'not50percentTemplate',
			ang_direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP,
			ANG_language__c = 'English',
			ANG_percentage__c = '50%',
			ANG_template_api__c = 'emailTemplate'       
		);

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
	}

	private static testmethod voId test_sucess_legacy(){

		Test.StartTest();
		ANG_RHC_Information__c rhcInfo=[SELECT Id,ANG_AccountId__c FROM ANG_RHC_Information__c LIMIT 1];
		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP,
			ANG_Threshold_Level__c = '50%'
		);

		String processRecorType = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('CS_Process_IDFS_ISS');

		System.assertEquals(0, [SELECT Id FROM Case WHERE RecordTypeId = :processRecorType].size(), 'No process should be created at this time');
		
		insert ara;

		System.assertEquals(1, [SELECT Id FROM Case WHERE RecordTypeId = :processRecorType].size(), 'There should one Process Case Created');
		Test.StopTest();

		System.assert([SELECT Id,ANG_email_sent__c FROM ANG_Risk_Alert__c LIMIT 1].get(0).ANG_email_sent__c,'Email was not sent');
	}

	private static testmethod voId test_sucess_newgen(){
		Test.StartTest();
		IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'FR'];
		country.ANG_Enable_NewGen__c = true;
		update country;

		ANG_RHC_Information__c rhcInfo=[SELECT Id,ANG_AccountId__c FROM ANG_RHC_Information__c LIMIT 1];
		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP,
			ANG_Threshold_Level__c = '50%'
		);

		insert ara;
		Test.StopTest();
		System.assert([SELECT Id,ANG_email_sent__c FROM ANG_Risk_Alert__c LIMIT 1].get(0).ANG_email_sent__c,'Email was not sent');
	}

	private static testmethod voId testRiskAlertCreationNoConfigurationMatched(){

		Test.StartTest();
		ANG_RHC_Information__c rhcInfo=[SELECT Id,ANG_AccountId__c FROM ANG_RHC_Information__c LIMIT 1];
		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c = rhcInfo.Id,
			ANG_Account__c = rhcInfo.ANG_AccountId__c,
			ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP,
			ANG_Threshold_Level__c = '88%' // no configuration exists with this percentage
		);

		insert ara;

		System.assert(![SELECT Id,ANG_email_sent__c FROM ANG_Risk_Alert__c LIMIT 1].get(0).ANG_email_sent__c,'Email was sent');
		Test.StopTest();
	}

}