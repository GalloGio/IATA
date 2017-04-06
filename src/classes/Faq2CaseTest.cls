@isTest(SeeAllData=true)
private class Faq2CaseTest {

    static testMethod void testArticleViewLine() {
        FAQ__kav article = new FAQ__kav();
        FAQ__VoteStat voteStat = new FAQ__VoteStat();
        
        Test.startTest();
        vfISSP_FAQ2Case.ArticleViewLine articleVL1 = new vfISSP_FAQ2Case.ArticleViewLine(article);
        articleVL1.getHasVoteStat();
        articleVL1.getPath();
        vfISSP_FAQ2Case.ArticleViewLine articleVL2 = new vfISSP_FAQ2Case.ArticleViewLine(article,voteStat);
        articleVL2.getHasVoteStat();
        articleVL2.getPath();
        Test.stopTest();
    }

    static testMethod void testFaq2Case_Cases_a()
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
            //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
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
            ctrl.AssignNewCaseRecordType();
            ctrl.getCaseRecordTypeIdByName('IATA_Airline');
            ctrl.CheckCountryMatch('ES','ES');
        }
        Test.stopTest();
    }

    static testMethod void testFaq2Case_Cases_b()
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
            //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
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

    static testMethod void testFaq2CaseExt() 
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

    public static testMethod void languageTest()
    {
        //Account account = (Account)ISSP_ObjectFactory.createSObject('Account');
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.Name = 'Account1';
        insert account;
        //Contact contact = (Contact)ISSP_ObjectFactory.createSObject('Contact');
        Contact contact = ISSP_ObjectFactory.createNewContact();
        //contact.Name = 'contact1';
        insert contact;
        ISSP_Case cttr = new ISSP_Case();
        String recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'DPC Service Request'].Id;
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





    /**
     * Nurit and Niv
     * Testing the 'calculateViewAndSatisfied' methode
     */
   /* static testMethod void testCalc(){
        List<User> newUser_List = new List<User>([select Id ,Name From User where Email = 'Test@test11.com' ]);
        User newUser = newUser_List[0];
        Test.startTest();
        System.runAs(newUser)
        {
            vfISSP_FAQ2Case controller = new vfISSP_FAQ2Case();
            system.debug('Kero2112 pageLoad Calc' );
            controller.pageLoad();

            // Set Topic and Subtopic
            Integer topCatGroupIndex = getIndexWithChildes(controller.DataCategoryContainer);
            controller.topic = String.valueOf(topCatGroupIndex);
            System.debug('controller.topic: ' + controller.topic);
            controller.subtopic = getSubCat(controller.DataCategoryContainer, topCatGroupIndex);
            System.debug('controller.subtopic: ' + controller.subtopic);

            // Set the group and category name for the articles
            String groupName = null;
            String catName = null;
            for (clsDataCategory dc : controller.DataCategoryContainer.lst_DataCategories)
            {
                if (dc.CategoryName == controller.subtopic)
                {
                    groupName = dc.topCategoryLabel;
                    catName = dc.CategoryLabel;
                    break;
                }
            }
            // Create 2 Articles with the URL Names: test0, test1
            List<FAQ__kav> lstFaqs = TestObjectCreator.createFAQArticles(2);

            // Create Categories to lstFaqs
            //TestObjectCreator.createFAQArticlesCategories(lstFaqs, groupName, catName);

            // Changing the article from 'Draft' status to 'Publish'
            List<String> lstFormatArgs = new List<String> {'\'', 'fr', 'Draft', 'FAQ__kav'};
            String query = 'SELECT Title, UrlName, Id, KnowledgeArticleId, Language, PublishStatus FROM {3} WHERE Language = {0}{1}{0} AND PublishStatus = {0}{2}{0}';
            query = String.format(query, lstFormatArgs);
            lstFaqs = (List<FAQ__kav>)Database.query(query);
            for (FAQ__kav faq : lstFaqs)
            {
                KbManagement.PublishingService.publishArticle(faq.KnowledgeArticleId, true);
            }
            System.debug('kerensen lstFaqs: ' + lstFaqs);
        
            // Set the first article as the First page 
            PageReference prFAQ2Case = Page.ISSP_FAQ2Case;
            prFAQ2Case.getParameters().put('artid', lstFaqs[0].Id);
            Test.setCurrentPage(prFAQ2Case);
            vfISSP_FAQ2Case.ArticleViewLine avl = new vfISSP_FAQ2Case.ArticleViewLine(lstFaqs[0]);
            avl.getHasVoteStat();
            avl.getPath();
            vfISSP_FAQ2Case.ArticleViewLine avl1 = new vfISSP_FAQ2Case.ArticleViewLine(lstFaqs[0], null);
            controller.articleViewLines = new List<vfISSP_FAQ2Case.ArticleViewLine> {avl, avl1};
        
            // Creating an Article Statistic record with Stat-Type 'View'
            ArticleStatistics__c artStatRecord_1 = new ArticleStatistics__c (URL_Name__c = 'test0', Timestamp__c = DateTime.now(), Stat_Type__c = ENV.ArticleStatType.View, Topic__c = groupName , Sub_Topic__c = catName);
            insert artStatRecord_1;
            PageReference pr1 = controller.getSelectArtical();

            // Set the second article as the Second page
            PageReference prFAQ2Case2 = Page.ISSP_FAQ2Case;
            prFAQ2Case2.getParameters().put('artid', lstFaqs[1].Id);
            Test.setCurrentPage(prFAQ2Case2);
            vfISSP_FAQ2Case.ArticleViewLine av2 = new vfISSP_FAQ2Case.ArticleViewLine(lstFaqs[1]);
            av2.getHasVoteStat();
            av2.getPath();
            vfISSP_FAQ2Case.ArticleViewLine avl2 = new vfISSP_FAQ2Case.ArticleViewLine(lstFaqs[1], null);
            controller.articleViewLines = new List<vfISSP_FAQ2Case.ArticleViewLine> {av2, avl2};

            // Creating an Article Statistic record with Stat-Type 'Satisfied'
            ArticleStatistics__c artStatRecord_2 = new ArticleStatistics__c (URL_Name__c = 'test1', Timestamp__c = DateTime.now(), Stat_Type__c = ENV.ArticleStatType.Satisfied , Topic__c = groupName, Sub_Topic__c = catName);
            insert artStatRecord_2;    
            PageReference pr2 = controller.getSelectArtical();

            controller.create();
            controller.createSatisfiedRecord();
        }
        Test.stopTest();
    }

     
    
    static testMethod void testFaq2Case001() 
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
        insert con;
        System.debug('con Id: ' + con.Id);

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User newUser1 = new User(alias = 'dsfsdfds', 
                                email = 'admin@admin.admin', 
                                emailencodingkey = 'UTF-8', 
                                firstname = con.firstName, 
                                lastname = con.lastname, 
                                languagelocalekey = 'en_US', 
                                localesidkey = 'en_US', 
                                contactId = con.Id,
                                UserPermissionsKnowledgeUser = true,
                                timezonesidkey = 'Asia/Dubai',
                                 Username = uniqueName + '@test' + orgId + '.org',
                                PortalRole = 'Manager',
                                License_Cost_Center__c = 'ITO005CH01',
                                CommunityNickname = 'admin'+Datetime.now().formatLong().substring(10,15),
                                ProfileId = [select Id from Profile where Name='ISS Portal Airline Delegated Admin User' limit 1].Id,
                                IsActive = true);
        insert newUser1;

        Test.startTest();
        System.runAs(newUser1)
        {
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId()];
            currentUserInfo.LanguageLocaleKey = 'fr';
            update currentUserInfo;

            vfISSP_FAQ2Case controller = new vfISSP_FAQ2Case();
            system.debug('Kero2112 pageLoad 1' );
            controller.pageLoad();

            object keg = controller.newCase;

            Integer topCatGroupIndex = getIndexWithChildes(controller.DataCategoryContainer);
            controller.topic = String.valueOf(topCatGroupIndex);
            System.debug('controller.topic: ' + controller.topic);
            controller.subtopic = getSubCat(controller.DataCategoryContainer, topCatGroupIndex);
            System.debug('controller.subtopic: ' + controller.subtopic);

            String groupName = null;
            String catName = null;
            for (clsDataCategory dc : controller.DataCategoryContainer.lst_DataCategories)
            {
                if (dc.CategoryName == controller.subtopic)
                {
                    groupName = dc.topCategoryLabel;
                    catName = dc.CategoryLabel;
                    break;
                }
            }
            System.debug('catName: ' + catName);
            List<FAQ__kav> lstFaqs = TestObjectCreator.createFAQArticles(1);
            //TestObjectCreator.createFAQArticlesCategories(lstFaqs, groupName, catName);
            List<String> lstFormatArgs = new List<String> {'\'', 'fr', 'Draft', 'FAQ__kav'};
            String query = 'SELECT Title, UrlName, Id, KnowledgeArticleId, Language, PublishStatus FROM {3} WHERE Language = {0}{1}{0} AND PublishStatus = {0}{2}{0}';
            query = String.format(query, lstFormatArgs);
            lstFaqs = (List<FAQ__kav>)Database.query(query);
            for (FAQ__kav faq : lstFaqs)
            {
                KbManagement.PublishingService.publishArticle(faq.KnowledgeArticleId, true);
            }

            PageReference prFAQ2Case = Page.ISSP_FAQ2Case;
            prFAQ2Case.getParameters().put('artid', lstFaqs[0].Id);
            Test.setCurrentPage(prFAQ2Case);
            vfISSP_FAQ2Case.ArticleViewLine avl = new vfISSP_FAQ2Case.ArticleViewLine(lstFaqs[0]);
            avl.getHasVoteStat();
            avl.getPath();
            vfISSP_FAQ2Case.ArticleViewLine avl1 = new vfISSP_FAQ2Case.ArticleViewLine(lstFaqs[0], null);
            controller.articleViewLines = new List<vfISSP_FAQ2Case.ArticleViewLine> {avl, avl1};
            PageReference pr = controller.getSelectArtical();

            //controller.resetCase();
            //controller.initTopicsList();
            //controller.addDecsription();
            controller.create();
            controller.back();
            controller.save();
            controller.refreshTopicPickList();
            controller.refreshSubTopicPickList();
            keg = controller.countryList;


            controller.subtopic = ENV.SelectOptionDefaultValue;
            controller.refreshSubTopicPickList();
        }
        Test.stopTest();
    }
    */
    static testMethod void testFaq2Case002() {
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
          //controller.create();
          controller.back();
          controller.saveAttach(); 
          controller.refreshTopicPickList();
          controller.refreshSubTopicPickList();
          keg = controller.countryList;
        }
        Test.stopTest();
    }

    static testMethod void testFaq2Case003() {
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
          //controller.create();
          controller.back();
          //controller.refreshTopicPickList();
          keg = controller.countryList;
        }
        Test.stopTest();
    }

    static testMethod void testFaq2Case004() {
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
          //controller.create();
          controller.back();
          controller.refreshTopicPickList();
          controller.refreshSubTopicPickList();
          keg = controller.countryList;
        }
        Test.stopTest();
    }

    static testMethod void testFaq2Case005() {
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
          //controller.topic = String.valueOf(topCatGroupIndex);
          //controller.subtopic = Env.SelectOptionDefaultValue;
          //controller.create();
          controller.IwishtoComplain();
          controller.topic = String.valueOf(topCatGroupIndex);
          controller.subtopic = Env.SelectOptionDefaultValue;
          controller.refreshTopicPickList();
          controller.refreshSubTopicPickList();
          keg = controller.countryList;
        }
        Test.stopTest();
    }

    static testMethod void testFaq2Case006() {
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

        String recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'DPC Service Request'].Id;

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
          //controller.refreshAirlineList();
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
          //controller.GenerateTopicHelpText();
          //controller.GeneratesubTopicHelpText();

          controller.topic = '0';
          controller.subtopic = 'CGO_Bank_Guarantees__c';
          controller.newCase.IFAP_Country_ISO__c = 'GB';
          String test;
          test = controller.encTopicLbl;
          test = controller.encSubtopicLbl;
          test = controller.encIsoCountry;
          test = controller.region;
          
          //   ISSP_FAQ2CaseLiveAgentTopics__c topicsSetting = new ISSP_FAQ2CaseLiveAgentTopics__c(name = '1', value__c = '0.CGO_Bank_Guarantees__c');
          //   insert topicsSetting;
          //   LiveAgentButtonSettings__c sectorSetting = new LiveAgentButtonSettings__c(name = 'AirlineEnglish',sectors__c='Airline');
          //   insert sectorSetting;
          //   LiveAgent_Countries_Per_Button__c codeSetting = new LiveAgent_Countries_Per_Button__c(Button_Name__c = 'AirlineEnglish', Iso_Code__c = 'GB');
          //   insert codeSetting;
          
          //System.assert(controller.showButton);
        }
        Test.stopTest();
    }

	static testMethod void testFaq2Case007() {
		Id agencyRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='IATA_Agency'].Id;
		Account testAccount = new Account(
			name= 'testAccount',
			CNS_Account__c = true,
			RecordTypeId = agencyRecordTypeId
		);
		insert testAccount;
        Contact con = ISSP_ObjectFactory.createNewContact();

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', ISO_Code__c = 't1', Case_BSP_Country__c = 'test1', Region__c = 'test');
		insert country;

		String recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'DPC Service Request'].Id;
		//
		// Case c=new Case(Subject='test 1',Status='Open', AccountId=parent.id, ContactId=con.id,Region__c = 'Europe', IFAP_Country_ISO__c ='t1' , RecordTypeId = recordTypeId);
		// insert c;
		//
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
		  //controller.refreshAirlineList();
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
		  Set<String> stString = controller.topicsToShowButton;
		  Boolean b = controller.showButton;
		  Boolean b2 = controller.isAllowedCode('test');
		//   Boolean b3 = controller.isAllowedSector('test');
		  PageReference pr = controller.getSelectArtical();
		  PageReference pr2 = controller.create1();
		  PageReference pr3 = controller.ComplimentGeneralQueueMethod();
		  Boolean b4 = controller.isArticalSelected;
		//   controller.refreshAirlineList();

		  controller.isCompliment1 = true;
		  Case newCase = controller.newCase;
		  newCase.IFAP_Country_ISO__c ='t1';
		  newCase.Subject = 'test';
		  newCase.Description = 'test';

		  controller.topic = '0';
		  controller.subtopic = 'CGO_Bank_Guarantees__c';
		  controller.save();
		}
		Test.stopTest();
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
}
