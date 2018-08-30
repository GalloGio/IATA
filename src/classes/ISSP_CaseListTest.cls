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

    // cover the extra features for DPC: myOwnCases and myCompanyCases
    public static testMethod void testDPC() {
        // pick a portal user to test as
        User testUser = [SELECT Id, ProfileId FROM User WHERE ContactId != null AND isActive = true LIMIT 1];
        String profId = (String)testUser.ProfileId; // (String)testUser.ProfileId.substring(0,15)
        profId = profId.substring(0,15);
        ISSPCaseListView__c cs = new ISSPCaseListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = profId; //Userinfo.getProfileId()
        cs.Field_Set_API_Name__c = 'ISSP_AllClosedCases';
        cs.SOQL_Filter__c = 'where id != null ';
        cs.isOwnedByMe__c = true;
        cs.isMyAccount__c = true;
        insert cs;
        System.runAS(testUser) {
            ISSP_CaseList cttr = new ISSP_CaseList();
            // cttr = new ISSP_CaseList();
            cttr.initialization();
            cttr.getCases();
            cttr.refresh();

            cttr.setSortDirection('DESC');
            system.assertEquals('DESC', cttr.getSortDirection());
            cttr.sortExpression = 'ASC';
        }

    }

 public static testMethod void testISSP_CaseList_http() {
        ISSP_CaseList cttr = new ISSP_CaseList();
        ISSPCaseListView__c cs = new ISSPCaseListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_AllClosedCases';
        insert cs;
        cttr.initialization();
        cttr.getCases();
        cttr.refresh();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/newgenapp/v1/getCaseList';
        req.httpMethod = 'GET';
        req.addParameter('filterKey', 'ASC');
        req.addParameter('page', '1');

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            ISSP_CaseList.doGet();
        Test.stopTest();
        //ISSP_CaseList.doGet();
    }    

}