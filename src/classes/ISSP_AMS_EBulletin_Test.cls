@isTest
private class ISSP_AMS_EBulletin_Test {



	
	@isTest static void test_method_one() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
        							IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
        							IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 't1',
        							IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test',
                                    Region__c = 'Americas' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', IATA_Contry_KR__c = 'test2',
                                    IATA_COUNTRY_EN__c = 'testEN2' , IATA_Country_FR__c = 'testFR2' , IATA_Country_ZH__c = 'testZH2' ,
                                    IATA_Country_IT__c = 'testIT2' , IATA_Country_JP__c = 'testJP2' , ISO_Code__c = 't2',
                                    IATA_Country_PT__c = 'testPT2' , IATA_Country_SP__c = 'testSP2' , Case_BSP_Country__c = 'test2',
                                    Region__c = 'Americas');
        insert country2;

        IATA_ISO_Country__c country3 = new IATA_ISO_Country__c(name = 'test3', IATA_Contry_KR__c = 'test3',
                                    IATA_COUNTRY_EN__c = 'testEN3' , IATA_Country_FR__c = 'testFR3' , IATA_Country_ZH__c = 'testZH3' ,
                                    IATA_Country_IT__c = 'testIT3' , IATA_Country_JP__c = 'testJP3' , ISO_Code__c = 't3',
                                    IATA_Country_PT__c = 'testPT3' , IATA_Country_SP__c = 'testSP3' , Case_BSP_Country__c = 'test3',
                                    Region__c = 'Europe');
        insert country3;

        IATA_ISO_Country__c country4 = new IATA_ISO_Country__c(name = 'test4', IATA_Contry_KR__c = 'test4',
                                    IATA_COUNTRY_EN__c = 'testEN4' , IATA_Country_FR__c = 'testFR4' , IATA_Country_ZH__c = 'testZH4' ,
                                    IATA_Country_IT__c = 'testIT4' , IATA_Country_JP__c = 'testJP4' , ISO_Code__c = 't4',
                                    IATA_Country_PT__c = 'testPT4' , IATA_Country_SP__c = 'testSP4' , Case_BSP_Country__c = 'test4',
                                    Region__c = 'China & North Asia');
        insert country4;

		Id rtIdBr = [ SELECT Id FROM RecordType 
		WHERE SobjectType = 'Account'
		AND DeveloperName = 'IATA_Agency'][0].Id; 


		Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
		parent.sector__c = 'airline';
		parent.Location_Type__c = 'HO';
		parent.RecordTypeId = rtIdBr ;
		parent.IATACode__c = '100';
		 
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
		child.sector__c = 'airline';
        child.Top_Parent__c = null;
		child.IATA_ISO_Country__c = country.Id;
		child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
		con.Email = 'Test@test11.com';
		con.User_Portal_Status__c='Administrator';
        
        insert con;


       
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        
        
        insert new ISSP_CS__c(Name = 'DefaultNewAccountOwnerId',Value__c = newUser.Id);
        insert new ISSP_CS__c(Name = 'eBulletin_UserGuide',Value__c = 'EBULLETIN-USERGUIDE-');
        insert new ISSP_CS__c(Name = 'eBulletin_StartDate',Value__c = '01/08/2015');
        insert new ISSP_PDF_Per_Region__c(Name = 'test_en_US',Address__c = 'test_en_US',Link_To_PDF__c = 'test_en_US');
        insert new ISSP_PDF_Per_Region__c(Name = 'test_PT_pt',Address__c = 'test_PT_pt',Link_To_PDF__c = 'test_PT_pt');
        
        insert new ISSP_PDF_Per_Region__c(Name = 'EBULLETIN-USERGUIDE-en_US',Address__c='EBULLETIN-USERGUIDE-en_US', Link_To_PDF__c = 'EBULLETIN-USERGUIDE-en_US');

        
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        Test.startTest();
        System.runAs(newUser)
        {
            ISSP_AMS_EBulletin bulletin_0 = new ISSP_AMS_EBulletin();

            bulletin_0.fillMapCountries();
System.debug('mCountries 1: ' + bulletin_0.mCountries);
            List<String> lsStr = bulletin_0.getCountryName(new List<String>{'t1','t2','t4'});

            bulletin_0.newFormDaily.Area_1__c = true;
            bulletin_0.newFormWeekly.Area_1__c = true;
            bulletin_0.newFormDaily.Area_2__c = true;
            bulletin_0.newFormWeekly.Area_2__c = true;
            bulletin_0.newFormDaily.Area_3__c = true;
            bulletin_0.newFormWeekly.Area_3__c = true;

            bulletin_0.dailyCountrySelectAll = false;
            bulletin_0.weeklyCountrySelectAll = false;

            bulletin_0.dailyCountry = new List<String>{'t1','t2','t4'};
            bulletin_0.weeklyCountry =  new List<String>{'t1','t2','t4'};

            
            

            bulletin_0.dailyFileDownload = 'test';
            bulletin_0.weeklyFileDownload = 'test';
            bulletin_0.todayPeriod = 'test';
            bulletin_0.pDateStart = '01/01/2017';
            bulletin_0.pWeekStart = '01/01/2017';
            bulletin_0.pWeekEnd = '01/02/2017';
            bulletin_0.onOff = false;
            bulletin_0.dailyOnOff = false;
            bulletin_0.weeklyOnOff = false;
            PageReference pr_0 = bulletin_0.checkRedirect();
            String userguide = bulletin_0.getUserGuideFileLink('test_', 'PT_pt');
            List<SelectOption> timeZone = bulletin_0.getTimeZone();
            List<SelectOption> itemsDaysOfWeek = bulletin_0.getItemsDaysOfWeek();
            List<SelectOption> itemsWeeks = bulletin_0.getItemsWeeks();
            
            //bulletin_0.dailyCountrySelectAll();
            //bulletin_0.weeklyCountrySelectAll();

            bulletin_0.applyLanguage = 'es';
            
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            List<String> lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            List<String> lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            List<SelectOption> countryNameList1 = bulletin_0.countryNameListSelectOption('Daily');
            List<SelectOption> countryNameList2 = bulletin_0.countryNameListSelectOption('Weekly');

            bulletin_0.applyLanguage = 'fr';
            
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            countryNameList1 = bulletin_0.countryNameListSelectOption('Daily');
            countryNameList2 = bulletin_0.countryNameListSelectOption('Weekly');

            bulletin_0.applyLanguage = 'en_US';
            countryNameList1 = bulletin_0.countryNameListSelectOption('Daily');
            countryNameList2 = bulletin_0.countryNameListSelectOption('Weekly');

System.debug('mCountries 2: ' + bulletin_0.mCountries);

            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            bulletin_0.applyLanguage = 'es';
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            bulletin_0.applyLanguage = 'fr';
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            bulletin_0.applyLanguage = 'en_US';
            
            bulletin_0.newFormDaily.Suspend_Subscription__c = true;
            PageReference pr_suspendSubscription = bulletin_0.suspendSubscription();
            bulletin_0.newFormDaily.Suspend_Subscription__c = false;
            pr_suspendSubscription = bulletin_0.suspendSubscription();

            Boolean bval = bulletin_0.validateCharactersInForm();

            PageReference pr_dailyReportDownload = bulletin_0.dailyReportDownload();
            PageReference pr_weeklyReportDownload = bulletin_0.weeklyReportDownload();

            PageReference pr_Nav = bulletin_0.goToStepHome();
            pr_Nav = bulletin_0.goToStep1();
            pr_Nav = bulletin_0.goToStep1_1();
            pr_Nav = bulletin_0.goToStep1_2();
            pr_Nav = bulletin_0.goToStep2();
            pr_Nav = bulletin_0.goToStep3();
            pr_Nav = bulletin_0.saveAMSFormAndGoSideways();
            pr_Nav = bulletin_0.saveAMSFormAndGoForward();
            pr_Nav = bulletin_0.saveAMSFormAndGoBack();
            pr_Nav = bulletin_0.saveAMSFormAndStay();

            pr_Nav = bulletin_0.securityCheck();

            String str1 = bulletin_0.getMultiSelectToSave(bulletin_0.dailyCountry);
            String str2 = bulletin_0.getMultiSelectOptionsToSave(bulletin_0.countryNameListSelectOptionDaily);

            List<SelectOption> countryNameListDaily = bulletin_0.countryNameListSelectOptionDaily;
            List<SelectOption> countryNameListWeekly = bulletin_0.countryNameListSelectOptionWeekly;

            //System.debug('dailyCountrySelected 1: ' + bulletin_0.dailyCountrySelected);

            bulletin_0.dailyCountrySelectAll = true;
            bulletin_0.weeklyCountrySelectAll = true;
            bulletin_0.dailyCountrySelectAll();
            bulletin_0.weeklyCountrySelectAll();

            List<String> lstrTest = new List<String>{'t1','t4'};

            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.weeklyCountrySelected =  bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.newFormDaily.Area_2__c = false;
            bulletin_0.newFormWeekly.Area_2__c = false;

            //System.debug('dailyCountrySelected 2: ' + bulletin_0.dailyCountrySelected);

            countryNameListDaily = bulletin_0.countryNameListSelectOptionDaily;
            countryNameListWeekly = bulletin_0.countryNameListSelectOptionWeekly;

            lstrTest = new List<String>{'t1','t3','t4'};
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.weeklyCountrySelected =  bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.newFormDaily.Area_2__c = true;
            bulletin_0.newFormWeekly.Area_2__c = true;
           

            
            ISSP_AMS_EBulletin bulletin_0_2 = new ISSP_AMS_EBulletin();
            PageReference pr_0_2 = bulletin_0_2.checkRedirect();

            ApexPages.currentPage().getParameters().put('step' ,'1' );
            ISSP_AMS_EBulletin bulletin_1 = new ISSP_AMS_EBulletin();
            PageReference pr_saveAMSFormAndGoSideways = bulletin_1.saveAMSFormAndGoSideways();
            PageReference pr_saveAMSFormAndGoForward = bulletin_1.saveAMSFormAndGoForward();

            ApexPages.currentPage().getParameters().put('step' ,'1_1' );
            ISSP_AMS_EBulletin bulletin_1_1 = new ISSP_AMS_EBulletin();
            bulletin_1_1.newFormDaily.Opt_in__c = true;
            pr_saveAMSFormAndGoSideways = bulletin_1_1.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_1_1.saveAMSFormAndGoForward();
            PageReference pr_saveAMSFormAndStay = bulletin_1_1.saveAMSFormAndStay();

            ApexPages.currentPage().getParameters().put('step' ,'1_2' );
            ISSP_AMS_EBulletin bulletin_1_2 = new ISSP_AMS_EBulletin();
            bulletin_1_2.newFormWeekly.Opt_in__c = true;
            pr_saveAMSFormAndGoSideways = bulletin_1_2.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_1_2.saveAMSFormAndGoForward();
            pr_saveAMSFormAndStay = bulletin_1_2.saveAMSFormAndStay();

            ApexPages.currentPage().getParameters().put('step' ,'2' );
            ISSP_AMS_EBulletin bulletin_2 = new ISSP_AMS_EBulletin();
            pr_saveAMSFormAndGoSideways = bulletin_2.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_2.saveAMSFormAndGoForward();

            ApexPages.currentPage().getParameters().put('step' ,'3' );
            ISSP_AMS_EBulletin bulletin_3 = new ISSP_AMS_EBulletin();
            pr_saveAMSFormAndGoSideways = bulletin_3.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_3.saveAMSFormAndGoForward();

            ApexPages.currentPage().getParameters().put('step' ,'home' );
            ISSP_AMS_EBulletin bulletin_home = new ISSP_AMS_EBulletin();

            PageReference pr_home = bulletin_home.checkRedirect();
    	}
        Test.stopTest();

	}
	
	@isTest static void test_CNS() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 't1',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test',
                                    Region__c = 'Americas' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', IATA_Contry_KR__c = 'test2',
                                    IATA_COUNTRY_EN__c = 'testEN2' , IATA_Country_FR__c = 'testFR2' , IATA_Country_ZH__c = 'testZH2' ,
                                    IATA_Country_IT__c = 'testIT2' , IATA_Country_JP__c = 'testJP2' , ISO_Code__c = 't2',
                                    IATA_Country_PT__c = 'testPT2' , IATA_Country_SP__c = 'testSP2' , Case_BSP_Country__c = 'test2',
                                    Region__c = 'Americas');
        insert country2;

        IATA_ISO_Country__c country3 = new IATA_ISO_Country__c(name = 'test3', IATA_Contry_KR__c = 'test3',
                                    IATA_COUNTRY_EN__c = 'testEN3' , IATA_Country_FR__c = 'testFR3' , IATA_Country_ZH__c = 'testZH3' ,
                                    IATA_Country_IT__c = 'testIT3' , IATA_Country_JP__c = 'testJP3' , ISO_Code__c = 't3',
                                    IATA_Country_PT__c = 'testPT3' , IATA_Country_SP__c = 'testSP3' , Case_BSP_Country__c = 'test3',
                                    Region__c = 'Europe');
        insert country3;

        IATA_ISO_Country__c country4 = new IATA_ISO_Country__c(name = 'test4', IATA_Contry_KR__c = 'test4',
                                    IATA_COUNTRY_EN__c = 'testEN4' , IATA_Country_FR__c = 'testFR4' , IATA_Country_ZH__c = 'testZH4' ,
                                    IATA_Country_IT__c = 'testIT4' , IATA_Country_JP__c = 'testJP4' , ISO_Code__c = 't4',
                                    IATA_Country_PT__c = 'testPT4' , IATA_Country_SP__c = 'testSP4' , Case_BSP_Country__c = 'test4',
                                    Region__c = 'China & North Asia');
        insert country4;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'airline';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'airline';
        child.Top_Parent__c = null;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        con.User_Portal_Status__c='Administrator';
        
        insert con;


       
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        
        
        insert new ISSP_CS__c(Name = 'DefaultNewAccountOwnerId',Value__c = newUser.Id);
        insert new ISSP_CS__c(Name = 'eBulletin_UserGuide',Value__c = 'EBULLETIN-USERGUIDE-');
        insert new ISSP_CS__c(Name = 'eBulletin_StartDate',Value__c = '01/08/2015');
        insert new ISSP_PDF_Per_Region__c(Name = 'test_en_US',Address__c = 'test_en_US',Link_To_PDF__c = 'test_en_US');
        insert new ISSP_PDF_Per_Region__c(Name = 'test_PT_pt',Address__c = 'test_PT_pt',Link_To_PDF__c = 'test_PT_pt');
        
        insert new ISSP_PDF_Per_Region__c(Name = 'EBULLETIN-USERGUIDE-en_US',Address__c='EBULLETIN-USERGUIDE-en_US', Link_To_PDF__c = 'EBULLETIN-USERGUIDE-en_US');

        
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        Test.startTest();
        System.runAs(newUser)
        {
            CNS_EBulletin bulletin_0 = new CNS_EBulletin();

            bulletin_0.fillMapCountries();
System.debug('mCountries 1: ' + bulletin_0.mCountries);
            List<String> lsStr = bulletin_0.getCountryName(new List<String>{'t1','t2','t4'});

            bulletin_0.newFormDaily.Area_1__c = true;
            bulletin_0.newFormWeekly.Area_1__c = true;
            bulletin_0.newFormDaily.Area_2__c = true;
            bulletin_0.newFormWeekly.Area_2__c = true;
            bulletin_0.newFormDaily.Area_3__c = true;
            bulletin_0.newFormWeekly.Area_3__c = true;

            bulletin_0.dailyCountrySelectAll = false;
            bulletin_0.weeklyCountrySelectAll = false;

            bulletin_0.dailyCountry = new List<String>{'t1','t2','t4'};
            bulletin_0.weeklyCountry =  new List<String>{'t1','t2','t4'};

            
            

            bulletin_0.dailyFileDownload = 'test';
            bulletin_0.weeklyFileDownload = 'test';
            bulletin_0.todayPeriod = 'test';
            bulletin_0.pDateStart = '01/01/2017';
            bulletin_0.pWeekStart = '01/01/2017';
            bulletin_0.pWeekEnd = '01/02/2017';
            bulletin_0.onOff = false;
            bulletin_0.dailyOnOff = false;
            bulletin_0.weeklyOnOff = false;
            PageReference pr_0 = bulletin_0.checkRedirect();
            String userguide = bulletin_0.getUserGuideFileLink('test_', 'PT_pt');
            List<SelectOption> timeZone = bulletin_0.getTimeZone();
            List<SelectOption> itemsDaysOfWeek = bulletin_0.getItemsDaysOfWeek();
            List<SelectOption> itemsWeeks = bulletin_0.getItemsWeeks();
            
            //bulletin_0.dailyCountrySelectAll();
            //bulletin_0.weeklyCountrySelectAll();

            bulletin_0.applyLanguage = 'es';
            
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            List<String> lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            List<String> lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            List<SelectOption> countryNameList1 = bulletin_0.countryNameListSelectOption('Daily');
            List<SelectOption> countryNameList2 = bulletin_0.countryNameListSelectOption('Weekly');

            bulletin_0.applyLanguage = 'fr';
            
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            countryNameList1 = bulletin_0.countryNameListSelectOption('Daily');
            countryNameList2 = bulletin_0.countryNameListSelectOption('Weekly');

            bulletin_0.applyLanguage = 'en_US';
            countryNameList1 = bulletin_0.countryNameListSelectOption('Daily');
            countryNameList2 = bulletin_0.countryNameListSelectOption('Weekly');

System.debug('mCountries 2: ' + bulletin_0.mCountries);

            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            bulletin_0.applyLanguage = 'es';
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            bulletin_0.applyLanguage = 'fr';
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            bulletin_0.applyLanguage = 'en_US';
            
            bulletin_0.newFormDaily.Suspend_Subscription__c = true;
            PageReference pr_suspendSubscription = bulletin_0.suspendSubscription();
            bulletin_0.newFormDaily.Suspend_Subscription__c = false;
            pr_suspendSubscription = bulletin_0.suspendSubscription();

            Boolean bval = bulletin_0.validateCharactersInForm();

            try{ PageReference pr_dailyReportDownload = bulletin_0.dailyReportDownload();}catch(Exception e){}
            try{ PageReference pr_weeklyReportDownload = bulletin_0.weeklyReportDownload();}catch(Exception e){}

            PageReference pr_Nav = bulletin_0.goToStep1();
            pr_Nav = bulletin_0.goToStep1_1();
            pr_Nav = bulletin_0.goToStep1_2();
            pr_Nav = bulletin_0.goToStep2();
            pr_Nav = bulletin_0.goToStep3();
            //pr_Nav = bulletin_0.saveAMSFormAndGoSideways();
            pr_Nav = bulletin_0.saveAMSFormAndGoForward();
            pr_Nav = bulletin_0.saveAMSFormAndGoBack();
            pr_Nav = bulletin_0.saveAMSFormAndStay();

            pr_Nav = bulletin_0.securityCheck();

            String str1 = bulletin_0.getMultiSelectToSave(bulletin_0.dailyCountry);
            String str2 = bulletin_0.getMultiSelectOptionsToSave(bulletin_0.countryNameListSelectOptionDaily);

            List<SelectOption> countryNameListDaily = bulletin_0.countryNameListSelectOptionDaily;
            List<SelectOption> countryNameListWeekly = bulletin_0.countryNameListSelectOptionWeekly;

            //System.debug('dailyCountrySelected 1: ' + bulletin_0.dailyCountrySelected);

            bulletin_0.dailyCountrySelectAll = true;
            bulletin_0.weeklyCountrySelectAll = true;
            bulletin_0.dailyCountrySelectAll();
            bulletin_0.weeklyCountrySelectAll();

            List<String> lstrTest = new List<String>{'t1','t4'};

            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.weeklyCountrySelected =  bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.newFormDaily.Area_2__c = false;
            bulletin_0.newFormWeekly.Area_2__c = false;

            //System.debug('dailyCountrySelected 2: ' + bulletin_0.dailyCountrySelected);

            countryNameListDaily = bulletin_0.countryNameListSelectOptionDaily;
            countryNameListWeekly = bulletin_0.countryNameListSelectOptionWeekly;

            lstrTest = new List<String>{'t1','t3','t4'};
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.weeklyCountrySelected =  bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.newFormDaily.Area_2__c = true;
            bulletin_0.newFormWeekly.Area_2__c = true;
           

            
            CNS_EBulletin bulletin_0_2 = new CNS_EBulletin();
            PageReference pr_0_2 = bulletin_0_2.checkRedirect();

            ApexPages.currentPage().getParameters().put('step' ,'1' );
            CNS_EBulletin bulletin_1 = new CNS_EBulletin();
            //PageReference pr_saveAMSFormAndGoSideways = bulletin_1.saveAMSFormAndGoSideways();
            PageReference pr_saveAMSFormAndGoForward = bulletin_1.saveAMSFormAndGoForward();

            ApexPages.currentPage().getParameters().put('step' ,'1_1' );
            CNS_EBulletin bulletin_1_1 = new CNS_EBulletin();
            bulletin_1_1.newFormDaily.Opt_in__c = true;
            //pr_saveAMSFormAndGoSideways = bulletin_1_1.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_1_1.saveAMSFormAndGoForward();
            PageReference pr_saveAMSFormAndStay = bulletin_1_1.saveAMSFormAndStay();

            ApexPages.currentPage().getParameters().put('step' ,'1_2' );
            CNS_EBulletin bulletin_1_2 = new CNS_EBulletin();
            bulletin_1_2.newFormWeekly.Opt_in__c = true;
            //pr_saveAMSFormAndGoSideways = bulletin_1_2.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_1_2.saveAMSFormAndGoForward();
            pr_saveAMSFormAndStay = bulletin_1_2.saveAMSFormAndStay();

            ApexPages.currentPage().getParameters().put('step' ,'2' );
            CNS_EBulletin bulletin_2 = new CNS_EBulletin();
            //pr_saveAMSFormAndGoSideways = bulletin_2.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_2.saveAMSFormAndGoForward();

            ApexPages.currentPage().getParameters().put('step' ,'3' );
            CNS_EBulletin bulletin_3 = new CNS_EBulletin();
            //pr_saveAMSFormAndGoSideways = bulletin_3.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_3.saveAMSFormAndGoForward();

            ApexPages.currentPage().getParameters().put('step' ,'home' );
            CNS_EBulletin bulletin_home = new CNS_EBulletin();

            PageReference pr_home = bulletin_home.checkRedirect();
        }
        Test.stopTest();

    }
	
}