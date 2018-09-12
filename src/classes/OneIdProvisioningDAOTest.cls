/**
 * Created by Manuel Conde on 18/03/2017.
 */
@IsTest
private class OneIdProvisioningDAOTest {
    
    @isTest static void testMethod01()
    {
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;

		Id recTypeId = OneIdProvisioningDAO.AppRecordTypesConfig.get('One_Id_Service_Provider_Config__c').get('Service_Bundle');
        
        One_Id_Service_Provider_Config__c oi = new One_Id_Service_Provider_Config__c(Service_Provider_Name__c = 'Bundle', License_Upgrade_Required__c= true,Profile_Id__c='a1', Description__c='qualquer',Is_Active__c = true, Portal_Visible__c = true, RecordTypeid = recTypeId, App_Picture_Url__c='oi',Customer_Type_Activation__c = 'Airline');
        insert oi;

        One_Id_Service_Provider_Config__c rr = new One_Id_Service_Provider_Config__c (Service_Provider_Name__c = 'Copa', Service_Bundle__c=oi.id,Customer_Type_Activation__c = 'Airline');
        insert rr;

        One_Id_App_Config_Detail__c r = new One_Id_App_Config_Detail__c (One_Id_Service_Provider_Config__c=rr.id);
        insert r;

        One_Id_App_Role_Config__c role = new One_Id_App_Role_Config__c (Role_Name__c = 'admin', One_Id_App_Config_Detail__c = r.id, Role_Description__c = 'des');
        insert role;

        
        Test.startTest();
        
        OneIdProvisioningDAO.getFilteredServiceBundles(acc);
        
        //OneIdProvisioningDAO.getFilteredServiceBundles();

        OneIdProvisioningDAO.getAppListForAppicker();

        OneIdProvisioningDAO.getAppRolesListForAppicker('ola');

        OneIdProvisioningDAO.getAppPicListForAppicker('xau');

        OneIdProvisioningDAO.getAppDescListForAppicker('vm');
        
        OneIdProvisioningDAO.getAppTermsForAppicker('vm');

        OneIdProvisioningDAO.getAppInfo('Bundle');

        OneIdProvisioningDAO.getAppPermissionSetListForAppicker('vm1');

        OneIdProvisioningDAO.getAppPermissionSetListForSSO();
        
        List<String> aa = new List<String>();
        aa.add('vm1');
        OneIdProvisioningDAO.getAppPermissionSetListForISSP(aa);

        Test.stopTest();

    }

    
}