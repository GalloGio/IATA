@isTest
private class ISSP_Create_External_Users_Test {

    static testMethod void myUnitTest() {
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        insert con;
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        ISSP_CASSLink_Users__c cass = new ISSP_CASSLink_Users__c();
        cass.Contact__c = con.Id;
        cass.Email__c = con.Email;
        cass.To_Create_New_User__c = true;
        insert cass;
        
        
        String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal (Partner)'].Id;
        ISSP_CS__c profileCS = new ISSP_CS__c();
        profileCS.Name = 'ISS_Portal';
        profileCS.Value__c = profileId;
        insert profileCS;
        ISSP_CS__c profileCS2 = new ISSP_CS__c();
        profileCS2.Name = 'Host';
        profileCS2.Value__c = 'iata.org';
        insert profileCS2;

        Test.startTest();
        ISSP_Create_External_Users.scheduleName('test','0 02 * * * ?');

        ISSP_Create_External_Users.scheduleIt();
        ISSP_Create_External_Users.scheduleIt('0 04 * * * ?');
        
        Test.stopTest();
        
        //ISSP_Create_External_Users.scheduleIt();
        //ISSP_Create_External_Users.scheduleIt('0 02 * * * ?');
    }
    
    static testMethod void myUnitTest_ASD() {
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        insert con;
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        ISSP_ASD_Users__c asd = new ISSP_ASD_Users__c();
        asd.Contact__c = con.Id;
        asd.Email__c = con.Email;
        asd.To_Create_New_User__c = true;
        insert asd;
        
        
        String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal (Partner)'].Id;
        ISSP_CS__c profileCS = new ISSP_CS__c();
        profileCS.Name = 'ISS_Portal';
        profileCS.Value__c = profileId;
        insert profileCS;
        ISSP_CS__c profileCS2 = new ISSP_CS__c();
        profileCS2.Name = 'Host';
        profileCS2.Value__c = 'iata.org';
        insert profileCS2;

        Test.startTest();
        ISSP_Create_External_Users_ASD.scheduleName('test','0 02 * * * ?');

        ISSP_Create_External_Users_ASD.scheduleIt();
        ISSP_Create_External_Users_ASD.scheduleIt('0 04 * * * ?');
        Test.stopTest();
        
        //ISSP_Create_External_Users_ASD.scheduleIt();
        //ISSP_Create_External_Users_ASD.scheduleIt('0 02 * * * ?');
    }
    
    static testMethod void myUnitTest_SIS() {
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        insert con;
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        ISSP_SIS_Users__c asd = new ISSP_SIS_Users__c();
        asd.Contact__c = con.Id;
        asd.Email__c = con.Email;
        asd.To_Create_New_User__c = true;
        insert asd;
        
        
        String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal (Partner)'].Id;
        ISSP_CS__c profileCS = new ISSP_CS__c();
        profileCS.Name = 'ISS_Portal';
        profileCS.Value__c = profileId;
        insert profileCS;
        ISSP_CS__c profileCS2 = new ISSP_CS__c();
        profileCS2.Name = 'Host';
        profileCS2.Value__c = 'iata.org';
        insert profileCS2;

        Test.startTest();
        ISSP_Create_External_Users_SIS.scheduleName('test','0 02 * * * ?');

        ISSP_Create_External_Users_SIS.scheduleIt();
        ISSP_Create_External_Users_SIS.scheduleIt('0 04 * * * ?');
        Test.stopTest();
        
        //ISSP_Create_External_Users_SIS.scheduleIt();
        //ISSP_Create_External_Users_SIS.scheduleIt('0 02 * * * ?');
    }
    
    static testMethod void myUnitTest_BSP() {
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        insert con;
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        ISSP_BSPLink_Users__c asd = new ISSP_BSPLink_Users__c();
        asd.Contact__c = con.Id;
        asd.Email__c = con.Email;
        asd.To_Create_New_User__c = true;
        insert asd;
        
        
        String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal (Partner)'].Id;
        ISSP_CS__c profileCS = new ISSP_CS__c();
        profileCS.Name = 'ISS_Portal';
        profileCS.Value__c = profileId;
        insert profileCS;
        ISSP_CS__c profileCS2 = new ISSP_CS__c();
        profileCS2.Name = 'Host';
        profileCS2.Value__c = 'iata.org';
        insert profileCS2;

        Test.startTest();
        ISSP_Create_External_Users_BSP.scheduleName('test','0 02 * * * ?');

        ISSP_Create_External_Users_BSP.scheduleIt();
        ISSP_Create_External_Users_BSP.scheduleIt('0 04 * * * ?');
        Test.stopTest();
        
        //ISSP_Create_External_Users_BSP.scheduleIt();
        //ISSP_Create_External_Users_BSP.scheduleIt('0 02 * * * ?');
    }
}