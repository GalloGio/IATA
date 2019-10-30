@isTest
public class portalIftpTestClass {


//    @testSetup
//    static void setup() {
	public static void test_config(){

		//Create Country
		List<IATA_ISO_Country__c> countryList = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c ctr1 = new IATA_ISO_Country__c(Name = 'Test1 country', ISO_Code__c = 'PT');
		IATA_ISO_Country__c ctr2 = new IATA_ISO_Country__c(Name = 'Test2 country', ISO_Code__c = 'CH');
		IATA_ISO_Country__c ctr3 = new IATA_ISO_Country__c(Name = 'Test3 country', ISO_Code__c = 'UK');
		IATA_ISO_Country__c ctr4 = new IATA_ISO_Country__c(Name = 'Test4 country', ISO_Code__c = 'FR');
		countryList.add(ctr1);
		countryList.add(ctr2);
		countryList.add(ctr3);
		countryList.add(ctr4);
		insert countryList;

		//Create Address
		List<Address__c> addressList = new List<Address__c>();
		Address__c add1 = new Address__c(City__c = 'LisbonX', Code__c = 'PTX', IATA_ISO_Country__c = ctr1.Id);
		Address__c add2 = new Address__c(City__c = 'GenevaX', Code__c = 'GVX', IATA_ISO_Country__c = ctr2.Id);
		Address__c add3 = new Address__c(City__c = 'ParisX', Code__c = 'FRX', IATA_ISO_Country__c = ctr4.Id);
		addressList.add(add1);
		addressList.add(add2);
		addressList.add(add3);
		insert addressList;

		//Create Portal Application
		Portal_Applications__c portalApp = new Portal_Applications__c(Name = 'IFTP');
		insert portalApp;

		//Create Accounts Roles
		List<Account_Roles__c> accRolesList = new List<Account_Roles__c>();
		Account_Roles__c accRolesITP = new Account_Roles__c(Name = 'ITP', Sector__c = 'Airline Supplier');
		Account_Roles__c accRolesAirline = new Account_Roles__c(Name = 'Airline');
		accRolesList.add(accRolesITP);
		accRolesList.add(accRolesAirline);
		insert accRolesList;

		//Create Accounts Services'
		List<Account_Role_Services__c> accRoleServicesList = new List<Account_Role_Services__c>();
		Account_Role_Services__c accRoleServicesITP = new Account_Role_Services__c(Name = 'IFTP-ITP', Account_Roles__c = accRolesITP.Id, Portal_Service__c = portalApp.Id);
		Account_Role_Services__c accRoleServicesAirline = new Account_Role_Services__c(Name = 'IFTP - Airline', Account_Roles__c = accRolesAirline.Id, Portal_Service__c = portalApp.Id);
		accRoleServicesList.add(accRoleServicesITP);
		accRoleServicesList.add(accRoleServicesAirline);
		insert accRoleServicesList;


		//Create Accounts - ITP/Airline
		Id accOthersRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Others');
		Id airlineHeadquartersRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

		List<Account> accountList = new List<Account>();
		Account accITP = new Account(Name = 'ITP Account', IATA_ISO_Country__c = ctr1.id, Sector__c = 'Airline Supplier', Category__c = 'Fuel Supplier', RecordTypeId = accOthersRT);
		Account accAirline = new Account(Name = 'Airline Account', IATA_ISO_Country__c = ctr1.id, Sector__c = 'Airline', Category__c = 'Passenger and Cargo',Type = 'Passenger and cargo', Site = '111',Site_index__c = '111', RecordTypeId = airlineHeadquartersRT);
		Account accAirline2 = new Account(Name = 'Airline Account 2', IATA_ISO_Country__c = ctr1.id, Sector__c = 'Airline', Category__c = 'Passenger and Cargo',Type = 'Passenger and cargo', Site = '111',Site_index__c = '111', RecordTypeId = airlineHeadquartersRT);
		accountList.add(accITP);
		accountList.add(accAirline);
		accountList.add(accAirline2);
		insert accountList;
		System.debug('accountList - ' + accountList);

		//Create OJT Document
		Document OJTdocument = new Document();
		OJTdocument.Body = Blob.valueOf('Some Text');
		OJTdocument.ContentType = 'application/pdf';
		OJTdocument.DeveloperName = 'ojt_document';
		OJTdocument.IsPublic = true;
		OJTdocument.Name = 'OJT Document';
		OJTdocument.FolderId = [select id from folder where name = 'Public Folder'].id;
		insert OJTdocument;


		ContentVersion cvOJT2 = new ContentVersion();
		cvOJT2.title = 'OJT Document';
		cvOJT2.PathOnClient = 'test';
		cvOJT2.versiondata = Blob.valueOf('Some Text');
		insert cvOJT2;

		//Create Accounts Role
		Id accRoleITP_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'IFTP');

		List<Account_Role__c> accRoleList = new List<Account_Role__c>();
		Account_Role__c accRoleITP = new Account_Role__c(Account__c = accITP.Id, Account_Roles__c = accRolesITP.Id, RecordTypeId = accRoleITP_RT, OJT_File_Id__c = OJTdocument.Id, OJT_file_validated__c = true);
		Account_Role__c accRoleAirline = new Account_Role__c(Account__c = accAirline.Id, Account_Roles__c = accRolesAirline.Id, RecordTypeId = accRoleITP_RT);
		Account_Role__c accRoleAirline_2 = new Account_Role__c(Account__c = accAirline2.Id, Account_Roles__c = accRolesAirline.Id, RecordTypeId = accRoleITP_RT);
		accRoleList.add(accRoleITP);
		accRoleList.add(accRoleAirline);
		accRoleList.add(accRoleAirline_2);
		insert accRoleList;
		System.debug('accRoleList - ' + accRoleList);


		//Create Accounts Service
		List<Account_Role_Service__c> accRoleServiceList = new List<Account_Role_Service__c>();
		Account_Role_Service__c accRoleServiceITP = new Account_Role_Service__c(Account_Role__c = accRoleITP.Id, Account_Role_Services__c = accRoleServicesITP.Id);
		Account_Role_Service__c accRoleServiceAirline = new Account_Role_Service__c(Account_Role__c = accRoleAirline.Id, Account_Role_Services__c = accRoleServicesAirline.Id);
		Account_Role_Service__c accRoleServiceAirline_2 = new Account_Role_Service__c(Account_Role__c = accRoleAirline_2.Id, Account_Role_Services__c = accRoleServicesAirline.Id);
		accRoleServiceList.add(accRoleServiceITP);
		accRoleServiceList.add(accRoleServiceAirline);
		accRoleServiceList.add(accRoleServiceAirline_2);
		insert accRoleServiceList;

		System.debug('accRoleServiceList - ' + accRoleServiceList);

		//Create Contact Roles
		List<Contact_Roles__c> contactRolesList = new List<Contact_Roles__c>();
		Contact_Roles__c contactRolesITPAdmin = new Contact_Roles__c(Name = 'ITP Administrator', Service__c = portalApp.Id);
		Contact_Roles__c contactRolesITPCoord = new Contact_Roles__c(Name = 'ITP Training Coordinator', Service__c = portalApp.Id);
		Contact_Roles__c contactRolesITPMaster = new Contact_Roles__c(Name = 'ITP Master', Service__c = portalApp.Id);
		contactRolesList.add(contactRolesITPAdmin);
		contactRolesList.add(contactRolesITPCoord);
		contactRolesList.add(contactRolesITPMaster);
		insert contactRolesList;

