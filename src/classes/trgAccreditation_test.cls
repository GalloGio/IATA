@isTest
public class trgAccreditation_test {

    @isTest  
    static void test1()
    {
        User testUser = IECTestUtil.createSampleStandardUser();

        System.runAs(testUser) {
        	Accreditation__c acc = new Accreditation__c();
            insert acc;
        }
    }
}
