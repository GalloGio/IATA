@isTest
private class ISSP_WS_Test {

    static testMethod void NewUser_1() {
        ISSP_WS_NewUser.SimpleInput myInput = new ISSP_WS_NewUser.SimpleInput();
        myInput.inputMessage = 'test';
        ISSP_WS_NewUser.simpleMethod1(myInput);
    }
       
    static testMethod void NewUser_2() {
    /*
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
        myInput.lastName = '';
        myInput.salutation = '';
        myInput.email = '';
        myInput.accountIATAcode = '';
        myInput.accountCountry = 'PT';
        myInput.phone = '';
        myInput.services = '';
        myInput.sisMemberId = '';
        myInput.description = '';
        ISSP_WS_NewUser.createUser(myInput);
        
        myInput.email = 'abcd';
        ISSP_WS_NewUser.createUser(myInput);
        
        myInput.lastName = 'test';
        ISSP_WS_NewUser.createUser(myInput);
        
        myInput.services = 'CASS10';
        ISSP_WS_NewUser.createUser(myInput);
        
        myInput.email = 'test.issp.interface@testisspinterface.com';
        ISSP_WS_NewUser.createUser(myInput);
        
        myInput.services = 'CASS01';
        ISSP_WS_NewUser.createUser(myInput);
        
        myInput.accountIATAcode = '';
        ISSP_WS_NewUser.createUser(myInput);
        
        myInput.accountIATAcode = '101';
        ISSP_WS_NewUser.createUser(myInput);
        
        myInput.accountIATAcode = '100';
        ISSP_WS_NewUser.createUser(myInput);
        
        myInput.services = 'CASS02';
        ISSP_WS_NewUser.createUser(myInput);
        */
       /* myInput.services = 'CASS03';
        ISSP_WS_NewUser.createUser(myInput);*/
 
    }
    
