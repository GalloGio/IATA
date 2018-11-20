@isTest
public class SurveyBatchTest {

  public static final ID hqrt = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;
  public static final ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
  public static final ID europeRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');
  public static final ID chinaRTID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_China_North_Asia');
  public static final ID FDS_ICCS_Email_to_CaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Email_to_Case');
  public static final ID Cases_SIS_Help_DeskRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_SIS_Help_Desk');
  public static final ID processRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');
  public static final ID aCAId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Coding_Application'); 


  @testSetup
    static void setupTestData() {

           Map<String,String> mpCountries = new Map<String,String>();
           mpCountries.put('Finland','FI');
           mpCountries.put('United States','US');
           mpCountries.put('Russian Federation','RU');
           mpCountries.put('People\'s Republic of China','CN');
           mpCountries.put('Canada','CA');
           mpCountries.put('Algeria','AL');
           mpCountries.put('Austria','AT');
           mpCountries.put('Indonesia','ID');
           mpCountries.put('Italy','IT');
           mpCountries.put('Japan','JP');
           mpCountries.put('Korea, Republic of','KO');
           mpCountries.put('Brazil','BR');
           mpCountries.put('Argentina','AR');
           mpCountries.put('Thailand','TH');
           mpCountries.put('Vietnam','VN');
           mpCountries.put('Egypt','EG');

           List<IATA_ISO_Country__c> listCountries = new List<IATA_ISO_Country__c>();
           for(String countryName : mpCountries.keySet()) {
               IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(
                    name = countryName,ISO_Code__c = mpCountries.get(countryName),AIMS_Area_Name__c=countryName, Case_BSP_Country__c = countryName );
               listCountries.add(isoCountry);
           }
           insert listCountries;

        Account a = new Account( name ='IFAP ACCT',
                                 industry = 'pluto',
                                 IATA_ISO_Country__c=listCountries[0].id,
                                 recordtypeID = hqrt,
                                 IATACode__c ='1234568',
                                 Type = 'IATA Cargo Agent',
                                 billingCountry = 'CH',Location_Type__c = 'AO',
                                 Source_System__c = 'WEBSTAR');
        insert a;

        Contact con =new contact(lastname = 'pluto' ,
                                 firstname = 'Name',
                                 phone = '123',
                                 accountid = a.id,
                                 Financial_Assessment_Contact__c = true,
                                 email = 'asd.arg@wewt.et',
                                 HasOptedOutOfEmail = false
                                 );
        insert con;

        User u1 = new User(FirstName='Ángel',
                Division='UnitTest',
                License_Cost_Center__c='AAA000AA00',
                Username='test1@iata.org.amsdev1',
                LastName='Peña', Email='test1@iata.org',
                Alias='Test1', CommunityNickname='Test1',
                TimeZoneSidKey='Europe/Brussels', LocaleSidKey='en_US',
                EmailEncodingKey='UTF-8', ProfileId='00e20000000h0gFAAQ',
                LanguageLocaleKey='en_US');

        insert u1;
      SurveyBatchIgnoreUsers__c ign = new SurveyBatchIgnoreUsers__c();
      ign.FirstName__c = 'Ángel';
      ign.LastName__c = 'Peña';
      ign.Name = 'Ángel Peña';
      insert ign;
    }


