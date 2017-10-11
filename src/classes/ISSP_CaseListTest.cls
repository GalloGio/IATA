@isTest
public class ISSP_CaseListTest {

    public static testMethod void testISSP_CaseList() {
        ISSP_CaseList cttr = new ISSP_CaseList();
        ISSPCaseListView__c cs = new ISSPCaseListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_AllClosedCases';
        insert cs;
        cttr.initialization();
        cttr.getCases();
        cttr.refresh();
        
        cttr.setSortDirection('DESC');
        system.assertEquals('DESC', cttr.getSortDirection());
        cttr.sortExpression = 'ASC';
        cttr.isPWCProfile = false;
        cttr.isDPCUser = false;
        String communityName = cttr.communityName;        
    }
    
    public static testMethod void testISSP_CaseList_2() {
        ISSP_CaseList cttr = new ISSP_CaseList();
        ISSPCaseListView__c cs = new ISSPCaseListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_AllClosedCases';
        cs.Permission_set__c = '0PS200000004CryGAE';
        insert cs;
        cttr.initialization();
        cttr.getCases();
        cttr.refresh();
        
        cttr.setSortDirection('DESC');
        system.assertEquals('DESC', cttr.getSortDirection());
        cttr.sortExpression = 'ASC';
    }
    
    public static testMethod void testISSP_CaseList_oldMethod() {
        ISSP_CaseList cttr = new ISSP_CaseList();
        cttr.initialization();
        cttr.getCases();
        cttr.refresh();
        ISSPCaseListView__c cs = new ISSPCaseListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        insert cs;
        cttr = new ISSP_CaseList();
        
        cttr.setSortDirection('DESC');
        system.assertEquals('DESC', cttr.getSortDirection());
        cttr.sortExpression = 'ASC';
    }

}