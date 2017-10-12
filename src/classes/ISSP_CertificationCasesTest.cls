@isTest
public class ISSP_CertificationCasesTest {

    public static testMethod void testISSP_CertificationCases() {
        ISSP_CertificationCases cttr = new ISSP_CertificationCases();
        ISSPCaseListView__c cs = new ISSPCaseListView__c();
        cs.Name = 'ISSP_Certifications';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_Certifications';
        insert cs;
        cttr.initialization();
        cttr.getCases();
        cttr.refresh();
        
        cttr.getSortDirection();
        cttr.isPWCProfile = false;
        cttr.isDPCUser = false;
        cttr.conId = '123'; 
        cttr.communityName = '123'; 

        cttr.setSortDirection('DESC');
        system.assertEquals('DESC', cttr.getSortDirection());
        cttr.sortExpression = 'ASC';
        cttr.sortExpression = 'ASC';
    }
    
    //public static testMethod void testISSP_CertificationCases_2() {
    //    ISSP_CertificationCases cttr = new ISSP_CertificationCases();
    //    ISSPCaseListView__c cs = new ISSPCaseListView__c();
    //    cs.Name = 'ISSP_Certifications';
    //    cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
    //    cs.Field_Set_API_Name__c = 'ISSP_Certifications';
    //    cs.Permission_set__c = '0PS200000004CryGAE';
    //    insert cs;
    //    cttr.initialization();
    //    cttr.getCases();
    //    cttr.refresh();
        
    //    cttr.setSortDirection('DESC');
    //    system.assertEquals('DESC', cttr.getSortDirection());
    //    cttr.sortExpression = 'ASC';
    //}
    
    //public static testMethod void testISSP_CertificationCases_oldMethod() {
    //    ISSP_CertificationCases cttr = new ISSP_CertificationCases();
    //    cttr.initialization();
    //    cttr.getCases();
    //    cttr.refresh();
    //    ISSPCaseListView__c cs = new ISSPCaseListView__c();
    //    cs.Name = 'Test';
    //    cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
    //    insert cs;
    //    cttr = new ISSP_CertificationCases();
        
    //    cttr.setSortDirection('DESC');
    //    system.assertEquals('DESC', cttr.getSortDirection());
    //    cttr.sortExpression = 'ASC';
    //}

}