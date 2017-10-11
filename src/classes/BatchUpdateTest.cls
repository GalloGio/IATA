@isTest
private class BatchUpdateTest {
    private static final Integer  BATCH_SIZE = 100;

    static testMethod void testBatch() {
        // load test data
        list<Account> myList = new List<Account>();
        for (Integer i=0; i<BATCH_SIZE; i++) {
            myList.add(new Account(Name='test'+i));
        }
        insert myList;

        // run batch
        Test.StartTest();
        BatchUpdate.run(myList, BATCH_SIZE);
        Test.StopTest();
    }

 }
