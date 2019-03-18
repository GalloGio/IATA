@isTest class AMS_OSCAR_TriggerTest {
    
    private static void loadCredentials() {
        Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        Amazon_Cred__c GenericAttach =  new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        Amazon_Cred__c recycleBin =  new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        List<Amazon_Cred__c> creds = new List<Amazon_Cred__c>();
        creds.add(Amazon_Cred);
        creds.add(GenericAttach);
        creds.add(recycleBin);
        insert creds;


        list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
            new AWSKey__c(
                name = 'adevconf',
                Key__c = 'asd', 
                Secret__c = 'asd',  
                IAS_configuration_name__c = 'asdas', 
                IAS_Access_Point__c = 'asd',
                Bucket__c = 'asd',
                AWS_ENDPOINT_URL__c = 'asd')
        };
        insert AWS_KEYs;
    }

    @testSetup static void setup(){
        AMS_ChangeCodes__c cc1 = new AMS_ChangeCodes__c(Integration_RecId__c = 'C', Name = 'DIS-AMS', Change_Code__c = 'DIS');
        AMS_ChangeCodes__c cc2 = new AMS_ChangeCodes__c(Integration_RecId__c = 'C', Name = 'FIN-AMS', Change_Code__c = 'FIN');
        upsert new List<AMS_ChangeCodes__c>{cc1, cc2};
        
		Portal_Applications__c pa = new Portal_Applications__c(name = 'Risk Profile and RHC');
		insert pa;
    }

    @isTest static void insertOSCARTest() {
        
        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();

        Test.startTest();

        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        System.assertEquals(oscar.STEP1__c,'Not Started');
        System.assertEquals(oscar.STEP10__c,'Passed');
        System.assertEquals(oscar.STEP11__c,'Not Started');
        System.assertEquals(oscar.STEP12__c,'Not Started');
        System.assertEquals(oscar.STEP13__c,'Not Started');
        System.assertEquals(oscar.STEP14__c,'Not Started');
        System.assertEquals(oscar.STEP15__c,'Not Started');
        System.assertEquals(oscar.STEP16__c,'Not Started');
        System.assertEquals(oscar.STEP17__c,'Not Started');
        System.assertEquals(oscar.STEP18__c,'Not Started');
        System.assertEquals(oscar.STEP19__c,'Not Started');
        System.assertEquals(oscar.STEP2__c,'Not Started');
        System.assertEquals(oscar.STEP20__c,'Not Started');
        System.assertEquals(oscar.STEP3__c,'Not Started');
        System.assertEquals(oscar.STEP4__c,'Not Started');
        System.assertEquals(oscar.STEP5__c,'Not Started');
        System.assertEquals(oscar.STEP6__c,'Not Started');
        System.assertEquals(oscar.STEP7__c,'Not Started');
        System.assertEquals(oscar.STEP8__c,'Not Started');
        System.assertEquals(oscar.STEP9__c,'Not Started');

        Test.stopTest();

    }

    @isTest static void updateOSCARTestOKFirstStep() {

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();
		loadCredentials();

        Test.startTest();
        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];
                
        AMS_Oscar__c oscar = [SELECT id, Account__c, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId,Oscar_Communication_Case_Id__c, AMS_Online_Accreditation__c  from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        Case oscarCase = [Select id from case where Oscar__c = :oscar.id];
        
        Attachment attc = new Attachment(
          OwnerId = UserInfo.getUserId(),
          IsPrivate = true,
          ParentId = oscarCase.Id,
          Body = Blob.valueOf('Test'),
          Name = 'test'
        );
        insert attc;

        /*** AMSU-180 ***/
        AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(
            Name= 'test owner',
            First_name__c= 'test',
            Last_name__c = 'owner',
            Email__c= 'owner.test@test.com',
            Phone__c= '123456789',
            Financial_interest__c= 100,
            AMS_Pax_Accreditation_Form__c= oscar.AMS_Online_Accreditation__c,
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner')
        );
        insert owner;

        oscar.STEP6__c = 'Passed';
        oscar.STEP10__c = 'Passed';
        oscar.STEP9__c = 'Passed';
        oscar.STEP11__c = 'Passed';
        oscar.STEP12__c = 'Passed';
        oscar.STEP13__c = 'Passed';
        oscar.STEP14__c = 'Passed';
        oscar.STEP15__c = 'Passed';
        oscar.STEP17__c = 'Passed';
        
        update oscar;

        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId,Documentation_Compliant__c,Proof_of_payment_received__c,
                 Assessment_Performed_Date__c,Financial_Assessment_requested__c,Financial_Assessment_deadline__c,Bank_Guarantee_received__c,Bank_Guarantee_deadline__c,
                 Local_Inspection_received__c,Local_Inspection_compliant__c, Issue_credit_note_if_applicable__c
                 from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        
        // JH: Where is this Documentation_Compliant__c field supposed to get filled in? Code search doesn't produce any results.
        //System.assertEquals(Date.today(), oscar.Documentation_Compliant__c);
        
        System.assertEquals(Date.today(), oscar.Proof_of_payment_received__c);
        //System.assertEquals(Date.today(), oscar.Assessment_Performed_Date__c);

        System.assertEquals(Date.today(), oscar.Bank_Guarantee_received__c);
        
        System.assertEquals(Date.today(), oscar.Local_Inspection_received__c);
        System.assertEquals('Passed', oscar.Local_Inspection_compliant__c);
        
        
        oscar.STEP11__c = 'In Progress';
        oscar.STEP12__c = 'In Progress';
        oscar.STEP13__c = 'In Progress';
        oscar.STEP20__c = 'In Progress';
        oscar.Issue_credit_note_if_applicable__c = true;
        oscar.STEP3__c = 'Passed';
        
        update oscar;
        
        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId,Fees_refund_requested__c,
                 Financial_Assessment_requested__c,Financial_Assessment_deadline__c,Bank_Guarantee_deadline__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        System.assertEquals(Date.today(), oscar.Financial_Assessment_requested__c);
        System.assertEquals(Date.today()+5, oscar.Financial_Assessment_deadline__c);
        //System.assertEquals(Date.today()+30, oscar.Bank_Guarantee_deadline__c);
        System.assertEquals(Date.today(), oscar.Fees_refund_requested__c);
        
        oscar.STEP13__c = 'Not Applicable';
        
        update oscar;
        
        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        oscar.STEP13__c = 'Failed';
        oscar.STEP11__c = 'Failed';
        
        update oscar;
        
        Test.stopTest();

    }

    @isTest static void updateOSCARTestOKSecondStep() {
        
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'FR20', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctry.Id);
        insert stt;
        
        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
        
        Account a1 = new Account(IATACode__c = '1234567', IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT ,Name='NewGenAgency',Short_Name__c='NewGenAgency', Location_Class__c = 'P', Location_Type__c = 'HE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');

        insert a1;
        
        Contact co1 = new Contact(AccountId = a1.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
        insert co1;

        ID oscarNewHeRt = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'NEW');

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Process__c = AMS_Utils.new_HO, Account__c = a1.id, Is_using_credit_card__c = true, RecordTypeId = oscarNewHeRt);
        oscar.STEP1__c = 'Passed';
        oscar.STEP12__c = 'Passed';
        oscar.STEP15__c = 'Passed';
        oscar.STEP2__c = 'Passed';
        oscar.Issue_credit_note_if_applicable__c = true;
        oscar.STEP3__c = 'Passed';
        oscar.STEP4__c = 'Passed';
        oscar.STEP5__c = 'Passed';
        oscar.First_Step_Completed__c = true;
        
        oscar.STEP12__c = 'In Progress';
        oscar.STEP13__c = 'In Progress';

        insert oscar;

        Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = caseRT);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;
    
        Attachment a = new Attachment(
          OwnerId = UserInfo.getUserId(),
          IsPrivate = true,
          ParentId = oscarCase.Id,
          Body = Blob.valueOf('Test'),
          Name = 'test'
        );
        insert a;
        
        EF_AttachmentListController.runningForEF = false;
        loadCredentials();

        AmazonFile__c aFile = new AmazonFile__c(
            Full_Name_Unique__c = 'test name',
            Case__c = oscarCase.Id
        );
        insert aFile;
        
        System.debug('CheckPoint 0');

        ID rtNew = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Head_Entity_Standard_no_Cash');

        AMS_Pax_Accreditation_Form__c theAccreditation = new AMS_Pax_Accreditation_Form__c(RecordTypeId = rtNew);

        theAccreditation.Account_Name__c='NEWGEN-559 HE5';
        theAccreditation.ISSP_AMS_Legal_Status__c='Association';
        theAccreditation.Branch_Office_Country__c= ctry.Id;
        theAccreditation.Branch_Office_Street_name_number__c='sdfsdf';
        theAccreditation.Branch_Office_City__c='sdfsdfdf';
        theAccreditation.IATA_ISO_State__c= stt.Id;
        theAccreditation.Branch_Office_Email__c='sdfsdfgdg@f3434.com';
        theAccreditation.Branch_Office_Phone__c='123123123';
        theAccreditation.ISSP_AMS_Premises_located_at_airport__c='No';
        theAccreditation.Abbreviated_name__c='NEWGEN-559 HE5';
        theAccreditation.Abbreviated_Address__c='sdfsdf';
        theAccreditation.Remittance_frequency__c='M';
        theAccreditation.Solicitation_Flag__c=false;
        theAccreditation.Location_Class__c='P';
        theAccreditation.Location_Type__c='HE';
        theAccreditation.SAAM_Case__c=oscarCase.Id;
        theAccreditation.Account_Name__c = a1.Id;

        insert theAccreditation;

        ID personRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

        AMS_Accreditation_Contact__c acontact = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = theAccreditation.Id, 
            First_name__c='Bugs', Last_name__c='Bunny', Agency_owner__c = true, Email__c='bugsandbunny@imagsd.com' , PhoneNational__c = '123123123',
            Phone__c='123123123', Contact__c = co1.Id, Financial_interest__c = 100, RecordTypeId=personRT);

        insert acontact;

        Test.startTest();

        oscar.STEP11__c = 'In Progress';

        update oscar;

        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId,Fees_refund_requested__c,
                 Financial_Assessment_requested__c,Financial_Assessment_deadline__c,Bank_Guarantee_deadline__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        System.assertEquals(Date.today(), oscar.Financial_Assessment_requested__c);
        System.assertEquals(Date.today()+5, oscar.Financial_Assessment_deadline__c);

        Test.stopTest();
        
    }

    @isTest static void updateOSCARTestNOKFirstStep() {
        
        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();

        Test.startTest();
        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        oscar.STEP1__c = 'Passed';
        oscar.STEP12__c = 'Passed';
        oscar.STEP15__c = 'Passed';
        oscar.STEP2__c = 'Passed';
        oscar.STEP3__c = 'Passed';
        oscar.STEP4__c = 'Passed';

        update oscar;

        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        System.assertEquals(oscar.STEP1__c,'Passed');
        
        oscar.STEP20__c = 'In Progress';
        
        update oscar;

        Test.stopTest();

    }

    @isTest static void updateOSCARTestNOKSecondStep() {

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();
		loadCredentials();

        Test.startTest();
        
        Id oscarCommRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId,account__c, AMS_Online_Accreditation__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
    
        Case oscarCase = [Select id from case where Oscar__c = :oscar.id];
        
        Attachment attc = new Attachment(
          OwnerId = UserInfo.getUserId(),
          IsPrivate = true,
          ParentId = oscarCase.Id,
          Body = Blob.valueOf('Test'),
          Name = 'test'
        );
        insert attc;
        
        /*** AMSU-180 ***/
        AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(
            Name= 'test owner',
            First_name__c= 'test',
            Last_name__c = 'owner',
            Email__c= 'owner.test@test.com',
            Phone__c= '123456789',
            Financial_interest__c= 100,
            AMS_Pax_Accreditation_Form__c= oscar.AMS_Online_Accreditation__c,
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner')
        );
        insert owner;  
        
        oscar.STEP5__c = 'Passed';
        oscar.STEP6__c = 'Passed';
        oscar.STEP10__c = 'Passed';
        oscar.STEP9__c = 'Passed';
        oscar.STEP11__c = 'Passed';
        oscar.STEP12__c = 'Passed';
        oscar.STEP13__c = 'Passed';
        oscar.STEP14__c = 'Passed';
        oscar.STEP15__c = 'Passed';
        oscar.STEP17__c = 'Passed';
        
        update oscar;

        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        System.assertEquals(oscar.STEP5__c,'Passed');
        
        oscar.STEP11__c = 'In Progress';
        oscar.STEP12__c = 'In Progress';
        oscar.STEP13__c = 'In Progress';
        
        update oscar;
        
        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        oscar.STEP13__c = 'Not Applicable';
        
        update oscar;
        
        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        oscar.STEP13__c = 'Failed';
        oscar.STEP11__c = 'Failed';
        
        update oscar;
        
        Case activeCase = [select id from Case where Oscar__c = :oscar.Id];
        delete activeCase;
        
        Case newCase = new Case(Status = 'New', OSCAR__c = oscar.Id, RecordTypeID = oscarCommRecordTypeId);

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= false;
        newCase.setOptions(dmo);

        insert newCase;
    
        Test.stopTest();

    }

    
     @isTest static void updateOscarToClose() {

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();

        Test.startTest();
        
        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];
        update a;
        Contact c = [select id from Contact where AccountId = :a.Id];
        
        AMS_OSCAR__c oscar = [SELECT id, Status__c, OwnerId, (SELECT Id FROM Cases__r) from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];


        try{
            oscar.Status__c = 'Closed (Closed)';
            update oscar;
        }catch(DmlException e){ /*validation on queues*/ }
                     
        try{
            oscar.Status__c = 'Closed_ Not Accepted'; 
            update oscar;
        }     catch(DmlException e){ /*validation on queues*/ }               

        try{
            oscar.Status__c = 'Closed_Rejected';
            update oscar;
        }catch(DmlException e){ /*validation on queues*/ }

        try{
            oscar.Status__c = 'Closed_Withrawn';
            update oscar;
        }catch(DmlException e){ /*validation on queues*/ }
           
        Test.stopTest();

    }
    
     @isTest static void createUpdateOscarCase() {

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();

        Test.startTest();
         
        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a.id, OwnerId = UserInfo.getUserId());
        
        insert oscar;
         
        Id oscarCommRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        Case newCase = new Case(Status = 'New', OSCAR__c = oscar.Id, RecordTypeID = oscarCommRecordTypeId);

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= false;
        newCase.setOptions(dmo);

        insert newCase;
         
        Case newCase2 = new Case(Status = 'New', OSCAR__c = oscar.Id, RecordTypeID = oscarCommRecordTypeId);

        dmo.assignmentRuleHeader.useDefaultRule= false;
        newCase2.setOptions(dmo);
         
        Case newCase3 = new Case(Status = 'New', OSCAR__c = oscar.Id, RecordTypeID = oscarCommRecordTypeId);

        dmo.assignmentRuleHeader.useDefaultRule= false;
        newCase3.setOptions(dmo);

        try {
            insert new List<Case>{newCase2, newCase3};
            System.assert(false, 'Exception expected'); // garantee that it does not pass here.
        } catch (DMLException e) {
             System.assert(e.getMessage().contains('The OSCAR assigned to this Case already has a Case Assigned.'), 'message=' + e.getMessage());
        }
         
        Case newCase4 = new Case(Status = 'New', RecordTypeID = oscarCommRecordTypeId);
        
        insert newCase4;
         
        newCase4 = [SELECT id , OSCAR__c from Case where OSCAR__c = null LIMIT 1];
        
        newCase4.OSCAR__c = oscar.Id;
        
        try {
            update newCase4;
            System.assert(false, 'Exception expected'); // garantee that it does not pass here.
        } catch (DMLException e) {
             System.assert(e.getMessage().contains('The OSCAR assigned to this Case already has a Case Assigned.'), 'message=' + e.getMessage());
        }
         
        newCase = [SELECT id , OSCAR__c from Case where OSCAR__c <> null LIMIT 1];
        
        newCase.OSCAR__c = null;
        
        try {
            update newCase;
            System.assert(false, 'Exception expected'); // garantee that it does not pass here.
        } catch (DMLException e) {
             System.assert(e.getMessage().contains('Cannot disattach OSCAR from Case.'), 'message=' + e.getMessage());
        }
        
        newCase = [SELECT id , OSCAR__c from Case where OSCAR__c <> null LIMIT 1];
        
        Id oscarCommRecordTypeId2 = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Mass_Application');
        newCase.RecordTypeId = oscarCommRecordTypeId2;
        
        try {
            update newCase;
            System.assert(false, 'Exception expected'); // garantee that it does not pass here.
        } catch (DMLException e) {
             System.assert(e.getMessage().contains('Cannot change the record type of an OSCAR Communication case having an OSCAR assigned.'), 'message=' + e.getMessage());
        }
        
        oscar = [SELECT id, status__c from AMS_OSCAR__C LIMIT 1];
        
        oscar.status__c = 'Closed (Closed)';
         
        try{
            update oscar;   
        }catch(Exception e1){}
        
        oscar = [SELECT id, status__c from AMS_OSCAR__C LIMIT 1];
        
        oscar.status__c = 'Closed_ Not Accepted';
         
        try{
            update oscar;   
        }catch(Exception e2){}
        
        oscar = [SELECT id, status__c from AMS_OSCAR__C LIMIT 1];
        
        oscar.status__c = 'Closed_Rejected';
         
        try{
            update oscar;   
        }catch(Exception e3){}
        
        oscar = [SELECT id, status__c from AMS_OSCAR__C LIMIT 1];
        
        oscar.status__c = 'Closed_Withrawn';
         
        try{
            update oscar;   
        }catch(Exception e4){} 
         
        Test.stopTest();
        
        
    }

     @isTest static void changeCodeGenOnApproval() {
        
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true, AIMS_Area_Name__c = 'FRANCE')  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'FR20', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctry.Id);
        insert stt;
        
        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
        
        Account a1 = new Account(IATACode__c = '1234567', IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT ,Name='NewGenAgency',Short_Name__c='NewGenAgency', Location_Class__c = 'P', Location_Type__c = 'HE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');

        insert a1;
        
        Contact co1 = new Contact(AccountId = a1.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
        insert co1;

        ID oscarNewHeRt = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'NEW');

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Process__c = AMS_Utils.new_HO, Account__c = a1.id, Is_using_credit_card__c = true, RecordTypeId = oscarNewHeRt);

        insert oscar;

        Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = caseRT);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

        EF_AttachmentListController.runningForEF = false;
        loadCredentials();

        AmazonFile__c aFile = new AmazonFile__c(
            Full_Name_Unique__c = 'test name',
            Case__c = oscarCase.Id
        );
        insert aFile;
        

        ID rtNew = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Head_Entity_Standard_no_Cash');

        AMS_Pax_Accreditation_Form__c theAccreditation = new AMS_Pax_Accreditation_Form__c(RecordTypeId = rtNew);

        theAccreditation.Account_Name__c='NEWGEN-559 HE5';
        theAccreditation.ISSP_AMS_Legal_Status__c='Association';
        theAccreditation.Branch_Office_Country__c= ctry.Id;
        theAccreditation.Branch_Office_Street_name_number__c='sdfsdf';
        theAccreditation.Branch_Office_City__c='sdfsdfdf';
        theAccreditation.IATA_ISO_State__c= stt.Id;
        theAccreditation.Branch_Office_Email__c='sdfsdfgdg@f3434.com';
        theAccreditation.Branch_Office_Phone__c='123123123';
        theAccreditation.ISSP_AMS_Premises_located_at_airport__c='No';
        theAccreditation.Abbreviated_name__c='NEWGEN-559 HE5';
        theAccreditation.Abbreviated_Address__c='sdfsdf';
        theAccreditation.Remittance_frequency__c='M';
        theAccreditation.Solicitation_Flag__c=false;
        theAccreditation.Location_Class__c='P';
        theAccreditation.Location_Type__c='HE';
        theAccreditation.SAAM_Case__c=oscarCase.Id;
        theAccreditation.Account_Name__c = a1.Id;

        insert theAccreditation;

        ID personRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

        AMS_Accreditation_Contact__c acontact = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = theAccreditation.Id, 
            First_name__c='Bugs', Last_name__c='Bunny', Agency_owner__c = true, Email__c='bugsandbunny@imagsd.com' , PhoneNational__c = '123123123',
            Phone__c='123123123', Contact__c = co1.Id, Financial_interest__c = 100, RecordTypeId=personRT);

        insert acontact;

        oscar.STEP6__c = AMS_Utils.PASSED;
        oscar.AMS_Online_Accreditation__c = theAccreditation.Id;
        oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
        oscar.STEP15__c = 'Passed';
        oscar.STEP12__c = 'Passed';

        update oscar;


        Test.startTest();
        
        AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

        changeCode.name = 'NEW';
        changeCode.reasonCode = '21';

        changeCode.memoText = 'New application in progress';
        changeCode.reasonDesc  = 'NEW APPLICATION';
        changeCode.status  = '2';

        AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode>{changeCode}, new List<AMS_OSCAR__c>{oscar}, new List<Account> {a1}, true); 
     

        oscar.Validation_Status__c = AMS_Utils.PASSED;
        oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        update oscar;

        oscar = [SELECT id, STEP2__c from AMS_OSCAR__c where id = :oscar.id];

        System.assertEquals(AMS_Utils.PASSED,oscar.STEP2__c);
        //TODO ASSERT: assert change code fin created


        Test.stopTest();

    }

    @isTest static void changeCodeGenOnDisapproval() {
        
        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();
        
        Account a = [SELECT id,Status__c, CNS_Agency__c from Account where Name = 'Test1 Agency' LIMIT 1];

        ID newRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'NEW');

        Test.startTest();
        
        AMS_OSCAR__c oscarT = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
        STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId,RPM_Approval__c, Is_NewGen__c from AMS_OSCAR__c limit 1];

        AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

        changeCode.name = 'NEW';
        changeCode.reasonCode = '21';

        changeCode.memoText = 'New application in progress';
        changeCode.reasonDesc  = 'NEW APPLICATION';
        changeCode.status  = '2';

        AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode>{changeCode}, new List<AMS_OSCAR__c>{oscarT}, new List<Account> {a}, true); 

        oscarT.recordTypeID = newRT;
        oscarT.STEP2__c = 'Not Started';
        oscarT.STEP12__c = 'Passed';
        oscarT.STEP15__c = 'Passed';

        update oscarT;

        oscarT.Validation_Status__c = AMS_Utils.PASSED;
        oscarT.RPM_Approval__c = AMS_Utils.AUTH_DISAPPROVAL;
        update oscarT;

        oscarT = [SELECT id, STEP2__c from AMS_OSCAR__c where id = :oscarT.id];

        System.assertEquals(AMS_Utils.FAILED,oscarT.STEP2__c);
        //TODO ASSERT: assert change code dis created

        Test.stopTest();

    }

    @isTest static void accreditationProcessLogic() {

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();

        Test.startTest();
        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId, Send_invoice__c,Send_inspection_request__c,Send_agreement__c,Update_DPC__c,Update_IRIS__c,Update_BSPLink_CASSLink__c,
            Update_Portal_Setup__c,Send_approval_letter__c,Welcome_pack__c,Off_site_storage__c,Welcome_call__c,
            Issue_disapproval_pack__c,Issue_credit_note_if_applicable__c,Release_FS_if_applicable__c,Issue_Withdrawal_notification__c,
            Issue_credit_note_withdrawal__c,Release_FS_withdrawal__c,Send_FS_request__c,Bank_Guarantee_amount__c,Update_IRIS_processing__c,
            Confirm_DD_setup_with_R_S__c,Confirm_DD_setup_with_agent__c,Confirm_DGR_DGA__c,Issue_rejection_notification_pack__c,
            Issue_billing_document__c,RPM_Approval__c, Validation_Status__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        ID newRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'NEW');

        oscar.STEP12__c = AMS_Utils.PASSED;
        oscar.Send_invoice__c = true;
        oscar.Send_inspection_request__c = true;
        oscar.Send_agreement__c = true;
        oscar.Update_DPC__c = true;
        oscar.Update_IRIS__c = true;
        oscar.Update_BSPLink_CASSLink__c = true;
        oscar.Update_Portal_Setup__c = true;
        oscar.Send_approval_letter__c = true;
        oscar.Welcome_pack__c = true;
        oscar.Off_site_storage__c = true;
        oscar.Welcome_call__c = true;
        oscar.Welcome_pack__c = true;
        oscar.Issue_disapproval_pack__c = true;
        oscar.Issue_credit_note_if_applicable__c = true;
        oscar.Release_FS_if_applicable__c = true;
        oscar.Issue_Withdrawal_notification__c = true;
        oscar.Issue_credit_note_withdrawal__c = true;
        oscar.Release_FS_withdrawal__c = true;
        oscar.Send_FS_request__c = true;
        //oscar.Bank_Guarantee_amount__c = 123;
        oscar.Update_IRIS_processing__c = true;
        oscar.Confirm_DD_setup_with_R_S__c = true;
        oscar.Confirm_DD_setup_with_agent__c = true;
        oscar.Confirm_DGR_DGA__c = true;
        oscar.Issue_rejection_notification_pack__c = true;
        oscar.Issue_billing_document__c = true;
        oscar.RPM_Approval__c = 'Reprocess case';
        oscar.Validation_Status__c = 'Passed';

        update oscar;

        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId, Send_invoice__c,Send_inspection_request__c,Send_agreement__c,Update_DPC__c,Update_IRIS__c,Update_BSPLink_CASSLink__c,
            Update_Portal_Setup__c,Send_approval_letter__c,Welcome_pack__c,Off_site_storage__c,Welcome_call__c,
            Issue_disapproval_pack__c,Issue_credit_note_if_applicable__c,Release_FS_if_applicable__c,Issue_Withdrawal_notification__c,
            Issue_credit_note_withdrawal__c,Release_FS_withdrawal__c,Send_FS_request__c,Bank_Guarantee_amount__c,Update_IRIS_processing__c,
            Confirm_DD_setup_with_R_S__c,Confirm_DD_setup_with_agent__c,Confirm_DGR_DGA__c,Issue_rejection_notification_pack__c,
            Issue_billing_document__c,RPM_Approval__c, Validation_Status__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        //TODO ASSERT: do some asserts

        Test.stopTest();

    }
    
    static testMethod void triggerHandler() {

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();
		loadCredentials();

        insert new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'Test Combination', TC_Name__c = true);

        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = [SELECT id, Status__c,OwnerId, AMS_Online_Accreditation__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        Case oscarCase = [Select id from case where Oscar__c = :oscar.id];
        
        Attachment attc = new Attachment(
          OwnerId = UserInfo.getUserId(),
          IsPrivate = true,
          ParentId = oscarCase.Id,
          Body = Blob.valueOf('Test'),
          Name = 'test'
        );
        insert attc;
        
	ID newRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CHANGE');

        /*** AMSU-180 ***/
        AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(
            Name= 'test owner',
            First_name__c= 'test',
            Last_name__c = 'owner',
            Email__c= 'owner.test@test.com',
            Phone__c= '123456789',
            Financial_interest__c= 100,
            AMS_Pax_Accreditation_Form__c= oscar.AMS_Online_Accreditation__c,
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner')
        );
        insert owner;

        oscar.recordTypeID = newRT;
        oscar.STEP6__c = AMS_Utils.PASSED;
        oscar.Type_of_change__c = 'Name';
        oscar.Change_effective_as_of__c = date.today();


        Test.startTest();
            
            update oscar;

        Test.stopTest();
    }

    @isTest static void testSTEP7() {

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();

        AMS_OSCAR__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        Test.startTest();

        oscar.Process__c = AMS_Utils.BANKACCCHANGES;
        oscar.STEP7__c = AMS_Utils.PASSED;

        update oscar;

        oscar = [SELECT id, IRIS_update_result__c FROM AMS_OSCAR__c where Process__c = :AMS_Utils.BANKACCCHANGES limit 1];

        system.debug('oscar.IRIS_update_result__c' + oscar.IRIS_update_result__c);

        system.assertEquals(oscar.IRIS_update_result__c, AMS_Utils.PASSED);

        oscar.STEP7__c = AMS_Utils.FAILED;

        update oscar;

        oscar = [SELECT id, IRIS_update_result__c FROM AMS_OSCAR__c where Process__c = :AMS_Utils.BANKACCCHANGES limit 1];

        system.assertEquals(oscar.IRIS_update_result__c, AMS_Utils.FAILED);

        Test.stopTest();
    }

    @isTest static void testSTEP25() {

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();

        AMS_OSCAR__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        Test.startTest();

        oscar.Process__c = AMS_Utils.AGENCYCHANGES;
        oscar.STEP12__c = AMS_Utils.PASSED;
        oscar.STEP25__c = AMS_Utils.PASSED;

        update oscar;

        oscar = [SELECT id, Dossier_Validation__c, Validation_result__c, Status__c FROM AMS_OSCAR__c where Process__c = :AMS_Utils.AGENCYCHANGES limit 1];

        system.assertEquals(oscar.Dossier_Validation__c, Date.today());
        system.assertEquals(oscar.Validation_result__c, AMS_Utils.PASSED);
        system.assertEquals(oscar.Status__c, 'Pending Approval');

        oscar.STEP25__c = AMS_Utils.FAILED;

        update oscar;

        oscar = [SELECT id, Dossier_Validation__c, Validation_result__c, Status__c FROM AMS_OSCAR__c where Process__c = :AMS_Utils.AGENCYCHANGES limit 1];

        system.assertEquals(oscar.Dossier_Validation__c, Date.today());
        system.assertEquals(oscar.Validation_result__c, AMS_Utils.FAILED);
        system.assertEquals(oscar.Status__c, 'On Hold_Internal');

        Test.stopTest();
    }

    @isTest static void testSTEP16() {

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();

        AMS_OSCAR__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        Test.startTest();

        oscar.Process__c = AMS_Utils.BANKACCCHANGES;
        oscar.STEP16__c = AMS_Utils.PASSED;

        update oscar;

        oscar = [SELECT id, Finalization_result__c FROM AMS_OSCAR__c where Process__c = :AMS_Utils.BANKACCCHANGES limit 1];

        system.assertEquals(oscar.Finalization_result__c, AMS_Utils.PASSED);

        oscar.STEP16__c = AMS_Utils.FAILED;

        update oscar;

        oscar = [SELECT id, Finalization_result__c FROM AMS_OSCAR__c where Process__c = :AMS_Utils.BANKACCCHANGES limit 1];

        system.assertEquals(oscar.Finalization_result__c, AMS_Utils.FAILED);

        Test.stopTest();
    }

    @isTest static void testAppointmentsUpdate() {

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();

        Test.startTest();

        AMS_OSCAR__c oscar = [SELECT Id, STEP10__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_GSA limit 1];

        oscar.STEP10__c = AMS_Utils.FAILED;

        update oscar;

        oscar.STEP10__c = AMS_Utils.PASSED;

        update oscar;

        List<AMS_Inspection__c> inspections = new List<AMS_Inspection__c>();

        inspections = [SELECT id, Accreditation_Endorsement_Status_code__c FROM AMS_Inspection__c where OSCAR__c = :oscar.Id];

        for(AMS_Inspection__c insp: inspections)
            system.assertEquals(insp.Accreditation_Endorsement_Status_code__c, '9');

        Test.stopTest();
    }

    @isTest static void testSTEP29() {

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();

        AMS_OSCAR__c oscar = [SELECT id, STEP29__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        Test.startTest();

        oscar.Process__c = AMS_Utils.AGENCYCHANGES;
        oscar.STEP29__c = AMS_Utils.PASSED;

        update oscar;

        Test.stopTest();
    }

    @isTest static void testVR_1() { 

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();

        Account a = [SELECT id,Status__c from Account where Name = 'Test2 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = [SELECT id, STEP30__c, STEP31__c, STEP32__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        Id volRelRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'VOLUNTARY_RELINQUISHMENT');

        Test.startTest();

        oscar.RecordTypeId = volRelRT;
        oscar.Process__c = AMS_Utils.VOLRELINQUISH_CA;
        oscar.Form_Effective_date__c = Date.today();
        oscar.STEP6__c = AMS_Utils.PASSED;
       
        update oscar;

        oscar.Suspend_in_BSPLink_CASSLink__c = true;
        oscar.STEP30__c = AMS_Utils.PASSED;

        update oscar;

        oscar.STEP31__c = AMS_Utils.PASSED;

        update oscar;
        
        oscar.STEP32__c = AMS_Utils.PASSED;

        update oscar;

        Test.stopTest();
    }

    @isTest static void testCertificates() {
        

        AMS_OSCAR_TestDataFactory.createCargoAgencyOSCARtestData();
        loadCredentials();
         
        Account a = [SELECT id from Account where Name = 'Test Cargo HO' LIMIT 1];

        AMS_OSCAR__c oscar = [SELECT id, STEP6__c, (SELECT Id FROM Cases__r)  
                              FROM AMS_OSCAR__c 
                              WHERE Account__c =: a.Id and Id IN (SELECT OSCAR__c FROM Case) limit 1];

        AMS_Accreditation_Contact__c dgr = [SELECT Id, Type_Of_Certificate__c FROM AMS_Accreditation_Contact__c WHERE Last_name__c = 'Plitt'];
        dgr.Type_Of_Certificate__c = AMS_Utils.CERT_DGR;
        update dgr;        
        Test.startTest();
		
        /*** AMSU-34 ***/
        AmazonFile__c file = new AmazonFile__c(Full_Name_Unique__c= 'Test', Case__c= oscar.Cases__r[0].Id); 
        insert file;
        
        oscar.STEP6__c = 'Passed';
        update oscar;

        AMS_OSCAR__c oscarT = [SELECT id, STEP6__c from AMS_OSCAR__c where id = :oscar.id];

        System.assertEquals('Passed',oscarT.STEP6__c);

        Test.stopTest();

    } 

    @isTest static void testMCLocationType() {

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();
		loadCredentials();

        Test.startTest();

        List<AMS_AgencyChangesConfig__c> customsettings = new List<AMS_AgencyChangesConfig__c>();
        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'Combination08', TC_Location_type__c = true, TCA_Fields_to_Migrate__c = 'ChangeOfLocationType',
                                                          TC_Legal_status__c = false, TC_Location__c = false, TC_Location_with_inspection__c = false, 
                                                          TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = false, 
                                                          TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false, 
                                                          TCA_Sanity_check__c = 'CAD', TCA_Application_withdrawal__c = 'CWD'));

        insert customsettings;

        Account aHo = [SELECT id, Location_Type__c from Account where Location_Type__c = 'HO' LIMIT 1];
        Account aBr = [SELECT id, Location_Type__c, Short_Name__c, Name from Account where Location_Type__c = 'BR' LIMIT 1];

        AMS_Agencies_Hierarchy__c ah1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Test Hierarchy');
        insert ah1;

        AMS_Agencies_relationhip__c ar1 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah1.id,Child_Account__c=aBr.id,Parent_Account__c=aHo.id);
        insert ar1;

        ID changeRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CHANGE');

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = aBr.id, OwnerId = UserInfo.getUserId(), Process__c = AMS_Utils.AGENCYCHANGES, RecordTypeId = changeRT);
        
        insert oscar;
         
        Id oscarCommRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        Case newCase = new Case(Status = 'New', OSCAR__c = oscar.Id, RecordTypeID = oscarCommRecordTypeId);

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= false;
        newCase.setOptions(dmo);

        insert newCase;
        
        Attachment attc = new Attachment(
          OwnerId = UserInfo.getUserId(),
          IsPrivate = true,
          ParentId = newCase.Id,
          Body = Blob.valueOf('Test'),
          Name = 'test'
        );
        insert attc;

        AMS_Pax_Accreditation_Form__c stagingArea = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = newCase.Id, Account_Name__c=aBr.Name, Short_Name__c=aBr.Short_Name__c );
        insert stagingArea;

        /*** AMSU-180 ***/
        AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(
            Name= 'test owner',
            First_name__c= 'test',
            Last_name__c = 'owner',
            Email__c= 'owner.test@test.com',
            Phone__c= '123456789',
            Financial_interest__c= 100,
            AMS_Pax_Accreditation_Form__c= stagingArea.Id,
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner')
        );
        insert owner;

        AMS_OSCAR__c oscarToUpdate = [SELECT id, STEP6__c, Type_of_change__c, Change_effective_as_of__c, AMS_Online_Accreditation__c from AMS_OSCAR__c where Process__c = :AMS_Utils.AGENCYCHANGES limit 1];        

        oscarToUpdate.STEP6__c = AMS_Utils.PASSED;
        oscarToUpdate.Type_of_change__c = AMS_Utils.LOCATION_TYPE;
        oscarToUpdate.Change_effective_as_of__c = date.today();
        oscarToUpdate.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscarToUpdate;

        AMS_OSCAR__c oscarT = [SELECT id, STEP6__c from AMS_OSCAR__c where id = :oscar.id];

        System.assertEquals('Passed',oscarT.STEP6__c);

        Test.stopTest();

    }

    @isTest static void testMCOwnershipToIATA() {

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();
		loadCredentials();

        

        List<AMS_AgencyChangesConfig__c> customsettings = new List<AMS_AgencyChangesConfig__c>();
        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'Combination10', TC_Location_type__c = false, TCA_Fields_to_Migrate__c = 'ChangeOfOwnership',
                                                          TC_Legal_status__c = false, TC_Location__c = false, TC_Location_with_inspection__c = false, 
                                                          TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = true, 
                                                          TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false, 
                                                          TCA_Sanity_check__c = 'CHI', TCA_Application_withdrawal__c = 'CHF'));

        insert customsettings;

        Account aHo = [SELECT id, Location_Type__c, Short_Name__c, Name from Account where Location_Type__c = 'HO' LIMIT 1];
        Account aBr = [SELECT id, Location_Type__c from Account where Location_Type__c = 'BR' LIMIT 1];

        /*** AMSU-180 ***/
        Contact c = new Contact(FirstName= 'test', LastName= 'contact', Email= 'test.owner@contact.com');
        insert c;

        ID changeRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CHANGE');

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = aHo.id, OwnerId = UserInfo.getUserId(), Process__c = AMS_Utils.AGENCYCHANGES, RecordTypeId = changeRT);
        
        insert oscar;
         
        Id oscarCommRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        Case newCase = new Case(Status = 'New', OSCAR__c = oscar.Id, RecordTypeID = oscarCommRecordTypeId);
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= false;
        newCase.setOptions(dmo);
        
        Test.startTest();

        insert newCase;               
        
        Attachment attc = new Attachment(
          OwnerId = UserInfo.getUserId(),
          IsPrivate = true,
          ParentId = newCase.Id,
          Body = Blob.valueOf('Test'),
          Name = 'test'
        );
        insert attc;
        AMS_Pax_Accreditation_Form__c stagingArea = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = newCase.Id, Account_Name__c=aHo.Name, Short_Name__c=aHo.Short_Name__c );
        insert stagingArea;

        
        AMS_Account_Role__c owner1 = new AMS_Account_Role__c(Account__c= aHo.Id, Contact__c= c.Id, Percentage__c= 100, RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership'));
        AMS_Account_Role__c owner2 = new AMS_Account_Role__c(Account__c= aBr.Id, Contact__c= c.Id, Percentage__c= 100, RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership'));

        insert new List<AMS_Account_Role__c> {owner1, owner2};

        AMS_OSCAR__c oscarToUpdate = [SELECT id, STEP6__c, Type_of_change__c, Change_effective_as_of__c from AMS_OSCAR__c where Process__c = :AMS_Utils.AGENCYCHANGES limit 1];        

        oscarToUpdate.STEP6__c = AMS_Utils.PASSED;
        oscarToUpdate.Type_of_change__c = AMS_Utils.OWNERSHIP_IATA;
        oscarToUpdate.Change_effective_as_of__c = date.today();
        oscarToUpdate.AMS_Target_Agency__c = aBr.Id;
        oscarToUpdate.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscarToUpdate;

        Test.stopTest();

        AMS_OSCAR__c oscarT = [SELECT id, STEP6__c from AMS_OSCAR__c where id = :oscar.id];

        System.assertEquals('Passed',oscarT.STEP6__c);
    }

    @isTest static void testMCOwnershipToNonIATA() {

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();
		loadCredentials();

        Test.startTest();

        List<AMS_AgencyChangesConfig__c> customsettings = new List<AMS_AgencyChangesConfig__c>();
        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'Combination09', TC_Location_type__c = false, TCA_Fields_to_Migrate__c = 'ChangeOfOwnership',
                                                          TC_Legal_status__c = false, TC_Location__c = false, TC_Location_with_inspection__c = false, 
                                                          TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = false, 
                                                          TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = true, TC_VMFR__c = false, 
                                                          TCA_Sanity_check__c = 'CHO', TCA_Application_withdrawal__c = 'CHF'));

        insert customsettings;

        Account a = [SELECT id, Location_Type__c, Short_Name__c, Name from Account where Location_Type__c = 'HO' LIMIT 1];

        ID changeRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CHANGE');

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a.id, OwnerId = UserInfo.getUserId(), Process__c = AMS_Utils.AGENCYCHANGES, RecordTypeId = changeRT);
        
        insert oscar;
         
        Id oscarCommRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        Case newCase = new Case(Status = 'New', OSCAR__c = oscar.Id, RecordTypeID = oscarCommRecordTypeId);

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= false;
        newCase.setOptions(dmo);

        insert newCase;
        
        Attachment attc = new Attachment(
          OwnerId = UserInfo.getUserId(),
          IsPrivate = true,
          ParentId = newCase.Id,
          Body = Blob.valueOf('Test'),
          Name = 'test'
        );
        insert attc;
        AMS_Pax_Accreditation_Form__c stagingArea = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = newCase.Id, Account_Name__c=a.Name, Short_Name__c=a.Short_Name__c );
        insert stagingArea;

        /*** AMSU-180 ***/
        AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(
            Name= 'test owner',
            First_name__c= 'test',
            Last_name__c = 'owner',
            Email__c= 'owner.test@test.com',
            Phone__c= '123456789',
            Financial_interest__c= 100,
            AMS_Pax_Accreditation_Form__c= stagingArea.Id,
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner')
        );
        insert owner;

        AMS_OSCAR__c oscarToUpdate = [SELECT id, STEP6__c, Type_of_change__c, Change_effective_as_of__c from AMS_OSCAR__c where Process__c = :AMS_Utils.AGENCYCHANGES limit 1];        

        oscarToUpdate.STEP6__c = AMS_Utils.PASSED;
        oscarToUpdate.Type_of_change__c = AMS_Utils.OWNERSHIP_NON_IATA;
        oscarToUpdate.Change_effective_as_of__c = date.today();
        oscarToUpdate.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscarToUpdate;

        AMS_OSCAR__c oscarT = [SELECT id, STEP6__c from AMS_OSCAR__c where id = :oscar.id];

        System.assertEquals('Passed',oscarT.STEP6__c);

        Test.stopTest();

    }

    @isTest static void testMCChangeOfLocation() {

        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();
		loadCredentials();

        Test.startTest();

        List<AMS_AgencyChangesConfig__c> customsettings = new List<AMS_AgencyChangesConfig__c>();
        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'Combination02', TC_Location_type__c = false, TCA_Fields_to_Migrate__c = 'ChangeOfLocation',
                                                          TC_Legal_status__c = false, TC_Location__c = true, TC_Location_with_inspection__c = false, 
                                                          TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = false, 
                                                          TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false, 
                                                          TCA_Sanity_check__c = 'CHL', TCA_Application_withdrawal__c = 'CLF'));

        insert customsettings;

        Account aHo = [SELECT id, Location_Type__c from Account where Location_Type__c = 'HO' LIMIT 1];
        Account aBr = [SELECT id, Location_Type__c, Short_Name__c, Name from Account where Location_Type__c = 'BR' LIMIT 1];

        aBr.Location_Type__c = AMS_Utils.SA;
        update aBr;

        ID changeRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CHANGE');

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = aBr.id, OwnerId = UserInfo.getUserId(), Process__c = AMS_Utils.AGENCYCHANGES, RecordTypeId = changeRT);
        
        insert oscar;
         
        Id oscarCommRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        Case newCase = new Case(Status = 'New', OSCAR__c = oscar.Id, RecordTypeID = oscarCommRecordTypeId);

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= false;
        newCase.setOptions(dmo);

        insert newCase;
        
        Attachment attc = new Attachment(
          OwnerId = UserInfo.getUserId(),
          IsPrivate = true,
          ParentId = newCase.Id,
          Body = Blob.valueOf('Test'),
          Name = 'test'
        );
        insert attc;
        AMS_Pax_Accreditation_Form__c stagingArea = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = newCase.Id, Account_Name__c=aBr.Name, Short_Name__c=aBr.Short_Name__c );
        insert stagingArea;

        /*** AMSU-180 ***/
        AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(
            Name= 'test owner',
            First_name__c= 'test',
            Last_name__c = 'owner',
            Email__c= 'owner.test@test.com',
            Phone__c= '123456789',
            Financial_interest__c= 100,
            AMS_Pax_Accreditation_Form__c= stagingArea.Id,
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner')
        );
        insert owner;

        AMS_OSCAR__c oscarToUpdate = [SELECT id, STEP6__c, Type_of_change__c, Change_effective_as_of__c from AMS_OSCAR__c where Process__c = :AMS_Utils.AGENCYCHANGES limit 1];        

        oscarToUpdate.STEP6__c = AMS_Utils.PASSED;
        oscarToUpdate.Type_of_change__c = AMS_Utils.LOCATION;
        oscarToUpdate.Change_effective_as_of__c = date.today();
        oscarToUpdate.AMS_Target_Agency__c = aHo.Id;
        oscarToUpdate.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscarToUpdate;

        AMS_OSCAR__c oscarT = [SELECT id, STEP6__c from AMS_OSCAR__c where id = :oscar.id];

        System.assertEquals('Passed',oscarT.STEP6__c);

        Test.stopTest();

    }

    @isTest static void testFetchCaseReason() {
        String result = '';

        result = AMS_OSCARTriggerHandler.fetchCaseReason('');
        System.assertEquals(result, 'Agency Changes');

        result = AMS_OSCARTriggerHandler.fetchCaseReason('Location type');
        System.assertEquals(result, 'CHG – Data Maintenance');

        result = AMS_OSCARTriggerHandler.fetchCaseReason('Ownership');
        System.assertEquals(result, 'CHO / CHS – Change of Ownership / Legal Status');

        result = AMS_OSCARTriggerHandler.fetchCaseReason('Major shareholding');
        System.assertEquals(result, 'CHC – Change of Shareholding');

        result = AMS_OSCARTriggerHandler.fetchCaseReason('Location');
        System.assertEquals(result, 'CHL - Change of Location');

        result = AMS_OSCARTriggerHandler.fetchCaseReason('Legal name');
        System.assertEquals(result, 'CHN - Change of Name');

        result = AMS_OSCARTriggerHandler.fetchCaseReason('VMFR');
        System.assertEquals(result, 'VMFR Setup/Update');

        result = AMS_OSCARTriggerHandler.fetchCaseReason('Minor shareholding');
        System.assertEquals(result, 'CHG – Data Maintenance');

        result = AMS_OSCARTriggerHandler.fetchCaseReason('Hierarchy');
        System.assertEquals(result, 'Change of Hierarchy');

        result = AMS_OSCARTriggerHandler.fetchCaseReason('Accreditation type');
        System.assertEquals(result, 'Accreditation Type');

    }    
        
    // CB - test AMS_OSCARTriggerHandler.createHoAdminNotifications
    @isTest static void test_createHoAdminNotifications() 
    {        
        Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' ,
                                    Enable_Minor_Changes_from_Portal__c = true,
                                    Local_language_Agency_details_required__c = true);
        insert country;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'); 

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '1000000';
        parent.IATA_ISO_Country__c = country.Id; 

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
        child.IATACode__c = '2000000';
        child.Location_Type__c = 'BR';
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        //insert con;

        Contact con_adm = ISSP_ObjectFactory.createNewContact();
        con_adm.AccountId= parent.Id;
        con_adm.Email = 'Test@test11.com';
        con_adm.User_Portal_Status__c = 'Approved Admin';
        //insert con_adm;
        insert new list<Contact>{con, con_adm};

        System.debug('con Id: ' + con.Id);

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = child.id,Change_effective_as_of__c = Date.today());
        oscar.STEP12__c = 'Passed';
        oscar.STEP15__c = 'Passed';
        insert oscar;
        
        Test.startTest();

        Case testCase2 = ISSP_ObjectFactory.createNewCase();
            testCase2.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase2.Reason1__c = 'Cargo';
            testCase2.Region__c = 'Europe';
            testCase2.Oscar__c = oscar.Id;
            testCase2.Customer_recovery__c = false;
            testCase2.BounceEmailCounter__c = 0.0;
            testCase2.Case_Language__c = 'English';
            testCase2.Subject = 'Test 007';
            testCase2.Reopened_case__c = 0.0;
            testCase2.AccountId = child.Id;
            testCase2.Account_Concerned__c = child.Id;
            testCase2.IFAP_Country_ISO__c = 'tq';
            testCase2.RecordTypeId = OSCAR_RECORD_TYPE_ID;
        insert testCase2;

        
        
        oscar.Process__c = AMS_Utils.BANKACCCHANGES;
        oscar.STEP16__c = AMS_Utils.PASSED;
        oscar.STEP1__c = AMS_Utils.PASSED;
        update oscar;

        Test.stopTest();

        list<Notification__c> notifications = [SELECT Id FROM Notification__c];
        System.assertNotEquals(true, notifications.isEmpty());

    }
	
    /*** AMSU-193 ***/
    @isTest static void prepopulateRF() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c();
        country.Name = 'Portugal';
        country.ISO_Code__c = 'PT';
        country.ISO_Code_Numeric__c = 11;
        insert country;

        Account agency = new Account();
        agency.Name = 'Agency';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.IATACode__c = '24125';
        agency.Location_Type__c = 'HO';
        agency.Location_Class__c = 'P';
        agency.IATA_ISO_Country__c = country.Id;
        insert agency;

        Contact agencyContact = new Contact();
        agencyContact.FirstName = 'FirstName';
        agencyContact.LastName = 'LastName';
        agencyContact.Email = 'mail@test.com';
        agencyContact.AccountId = agency.Id;
        insert agencyContact;

        AMS_OSCAR__c oscar = new AMS_OSCAR__c();  
        oscar.Account__c = agency.Id;
        oscar.OwnerId = UserInfo.getUserId();
        oscar.Process__c = AMS_Utils.new_HO;    
        oscar.RecordTypeId = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();  
        insert oscar;

        Case cse = new Case();
        cse.OSCAR__c = oscar.Id;
        cse.Status = 'New';
        cse.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
        insert cse;

        Attachment attch = new Attachment();
        attch.OwnerId = UserInfo.getUserId();
        attch.IsPrivate = true;
        attch.ParentId = cse.Id;
        attch.Body = Blob.valueOf('Test');
        attch.Name = 'test';
        insert attch;

        AMS_Pax_Accreditation_Form__c stagingArea = new AMS_Pax_Accreditation_Form__c();
        stagingArea.SAAM_Case__c = cse.Id;
        stagingArea.Account_Name__c = agency.Name;
        stagingArea.Short_Name__c= agency.Short_Name__c;
        stagingArea.Location_Class__c = 'P';
        insert stagingArea;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscar;

        AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c();
        owner.Name = 'test owner';
        owner.First_name__c = 'test';
        owner.Last_name__c = 'owner';
        owner.Email__c = 'owner.test@test.com';
        owner.Phone__c = '123456789';
        owner.Financial_interest__c = 100;
        owner.AMS_Pax_Accreditation_Form__c = stagingArea.Id;
        owner.RecordTypeId = Schema.AMS_Accreditation_Contact__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Current Owner').getRecordTypeId();
        insert owner;

        Test.startTest();
        AMS_Settlement_System__c issOperation = new AMS_Settlement_System__c();
        issOperation.Name = 'TEST';
        issOperation.RecordTypeId = Schema.AMS_Settlement_System__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('BSP').getRecordTypeId();
        insert issOperation;

        AMS_Operation__c operation = new AMS_Operation__c();
        operation.Country__c = country.Id;
        operation.Settlement__c = issOperation.Id;
        operation.Name = 'TEST';
        insert operation;

        ANG_BSP_Attributes__c attribute = new ANG_BSP_Attributes__c();
        attribute.Operation__c = operation.Id;
        attribute.Remittance_Frequency__c = 'M';
        attribute.Class_Type__c = 'P';
        insert attribute;

        AMS_OSCARTriggerHandler.allOnlineAccr = null;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;            

        Test.stopTest();    
    }
}
