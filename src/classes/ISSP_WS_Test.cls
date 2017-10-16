@isTest
private class ISSP_WS_Test {

    static testMethod void NewUser_1() {
        ISSP_WS_NewUser.SimpleInput myInput = new ISSP_WS_NewUser.SimpleInput();
        myInput.inputMessage = 'test';
        ISSP_WS_NewUser.simpleMethod1(myInput);
    }
       
    static testMethod void NewUser_2() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;

        ISSP_WS_NewUser.UserInputData myInput = new ISSP_WS_NewUser.UserInputData();

        Test.startTest();
        ISSP_WS_NewUser.createUser(myInput);
        myInput.sisMemberId = 'SISID01';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.sisAccountId = 'SISACCID01';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.email = 'wrongmail';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.lastName = 'lastName';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.services = 'APP';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.email = 'test@email.com';
        ISSP_WS_NewUser.createUser(myInput);
        Test.stopTest();
    }
    
    /*
    static testMethod void NewUser_2_A() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'CASS01';
        insert newApp;
        
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
        theIds.CASSLinkExport__c = newApp.Id;
        theIds.CASSLinkImport__c = newApp.Id;
        theIds.CASSLinkRouteAnalyzer__c = newApp.Id;
        theIds.SIS__c = newApp.Id;
        theIds.ASD__c = newApp.Id;
        theIds.BSPLink__c = newApp.Id;
        insert theIds;
        
        ISSP_WS_NewUser.UserInputData myInput = new ISSP_WS_NewUser.UserInputData();
        myInput.firstName = 'test';
        myInput.lastName = 'test';
        myInput.salutation = '';
        myInput.email = 'test.issp.interface@testisspinterface.com';
        //myInput.accountIATAcode = '100';
        myInput.accountCountry = 'PT';
        myInput.phone = '';
        myInput.services = 'ASD';
        myInput.sisMemberId = '';
        myInput.description = '';
        ISSP_WS_NewUser.createUser(myInput);
         
        myInput.services = 'BSPLink';
        ISSP_WS_NewUser.createUser(myInput);
        
        myInput.services = 'SIS';
        ISSP_WS_NewUser.createUser(myInput);
        
    }
    */
    
    static testMethod void NewUser_3() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.User_Portal_Status__c = 'Approved User';
        con.Email = 'test.issp.interface@testisspinterface.com';
        con.Community__c = 'ISSP';
        insert con;
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'CASS01';
        insert newApp;
        
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
        theIds.CASSLinkExport__c = newApp.Id;
        theIds.CASSLinkImport__c = newApp.Id;
        theIds.CASSLinkRouteAnalyzer__c = newApp.Id;
        theIds.SIS__c = newApp.Id;
        theIds.ASD__c = newApp.Id;
        theIds.BSPLink__c = newApp.Id;
        insert theIds;
        
        ISSP_WS_NewUser.UserInputData myInput = new ISSP_WS_NewUser.UserInputData();
        myInput.firstName = 'test';
        myInput.lastName = '';
        myInput.salutation = '';
        myInput.email = '';
        ////myInput.accountIATAcode = '100';
        myInput.accountCountry = 'PT';
        myInput.phone = '';
        myInput.services = '';
        myInput.sisMemberId = 'SISID01';
        myInput.sisAccountId = 'SISACCID01';
        myInput.description = '';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.email = 'test.issp.interface@testisspinterface.com';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.lastName = 'test';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.services = 'CASS01';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.services = 'CASS02';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.services = 'CASS03';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.services = 'CASS04';
        con.User_Portal_Status__c = 'Approved User';  
        con.Community__c = '';  
        update con;
        ISSP_WS_NewUser.createUser(myInput);
        myInput.services = 'SIS';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.services = 'ASD';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.services = 'BSPLINK';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.email = 'a';
        ISSP_WS_NewUser.createUser(myInput);
    }

    static testMethod void NewUser_4() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.User_Portal_Status__c = 'Approved User';
        con.Email = 'test.issp.interface@testisspinterface.com';
        insert con;
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'CASS01';
        insert newApp;
        
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
        theIds.CASSLinkExport__c = newApp.Id;
        theIds.CASSLinkImport__c = newApp.Id;
        theIds.CASSLinkRouteAnalyzer__c = newApp.Id;
        theIds.SIS__c = newApp.Id;
        theIds.ASD__c = newApp.Id;
        theIds.BSPLink__c = newApp.Id;
        insert theIds;
        
        Portal_Application_Right__c newAppRight = new Portal_Application_Right__c();
        newAppRight.Portal_Application__c = newApp.Id;
        newAppRight.Contact__c = con.Id;
        newAppRight.Right__c = 'Access Granted';
        insert newAppRight;
        
		Test.startTest();
        ISSP_WS_NewUser.UserInputData myInput = new ISSP_WS_NewUser.UserInputData();
        myInput.firstName = 'test';
        myInput.lastName = 'test';
        myInput.salutation = '';
        myInput.email = 'test.issp.interface@testisspinterface.com';
        ////myInput.accountIATAcode = '100';
        myInput.accountCountry = 'PT';
        myInput.phone = '';
        myInput.services = 'CASS01';
        myInput.sisMemberId = 'SISID01';
        myInput.sisAccountId = 'SISACCID01';
        myInput.description = '';
        ISSP_WS_NewUser.createUser(myInput);        
        newAppRight.Right__c = 'Access Denied';
        update newAppRight;
        ISSP_WS_NewUser.createUser(myInput);
        con.status__c = 'Inactive';
        update con;
        ISSP_WS_NewUser.createUser(myInput);
		Test.stopTest();
    }
    
    static testMethod void NewUser_5() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.User_Portal_Status__c = 'Approved User';
        con.Email = 'test.issp.interface@testisspinterface.com';
        insert con;
        
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'CASS01';
        insert newApp;
        
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
        theIds.CASSLinkExport__c = newApp.Id;
        theIds.CASSLinkImport__c = newApp.Id;
        theIds.CASSLinkRouteAnalyzer__c = newApp.Id;
        theIds.SIS__c = newApp.Id;
        theIds.ASD__c = newApp.Id;
        theIds.BSPLink__c = newApp.Id;
        insert theIds;
        
        User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(myUser){
            ISSP_WS_NewUser.UserInputData myInput = new ISSP_WS_NewUser.UserInputData();
            myInput.firstName = 'test';
            myInput.lastName = 'test';
            myInput.salutation = '';
            myInput.email = 'test.issp.interface@testisspinterface.com';
            ////myInput.accountIATAcode = '100';
            myInput.accountCountry = 'PT';
            myInput.phone = '';
            myInput.services = 'CASS01';
            myInput.sisMemberId = 'SISID01';
            myInput.sisAccountId = 'SISACCID01';
            myInput.description = '';
            ISSP_WS_NewUser.createUser(myInput);
        }

    }
    
    static testMethod void NewUser_6() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.User_Portal_Status__c = 'Rejected';
        con.Status__c = 'Inactive';
        con.Email = 'test.issp.interface@testisspinterface.com';
        insert con;
        
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'MYTEST';
        insert newApp;
        
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
        theIds.CASSLinkExport__c = newApp.Id;
        theIds.CASSLinkImport__c = newApp.Id;
        theIds.CASSLinkRouteAnalyzer__c = newApp.Id;
        theIds.SIS__c = newApp.Id;
        theIds.ASD__c = newApp.Id;
        theIds.BSPLink__c = newApp.Id;
        insert theIds;
        
        User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(myUser){
            ISSP_WS_NewUser.UserInputData myInput = new ISSP_WS_NewUser.UserInputData();
            myInput.firstName = 'test';
            myInput.lastName = 'test';
            myInput.salutation = '';
            myInput.email = 'test.issp.interface@testisspinterface.com';
            ////myInput.accountIATAcode = '100';
            myInput.accountCountry = 'PT';
            myInput.phone = '';
            myInput.services = 'CASS01';
            myInput.sisMemberId = 'SISID01';
            myInput.sisAccountId = 'SISACCID01';
            myInput.description = '';
            ISSP_WS_NewUser.createUser(myInput);
        }
    }
    
    static testMethod void NewUser_7() {
        Map<Id, String> sisFedIdMap = new Map<Id, String>();
        Map<Id, String> sisEmailMap = new Map<Id, String>();
        Map<Id, String> sisFirstNameMap = new Map<Id, String>();
        Map<Id, String> sisLastNameMap = new Map<Id, String>();
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        String recordTypeId1 = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Agency'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.User_Portal_Status__c = 'Pending Approval';
        con.Email = 'test.issp.interface@testisspinterface.com';
        con.Community__c = 'ISS Customer Portal';
        insert con;
        
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'MYTEST';
        insert newApp;
        
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
        theIds.CASSLinkExport__c = newApp.Id;
        theIds.CASSLinkImport__c = newApp.Id;
        theIds.CASSLinkRouteAnalyzer__c = newApp.Id;
        theIds.SIS__c = newApp.Id;
        theIds.ASD__c = newApp.Id;
        theIds.BSPLink__c = newApp.Id;
        insert theIds;

        String fedId = String.valueOf(con).substring(0,15);
        sisEmailMap.put(con.id, con.Email);
        sisFirstNameMap.put(con.id, con.FirstName);
        sisLastNameMap.put(con.id, con.LastName);
        sisFedIdMap.put(con.id, fedId);

        User myUser = [ select Id, firstname, lastname, email from User where Id = :UserInfo.getUserId() ];
        Contact con2 = ISSP_WS_Utilities.createContact(myUser.firstName, myUser.lastName, myUser.email, acc.id, false);
        Test.startTest();
        system.runAs(myUser){
            ISSP_WS_NewUser.UserInputData myInput = new ISSP_WS_NewUser.UserInputData();
            myInput.firstName = 'test';
            myInput.lastName = 'test';
            myInput.salutation = '';
            myInput.email = 'test.issp.interfac2e@testisspinterface.com';
            ////myInput.accountIATAcode = '100';
            myInput.accountCountry = 'PT';
            myInput.phone = '';
            myInput.services = 'CASS01';
            myInput.sisMemberId = 'SISID01';
            myInput.sisAccountId = 'SISACCID01';
            myInput.description = '';
            ISSP_WS_NewUser.createUser(myInput);
            ISSP_WS_NewUser.createUser(myInput);
            myInput.accountCountry = '';
            ISSP_WS_NewUser.createUser(myInput);
            acc.RecordTypeId = recordTypeId1;
            update acc;
            ISSP_WS_NewUser.createUser(myInput);
            ISSP_WS_Utilities.invokeSisModifyUser(sisFedIdMap, sisEmailMap, sisFirstNameMap, sisLastNameMap);         
            try{
            ISSP_WS_Utilities.sendUserEmail(thisUser, con);
            }catch (Exception e){
            }
        }
        Test.stopTest();
    }
    
    static testMethod void NewUser_8() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.User_Portal_Status__c = 'Approved User';
        con.Email = 'test.issp.interface@testisspinterface.com';
        con.Community__c = 'ISSP';
        insert con;
        
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'MYTEST';
        insert newApp;
        
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
        theIds.CASSLinkExport__c = newApp.Id;
        theIds.CASSLinkImport__c = newApp.Id;
        theIds.CASSLinkRouteAnalyzer__c = newApp.Id;
        theIds.SIS__c = newApp.Id;
        theIds.ASD__c = newApp.Id;
        theIds.BSPLink__c = newApp.Id;
        theIds.CNS_CassLink__c = newApp.Id;
        insert theIds;
        
        Portal_Application_Right__c newAppRight = new Portal_Application_Right__c();
        newAppRight.Portal_Application__c = newApp.Id;
        newAppRight.Contact__c = con.Id;
        newAppRight.Right__c = 'Access Granted';
        insert newAppRight;
        
        User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(myUser){
            ISSP_WS_NewUser.UserInputData myInput = new ISSP_WS_NewUser.UserInputData();
            myInput.firstName = 'test';
            myInput.lastName = 'test';
            myInput.salutation = '';
            myInput.email = 'test.issp.interface@testisspinterface.com';
            ////myInput.accountIATAcode = '100';
            myInput.accountCountry = 'PT';
            myInput.phone = '';
            myInput.services = 'CASS01';
            myInput.sisMemberId = 'SISID01';
            myInput.sisAccountId = 'SISACCID01';
            myInput.description = '';
            thisUser.FederationIdentifier = null;
            update thisUser;
            ISSP_WS_NewUser.createUser(myInput);
            myInput.services = 'CASS04';
            //  con.Community__c = '';
            con.User_Portal_Status__c = 'Pending Approval';
            update con;
            ISSP_WS_NewUser.createUser(myInput);
        }
    }
    
    static testMethod void NewUser_9() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.User_Portal_Status__c = 'Approved User';
        con.Email = 'test.issp.interface@testisspinterface.com';
        insert con;
        
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'MYTEST';
        insert newApp;
        
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
        theIds.CASSLinkExport__c = newApp.Id;
        theIds.CASSLinkImport__c = newApp.Id;
        theIds.CASSLinkRouteAnalyzer__c = newApp.Id;
        theIds.SIS__c = newApp.Id;
        theIds.ASD__c = newApp.Id;
        theIds.BSPLink__c = newApp.Id;
        insert theIds;
        
        Portal_Application_Right__c newAppRight = new Portal_Application_Right__c();
        newAppRight.Portal_Application__c = newApp.Id;
        newAppRight.Contact__c = con.Id;
        newAppRight.Right__c = 'Access Denied';
        insert newAppRight;
        
        User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(myUser){
            ISSP_WS_NewUser.UserInputData myInput = new ISSP_WS_NewUser.UserInputData();
            myInput.firstName = 'test';
            myInput.lastName = 'test';
            myInput.salutation = '';
            myInput.email = 'test.issp.interface@testisspinterface.com';
            //myInput.accountIATAcode = '100';
            myInput.accountCountry = 'PT';
            myInput.phone = '';
            myInput.services = 'CASS01';
            myInput.sisMemberId = 'SISID01';
            myInput.sisAccountId = 'SISACCID01';
            myInput.description = '';
            ISSP_WS_NewUser.createUser(myInput);
        }

    }
    
    static testMethod void NewUser_10() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.User_Portal_Status__c = 'Approved User';
        con.Email = 'test.issp.interface@testisspinterface.com';
        insert con;
        
        String conId15 = con.Id;
        conId15 = conId15.substring(0,15);
        
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'MYTEST';
        insert newApp;
        
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
        theIds.CASSLinkExport__c = newApp.Id;
        theIds.CASSLinkImport__c = newApp.Id;
        theIds.CASSLinkRouteAnalyzer__c = newApp.Id;
        theIds.SIS__c = newApp.Id;
        theIds.ASD__c = newApp.Id;
        theIds.BSPLink__c = newApp.Id;
        insert theIds;
        
        Portal_Application_Right__c newAppRight = new Portal_Application_Right__c();
        newAppRight.Portal_Application__c = newApp.Id;
        newAppRight.Contact__c = con.Id;
        newAppRight.Right__c = 'Access Denied';
        insert newAppRight;
        
        User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        Test.startTest();
        system.runAs(myUser){
            ISSP_WS_DisableUser.UserInputData myInput = new ISSP_WS_DisableUser.UserInputData();
            myInput.fedId = '';
            myInput.services = '';
            ISSP_WS_DisableUser.disableUser(myInput);
            
            myInput.fedId = '1234';
            ISSP_WS_DisableUser.disableUser(myInput);
            
            myInput.services = 'CASS10';
            ISSP_WS_DisableUser.disableUser(myInput);
            
            myInput.fedId = conId15;
            ISSP_WS_DisableUser.disableUser(myInput);
            
            myInput.services = 'CASS02';
            ISSP_WS_DisableUser.disableUser(myInput);
            
            myInput.services = 'CASS03';
            ISSP_WS_DisableUser.disableUser(myInput);
            
            myInput.services = 'CASS01';
            ISSP_WS_DisableUser.disableUser(myInput);

            myInput.services = 'SIS';
            ISSP_WS_DisableUser.disableUser(myInput);
            
            myInput.services = 'ASD';
            ISSP_WS_DisableUser.disableUser(myInput);
            
			
            myInput.services = 'BSPLink';
            ISSP_WS_DisableUser.disableUser(myInput);
        }
        Test.stopTest();
    }
    
    static testMethod void NewUser_11() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.User_Portal_Status__c = 'Approved User';
        con.Email = 'test.issp.interface@testisspinterface.com';
        insert con;
        
        String conId15 = con.Id;
        conId15 = conId15.substring(0,15);
        
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'MYTEST';
        insert newApp;
        
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
        theIds.CASSLinkExport__c = newApp.Id;
        theIds.CASSLinkImport__c = newApp.Id;
        theIds.CASSLinkRouteAnalyzer__c = newApp.Id;
        theIds.SIS__c = newApp.Id;
        theIds.ASD__c = newApp.Id;
        theIds.BSPLink__c = newApp.Id;
        insert theIds;
        
        User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(myUser){
            ISSP_WS_DisableUser.UserInputData myInput = new ISSP_WS_DisableUser.UserInputData();
            myInput.services = 'CASS01';
            myInput.fedId = conId15;
            ISSP_WS_DisableUser.disableUser(myInput);
        }
        
        Portal_Application_Right__c newAppRight = new Portal_Application_Right__c();
        newAppRight.Portal_Application__c = newApp.Id;
        newAppRight.Contact__c = con.Id;
        newAppRight.Right__c = 'Access Granted';
        insert newAppRight;
        
        system.runAs(myUser){
            ISSP_WS_DisableUser.UserInputData myInput = new ISSP_WS_DisableUser.UserInputData();
            myInput.services = 'CASS01';
            myInput.fedId = conId15;
            ISSP_WS_DisableUser.disableUser(myInput);
        }
    }
    
    static testMethod void NewUser_12() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.User_Portal_Status__c = 'Approved User';
        con.Email = 'test.issp.interface@testisspinterface.com';
        insert con;
        
        String conId15 = con.Id;
        conId15 = conId15.substring(0,15);
        
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'MYTEST';
        insert newApp;
        
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
        theIds.CASSLinkExport__c = newApp.Id;
        theIds.CASSLinkImport__c = newApp.Id;
        theIds.CASSLinkRouteAnalyzer__c = newApp.Id;
        theIds.SIS__c = newApp.Id;
        theIds.ASD__c = newApp.Id;
        theIds.BSPLink__c = newApp.Id;
        insert theIds;
        
        Portal_Application_Right__c newAppRight = new Portal_Application_Right__c();
        newAppRight.Portal_Application__c = newApp.Id;
        newAppRight.Contact__c = con.Id;
        newAppRight.Right__c = 'Access Denied';
        insert newAppRight;
        
        User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        Test.startTest();
        system.runAs(myUser){
            ISSP_WS_DisableUser.UserInputData myInput = new ISSP_WS_DisableUser.UserInputData();
            myInput.fedId = '';
            myInput.services = '';
            ISSP_WS_DisableUser.reactivateUser(myInput);
            
            myInput.fedId = '1234';
            ISSP_WS_DisableUser.reactivateUser(myInput);
            
            myInput.services = 'CASS10';
            ISSP_WS_DisableUser.reactivateUser(myInput);
            
            myInput.fedId = conId15;
            ISSP_WS_DisableUser.reactivateUser(myInput);
            
            myInput.services = 'CASS02';
            ISSP_WS_DisableUser.reactivateUser(myInput);
            
            myInput.services = 'CASS03';
            ISSP_WS_DisableUser.reactivateUser(myInput);

            myInput.services = 'CASS01';
            ISSP_WS_DisableUser.reactivateUser(myInput);
            
            myInput.services = 'SIS';
            ISSP_WS_DisableUser.disableUser(myInput);
            
            myInput.services = 'ASD';
            ISSP_WS_DisableUser.disableUser(myInput);
            
            myInput.services = 'BSPLink';
            ISSP_WS_DisableUser.disableUser(myInput);
        }
        Test.stopTest();
    }

     static testMethod void asdDeactivateUser() { 
        ISSP_WS_Utilities.invokeAsdDisableUser('1234');
    }
    
    static testMethod void NewUser_13() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.User_Portal_Status__c = 'Approved User';
        con.Email = 'NOTFOUND@testisspinterface.com';
        insert con;
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'CASS01';
        insert newApp;
        
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
        theIds.CASSLinkExport__c = newApp.Id;
        theIds.CASSLinkImport__c = newApp.Id;
        theIds.CASSLinkRouteAnalyzer__c = newApp.Id;
        theIds.SIS__c = newApp.Id;
        theIds.ASD__c = newApp.Id;
        theIds.BSPLink__c = newApp.Id;
        insert theIds;
        
        Portal_Application_Right__c newAppRight = new Portal_Application_Right__c();
        newAppRight.Portal_Application__c = newApp.Id;
        newAppRight.Contact__c = con.Id;
        newAppRight.Right__c = 'Access Granted';
        insert newAppRight;
        
        ISSP_WS_NewUser.UserInputData myInput = new ISSP_WS_NewUser.UserInputData();
        myInput.firstName = 'test';
        myInput.lastName = 'test';
        myInput.salutation = '';
        myInput.email = 'test.issp.interface@testisspinterface.com';
        ////myInput.accountIATAcode = '100';
        myInput.accountCountry = 'PT';
        myInput.phone = '';
        myInput.services = 'CASS01';
        myInput.sisMemberId = 'SISID01';
        myInput.sisAccountId = 'SISACCID01';
        myInput.description = '';
        ISSP_WS_NewUser.createUser(myInput);
        
        newAppRight.Right__c = 'Access Denied';
        update newAppRight;
        ISSP_WS_NewUser.createUser(myInput);
    }
    
