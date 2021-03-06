@isTest
public class ANG_MulticountryCopyParentInfo_Test {


	@testSetup static void setup(){

		Id agencyAcctRecId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		//Create BSP Countries
		AMS_Settlement_System__c bspPT = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		AMS_Settlement_System__c bspGB = new AMS_Settlement_System__c(
			Name = 'BSP-GB',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		insert new List<AMS_Settlement_System__c>{bspPT, bspGB};

		IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c();
		countryPT.Name = 'Portugal';
		countryPT.ISO_Code__c = 'PT';
		countryPT.ANG_Enable_NewGen__c = true;
		countryPT.AMS_Settlement_System__c = bspPT.Id;
		countryPT.Multicountry_Enabled__c = true;

		IATA_ISO_Country__c countryUK = new IATA_ISO_Country__c();
		countryUK.Name = 'United Kingdom';
		countryUK.ISO_Code__c = 'GB';
		countryUK.ANG_Enable_NewGen__c = true;
		countryUK.AMS_Settlement_System__c = bspGB.Id;
		countryUK.Multicountry_Enabled__c = true;

		insert new List<IATA_ISO_Country__c>{countryPT, countryUK};

		IATA_ISO_State__c isos = new IATA_ISO_State__c(Name= 'PT', ISO_Code__c = 'TS', IATA_Iso_Country__c = countryPT.Id);
		insert isos;

		//Create Account - GE - PT
		Account geAccount = new Account(Name = 'Multicountry GE PT',
			Location_Type__c = AMS_Utils.GE,
			Location_Class__c = 'P',
			IATA_ISO_Country__c = countryPT.Id,
			RecordTypeId = agencyAcctRecId,
			Company_Type__c = 'A',
			TradeName__c = 'Trade Name GE',
			Short_Name__c = 'Short Name GE',
			Website = 'Website GE',
			VAT_Number__c = 'Vat Number GE',
			Iso_State__c = isos.id,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY,
			Remittance_frequency__c = 'V'
		);

		insert geAccount;

		//Create Account - AE - PT
		Account aeAccount = new Account(Name = 'Multicountry AE PT',
			ParentId = geAccount.Id,
			Location_Type__c = AMS_Utils.AE,
			Location_Class__c = 'P',
			IATA_ISO_Country__c = countryPT.Id,
			RecordTypeId = agencyAcctRecId
		);

 		insert aeAccount;

		Case cseGE = new Case(
			RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM,
			AccountId = geAccount.Id
		);

		Case cseAE = new Case(
			RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM,
			AccountId = aeAccount.Id
		);

		insert new List<Case>{cseGE,cseAE};

		Id travelAgentrt = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Head_Entity_Standard_no_Cash');

		AMS_Pax_Accreditation_Form__c paxAccGE = new AMS_Pax_Accreditation_Form__c(RecordTypeID =travelAgentrt, SAAM_Case__c = cseGE.id);
		AMS_Pax_Accreditation_Form__c paxAccAE = new AMS_Pax_Accreditation_Form__c(RecordTypeID =travelAgentrt, SAAM_Case__c = cseAE.id);

		insert new List<AMS_Pax_Accreditation_Form__c>{paxAccGE, paxAccAE};

		//Create Oscars
		AMS_Oscar__c oscarGE = new AMS_OSCAR__c(
			RecordTypeId = AMS_Utils.RECTYPE_NEWGE,
			Account__c = geAccount.Id,
			Process__c = AMS_Utils.NEWGESTANDARD,
			AMS_Online_Accreditation__c = paxAccGE.id
		);

		AMS_Oscar__c oscarAE = new AMS_OSCAR__c(
			RecordTypeId = AMS_Utils.RECTYPE_MCAE,
			Account__c = aeAccount.Id,
			Process__c = AMS_Utils.MCAE,
			AMS_Online_Accreditation__c = paxAccAE.id
		);

		insert new List<AMS_Oscar__c>{oscarGE,oscarAE};
	}

	@isTest static void testCopyDataAfterApprovalStep(){

		List<ID> accountIdList = new List<Id>(new Map<Id, Account>([SELECT ID FROM Account WHERE Name = 'Multicountry GE PT']).keySet());

		// startTest/stopTest block to force async processes to run in the test.
		Test.startTest();

		System.enqueueJob(new ANG_MulticountryCopyParentInfo(accountIdList, 'FIN'));

		Test.stopTest();

		//Validate if the Data was copy from Parent Account to Child Staging Area - Remittance_frequency__c
		List<AMS_Oscar__c> childOscar = [SELECT Id, AMS_Online_Accreditation__r.Remittance_frequency__c
										FROM AMS_Oscar__c WHERE Account__r.ParentId =:accountIdList.get(0)];

		AMS_Oscar__c oscar = childOscar[0];

		System.assertEquals('V', oscar.AMS_Online_Accreditation__r.Remittance_frequency__c); // Weekly
	}

}
