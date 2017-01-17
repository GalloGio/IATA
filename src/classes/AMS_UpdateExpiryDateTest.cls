@isTest
private class AMS_UpdateExpiryDateTest {
	
	@isTest static void test_UpdateExpiryDate() {
		List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='United States',ISO_Code__c='US');
		IATA_ISO_Country__c ctry1 = new IATA_ISO_Country__c (Name='Australia',ISO_Code__c='AU');
		countries.add(ctry);
		countries.add(ctry1);
		insert countries;

		Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');
		
		AMS_Agency__c a4 = new AMS_Agency__c(Country__c = ctry1.id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test Agency4', IATAcode__c = '1234561', Chk_dgt__c = '8', Legal_Name_1__c = 'Test Agency4', Legacy_External_ID__c = '12345618', Legacy_System__c = 'AIMS',OwnerId = UserInfo.getUserId(), Agency_Status__c = 'Terminated');
		insert a4;

		AMS_Accreditation_Organization__c ao1 = new AMS_Accreditation_Organization__c(Air_Code__c = 'TEST');
		AMS_Accreditation_Organization__c ao2 = new AMS_Accreditation_Organization__c(Air_Code__c = 'IATA');
		List<AMS_Accreditation_Organization__c> aos = new List<AMS_Accreditation_Organization__c>{ao1, ao2};
		insert aos;

		AMS_Inspection__c i1 = new AMS_Inspection__c(Accreditation_Endorsement_organisation__c = ao1.id, Accreditation_Endorsement_Status_code__c = '1', Agency__c = a4.id, Date_Organisation_Status_attained__c = date.today());
		AMS_Inspection__c i2 = new AMS_Inspection__c(Accreditation_Endorsement_organisation__c = ao2.id, Accreditation_Endorsement_Status_code__c = '1', Agency__c = a4.id, Date_Organisation_Status_attained__c = date.today());
		AMS_Inspection__c i3 = new AMS_Inspection__c(Accreditation_Endorsement_organisation__c = ao1.id, Accreditation_Endorsement_Status_code__c = '0', Agency__c = a4.id, Date_Organisation_Status_attained__c = date.today());
		AMS_Inspection__c i4 = new AMS_Inspection__c(Accreditation_Endorsement_organisation__c = ao2.id, Accreditation_Endorsement_Status_code__c = '0', Agency__c = a4.id, Date_Organisation_Status_attained__c = date.today());
		AMS_Inspection__c i5 = new AMS_Inspection__c(Accreditation_Endorsement_organisation__c = ao2.id, Accreditation_Endorsement_Status_code__c = '0', Agency__c = a4.id, Date_Organisation_Status_attained__c = date.today().addDays(-1));
		List<AMS_Inspection__c> ins = new List<AMS_Inspection__c>{i1, i2, i3, i4, i5};
		
		Test.startTest();
		insert ins;
		Database.executeBatch(new AMS_UpdateExpiryDate(), 100);
		Test.stopTest();
		AMS_Agency__c acc4 = [select id, Recert_Expiry_Date__c from AMS_Agency__c];
		system.assertEquals(system.today(),acc4.Recert_Expiry_Date__c);
	}
}