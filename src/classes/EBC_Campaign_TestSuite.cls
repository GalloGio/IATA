@isTest (seeAllData=true)
public class EBC_Campaign_TestSuite {
    public static testMethod void testElasticQuery1() {
        EBC_Campaign_Test.testElasticQuery(false,false);
    }  
    public static testMethod void testElasticQuery2() {
        EBC_Campaign_Test.testElasticQuery(true,false);
    }  
    public static testMethod void testElasticQuery3() {
        EBC_Campaign_Test.testElasticQuery(false,true);
    }  
    public static testMethod void testElasticQuery4() {
        EBC_Campaign_Test.testElasticQuery(true,true);
    }  
}