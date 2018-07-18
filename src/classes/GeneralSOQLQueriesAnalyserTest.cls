@isTest
private class GeneralSOQLQueriesAnalyserTest {
    
    @isTest static void testOscarHEStandard() {
        
        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        System.debug('Checkpoint 1');
        ANG_EntityCreator.checkSFDCLimits();

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'FR20', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        System.debug('Checkpoint 2');
        ANG_EntityCreator.checkSFDCLimits();

        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        
        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Sector__C','Travel Agent');
        fieldsOfObject.put('Category__C','Non-IATA Passenger Agent');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');

        Account a = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);
        insert a;

        System.debug('Checkpoint 3');
        ANG_EntityCreator.checkSFDCLimits();

        ID contactRt = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
       
        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Firstname','John');
        fieldsOfObject.put('Lastname','Rambo');
        fieldsOfObject.put('Phone','666123456');
        fieldsOfObject.put('MobilePhone','911111111');
        fieldsOfObject.put('Email','rambo.johnj@test.com');
        fieldsOfObject.put('Financial_Assessment_Contact__c',false);

        Contact co1 = ANG_EntityCreator.createContact(contactRt, a.Id, fieldsOfObject);
        insert co1;

        System.debug('Checkpoint 4');
        ANG_EntityCreator.checkSFDCLimits();

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Process__c',AMS_Utils.NEWHESTANDARD);
        fieldsOfObject.put('Is_using_credit_card__c',true);

        ID oscarNewHeRt = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_New_HE');

        AMS_OSCAR__c oscar = ANG_EntityCreator.createOscar(oscarNewHeRt, a.Id, fieldsOfObject);
        insert oscar;

        System.debug('Checkpoint 5');
        ANG_EntityCreator.checkSFDCLimits();

        Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Oscar__c',oscar.Id);
        fieldsOfObject.put('ContactId',co1.Id);

        Case c =ANG_EntityCreator.createCase(caseRT, a.Id, fieldsOfObject);
        insert c;

        System.debug('Checkpoint 6');
        ANG_EntityCreator.checkSFDCLimits();

        EF_AttachmentListController.runningForEF = false;
        ANG_EntityCreator.loadCredentials();

        AmazonFile__c aFile = new AmazonFile__c(
            Full_Name_Unique__c = 'test name',
            Case__c = c.Id
        );
        insert aFile;

        System.debug('Checkpoint 7');
        ANG_EntityCreator.checkSFDCLimits();

        ID rtNew = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c','Travel_Agent_Head_Entity_Standard_no_Cash');

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Account_Name__c','NEWGEN-559 HE5');
        fieldsOfObject.put('ISSP_AMS_Legal_Status__c','Association');
        fieldsOfObject.put('Branch_Office_Country__c', ctry.Id);
        fieldsOfObject.put('Branch_Office_Street_name_number__c','sdfsdf');
        fieldsOfObject.put('Branch_Office_City__c','sdfsdfdf');
        fieldsOfObject.put('IATA_ISO_State__c',stt.Id);
        fieldsOfObject.put('Branch_Office_Email__c','sdfsdfgdg@f3434.com');
        fieldsOfObject.put('Branch_Office_Phone__c','123123123');
        fieldsOfObject.put('ISSP_AMS_Premises_located_at_airport__c','No');
        fieldsOfObject.put('Abbreviated_name__c','NEWGEN-559 HE5');
        fieldsOfObject.put('Abbreviated_Address__c','sdfsdf');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Solicitation_Flag__c',false);
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');

        AMS_Pax_Accreditation_Form__c theAccreditation = ANG_EntityCreator.createStagingArea(rtNew, a.Id, c.Id, fieldsOfObject);
        insert theAccreditation;

        System.debug('Checkpoint 8');
        ANG_EntityCreator.checkSFDCLimits();

        ID personRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('First_name__c','Bugs');
        fieldsOfObject.put('Last_name__c','Bunny');
        fieldsOfObject.put('Agency_owner__c',true);
        fieldsOfObject.put('Email__c','bugsandbunny@imagsd.com');
        fieldsOfObject.put('PhoneNational__c','123123123');
        fieldsOfObject.put('Phone__c','123123123');
        fieldsOfObject.put('Contact__c',co1.Id);
        fieldsOfObject.put('Financial_interest__c',100);

        AMS_Accreditation_Contact__c acontact = ANG_EntityCreator.createAccreditationContact(personRT, theAccreditation.Id, fieldsOfObject);
        insert acontact;

        System.debug('Checkpoint 9');
        ANG_EntityCreator.checkSFDCLimits();

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Oscar_Communication_Case_Id__c',c.Id);
        fieldsOfObject.put('AMS_Online_Accreditation__c',theAccreditation.Id);

        oscar = ANG_EntityCreator.updateOscar(oscar, fieldsOfObject);
        update oscar;

