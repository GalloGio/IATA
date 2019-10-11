@isTest
public class EBC_Batch_Test {

     /*
     Author: Abdellah Bellahssan
     This test class is to test the batch to retrieve agency and Agent total counters
     //to check if the sync process to Eleasticsearch database has worked properly
    */
    public static testmethod void TestEBC_ElasticsearchSyncCountersBatch() {

        //Act
        Test.StartTest();
        EBC_Setup__c setup = new EBC_Setup__c();
        
        setup.name='default';
        insert setup;

        String jobname = 'EBC_Schdl_CheckElasticSearchSync_Test';
        EBC_Schdl_CheckElasticSearchSync btch = new EBC_Schdl_CheckElasticSearchSync();
       
        Datetime nextScheduleTime = system.now().addSeconds(2);
        string month = string.valueof(nextScheduleTime.month());
        string day = string.valueof(nextScheduleTime.day());
        string hour = string.valueof(nextScheduleTime.hour());
        string minute = string.valueof(nextScheduleTime.minute());
        string second = string.valueof(nextScheduleTime.second());
        string cronvalue = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
        
        system.debug('****jobname****'+jobname);
        system.debug('****cronvalue****'+cronvalue);
        system.debug('****btch****'+btch);
        
        String jobID = System.schedule(jobname, cronvalue, btch);
        System.debug('Returned Job Id: ' + jobID);

        Test.StopTest();
        
    }
}