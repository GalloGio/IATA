@isTest
private class ANG_ChangeCodesCreationTest {

	@testSetup
	static void setup() {

		//create hierarchy with more than the threshold defined

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account account = new Account();
		account.Name = 'Main HE Account H1';
		account.Sector__c = 'Travel Agent';
		account.IATACode__c = '12345678';
		account.Category__c = 'IATA Passenger Sales Agent';
		account.Location_Class__c = 'P';
		account.Location_Type__c = 'HE';
		account.ANG_Accreditation_Model__c = 'Cashless';
		account.IATA_ISO_Country__c = ctry.Id;
		account.ANG_IEP_HE_AccntNum__c = '1232132323';
		account.ANG_IEP_Status__c = 'Suspended' ;
		account.ANG_HE_CashCondition__c = true;
		account.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		account.ANG_HE_RiskStatus__c = 'Not Applicable';
		account.RecordTypeId = accountAgencyRT;

		insert account;

	}

	@isTest
	static void testChangeCodeCreation() {

		Account parentAcc = [SELECT Id, (SELECT Id FROM Agencies_Applied_Change_codes__r) FROM Account WHERE Name = 'Main HE Account H1' LIMIT 1];

		System.assertEquals(new List<Agency_Applied_Change_code__c>(), parentAcc.Agencies_Applied_Change_codes__r);

		List<Agency_Applied_Change_code__c> aaccList = new List<Agency_Applied_Change_code__c>();
		Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c(
				Active__c = true
				, Account__c = parentAcc.Id
				, Change_Code__c = 'COR'
				, Bulletin_Information__c = 'Test Bulletin Information'
				, Reason_Code__c = '91'
				, Reason_Description__c = 'ACCREDITED-MEETS-STANDARDS'
				, To_Publish_in_e_Bulletin__c = true);

		aaccList.add(aacc);

		List<AMS_ChangeCodesHelper.ChangeCodeStruct> aaccHistoryToProcessList = new List<AMS_ChangeCodesHelper.ChangeCodeStruct>();
		AMS_ChangeCodesHelper.ChangeCodeStruct aaccHistoryToProcess = new AMS_ChangeCodesHelper.ChangeCodeStruct(aacc, parentAcc, new List<AMS_Agency_A_Change_code_History__c>());
		aaccHistoryToProcessList.add(aaccHistoryToProcess);

		Test.startTest();
		System.enqueueJob(new ANG_ChangeCodesCreation(aaccList, aaccHistoryToProcessList));
		Test.stopTest();

		List<Agency_Applied_Change_code__c> newAaccList = [SELECT Id, Change_Code__c FROM Agency_Applied_Change_code__c WHERE Account__c =: parentAcc.Id];

		System.assertEquals(1, newAaccList.size());
		System.assertEquals('COR', newAaccList.get(0).Change_Code__c);

	}

}
