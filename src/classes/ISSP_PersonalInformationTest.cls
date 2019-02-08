@isTest
private class ISSP_PersonalInformationTest {
	public static testMethod void testISSP_HomepageTest() {
		//ISSP_ObjectFactory.fiilIncludedFields();
		//Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
		Account acc1 = ISSP_ObjectFactory.createNewAccount();
        acc1.IATACode__c = '258';
        acc1.Status__c = 'Under review';
        acc1.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        insert acc1;
		Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '132';
        acc.RecordTypeId = acc1.RecordTypeId;
        acc.Top_Parent__c = acc1.Id;
        Test.startTest();
        insert acc;
        Test.stopTest();
		//Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.Senior_Contact_Email__c = 'senior@dev.com';
		con.AccountId= acc.Id;
		con.User_Portal_Status__c = 'Active';
		
		system.debug('contact >> ' + con);
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
	                            username = con.email+'dfgdf',
	                            PortalRole = 'Manager',
	                            CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
	                            ProfileId = ISSP_Constant.TEST_User_ProfileID,
	                            IsActive = true);
    	insert newUser;
    	con.OwnerId = newUser.Id;
    	update con;
    	
    	AccountTeamMember member = new AccountTeamMember();
		//member.AccountAccessLevel = 'Edit';
		member.TeamMemberRole = 'Portal Regional Administrator';
		member.UserId = newUser.Id;
		member.AccountId = acc.Id;
		
		AccountTeamMember member1 = new AccountTeamMember();
		//member1.AccountAccessLevel = 'Edit';
		member1.TeamMemberRole = 'Portal Administrator';
		member1.UserId = newUser.Id;
		member1.AccountId = acc.Id;
    	
    	insert new list<AccountTeamMember>{ member, member1 };
    	
