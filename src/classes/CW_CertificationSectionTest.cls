@isTest
public class CW_CertificationSectionTest {
    @testSetup
    static void testSetup(){
        // Create the certification
        ICG_Certification__c certification = new ICG_Certification__c(Name__c='Test1',Certification_Type__c='Assessments',is_visible__C = TRUE);
        insert certification;
        ICG_Certification__c certification1 = new ICG_Certification__c(Name__c='Test2',Certification_Type__c='Certifications of Excellency',is_visible__C = TRUE);
        insert certification1;
	}

    @istest
    static void testGetCertifications(){
        
        test.startTest();
        // Without parameters
    	List<ICG_Certification__c> resultNoParams = CW_CertificationSection.getCertifications('','');
        System.assertEquals(resultNoParams.size() == 2, true);
        // With Name parameter
    	List<ICG_Certification__c> resultTypeParam = CW_CertificationSection.getCertifications('Assessments','');
        System.assertEquals(resultTypeParam.size() == 1, true);
        // With Type parameter
    	List<ICG_Certification__c> resultNameParam = CW_CertificationSection.getCertifications('','Test1');
        System.assertEquals(resultNameParam.size() == 1, true);
        // With both parameters
    	List<ICG_Certification__c> resultAllParams = CW_CertificationSection.getCertifications('Assessments','Test1');
        System.assertEquals(resultAllParams.size() == 1, true);
        test.stopTest();

        
    }
}