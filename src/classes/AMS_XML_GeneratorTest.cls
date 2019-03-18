@isTest
private class AMS_XML_GeneratorTest {

    private static Id  programRT  =  RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Segment__c', 'IATA_Code_Programs');

    private static AMS_Segment__c prog1 = new AMS_Segment__c (label__c = 'A', RecordTypeId = programRT );
    private static AMS_Segment__c prog2 = new AMS_Segment__c (label__c = 'S', RecordTypeId = programRT );
    private static AMS_Segment__c prog3 = new AMS_Segment__c (label__c = 'C', RecordTypeId = programRT );
    private static Id rtAccRoleOwnership = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
    private static Id rtAccRoleEmployee = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Employee');
    private static Id rtIATAStandardContact = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');

    private static AMS_Segment__c[] prgms = null;

    @isTest static void test_method_getAgencyDetail() {


        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;

        // Implement test code
        AMS_WAD_Settings__c wad = new AMS_WAD_Settings__c(Name = 'act', Field__c = null, Size__c = 2, Position__c = 1720);
        insert wad;
        AMS_XML_Fields__c xml1 = new AMS_XML_Fields__c(Name = 'address.address_1', Operation_Type__c = 'include', Object__c = 'ams_address__c', Field__c = 'address_1__c');
        AMS_XML_Fields__c xml2 = new AMS_XML_Fields__c(Name = 'all.agency__c', Operation_Type__c = 'exclude', Object__c = 'all', Field__c = 'agency__c');
        AMS_XML_Fields__c xml3 = new AMS_XML_Fields__c(Name = 'ams_address__c.address_1', Operation_Type__c = 'translate', Object__c = 'ams_address__c', Field__c = 'address_1__c');

        AMS_XML_Fields__c xml4 = new AMS_XML_Fields__c(Name = 'Account.Name', Operation_Type__c = 'translate', Object__c = 'Account', Field__c = 'Name');
        AMS_XML_Fields__c xml5 = new AMS_XML_Fields__c(Name = 'AMS_Person__c.Name', Operation_Type__c = 'translate', Object__c = 'AMS_Person__c', Field__c = 'Name');
        AMS_XML_Fields__c xml6 = new AMS_XML_Fields__c(Name = 'IATA_ISO_State__c.Name', Operation_Type__c = 'translate', Object__c = 'IATA_ISO_State__c', Field__c = 'Name');
        AMS_XML_Fields__c xml7 = new AMS_XML_Fields__c(Name = 'IATA_ISO_Country__c.Name', Operation_Type__c = 'translate', Object__c = 'IATA_ISO_Country__c', Field__c = 'Name');
        AMS_XML_Fields__c xml8 = new AMS_XML_Fields__c(Name = 'User.Name', Operation_Type__c = 'translate', Object__c = 'User', Field__c = 'Name');
        AMS_XML_Fields__c xml9 = new AMS_XML_Fields__c(Name = 'Contact.Name', Operation_Type__c = 'translate', Object__c = 'Contact', Field__c = 'Name');

        AMS_XML_Fields__c xml10 = new AMS_XML_Fields__c(Name = 'iata_iso_state.name', Operation_Type__c = 'include', Object__c = 'iata_iso_state__c', Field__c = 'name');
        AMS_XML_Fields__c xml11 = new AMS_XML_Fields__c(Name = 'iata_iso_state.iso_code_standard__c', Operation_Type__c = 'include', Object__c = 'iata_iso_state__c', Field__c = 'iso_code_standard__c');
        AMS_XML_Fields__c xml12 = new AMS_XML_Fields__c(Name = 'Account.organization_last_change_date', Operation_Type__c = 'include', Object__c = 'Account', Field__c = 'organization_last_change_date__c');
        AMS_XML_Fields__c xml13 = new AMS_XML_Fields__c(Name = 'Account.Location_Type__c', Operation_Type__c = 'include', Object__c = 'Account', Field__c = 'Location_Type__c');
        AMS_XML_Fields__c xml14 = new AMS_XML_Fields__c(Name = 'Account.Location_Category__c', Operation_Type__c = 'include', Object__c = 'Account', Field__c = 'Location_Category__c');
        AMS_XML_Fields__c xml15 = new AMS_XML_Fields__c(Name = 'Account.Accreditation_date__c', Operation_Type__c = 'include', Object__c = 'Account', Field__c = 'Accreditation_date__c');
        AMS_XML_Fields__c xml16 = new AMS_XML_Fields__c(Name = 'Account.Original_Approval_DAte__c', Operation_Type__c = 'include', Object__c = 'Account', Field__c = 'Original_Approval_DAte__c');
        AMS_XML_Fields__c xml17 = new AMS_XML_Fields__c(Name = 'Account.GDS__c', Operation_Type__c = 'include', Object__c = 'Account', Field__c = 'GDS__c');
        AMS_XML_Fields__c xml18 = new AMS_XML_Fields__c(Name = 'Account.GDP_Opt_In__c', Operation_Type__c = 'include', Object__c = 'Account', Field__c = 'GDP_Opt_In__c');

        List<AMS_XML_Fields__c> listofxml = new List<AMS_XML_Fields__c>();
        listofxml.add(xml1);
        listofxml.add(xml2);
        listofxml.add(xml3);
        listofxml.add(xml4);
        listofxml.add(xml5);
        listofxml.add(xml6);
        listofxml.add(xml7);
        listofxml.add(xml8);
        listofxml.add(xml9);
        listofxml.add(xml10);
        listofxml.add(xml11);
        listofxml.add(xml12);
        listofxml.add(xml13);
        listofxml.add(xml14);
        listofxml.add(xml15);
        listofxml.add(xml16);
        listofxml.add(xml17);
        listofxml.add(xml18);

        insert listofxml;

        AMS_XML_Tags__c xmltag1 = new AMS_XML_Tags__c(Name = 'Account', Name__c = 'Account', Tag__c = 'account');
        AMS_XML_Tags__c xmltag2 = new AMS_XML_Tags__c(Name = 'IATA_ISO_State', Name__c = 'IATA_ISO_State', Tag__c = 'iso_state');

        List<AMS_XML_Tags__c> listofxmltag = new List<AMS_XML_Tags__c>();
        listofxmltag.add(xmltag1);
        insert listofxmltag;

        prgms = new AMS_Segment__c[] {prog1, prog2, prog3};
        insert prgms;

        Set<String> sAgIDs = new Set<String>();

        List<AMS_Settlement_System__c> settlementSystemList = new List<AMS_Settlement_System__c>();
        AMS_Settlement_System__c sett_dpc = new AMS_Settlement_System__c(name = 'test_dpc', DPC_System__c = 'test_dpc');
        AMS_Settlement_System__c sett_cass = new AMS_Settlement_System__c(name = 'test_cass', DPC_System__c = 'test_cass');
        settlementSystemList.add(sett_dpc);
        settlementSystemList.add(sett_cass);
        insert settlementSystemList;

        //Countries
        List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
        IATA_ISO_Country__c ctr1 = new IATA_ISO_Country__c(Name = 'Test1 country', ISO_Code__c = 'PT', AMS_Settlement_System__c = sett_dpc.Id, AMS_Settlement_System_CASS__c = sett_cass.Id);
        IATA_ISO_Country__c ctr2 = new IATA_ISO_Country__c(Name = 'Test2 country', ISO_Code__c = 'ES');
        IATA_ISO_Country__c ctr3 = new IATA_ISO_Country__c(Name = 'Test3 country', ISO_Code__c = 'UK', AMS_Settlement_System__c = sett_dpc.Id, AMS_Settlement_System_CASS__c = sett_cass.Id);
        IATA_ISO_Country__c ctr4 = new IATA_ISO_Country__c(Name = 'Test4 country', ISO_Code__c = 'FR', AMS_Settlement_System__c = sett_dpc.Id, AMS_Settlement_System_CASS__c = sett_cass.Id);
        countrylist.add(ctr1);
        countrylist.add(ctr2);
        countrylist.add(ctr3);
        countrylist.add(ctr4);
        insert countrylist;

        List<IATA_ISO_State__c> statelist = new List<IATA_ISO_State__c>();
        IATA_ISO_State__c st1 = new IATA_ISO_State__c(Name = 'Test1 state', IATA_ISO_Country__c = ctr1.Id, ISO_Code__c = 'PT50', Iso_code_standard__c = 'PT50');
        IATA_ISO_State__c st2 = new IATA_ISO_State__c(Name = 'Test2 state', IATA_ISO_Country__c = ctr2.Id, ISO_Code__c = 'AU-ACT', Iso_code_standard__c = 'AU-ACT');
        IATA_ISO_State__c st3 = new IATA_ISO_State__c(Name = 'Test3 state', IATA_ISO_Country__c = ctr3.Id, ISO_Code__c = 'UK', Iso_code_standard__c = 'UK41');
        IATA_ISO_State__c st4 = new IATA_ISO_State__c(Name = 'Test4 state', IATA_ISO_Country__c = ctr4.Id, ISO_Code__c = 'FR', Iso_code_standard__c = 'FR25');
        statelist.add(st1);
        statelist.add(st2);
        statelist.add(st3);
        statelist.add(st4);
        insert statelist;

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name = 'US', ISO_Code__c = 'US', AMS_Settlement_System__c = sett_dpc.Id, AMS_Settlement_System_CASS__c = sett_cass.Id);
        insert ctry ;

        
        Account ag1 = new Account(Name = 'Test1 Account', IATA_ISO_Country__c = ctr1.id, Sector__c = 'Travel Agent', IATACode__c = '1234567', Phone = '+351000000000', Abbreviated_address__c = 'Abbreviated_address__c', BillingStreet = 'BillingStreet', ShippingStreet = 'ShippingStreet', ShippingState = 'Test1 state', ShippingCountry = 'Test1 country', Accreditation_date__c = Date.newInstance(2016, 11, 11), Original_Approval_DAte__c = Date.newInstance(2016, 11, 11), Status__c = 'Approved', TradeName__c = 'TradeName', Location_Category__c = 'A;B', GDS__c = 'A;B', Location_Type__c = 'HO', Type = 'IATA Passenger Sales Agent', GDP_Opt_In__c = True);
        Account ag2 = new Account(Name = 'Test2 Account', IATA_ISO_Country__c = ctr1.id, Sector__c = 'Travel Agent', IATACode__c = '1234567', Phone = '+351000000000000', Abbreviated_address__c = 'Abbreviated_address__c', BillingStreet = 'BillingStreet', ShippingStreet = 'ShippingStreet', ShippingState = 'Test1 state', ShippingCountry = 'Test1 country', Original_Approval_DAte__c = Date.newInstance(2016, 11, 11), Status__c = 'Approved', Fax = '+351911234567' );
        Account ag3 = new Account(Name = 'Test3 Account', IATA_ISO_Country__c = ctr2.id, Sector__c = 'Travel Agent', IATACode__c = '12345678', Phone = '+351000000000000000000000', Abbreviated_address__c = 'Abbreviated_address__c', BillingStreet = 'BillingStreet', ShippingStreet = 'ShippingStreet', ShippingState = 'Test1 state', ShippingCountry = 'Test1 country', Accreditation_date__c = Date.newInstance(2016, 11, 11), Original_Approval_DAte__c = Date.newInstance(2016, 11, 11), Status__c = 'Terminated' );
        Account ag4 = new Account(Name = 'Test4 Account', IATA_ISO_Country__c = ctr1.id, Sector__c = 'Cargo Agent', IATACode__c = '12345678', Abbreviated_address__c = 'Abbreviated_address__c', BillingStreet = 'BillingStreet', ShippingStreet = 'ShippingStreet', ShippingState = 'Test1 state', ShippingCountry = 'Test1 country', Status__c = 'Approved', CASS_Number__c = '02' );
        Account ag5 = new Account(Name = 'Test5 Account', IATA_ISO_Country__c = ctr1.id, Sector__c = 'Travel Agent', IATACode__c = '12345678', Abbreviated_address__c = 'Abbreviated_address__c', BillingStreet = 'BillingStreet', ShippingStreet = 'ShippingStreet', ShippingState = 'Test1 state', ShippingCountry = 'Test1 country', Status__c = 'Approved' );
        Account ag6 = new Account(Name = 'Test6 Account', IATA_ISO_Country__c = ctr1.id, Sector__c = 'Travel Agent', IATACode__c = '12345678', Abbreviated_address__c = 'Abbreviated_address__c', BillingStreet = 'BillingStreet', ShippingStreet = 'ShippingStreet', ShippingState = 'Test1 state', ShippingCountry = 'Test1 country', Status__c = 'Approved' );

