@isTest
private class ANG_AgentsNotificationRhcTest {

	@testSetup static void setup() {

		Map<String, Profile> airlineProfileMap = new Map<String, Profile>(
			[SELECT Id FROM Profile WHERE Name LIKE 'ISS Portal Airline%']
		);

		Map<String, Profile> agencyProfileMap = new Map<String, Profile>(
			[SELECT Id FROM Profile WHERE Name LIKE 'ISS Portal Agency%']
		);

		List<ISSP_CS__c> listCs = new List<ISSP_CS__c>();

		listCs.add(
			new ISSP_CS__c(
				Name = 'ISS OperationalCalendar Airline Profil',
				Value__c = String.join(new List<string>(airlineProfileMap.keySet()),',')
			)
		);

		listCs.add(
			new ISSP_CS__c(
				Name = 'ISS OperationalCalendar Agency Profile',
				Value__c = String.join(new List<string>(agencyProfileMap.keySet()),',')
			)
		);

		insert listCs;

		AMS_Settlement_System__c bspES = new AMS_Settlement_System__c(
			Name = 'BSP-ES',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		insert bspES;

		Operational_Calendar__c opES = new Operational_Calendar__c(
			ISS_Operation__c = bspES.id,
			First_Day__c = Date.today().addDays(30),
			Last_Day__c = Date.today().addDays(60),
			Frequency_code__c = 'W',
			Remittance_Day__c = Date.today().addDays(30)
		);

		insert opES;

		IATA_ISO_Country__c cntry = new IATA_ISO_Country__c();
		cntry.Name = 'Spain';
		cntry.CurrencyIsoCode = 'EUR';
		cntry.ISO_Code_Numeric__c = 625;
		cntry.ISO_Code__c = 'ES';
		cntry.ANG_Enable_NewGen__c = TRUE;
		cntry.AMS_Settlement_System__c = bspES.Id;

		insert cntry;

		Portal_Applications__c par = new Portal_Applications__c(
			Name = ANG_RHCHelper.RISK_PROFILE_AND_RHC_PORTAL_SERVICE
		);

		insert par;

		User adminWithRole =
			[SELECT
				Id
			 FROM
				User
			 WHERE
				 IsActive = TRUE
			 AND Profile.Name = 'System Administrator'
			 AND UserRoleId <> NULL
			 LIMIT 1
			];

		System.runAs(adminWithRole) {

			Test.startTest();

			Account acct = new Account();

			acct.Name = 'Risk Status Update Acct';
			acct.Type = 'IATA Passenger Sales Agent';
			acct.Sector__c = 'Travel Agent';
			acct.Location_Type__c = AMS_Utils.HE;
			acct.Location_Class__c = 'P';
			acct.IATACode__c = '99999999';
			acct.IATA_ISO_Country__c = cntry.Id;
			acct.BillingCountry='Iso Country Name Test2';
			acct.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;
			acct.Status__c = AMS_Utils.ACC_S9_APPROVED;
			acct.ANG_HE_RiskHistoryAssessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED;
			acct.Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY;
			acct.RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY;
			acct.Remittance_frequency__c = 'W';
			acct.ANG_HE_RiskStatus__c = 'C';

			insert acct;

			Contact contact = new Contact(
				FirstName = 'Alice',
				LastName = 'Jones',
				AccountId = acct.Id,
				User_Portal_Status__c = ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM,
				email = 'alicejones@test.com'
			);

			insert contact;

			User usr = ISSP_ObjectFactory.createPortalUser(contact);
			contact.OwnerId = usr.Id;
			update contact;

			insert new Portal_Application_Right__c(
				Portal_Application__c = par.id,
				Right__c = 'Access Granted',
				Contact__c = contact.Id
			);

			Test.stopTest();

		}

	}

	@isTest
	public static void riskAndRhcInformationUpdateNotificationTest(){

		Test.startTest();

		Notification_Template__c nt = new Notification_Template__c();
		nt.Identifier__c = 'Risk_Information_Update';
		nt.Language__c = 'English';
		nt.Subject__c = 'Risk Information Update';
		nt.Type__c = 'Information';
		nt.Notification_color__c = '#007FFF';
		nt.Expire_in_days__c = 180;
		nt.Admins_Users__c = 'Administrators';
		nt.Message__c =
			'We would like to inform you that your Risk Status has been updated. ' +
			'Your risk information now stands as follow:' +
			'<br><br>Risk Status: #RISK_STATUS#' +
			'<br>Cash conditions limited to Financial Security: #CASH_CONDITION#'+
			'<br>RHC Amount: #RHC_AMOUNT#'+
			'<br>RHC Effective Date: #RHC_EFFECTIVE_DATE#'+
			'<p>Please check more details on the RHC Information page.' +
			'<br>Thank you</p>'+
			'<p>IATA – Global Delivery Center</p>';

		insert nt;

		Account acct =
			[SELECT
				Id, IATA_ISO_Country__c
			 FROM
				Account
			 WHERE
				Name = 'Risk Status Update Acct'
			 LIMIT 1
			];

		Financial_Institution__c fi = new Financial_Institution__c(
			Name = 'Financial Institution',
			Region__c = 'Europe',
			Country__c = 'Spain',
			Institution_Type__c = 'Bank'
		);

		insert fi;

		Case cc = new Case(AccountId = acct.Id);
		insert cc;

		ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
			ANG_AccountId__c = acct.Id,
			CurrencyIsoCode = 'EUR',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			ANG_Forecasted_RHC_Effective_date__c = System.today()
		);

		insert rhcInfo;

		Financial_Security__c fs = new Financial_Security__c(
			CurrencyIsoCode = 'EUR',
			Account__c = acct.Id,
			Amount__c = 5000,
			Expiry_date__c = System.Today().AddDays(100),
			Financial_Institution__c = fi.Id,
			Security_Status__c = 'Active',
			Security_Type__c = 'Bank Guarantee',
			Region__c = 'Europe',
			Reception_Date__c = System.today(),
			Reasonforrequest__c = 'New Application',
			Reception_Case__c = cc.Id,
			Financial_Security_Validation_Case__c = cc.Id
		);

		insert fs;

		ANG_RHCHelper.updateNotificationAlreadySent.clear();

		acct.ANG_HE_RiskStatus__c = 'A';
		update acct;

		Notification__c no =
			[SELECT
				Id,
				Message__c
			 FROM
				Notification__c
			 WHERE
				Contact__r.AccountId = :acct.Id
			ORDER BY CreatedDate  DESC
			LIMIT 1
			];

		System.assert(no.Message__c.contains('Risk Status: ' + acct.ANG_HE_RiskStatus__c));

		//Force to send another notification
		//for the same account in the same transaction
		ANG_RHCHelper.updateNotificationAlreadySent.clear();

		rhcInfo.ANG_RHC_Amount_Forecasted__c = 10000.00;
		update rhcInfo;

		Notification__c no2 =
			[SELECT
				Id,
				Message__c
			 FROM
				Notification__c
			 WHERE
				 Contact__r.AccountId = :acct.Id AND id != :no.ID
			 ORDER BY CreatedDate DESC
			 LIMIT 1
			];

		System.assert(no2.Message__c.contains('RHC Amount: ' + String.valueOf(rhcInfo.ANG_RHC_Amount_Forecasted__c.format()) + ' ' + rhcInfo.CurrencyIsoCode));

		//Now checking that the blocking is working
		Integer size = [SELECT Id FROM Notification__c ].size();

		//Force to send another notification
		//for the same account in the same transaction
		ANG_RHCHelper.updateNotificationAlreadySent.clear();

		//Blocking notifications
		insert new AMS_Country_Specific_Attribute__c (recordtypeid =AMS_Utils.RECTYPE_CSA_RISK_NOTIFICATION, Block_notification_on_Risk_Status_update__c = true, Block_notification_on_RHC_amount_update__c = true, IATA_ISO_Country__c = acct.IATA_ISO_Country__c);
		IATAIsoCountryDAO.resetMapIataIsoCountry();
		rhcInfo.ANG_RHC_Amount_Forecasted__c = 100001.00;
		update rhcInfo;

		Integer currentSize = [SELECT Id FROM Notification__c ].size();
		system.assert(size == currentSize, 'Too manny notifications. Should only have the previous ones');

		Test.stopTest();

	}

}
