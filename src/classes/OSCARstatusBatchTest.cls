@isTest
private class OSCARstatusBatchTest {

	
	@testSetup static void initialize() {
		List<AMS_OSCAR__c> oscarList = new List<AMS_OSCAR__c>();
		String Voluntary_Relinquishment_Id = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'VOLUNTARY_RELINQUISHMENT');
		Id Change_Id = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CHANGE');

		Id Certification_Id = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CERTIFICATION');

		Date today = System.today();
		
		Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Account account = new Account(RecordTypeId = agencyRT, Name = 'Test Account');
		insert account;
		
		AMS_OSCAR__c osc1 = new AMS_OSCAR__c(Name = 'Voluntary_Relinquishment1', Account__c = account.Id,
		                                     Change_effective_as_of__c = System.today(), Status__c='Accepted_Future Date', RecordTypeId=Voluntary_Relinquishment_Id);
		
		AMS_OSCAR__c osc2 = new AMS_OSCAR__c(Name = 'Voluntary_Relinquishment3', Account__c = account.Id,
		                                     Termination_Date__c = System.today(), Status__c='Accepted_Future Date', RecordTypeId=Voluntary_Relinquishment_Id);
		
		AMS_OSCAR__c osc3 = new AMS_OSCAR__c(Name = 'Change1', Account__c = account.Id,
		                                     Change_effective_as_of__c = System.today(), Status__c='Accepted_Future Date', RecordTypeId=Change_Id);
		
		AMS_OSCAR__c osc4 = new AMS_OSCAR__c(Name = 'certification1', Account__c = account.Id,
		                                     Sanity_check_deadline__c = System.today(), Status__c='Accepted_Future Date', RecordTypeId=Certification_Id);
		
		oscarList.add(osc1);
		oscarList.add(osc2);
		oscarList.add(osc3);
		oscarList.add(osc4);
		insert oscarList;
	}


	@isTest static void runBatchTest() {
		// Implement test code
		Test.startTest();
		OSCARstatusBatch batch = new OSCARstatusBatch();
        Database.executeBatch(batch, 10);
		Test.stopTest();
		List<AMS_OSCAR__c> oscarList = [SELECT id, Recordtype.Developername, Change_effective_as_of__c, Termination_Date__c, Status__c, Sanity_check_deadline__c from AMS_OSCAR__c
	                                where (Status__c = 'Accepted_Future Date' or  Status__c = 'Open')  and ( Recordtype.Developername = 'Voluntary_Relinquishment' or Recordtype.Developername = 'certification' or Recordtype.Developername = 'change') order by Status__c];
		 system.debug(oscarList);
       
        System.AssertEquals(oscarList[0].Status__c, 'Accepted_Future Date'); //Sanity_check_deadline__c is always one moth in front
        System.AssertEquals(oscarList[1].Status__c, 'Open');    
        System.AssertEquals(oscarList[2].Status__c, 'Open');    
        System.AssertEquals(oscarList[3].Status__c, 'Open');    
	}	
}