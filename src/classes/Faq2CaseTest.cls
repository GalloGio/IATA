@isTest
private class Faq2CaseTest {

    @testSetup static void loadData() {
        list<ISSP_Case_Fields__c> listCaseFields = new list<ISSP_Case_Fields__c>{
            new ISSP_Case_Fields__c(
                Name = 'Section',
                Field_Name__c = 'First Section',
                Label__c = '',
                Order__c = 10,
                AP_Case__c = false,
                New_Case__c = false,
                NOT_FDS__c = false,
                Profile_Id_List__c = '',
                Read_Only__c = false,
                Required__c = false,
                Type__c = 'Section'),
            new ISSP_Case_Fields__c(
                Name = 'CCOthers',
                Field_Name__c = 'E2CP__AdditionalCC__c',
                Label__c = 'ISSP_CCOther_Include_Additional_Recipients',
                Order__c = 15,
                AP_Case__c = false,
                New_Case__c = false,
                NOT_FDS__c = false,
                Profile_Id_List__c = '',
                Read_Only__c = false,
                Required__c = false,
                Type__c = 'ccothers'),
            new ISSP_Case_Fields__c(
                Name = 'ISSP_IATA CODE',
                Field_Name__c = 'IATAcode__c',
                Label__c = 'ISSP_MyProfile_IATACODE',
                Order__c = 20,
                AP_Case__c = false,
                New_Case__c = false,
                NOT_FDS__c = false,
                Profile_Id_List__c = '',
                Read_Only__c = false,
                Required__c = false,
                Type__c = 'bootstrap-select'),
            new ISSP_Case_Fields__c(
                Name = 'ISSP_Type',
                Field_Name__c = 'Type',
                Label__c = 'LAQ_Type',
                Order__c = 50,
                AP_Case__c = false,
                New_Case__c = false,
                NOT_FDS__c = false,
                Profile_Id_List__c = '',
                Read_Only__c = false,
                Required__c = false,
                Type__c = 'Field'),
            new ISSP_Case_Fields__c(
                Name = 'ISSP_Sub Type',
                Field_Name__c = 'Sub_Type__c',
                Label__c = 'ISSP_Sub_Type',
                Order__c = 60,
                AP_Case__c = false,
                New_Case__c = false,
                NOT_FDS__c = false,
                Profile_Id_List__c = '',
                Read_Only__c = false,
                Required__c = false,
                Type__c = 'Field'),
            new ISSP_Case_Fields__c(
                Name = 'Case concerns GSA only',
                Field_Name__c = 'GSA_Agreement__c',
                Label__c = 'ISSP_GSA_Only',
                Order__c = 71,
                AP_Case__c = false,
                New_Case__c = true,
                NOT_FDS__c = true,
                Profile_Id_List__c = '',
                Read_Only__c = false,
                Required__c = false,
                Type__c = 'GSA_Only_Checkbox'),
            new ISSP_Case_Fields__c(
                Name = 'ISSP_GSA_Airline',
                Field_Name__c = 'Name',
                Label__c = 'ISSP_Airline',
                Order__c = 72,
                AP_Case__c = false,
                New_Case__c = false,
                NOT_FDS__c = false,
                Profile_Id_List__c = '',
                Read_Only__c = false,
                Required__c = false,
                Type__c = 'AirlineList'),
            new ISSP_Case_Fields__c(
                Name = 'ISSP_Subject',
                Field_Name__c = 'Subject',
                Label__c = 'ISSP_Subject',
                Order__c = 73,
                AP_Case__c = false,
                New_Case__c = false,
                NOT_FDS__c = false,
                Profile_Id_List__c = '',
                Read_Only__c = false,
                Required__c = true,
                Type__c = 'Field'),
            new ISSP_Case_Fields__c(
                Name = 'ISSP_Description',
                Field_Name__c = 'Description',
                Label__c = 'IDCard_Description',
                Order__c = 74,
                AP_Case__c = false,
                New_Case__c = true,
                NOT_FDS__c = true,
                Profile_Id_List__c = '',
                Read_Only__c = false,
                Required__c = true,
                Type__c = 'Field'),
            new ISSP_Case_Fields__c(
                Name = 'Second Section',
                Field_Name__c = 'Second Section',
                Label__c = '',
                Order__c = 170,
                AP_Case__c = false,
                New_Case__c = false,
                NOT_FDS__c = false,
                Profile_Id_List__c = '',
                Read_Only__c = false,
                Required__c = false,
                Type__c = 'Section')
        };
        insert listCaseFields;
        
        list<ISSP_FAQ2Case_Record_Type__c> listFaq2CaseRT = new list<ISSP_FAQ2Case_Record_Type__c>{
            new ISSP_FAQ2Case_Record_Type__c(
                Name = '1',
                Complaint__c = false,
                Recordtype__c = 'IATA_Airline',
                Topic__c = 'Airline_Management__c',
                Subtopic__c = 'MITA_Interline_Agreements__c'),
            new ISSP_FAQ2Case_Record_Type__c(
                Name = '2',
                Complaint__c = true,
                Recordtype__c = 'IATA_Airline',
                Topic__c = 'ICCS__c',
                Subtopic__c = ''),
            new ISSP_FAQ2Case_Record_Type__c(
                Name = '3',
                Complaint__c = true,
                Recordtype__c = 'IATA_Airline',
                Topic__c = 'TIESS__c',
                Subtopic__c = 'TIESS_General_Information__c,TIESS_Link_request_to_Supplier__c,TIESS_New_registration__c,TIESS_Settlement_amount__c,TIESS_User_Profile__c')
        };
        insert listFaq2CaseRT;
        
        list<ISSP_FAQ2Case_Permissions__c> listFaq2CasePermissions = new list<ISSP_FAQ2Case_Permissions__c>{
            new ISSP_FAQ2Case_Permissions__c(
                Name = '1',
                ISO_Country__c = 'All',
                Sector_Permission__c = 'All',
                Topic__c = 'CNS_Portal,CNS_CASS_Operations_Cargo,CNS_Endorsement_Cargo_Agent,TASF',
                Subtopic__c = ''),
            new ISSP_FAQ2Case_Permissions__c(
                Name = '2',
                ISO_Country__c = 'All',
                Sector_Permission__c = 'All',
                Topic__c = '',
                Subtopic__c = 'CGO_Accreditations_Fees,CGO_Changes_to_my_Agency,CGO_Closure_of_my_Agency,New_Cargo_Agency_Application,PAX_Accreditation_Fees,PAX_Changes_to_my_Agency,PAX_Closure_of_my_Agency,ID_CardNew_Travel_Agency_Application,PORTAL_General_Information')
        };
        insert listFaq2CasePermissions;
        
        LiveAgentButtonSettings__c liveagent = new LiveAgentButtonSettings__c(
            Name = 'AirlineEnglish',
            Sectors__c = 'Airline',
            Language__c = 'en',
            DeploymentId__c = '572000000000000',
            ButtonId__c = '573000000000000'
        );
        insert liveagent;
    }

