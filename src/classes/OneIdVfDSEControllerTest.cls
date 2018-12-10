/**
 * Created by Manuel Conde on 14/03/2017.
 */
@IsTest
private class OneIdVfDSEControllerTest {

    public static testMethod void OneIdRegistration_test1() {

        OneIdVfDSEControllerTest.createTestData();

        IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        IATA_ISO_Country__c ISO_Country2 = new IATA_ISO_Country__c(ISO_Code__c='TP',Name='test2');
        insert ISO_Country2;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.Airline_designator__c = 'TT';
        insert acc;

        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.Email = 'test.issp.registration@testisspregistration.com';
        con.RecordTypeId = rtId;
        insert con;

        System.assert(con.id !=null,'Contact must be created');
        User newUser = new User(alias = 'dsfsdfds',
                email = con.email,
                emailencodingkey = 'UTF-8',
                firstname = con.firstName,
                lastname = con.lastname,
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                contactId = con.Id,
                timezonesidkey = 'Asia/Dubai',
                Username = ISSP_Utilities.buildPortalUserName(con.email),
                PortalRole = 'Manager',
                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                IsActive = true);
        //insert newUser;



        OneIdVfDSEController ctrl = new OneIdVfDSEController();
        ctrl.con = con;

        ctrl.con.email = '';

        ctrl.con.email = 'test.issp.registration@testisspregistration.com';
        ctrl.con.lastname = 'test';


        ctrl.getISOCountry();
        ctrl.isAgency =false;
        ctrl.isGSA =false;
        ctrl.isNotIATA =false;
        ctrl.isOther =false;
        ctrl.isTIESS =false;
        ctrl.isGeneral =false;



        ctrl.searchCountryAirline = ISO_Country.Id;
        ctrl.searchCountry = ISO_Country.Id;
        ctrl.searchDesignatorCode = 'TP';
        ctrl.searchAccount();
        ctrl.searchDesignatorCode = 'TT';
        ctrl.searchAccount();
        ctrl.searchIATACodeAirline = '10';
        ctrl.searchAccount();
        ctrl.searchIATACodeAirline = '101';
        ctrl.searchAccount();
        ctrl.searchIATACodeAirline = '100';
        ctrl.searchAccount();
        ctrl.register();

        ctrl.isAirline = true;
        ctrl.toSearchDesignatorCode = true;
        ctrl.searchAccount();

        ctrl.getRecordTypeCode('NonIATAAgent');
        ctrl.findLocation();
        ctrl.selectType();
        ctrl.getCustomerTypeList();
        ctrl.getCargoTravelOptions();
        ctrl.cargoTravel='Cargo';
        ctrl.checkAgencyType();
        ctrl.cargoTravel='Travel';
        ctrl.checkAgencyType();
        ctrl.getIataCodeQuestion();

        ctrl.isAgency = true;
        ctrl.searchAccount();
        ctrl.backToAccountPage();
        ctrl.backToContactPage();
    }

    public static testMethod void OneIdRegistration_test00() {

        HttpResponseGenerator generator = new HttpResponseGenerator();
        System.Test.setMock(HttpCalloutMock.class, generator);

        OneIdVfDSEControllerTest.createTestData();

        IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c = 'TT', Name = 'test');
        insert ISO_Country;

        IATA_ISO_Country__c ISO_Country2 = new IATA_ISO_Country__c(ISO_Code__c = 'TP', Name = 'test2');
        insert ISO_Country2;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.Airline_designator__c = 'TT';
        acc.billingstate = 'Test';
        acc.shippingstate = 'Test';
        acc.name = 'Test';
        insert acc;

        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.Email = 'test.issp.registration@testisspregistration.com';
        con.RecordTypeId = rtId;
        insert con;

