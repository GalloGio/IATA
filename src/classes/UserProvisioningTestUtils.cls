@isTest
public with sharing class UserProvisioningTestUtils {

    // some plugins expect / assume a number
    public static final String EXTERNAL_USER_ID = '1234';

    public static Process.PluginResult runPlugin(UserProvisioning.UserProvisioningPlugin plugin,
        Map<String,Object> inputParams) {

        Process.PluginDescribeResult describeResult = plugin.buildDescribeCall();

        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        System.Test.startTest();
        Process.PluginResult response = plugin.invoke(request);
        System.Test.stopTest();

        return response;
    }
    
    public static UserProvisioningRequest createUserProvisioningRequest(String appName, String operation) {
        return createUserProvisioningRequest(appName, operation, 'New');
    }

    public static UserProvisioningRequest createUserProvisioningRequest(String appName, String operation, String status) {
        
        // Create a test user - changes will be reverted automatically by Salesforce        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        User user = new User(
            userName = 'john.doeQWERT4567@example.org', 
            email = 'john.doeQWERT4567@example.org', 
            firstName = 'John',
            lastName = 'Doe',
            profileId = p.id,
            alias = 'johndoe', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'ISO-8859-1', 
            LanguageLocaleKey = 'en_US',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert user;

        //Manuel Conde
        List<PermissionSet> psIds = [SELECT Id,name FROM PermissionSet LIMIT 2];
        Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');

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


        // Suffix the appName argument so we are not colliding with Connected Apps
        // already in the system when ConnectedTestUtil is implemented by SFDC.
        // For now our stubbed createConnectedApp() will know to strip the suffix
        // and then perform the SOQL query.
       
        Id cAppId = getConnectedApp(appName);
        
        // Build user provisioning account linked to the test user
        UserProvAccount upa = new UserProvAccount(
            salesforceUserId = user.id, 
            connectedAppId = cAppId,
            externalUserId = EXTERNAL_USER_ID, 
            externalUserName = 'john.doe@example.org',
            externalFirstName = 'John', 
            externalLastName = 'Doe',
            linkState = 'Linked', 
            status = 'Active'
        );
        insert upa;
        
        // Build user provisioning request linked to the test user
        UserProvisioningRequest upr = new UserProvisioningRequest(
            connectedAppId = cAppId,
            salesforceUserId = user.id,
            operation = operation, 
            state = status, 
            approvalStatus = 'NotRequired'
            
            // can uncomment below once SFDC populates this field
            // as of 1/29/2016 this code path is not followed
            //
            // see UserProvisioningUtils.getLinkedUserProvAccount()
            //
            // MUST CHANGE UserProvisioningUtilsTest.testDeletedLinkedUserProvAccount()
            // in conjunction
            
            //, UserProvAccountId = upa.id
        );
        insert upr;

        return upr;
    }
    
    //Generates a test connected app
    public static Id getConnectedApp(String AppName){
    
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
        String fullAppName = appName + '|4t8izz2t';
        ConnectedApplication capp = UserProvisioning.ConnectorTestUtil.createConnectedApp(fullAppName);
        return capp.id;
        }
    return null;
    }

    
    public static UserProvisioningRequest userProvisioningRequestVM (String appName, String operation, String status){

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        
        insert ISO_Country;
        
        ID recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.Airline_designator__c = 'TT';
        acc.Name = 'TestAccount';
        insert acc;

 		Contact c = new Contact ( accountid = acc.id, FirstName = 'AAAlberto'  , LastName = 'Borges' , Phone = 'phone' , Fax = 'fax', Title='jobtitle', Membership_Function__c = 'Aeropolitical', Preferred_Language__c='preferredlanguage', email='testddd.fff@gmail.com');
  		insert c;

  		Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal (Partner)'];
  
  		User u = null;//[SELECT id, username  FROM User where username = 'alberto.borges.gmail.com@partner.iata.org'];

     	u = ISSP_ObjectFactory.createPortalUser(c);
      	c.OwnerId = u.Id;
      	update c;

        //Manuel Conde
        List<PermissionSet> psIds = [SELECT Id,name FROM PermissionSet LIMIT 2];
        
        Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');

        One_Id_Service_Provider_Config__c oi = new One_Id_Service_Provider_Config__c(Service_Provider_Name__c = 'Bundle',
                License_Upgrade_Required__c= true,
                Profile_Id__c='a1',
                Description__c='qualquer',
                Is_Active__c = true, Portal_Visible__c = false,
                RecordTypeid = recTypeId, App_Picture_Url__c='oi',
                Customer_Type_Activation__c = 'Airline');
        insert oi;

        One_Id_Service_Provider_Config__c rr = new One_Id_Service_Provider_Config__c (Service_Provider_Name__c = 'Bundle', Is_Active__c = true, Portal_Visible__c = true, Service_Bundle__c=oi.id,Customer_Type_Activation__c = 'Airline');
        insert rr;

        One_Id_App_Config_Detail__c r = new One_Id_App_Config_Detail__c (One_Id_Service_Provider_Config__c=rr.id, PermissionSet_SSO__c = psIds[0].name, PermissionSet_Provisioning__c = psIds[1].name );
        insert r;

        One_Id_App_Role_Config__c role = new One_Id_App_Role_Config__c (Role_Name__c = 'Admin', One_Id_App_Config_Detail__c = r.id, Role_Description__c = 'desc');
        insert role;

        Portal_Applications__c portApp = new Portal_Applications__c(
        Name = 'My Test App',
        Provisioning_Type__c =SCIMServProvManager.PROV_TYP_SCIM,
        SCIM_App_Name__c = 'Bundle'
        );
        insert portApp;

        Portal_Application_Right__c par = new Portal_Application_Right__c (Portal_Application__c = portApp.id, Contact__c = c.id);
        insert par;    
        
        par.Right__c = 'Access Granted';
        update par;


        One_Id_User_Applications__c anUserApp = new One_Id_User_Applications__c();
        anUserApp.Application__c = r.id;
        anUserApp.One_Id_Service_Provider_Config__c = rr.id;
        anUserApp.One_Id_App_Bundle__c = oi.id;
        anUserApp.Identity_User__c = UserInfo.getUserId();
        anUserApp.Provisioning_Status__c = 'Started';        
        anUserApp.Portal_Service_Access__c = par.id;        
        anUserApp.action__c = 'Add';
        anUserApp.App_Key__c = LightningConnectedAppHelper.OneIdBuildUserAppKey(anUserApp);

        insert anUserApp;  


        // Suffix the appName argument so we are not colliding with Connected Apps
        // already in the system when ConnectedTestUtil is implemented by SFDC.
        // For now our stubbed createConnectedApp() will know to strip the suffix
        // and then perform the SOQL query.
       /* User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
        String fullAppName = appName + '|4t8izz2t';
        ConnectedApplication capp = UserProvisioning.ConnectorTestUtil.createConnectedApp(fullAppName);
        }*/
        Id cAppId = getConnectedApp(appName);
        
        // Build user provisioning account linked to the test user
        UserProvAccount upa = new UserProvAccount(
            salesforceUserId = u.id, 
            connectedAppId = cAppId,
            externalUserId = EXTERNAL_USER_ID, 
            externalUserName = 'john.doe@example.org',
            externalFirstName = 'John', 
            externalLastName = 'Doe',
            linkState = 'Linked', 
            status = 'Active'
        );
        insert upa; 
        
        // Build user provisioning request linked to the test user
        UserProvisioningRequest upr = new UserProvisioningRequest(
            connectedAppId = cAppId,
            salesforceUserId = u.id,
            operation = operation, 
            state = status, 
            approvalStatus = 'NotRequired'
            
            // can uncomment below once SFDC populates this field
            // as of 1/29/2016 this code path is not followed
            //
            // see UserProvisioningUtils.getLinkedUserProvAccount()
            //
            // MUST CHANGE UserProvisioningUtilsTest.testDeletedLinkedUserProvAccount()
            // in conjunction
            
            //, UserProvAccountId = upa.id
        );
        insert upr;

        return upr;
    }

}