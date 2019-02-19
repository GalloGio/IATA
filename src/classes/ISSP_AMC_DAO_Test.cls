/*
    Class Name: ISSP_AMC_ParticipationFactory_Test.cls
    Related Classes: ISSP_AMC_ParticipationFactory.cls

    Copyright @Right IT Services

    Purpose: Test class for Participation Factory

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         DAVID BENTO & TIAGO MENDES    31-12-2018              INITIAL DEVELOPMENT
*/

/*

NOTE : To achieve the correct code coverage for the class ISSP_AMC_DAO, run also this class tests:
    - ISSP_AMC_Baggage_Tag_Rance_Test.cls
    - ISSP_AMC_Location_Identifier_Test.cls
    - ISSP_AMC_Airline_Designator_Test.cls
    - ISSP_AMC_Accounting_Or_Prefix_Code_Test.cls
    - Part_Online_App_ReqTriggerHandler_Test
        - 

*/
@isTest
public with sharing class ISSP_AMC_DAO_Test {

    public static User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];



    /*
        Purpose: Change the language of the user multipler times acessing the portal
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
  @isTest public static  void languageTest()
    {


        Test.StartTest();
            System.runAs(myUser)
            {
                User user1 = ISSP_AMC_ParticipationFactory.portalSetup();       
                System.runAs(user1){
                    PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
                    Test.setCurrentPageReference(pageRef);
                    pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY).Id);
                    ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
                    //ISSP_AMC_DAO controller = new ISSP_AMC_DAO();
                    List <SelectOption> testLangOptions;


                    List<IATA_ISO_Country__c> countryList = new List<IATA_ISO_Country__c>();
                    // create iso country
                    IATA_ISO_Country__c iso_country1 = new IATA_ISO_Country__c (
                        name='Brazil',
                        ISO_Code__c ='PT',
                        ISO_Code_Numeric__c=1,
                        IATA_Country_PT__c = 'PT',
                        Case_BSP_Country__c = 'Portugal',
                        currencyIsoCode = 'USD');
                    countryList.add(iso_country1);

                                // create iso country
                    IATA_ISO_Country__c iso_country2 = new IATA_ISO_Country__c (
                        name='United zh_CN',
                        ISO_Code__c ='CN',
                        ISO_Code_Numeric__c=3,
                        IATA_Country_ZH__c = 'CN',
                        Case_BSP_Country__c = 'Honduras',
                        currencyIsoCode = 'USD');
                    countryList.add(iso_country2);

                    // create iso country
                    IATA_ISO_Country__c iso_country3 = new IATA_ISO_Country__c (
                        name='United es',
                        ISO_Code__c ='es',
                        ISO_Code_Numeric__c=2,
                        IATA_Country_SP__c = 'es',
                        Case_BSP_Country__c = 'India',
                        currencyIsoCode = 'USD');
                    countryList.add(iso_country3);

                                // create iso country
                    IATA_ISO_Country__c iso_country4 = new IATA_ISO_Country__c (
                        name='Udfs',
                        ISO_Code__c ='ko',
                        ISO_Code_Numeric__c=4,
                        IATA_Contry_KR__c = 'ko',
                        Case_BSP_Country__c = 'Iraq',
                        currencyIsoCode = 'USD');
                    countryList.add(iso_country4);

                    // create iso country
                    IATA_ISO_Country__c iso_country5 = new IATA_ISO_Country__c (
                        name='United States',
                        ISO_Code__c ='FR',
                        ISO_Code_Numeric__c=5,
                        IATA_Country_FR__c = 'FR',
                        Case_BSP_Country__c = 'Jamaica',
                        currencyIsoCode = 'USD');
                    countryList.add(iso_country5);

                                // create iso country
                    /*IATA_ISO_Country__c iso_country6 = new IATA_ISO_Country__c (
                        name='United States',
                        ISO_Code__c ='US',
                        ISO_Code_Numeric__c=1,
                        currencyIsoCode = 'USD');
                    countryList.add(iso_country6);*/

                    // create iso country
                    IATA_ISO_Country__c iso_country7 = new IATA_ISO_Country__c (
                        name='United JP',
                        ISO_Code__c ='JP',
                        ISO_Code_Numeric__c=7,
                        IATA_Country_JP__c = 'JP',
                        Case_BSP_Country__c = 'Japan',
                        currencyIsoCode = 'USD');
                    countryList.add(iso_country7);

                                // create iso country
                    IATA_ISO_Country__c iso_country8 = new IATA_ISO_Country__c (
                        name='United IT',
                        ISO_Code__c ='IT',
                        ISO_Code_Numeric__c=8,
                        IATA_Country_IT__c = 'IT',
                        Case_BSP_Country__c = 'Kenya',
                        currencyIsoCode = 'USD');
                    countryList.add(iso_country8);

                    insert countryList;


                    user1.LanguageLocaleKey = 'pt_BR';
                    update user1;
                    testLangOptions = ISSP_AMC_DAO.countryList;
                    ISSP_AMC_Airline_Designators controller1 = new ISSP_AMC_Airline_Designators();
                    user1.LanguageLocaleKey = 'zh_CN';
                    update user1;
                    testLangOptions = ISSP_AMC_DAO.countryList;
                    ISSP_AMC_Airline_Designators controller2 = new ISSP_AMC_Airline_Designators();
                    user1.LanguageLocaleKey = 'fr';
                    update user1;
                    testLangOptions = ISSP_AMC_DAO.countryList;
                    ISSP_AMC_Airline_Designators controller3 = new ISSP_AMC_Airline_Designators();
                    user1.LanguageLocaleKey = 'ja';
                    update user1;
                    testLangOptions = ISSP_AMC_DAO.countryList;
                    ISSP_AMC_Airline_Designators controller4 = new ISSP_AMC_Airline_Designators();
                    user1.LanguageLocaleKey = 'it';
                    update user1;
                    testLangOptions = ISSP_AMC_DAO.countryList;
                    ISSP_AMC_Airline_Designators controller5 = new ISSP_AMC_Airline_Designators();
                    user1.LanguageLocaleKey = 'es';
                    update user1;
                    testLangOptions = ISSP_AMC_DAO.countryList;
                    ISSP_AMC_Airline_Designators controller6 = new ISSP_AMC_Airline_Designators();
                    user1.LanguageLocaleKey = 'ko';
                    update user1;
                    testLangOptions = ISSP_AMC_DAO.countryList;
                    ISSP_AMC_Airline_Designators controller7 = new ISSP_AMC_Airline_Designators();
                    user1.LanguageLocaleKey = 'de';
                    update user1;
                    testLangOptions = ISSP_AMC_DAO.countryList;
                    ISSP_AMC_Airline_Designators controller8 = new ISSP_AMC_Airline_Designators();
                }

        }
        Test.stopTest();
    }   


    /*
        Purpose: Gets the existing case of the participation
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
    @isTest public static  void existingCase()
    {
        ISSP_AMC_ParticipationFactory.createcustomSetting(true);
        ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
        
        User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

        Test.StartTest(); 
            System.runAs(myUser){

            User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

            System.runAs(portalUser){

                Test.setCurrentPageReference(new PageReference('Page.ISSP_AMC_Location_Identifier'));
                ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
                controller.init();
                controller.step = '1';
                controller.saveParticipation();
                ISSP_AMC_DAO.getExistingCase(controller.participation.case__c);

                ISSP_AMC_DAO.getCompleteDesignatorCode(controller.participation.Id);
                //ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);
                Id caseId = [SELECT Id FROM Case WHERE Id=:controller.participation.case__c][0].Id;
                System.assertEquals(caseId,controller.participation.case__c);
            }

            Test.stopTest();
            

        }
    }

    

    /*
        Create test method for 
                                saveAmazonFileInJunctionObject(Id amazonFileId, id participationBackend )
                                getCompleteDesignatorCodeList(set<Id> poaIdSet)



    */
}