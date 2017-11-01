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

        Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');
        
        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','Monthly');
        fieldsOfObject.put('Sector__C','Travel Agent');
        fieldsOfObject.put('Category__C','Non-IATA Passenger Agent');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');

        Account a = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);
        insert a;

        System.debug('Checkpoint 3');
        ANG_EntityCreator.checkSFDCLimits();

        ID contactRt = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
       
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

        ID oscarNewHeRt = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NG New HE').getRecordTypeId();

        AMS_OSCAR__c oscar = ANG_EntityCreator.createOscar(oscarNewHeRt, a.Id, fieldsOfObject);
        insert oscar;

        System.debug('Checkpoint 5');
        ANG_EntityCreator.checkSFDCLimits();

        Id caseRT = AMS_Utils.getId('Case', 'OSCAR_Communication');

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

        ID rtNew = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.getRecordTypeInfosByName().get('Travel Agent - Head Entity Standard no Cash').getRecordTypeId();

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
        fieldsOfObject.put('Remittance_frequency__c','Monthly');
        fieldsOfObject.put('Solicitation_Flag__c',false);
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');

        AMS_Pax_Accreditation_Form__c theAccreditation = ANG_EntityCreator.createStagingArea(rtNew, a.Id, c.Id, fieldsOfObject);
        insert theAccreditation;

        System.debug('Checkpoint 8');
        ANG_EntityCreator.checkSFDCLimits();

        ID personRT = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Person').getRecordTypeId();

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

        oscar = ANG_EntityCreator.updateOscar(oscar, fieldsOfObject);
        update oscar;

        System.debug('Checkpoint 11');
        ANG_EntityCreator.checkSFDCLimits();

        Test.stopTest();

	}
	
}