        System.debug('Checkpoint 10');
        ANG_EntityCreator.checkSFDCLimits();

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('STEP6__c',AMS_Utils.PASSED);
        fieldsOfObject.put('Is_PCI_compliant__c','Yes');
        fieldsOfObject.put('ANG_PCI_compliance_expiry_date__c',Date.today());

        oscar = ANG_EntityCreator.updateOscar(oscar, fieldsOfObject);
        update oscar;

        System.debug('Checkpoint 11');
        ANG_EntityCreator.checkSFDCLimits();
        
        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Hierarchy_Name__c', 'Tosca hierarchy');

        AMS_Agencies_Hierarchy__c agHierarchy = new AMS_Agencies_Hierarchy__c();
        agHierarchy = ANG_EntityCreator.createAgenciesHierarchy(fieldsOfObject);
        insert agHierarchy;

        Test.stopTest();

    }

    @isTest static void testCreateUpdateAccountAndContact() {

        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'FR20', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        
        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Sector__C','Travel Agent');
        fieldsOfObject.put('Category__C','Non-IATA Passenger Agent');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');

        Account a = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);
        insert a;

        fieldsOfObject.clear();
        fieldsOfObject.put('Name','NewGenAgencyUpdated');

        a = ANG_EntityCreator.updateAccount(a, fieldsOfObject);

        ID contactRt = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
       
        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Firstname','John');
        fieldsOfObject.put('Lastname','Rambo');
        fieldsOfObject.put('Phone','666123456');
        fieldsOfObject.put('MobilePhone','911111111');
        fieldsOfObject.put('Email','rambo.johnj@test.com');
        fieldsOfObject.put('Financial_Assessment_Contact__c',false);

        Contact co1 = ANG_EntityCreator.createContact(contactRt, a.Id, fieldsOfObject);
        insert co1;

        fieldsOfObject.clear();
        fieldsOfObject.put('Lastname','Rambo Updated');

        co1 = ANG_EntityCreator.updateContact(co1,fieldsOfObject);

        Test.stopTest();

    }
    
    @isTest static void testCreateUpdatePerson() {

        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'FR20', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        
        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Sector__C','Travel Agent');
        fieldsOfObject.put('Category__C','Non-IATA Passenger Agent');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');

        Account a = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);
        insert a;

        ID contactRt = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
       
        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Firstname','John');
        fieldsOfObject.put('Lastname','Rambo');
        fieldsOfObject.put('Phone','666123456');
        fieldsOfObject.put('MobilePhone','911111111');
        fieldsOfObject.put('Email','rambo.johnj@test.com');
        fieldsOfObject.put('Financial_Assessment_Contact__c',false);

        Contact co1 = ANG_EntityCreator.createContact(contactRt, a.Id, fieldsOfObject);
        insert co1;

        fieldsOfObject.clear();
        fieldsOfObject.put('First_Name__c','John');
        fieldsOfObject.put('Contact__c','co1');

        AMS_Person__c per = ANG_EntityCreator.createPerson('rambo.johnj@test.com', 'Rambo',fieldsOfObject);

        fieldsOfObject.clear();
        fieldsOfObject.put('First_Name__c','John');
        per = ANG_EntityCreator.updatePerson(per,fieldsOfObject);

        Test.stopTest();
    }

    @isTest static void testCreateUpdateCase() {

        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'FR20', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        
        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Sector__C','Travel Agent');
        fieldsOfObject.put('Category__C','Non-IATA Passenger Agent');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');

        Account a = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);
        insert a;

        ID contactRt = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
       
        fieldsOfObject.clear();
        fieldsOfObject.put('Firstname','John');
        fieldsOfObject.put('Lastname','Rambo');
        fieldsOfObject.put('Phone','666123456');
        fieldsOfObject.put('MobilePhone','911111111');
        fieldsOfObject.put('Email','rambo.johnj@test.com');
        fieldsOfObject.put('Financial_Assessment_Contact__c',false);

        Contact co1 = ANG_EntityCreator.createContact(contactRt, a.Id, fieldsOfObject);
        insert co1;

        Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('ContactId',co1.Id);

        Case c =ANG_EntityCreator.createCase(caseRT, a.Id, fieldsOfObject);
        insert c;

        fieldsOfObject.clear();
        c = ANG_EntityCreator.updateCase(c,null);

        fieldsOfObject.put('Subject','Case subject');
        c = ANG_EntityCreator.updateCase(c,fieldsOfObject);

        Test.stopTest();
    }


    @isTest static void testCreateUpdateStagingArea() {
        
        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'FR20', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        
        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Sector__C','Travel Agent');
        fieldsOfObject.put('Category__C','Non-IATA Passenger Agent');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');

        Account a = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);
        insert a;

        ID contactRt = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
       
        fieldsOfObject.clear();
        fieldsOfObject.put('Firstname','John');
        fieldsOfObject.put('Lastname','Rambo');
        fieldsOfObject.put('Phone','666123456');
        fieldsOfObject.put('MobilePhone','911111111');
        fieldsOfObject.put('Email','rambo.johnj@test.com');
        fieldsOfObject.put('Financial_Assessment_Contact__c',false);

        Contact co1 = ANG_EntityCreator.createContact(contactRt, a.Id, fieldsOfObject);
        insert co1;

        fieldsOfObject.clear();
        fieldsOfObject.put('Process__c',AMS_Utils.NEWHESTANDARD);
        fieldsOfObject.put('Is_using_credit_card__c',true);

        ID oscarNewHeRt = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_New_HE');

        AMS_OSCAR__c oscar = ANG_EntityCreator.createOscar(oscarNewHeRt, a.Id, fieldsOfObject);
        insert oscar;

        Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        fieldsOfObject.clear();
        fieldsOfObject.put('Oscar__c',oscar.Id);
        fieldsOfObject.put('ContactId',co1.Id);

        Case c =ANG_EntityCreator.createCase(caseRT, a.Id, fieldsOfObject);
        insert c;

        EF_AttachmentListController.runningForEF = false;
        ANG_EntityCreator.loadCredentials();

        AmazonFile__c aFile = new AmazonFile__c(
            Full_Name_Unique__c = 'test name',
            Case__c = c.Id
        );
        insert aFile;

        ID rtNew = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Head_Entity_Standard_no_Cash');

        fieldsOfObject.clear();
        fieldsOfObject.put('Account_Name__c','NEWGEN-559 HE5');
        fieldsOfObject.put('ISSP_AMS_Legal_Status__c','Association');
        fieldsOfObject.put('Branch_Office_Country__c', ctry.Id);
        fieldsOfObject.put('Branch_Office_Street_name_number__c','sdfsdf');
        fieldsOfObject.put('Branch_Office_City__c','sdfsdfdf');
        fieldsOfObject.put('IATA_ISO_State__c',stt.Id);
        fieldsOfObject.put('Branch_Office_Email__c','sdfsdfgdg@f3434.com');
        fieldsOfObject.put('Branch_Office_Phone__c','123123123');
        fieldsOfObject.put('ISSP_AMS_Premises_located_at_airport__c','No');
        fieldsOfObject.put('Abbreviated_name__c','NEWGEN-559 HE5');
        fieldsOfObject.put('Abbreviated_Address__c','sdfsdf');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Solicitation_Flag__c',false);
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');

        AMS_Pax_Accreditation_Form__c theAccreditation = ANG_EntityCreator.createStagingArea(rtNew, a.Id, c.Id, fieldsOfObject);
        insert theAccreditation;

        fieldsOfObject.clear();
        fieldsOfObject.put('Account_Name__c','NEWGEN-559 HE5 UPDATE');

        theAccreditation = ANG_EntityCreator.updateStagingArea(theAccreditation,fieldsOfObject);

        ID personRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

        fieldsOfObject.clear();
        fieldsOfObject.put('First_name__c','Bugs');
        fieldsOfObject.put('Last_name__c','Bunny');
        fieldsOfObject.put('Agency_owner__c',true);
        fieldsOfObject.put('Email__c','bugsandbunny@imagsd.com');
        fieldsOfObject.put('PhoneNational__c','123123123');
        fieldsOfObject.put('Phone__c','123123123');
        fieldsOfObject.put('Contact__c',co1.Id);
        fieldsOfObject.put('Financial_interest__c',100);

        AMS_Accreditation_Contact__c acontact = ANG_EntityCreator.createAccreditationContact(personRT, theAccreditation.Id, fieldsOfObject);
        insert acontact;

        fieldsOfObject.clear();
        fieldsOfObject.put('First_name__c','Bugs UPDATE');
        acontact = ANG_EntityCreator.updateAccreditationContact(acontact,fieldsOfObject);

        Test.stopTest();

    }


    @isTest static void testFailures() {

        Test.startTest();

        try{
            ANG_EntityCreator.createAccount(null,null,null);
        }catch(Exception e){}

        try{
           ANG_EntityCreator.createContact(null,null,null);
        }catch(Exception e){}

        try{
           ANG_EntityCreator.createCase(null,null,null);
        }catch(Exception e){} 

        try{
           ANG_EntityCreator.createPerson(null,null,null);
        }catch(Exception e){}

        try{
           ANG_EntityCreator.createOscar(null,null,null);
        }catch(Exception e){}
       
        try{
           ANG_EntityCreator.createStagingArea(null,null,null,null);
        }catch(Exception e){}
       
        try{
           ANG_EntityCreator.createAccreditationContact(null,null,null);
        }catch(Exception e){}

        Test.stopTest();
    }



}