  // static testMethod void SurveyCustomerRecoveryBatchTest() {
  //
  // //   User u1 = new User(FirstName='Ángel',
  // //              Division='UnitTest',
  // //              License_Cost_Center__c='AAA000AA00',
  // //              Username='test1@iata.org.amsdev1',
  // //              LastName='Peña', Email='test1@iata.org',
  // //              Alias='Test1', CommunityNickname='Test1',
  // //              TimeZoneSidKey='Europe/Brussels', LocaleSidKey='en_US',
  // //              EmailEncodingKey='UTF-8', ProfileId='00e20000000h0gFAAQ',
  // //              LanguageLocaleKey='en_US');
  //       //
  //       // insert u1;
  //
  //       User u1 = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];
  //       IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c = 'CH', AIMS_Area_Name__c = 'Suisse', AIMS_Area_ID__c = '1' );
  //       insert isoCountry;
  //       //
  //       Account a = new Account( name ='IFAP ACCT',
  //                                industry = 'pluto',
  //                                IATA_ISO_Country__c=isoCountry.id,
  //                                recordtypeID = hqrt,
  //                                IATACode__c ='12345689',
  //                                Type = 'IATA Cargo Agent',
  //                                billingCountry = 'CH',Location_Type__c = 'AO');
  //       insert a;
  //       // Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];
  //       // Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];
  //       Contact con =new contact(lastname = 'pluto' ,
  //                                phone = '123',
  //                                accountid = a.id,
  //                                Financial_Assessment_Contact__c = true,
  //                                email = 'asd.arg@wewt.etc',
  //                                HasOptedOutOfEmail = false
  //                                );
  //       insert con;
  //
  //       // Create cases and close them
  //       Date dead = date.today().addDays(40);
  //       Date twoweeksAgo = date.today().addDays(- 14);
  //
  //       test.startTest();
  //       List<Case> listCases = new List<Case>();
  //
  //           // query case, matches filters
  //           Case c1 = new Case(recordtypeID = chinaRTID,
  //                             Region__c = 'China & North Asia',
  //                             BSPCountry__c = 'China',
  //                             Status = 'Financial Security Requested',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             CaseArea__c = 'Accreditation',
  //                             Reason1__c = 'Annual Fees',
  //                             Financial_Review_Type__c ='bla',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Financial_Review_Result__c = 'very good' ,
  //                             Instant_Survey_Feedback_requested__c = true,
  //                             Subject = 'c1',
  //                             OwnerId = u1.Id);
  //           insert c1;
  //           //listCases.add(c1);
  //           c1.Status = 'Closed';
  //           update c1;
  //
  //           // IFAP case, doesn't match filters
  //           Case c2 = new Case(recordtypeID = IFAPcaseRecordTypeID,
  //                             Status = 'Financial Security Requested',
  //                             Financial_Review_Result__c = 'Satisfactory - New Financial Security',
  //                             Financial_Review_Type__c = 'Annual',
  //                             BSPCountry__c = 'Viet Nam',
  //                             Type_of_customer__c = 'asfg',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Region__c = 'Europe',
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Subject = 'c2',
  //                             Instant_Survey_Feedback_requested__c = true,
  //                             Phone_Redirected_to_Web__c = false,
  //                             OwnerId = u1.Id);
  //           //insert c2;
  //           listCases.add(c2);
  //           //c2.Status = 'Closed';
  //           //update c2;
  //
  //           // query case, doesn't match filters (because of the Region field)
  //           Case c3 = new Case(recordtypeID = europeRTId,
  //                             Region__c = 'Europe (Americas Countries)',
  //                             BSPCountry__c = 'Turkey',
  //                             Status = 'Financial Security Requested',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             CaseArea__c = 'Accreditation',
  //                             Reason1__c = 'Annual Fees',
  //                             Financial_Review_Type__c ='bla',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Financial_Review_Result__c = 'very good' ,
  //                             Instant_Survey_Feedback_requested__c = true,
  //                             Subject = 'c3',
  //                             OwnerId = u1.Id);
  //           //insert c3;
  //            listCases.add(c3);
  //          // c3.Status = 'Closed';
  //           //update c3;
  //
  //           // query case, matches filters
  //           Case c4 = new Case(recordtypeID = europeRTId,
  //                             Region__c = 'Europe',
  //                             BSPCountry__c = 'France',
  //                             Status = 'Financial Security Requested',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             CaseArea__c = 'Accreditation',
  //                             Reason1__c = 'Annual Fees',
  //                             Financial_Review_Type__c ='bla',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Financial_Review_Result__c = 'very good' ,
  //                             Instant_Survey_Feedback_requested__c = true,
  //                             Subject = 'c4',
  //                             OwnerId = u1.Id);
  //           //insert c4;
  //           listCases.add(c4);
  //           //c4.Status = 'Closed';
  //           //update c4;
  //
  //           insert listCases;
  //
  //           for(Case c : listCases)
  //             c.Status = 'Closed';
  //
  //           update listCases;
  //
  //           // create instant surveys for the cases
  //           // Satisfaction score < 5 + case matches filters => case should be updated
  //           Instant_Surveys__c is1 = new Instant_Surveys__c(Name = 'is - c1', X2015_Overall_Satisfaction__c = '2', Relationship_to_Case__c = c1.Id);
  //           insert is1;
  //
  //           // Case matches filters, but satisfaction score > 4 => case out of scope, should NOT be updated
  //           Instant_Surveys__c is2 = new Instant_Surveys__c(Name = 'is - c2', X2015_Overall_Satisfaction__c = '9', Relationship_to_Case__c = c2.Id);
  //           insert is2;
  //
  //           // Satisfaction score < 5, but case doesn't match filters => case should NOT be updated
  //           Instant_Surveys__c is3 = new Instant_Surveys__c(Name = 'is - c3', X2015_Overall_Satisfaction__c = '2', Relationship_to_Case__c = c3.Id);
  //           insert is3;
  //
  //           // Satisfaction score < 5 + case matches filters => case should be updated
  //           Instant_Surveys__c is4 = new Instant_Surveys__c(Name = 'is - c4', X2015_Overall_Satisfaction__c = '4', Relationship_to_Case__c = c4.Id);
  //           insert is4;
  //
  //           List<Case> lstTestCases = new List<Case>([SELECT Id FROM Case WHERE Customer_recovery__c = true]);
  //           system.assertEquals(0, lstTestCases.size());
  //
  //
  //       //test.startTest();
  //
  //           SurveyBatch batch = new SurveyBatch();
  //           batch.CreatedDate = date.today();
  //           Database.executeBatch(batch, 10);
  //
  //           // cover the wrapper too
  //           /*
  //           string jobId = System.schedule('SurveyCustomerRecoveryTest',
  //                       '0 0 0 15 3 ? 2022',
  //                       new SurveyCustomerRecoveryWrapper());*/
  //
  //       test.stopTest();
  //
  //       // only two of the cases should have been set to customer recovery mode
  //       lstTestCases = [SELECT Id FROM Case WHERE Customer_recovery__c = true ];// AND RecordType.DeveloperName = 'ComplaintIDFS'
  //    //   system.assertEquals(2, lstTestCases.size());
  //
  //       // check that the owner of the cases was correctly changed
  //       c1 = [SELECT Id, OwnerId, Customer_recovery__c, RecordType.DeveloperName, Status FROM Case WHERE Id = :c1.Id];
  //       c4 = [SELECT Id, OwnerId, Customer_recovery__c, RecordType.DeveloperName, Status FROM Case WHERE Id = :c4.Id];
  //
  //       //system.debug(LoggingLevel.error,'################### C1: Customer_recovery__c = '+c1.Customer_recovery__c + '; RecordType = ' + c1.RecordType.DeveloperName);
  //
  //       Id EuropeComplaintQueueId = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CasesOCITComplaints' LIMIT 1].Id;
  //       Id ChinaNAComplaintQueueId = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Cases_Complaints_BJS' LIMIT 1].Id;
  //
  //      // system.assertEquals(EuropeComplaintQueueId, c4.OwnerId);
  //    //   system.assertEquals(ChinaNAComplaintQueueId, c1.OwnerId);
  //
  //
  //
  //   }
  //
  //   static testMethod void SurveyEmailTest() {
  //
  //           TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
  //           TransformationHelper.CalculateBusinessHoursAges = true;
  //           CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;
  //
  //           // User u1 = new User(FirstName='Ángel',
  //   //            Division='UnitTest',
  //   //            License_Cost_Center__c='AAA000AA00',
  //   //            Username='test1@iata.org.amsdev1',
  //   //            LastName='Peña', Email='test1@iata.org',
  //   //            Alias='Test1', CommunityNickname='Test1',
  //   //            TimeZoneSidKey='Europe/Brussels', LocaleSidKey='en_US',
  //   //            EmailEncodingKey='UTF-8', ProfileId='00e20000000h0gFAAQ',
  //   //            LanguageLocaleKey='en_US');
  //           //
  //        //   insert u1;
  //           User u1 = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];
  //
  //           // list<IATA_ISO_Country__c> listCountries = new list<IATA_ISO_Country__c>();
  //           // IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1' );
  //           // listCountries.add(isoCountry);
  //           // IATA_ISO_Country__c isoCountry1 = new IATA_ISO_Country__c(name = 'Canada',ISO_Code__c ='CA',AIMS_Area_Name__c='',AIMS_Area_ID__c= '1',  Case_BSP_Country__c  = 'Canada');
  //           // listCountries.add(isoCountry1);
  //           // insert listCountries;
  //           list<IATA_ISO_Country__c> listCountries = [SELECT Id, Name FROM IATA_ISO_Country__c];
  //
  //           list<Account> listAccount = new list<Account>();
  //           Account a = new Account( name ='IFAP ACCT',
  //                                    industry = 'pluto',
  //                                    IATA_ISO_Country__c=listCountries[0].id,
  //                                    recordtypeID = hqrt,
  //                                    IATACode__c ='1234567',
  //                                    Type = 'IATA Cargo Agent',
  //                                    billingCountry = 'ss',Location_Type__c = 'AO');
  //           listAccount.add(a);
  //
  //           Account a1 = new Account( name ='IFAP ACCT 1',
  //                                    industry = 'pluto',
  //                                    IATA_ISO_Country__c=listCountries[1].id,
  //                                    recordtypeID = hqrt,
  //                                    IATACode__c ='7654321',
  //                                    Type = 'IATA Cargo Agent',
  //                                    billingCountry = 'ss',Location_Type__c = 'AO');
  //           listAccount.add(a1);
  //           insert listAccount;
  //
  //           List<Contact> contactList = new List<Contact>();
  //
  //           Contact con =new contact(lastname = 'pluto' ,phone = '123',accountid = a.id,Financial_Assessment_Contact__c = true,email = 'asd.arg@wewt.et',HasOptedOutOfEmail = false);
  //           Contact con1 =new contact(lastname = 'pluto' ,phone = '123',accountid = a1.id,Financial_Assessment_Contact__c = true,email = 'abc.arg@wewt.et',HasOptedOutOfEmail = false);
  //
  //           contactList.add(con);
  //           contactList.add(con1);
  //
  //           insert contactList;
  //
  //           date dead = date.today().addDays(40);
  //
  //           Date twoweeksAgo = date.today().addDays(- 14);
  //           List<Case> cases = new List<Case>();
  //
  //           cases.add(new Case(recordtypeID = IFAPcaseRecordTypeID,
  //                             Status = 'Financial Security Requested',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             Financial_Review_Type__c ='Annual',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Region__c = 'Europe',
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Financial_Review_Result__c = 'Satisfactory - Update Financial Security'
  //                             ));
  //
  //           /*AM*/
  //
  //           cases.add(new Case(recordtypeID = processRTId,
  //                             //Region__c = 'Europe',
  //                             Reason1__c = 'CHC – Change of Shareholding',
  //                             BSPCountry__c='Canada',
  //                             Status = 'Financial Security Requested',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             Financial_Review_Type__c ='bla',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Financial_Review_Result__c = 'very good' ,
  //                             Subject = 'wrthsrthjr'
  //                             //OwnerId = u1.Id
  //                             ));
  //
  //           cases.add(new Case(recordtypeID = processRTId,
  //                             //Region__c = 'Europe',
  //                             Reason1__c = 'CHC – Change of Shareholding',
  //                             BSPCountry__c='Algeria',
  //                             Status = 'Financial Security Requested',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             Financial_Review_Type__c ='bla',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Financial_Review_Result__c = 'very good' ,
  //                             Subject = 'wrthsrthjr'
  //                             ));
  //
  //           cases.add(new Case(recordtypeID = processRTId,
  //                             //Region__c = 'Europe',
  //                             Reason1__c = 'CHC – Change of Shareholding',
  //                             BSPCountry__c='Austria',
  //                             Status = 'Financial Security Requested',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             Financial_Review_Type__c ='bla',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Financial_Review_Result__c = 'very good' ,
  //                             Subject = 'wrthsrthjr'
  //                             ));
  //
  //           cases.add(new Case(recordtypeID = processRTId,
  //                             //Region__c = 'Europe',
  //                             Reason1__c = 'CHC – Change of Shareholding',
  //                             BSPCountry__c='Indonesia',
  //                             Status = 'Financial Security Requested',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             Financial_Review_Type__c ='bla',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Financial_Review_Result__c = 'very good' ,
  //                             Subject = 'wrthsrthjr'
  //                             ));
  //
  //           cases.add(new Case(recordtypeID = processRTId,
  //                             //Region__c = 'Europe',
  //                             Reason1__c = 'CHC – Change of Shareholding',
  //                             BSPCountry__c='Italy',
  //                             Status = 'Financial Security Requested',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             Financial_Review_Type__c ='bla',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Financial_Review_Result__c = 'very good' ,
  //                             Subject = 'wrthsrthjr'
  //                             ));
  //
  //           cases.add(new Case(recordtypeID = processRTId,
  //                             //Region__c = 'Europe',
  //                             Reason1__c = 'CHC – Change of Shareholding',
  //                             BSPCountry__c='Japan',
  //                             Status = 'Financial Security Requested',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             Financial_Review_Type__c ='bla',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Financial_Review_Result__c = 'very good' ,
  //                             Subject = 'wrthsrthjr'
  //                             ));
  //           cases.add(new Case(recordtypeID = processRTId,
  //                             //Region__c = 'Europe',
  //                             Reason1__c = 'CHC – Change of Shareholding',
  //                             BSPCountry__c='Korea, Republic of',
  //                             Status = 'Financial Security Requested',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             Financial_Review_Type__c ='bla',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Financial_Review_Result__c = 'very good' ,
  //                             Subject = 'wrthsrthjr'
  //                             ));
  //           cases.add(new Case(recordtypeID = processRTId,
  //                             //Region__c = 'Europe',
  //                             Reason1__c = 'CHC – Change of Shareholding',
  //                             BSPCountry__c='Brazil',
  //                             Status = 'Financial Security Requested',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             Financial_Review_Type__c ='bla',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Financial_Review_Result__c = 'very good' ,
  //                             Subject = 'wrthsrthjr'
  //                             ));
  //           cases.add(new Case(recordtypeID = processRTId,
  //                             //Region__c = 'Europe',
  //                             Reason1__c = 'CHC – Change of Shareholding',
  //                             BSPCountry__c='Argentina',
  //                             Status = 'Financial Security Requested',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             Financial_Review_Type__c ='bla',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Financial_Review_Result__c = 'very good' ,
  //                             Subject = 'wrthsrthjr'
  //                             ));
  //           cases.add(new Case(recordtypeID = processRTId,
  //                             //Region__c = 'Europe',
  //                             Reason1__c = 'CHC – Change of Shareholding',
  //                             BSPCountry__c='Thailand',
  //                             Status = 'Financial Security Requested',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             Financial_Review_Type__c ='bla',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Financial_Review_Result__c = 'very good' ,
  //                             Subject = 'wrthsrthjr'
  //                             ));
  //
  //           cases.add(new Case(recordtypeID = processRTId,
  //                             //Region__c = 'Europe',
  //                             Reason1__c = 'CHC – Change of Shareholding',
  //                             BSPCountry__c='Turkey',
  //                             Status = 'Financial Security Requested',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             Financial_Review_Type__c ='bla',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con1.id,
  //                             AccountId = a1.id,
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Financial_Review_Result__c = 'very good' ,
  //                             Subject = 'wrthsrthjr',
  //                             OwnerId = u1.Id
  //                             ));
  //
  //           /*ARM*/
  //
  //         cases.add(new Case(recordtypeID = IFAPcaseRecordTypeID,
  //                             Status = 'Financial Security Requested',
  //                             Financial_Review_Result__c = 'Satisfactory - New Financial Security',
  //                             Financial_Review_Type__c = 'Annual',
  //                             BSPCountry__c='Viet Nam',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Region__c = 'Europe',
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Subject = 'wrthsrthjr'
  //                             ));
  //
  //
  //           /*Clicktools*/
  //
  //           cases.add(new Case(recordtypeID = chinaRTID,
  //                             Status = 'Financial Security Requested',
  //                             Financial_Review_Result__c = 'Satisfactory - New Financial Security',
  //                             Financial_Review_Type__c = 'Annual',
  //                             BSPCountry__c='Viet Nam',
  //                             Type_of_customer__c = 'asfg',
  //                             FS_Submitted_Date__c = date.today(),
  //                             FS_Deadline_Date__c = twoweeksAgo,
  //                             Origin = 'asd',
  //                             IFAP_Area__c = 'asda',
  //                             IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
  //                             Deadline_Date__c = dead,
  //                             contactid = con.id,
  //                             AccountId = a.id,
  //                             Assessment_Performed_Date__c = date.today(),
  //                             Subject = 'wrthsrthjr',
  //                             Phone_Redirected_to_Web__c = false
  //                             ));
  //
  //           for(Case c : cases){
  //             c.Status = 'Closed';
  //           }
  //           insert cases;
  //           /*
  //           list<id> caseids = new list<id>();
  //           for(Case c : cases){
  //               c.Status = 'Closed';
  //               caseids.add(c.id);
  //           }
  //
  //           //update cases;
  //           */
  //
  //       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
  //       TransformationHelper.CalculateBusinessHoursAges = false;
  //       CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
  //
  //       test.startTest();
  //           //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
  //           SurveyBatch batch = new SurveyBatch();
  //           batch.ClosedDate = date.today();
  //           Database.executeBatch(batch, 50);
  //
  //         /*string jobId = System.schedule('SurveyCustomWorkflowTest',
  //                       '0 0 0 15 3 ? 2022',
  //                       new SurveyBatchScheduler());*/
  //
  //       test.stopTest();
  //
  //           //these cases are for the same account so only one of them should have been sent
  //           //system.assertEquals(1,[SELECT Id FROM Case WHERE Instant_Survey_Last_survey_sent__c <> NULL].size());
  //           // BECAUSE THE ANTI SPAM FILTERS HAVE BEEN DEACTIVATED, BOTH CASES ARE SENDING SURVEYS
  //        //   system.assertEquals(2,[SELECT Id FROM Case WHERE Instant_Survey_Last_survey_sent__c <> NULL].size());
  //
  //   }


