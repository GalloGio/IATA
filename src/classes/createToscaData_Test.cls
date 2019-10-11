@isTest
private class createToscaData_Test {


	@testSetup static void createData() {
		IATA_ISO_Country__c newgenCountry = new IATA_ISO_Country__c(name = 'United Kingdom',ISO_Code__c ='UK',ANG_Enable_NewGen__c = true);
        insert newgenCountry;
		
		IATA_ISO_State__c newgenState = new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=newgenCountry.Id, Name='London', ISO_Code__c='UK-LO');
		insert newgenState;

		IATA_ISO_Country__c amsCountry = new IATA_ISO_Country__c(name = 'Jamaica',ISO_Code__c ='PH',ANG_Enable_NewGen__c = false);
		insert amsCountry;

		IATA_ISO_State__c amsState = new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=amsCountry.Id, Name='Xe', ISO_Code__c='PH-LO');
		insert amsState;	
	}

    static testMethod void createToscaData_Test_Cash(){
        
        createToscaData_V2 toscaController = new createToscaData_V2();
            toscaController.qCountry = '--None--';
            toscaController.selectedTest = 'HE Cash';
            toscaController.usedEmail = 'test@tosca.com';
       	toscaController.createData();
        Test.startTest();
            toscaController.createOscarCase();            
        Test.stopTest();
    }

    static testMethod void createToscaData_Test_Cashless(){
    	
       	createToscaData_V2 toscaController = new createToscaData_V2();
        toscaController.qCountry = '--None--';
        toscaController.selectedTest = 'HE Cashless';
        toscaController.usedEmail = 'test@tosca.com';
        toscaController.isLimitedCompany = true;
        
        toscaController.createData();
       	
        Test.startTest();
            toscaController.createOscarCase();           
        Test.stopTest();
    }

    static testMethod void createToscaData_Test_HEStandard(){

        createToscaData_V2 toscaController = new createToscaData_V2();
        toscaController.qCountry = '--None--';
        toscaController.selectedTest = 'HE Standard';
        toscaController.usedEmail = 'test@tosca.com';
		
        toscaController.createData();
		
        Test.startTest();
            toscaController.createOscarCase();            
        Test.stopTest();
    }

    static testMethod void createToscaData_Test_HOPassenger(){
       
        createToscaData_V2 toscaController = new createToscaData_V2();
        toscaController.qCountry = '--None--';
        toscaController.selectedTest = 'HO Passenger';
        toscaController.usedEmail = 'test@tosca.com';
        
        toscaController.createData();
        
        Test.startTest();
            toscaController.createOscarCase();            
        Test.stopTest();
    }

    static testMethod void createToscaData_Test_HOTids(){

        createToscaData_V2 toscaController = new createToscaData_V2();
        toscaController.qCountry = '--None--';
        toscaController.selectedTest = 'HO TIDS';
        toscaController.usedEmail = 'test@tosca.com';
        
        toscaController.createData();
       	
        Test.startTest();
            toscaController.createOscarCase();            
        Test.stopTest();
    }

    static testMethod void createToscaData_Test_HOCargo(){
        createToscaData_V2 toscaController = new createToscaData_V2();
        //toscaController.deleteToscaUsers();
        toscaController.qCountry = '--None--';
        toscaController.selectedTest = 'HO Cargo';
        toscaController.usedEmail = 'test@tosca.com';
        
        toscaController.createData();
        
        Test.startTest();
            toscaController.createOscarCase();            
        Test.stopTest();
    }

    static testMethod void createToscaData_Test_DeleteToscaUsers(){
        Test.startTest();
            createToscaData_V2 toscaController = new createToscaData_V2();
            toscaController.deleteToscaUsers();                   
        Test.stopTest();
    }

   /*  static testMethod void getTestSelection(){
        Test.startTest();
            createToscaData_V2 toscaController = new createToscaData_V2();
            List<SelectOption> testSelection = toscaController.getTestSelection();
        Test.stopTest();
    }*/

  @isTest static void createToscaData_Test_generateIATACode(){
        
        ID accountRoleRt = AMS_Utils.AccountRoleOwnershipRT;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountRT =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

        Account parentAcc = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency');
        insert parentAcc;

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(STEP1__c = 'In Progress', Account__c = parentAcc.id);
        insert oscar;

        Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM);

            oscarCase.Financial_Assessment_requested__c = date.today();
            oscarCase.Deadline_Date__c= date.today();
            oscarCase.Assessment_Performed_Date__c= date.today();
            oscarCase.Financial_Review_Result__c = 'Satisfactory';
            oscarCase.Financial_Security_Amount__c = 1235;
            oscarCase.Financial_Security_Currency__c = 'EUR';
            oscarCase.FS_Deadline_Date__c = date.today();
        insert oscarCase;

        AMS_Pax_Accreditation_Form__c onlineAccreditation = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No'
            ,CurrencyIsoCode = isoc.CurrencyIsoCode
            ,SAAM_Case__c = oscarCase.Id
            ,Account_Name__c = parentAcc.Name);
        insert onlineAccreditation;

        Contact contact = ISSP_ObjectFactory.createNewContact();
            contact.FirstName = 'Tosca';
            contact.LastName = 'Contact 2';
            contact.AccountId = parentAcc.Id;   
        insert contact;

        AMS_Accreditation_Contact__c accContact = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id
            ,Company__c = parentAcc.id
            ,First_name__c='NameToUse'
            ,Last_name__c='Last'
            ,Job_title__c='ABC'
            ,Mobile__c='+4112345678'
            ,Phone__c='3424322343'
            ,Email__c='unique@email.com'
            ,Financial_interest__c = 100
            ,RecordTypeId=AMS_Utils.AccreditationContactPersonRT);
        insert accContact;

    oscar.AMS_Online_Accreditation__c = onlineAccreditation.Id;
    update oscar;

     /******************* needs fixing  ***
     AmazonFile__c aFile = new AmazonFile__c(
		        	Full_Name_Unique__c = 'test name',
		        	Case__c = oscarCase.Id
		    	);
    insert aFile;
	*****************/
     
    system.debug(LoggingLevel.ERROR,'aqui oscar test ' + oscar);


        Test.startTest();
            createToscaData_V2 toscaController = new createToscaData_V2();                                      
            toscaController.oscarCase = oscarCase;
            toscaController.oscar = oscar;
            toscaController.parentAcc = parentAcc;
            toscaController.contact = contact;
            toscaController.theAccreditation = onlineAccreditation;
            toscaController.accreditationContact = accContact;
            
      /*** requires AmazonFile__c to be fixed ***/      
      //toscaController.generateIATACode();
            

        Test.stopTest();
    }





    static testMethod void createToscaData_Test2(){
        Id agencyRecTypeId = AMS_Utils.RECTYPE_IATAAGENCY;
         Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'];

        Account a = new Account(Name = 'Tosca Account Test - 2', RecordTypeId = agencyRecTypeId, IATACode__c = '1234567');
        insert a;

        Contact contact = ISSP_ObjectFactory.createNewContact();
        Contact.FirstName = 'Tosca';
        Contact.LastName = 'Contact 2';
        contact.AccountId = a.Id; 
        insert contact;

        User testUser = New User(

            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01', ContactId = contact.Id
        );
        insert testUser;

        ANG_Risk_Event_Type__c riskType = new ANG_Risk_Event_Type__c(Name = 'Auth. Cash Payment', ANG_Risk_Id__c = '99', ANG_Expiration__c = 24);
        insert riskType;

        Test.startTest();
            createToscaData_V2 toscaController = new createToscaData_V2();
            toscaController.selectedTest = 'HE Cash with multiple hierarchy';
            toscaController.usedEmail = 'test3@tosca.com';
            toscaController.createData();     
        Test.stopTest();
    }


        static testMethod void createToscaData_Test3(){
        Test.startTest();
        createToscaData_V2 toscaController = new createToscaData_V2();
            toscaController.deleteToscaUsers();
        Test.stopTest();
    }

    static testMethod void createToscaData_Test4(){
        Id agencyRecTypeId = AMS_Utils.RECTYPE_IATAAGENCY;
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'];

        Account a = new Account(Name = 'Tosca Account Test - 2', RecordTypeId = agencyRecTypeId, IATACode__c = '1234567');
        insert a;

        Contact contact = ISSP_ObjectFactory.createNewContact();
        Contact.FirstName = 'Tosca';
        Contact.LastName = 'Contact 2';
        contact.AccountId = a.Id;   
        insert contact;

        User testUser = New User(

            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01', ContactId = contact.Id
        );
        insert testUser;

        ANG_Risk_Event_Type__c riskType = new ANG_Risk_Event_Type__c(Name = 'Auth. Cash Payment', ANG_Risk_Id__c = '99', ANG_Expiration__c = 24);
        insert riskType;

        Test.startTest();
            createToscaData_V2 toscaController = new createToscaData_V2();
            toscaController.selectedTest = 'HE Risk with Sidra Lite Case';
            toscaController.usedEmail = 'test2@tosca.com';
            toscaController.createData();

            
        Test.stopTest();
    }


    static testMethod void createToscaData_Test5(){
        Id agencyRecTypeId = AMS_Utils.RECTYPE_IATAAGENCY;
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'];

        Account a = new Account(Name = 'Tosca Account Test - 2', RecordTypeId = agencyRecTypeId, IATACode__c = '1234567');
        insert a;

        Contact contact = ISSP_ObjectFactory.createNewContact();
        Contact.FirstName = 'Tosca';
        Contact.LastName = 'Contact 2';
        contact.AccountId = a.Id;   
        insert contact;

        User testUser = New User(

            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01', ContactId = contact.Id
        );
        insert testUser;

        ANG_Risk_Event_Type__c riskType = new ANG_Risk_Event_Type__c(Name = 'Auth. Cash Payment', ANG_Risk_Id__c = '99', ANG_Expiration__c = 24);
        insert riskType;

        Test.startTest();
            createToscaData_V2 toscaController = new createToscaData_V2();
            toscaController.selectedTest = 'HE Risk with Sidra Lite Case Risk Status B';
            toscaController.usedEmail = 'test2@tosca.com';
            toscaController.createData();
        Test.stopTest();
    }
    
    static testMethod void createToscaData_Test6_noEmail(){
        try{
            Test.startTest();
                createToscaData_V2 toscaController = new createToscaData_V2();
                toscaController.selectedTest = 'Child Account';
                toscaController.usedEmail = '';
                toscaController.createData();		
            Test.stopTest();
        }
        catch(Exception e){ 
            Boolean expectedExceptionThrown = e.getMessage().contains('Please fill the email to be used'); 
            System.AssertEquals(true, expectedExceptionThrown);      
		}
    }
    
    static testMethod void createToscaData_Test7_noParentId(){
        try{
            Test.startTest();
                createToscaData_V2 toscaController = new createToscaData_V2();
                toscaController.selectedTest = 'Child Account';
                toscaController.usedEmail = 'test2@tosca.com';
                toscaController.createData();		
            Test.stopTest();
        }
        catch(Exception e){ 
            Boolean expectedExceptionThrown = e.getMessage().contains('Please fill the parent account with the IATA code of the Account to be used has a Parent or Risk Account'); 
            System.AssertEquals(true, expectedExceptionThrown);      
		}
    }
    
    
    static testMethod void createToscaData_Test8_createRiskEvent(){
     
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountRT =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        
        Account parentAcc = new Account(IATA_ISO_Country__c = ctry.id, 
                                        RecordTypeId = accountRT, 
                                        IATACode__c='1234567',
                                        Name='Test1 Agency',
                                        Short_Name__c='Test1 Agency');
        insert parentAcc;
        
        Test.startTest();
            createToscaData_V2 toscaController = new createToscaData_V2();
            toscaController.selectedTest = 'Create Risk Event';
            toscaController.usedEmail = 'test2@tosca.com';
            toscaController.qCountry = '--None--';
            toscaController.parentAccount = parentAcc.Id;
        	toscaController.country = ctry;
            toscaController.createData();
        	toscaController.createOscar();
        Test.stopTest();
    }
    
    
    static testMethod void createToscaData_Test9_ParentHE(){

        IATA_ISO_Country__c ctry = [SELECT Id, ISO_Code__c, ANG_Enable_NewGen__c, Name FROM IATA_ISO_Country__c WHERE name = 'United Kingdom' LIMIT 1];
       
        Id accountRT =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        
        Account parentAcc = new Account(IATA_ISO_Country__c = ctry.id,
                                        RecordTypeId = accountRT,
                                        IATACode__c='1234567',
                                        Name='Test1 Agency',
                                        Short_Name__c='Test1 Agency',
                                       	Location_Type__c = 'HE',
                                       	Location_Class__c = 'P');
        insert parentAcc;
        
        Test.startTest();
            createToscaData_V2 toscaController = new createToscaData_V2();
            toscaController.selectedTest = 'Child Account';
            toscaController.usedEmail = 'test2@tosca.com';
            toscaController.qCountry = '--None--';
			toscaController.parentAccount = parentAcc.IATACode__c;
            toscaController.createData();
        	toscaController.createOscar();
        	toscaController.createCaseOscarCommunication();
        	toscaController.createAccreditationForm();
        Test.stopTest();
    }
    
    static testMethod void createToscaData_Test10_ParentHO(){

        IATA_ISO_Country__c ctry = [SELECT Id, ISO_Code__c, ANG_Enable_NewGen__c, Name FROM IATA_ISO_Country__c WHERE name = 'United Kingdom' LIMIT 1];
       
        Id accountRT =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        
        Account parentAcc = new Account(IATA_ISO_Country__c = ctry.id,
                                        RecordTypeId = accountRT,
                                        IATACode__c='1234567',
                                        Name='Test1 Agency',
                                        Short_Name__c='Test1 Agency',
                                       	Location_Type__c = 'HO',
                                       	Location_Class__c = 'C',
                                       	Sector__c = 'Cargo Agent',
                                       	Reason_for_creation__c = 'New agent'
                                       	);
        insert parentAcc;
        
        Test.startTest();
            createToscaData_V2 toscaController = new createToscaData_V2();
            toscaController.selectedTest = 'Child Account';
            toscaController.usedEmail = 'test2@tosca.com';
            toscaController.qCountry = '--None--';
			toscaController.parentAccount = parentAcc.IATACode__c;
            toscaController.createData();
        	toscaController.createOscar();
        	toscaController.createCaseOscarCommunication();
        	toscaController.createAccreditationForm();
        Test.stopTest();
    }
    
     static testMethod void createToscaData_Test11_ParentBR(){

        IATA_ISO_Country__c ctry = [SELECT Id, ISO_Code__c, ANG_Enable_NewGen__c, Name FROM IATA_ISO_Country__c WHERE name = 'United Kingdom' LIMIT 1];
       
        Id accountRT =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        
        Account parentParentAcc =  new Account(Name = 'tosca Test',
                                              Location_Type__c = 'HO',
                                              Sector__c = AMS_Utils.SECTOR_PASSENGER,
                                              Category__c = AMS_Utils.CATEGORY_TOUR_OPERATOR);
        insert parentParentAcc;
         
        Account parentAcc = new Account(IATA_ISO_Country__c = ctry.id,
                                        RecordTypeId = accountRT,
                                        IATACode__c='1234567',
                                        Name='Test1 Agency',
                                        Short_Name__c='Test1 Agency',
                                       	Location_Type__c = 'BR',
                                       	Location_Class__c = 'M',
                                       	Sector__c = AMS_Utils.SECTOR_PASSENGER,
                                        Category__c = AMS_Utils.CATEGORY_TOUR_OPERATOR,
                                       	Reason_for_creation__c = 'New agent',
                                       	ParentId = parentParentAcc.Id,
                                       	CASS_Number__C = '123');
        insert parentAcc;
        
        Test.startTest();
            createToscaData_V2 toscaController = new createToscaData_V2();
            toscaController.selectedTest = 'Child Account';
            toscaController.usedEmail = 'test2@tosca.com';
            toscaController.qCountry = '--None--';
			toscaController.parentAccount = parentAcc.IATACode__c;
            toscaController.createData();
         	toscaController.createOscar();
         	toscaController.createCaseOscarCommunication();
        	toscaController.createAccreditationForm();
        Test.stopTest();
    }
    
    /*
    static testMethod void createToscaData_Test12(){
        
        Test.startTest();
            createToscaData_V2 toscaController = new createToscaData_V2();
            toscaController.createOscarCase();
        Test.stopTest();
    }*/
}