		//Create Contacts - ITP / Airline
		Id contact_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');

		List<Contact> contactList = new List<Contact>();
		Contact cont1 = new Contact(AccountId = accITP.Id, FirstName = 'ITP Master', LastName = 'Master', Preferred_Language__c = 'English', RecordTypeId = contact_RT, email = 'test.cont1@test.com');
		Contact cont2 = new Contact(AccountId = accITP.Id, FirstName = 'ITP Admin', LastName = 'Admin', Preferred_Language__c = 'English', RecordTypeId = contact_RT, email = 'test.cont2@test.com');
		Contact cont3 = new Contact(AccountId = accITP.Id, FirstName = 'ITP Coordinator', LastName = 'Coordinator', Preferred_Language__c = 'English', RecordTypeId = contact_RT, email = 'test.cont3@test.com');
		Contact cont4 = new Contact(AccountId = accAirline.Id, FirstName = 'Airline Contact', LastName = 'Airline', Preferred_Language__c = 'English', RecordTypeId = contact_RT, email = 'test.cont4@test.com');
		Contact cont5 = new Contact(AccountId = accITP.Id, FirstName = 'ITP Student', LastName = 'Student', Preferred_Language__c = 'English', RecordTypeId = contact_RT, email = 'test.cont5@test.com');
		Contact cont50 = new Contact(AccountId = accITP.Id, FirstName = 'ITP Student 2', LastName = 'Student 2', Preferred_Language__c = 'English', RecordTypeId = contact_RT, email = 'test.cont50@test.com');
		Contact cont5S3 = new Contact(AccountId = accITP.Id, FirstName = 'ITP Student 3', LastName = 'Student 3', Preferred_Language__c = 'English', RecordTypeId = contact_RT, email = 'test.cont5S3@test.com');
		Contact cont6 = new Contact(AccountId = accITP.Id, FirstName = 'ITP Coordinator 2', LastName = 'Coordinator 2', Preferred_Language__c = 'English', RecordTypeId = contact_RT, email = 'test.cont6@test.com');
		contactList.add(cont1);
		contactList.add(cont2);
		contactList.add(cont3);
		contactList.add(cont4);
		contactList.add(cont5);
		contactList.add(cont50);
		contactList.add(cont5S3);
		contactList.add(cont6);
		insert contactList;

		//Create Portal Users
		Id profilePortalPartner = null;
		Id profilePortalPartnerAdmin = null;
		Id profilePortalAirline = null;
		Id profilePortalAirlineAdmin = null;

		List<Profile> profiles = [Select Name, Id From Profile where Name in ('ISS Portal (Partner)','ISS Portal Delegated Admin User','ISS Portal Airline User (Partner)','ISS Portal Airline Delegated Admin User')];
		for(Profile prof : profiles){
			if(prof.name == 'ISS Portal (Partner)'){
				profilePortalPartner = prof.Id;
			}else if(prof.name == 'ISS Portal Delegated Admin User'){
				profilePortalPartnerAdmin = prof.Id;
			}else if(prof.name == 'ISS Portal Airline User (Partner)'){
				profilePortalAirline = prof.Id;
			}else if(prof.name == 'ISS Portal Airline Delegated Admin User'){
				profilePortalAirlineAdmin = prof.Id;
			}
		}

		User u1 = new User(
			Username = ISSP_Utilities.buildPortalUserName('test.cont3@test.com')
			, Email = 'test.cont3@test.com'
			, emailencodingkey = 'UTF-8'
			, Alias = 'cont3'
			, FirstName = cont3.FirstName
			, LastName = cont3.LastName
			, LocaleSidKey = 'en_US'
			, CommunityNickname = 'cont3'
			, ProfileId = profilePortalPartnerAdmin
			, LanguageLocaleKey = 'en_US'
			, timezonesidkey = 'America/New_York'
			, ContactId = cont3.Id
			, IsActive = true
			, ReceivesAdminInfoEmails = false
			, ReceivesInfoEmails = false
			, UID__c = '1234'
		);
		insert u1;
		String user1Id = Site.createPortalUser(u1, accITP.Id, 'testpassword');

		User u2 = new User(
			Username = ISSP_Utilities.buildPortalUserName('test.cont4@test.com')
			, Email = 'test.cont4@test.com'
			, emailencodingkey = 'UTF-8'
			, Alias = 'cont4'
			, FirstName = cont4.FirstName
			, LastName = cont4.LastName
			, LocaleSidKey = 'en_US'
			, CommunityNickname = 'cont4'
			, ProfileId = profilePortalAirlineAdmin
			, LanguageLocaleKey = 'en_US'
			, timezonesidkey = 'America/New_York'
			, ContactId = cont4.Id
			, IsActive = true
			, ReceivesAdminInfoEmails = false
			, ReceivesInfoEmails = false
			, UID__c = '1235'
		);
		insert u2;
		String user2Id = Site.createPortalUser(u2, accAirline.Id, 'testpassword');

		User u3 = new User(
			Username = ISSP_Utilities.buildPortalUserName('test.cont6@test.com')
			, Email = 'test.cont6@test.com'
			, emailencodingkey = 'UTF-8'
			, Alias = 'cont6'
			, FirstName = cont6.FirstName
			, LastName = cont6.LastName
			, LocaleSidKey = 'en_US'
			, CommunityNickname = 'cont6'
			, ProfileId = profilePortalPartner
			, LanguageLocaleKey = 'en_US'
			, timezonesidkey = 'America/New_York'
			, ContactId = cont6.Id
			, IsActive = true
			, ReceivesAdminInfoEmails = false
			, ReceivesInfoEmails = false
			, UID__c = '1234'
		);
		insert u3;
		String user3Id = Site.createPortalUser(u3, accITP.Id, 'testpassword');

		// User Portal_Application_Right__c
		Portal_Applications__c pa = new Portal_Applications__c(Name = 'IFTP');
		insert pa;
		List<Portal_Application_Right__c> lUserPAR = new List<Portal_Application_Right__c>() ;
		Portal_Application_Right__c u3PAR = new Portal_Application_Right__c(Right__c = 'Access Granted', Portal_Application__c = pa.Id, Contact__c = cont3.Id);
		Portal_Application_Right__c u4PAR = new Portal_Application_Right__c(Right__c = 'Access Granted', Portal_Application__c = pa.Id, Contact__c = cont4.Id);
		lUserPAR.add(u3PAR);
		lUserPAR.add(u4PAR);

		insert lUserPAR;

