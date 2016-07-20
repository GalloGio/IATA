//This test class is the unit test for AMS-129
@isTest
public class AMS_2_MDM_WebserviceTest {
    
    public static testmethod void test_getAgencyList() {
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(Name='Test1 Account');
        Account acc2 = new Account(Name='Test2 Account');
        Account acc3 = new Account(Name='Test3 Account');
        Account acc4 = new Account(Name='Test4 Account');
        accountList.add(acc1);
        accountList.add(acc2);
        accountList.add(acc3);
        accountList.add(acc4);
        insert accountList;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;
            
        List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
        AMS_Agency__c ag1 = new AMS_Agency__c(Name='Test1 Agency',Account__c=acc1.Id, Country__c = isoc.id);
        AMS_Agency__c ag2 = new AMS_Agency__c(Name='Test2 Agency',Account__c=acc2.Id, Country__c = isoc.id);
        AMS_Agency__c ag3 = new AMS_Agency__c(Name='Test3 Agency',Account__c=acc3.Id, Country__c = isoc.id);
        AMS_Agency__c ag4 = new AMS_Agency__c(Name='Test4 Agency',Account__c=acc4.Id, Country__c = isoc.id);
        agencylist.add(ag1);
        agencylist.add(ag2);
        agencylist.add(ag3);
        agencylist.add(ag4);
        insert agencylist;

        ag1.Name='Update Agency 1';
        ag2.Name='Update Agency 2';
        ag3.Name='Update Agency 3';
        ag4.Name='Update Agency 4';
        update agencylist;    

        Test.startTest();
        List<Id> result = AMS_2_MDM_Webservice.getUpdatedAgenciesList(null,null);
        system.assertEquals(4, result.size());
        Map<Id,Id> mapResult = new Map<Id,Id>();
        for(Id theId: result){
            mapResult.put(theId, theId);
        }
        system.assert(mapResult.get(ag1.Id) != null);
        system.assert(mapResult.get(ag2.Id) != null);
        system.assert(mapResult.get(ag3.Id) != null);
        system.assert(mapResult.get(ag4.Id) != null);
        Test.stopTest();
    }
    