    @isTest
    static void testArticleViewLine() {
        FAQ__kav article = new FAQ__kav();
        FAQ__VoteStat voteStat = new FAQ__VoteStat();
        
        Test.startTest();
        
        vfISSP_FAQ2Case ctrl = new vfISSP_FAQ2Case();
        ctrl.createArticleStatisticsRecords(article,'Test');

        vfISSP_FAQ2Case.ArticleViewLine articleVL1 = new vfISSP_FAQ2Case.ArticleViewLine(article);
        articleVL1.getHasVoteStat();
        articleVL1.getPath();
        vfISSP_FAQ2Case.ArticleViewLine articleVL2 = new vfISSP_FAQ2Case.ArticleViewLine(article,voteStat);
        articleVL2.getHasVoteStat();
        articleVL2.getPath();
        Test.stopTest();
    }

    @isTest
    static void testFaq2Case_Cases_a()
    {
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';

        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Airline';
        child.Top_Parent__c = parent.Id;
        insert child;
        System.debug('child Id: ' + child.Id);
        Contact con = ISSP_ObjectFactory.createNewContact();
        

        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        system.debug('rrrrrrrrrr  ' + con.Owner.UserRoleId);
        insert con;
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;
        Test.startTest();
        System.runAs(newUser)
        {
            
            vfISSP_FAQ2Case ctrl = new vfISSP_FAQ2Case();
            object keg = ctrl.newCase;

            //init
            ctrl.pageLoad();
            Integer topCatGroupIndex = getIndexWithChildes(ctrl.DataCategoryContainer);
            ctrl.topic = String.valueOf(topCatGroupIndex);
            System.debug('ctrl.topic: ' + ctrl.topic);
            ctrl.subtopic = getSubCat(ctrl.DataCategoryContainer, topCatGroupIndex);
            System.debug('ctrl.subtopic: ' + ctrl.subtopic);

            //c2
            ctrl.isGSAOnly = false;
            ctrl.newCase.IATAcode__c = null;
            ctrl.isGSAUser = true;
            ctrl.save();

            //c3
            Account acc = ISSP_ObjectFactory.createNewAccount();
            acc.BillingCity = 'test';
            acc.Name = 'test';
            insert acc;
            ctrl.accountId = acc.Id;
            ctrl.isGSAOnly = true;
            ctrl.save();
            ctrl.copyCountryISO();
            ctrl.GeneratesubTopicHelpText();
            ctrl.GenerateTopicHelpText();
            ctrl.Clicked_SISHelpDesk = false;
            ctrl.Clicked_IATAServiceRequest = false;
            ctrl.Clicked_PWCServiceRequest = false;
            ctrl.Clicked_DPCServiceRequest = false;
            ctrl.AssignNewCaseRecordType();
            ctrl.Clicked_DPCServiceRequest = true;
            ctrl.AssignNewCaseRecordType();
            ctrl.Clicked_PWCServiceRequest = true;
            ctrl.AssignNewCaseRecordType();
            ctrl.Clicked_IATAServiceRequest = true;
            ctrl.AssignNewCaseRecordType();
            ctrl.Clicked_SISHelpDesk = true;
            ctrl.AssignNewCaseRecordType();

            ctrl.CheckCountryMatch('ES','ES');
        }
        Test.stopTest();
    }

