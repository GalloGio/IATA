/**
 * Created by Manuel Conde on 04/04/2017.
 */
@IsTest
private class OneIdProvisioningDaemonTest {

    static testMethod void OneIdProvisioningDaemonTest1(){
        List<PermissionSet> psIds = [SELECT Id,name FROM PermissionSet LIMIT 5];
        Id recTypeId = OneIdProvisioningDAO.AppRecordTypesConfig.get('One_Id_Service_Provider_Config__c').get('Service_Bundle');
        One_Id_Service_Provider_Config__c oi = new One_Id_Service_Provider_Config__c(Service_Provider_Name__c = 'Bundle',
                License_Upgrade_Required__c= true,
                Profile_Id__c='a1',
                Description__c='qualquer',
                Is_Active__c = true, Portal_Visible__c = true,
                RecordTypeid = recTypeId, App_Picture_Url__c='oi',
                Customer_Type_Activation__c = 'Airline');
        insert oi;

        One_Id_Service_Provider_Config__c rr = new One_Id_Service_Provider_Config__c (Service_Provider_Name__c = 'App 1', Is_Active__c = true, Portal_Visible__c = true, Service_Bundle__c=oi.id,Customer_Type_Activation__c = 'Airline');
        insert rr;

        One_Id_App_Config_Detail__c r = new One_Id_App_Config_Detail__c (One_Id_Service_Provider_Config__c=rr.id, PermissionSet_SSO__c = psIds[0].name, PermissionSet_Provisioning__c = psIds[1].name );
        insert r;

        One_Id_App_Role_Config__c role = new One_Id_App_Role_Config__c (Role_Name__c = 'Admin', One_Id_App_Config_Detail__c = r.id, Role_Description__c = 'desc');
        insert role;



        One_Id_User_Applications__c anUserApp = new One_Id_User_Applications__c();
        anUserApp.Application__c = r.id;
        anUserApp.One_Id_Service_Provider_Config__c = rr.id;
        anUserApp.One_Id_App_Bundle__c = oi.id;
        anUserApp.Identity_User__c = UserInfo.getUserId();
        anUserApp.Provisioning_Status__c = 'Started';
        //anUserApp.User_Provisioning_Request__c = uprov.id;
        anUserApp.action__c = 'Add';
        anUserApp.App_Key__c = LightningConnectedAppHelper.OneIdBuildUserAppKey(anUserApp);
        insert anUserApp;

        One_Id_Service_Provider_Config__c oi1 = new One_Id_Service_Provider_Config__c(Service_Provider_Name__c = 'Bundle',
                License_Upgrade_Required__c= true,
                Profile_Id__c='a1',
                Description__c='qualquer',
                Is_Active__c = true, Portal_Visible__c = true,
                RecordTypeid = recTypeId, App_Picture_Url__c='oi',
                Customer_Type_Activation__c = 'Airline');
        insert oi1;

        One_Id_Service_Provider_Config__c rr1 = new One_Id_Service_Provider_Config__c (Service_Provider_Name__c = 'App 1', Is_Active__c = true, Portal_Visible__c = true, Service_Bundle__c=oi1.id,Customer_Type_Activation__c = 'Airline');
        insert rr1;

        One_Id_App_Config_Detail__c r1 = new One_Id_App_Config_Detail__c (One_Id_Service_Provider_Config__c=rr1.id, PermissionSet_SSO__c = psIds[0].name, PermissionSet_Provisioning__c = psIds[1].name );
        insert r1;

        One_Id_App_Role_Config__c role1 = new One_Id_App_Role_Config__c (Role_Name__c = 'Admin', One_Id_App_Config_Detail__c = r1.id, Role_Description__c = 'desc');
        insert role1;

        One_Id_User_Applications__c anUserApp1 = new One_Id_User_Applications__c();
        anUserApp1.Application__c = r1.id;
        anUserApp1.One_Id_Service_Provider_Config__c = rr1.id;
        anUserApp1.One_Id_App_Bundle__c = oi1.id;
        anUserApp1.Identity_User__c = UserInfo.getUserId();
        anUserApp1.Provisioning_Status__c = 'Started';
        anUserApp1.action__c = 'Remove';
        //anUserApp.User_Provisioning_Request__c = uprov.id;
        anUserApp1.App_Key__c = LightningConnectedAppHelper.OneIdBuildUserAppKey(anUserApp1);
        insert anUserApp1;

        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // setup the data for the email
        email.subject = '100';
        email.plainTextBody = 'test';

        // call the email service class and test it with the data in the testMethod
        OneIdProvisioningDaemon emailProcess = new OneIdProvisioningDaemon();
        emailProcess.handleInboundEmail(email, env);

    }
}