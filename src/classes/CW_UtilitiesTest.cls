@isTest
public class CW_UtilitiesTest {

    @istest
    static void testGetMetadataInfo(){
        
        test.startTest();
    	Portal_Identity_Data__mdt mtdResult = CW_Utilities.getMetadataInfo('Twitter');
        test.stopTest();

        System.assertEquals(mtdResult.MasterLabel, 'Twitter');
        System.assertEquals(mtdResult.DeveloperName, 'Twitter');
    }
}