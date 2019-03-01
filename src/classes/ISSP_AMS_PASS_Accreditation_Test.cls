@isTest
private class ISSP_AMS_PASS_Accreditation_Test
{
    @testSetup static void customSettingSetup() {
        insert new ISSP_CS__c(Name = 'ISSP AMS ALLOWED AGENCY URL',Value__c = '^(http:\\/\\/|https:\\/\\/)?(www.)([a-zA-Z0-9\\-]+)([.])(([a-zA-Z]{3})|([a-zA-Z]{2}))');
        insert new ISSP_CS__c(Name = 'No Notification Email Contact Id',Value__c = null);
        insert new ISSP_AMS_Contextual_Help__c(Name='CURRENCY',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        insert new ISSP_AMS_Contextual_Help__c(Name='MIN_PAIDUP_CAPITAL',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        insert new ISSP_AMS_Contextual_Help__c(Name='REGISTERED_CAPITAL',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        insert new ISSP_AMS_Contextual_Help__c(Name='PAIDUP_CAPITAL',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        insert new ISSP_AMS_Contextual_Help__c(Name='TAX_NUMBER',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        insert new ISSP_AMS_Contextual_Help__c(Name='AUTHORISED_SIG',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        insert new ISSP_AMS_Contextual_Help__c(Name='FIN_CONTACT',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        insert new ISSP_AMS_Contextual_Help__c(Name='PORTAL_ADMIN',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        insert new ISSP_AMS_Contextual_Help__c(Name='GROSS_SALES',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        insert new ISSP_AMS_Contextual_Help__c(Name='TRAINED_STAFF_ORGANIZATION',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        insert new ISSP_AMS_Contextual_Help__c(Name='TRAINED_STAFF_REFERENCE',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        insert new ISSP_AMS_Contextual_Help__c(Name='GROSS_SALES',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
    
    }

    @isTest static void ISSP_AMS_PASS_Accreditation_Test_1()
    {
        List<Account> accountList= new List<Account>();
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id;


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.Email__c='';
        accountList.add(parent);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.Email__c='';
        accountList.add(child);

        Account iatanAccount = ISSP_ObjectFactory.createNewAccount();
        iatanAccount.BillingCity = 'test2';
        iatanAccount.Name = 'test2';
        iatanAccount.Site = 'headSite';
        iatanAccount.sector__c = AMS_Utils.SECTOR_PASSENGER;
        iatanAccount.Top_Parent__c = parent.Id;
        iatanAccount.IATA_ISO_Country__c = country.Id;
        iatanAccount.RecordTypeId = rtIdBr ;
        iatanAccount.Email__c='';
        iatanAccount.Category__c =AMS_UTILS.IATAN_PASSENGER_AGENT;
        iatanAccount.IATACode__c = '100';
        accountList.add(iatanAccount);

        Account agentAccount = ISSP_ObjectFactory.createNewAccount();
        agentAccount.BillingCity = 'test2';
        agentAccount.Name = 'test2';
        agentAccount.Site = 'headSite';
        agentAccount.sector__c = 'Travel Agent';
        agentAccount.Top_Parent__c = parent.Id;
        agentAccount.IATA_ISO_Country__c = country.Id;
        agentAccount.RecordTypeId = rtIdBr ;
        agentAccount.Email__c='';
        agentAccount.IATACode__c = '100';
        accountList.add(agentAccount);

        insert accountList;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser)
        {
            //Case testCase = (Case)ISSP_ObjectFactory.createSObject('Case',false,1);
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = true;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            testCase.Region__c='Europe';
            testCase.Reason1__c=AMS_Utils.CASE_REASON_NEW_HO;
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            newForm.ISSP_AMS_Legal_Status__c ='';
            insert newForm ;

            AMS_Accreditation_Contact__c testAccContact=new AMS_Accreditation_Contact__c();
            testAccContact.AMS_Pax_Accreditation_Form__c=newForm.id;
            testAccContact.PASS_contact__c  =true;
            testAccContact.Authorised_signatory__c=true;
            testAccContact.Financial_interest__c=50;
            testAccContact.Legacy_External_Id__c = 'test';
            testAccContact.Last_name__c = 'Last_name';
            testAccContact.Agencies_prev_worked_for__c ='2';
            insert testAccContact;

            newForm.ISSP_AMS_Portal_admin__c =testAccContact.id;
            update newForm ;

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ISSP_AMS_PASS_Accreditation test = new ISSP_AMS_PASS_Accreditation();
            test.newCase = testCase ;
            test.contactType='Company';
            test.iatacode='';
            test.getnewlabels();
            test.save();
            test.cancel();
            test.getBranchAccounts();
            test.updateAmsCountry();
            test.createBranchAccount();
            test.createAgencyContact();
            test.securityCheck();
            test.cancelAgentUpdate();
            test.cancelAccountUpdate();
            test.goToStep1();
            test.goToStep2();
            test.goToStep3();
            test.goToStep3Section1();
            test.goToStep3Section2();
            test.goToStep3Section3();
            test.goToStep3Section4();
            test.goToStep3Section5();
            test.goToStep3Section6();
            test.goToStep3Section7();
            test.goToStep3Section8();
            test.goToStep4();
            test.goToStep5();
            test.highLightPageForErrors();
            test.saveAMSFormAndGoForward();
            test.saveAMSFormAndGoToStep5();
            test.saveAMSFormAndGoBack();
            test.saveAMSFormAndGoToStep1();
            test.saveAMSFormAndLeave();
            test.validateCharactersInForm();
            test.sendConfirmationEmail(testCase);
            test.resetOwnership();
            test.resetCreatedOwnership();
            test.createListOfClosedStatuses();
            test.getIsEmpty();
            test.getIsNotEmpty();
            test.getAMSDraftCases();
            test.getIsEmptySumbittedCases();
            test.getAMSSubmittedCases();
            test.CheckCountryReqments();
            test.setPageLegalStatusAfterChangeLabels();
            test.checkEligibilityForAChange();
            test.getPrevWorkedForItems();
            test.validateDangerousGoods(5);
            test.getRegionalQueue();
            test.redirectToPDF();
            test.cancelTrainedStaff();
            test.redirectToCasePage();
            test.redirectToCountryRequirementPage();
            test.setOwners('type');
            test.runOptInOut();
            test.checkLegalStatus();

            test.isNoticeOfChange=true;
            test.goToStep1();
            test.goToStep2();
            test.goToStep3();
            test.goToStep3Section1();
            test.goToStep3Section2();
            test.goToStep3Section3();
            test.goToStep3Section4();
            test.goToStep3Section5();
            test.goToStep3Section6();
            test.goToStep3Section7();
            test.goToStep3Section8();
            test.goToStep4();
            test.goToStep5();

            test.isEUCountry=true;
            test.vatNumber='12345';
            test.validateVATNumber();

            test.contactType='';
            test.sector=AMS_Utils.SECTOR_PASSENGER;
            test.createAgencyContact();

            test.iatanAccount = AMS_UTILS.IATAN_PASSENGER_AGENT;
            test.fetchIATANDetails();
            test.fetchAgentDetails();
        }
        Test.stopTest();
    }

    @isTest static void ISSP_AMS_PASS_Accreditation_Test_2()
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id;


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
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

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser)
        {
            //Case testCase = (Case)ISSP_ObjectFactory.createSObject('Case',false,1);
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = true;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );

            ApexPages.currentPage().getParameters().put('step' ,'2');
            ISSP_AMS_PASS_Accreditation testStep2 = new ISSP_AMS_PASS_Accreditation();

            testStep2.txtHelpCurrency='';
            testStep2.txtHelpMinPaidCapital='';
            testStep2.txtHelpRegisteredCapital='';
            testStep2.txtHelpPaidUpCapital='';
            testStep2.txtHelpTaxNumber='';
            testStep2.txtHelpAuthorisedSig='';
            testStep2.txtHelpFinContact='';
            testStep2.txtHelpPortalAdmin='';
            testStep2.txtHelpGrossSales='';
            testStep2.txtHelpTrainedStaffOrganization='';
            testStep2.txtHelpTrainedStaffReference='';
            testStep2.lblStep1Title='';
            testStep2.PDFPerRegionCS=null;
            testStep2.isGSAList =null;
            testStep2.itemsYesNo =null;
            testStep2.salesSaved =null;
            testStep2.passedFormValidation =null;
            testStep2.formUpdated =null;
            testStep2.fileBody =null;
            testStep2.fileName  ='';
            testStep2.lblEACPTitle ='';
            testStep2.consignments ='';
            testStep2.isleased ='';
            testStep2.issubcontractor ='';
            testStep2.facilitiesId =null;
            testStep2.facilityInContext =null;
            testStep2.facilityRecordTypeName ='';
            testStep2.agencyCodesConcernedForPDF ='';
            testStep2.accredidationType ='';
            testStep2.pEfectiveDateStr='';
             

            testStep2.getAmsAllLangCountryLabel(country,'es');
            testStep2.getAmsAllLangCountryLabel(country,'fr');
            testStep2.getAmsAllLangCountryLabel(country,'it');
            testStep2.getAmsAllLangCountryLabel(country,'pt_BR');
            testStep2.getAmsAllLangCountryLabel(country,'ko');
            testStep2.getAmsAllLangCountryLabel(country,'zh_CN');
            testStep2.getAmsAllLangCountryLabel(country,'ja');
            testStep2.getAmsAllLangCountryLabel(country,'test');
            testStep2.getAmsAllLangCountryLabel(country,null);

            testStep2.legalStatus='association';
            testStep2.legalStatusAfterChange='association';
            testStep2.setPageLegalStatusLabels();
            testStep2.setPageLegalStatusAfterChangeLabels();

            testStep2.legalStatus='co-operative';
            testStep2.legalStatusAfterChange='co-operative';
            testStep2.setPageLegalStatusLabels();
            testStep2.setPageLegalStatusAfterChangeLabels();

            ApexPages.currentPage().getParameters().put('step' ,'3');

            newForm.IATAN_Code__c = '123';
            update newForm;

            ISSP_AMS_PASS_Accreditation testStep3 = new ISSP_AMS_PASS_Accreditation();

            ApexPages.currentPage().getParameters().put('step' ,'4');
            ISSP_AMS_PASS_Accreditation testStep4 = new ISSP_AMS_PASS_Accreditation();

            ApexPages.currentPage().getParameters().put('step' ,'5');
            ISSP_AMS_PASS_Accreditation testStep5 = new ISSP_AMS_PASS_Accreditation();

            ApexPages.currentPage().getParameters().put('step' ,'6');
            ISSP_AMS_PASS_Accreditation testStep6 = new ISSP_AMS_PASS_Accreditation();
        }

        Test.stopTest();
    }

    @isTest static void ISSP_AMS_PASS_Accreditation_Test_3()
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id;


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.IATA_ISO_Country__c = country.Id;
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Person__c testAMSPerson= new AMS_Person__c();
        insert testAMSPerson;

        AMS_Account_Role__c testAccountRole=new AMS_Account_Role__c();
        testAccountRole.Account__c=parent.Id;
        testAccountRole.RecordTypeId =Schema.SObjectType.AMS_Account_Role__c.getRecordTypeInfosByName().get('Ownership').getRecordTypeId();
        testAccountRole.Percentage__c =50;
        testAccountRole.Legacy_External_ID__c='';
        testAccountRole.Contact__c=con.id;
        testAccountRole.Person__c =testAMSPerson.id;
        testAccountRole.Owner_Account__c =parent.id;
        insert testAccountRole;

        Test.startTest();
        System.runAs(newUser)
        {

            ISSP_AMS_PASS_Accreditation test = new ISSP_AMS_PASS_Accreditation();
            test.save();

            test.amsLocationType=AMS_Utils.TYPE_PAX_PASS_HO;
            test.save();

            Case duplicatedCase=test.newCase.clone(false, true, false, false);
            insert duplicatedCase;
            test.save();


            List<AMS_Accreditation_Contact__c> testAccContact=test.trainedStaffList;
            testAccContact=test.List_AgencyContacts;
            testAccContact=test.List_IFAPAgencyContacts;
            testAccContact=test.List_PreviousOwners;
            testAccContact=test.List_CurrentOwners;
            testAccContact=test.List_CurrentCompanies;
            testAccContact=test.List_PreviousCompanies;
            testAccContact=test.List_AgencyCompanies;
            testAccContact=test.List_Ownership_Summary;
            testAccContact=test.List_Curr_Ownership_Summary;
            testAccContact=test.List_Prev_Ownership_Summary;
            List<ISSP_AMS_Statement_International_Sales__c> testListInternationalSales=test.List_InternationalSales;
            Double testDouble=test.Ownership_Total;
            testDouble=test.Curr_Ownership_Total;
            testDouble=test.Prev_Ownership_Total;
            Decimal testDecimal=test.InternationalSales_Total;
            testDecimal=test.InternationalCharges_Collected_Total;
            testDecimal=test.InternationalPrepaid_Collected_Total;
            ApexPages.StandardSetController standardSetControllerTest= test.setConn;
            standardSetControllerTest=test.setConnNotDraft;
            boolean testBoolean=test.openHQCaseExists;
            String testString=test.pageLanguage;
            ISSP_AMS_PASS_Accreditation.AccountChanges testAccountChanges=new ISSP_AMS_PASS_Accreditation.AccountChanges('accountFieldAPI','oldValue','newValue');
            String portalLoginTest=test.Portal_Login_URL;
            AMS_Accreditation_Country_CheckList__c testCountryChecklist= test.CountryCheckList;
        }

        Test.stopTest();
    }

    @isTest static void ISSP_AMS_PASS_Accreditation_Test_4()
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id;


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.IATA_ISO_Country__c = country.Id;
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
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

            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = true;
            testCase.Account_Concerned__c = parent.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c=testCase.Id;
            newForm.IATAN_Code__c='';
            insert newForm ;

            ISSP_AMS_PASS_Accreditation test = new ISSP_AMS_PASS_Accreditation();

            Account testAccount = ISSP_ObjectFactory.createNewAccount();
            testAccount.Website='';
            testAccount.BillingCountry='';
            testAccount.BillingPostalCode='';
            testAccount.BillingCity='';
            testAccount.BillingStreet='';
            testAccount.TradeName__c='';
            testAccount.Name='testName';
            insert testAccount;
            test.hqAccount=testAccount;
            test.validateCharactersInAgencyWindow();

            AMS_Accreditation_Contact__c testContact= new AMS_Accreditation_Contact__c();
            testContact.First_name__c = '';
            testContact.Last_name__c = 'Last_name';
            testContact.AddressStreet__c  = '';
            testContact.AddressCity__c  = '';
            testContact.AddressPostcode__c  = '';
            testContact.Job_title__c  = '';
            testContact.Agencies_prev_worked_for__c  = '';
            testContact.Prev_Job1_Employer__c= '';
            testContact.Prev_Job1_Position__c= '';
            testContact.Prev_Job1_Address__c= '';
            testContact.Prev_Job2_Position__c= '';
            testContact.Prev_Job2_Address__c= '';
            testContact.Registration_number__c= '';
            testContact.Name = 'test_';
            testContact.Legacy_External_Id__c = 'test';
            testContact.AMS_Pax_Accreditation_Form__c=newform.id;
            insert testContact;
            test.newContact=testContact;
            test.validateCharactersInPersonWindow();
            test.validateCharactersInCompanyWindow();

            newForm.ISSP_AMS_where_incorporated__c='';
            newForm.ISSP_AMS_Principal_business_Org__c='';
            newForm.ISSP_AM_Means_Identified_Travel_Agency__c='';
            newForm.ISSP_AMS_Prev_default_explanation__c='';
            newForm.Account_Name__c='Я';
            newForm.Trade_Name__c='Я';
            newForm.ISSP_AMS_License_No__c='Я';
            newForm.ISSP_AMS_Trade_Reg_No__c='Я';
            newForm.Branch_Office_Street_name_number__c='Я';
            newForm.Branch_Office_City__c='Я';
            newForm.Branch_Office_Postal_code__c='Я';
            newForm.State_Province__c='Я';
            newForm.ISSP_AMS_VAT_Number_Input__c='Я';
            newForm.ISSP_AMS_VAT_number__c='Я';
            newForm.Shipping_Street__c='Я';
            newForm.Shipping_City__c='Я';
            newForm.Shipping_State__c='Я';
            newForm.Shipping_Country__c='Я';
            newForm.Shipping_Postal_Code__c='Я';
            newForm.State_Province__c ='Я';
            newForm.Branch_Office_Email__c ='';
            newForm.State_Province__c ='';
            newForm.ISSP_AMS_Online_Agency_URL__c ='';
            newForm.ISSP_AMS_Legal_Reg_Name_Address__c ='';
            update newForm;

            test.newForm=newForm;
            test.validateCharactersInForm();
        }

        Test.stopTest();
    }

    @isTest static void ISSP_AMS_PASS_Accreditation_Test_5()
    {

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'Standard_Account'][0].Id;


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.Email__c='';
        parent.IATA_ISO_Country__c = country.Id;
        parent.Reason_for_creation__c='test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        AMS_OSCAR__c oscarTest= new AMS_OSCAR__c();
        oscarTest.Account__c=parent.id;
        insert oscarTest;

        Test.startTest();
        System.runAs(newUser)
        {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = parent.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            testCase.Region__c='Europe';
            testCase.Reason1__c=AMS_Utils.CASE_REASON_NEW_HO;
            testCase.RecordTypeId= Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;
            insert testCase;

            Case testOscarCase = ISSP_ObjectFactory.createNewCase();
            testOscarCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testOscarCase.Status = 'Open - EDMC';
            testOscarCase.Customer_recovery__c = false;
            testOscarCase.BounceEmailCounter__c = 0.0;
            testOscarCase.Case_Language__c = 'English';
            testOscarCase.Subject = 'Test 006';
            testOscarCase.Reopened_case__c = 0.0;
            testOscarCase.Account_Concerned__c = parent.Id;
            testOscarCase.IFAP_Country_ISO__c = 'tq';
            testOscarCase.Region__c='Europe';
            testOscarCase.Reason1__c=AMS_Utils.CASE_REASON_NEW_HO;
            testOscarCase.RecordTypeId= Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;
            testOscarCase.OSCAR__c=oscarTest.id;
            insert testOscarCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            newForm.ISSP_AMS_Legal_Status__c ='State Owned Enterprise';
            newForm.Account_Name__c ='';
            newForm.Operation_Type__c=AMS_Utils.sectorValuePass;
            newForm.Accept_terms_and_conditions__c=true;
            newForm.Solicitation_Flag__c=false;
            insert newForm ;

            AMS_Accreditation_Contact__c testAccContact=new AMS_Accreditation_Contact__c();
            testAccContact.AMS_Pax_Accreditation_Form__c=newForm.id;
            testAccContact.PASS_contact__c  =true;
            testAccContact.Authorised_signatory__c=true;
            testAccContact.Financial_interest__c=50;
            testAccContact.Legacy_External_Id__c = 'test';
            testAccContact.Last_name__c = 'Last_name';
            insert testAccContact;

            newForm.ISSP_AMS_Portal_admin__c =testAccContact.id;
            update newForm ;

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ISSP_AMS_PASS_Accreditation test = new ISSP_AMS_PASS_Accreditation();
            test.newCase = testCase ;
            

            Account testAccount = ISSP_ObjectFactory.createNewAccount();
            testAccount.Website='';
            testAccount.BillingCountry='';
            testAccount.BillingPostalCode='';
            testAccount.BillingCity='BillingCity';
            testAccount.BillingStreet='BillingStreet';
            testAccount.TradeName__c='';
            testAccount.Name='testName';
            testAccount.Email__c='';
            testAccount.Solicitation_Flag__c=false;
            insert testAccount;
            test.hqAccount=testAccount;

            test.goToFinalStep();

            List<AMS_Accreditation_Requirement__c> listCountryRequirements=new List<AMS_Accreditation_Requirement__c>();

            AMS_Accreditation_Country_CheckList__c accCountryChecklistTest=new AMS_Accreditation_Country_CheckList__c();
            accCountryChecklistTest.IATA_ISO_Country__c=country.id;
            insert accCountryChecklistTest;

            AMS_Accreditation_Requirement__c accRequirementTest=new AMS_Accreditation_Requirement__c();
            accRequirementTest.AMS_Accreditation_Country_CheckList__c=accCountryChecklistTest.id;
            accRequirementTest.File_to_Upload__c='Mandatory';
            accRequirementTest.Location_type__c='HO';
            accRequirementTest.File_Identifier2__c='CGO_SIGNED_CONTRACT';
            listCountryRequirements.add(accRequirementTest);
            test.List_CountryReqments=listCountryRequirements;
            test.goToFinalStep();
        }
        Test.stopTest();
    }

    @isTest static void ISSP_AMS_PASS_Accreditation_Test_6()
    {

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test',Local_language_Agency_details_required__c=true);
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes',Local_language_Agency_details_required__c=true);
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'Standard_Account'][0].Id;


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.Email__c='';
        parent.IATA_ISO_Country__c = country.Id;
        parent.Reason_for_creation__c='test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        AMS_OSCAR__c oscarTest= new AMS_OSCAR__c();
        oscarTest.Account__c=parent.id;
        insert oscarTest;

        Test.startTest();
        System.runAs(newUser)
        {

            Case testOscarCase = ISSP_ObjectFactory.createNewCase();
            testOscarCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testOscarCase.Status = 'Open - EDMC';
            testOscarCase.Customer_recovery__c = false;
            testOscarCase.BounceEmailCounter__c = 0.0;
            testOscarCase.Case_Language__c = 'English';
            testOscarCase.Subject = 'Test 006';
            testOscarCase.Reopened_case__c = 0.0;
            testOscarCase.Account_Concerned__c = parent.Id;
            testOscarCase.IFAP_Country_ISO__c = 'tq';
            testOscarCase.Region__c='Europe';
            testOscarCase.Reason1__c=AMS_Utils.CASE_REASON_NEW_HO;
            testOscarCase.RecordTypeId= Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;
            testOscarCase.OSCAR__c=oscarTest.id;
            insert testOscarCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testOscarCase.Id;
            newForm.ISSP_AMS_Legal_Status__c ='State Owned Enterprise';
            newForm.Account_Name__c ='';
            newForm.Operation_Type__c=AMS_Utils.sectorValuePass;
            newForm.Accept_terms_and_conditions__c=true;
            newForm.Solicitation_Flag__c=false;
            insert newForm ;

            ApexPages.currentPage().getParameters().put('caseId' ,testOscarCase.Id );
            ISSP_AMS_PASS_Accreditation test = new ISSP_AMS_PASS_Accreditation();
            test.newCase = testOscarCase ;

            test.goToFinalStep();
        }
        Test.stopTest();
    }

    @isTest static void ISSP_AMS_PASS_Accreditation_Test_7()
    {

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test',Local_language_Agency_details_required__c=true);
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes',Local_language_Agency_details_required__c=true);
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'Standard_Account'][0].Id;


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.Email__c='';
        parent.IATA_ISO_Country__c = country.Id;
        parent.Reason_for_creation__c='test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        AMS_OSCAR__c oscarTest= new AMS_OSCAR__c();
        oscarTest.Account__c=parent.id;
        insert oscarTest;

        Test.startTest();
        System.runAs(newUser)
        {

            Case testOscarCase = ISSP_ObjectFactory.createNewCase();
            testOscarCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testOscarCase.Status = 'Open - EDMC';
            testOscarCase.Customer_recovery__c = false;
            testOscarCase.BounceEmailCounter__c = 0.0;
            testOscarCase.Case_Language__c = 'English';
            testOscarCase.Subject = 'Test 006';
            testOscarCase.Reopened_case__c = 0.0;
            testOscarCase.Account_Concerned__c = parent.Id;
            testOscarCase.IFAP_Country_ISO__c = 'tq';
            testOscarCase.Region__c='Europe';
            testOscarCase.Reason1__c=AMS_Utils.CASE_REASON_NEW_HO;
            testOscarCase.RecordTypeId= Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;
            testOscarCase.OSCAR__c=oscarTest.id;
            insert testOscarCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testOscarCase.Id;
            newForm.ISSP_AMS_Legal_Status__c ='State Owned Enterprise';
            newForm.Account_Name__c ='';
            newForm.Operation_Type__c=AMS_Utils.sectorValuePass;
            newForm.Accept_terms_and_conditions__c=true;
            newForm.Solicitation_Flag__c=false;
            insert newForm ;

            ApexPages.currentPage().getParameters().put('caseId' ,testOscarCase.Id );
            ISSP_AMS_PASS_Accreditation test = new ISSP_AMS_PASS_Accreditation();
            test.newCase = testOscarCase ;

            test.amsOfficeType='Branch';
            test.goToFinalStep();
        }
        Test.stopTest();
    }

    @isTest static void ISSP_AMS_PASS_Accreditation_Test_8()
    {

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'Standard_Account'][0].Id;


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.Email__c='';
        parent.IATA_ISO_Country__c = country.Id;
        parent.Reason_for_creation__c='test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
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

            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Status = 'Open - EDMC';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = parent.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            testCase.Region__c='Europe';
            testCase.Reason1__c=AMS_Utils.CASE_REASON_NEW_HO;
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            newForm.ISSP_AMS_Legal_Status__c ='State Owned Enterprise';
            newForm.Account_Name__c ='';
            newForm.Operation_Type__c=AMS_Utils.sectorValuePass;
            newForm.Accept_terms_and_conditions__c=true;
            newForm.Solicitation_Flag__c=false;
            insert newForm ;

            AMS_Accreditation_Contact__c testAgencyContact=new AMS_Accreditation_Contact__c();
            testAgencyContact.AMS_Pax_Accreditation_Form__c=newForm.id;
            testAgencyContact.PASS_contact__c  =true;
            testAgencyContact.Authorised_signatory__c=true;
            testAgencyContact.Financial_interest__c=50;
            testAgencyContact.Legacy_External_Id__c = 'test';
            testAgencyContact.Last_name__c = 'Last_name';
            insert testAgencyContact;

            AMS_Accreditation_Contact__c testTrainedStaffContact=new AMS_Accreditation_Contact__c();
            testTrainedStaffContact.AMS_Pax_Accreditation_Form__c=newForm.id;
            testTrainedStaffContact.PASS_contact__c  =true;
            testTrainedStaffContact.Authorised_signatory__c=true;
            testTrainedStaffContact.Financial_interest__c=50;
            testTrainedStaffContact.Legacy_External_Id__c = 'test';
            testTrainedStaffContact.Last_name__c = 'Last_name';
            insert testTrainedStaffContact;

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ISSP_AMS_PASS_Accreditation test = new ISSP_AMS_PASS_Accreditation();
            test.newCase = testCase ;

            test.editContactId=testAgencyContact.id;
            test.trainedStaffId=testTrainedStaffContact.id;

            test.editAgencyContact();
            test.updateAgencyDetails();
            test.deleteTrainedStaff();
            test.deleteAgencyContact();
        }
        Test.stopTest();
    }

