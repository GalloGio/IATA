@isTest(SeeAllData=true)


private class ProvisionKaviAccessTest {
    
    // Dataset
    static user KPUser;
    static user NKPUser;
    static user me;
    static {
        //KPUser = [SELECT id, profile.Name FROM User WHERE profile.Name = 'KaviProvisioningUser' limit 1][0];
        KPUser = [SELECT id, profile.Name FROM User WHERE Is_Kavi_Internal_User__c = true limit 1][0];
        insert new Portal_Applications__c (Name = 'Standards Setting Workspace');
        //NKPUser = [SELECT id, profile.Name FROM User WHERE profile.Name != 'KaviProvisioningUser' limit 1][0];
        NKPUser = [SELECT id, profile.Name FROM User WHERE Is_Kavi_Internal_User__c = false limit 1][0];
        me = [SELECT id FROM User WHERE id =: UserInfo.getUserId() limit 1];
        List<ISSP_Kavi_Settings__c> isspkslist = new List<ISSP_Kavi_Settings__c>();
        isspkslist = [Select Id from ISSP_Kavi_Settings__c where Name = 'CLIENT_SECRET'];
        if (isspkslist.size() == 0 ) {insert new ISSP_Kavi_Settings__c(name='CLIENT_SECRET', value__c='9c20a3922688fa22454545c0fee9155e7dfb72df');}
        isspkslist = [Select Id from ISSP_Kavi_Settings__c where Name = 'CLIENT_KEY'];
        if (isspkslist.size() == 0 ) {insert new ISSP_Kavi_Settings__c(name='CLIENT_KEY', value__c='api_admin');}
        isspkslist = [Select Id from ISSP_Kavi_Settings__c where Name = 'CLIENT_ENDPOINT'];
        if (isspkslist.size() == 0 ) {insert new ISSP_Kavi_Settings__c(name='CLIENT_ENDPOINT', value__c=' https://api-sandbox.kavi.com');}
        isspkslist = [Select Id from ISSP_Kavi_Settings__c where Name = 'X_KAVI_SITE'];
        if (isspkslist.size() == 0 ) {insert new ISSP_Kavi_Settings__c(name='X_KAVI_SITE', value__c=' iata.sandbox.kavi.com');}
    }
    
    
    static testMethod void errorTest(){
        //User u2 = [SELECT id, profile.Name FROM User WHERE profile.Name != 'KaviProvisioningUser' limit 1];
        //String userId = u2.id;
        //String profileName = u2.profile.Name;
        
        //System.assertNotEquals('KaviProvisioningUser', u2.profile.Name, 'Error because user is not KaviProvisioningUser profile');
        Test.startTest();
        //Runnin as Admin provisioning a KaviProvisioningUser profile user
        System.runAs(me) {
                Test.setMock(HttpCalloutMock.class, new ProvisionKaviAccessTestWS());
                ProvisionKaviAccess.EnableInternalUserKaviAccess(KPUser.Id, 'KaviProvisioningUser', true);
        }
        Test.stopTest();
    
    }
    
    static testMethod void test1(){
        
        
        //Runnin as Admin provisioning a NON KaviProvisioningUser profile user
        
        
        Test.startTest();
           
           System.debug('Este es el usuario con perfil NO provisioning ' + NKPUser);
           Test.setMock(HttpCalloutMock.class, new ProvisionKaviAccessTestWS());
           System.runAs(me) {

                ProvisionKaviAccess.EnableInternalUserKaviAccess(NKPUser.Id, 'KaviProvisioningUser', true);
        			}
        Test.stopTest();
    
    }

    static testMethod void test2(){
        
        
        //Runnin as Admin provisioning a NON KaviProvisioningUser profile user
        
        
        Test.startTest();
           
           System.debug('Este es el usuario con perfil NO provisioning ' + NKPUser);
           Test.setMock(HttpCalloutMock.class, new ProvisionKaviAccessTestWS());
           System.runAs(me) {

                ProvisionKaviAccess.EnableInternalUserKaviAccess(NKPUser.Id, 'KaviProvisioningUserKO', false);
        			}
        Test.stopTest();
    
    }
    
      
}