    @isTest
    static void testFaq2Case_Cases_b()
    {
        PageReference pageref = Page.ISSP_FAQ2Case;
        pageref.getParameters().put('myRecordType','Cases_SIS_Help_Desk');
        Test.setCurrentPage(pageref);
        
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Airline';
        child.Top_Parent__c = parent.Id;
        insert child;
        System.debug('child Id: ' + child.Id);
        Contact con = ISSP_ObjectFactory.createNewContact();
 
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;
        System.debug('con Id: ' + con.Id);
         User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;
        Test.startTest();
        System.runAs(newUser)
        {
            vfISSP_FAQ2Case ctrl = new vfISSP_FAQ2Case();
            object keg = ctrl.newCase;

            //init
            ctrl.pageLoad();
            Integer topCatGroupIndex = getIndexWithChildes(ctrl.DataCategoryContainer);
            ctrl.topic = String.valueOf(topCatGroupIndex);
            System.debug('ctrl.topic: ' + ctrl.topic);
            ctrl.subtopic = getSubCat(ctrl.DataCategoryContainer, topCatGroupIndex);
            System.debug('ctrl.subtopic: ' + ctrl.subtopic);

            //c2
            ctrl.isGSAOnly = false;
            ctrl.newCase.IATAcode__c = null;
            ctrl.isGSAUser = true;
            ctrl.saveAttach();

            //c3
            Account acc = ISSP_ObjectFactory.createNewAccount();
            acc.BillingCity = 'test';
            acc.Name = 'test';
            insert acc;
            ctrl.accountId = acc.Id;
            ctrl.isGSAOnly = true;
            ctrl.saveAttach();
        }
        Test.stopTest();
    }

    @isTest
    static void testFaq2CaseExt() 
    {
        Id rtIdHq = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');                    

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
       
        Account headQuarter = ISSP_ObjectFactory.createNewAccount();
        headQuarter.ParentId = parent.Id;
        headQuarter.BillingCity = 'test2';
        headQuarter.Name = 'test2';
        headQuarter.RecordTypeId = rtIdHq;
        headQuarter.Site = 'headSite';
        insert headQuarter;
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.Email = 'testxxaasddasdasd@test.com';
        con.AccountId= headQuarter.Id;
        insert con;
        User newUser = ISSP_ObjectFactory.createPortalUser(con);

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', ISO_Code__c = 't1', Case_BSP_Country__c = 'test1');
        insert country;

        list<Account> consumers = new list<Account>();
        for (integer i = 0;i<1;i++)
            consumers.add(new Account(name = 'consumer '+i,
                                    recordTypeId =rtIdBr,
                                    parentId = headQuarter.id,
                                    Site = 'Site'+i,
                                    IATA_ISO_Country__c = country.Id));
        insert consumers;

        list<Services_Rendered__c> services = new list<Services_Rendered__c>();
        for(Account cons: consumers )
        { 
            services.add( new  Services_Rendered__c(Services_Rendered_Status__c = 'Active',Services_Rendered_Type__c = 'CASS Participation',Services_Rendered_to_Airline__c = cons.id, Services_Rendered_By__c = headQuarter.Id));
            services.add( new  Services_Rendered__c(Services_Rendered_Status__c = 'Active',Services_Rendered_Type__c = 'BSP Representation',Services_Rendered_to_Airline__c = cons.id, Services_Rendered_By__c = headQuarter.Id));
            services.add( new  Services_Rendered__c(Services_Rendered_Status__c = 'Active',Services_Rendered_Type__c = 'THIS ONE WILL NOT FIRE !!!!',Services_Rendered_to_Airline__c = cons.id, Services_Rendered_By__c = headQuarter.Id));
        }
        insert services;

        System.runAs(newUser)
        {
            vfISSP_FAQ2Case controller = new vfISSP_FAQ2Case();
            controller.getGsaCountryList_2();
            controller.refreshAirlineList();
        }

    }