    public static testmethod void test_getHierarchyList() {
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(Name='Test1 Account');
        Account acc2 = new Account(Name='Test2 Account');
        Account acc3 = new Account(Name='Test3 Account');
        Account acc4 = new Account(Name='Test4 Account');
        accountList.add(acc1);
        accountList.add(acc2);
        accountList.add(acc3);
        accountList.add(acc4);
        insert accountList;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;

        List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
        AMS_Agency__c a1 = new AMS_Agency__c(Name='Test1 Parent Agency',Account__c=acc1.Id, Country__c = isoc.id);
        AMS_Agency__c a2 = new AMS_Agency__c(Name='Test1 Child Agency',Account__c=acc2.Id, Country__c = isoc.id);
        AMS_Agency__c a3 = new AMS_Agency__c(Name='Test2 Parent Agency',Account__c=acc3.Id, Country__c = isoc.id);
        AMS_Agency__c a4 = new AMS_Agency__c(Name='Test2 Child Agency',Account__c=acc4.Id, Country__c = isoc.id);
        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        insert agencylist;

        List<AMS_Agencies_Hierarchy__c> hierachieslist = new List<AMS_Agencies_Hierarchy__c>();
        AMS_Agencies_Hierarchy__c ah1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Test Hierarchy');
        AMS_Agencies_Hierarchy__c ah2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Another Test Hierarchy');
        hierachieslist.add(ah1);
        hierachieslist.add(ah2);
        insert hierachieslist;

        List<AMS_Agencies_relationhip__c> relationshiplist = new List<AMS_Agencies_relationhip__c>();
        AMS_Agencies_relationhip__c ar1 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah1.id,Child_Agency__c=a2.id,Parent_agency__c=a1.id);
        AMS_Agencies_relationhip__c ar2 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah2.id,Child_Agency__c=a4.id,Parent_agency__c=a3.id);
        relationshiplist.add(ar1);
        relationshiplist.add(ar2);
        insert relationshiplist;

        ah1.Hierarchy_Name__c = 'Test update';
        ah2.Hierarchy_Name__c = 'Test update';
        update hierachieslist;

        Test.startTest();
        List<Id> result = AMS_2_MDM_Webservice.getUpdatedHierarchiesList(null,null);
        system.assertEquals(2, result.size());
        Map<Id,Id> mapResult = new Map<Id,Id>();
        for(Id theId: result){
            mapResult.put(theId, theId);
        }
        system.assert(mapResult.get(ah1.Id) != null);
        system.assert(mapResult.get(ah2.Id) != null);
        Test.stopTest();
    }   
    
    
    public static testmethod void test_getAgencyContent() {
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(Name='Test1 Account');
        Account acc2 = new Account(Name='Test2 Account');
        Account acc3 = new Account(Name='Test3 Account');
        Account acc4 = new Account(Name='Test4 Account');
        accountList.add(acc1);
        accountList.add(acc2);
        accountList.add(acc3);
        accountList.add(acc4);
        insert accountList;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;

        List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
        AMS_Agency__c a1 = new AMS_Agency__c(Name='Test1 Parent Agency',Account__c=acc1.Id, Country__c = isoc.id);
        AMS_Agency__c a2 = new AMS_Agency__c(Name='Test1 Child Agency',Account__c=acc2.Id, Country__c = isoc.id);
        AMS_Agency__c a3 = new AMS_Agency__c(Name='Test2 Parent Agency',Account__c=acc3.Id, Country__c = isoc.id);
        AMS_Agency__c a4 = new AMS_Agency__c(Name='Test2 Child Agency',Account__c=acc4.Id, Country__c = isoc.id);
        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        insert agencylist;

        List<AMS_Agencies_Hierarchy__c> hierachieslist = new List<AMS_Agencies_Hierarchy__c>();
        AMS_Agencies_Hierarchy__c ah1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Test Hierarchy');
        AMS_Agencies_Hierarchy__c ah2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Another Test Hierarchy');
        hierachieslist.add(ah1);
        hierachieslist.add(ah2);
        insert hierachieslist;

        List<AMS_Agencies_relationhip__c> relationshiplist = new List<AMS_Agencies_relationhip__c>();
        AMS_Agencies_relationhip__c ar1 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah1.id,Child_Agency__c=a2.id,Parent_agency__c=a1.id);
        AMS_Agencies_relationhip__c ar2 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah2.id,Child_Agency__c=a4.id,Parent_agency__c=a3.id);
        relationshiplist.add(ar1);
        relationshiplist.add(ar2);
        insert relationshiplist;

        ah1.Hierarchy_Name__c = 'Test update';
        ah2.Hierarchy_Name__c = 'Test update';
        update hierachieslist;

        Test.startTest();

        //getAgenciesContent(String GroupID, String ChunkSize , String ChunkKey, String ChunkTotal, List<String> ids)

        String[] r = AMS_2_MDM_Webservice.getAgenciesContent('GroupID','3','ChunkKey','1', new List<String> {a1.Id } );
        String xml = r[5];
        //system.assert(xml!=null);
        Test.stopTest();
    }   

    public static testmethod void test_sendAgencyECC() {
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(Name='Test1 Account');
        Account acc2 = new Account(Name='Test2 Account');
        Account acc3 = new Account(Name='Test3 Account');
        Account acc4 = new Account(Name='Test4 Account');
        accountList.add(acc1);
        accountList.add(acc2);
        accountList.add(acc3);
        accountList.add(acc4);
        insert accountList;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;

        List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
        AMS_Agency__c a1 = new AMS_Agency__c(Name='Test1 Parent Agency',Account__c=acc1.Id, Country__c = isoc.id);
        AMS_Agency__c a2 = new AMS_Agency__c(Name='Test1 Child Agency',Account__c=acc2.Id, Country__c = isoc.id);
        AMS_Agency__c a3 = new AMS_Agency__c(Name='Test2 Parent Agency',Account__c=acc3.Id, Country__c = isoc.id);
        AMS_Agency__c a4 = new AMS_Agency__c(Name='Test2 Child Agency',Account__c=acc4.Id, Country__c = isoc.id);
        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        insert agencylist;

        List<AMS_Agencies_Hierarchy__c> hierachieslist = new List<AMS_Agencies_Hierarchy__c>();
        AMS_Agencies_Hierarchy__c ah1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Test Hierarchy');
        AMS_Agencies_Hierarchy__c ah2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Another Test Hierarchy');
        hierachieslist.add(ah1);
        hierachieslist.add(ah2);
        insert hierachieslist;

        List<AMS_Agencies_relationhip__c> relationshiplist = new List<AMS_Agencies_relationhip__c>();
        AMS_Agencies_relationhip__c ar1 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah1.id,Child_Agency__c=a2.id,Parent_agency__c=a1.id);
        AMS_Agencies_relationhip__c ar2 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah2.id,Child_Agency__c=a4.id,Parent_agency__c=a3.id);
        relationshiplist.add(ar1);
        relationshiplist.add(ar2);
        insert relationshiplist;

        ah1.Hierarchy_Name__c = 'Test update';
        ah2.Hierarchy_Name__c = 'Test update';
        update hierachieslist;

        Test.startTest();

        //getAgenciesContent(String GroupID, String ChunkSize , String ChunkKey, String ChunkTotal, List<String> ids)

        boolean r = AMS_2_MDM_Webservice.sendAgencyECC(a1.Id);
        //system.assert(xml!=null);
        Test.stopTest();
    }   

    
    public static testmethod void test_AMS_2_MDM_WS_AgencyDetails() {

        // instantiate the web service proxy
        AMS_2_MDM_WS_AgencyDetails.HTTP_Port ws = new AMS_2_MDM_WS_AgencyDetails.HTTP_Port();

        // set the timeout to maximum value (60 seconds)
        ws.timeout_x = 60000;

        Blob headerValue = Blob.valueOf('test_username:test_password');
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);

        String s = 'some XML message';
        String sRespStatusCode = '';

        // Call SAP web service
        sRespStatusCode = ws.SI_SFDC_AgenciesData_OB_Http(s,authorizationHeader);

        system.assert(sRespStatusCode=='200');
    }

    public static testmethod void test_AMS_2_MDM_WS_AgencyList() {

        // instantiate the web service proxy
        AMS_2_MDM_WS_AgencyList.HTTP_Port ws = new AMS_2_MDM_WS_AgencyList.HTTP_Port();
    
        // set the timeout to maximum value (60 seconds)
        ws.timeout_x = 60000;

        Blob headerValue = Blob.valueOf('test_username:test_password');
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);

        String s = 'some XML message';
        String sRespStatusCode = '';

        // Call SAP web service
        sRespStatusCode = ws.SI_SFDC_AgencyList_OB_Http(s,authorizationHeader);

        system.assert(sRespStatusCode=='200');
    }
}