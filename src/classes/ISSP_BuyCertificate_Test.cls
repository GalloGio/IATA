@isTest
public class ISSP_BuyCertificate_Test {

    public static testMethod void testISSP_BuyCertificate_Test() {
		Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '132';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Test.startTest();
        insert acc;
        Test.stopTest();
		//Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.Senior_Contact_Email__c = 'senior@dev.com';
		con.AccountId= acc.Id;
		con.User_Portal_Status__c = 'Active';
		
		system.debug('SOS contact >> ' + con);
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

    	Product_Category__c pc = new Product_Category__c();
		pc.Name = 'IATA Certificate';
		pc.Short_Description__c = 'CARGO Certificate. Soft Copy, digital file';
		insert pc ;
        
        
        
        system.runAs(newUser)
		{
        	ISSP_Ctrl_BuyCertificate cttr = new ISSP_Ctrl_BuyCertificate();
			ISSP_CertificateListView__c cs = new ISSP_CertificateListView__c();
			cs.Name = 'Test';
			cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
			cs.Field_Set_API_Name__c = 'ISSP_View_Certificate';
			insert cs;
			cttr.initialization();
			cttr.getCases();
			cttr.getAccounts();
			//cttr.refresh();
        
			cttr.setSortDirection('DESC');
			system.assertEquals('DESC', cttr.getSortDirection());
			cttr.sortExpression = 'ASC';
			List<SelectOption> so1 = new List<SelectOption>(); 
			so1 = cttr.getSubCategories();
			
			List<SelectOption> so2 = new List<SelectOption>(); 
			so2 = cttr.getCategories();
			cttr.category = 'IATA Certificate';
			cttr.SubCategory = 'CARGO Certificate. Soft Copy, digital file';
			cttr.Purchase();
			cttr.home();

        }
        
        
         
    }
    
    public static testMethod void testISSP_BuyCertificate_Test_2() {
        ISSP_Ctrl_BuyCertificate cttr = new ISSP_Ctrl_BuyCertificate();
        ISSP_CertificateListView__c cs = new ISSP_CertificateListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_View_Certificate';
        cs.Permission_set__c = '0PS200000004CryGAE';
        insert cs;
        cttr.initialization();
       // cttr.getCases();
        cttr.refresh();
        
        cttr.setSortDirection('DESC');
        system.assertEquals('DESC', cttr.getSortDirection());
        cttr.sortExpression = 'ASC';
    }
    
    public static testMethod void testtestISSP_BuyCertificate_Test_3() {
        ISSP_Ctrl_BuyCertificate cttr = new ISSP_Ctrl_BuyCertificate();
        cttr.initialization();
        //cttr.getCases();
        cttr.refresh();
        ISSP_CertificateListView__c cs = new ISSP_CertificateListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        insert cs;
        cttr = new ISSP_Ctrl_BuyCertificate();
        
        cttr.setSortDirection('DESC');
        system.assertEquals('DESC', cttr.getSortDirection());
        cttr.sortExpression = 'ASC';

		cttr.Purchase();
    }

}