    @isTest
    public static void languageTest()
    {
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.Name = 'Account1';
        insert account;
        Contact contact = ISSP_ObjectFactory.createNewContact();
        insert contact;
        ISSP_Case cttr = new ISSP_Case();
        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'DPC_Service_Request');
        Case c=new Case(Subject='test 1',Status='Open', AccountId=account.id, ContactId=contact.id,Region__c = 'Europe', RecordTypeId = recordTypeId);
        insert c;
        User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId()];
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'test'+c.Region__c, IATA_Country_FR__c = 'test'+c.Region__c, IATA_Country_ZH__c = 'test'+c.Region__c,
                                    IATA_Country_IT__c = 'test'+c.Region__c, IATA_Country_JP__c = 'test'+c.Region__c, ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'test'+c.Region__c, IATA_Country_SP__c = 'test'+c.Region__c, Case_BSP_Country__c = 'test'+c.Region__c);
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        vfISSP_FAQ2Case.getIsoCountryList();
        vfISSP_FAQ2Case controller = new vfISSP_FAQ2Case();
        List<SelectOption> testLangOptions = NULL;

        currentUserInfo.LanguageLocaleKey = 'pt_BR';
        update currentUserInfo;
        testLangOptions = controller.countryList;
        currentUserInfo.LanguageLocaleKey = 'zh_CN';
        update currentUserInfo;
        testLangOptions = controller.countryList;
        currentUserInfo.LanguageLocaleKey = 'fr';
        update currentUserInfo;
        testLangOptions = controller.countryList;
        currentUserInfo.LanguageLocaleKey = 'ja';
        update currentUserInfo;
        testLangOptions = controller.countryList;
        currentUserInfo.LanguageLocaleKey = 'it';
        update currentUserInfo;
        testLangOptions = controller.countryList;
        currentUserInfo.LanguageLocaleKey = 'es';
        update currentUserInfo;
        testLangOptions = controller.countryList;
        currentUserInfo.LanguageLocaleKey = 'ko';
        update currentUserInfo;
        testLangOptions = controller.countryList;
        currentUserInfo.LanguageLocaleKey = 'de';
        update currentUserInfo;
        testLangOptions = controller.countryList;
    }


    @isTest
    static void testFaq2Case002() {
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Airline';
        child.Top_Parent__c = parent.Id;
        insert child;
        System.debug('child Id: ' + child.Id);
        Contact con = ISSP_ObjectFactory.createNewContact();
 
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;
        System.debug('con Id: ' + con.Id);
         User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;
        Test.startTest();
        System.runAs(newUser)
        {
          vfISSP_FAQ2Case controller = new vfISSP_FAQ2Case();
          controller.pageLoad();

          object keg = controller.newCase;

          Integer topCatGroupIndex = getIndex(controller.DataCategoryContainer);
          controller.topic = String.valueOf(topCatGroupIndex);
          controller.subtopic = getSubCat(controller.DataCategoryContainer, topCatGroupIndex);
          controller.back();
          controller.saveAttach(); 
          controller.refreshTopicPickList();
          controller.refreshSubTopicPickList();
          keg = controller.countryList;
        }
        Test.stopTest();
    }

    @isTest
    static void testFaq2Case003() {
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Airline';
        child.Top_Parent__c = parent.Id;
        insert child;
        System.debug('child Id: ' + child.Id);
        Contact con = ISSP_ObjectFactory.createNewContact();
 
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;
        Test.startTest();
        System.runAs(newUser)
        {
          vfISSP_FAQ2Case controller = new vfISSP_FAQ2Case();
          controller.pageLoad();

          object keg = controller.newCase;

          controller.topic = Env.SelectOptionDefaultValue;
          controller.subtopic = Env.SelectOptionDefaultValue;
          controller.back();
          keg = controller.countryList;
        }
        Test.stopTest();
    }

    @isTest
    static void testFaq2Case004() {
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Airline';
        child.Top_Parent__c = parent.Id;
        insert child;
        System.debug('child Id: ' + child.Id);
        Contact con = ISSP_ObjectFactory.createNewContact();
 
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;
        System.debug('con Id: ' + con.Id);
         User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;
        Test.startTest();
        System.runAs(newUser)
        {
          vfISSP_FAQ2Case controller = new vfISSP_FAQ2Case();
          controller.pageLoad();

          object keg = controller.newCase;

          Integer topCatGroupIndex = getIndex(controller.DataCategoryContainer);
          controller.topic = String.valueOf(topCatGroupIndex);
          controller.subtopic = Env.SelectOptionDefaultValue;
          controller.back();
          controller.refreshTopicPickList();
          controller.refreshSubTopicPickList();
          keg = controller.countryList;
        }
        Test.stopTest();
    }

    @isTest
    static void testFaq2Case005() {
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Airline';
        child.Top_Parent__c = parent.Id;
        insert child;
        System.debug('child Id: ' + child.Id);
        Contact con = ISSP_ObjectFactory.createNewContact();
 
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;
        System.debug('con Id: ' + con.Id);
         User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;
        Test.startTest();
        System.runAs(newUser)
        {
          vfISSP_FAQ2Case controller = new vfISSP_FAQ2Case();
          controller.pageLoad();

          object keg = controller.newCase;

          Integer topCatGroupIndex = getIndex(controller.DataCategoryContainer);
          controller.IwishtoComplain();
          controller.topic = String.valueOf(topCatGroupIndex);
          controller.subtopic = Env.SelectOptionDefaultValue;
          controller.refreshTopicPickList();
          controller.refreshSubTopicPickList();
          keg = controller.countryList;
        }
        Test.stopTest();
    }

    @isTest
    static void testFaq2Case006() {
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Airline';
        child.Top_Parent__c = parent.Id;
        insert child;
        System.debug('child Id: ' + child.Id);
        Contact con = ISSP_ObjectFactory.createNewContact();

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', ISO_Code__c = 't1', Case_BSP_Country__c = 'test1', Region__c = 'test');
        insert country;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'DPC_Service_Request');

        Case c=new Case(Subject='test 1',Status='Open', AccountId=parent.id, ContactId=con.id,Region__c = 'Europe', IFAP_Country_ISO__c ='t1' , RecordTypeId = recordTypeId);
        insert c;

        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;
        System.debug('con Id: ' + con.Id);
         User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;
        Test.startTest();
        System.runAs(newUser)
        {
          vfISSP_FAQ2Case controller = new vfISSP_FAQ2Case();
          controller.pageLoad();
          controller.topic = '2';
          controller.setRecordType();
          
          controller.create();
          controller.back();
          controller.save();
          controller.refreshTopicPickList();
          controller.refreshSubTopicPickList();

          controller.subtopic = ENV.SelectOptionDefaultValue;
          controller.refreshSubTopicPickList();
          controller.createSatisfiedRecord();
          controller.GeneralQueueMethod();
          controller.ComplimentGeneralQueueMethod();
          controller.CheckNewCaseRecordType();

          controller.topic = '0';
          controller.subtopic = 'CGO_Bank_Guarantees__c';
          controller.newCase.IFAP_Country_ISO__c = 'GB';
          String test;
          test = controller.encTopicLbl;
          test = controller.encSubtopicLbl;
          test = controller.encIsoCountry;
          test = controller.region;
          
        }
        Test.stopTest();
    }

    @isTest
	static void testFaq2Case007() {
		Id agencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Account testAccount = new Account(
			name= 'testAccount',
			CNS_Account__c = true,
			RecordTypeId = agencyRecordTypeId
		);
		insert testAccount;
        Contact con = ISSP_ObjectFactory.createNewContact();
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'United States', ISO_Code__c = 't1', Case_BSP_Country__c = 'test1', Region__c = 'test');
		insert country;

		Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'DPC_Service_Request');

        con.AccountId= testAccount.Id;
		con.Email = 'Test@test11.com';
		con.CNS_Contact__c = true;
        insert con;
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;
        Test.startTest();
        System.runAs(newUser)
        {
		  vfISSP_FAQ2Case controller = new vfISSP_FAQ2Case();
		  controller.pageLoad();
		  controller.topic = '2';
		  controller.setRecordType();
		  controller.create();
		  	  controller.back();
		  controller.refreshTopicPickList();
		  controller.refreshSubTopicPickList();
		  controller.subtopic = ENV.SelectOptionDefaultValue;
		  controller.refreshSubTopicPickList();
		  controller.createSatisfiedRecord();
		  controller.GeneralQueueMethod();
		  controller.CheckNewCaseRecordType();
		  controller.GenerateTopicHelpText();
		  controller.GeneratesubTopicHelpText();

		  Boolean b = controller.showButton;
		  Boolean b2 = controller.isAllowedCode('test');
		  PageReference pr = controller.getSelectArtical();
		  PageReference pr2 = controller.create1();
		  PageReference pr3 = controller.ComplimentGeneralQueueMethod();
		  Boolean b4 = controller.isArticalSelected;

		  controller.isCompliment1 = true;
		  Case newCase = controller.newCase;
		  newCase.IFAP_Country_ISO__c ='t1';
		  newCase.Subject = 'test';
		  newCase.Description = 'test';
		  controller.topic = '0';
		  controller.subtopic = 'CGO_Bank_Guarantees__c';
          setCCOthersEmail(controller,'fake@email.com');
          controller.save();
          setCCOthersEmail(controller,'Test@test11.com');
          controller.save();
		}
		Test.stopTest();
    }

    @isTest
    static void testFaq2Case008() {
        Id agencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account testAccount = new Account(
            name= 'testAccount',
            CNS_Account__c = true,
            RecordTypeId = agencyRecordTypeId
        );
        insert testAccount;
        Contact con = ISSP_ObjectFactory.createNewContact();
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'Spain', ISO_Code__c = 't1', Case_BSP_Country__c = 'test1', Region__c = 'test');
        insert country;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'DPC_Service_Request');

        con.AccountId= testAccount.Id;
        con.Email = 'Test@test11.com';
        con.CNS_Contact__c = true;
        insert con;
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;
        Test.startTest();
        System.runAs(newUser)
        {
            vfISSP_FAQ2Case controller = new vfISSP_FAQ2Case();
            controller.pageLoad();
            controller.topic = '2';
            controller.setRecordType();
            controller.create();
            controller.back();
            controller.refreshTopicPickList();
            controller.refreshSubTopicPickList();
            controller.subtopic = ENV.SelectOptionDefaultValue;
            controller.refreshSubTopicPickList();
            controller.createSatisfiedRecord();
            controller.GeneralQueueMethod();
            controller.CheckNewCaseRecordType();
            controller.GenerateTopicHelpText();
            controller.GeneratesubTopicHelpText();

            Boolean b = controller.showButton;
            Boolean b2 = controller.isAllowedCode('test');
            PageReference pr = controller.getSelectArtical();
            PageReference pr2 = controller.create1();
            PageReference pr3 = controller.ComplimentGeneralQueueMethod();
            Boolean b4 = controller.isArticalSelected;
            
            controller.isCompliment1 = true;
            Case newCase = controller.newCase;
            newCase.IFAP_Country_ISO__c ='t1';
            newCase.Subject = 'test';
            newCase.Description = 'test';
            controller.topic = '0';
            controller.subtopic = 'CGO_Bank_Guarantees__c';
            setCCOthersEmail(controller,'fake@email.com');
            controller.saveAttach();
            setCCOthersEmail(controller,'Test@test11.com');
            controller.saveAttach();
        }
        Test.stopTest();
    }
    
    @isTest
    static void testAllowedSector() {
        Account testAccount = new Account(
            name= 'testAccount',
            CNS_Account__c = true
        );
        insert testAccount;
        Contact con = ISSP_ObjectFactory.createNewContact();
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'Spain', ISO_Code__c = 't1', Case_BSP_Country__c = 'test1', Region__c = 'test');
        insert country;
        
        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'DPC_Service_Request');
        con.AccountId= testAccount.Id;
        con.Email = 'Test@test11.com';
        con.CNS_Contact__c = true;
        insert con;
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

    }

    private static Integer getIndex(clsDataCategoryContainer cont) {
        //controller.DataCategoryContainer.lst_DataCategories[index]
        return 0;
    }

    private static String getSubCat(clsDataCategoryContainer cont, Integer index) {
        return cont.lst_DataCategories[index].CategoryName;
    }

    private static Integer getIndexWithChildes(clsDataCategoryContainer cont)
    {
        for (Integer index = 0; index < cont.lst_DataCategories.size(); ++index)
        {
            clsDataCategory cdc = cont.lst_DataCategories[index];
            if (cdc.lst_childs.size() > 0)
            {
                return index;
            }
        }

        return 0;
    }
    
    static testMethod void testinitIATACodeList() {
        Account account1 = new Account(Name='test1', IATAcode__c = '1');
        insert account1;
        
        Contact contact = new Contact(
            Salutation = 'Mr.',
            FirstName= 'first',
            LastName= 'last',
            AccountId = account1.id);
        insert contact;
        
        vfISSP_FAQ2Case ctrl = new vfISSP_FAQ2Case();
        
        Test.StartTest();
        ctrl.initIATACodeList(account1.id);
        Account account2 = new Account(Name='test2', IATAcode__c = '2', ParentId=account1.Id);
        insert account2;
        ctrl.initIATACodeList(account2.id);
        Account account3 = new Account(Name='test3', IATAcode__c = '3', ParentId=account2.Id);
        insert account3;
        ctrl.initIATACodeList(account3.id);
        Account account4 = new Account(Name='test4', IATAcode__c = '4', ParentId=account3.Id);
        insert account4;
        ctrl.initIATACodeList(account4.id);
        Account account5 = new Account(Name='test5', IATAcode__c = '5', ParentId=account4.Id);
        insert account5;
        ctrl.initIATACodeList(account5.id);
        Test.StopTest();
    }
    
    
    static testMethod void testLiveAgentConfList(){
        //Custom settings 1
        LiveAgent_Countries_Per_Button__c LAcountriesPB = new LiveAgent_Countries_Per_Button__c();
        LAcountriesPB.Button_Name__c = 'AirlinePortugueseEurope';
        LAcountriesPB.Country__c = 'Albania';
        LAcountriesPB.Iso_Code__c = 'AL';
        LAcountriesPB.Region__c = 'Europe';
        LAcountriesPB.Sector__c = '';
        LAcountriesPB.Name = 'AirlinePortugueseEurope';
        insert LAcountriesPB;
        
        //Custom settings 2
        LiveAgentButtonSettings__c  LAbtnSettings = new LiveAgentButtonSettings__c();
        LAbtnSettings.ButtonId__c= '5739E00000000R0QAI';
        LAbtnSettings.DeploymentId__c='572w0000000CdgF';
        LAbtnSettings.Language__c='pt';
        LAbtnSettings.Region__c='Europe';
        LAbtnSettings.Sectors__c='Airline';
        LAbtnSettings.Name='AirlinePortugueseEurope';
        insert LAbtnSettings;
        
        //Custom settings 3
        ISSP_FAQ2CaseLiveAgentTopics__c LAtopics =  new ISSP_FAQ2CaseLiveAgentTopics__c();
        LAtopics.value__c='AIRLINE_General_Information__c';
        LAtopics.LVA_ButtomCategories__c= 'BUT_CAT_EMERGENCY,BUT_CAT_ALL,BUT_CAT_PORTAL,BUT_CAT_COUNTRY,BUT_CAT_ENGLISH,BUTTON_NOT_ALLOWED';
        LAtopics.Name = '23';
        insert LAtopics;
        List <String> splitButtomCategories = (LAtopics.LVA_ButtomCategories__c).split(',');
        
        //ISO Country        
        IATA_ISO_Country__c isoC = new IATA_ISO_Country__c();
        isoC.name = 'Portugal';
        isoC.ISO_Code__c = 'PT';
        isoC.Case_BSP_Country__c = 'Portugal';
        isoC.Region__c = 'Europe';
        insert isoC;
        system.debug('isoCisoC ' + isoC);
        
        //Account
        Id agencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account testAccount = new Account(
            name= 'testAccount',
            RecordTypeId = agencyRecordTypeId,
            IATAcode__c = '047',
            IATA_ISO_Country__r = isoC
        );
        insert testAccount;
        system.debug('testAccount zzzzzz ' + testAccount.IATA_ISO_Country__r.Case_BSP_Country__c);   
        
        //Contact
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= testAccount.Id;
        con.Email = 'fake@email.com';
        con.CNS_Contact__c = true;
        insert con;
        system.debug('con zzzzzz ' + con);
        
        //User
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;
        system.debug('newUser zzzzzz ' + newUser);
        
        //One time showing the Video
        Boolean amIseeingThisAgain;
        
        
        //Run Test
        Test.StartTest();
        System.runAs(newUser){
            
            vfISSP_FAQ2Case controller = new vfISSP_FAQ2Case();
            controller.pageLoad();
            String agentvidMode = controller.livAgentIntroVidMode;
            amIseeingThisAgain = controller.isIntrovideoAlreadyShowed;
            system.assertEquals(false, amIseeingThisAgain);
            controller.livAgentIntroVidCloseAndDontRemenber();
            amIseeingThisAgain = controller.isIntrovideoAlreadyShowed;
            system.assertEquals(true,amIseeingThisAgain);
            
            
            controller.IwishtoComplain();
            controller.topic = '0';
            controller.subtopic = 'Fees__c';
            controller.setRecordType();
            controller.create();
            controller.refreshTopicPickList();
            controller.refreshSubTopicPickList();
            controller.Sector = 'Airline';
            controller.isAgencyUser = true;
            
            Case newCases = controller.newCase;
            newCases.IFAP_Country_ISO__c ='PT';
            newCases.Subject = 'testMeSub';
            newCases.Description = 'testMeDesc';            
            
            controller.getTopicsToShowButtonFromACategory(splitButtomCategories[1]);
            
            Boolean showButton = controller.showButton;
            system.assertEquals(false,showButton);
            
            controller.setLiveAgentButtonsNames();
            controller.getButtonNameFromConfigAndAddToList(LAbtnSettings.Name,splitButtomCategories[1]);
            controller.isAllowedCode(LAbtnSettings.Name);
            system.assertEquals(true,controller.isAllowedCode(LAbtnSettings.Name));

            
            controller.getTopicsToShowButtonFromACategory(splitButtomCategories[0]);
            LAbtnSettings.Name='Emergency';
            update LAbtnSettings;
            controller.setLiveAgentButtonsNames();
            controller.getButtonNameFromConfigAndAddToList(LAbtnSettings.Name,splitButtomCategories[0]);
            controller.isAllowedCode(LAbtnSettings.Name);
            system.assertEquals(false,controller.isAllowedCode(LAbtnSettings.Name));
            
            Boolean isVidAllowed = controller.livAgentIntroVidIsAllowed;
            system.assertEquals(true, isVidAllowed);
            
            Boolean isToShowFAQs = controller.isToShowFAQs;
            system.assertEquals(true, isToShowFAQs);
            
            controller.save();
            
            controller.cancel();
        }
        Test.StopTest();
    }
    

    static testMethod void testDoGet() {
        //Custom settings 1
        LiveAgent_Countries_Per_Button__c LAcountriesPB = new LiveAgent_Countries_Per_Button__c();
        LAcountriesPB.Button_Name__c = 'AirlinePortugueseEurope';
        LAcountriesPB.Country__c = 'Albania';
        LAcountriesPB.Iso_Code__c = 'AL';
        LAcountriesPB.Region__c = 'Europe';
        LAcountriesPB.Sector__c = '';
        LAcountriesPB.Name = 'AirlinePortugueseEurope';
        insert LAcountriesPB;
        
        //Custom settings 2
        LiveAgentButtonSettings__c  LAbtnSettings = new LiveAgentButtonSettings__c();
        LAbtnSettings.ButtonId__c= '5739E00000000R0QAI';
        LAbtnSettings.DeploymentId__c='572w0000000CdgF';
        LAbtnSettings.Language__c='ar';
        LAbtnSettings.Region__c='Africa & Middle East';
        LAbtnSettings.Sectors__c='Airline';
        LAbtnSettings.Name='AirlineArabEurope';
        insert LAbtnSettings;
        
        //Custom settings 3
        ISSP_FAQ2CaseLiveAgentTopics__c LAtopics =  new ISSP_FAQ2CaseLiveAgentTopics__c();
        LAtopics.value__c='AIRLINE_General_Information__c';
        //LAtopics.LVA_ButtomCategories__c= 'BUT_CAT_4_EMERGENCY,BUT_CAT_ALL,BUT_CAT_1_PORTAL,BUT_CAT_2_COUNTRY,BUT_CAT_3_ENGLISH,BUTTON_NOT_ALLOWED';
        LAtopics.LVA_ButtomCategories__c= 'BUT_CAT_EMERGENCY,BUT_CAT_ALL,BUT_CAT_PORTAL,BUT_CAT_COUNTRY,BUT_CAT_ENGLISH,BUTTON_NOT_ALLOWED';
        LAtopics.Name = '23';
        insert LAtopics;
        List <String> splitButtomCategories = (LAtopics.LVA_ButtomCategories__c).split(',');
        
        //ISO Country        
        IATA_ISO_Country__c isoC = new IATA_ISO_Country__c();
        isoC.name = 'United Arab Emirates';
        isoC.ISO_Code__c = 'AE';
        isoC.Case_BSP_Country__c = 'United Arab Emirates';
        isoC.Region__c = 'Africa & Middle East';
        insert isoC;
        
        //Account
        Id agencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account testAccount = new Account(
            name= 'testAccount',
            RecordTypeId = agencyRecordTypeId,
            IATAcode__c = '047',
            IATA_ISO_Country__r = isoC
        );
        insert testAccount;
        system.debug('testAccount zzzzzz ' + testAccount.IATA_ISO_Country__r.Case_BSP_Country__c);   
        
        //Contact
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= testAccount.Id;
        con.Email = 'fake@email.com';
        con.CNS_Contact__c = true;
        insert con;
        system.debug('con zzzzzz ' + con);
        
        //User
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;
        system.debug('newUser zzzzzz ' + newUser);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/newgenapp/v1/contactSupport';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response= res;

        System.runAs(newUser){
            Test.startTest();
                vfISSP_FAQ2Case.CustomerSupporWrapperGet customerSupportInfo = vfISSP_FAQ2Case.doGet();
                // should have topics to choose
                System.assert(customerSupportInfo.topicsMap != null && customerSupportInfo.topicsMap.size() > 0);
                // should have subtopics to choose
                System.assert(customerSupportInfo.subTopicsMap != null && customerSupportInfo.subTopicsMap.size() > 0);
                // should have countries to choose
                System.assert(customerSupportInfo.countryMap != null && customerSupportInfo.countryMap.size() > 0);
            Test.stopTest();
        }
    }

    static testMethod void testDoPost() {
        //Custom settings 1
        LiveAgent_Countries_Per_Button__c LAcountriesPB = new LiveAgent_Countries_Per_Button__c();
        LAcountriesPB.Button_Name__c = 'AirlinePortugueseEurope';
        LAcountriesPB.Country__c = 'Albania';
        LAcountriesPB.Iso_Code__c = 'AL';
        LAcountriesPB.Region__c = 'Europe';
        LAcountriesPB.Sector__c = '';
        LAcountriesPB.Name = 'AirlinePortugueseEurope';
        insert LAcountriesPB;
        
        //Custom settings 2
        LiveAgentButtonSettings__c  LAbtnSettings = new LiveAgentButtonSettings__c();
        LAbtnSettings.ButtonId__c= '5739E00000000R0QAI';
        LAbtnSettings.DeploymentId__c='572w0000000CdgF';
        LAbtnSettings.Language__c='ar';
        LAbtnSettings.Region__c='Africa & Middle East';
        LAbtnSettings.Sectors__c='Airline';
        LAbtnSettings.Name='AirlineArabEurope';
        insert LAbtnSettings;
        
        //Custom settings 3
        ISSP_FAQ2CaseLiveAgentTopics__c LAtopics =  new ISSP_FAQ2CaseLiveAgentTopics__c();
        LAtopics.value__c='AIRLINE_General_Information__c';
        //LAtopics.LVA_ButtomCategories__c= 'BUT_CAT_4_EMERGENCY,BUT_CAT_ALL,BUT_CAT_1_PORTAL,BUT_CAT_2_COUNTRY,BUT_CAT_3_ENGLISH,BUTTON_NOT_ALLOWED';
        LAtopics.LVA_ButtomCategories__c= 'BUT_CAT_EMERGENCY,BUT_CAT_ALL,BUT_CAT_PORTAL,BUT_CAT_COUNTRY,BUT_CAT_ENGLISH,BUTTON_NOT_ALLOWED';
        LAtopics.Name = '23';
        insert LAtopics;
        List <String> splitButtomCategories = (LAtopics.LVA_ButtomCategories__c).split(',');
        
        //ISO Country        
        IATA_ISO_Country__c isoC = new IATA_ISO_Country__c();
        isoC.name = 'United Arab Emirates';
        isoC.ISO_Code__c = 'AE';
        isoC.Case_BSP_Country__c = 'United Arab Emirates';
        isoC.Region__c = 'Africa & Middle East';
        insert isoC;
        
        //Account
        Id agencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account testAccount = new Account(
            name= 'testAccount',
            RecordTypeId = agencyRecordTypeId,
            IATAcode__c = '047',
            IATA_ISO_Country__r = isoC
        );
        insert testAccount;
        system.debug('testAccount zzzzzz ' + testAccount.IATA_ISO_Country__r.Case_BSP_Country__c);   
        
        //Contact
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= testAccount.Id;
        con.Email = 'fake@email.com';
        con.CNS_Contact__c = true;
        insert con;
        system.debug('con zzzzzz ' + con);
        
        //User
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;
        system.debug('newUser zzzzzz ' + newUser);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/newgenapp/v1/contactSupport';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response= res;

        System.runAs(newUser){
            Test.startTest();
                vfISSP_FAQ2Case.CustomerSupporWrapperPost customerSupportInfo = vfISSP_FAQ2Case.doPost('0', 'CGO_Accreditations_Fees__c', 'AE', '', 'This is a test subject',
                                                                                    'This is a test description', 'Phone [NewGenAPP - Android]');
            Test.stopTest();
        }
    }
    
    private static void setCCOthersEmail(vfISSP_FAQ2Case controller, String email) {
        for (vfISSP_FAQ2Case.sectionRecordWrapper section : controller.fullList) {
            for (vfISSP_FAQ2Case.fieldRecordWrapper thisField : section.fieldList) {
                if (thisField.fieldType == 'ccothers') {
                    thisField.fieldValueEntered = email;
                }
            }
      }
    }
    
    static testMethod void testFaq2CaseEmergency() 
    {
        //ISSP_ObjectFactory.fiilIncludedFields();

        Id rtIdHq = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Airline'][0].Id;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Airline_BR'][0].Id;                       

        //Account parent =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
       
        //Account headQuarter =  (Account)ISSP_ObjectFactory.createSObject('Account',false,2);
        Account headQuarter = ISSP_ObjectFactory.createNewAccount();
        headQuarter.ParentId = parent.Id;
        headQuarter.BillingCity = 'test2';
        headQuarter.Name = 'test2';
        headQuarter.RecordTypeId = rtIdHq;
        headQuarter.Site = 'headSite';
        insert headQuarter;
        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.Email = 'testxxaasddasdasda@test.com';
        con.AccountId= headQuarter.Id;
        insert con;
        User newUser = ISSP_ObjectFactory.createPortalUser(con);

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', ISO_Code__c = 't1', Case_BSP_Country__c = 'test1');
        insert country;

        list<Account> consumers = new list<Account>();
        for (integer i = 0;i<1;i++)
            consumers.add(new Account(name = 'consumer '+i,
                                    recordTypeId =rtIdBr,
                                    parentId = headQuarter.id,
                                    Site = 'Site'+i,
                                    IATA_ISO_Country__c = country.Id));
        insert consumers;

        list<Services_Rendered__c> services = new list<Services_Rendered__c>();
        for(Account cons: consumers )
        { 
            services.add( new  Services_Rendered__c(Services_Rendered_Status__c = 'Active',Services_Rendered_Type__c = 'CASS Participation',Services_Rendered_to_Airline__c = cons.id, Services_Rendered_By__c = headQuarter.Id));
            services.add( new  Services_Rendered__c(Services_Rendered_Status__c = 'Active',Services_Rendered_Type__c = 'BSP Representation',Services_Rendered_to_Airline__c = cons.id, Services_Rendered_By__c = headQuarter.Id));
            services.add( new  Services_Rendered__c(Services_Rendered_Status__c = 'Active',Services_Rendered_Type__c = 'THIS ONE WILL NOT FIRE !!!!',Services_Rendered_to_Airline__c = cons.id, Services_Rendered_By__c = headQuarter.Id));
        }
        insert services;

        System.runAs(newUser)
        {
            vfISSP_FAQ2Case controller = new vfISSP_FAQ2Case();
            controller.pageLoad();
            controller.createAnEmergency();
            controller.refreshTopicPickList();
            controller.getCallUsEmergencyFinalString();
        }

    }
 }