		//Create Account Contacts Roles
		Id accContactRole_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'ITP');

		List<Account_Contact_Role__c> accountContactRoleList = new List<Account_Contact_Role__c>();
		Account_Contact_Role__c accountContactRoleITPMaster = new Account_Contact_Role__c(Status__c = 'Active', RecordTypeId = accContactRole_RT, Service_Rendered__c = 'IFTP', Contact_Roles__c = contactRolesITPMaster.Id, Account_Role__c = accRoleITP.Id, Contact__c = cont1.Id, Contact_Role__c = 'ITP Master');
		Account_Contact_Role__c accountContactRoleITPAdmin = new Account_Contact_Role__c(Status__c = 'Active', RecordTypeId = accContactRole_RT, Service_Rendered__c = 'IFTP', Contact_Roles__c = contactRolesITPAdmin.Id, Account_Role__c = accRoleITP.Id, Contact__c = cont2.Id, Contact_Role__c = 'ITP Administrator');
		Account_Contact_Role__c accountContactRoleITPCoord = new Account_Contact_Role__c(Status__c = 'Active', RecordTypeId = accContactRole_RT, Service_Rendered__c = 'IFTP', Contact_Roles__c = contactRolesITPCoord.Id, Account_Role__c = accRoleITP.Id, Contact__c = cont3.Id, Contact_Role__c = 'ITP Training Coordinator');
		Account_Contact_Role__c accountContactRoleAirline = new Account_Contact_Role__c(Status__c = 'Active', RecordTypeId = accContactRole_RT, Service_Rendered__c = 'IFTP', Account_Role__c = accRoleAirline.Id, Contact__c = cont4.Id);
		Account_Contact_Role__c accountContactRoleITPStudent = new Account_Contact_Role__c(Status__c = 'Active', RecordTypeId = accContactRole_RT, Service_Rendered__c = 'IFTP', Account_Role__c = accRoleITP.Id, Contact__c = cont5.Id, Contact_Role__c = 'ITP Trainee', Company_Code__c = 'Abc');
		Account_Contact_Role__c accountContactRoleITPStudent2 = new Account_Contact_Role__c(Status__c = 'Active', RecordTypeId = accContactRole_RT, Service_Rendered__c = 'IFTP', Account_Role__c = accRoleITP.Id, Contact__c = cont50.Id, Contact_Role__c = 'ITP Trainee', Company_Code__c = 'Abc2');
		Account_Contact_Role__c accountContactRoleITPStudent3 = new Account_Contact_Role__c(Status__c = 'Active', RecordTypeId = accContactRole_RT, Service_Rendered__c = 'IFTP', Account_Role__c = accRoleITP.Id, Contact__c = cont5S3.Id, Contact_Role__c = 'ITP Trainee', Company_Code__c = 'Abc3');
		accountContactRoleList.add(accountContactRoleITPMaster);
		accountContactRoleList.add(accountContactRoleITPAdmin);
		accountContactRoleList.add(accountContactRoleITPCoord);
		accountContactRoleList.add(accountContactRoleAirline);
		accountContactRoleList.add(accountContactRoleITPStudent);
		accountContactRoleList.add(accountContactRoleITPStudent2);
		accountContactRoleList.add(accountContactRoleITPStudent3);
		insert accountContactRoleList;

		//Create Account Role Relationship
		List<Account_Role_Relationship__c> accountRoleRelatAirlineITPList = new List<Account_Role_Relationship__c>();
		Account_Role_Relationship__c accountRoleRelatAirlineITP = new Account_Role_Relationship__c(From__c = accRoleAirline.Id, To__c = accRoleITP.Id, Portal_Service__c = portalApp.Id, Relationship_Status__c = 'Active');
		accountRoleRelatAirlineITPList.add(accountRoleRelatAirlineITP);
		insert accountRoleRelatAirlineITPList;

		//Create Role Address - ITP / Airline / Contact / Relationship

		List<Role_Address__c> roleAddressList = new List<Role_Address__c>();
		Role_Address__c roleAddressITPUser = new Role_Address__c(Account_Contact_Role__c = accountContactRoleITPCoord.Id, Address__c = add1.Id, Name = 'Role Address ITP Coord');
		Role_Address__c roleAddressITPTrainee = new Role_Address__c(Account_Contact_Role__c = accountContactRoleITPStudent.Id, Address__c = add1.Id, Name = 'Role Address ITP Trainee', Primary__c = true);
		Role_Address__c roleAddressITPTrainee2 = new Role_Address__c(Account_Contact_Role__c = accountContactRoleITPStudent.Id, Address__c = add2.Id, Name = 'Role Address ITP Trainee');
		Role_Address__c roleAddressITPTrainee1 = new Role_Address__c(Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Address__c = add1.Id, Name = 'Role Address ITP Trainee', Primary__c = true);
		Role_Address__c roleAddressITPTrainee12 = new Role_Address__c(Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Address__c = add2.Id, Name = 'Role Address ITP Trainee');
		Role_Address__c roleAddressITPTrainee3 = new Role_Address__c(Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Address__c = add1.Id, Name = 'Role Address ITP Trainee', Primary__c = true);
		Role_Address__c roleAddressITPTrainee32 = new Role_Address__c(Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Address__c = add2.Id, Name = 'Role Address ITP Trainee');
		Role_Address__c roleAddressITP = new Role_Address__c(Account_Role_Service__c = accRoleServiceITP.Id, Address__c = add1.Id, Name = 'Role Address ITP', OJT_File_Id__c = OJTdocument.Id, OJT_file_validated__c=true);
		Role_Address__c roleAddressAirlineUser = new Role_Address__c(Account_Contact_Role__c = accountContactRoleAirline.Id, Address__c = add1.Id, Name = 'Role Address Airline User');
		Role_Address__c roleAddressAirline = new Role_Address__c(Account_Role_Service__c = accRoleServiceAirline.Id, Address__c = add1.Id, Name = 'Role Address Airline');
		Role_Address__c roleAddressRelationAirlineITP = new Role_Address__c(Account_Role_Relationship__c = accountRoleRelatAirlineITP.Id, Address__c = add1.Id, Name = 'Role Address Airline vs ITP');
		roleAddressList.add(roleAddressITPUser);
		roleAddressList.add(roleAddressITPTrainee);
		roleAddressList.add(roleAddressITPTrainee2);
		roleAddressList.add(roleAddressITPTrainee1);
		roleAddressList.add(roleAddressITPTrainee12);
		roleAddressList.add(roleAddressITPTrainee3);
		roleAddressList.add(roleAddressITPTrainee32);
		roleAddressList.add(roleAddressITP);
		roleAddressList.add(roleAddressAirlineUser);
		roleAddressList.add(roleAddressAirline);
		roleAddressList.add(roleAddressRelationAirlineITP);
		insert roleAddressList;

		//Create Certification
		List<Certification__c> certificationList = new List<Certification__c>();
		Certification__c certGeneralTraining1 = new Certification__c(Name='General Training 1', Type__c = 'General', Status__c = 'Active');
		Certification__c certGeneralTraining2 = new Certification__c(Name='General Training 2', Type__c = 'General', Status__c = 'Active');
		Certification__c certGeneralTraining3 = new Certification__c(Name='General Training 3', Type__c = 'General', Status__c = 'Active');
		Certification__c certPlane1 = new Certification__c(Name='Plane 1', Type__c = 'Aircraft', Status__c = 'Active', Code__c = 'P1');
		Certification__c certPlane2 = new Certification__c(Name='Plane 2', Type__c = 'Aircraft', Status__c = 'Active', Code__c = 'P2');
		Certification__c certPlane3 = new Certification__c(Name='Plane 3', Type__c = 'Aircraft', Status__c = 'Active', Code__c = 'P3');
		Certification__c certPlaneAL2 = new Certification__c(Name='Plane A L2', Type__c = 'Aircraft', Status__c = 'Active', Code__c = 'P A L2');
		Certification__c certPlaneBL2 = new Certification__c(Name='Plane B L2', Type__c = 'Aircraft', Status__c = 'Active', Code__c = 'P B L2');
		Certification__c certPlaneCL2 = new Certification__c(Name='Plane C L2', Type__c = 'Aircraft', Status__c = 'Active', Code__c = 'P C L2');
		Certification__c certPlaneDL2 = new Certification__c(Name='Plane D L2', Type__c = 'Aircraft', Status__c = 'Active', Code__c = 'P D L2');
		Certification__c certPlaneAL3 = new Certification__c(Name='Plane A L3', Type__c = 'Aircraft', Status__c = 'Active', Code__c = 'P A L3');
		Certification__c certPlaneBL3 = new Certification__c(Name='Plane B L3', Type__c = 'Aircraft', Status__c = 'Active', Code__c = 'P B L3');
		Certification__c certPlaneCL3 = new Certification__c(Name='Plane C L3', Type__c = 'Aircraft', Status__c = 'Active', Code__c = 'P C L3');
		Certification__c certPlaneDL3 = new Certification__c(Name='Plane D L3', Type__c = 'Aircraft', Status__c = 'Active', Code__c = 'P D L3');
		certificationList.add(certGeneralTraining1);
		certificationList.add(certGeneralTraining2);
		certificationList.add(certGeneralTraining3);
		certificationList.add(certPlane1);
		certificationList.add(certPlane2);
		certificationList.add(certPlane3);
		certificationList.add(certPlaneAL2);
		certificationList.add(certPlaneBL2);
		certificationList.add(certPlaneCL2);
		certificationList.add(certPlaneDL2);
		certificationList.add(certPlaneAL3);
		certificationList.add(certPlaneBL3);
		certificationList.add(certPlaneCL3);
		certificationList.add(certPlaneDL3);
		insert certificationList;

		System.debug('certificationList' + certificationList);
		System.debug('certGeneralTraining1' + certGeneralTraining1);

		//Create IFTP Certification Detail
		List<IFTP_Certification_Detail__c> iftpCertDetailList = new List<IFTP_Certification_Detail__c>();
		IFTP_Certification_Detail__c certDetail1 = new IFTP_Certification_Detail__c(Name = 'General Training 1' , Certification__c = certGeneralTraining1.Id,
																		General_Training__c = 'Yes', Prerequisite_Level__c = 'Level 2');
		IFTP_Certification_Detail__c certDetail2 = new IFTP_Certification_Detail__c(Name = 'General Training 2' , Certification__c = certGeneralTraining2.Id,
																		General_Training__c = 'Yes', Prerequisite_Level__c = 'Level 2');
		IFTP_Certification_Detail__c certDetail3 = new IFTP_Certification_Detail__c(Name = 'General Training 3' , Certification__c = certGeneralTraining3.Id,
																		General_Training__c = 'Yes', Prerequisite_Level__c = 'Level 3');
		IFTP_Certification_Detail__c certDetail4 = new IFTP_Certification_Detail__c(Name = 'Plane 1' , Certification__c = certPlane1.Id,
																		General_Training__c = 'No', Prerequisite_Level__c = 'Level 2');
		IFTP_Certification_Detail__c certDetail5 = new IFTP_Certification_Detail__c(Name = 'Plane 2' , Certification__c = certPlane2.Id,
																		General_Training__c = 'No', Prerequisite_Level__c = 'Level 2');
		IFTP_Certification_Detail__c certDetail6 = new IFTP_Certification_Detail__c(Name = 'Plane 3' , Certification__c = certPlane3.Id,
																		General_Training__c = 'No', Prerequisite_Level__c = 'Level 3');
		IFTP_Certification_Detail__c certDetailPAL2 = new IFTP_Certification_Detail__c(Name = 'Plane A L2' , Certification__c = certPlaneAL2.Id,
																		General_Training__c = 'No', Prerequisite_Level__c = 'Level 2');
		IFTP_Certification_Detail__c certDetailPBL2 = new IFTP_Certification_Detail__c(Name = 'Plane B L2' , Certification__c = certPlaneBL2.Id,
																		General_Training__c = 'No', Prerequisite_Level__c = 'Level 2');
		IFTP_Certification_Detail__c certDetailPCL2 = new IFTP_Certification_Detail__c(Name = 'Plane C L2' , Certification__c = certPlaneCL2.Id,
																		General_Training__c = 'No', Prerequisite_Level__c = 'Level 2');
		IFTP_Certification_Detail__c certDetailPDL2 = new IFTP_Certification_Detail__c(Name = 'Plane D L2' , Certification__c = certPlaneDL2.Id,
																		General_Training__c = 'No', Prerequisite_Level__c = 'Level 2');
		IFTP_Certification_Detail__c certDetailPAL3 = new IFTP_Certification_Detail__c(Name = 'Plane A L3' , Certification__c = certPlaneAL2.Id,
																		General_Training__c = 'No', Prerequisite_Level__c = 'Level 3');
		IFTP_Certification_Detail__c certDetailPBL3 = new IFTP_Certification_Detail__c(Name = 'Plane B L3' , Certification__c = certPlaneBL2.Id,
																		General_Training__c = 'No', Prerequisite_Level__c = 'Level 3');
		IFTP_Certification_Detail__c certDetailPCL3 = new IFTP_Certification_Detail__c(Name = 'Plane C L3' , Certification__c = certPlaneCL2.Id,
																		General_Training__c = 'No', Prerequisite_Level__c = 'Level 3');
		IFTP_Certification_Detail__c certDetailPDL3 = new IFTP_Certification_Detail__c(Name = 'Plane D L3' , Certification__c = certPlaneDL2.Id,
																		General_Training__c = 'No', Prerequisite_Level__c = 'Level 3');
		iftpCertDetailList.add(certDetail1);
		iftpCertDetailList.add(certDetail2);
		iftpCertDetailList.add(certDetail3);
		iftpCertDetailList.add(certDetail4);
		iftpCertDetailList.add(certDetail5);
		iftpCertDetailList.add(certDetail6);
		iftpCertDetailList.add(certDetailPAL2);
		iftpCertDetailList.add(certDetailPBL2);
		iftpCertDetailList.add(certDetailPCL2);
		iftpCertDetailList.add(certDetailPDL2);
		iftpCertDetailList.add(certDetailPAL3);
		iftpCertDetailList.add(certDetailPBL3);
		iftpCertDetailList.add(certDetailPCL3);
		iftpCertDetailList.add(certDetailPDL3);
		insert iftpCertDetailList;

		System.debug('iftpCertDetailList' + iftpCertDetailList);
		System.debug('certDetail1' + certDetail1);

		//Create Contact Role Certification
		List<Contact_Role_Certification__c> contRoleCertifList = new List<Contact_Role_Certification__c>();
		//Student 1
		Contact_Role_Certification__c contRoleCertifS1GT1 = new Contact_Role_Certification__c(Name = 'Certification S1 GT 1', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certGeneralTraining1.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS1GT1');
		Contact_Role_Certification__c contRoleCertifS1GT2 = new Contact_Role_Certification__c(Name = 'Certification S1 GT 2', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certGeneralTraining2.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS1GT2');
		Contact_Role_Certification__c contRoleCertifS1GT3 = new Contact_Role_Certification__c(Name = 'Certification S1 GT 3', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certGeneralTraining3.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS1GT3');
		Contact_Role_Certification__c contRoleCertifS1PAL2 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane A L2', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneAL2.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS1PAL2');
		Contact_Role_Certification__c contRoleCertifS1PAL2R1 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane A L2 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneAL2.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS1PAL2R1');
		Contact_Role_Certification__c contRoleCertifS1PBL2 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane B L2', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneBL2.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS1PBL2');
		Contact_Role_Certification__c contRoleCertifS1PBL2R1 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane B L2 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneBL2.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS1PBL2R1');
		Contact_Role_Certification__c contRoleCertifS1PCL2 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane C L2', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneCL2.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS1PCL2');
		Contact_Role_Certification__c contRoleCertifS1PCL2R1 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane C L2 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneCL2.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS1PCL2R1');
		Contact_Role_Certification__c contRoleCertifS1PDL2 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane D L2', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneDL2.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS1PDL2');
		Contact_Role_Certification__c contRoleCertifS1PDL2R1 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane D L2 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneDL2.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS1PDL2R1');


		Contact_Role_Certification__c contRoleCertifS1PAL3 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane A L3', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneAL3.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS1PAL3');
		Contact_Role_Certification__c contRoleCertifS1PAL3R1 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane A L3 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneAL3.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS1PAL3R1');
		Contact_Role_Certification__c contRoleCertifS1PBL3 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane B L3', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneBL3.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS1PBL3');
		Contact_Role_Certification__c contRoleCertifS1PBL3R1 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane B L3 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneBL3.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS1PBL3R1');
		Contact_Role_Certification__c contRoleCertifS1PCL3 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane C L3', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneCL3.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS1PCL3');
		Contact_Role_Certification__c contRoleCertifS1PCL3R1 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane C L3 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneCL3.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS1PCL3R1');
		Contact_Role_Certification__c contRoleCertifS1PDL3 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane D L3', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneDL3.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS1PDL3');
		Contact_Role_Certification__c contRoleCertifS1PDL3R1 = new Contact_Role_Certification__c(Name = 'Certification S1 Plane D L3 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlaneDL3.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS1PDL3R1');
		contRoleCertifList.add(contRoleCertifS1GT1);
		contRoleCertifList.add(contRoleCertifS1GT2);
		contRoleCertifList.add(contRoleCertifS1GT3);

		contRoleCertifList.add(contRoleCertifS1PAL2);
		contRoleCertifList.add(contRoleCertifS1PAL2R1);
		contRoleCertifList.add(contRoleCertifS1PBL2);
		contRoleCertifList.add(contRoleCertifS1PBL2R1);
		contRoleCertifList.add(contRoleCertifS1PCL2);
		contRoleCertifList.add(contRoleCertifS1PCL2R1);
		contRoleCertifList.add(contRoleCertifS1PDL2);
		contRoleCertifList.add(contRoleCertifS1PDL2R1);

		contRoleCertifList.add(contRoleCertifS1PAL3);
		contRoleCertifList.add(contRoleCertifS1PAL3R1);
		contRoleCertifList.add(contRoleCertifS1PBL3);
		contRoleCertifList.add(contRoleCertifS1PBL3R1);
		contRoleCertifList.add(contRoleCertifS1PCL3);
		contRoleCertifList.add(contRoleCertifS1PCL3R1);
		contRoleCertifList.add(contRoleCertifS1PDL3);
		contRoleCertifList.add(contRoleCertifS1PDL3R1);
		//Student 1

		Contact_Role_Certification__c contRoleCertifGT1 = new Contact_Role_Certification__c(Name = 'Certification GT 1', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certGeneralTraining1.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment1');
		Contact_Role_Certification__c contRoleCertifGT111 = new Contact_Role_Certification__c(Name = 'Certification GT 1', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certGeneralTraining1.Id, Expiration_Date__c = date.today().addDays(20), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment100');
		Contact_Role_Certification__c contRoleCertifGT2 = new Contact_Role_Certification__c(Name = 'Certification GT 2', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certGeneralTraining2.Id, Expiration_Date__c = date.today().addDays(11), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment2');
		Contact_Role_Certification__c contRoleCertifGT3 = new Contact_Role_Certification__c(Name = 'Certification GT 3', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certGeneralTraining3.Id, Expiration_Date__c = date.today().addDays(11), Proficiency__c = 'Level 3', AssessmentId__c = 'Assessment3');
		Contact_Role_Certification__c contRoleCertifPlane1 = new Contact_Role_Certification__c(Name = 'Certification Plane 1A', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlane1.Id, Expiration_Date__c = date.today().addDays(12), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment4');
		Contact_Role_Certification__c contRoleCertifPlane2 = new Contact_Role_Certification__c(Name = 'Certification Plane 2', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlane2.Id, Expiration_Date__c = date.today().addDays(13), Proficiency__c = 'Level 3', AssessmentId__c = 'Assessment5');
		Contact_Role_Certification__c contRoleCertifPlane3 = new Contact_Role_Certification__c(Name = 'Certification Plane 3', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlane3.Id, Expiration_Date__c = date.today().addDays(30), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment50');
		Contact_Role_Certification__c contRoleCertifPlane31 = new Contact_Role_Certification__c(Name = 'Certification Plane 3 Old', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlane3.Id, Expiration_Date__c = date.today().addDays(13), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment51');

		contRoleCertifList.add(contRoleCertifGT1);
		contRoleCertifList.add(contRoleCertifGT111);
		contRoleCertifList.add(contRoleCertifGT2);
		contRoleCertifList.add(contRoleCertifGT3);
		contRoleCertifList.add(contRoleCertifPlane1);
		contRoleCertifList.add(contRoleCertifPlane2);
		contRoleCertifList.add(contRoleCertifPlane3);
		contRoleCertifList.add(contRoleCertifPlane31);


		//Student 2
		Contact_Role_Certification__c contRoleCertifS2GT1 = new Contact_Role_Certification__c(Name = 'Certification S2 GT 1', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certGeneralTraining1.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS2GT1');
		Contact_Role_Certification__c contRoleCertifS2GT2 = new Contact_Role_Certification__c(Name = 'Certification S2 GT 2', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certGeneralTraining2.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS2GT2');
		Contact_Role_Certification__c contRoleCertifS2GT3 = new Contact_Role_Certification__c(Name = 'Certification S2 GT 3', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certGeneralTraining3.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS2GT3');

		Contact_Role_Certification__c contRoleCertifS2PAL2 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane A L2', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneAL2.Id, Expiration_Date__c = date.today().addDays(-10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS2PAL2');
		Contact_Role_Certification__c contRoleCertifS2PAL2R1 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane A L2 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneAL2.Id, Expiration_Date__c = date.today().addDays(-5), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS2PAL2R1');
		Contact_Role_Certification__c contRoleCertifS2PBL2 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane B L2', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneBL2.Id, Expiration_Date__c = date.today().addDays(-10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS2PBL2');
		Contact_Role_Certification__c contRoleCertifS2PBL2R1 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane B L2 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneBL2.Id, Expiration_Date__c = date.today().addDays(-5), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS2PBL2R1');
		Contact_Role_Certification__c contRoleCertifS2PCL2 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane C L2', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneCL2.Id, Expiration_Date__c = date.today().addDays(-10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS2PCL2');
		Contact_Role_Certification__c contRoleCertifS2PCL2R1 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane C L2 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneCL2.Id, Expiration_Date__c = date.today().addDays(-5), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS2PCL2R1');
		Contact_Role_Certification__c contRoleCertifS2PDL2 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane D L2', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneDL2.Id, Expiration_Date__c = date.today().addDays(-10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS2PDL2');
		Contact_Role_Certification__c contRoleCertifS2PDL2R1 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane D L2 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneDL2.Id, Expiration_Date__c = date.today().addDays(-5), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS2PDL2R1');

		Contact_Role_Certification__c contRoleCertifS2PAL3 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane A L3', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneAL3.Id, Expiration_Date__c = date.today().addDays(-10), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS2PAL3');
		Contact_Role_Certification__c contRoleCertifS2PAL3R1 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane A L3 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneAL3.Id, Expiration_Date__c = date.today().addDays(-5), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS2PAL3R1');
		Contact_Role_Certification__c contRoleCertifS2PBL3 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane B L3', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneBL3.Id, Expiration_Date__c = date.today().addDays(-10), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentPBL3');
		Contact_Role_Certification__c contRoleCertifS2PBL3R1 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane B L3 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneBL3.Id, Expiration_Date__c = date.today().addDays(-5), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentPBL3R1');
		Contact_Role_Certification__c contRoleCertifS2PCL3 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane C L3', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneCL3.Id, Expiration_Date__c = date.today().addDays(-10), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS2PCL3');
		Contact_Role_Certification__c contRoleCertifS2PCL3R1 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane C L3 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneCL3.Id, Expiration_Date__c = date.today().addDays(-5), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS2PCL3R1');
		Contact_Role_Certification__c contRoleCertifS2PDL3 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane D L3', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneDL3.Id, Expiration_Date__c = date.today().addDays(-10), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS2PDL3');
		Contact_Role_Certification__c contRoleCertifS2PDL3R1 = new Contact_Role_Certification__c(Name = 'Certification S2 Plane D L3 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlaneDL3.Id, Expiration_Date__c = date.today().addDays(-5), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS2PDL3R1');

		Contact_Role_Certification__c contRoleCertifGT10 = new Contact_Role_Certification__c(Name = 'Certification GT 1', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certGeneralTraining1.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment6');
		Contact_Role_Certification__c contRoleCertifGT20 = new Contact_Role_Certification__c(Name = 'Certification GT 2', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certGeneralTraining2.Id, Expiration_Date__c = date.today().addDays(11), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment7');
		Contact_Role_Certification__c contRoleCertifGT30 = new Contact_Role_Certification__c(Name = 'Certification GT 3', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certGeneralTraining3.Id, Expiration_Date__c = date.today().addDays(12), Proficiency__c = 'Level 3', AssessmentId__c = 'Assessment8');
		Contact_Role_Certification__c contRoleCertifPlane10 = new Contact_Role_Certification__c(Name = 'Certification Plane 1', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlane1.Id, Expiration_Date__c = date.today().addDays(-10), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment9');
		Contact_Role_Certification__c contRoleCertifPlane11 = new Contact_Role_Certification__c(Name = 'Certification Plane 1 renew', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlane1.Id, Expiration_Date__c = date.today().addDays(20), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment90');
		Contact_Role_Certification__c contRoleCertifPlane20 = new Contact_Role_Certification__c(Name = 'Certification Plane 2', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlane2.Id, Expiration_Date__c = date.today().addDays(13), Proficiency__c = 'Level 3', AssessmentId__c = 'Assessment10');
		Contact_Role_Certification__c contRoleCertifPlane21 = new Contact_Role_Certification__c(Name = 'Certification Plane 3', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlane3.Id, Expiration_Date__c = date.today().addDays(3), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment11');
		Contact_Role_Certification__c contRoleCertifPlane22 = new Contact_Role_Certification__c(Name = 'Certification Plane 3 renew', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlane3.Id, Expiration_Date__c = date.today().addDays(13), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment12');

		contRoleCertifList.add(contRoleCertifS2GT1);
		contRoleCertifList.add(contRoleCertifS2GT2);
		contRoleCertifList.add(contRoleCertifS2GT3);

		contRoleCertifList.add(contRoleCertifS2PAL2);
		contRoleCertifList.add(contRoleCertifS2PAL2R1);
		contRoleCertifList.add(contRoleCertifS2PBL2);
		contRoleCertifList.add(contRoleCertifS2PBL2R1);
		contRoleCertifList.add(contRoleCertifS2PCL2);
		contRoleCertifList.add(contRoleCertifS2PCL2R1);
		contRoleCertifList.add(contRoleCertifS2PDL2);
		contRoleCertifList.add(contRoleCertifS2PDL2R1);

		contRoleCertifList.add(contRoleCertifS2PAL3);
		contRoleCertifList.add(contRoleCertifS2PAL3R1);
		contRoleCertifList.add(contRoleCertifS2PBL3);
		contRoleCertifList.add(contRoleCertifS2PBL3R1);
		contRoleCertifList.add(contRoleCertifS2PCL3);
		contRoleCertifList.add(contRoleCertifS2PCL3R1);
		contRoleCertifList.add(contRoleCertifS2PDL3);
		contRoleCertifList.add(contRoleCertifS2PDL3R1);

		contRoleCertifList.add(contRoleCertifGT10);
		contRoleCertifList.add(contRoleCertifGT20);
		contRoleCertifList.add(contRoleCertifGT30);
		contRoleCertifList.add(contRoleCertifPlane10);
		contRoleCertifList.add(contRoleCertifPlane11);
		contRoleCertifList.add(contRoleCertifPlane20);
		contRoleCertifList.add(contRoleCertifPlane21);
		contRoleCertifList.add(contRoleCertifPlane22);

		//Student 3
		Contact_Role_Certification__c contRoleCertifS3GT1 = new Contact_Role_Certification__c(Name = 'Certification S3 GT 1', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certGeneralTraining1.Id, Expiration_Date__c = date.today().addDays(-10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS3GT1');
		Contact_Role_Certification__c contRoleCertifS3GT2 = new Contact_Role_Certification__c(Name = 'Certification S3 GT 2', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certGeneralTraining2.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS3GT2');
		Contact_Role_Certification__c contRoleCertifS3GT3 = new Contact_Role_Certification__c(Name = 'Certification S3 GT 3', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certGeneralTraining3.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS3GT3');
		Contact_Role_Certification__c contRoleCertifS3PAL2 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane A L2', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneAL2.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS3PAL2');
		Contact_Role_Certification__c contRoleCertifS3PAL2R1 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane A L2 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneAL2.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS3PAL2R1');
		Contact_Role_Certification__c contRoleCertifS3PBL2 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane B L2', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneBL2.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS3PBL2');
		Contact_Role_Certification__c contRoleCertifS3PBL2R1 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane B L2 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneBL2.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS3PBL2R1');
		Contact_Role_Certification__c contRoleCertifS3PCL2 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane C L2', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneCL2.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS3PCL2');
		Contact_Role_Certification__c contRoleCertifS3PCL2R1 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane C L2 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneCL2.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS3PCL2R1');
		Contact_Role_Certification__c contRoleCertifS3PDL2 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane D L2', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneDL2.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS3PDL2');
		Contact_Role_Certification__c contRoleCertifS3PDL2R1 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane D L2 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneDL2.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'AssessmentS3PDL2R1');


		Contact_Role_Certification__c contRoleCertifS3PAL3 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane A L3', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneAL3.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS3PAL3');
		Contact_Role_Certification__c contRoleCertifS3PAL3R1 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane A L3 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneAL3.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS3PAL3R1');
		Contact_Role_Certification__c contRoleCertifS3PBL3 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane B L3', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneBL3.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS3PBL3');
		Contact_Role_Certification__c contRoleCertifS3PBL3R1 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane B L3 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneBL3.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS3PBL3R1');
		Contact_Role_Certification__c contRoleCertifS3PCL3 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane C L3', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneCL3.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS3PCL3');
		Contact_Role_Certification__c contRoleCertifS3PCL3R1 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane C L3 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneCL3.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS3PCL3R1');
		Contact_Role_Certification__c contRoleCertifS3PDL3 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane D L3', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneDL3.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS3PDL3');
		Contact_Role_Certification__c contRoleCertifS3PDL3R1 = new Contact_Role_Certification__c(Name = 'Certification S3 Plane D L3 Renew 1', Account_Contact_Role__c = accountContactRoleITPStudent3.Id, Certification__c = certPlaneDL3.Id, Expiration_Date__c = date.today().addDays(15), Proficiency__c = 'Level 3', AssessmentId__c = 'AssessmentS3PDL3R1');
		contRoleCertifList.add(contRoleCertifS3GT1);
		contRoleCertifList.add(contRoleCertifS3GT2);
		contRoleCertifList.add(contRoleCertifS3GT3);

		contRoleCertifList.add(contRoleCertifS3PAL2);
		contRoleCertifList.add(contRoleCertifS3PAL2R1);
		contRoleCertifList.add(contRoleCertifS3PBL2);
		contRoleCertifList.add(contRoleCertifS3PBL2R1);
		contRoleCertifList.add(contRoleCertifS3PCL2);
		contRoleCertifList.add(contRoleCertifS3PCL2R1);
		contRoleCertifList.add(contRoleCertifS3PDL2);
		contRoleCertifList.add(contRoleCertifS3PDL2R1);

		contRoleCertifList.add(contRoleCertifS3PAL3);
		contRoleCertifList.add(contRoleCertifS3PAL3R1);
		contRoleCertifList.add(contRoleCertifS3PBL3);
		contRoleCertifList.add(contRoleCertifS3PBL3R1);
		contRoleCertifList.add(contRoleCertifS3PCL3);
		contRoleCertifList.add(contRoleCertifS3PCL3R1);
		contRoleCertifList.add(contRoleCertifS3PDL3);
		contRoleCertifList.add(contRoleCertifS3PDL3R1);

		insert contRoleCertifList;

		//Create Proficiency Records
		List<Role_Address__c> proficiencyRecordsList = new List<Role_Address__c>();
		//Student 1
		Role_Address__c proficiencyS1P1 = new Role_Address__c(Name = 'Proficiency S1 Plane 1 L2', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifPlane1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS1PAL2 = new Role_Address__c(Name = 'Proficiency S1 Plane A L2', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PAL2.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS1PAL2R1 = new Role_Address__c(Name = 'Proficiency S1 Plane A L2 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PAL2R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS1PBL2 = new Role_Address__c(Name = 'Proficiency S1 Plane B L2', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PBL2.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS1PBL2R1 = new Role_Address__c(Name = 'Proficiency S1 Plane B L2 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PBL2R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS1PCL2 = new Role_Address__c(Name = 'Proficiency S1 Plane C L2', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PCL2.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS1PCL2R1 = new Role_Address__c(Name = 'Proficiency S1 Plane C L2 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PCL2R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS1PDL2 = new Role_Address__c(Name = 'Proficiency S1 Plane D L2', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PDL2.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS1PDL2R1 = new Role_Address__c(Name = 'Proficiency S1 Plane D L2 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PDL2R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');


		Role_Address__c proficiencyS1PAL3 = new Role_Address__c(Name = 'Proficiency S1 Plane A L3', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PAL3.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS1PAL3R1 = new Role_Address__c(Name = 'Proficiency S1 Plane A L3 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PAL3R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS1PBL3 = new Role_Address__c(Name = 'Proficiency S1 Plane B L3', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PBL3.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS1PBL3R1 = new Role_Address__c(Name = 'Proficiency S1 Plane B L3 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PBL3R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS1PCL3 = new Role_Address__c(Name = 'Proficiency S1 Plane C L3', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PCL3.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS1PCL3R1 = new Role_Address__c(Name = 'Proficiency S1 Plane C L3 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PCL3R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS1PDL3 = new Role_Address__c(Name = 'Proficiency S1 Plane D L3', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PDL3.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS1PDL3R1 = new Role_Address__c(Name = 'Proficiency S1 Plane D L3 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PDL3R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');

		proficiencyRecordsList.add(proficiencyS1P1);
		proficiencyRecordsList.add(proficiencyS1PAL2);
		proficiencyRecordsList.add(proficiencyS1PAL2R1);
		proficiencyRecordsList.add(proficiencyS1PBL2);
		proficiencyRecordsList.add(proficiencyS1PBL2R1);
		proficiencyRecordsList.add(proficiencyS1PCL2);
		proficiencyRecordsList.add(proficiencyS1PCL2R1);
		proficiencyRecordsList.add(proficiencyS1PDL2);
		proficiencyRecordsList.add(proficiencyS1PDL2R1);

		proficiencyRecordsList.add(proficiencyS1PAL3);
		proficiencyRecordsList.add(proficiencyS1PAL3R1);
		proficiencyRecordsList.add(proficiencyS1PBL3);
		proficiencyRecordsList.add(proficiencyS1PBL3R1);
		proficiencyRecordsList.add(proficiencyS1PCL3);
		proficiencyRecordsList.add(proficiencyS1PCL3R1);
		proficiencyRecordsList.add(proficiencyS1PDL3);
		proficiencyRecordsList.add(proficiencyS1PDL3R1);

		//Student 2
		Role_Address__c proficiencyS2PAL2 = new Role_Address__c(Name = 'Proficiency S2 Plane A L2', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS2PAL2.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS2PAL2R1 = new Role_Address__c(Name = 'Proficiency S2 Plane A L2 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS2PAL2R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS2PBL2 = new Role_Address__c(Name = 'Proficiency S2 Plane B L2', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS2PBL2.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS2PBL2R1 = new Role_Address__c(Name = 'Proficiency S2 Plane B L2 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS2PBL2R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS2PCL2 = new Role_Address__c(Name = 'Proficiency S2 Plane C L2', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS2PCL2.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS2PCL2R1 = new Role_Address__c(Name = 'Proficiency S2 Plane C L2 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS2PCL2R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS2PDL2 = new Role_Address__c(Name = 'Proficiency S2 Plane D L2', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS2PDL2.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS2PDL2R1 = new Role_Address__c(Name = 'Proficiency S2 Plane D L2 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS2PDL2R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');



		Role_Address__c proficiencyS2PAL3 = new Role_Address__c(Name = 'Proficiency S2 Plane A L3', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS2PAL3.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS2PAL3R1 = new Role_Address__c(Name = 'Proficiency S2 Plane A L3 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS2PAL3R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS2PBL3 = new Role_Address__c(Name = 'Proficiency S2 Plane B L3', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS2PBL3.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS2PBL3R1 = new Role_Address__c(Name = 'Proficiency S2 Plane B L3 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PBL3R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS2PCL3 = new Role_Address__c(Name = 'Proficiency S2 Plane C L3', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PCL3.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS2PCL3R1 = new Role_Address__c(Name = 'Proficiency S2 Plane C L3 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PCL3R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS2PDL3 = new Role_Address__c(Name = 'Proficiency S2 Plane D L3', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PDL3.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyS2PDL3R1 = new Role_Address__c(Name = 'Proficiency S2 Plane D L3 Renew 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifS1PDL3R1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');

		proficiencyRecordsList.add(proficiencyS2PAL2);
		proficiencyRecordsList.add(proficiencyS2PAL2R1);
		proficiencyRecordsList.add(proficiencyS2PBL2);
		proficiencyRecordsList.add(proficiencyS2PBL2R1);
		proficiencyRecordsList.add(proficiencyS2PCL2);
		proficiencyRecordsList.add(proficiencyS2PCL2R1);
		proficiencyRecordsList.add(proficiencyS2PDL2);
		proficiencyRecordsList.add(proficiencyS2PDL2R1);

		proficiencyRecordsList.add(proficiencyS2PAL3);
		proficiencyRecordsList.add(proficiencyS2PAL3R1);
		proficiencyRecordsList.add(proficiencyS2PBL3);
		proficiencyRecordsList.add(proficiencyS2PBL3R1);
		proficiencyRecordsList.add(proficiencyS2PCL3);
		proficiencyRecordsList.add(proficiencyS2PCL3R1);
		proficiencyRecordsList.add(proficiencyS2PDL3);
		proficiencyRecordsList.add(proficiencyS2PDL3R1);

		Role_Address__c proficiencyRec2 = new Role_Address__c(Name = 'Proficiency Record 2', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifPlane2.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyRec10 = new Role_Address__c(Name = 'Proficiency Record 10', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifPlane10.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyRec11 = new Role_Address__c(Name = 'Proficiency Record 11', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifPlane11.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyRec20 = new Role_Address__c(Name = 'Proficiency Record 20', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifPlane20.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyRec3 = new Role_Address__c(Name = 'Proficiency Record 3', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifPlane3.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyRec31 = new Role_Address__c(Name = 'Proficiency Record 31', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifPlane31.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'No', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyRec311 = new Role_Address__c(Name = 'Proficiency Record 311', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifPlane21.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
		Role_Address__c proficiencyRec312 = new Role_Address__c(Name = 'Proficiency Record 312', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifPlane22.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');

		proficiencyRecordsList.add(proficiencyRec2);
		proficiencyRecordsList.add(proficiencyRec10);
		proficiencyRecordsList.add(proficiencyRec11);
		proficiencyRecordsList.add(proficiencyRec20);
		proficiencyRecordsList.add(proficiencyRec3);
		proficiencyRecordsList.add(proficiencyRec31);
		proficiencyRecordsList.add(proficiencyRec311);
		proficiencyRecordsList.add(proficiencyRec312);

		insert proficiencyRecordsList;

		id auxFolderId = [select id from folder where name = 'Public Folder' limit 1].id;

		//Create Insert Employee Document
		ContentVersion stationInsDocument = new ContentVersion();
		String sBody = 'code\n' +
			'PTX\n' +
			'GVX\n' +
			'aab';
		stationInsDocument.VersionData = Blob.valueOf(sBody);
		stationInsDocument.PathOnClient = 'station_ins_document.csv';
		stationInsDocument.IsMajorVersion = true;
		stationInsDocument.Title = 'Station Ins Document';
		insert stationInsDocument;

		// Create delete employees document
		ContentVersion employeesCodesDelDocument = new ContentVersion();
		String sBody4 = 'Employee Code\n' +
			'Abc';
		employeesCodesDelDocument.VersionData = Blob.valueOf(sBody4);
		employeesCodesDelDocument.PathOnClient = 'employees_del_document.csv';
		employeesCodesDelDocument.IsMajorVersion = true;
		employeesCodesDelDocument.Title = 'Employees Del Document';
		insert employeesCodesDelDocument;

		ContentVersion employeesCodesDelDocument2 = new ContentVersion();
		String sBody5 = 'Employee Code\n\n' +
			'Abc\n' +
			'MMM';
		employeesCodesDelDocument2.VersionData = Blob.valueOf(sBody5);
		employeesCodesDelDocument2.PathOnClient = 'employees_del_document2.csv';
		employeesCodesDelDocument2.IsMajorVersion = true;
		employeesCodesDelDocument2.Title = 'Employees Del Document 2';
		insert employeesCodesDelDocument2;

		//Create Insert Employee Document
		ContentVersion empInsDocument = new ContentVersion();
		String sBody2 = 'Employee Code,First Name,Last Name,Coordinator,Business Email,Stations Codes\n' +
			'"MZ414","Abel14","Chain14","Title","123456","AbChain14@demo.com","GVX; GVX"\n' +
			'"MZ414","Aaron","Chain","Title","123456","AaronChain@demo.com","GVX; GVX"\n' +
			'"MA415","Abel15","Chain15","Title","","AbChain15@demo.com","GVX; PTX; FRX"\n' +
			'"MA416","Abel16","Chain16","Title","123456","AbChain16@demo.com","GVX"\n';
		empInsDocument.VersionData = Blob.valueOf(sBody2);
		empInsDocument.PathOnClient = 'emp_ins_document.csv';
		empInsDocument.IsMajorVersion = true;
		empInsDocument.Title = 'Emp Ins Document';
		insert empInsDocument;

		ContentVersion empInsDocument2 = new ContentVersion();
		String sBody3 = 'Employee Code,First Name,Last Name,Coordinator,Business Email,Stations Codes\n' +
			'"","Abel14","Chain14","Title","123456","AbChain14@demo.com","GVX"\n' +
			'"MA415","Abel15","","Title","","AbChain15@demo.com","GVX"\n' +
			'"MA416","","Chain16","Title","123456","AbChain16@demo.com",""\n' +
			'"MZ414","Abel14","Chain14","Title","123456","AbChain14@demo.com","PTX"\n' +
			'"Abc","Abel14","Chain14","Title","123456","AbChain14@demo.com","PTX"\n';
		empInsDocument2.VersionData = Blob.valueOf(sBody3);
		empInsDocument2.PathOnClient = 'emp_ins_document2.csv';
		empInsDocument2.IsMajorVersion = true;
		empInsDocument2.Title = 'Emp Ins Document2';
		insert empInsDocument2;

		ContentVersion empInsDocument3 = new ContentVersion();
		String sBody6 = 'Employee Code,First Name,Last Name,Coordinator,Business Email,Stations Codes\n' +
			'"","Abel14","Chain14","Title","123456","AbChain14@demo.com","GVX"\n' +
			'"Abc","Abel14","Chain14","Title","123456","AbChain14@demo.com","FRX"\n' +
			'"MA415","Abel15","Chain15","Title","","AbChain15@demo.com","FRX; PTX"\n';
		empInsDocument3.VersionData = Blob.valueOf(sBody6);
		empInsDocument3.PathOnClient = 'emp_ins_document3.csv';
		empInsDocument3.IsMajorVersion = true;
		empInsDocument3.Title = 'Emp Ins Document3';
		insert empInsDocument3;

		List<ISSP_CS__c> isspCs = new List<ISSP_CS__c>();
		isspCs.add( new ISSP_CS__c(Name = 'IFTP-DocumentLibrary',Value__c = '0581j00000050jV'));
		insert isspCs;

	}

}