static testMethod void NewUser_14() {
    List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
    insert errorList;
    
    String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
    
    Account acc = ISSP_ObjectFactory.createNewAccount();
    acc.IATACode__c = '100';
    acc.RecordTypeId = recordTypeId;
    acc.SIS_ID__c = 'SISACCID01';
    insert acc;
    
    Contact con = ISSP_ObjectFactory.createNewContact();
    con.AccountId = acc.Id;
    con.LastName = 'test';
    con.User_Portal_Status__c = 'Approved User';
    con.Email = 'NOTFOUND@testisspinterface.com';
    insert con;
    
    Portal_Applications__c newApp = new Portal_Applications__c();
    newApp.Name = 'CASS01';
    insert newApp;
    
    ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
    theIds.CASSLinkExport__c = newApp.Id;
    theIds.CASSLinkImport__c = newApp.Id;
    theIds.CASSLinkRouteAnalyzer__c = newApp.Id;
    theIds.SIS__c = newApp.Id;
    theIds.ASD__c = newApp.Id;
    theIds.BSPLink__c = newApp.Id;
    insert theIds;
    
    Portal_Application_Right__c newAppRight = new Portal_Application_Right__c();
    newAppRight.Portal_Application__c = newApp.Id;
    newAppRight.Contact__c = con.Id;
    newAppRight.Right__c = 'Access Granted';
    insert newAppRight;
    
    ISSP_WS_NewUser.UserInputData myInput = new ISSP_WS_NewUser.UserInputData();
    myInput.firstName = 'test';
    myInput.lastName = 'test';
    myInput.salutation = '';
    myInput.email = 'test.issp.interface@testisspinterface.com';
    ////myInput.accountIATAcode = '100';
    myInput.accountCountry = 'PT';
    myInput.phone = '';
    myInput.services = 'CASS01';
    myInput.sisMemberId = 'SISID01';
    myInput.sisAccountId = acc.SIS_ID__c;
    myInput.description = '';
    ISSP_WS_NewUser.createUser(myInput);
    
    newAppRight.Right__c = 'Access Denied';
    update newAppRight;
    ISSP_WS_NewUser.createUser(myInput);
}
    /*
    static testMethod void NewUser_14() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.User_Portal_Status__c = 'Approved User';
        con.Email = 'test.issp.interface@testisspinterface.com';
        insert con;
        
        String conId15 = con.Id;
        conId15 = conId15.substring(0,15);
        
        User thisUser = ISSP_ObjectFactory.createInactivePortalUser(con);
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'MYTEST';
        insert newApp;
        
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
        theIds.CASSLinkExport__c = newApp.Id;
        theIds.CASSLinkImport__c = newApp.Id;
        theIds.CASSLinkRouteAnalyzer__c = newApp.Id;
        theIds.SIS__c = newApp.Id;
        theIds.ASD__c = newApp.Id;
        theIds.BSPLink__c = newApp.Id;
        insert theIds;
        
        User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(myUser){
            ISSP_WS_DisableUser.UserInputData myInput = new ISSP_WS_DisableUser.UserInputData();
            myInput.fedId = conId15;
            myInput.services = 'CASS01';
            ISSP_WS_DisableUser.disableUser(myInput);
            ISSP_WS_DisableUser.reactivateUser(myInput);
        }
    }
    
    static testMethod void NewUser_15() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.User_Portal_Status__c = 'Approved User';
        con.Email = 'test.issp.interface@testisspinterface.com';
        insert con;
        
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        
        String conId15 = con.Id;
        conId15 = conId15.substring(0,15);      
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'MYTEST';
        insert newApp;
        
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
        theIds.CASSLinkExport__c = newApp.Id;
        theIds.CASSLinkImport__c = newApp.Id;
        theIds.CASSLinkRouteAnalyzer__c = newApp.Id;
        theIds.SIS__c = newApp.Id;
        theIds.ASD__c = newApp.Id;
        theIds.BSPLink__c = newApp.Id;
        insert theIds;
        
        User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(myUser){
            ISSP_WS_DisableUser.UserInputData myInput = new ISSP_WS_DisableUser.UserInputData();
            myInput.fedId = conId15;
            myInput.services = 'CASS01';
            ISSP_WS_DisableUser.reactivateUser(myInput);
        }
    }
    
    static testMethod void changeBsplink() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'MYTEST';
        insert newApp;
        
        ISSP_CS__c cs1 = new ISSP_CS__c();
        cs1.Name = 'BSPLink URL A';
        cs1.Value__c = '/ISSP_Homepage';
        insert cs1;
        
        ISSP_CS__c cs2 = new ISSP_CS__c();
        cs2.Name = 'BSPLink URL B';
        cs2.Value__c = '/ISSP_Login';
        insert cs2;
        
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
        theIds.BSPLink__c = newApp.Id;
        insert theIds;
        
        ISSP_WS_BSP_Utilities.EnvironmentData myInput = new ISSP_WS_BSP_Utilities.EnvironmentData();
        myInput.validationKey = '';
        myInput.currentEnvironment = '';
        ISSP_WS_BSP_Utilities.changeEnvironment(myInput);
        myInput.validationKey = 'BSP_Change_Env_ABC1234';
        ISSP_WS_BSP_Utilities.changeEnvironment(myInput);
        myInput.currentEnvironment = 'C';
        ISSP_WS_BSP_Utilities.changeEnvironment(myInput);
        myInput.currentEnvironment = 'A';
        ISSP_WS_BSP_Utilities.changeEnvironment(myInput);
        myInput.currentEnvironment = 'B';
        ISSP_WS_BSP_Utilities.changeEnvironment(myInput);
    }
    
    static testMethod void getLastLoginDate() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.User_Portal_Status__c = 'Approved User';
        con.Email = 'test.issp.interface@testisspinterface.com';
        insert con;
        
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        
        ISSP_CS__c cs = new ISSP_CS__c();
        cs.Name = 'Host';
        cs.Value__c = '1234';
        insert cs;
        ISSP_WS_Utilities.sendUserEmail(thisUser, con);
        
        String conId15 = con.Id;
        conId15 = conId15.substring(0,15);      
        
        ISSP_WS_BSP_Utilities.UserInputData myInput = new ISSP_WS_BSP_Utilities.UserInputData();
        myInput.FederationID = '';
        ISSP_WS_BSP_Utilities.getLastLoginDate(myInput);
        myInput.FederationID = '1234';
        ISSP_WS_BSP_Utilities.getLastLoginDate(myInput);
        myInput.FederationID = conId15;
        ISSP_WS_BSP_Utilities.getLastLoginDate(myInput);
    }
    
    static testMethod void asdDeactivateUser() { 
        ISSP_WS_Utilities.invokeAsdDisableUser('1234');
    }
    
    static testMethod void sisModifyUser() {
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        insert acc;
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        insert con;
        Map<Id, String> sisFedIdMap = new Map<Id, String>();
        sisFedIdMap.put(con.id, '1234');
        Map<Id, String> sisEmailMap = new Map<Id, String>();
        sisEmailMap.put(con.id, '1234');
        Map<Id, String> sisFirstNameMap = new Map<Id, String>();
        sisFirstNameMap.put(con.id, '1234');
        Map<Id, String> sisLastNameMap = new Map<Id, String>();
        sisLastNameMap.put(con.id, '1234');
        ISSP_WS_Utilities.invokeSisModifyUser(sisFedIdMap, sisEmailMap, sisFirstNameMap, sisLastNameMap);
    }
    
    static testMethod void createNotification_1() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.Airline_designator__c = 'TP';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        Account acc2 = ISSP_ObjectFactory.createNewAccount();
        acc2.IATACode__c = '100';
        acc2.Airline_designator__c = 'TZ';
        acc2.RecordTypeId = recordTypeId;
        insert acc2;
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'MYTEST';
        insert newApp;
        
        ISSP_WS_CreateNotification.inputData myInputData = new ISSP_WS_CreateNotification.inputData();
        myInputData.requestingSystem = '';
        myInputData.iataCode = '';
        myInputData.designatorCode = '';
        myInputData.serviceName = '';
        myInputData.listOfUsers = new List<String>();
        myInputData.templateName = '';
        myInputData.languageMessageList = new List<ISSP_WS_CreateNotification.languageMessage>();
        myInputData.notificationType = '';
        myInputData.daysToExpire = 1;
        myInputData.emailAlert = true;
        myInputData.criticalNotification = true;
        myInputData.campaignName = '';
        
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        myInputData.iataCode = '101';
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        myInputData.iataCode = '100';
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.Email = 'test_createnotification1@test.com';
        insert con;
        
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        ISSP_WS_CreateNotification.languageMessage newLang1 = new ISSP_WS_CreateNotification.languageMessage();
        newLang1.languageCode = 'es';
        newLang1.message = 'test';
        newLang1.subject = 'test';
        myInputData.languageMessageList.add(newLang1);
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        ISSP_WS_CreateNotification.languageMessage newLang2 = new ISSP_WS_CreateNotification.languageMessage();
        newLang2.languageCode = 'en_US';
        newLang2.message = 'test';
        newLang2.subject = 'test';
        myInputData.languageMessageList.add(newLang2);
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        myInputData.designatorCode = 'TT';
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        myInputData.designatorCode = 'TZ';
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        myInputData.designatorCode = 'TP';
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        myInputData.serviceName = 'test';
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        myInputData.serviceName = 'MYTEST';
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
    }
    
    static testMethod void createNotification_1_A() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.Airline_designator__c = 'TP';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        Account acc2 = ISSP_ObjectFactory.createNewAccount();
        acc2.IATACode__c = '100';
        acc2.Airline_designator__c = 'TZ';
        acc2.RecordTypeId = recordTypeId;
        insert acc2;
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'MYTEST';
        insert newApp;
        
        ISSP_WS_CreateNotification.inputData myInputData = new ISSP_WS_CreateNotification.inputData();
        myInputData.requestingSystem = '';
        myInputData.iataCode = '';
        myInputData.designatorCode = '';
        myInputData.serviceName = '';
        myInputData.listOfUsers = new List<String>();
        myInputData.templateName = '';
        myInputData.languageMessageList = new List<ISSP_WS_CreateNotification.languageMessage>();
        myInputData.notificationType = '';
        myInputData.daysToExpire = 1;
        myInputData.emailAlert = true;
        myInputData.criticalNotification = true;
        myInputData.campaignName = '';
        
        myInputData.iataCode = '100';
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.Email = 'test_createnotification1@test.com';
        insert con;
        
        ISSP_WS_CreateNotification.languageMessage newLang1 = new ISSP_WS_CreateNotification.languageMessage();
        newLang1.languageCode = 'es';
        newLang1.message = 'test';
        newLang1.subject = 'test';
        myInputData.languageMessageList.add(newLang1);
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        ISSP_WS_CreateNotification.languageMessage newLang2 = new ISSP_WS_CreateNotification.languageMessage();
        newLang2.languageCode = 'en_US';
        newLang2.message = 'test';
        newLang2.subject = 'test';
        myInputData.languageMessageList.add(newLang2);
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        myInputData.designatorCode = 'TP';
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        myInputData.serviceName = 'MYTEST';
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        Portal_Application_Right__c newAppRight = new Portal_Application_Right__c();
        newAppRight.Portal_Application__c = newApp.Id;
        newAppRight.Contact__c = con.Id;
        newAppRight.Right__c = 'Access Granted';
        insert newAppRight;
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        List<String> emailList = new List<String>();
        emailList.add('test_createnotification1@test.com');
        myInputData.listOfUsers = emailList;
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
    }
    
    static testMethod void createNotification_2() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.Airline_designator__c = 'TP';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'MYTEST';
        insert newApp;
        
        ISSP_WS_CreateNotification.inputData myInputData = new ISSP_WS_CreateNotification.inputData();
        myInputData.requestingSystem = '';
        myInputData.iataCode = '';
        myInputData.designatorCode = '';
        myInputData.serviceName = '';
        myInputData.listOfUsers = new List<String>();
        myInputData.templateName = '';
        myInputData.languageMessageList = new List<ISSP_WS_CreateNotification.languageMessage>();
        myInputData.notificationType = '';
        myInputData.daysToExpire = 1;
        myInputData.emailAlert = true;
        myInputData.criticalNotification = true;
        myInputData.campaignName = '';

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        insert con;
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);

        myInputData.designatorCode = 'TP';
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        Notification_template__c notificationTemplate = new Notification_template__c();
        notificationTemplate.Subject__c = 'Test 001';
        notificationTemplate.Type__c = 'Action';
        notificationTemplate.Admins_Users__c = 'User';
        notificationTemplate.Message__c = 'test';
        notificationTemplate.Notification_color__c = '#007FFF';
        insert notificationTemplate;
        
        String tempName = [SELECT Name FROM Notification_template__c WHERE Id = :notificationTemplate.Id].Name;
        
        myInputData.templateName = 'test';
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        //myInputData.templateName = tempName;
        //ISSP_WS_CreateNotification.createNotification(myInputData);
        
    }
    
    static testMethod void createNotification_3() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.Airline_designator__c = 'TP';
        acc.RecordTypeId = recordTypeId;
        insert acc;

        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'MYTEST';
        insert newApp;
        
        ISSP_WS_CreateNotification.inputData myInputData = new ISSP_WS_CreateNotification.inputData();
        myInputData.requestingSystem = '';
        myInputData.iataCode = '';
        myInputData.designatorCode = '';
        myInputData.serviceName = 'MYTEST';
        myInputData.listOfUsers = new List<String>();
        myInputData.templateName = '';
        myInputData.languageMessageList = new List<ISSP_WS_CreateNotification.languageMessage>();
        myInputData.notificationType = '';
        myInputData.daysToExpire = 1;
        myInputData.emailAlert = true;
        myInputData.criticalNotification = true;
        myInputData.campaignName = '';

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        insert con;

        Portal_Application_Right__c newAppRight = new Portal_Application_Right__c();
        newAppRight.Portal_Application__c = newApp.Id;
        newAppRight.Contact__c = con.Id;
        newAppRight.Right__c = 'Access Granted';
        insert newAppRight;
        
        ISSP_WS_CreateNotification.createNotification(myInputData);
    }
    
    static testMethod void createNotification_4() {
        List <ISSP_Int_Error__c> errorList = ISSP_WS_Test.createErrors();
        insert errorList;
        
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.Airline_designator__c = 'TP';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.Email = 'test_createnotification2@test.com';
        insert con;
        
        ISSP_WS_CreateNotification.inputData myInputData = new ISSP_WS_CreateNotification.inputData();
        myInputData.requestingSystem = '';
        myInputData.iataCode = '';
        myInputData.designatorCode = '';
        myInputData.serviceName = '';
        myInputData.listOfUsers = new List<String>();
        myInputData.templateName = '';
        myInputData.languageMessageList = new List<ISSP_WS_CreateNotification.languageMessage>();
        myInputData.notificationType = '';
        myInputData.daysToExpire = 1;
        myInputData.emailAlert = true;
        myInputData.criticalNotification = true;
        myInputData.campaignName = '';
        
        List<String> emailList = new List<String>();
        emailList.add('test_createnotification1@test.com');
        myInputData.listOfUsers = emailList;
        ISSP_WS_CreateNotification.createNotification(myInputData);
        
        emailList.add('test_createnotification2@test.com');
        myInputData.listOfUsers = emailList;
        ISSP_WS_CreateNotification.createNotification(myInputData);
    }
    */
    public static List <ISSP_Int_Error__c> createErrors(){
        List <ISSP_Int_Error__c> errorList = new List <ISSP_Int_Error__c>();
        for (Integer i =1; i<=20; i++) {
            String errorCode = ('000' + i).right(3);
            errorList.add(new ISSP_Int_Error__c(Name = errorCode, Error_Message__c = errorCode));
            errorList.add(new ISSP_Int_Error__c(Name = 'A' + errorCode, Error_Message__c = errorCode));
        }
        return errorList;
    }
    
    /*
    static testMethod void newCNSContact() {

        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;

        Test.startTest();

            ISSP_WS_Utilities.createContact('LauraCNS', 'testLaura', 'test.cn.sla.ura@test.com', String.valueOf(acc.Id), true);

        Test.stopTest();
        
    }
       
    */
    
}