@isTest
private  class LightningConnectedAppHelper_Test {

    static testMethod void testAuramethods() {
        LightningConnectedAppHelper.ConnectedAppsList();
        LightningConnectedAppHelper.getroles('testconnectedapp');
        UserProvisioningRequest u = new UserProvisioningRequest();
        u.SalesforceUserId = UserInfo.getUserId();
        u.ConnectedAppId = [SELECT id FROM ConnectedApplication LIMIT 1].id;
        u.State = 'New';
        u.Operation = 'Create';
        u.ApprovalStatus = 'Required';

        database.insert(u);
        u.state = 'Completed';
        database.update(u);

        SCIM_Prov_Connector__c conf = new SCIM_Prov_Connector__c();
        conf.Name = 'Test';
        conf.FYI_Email__c = 'manuel.conde@rightitservices.com';
        conf.Processor_Email__c = 'manuel.conde@rightitservices.com';
        conf.SetupOwnerId=UserInfo.getOrganizationId();
        insert conf;

        Profile p = [SELECT Id FROM Profile WHERE Name='Developer'];
        USER user = new USER (Alias = 'newUser',Email = 'ze@ze.pt', LastName = 'ze',  ProfileId = p.Id, UserName='ze@testorg.com',TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US',EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US');
        Id recTypeId = OneIdProvisioningDAO.AppRecordTypesConfig.get('One_Id_Service_Provider_Config__c').get('Service_Bundle');
        
        One_Id_Service_Provider_Config__c oi = new One_Id_Service_Provider_Config__c(Service_Provider_Name__c = 'Bundle',
                                                                                     License_Upgrade_Required__c= true,
                                                                                     Profile_Id__c='a1', 
                                                                                     Description__c='qualquer',
                                                                                     Is_Active__c = true, Portal_Visible__c = true, 
                                                                                     RecordTypeid = recTypeId, App_Picture_Url__c='oi');
        insert oi;

        List<id> userlist = New List<id>();
        userlist.add(user.id);
        
        List<PermissionSet> psIds = [SELECT Id,name FROM PermissionSet LIMIT 5];
        
        List<id> idd = New List<id>();
        idd.add(psIds[0].id);
       
        List<String> userlistst = New List<String>();
        userlistst.add(user.id);
        
        List<String> idds = New List<String>();
        idds.add(psIds[0].id);
        
               
        One_Id_Service_Provider_Config__c rr = new One_Id_Service_Provider_Config__c (Service_Provider_Name__c = 'App 1', Is_Active__c = true, Portal_Visible__c = true, Service_Bundle__c=oi.id);
        insert rr;
        One_Id_App_Config_Detail__c r = new One_Id_App_Config_Detail__c (One_Id_Service_Provider_Config__c=rr.id, PermissionSet_SSO__c = psIds[0].name, PermissionSet_Provisioning__c = psIds[1].name );
        insert r;
        One_Id_App_Role_Config__c role = new One_Id_App_Role_Config__c (Role_Name__c = 'Admin', One_Id_App_Config_Detail__c = r.id, Role_Description__c = 'desc');
        insert role;

        System.debug('««««««««««««««««««««««««««««««««««««««' + rr);
        System.debug(LoggingLevel.INFO,role);

        try {
            LightningConnectedAppHelper.getPic('vm');

        }
        catch (Exception e) {
            
        }
        
        try {
            LightningConnectedAppHelper.getAppDescription('App 1');
            LightningConnectedAppHelper.getAppDescription('empty');            
        }
        catch (Exception e) {
            
        }
        
 

        LightningConnectedAppHelper_Test.createData();
        Test.startTest();

        LightningConnectedAppHelper.ConnectedAppsList();
        
        LightningConnectedAppHelper.getroles('Bundle');
        LightningConnectedAppHelper.getAppTerms('Bundle');
        LightningConnectedAppHelper.submit('Bundle', 'Admin');
        LightningConnectedAppHelper.massAssignPermissionSets(userlist,idd);
        LightningConnectedAppHelper.massassignpermissionset(userlistst,idds);
                
        Test.stopTest();


    }

