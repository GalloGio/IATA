@IsTest
public class Service_Usage_Tracker_CTRL_TEST {

    @TestSetup
    private static void setup() {

    }

    @IsTest
    private static void saveNewCacheEntryTest() {


        Test.startTest();

            Boolean success = Service_Usage_Tracker_CTRL.saveNewCacheEntry(UserInfo.getUserId(), 'HOME');

        Test.stopTest();

        System.assertEquals(true, success, 'Key was not saved in session cache!');
        Cache.SessionPartition sessionPartition = Cache.Session.getPartition('local.ServiceUsage');
        Set<String> allKeys = sessionPartition.getKeys();
        System.assertEquals(true, allKeys.contains(UserInfo.getUserId()+'HOME'), 'Given key is not found in session cache!');
    }

    @IsTest
    private static void saveUsageTrackingTest() {


        Test.startTest();

            Boolean saved = Service_Usage_Tracker_CTRL.saveUsageTracking(UserInfo.getUserId(), 'HOME', 'GADM', 'Page');

        Test.stopTest();

        System.assertEquals(true, saved);

        List<Service_Usage__c> savedUsages = [SELECT Id, User__c, Target__c, Service__c FROM Service_Usage__c];
        System.assertEquals(1, savedUsages.size(), 'Incorrect number of Service_Usage__c objects retrieved!');
        System.assertEquals(UserInfo.getUserId(), savedUsages[0].User__c, 'User__c on Service_Usage__c object does not match!');
        System.assertEquals('HOME', savedUsages[0].Target__c, 'Target__c on Service_Usage__c object does not match!');
        System.assertEquals('GADM', savedUsages[0].Service__c, 'Service__c on Service_Usage__c object does not match!');
    }

    @IsTest
    private static void saveUsageTracking_falseTest() {

        String loger255 = 'This string is very very very very very very very very very very very very very very very ' +
                'very very very very very very very very very very very very very very very very very very. This string' +
                'is very very very very very very very very very very very very very very vevy very very very very very' +
                ' very very very very very very very very very very very very very long.';


        Test.startTest();

        Boolean saved = Service_Usage_Tracker_CTRL.saveUsageTracking(null, loger255, 'GADM', 'Page');

        Test.stopTest();

        System.assertEquals(false, saved);

        List<Service_Usage__c> savedUsages = [SELECT Id, User__c, Target__c, Service__c FROM Service_Usage__c];
        System.assertEquals(0, savedUsages.size(), 'Incorrect number of Service_Usage__c objects retrieved!');

    }

}