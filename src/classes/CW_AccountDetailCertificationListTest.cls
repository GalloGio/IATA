@IsTest
private class CW_AccountDetailCertificationListTest {
    
    @IsTest
    static void testCertificationList(){
        
        Account acc = new Account();
        acc.Name = 'Test testersen';

        insert acc;

        ICG_Certification__c cert = new ICG_Certification__c();
        cert.is_visible__C = true;
        cert.Name__c = 'TestCert';
        cert.Certification_Type__c = 'Assessments';

        insert cert;

        ICG_Certification__c cert2 = new ICG_Certification__c();
        cert2.is_visible__C = true;
        cert2.Name__c = 'TestCert2';
        cert2.Certification_Type__c = 'Assessments';
        insert cert2;

        ICG_Certification__c cert3 = new ICG_Certification__c();
        cert3.is_visible__C = true;
        cert3.Name__c = 'TestCert3';
        cert3.Certification_Type__c = 'Assessments';
        insert cert3;

        Account_Role__c accRole = new Account_Role__c();
        accRole.Account__c = acc.Id;
        insert accRole;

        ICG_Account_Role_Detail__c roleDetail = new ICG_Account_Role_Detail__c();
        roleDetail.name = acc.name;
        roleDetail.Account_Role__c = accRole.Id;
        insert roleDetail;

        ICG_Account_Role_Detail_Certification__c certDetail = new ICG_Account_Role_Detail_Certification__c();
        certDetail.Certification__r = cert;
        certDetail.ICG_Account_Role_Detail__r = roleDetail;
        certDetail.ICG_Account_Role_Detail__c = roleDetail.id;
        certDetail.Certification__c = cert.Id;
        insert certDetail;

        Map<Boolean, List<ICG_Certification__c>> resultMap = CW_AccountDetailCertificationList.getCertificationList(acc.Name);

        System.assertEquals(2, resultMap.keySet().size(), 'The amount of keys in the map is incorrect');
        
    }

    @IsTest
    static void testCertificationListShouldBeAllFalse(){
        
        Account acc = new Account();
        acc.Name = 'Test testersen';

        insert acc;

        ICG_Certification__c cert = new ICG_Certification__c();
        cert.is_visible__C = true;
        cert.Name__c = 'TestCert';
        cert.Certification_Type__c = 'Assessments';

        insert cert;

        Map<Boolean, List<ICG_Certification__c>> resultMap = CW_AccountDetailCertificationList.getCertificationList(acc.Name);

        System.assertEquals(1, resultMap.keySet().size(), 'The amount of keys in the map is incorrect');
        for(Boolean exists : resultMap.keySet()){
            System.assert(!exists, 'Value should be false');
        }
        
    }

}