    @isTest static void ISSP_AMS_PASS_Accreditation_Test_9()
    {

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes',EACP_Country__c=true);
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'Standard_Account'][0].Id;


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.Email__c='';
        parent.IATA_ISO_Country__c = country.Id;
        parent.Reason_for_creation__c='test';
        parent.Sector__c=AMS_Utils.SECTOR_PASS;
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
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

            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Status = 'Open - EDMC';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = parent.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            testCase.Region__c='Europe';
            testCase.Reason1__c=AMS_Utils.CASE_REASON_NEW_HO;
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            newForm.ISSP_AMS_Legal_Status__c ='State Owned Enterprise';
            newForm.Account_Name__c ='';
            newForm.Operation_Type__c=AMS_Utils.sectorValuePass;
            newForm.Accept_terms_and_conditions__c=true;
            newForm.Solicitation_Flag__c=false;
            newForm.Is_your_firm_handling_Dangerous_Goods__c='No';
            insert newForm ;

            AMS_Accreditation_Contact__c testAgencyContact=new AMS_Accreditation_Contact__c();
            testAgencyContact.AMS_Pax_Accreditation_Form__c=newForm.id;
            testAgencyContact.PASS_contact__c  =true;
            testAgencyContact.Authorised_signatory__c=true;
            testAgencyContact.Financial_interest__c=50;
            testAgencyContact.Legacy_External_Id__c = 'test';
            testAgencyContact.Last_name__c = 'Last_name';
            testAgencyContact.Agency_owner__c =true;
            insert testAgencyContact;

