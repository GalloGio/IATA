@isTest
private class Ifap_ReminderBatchTestClass {

    static testMethod void myUnitTest() {
    	
    	TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
		TransformationHelper.CalculateBusinessHoursAges = true;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;
       
                     
            ID hqrt =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;
            ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review'); 
            
            List<IATA_ISO_Country__c> isoCountries = new List<IATA_ISO_Country__c>();
            isoCountries.add(new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1' ));
            isoCountries.add(new IATA_ISO_Country__c(name = 'italia',ISO_Code__c ='IT',AIMS_Area_Name__c='italia',AIMS_Area_ID__c= '2' ));
            isoCountries.add(new IATA_ISO_Country__c(name = 'france',ISO_Code__c ='FR',AIMS_Area_Name__c='france',AIMS_Area_ID__c= '3' ));
            //isoCountries.add(new IATA_ISO_Country__c(name = 'france2',ISO_Code__c ='F2',AIMS_Area_Name__c='france2',AIMS_Area_ID__c= '3' ));
            insert isoCountries;
            
            List<EmailTemplate__c> emailTemplates = new List<EmailTemplate__c>();
            
            emailTemplates.add(new EmailTemplate__c(name ='Suisse PAX',
                                                    Is_reminder__c = true,
                                                    Template_Type__c = 'FA - Financial Assessment',
                                                    IATA_ISO_Country__c = isoCountries[0].id));
            emailTemplates.add(new EmailTemplate__c(name ='Italia PAX',
                                                    Is_reminder__c = true,
                                                    Template_Type__c = 'FA - Financial Assessment',
                                                    IATA_ISO_Country__c = isoCountries[1].id));
            emailTemplates.add(new EmailTemplate__c(name ='France PAX',
                                                    Is_reminder__c = true,
                                                    Template_Type__c = 'FA - Financial Assessment',
                                                    IATA_ISO_Country__c = isoCountries[2].id));
            emailTemplates.add(new EmailTemplate__c(name ='France2 PAX',
                                                    Is_reminder__c = true,
                                                    Template_Type__c = 'FA - Financial Assessment',
                                                    IATA_ISO_Country__c = isoCountries[2].id));
            emailTemplates.add(new EmailTemplate__c(name ='IFAP PAX',
                                                    Is_reminder__c = true,
                                                    Template_Type__c = 'FS - Financial Security',
                                                    IATA_ISO_Country__c = isoCountries[0].id,
                                                    FA_Result__c  = 'result' ));

            insert emailtemplates;
            
            List<Account> accs = new List<Account>();
            accs.add(new Account( name ='IFAP ACCT suisse',
                                     industry = 'pluto CARGO',
                                     IATA_ISO_Country__c=isoCountries[0].id,
                                     recordtypeID = hqrt,
                                     IATACode__c ='1234567',
                                     Type = 'IATA Cargo Agent',
                                     billingCountry = 'suisse',Location_Type__c = 'AO'));
            accs.add(new Account( name ='IFAP ACCT italia',
                                     industry = 'CARGO',
                                     IATA_ISO_Country__c=isoCountries[1].id,
                                     recordtypeID = hqrt,
                                     IATACode__c ='1234568',
                                     Type = 'IATA Cargo Agent',
                                     billingCountry = 'italia',Location_Type__c = 'AO'));
            accs.add(new Account( name ='IFAP ACCT france',
                                     industry = 'CARGO',
                                     IATA_ISO_Country__c=isoCountries[2].id,
                                     recordtypeID = hqrt,
                                     IATACode__c ='1234569',
                                     Type = 'IATA Cargo Agent',
                                     billingCountry = 'france',Location_Type__c = 'AO'));
            insert accs;
            
            List<Contact> conts = new List<Contact>();
            conts.add(new Contact(lastname = 'pluto' ,
                                     firstname = 'Name',
                                     phone = '123',
                                     accountid = accs[0].id,
                                     Financial_Assessment_Contact__c = true));
            conts.add(new Contact(lastname = 'pluto' ,
                                     firstname = 'Name',
                                     phone = '123',
                                     accountid = accs[1].id,
                                     Financial_Assessment_Contact__c = true));
            conts.add(new Contact(lastname = 'pluto' ,
                                     firstname = 'Name',
                                     phone = '123',
                                     accountid = accs[2].id,
                                     Financial_Assessment_Contact__c = true));
            insert conts;
                                    
            date dead = date.today().addDays(40);
            
            Date twoweeksFromNow = date.today().addDays(+ 14);

            List<Case> cases = new List<Case>();
            cases.add(new Case(recordtypeID = IFAPcaseRecordTypeID,
                              Status = 'Financial Security Requested',
                              FS_Submitted_Date__c = date.today(),
                              FS_Deadline_Date__c = twoweeksFromNow ,
                              Origin = 'asd',
                              IFAP_Area__c = 'asda',
                              Financial_Review_Type__c ='bla',
                              IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                              Deadline_Date__c = dead,
                              contactid = conts[0].id,
                              AccountId = accs[0].id,
                              Assessment_Performed_Date__c = date.today(),
                              Financial_Review_Result__c = 'Satisfactory - No Action'  ,
                              //FS_Reminder_EmailTemplate__c   =   emailTemplates[0].id,
                              IFAP_Country_ISO__c = 'SS',
                              Subject = 'Test case Suisse'
                              ));
            
            cases.add(new Case(recordtypeID = IFAPcaseRecordTypeID,
                              Status = 'Agent Notified (Mail)',
                              FS_Submitted_Date__c = date.today(),
                              FS_Deadline_Date__c = twoweeksFromNow ,
                              Deadline_Date__c = twoweeksFromNow ,
                              Origin = 'asd',
                              IFAP_Area__c = 'asda',
                              Financial_Review_Type__c ='bla',
                              IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                              contactid = conts[1].id,
                              AccountId = accs[1].id,
                              Assessment_Performed_Date__c = date.today(),
                              Financial_Review_Result__c = 'Satisfactory - No Action'  ,
                              //FS_Reminder_EmailTemplate__c   =   emailTemplates[1].id,
                              IFAP_Country_ISO__c = 'IT',
                              Subject = 'Test case Italia'
                              ));
            
            cases.add(new Case(recordtypeID = IFAPcaseRecordTypeID,
                              Status = 'Agent Notified (Mail)',
                              FS_Submitted_Date__c = date.today(),
                              FS_Deadline_Date__c = twoweeksFromNow ,
                              Deadline_Date__c = twoweeksFromNow ,
                              Origin = 'asd',
                              IFAP_Area__c = 'asda',
                              Financial_Review_Type__c ='bla',
                              IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                              contactid = conts[2].id,
                              AccountId = accs[2].id,
                              Assessment_Performed_Date__c = date.today(),
                              Financial_Review_Result__c = 'Satisfactory - No Action'  
                              //FS_Reminder_EmailTemplate__c   =   emailTemplates[2].id                                            
              ));
           
            insert cases;

            Case c = [SELECT id, Financial_Review_Type__c FROM Case WHERE Subject = 'Test case Italia' LIMIT 1];
            c.Financial_Review_Type__c = 'Annual';
        
            update c;
            
            TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
			TransformationHelper.CalculateBusinessHoursAges = false;
			CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
            
            test.startTest();
            
            IFAP_Reminder_Batch batch = new IFAP_Reminder_Batch();
            
            database.executeBatch(batch);
            
            test.stopTest();
            
            
            // Suisse can use FS - Financial Security template
        //    cases = [SELECT Subject FROM Case WHERE FS_Reminder_EmailTemplate__c <> null];
          //  system.assertEquals(1,cases.size());
         //   system.assertEquals('Test case Suisse',cases[0].Subject);
            
            // Suisse has "FA - Financial Assessment" template
            // Italy has "FA - Financial Assessment" template
            // France has 2 "FA - Financial Assessment" templates -> none of them is chosen
         //   cases = [SELECT Subject FROM Case WHERE Reminder_EmailTemplate__c <> null];
           // system.assertEquals(2,cases.size());
            
    }
}