        List<Account> accountList = new List<Account>{ag1,ag2,ag3,ag4,ag5,ag6};
        insert accountList;

        ag1.ParentId = ag6.id;
        update ag1;


        Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Active__c = true,
                Account__c = ag1.Id, Change_Code__c = 'FIN', Bulletin_Information__c = 'changeCode.memoText',
                Reason_Code__c = 'changeCode.reasonCode', Reason_Description__c = 'changeCode.reasonDesc');
        Agency_Applied_Change_code__c aacc2 = new Agency_Applied_Change_code__c(Active__c = true,
                Account__c = ag2.Id, Change_Code__c = 'FIN', Bulletin_Information__c = 'changeCode.memoText',
                Reason_Code__c = 'changeCode.reasonCode', Reason_Description__c = 'changeCode.reasonDesc');
        Agency_Applied_Change_code__c aacc3 = new Agency_Applied_Change_code__c(Active__c = true,
                Account__c = ag3.Id, Change_Code__c = 'FIN', Bulletin_Information__c = 'changeCode.memoText',
                Reason_Code__c = 'changeCode.reasonCode', Reason_Description__c = 'changeCode.reasonDesc');
        Agency_Applied_Change_code__c aacc4 = new Agency_Applied_Change_code__c(Active__c = true,
                Account__c = ag4.Id, Change_Code__c = 'FIN', Bulletin_Information__c = 'changeCode.memoText',
                Reason_Code__c = 'changeCode.reasonCode', Reason_Description__c = 'changeCode.reasonDesc');
        Agency_Applied_Change_code__c aacc5 = new Agency_Applied_Change_code__c(Active__c = true,
                Account__c = ag1.Id, Change_Code__c = 'CAR', Bulletin_Information__c = 'changeCode.memoText',
                Reason_Code__c = 'changeCode.reasonCode', Reason_Description__c = 'changeCode.reasonDesc');
        Agency_Applied_Change_code__c aacc6 = new Agency_Applied_Change_code__c(Active__c = true,
                Account__c = ag1.Id, Change_Code__c = 'DEF', Bulletin_Information__c = 'changeCode.memoText',
                Reason_Code__c = 'changeCode.reasonCode', Reason_Description__c = 'changeCode.reasonDesc');
        Agency_Applied_Change_code__c aacc7 = new Agency_Applied_Change_code__c(Active__c = true,
                Account__c = ag3.Id, Change_Code__c = 'DEF', Bulletin_Information__c = 'changeCode.memoText',
                Reason_Code__c = 'changeCode.reasonCode', Reason_Description__c = 'changeCode.reasonDesc');
        Agency_Applied_Change_code__c aacc8 = new Agency_Applied_Change_code__c(Active__c = true,
                Account__c = ag4.Id, Change_Code__c = 'CAR', Bulletin_Information__c = 'changeCode.memoText',
                Reason_Code__c = 'changeCode.reasonCode', Reason_Description__c = 'changeCode.reasonDesc');

        insert new List<Agency_Applied_Change_code__c>{aacc1,aacc2,aacc3,aacc4,aacc5,aacc6,aacc7,aacc8};

        sAgIDs.add(ag1.Id);
        sAgIDs.add(ag2.Id);
        sAgIDs.add(ag3.Id);
        sAgIDs.add(ag4.Id);

        List<AMS_Affiliation__c> affiliationlist = new List<AMS_Affiliation__c>();
        AMS_Affiliation__c aff1 = new AMS_Affiliation__c(Name = 'Test1 Affiliation', Affiliation_Code__c = 'AF1');
        AMS_Affiliation__c aff2 = new AMS_Affiliation__c(Name = 'Test2 Affiliation', Affiliation_Code__c = 'AF2');
        AMS_Affiliation__c aff3 = new AMS_Affiliation__c(Name = 'Test3 Affiliation', Affiliation_Code__c = 'AF3');
        AMS_Affiliation__c aff4 = new AMS_Affiliation__c(Name = 'Test4 Affiliation', Affiliation_Code__c = 'AF4');
        affiliationlist.add(aff1);
        affiliationlist.add(aff2);
        affiliationlist.add(aff3);
        affiliationlist.add(aff4);
        insert affiliationlist;

        List<AMS_Agency_Affiliation__c> agencyAffiliationlist = new List<AMS_Agency_Affiliation__c>();
        AMS_Agency_Affiliation__c agaff1 = new AMS_Agency_Affiliation__c(Account__c = ag1.id, Affiliation__c = aff1.id);
        AMS_Agency_Affiliation__c agaff2 = new AMS_Agency_Affiliation__c(Account__c = ag2.id, Affiliation__c = aff2.id);
        AMS_Agency_Affiliation__c agaff3 = new AMS_Agency_Affiliation__c(Account__c = ag3.id, Affiliation__c = aff3.id);
        AMS_Agency_Affiliation__c agaff4 = new AMS_Agency_Affiliation__c(Account__c = ag4.id, Affiliation__c = aff4.id);
        agencyAffiliationlist.add(agaff1);
        agencyAffiliationlist.add(agaff2);
        agencyAffiliationlist.add(agaff3);
        agencyAffiliationlist.add(agaff4);
        insert agencyAffiliationlist;

        List<AMS_Address__c> addresslist = new List<AMS_Address__c>();
        AMS_Address__c add1 = new AMS_Address__c(Address_1__c = 'Test1 Address', Account__c = ag1.Id, Country__c = ctr1.Id, State__c = st1.Id, Address_Type__c = 'Mailing');
        AMS_Address__c add2 = new AMS_Address__c(Address_1__c = 'Test2 Address', Account__c = ag2.Id, Country__c = ctr2.Id, State__c = st2.Id, Address_Type__c = 'Mailing');
        AMS_Address__c add3 = new AMS_Address__c(Address_1__c = 'Test3 Address', Account__c = ag3.Id, Country__c = ctr3.Id, State__c = st3.Id, Address_Type__c = 'Mailing');
        AMS_Address__c add4 = new AMS_Address__c(Address_1__c = 'Test4 Address', Account__c = ag4.Id, Country__c = ctr4.Id, State__c = st4.Id, Address_Type__c = 'Mailing');
        addresslist.add(add1);
        addresslist.add(add2);
        addresslist.add(add3);
        addresslist.add(add4);
        insert addresslist;

        List<AMS_Owner__c> ownerlist = new List<AMS_Owner__c>();
        AMS_Owner__c own1 = new AMS_Owner__c(Name = 'Test1 owner');
        AMS_Owner__c own2 = new AMS_Owner__c(Name = 'Test2 owner');
        AMS_Owner__c own3 = new AMS_Owner__c(Name = 'Test3 owner');
        AMS_Owner__c own4 = new AMS_Owner__c(Name = 'Test4 owner');
        ownerlist.add(own1);
        ownerlist.add(own2);
        ownerlist.add(own3);
        ownerlist.add(own4);
        insert ownerlist;

        List<User> userList = new List<User>();
        User u1 = new User(FirstName = 'Test1 User', Division = 'UnitTest', License_Cost_Center__c = 'AAA000AA00', Username = 'test1@iata.org.amsdev1', LastName = 'Test1', Email = 'test1@iata.org', Alias = 'Test1', CommunityNickname = 'Test1', TimeZoneSidKey = 'Europe/Brussels', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = '00e20000000h0gFAAQ', LanguageLocaleKey = 'en_US');
        User u2 = new User(FirstName = 'Test2 User', Division = 'UnitTest', License_Cost_Center__c = 'AAA000AA00', Username = 'test2@iata.org.amsdev1', LastName = 'Test2', Email = 'test2@iata.org', Alias = 'Test2', CommunityNickname = 'Test2', TimeZoneSidKey = 'Europe/Brussels', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = '00e20000000h0gFAAQ', LanguageLocaleKey = 'en_US');
        User u3 = new User(FirstName = 'Test3 User', Division = 'UnitTest', License_Cost_Center__c = 'AAA000AA00', Username = 'test3@iata.org.amsdev1', LastName = 'Test3', Email = 'test3@iata.org', Alias = 'Test3', CommunityNickname = 'Test3', TimeZoneSidKey = 'Europe/Brussels', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = '00e20000000h0gFAAQ', LanguageLocaleKey = 'en_US');
        User u4 = new User(FirstName = 'Test4 User', Division = 'UnitTest', License_Cost_Center__c = 'AAA000AA00', Username = 'test4@iata.org.amsdev1', LastName = 'Test4', Email = 'test4@iata.org', Alias = 'Test4', CommunityNickname = 'Test4', TimeZoneSidKey = 'Europe/Brussels', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = '00e20000000h0gFAAQ', LanguageLocaleKey = 'en_US');
        userList.add(u1);
        userList.add(u2);
        userList.add(u3);
        userList.add(u4);
        insert userList;

        List<Contact> contactList = new List<Contact>();
        Contact c1 = new Contact(AccountId = ag1.Id, FirstName = 'Test1 Contact', LastName = 'Test1', Preferred_Language__c = 'English', RecordTypeId = rtIATAStandardContact, Financial_Assessment_Contact__c = true);
        Contact c2 = new Contact(AccountId = ag2.Id, FirstName = 'Test2 Contact', LastName = 'Test2', Preferred_Language__c = 'French');
        Contact c3 = new Contact(AccountId = ag3.Id, FirstName = 'Test3 Contact', LastName = 'Test3', Preferred_Language__c = 'English');
        Contact c4 = new Contact(AccountId = ag4.Id, FirstName = 'Test4 Contact', LastName = 'Test4', Preferred_Language__c = 'Spanish');
        contactList.add(c1);
        contactList.add(c2);
        contactList.add(c3);
        contactList.add(c4);
        insert contactList;

        List<AMS_Person__c> personList = new List<AMS_Person__c>();
        AMS_Person__c p1 = new AMS_Person__c(Name = 'Test1 Person', User__c = u1.Id); //Contact__c=c1.Id,
        AMS_Person__c p2 = new AMS_Person__c(Name = 'Test2 Person', User__c = u2.Id); //Contact__c=c2.Id,
        AMS_Person__c p3 = new AMS_Person__c(Name = 'Test3 Person', User__c = u3.Id); //Contact__c=c3.Id,
        AMS_Person__c p4 = new AMS_Person__c(Name = 'Test4 Person', User__c = u4.Id); //Contact__c=c4.Id,
        personList.add(p1);
        personList.add(p2);
        personList.add(p3);
        personList.add(p4);
        insert personList;

        List<AMS_Account_Role__c> employeeList = new List<AMS_Account_Role__c>();
        AMS_Account_Role__c e1 = new AMS_Account_Role__c(Employee_Name__c = 'Test1 employee', RecordTypeId = rtAccRoleEmployee, Person__c = p1.Id, Employee_type__c = 'RG,CL', Account__c = ag1.Id, isManager__c = True, isTicketingAgent__c = True);
        AMS_Account_Role__c e2 = new AMS_Account_Role__c(Employee_Name__c = 'Test2 employee', RecordTypeId = rtAccRoleEmployee, Person__c = p2.Id, Employee_type__c = 'RG,CL', Account__c = ag2.Id, isManager__c = True);
        AMS_Account_Role__c e3 = new AMS_Account_Role__c(Employee_Name__c = 'Test3 employee', RecordTypeId = rtAccRoleEmployee, Person__c = p3.Id, Employee_type__c = 'RG,CL', Account__c = ag3.Id, isManager__c = True);
        AMS_Account_Role__c e4 = new AMS_Account_Role__c(Employee_Name__c = 'Test4 employee', RecordTypeId = rtAccRoleEmployee, Contact__c = c4.Id, Employee_type__c = 'RG,CL', Account__c = ag4.Id, isManager__c = True);
        employeeList.add(e1);
        employeeList.add(e2);
        employeeList.add(e3);
        employeeList.add(e4);
        insert employeeList;

        List<AMS_Account_Role__c> ownershipList = new List<AMS_Account_Role__c>();
        AMS_Account_Role__c o1 = new AMS_Account_Role__c(Employee_Name__c = 'Test1 employee', Owner_Account__c = ag5.id, Percentage__c = 100, RecordTypeId = rtAccRoleOwnership, Person__c = p1.Id, Employee_type__c = 'RG,CL', Account__c = ag1.Id);
        AMS_Account_Role__c o2 = new AMS_Account_Role__c(Employee_Name__c = 'Test2 employee', Owner_Account__c = ag5.id, Percentage__c = 100, RecordTypeId = rtAccRoleOwnership, Person__c = p2.Id, Employee_type__c = 'RG,CL', Account__c = ag2.Id);
        AMS_Account_Role__c o3 = new AMS_Account_Role__c(Employee_Name__c = 'Test3 employee', Owner_Account__c = ag5.id, Percentage__c = 100, RecordTypeId = rtAccRoleOwnership, Person__c = p3.Id, Employee_type__c = 'RG,CL', Account__c = ag3.Id);
        AMS_Account_Role__c o4 = new AMS_Account_Role__c(Employee_Name__c = 'Test4 employee', Owner_Account__c = ag5.id, Percentage__c = 100, RecordTypeId = rtAccRoleOwnership, Person__c = p4.Id, Employee_type__c = 'RG,CL', Account__c = ag4.Id);
        ownershipList.add(o1);
        ownershipList.add(o2);
        ownershipList.add(o3);
        ownershipList.add(o4);
        insert ownershipList;

        List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();
        for (Account a : accountList) {
            agsgts.add(new AMS_Agency_Segment__c(account__c = a.Id, Segment__c = prog1.Id));
        }
        insert agsgts;

        List<AMS_Accreditation_Organization__c> accredOrgList = new List<AMS_Accreditation_Organization__c>();
        AMS_Accreditation_Organization__c accredOrg1 = new AMS_Accreditation_Organization__c(Country__c = ctr1.Id, State__c = st1.Id);
        AMS_Accreditation_Organization__c accredOrg2 = new AMS_Accreditation_Organization__c(Country__c = ctr2.Id, State__c = st2.Id);
        AMS_Accreditation_Organization__c accredOrg3 = new AMS_Accreditation_Organization__c(Country__c = ctr3.Id, State__c = st3.Id);
        AMS_Accreditation_Organization__c accredOrg4 = new AMS_Accreditation_Organization__c(Country__c = ctr4.Id, State__c = st4.Id);
        accredOrgList.add(accredOrg1);
        accredOrgList.add(accredOrg2);
        accredOrgList.add(accredOrg3);
        accredOrgList.add(accredOrg4);
        insert accredOrgList;

        List<AMS_Inspection__c> inspectionList = new List<AMS_Inspection__c>();
        AMS_Inspection__c insp1 = new AMS_Inspection__c(Account__c = ag1.Id, Accreditation_Endorsement_organisation__c = accredOrg1.Id, Accreditation_Endorsement_Status_code__c = '0');
        AMS_Inspection__c insp2 = new AMS_Inspection__c(Account__c = ag2.Id, Accreditation_Endorsement_organisation__c = accredOrg2.Id, Accreditation_Endorsement_Status_code__c = '0');
        AMS_Inspection__c insp3 = new AMS_Inspection__c(Account__c = ag3.Id, Accreditation_Endorsement_organisation__c = accredOrg3.Id, Accreditation_Endorsement_Status_code__c = '0');
        AMS_Inspection__c insp4 = new AMS_Inspection__c(Account__c = ag4.Id, Accreditation_Endorsement_organisation__c = accredOrg4.Id, Accreditation_Endorsement_Status_code__c = '0');
        inspectionList.add(insp1);
        inspectionList.add(insp2);
        inspectionList.add(insp3);
        inspectionList.add(insp4);
        insert inspectionList;

        List<AMS_Agencies_Hierarchy__c> agenciesHierarchyList = new List<AMS_Agencies_Hierarchy__c>();
        AMS_Agencies_Hierarchy__c agH1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Test1 agenciesHierarchy');
        AMS_Agencies_Hierarchy__c agH2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Test2 agenciesHierarchy');
        AMS_Agencies_Hierarchy__c agH3 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Test3 agenciesHierarchy');
        AMS_Agencies_Hierarchy__c agH4 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Test4 agenciesHierarchy');
        agenciesHierarchyList.add(agH1);
        agenciesHierarchyList.add(agH2);
        agenciesHierarchyList.add(agH3);
        agenciesHierarchyList.add(agH4);
        insert agenciesHierarchyList;

        Test.startTest();

        List<AMS_Agencies_relationhip__c> agenciesRelationhipList = new List<AMS_Agencies_relationhip__c>();
        AMS_Agencies_relationhip__c agR1 = new AMS_Agencies_relationhip__c(Hierarchy__c = agH1.Id, Child_Account__c = ag3.Id, Parent_Account__c = ag1.Id);
        AMS_Agencies_relationhip__c agR2 = new AMS_Agencies_relationhip__c(Hierarchy__c = agH2.Id, Child_Account__c = ag4.Id, Parent_Account__c = ag2.Id);
        AMS_Agencies_relationhip__c agR3 = new AMS_Agencies_relationhip__c(Hierarchy__c = agH3.Id, Child_Account__c = ag3.Id, Parent_Account__c = ag1.Id);
        AMS_Agencies_relationhip__c agR4 = new AMS_Agencies_relationhip__c(Hierarchy__c = agH4.Id, Child_Account__c = ag4.Id, Parent_Account__c = ag2.Id);
        agenciesRelationhipList.add(agR1);
        agenciesRelationhipList.add(agR2);
        agenciesRelationhipList.add(agR3);
        agenciesRelationhipList.add(agR4);
        insert agenciesRelationhipList;

        List<AMS_Airport__c> airportList = new List<AMS_Airport__c>();
        AMS_Airport__c air1 = new AMS_Airport__c(Name = 'Test1 airport');
        AMS_Airport__c air2 = new AMS_Airport__c(Name = 'Test2 airport');
        AMS_Airport__c air3 = new AMS_Airport__c(Name = 'Test3 airport');
        AMS_Airport__c air4 = new AMS_Airport__c(Name = 'Test4 airport');
        airportList.add(air1);
        airportList.add(air2);
        airportList.add(air3);
        airportList.add(air4);
        insert airportList;

        List<AMS_Agency_Airport__c> agAirportList = new List<AMS_Agency_Airport__c>();
        AMS_Agency_Airport__c agAir1 = new AMS_Agency_Airport__c(Airport__c = air1.Id, Account__c = ag1.Id);
        AMS_Agency_Airport__c agAir2 = new AMS_Agency_Airport__c(Airport__c = air2.Id, Account__c = ag2.Id);
        AMS_Agency_Airport__c agAir3 = new AMS_Agency_Airport__c(Airport__c = air3.Id, Account__c = ag3.Id);
        AMS_Agency_Airport__c agAir4 = new AMS_Agency_Airport__c(Airport__c = air4.Id, Account__c = ag4.Id);
        agAirportList.add(agAir1);
        agAirportList.add(agAir2);
        agAirportList.add(agAir3);
        agAirportList.add(agAir4);
        insert agAirportList;

        List<AMS_Agency_Profile__c> agProfileList = new List<AMS_Agency_Profile__c>();
        AMS_Agency_Profile__c agProf1 = new AMS_Agency_Profile__c(Account__c = ag1.Id, GR_Code__c = 'MK', GR_Item__c = 'BH;CR;GN');
        AMS_Agency_Profile__c agProf2 = new AMS_Agency_Profile__c(Account__c = ag2.Id, GR_Code__c = 'MK', GR_Item__c = 'BH;CR;GN');
        AMS_Agency_Profile__c agProf3 = new AMS_Agency_Profile__c(Account__c = ag3.Id, GR_Code__c = 'MK', GR_Item__c = 'BH;CR;GN');
        AMS_Agency_Profile__c agProf4 = new AMS_Agency_Profile__c(Account__c = ag4.Id, GR_Code__c = 'MK', GR_Item__c = 'BH;CR;GN');
        agProfileList.add(agProf1);
        agProfileList.add(agProf2);
        agProfileList.add(agProf3);
        agProfileList.add(agProf4);
        insert agProfileList;

        List<AMS_Fields_Translation__c> ltrans = new List<AMS_Fields_Translation__c>();

        AMS_Fields_Translation__c trans1 = new AMS_Fields_Translation__c(Account__c = ag1.id, Field_name__c = 'Name', Translation__c = 'name', Language__c = 'CN');
        AMS_Fields_Translation__c trans2 = new AMS_Fields_Translation__c(Address__c = add1.id, Field_name__c = 'Address_1__c', Translation__c = 'teste', Language__c = 'CN');
        AMS_Fields_Translation__c trans3 = new AMS_Fields_Translation__c(AMSPerson__c = p1.id, Field_name__c = 'Name', Translation__c = 'name', Language__c = 'CN');
        AMS_Fields_Translation__c trans4 = new AMS_Fields_Translation__c(IATA_ISO_State__c = st1.id, Field_name__c = 'Name', Translation__c = 'name', Language__c = 'CN');
        AMS_Fields_Translation__c trans5 = new AMS_Fields_Translation__c(IATA_ISO_Country__c = ctr1.id, Field_name__c = 'Name', Translation__c = 'name', Language__c = 'CN');
        AMS_Fields_Translation__c trans6 = new AMS_Fields_Translation__c(User__c = u1.id, Field_name__c = 'Name', Translation__c = 'name', Language__c = 'CN');
        AMS_Fields_Translation__c trans7 = new AMS_Fields_Translation__c(Contact__c = c1.id, Field_name__c = 'Name', Translation__c = 'name', Language__c = 'CN');

        ltrans.add(trans1);
        ltrans.add(trans2);
        ltrans.add(trans3);
        ltrans.add(trans4);
        ltrans.add(trans5);
        ltrans.add(trans6);
        ltrans.add(trans7);

        insert ltrans;

        String[] r = new String[6];
        r[0] = 'GroupID';
        r[1] = '3';
        r[2] = '1';
        r[3] = '1';
        r[4] = 'true';


        r[5] = ag1.Id;

        /*  NEWGEN-801 */

        List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();

        ID FormOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'FormOfPayment');

        authorizations.add(new Agency_Authorization__c(Account__c = ag1.Id, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
        authorizations.add(new Agency_Authorization__c(Account__c = ag1.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
        authorizations.add(new Agency_Authorization__c(Account__c = ag1.Id, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));

        insert authorizations;

        ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
            ANG_AccountId__c = ag1.id,
            CurrencyIsoCode = 'USD',
            RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
            ANG_Financial_Security__c = 0
        );

        insert rhcInfo;

        Account agTest1 = (Account)[SELECT Airline_Code__c, A_Code__c,
                                    CASS_Number__c, Check_Digit__c, GDS__c,
                                    BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, Iso_State__c,
                                    ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet,
                                    Company_Type__c, C_Code__c, IATACode__c, Id, Location_Type__c,
                                    Last_Inspection_Date__c, Last_synchronization__c,
                                    License_Number__c, Location_Category__c, Location_Class__c, Name, GDP_Opt_In__c,
                                    N_Code__c, Organization_Last_Change_Date__c,
                                    Original_Approval_DAte__c, VAT_Number_2__c, OwnerId,
                                    Phone_Number__c, Phone, Fax, Primary_address__c,
                                    RecordTypeId, RecordType.name,
                                    STD_Code__c, VAT_Number__c,
                                    TradeName__c, Unique_ID__c, Verification_Date__c, IATA_ISO_Country__c, IATA_ISO_Country__r.Name,
                                    Short_Name__c, Sector__c, AIMS_ID__c, BSP_CASS_Code__c,
                                    Email__c, TTY__c, Website, Accreditation_date__c,
                                    Abbreviated_name__c, Abbreviated_address__c, Status__c,
                                    Top_Parent__c, Top_Parent__r.IATACode__c, Default_date__c
                                    , ANG_Accreditation_Model__c, Remittance_frequency__c,
                                    ANG_RiskStatus__c, ANG_IEP_Status_FF__c, Segmentation__c, Purge_Flag__c, Is_Branch_Abroad__c,
                    IATA_ISO_Country__r.BSP__c, IATA_ISO_Country__r.BSP_Country_free_text__c, Reason__c,
                    Expiry_Date__c //AMSU-207
                                    FROM Account where id =  :ag1.Id
                                            ORDER BY Location_Type__c DESC, IATA_ISO_Country__r.ISO_Code__c, Sector__c, Id, IATA_ISO_Country__r.IATA_Regional_Office__c];

        AMS_XML_Generator xmlGen = new AMS_XML_Generator();
        String s1 = xmlGen.getAgencyDetail(agTest1, r, 'Master', '');

        system.assertNotEquals(s1, '');

        r[5] = ag1.Id + ',' + ag2.Id + ',' + ag3.Id + ',' + ag4.Id + ',' + ag5.Id;


        List<Account> agTestN = [SELECT Airline_Code__c, A_Code__c,
                                 CASS_Number__c, Check_Digit__c, GDS__c,
                                 BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, Iso_State__c,
                                 ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet,
                                 Company_Type__c, C_Code__c, IATACode__c, Id, Location_Type__c,
                                 Last_Inspection_Date__c, Last_synchronization__c,
                                 License_Number__c, Location_Category__c, Location_Class__c, Name, GDP_Opt_In__c,
                                 N_Code__c, Organization_Last_Change_Date__c,
                                 Original_Approval_DAte__c, VAT_Number_2__c, OwnerId,
                                 Phone_Number__c, Phone, Fax, Primary_address__c,
                                 RecordTypeId, RecordType.name,
                                 STD_Code__c, VAT_Number__c,
                                 TradeName__c, Unique_ID__c, Verification_Date__c, IATA_ISO_Country__c, IATA_ISO_Country__r.Name,
                                 Short_Name__c, Sector__c, AIMS_ID__c, BSP_CASS_Code__c,
                                 Email__c, TTY__c, Website, Accreditation_date__c,
                                 Abbreviated_name__c, Abbreviated_address__c, Status__c,
                                 Top_Parent__c, Top_Parent__r.IATACode__c, Default_date__c, ANG_Accreditation_Model__c, Remittance_frequency__c,
                                 ANG_RiskStatus__c, ANG_IEP_Status_FF__c, Segmentation__c, Purge_Flag__c, Is_Branch_Abroad__c,
                    IATA_ISO_Country__r.BSP__c, IATA_ISO_Country__r.BSP_Country_free_text__c, Reason__c,
                    Expiry_Date__c //AMSU-207
                                 FROM Account where id in :sAgIDs
                                 ORDER BY Location_Type__c DESC, IATA_ISO_Country__r.ISO_Code__c, Sector__c, Id, IATA_ISO_Country__r.IATA_Regional_Office__c];


        String sN = xmlGen.getAgencyDetail(agTestN, r, 'Master', '');

        system.assertNotEquals(sN, '');

        String sN2 = xmlGen.getAgencySalesOrder(aacc1);

        String sN3 = xmlGen.getErrorMessage((String)aacc1.id, r);

        String sN4 = AMS_XML_Generator.PadZeros('000222', 2);

        String sN5 = xmlGen.getPersonLanguageOfCorrespondence('EN');
        sN5 = xmlGen.getPersonLanguageOfCorrespondence('FR');
        sN5 = xmlGen.getPersonLanguageOfCorrespondence('SP');

        Dom.Document doc = new Dom.Document();
        Dom.Xmlnode rootNode = doc.createRootElement('agencies_message', null, null);
        xmlGen.getObjectData(rootNode, 'Account', ag1, false );
        xmlGen.getObjectData(rootNode, 'Account', ag1, true );

        xmlGen.getObjectData(rootNode, 'AMS_Inspection__c', insp1, true );

        xmlGen.getObjectData(rootNode, 'iata_iso_state__c', st1, true );
        xmlGen.getObjectData(rootNode, 'iata_iso_state__c', st2, true );

        system.debug(Logginglevel.ERROR, 'ALEX 30 --> Query issued: ' + Limits.getQueries());

        Test.stopTest();
    }


    @isTest
    static void test_splitPhone() {
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



    @isTest
    static void test_AgencySalesOrder_GDI_GDN() {

        AMS_Settlement_System__c sett_dpc = new AMS_Settlement_System__c(name = 'test_dpc', DPC_System__c = 'test_dpc');
        insert sett_dpc;

        IATA_ISO_Country__c ctr1 = new IATA_ISO_Country__c(Name = 'Test1 country', ISO_Code__c = 'PT', AMS_Settlement_System__c = sett_dpc.Id, 
                                    ANG_Enable_NewGen__c = true, IATA_Regional_Office__c = 'Office Regional');
        insert ctr1;

        ID rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account acc = new Account(Name = 'Test1 Account', IATA_ISO_Country__c = ctr1.id, Sector__c = 'Travel Agent', 
            IATACode__c = '1234567', Phone = '+351000000000',  BillingStreet = 'BillingStreet', Accreditation_date__c = Date.newInstance(2019, 03, 14),  Status__c = 'Approved', TradeName__c = 'TradeName', 
            Location_Class__c = 'P', Location_Type__c = 'HE', Type = 'IATA Passenger Sales Agent', RecordTypeId = rtAgency );

        insert acc;

        Case theCommunicationCase = new Case(RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM, CaseArea__c = 'GDI Setup', AccountId = acc.id);
        insert theCommunicationCase;

        AMS_OSCAR__c gdiOscar = new AMS_OSCAR__c(RecordTypeId =  AMS_Utils.RECTYPE_GDI, STEP1__c = 'In Progress', Account__c = acc.id, 
            Oscar_Communication_Case_Id__c = theCommunicationCase.id);
        insert gdiOscar;

        //GDI Change Code 
        Agency_Applied_Change_code__c agencyAppliedChangeCode = new Agency_Applied_Change_code__c(Active__c = true,
                Account__c = acc.Id, Change_Code__c = 'GDI', Bulletin_Information__c = 'changeCode.memoText',
                Reason_Code__c = 'changeCode.reasonCode', Reason_Description__c = 'changeCode.reasonDesc.GDI',
                OSCAR__c = gdiOscar.id);

        insert agencyAppliedChangeCode;

        ID oppRecordtype = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'GDI_FinancialSecurity'); 
        Opportunity opp = new Opportunity(AccountId = acc.id, CloseDate = Date.today(), Name ='OPP - ' , RecordTypeId = oppRecordtype, 
            StageName = 'Pending', Related_Oscar__c = gdiOscar.id, GDI_Offer_Id__c='001', Offer_exchange_rate_date__c = Date.today());
        insert opp;


        Test.startTest();

        Agency_Applied_Change_code__c aaChangeCode = [SELECT OSCAR__c, OSCAR__r.Oscar_Communication_Case_Id__c, Account__r.Location_Class__c, Change_Code__c,
                                                        Account__r.IATA_ISO_Country__r.IATA_Regional_Office__c, Account__r.IATACode__c
                                                      FROM Agency_Applied_Change_code__c ];

        AMS_XML_Generator xmlGen = new AMS_XML_Generator();
        String response = xmlGen.getAgencySalesOrder(aaChangeCode);

        Test.stopTest();

        System.debug('Debug response message:' + response);

        DOM.Document doc = new DOM.Document();
        doc.load(response);
        Dom.XMLNode root = doc.getRootElement();

        Dom.XMLNode line_item = root.getChildElement('line_item', null);

        System.assertEquals(aaChangeCode.OSCAR__r.Oscar_Communication_Case_Id__c, line_item.getChildElement('CaseId', null).getText());
        
        Date offerDate =  opp.Offer_exchange_rate_date__c;
        Datetime dtOfferDate = datetime.newInstance(offerDate.year(), offerDate.month(),offerDate.day());
        
        System.assertEquals(dtOfferDate.format('yyyyMMdd'), line_item.getChildElement('offerDate', null).getText());
        System.assertEquals(opp.GDI_Offer_Id__c, line_item.getChildElement('offerId', null).getText());
    }

    @isTest static void agencySalesOrderTest(){

        IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c(
            Name = 'Portugal', 
            ISO_Code__c = 'PT', 
            Region__c = 'Europe',
            ANG_Enable_NewGen__c = true
        );

        IATA_ISO_Country__c countryES = new IATA_ISO_Country__c(
            Name = 'Spain', 
            ISO_Code__c = 'ES', 
            Region__c = 'Europe'
        );

        insert new List<IATA_ISO_Country__c>{countryPT, countryES};
        
        AMS_ChangeCodes__c cc = new AMS_ChangeCodes__c(
            Name = 'TST', 
            Change_Code__c = 'TST', 
            Billable__c = true, 
            Integration_RecId__c='C', 
            Billable_Location_Class__c = 'P'
        );

        insert cc;

        AMS_Change_Codes_Billable_Setup__c ccbs =  new AMS_Change_Codes_Billable_Setup__c(
            Name = 'TST', Change_Code__c = 'TST', 
            Country_To_Exclude__c = 'TS', 
            Location_Class_To_Exclude__c = 'P'
        );

        insert ccbs;

        Account a1 = new Account(
            Name='New Gen Agency',
            IATA_ISO_Country__c = countryPT.id, 
            Sent_to_external_system__c = true, 
            IATACode__c = '99999999', 
            Location_Class__c = 'P',
            RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY
        );

        Account a2 = new Account(
            Name='Non New Gen Agency',
            IATA_ISO_Country__c = countryES.id, 
            Sent_to_external_system__c = true, 
            IATACode__c = '99999998', 
            Location_Class__c = 'P',
            RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY
        );

        insert new List<Account>{a1, a2};

        Test.startTest();

        AMS_Oscar__c oscarA1 = new AMS_OSCAR__c(
            Account__c = a1.Id,
            RecordTypeId = AMS_Utils.RECTYPE_GDI,
            Process__c = AMS_Utils.NGGDI
        );

        insert oscarA1;

        AMS_Oscar__c oscarA2 = new AMS_OSCAR__c(
            Account__c = a1.Id,
            RecordTypeId = AMS_Utils.RECTYPE_GDI,
            Process__c = AMS_Utils.NGGDI
        );

        insert oscarA2;

        Case cseA1 = new Case(
            RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM, 
            AccountId = a1.Id,
            Oscar__c = oscarA1.Id
        );

        Case cseA2 = new Case(
            RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM, 
            AccountId = a2.Id,
            Oscar__c = oscarA2.Id
        );

        insert new List<Case>{cseA1, cseA2};

        oscarA1.Oscar_Communication_Case_Id__c = cseA1.Id;
        oscarA2.Oscar_Communication_Case_Id__c = cseA2.Id;

        update oscarA1;
        update oscarA2;

        Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(
            Account__c = a1.Id, 
            Change_Code__c = 'TST', 
            Sent_to_external_system__c = false,
            Oscar__c = oscarA1.Id
        );

        Agency_Applied_Change_code__c aacc2 = new Agency_Applied_Change_code__c(
            Account__c = a2.Id, 
            Change_Code__c = 'TST',  
            Sent_to_external_system__c = false,
            Oscar__c = oscarA2.Id
        );
      
        insert new List<Agency_Applied_Change_code__c>{aacc1, aacc2};

        List<Agency_Applied_Change_code__c> aaccLst = new List<Agency_Applied_Change_code__c>(
            [SELECT 
                OSCAR__c, 
                Account__c, 
                Change_Code__c, 
                Account__r.IATACode__c, 
                Account__r.Location_Class__c,
                Account__r.IATA_ISO_Country__r.IATA_Regional_Office__c,
                Account__r.IATA_ISO_Country__r.Iso_code__c, 
                OSCAR__r.Oscar_Communication_Case_Id__c,
                Account__r.ANG_Accreditation_Model__c, 
                Account__r.ANG_IsNewGenAgency__c
             FROM 
                Agency_Applied_Change_code__c
            ]
        );

        Agency_Applied_Change_code__c aa1 = aaccLst.get(0);
        Agency_Applied_Change_code__c aa2 = aaccLst.get(1);

        AMS_XML_Generator xmlGen = new AMS_XML_Generator();

        String xmlReq1 = xmlGen.getAgencySalesOrder(new List<Agency_Applied_Change_code__c>{aa1});
        String xmlReq2 = xmlGen.getAgencySalesOrder(new List<Agency_Applied_Change_code__c>{aa2});

        if(aa1.Account__r.ANG_IsNewGenAgency__c){
            system.assert(xmlReq1.contains('<CaseId>'));
            system.assert(!xmlReq2.contains('<CaseId>'));
        }
        else {
            system.assert(!xmlReq1.contains('<CaseId>'));
            system.assert(xmlReq2.contains('<CaseId>'));
        }

        Test.stopTest();

    }
        
}   