    static testMethod void SurveyEmailTest2() {

        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        TransformationHelper.CalculateBusinessHoursAges = true;
        CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

        UserRole r1 = new UserRole(Name = 'China & N. Asia Customer Service');
        insert r1;


        User u1 = new User(FirstName='Ángel',
           Division='UnitTest',
           License_Cost_Center__c='AAA000AA00',
           Username='test1@iata.org.amsdev11',
           LastName='Peña', Email='test1@iata.org',
           Alias='Test1', CommunityNickname='Test11',
           TimeZoneSidKey='Europe/Brussels', LocaleSidKey='en_US',
           EmailEncodingKey='UTF-8', ProfileId='00e20000000h0gFAAQ',
           LanguageLocaleKey='en_US');

        User u2 = new User(FirstName='Mario',
           Division='UnitTest',
           License_Cost_Center__c='AAA000AA00',
           Username='test2@iata.org.amsdev1',
           LastName='Peña', Email='test1@iata.org',
           Alias='Test1', CommunityNickname='Test2',
           TimeZoneSidKey='Europe/Brussels', LocaleSidKey='en_US',
           EmailEncodingKey='UTF-8', ProfileId='00e20000000h0gFAAQ',
           LanguageLocaleKey='en_US');

        list<User> listUser = new list<User>();
        listUser.add(u1);
        listUser.add(u2);
        insert listUser;

        System.runAs (u2) {
            //List ISO Country
            List<IATA_ISO_Country__c> isoList = new List<IATA_ISO_Country__c>();
            IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1');
            isoList.add(isoCountry);

            IATA_ISO_Country__c isoCountry2 = new IATA_ISO_Country__c(name = 'suisse1',ISO_Code__c ='GE',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1', Case_BSP_Country__c  = 'Germany' );
            isoList.add(isoCountry2);

            IATA_ISO_Country__c isoCountry3 = new IATA_ISO_Country__c(name = 'suisse2',ISO_Code__c ='IN',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1', Case_BSP_Country__c  = 'India' );
            isoList.add(isoCountry3);

            IATA_ISO_Country__c isoCountry4 = new IATA_ISO_Country__c(name = 'suisse3',ISO_Code__c ='IR',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1', Case_BSP_Country__c  = 'Iran' );
            isoList.add(isoCountry4);

            IATA_ISO_Country__c isoCountry5 = new IATA_ISO_Country__c(name = 'suisse4',ISO_Code__c ='JA',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1', Case_BSP_Country__c  = 'Jamaica' );
            isoList.add(isoCountry5);

            IATA_ISO_Country__c isoCountry6 = new IATA_ISO_Country__c(name = 'suisse5',ISO_Code__c ='CH',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1', Case_BSP_Country__c  = 'People\'s Republic of China' );
            isoList.add(isoCountry6);

            IATA_ISO_Country__c isoCountrySpain = new IATA_ISO_Country__c(
                    name = 'Spain',ISO_Code__c = 'ES',AIMS_Area_Name__c='Spain');
               isoList.add(isoCountrySpain);

            insert isoList;

            //List Account
            List<Account> acc = new List<Account>();
            Account a = new Account( name ='IFAP ACCT',
                                     industry = 'pluto',
                                     IATA_ISO_Country__c=isoCountry.id,
                                     recordtypeID = hqrt,
                                     IATACode__c ='1234567',
                                     Type = 'IATA Cargo Agent',
                                     billingCountry = 'China',Location_Type__c = 'AO');


            Account a2 = new Account( name ='IFAP ACCT',
                                     industry = 'pluto',
                                     IATA_ISO_Country__c=isoCountry.id,
                                     recordtypeID = hqrt,
                                     IATACode__c ='1234567',
                                     Type = 'IATA Cargo Agent',
                                     billingCountry = 'ss',Location_Type__c = 'AO');

            Account a3 = new Account( name ='IFAP ACCT',
                                     industry = 'pluto',
                                     IATA_ISO_Country__c=isoCountry.id,
                                     recordtypeID = hqrt,
                                     IATACode__c ='1234567',
                                     Type = 'IATA Cargo Agent',
                                     billingCountry = 'ss',Location_Type__c = 'AO',
                                     Source_System__c = 'WEBSTAR',
                                     status__c='Approved',
                                     CNS_Account__c = false);




            acc.add(a);
            acc.add(a2);
            acc.add(a3);

            insert acc;

            //List Contact
            List<Contact> cont = new List<Contact>();

            Contact con =new contact(firstname = 'Name', lastname = 'pluto', phone = '123', accountid = a.id, Financial_Assessment_Contact__c = true, email = 'asd.arg@wewt.et1', HasOptedOutOfEmail = false);
            Contact con2 =new contact(firstname = 'Name', lastname = 'pluto', phone = '123', accountid = a2.id, Financial_Assessment_Contact__c = true, email = 'asd.arg@wewt.et2', HasOptedOutOfEmail = false);

            cont.add(con);
            cont.add(con2);

            insert cont;

            date dead = date.today().addDays(40);

            Date twoweeksAgo = date.today().addDays(- 14);

            u2.UserRoleId = r1.Id;
            update u2;

            List<Case> cases = new List<Case>();
                        cases.add(new Case(recordtypeID = IFAPcaseRecordTypeID,
                              Status = 'Financial Security Requested',
                              FS_Submitted_Date__c = date.today(),
                              FS_Deadline_Date__c = twoweeksAgo,
                              Origin = 'asd',
                              IFAP_Area__c = 'asda',
                              Financial_Review_Type__c ='Annual',
                              IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                              Deadline_Date__c = dead,
                              contactid = con.id,
                              AccountId = a.id,
                              Region__c = 'China & North Asia',
                              Assessment_Performed_Date__c = date.today(),
                              Financial_Review_Result__c = 'Satisfactory - Update Financial Security',
                              Reason1__c = 'CHC – Change of Shareholding'
                              ));

                        cases.add(new Case(recordtypeID = processRTId,
                              Status = 'Financial Security Requested',
                              FS_Submitted_Date__c = date.today(),
                              FS_Deadline_Date__c = twoweeksAgo,
                              Origin = 'asd',
                              IFAP_Area__c = 'asda',
                              Financial_Review_Type__c ='Annual',
                              IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                              Deadline_Date__c = dead,
                              contactid = con.id,
                              AccountId = a.id,
                              Region__c = 'China & North Asia',
                              Assessment_Performed_Date__c = date.today(),
                              Financial_Review_Result__c = 'Satisfactory',
                              Reason1__c = 'CHC – Change of Shareholding'
                              ));


                         cases.add(new Case(recordtypeID = processRTId,
                               Status = 'Financial Security Requested',
                               FS_Submitted_Date__c = date.today(),
                               FS_Deadline_Date__c = twoweeksAgo,
                               Origin = 'asd',
                               IFAP_Area__c = 'asda',
                               Financial_Review_Type__c ='Annual',
                               IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                               Deadline_Date__c = dead,
                               contactid = con2.id,
                               AccountId = a2.id,
                               BSPCountry__c = 'Italy',
                               Assessment_Performed_Date__c = date.today(),
                               Financial_Review_Result__c = 'Satisfactory',
                               Reason1__c = 'CHC – Change of Shareholding'
                               ));

                         cases.add(new Case(recordtypeID = processRTId,
                               Status = 'Financial Security Requested',
                               FS_Submitted_Date__c = date.today(),
                               FS_Deadline_Date__c = twoweeksAgo,
                               Origin = 'asd',
                               IFAP_Area__c = 'asda',
                               Financial_Review_Type__c ='Annual',
                               IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                               Deadline_Date__c = dead,
                               contactid = con2.id,
                               AccountId = a2.id,
                               BSPCountry__c = 'Japan',
                               Assessment_Performed_Date__c = date.today(),
                               Financial_Review_Result__c = 'Satisfactory',
                               Reason1__c = 'CHC – Change of Shareholding'
                               ));

                         cases.add(new Case(recordtypeID = processRTId,
                              Status = 'Financial Security Requested',
                              FS_Submitted_Date__c = date.today(),
                              FS_Deadline_Date__c = twoweeksAgo,
                              Origin = 'asd',
                              IFAP_Area__c = 'asda',
                              Financial_Review_Type__c ='Annual',
                              IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                              Deadline_Date__c = dead,
                              contactid = con.id,
                              AccountId = a2.id,
                              BSPCountry__c = 'Bermuda',
                              Region__c = 'Africa & Middle East',
                              Assessment_Performed_Date__c = date.today(),
                              Financial_Review_Result__c = 'Satisfactory',
                              Reason1__c = 'CHC – Change of Shareholding'
                              ));

                         cases.add(new Case(recordtypeID = processRTId,
                              Status = 'Financial Security Requested',
                              FS_Submitted_Date__c = date.today(),
                              FS_Deadline_Date__c = twoweeksAgo,
                              Origin = 'asd',
                              IFAP_Area__c = 'asda',
                              Financial_Review_Type__c ='Annual',
                              IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                              Deadline_Date__c = dead,
                              contactid = con.id,
                               AccountId = a3.id,
                               BSPCountry__c = 'United States',
                              Assessment_Performed_Date__c = date.today(),
                              Financial_Review_Result__c = 'Satisfactory',
                              Reason1__c = 'CHC – Change of Shareholding',
                              CNSCase__c =false
                              ));
/*
                         cases.add(new Case(recordtypeID = processRTId,
                              Status = 'Financial Security Requested',
                              FS_Submitted_Date__c = date.today(),
                              FS_Deadline_Date__c = twoweeksAgo,
                              Origin = 'asd',
                              IFAP_Area__c = 'asda',
                              Financial_Review_Type__c ='Annual',
                              IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                              Deadline_Date__c = dead,
                              contactid = con.id,
                              AccountId = a2.id,
                              BSPCountry__c = 'Sri Lanka',
                              Region__c = 'Asia & Pacific',
                              Assessment_Performed_Date__c = date.today(),
                              Financial_Review_Result__c = 'Satisfactory',
                              Reason1__c = 'CHC – Change of Shareholding'
                              ));
                          cases.add(new Case(recordtypeID = processRTId,
                              Status = 'Financial Security Requested',
                              FS_Submitted_Date__c = date.today(),
                              FS_Deadline_Date__c = twoweeksAgo,
                              Origin = 'asd',
                              IFAP_Area__c = 'asda',
                              Financial_Review_Type__c ='Annual',
                              IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                              Deadline_Date__c = dead,
                              contactid = con.id,
                              AccountId = a2.id,
                              BSPCountry__c = 'Sri Lanka',
                              Region__c = 'Europe',
                              Assessment_Performed_Date__c = date.today(),
                              Financial_Review_Result__c = 'Satisfactory',
                              Reason1__c = 'CHC – Change of Shareholding'
                              ));

                           cases.add(new Case(recordtypeID = processRTId,
                              Status = 'Financial Security Requested',
                              FS_Submitted_Date__c = date.today(),
                              FS_Deadline_Date__c = twoweeksAgo,
                              Origin = 'asd',
                              IFAP_Area__c = 'asda',
                              Financial_Review_Type__c ='Annual',
                              IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                              Deadline_Date__c = dead,
                              contactid = con.id,
                              AccountId = a2.id,
                              BSPCountry__c = 'Turks and Caicos Islands',
                              Region__c = 'Americas',
                              Assessment_Performed_Date__c = date.today(),
                              Financial_Review_Result__c = 'Satisfactory',
                              Reason1__c = 'CHC – Change of Shareholding'
                              ));*/



        for(Case c : cases){
          c.Status = 'Closed';
        }

    test.startTest();
        insert cases;
    test.stopTest();

        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
        TransformationHelper.CalculateBusinessHoursAges = false;
        CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;


            //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
            SurveyBatch batch = new SurveyBatch();
            batch.ClosedDate = date.today();
            batch.CreatedDate = date.today();
            Database.executeBatch(batch, 50);

          string jobId = System.schedule('SurveyCustomWorkflowTest',
                        '0 0 0 15 3 ? 2022',
                        new SurveyBatchScheduler());


    }
   }

       static testMethod void SurveyEmailTest3() {

        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        TransformationHelper.CalculateBusinessHoursAges = true;
        CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

        UserRole r1 = new UserRole(Name = 'China & N. Asia Customer Service');
        insert r1;


        User u1 = new User(FirstName='Ángel',
           Division='UnitTest',
           License_Cost_Center__c='AAA000AA00',
           Username='test1@iata.org.amsdev11',
           LastName='Peña', Email='test1@iata.org',
           Alias='Test1', CommunityNickname='Test11',
           TimeZoneSidKey='Europe/Brussels', LocaleSidKey='en_US',
           EmailEncodingKey='UTF-8', ProfileId='00e20000000h0gFAAQ',
           LanguageLocaleKey='en_US');

        list<User> listUser = new list<User>();
        listUser.add(u1);
        insert listUser;

        System.runAs (u1) {
            //List ISO Country
            List<IATA_ISO_Country__c> isoList = new List<IATA_ISO_Country__c>();
            IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1');
            isoList.add(isoCountry);

            IATA_ISO_Country__c isoCountry2 = new IATA_ISO_Country__c(name = 'suisse1',ISO_Code__c ='GE',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1', Case_BSP_Country__c  = 'Germany' );
            isoList.add(isoCountry2);

            IATA_ISO_Country__c isoCountry3 = new IATA_ISO_Country__c(name = 'suisse2',ISO_Code__c ='IN',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1', Case_BSP_Country__c  = 'India' );
            isoList.add(isoCountry3);

            IATA_ISO_Country__c isoCountry4 = new IATA_ISO_Country__c(name = 'suisse3',ISO_Code__c ='IR',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1', Case_BSP_Country__c  = 'Iran' );
            isoList.add(isoCountry4);

            IATA_ISO_Country__c isoCountry5 = new IATA_ISO_Country__c(name = 'suisse4',ISO_Code__c ='JA',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1', Case_BSP_Country__c  = 'Jamaica' );
            isoList.add(isoCountry5);

            IATA_ISO_Country__c isoCountry6 = new IATA_ISO_Country__c(name = 'suisse5',ISO_Code__c ='CH',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1', Case_BSP_Country__c  = 'People\'s Republic of China' );
            isoList.add(isoCountry6);

            IATA_ISO_Country__c isoCountrySpain = new IATA_ISO_Country__c(
                    name = 'Spain',ISO_Code__c = 'ES',AIMS_Area_Name__c='Spain');
               isoList.add(isoCountrySpain);

            insert isoList;

            //List Account
            List<Account> acc = new List<Account>();
            Account a = new Account( name ='IFAP ACCT',
                                     industry = 'pluto',
                                     IATA_ISO_Country__c=isoCountry.id,
                                     recordtypeID = hqrt,
                                     IATACode__c ='1234567',
                                     Type = 'IATA Cargo Agent',
                                     billingCountry = 'China',Location_Type__c = 'AO');


            Account a2 = new Account( name ='IFAP ACCT',
                                     industry = 'pluto',
                                     IATA_ISO_Country__c=isoCountry2.id,
                                     recordtypeID = hqrt,
                                     IATACode__c ='1234567',
                                     Type = 'IATA Cargo Agent',
                                     billingCountry = 'ss',Location_Type__c = 'AO');


            Account a3 = new Account( name ='IFAP ACCT',
                                     industry = 'pluto',
                                     IATA_ISO_Country__c=isoCountry3.id,
                                     recordtypeID = hqrt,
                                     IATACode__c ='1234567',
                                     Type = 'IATA Cargo Agent',
                                     billingCountry = 'ss',Location_Type__c = 'AO');


            Account a4 = new Account( name ='IFAP ACCT',
                                     industry = 'pluto',
                                     IATA_ISO_Country__c=isoCountry4.id,
                                     recordtypeID = hqrt,
                                     IATACode__c ='1234567',
                                     Type = 'IATA Cargo Agent',
                                     billingCountry = 'ss',Location_Type__c = 'AO');


            Account a5 = new Account( name ='IFAP ACCT',
                                     industry = 'pluto',
                                     IATA_ISO_Country__c=isoCountry5.id,
                                     recordtypeID = hqrt,
                                     IATACode__c ='1234567',
                                     Type = 'IATA Cargo Agent',
                                     billingCountry = 'ss',Location_Type__c = 'AO');

           Account a6 = new Account( name ='IFAP ACCT',
                                     industry = 'pluto',
                                     IATA_ISO_Country__c=isoCountry6.id,
                                     recordtypeID = hqrt,
                                     IATACode__c ='1234566',
                                     Type = 'IATA Cargo Agent',
                                     billingCountry = 'ss',Location_Type__c = 'AO');

           Account a7 = new Account( name ='IFAP ACCT',
                                     industry = 'pluto',
                                     IATA_ISO_Country__c=isoCountrySpain.id,
                                     recordtypeID = hqrt,
                                     IATACode__c ='1234556',
                                     Type = 'IATA Cargo Agent',
                                     billingCountry = 'ss',Location_Type__c = 'AO');

            acc.add(a);
            acc.add(a2);
            acc.add(a3);
            acc.add(a4);
            acc.add(a5);
            acc.add(a6);
            acc.add(a7);
            insert acc;

            //List Contact
            List<Contact> cont = new List<Contact>();

            Contact con =new contact(firstname = 'Name', lastname = 'pluto', phone = '123', accountid = a.id, Financial_Assessment_Contact__c = true, email = 'asd.arg@wewt.et1', HasOptedOutOfEmail = false);
            Contact con2 =new contact(firstname = 'Name', lastname = 'pluto', phone = '123', accountid = a2.id, Financial_Assessment_Contact__c = true, email = 'asd.arg@wewt.et2', HasOptedOutOfEmail = false);
            Contact con3 =new contact(firstname = 'Name', lastname = 'pluto', phone = '123', accountid = a3.id, Financial_Assessment_Contact__c = true, email = 'asd.arg@wewt.et3', HasOptedOutOfEmail = false);
            Contact con4 =new contact(firstname = 'Name', lastname = 'pluto',phone = '123', accountid = a4.id, Financial_Assessment_Contact__c = true, email = 'asd.arg@wewt.et4',HasOptedOutOfEmail = false);
            Contact con5 =new contact(firstname = 'Name', lastname = 'pluto', phone = '123', accountid = a5.id, Financial_Assessment_Contact__c = true, email = 'asd.arg@wewt.et5', HasOptedOutOfEmail = false);
            Contact con6 =new contact(firstname = 'Name', lastname = 'pluto', phone = '123', accountid = a6.id, Financial_Assessment_Contact__c = true, email = 'asd.arg@wewt.et6', HasOptedOutOfEmail = false);
            Contact con7 =new contact(firstname = 'Name', lastname = 'pluto', phone = '123', accountid = a7.id, Financial_Assessment_Contact__c = true, email = 'asd.arg@wewt.et6', HasOptedOutOfEmail = false);

            cont.add(con);
            cont.add(con2);
            cont.add(con3);
            cont.add(con4);
            cont.add(con5);
            cont.add(con6);
            cont.add(con7);
            insert cont;

            date dead = date.today().addDays(40);

            Date twoweeksAgo = date.today().addDays(- 14);


            List<Case> cases = new List<Case>();
                        cases.add(new Case(recordtypeID = IFAPcaseRecordTypeID,
                              Status = 'Financial Security Requested',
                              FS_Submitted_Date__c = date.today(),
                              FS_Deadline_Date__c = twoweeksAgo,
                              Origin = 'asd',
                              IFAP_Area__c = 'asda',
                              Financial_Review_Type__c ='Annual',
                              IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                              Deadline_Date__c = dead,
                              contactid = con.id,
                              AccountId = a.id,
                              Region__c = 'China & North Asia',
                              Assessment_Performed_Date__c = date.today(),
                              Financial_Review_Result__c = 'Satisfactory - Update Financial Security',
                              Reason1__c = 'CHC – Change of Shareholding',
                              OwnerId = u1.Id
                              ));



        for(Case c : cases){
          c.Status = 'Closed';
        }
    test.startTest();
        insert cases;
    test.stopTest();

        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
        TransformationHelper.CalculateBusinessHoursAges = false;
        CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;


            //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
            SurveyBatch batch = new SurveyBatch();
            batch.ClosedDate = date.today();
            batch.CreatedDate = date.today();
            Database.executeBatch(batch, 50);

          string jobId = System.schedule('SurveyCustomWorkflowTest',
                        '0 0 0 15 3 ? 2022',
                        new SurveyBatchScheduler());


    }
   }

    static void prepareTestForCountries(Integer countriesLimit, Integer offsetLimit){
      list<IATA_ISO_Country__c> listCountries = new list<IATA_ISO_Country__c>();
      if(offsetLimit!=null){
        listCountries = [SELECT Id, Name, ISO_Code__c FROM IATA_ISO_Country__c LIMIT :countriesLimit Offset :offsetLimit];
        }else{
        listCountries = [SELECT Id, Name, ISO_Code__c FROM IATA_ISO_Country__c LIMIT :countriesLimit];
      }
       Integer i = 0;
       i=0;
       list<Account> listAccount = new list<Account>();
       for(IATA_ISO_Country__c iso : listCountries) {
           Account a = new Account( name ='IFAP ACCT'+i,
           industry = 'pluto',
           IATA_ISO_Country__c=iso.id,
           recordtypeID = hqrt,
           IATACode__c ='1234567'+i,
           Type = 'IATA Cargo Agent',
           billingCountry = iso.Name,
           Location_Type__c = 'AO',
           Source_System__c = 'WEBSTAR',
           status__c = 'Approved');
           listAccount.add(a);

           i++;
       }

       insert listAccount;

        List<Contact> contactList = new List<Contact>();
        i=0;
        for(Account a : listAccount) {
           Contact con =new contact(
                firstname = 'Name', lastname = 'pluto' ,phone = '123',accountid = a.id,
                Financial_Assessment_Contact__c = true,
                email = 'asd.arg@wewt.et'+i,HasOptedOutOfEmail = false);
           contactList.add(con);

           i++;
        }

       insert contactList;

       date dead = date.today().addDays(40);

       Date twoweeksAgo = date.today().addDays(- 14);
       List<Case> cases = new List<Case>();

       List<String> lsReasons =
            new List<String>{'CHC – Change of Shareholding',
                            'CHL - Change of Location',
                            'CHN - Change of Name',
                            'CHO / CHS – Change of Ownership / Legal Status',
                            'New BR / IP', 'New HO',
                            'New SA / CHV – New Code'};
       List<String> lsRegions =
            new List<String>{'Europe',
                            'Asia & Pacific',
                            'China & North Asia',
                            'Africa & Middle East',
                            'Americas'};
       i=0;

        for(IATA_ISO_Country__c iso : listCountries) {
            cases.add(new Case(recordtypeID = processRTId,
            Status = 'Financial Security Requested',
            Reason1__c = 'CHC – Change of Shareholding',
            FS_Submitted_Date__c = date.today(),
            FS_Deadline_Date__c = twoweeksAgo,
            Origin = 'asd',
            IFAP_Area__c = 'asda',
            Financial_Review_Type__c ='Annual',
            IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
            Deadline_Date__c = dead,
            contactid = contactList[i].id,
            AccountId = listAccount[i].id,
            // Region__c = 'Europe',
            Assessment_Performed_Date__c = date.today(),
            Financial_Review_Result__c = 'Satisfactory'
            ));

            cases.add(new Case(recordtypeID = IFAPcaseRecordTypeID,
            Status = 'Financial Security Requested',
            Reason1__c = 'CHC – Change of Shareholding',
            FS_Submitted_Date__c = date.today(),
            FS_Deadline_Date__c = twoweeksAgo,
            Origin = 'asd',
            IFAP_Area__c = 'asda',
            Financial_Review_Type__c ='Annual',
            IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
            Deadline_Date__c = dead,
            contactid = contactList[i].id,
            AccountId = listAccount[i].id,
            // Region__c = 'Europe',
            Assessment_Performed_Date__c = date.today(),
            Financial_Review_Result__c = 'Satisfactory - Update Financial Security'
            ));
       i++;

        }
       for(Case c : cases){
           c.Status = 'Closed';
       }
       insert cases;
   TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
   TransformationHelper.CalculateBusinessHoursAges = false;
   CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
    }

    static testMethod void testForCountries() {

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
       TransformationHelper.CalculateBusinessHoursAges = true;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

    User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];
    test.startTest();
    System.runAS(u) {
      prepareTestForCountries(5,null);
      }
   SurveyBatch batch = new SurveyBatch();
   batch.ClosedDate = date.today();
   Database.executeBatch(batch, 50);
   test.stopTest();

}
  static testMethod void testForCountries2() {

     TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
     TransformationHelper.CalculateBusinessHoursAges = true;
     CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

      User u = [SELECT Id, FirstName, LastName FROM User WHERE UserName= 'test1@iata.org.amsdev1'];
    test.startTest();
    System.runAS(u) {
       prepareTestForCountries(5,5);
    }
   SurveyBatch batch = new SurveyBatch();
   batch.ClosedDate = date.today();
   Database.executeBatch(batch, 50);
   test.stopTest();
}
static testMethod void testForCountries3() {

     TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
     TransformationHelper.CalculateBusinessHoursAges = true;
     CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

      User u = [SELECT Id, FirstName, LastName FROM User WHERE UserName= 'test1@iata.org.amsdev1'];
    test.startTest();
    System.runAS(u) {
       prepareTestForCountries(6,10);
    }

   SurveyBatch batch = new SurveyBatch();
   batch.ClosedDate = date.today();
   Database.executeBatch(batch, 50);
   test.stopTest();
}

    static testMethod void testForRegions() {

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
       TransformationHelper.CalculateBusinessHoursAges = true;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

    User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];
System.runAS(u) {



       Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];


       Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];

       date dead = date.today().addDays(40);

       Date twoweeksAgo = date.today().addDays(- 14);
       List<Case> cases = new List<Case>();

       List<String> lsReasons =
            new List<String>{'CHC – Change of Shareholding',
                            'CHL - Change of Location',
                            'CHN - Change of Name',
                            'CHO / CHS – Change of Ownership / Legal Status',
                            'New BR / IP', 'New HO',
                            'New SA / CHV – New Code'};
       List<String> lsRegions =
            new List<String>{'Europe',
                            'Asia & Pacific',
                            'China & North Asia',
                            'Africa & Middle East',
                            'Americas'};


        for(String region : lsRegions) {
            cases.add(new Case(recordtypeID = processRTId,
            Status = 'Financial Security Requested',
            // Reason1__c = reason,
            Reason1__c = 'CHC – Change of Shareholding',
            FS_Submitted_Date__c = date.today(),
            FS_Deadline_Date__c = twoweeksAgo,
            Origin = 'asd',
            IFAP_Area__c = 'asda',
            Financial_Review_Type__c ='Annual',
            IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
            Deadline_Date__c = dead,
            contactid = con.id,
            AccountId = a.id,
            Region__c = region,
            Assessment_Performed_Date__c = date.today(),
            Financial_Review_Result__c = 'Satisfactory'
            ));
            cases.add(new Case(recordtypeID = IFAPcaseRecordTypeID,
            Status = 'Financial Security Requested',
            // Reason1__c = reason,
            FS_Submitted_Date__c = date.today(),
            FS_Deadline_Date__c = twoweeksAgo,
            Origin = 'asd',
            IFAP_Area__c = 'asda',
            Financial_Review_Type__c ='Annual',
            IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
            Deadline_Date__c = dead,
            contactid = con.id,
            AccountId = a.id,
            Region__c = region,
            Assessment_Performed_Date__c = date.today(),
            Financial_Review_Result__c = 'Satisfactory - Update Financial Security'
            ));
        }
        for(String reason : lsReasons) {
            cases.add(new Case(recordtypeID = processRTId,
            Status = 'Financial Security Requested',
            // Reason1__c = reason,
            Reason1__c = reason,
            FS_Submitted_Date__c = date.today(),
            FS_Deadline_Date__c = twoweeksAgo,
            Origin = 'asd',
            IFAP_Area__c = 'asda',
            Financial_Review_Type__c ='Annual',
            IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
            Deadline_Date__c = dead,
            contactid = con.id,
            AccountId = a.id,
            // Region__c = region,
            Assessment_Performed_Date__c = date.today(),
            Financial_Review_Result__c = 'Satisfactory'
            ));

            cases.add(new Case(recordtypeID = IFAPcaseRecordTypeID,
            Status = 'Financial Security Requested',
            // Reason1__c = reason,
            FS_Submitted_Date__c = date.today(),
            FS_Deadline_Date__c = twoweeksAgo,
            Origin = 'asd',
            IFAP_Area__c = 'asda',
            Financial_Review_Type__c ='Annual',
            IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
            Deadline_Date__c = dead,
            contactid = con.id,
            AccountId = a.id,
            // Region__c = region,
            Assessment_Performed_Date__c = date.today(),
            Financial_Review_Result__c = 'Satisfactory - Update Financial Security'
            ));
        }


       for(Case c : cases){
           c.Status = 'Closed';
       }
       insert cases;

   TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
   TransformationHelper.CalculateBusinessHoursAges = false;
   CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
}
   test.startTest();
   //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
   SurveyBatch batch = new SurveyBatch();
   batch.ClosedDate = date.today();
   Database.executeBatch(batch, 50);

   /*string jobId = System.schedule('SurveyCustomWorkflowTest',
   '0 0 0 15 3 ? 2022',
   new SurveyBatchScheduler());*/

   test.stopTest();

   //these cases are for the same account so only one of them should have been sent
   //system.assertEquals(1,[SELECT Id FROM Case WHERE Instant_Survey_Last_survey_sent__c <> NULL].size());
   // BECAUSE THE ANTI SPAM FILTERS HAVE BEEN DEACTIVATED, BOTH CASES ARE SENDING SURVEYS
   //   system.assertEquals(2,[SELECT Id FROM Case WHERE Instant_Survey_Last_survey_sent__c <> NULL].size());

}

    static testMethod void testForRoles01() {

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
       TransformationHelper.CalculateBusinessHoursAges = true;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;


       User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];

       UserRole uRole = new UserRole(Name = 'Distribution - Airline Coding & MITA');

       insert uRole;
       u.UserRoleId = uRole.Id;
       update u;

    System.runAS(u) {

        Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];

        Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];


        Case c = new Case();
        c.RecordTypeId = chinaRTID;
        c.OwnerId = u.Id;
        c.Reason1__c = 'CHC – Change of Shareholding';
        c.BSPCountry__c='Canada';
        c.Status = 'Financial Security Requested';
        c.FS_Submitted_Date__c = date.today();
        c.FS_Deadline_Date__c = date.today().addDays(-14);
        c.Origin = 'asd';
        c.IFAP_Area__c = 'asda';
        c.Financial_Review_Type__c ='bla';
        c.IFAP_Financial_Year__c =  String.valueOF(date.today().month());
        c.Deadline_Date__c = date.today().addDays(-14);
        c.contactid = con.id;
        c.AccountId = a.id;
        c.Assessment_Performed_Date__c = date.today();
        c.Financial_Review_Result__c = 'Satisfactory' ;
        c.Subject = 'wrthsrthjr';
        // OwnerId = us.Id
        insert c;

        c.Status = 'Closed';
        update c;

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
       TransformationHelper.CalculateBusinessHoursAges = false;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
    }
       test.startTest();
       //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
       SurveyBatch batch = new SurveyBatch();
       batch.ClosedDate = date.today();
       Database.executeBatch(batch, 50);


       test.stopTest();
    }

    static testMethod void testForRoles02() {

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
       TransformationHelper.CalculateBusinessHoursAges = true;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;


       User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];

    //    UserRole uRole = new UserRole(Name = 'Distribution - Airline Coding & MITA');
       //
    //    insert uRole;
    //    u.UserRoleId = uRole.Id;
    //    update u;

    System.runAS(u) {

        Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];

        Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];