            AMS_Accreditation_Contact__c testTrainedStaffContact=new AMS_Accreditation_Contact__c();
            testTrainedStaffContact.AMS_Pax_Accreditation_Form__c=newForm.id;
            testTrainedStaffContact.PASS_contact__c  =true;
            testTrainedStaffContact.Authorised_signatory__c=true;
            testTrainedStaffContact.Financial_interest__c=50;
            testTrainedStaffContact.Legacy_External_Id__c = 'test';
            testTrainedStaffContact.Last_name__c = 'Last_name';
            testTrainedStaffContact.Agencies_prev_worked_for__c='';
            insert testTrainedStaffContact;

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ISSP_AMS_PASS_Accreditation test = new ISSP_AMS_PASS_Accreditation();
            test.newCase = testCase ;

            test.editContactId=testAgencyContact.id;
            test.trainedStaffId=testTrainedStaffContact.id;

            test.newContact=testTrainedStaffContact;
            test.contactType='Trained Staff';
            test.isoCountry=country2;
            test.sector=AMS_Utils.SECTOR_PASSENGER;
            test.createAgencyContact();

            testTrainedStaffContact.Agencies_prev_worked_for__c='2';
            update testTrainedStaffContact;
            test.newContact=testTrainedStaffContact;
            test.createAgencyContact();

