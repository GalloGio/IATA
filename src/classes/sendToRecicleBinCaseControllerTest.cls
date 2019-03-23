@isTest
private class sendToRecicleBinCaseControllerTest {
        @TestSetup static void setupdata(){
          Group g1 = new Group(Name='Recycle Bin Europe', type='Queue');
        insert g1;

        
        }
       @IsTest  static void testSendToRecicleBin(){
        
        Test.startTest();
            Account acc= new Account(
                name='Acc 1',
                region__c='Europe'
            );
            insert acc;
            case c= new case(
                accountId =acc.id,
                region__c ='Europe'
            );  
            insert c;

        string res=sendToRecicleBinCaseController.findRecycleQueue(c.id);

        group q=[select id from group where name ='Recycle Bin Europe'].get(0);
        test.stopTest();

        //Empty parameter check
        system.assertEquals('',sendToRecicleBinCaseController.findRecycleQueue(''));

        //moves succefully to the correct Recycle bin queue
        system.assertEquals(String.valueOf(q.id),sendToRecicleBinCaseController.findRecycleQueue(c.id));

        c.region__c='Narnia';
        update c;

        //not existing recycle bin for this region
        system.assertEquals('',sendToRecicleBinCaseController.findRecycleQueue(c.id));



    }
}
