/*
    Class Name: ISSP_AMC_ParticipationFactory
    Related Classes: ISSP_AMC_ParticipationFactory_Test

    Copyright @Right IT Services

    Purpose: 

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         DAVID BENTO & TIAGO MENDES    31-12-2018              INITIAL DEVELOPMENT
*/
public with sharing class ISSP_AMC_ParticipationFactory {

    /*
        Purpose: Creates a portal User
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
    public static User portalSetup(){
        //Create portal account owner
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + Math.random() + 'test2@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            License_Cost_Center__c = 'ISF005CH01'
        );
        Database.insert(portalAccountOwner1);

        //create Country
        /*IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
            IATA_COUNTRY_EN__c = 'test', IATA_Country_FR__c = 'test', IATA_Country_ZH__c = 'test',
            IATA_Country_IT__c = 'test', IATA_Country_JP__c = 'test', ISO_Code__c = 'EN',
            IATA_Country_PT__c = 'test', IATA_Country_SP__c = 'test', Case_BSP_Country__c = 'test');
        insert country;

        //parent account(ISSP_AMC_Home_Test)
        Account parentAccount = new Account(                        // HOME
            Name = 'TestAccount2',
            OwnerId = portalAccountOwner1.Id,
            IATA_ISO_Country__c = country.Id,
            RecordType = [SELECT Name,id from RecordType WHERE Name = 'Airline Headquarters'][0]
        );
        Database.insert(parentAccount);*/

        //Create account
        Account portalAccount1 = new Account(
            Name = 'TestAccount',
            //Top_Parent__c = parentAccount.Id,
            OwnerId = portalAccountOwner1.Id,
            RecordType = [SELECT Name,id from RecordType WHERE Name = 'Airline Headquarters'][0]
        );
        Database.insert(portalAccount1);

        
                
        //Create contact
        Contact contact1 = new Contact(
            FirstName = 'Test',
            //User_Portal_Status__c = 'Administrator',
            Lastname = 'McTesty',
            AccountId = portalAccount1.Id,
            Email = System.now().millisecond() + 'test@test.com',
            RecordType = [SELECT Name,id from RecordType WHERE Name = 'Standard'][0]
        );
        Database.insert(contact1);
                
        //Create user
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE 'ISS Portal Airline Delegated Admin User' Limit 1];
        User user1 = new User(
            Username = System.now().millisecond() + Math.random() + 'test12345@test.com',
            ContactId = contact1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        Database.insert(user1);

        return user1;
    }

    /*
        Purpose: Creates and upload files to the junction object and is tested alongside the controller
        Parameters: ISSP_AMC_Location_Identifier
        Returns: User
        Throws [Exceptions]: 
    */
    public static void testLocationUploadFiles(ISSP_AMC_Location_Identifier controller){
        List <Participant_Online_App_Requirement__c> reqList = [SELECT Id,Name,Participation_Application_Requirement__r.Type_of_Requirement__c FROM Participant_Online_App_Requirement__c WHERE Participation_Online_Application__c= :controller.participation.Id AND Participation_Application_Requirement__r.Type_of_Requirement__c = 'Attachment'];
        System.debug('REQLIST size' + reqList);
        System.debug('REQLIST size' + reqList.size());
        List <AmazonFile__c> filesList = new List<AmazonFile__c>();

        
        WrapperAttachTest.loadTestCredentials();


        String parentId = controller.participation.case__c;
        Long filesize = 100;
        String amazonKey = 'path/'+Math.random()+'testfileName.pdf';
        String fileName='ICE POP';
        RecordTypeInfo rtInfo = Schema.SObjectType.AmazonFile__c.getRecordTypeInfosByName().get('File');
        Id RTId = rtInfo.getRecordTypeId();
        System.debug('RTId' + RTId);
        AmazonFile__c azFile;
        for(Participant_Online_App_Requirement__c req : reqList){
            
            if(req.Participation_Application_Requirement__r.Type_of_Requirement__c == 'Attachment'){
                azFile = new AmazonFile__c(
                                    Name='ICE POP',
                                    RecordTypeId = RTId,
                                    Case__c =controller.participation.case__c,
                                    Full_Name_Unique__c = '001/'+controller.participation.case__c+Math.random()+'/ICE POP'
                            );
                insert azFile;
                UploadFileToAmazonButtonCtrl.createAmazonFileObject(amazonKey, filesize, parentId, azFile);
                //ISSP_AMC_DAO.saveAmazonFileInJunctionObject(azFile.id,controller.participation.id);
                req.AmazonFile__c = azFile.Id;
                
            }

        }

        //insert filesList;
        update reqList;
        update [SELECT Id FROM Case WHERE Id=:controller.participation.case__c];
        System.debug('ITEMS NO ATTACHMENT'+[SELECT Id  FROM Attachment]);

        ISSP_AMC_Upload_Files uploadFiles = new ISSP_AMC_Upload_Files();
        uploadFiles.participationBackend = controller.participation;
        uploadFiles.getUploadedFileInfo();
        AmazonFile__c fileToDelete = [SELECT Id,Name,Full_Name_Unique__c FROM AmazonFile__c][0];
        String amazonId = ''+fileToDelete.Id;
        String amazonName = ''+fileToDelete.Full_Name_Unique__c;
        ISSP_AMC_Upload_Files.getExpiringLink(amazonName);
        ISSP_AMC_Upload_Files.deleteAttachment(amazonId,amazonName);
    }

    /*
        Purpose: Creates and upload files to the junction object and is tested alongside the controller
        Parameters: ISSP_AMC_Airline_Designators
        Returns:
        Throws [Exceptions]: 
    */
    public static void testDesignatorUploadFiles(ISSP_AMC_Airline_Designators controller){
        List <Participant_Online_App_Requirement__c> reqList = [SELECT Id,Name,Participation_Application_Requirement__r.Type_of_Requirement__c FROM Participant_Online_App_Requirement__c WHERE Participation_Online_Application__c= :controller.participation.Id AND Participation_Application_Requirement__r.Type_of_Requirement__c = 'Attachment'];
        System.debug('REQLIST size' + reqList);
        System.debug('REQLIST size' + reqList.size());
        List <AmazonFile__c> filesList = new List<AmazonFile__c>();

        
        WrapperAttachTest.loadTestCredentials();


        String parentId = controller.participation.case__c;
        Long filesize = 100;
        String amazonKey = 'path/'+Math.random()+'testfileName.pdf';
        String fileName='ICE POP';
        RecordTypeInfo rtInfo = Schema.SObjectType.AmazonFile__c.getRecordTypeInfosByName().get('File');
        Id RTId = rtInfo.getRecordTypeId();
        System.debug('RTId' + RTId);
        AmazonFile__c azFile;
        for(Participant_Online_App_Requirement__c req : reqList){
            
            if(req.Participation_Application_Requirement__r.Type_of_Requirement__c == 'Attachment'){
                azFile = new AmazonFile__c(
                                    Name='ICE POP',
                                    RecordTypeId = RTId,
                                    Case__c =controller.participation.case__c,
                                    Full_Name_Unique__c = '001/'+controller.participation.case__c+Math.random()+'/ICE POP'
                            );
                insert azFile;
                UploadFileToAmazonButtonCtrl.createAmazonFileObject(amazonKey, filesize, parentId, azFile);
                //ISSP_AMC_DAO.saveAmazonFileInJunctionObject(azFile.id,controller.participation.id);
                req.AmazonFile__c = azFile.Id;
                
            }
        }

        //insert filesList;
        update reqList;
        update [SELECT Id FROM Case WHERE Id=:controller.participation.case__c];

        ISSP_AMC_Upload_Files uploadFiles = new ISSP_AMC_Upload_Files();
        uploadFiles.participationBackend = controller.participation;
        uploadFiles.getUploadedFileInfo();
    }

    /*
        Purpose: Creates and upload files to the junction object and is tested alongside the controller
        Parameters: ISSP_AMC_Accounting_Or_Prefix_Code
        Returns:
        Throws [Exceptions]: 
    */
    public static void testAccountingPrefixUploadFiles(ISSP_AMC_Accounting_Or_Prefix_Code controller){
        List <Participant_Online_App_Requirement__c> reqList = [SELECT Id,Name,Participation_Application_Requirement__r.Type_of_Requirement__c FROM Participant_Online_App_Requirement__c WHERE Participation_Online_Application__c= :controller.participation.Id AND Participation_Application_Requirement__r.Type_of_Requirement__c = 'Attachment'];
        System.debug('REQLIST size' + reqList);
        System.debug('REQLIST size' + reqList.size());
        List <AmazonFile__c> filesList = new List<AmazonFile__c>();

        
        WrapperAttachTest.loadTestCredentials();


        String parentId = controller.participation.case__c;
        Long filesize = 100;
        String amazonKey = 'path/'+Math.random()+'testfileName.pdf';
        String fileName='ICE POP';
        RecordTypeInfo rtInfo = Schema.SObjectType.AmazonFile__c.getRecordTypeInfosByName().get('File');
        Id RTId = rtInfo.getRecordTypeId();
        System.debug('RTId' + RTId);
        AmazonFile__c azFile;
        for(Participant_Online_App_Requirement__c req : reqList){
            
            if(req.Participation_Application_Requirement__r.Type_of_Requirement__c == 'Attachment'){
                azFile = new AmazonFile__c(
                                    Name='ICE POP',
                                    RecordTypeId = RTId,
                                    Case__c =controller.participation.case__c,
                                    Full_Name_Unique__c = '001/'+controller.participation.case__c+Math.random()+'/ICE POP'
                            );
                insert azFile;
                UploadFileToAmazonButtonCtrl.createAmazonFileObject(amazonKey, filesize, parentId, azFile);
                //ISSP_AMC_DAO.saveAmazonFileInJunctionObject(azFile.id,controller.participation.id);
                req.AmazonFile__c = azFile.Id;
                
            }

        }

        //insert filesList;
        update reqList;
        //update [SELECT Id FROM Case WHERE Id=:controller.participation.case__c];

        ISSP_AMC_Upload_Files uploadFiles = new ISSP_AMC_Upload_Files();
        uploadFiles.participationBackend = controller.participation;
        uploadFiles.getUploadedFileInfo();
    }

    /*
        Purpose: Creates and upload files to the junction object and is tested alongside the controller
        Parameters: ISSP_AMC_Baggage_Tag_Range
        Returns:
        Throws [Exceptions]: 
    */
    public static void testBaggageUploadFiles(ISSP_AMC_Baggage_Tag_Range controller){
        List <Participant_Online_App_Requirement__c> reqList = [SELECT Id,Name,Participation_Application_Requirement__r.Type_of_Requirement__c FROM Participant_Online_App_Requirement__c WHERE Participation_Online_Application__c= :controller.participation.Id AND Participation_Application_Requirement__r.Type_of_Requirement__c = 'Attachment'];
        System.debug('REQLIST size' + reqList);
        System.debug('REQLIST size' + reqList.size());
        List <AmazonFile__c> filesList = new List<AmazonFile__c>();

        
        WrapperAttachTest.loadTestCredentials();


        String parentId = controller.participation.case__c;
        Long filesize = 100;
        String amazonKey = 'path/'+Math.random()+'testfileName.pdf';
        String fileName='ICE POP';
        RecordTypeInfo rtInfo = Schema.SObjectType.AmazonFile__c.getRecordTypeInfosByName().get('File');
        Id RTId = rtInfo.getRecordTypeId();
        System.debug('RTId' + RTId);
        AmazonFile__c azFile;
        for(Participant_Online_App_Requirement__c req : reqList){
            
            if(req.Participation_Application_Requirement__r.Type_of_Requirement__c == 'Attachment'){
                azFile = new AmazonFile__c(
                                    Name='ICE POP',
                                    RecordTypeId = RTId,
                                    Case__c =controller.participation.case__c,
                                    Full_Name_Unique__c = '001/'+controller.participation.case__c+Math.random()+'/ICE POP'
                            );
                insert azFile;
                UploadFileToAmazonButtonCtrl.createAmazonFileObject(amazonKey, filesize, parentId, azFile);
                //ISSP_AMC_DAO.saveAmazonFileInJunctionObject(azFile.id,controller.participation.id);
                req.AmazonFile__c = azFile.Id;
                
            }

        }

        //insert filesList;
        update reqList;
        update [SELECT Id FROM Case WHERE Id=:controller.participation.case__c];

        ISSP_AMC_Upload_Files uploadFiles = new ISSP_AMC_Upload_Files();
        uploadFiles.participationBackend = controller.participation;
        uploadFiles.getUploadedFileInfo();
    }
  


    /*public static Contact dummyContact(Boolean insertContact){
        Contact con = new Contact(
            Firstname = 'AMC',
            Lastname = 'User Partner',
            Status__c = 'Active',
            Membership_Function__c = 'Aeropolitical; Operations; Technical',
            Email = 'joeblack12345zao@gmail.com',
            Preferred_Language__c = 'English',
            User_Portal_Status__c = 'Active'
            //ISO_Country__c = 'Portugal',
            //RecordTypeId = [SELECT RecordTypeId FROM Contact][0].Id
            );

        if(insertContact){
            insert con;
        }

        return con;
    }

    public static Account dummyAccount(Boolean insertAccount){
        Account acc = new Account(
            Name = 'TAP Portugal',
            Field_Head_Office__c = 'Headquarter',
            Payment_Term__c = '2003',
            Segmentation__c = 'Large',
            Sector__c = 'Airline',
            Site = 'TP PT',
            Legal_name__c = 'Transportes Aéreos Portugueses S.A.',
            Name_on_AOC__c = 'TAP Portugal',
            //Type_of_Operations__c = 'Scheduled Passenger and Cargo',
            Type_of_Service__c = 'Scheduled and Non-Scheduled',
            Airline_Model_Type__c = 'Full Service Carrier',
            ACLI_Status__c = 'Active Company',
            TradeName__c = 'TAP Portugal',
            //AOC_Expiry_Date__c = '12/31/2100',
            Area_of_Operation__c = 'International and Domestic',
            MITA_Member__c = true,
            Membership_SITA__c = true,
            BIETA_Member__c = true,
            ICh_Member__c= true,
            Membership_status__c = 'Non-IATA member',
            //Region_formula__c = 'Europe',
            //IATA_ISO_Country__c = 'Portugal',
            Email__c = 't@bjdf.com',
            Website = 'http://www.iata.org',
            Phone = '85325963',
            BillingStreet = 'Aeroporto de Lisboa',
            BillingCity = 'Lisboa',
            BillingPostalCode = '1704-801',
            BillingState = 'Campo Grande',
            BillingCountry = 'Portugal',
            ShippingStreet = 'Aeroporto de Lisboa',
            ShippingCity = 'Lisboa',
            ShippingPostalCode = '1704-801',
            ShippingState = 'Campo Grande',
            ShippingCountry = 'Portugal',
            Type = 'Passenger and cargo',
            RecordType = [SELECT Name,id from RecordType WHERE Name = 'Airline Headquarters'][0]

            );

        if(insertAccount){
            insert acc;
        }

        return acc;
    }

    @future 
    public static void insertUser(Id contactId){
        User portalUser = new User( email='portaluser@portal.com',
                //profileid = [select Id,Name from UserRole WHERE RoleName='TAPPortugalPartnerUser27'][0].Id, 
            profileid = [select Id,Name from Profile WHERE Name='ISS Portal Airline Delegated Admin User'][0].Id,
            UserName='portaluserUsername', 
            Alias = 'portU',
            TimeZoneSidKey='America/New_York',
            EmailEncodingKey='ISO-8859-1',
            LocaleSidKey='en_US', 
            LanguageLocaleKey='en_US',
            ContactId = contactId,
            PortalRole = 'Worker',
            UserRoleId = [select Id from UserRole where Name='TAP Portugal Partner User'][0].Id,
            FirstName = 'Portal',
            LastName = 'User'
        );
        insert portalUser;
    }*/


    /*
        Purpose: Create Airline Designator Participation
        Parameters: 
        Returns: Participation_Online_Application__c
        Throws [Exceptions]: 
    */
    public static Participation_Online_Application__c createDesignatorParticipation(String name, Boolean insertParticipation, String typeOperation){
        /*
        Types of Operation
        AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER = 'Scheduled Passenger';  
        AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO = 'Scheduled Cargo';
        AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER = 'Non-Scheduled Passenger';
        AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO = 'Non-Scheduled Cargo';
        AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY = 'Ferry Company';
        AMC_PAR_TYPEOFOPERATION_CRS = 'CRS';
        AMC_PAR_TYPEOFOPERATION_ULD = 'ULD';
        AMC_PAR_TYPEOFOPERATION_BUS_COMPANY = 'Bus Company';
        AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY = 'Railway Company';*/
        

        Participation_Online_Application__c participation = new Participation_Online_Application__c(

            //Entity Data 
            HOC_Salutation__c = 'Admiral',
            HOC_First_Name__c = 'First Name',
            HOC_Last_Name__c  = 'HOC Last Name',
            HOC_Title__c = 'HOC Title',
            HOC_Phone__c = 'HOC_Phone__c',
            HOC_Email__c = 'HOC_Email__c',
            Is_the_billing_contact_same_the_HOC__c = false,
            HOB_Salutation__c = 'Admiral',
            HOB_First_Name__c = 'HOB_First_Name__c',
            HOB_Last_Name__c = 'HOB_Last_Name__c',
            HOB_Title__c = 'HOB_Title__c',
            HOB_Phone__c = 'HOB_Phone__c',
            HOB_Email__c = 'HOB_Email__c',
            //Preference of Code
            Preference_of_Code_1__c = 'AA',
            Preference_of_Code_2__c = 'B2',
            Preference_of_Code_3__c = '3C',
            
            //TermsAndConditions
            Terms_Conditions_Agreement__c = true
        );

        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER){
            //Authorized Areas Of Operation
            participation.AOC_Scheduled_Passenger__c = true;
            participation.AAO_Domestic__c = true;
            participation.AAO_International__c = true;
            //Previous IATA Code
            participation.Has_airline_assigned_two_char_code__c = 'Yes';
            participation.Previously_assigned_IATA_code__c = 'AA';
            //ICAO Code
            participation.Does_the_airline_presently_hold_a_three__c = 'Yes';
            participation.ICAO_Code__c = 'AAA';
            //Schedules Publication
            participation.Has_the_company_published_their_schedule__c = 'Yes';

        }

        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO){
            participation.AOC_Scheduled_Cargo__c = true;
            //Authorized Areas Of Operation
            participation.AAO_Domestic__c = true;
            participation.AAO_International__c = true;
            //Previous IATA Code
            participation.Has_airline_assigned_two_char_code__c = 'Yes';
            participation.Previously_assigned_IATA_code__c = 'AA';
            //ICAO Code
            participation.Does_the_airline_presently_hold_a_three__c = 'Yes';
            participation.ICAO_Code__c = 'AAA';
            //Schedules Publication
            participation.Has_the_company_published_their_schedule__c = 'Yes';
            
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER){
            participation.AOC_Non_Scheduled_Passenger__c = true;
            //Authorized Areas Of Operation
            participation.AAO_Domestic__c = true;
            participation.AAO_International__c = true;
            //Previous IATA Code
            participation.Has_airline_assigned_two_char_code__c = 'Yes';
            participation.Previously_assigned_IATA_code__c = 'AA';
            //ICAO Code
            participation.Does_the_airline_presently_hold_a_three__c = 'Yes';
            participation.ICAO_Code__c = 'AAA';
            
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO){
            participation.AOC_Non_Scheduled_Cargo__c = true;
            //Authorized Areas Of Operation
            participation.AAO_Domestic__c = true;
            participation.AAO_International__c = true;
            //Previous IATA Code
            participation.Has_airline_assigned_two_char_code__c = 'Yes';
            participation.Previously_assigned_IATA_code__c = 'AA';
            //ICAO Code
            participation.Does_the_airline_presently_hold_a_three__c = 'Yes';
            participation.ICAO_Code__c = 'AAA';
            
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY){
            participation.AOC_Ferry_Company__c = true;
             //Schedules Publication
            participation.Has_the_company_published_their_schedule__c = 'Yes';
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_CRS){
            participation.AOC_CRS__c = true;
            /*participation.Name_of_Airline__c = 'Name of Airline';
            participation.Reciprocal_Two_Way_IATA_Airline_Code__c = 'AC';
            participation.Providing_ticketing_services_to_airline__c = 'Yes';*/
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_ULD){
            participation.AOC_ULD__c = true;
            participation.Is_ULD_participation_IATA_program__c ='Yes';
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_BUS_COMPANY){
            participation.AOC_Bus_Company__c = true;
             //Schedules Publication
            participation.Has_the_company_published_their_schedule__c = 'Yes';
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY){
            participation.AOC_Railway_Company__c = true;
             //Schedules Publication
            participation.Has_the_company_published_their_schedule__c = 'Yes';
        }
        system.debug('Participation Factory ' + participation);

        if(insertParticipation){
            insert participation;
        }

        return participation;
        
    }

    /*
        Purpose: Create Airline Designator Participation with ONLY the type of Operation selected
        Parameters: 
        Returns: Participation_Online_Application__c
        Throws [Exceptions]: 
    */
    public static Participation_Online_Application__c createEmptyDesignatorParticipation(String name, Boolean insertParticipation, String typeOperation){
    
        Participation_Online_Application__c participation = new Participation_Online_Application__c(

 
        );

        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER){
            participation.AOC_Scheduled_Passenger__c = true;
        }

        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO){
            participation.AOC_Scheduled_Cargo__c = true;
            
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER){
            participation.AOC_Non_Scheduled_Passenger__c = true;
            
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO){
            participation.AOC_Non_Scheduled_Cargo__c = true;
            
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY){
            participation.AOC_Ferry_Company__c = true;
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_CRS){
            participation.AOC_CRS__c = true;
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_ULD){
            participation.AOC_ULD__c = true;
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_BUS_COMPANY){
            participation.AOC_Bus_Company__c = true;
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY){
            participation.AOC_Railway_Company__c = true;
        }

        if(insertParticipation){
            insert participation;
        }

        return participation;
        
    }

    /*
        Purpose: Create Accounting Or Prefix Participation
        Parameters: 
        Returns: Participation_Online_Application__c
        Throws [Exceptions]: 
    */
    public static Participation_Online_Application__c createAccountingPrefixParticipation(String name, Boolean insertParticipation, String typeOperation){

        
        /*
        Types of Operation
        AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER = 'Scheduled Passenger';  
        AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO = 'Scheduled Cargo';
        AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER = 'Non-Scheduled Passenger';
        AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO = 'Non-Scheduled Cargo';
        AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY = 'Ferry Company';
        AMC_PAR_TYPEOFOPERATION_CRS = 'CRS';
        AMC_PAR_TYPEOFOPERATION_BUS_COMPANY = 'Bus Company';
        AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY = 'Railway Company';*/
        
       

        Participation_Online_Application__c participation = new Participation_Online_Application__c(

            //Entity Data 
            HOC_Salutation__c = 'Admiral',
            HOC_First_Name__c = 'First Name',
            HOC_Last_Name__c  = 'HOC Last Name',
            HOC_Title__c = 'HOC Title',
            HOC_Phone__c = 'HOC_Phone__c',
            HOC_Email__c = 'HOC_Email__c',
            Is_the_billing_contact_same_the_HOC__c = false,
            HOB_Salutation__c = 'Admiral',
            HOB_First_Name__c = 'HOB_First_Name__c',
            HOB_Last_Name__c = 'HOB_Last_Name__c',
            HOB_Title__c = 'HOB_Title__c',
            HOB_Phone__c = 'HOB_Phone__c',
            HOB_Email__c = 'HOB_Email__c',
            //Preference of Code
            Preference_of_Code_1__c = '111',
            Preference_of_Code_2__c = '222',
            Preference_of_Code_3__c = '333',
            
            //TermsAndConditions
            Terms_Conditions_Agreement__c = true
        );

        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER){
            participation.AOC_Scheduled_Passenger__c = true;
            //Authorized Areas Of Operation
            participation.AAO_Domestic__c = true;
            participation.AAO_International__c = true;
            //Previous IATA Code
            participation.Has_airline_assigned_two_char_code__c = 'Yes';
            participation.Previously_assigned_IATA_code__c = 'AA';
            //ICAO Code
            participation.Does_the_airline_presently_hold_a_three__c = 'Yes';
            participation.ICAO_Code__c = 'AAA';
            //Schedules Publication
            participation.Has_the_company_published_their_schedule__c = 'Yes';

        }

        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO){
            participation.AOC_Scheduled_Cargo__c = true;
            //Authorized Areas Of Operation
            participation.AAO_Domestic__c = true;
            participation.AAO_International__c = true;
            //Previous IATA Code
            participation.Has_airline_assigned_two_char_code__c = 'Yes';
            participation.Previously_assigned_IATA_code__c = 'AA';
            //ICAO Code
            participation.Does_the_airline_presently_hold_a_three__c = 'Yes';
            participation.ICAO_Code__c = 'AAA';
            //Schedules Publication
            participation.Has_the_company_published_their_schedule__c = 'Yes';
            
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER){
            participation.AOC_Non_Scheduled_Passenger__c = true;
            //Authorized Areas Of Operation
            participation.AAO_Domestic__c = true;
            participation.AAO_International__c = true;
            //Previous IATA Code
            participation.Has_airline_assigned_two_char_code__c = 'Yes';
            participation.Previously_assigned_IATA_code__c = 'AA';
            //ICAO Code
            participation.Does_the_airline_presently_hold_a_three__c = 'Yes';
            participation.ICAO_Code__c = 'AAA';
            
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO){
            participation.AOC_Non_Scheduled_Cargo__c = true;
            //Authorized Areas Of Operation
            participation.AAO_Domestic__c = true;
            participation.AAO_International__c = true;
            //Previous IATA Code
            participation.Has_airline_assigned_two_char_code__c = 'Yes';
            participation.Previously_assigned_IATA_code__c = 'AA';
            //ICAO Code
            participation.Does_the_airline_presently_hold_a_three__c = 'Yes';
            participation.ICAO_Code__c = 'AAA';
            
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_CRS){
            participation.AOC_CRS__c = true;
            /*participation.Name_of_Airline__c = 'Name of Airline';
            participation.Reciprocal_Two_Way_IATA_Airline_Code__c = 'AC';
            participation.Providing_ticketing_services_to_airline__c = 'Yes';*/
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY){
            participation.AOC_Ferry_Company__c = true;
             //Schedules Publication
            participation.Has_the_company_published_their_schedule__c = 'Yes';
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_BUS_COMPANY){
            participation.AOC_Bus_Company__c = true;
             //Schedules Publication
            participation.Has_the_company_published_their_schedule__c = 'Yes';
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY){
            participation.AOC_Railway_Company__c = true;
             //Schedules Publication
            participation.Has_the_company_published_their_schedule__c = 'Yes';
        }
        system.debug('Participation Factory ' + participation);

        if(insertParticipation){
            insert participation;
        }
        return participation;
    }

    /*
        Purpose: Create Accounting Or Prefix Participation with ONLY the type of Operation selected
        Parameters: 
        Returns: Participation_Online_Application__c
        Throws [Exceptions]: 
    */
    public static Participation_Online_Application__c createEmptyAccountingPrefixParticipation(String name, Boolean insertParticipation, String typeOperation){

        
        /*
        Types of Operation
        AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER = 'Scheduled Passenger';  
        AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO = 'Scheduled Cargo';
        AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER = 'Non-Scheduled Passenger';
        AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO = 'Non-Scheduled Cargo';
        AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY = 'Ferry Company';
        AMC_PAR_TYPEOFOPERATION_CRS = 'CRS';
        AMC_PAR_TYPEOFOPERATION_BUS_COMPANY = 'Bus Company';
        AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY = 'Railway Company';*/
        
       

        Participation_Online_Application__c participation = new Participation_Online_Application__c(

        
        );

        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER){
            participation.AOC_Scheduled_Passenger__c = true;

        }

        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO){
            participation.AOC_Scheduled_Cargo__c = true;
            
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER){
            participation.AOC_Non_Scheduled_Passenger__c = true;
            
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO){
            participation.AOC_Non_Scheduled_Cargo__c = true;
            
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_CRS){
            participation.AOC_CRS__c = true;
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY){
            participation.AOC_Ferry_Company__c = true;
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_BUS_COMPANY){
            participation.AOC_Bus_Company__c = true;
        }
        if(typeOperation == ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY){
            participation.AOC_Railway_Company__c = true;
        }
        system.debug('Participation Factory ' + participation);

        if(insertParticipation){
            insert participation;
        }
        return participation;
    }

    /*
        Purpose: Create Location Identifier Participation
        Parameters: 
        Returns: Participation_Online_Application__c
        Throws [Exceptions]: 
    */
    public static Participation_Online_Application__c createLocationIdentifierParticipation(String name, Boolean insertParticipation, String locationType, boolean metroQuestion){
        Participation_Online_Application__c participation = new Participation_Online_Application__c(
            //Area Data
            City_Name__c = 'City Name',
            //IATA_ISO_Country__c = 'AL', MUST BE A ID
            Location_Name__c    = 'Location Name',
            State__c = 'State Name',
            Recommended_Loc_Identifier__c = 'Recommended Loc Identifier',
            GPS_Coordinates__c = '43°41’30.149"N, 94°55’18.75"W',
            Time_Zone__c = 'Time Zone',
            // Terms and Conditions
            Terms_Conditions_Agreement__c = true
            );

        if(locationType == ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_AIRPORT || locationType == ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_HELIPORT){
                // AIRPORT/HELIPORT FORM
                participation.Location_Type__c ='Airport';
                participation.Date_when_airport_has_been_operational__c = date.today().format();
                participation.X1_other_airlines_in_the_airport__c = 'text';
                participation.X2_other_airlines_in_the_airport__c = 'text';
                participation.X3_other_airlines_in_the_airport__c = 'text';
        }

        if(locationType == ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_RAILWAY_STATION || locationType == ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_BUS_STATION || locationType == ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_FERRY_PORT){
                // AIRPORT/HELIPORT FORM
                participation.Location_Type__c ='Railway Station';
        }

        if(locationType == ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_OFF_LINE_POINT){
                // OFF-LINE POINT FORM
                participation.Location_Type__c ='Off-line Point';
                participation.Off_Line_Point_Purpose__c = 'text';
        }

        if(locationType == ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_METROPOLITAN_AREA){
            //METROPOLITAN AREA FORM
            participation.Location_Type__c ='Metropolitan Area';
            if(metroQuestion){
                participation.Does_Metropolitan_area_currently_exists__c = 'Yes';
                participation.Location_Code__c = 'AAA';
            }
            else if(metroQuestion = false){
                participation.Does_Metropolitan_area_currently_exists__c = 'No';
                participation.Location_Code_1__c = 'AAA';
                participation.Location_Code_2__c = 'BBB';
            }

        }

        if(insertParticipation){
            insert participation;
        }

        return participation;
    }

    /*
        Purpose: Create Baggage Participation
        Parameters: 
        Returns: Participation_Online_Application__c
        Throws [Exceptions]: 
    */
    public static Participation_Online_Application__c createBaggageParticipation(String name, Boolean insertParticipation, boolean charDesig, boolean numCode){
        Participation_Online_Application__c participation = new Participation_Online_Application__c(
            // Entity/Contact Data
            Name = name,
            HOC_Salutation__c = 'Admiral',
            HOC_First_Name__c = 'First Name',
            HOC_Last_Name__c  = 'HOC Last Name',
            HOC_Title__c = 'HOC Title',
            HOC_Phone__c = 'HOC_Phone__c',
            HOC_Email__c = 'HOC_Email__c',
            Is_the_billing_contact_same_the_HOC__c = false,
            HOB_Salutation__c = 'Admiral',
            HOB_First_Name__c = 'HOB_First_Name__c',
            HOB_Last_Name__c = 'HOB_Last_Name__c',
            HOB_Title__c = 'HOB_Title__c',
            HOB_Phone__c = 'HOB_Phone__c',
            HOB_Email__c = 'HOB_Email__c',
            //TermsAndConditions
            Terms_Conditions_Agreement__c = true,
            // Reasons for Use
            Baggage_Reason_For_Use_1__c = true,
            Baggage_Reason_For_Use_2__c = true,
            Baggage_Reason_For_Use_3__c = true,
            Baggage_Reason_For_Use_4__c = true,
            Baggage_Reason_For_Use_5__c = true
            );

            if(charDesig){
                participation.Has_airline_assigned_two_char_code__c = 'Yes';
                participation.Previously_assigned_IATA_code__c = 'AA';
            }
            else if(charDesig = false){
                participation.Has_airline_assigned_two_char_code__c = 'No';
            }

            if(numCode){
                participation.Has_company_assigned_numeric_code__c = 'Yes';
                participation.Previously_assigned_numeric_code__c = '000';
            }
            else if(numCode = false){
                participation.Has_company_assigned_numeric_code__c = 'No';
            }

            if(insertParticipation){
                insert participation;
            }

            return participation;
    }

    /*
        Purpose: Create Baggage Participation with ONLY the type of Operation selected
        Parameters: 
        Returns: Participation_Online_Application__c
        Throws [Exceptions]: 
    */
    public static Participation_Online_Application__c createEmptyBaggageParticipation(String name, Boolean insertParticipation, boolean charDesig, boolean numCode){
        Participation_Online_Application__c participation = new Participation_Online_Application__c(
            
            );

            if(charDesig){
                participation.Has_airline_assigned_two_char_code__c = 'Yes';
                participation.Previously_assigned_IATA_code__c = '8A';
            }
            else if(charDesig = false){
                participation.Has_airline_assigned_two_char_code__c = 'No';
            }

            if(numCode){
                participation.Has_company_assigned_numeric_code__c = 'Yes';
                participation.Previously_assigned_numeric_code__c = 'AAA';
            }
            else if(numCode = false){
                participation.Has_company_assigned_numeric_code__c = 'No';
            }

            if(insertParticipation){
                insert participation;
            }

            return participation;
    }
    
    /*
        Purpose: Creates ALL requirements related to the Airline Designator
        Parameters: 
        Returns: 
        Throws [Exceptions]: 
    */
    public static List <Participation_Application_Requirement__c> createDesignatorRequirements(Boolean insertRequirement){

        List <Participation_Application_Requirement__c> reqList = new List<Participation_Application_Requirement__c>();

        Participation_Application_Requirement__c entityData = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Non-Scheduled Passenger;Non-Scheduled Cargo;Ferry Company;CRS;ULD;Bus Company;Railway Company',
            Component_Key__c = 'ISSP_AMC_EntityContactData',
            isToShow__c = true
        );
        reqList.add(entityData);
        Participation_Application_Requirement__c authorizedAreasOfOperation = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Non-Scheduled Passenger;Non-Scheduled Cargo',
            Component_Key__c = 'ISSP_AMC_Authorized_Areas_Operation',
            isToShow__c = true,
            ACLI_Requirement_Fields__c = 'AAO_International__c; AAO_Domestic__c'
        );
        reqList.add(authorizedAreasOfOperation);
        Participation_Application_Requirement__c uld = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Type_of_Operation__c = 'ULD',
            Component_Key__c = 'ISSP_AMC_ULD',
            isToShow__c = true
        );
        reqList.add(uld);
        Participation_Application_Requirement__c previousIATACode = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Non-Scheduled Passenger;Non-Scheduled Cargo',
            Component_Key__c = 'ISSP_AMC_PreviousIATACode',
            isToShow__c = true
        );
        reqList.add(previousIATACode);
        Participation_Application_Requirement__c icaoCode = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Non-Scheduled Passenger;Non-Scheduled Cargo',
            Component_Key__c = 'ISSP_AMC_ICAOCode',
            isToShow__c = true
        );
        reqList.add(icaoCode);
        Participation_Application_Requirement__c schedulesPublication = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Ferry Company;Bus Company;Railway Company',
            Component_Key__c = 'ISSP_AMC_SchedulesPublication',
            isToShow__c = true
        );
        reqList.add(schedulesPublication);
        Participation_Application_Requirement__c preferenceofCode = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Non-Scheduled Passenger;Non-Scheduled Cargo;Ferry Company;CRS;ULD;Bus Company;Railway Company',
            Component_Key__c = 'ISSP_AMC_PreferenceOfCode',
            isToShow__c = true
        );
        reqList.add(preferenceofCode);


        Participation_Application_Requirement__c nonScheduledUpload = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Type_of_Operation__c = 'Non-Scheduled Passenger;Non-Scheduled Cargo',
            Component_Key__c = 'ISSP_AMC_Non_Scheduled',
            isToShow__c = true
        );
        reqList.add(nonScheduledUpload);
        Participation_Application_Requirement__c uldUpload = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Type_of_Operation__c = 'ULD',
            Component_Key__c = 'ISSP_AMC_ULD',
            isToShow__c = true
        );
        reqList.add(uldUpload);
        Participation_Application_Requirement__c breakdownOfShareholders = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Non-Scheduled Passenger;Non-Scheduled Cargo;Ferry Company;CRS;ULD;Bus Company;Railway Company',
            Component_Key__c = 'ISSP_AMC_BreakdownOfShareholders',
            isToShow__c = true
        );
        reqList.add(breakdownOfShareholders);
        Participation_Application_Requirement__c authorizationTransportationServices = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Type_of_Operation__c = 'Ferry Company;Bus Company;Railway Company',
            Component_Key__c = 'ISSP_AMC_Authorization_Transportation_Services',
            isToShow__c = true
        );
        reqList.add(authorizationTransportationServices);
        Participation_Application_Requirement__c trafficAgreementValidIATACode = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Type_of_Operation__c = 'Ferry Company;Bus Company;Railway Company',
            Component_Key__c = 'ISSP_AMC_TrafficAgreement_Valid_IATA_Code',
            isToShow__c = true
        );
        reqList.add(trafficAgreementValidIATACode);
        Participation_Application_Requirement__c signedLetterCRS = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Type_of_Operation__c = 'CRS',
            Component_Key__c = 'ISSP_AMC_Signed_Letter_CRS',
            isToShow__c = true
        );
        reqList.add(signedLetterCRS);
        Participation_Application_Requirement__c certificateIncorporationRegistration = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Non-Scheduled Passenger;Non-Scheduled Cargo;Ferry Company;CRS;ULD;Bus Company;Railway Company',
            Component_Key__c = 'ISSP_AMC_CertificateIncorporationRegistration',
            isToShow__c = true
        );
        reqList.add(certificateIncorporationRegistration);
        Participation_Application_Requirement__c airlineIssuedAOC = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Non-Scheduled Passenger;Non-Scheduled Cargo',
            Component_Key__c = 'ISSP_AMC_Airline_Issued_AOC',
            isToShow__c = true
        );
        reqList.add(airlineIssuedAOC);
        Participation_Application_Requirement__c termsAndConditions = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Designator Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Non-Scheduled Passenger;Non-Scheduled Cargo;Ferry Company;CRS;ULD;Bus Company;Railway Company',
            Component_Key__c = 'ISSP_AMC_TermsAndConditions',
            isToShow__c = true
        );
        reqList.add(termsAndConditions);

        if(insertRequirement){
            insert reqList;
        }

        return reqList;
    }

    /*
        Purpose: Creates ALL requirements related to the Accounting & Prefix
        Parameters: 
        Returns: 
        Throws [Exceptions]: 
    */
    public static void createAccountingPrefixRequirements(Boolean insertRequirement){
        
        List <Participation_Application_Requirement__c> reqList = new List<Participation_Application_Requirement__c>();


        Participation_Application_Requirement__c entityData = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Non-Scheduled Passenger;Non-Scheduled Cargo;Ferry Company;CRS;Bus Company;Railway Company',
            Component_Key__c = 'ISSP_AMC_EntityContactData',
            isToShow__c = true
        );
        reqList.add(entityData);
        Participation_Application_Requirement__c authorizedAreasOfOperation = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'VF_Component', // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Non-Scheduled Passenger;Non-Scheduled Cargo',
            Component_Key__c = 'ISSP_AMC_Authorized_Areas_Operation',
            isToShow__c = true
        );
        reqList.add(authorizedAreasOfOperation);
        Participation_Application_Requirement__c previousIATACode = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'VF_Component', // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Non-Scheduled Passenger;Non-Scheduled Cargo',
            Component_Key__c = 'ISSP_AMC_PreviousIATACode',
            isToShow__c = true
        );
        reqList.add(previousIATACode);
        Participation_Application_Requirement__c icaoCode = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'VF_Component', // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Non-Scheduled Passenger;Non-Scheduled Cargo',
            Component_Key__c = 'ISSP_AMC_ICAOCode',
            isToShow__c = true
        );
        reqList.add(icaoCode);
        Participation_Application_Requirement__c schedulesPublication = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'VF_Component', // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Ferry Company;Bus Company;Railway Company',
            Component_Key__c = 'ISSP_AMC_SchedulesPublication',
            isToShow__c = true
        );
        reqList.add(schedulesPublication);
        Participation_Application_Requirement__c preferenceofCode = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'VF_Component', // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Non-Scheduled Passenger;Non-Scheduled Cargo;Ferry Company;CRS;Bus Company;Railway Company',
            Component_Key__c = 'ISSP_AMC_PreferenceOfCode',
            isToShow__c = true
        );
        reqList.add(preferenceofCode);
        Participation_Application_Requirement__c termsAndConditions = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'VF_Component', // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger;Scheduled Cargo;Non-Scheduled Passenger;Non-Scheduled Cargo;Ferry Company;CRS;Bus Company;Railway Company',
            Component_Key__c = 'ISSP_AMC_TermsAndConditions',
            isToShow__c = true
        );
        reqList.add(termsAndConditions);


        Participation_Application_Requirement__c passengerUpload = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'Attachment', // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger; Non-Scheduled Passenger',
            Component_Key__c = 'ISSP_AMC_Passenger',
            isToShow__c = true
        );
        reqList.add(passengerUpload);
        Participation_Application_Requirement__c cargoUpload = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'Attachment', // OR Attachment
            Type_of_Operation__c = 'Scheduled Cargo; Non-Scheduled Cargo',
            Component_Key__c = 'ISSP_AMC_Cargo',
            isToShow__c = true
        );
        reqList.add(cargoUpload);
        Participation_Application_Requirement__c trafficAgreementUpload = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'Attachment', // OR Attachment
            Type_of_Operation__c = 'Ferry Company; Bus Company; Railway Company',
            Component_Key__c = 'ISSP_AMC_TrafficAgreement_Valid_IATA_Code',
            isToShow__c = true
        );
        reqList.add(trafficAgreementUpload);
        Participation_Application_Requirement__c crsUpload = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'Attachment', // OR Attachment
            Type_of_Operation__c = 'CRS',
            Component_Key__c = 'ISSP_AMC_Signed_Letter_CRS',
            isToShow__c = true
        );
        reqList.add(crsUpload);
        Participation_Application_Requirement__c breakdownOfShareholdersUpload = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'Attachment', // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger; Scheduled Cargo; Non-Scheduled Passenger; Non-Scheduled Cargo; Ferry Company; CRS; Bus Company; Railway Company',
            Component_Key__c = 'ISSP_AMC_BreakdownOfShareholders',
            isToShow__c = true
        );
        reqList.add(breakdownOfShareholdersUpload);
        Participation_Application_Requirement__c certificateIncorporationRegistrationUpload = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'Attachment', // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger; Scheduled Cargo; Non-Scheduled Passenger; Non-Scheduled Cargo; Ferry Company; CRS; Bus Company; Railway Company',
            Component_Key__c = 'ISSP_AMC_CertificateIncorporationRegistration',
            isToShow__c = true
        );
        reqList.add(certificateIncorporationRegistrationUpload);
        Participation_Application_Requirement__c airlineIssuedAOCUpload = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'Attachment', // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger; Scheduled Cargo; Non-Scheduled Passenger; Non-Scheduled Cargo',
            Component_Key__c = 'ISSP_AMC_Airline_Issued_AOC',
            isToShow__c = true
        );
        reqList.add(airlineIssuedAOCUpload);
        Participation_Application_Requirement__c authorizationTransportationServicesUpload = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'Attachment', // OR Attachment
            Type_of_Operation__c = 'Scheduled Passenger; Scheduled Cargo; Non-Scheduled Passenger; Non-Scheduled Cargo',
            Component_Key__c = 'ISSP_AMC_Authorization_Transportation_Services',
            isToShow__c = true
        );
        reqList.add(authorizationTransportationServicesUpload);
        Participation_Application_Requirement__c nonScheduledUpload = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Accounting or Prefix Code',
            Type_of_Requirement__c = 'Attachment', // OR Attachment
            Type_of_Operation__c = 'Non-Scheduled Passenger; Non-Scheduled Cargo',
            Component_Key__c = 'ISSP_AMC_Non_Scheduled',
            isToShow__c = true
        );
        reqList.add(nonScheduledUpload);

        if(insertRequirement){
            insert reqList;
        }
    }

    /*
        Purpose: Creates ALL requirements related to the Location Identifier
        Parameters: 
        Returns: Participation_Online_Application__c
        Throws [Exceptions]: 
    */
    public static void createLocationIdentifierRequirements(Boolean insertRequirement){
        List <Participation_Application_Requirement__c> reqList = new List<Participation_Application_Requirement__c>();

        Participation_Application_Requirement__c airportheliport = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Location Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Location_Type__c = 'Airport; Heliport',
            Component_Key__c = 'ISSP_AMC_LocationAirportHeliportForm',
            isToShow__c = true
        );
        reqList.add(airportheliport);
        Participation_Application_Requirement__c metropolitanArea = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Location Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Location_Type__c = 'Metropolitan Area',
            Component_Key__c = 'ISSP_AMC_Metropolitan_Area',
            isToShow__c = true
        );
        reqList.add(metropolitanArea);
        Participation_Application_Requirement__c offlinePoint = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Location Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Location_Type__c = 'Off-line Point',
            Component_Key__c = 'ISSP_AMC_LocationOfflinePoint',
            isToShow__c = true
        );
        reqList.add(offlinePoint);
        Participation_Application_Requirement__c currentstructureLocation = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Location Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Location_Type__c = 'Airport; Heliport',
            Component_Key__c = 'ISSP_AMC_CurrentStructureLocation',
            isToShow__c = true
        );
        reqList.add(currentstructureLocation);
        Participation_Application_Requirement__c openingdayLetter = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Location Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Location_Type__c = 'Airport; Heliport',
            Component_Key__c = 'ISSP_AMC_CAALetterOpeningDate',
            isToShow__c = true
        );
        reqList.add(openingdayLetter);
        Participation_Application_Requirement__c commercialOperations = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Location Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Location_Type__c = 'Airport; Heliport',
            Component_Key__c = 'ISSP_AMC_CommercialScheduledOperations',
            isToShow__c = true
        );
        reqList.add(commercialOperations);
        Participation_Application_Requirement__c termsAndConditions = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Location Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Location_Type__c = 'Airport; Heliport; Railway Station; Bus Station; Ferry Port; Off-line Point; Metropolitan Area',
            Component_Key__c = 'ISSP_AMC_TermsAndConditions',
            isToShow__c = true
        );
        reqList.add(termsAndConditions);
        Participation_Application_Requirement__c areaData = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Location Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Location_Type__c = 'Airport; Heliport; Railway Station; Bus Station; Ferry Port; Off-line Point; Metropolitan Area',
            Component_Key__c = 'ISSP_AMC_LocationAreaData',
            isToShow__c = true
        );
        reqList.add(areaData);
        Participation_Application_Requirement__c trafficAgreementValidIATACode = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Location Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Location_Type__c = 'Railway Station; Bus Station; Ferry Port',
            Component_Key__c = 'ISSP_AMC_TrafficAgreement_Valid_IATA_Code',
            isToShow__c = true
        );
        reqList.add(trafficAgreementValidIATACode);
        Participation_Application_Requirement__c approveCreationMetro1 = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Location Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Location_Type__c = 'Metropolitan Area',
            Component_Key__c = 'ISSP_AMC_Metropolitan_Area',
            isToShow__c = true
        );
        reqList.add(approveCreationMetro1);
        Participation_Application_Requirement__c approveCreationMetro2 = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Location Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Location_Type__c = 'Metropolitan Area',
            Component_Key__c = 'ISSP_AMC_Metropolitan_AirportB',
            isToShow__c = true
        );
        reqList.add(approveCreationMetro2);

        system.debug('DB::::::::::::::::::::::::::::::::::::::::::::::::::::'+reqList);

        if(insertRequirement){
            insert reqList;
        }
    }

    /*
        Purpose: Creates ALL requirements related to the Baggage
        Parameters: 
        Returns: Participation_Online_Application__c
        Throws [Exceptions]: 
    */
    public static void createBaggageRequirements(Boolean insertRequirement){
        List <Participation_Application_Requirement__c> reqList = new List<Participation_Application_Requirement__c>();

        Participation_Application_Requirement__c breakDownOfShareholders = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Baggage Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Type_of_Operation__c = 'Baggage',
            Component_Key__c = 'ISSP_AMC_BreakdownOfShareholders',
            isToShow__c = true
        );
        reqList.add(breakDownOfShareholders);
        Participation_Application_Requirement__c companyPreviousIATACode = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Baggage Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Type_of_Operation__c = 'Baggage',
            Component_Key__c = 'ISSP_AMC_CompanyPreviousIATACode',
            isToShow__c = true
        );
        reqList.add(companyPreviousIATACode);
        Participation_Application_Requirement__c previousNumericIATACode = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Baggage Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Type_of_Operation__c = 'Baggage',
            Component_Key__c = 'ISSP_AMC_PreviousNumericIATACode',
            isToShow__c = true
        );
        reqList.add(previousNumericIATACode);
        Participation_Application_Requirement__c reasonsToUse = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Baggage Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Type_of_Operation__c = 'Baggage',
            Component_Key__c = 'ISSP_AMC_DeclarationBaggageTagCodes',
            isToShow__c = true
        );
        reqList.add(reasonsToUse);
        Participation_Application_Requirement__c airOperatorCertificate = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Baggage Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Type_of_Operation__c = 'Baggage',
            Component_Key__c = 'ISSP_AMC_Airline_Issued_AOC',
            isToShow__c = true
        );
        reqList.add(airOperatorCertificate);
        Participation_Application_Requirement__c certificateIncorporationRegistration = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Baggage Code',
            Type_of_Requirement__c = 'Attachment',  // OR Attachment
            Type_of_Operation__c = 'Baggage',
            Component_Key__c = 'ISSP_AMC_CertificateIncorporationRegistration',
            isToShow__c = true
        );
        reqList.add(certificateIncorporationRegistration);
        Participation_Application_Requirement__c termsAndConditions = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Baggage Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Type_of_Operation__c = 'Baggage',
            Component_Key__c = 'ISSP_AMC_TermsAndConditions',
            isToShow__c = true
        );
        reqList.add(termsAndConditions);
        Participation_Application_Requirement__c entityContactDataForBaggage = new Participation_Application_Requirement__c(
            
            ACLI_Codes__c = 'Baggage Code',
            Type_of_Requirement__c = 'VF_Component',  // OR Attachment
            Type_of_Operation__c = 'Baggage',
            Component_Key__c = 'ISSP_AMC_EntityContactDataForBaggage',
            isToShow__c = true
        );
        reqList.add(entityContactDataForBaggage);

        if(insertRequirement){
            insert reqList;
        }
    }
    
    /*
        Purpose: Create a custom setting with the Records Type 'Airline Coding Application'
        Parameters: 
        Returns: Participation_Online_Application__c
        Throws [Exceptions]: 
    */
    public static void createcustomSetting(Boolean insertSetting){

        AMC_Configuration__c csetting = new AMC_Configuration__c(

            amazonRecordTypeId__c = '012w0000000YcHe',
            CaseAccountingPrefixCodeRecordType__c = 'Airline Coding Application',
            CaseBaggageCodeRecordType__c = 'Airline Coding Application',
            CaseCompanyInfoRecordType__c = 'Airline Coding Application',
            CaseDesignatorCodeRecordType__c = 'Airline Coding Application',
            CaseLocationCodeRecordType__c = 'Airline Coding Application',
            CaseManageCodesRecordType__c = 'Airline Coding Application',
            isPublicAmazonFile__c = true
        );

        if(insertSetting){
            insert csetting;
        }
    }

    


}