            newForm.Is_your_firm_handling_Dangerous_Goods__c='Yes';
            update newForm;
            test.newForm=newForm;
            testTrainedStaffContact.Training_dangerous_goods_completed__c = 'Yes';
            update testTrainedStaffContact;
            test.trainedStaffContact=testTrainedStaffContact;
            test.createAgencyContact();


            test.contactType='Company';
            test.createAgencyContact();

            test.contactType='Person';
            test.createAgencyContact();

            Case testCase2 = ISSP_ObjectFactory.createNewCase();
            testCase2.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase2.Status='On Hold_External';
            insert testCase2;

            test.newCase = testCase2;
            test.securityCheck();

            Case testCase3 = ISSP_ObjectFactory.createNewCase();
            testCase3.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase3.Status='Closed_Disapproved';
            insert testCase3;

            test.newCase = testCase3;
            test.securityCheck();
        }
        Test.stopTest();
    }

    @isTest static void ISSP_AMS_PASS_Accreditation_Test_10()
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id;


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.IATA_ISO_Country__c = country.Id;
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
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

            ISSP_AMS_PASS_Accreditation test = new ISSP_AMS_PASS_Accreditation();
            test.save();

            List<Case> caseList=new List<Case>();

            Case testCase1 = ISSP_ObjectFactory.createNewCase();
            testCase1.Reason1__c = 'FoP Management';
            testCase1.origin = 'Massive FOP Creation';
            caseList.add(testCase1);

            Case testCase2 = ISSP_ObjectFactory.createNewCase();
            testCase2.BSPCountry__c = null;
            caseList.add(testCase2);

            Case testCase3 = ISSP_ObjectFactory.createNewCase();
            testCase3.BSPCountry__c = 'Spain';
            caseList.add(testCase3);

            Case testCase4 = ISSP_ObjectFactory.createNewCase();
            testCase4.BSPCountry__c = 'France';
            caseList.add(testCase4);

            Case testCase5 = ISSP_ObjectFactory.createNewCase();
            testCase5.BSPCountry__c = 'Canada';
            caseList.add(testCase5);

            Case testCase6 = ISSP_ObjectFactory.createNewCase();
            testCase6.Region__c = 'Americas';
            testCase6.BSPCountry__c = 'Argentina';
            caseList.add(testCase6);

            Case testCase7 = ISSP_ObjectFactory.createNewCase();
            testCase7.Region__c = 'China';
            testCase7.BSPCountry__c = 'China';
            caseList.add(testCase7);

            Case testCase8 = ISSP_ObjectFactory.createNewCase();
            testCase8.Region__c = 'Africa';
            testCase8.BSPCountry__c = 'South Africa';
            caseList.add(testCase8);
            
            test.sendConfirmationEmail(testCase1);
            test.sendConfirmationEmail(testCase2);
            test.sendConfirmationEmail(testCase3);
            test.sendConfirmationEmail(testCase4);
            test.sendConfirmationEmail(testCase5);
            test.sendConfirmationEmail(testCase6);
            test.sendConfirmationEmail(testCase7);
            test.sendConfirmationEmail(testCase8);
        }

        Test.stopTest();
    }

    @isTest static void ISSP_AMS_PASS_Accreditation_Test_11()
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id;


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.IATA_ISO_Country__c = country.Id;
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        Account testAccount = ISSP_ObjectFactory.createNewAccount();
        testAccount.BillingCity = 'test';
        testAccount.Name = 'test';
        testAccount.sector__c = 'Travel Agent';
        testAccount.Category__c=AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT;
        testAccount.ANG_Accreditation_Model__c=AMS_Utils.ACCREDITATIONMODEL_CASH;
        testAccount.ANG_FA_Opt_out__c=true;
        testAccount.Email__c='';
        testAccount.Reason_for_creation__c='New agent';
        insert testAccount;

        Account testAccount2 = ISSP_ObjectFactory.createNewAccount();
        testAccount2.BillingCity = 'test';
        testAccount2.Name = 'test';
        testAccount2.sector__c = 'Travel Agent';
        testAccount2.Category__c=AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT;
        testAccount2.ANG_Accreditation_Model__c=AMS_Utils.ACCREDITATIONMODEL_CASH;
        testAccount2.ANG_FA_Opt_out__c=false;
        testAccount2.Email__c='';
        testAccount2.Reason_for_creation__c='New agent';
        insert testAccount2;
        
        Test.startTest();
        System.runAs(newUser)
        {

            ISSP_AMS_PASS_Accreditation test = new ISSP_AMS_PASS_Accreditation();
            test.save();

            test.getRegionalQueue();

            test.con.Account=testAccount;
            test.isHOAccredited=true;
            test.isHOcontact=true;
            test.sector=AMS_Utils.SECTOR_PASSENGER;

            test.getAMSDraftCases();

            test.con.Account=testAccount2;
            test.getAMSDraftCases();
        }

        Test.stopTest();
    }
}