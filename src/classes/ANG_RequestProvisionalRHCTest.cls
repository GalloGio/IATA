@isTest
public class ANG_RequestProvisionalRHCTest{

	@testSetup static void testSetup(){


		Id settlementRTId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c', 'BSP');

		AMS_Settlement_System__c settlement = new AMS_Settlement_System__c(
			Name = 'test settlement',
			RecordTypeId = settlementRTId
		);

		insert settlement;

		  // Create a new ISO Country
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
			Name = 'France',
			ISO_Code__c = 'FR',
			AIMS_Area_Name__c='France',
			AIMS_Area_ID__c= '1',
			ANG_Enable_NewGen__c = true,
			AMS_Settlement_System__c = settlement.Id
		);
		insert country;

		// Create an Airline HQ account
		Account a = new Account(
			name='acc1',
			Location_Type__c='HE',
			Location_Class__c='P',
			Type = 'IATA Cargo Agent',
			IATA_ISO_Country__c=country.id,
			IATACode__c ='1234567',
			Remittance_frequency__c='M',
			billingCountry = 'fr',
			ANG_Accreditation_Model__c ='Cash',
			category__c = 'IATA Passenger Sales Agent',
			sector__c = 'Travel Agent',
			Company_Type__c='A',
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency')
		);
		insert a;

		ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
			ANG_AccountId__c =a.id,
			CurrencyIsoCode ='USD',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			ANG_Financial_Security__c=100
		);

		insert rhcInfo;

		// Create a new Financial Institution
		Financial_Institution__c fi = new Financial_Institution__c(
			Name = 'Test',
			Region__c = 'Europe',
			Country__c = 'France',
			Institution_Type__c = 'Bank'
		);
		insert fi;

		Contact con =new contact(
					lastname = 'hodor' ,
					firstname = 'hodor',
					phone = '123',
					accountid = a.id,
					Financial_Assessment_Contact__c = true
				);
		insert con;

		Case c = new Case(
				Origin = 'asd',
				IFAP_Area__c = 'asda',
				Financial_Review_Type__c ='bla',
				IFAP_Financial_Year__c =  String.valueOF(date.today().year()),
				Deadline_Date__c = date.today().addDays(40),
				contactid = con.id,
				AccountId = a.id,
				Assessment_Performed_Date__c = date.today(),
				Financial_Security_Currency__c= 'EUR',
				Financial_Security_Amount__c=10000
			);
		insert c;




		Financial_Security__c fs = new Financial_Security__c(
			Region__c = 'Europe',
			Security_status__c = 'Active',
			Account__c = a.Id,
			CurrencyIsoCode = 'EUR',
			Security_Type__c='CCG',
			Amount__c = 100,
			Expiry_date__c = Date.today().addYears(2),
			Financial_Institution__c = fi.Id,
			Validity_Start_Date__c = Date.today().addDays(-2),
			Reception_Case__c = c.Id,
			Reception_Date__c = Date.today(),
			Reasonforrequest__c = 'New Application'
		);
		insert fs;

		List<ANG_CalloutMapping__c> customsettings = new List<ANG_CalloutMapping__c>();
		customsettings.add(new ANG_CalloutMapping__c(Name = 'BTN_Prov', CalloutClass__c = 'ANG_RME_Alert_Service', Action__c = 'GET', Event_Type__C = 'WebService', Credential__c = '/calculatedrhc/{agencyId}/v1', Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'Button'));

		insert customsettings;


		AMS_Operation__c opCode = new AMS_Operation__c(
			Name = 'test operation',
			Settlement__c = settlement.id,
			Allow_multiple_remittances__c = false,
			Country__c = country.id
		);

		insert opCode;

		List<ANG_BSP_Attributes__c> bSPAttributes = new List<ANG_BSP_Attributes__c>();

		ANG_BSP_Attributes__c bSPAttributes1 = new ANG_BSP_Attributes__c(
			Class_Type__c  = 'P',
			Remittance_Frequency__c = 'D',
			Operation__c = opCode.Id,
			BSP__c = settlement.Id
		);

		bSPAttributes.add(bSPAttributes1);

		insert bSPAttributes;



	}

	TestMethod static void requestProvisional(){

		Test.startTest();

		ANG_RHC_Information__c rhc = [Select Id, ANG_RHC_Amount_Provisional__c, ANG_Provisional_RHC_Last_Update__c, ANG_RME_Amount__c, ANG_AccountId__c from ANG_RHC_Information__c];

		PageReference pg = Page.ANG_RequestProvisionalRHC;
		pg.getParameters().put('Id', rhc.Id);

		Test.setCurrentPage(pg);

		ANG_RequestProvisionalRHCCtrl controller = new ANG_RequestProvisionalRHCCtrl();

		controller.requestProvisionalRHC();
		controller.requestProvisionalRHC();
		controller.save();

		ANG_RHC_Information__c newRHC = [Select Id, ANG_RHC_Amount_Provisional__c, ANG_Provisional_RHC_Last_Update__c, ANG_RME_Amount__c, ANG_AccountId__c from ANG_RHC_Information__c];

		System.debug('NewRHC:'+newRHC);

		System.assertNotEquals(rhc.ANG_RHC_Amount_Provisional__c, newRHC.ANG_RHC_Amount_Provisional__c);
		System.assertNotEquals(rhc.ANG_RHC_Amount_Provisional__c, newRHC.ANG_RHC_Amount_Provisional__c);

		System.assertEquals(newRHC.ANG_RHC_Amount_Provisional__c,200);
		System.assertEquals(newRHC.ANG_Provisional_RHC_Last_Update__c,System.today());

		Test.stopTest();

	}

}
