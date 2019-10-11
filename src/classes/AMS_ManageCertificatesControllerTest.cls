@isTest
private class AMS_ManageCertificatesControllerTest {

	@testSetup 
	static void setup() {
		ISSP_CS__c cs1 = new ISSP_CS__c();
		cs1.Name = 'ISSP AMS AMAZON S3 MAX FILE SIZE';
		cs1.Value__c = '100';
		insert cs1;

		ISSP_CS__c cs2 = new ISSP_CS__c();
		cs2.Name = 'ISSP AMS AMAZON S3 ALLOWED EXTS';
		cs2.Value__c = 'pdf';
		insert cs2;

		Amazon_Cred__c cred = new Amazon_Cred__c();
		cred.Name = 'GenericAttach';
		cred.Dev_Configuration__c = 'GenericDev';
		cred.Prod_Configuration__c = 'GenericProd';
		insert cred;

		AWSKey__c key = new AWSKey__c();
		key.AWS_ENDPOINT_URL__c = 'test';
		key.Bucket__c = 'test';
		key.IAS_Configation_name__c = 'test';
		key.IAS_configuration_name__c = 'test';
		key.Key__c = 'test';
		key.Name = UserInfo.getOrganizationId().substring(0,15) == '00D2000000008TF'  ? cred.Prod_Configuration__c : cred.Dev_Configuration__c ;
		key.Secret__c = 'test';
		insert key;
		
		/*** Set IATA ISO Country ***/
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Wakanda';
		country.ISO_Code__c = 'XW';
		country.ISO_Code_Numeric__c = 11;
		country.Region__c = 'Africa & Middle East';
		insert country;

		/*** Set IATA ISO State ***/
		IATA_ISO_State__c state = new IATA_ISO_State__c();
		state.Name = 'WAKA';
		state.ISO_Code__c = 'XW';
		state.IATA_ISO_Country__c = country.Id;
		insert state;

		/*** Set Account ***/
		Account acc = new Account();
		acc.Name = 'Cargo DGR Test';
		acc.Sector__c = 'Cargo Agent';
		acc.Category__c = 'IATA Cargo Agent';
		acc.Location_Type__c = 'HO';
		acc.Location_Class__c = 'C';
		acc.IATA_ISO_Country__c = country.Id;
		acc.Is_your_firm_handling_Dangerous_Goods__c = 'Yes';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
		insert acc;

		Contact con = new Contact();
		con.AccountId = acc.Id;
		con.FirstName = 'Owner';
		con.LastName = 'Contact';
		con.Email = 'owner@test.com';
		con.User_Portal_Status__c = 'Approved Admin';
		insert con;

		createPortalUser(con);
	}

	public static User createPortalUser(Contact con) {
		String orgId = UserInfo.getOrganizationId();
		String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
		Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
		String uniqueName = orgId + dateString + con.Firstname;
		String conId15 = con.Id;
		//conId15 = conId15.substring(0,15);
		String UserNameStr=uniqueName+ string.valueof(randomInt) + '@test' + orgId + '.org';
		String ComNickNameStr=con.email.substring(0, con.email.indexOf('@'))+randomInt;//Datetime.now().formatLong().substring(10,15);
		system.debug('basto1p TEST UserName='+UserNameStr);
		system.debug('basto1p TEST ComNickNameStr='+ComNickNameStr);
		User newUser = new User(alias = 'dsfsdfds', 
		                        email = con.email, 
		                        emailencodingkey = 'UTF-8', 
		                        firstname = con.firstName, 
		                        lastname = con.lastname, 
		                        languagelocalekey = 'en_US', 
		                        localesidkey = 'en_US', 
		                        contactId = con.Id,
		                        FederationIdentifier = conId15,
		                        timezonesidkey = 'Asia/Dubai',
		                        Username = con.Email,
		                        PortalRole = 'Manager',
		                        CommunityNickname = ComNickNameStr,
		                        ProfileId = ISSP_Constant.TEST_User_ProfileID,
		                        IsActive = true);
		insert newUser;
		return newUser;
		}
	
