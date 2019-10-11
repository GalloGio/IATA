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
        Address__c add3 = new Address__c(City__c = 'ParisX', Code__c = 'FRX', IATA_ISO_Country__c = ctr3.Id);
        addressList.add(add1);
        addressList.add(add2);
        addressList.add(add3);
        insert addressList;

        //Create Portal Application
        Portal_Applications__c portalApp = new Portal_Applications__c(Name = 'IFTP');
        insert portalApp;

        //Create Accounts Roles
        List<Account_Roles__c> accRolesList = new List<Account_Roles__c>();
        Account_Roles__c accRolesITP = new Account_Roles__c(Name = 'ITP');
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

        //Create Accounts Role
        Id accRoleITP_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'ITP');

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
        Contact cont6 = new Contact(AccountId = accITP.Id, FirstName = 'ITP Coordinator 2', LastName = 'Coordinator 2', Preferred_Language__c = 'English', RecordTypeId = contact_RT, email = 'test.cont6@test.com');
        contactList.add(cont1);
        contactList.add(cont2);
        contactList.add(cont3);
        contactList.add(cont4);
        contactList.add(cont5);
        contactList.add(cont50);
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

        //Create Account Contacts Roles
        Id accContactRole_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'ITP');
        
        List<Account_Contact_Role__c> accountContactRoleList = new List<Account_Contact_Role__c>();
        Account_Contact_Role__c accountContactRoleITPMaster = new Account_Contact_Role__c(Status__c = 'Active', RecordTypeId = accContactRole_RT, Service_Rendered__c = 'IFTP', Contact_Roles__c = contactRolesITPMaster.Id, Account_Role__c = accRoleITP.Id, Contact__c = cont1.Id, Contact_Role__c = 'ITP Master');
        Account_Contact_Role__c accountContactRoleITPAdmin = new Account_Contact_Role__c(Status__c = 'Active', RecordTypeId = accContactRole_RT, Service_Rendered__c = 'IFTP', Contact_Roles__c = contactRolesITPAdmin.Id, Account_Role__c = accRoleITP.Id, Contact__c = cont2.Id, Contact_Role__c = 'ITP Administrator');
        Account_Contact_Role__c accountContactRoleITPCoord = new Account_Contact_Role__c(Status__c = 'Active', RecordTypeId = accContactRole_RT, Service_Rendered__c = 'IFTP', Contact_Roles__c = contactRolesITPCoord.Id, Account_Role__c = accRoleITP.Id, Contact__c = cont3.Id, Contact_Role__c = 'ITP Training Coordinator');
        Account_Contact_Role__c accountContactRoleAirline = new Account_Contact_Role__c(Status__c = 'Active', RecordTypeId = accContactRole_RT, Service_Rendered__c = 'IFTP', Account_Role__c = accRoleAirline.Id, Contact__c = cont4.Id);
        Account_Contact_Role__c accountContactRoleITPStudent = new Account_Contact_Role__c(Status__c = 'Active', RecordTypeId = accContactRole_RT, Service_Rendered__c = 'IFTP', Account_Role__c = accRoleITP.Id, Contact__c = cont5.Id, Contact_Role__c = 'ITP Trainee', Company_Code__c = 'Abc');
        Account_Contact_Role__c accountContactRoleITPStudent2 = new Account_Contact_Role__c(Status__c = 'Active', RecordTypeId = accContactRole_RT, Service_Rendered__c = 'IFTP', Account_Role__c = accRoleITP.Id, Contact__c = cont50.Id, Contact_Role__c = 'ITP Trainee', Company_Code__c = 'Abc2');
        accountContactRoleList.add(accountContactRoleITPMaster);
        accountContactRoleList.add(accountContactRoleITPAdmin);
        accountContactRoleList.add(accountContactRoleITPCoord);
        accountContactRoleList.add(accountContactRoleAirline);
        accountContactRoleList.add(accountContactRoleITPStudent);
        accountContactRoleList.add(accountContactRoleITPStudent2);
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
        Role_Address__c roleAddressITP = new Role_Address__c(Account_Role_Service__c = accRoleServiceITP.Id, Address__c = add1.Id, Name = 'Role Address ITP', OJT_File_Id__c = OJTdocument.Id, OJT_file_validated__c=true);
        Role_Address__c roleAddressAirlineUser = new Role_Address__c(Account_Contact_Role__c = accountContactRoleAirline.Id, Address__c = add1.Id, Name = 'Role Address Airline User');
        Role_Address__c roleAddressAirline = new Role_Address__c(Account_Role_Service__c = accRoleServiceAirline.Id, Address__c = add1.Id, Name = 'Role Address Airline');
        Role_Address__c roleAddressRelationAirlineITP = new Role_Address__c(Account_Role_Relationship__c = accountRoleRelatAirlineITP.Id, Address__c = add1.Id, Name = 'Role Address Airline vs ITP');
        roleAddressList.add(roleAddressITPUser);
        roleAddressList.add(roleAddressITPTrainee);
        roleAddressList.add(roleAddressITPTrainee2);
        roleAddressList.add(roleAddressITPTrainee1);
        roleAddressList.add(roleAddressITPTrainee12);
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
        certificationList.add(certGeneralTraining1);
        certificationList.add(certGeneralTraining2);
        certificationList.add(certGeneralTraining3);
        certificationList.add(certPlane1);
        certificationList.add(certPlane2);
        certificationList.add(certPlane3);
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
                                                                        General_Training__c = 'No', Prerequisite_Level__c = 'Level 3');
        IFTP_Certification_Detail__c certDetail6 = new IFTP_Certification_Detail__c(Name = 'Plane 3' , Certification__c = certPlane3.Id, 
                                                                        General_Training__c = 'No', Prerequisite_Level__c = 'Level 2');

        iftpCertDetailList.add(certDetail1);
        iftpCertDetailList.add(certDetail2);
        iftpCertDetailList.add(certDetail3);
        iftpCertDetailList.add(certDetail4);
        iftpCertDetailList.add(certDetail5);
        iftpCertDetailList.add(certDetail6);
        insert iftpCertDetailList;

        System.debug('iftpCertDetailList' + iftpCertDetailList);
        System.debug('certDetail1' + certDetail1);

        //Create Contact Role Certification
        List<Contact_Role_Certification__c> contRoleCertifList = new List<Contact_Role_Certification__c>();
        //Student 1
        Contact_Role_Certification__c contRoleCertifGT1 = new Contact_Role_Certification__c(Name = 'Certification GT 1', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certGeneralTraining1.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment1');
        Contact_Role_Certification__c contRoleCertifGT111 = new Contact_Role_Certification__c(Name = 'Certification GT 1', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certGeneralTraining1.Id, Expiration_Date__c = date.today().addDays(20), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment100');
        Contact_Role_Certification__c contRoleCertifGT2 = new Contact_Role_Certification__c(Name = 'Certification GT 2', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certGeneralTraining2.Id, Expiration_Date__c = date.today().addDays(11), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment2');
        Contact_Role_Certification__c contRoleCertifGT3 = new Contact_Role_Certification__c(Name = 'Certification GT 3', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certGeneralTraining3.Id, Expiration_Date__c = date.today().addDays(11), Proficiency__c = 'Level 3', AssessmentId__c = 'Assessment3');
        Contact_Role_Certification__c contRoleCertifPlane1 = new Contact_Role_Certification__c(Name = 'Certification Plane 1', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlane1.Id, Expiration_Date__c = date.today().addDays(12), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment4');
        Contact_Role_Certification__c contRoleCertifPlane2 = new Contact_Role_Certification__c(Name = 'Certification Plane 2', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlane2.Id, Expiration_Date__c = date.today().addDays(13), Proficiency__c = 'Level 3', AssessmentId__c = 'Assessment5');
        Contact_Role_Certification__c contRoleCertifPlane3 = new Contact_Role_Certification__c(Name = 'Certification Plane 3', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlane3.Id, Expiration_Date__c = date.today().addDays(30), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment50');
        Contact_Role_Certification__c contRoleCertifPlane31 = new Contact_Role_Certification__c(Name = 'Certification Plane 3', Account_Contact_Role__c = accountContactRoleITPStudent.Id, Certification__c = certPlane3.Id, Expiration_Date__c = date.today().addDays(13), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment51');



        //Student 2
        Contact_Role_Certification__c contRoleCertifGT10 = new Contact_Role_Certification__c(Name = 'Certification GT 1', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certGeneralTraining1.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment6');
        Contact_Role_Certification__c contRoleCertifGT20 = new Contact_Role_Certification__c(Name = 'Certification GT 2', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certGeneralTraining2.Id, Expiration_Date__c = date.today().addDays(11), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment7');
        Contact_Role_Certification__c contRoleCertifGT30 = new Contact_Role_Certification__c(Name = 'Certification GT 3', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certGeneralTraining3.Id, Expiration_Date__c = date.today().addDays(12), Proficiency__c = 'Level 3', AssessmentId__c = 'Assessment8');
        Contact_Role_Certification__c contRoleCertifPlane10 = new Contact_Role_Certification__c(Name = 'Certification Plane 1', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlane1.Id, Expiration_Date__c = date.today().addDays(10), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment9');
        Contact_Role_Certification__c contRoleCertifPlane11 = new Contact_Role_Certification__c(Name = 'Certification Plane 1 renew', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlane1.Id, Expiration_Date__c = date.today().addDays(20), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment90');
        Contact_Role_Certification__c contRoleCertifPlane20 = new Contact_Role_Certification__c(Name = 'Certification Plane 2', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlane2.Id, Expiration_Date__c = date.today().addDays(13), Proficiency__c = 'Level 3', AssessmentId__c = 'Assessment10');
        Contact_Role_Certification__c contRoleCertifPlane21 = new Contact_Role_Certification__c(Name = 'Certification Plane 3', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlane3.Id, Expiration_Date__c = date.today().addDays(3), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment11');
        Contact_Role_Certification__c contRoleCertifPlane22 = new Contact_Role_Certification__c(Name = 'Certification Plane 3 renew', Account_Contact_Role__c = accountContactRoleITPStudent2.Id, Certification__c = certPlane3.Id, Expiration_Date__c = date.today().addDays(13), Proficiency__c = 'Level 2', AssessmentId__c = 'Assessment12');
        contRoleCertifList.add(contRoleCertifGT1);
        contRoleCertifList.add(contRoleCertifGT111);
        contRoleCertifList.add(contRoleCertifGT2);
        contRoleCertifList.add(contRoleCertifGT3);
        contRoleCertifList.add(contRoleCertifPlane1);
        contRoleCertifList.add(contRoleCertifPlane2);
        contRoleCertifList.add(contRoleCertifPlane3);
        contRoleCertifList.add(contRoleCertifPlane31);

        contRoleCertifList.add(contRoleCertifGT10);
        contRoleCertifList.add(contRoleCertifGT20);
        contRoleCertifList.add(contRoleCertifGT30);
        contRoleCertifList.add(contRoleCertifPlane10);
        contRoleCertifList.add(contRoleCertifPlane11);
        contRoleCertifList.add(contRoleCertifPlane20);
        contRoleCertifList.add(contRoleCertifPlane21);
        contRoleCertifList.add(contRoleCertifPlane22);
        insert contRoleCertifList;

        //Create Proficiency Records
        List<Role_Address__c> proficiencyRecordsList = new List<Role_Address__c>();
        Role_Address__c proficiencyRec1 = new Role_Address__c(Name = 'Proficiency Record 1', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifPlane1.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
        Role_Address__c proficiencyRec2 = new Role_Address__c(Name = 'Proficiency Record 2', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifPlane2.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
        Role_Address__c proficiencyRec10 = new Role_Address__c(Name = 'Proficiency Record 10', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifPlane10.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');
        Role_Address__c proficiencyRec20 = new Role_Address__c(Name = 'Proficiency Record 20', Address__c = add1.Id, Contact_Role_Certification__c = contRoleCertifPlane20.id, Proficiency_Status__c = 'Active', Proficiency_level__c = 'Yes', Proficiency_Granted_By__c = 'COORDINATOR, ITP Coordinator');

        proficiencyRecordsList.add(proficiencyRec1);
        proficiencyRecordsList.add(proficiencyRec2);

        insert proficiencyRecordsList;

        id auxFolderId = [select id from folder where name = 'Public Folder' limit 1].id;
		
		//Create Insert Station Document
        // Document stationInsDocument = new Document();
		// String sBody = 'code\n' +
		// 	'CND\n' +
		// 	'CRA\n' +
		// 	'DZN\n' +
		// 	'DVA'; 
        // stationInsDocument.Body = Blob.valueOf(sBody);
        // stationInsDocument.ContentType = 'text/csv';
        // stationInsDocument.DeveloperName = 'station_ins_document';
        // stationInsDocument.IsPublic = true;
        // stationInsDocument.Name = 'Station Ins Document';
        // stationInsDocument.FolderId = auxFolderId;
        // insert stationInsDocument;

        //Create Insert Employee Document
        ContentVersion stationInsDocument = new ContentVersion();
		String sBody = 'code\n' +
			'PTX\n' +
			'GVX\n' +
            'aab'; 
        stationInsDocument.VersionData = Blob.valueOf(sBody);
        //stationInsDocument.ContentType = 'text/csv';
        stationInsDocument.PathOnClient = 'station_ins_document.csv';
        stationInsDocument.IsMajorVersion = true;
        stationInsDocument.Title = 'Station Ins Document';
        //stationInsDocument.FolderId = auxFolderId;
        insert stationInsDocument;

        // Create delete employees document
        ContentVersion employeesCodesDelDocument = new ContentVersion();
		String sBody4 = 'Employee Code\n' +
			'Abc'; 
        employeesCodesDelDocument.VersionData = Blob.valueOf(sBody4);
        //stationInsDocument.ContentType = 'text/csv';
        employeesCodesDelDocument.PathOnClient = 'employees_del_document.csv';
        employeesCodesDelDocument.IsMajorVersion = true;
        employeesCodesDelDocument.Title = 'Employees Del Document';
        //stationInsDocument.FolderId = auxFolderId;
        insert employeesCodesDelDocument;

        ContentVersion employeesCodesDelDocument2 = new ContentVersion();
		String sBody5 = 'Employee Code\n\n' +
			'Abc\n' +
            'MMM'; 
        employeesCodesDelDocument2.VersionData = Blob.valueOf(sBody5);
        //stationInsDocument.ContentType = 'text/csv';
        employeesCodesDelDocument2.PathOnClient = 'employees_del_document2.csv';
        employeesCodesDelDocument2.IsMajorVersion = true;
        employeesCodesDelDocument2.Title = 'Employees Del Document 2';
        //stationInsDocument.FolderId = auxFolderId;
        insert employeesCodesDelDocument2;

        //Create Insert Employee Document
        // Document empInsDocument = new Document();
		// String sBody2 = 'Employee Code,First Name,Last Name,Coordinator,Business Email,Stations Codes\n' +
		// 	'"MZ414","Abel14","Chain14","YES","AbChain14@demo.com","GVA"\n' +
		// 	'"MA415","Abel15","Chain15","YES","AbChain15@demo.com","GVA"\n' +
		// 	'"MA416","Abel16","Chain16","YES","AbChain16@demo.com","GVA"\n'; 
        // empInsDocument.Body = Blob.valueOf(sBody2);
        // empInsDocument.ContentType = 'text/csv';
        // empInsDocument.DeveloperName = 'emp_ins_document';
        // empInsDocument.IsPublic = true;
        // empInsDocument.Name = 'Emp Ins Document';
        // empInsDocument.FolderId = auxFolderId;
        // insert empInsDocument;

        //Create Insert Employee Document
        ContentVersion empInsDocument = new ContentVersion();
		String sBody2 = 'Employee Code,First Name,Last Name,Coordinator,Business Email,Stations Codes\n' +
			'"MZ414","Abel14","Chain14","Title","123456","AbChain14@demo.com","GVX; GVX"\n' +
            '"MZ414","Aaron","Chain","Title","123456","AaronChain@demo.com","GVX; GVX"\n' +
			'"MA415","Abel15","Chain15","Title","","AbChain15@demo.com","GVX; PTX; FRX"\n' +
			'"MA416","Abel16","Chain16","Title","123456","AbChain16@demo.com","GVX"\n'; 
        empInsDocument.VersionData = Blob.valueOf(sBody2);
        //empInsDocument.ContentType = 'text/csv';
        empInsDocument.PathOnClient = 'emp_ins_document.csv';
        empInsDocument.IsMajorVersion = true;
        empInsDocument.Title = 'Emp Ins Document';
        //empInsDocument.FolderId = auxFolderId;
        insert empInsDocument;

        ContentVersion empInsDocument2 = new ContentVersion();
		String sBody3 = 'Employee Code,First Name,Last Name,Coordinator,Business Email,Stations Codes\n' +
			'"","Abel14","Chain14","Title","123456","AbChain14@demo.com","GVX"\n' +
			'"MA415","Abel15","","Title","","AbChain15@demo.com","GVX"\n' +
			'"MA416","","Chain16","Title","123456","AbChain16@demo.com",""\n' +
            '"MZ414","Abel14","Chain14","Title","123456","AbChain14@demo.com","PTX"\n' + 
            '"Abc","Abel14","Chain14","Title","123456","AbChain14@demo.com","PTX"\n'; 
        empInsDocument2.VersionData = Blob.valueOf(sBody3);
        //empInsDocument.ContentType = 'text/csv';
        empInsDocument2.PathOnClient = 'emp_ins_document2.csv';
        empInsDocument2.IsMajorVersion = true;
        empInsDocument2.Title = 'Emp Ins Document2';
        //empInsDocument.FolderId = auxFolderId;
        insert empInsDocument2;

        ContentVersion empInsDocument3 = new ContentVersion();
		String sBody6 = 'Employee Code,First Name,Last Name,Coordinator,Business Email,Stations Codes\n' + 
            '"","Abel14","Chain14","Title","123456","AbChain14@demo.com","GVX"\n' +
            '"Abc","Abel14","Chain14","Title","123456","AbChain14@demo.com","FRX"\n' +
            '"MA415","Abel15","Chain15","Title","","AbChain15@demo.com","FRX; PTX"\n'; 
        empInsDocument3.VersionData = Blob.valueOf(sBody6);
        //empInsDocument.ContentType = 'text/csv';
        empInsDocument3.PathOnClient = 'emp_ins_document3.csv';
        empInsDocument3.IsMajorVersion = true;
        empInsDocument3.Title = 'Emp Ins Document3';
        //empInsDocument.FolderId = auxFolderId;
        insert empInsDocument3;

        List<ISSP_CS__c> isspCs = new List<ISSP_CS__c>();
		isspCs.add( new ISSP_CS__c(Name = 'IFTP-DocumentLibrary',Value__c = '0581j00000050jV'));
        insert isspCs;
        
    }

}