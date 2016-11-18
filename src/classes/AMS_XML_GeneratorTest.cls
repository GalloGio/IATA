@isTest
private class AMS_XML_GeneratorTest {
    
    @isTest static void test_method_getAgencyDetail() {
      

        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
      
        // Implement test code
        AMS_WAD_Settings__c wad = new AMS_WAD_Settings__c(Name='act',Field__c=null,Size__c=2,Position__c=1720);
        insert wad;
        AMS_XML_Fields__c xml1 = new AMS_XML_Fields__c(Name='address.address_1',Operation_Type__c='include',Object__c='ams_address__c',Field__c='address_1__c');
        AMS_XML_Fields__c xml2= new AMS_XML_Fields__c(Name='all.agency__c',Operation_Type__c='exclude',Object__c='all',Field__c='agency__c');
        AMS_XML_Fields__c xml3 = new AMS_XML_Fields__c(Name='ams_address__c.address_1',Operation_Type__c='translate',Object__c='ams_address__c',Field__c='address_1__c');
        List<AMS_XML_Fields__c> listofxml = new List<AMS_XML_Fields__c>();
        listofxml.add(xml1);
        listofxml.add(xml2);
        listofxml.add(xml3);
        insert listofxml;

        Set<String> sAgIDs = new Set<String>();


        //Country__r.AMS_Settlement_System__r.name bsp,
        //Country__r.AMS_Settlement_System__r.DPC_System__c dpc
        //Country__r.AMS_Settlement_System_CASS__r.name bsp,
        //Country__r.AMS_Settlement_System_CASS__r.DPC_System__c dpc
        List<AMS_Settlement_System__c> settlementSystemList = new List<AMS_Settlement_System__c>();
        AMS_Settlement_System__c sett_dpc = new AMS_Settlement_System__c(name = 'test_dpc', DPC_System__c = 'test_dpc');
        AMS_Settlement_System__c sett_cass = new AMS_Settlement_System__c(name = 'test_cass', DPC_System__c = 'test_cass');
        settlementSystemList.add(sett_dpc);
        settlementSystemList.add(sett_cass);
        insert settlementSystemList;


        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US',AMS_Settlement_System__c = sett_dpc.Id, AMS_Settlement_System_CASS__c = sett_cass.Id);
        insert ctry ;

        Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        List<Account> accountList = new List<Account>();
        Account ag1 = new Account(Name='Test1 Account', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent', IATACode__c = '12345678', Phone = '+351 000 000 000',Reason_for_creation__c='New agent');
        Account ag2 = new Account(Name='Test2 Account', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent', IATACode__c = '12345678', Phone = '+351 000 000 000 000',Reason_for_creation__c='New agent');
        Account ag3 = new Account(Name='Test3 Account', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent', IATACode__c = '12345678', Phone = '+351 000 000 000 000 000 000 000',Reason_for_creation__c='New agent');
        Account ag4 = new Account(Name='Test4 Account', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent', IATACode__c = '12345678',Reason_for_creation__c='New agent');
        accountList.add(ag1);
        accountList.add(ag2);
        accountList.add(ag3);
        accountList.add(ag4);
        insert accountList;
            
        //List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
        //AMS_Agency__c ag1 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test1 Agency',Account__c=acc1.Id, Legacy_System__c = 'AIMS1');
        //AMS_Agency__c ag2 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test2 Agency',Account__c=acc2.Id, Legacy_System__c = 'AIMS1');
        //AMS_Agency__c ag3 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test3 Agency',Account__c=acc3.Id, Legacy_System__c = 'AIMS1');
        //AMS_Agency__c ag4 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test4 Agency',Account__c=acc4.Id, Legacy_System__c = 'AIMS1');
        //agencylist.add(ag1);
        //agencylist.add(ag2);
        //agencylist.add(ag3);
        //agencylist.add(ag4);
        //insert agencylist;

        //ag1.Name='Update Agency 1';
        //ag2.Name='Update Agency 2';
        //ag3.Name='Update Agency 3';
        //ag4.Name='Update Agency 4';
        //update agencylist;    

        sAgIDs.add(ag1.Id);
        sAgIDs.add(ag2.Id);
        sAgIDs.add(ag3.Id);
        sAgIDs.add(ag4.Id);

        List<AMS_Affiliation__c> affiliationlist = new List<AMS_Affiliation__c>();
        AMS_Affiliation__c aff1 = new AMS_Affiliation__c(Name='Test1 Affiliation',Affiliation_Code__c='AF1');
        AMS_Affiliation__c aff2 = new AMS_Affiliation__c(Name='Test2 Affiliation',Affiliation_Code__c='AF2');
        AMS_Affiliation__c aff3 = new AMS_Affiliation__c(Name='Test3 Affiliation',Affiliation_Code__c='AF3');
        AMS_Affiliation__c aff4 = new AMS_Affiliation__c(Name='Test4 Affiliation',Affiliation_Code__c='AF4');
        affiliationlist.add(aff1);
        affiliationlist.add(aff2);
        affiliationlist.add(aff3);
        affiliationlist.add(aff4);
        insert affiliationlist;

        //List<AMS_Agency_Affiliation__c> agencyAffiliationlist = new List<AMS_Agency_Affiliation__c>();
        //AMS_Agency_Affiliation__c agaff1 = new AMS_Agency_Affiliation__c(Agency__c=ag1.id, Affiliation__c=aff1.id);
        //AMS_Agency_Affiliation__c agaff2 = new AMS_Agency_Affiliation__c(Agency__c=ag2.id, Affiliation__c=aff2.id);
        //AMS_Agency_Affiliation__c agaff3 = new AMS_Agency_Affiliation__c(Agency__c=ag3.id, Affiliation__c=aff3.id);
        //AMS_Agency_Affiliation__c agaff4 = new AMS_Agency_Affiliation__c(Agency__c=ag4.id, Affiliation__c=aff4.id);
        //agencyAffiliationlist.add(agaff1);
        //agencyAffiliationlist.add(agaff2);
        //agencyAffiliationlist.add(agaff3);
        //agencyAffiliationlist.add(agaff4);
        //insert agencyAffiliationlist;

        //Countries
        List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
        IATA_ISO_Country__c ctr1 = new IATA_ISO_Country__c(Name='Test1 country',ISO_Code__c='PT');
        IATA_ISO_Country__c ctr2 = new IATA_ISO_Country__c(Name='Test2 country',ISO_Code__c='ES');
        IATA_ISO_Country__c ctr3 = new IATA_ISO_Country__c(Name='Test3 country',ISO_Code__c='UK');
        IATA_ISO_Country__c ctr4 = new IATA_ISO_Country__c(Name='Test4 country',ISO_Code__c='FR');
        countrylist.add(ctr1);
        countrylist.add(ctr2);
        countrylist.add(ctr3);
        countrylist.add(ctr4);
        insert countrylist;

        List<IATA_ISO_State__c> statelist = new List<IATA_ISO_State__c>();
        IATA_ISO_State__c st1 = new IATA_ISO_State__c(Name='Test1 state',IATA_ISO_Country__c=ctr1.Id, ISO_Code__c='PT');
        IATA_ISO_State__c st2 = new IATA_ISO_State__c(Name='Test2 state',IATA_ISO_Country__c=ctr2.Id, ISO_Code__c='ES');
        IATA_ISO_State__c st3 = new IATA_ISO_State__c(Name='Test3 state',IATA_ISO_Country__c=ctr3.Id, ISO_Code__c='UK');
        IATA_ISO_State__c st4 = new IATA_ISO_State__c(Name='Test4 state',IATA_ISO_Country__c=ctr4.Id, ISO_Code__c='FR');
        statelist.add(st1);
        statelist.add(st2);
        statelist.add(st3);
        statelist.add(st4);
        insert statelist;

        List<AMS_Address__c> addresslist = new List<AMS_Address__c>();
        AMS_Address__c add1 = new AMS_Address__c(Address_1__c='Test1 Address',Account__c=ag1.Id,Country__c=ctr1.Id,State__c=st1.Id);
        AMS_Address__c add2 = new AMS_Address__c(Address_1__c='Test2 Address',Account__c=ag2.Id,Country__c=ctr2.Id,State__c=st2.Id);
        AMS_Address__c add3 = new AMS_Address__c(Address_1__c='Test3 Address',Account__c=ag3.Id,Country__c=ctr3.Id,State__c=st3.Id);
        AMS_Address__c add4 = new AMS_Address__c(Address_1__c='Test4 Address',Account__c=ag4.Id,Country__c=ctr4.Id,State__c=st4.Id);
        addresslist.add(add1);
        addresslist.add(add2);
        addresslist.add(add3);
        addresslist.add(add4);
        insert addresslist;

        AMS_Fields_Translation__c trans = new AMS_Fields_Translation__c(Address__c=add1.id,Field_name__c='Address_1__c',Translation__c='teste',Language__c='CN');
        insert trans;

        List<AMS_Owner__c> ownerlist = new List<AMS_Owner__c>();
        AMS_Owner__c own1 = new AMS_Owner__c(Name='Test1 owner');
        AMS_Owner__c own2 = new AMS_Owner__c(Name='Test2 owner');
        AMS_Owner__c own3 = new AMS_Owner__c(Name='Test3 owner');
        AMS_Owner__c own4 = new AMS_Owner__c(Name='Test4 owner');
        ownerlist.add(own1);
        ownerlist.add(own2);
        ownerlist.add(own3);
        ownerlist.add(own4);
        insert ownerlist;

        List<User> userList = new List<User>();
        User u1 = new User(FirstName='Test1 User',Division='UnitTest',License_Cost_Center__c='AAA000AA00',Username='test1@iata.org.amsdev1', LastName='Test1', Email='test1@iata.org', Alias='Test1', CommunityNickname='Test1', TimeZoneSidKey='Europe/Brussels', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ProfileId='00e20000000h0gFAAQ', LanguageLocaleKey='en_US');
        User u2 = new User(FirstName='Test2 User',Division='UnitTest',License_Cost_Center__c='AAA000AA00',Username='test2@iata.org.amsdev1', LastName='Test2', Email='test2@iata.org', Alias='Test2', CommunityNickname='Test2', TimeZoneSidKey='Europe/Brussels', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ProfileId='00e20000000h0gFAAQ', LanguageLocaleKey='en_US');
        User u3 = new User(FirstName='Test3 User',Division='UnitTest',License_Cost_Center__c='AAA000AA00',Username='test3@iata.org.amsdev1', LastName='Test3', Email='test3@iata.org', Alias='Test3', CommunityNickname='Test3', TimeZoneSidKey='Europe/Brussels', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ProfileId='00e20000000h0gFAAQ', LanguageLocaleKey='en_US');
        User u4 = new User(FirstName='Test4 User',Division='UnitTest',License_Cost_Center__c='AAA000AA00',Username='test4@iata.org.amsdev1', LastName='Test4', Email='test4@iata.org', Alias='Test4', CommunityNickname='Test4', TimeZoneSidKey='Europe/Brussels', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ProfileId='00e20000000h0gFAAQ', LanguageLocaleKey='en_US');
        userList.add(u1);
        userList.add(u2);
        userList.add(u3);
        userList.add(u4);
        insert userList;


        //List<AMS_Agency_Ownership__c> agencyOwnershipList = new List<AMS_Agency_Ownership__c>();
        //AMS_Agency_Ownership__c agOwn1 = new AMS_Agency_Ownership__c(AMS_Agency_Owner__c=own1.Id,Agency__c=ag1.Id);
        //AMS_Agency_Ownership__c agOwn2 = new AMS_Agency_Ownership__c(AMS_Agency_Owner__c=own2.Id,Agency__c=ag2.Id);
        //AMS_Agency_Ownership__c agOwn3 = new AMS_Agency_Ownership__c(AMS_Agency_Owner__c=own3.Id,Agency__c=ag3.Id);
        //AMS_Agency_Ownership__c agOwn4 = new AMS_Agency_Ownership__c(AMS_Agency_Owner__c=own4.Id,Agency__c=ag4.Id);
        //agencyOwnershipList.add(agOwn1);
        //agencyOwnershipList.add(agOwn2);
        //agencyOwnershipList.add(agOwn3);
        //agencyOwnershipList.add(agOwn4);
        //insert agencyOwnershipList;

        
        List<Contact> contactList = new List<Contact>();
        Contact c1 = new Contact(FirstName='Test1 Contact',LastName='Test1',Phone = '+351 000 000 000');
        Contact c2 = new Contact(FirstName='Test2 Contact',LastName='Test2',Phone = '+351 000 000 000');
        Contact c3 = new Contact(FirstName='Test3 Contact',LastName='Test3',Phone = '+351 000 000 000');
        Contact c4 = new Contact(FirstName='Test4 Contact',LastName='Test4',Phone = '+351 000 000 000');
        contactList.add(c1);
        contactList.add(c2);
        contactList.add(c3);
        contactList.add(c4);
        insert contactList;
        
        //List<AMS_Person__c> personList = new List<AMS_Person__c>();
        //AMS_Person__c p1 = new AMS_Person__c(Name='Test1 Person', User__c=u1.Id);//Contact__c=c1.Id,
        //AMS_Person__c p2 = new AMS_Person__c(Name='Test2 Person', User__c=u2.Id);//Contact__c=c2.Id,
        //AMS_Person__c p3 = new AMS_Person__c(Name='Test3 Person', User__c=u3.Id);//Contact__c=c3.Id,
        //AMS_Person__c p4 = new AMS_Person__c(Name='Test4 Person', User__c=u4.Id);//Contact__c=c4.Id,
        //personList.add(p1);
        //personList.add(p2);
        //personList.add(p3);
        //personList.add(p4);
        //insert personList;  
        
        //List<AMS_Employee__c> employeeList = new List<AMS_Employee__c>();
        //AMS_Employee__c e1 = new AMS_Employee__c(Name='Test1 employee',Person__c=p1.Id,Employee_type__c='RG,CL',Agency__c=ag1.Id);
        //AMS_Employee__c e2 = new AMS_Employee__c(Name='Test2 employee',Person__c=p2.Id,Employee_type__c='RG,CL',Agency__c=ag2.Id);
        //AMS_Employee__c e3 = new AMS_Employee__c(Name='Test3 employee',Person__c=p3.Id,Employee_type__c='RG,CL',Agency__c=ag3.Id);
        //AMS_Employee__c e4 = new AMS_Employee__c(Name='Test4 employee',Person__c=p4.Id,Employee_type__c='RG,CL',Agency__c=ag4.Id);
        //employeeList.add(e1);
        //employeeList.add(e2);
        //employeeList.add(e3);
        //employeeList.add(e4);
        //insert employeeList;    
        /*
        JFO 13/8/2015  deleted for new DM without GDS custom object
        List<AMS_Computer_Reservation_System__c> computerReservationList = new List<AMS_Computer_Reservation_System__c>();
        AMS_Computer_Reservation_System__c cr1 = new AMS_Computer_Reservation_System__c(Name='Test1 computerReservation');
        AMS_Computer_Reservation_System__c cr2 = new AMS_Computer_Reservation_System__c(Name='Test2 computerReservation');
        AMS_Computer_Reservation_System__c cr3 = new AMS_Computer_Reservation_System__c(Name='Test3 computerReservation');
        AMS_Computer_Reservation_System__c cr4 = new AMS_Computer_Reservation_System__c(Name='Test4 computerReservation');
        computerReservationList.add(cr1);
        computerReservationList.add(cr2);
        computerReservationList.add(cr3);
        computerReservationList.add(cr4);
        insert computerReservationList;
        

        List<AMS_Agency_Computer_Reservation__c> agComputerReservationList = new List<AMS_Agency_Computer_Reservation__c>();
        AMS_Agency_Computer_Reservation__c acr1 = new AMS_Agency_Computer_Reservation__c(Computer_Reservation_System__c=cr1.Id,Agency__c=ag1.Id);
        AMS_Agency_Computer_Reservation__c acr2 = new AMS_Agency_Computer_Reservation__c(Computer_Reservation_System__c=cr2.Id,Agency__c=ag2.Id);
        AMS_Agency_Computer_Reservation__c acr3 = new AMS_Agency_Computer_Reservation__c(Computer_Reservation_System__c=cr3.Id,Agency__c=ag3.Id);
        AMS_Agency_Computer_Reservation__c acr4 = new AMS_Agency_Computer_Reservation__c(Computer_Reservation_System__c=cr4.Id,Agency__c=ag4.Id);
        agComputerReservationList.add(acr1);
        agComputerReservationList.add(acr2);
        agComputerReservationList.add(acr3);
        agComputerReservationList.add(acr4);
        insert agComputerReservationList;
            
        */
        
        List<AMS_Accreditation_Organization__c> accredOrgList = new List<AMS_Accreditation_Organization__c>();
        AMS_Accreditation_Organization__c accredOrg1 = new AMS_Accreditation_Organization__c(Country__c=ctr1.Id,State__c=st1.Id);
        AMS_Accreditation_Organization__c accredOrg2 = new AMS_Accreditation_Organization__c(Country__c=ctr2.Id,State__c=st2.Id);
        AMS_Accreditation_Organization__c accredOrg3 = new AMS_Accreditation_Organization__c(Country__c=ctr3.Id,State__c=st3.Id);
        AMS_Accreditation_Organization__c accredOrg4 = new AMS_Accreditation_Organization__c(Country__c=ctr4.Id,State__c=st4.Id);
        accredOrgList.add(accredOrg1);
        accredOrgList.add(accredOrg2);
        accredOrgList.add(accredOrg3);
        accredOrgList.add(accredOrg4);
        insert accredOrgList;

        List<AMS_Inspection__c> inspectionList = new List<AMS_Inspection__c>();
        AMS_Inspection__c insp1 = new AMS_Inspection__c(Account__c=ag1.Id,Accreditation_Endorsement_organisation__c=accredOrg1.Id,Accreditation_Endorsement_Status_code__c='0');
        AMS_Inspection__c insp2 = new AMS_Inspection__c(Account__c=ag2.Id,Accreditation_Endorsement_organisation__c=accredOrg2.Id,Accreditation_Endorsement_Status_code__c='0');
        AMS_Inspection__c insp3 = new AMS_Inspection__c(Account__c=ag3.Id,Accreditation_Endorsement_organisation__c=accredOrg3.Id,Accreditation_Endorsement_Status_code__c='0');
        AMS_Inspection__c insp4 = new AMS_Inspection__c(Account__c=ag4.Id,Accreditation_Endorsement_organisation__c=accredOrg4.Id,Accreditation_Endorsement_Status_code__c='0');
        inspectionList.add(insp1);
        inspectionList.add(insp2);
        inspectionList.add(insp3);
        inspectionList.add(insp4);
        insert inspectionList;
            
        List<AMS_Agencies_Hierarchy__c> agenciesHierarchyList = new List<AMS_Agencies_Hierarchy__c>();
        AMS_Agencies_Hierarchy__c agH1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Test1 agenciesHierarchy');
        AMS_Agencies_Hierarchy__c agH2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Test2 agenciesHierarchy');
        AMS_Agencies_Hierarchy__c agH3 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Test3 agenciesHierarchy');
        AMS_Agencies_Hierarchy__c agH4 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Test4 agenciesHierarchy');
        agenciesHierarchyList.add(agH1);
        agenciesHierarchyList.add(agH2);
        agenciesHierarchyList.add(agH3);
        agenciesHierarchyList.add(agH4);
        insert agenciesHierarchyList;

        List<AMS_Agencies_relationhip__c> agenciesRelationhipList = new List<AMS_Agencies_relationhip__c>();
        AMS_Agencies_relationhip__c agR1 = new AMS_Agencies_relationhip__c(Hierarchy__c=agH1.Id,Child_Account__c=ag3.Id,Parent_Account__c=ag1.Id);
        AMS_Agencies_relationhip__c agR2 = new AMS_Agencies_relationhip__c(Hierarchy__c=agH2.Id,Child_Account__c=ag4.Id,Parent_Account__c=ag2.Id);
        AMS_Agencies_relationhip__c agR3 = new AMS_Agencies_relationhip__c(Hierarchy__c=agH3.Id,Child_Account__c=ag3.Id,Parent_Account__c=ag1.Id);
        AMS_Agencies_relationhip__c agR4 = new AMS_Agencies_relationhip__c(Hierarchy__c=agH4.Id,Child_Account__c=ag4.Id,Parent_Account__c=ag2.Id);
        agenciesRelationhipList.add(agR1);
        agenciesRelationhipList.add(agR2);
        agenciesRelationhipList.add(agR3);
        agenciesRelationhipList.add(agR4);
        insert agenciesRelationhipList;

        List<AMS_Airport__c> airportList = new List<AMS_Airport__c>();
        AMS_Airport__c air1 = new AMS_Airport__c(Name='Test1 airport');
        AMS_Airport__c air2 = new AMS_Airport__c(Name='Test2 airport');
        AMS_Airport__c air3 = new AMS_Airport__c(Name='Test3 airport');
        AMS_Airport__c air4 = new AMS_Airport__c(Name='Test4 airport');
        airportList.add(air1);
        airportList.add(air2);
        airportList.add(air3);
        airportList.add(air4);
        insert airportList;

        List<AMS_Agency_Airport__c> agAirportList = new List<AMS_Agency_Airport__c>();
        AMS_Agency_Airport__c agAir1 = new AMS_Agency_Airport__c(Airport__c=air1.Id,Account__c=ag1.Id);
        AMS_Agency_Airport__c agAir2 = new AMS_Agency_Airport__c(Airport__c=air2.Id,Account__c=ag2.Id);
        AMS_Agency_Airport__c agAir3 = new AMS_Agency_Airport__c(Airport__c=air3.Id,Account__c=ag3.Id);
        AMS_Agency_Airport__c agAir4 = new AMS_Agency_Airport__c(Airport__c=air4.Id,Account__c=ag4.Id);
        agAirportList.add(agAir1);
        agAirportList.add(agAir2);
        agAirportList.add(agAir3);
        agAirportList.add(agAir4);
        insert agAirportList;

        List<AMS_Agency_Profile__c> agProfileList = new List<AMS_Agency_Profile__c>();
        AMS_Agency_Profile__c agProf1 = new AMS_Agency_Profile__c(Account__c=ag1.Id,GR_Code__c='MK',GR_Item__c='BH;CR;GN');
        AMS_Agency_Profile__c agProf2 = new AMS_Agency_Profile__c(Account__c=ag2.Id,GR_Code__c='MK',GR_Item__c='BH;CR;GN');
        AMS_Agency_Profile__c agProf3 = new AMS_Agency_Profile__c(Account__c=ag3.Id,GR_Code__c='MK',GR_Item__c='BH;CR;GN');
        AMS_Agency_Profile__c agProf4 = new AMS_Agency_Profile__c(Account__c=ag4.Id,GR_Code__c='MK',GR_Item__c='BH;CR;GN');
        agProfileList.add(agProf1);
        agProfileList.add(agProf2);
        agProfileList.add(agProf3);
        agProfileList.add(agProf4);
        insert agProfileList;

        String[] r = new String[6];
        r[0]='GroupID';
        r[1]='3';
        r[2]='1';
        r[3]='1';
        r[4]='true';

        
        r[5] = ag1.Id;

        Test.startTest();

        //AMS_Agency__c agTest1 = (AMS_Agency__c)[SELECT Account__c,Administrator__c,Airline_Code__c,
        //            A_Code__c,BSP_Code__c,CASS_Number__c,Chk_Dgt__c,
        //            Company_Type__c,C_Code__c,DPC_Operation__c,IATACode__c,Id,
        //            Last_Inspection_Date__c,Last_synchronization__c,Legacy_External_ID__c,
        //            Legacy_System__c,Legal_Name_2__c,Legal_Name_3__c,License_Number__c,
        //            Location_Category__c,Location_Class__c,Name,Solicitation_Flag__c,
        //            N_Code__c,Organization_Last_Change_Date__c,
        //            Original_Approval_DAte__c,Other_Tax_Reference_Number__c,OwnerId,
        //            Parent_Reference_Number__c,Phone_Number__c,Primary_address__c,
        //            Recert_Expiry_Date__c,RecordTypeId,RecordType.name,
        //            Reference_Number__c,STD_Code__c,SystemModstamp,Tax_Reference_Number__c,
        //            Trading_Name_1__c,Trading_Name_2__c,Unique_ID__c,Verification_Date__c,
        //            Site_Type__c, GDS__c,Country__c,Abbreviated_name__c
        //            FROM AMS_Agency__c where id = :ag1.Id];
        Account agTest1 = (Account)[SELECT Airline_Code__c,A_Code__c,
                    CASS_Number__c,Check_Digit__c,GDS__c,
                    BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, Iso_State__c, 
                    ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet,
                    Company_Type__c,C_Code__c,IATACode__c,Id,Location_Type__c,
                    Last_Inspection_Date__c,Last_synchronization__c,
                    License_Number__c,Location_Category__c,Location_Class__c,Name,GDP_Opt_In__c,
                    N_Code__c,Organization_Last_Change_Date__c,
                    Original_Approval_DAte__c,VAT_Number_2__c,OwnerId,
                    Phone_Number__c, Phone, Fax, Primary_address__c,
                    RecordTypeId,RecordType.name,
                    STD_Code__c,VAT_Number__c,
                    TradeName__c,Unique_ID__c,Verification_Date__c,IATA_ISO_Country__c, IATA_ISO_Country__r.Name, 
                    Short_Name__c,Sector__c,AIMS_ID__c,BSP_CASS_Code__c,
                    Email__c,TTY__c,Website,
                    Abbreviated_name__c, Abbreviated_address__c, status__c,
                    Top_Parent__c, Top_Parent__r.IATACode__c
                    FROM Account where id =  :ag1.Id];

        AMS_XML_Generator xmlGen = new AMS_XML_Generator();
        String s1 = xmlGen.getAgencyDetail(agTest1, r, 'Master','');

        //TODO: Parse XML and test the ID's of the Elements against the ID's of the generated records

        system.assertNotEquals(s1,'');

        r[5] = ag1.Id + ',' + ag2.Id + ',' + ag3.Id + ',' + ag4.Id;
 

        //List<AMS_Agency__c> agTestN = [SELECT Account__c,Administrator__c,Airline_Code__c,
        //            A_Code__c,BSP_Code__c,CASS_Number__c,Chk_Dgt__c,
        //            Company_Type__c,C_Code__c,DPC_Operation__c,IATACode__c,Id,
        //            Last_Inspection_Date__c,Last_synchronization__c,Legacy_External_ID__c,
        //            Legacy_System__c,Legal_Name_2__c,Legal_Name_3__c,License_Number__c,
        //            Location_Category__c,Location_Class__c,Name,Solicitation_Flag__c,
        //            N_Code__c,Organization_Last_Change_Date__c,
        //            Original_Approval_DAte__c,Other_Tax_Reference_Number__c,OwnerId,
        //            Parent_Reference_Number__c,Phone_Number__c,Primary_address__c,
        //            Recert_Expiry_Date__c,RecordTypeId,RecordType.name,
        //            Reference_Number__c,STD_Code__c,SystemModstamp,Tax_Reference_Number__c,
        //            Trading_Name_1__c,Trading_Name_2__c,Unique_ID__c,Verification_Date__c,
        //            Site_Type__c, GDS__c,Country__c,Abbreviated_name__c
        //            FROM AMS_Agency__c where id in :sAgIDs];
        List<Account> agTestN = [SELECT Airline_Code__c,A_Code__c,
                    CASS_Number__c,Check_Digit__c,GDS__c,
                    BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, Iso_State__c, 
                    ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet,
                    Company_Type__c,C_Code__c,IATACode__c,Id,Location_Type__c,
                    Last_Inspection_Date__c,Last_synchronization__c,
                    License_Number__c,Location_Category__c,Location_Class__c,Name,GDP_Opt_In__c,
                    N_Code__c,Organization_Last_Change_Date__c,
                    Original_Approval_DAte__c,VAT_Number_2__c,OwnerId,
                    Phone_Number__c, Phone, Fax, Primary_address__c,
                    RecordTypeId,RecordType.name,
                    STD_Code__c,VAT_Number__c,
                    TradeName__c,Unique_ID__c,Verification_Date__c,IATA_ISO_Country__c, IATA_ISO_Country__r.Name,
                    Short_Name__c,Sector__c,AIMS_ID__c,BSP_CASS_Code__c,
                    Email__c,TTY__c,Website,
                    Abbreviated_name__c, Abbreviated_address__c, status__c,
                    Top_Parent__c, Top_Parent__r.IATACode__c
                    FROM Account where id in :sAgIDs];
        
        
        String sN = xmlGen.getAgencyDetail(agTestN, r, 'Master','');
        
        system.assertNotEquals(sN,'');

        //TODO: Parse XML and test the ID's of the Elements against the ID's of the generated records

        Test.stopTest();
    }
    
    //@isTest static void test_method_getAgencyList() {
    //    // Implement test code
    //    Set<String> sAgIDs = new Set<String>();

    //    IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
    //    insert ctry ;

    //    Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

    //    List<Account> accountList = new List<Account>();
    //    Account acc1 = new Account(Name='Test1 Account');
    //    Account acc2 = new Account(Name='Test2 Account');
    //    Account acc3 = new Account(Name='Test3 Account');
    //    Account acc4 = new Account(Name='Test4 Account');
    //    accountList.add(acc1);
    //    accountList.add(acc2);
    //    accountList.add(acc3);
    //    accountList.add(acc4);
    //    insert accountList;
            
    //    List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
    //    AMS_Agency__c ag1 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test1 Agency',Account__c=acc1.Id,BSP_Code__c='BSP1');
    //    AMS_Agency__c ag2 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test2 Agency',Account__c=acc2.Id,BSP_Code__c='BSP1');
    //    AMS_Agency__c ag3 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test3 Agency',Account__c=acc3.Id,BSP_Code__c='BSP2');
    //    AMS_Agency__c ag4 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test4 Agency',Account__c=acc4.Id,BSP_Code__c='BSP2');
    //    agencylist.add(ag1);
    //    agencylist.add(ag2);
    //    agencylist.add(ag3);
    //    agencylist.add(ag4);
    //    insert agencylist;

    //    Test.startTest();

    //    String[] headerParams = new String[5];
    //    headerParams[0] = ''; //'PreviousID'
    //    headerParams[1] = ''; //'GroupID'
    //    headerParams[2] = '5'; //'ChunkSize'
    //    headerParams[3] = ''; //'ChunkKey'
    //    headerParams[4] = ''; //'ChunkTotal'

    //    List<String> ids = new List<String>();

    //    String sCurrentGroupBy = '';
    //    String sCurrentIndicator = '';

    //    for(AMS_Agency__c au :agencylist){
    //        sCurrentGroupBy = au.BSP_Code__c;
    //        ids.add(au.Id);
    //    }

    //    AMS_XML_Generator xmlGen = new AMS_XML_Generator();
    //    //List<String> agenciesIDs, String sGroupBy, String[] headerParams
    //    String s = xmlGen.getAgencyList(ids, sCurrentGroupBy, sCurrentIndicator, headerParams);
        
    //    system.assertNotEquals(s,'');

    //    Test.stopTest();
    //}
    
    //@isTest static void test_method_getAgencyHierarchy() {
    //    IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
    //    insert ctry ;

    //    Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

    //    AMS_Agency__c a1 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test1 Agency', IATAcode__c = '1234567', Chk_dgt__c = '7', Legal_Name_1__c = 'Test1 Agency', Legacy_External_ID__c = '12345677', Legacy_System__c = 'AIMS');
    //    AMS_Agency__c a2 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test2 Agency', IATAcode__c = '1234567', Chk_dgt__c = '8', Legal_Name_1__c = 'Test2 Agency', Legacy_External_ID__c = '12345678', Legacy_System__c = 'AIMS');
    //    AMS_Agency__c a3 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test3 Agency', IATAcode__c = '1234567', Chk_dgt__c = '9', Legal_Name_1__c = 'Test3 Agency', Legacy_External_ID__c = '12345679', Legacy_System__c = 'AIMS');
    //    List<AMS_Agency__c> listOfAgencies = new List<AMS_Agency__c>();
    //    listOfAgencies.add(a1);
    //    listOfAgencies.add(a2);
    //    listOfAgencies.add(a3);
    //    insert listOfAgencies;

    //    AMS_Agencies_Hierarchy__c ah = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='MAIN');
    //    insert ah;

    //    AMS_Agencies_relationhip__c ar1 = new AMS_Agencies_relationhip__c(Hierarchy__c = ah.id, Parent_Account__c = a1.id, Child_Account__c = a2.id);
    //    AMS_Agencies_relationhip__c ar2 = new AMS_Agencies_relationhip__c(Hierarchy__c = ah.id, Parent_Account__c = a2.id, Child_Account__c = a3.id);
    //    List<AMS_Agencies_relationhip__c> listOfRelationships = new List<AMS_Agencies_relationhip__c>();
    //    listOfRelationships.add(ar1);
    //    listOfRelationships.add(ar2);
    //    insert listOfRelationships;

    //    Test.startTest();

    //    String[] headerParams = new String[5];
    //    headerParams[0] = ''; //'PreviousID'
    //    headerParams[1] = ''; //'GroupID'
    //    headerParams[2] = '5'; //'ChunkSize'
    //    headerParams[3] = ''; //'ChunkKey'
    //    headerParams[4] = ''; //'ChunkTotal'

    //    AMS_XML_Generator xmlGen = new AMS_XML_Generator();

    //    String s = xmlGen.getAgencyHierarchy(listOfAgencies, headerParams);

    //    s = xmlGen.getAgencyHierarchy(a1, headerParams);

    //    Test.stopTest();
    //}

    static testMethod void test_splitPhone() {
        ITU_Country_Code__c itu = new ITU_Country_Code__c(Name = 'Test', Code__c = '351');
        insert itu;

        AMS_XML_Generator gen = new AMS_XML_Generator();

        String[] phones;
        String phone;
        String country = 'Test';

        Test.startTest();

        phones = gen.splitPhone(null, country);
        System.assertEquals(null, phones);

        phone = '+351 764 345 567';
        phones = gen.splitPhone(phone, country);
        System.assertEquals('00351', phones[0]);
        System.assertEquals(null, phones[1]);
        System.assertEquals('764345567', phones[2]);

        phone = '+55 1 764 345 567';
        phones = gen.splitPhone(phone, country);
        System.assertEquals('00351', phones[0]);
        System.assertEquals(null, phones[1]);
        System.assertEquals('551764345567', phones[2]);

        phone = '+55 351 764 345 567';
        phones = gen.splitPhone(phone, country);
        System.assertEquals('00351', phones[0]);
        System.assertEquals('55', phones[1]);
        System.assertEquals('351764345567', phones[2]);

        phone = '55 978 123 351 764 345 567';
        phones = gen.splitPhone(phone, country);
        System.assertEquals('00351', phones[0]);
        System.assertEquals('978123', phones[1]);
        System.assertEquals('351764345567', phones[2]);

        Test.stopTest();
    }
}