@isTest
public class ISSP_PortalService_Test {


	public static testMethod void unitTest1() {
		ISSP_PortalService_Test.createTestData();
		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='12',Name='test');
        insert ISO_Country;

		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.IATACode__c = '1111';
		acc.IATA_ISO_Country__c = ISO_Country.Id;
		acc.BillingCity = 'Test';
		acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		insert acc;
		
		String agencyProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)'].Id;
        ISSP_CS__c profileCS = new ISSP_CS__c();
        profileCS.Name = 'ISS_Portal_Agency_User';
        profileCS.Value__c = agencyProfileId;
        insert profileCS;
        ISSP_CS__c profileCS2 = new ISSP_CS__c();
        profileCS2.Name = 'Host';
        profileCS2.Value__c = 'preprod-customer-portal-iata.cs18.force.com';
        insert profileCS2;
        
        IECTestUtil.trgPortalUserAfterInserUpdate = true;
		
		//Contact con = [Select id from Contact where LastName = 'test123'];		

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId = acc.Id;
		insert con;

        Portal_Applications__c app = new Portal_Applications__c(Name = 'Test App'); 
        insert app;
        
        Portal_Application_Right__c appReq = new Portal_Application_Right__c();
        appReq.Portal_Application__c = app.Id;
        appReq.Right__c = 'Access Granted';
        appReq.Contact__c = con.Id;
        
        insert appReq;


        
		

        Apexpages.currentPage().getParameters().put('id', appReq.Id);
        ISSP_PortalServiceAccess ctrl1 = new ISSP_PortalServiceAccess();
		
		Test.startTest();
        
        Apexpages.currentPage().getParameters().put('id', app.Id);


        /*ISSP_PortalService ctrl2 = new ISSP_PortalService();
        ctrl2.RedirectToServiceAccess();
     
        Apexpages.currentPage().getParameters().put('id', appReq.Id);
        Apexpages.currentPage().getParameters().put('PSid', app.Id);
        Apexpages.currentPage().getParameters().put('PSname', 'test');
        ISSP_EditPortalServiceAccess ctrl3 = new ISSP_EditPortalServiceAccess();
        ctrl3.getRightsOptions();
        ctrl3.AssignIFAPContact();
        ctrl3.DenyAccess();
        ctrl3.GrantAccess();
        ctrl3.RedirectToService();
        ctrl3.getContacts();*/

        Test.stopTest();
	}
		
	public static testMethod void unitTest3() {

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='12',Name='test', ANG_Enable_NewGen__c=true);
        insert ISO_Country;

		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.IATACode__c = '1111';
		acc.IATA_ISO_Country__c = ISO_Country.Id;
		acc.BillingCity = 'Test';
		acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		insert acc;
		
		String agencyProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)'].Id;
        ISSP_CS__c profileCS = new ISSP_CS__c();
        profileCS.Name = 'ISS_Portal_Agency_User';
        profileCS.Value__c = agencyProfileId;
        insert profileCS;
        ISSP_CS__c profileCS2 = new ISSP_CS__c();
        profileCS2.Name = 'Host';
        profileCS2.Value__c = 'preprod-customer-portal-iata.cs18.force.com';
        insert profileCS2;
        
        IECTestUtil.trgPortalUserAfterInserUpdate = true;
		
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId = acc.Id;
		con.Community__c = '123';
		con.User_Portal_Status__c = 'Deactivated';
		insert con;

		Test.startTest();

        Portal_Applications__c app = new Portal_Applications__c(Name = 'EasyPay'); 
        insert app;
        
        Portal_Application_Right__c appReq = new Portal_Application_Right__c();
        appReq.Portal_Application__c = app.Id;
        appReq.Right__c = 'Access Granted';
        appReq.Contact__c = con.Id;
        insert appReq;        
        
        Apexpages.currentPage().getParameters().put('id', appReq.Id);
        ISSP_PortalServiceAccess ctrl1 = new ISSP_PortalServiceAccess();
        
        Apexpages.currentPage().getParameters().put('id', app.Id);
        ISSP_PortalService ctrl2 = new ISSP_PortalService();
        ctrl2.RedirectToServiceAccess();
        
        Apexpages.currentPage().getParameters().put('id', appReq.Id);
        Apexpages.currentPage().getParameters().put('PSid', app.Id);
        Apexpages.currentPage().getParameters().put('PSname', 'EasyPay');
        ISSP_EditPortalServiceAccess ctrl3 = new ISSP_EditPortalServiceAccess();
        ctrl3.getRightsOptions();
        ctrl3.DenyAccess();
        ctrl3.GrantAccess();
        ctrl3.pendingApproval = true;
        ctrl3.GrantAccess();

        ctrl3.RedirectToService();
		ctrl3.AssignIFAPContact();

        
        ctrl3.getContacts();

        ctrl3.SelectedContacts = con.id;

        ctrl3.activateUsers();

        Apexpages.currentPage().getParameters().put('id', appReq.Id);
        Apexpages.currentPage().getParameters().put('PSid', app.Id);
        Apexpages.currentPage().getParameters().put('PSname', 'test');
        ISSP_EditPortalServiceAccess ctrl4 = new ISSP_EditPortalServiceAccess();

        ctrl4.SelectedRightOption = '';
        ctrl4.contactIds = new List<String>();

        Test.stopTest();
	}
	
	
	public static testMethod void unitTest4() {
		ISSP_PortalService_Test.createTestData();
		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='12',Name='test');
        insert ISO_Country;

		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.IATACode__c = '1111';
		acc.IATA_ISO_Country__c = ISO_Country.Id;
		acc.BillingCity = 'Test';
		acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		insert acc;
		
		String agencyProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)'].Id;
        ISSP_CS__c profileCS = new ISSP_CS__c();
        profileCS.Name = 'ISS_Portal_Agency_User';
        profileCS.Value__c = agencyProfileId;
        insert profileCS;
        ISSP_CS__c profileCS2 = new ISSP_CS__c();
        profileCS2.Name = 'Host';
        profileCS2.Value__c = 'preprod-customer-portal-iata.cs18.force.com';
        insert profileCS2;

    	Connected_App_Roles__c car = new Connected_App_Roles__c(
			Name = 'Teste',
			Active__c = true,
			App_Picture_Url__c = '',
			Connected_App_Description__c = '',
			Connected_App_Provisioning_Name__c = 'IATA EasyPay (EDENRED)', 
			Connected_App__c = 'IATA EasyPay (EDENRED)',
			Default_User_Role__c = true,
			Description__c = '',
			IsCommunity__c = true,
			Manage_User_Access__c = true,
			PermissionSet_Provisioning__c = '',
			Permission_set_SSO__c = '',
			Role__c = 'iep admin'
		);

		insert car;
        	       
        IECTestUtil.trgPortalUserAfterInserUpdate = true;
			
		List<Contact> cl = new List<Contact>();

		Contact con1 = ISSP_ObjectFactory.createNewContact();
		con1.AccountId = acc.Id;
		con1.User_Portal_Status__c = 'Pending Approval';
		con1.Email = 'con1@test.test';
		con1.Community__c = 'ISS Customer Portal';
		cl.add(con1);		

		Contact con2 = ISSP_ObjectFactory.createNewContact();
		con2.AccountId = acc.Id;
		con2.User_Portal_Status__c = 'Approved User';
		con2.Email = 'con2@test.test';
		con2.Community__c = 'ISS Customer Portal';
		cl.add(con2);
		
		
		
		Contact con3 = ISSP_ObjectFactory.createNewContact();
		con3.AccountId = acc.Id;
		con3.Email = 'con3@test.test';
		con3.Community__c = 'ISS Customer Portal';
		cl.add(con3);		

		insert cl;		
		
		Test.startTest();

        Portal_Applications__c app = new Portal_Applications__c(Name = 'IATA Accreditation'); 
        insert app;
        
        Apexpages.currentPage().getParameters().put('PSid', app.Id);
        Apexpages.currentPage().getParameters().put('PSname', 'IATA Accreditation');
        ISSP_EditPortalServiceAccess ctrl3 = new ISSP_EditPortalServiceAccess();

        ctrl3.getContacts();
        ctrl3.SelectedContacts = ' ' + con1.Id + ' , ' + con2.Id + ' , ' + con3.Id + ' ';
        ctrl3.confirmContacts();
        ctrl3.CreateNewPortalAccess();
        //ctrl3.AssignIFAPContact();

        //ctrl3.CreateNewPortalAccess();
        test.stopTest();
	}
	

	public static testMethod void unitTest5() {

		ISSP_PortalService_Test.createTestData();
		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='12',Name='test');
        insert ISO_Country;

		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.IATACode__c = '1111';
		acc.IATA_ISO_Country__c = ISO_Country.Id;
		acc.BillingCity = 'Test';
		acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		insert acc;
		
		String agencyProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)'].Id;
        ISSP_CS__c profileCS = new ISSP_CS__c();
        profileCS.Name = 'ISS_Portal_Agency_User';
        profileCS.Value__c = agencyProfileId;
        insert profileCS;
        ISSP_CS__c profileCS2 = new ISSP_CS__c();
        profileCS2.Name = 'Host';
        profileCS2.Value__c = 'preprod-customer-portal-iata.cs18.force.com';
        insert profileCS2;
        
        IECTestUtil.trgPortalUserAfterInserUpdate = true;
		
		//Contact con = [Select id from Contact where LastName = 'test123'];		

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId = acc.Id;
		con.Community__c = '123';
		insert con;

		Test.startTest();

        Portal_Applications__c app = new Portal_Applications__c(Name = 'Test App'); 
        insert app;
        
        Portal_Application_Right__c appReq = new Portal_Application_Right__c();
        appReq.Portal_Application__c = app.Id;
        appReq.Right__c = 'Access Granted';
        appReq.Contact__c = con.Id;
        
        insert appReq;


        ISSP_PortalService ctrl4 = new ISSP_PortalService();

        ctrl4.psId = app.id;
        ctrl4.serviceId =  app.Id;
        ctrl4.contactId = con.Id;

        ctrl4.contactStatus = 'PA';

        ctrl4.getAppsGrantedListAux();

        Pagereference p = ctrl4.denyAccess();

        p = ctrl4.grantAccess();

        ctrl4.contactStatus = 'NO';

		p = ctrl4.grantAccess();

        p = ctrl4.permissionSetPoller();

        p = ctrl4.refreshList();

        // force errors
		ctrl4.contactId = null;

		p = ctrl4.denyAccess();

		p = ctrl4.grantAccess();

        p = ctrl4.permissionSetPoller();

        Test.stopTest();

	}

	public static void createTestData(){
		
		List<ISSP_CS__c> csList = new List<ISSP_CS__c>();
		
		ISSP_CS__c cs1 = new ISSP_CS__c();
		cs1.Name = 'DefaultNewAccountOwnerId';
		cs1.Value__c = UserInfo.getUserId();
		csList.add(cs1);
		ISSP_CS__c cs2 = new ISSP_CS__c();
		cs2.Name = 'Host';
		cs2.Value__c = 'test';
		csList.add(cs2);
		
		List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name LIKE 'ISS%'];
		for (Profile thisProfile : profileList){
			ISSP_CS__c newCS = new ISSP_CS__c();
			newCS.Value__c = thisProfile.Id;
			if (thisProfile.Name == 'ISS Portal (Partner)'){
				newCS.Name = 'ISS_Portal';
				csList.add(newCS);
			}
			else if (thisProfile.Name == 'ISS Portal Agency Delegated Admin User'){
				newCS.Name = 'ISS_Portal_Agency_Delegated_Admin';
				csList.add(newCS);
			}
			else if (thisProfile.Name == 'ISS Portal Agency User (Partner)'){
				newCS.Name = 'ISS_Portal_Agency_User';
				csList.add(newCS);
			}
			else if (thisProfile.Name == 'ISS Portal Airline Delegated Admin User'){
				newCS.Name = 'ISS_Portal_Airline_Delegated_Admin';
				csList.add(newCS);
			}
			else if (thisProfile.Name == 'ISS Portal Airline User (Partner)'){
				newCS.Name = 'ISS_Portal_Airline_User';
				csList.add(newCS);
			}
			else if (thisProfile.Name == 'ISS Portal Delegated Admin User'){
				newCS.Name = 'ISS_Portal_Delegated_Admin';
				csList.add(newCS);
			}
			else if (thisProfile.Name == 'ISS Portal GSA Delegated Admin User'){
				newCS.Name = 'ISS_Portal_GSA_Delegated_Admin';
				csList.add(newCS);
			}
			else if (thisProfile.Name == 'ISS Portal GSA User (Partner)'){
				newCS.Name = 'ISS_Portal_GSA_User';
				csList.add(newCS);
			}
		}
		insert csList;
	}
}