@isTest
private class ANG_MassiveFOPCaseTest {
	
	@testSetup static void setup(){
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', Region__c = 'Europe')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account acct = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HE',Name='The Agency CIA',Short_Name__c='The Agency CIA', Sector__c = 'Travel Agent', Type ='IATA Passenger Sales Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert acct;
        
        Contact co1 = new Contact(AccountId = acct.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = true);
		insert co1;

	}
	
	@isTest static void test_method_two() {
		
		Test.startTest();

		ANG_MassiveFOPCaseCreationBatch massFOPCaseCreationBatch = new ANG_MassiveFOPCaseCreationBatch(new Set<Id>{[Select Id from Account].Id});
		Id massFOPCaseCreationBatchId = Database.executeBatch(massFOPCaseCreationBatch,1);	

		Test.stopTest();
	}
	
}