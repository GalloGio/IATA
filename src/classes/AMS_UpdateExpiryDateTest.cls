@isTest
private class AMS_UpdateExpiryDateTest {
	static testMethod void test_UpdateExpiryDate() {
		
		TestData.ForUpdateExpiryDate testData = new TestData.ForUpdateExpiryDate();
		
		System.runAs(testData.user) {

			AMS_Agency__c a4 = new AMS_Agency__c(Country__c = testData.country.id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Agency__c', 'PASSENGER'), Name='Test Agency4', IATAcode__c = '1234561', Chk_dgt__c = '8', Legal_Name_1__c = 'Test Agency4', Legacy_External_ID__c = '12345618', Legacy_System__c = 'AIMS',OwnerId = UserInfo.getUserId(), Agency_Status__c = 'Terminated');
			insert a4;

			AMS_Accreditation_Organization__c ao1 = new AMS_Accreditation_Organization__c(Air_Code__c = 'TEST');
			AMS_Accreditation_Organization__c ao2 = new AMS_Accreditation_Organization__c(Air_Code__c = 'IATA');
			List<AMS_Accreditation_Organization__c> aos = new List<AMS_Accreditation_Organization__c>{ao1, ao2};
			insert aos;

			AMS_Inspection__c i1 = new AMS_Inspection__c(Accreditation_Endorsement_organisation__c = ao1.id, Accreditation_Endorsement_Status_code__c = '1', Agency__c = a4.id, Date_Organisation_Status_attained__c = date.today(), Account__c = testData.accountsList[0].Id);
			AMS_Inspection__c i2 = new AMS_Inspection__c(Accreditation_Endorsement_organisation__c = ao2.id, Accreditation_Endorsement_Status_code__c = '1', Agency__c = a4.id, Date_Organisation_Status_attained__c = date.today(), Account__c = testData.accountsList[1].Id);
			AMS_Inspection__c i3 = new AMS_Inspection__c(Accreditation_Endorsement_organisation__c = ao1.id, Accreditation_Endorsement_Status_code__c = '0', Agency__c = a4.id, Date_Organisation_Status_attained__c = date.today(), Account__c = testData.accountsList[2].Id);
			AMS_Inspection__c i4 = new AMS_Inspection__c(Accreditation_Endorsement_organisation__c = ao2.id, Accreditation_Endorsement_Status_code__c = '0', Agency__c = a4.id, Date_Organisation_Status_attained__c = date.today(), Account__c = testData.accountsList[3].Id);
			AMS_Inspection__c i5 = new AMS_Inspection__c(Accreditation_Endorsement_organisation__c = ao2.id, Accreditation_Endorsement_Status_code__c = '0', Agency__c = a4.id, Date_Organisation_Status_attained__c = date.today().addDays(-1), Account__c = testData.accountsList[4].Id);

			List<AMS_Inspection__c> ins = new List<AMS_Inspection__c>{i1, i2, i3, i4, i5};
			
			Test.startTest();
			insert ins;
			Database.executeBatch(new AMS_UpdateExpiryDate(), 3);
			Test.stopTest();
			
			AMS_Agency__c acc4 = [select id, Recert_Expiry_Date__c from AMS_Agency__c][0];
		}
	}
}