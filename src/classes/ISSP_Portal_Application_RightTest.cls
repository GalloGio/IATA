@isTest
public class ISSP_Portal_Application_RightTest {

	public static testMethod void myUnitTest_1bis() {
		Portal_Applications__c apptest = new Portal_Applications__c(Name = 'SIS'); 
	    insert apptest;
	}
	
	public static testMethod void myUnitTest_1() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		thisUser.SIS_Team__c = true;
    	update thisUser;
    	thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	system.runAs(thisUser){
			ISSP_ObjectFactory.fiilIncludedFields();
			PermissionSet newPermSet = new PermissionSet(Name = 'ISS_Portal_Permission_Set_SIS_users');
			//Account acc = (Account)ISSP_ObjectFactory.createSObject('Account',false,4);
			Account acc = ISSP_ObjectFactory.createNewAccount();
			insert acc;
			//Contact contact = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
			Contact contact = ISSP_ObjectFactory.createNewContact();
	        contact.AccountId = acc.Id;
	        insert contact;
	        User newUser = new User(alias = 'dsfsdfds', 
		                            email = contact.email, 
		                            emailencodingkey = 'UTF-8', 
		                            firstname = contact.firstName, 
		                            lastname = contact.lastname, 
		                            languagelocalekey = 'en_US', 
		                            localesidkey = 'en_US', 
		                            contactId = contact.Id,
		                            timezonesidkey = 'Asia/Dubai',
		                            username = contact.email+'dfgdf',
		                            PortalRole = 'Manager',
		                            CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
		                            ProfileId = ISSP_Constant.TEST_User_ProfileID,
		                            IsActive = true);
	    	insert newUser;
			Portal_Applications__c app = new Portal_Applications__c(Name = 'SIS'); 
	        insert app;

	        Portal_Application_Right__c appRight = new Portal_Application_Right__c();
	        appRight.Portal_Application__c = app.Id;
	        appRight.Right__c = 'Access Granted';
	        appRight.Contact__c = contact.Id;
	        insert appRight;
	        appRight.Right__c = 'Access Denied';
	        update appRight;
	        appRight.Right__c = 'Access Granted';
	        update appRight;
        }
	}
	
	public static testMethod void ISSP_Portal_Application_RightTest() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	system.runAs(thisUser){
			RecordType rt = [select Id from RecordType where developerName=:'Biller_Direct'];
			//ISSP_ObjectFactory.fiilIncludedFields();
			
			Account acc = ISSP_ObjectFactory.createNewAccount();  
	            //(Account)ISSP_ObjectFactory.createSObject('Account',false,4);
			insert acc;
			
			SAP_Account__c sap = new SAP_Account__c();
	            //(SAP_Account__c)ISSP_ObjectFactory.createSObject('SAP_Account__c',false,3);
			sap.SAP_Account_type__c = 'test';
			sap.Account__c = acc.Id;
			sap.SAP_Id__c = '1234';
			insert sap;
			
			Contact contact = ISSP_ObjectFactory.createNewContact();
	            //(Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
	         contact.AccountId = acc.Id;
	         insert contact;
	         
	         User newUser = new User(alias = 'dsfsdfds', 
		                            email = contact.email, 
		                            emailencodingkey = 'UTF-8', 
		                            firstname = contact.firstName, 
		                            lastname = contact.lastname, 
		                            languagelocalekey = 'en_US', 
		                            localesidkey = 'en_US', 
		                            contactId = contact.Id,
		                            timezonesidkey = 'Asia/Dubai',
		                            username = contact.email+'dfgdf',
		                            PortalRole = 'Manager',
		                            CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
		                            ProfileId = ISSP_Constant.TEST_User_ProfileID,
		                            IsActive = true);
	    	insert newUser;
    	

         	Portal_Applications__c app = new Portal_Applications__c(Name = 'Biller Direct'); 
        	insert app;
			//Portal_Application_Right__c par = (Portal_Application_Right__c)ISSP_ObjectFactory.createSObject('Portal_Application_Right__c',false,2);
			Portal_Application_Right__c par = new Portal_Application_Right__c();
	        par.Contact__c = contact.Id;
	        par.Portal_Application__c = app.Id;
	        par.Right__c = 'Access Granted';
	        par.RecordTypeId = rt.Id;
	        par.Invoice_Type__c = 'test';
	        insert par;
         }
         
	}

	public static testMethod void IFGUnitTest() {
		////////////////////////////////
  		// Configurations SET
  		////////////////////////////////
  		SCIM_Prov_Connector__c conf = new SCIM_Prov_Connector__c();
  		conf.Name = 'Test';
  		conf.FYI_Email__c = 'manuel.conde@rightitservices.com';
  		conf.Processor_Email__c = 'manuel.conde@rightitservices.com';
  		conf.SetupOwnerId=UserInfo.getOrganizationId();
  		insert conf;

  		System.debug('basto1p - testConfigObjsInit SCIM_Prov_Connector__c conf='+conf);

  		Id recTypeId = OneIdProvisioningDAO.AppRecordTypesConfig.get('One_Id_Service_Provider_Config__c').get('Service_Bundle');

  		One_Id_Service_Provider_Config__c oi = new One_Id_Service_Provider_Config__c(
  			Service_Provider_Name__c = SCIMServProvManager.PRE_PROD_SRV_PROV,
  			License_Upgrade_Required__c= true,
  			Profile_Id__c='a1',
  			Description__c='qualquer',
  			Is_Active__c = true,
  			Portal_Visible__c = false,
  			RecordTypeid = recTypeId,
  			App_Picture_Url__c='oi');
  		insert oi;

  		System.debug('basto1p - testConfigObjsInit One_Id_Service_Provider_Config__c oi='+oi);

  		One_Id_Service_Provider_Config__c rr =
  		new One_Id_Service_Provider_Config__c (
  			Service_Provider_Name__c = SCIMServProvManager.PRE_PROD_SRV_PROV,
  			Is_Active__c = true,
  			Portal_Visible__c = false,
  			RecordTypeid = recTypeId,
  			Service_Bundle__c=oi.id);
  		insert rr;

  		System.debug('basto1p - testConfigObjsInit One_Id_Service_Provider_Config__c rr='+rr);

  		List<PermissionSet> psIds = [SELECT Id,name FROM PermissionSet LIMIT 5];

  		One_Id_App_Config_Detail__c r =
  		new One_Id_App_Config_Detail__c (
  			One_Id_Service_Provider_Config__c=rr.id,
  			PermissionSet_SSO__c = psIds[0].name,
  			PermissionSet_Provisioning__c = psIds[01].name );
  		insert r;

  		System.debug('basto1p - testConfigObjsInit One_Id_App_Config_Detail__c r='+r);

  		/////////////////////////////////////////////////////////////

  		Account newAccount = ISSP_ObjectFactory.CreateNewAccount();
  		insert newAccount;

  		Contact newContact = ISSP_ObjectFactory.CreateNewContact();
  		newContact.AccountId = newAccount.id;
  		insert newContact;

  		User newPortalUser = ISSP_ObjectFactory.createPortalUser(newContact);

		//Portal_Applications__c app = [SELECT Id,Name,Provisioning_Type__c FROM Portal_Applications__c WHERE Name =:'IFG Production' LIMIT 1];

		Portal_Applications__c app = new Portal_Applications__c(Name = 'IFG Pre-Production', Provisioning_Type__c = 'SCIM', SCIM_App_Name__c = SCIMServProvManager.PRE_PROD_SRV_PROV);
		insert app;

		system.runAs(newPortalUser){

			Portal_Application_Right__c par = new Portal_Application_Right__c();
			par.Contact__c = newContact.Id;
			par.Portal_Application__c = app.Id;
			par.Right__c = 'Access Granted';
			par.Technical_Provisioning_Status__c = 'IATA Access Granted';
			insert par;
			par.Right__c = SCIMServProvManager.IATA_STS_ACCESS_DENIED;
			update par;
            par.Right__c = SCIMServProvManager.IATA_STS_ACCESS_GRANTED;
			update par;
		}
		

	}
}