    static testMethod void NewUser_2_A() {
    /*
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
        myInput.accountIATAcode = '100';
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
        */
        
    }
    
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
        myInput.accountIATAcode = '100';
        myInput.accountCountry = 'PT';
        myInput.phone = '';
        myInput.services = '';
        myInput.sisMemberId = '';
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
		Test.startTest();
        ISSP_WS_NewUser.createUser(myInput);
        myInput.services = 'SIS';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.services = 'ASD';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.services = 'BSPLINK';
        ISSP_WS_NewUser.createUser(myInput);
        myInput.email = 'a';
        ISSP_WS_NewUser.createUser(myInput);
		Test.stopTest();
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
        myInput.accountIATAcode = '100';
        myInput.accountCountry = 'PT';
        myInput.phone = '';
        myInput.services = 'CASS01';
        myInput.sisMemberId = '';
        myInput.description = '';
        ISSP_WS_NewUser.createUser(myInput);        
        newAppRight.Right__c = 'Access Denied';
        update newAppRight;
        ISSP_WS_NewUser.createUser(myInput);
        con.status__c = 'Inactive';
        update con;
        ISSP_WS_NewUser.createUser(myInput);
        myInput.accountIATAcode = '1001';
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
            myInput.accountIATAcode = '100';
            myInput.accountCountry = 'PT';
            myInput.phone = '';
            myInput.services = 'CASS01';
            myInput.sisMemberId = '';
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
            myInput.accountIATAcode = '100';
            myInput.accountCountry = 'PT';
            myInput.phone = '';
            myInput.services = 'CASS01';
            myInput.sisMemberId = '';
            myInput.description = '';
            ISSP_WS_NewUser.createUser(myInput);
        }
    }
    
    static testMethod void NewUser_7() {
	/*
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
            myInput.accountIATAcode = '';
            myInput.accountCountry = 'PT';
            myInput.phone = '';
            myInput.services = 'CASS01';
            myInput.sisMemberId = '';
            myInput.description = '';
            ISSP_WS_NewUser.createUser(myInput);
            myInput.accountIATAcode = '100';            
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
		*/
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
            myInput.accountIATAcode = '100';
            myInput.accountCountry = 'PT';
            myInput.phone = '';
            myInput.services = 'CASS01';
            myInput.sisMemberId = '';
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
            myInput.accountIATAcode = '100';
            myInput.accountCountry = 'PT';
            myInput.phone = '';
            myInput.services = 'CASS01';
            myInput.sisMemberId = '';
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
    
    /*
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
        con.Email = 'test.issp.interface@testisspinterface.com';
        insert con;
        
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
        
        Portal_Application_Right__c newAppRight = new Portal_Application_Right__c();
        newAppRight.Portal_Application__c = newApp.Id;
        newAppRight.Contact__c = con.Id;
        newAppRight.Right__c = 'Access Granted';
        insert newAppRight;
        
        User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        myUser.FederationIdentifier = conId15;
        update myUser;
        system.runAs(myUser){
            ISSP_WS_DisableUser.UserInputData myInput = new ISSP_WS_DisableUser.UserInputData();
            myInput.fedId = conId15;
            myInput.services = 'CASS01';
            ISSP_WS_DisableUser.disableUser(myInput);
            ISSP_WS_DisableUser.reactivateUser(myInput);
        }
    }
    
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
    */
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
    
    public static List <ISSP_Int_Error__c> createErrors(){
        List <ISSP_Int_Error__c> errorList = new List <ISSP_Int_Error__c>();
        ISSP_Int_Error__c newError1 = new ISSP_Int_Error__c();
        newError1.Name = '001';
        newError1.Error_Message__c = '001';
        errorList.add(newError1);
        ISSP_Int_Error__c newError2 = new ISSP_Int_Error__c();
        newError2.Name = '002';
        newError2.Error_Message__c = '002';
        errorList.add(newError2);
        ISSP_Int_Error__c newError3 = new ISSP_Int_Error__c();
        newError3.Name = '003';
        newError3.Error_Message__c = '003';
        errorList.add(newError3);
        ISSP_Int_Error__c newError4 = new ISSP_Int_Error__c();
        newError4.Name = '004';
        newError4.Error_Message__c = '004';
        errorList.add(newError4);
        ISSP_Int_Error__c newError5 = new ISSP_Int_Error__c();
        newError5.Name = '005';
        newError5.Error_Message__c = '005';
        errorList.add(newError5);
        ISSP_Int_Error__c newError6 = new ISSP_Int_Error__c();
        newError6.Name = '006';
        newError6.Error_Message__c = '006';
        errorList.add(newError6);
        ISSP_Int_Error__c newError7 = new ISSP_Int_Error__c();
        newError7.Name = '007';
        newError7.Error_Message__c = '007';
        errorList.add(newError7);
        ISSP_Int_Error__c newError8 = new ISSP_Int_Error__c();
        newError8.Name = '008';
        newError8.Error_Message__c = '008';
        errorList.add(newError8);
        ISSP_Int_Error__c newError9 = new ISSP_Int_Error__c();
        newError9.Name = '009';
        newError9.Error_Message__c = '009';
        errorList.add(newError9);
        ISSP_Int_Error__c newError10 = new ISSP_Int_Error__c();
        newError10.Name = '010';
        newError10.Error_Message__c = '010';
        errorList.add(newError10);
        ISSP_Int_Error__c newError11 = new ISSP_Int_Error__c();
        newError11.Name = '011';
        newError11.Error_Message__c = '011';
        errorList.add(newError11);
        ISSP_Int_Error__c newError12 = new ISSP_Int_Error__c();
        newError12.Name = '012';
        newError12.Error_Message__c = '012';
        errorList.add(newError12);
        ISSP_Int_Error__c newError13 = new ISSP_Int_Error__c();
        newError13.Name = '013';
        newError13.Error_Message__c = '013';
        errorList.add(newError13);
        ISSP_Int_Error__c newError14 = new ISSP_Int_Error__c();
        newError14.Name = '014';
        newError14.Error_Message__c = '014';
        errorList.add(newError14);
        ISSP_Int_Error__c newError15 = new ISSP_Int_Error__c();
        newError15.Name = '015';
        newError15.Error_Message__c = '015';
        errorList.add(newError15);
        ISSP_Int_Error__c newError16 = new ISSP_Int_Error__c();
        newError16.Name = '016';
        newError16.Error_Message__c = '016';
        errorList.add(newError16);
        ISSP_Int_Error__c newError17 = new ISSP_Int_Error__c();
        newError17.Name = '017';
        newError17.Error_Message__c = '017';
        errorList.add(newError17);
        ISSP_Int_Error__c newErrorA001 = new ISSP_Int_Error__c();
        newErrorA001.Name = 'A001';
        newErrorA001.Error_Message__c = 'A001';
        errorList.add(newErrorA001);
        ISSP_Int_Error__c newErrorA002 = new ISSP_Int_Error__c();
        newErrorA002.Name = 'A002';
        newErrorA002.Error_Message__c = 'A002';
        errorList.add(newErrorA002);
        ISSP_Int_Error__c newErrorA010 = new ISSP_Int_Error__c();
        newErrorA010.Name = 'A010';
        newErrorA010.Error_Message__c = 'A010';
        errorList.add(newErrorA010);
        ISSP_Int_Error__c newErrorA011 = new ISSP_Int_Error__c();
        newErrorA011.Name = 'A011';
        newErrorA011.Error_Message__c = 'A011';
        errorList.add(newErrorA011);
        ISSP_Int_Error__c newErrorA003 = new ISSP_Int_Error__c();
        newErrorA003.Name = 'A003';
        newErrorA003.Error_Message__c = 'A003';
        errorList.add(newErrorA003);
        ISSP_Int_Error__c newErrorA004 = new ISSP_Int_Error__c();
        newErrorA004.Name = 'A004';
        newErrorA004.Error_Message__c = 'A004';
        errorList.add(newErrorA004);
        ISSP_Int_Error__c newErrorA005 = new ISSP_Int_Error__c();
        newErrorA005.Name = 'A005';
        newErrorA005.Error_Message__c = 'A005';
        errorList.add(newErrorA005);
        ISSP_Int_Error__c newErrorA006 = new ISSP_Int_Error__c();
        newErrorA006.Name = 'A006';
        newErrorA006.Error_Message__c = 'A006';
        errorList.add(newErrorA006);
        ISSP_Int_Error__c newErrorA099 = new ISSP_Int_Error__c();
        newErrorA099.Name = 'A099';
        newErrorA099.Error_Message__c = 'A099';
        errorList.add(newErrorA099);
        ISSP_Int_Error__c newErrorA007 = new ISSP_Int_Error__c();
        newErrorA007.Name = 'A007';
        newErrorA007.Error_Message__c = 'A007';
        errorList.add(newErrorA007);
        ISSP_Int_Error__c newErrorA008 = new ISSP_Int_Error__c();
        newErrorA008.Name = 'A008';
        newErrorA008.Error_Message__c = 'A008';
        errorList.add(newErrorA008);
        ISSP_Int_Error__c newErrorA009 = new ISSP_Int_Error__c();
        newErrorA009.Name = 'A009';
        newErrorA009.Error_Message__c = 'A009';
        errorList.add(newErrorA009);
        
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