	@isTest 
	static void test1() {	
		User u = [SELECT Id FROM User WHERE Email = 'owner@test.com'];
		Test.startTest();
		AMS_Agency_Regulation__c agReg1 = new AMS_Agency_Regulation__c();
		agReg1.First_Name__c = 'Member';
		agReg1.Last_Name__c = 'Staff1';
		agReg1.Issuer__c = 'School';
		agReg1.Issued_on__c = Date.today().addDays(-365);
		agReg1.Position__c = 'Worker';
		agReg1.Type_Of_Certificate__c = 'DGR';
		agReg1.Expiry_Date__c = Date.today().addDays(80);
		agReg1.Account__c = [SELECT Id FROM Account].Id;
		AMS_Agency_Regulation__c agReg2 = new AMS_Agency_Regulation__c();
		agReg2.First_Name__c = 'Member';
		agReg2.Last_Name__c = 'Staff2';
		agReg2.Issuer__c = 'School';
		agReg2.Issued_on__c = Date.today().addDays(-365);
		agReg2.Position__c = 'Worker';
		agReg2.Type_Of_Certificate__c = 'DGR';
		agReg2.Expiry_Date__c = Date.today().addDays(180);
		agReg2.Account__c = [SELECT Id FROM Account].Id;
		insert new List<AMS_Agency_Regulation__c> {agReg1, agReg2};

		agReg1.Notification_Sent__c = true;
		update agReg1;
		Test.stopTest();

		Case cse = [SELECT Id FROM Case];
		System.runAs(u) {
			PageReference currPage = Page.ISSP_Case;
			Test.setCurrentPage(currPage);
			ApexPages.currentPage().getParameters().put('caseId', cse.Id);
			AMS_ManageCertificatesController ctr = new AMS_ManageCertificatesController();
			ctr.refreshList();	
			ctr.redirectToTrainedStaffPage();
			ctr = new AMS_ManageCertificatesController();
			ctr.dataConfig.trainnedStaffIds = agReg1.Id +',' + agReg2.Id;
			ctr.dataConfig.accountId = agReg1.Account__c;
			ctr.refreshList();
			for(AMS_ManageCertificatesController.Person c : ctr.dataConfig.trainedStaffList) {
				c.accContact.Valid_until__c = Date.today().addDays(365);
			}
			ctr.dataConfig.fileNames = 'test.txt';
			ctr.updateCertificates();
		}
	}

	@isTest 
	static void test2() {	
		User u = [SELECT Id FROM User WHERE Email = 'owner@test.com'];		
		Test.startTest();
		Account acc = [SELECT Id FROM Account];
		AMS_Agency_Regulation__c agReg2 = new AMS_Agency_Regulation__c();
		agReg2.First_Name__c = 'Member';
		agReg2.Last_Name__c = 'Staff2';
		agReg2.Issuer__c = 'School';
		agReg2.Issued_on__c = Date.today().addDays(-365);
		agReg2.Position__c = 'Worker';
		agReg2.Type_Of_Certificate__c = 'DGR';
		agReg2.Expiry_Date__c = Date.today().addDays(180);
		agReg2.Account__c = acc.Id;
		insert agReg2;
		Test.stopTest();
		
		System.runAs(u) {
			AMS_ManageCertificatesController ctr = new AMS_ManageCertificatesController();
			ctr.fileConfig = new AMS_ManageCertificatesController.FileConfiguration();
			ctr.dataConfig.trainnedStaffIds = agReg2.Id;
			ctr.dataConfig.accountId = agReg2.Account__c;
			ctr.refreshList();
			for(AMS_ManageCertificatesController.Person c : ctr.dataConfig.trainedStaffList) {
				c.accContact.Valid_until__c = Date.today().addDays(365);
			}
			ctr.dataConfig.fileNames = 'test.pdf';
			ctr.updateCertificates();
			ctr.addStaffMember();
			AMS_ManageCertificatesController.createAmazonFile(ctr.dataConfig.mapCasePerStaff.values()[0], 'test.pdf', 'DGR_CERT', 1);
		}
	}
		
}