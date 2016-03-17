@isTest
private class AMS_2_MDM_BatchTest {
	
	
	static testmethod void test() {
        
         
        //Test.setMock(AMS_WebServiceMockImpl.class, new AMS_WebServiceMockImpl());
    
        
        // The query used by the batch job.
       	String query = 'SELECT Agency__r.BSP_Code__c ,Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c FROM AMS_Agency_Updates__c ' +
						'where Update_Type__c = \'Update\' order by Agency__r.BSP_Code__c limit 5' ; 

		List<Account> accountList = new List<Account>();
        Account acc1 = new Account(Name='Test1 Account');
        Account acc2 = new Account(Name='Test2 Account');
        Account acc3 = new Account(Name='Test3 Account');
        Account acc4 = new Account(Name='Test4 Account');
        accountList.add(acc1);
        accountList.add(acc2);
        accountList.add(acc3);
        accountList.add(acc4);
        insert accountList;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;

        Map<string, Id>  agenciesRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
        AMS_Agency__c a1 = new AMS_Agency__c(Name='Test1 Parent Agency',Account__c=acc1.Id, Country__c = isoc.id);
        AMS_Agency__c a2 = new AMS_Agency__c(Name='Test1 Child Agency',Account__c=acc2.Id, Country__c = isoc.id);
        AMS_Agency__c a3 = new AMS_Agency__c(Name='Test2 Parent Agency',Account__c=acc3.Id, Country__c = isoc.id);
        AMS_Agency__c a4 = new AMS_Agency__c(Name='Test2 Child Agency',Account__c=acc4.Id, Country__c = isoc.id);
        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        insert agencylist;

		a1.Name='Update Agency 1';
        a2.Name='Update Agency 2';
        a3.Name='Update Agency 3';
        a4.Name='Update Agency 4';
        update agencylist;    


       Test.startTest();
       AMS_2_MDM_Batch c = new AMS_2_MDM_Batch(query);
       Database.executeBatch(c);
       Test.stopTest();
 
       // Verify merchandise items got deleted
       Integer i = [SELECT COUNT() FROM AMS_Agency_Updates__c];
       System.assertEquals(i, 4);
    }

	
}