    	system.runAs(newUser){
    		ISSP_PersonalInformation ctrl = new ISSP_PersonalInformation();
    		ISSP_PersonalInformationWithoutSharing ctrlChild = new ISSP_PersonalInformationWithoutSharing(ctrl);
			ctrl.iataCode = '132';
			ctrl.saveNewCompanyName();
			ctrl.getPicklistValues();
			List<SelectOption> paxBranches = ctrl.getPAXBranches();
			ctrl.getBranchOffice();
			ctrl.saveContact(); 
			ctrl.saveAccount(); 
			ctrl.getIsVerifiedAccount();
			ctrl.getIsStandardAccount();
			ctrl.getPermissionForStandardAccount();
		}
	}
	
	public static testMethod void testISSP_HomepageTest1() {
		//ISSP_ObjectFactory.fiilIncludedFields();
		//Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
		Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '132';
        acc.Sector__c = 'Cargo Agent';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Test.startTest();
        insert acc;
        Test.stopTest();
        Account acc1 = ISSP_ObjectFactory.createNewAccount();
        acc1.IATACode__c = '258';
        acc1.Top_Parent__c = acc.Id;
        acc1.Status__c = 'Under review';
        acc1.SIS_Status__c = 'Active';
        acc1.RecordTypeId = acc.RecordTypeId;
        insert acc1;

		//Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.Senior_Contact_Email__c = 'senior@dev.com';
		con.AccountId= acc.Id;
		con.User_Portal_Status__c = 'Regional Administrator';
		con.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		
		Contact con2 = ISSP_ObjectFactory.createNewContact();
		con2.Senior_Contact_Email__c = 'senior2@dev.com';
		con2.AccountId= acc.Id;
		con2.SIS_Contact_Type__c = 'Super User';
		con2.Status__c = 'Active';
		con2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		
		system.debug('contact1 >> ' + con);
		system.debug('contact2 >> ' + con2);
		insert new List<Contact> {con, con2};
		User newUser = new User(alias = 'dsfsdfds', 
	                            email = con.email, 
	                            emailencodingkey = 'UTF-8', 
	                            firstname = con.firstName, 
	                            lastname = con.lastname, 
	                            languagelocalekey = 'en_US', 
	                            localesidkey = 'en_US', 
	                            contactId = con.Id,
	                            timezonesidkey = 'Asia/Dubai',
	                            username = con.email+'dfgdf',
	                            PortalRole = 'Manager',
	                            CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
	                            ProfileId = ISSP_Constant.TEST_User_ProfileID,
	                            IsActive = true);
    	insert newUser;
    	con.OwnerId = newUser.Id;
    	update con;
    	
		AccountTeamMember member1 = new AccountTeamMember();
		//member1.AccountAccessLevel = 'Edit';
		member1.TeamMemberRole = 'Portal Administrator';
		member1.UserId = newUser.Id;
		member1.AccountId = acc.Id;
		
		AccountTeamMember member2 = new AccountTeamMember();
		//member1.AccountAccessLevel = 'Edit';
		member2.TeamMemberRole = 'Manager';
		member2.UserId = newUser.Id;
		member2.AccountId = acc.Id;
		
    	
    	insert new list<AccountTeamMember>{ member1, member2 };

    	ID_Card__c newIdCard = new ID_Card__c (FirstName__c = con.FirstName,
    		LastName__c = con.LastName,
    		Name_on_ID_Card__c = 'Test ID Card',
    		Related_Contact__c = con.Id,
    		Card_Status__c =  'Sent ID Card',
    		Valid_From_Date__c = Date.today(),
    		Valid_To_Date__c = Date.today().addMonths(5));

    	insert newIdCard;
    	
    	system.runAs(newUser){
			ApexPages.currentPage().getParameters().put('confirm','yes');
    		ISSP_PersonalInformation ctrl = new ISSP_PersonalInformation();
    		ISSP_PersonalInformationWithoutSharing ctrlChild = new ISSP_PersonalInformationWithoutSharing(ctrl);
			ctrl.iataCode = '132';
			ctrl.saveNewCompanyName();
			ctrl.getPicklistValues();
			List<SelectOption> paxBranches = ctrl.getPAXBranches();
			ctrl.selectedBranchAccount = acc.Id;
			ctrl.getBranchOffice();
			ctrl.saveContact();
			ctrl.saveAccount();
			ctrl.saveAccountBR();
			ctrl.AssignIFAPContact(); 
			ctrl.getIsVerifiedAccount();
			ctrl.getIsStandardAccount();
			ctrl.getPermissionForStandardAccount();
			ctrl.goToEmaDomVal();
			ctrl.getAccountDomainValidRT();
			ISSP_PersonalInformationWithoutSharing.getPortalAdmins(new List<Id> {acc.Id});
		}
	}

	public static testMethod void test_companyInformationPage() {
		Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.SIS_Status__c = 'Active';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');	
        insert acc;

        Contact con1 = ISSP_ObjectFactory.createNewContact();
		con1.Senior_Contact_Email__c = 'senior@dev.com';
		con1.AccountId= acc.Id;
		con1.User_Portal_Status__c = 'Approved Admin';
		con1.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');

		Contact con2 = ISSP_ObjectFactory.createNewContact();
		con2.Senior_Contact_Email__c = 'senior@dev.com';
		con2.AccountId= acc.Id;
		con2.User_Portal_Status__c = 'Active';
		con2.SIS_Contact_Type__c  = 'Super User';
		con2.Status__c = 'Active';
		con2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');

		List<Contact> contacts = new List<Contact> {con1, con2};

		insert contacts;

		Profile p = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline Delegated Admin User'];

		User newUser = new User(alias = 'dsfsdfds', 
                        email = con1.email, 
                        emailencodingkey = 'UTF-8', 
                        firstname = con1.firstName, 
                        lastname = con1.lastname, 
                        languagelocalekey = 'en_US', 
                        localesidkey = 'en_US', 
                        contactId = con1.Id,
                        timezonesidkey = 'Asia/Dubai',
                        username = con1.email+'dfgdf',
                        PortalRole = 'Manager',
                        CommunityNickname = con1.email.substring(0, con1.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                        ProfileId = p.Id,
                        IsActive = true);
    	insert newUser;
    	con1.OwnerId = newUser.Id;
    	con2.OwnerId = newUser.Id;
    	update contacts;

        Test.startTest();
        System.runAs(newUser){
	        ApexPages.currentPage().getParameters().put('confirm','yes');
			ISSP_PersonalInformation ctrl = new ISSP_PersonalInformation();
			ISSP_PersonalInformationWithoutSharing ctrlChild = new ISSP_PersonalInformationWithoutSharing(ctrl);
		}
        Test.stopTest();
	}
}