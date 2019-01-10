@isTest
public class IATA_ServiceList_CTRL_TEST {
    
    public static testMethod void serviceList_ctrl_test1() {
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;

		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		Contact con = ISSP_ObjectFactory.createNewContact();
    	con.AccountId = acc.Id;
    	con.LastName = 'test';
    	con.Email = 'test.gdpr.registration@testgdprregistration.com';
    	con.RecordTypeId = rtId;
		insert con;

       	User newUser = new User(alias = 'dsfsdfds',
                                email = con.email,
                                emailencodingkey = 'UTF-8',
                                firstname = con.firstName,
                                lastname = con.lastname,
                                languagelocalekey = 'en_US',
                                localesidkey = 'en_US',
                                contactId = con.Id,
                                timezonesidkey = 'Asia/Dubai',
                                Username = 'test.gdpr.registration.testgdprpregistration.com@partner.iata.org',
                                PortalRole = 'Manager',
                                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                                IsActive = true);
        insert newUser;
        
        //Create service
        Id serviceRTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Portal_Applications__c', 'ISS_Portal_Application');
        Portal_Applications__c portalApp = new Portal_Applications__c();
        portalApp.Name = 'app test 1';
        portalApp.GDPR_PrivacyStatement__c = 'https://www.saleforce.com';
        portalApp.RecordTypeId = serviceRTypeId;
        insert portalApp;
        
        //create service link
        Portal_Application_Right__c portalAppUser = new Portal_Application_Right__c();
        portalAppUser.Right__c = 'Access Granted';
        portalAppUser.Contact__c = con.Id;
        
        
        System.runAs(newUser) {
        
			List<Portal_Application_Right__c> lstServices = IATA_ServiceList_CTRL.getUserPortalServices();
            System.assertEquals(1,lstServices.size());
        }
    }

}