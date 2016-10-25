@isTest
private class ISSP_PortalUserStatusChangeTest {
    
    public static testMethod void testISSP_PortalUserStatusChangeTest() {
        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        insert con;
        ISSP_PortalUserStatusChange controler = new ISSP_PortalUserStatusChange(new Apexpages.Standardcontroller(con));
        
        controler.con.User_Portal_Status__c = 'Approved User';
        string actionName = ISSP_PortalUserStatusChange.getActionName(controler.con.User_Portal_Status__c,'');
        ISSP_PortalUserStatusChange.preformAction(actionName,controler.con.Id,controler.con.User_Portal_Status__c);
         
        ISSP_ObjectFactory.createPortalUser(con);
        
        controler.con.User_Portal_Status__c = 'Deactivate';
        actionName = ISSP_PortalUserStatusChange.getActionName(controler.con.User_Portal_Status__c,'');
        ISSP_PortalUserStatusChange.preformAction(actionName,controler.con.Id,controler.con.User_Portal_Status__c);
        
        //ISSP_PortalUserStatusChange.isUserDisabel(con.Id);
        //ISSP_PortalUserStatusChange.disabelUser(con.Id);
        Set<String> setIds = new Set<String>();
        setIds.add(con.Id);
        
        //ISSP_PortalUserStatusChange.futureDeactivateUsers(setIds);
        //ISSP_PortalUserStatusChange.futureUpdateUsers(setIds);
        
        controler.con.User_Portal_Status__c = 'Approved Admin';
        actionName = ISSP_PortalUserStatusChange.getActionName(controler.con.User_Portal_Status__c,'');
        ISSP_PortalUserStatusChange.preformAction(actionName,controler.con.Id,controler.con.User_Portal_Status__c);
        controler.save();
        
        ISSP_PortalUserStatusChange.createEmail(null,null);
        //controler.disabelUser();
        
 //       ISSP_PortalUserStatusChange.maasUserCreation(con);
        
        
    }

    public static testMethod void testISSP_PortalUserStatusChangeTest2() {
    	//ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Pending Approval';
        insert con;
        ISSP_PortalUserStatusChange controler = new ISSP_PortalUserStatusChange(new Apexpages.Standardcontroller(con));
        
        controler.disabelUser();
     } 
     
     public static testMethod void testISSP_PortalUserStatusChangeTest3() {
     	
     	//ISSP_ObjectFactory.fiilIncludedFields();
    	String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC' LIMIT 1].Id;
    	//Account acc = (Account)ISSP_ObjectFactory.createSObject('Account',false,4);
    	Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;
		//Contact contact = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
		Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = acc.Id;
        contact.User_Portal_Status__c = 'Pending Approval';
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
	                            ProfileId = profileId,
	                            IsActive = true);
    	insert newUser;
    	
    	ISSP_PortalUserStatusChange controler = new ISSP_PortalUserStatusChange(new Apexpages.Standardcontroller(contact));
    	controler.contactId = contact.Id;
    	controler.sendEmailToUser();
     	
     	ISSP_PortalUserStatusChange.preformActionImmediate(contact.Id,'Pending Approval','Approved User');

     }
     
     public static testMethod void testISSP_PortalUserStatusChangeTest4() {
    	//ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Pending Approval';
        insert con;
        ISSP_PortalUserStatusChange controler = new ISSP_PortalUserStatusChange(new Apexpages.Standardcontroller(con));
        controler.contactId = con.Id;
        controler.portalStatus = 'Approved User';
        controler.oldPortalStatus = 'Pending Approval';
        controler.preformAction();
        controler.portalStatus = 'Approved Admin';
        controler.oldPortalStatus = 'Approved User';
        controler.preformAction();
        controler.portalStatus = 'Approved User';
        controler.oldPortalStatus = 'Approved Admin';
        controler.preformAction();
        ISSP_PortalUserStatusChange.disabelUser(con.Id);
     }
     
     public static testMethod void testISSP_PortalUserStatusChangeTest5() {
    	//ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Pending Approval';
        con.Email = 'test1@test.com';
        insert con;
        //Contact con2 = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,2);
        Contact con2 = ISSP_ObjectFactory.createNewContact();
        con2.AccountId= acc.Id;
        con2.User_Portal_Status__c = 'Pending Approval';
        con2.Email = 'test2@test.com';
        insert con2;
        List <Contact> contactList = new List <Contact>();
        contactList.add(con);
        contactList.add(con2);
        Set <String> contactListId = new Set <String>();
        contactListId.add(con.Id);
        contactListId.add(con2.Id);
        ISSP_PortalUserStatusChange.maasUserCreation(contactList);
        ISSP_PortalUserStatusChange.futureUpdateUsers(contactListId);
        ISSP_PortalUserStatusChange.futureDeactivateUsers(contactListId);
     }
     
}