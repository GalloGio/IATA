@IsTest
public  class GADM_TabsContainerController_TEST {


    @IsTest
    private static void checkSessionCachePositiveTest() {

        Cache.SessionPartition sessionPartition = Cache.Session.getPartition('local.ServiceUsage');
        sessionPartition.put(UserInfo.getUserId()+'HOME', true);

        Boolean presentInCache;

        Test.startTest();

            presentInCache = GADM_TabsContainerController.checkSessionCache(UserInfo.getUserId(), 'HOME');

        Test.stopTest();

        System.assertEquals(true, presentInCache, 'Key is not preset in cache but should be!');

    }

    @IsTest
    private static void checkSessionCacheNegativeTest() {

        Boolean presentInCache;

        Test.startTest();

            presentInCache = GADM_TabsContainerController.checkSessionCache(UserInfo.getUserId(), 'HOME');

        Test.stopTest();

        System.assertEquals(false, presentInCache, 'Key is present in cache but should not be!');

    }

}