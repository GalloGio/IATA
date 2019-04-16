@isTest
public class ANG_ProgressBar_Test {

    public static testMethod void test1() {
        Case cse = new Case();
        insert cse;

        Test.StartTest();
        ANG_ProgressBarHelper helper = new ANG_ProgressBarHelper(cse);
        ANG_ProgressBar pb = new ANG_ProgressBar();
        pb.helper = helper;
        Test.StopTest();
    }

    public static testMethod void test2() {
        Account account = new Account(
            Name = 'test account',
            RecordtypeId = RecordTypeSingleton.getInstance().getRecordType('Account','IATA_Agency').Id
        );
        insert account;

        AMS_Oscar__c oscar = new AMS_Oscar__c(
            RecordtypeId = RecordTypeSingleton.getInstance().getRecordType('AMS_OSCAR__c','ANG_New_HE').Id,
            Process__c='ANG.NEW.HE.STANDARD.1.0',
            Account__c = account.Id
        );
        insert oscar;

        Case cse = new Case(
            RecordtypeId = RecordTypeSingleton.getInstance().getRecordType('Case','OSCAR_Communication').Id,
            Status='Draft',
            OSCAR__c = oscar.Id
        );
        insert cse;
        cse = [SELECT ID, RecordType.DeveloperName FROM case WHERE Id=:cse.Id];

        Test.StartTest();
        ANG_ProgressBarHelper helper = new ANG_ProgressBarHelper(cse);
        ANG_ProgressBar pb = new ANG_ProgressBar();
        pb.helper = helper;
        Test.StopTest();
    }
}