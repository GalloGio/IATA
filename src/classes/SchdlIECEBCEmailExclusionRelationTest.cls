@isTest
private class SchdlIECEBCEmailExclusionRelationTest {

    static testMethod void testBatch() {

        EBC_Email_Exclusion__c ee1 = new EBC_Email_Exclusion__c();
        ee1.Is_Relation_Created__c = true;
        ee1.Email__c = 'email@ebc.com';
        insert ee1;

        EBC_Email_Exclusion__c ee2 = new EBC_Email_Exclusion__c();
        ee2.Is_Relation_Created__c = true;
        ee2.Email__c = 'card@ebc.com';
        insert ee2;

        GDP_Products_Account_View__c gav = new GDP_Products_Account_View__c();
        gav.Email_Address__c = 'email@ebc.com';
        insert gav;

        ID_Card__c idc = new ID_Card__c();
        idc.Email__c = 'card@ebc.com';
        idc.Name_on_ID_Card__c = 'name on card';
        insert idc;

        Test.startTest();

        SchdlIECEBCEmailExclusionRelation obj1 = new SchdlIECEBCEmailExclusionRelation();
        DataBase.executeBatch(obj1);

        SchdlIECEBCEmailExclusionRelation sh1 = new SchdlIECEBCEmailExclusionRelation();
        String sch = '0 0 23 * * ?'; system.schedule('Test', sch, sh1);

        Test.stopTest();

    }
}