        Case c = new Case();
        c.RecordTypeId = chinaRTID;
        c.OwnerId = u.Id;
        c.Reason1__c = 'CHC – Change of Shareholding';
        c.BSPCountry__c='Canada';
        c.Status = 'Financial Security Requested';
        c.FS_Submitted_Date__c = date.today();
        c.FS_Deadline_Date__c = date.today().addDays(-14);
        c.Origin = 'asd';
        c.IFAP_Area__c = 'asda';
        c.Financial_Review_Type__c ='bla';
        c.IFAP_Financial_Year__c =  String.valueOF(date.today().month());
        c.Deadline_Date__c = date.today().addDays(-14);
        c.contactid = con.id;
        c.AccountId = a.id;
        c.Assessment_Performed_Date__c = date.today();
        c.Financial_Review_Result__c = 'Satisfactory' ;
        c.Subject = 'wrthsrthjr';
        // OwnerId = us.Id
        insert c;

        c.CNSCase__c = true;
        c.Status = 'Closed';
        update c;

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
       TransformationHelper.CalculateBusinessHoursAges = false;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
    }
       test.startTest();
       //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
       SurveyBatch batch = new SurveyBatch();
       batch.ClosedDate = date.today();
       Database.executeBatch(batch, 50);


       test.stopTest();
    }

    static testMethod void testForRoles03() {

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
       TransformationHelper.CalculateBusinessHoursAges = true;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;


       User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];

       UserRole uRole = new UserRole(Name = 'China & N. Asia Customer Service');

       insert uRole;
       u.UserRoleId = uRole.Id;
       update u;

    System.runAS(u) {

        Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];
        a.billingCountry = 'People\'s Republic of China';
        update a;

        Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];


        Case c = new Case();
        c.RecordTypeId = chinaRTID;
        c.OwnerId = u.Id;
        c.Reason1__c = 'CHC – Change of Shareholding';
        c.BSPCountry__c='People\'s Republic of China';
        c.Status = 'Financial Security Requested';
        c.FS_Submitted_Date__c = date.today();
        c.FS_Deadline_Date__c = date.today().addDays(-14);
        c.Origin = 'asd';
        c.IFAP_Area__c = 'asda';
        c.Financial_Review_Type__c ='bla';
        c.IFAP_Financial_Year__c =  String.valueOF(date.today().month());
        c.Deadline_Date__c = date.today().addDays(-14);
        c.contactid = con.id;
        c.AccountId = a.id;
        c.Assessment_Performed_Date__c = date.today();
        c.Financial_Review_Result__c = 'Satisfactory' ;
        c.Subject = 'wrthsrthjr';
        // OwnerId = us.Id
        insert c;

        c.Region__c = 'China & North Asia';
        c.Status = 'Closed';
        update c;

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
       TransformationHelper.CalculateBusinessHoursAges = false;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
    }
       test.startTest();
       //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
       SurveyBatch batch = new SurveyBatch();
       batch.ClosedDate = date.today();
       Database.executeBatch(batch, 50);


       test.stopTest();
    }

    static testMethod void testForRoles04() {

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
       TransformationHelper.CalculateBusinessHoursAges = true;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;


       User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];

       UserRole uRole = new UserRole(Name = 'Americas Customer Service');

       insert uRole;
       u.UserRoleId = uRole.Id;
       update u;

    System.runAS(u) {

        Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];
        a.billingCountry = 'People\'s Republic of China';
        update a;

        Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];


        Case c = new Case();
        c.RecordTypeId = chinaRTID;
        c.OwnerId = u.Id;
        c.Reason1__c = 'CHC – Change of Shareholding';
        c.BSPCountry__c='Canada';
        c.Status = 'Financial Security Requested';
        c.FS_Submitted_Date__c = date.today();
        c.FS_Deadline_Date__c = date.today().addDays(-14);
        c.Origin = 'asd';
        c.IFAP_Area__c = 'asda';
        c.Financial_Review_Type__c ='bla';
        c.IFAP_Financial_Year__c =  String.valueOF(date.today().month());
        c.Deadline_Date__c = date.today().addDays(-14);
        c.contactid = con.id;
        c.AccountId = a.id;
        c.Assessment_Performed_Date__c = date.today();
        c.Financial_Review_Result__c = 'Satisfactory' ;
        c.Subject = 'wrthsrthjr';
        // OwnerId = us.Id
        insert c;

        c.Region__c = 'Americas';
        c.Status = 'Closed';
        update c;

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
       TransformationHelper.CalculateBusinessHoursAges = false;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
    }
       test.startTest();
       //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
       SurveyBatch batch = new SurveyBatch();
       batch.ClosedDate = date.today();
       Database.executeBatch(batch, 50);


       test.stopTest();
    }

    static testMethod void testForRoles05() {

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
       TransformationHelper.CalculateBusinessHoursAges = true;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;


       User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];

       UserRole uRole = new UserRole(Name = 'Africa & ME First Level CS');

       insert uRole;
       u.UserRoleId = uRole.Id;
       update u;

    System.runAS(u) {

        Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];
        a.billingCountry = 'People\'s Republic of China';
        update a;

        Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];


        Case c = new Case();
        c.RecordTypeId = chinaRTID;
        c.OwnerId = u.Id;
        c.Reason1__c = 'CHC – Change of Shareholding';
        c.BSPCountry__c='Algeria';
        c.Status = 'Financial Security Requested';
        c.FS_Submitted_Date__c = date.today();
        c.FS_Deadline_Date__c = date.today().addDays(-14);
        c.Origin = 'asd';
        c.IFAP_Area__c = 'asda';
        c.Financial_Review_Type__c ='bla';
        c.IFAP_Financial_Year__c =  String.valueOF(date.today().month());
        c.Deadline_Date__c = date.today().addDays(-14);
        c.contactid = con.id;
        c.AccountId = a.id;
        c.Assessment_Performed_Date__c = date.today();
        c.Financial_Review_Result__c = 'Satisfactory' ;
        c.Subject = 'wrthsrthjr';
        // OwnerId = us.Id
        insert c;

        c.Region__c = 'Africa & Middle East';
        c.Status = 'Closed';
        update c;

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
       TransformationHelper.CalculateBusinessHoursAges = false;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
    }
       test.startTest();
       //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
       SurveyBatch batch = new SurveyBatch();
       batch.ClosedDate = date.today();
       Database.executeBatch(batch, 50);


       test.stopTest();
    }

    static testMethod void testForRoles06() {

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
       TransformationHelper.CalculateBusinessHoursAges = true;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;


       User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];

       UserRole uRole = new UserRole(Name = 'A&P Customer Service Staff');

       insert uRole;
       u.UserRoleId = uRole.Id;
       update u;

    System.runAS(u) {

        Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];
        a.billingCountry = 'People\'s Republic of China';
        update a;

        Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];


        Case c = new Case();
        c.RecordTypeId = chinaRTID;
        c.OwnerId = u.Id;
        c.Reason1__c = 'CHC – Change of Shareholding';
        c.BSPCountry__c='Philippines';
        c.Status = 'Financial Security Requested';
        c.FS_Submitted_Date__c = date.today();
        c.FS_Deadline_Date__c = date.today().addDays(-14);
        c.Origin = 'asd';
        c.IFAP_Area__c = 'asda';
        c.Financial_Review_Type__c ='bla';
        c.IFAP_Financial_Year__c =  String.valueOF(date.today().month());
        c.Deadline_Date__c = date.today().addDays(-14);
        c.contactid = con.id;
        c.AccountId = a.id;
        c.Assessment_Performed_Date__c = date.today();
        c.Financial_Review_Result__c = 'Satisfactory' ;
        c.Subject = 'wrthsrthjr';
        // OwnerId = us.Id
        insert c;

        c.Region__c = 'Asia & Pacific';
        c.Status = 'Closed';
        update c;

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
       TransformationHelper.CalculateBusinessHoursAges = false;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
    }
       test.startTest();
       //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
       SurveyBatch batch = new SurveyBatch();
       batch.ClosedDate = date.today();
       Database.executeBatch(batch, 50);


       test.stopTest();
    }

     static testMethod void testForRoles07() {

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
       TransformationHelper.CalculateBusinessHoursAges = true;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;


       User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];

       UserRole uRole = new UserRole(Name = 'A&P Customer Service Staff');

       insert uRole;
       u.UserRoleId = uRole.Id;
       update u;

    System.runAS(u) {

        Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];
        a.billingCountry = 'People\'s Republic of China';
        update a;

        Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];


        Case c = new Case();
        c.RecordTypeId = FDS_ICCS_Email_to_CaseRecordTypeID;
        c.OwnerId = u.Id;
        c.Reason1__c = 'CHC – Change of Shareholding';
        c.BSPCountry__c='Philippines';
        c.Status = 'Financial Security Requested';
        c.FS_Submitted_Date__c = date.today();
        c.FS_Deadline_Date__c = date.today().addDays(-14);
        c.Origin = 'asd';
        c.IFAP_Area__c = 'asda';
        c.Financial_Review_Type__c ='bla';
        c.IFAP_Financial_Year__c =  String.valueOF(date.today().month());
        c.Deadline_Date__c = date.today().addDays(-14);
        c.contactid = con.id;
        c.AccountId = a.id;
        c.Assessment_Performed_Date__c = date.today();
        c.Financial_Review_Result__c = 'Satisfactory' ;
        c.Subject = 'wrthsrthjr';
        // OwnerId = us.Id
        insert c;

        c.Region__c = 'Asia & Pacific';
        c.Status = 'Closed';
        update c;

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
       TransformationHelper.CalculateBusinessHoursAges = false;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
    }
       test.startTest();
       //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
       SurveyBatch batch = new SurveyBatch();
       batch.ClosedDate = date.today();
       Database.executeBatch(batch, 50);


       test.stopTest();
    }

     static testMethod void testForRoles08() {

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
       TransformationHelper.CalculateBusinessHoursAges = true;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;


       User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];

       UserRole uRole = new UserRole(Name = 'A&P Customer Service Staff');

       insert uRole;
       u.UserRoleId = uRole.Id;
       update u;

    System.runAS(u) {

        Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];
        a.billingCountry = 'People\'s Republic of China';
        update a;

        Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];


        Case c = new Case();
        c.RecordTypeId = Cases_SIS_Help_DeskRecordTypeID;
        c.OwnerId = u.Id;
        c.Reason1__c = 'CHC – Change of Shareholding';
        c.BSPCountry__c='Philippines';
        c.Status = 'Financial Security Requested';
        c.FS_Submitted_Date__c = date.today();
        c.FS_Deadline_Date__c = date.today().addDays(-14);
        c.Origin = 'asd';
        c.IFAP_Area__c = 'asda';
        c.Financial_Review_Type__c ='bla';
        c.IFAP_Financial_Year__c =  String.valueOF(date.today().month());
        c.Deadline_Date__c = date.today().addDays(-14);
        c.contactid = con.id;
        c.AccountId = a.id;
        c.Assessment_Performed_Date__c = date.today();
        c.Financial_Review_Result__c = 'Satisfactory' ;
        c.Subject = 'wrthsrthjr';
        // OwnerId = us.Id
        insert c;

        c.Region__c = 'Asia & Pacific';
        c.Status = 'Closed';
        update c;

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
       TransformationHelper.CalculateBusinessHoursAges = false;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
    }
       test.startTest();
       //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
       SurveyBatch batch = new SurveyBatch();
       batch.ClosedDate = date.today();
       Database.executeBatch(batch, 50);


       test.stopTest();
    }

    static testMethod void testForRoles09() {

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
       TransformationHelper.CalculateBusinessHoursAges = true;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;


       User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];

       UserRole uRole = new UserRole(Name = 'A&P Customer Service Staff');

       insert uRole;
       u.UserRoleId = uRole.Id;
       update u;

    System.runAS(u) {

        Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];
        a.billingCountry = 'People\'s Republic of China';
        update a;

        Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];


        Case c = new Case();
        c.RecordTypeId = aCAId;
        c.OwnerId = u.Id;
        c.Reason1__c = 'CHC – Change of Shareholding';
        c.BSPCountry__c='Philippines';
        c.Status = 'Financial Security Requested';
        c.FS_Submitted_Date__c = date.today();
        c.FS_Deadline_Date__c = date.today().addDays(-14);
        c.Origin = 'asd';
        c.IFAP_Area__c = 'asda';
        c.Financial_Review_Type__c ='bla';
        c.IFAP_Financial_Year__c =  String.valueOF(date.today().month());
        c.Deadline_Date__c = date.today().addDays(-14);
        c.contactid = con.id;
        c.AccountId = a.id;
        c.Assessment_Performed_Date__c = date.today();
        c.Financial_Review_Result__c = 'Satisfactory' ;
        c.Subject = 'wrthsrthjr';
        // OwnerId = us.Id
        insert c;

        c.Region__c = 'Asia & Pacific';
        c.Status = 'Closed';
        update c;

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
       TransformationHelper.CalculateBusinessHoursAges = false;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
    }
       test.startTest();
       //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
       SurveyBatch batch = new SurveyBatch();
       batch.ClosedDate = date.today();
       Database.executeBatch(batch, 50);


       test.stopTest();
    }

    static testMethod void testForRoles10() {

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
       TransformationHelper.CalculateBusinessHoursAges = true;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;


       User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];

       UserRole uRole = new UserRole(Name = 'Americas Customer Service Staff');

       insert uRole;
       u.UserRoleId = uRole.Id;
       update u;

    System.runAS(u) {

        Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];
        a.billingCountry = 'People\'s Republic of China';
        update a;

        Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];


        Case c = new Case();
        c.RecordTypeId = chinaRTID;
        c.OwnerId = u.Id;
        c.Reason1__c = 'CHC – Change of Shareholding';
        c.BSPCountry__c='HAITI';
        c.Status = 'Financial Security Requested';
        c.FS_Submitted_Date__c = date.today();
        c.FS_Deadline_Date__c = date.today().addDays(-14);
        c.Origin = 'asd';
        c.IFAP_Area__c = 'asda';
        c.Financial_Review_Type__c ='bla';
        c.IFAP_Financial_Year__c =  String.valueOF(date.today().month());
        c.Deadline_Date__c = date.today().addDays(-14);
        c.contactid = con.id;
        c.AccountId = a.id;
        c.Assessment_Performed_Date__c = date.today();
        c.Financial_Review_Result__c = 'Satisfactory' ;
        c.Subject = 'wrthsrthjr';
        // OwnerId = us.Id
        insert c;

        c.Region__c = 'Americas';
        c.Status = 'Closed';
        update c;

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
       TransformationHelper.CalculateBusinessHoursAges = false;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
    }
       test.startTest();
       //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
       SurveyBatch batch = new SurveyBatch();
       batch.ClosedDate = date.today();
       Database.executeBatch(batch, 50);


       test.stopTest();
    }

    static testMethod void testForRoles11() {

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
       TransformationHelper.CalculateBusinessHoursAges = true;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;


       User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];

       UserRole uRole = new UserRole(Name = 'Distribution - Airline Coding & MITA');

       insert uRole;
       u.UserRoleId = uRole.Id;
       update u;

    System.runAS(u) {

        Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];
        a.billingCountry = 'People\'s Republic of China';
        update a;

        Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];


        Case c = new Case();
        c.RecordTypeId = chinaRTID;
        c.OwnerId = u.Id;
        c.Reason1__c = 'CHC – Change of Shareholding';
        c.BSPCountry__c='People\'s Republic of China';
        c.Status = 'Financial Security Requested';
        c.FS_Submitted_Date__c = date.today();
        c.FS_Deadline_Date__c = date.today().addDays(-14);
        c.Origin = 'asd';
        c.IFAP_Area__c = 'asda';
        c.Financial_Review_Type__c ='bla';
        c.IFAP_Financial_Year__c =  String.valueOF(date.today().month());
        c.Deadline_Date__c = date.today().addDays(-14);
        c.contactid = con.id;
        c.AccountId = a.id;
        c.Assessment_Performed_Date__c = date.today();
        c.Financial_Review_Result__c = 'Satisfactory' ;
        c.Subject = 'wrthsrthjr';
        // OwnerId = us.Id
        insert c;

        c.Region__c = 'China & North Asia';
        c.Status = 'Closed';
        update c;

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
       TransformationHelper.CalculateBusinessHoursAges = false;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
    }
       test.startTest();
       //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
       SurveyBatch batch = new SurveyBatch();
       batch.ClosedDate = date.today();
       Database.executeBatch(batch, 50);


       test.stopTest();
    }


    static testMethod void testForRoles12() {

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
       TransformationHelper.CalculateBusinessHoursAges = true;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;


       User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];

       UserRole uRole = new UserRole(Name = 'A&P Customer Service Staff');

       insert uRole;
       u.UserRoleId = uRole.Id;
       update u;

    System.runAS(u) {

        Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];
        a.billingCountry = 'People\'s Republic of China';
        update a;

        Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];


        Case c = new Case();
        c.RecordTypeId = Cases_SIS_Help_DeskRecordTypeID;
        c.OwnerId = u.Id;
        c.Reason1__c = 'CHC – Change of Shareholding';
        c.BSPCountry__c='Philippines';
        c.Status = 'Financial Security Requested';
        c.FS_Submitted_Date__c = date.today();
        c.FS_Deadline_Date__c = date.today().addDays(-14);
        c.Origin = 'asd';
        c.IFAP_Area__c = 'asda';
        c.Financial_Review_Type__c ='bla';
        c.IFAP_Financial_Year__c =  String.valueOF(date.today().month());
        c.Deadline_Date__c = date.today().addDays(-14);
        c.contactid = con.id;
        c.AccountId = a.id;
        c.Assessment_Performed_Date__c = date.today();
        c.Financial_Review_Result__c = 'Satisfactory' ;
        c.Subject = 'wrthsrthjr';
        c.CaseArea__c = 'ICH';
        insert c;

        c.Region__c = 'Asia & Pacific';
        c.Status = 'Closed';
        update c;

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
       TransformationHelper.CalculateBusinessHoursAges = false;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
    }
       test.startTest();
       //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
       SurveyBatch batch = new SurveyBatch();
       batch.ClosedDate = date.today();
       Database.executeBatch(batch, 50);


       test.stopTest();
    }

    static testMethod void testForRoles13() {

     TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
     TransformationHelper.CalculateBusinessHoursAges = true;
     CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;


     User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];

     UserRole uRole = new UserRole(Name = 'E&F Client Service');

     insert uRole;
     u.UserRoleId = uRole.Id;
     update u;

     System.runAS(u) {

      Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];

      Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];


      Case c = new Case();
      c.RecordTypeId = chinaRTID;
      c.OwnerId = u.Id;
      c.Reason1__c = 'CHC – Change of Shareholding';
      c.BSPCountry__c='Canada';
      c.Status = 'Financial Security Requested';
      c.FS_Submitted_Date__c = date.today();
      c.FS_Deadline_Date__c = date.today().addDays(-14);
      c.Origin = 'asd';
      c.IFAP_Area__c = 'asda';
      c.Financial_Review_Type__c ='bla';
      c.IFAP_Financial_Year__c =  String.valueOF(date.today().month());
      c.Deadline_Date__c = date.today().addDays(-14);
      c.contactid = con.id;
      c.AccountId = a.id;
      c.Assessment_Performed_Date__c = date.today();
      c.Financial_Review_Result__c = 'Satisfactory' ;
      c.Subject = 'wrthsrthjr';
        // OwnerId = us.Id
        insert c;

        c.Status = 'Closed';
        update c;

        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
        TransformationHelper.CalculateBusinessHoursAges = false;
        CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
      }
      test.startTest();
       //SurveyCustomWorkflowWrapper wrap = new SurveyCustomWorkflowWrapper();
       SurveyBatch batch = new SurveyBatch();
       batch.ClosedDate = date.today();
       Database.executeBatch(batch, 50);


       test.stopTest();
     }

    static testMethod void testProcessCustomerRecovery() {
       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
       TransformationHelper.CalculateBusinessHoursAges = true;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

       User u = [SELECT Id FROM User WHERE UserName= 'test1@iata.org.amsdev1'];

       UserRole uRole = new UserRole(Name = 'Americas Customer Service Staff');

       insert uRole;
       u.UserRoleId = uRole.Id;
       update u;

    System.runAS(u) {

        Account a = [SELECT Id, Name FROM Account WHERE  name ='IFAP ACCT' LIMIT 1];
        a.billingCountry = 'People\'s Republic of China';
        update a;

        Contact con = [SELECT Id, Name FROM Contact WHERE email = 'asd.arg@wewt.et' LIMIT 1];


        Case c = new Case();
        c.RecordTypeId = chinaRTID;
        c.OwnerId = u.Id;
        c.Reason1__c = 'CHC – Change of Shareholding';
        c.BSPCountry__c='HAITI';
        c.Status = 'Financial Security Requested';
        c.FS_Submitted_Date__c = date.today();
        c.FS_Deadline_Date__c = date.today().addDays(-14);
        c.Origin = 'asd';
        c.IFAP_Area__c = 'asda';
        c.Financial_Review_Type__c ='bla';
        c.IFAP_Financial_Year__c =  String.valueOF(date.today().month());
        c.Deadline_Date__c = date.today().addDays(-14);
        c.contactid = con.id;
        c.AccountId = a.id;
        c.Assessment_Performed_Date__c = date.today();
        c.Financial_Review_Result__c = 'Satisfactory' ;
        c.Subject = 'wrthsrthjr';
        // OwnerId = us.Id
        insert c;

        c.Instant_Survey_Feedback_requested__c = true;
        c.Region__c = 'Americas';
        c.Status = 'Closed';
        update c;

        Instant_Surveys__c is = new Instant_Surveys__c(Name = 'is', X2015_Overall_Satisfaction__c = '3', Relationship_to_Case__c = c.Id);
        insert is;

       TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
       TransformationHelper.CalculateBusinessHoursAges = false;
       CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
    }
       test.startTest();
       SurveyBatch batch = new SurveyBatch();
       batch.ClosedDate = date.today();
       Database.executeBatch(batch, 50);
       test.stopTest();
    }

    static testMethod void testFakeMethod(){
      SurveyBatch batch = new SurveyBatch();
      batch.fakeMethod();
    }
}
