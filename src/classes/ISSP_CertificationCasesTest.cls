@isTest
public class ISSP_CertificationCasesTest {

    @testSetup static void setup(){
        AMS_OSCAR_TestDataFactory.createCargoAgencyOSCARtestData();
    }

    public static testMethod void testISSP_CertificationCases() {
        Test.startTest();
        ISSP_CertificationCases cttr = new ISSP_CertificationCases();
        ISSPCaseListView__c cs = new ISSPCaseListView__c();
        cs.Name = 'ISSP_Certifications';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_Certifications';
        insert cs;
        
        Account acc1 = new Account();
        acc1.Name = 'HO Account 1';
        acc1.Type = 'IATA Cargo Agent';
        acc1.IATACode__c = '1234567';
        acc1.Location_Type__c = 'HO';
        acc1.Is_your_firm_handling_Dangerous_Goods__c = 'No';
        acc1.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Standard Account').RecordTypeId;
        insert acc1;
        Test.stopTest();
/*
        Account acc2 = new Account();
        acc2.Name = 'BR Account 1';
        acc2.Type = 'IATA Cargo Agent2';
        acc2.IATACode__c = '1234568';
        acc2.Location_Type__c = 'BR';
        acc2.Is_your_firm_handling_Dangerous_Goods__c = 'No';
        acc2.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Standard Account').RecordTypeId;
        acc2.ParentId = acc1.Id;
        insert acc2;
*/
        AMS_Agency_Regulation__c certificate1 = new AMS_Agency_Regulation__c(Last_Name__c = 'test1', Account__c = acc1.Id, Expiry_Date__c = Date.today().addDays(365), Type_of_Certificate__c = 'DGR', Is_your_firm_handling_Dangerous_Goods__c = 'No');
        insert certificate1;
//        AMS_Agency_Regulation__c certificate2 = new AMS_Agency_Regulation__c(Last_Name__c = 'test2', Account__c = acc2.Id, Expiry_Date__c = Date.today().addDays(365), Type_of_Certificate__c = 'DGR', Is_your_firm_handling_Dangerous_Goods__c = 'No');
//        insert certificate2;
        
        cttr.initialization();
        
        map<String, list<AMS_Agency_Regulation__c>> m = cttr.listCases;
        
        cttr.getCases();
        cttr.refresh();

        cttr.searchText = 'test';
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

        try{
            cttr.next();
        }catch(Exception e){}
        try{
            cttr.first();
        }catch(Exception e){}
        try{
            cttr.last();
        }catch(Exception e){}
        try{
            cttr.previous();
        }catch(Exception e){}
        try{
            Integer i = cttr.listCasesSize;
        }catch(Exception e){}
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