        OneIdVfDSEController ctrl = new OneIdVfDSEController();
        ctrl.searchCompanyName = 'Test';
        ctrl.getISOCountry();
        ctrl.isAgency =false;
        ctrl.isGSA =false;
        ctrl.isNotIATA =false;
        ctrl.isOther =false;
        ctrl.isTIESS =false;
        ctrl.isGeneral =false;
        ctrl.selectType();
        ctrl.con = con;
        ctrl.acc = acc;
        ctrl.accountFound = false;
        ctrl.isNotIATA = true;
        ctrl.isAirline = true;
        ctrl.searchCountry = ISO_Country.Id;
        ctrl.selectedCustomerType = 'Airline';
        ctrl.register();
        ctrl.searchDesignatorCode = 'TT';
        ctrl.searchCountryAirline = ISO_Country.Id;
        ctrl.searchCountry = ISO_Country.Id;
        ctrl.toSearchDesignatorCode = true;
        ctrl.searchIATACodeAirline = '100';
        ctrl.searchAccount();
        ctrl.selectType();
        ctrl.getRecordTypeCode('a');
        ctrl.isOther = true;
        ctrl.selectedCustomerType = 'OtherCompany';
        ctrl.searchCountry = ISO_Country.Id;
        ctrl.searchAccount();
        ctrl.getRecordTypeCode('a');
        ctrl.isGeneral = true;
        ctrl.selectType();
        ctrl.selectedCustomerType = 'GloballSalesAgent';
        ctrl.searchCountry = ISO_Country.Id;
        ctrl.searchAccount();
        ctrl.selectType();
        ctrl.selectedCustomerType = 'TIESS';
        ctrl.searchCountry = ISO_Country.Id;
        ctrl.searchAccount();



    }
    public static testMethod void TestPageReg() {

        
        OneIdVfDSEControllerTest.createTestData();

        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;

        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.Email = 'test.issp.registration@testisspregistration.com';
        con.RecordTypeId = rtId;
        insert con;

        System.assert(con.id !=null,'Contact must be created');
        User newUser = new User(alias = 'dsfsdfds',
                email = con.email,
                emailencodingkey = 'UTF-8',
                firstname = con.firstName,
                lastname = con.lastname,
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                contactId = con.Id,
                timezonesidkey = 'Asia/Dubai',
                Username = ISSP_Utilities.buildPortalUserName(con.email),
                PortalRole = 'Manager',
                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                IsActive = true);
        //insert newUser;

        PageReference pageRef = Page.OneIdVfDSE;
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('lang', 'en_US');
        ApexPages.currentPage().getParameters().put('language', 'en_US');
        ApexPages.currentPage().getParameters().put('Accept-Language', 'en_US');        

        OneIdVfDSEController ctrl = new OneIdVfDSEController();
        String langd = ctrl.lang;

        ctrl.con = con;


        ctrl.con.email = '';


        ctrl.con.email = 'test.issp.registration@testisspregistration.com';
        ctrl.con.lastname = 'test';


        IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        IATA_ISO_Country__c ISO_Country2 = new IATA_ISO_Country__c(ISO_Code__c='TP',Name='test2');
        insert ISO_Country2;
        ctrl.getISOCountry();
        ctrl.isAgency =false;
        ctrl.isGSA =false;
        ctrl.isNotIATA =false;
        ctrl.isOther =false;
        ctrl.isTIESS =false;
        ctrl.isGeneral =false;



        ctrl.searchCountryAirline = ISO_Country.Id;
        ctrl.searchCountry = ISO_Country.Id;
        ctrl.searchDesignatorCode = 'TP';
        ctrl.searchAccount();
        ctrl.searchDesignatorCode = 'TT';
        ctrl.searchAccount();
        ctrl.searchIATACodeAirline = '10';
        ctrl.searchAccount();
        ctrl.searchIATACodeAirline = '101';
        ctrl.searchAccount();
        ctrl.searchIATACodeAirline = '100';
        ctrl.searchAccount();
        ctrl.register();

        ctrl.isAirline = true;
        ctrl.toSearchDesignatorCode = true;
        ctrl.searchAccount();

        ctrl.getRecordTypeCode('NonIATAAgent');
        ctrl.findLocation();
        ctrl.selectType();
        
        ctrl.selectedCustomerType = 'Airline';
        ctrl.selectType();

        ctrl.selectedCustomerType = 'Agency';
        ctrl.selectType();

        ctrl.selectedCustomerType = 'GloballSalesAgent';
        ctrl.selectType();
        
        ctrl.selectedCustomerType = 'TIESS';
        ctrl.selectType();
        
        ctrl.selectedCustomerType = 'NonIATAAgent';
        ctrl.selectType();
        
        ctrl.selectedCustomerType = 'OtherCompany';
        ctrl.selectType();
        
        ctrl.selectedCustomerType = 'GeneralPublic';
        ctrl.selectType();                        


        ctrl.getCustomerTypeList();
        ctrl.getCargoTravelOptions();
        ctrl.cargoTravel='Cargo';
        ctrl.checkAgencyType();
        ctrl.cargoTravel='Travel';
        ctrl.checkAgencyType();
        ctrl.getIataCodeQuestion();
        ctrl.checkSearchDesignatorCode();
        ctrl.toSearchDesignatorCodeString = 'Yes';
        ctrl.checkSearchDesignatorCode();
        ctrl.checkSearchIataCode();
        ctrl.toSearchIataCodeString = 'Yes';
        ctrl.checkSearchIataCode();        

        ctrl.isAgency = true;
        ctrl.searchAccount();
        OneIdVfDSEController.getHostURL();
        Contact aC = new Contact(email='sss@ddd.pt');
        ctrl.setConStr(JSON.serialize(aC));
        ctrl.PassingTheContact();
        ctrl.getConStr();
    }
    
    
    public static testMethod void TestPageRegFind() {
        
        OneIdVfDSEControllerTest.createTestData();
        
        PageReference pageRef = Page.OneIdVfDSE;
        
        Test.setCurrentPage(pageRef);
        
        Cookie cookie1 = new Cookie('lang','lang',null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{cookie1 });       

        OneIdVfDSEController ctrl = new OneIdVfDSEController();
        String langd = ctrl.lang;     
     
    }
    public static testMethod void TestPageRegFind2() {
        
        OneIdVfDSEControllerTest.createTestData();
        
        PageReference pageRef = Page.OneIdVfDSE;
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('Accept-Language', 'en_US,en_UK');                    

        OneIdVfDSEController ctrl = new OneIdVfDSEController();
        String langd = ctrl.lang;     
     
    } 
   public static testMethod void TestPageRegFind3() {
        
        OneIdVfDSEControllerTest.createTestData();
        
        PageReference pageRef = Page.OneIdVfDSE;
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getHeaders().put('Accept-Language', 'en_US,en_UK');                    

        OneIdVfDSEController ctrl = new OneIdVfDSEController();
        String langd = ctrl.lang;     
     
    }   
   public static testMethod void TestPageRegFind4() {
        
        OneIdVfDSEControllerTest.createTestData();
        
        PageReference pageRef = Page.OneIdVfDSE;
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getHeaders().put('Accept-Language', ' ');                    

        OneIdVfDSEController ctrl = new OneIdVfDSEController();
        String langd = ctrl.lang;     
     
    }    
    
 public static testMethod void TestSearchAccount1() {

        
        OneIdVfDSEControllerTest.createTestData();

        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;

        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.Email = 'test.issp.registration@testisspregistration.com';
        con.RecordTypeId = rtId;
        insert con;

        System.assert(con.id !=null,'Contact must be created');
        User newUser = new User(alias = 'dsfsdfds',
                email = con.email,
                emailencodingkey = 'UTF-8',
                firstname = con.firstName,
                lastname = con.lastname,
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                contactId = con.Id,
                timezonesidkey = 'Asia/Dubai',
                Username = ISSP_Utilities.buildPortalUserName(con.email),
                PortalRole = 'Manager',
                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                IsActive = true);
        //insert newUser;

        PageReference pageRef = Page.OneIdVfDSE;
        
        Test.setCurrentPage(pageRef);

        OneIdVfDSEController ctrl = new OneIdVfDSEController();
        
        
        IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        IATA_ISO_Country__c ISO_Country2 = new IATA_ISO_Country__c(ISO_Code__c='TP',Name='test2');
        insert ISO_Country2;
        

        ctrl.isAgency =false;
        ctrl.isGSA =false;
        ctrl.isNotIATA =false;
        ctrl.isOther =false;
        ctrl.isTIESS =false;
        ctrl.isGeneral =false;
        
        ctrl.getISOCountry();

        ctrl.searchCountryAirline = ISO_Country.Id;
        ctrl.searchCountry = ISO_Country.Id;        
        
        ctrl.isAirline = true;
        ctrl.searchIATACodeAirline = '10';
        ctrl.toSearchDesignatorCode = true;
        ctrl.searchAccount();
        ctrl.searchIATACodeAirline = 'AAA';
        ctrl.searchAccount();
        
    }         
    public static testMethod void TestSearchAccount2() {

        IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        IATA_ISO_Country__c ISO_Country2 = new IATA_ISO_Country__c(ISO_Code__c='TP',Name='test2');
        insert ISO_Country2;

        OneIdVfDSEControllerTest.createTestData();
		List<Account> anListAct = new List<Account>();
		
		List<String> recTypesNamesLst = new List<String>
		{ 	 
			 'Others',
			 'IATA_Airline', 
			 'Standard_Account', 
			 'IATA_Agency', 
			 'IATA'
		};
		
		List<Id> recordTypesIdLst = RecordTypeSingleton.getInstance().getRecordTypeObjIdListForSpecfifiedNames('Account', recTypesNamesLst);
		
        for(Id rtId : recordTypesIdLst){
        	Account acc = ISSP_ObjectFactory.createNewAccount();
            acc.RecordTypeId = rtId;
            acc.IATA_ISO_Country__c = ISO_Country.id;
            anListAct.add(acc);
        }
        
        insert anListAct;

        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = anListAct[0].Id;
        con.LastName = 'test';
        con.Email = 'test.issp.registration@testisspregistration.com';
        con.RecordTypeId = rtId;
        insert con;

        System.assert(con.id !=null,'Contact must be created');
        User newUser = new User(alias = 'dsfsdfds',
                email = con.email,
                emailencodingkey = 'UTF-8',
                firstname = con.firstName,
                lastname = con.lastname,
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                contactId = con.Id,
                timezonesidkey = 'Asia/Dubai',
                Username = ISSP_Utilities.buildPortalUserName(con.email),
                PortalRole = 'Manager',
                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                IsActive = true);
        //insert newUser;

        PageReference pageRef = Page.OneIdVfDSE;
        
        Test.setCurrentPage(pageRef);

        OneIdVfDSEController ctrl = new OneIdVfDSEController();
        
        ctrl.isAgency =true;
        ctrl.isGSA =false;
        ctrl.isNotIATA =false;
        ctrl.isOther =false;
        ctrl.isTIESS =false;
        ctrl.isGeneral =false;
        
        ctrl.getISOCountry();
		ctrl.searchCompanyName = anListAct[0].name;
        ctrl.searchCountryAirline = ISO_Country.Id;
        ctrl.searchCountry = ISO_Country.Id;        
        
        ctrl.isAirline = false;
        ctrl.isCargo = true;
        ctrl.searchIATACodeAirline = '10';
        ctrl.toSearchDesignatorCode = true;
        ctrl.searchAccount();
        ctrl.searchIATACodeAirline = 'AAA';
        ctrl.searchAccount();
        ctrl.isTravel = false;
        ctrl.searchAccount();
        
        ctrl.isCargo = false;
        ctrl.isTravel = true;
        ctrl.searchIATACode= '10222222222';        
        ctrl.searchAccount();        

        ctrl.isCargo = true;
        ctrl.isTravel = false;
        ctrl.searchIATACodeAirline = '10222222222';        
        ctrl.searchAccount();

        ctrl.isAgency = true;
        ctrl.isCargo = true;
        ctrl.isTravel = false;
        ctrl.searchIATACode = 'qqqqqqqq';
        ctrl.searchIATACodeAirline = 'AAAAAAAA';
        ctrl.searchAccount();

        ctrl.isCargo = false;
        ctrl.isTravel = false;
        ctrl.searchIATACode= '1022222222';        
        ctrl.searchAccount();  

        ctrl.isCargo = false;
        ctrl.isTravel = false;
        ctrl.isOther = true;
        ctrl.searchIATACode= '1022222222';        
        ctrl.searchAccount();  

        
        ctrl.accList.add(anListAct[0]);     
        ctrl.nextAsGP();           

    }         

    public static void createTestData(){

        List<ISSP_CS__c> csList = new List<ISSP_CS__c>();

        ISSP_CS__c cs1x = new ISSP_CS__c();
        cs1x.Name = 'ipinfo_token';
        cs1x.Value__c = UserInfo.getUserId();
        csList.add(cs1x);

        ISSP_CS__c cs1 = new ISSP_CS__c();
        cs1.Name = 'DefaultNewAccountOwnerId';
        cs1.Value__c = UserInfo.getUserId();                        
        csList.add(cs1);
        
        ISSP_CS__c cs2 = new ISSP_CS__c();
        cs2.Name = 'Host';
        cs2.Value__c = 'test';
        csList.add(cs2);

        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name LIKE 'ISS%'];
        for (Profile thisProfile : profileList){
            ISSP_CS__c newCS = new ISSP_CS__c();
            newCS.Value__c = thisProfile.Id;
            if (thisProfile.Name == 'ISS Portal (Partner)'){
                newCS.Name = 'ISS_Portal';
                csList.add(newCS);
            }
            else if (thisProfile.Name == 'ISS Portal Agency Delegated Admin User'){
                newCS.Name = 'ISS_Portal_Agency_Delegated_Admin';
                csList.add(newCS);
            }
            else if (thisProfile.Name == 'ISS Portal Agency User (Partner)'){
                newCS.Name = 'ISS_Portal_Agency_User';
                csList.add(newCS);
            }
            else if (thisProfile.Name == 'ISS Portal Airline Delegated Admin User'){
                newCS.Name = 'ISS_Portal_Airline_Delegated_Admin';
                csList.add(newCS);
            }
            else if (thisProfile.Name == 'ISS Portal Airline User (Partner)'){
                newCS.Name = 'ISS_Portal_Airline_User';
                csList.add(newCS);
            }
            else if (thisProfile.Name == 'ISS Portal Delegated Admin User'){
                newCS.Name = 'ISS_Portal_Delegated_Admin';
                csList.add(newCS);
            }
            else if (thisProfile.Name == 'ISS Portal GSA Delegated Admin User'){
                newCS.Name = 'ISS_Portal_GSA_Delegated_Admin';
                csList.add(newCS);
            }
            else if (thisProfile.Name == 'ISS Portal GSA User (Partner)'){
                newCS.Name = 'ISS_Portal_GSA_User';
                csList.add(newCS);
            }
        }
        insert csList;
    }

    public static testMethod void isspRegistration_test6() {
        
        OneIdVfDSEControllerTest.createTestData();
        
        IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;
        
        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.Airline_designator__c = 'TT';
        acc.Name = 'TestAccount';
        insert acc;

         Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.Email = 'test.issp.registration@testisspregistration.com';
        con.RecordTypeId = rtId;
        insert con;

        System.assert(con.id !=null,'Contact must be created');
        User newUser = new User(alias = 'dsfsdfds',
                email = con.email,
                emailencodingkey = 'UTF-8',
                firstname = con.firstName,
                lastname = con.lastname,
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                contactId = con.Id,
                timezonesidkey = 'Asia/Dubai',
                Username = ISSP_Utilities.buildPortalUserName(con.email),
                PortalRole = 'Manager',
                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                IsActive = true);
        insert newUser;        
        
        OneIdVfDSEController ctrl = new OneIdVfDSEController();

      
        
        ctrl.con.email = 'sasa@dd.pt';

        
        ctrl.con.email = 'test.issp.registration@testisspregistration.com';
        ctrl.con.lastname = 'test';

        
        //ctrl.submitContact();
        
        ctrl.getISOCountry();
        ctrl.getCustomerTypeList();
        ctrl.getCargoTravelOptions();
        ctrl.getIataCodeQuestion();
        ctrl.selectedCustomerType = 'Airline';
        ctrl.selectType();
        ctrl.toSearchDesignatorCodeString = 'No';
        ctrl.checkSearchDesignatorCode();
        ctrl.searchCountry = ISO_Country.Id;
        ctrl.searchCompanyName = 'bla';
        ctrl.searchAccount();
        ctrl.register();
    }

    public static testMethod void OneIdRegistration_test01() {

        HttpResponseGenerator generator = new HttpResponseGenerator();
        System.Test.setMock(HttpCalloutMock.class, generator);

        OneIdVfDSEControllerTest.createTestData();

        IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c = 'TT', Name = 'test');
        insert ISO_Country;

        IATA_ISO_Country__c ISO_Country2 = new IATA_ISO_Country__c(ISO_Code__c = 'TP', Name = 'test2');
        insert ISO_Country2;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.Airline_designator__c = 'TT';
        acc.billingstate = 'Test';
        acc.shippingstate = 'Test';
        acc.name = 'Test';
        insert acc;

        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.Email = 'test.issp.registration@testisspregistration.com';
        con.RecordTypeId = rtId;
        insert con;

        OneIdVfDSEController ctrl = new OneIdVfDSEController();
        ctrl.searchCompanyName = 'Test';
        ctrl.getISOCountry();
        ctrl.isAgency =false;
        ctrl.isGSA =false;
        ctrl.isNotIATA =false;
        ctrl.isOther =false;
        ctrl.isTIESS =false;
        ctrl.isGeneral =false;
        ctrl.selectType();
        ctrl.con = con;
        ctrl.acc = acc;
        ctrl.accountFound = false;
        ctrl.isNotIATA = true;
        ctrl.isAirline = true;
        ctrl.searchCountry = ISO_Country.Id;
        ctrl.selectedCustomerType = 'Airline';
        ctrl.register();
        ctrl.searchDesignatorCode = 'TT';
        ctrl.searchCountryAirline = ISO_Country.Id;
        ctrl.searchCountry = ISO_Country.Id;
        ctrl.toSearchDesignatorCode = true;
        ctrl.searchIATACodeAirline = '100';
        ctrl.searchAccount();
        ctrl.selectType();
        ctrl.getRecordTypeCode('a');
        ctrl.isOther = true;
        ctrl.selectedCustomerType = 'OtherCompany';
        ctrl.searchCountry = ISO_Country.Id;
        ctrl.searchAccount();
        ctrl.getRecordTypeCode('a');
        ctrl.isGeneral = true;
        ctrl.selectType();
        ctrl.selectedCustomerType = 'GloballSalesAgent';
        ctrl.searchCountry = ISO_Country.Id;
        ctrl.searchAccount();
        ctrl.selectType();
        ctrl.selectedCustomerType = 'TIESS';
        ctrl.searchCountry = ISO_Country.Id;
        ctrl.searchAccount();
    }
}