    static void createData(){
    
    
        IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.Airline_designator__c = 'TT';
        acc.Name = 'TestAccount';
        insert acc;

         RecordType rt = [Select r.Id,r.Name, r.DeveloperName From RecordType r where  DeveloperName='Standard_Contact'];
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.Email = 'test.issp.registration@testisspregistration.com';
        con.RecordTypeId = rt.Id;
        insert con;

        System.assert(con.id !=null,'Contact must be created');
        User newUser = new User(alias = 'dsfsdfds',
                email = con.email,
                emailencodingkey = 'UTF-8',
                firstname = con.firstName,
                lastname = con.lastname,
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                contactId = con.Id,
                timezonesidkey = 'Asia/Dubai',
                Username = ISSP_Utilities.buildPortalUserName(con.email),
                PortalRole = 'Manager',
                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                IsActive = true);
        insert newUser;    
        

       

   }
    // Tests
    @isTest static void testCreate() {
        // arrange
        HttpResponseGenerator generator = new HttpResponseGenerator();
        generator.nextBody = '{"schemas":["urn:scim:schemas:core:1.0","urn:scim:schemas:extension:enterprise:1.0"],"id":"005B0000001SFMhIAO","userName":"jane.doe@scimuserprov.test","name":{"formatted":"Jane Doe","familyName":"Doe","givenName":"Jane"},"displayName":"Jane Doe","nickName":"jane.doe","emails":[{"type":"work","primary":true,"value":"jane.doe@testemail.com"}],"photos":[{"type":"photo","value":"https://c.gus.content.force.com/profilephoto/005/F"},{"type":"thumbnail","value":"https://c.gus.content.force.com/profilephoto/005/T"}],"userType":"Standard","preferredLanguage":"en_US","locale":"en_US","active":true,"entitlements":[{"value":"00eB0000000MZj0IAG","display":"Identity User","primary":true}],"groups":[],"urn:scim:schemas:extension:enterprise:1.0":{"organization":"00DB000000016v5MAA"},"meta":{"created":"2015-06-24T11:57:02Z","lastModified":"2015-06-24T11:57:02Z","version":"0b86f5170f7ee5b9a7b3120670a2621127b853b9"}}';
        System.Test.setMock(HttpCalloutMock.class, generator);

        // act
        Process.PluginResult response = callPlugin(true);

        // assert
        System.assertEquals('Completed', response.outputParameters.get(UserProvisioningUtils.PARAM_STATUS));
        System.assertEquals('005B0000001SFMhIAO', response.outputParameters.get(UserProvisioningUtils.PARAM_EXTERNAL_USERID));
        System.assertEquals('jane.doe@scimuserprov.test', response.outputParameters.get(UserProvisioningUtils.PARAM_EXTERNAL_USERNAME));
        System.assertEquals('daisypop89@gmail.com', response.outputParameters.get(UserProvisioningUtils.PARAM_EXTERNAL_EMAIL));
        System.assertEquals('Daisy', response.outputParameters.get(UserProvisioningUtils.PARAM_EXTERNAL_FIRSTNAME));
        System.assertEquals('Jensen', response.outputParameters.get(UserProvisioningUtils.PARAM_EXTERNAL_LASTNAME));
    }
    private static Process.PluginResult callPlugin() {
        return callPlugin(true);
    }

    private static Process.PluginResult callPlugin(Boolean validInput) {
        // Create a UserProvisioningRequest for testing
        UserProvisioningRequest upr = UserProvisioningTestUtils.createUserProvisioningRequest('SCIM', 'Create');

        // Build input params
        Map<String,Object> inputParams = new Map<String,Object>();
        if (validInput) {
            inputParams.put(UserProvisioningUtils.PARAM_UPR_ID, upr.id);
            inputParams.put(UserProvisioningUtils.PARAM_USERPAYLOAD, '{\n  "name" : {\n    "familyName" : "Jensen",\n    "givenName" : "Daisy"\n  },\n  "emails" : [ {\n    "value" : "daisypop89@gmail.com"\n  } ],\n  "schemas" : [ "urn:scim:schemas:core:1.0" ]\n}');
        }

        return UserProvisioningTestUtils.runPlugin(new SCIMCreateUserPlugin(), inputParams);
    }
}