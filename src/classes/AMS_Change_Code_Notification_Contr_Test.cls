@isTest
private class AMS_Change_Code_Notification_Contr_Test {
	
	@isTest static void test_Oscar_notification() {

		Id conRtId = [SELECT Id FROM RecordType WHERE DeveloperName ='Standard_Contact' AND SobjectType = 'Contact'].Id;
        //Id accRtId = [SELECT Id FROM RecordType WHERE DeveloperName ='IATA_Airline' AND SobjectType = 'Account'].Id;
        Id agcRtId = [SELECT Id FROM RecordType WHERE DeveloperName ='IATA_Agency' AND SobjectType = 'Account'].Id;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Account msoAccount =  new Account (
            RecordTypeId = agcRtId,
            Name = 'Agency', 
            Location_Class__c = 'M',
            IATA_ISO_Country__c = isoc.Id,
            Status__c = 'Approved'
            );  
        insert msoAccount;

        Contact con = new Contact (
          AccountId = msoAccount.id,
          RecordTypeId = conRtId, 
          LastName = 'portalUser',
            FirstName = 'firstname',
            Phone = '123456789',
          User_Portal_Status__c = 'Approved User'
          );
        insert con;

        AMS_OSCAR__c oscar = new AMS_OSCAR__c();
        oscar.RecordTypeId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_OSCAR__c'}).get('AMS_OSCAR__c').get('VOLUNTARY_RELINQUISHMENT');
        oscar.Name = 'tempName'; 
        oscar.Process__c = AMS_Utils.VOLRELINQUISH_CA;
        oscar.Account__c = msoAccount.Id;
        insert oscar;

        Case oscarCase = new Case();
        oscarCase.AccountId = msoAccount.Id;
        oscarCase.ContactId = con.Id; 
        oscarCase.RecordTypeId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case').get('OSCAR_Communication');//caseRT.Id;
        oscarCase.OSCAR__c = oscar.Id;
        oscarCase.Status = 'Open';
        insert oscarCase;


        Agency_Applied_Change_code__c ccode= new Agency_Applied_Change_code__c();
        ccode.Change_Code__c = 'TER';
        ccode.OSCAR__c = oscar.Id;
        ccode.Account__c = msoAccount.Id;
		insert ccode;

        Test.startTest();

	        ApexPages.StandardController stdController = new ApexPages.StandardController(oscarCase);

	        AMS_Change_Code_Notification_Controller ctrl = new AMS_Change_Code_Notification_Controller(stdController);

	        ctrl.setNotificationMessage();

        Test.stopTest();

	}



	@isTest static void test_Case_notification() {

		Id conRtId = [SELECT Id FROM RecordType WHERE DeveloperName ='Standard_Contact' AND SobjectType = 'Contact'].Id;
        //Id accRtId = [SELECT Id FROM RecordType WHERE DeveloperName ='IATA_Airline' AND SobjectType = 'Account'].Id;
        Id agcRtId = [SELECT Id FROM RecordType WHERE DeveloperName ='IATA_Agency' AND SobjectType = 'Account'].Id;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Account msoAccount =  new Account (
            RecordTypeId = agcRtId,
            Name = 'Agency', 
            Location_Class__c = 'M',
            IATA_ISO_Country__c = isoc.Id,
            Status__c = 'Approved'
            );  
        insert msoAccount;

        Contact con = new Contact (
          AccountId = msoAccount.id,
          RecordTypeId = conRtId, 
          LastName = 'portalUser',
            FirstName = 'firstname',
            Phone = '123456789',
          User_Portal_Status__c = 'Approved User'
          );
        insert con;

        Case ccase = new Case();
        ccase.AccountId = msoAccount.Id;
        ccase.ContactId = con.Id; 
        ccase.RecordTypeId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case').get('SIDRA');
        ccase.Status = 'Open';
        ccase.Late_Payment_Date__c = Date.today();
        insert ccase;


        Agency_Applied_Change_code__c ccode= new Agency_Applied_Change_code__c();
        ccode.Change_Code__c = 'TER';
        ccode.SIDRA_Case__c = ccase.Id;
        ccode.Account__c = msoAccount.Id;
        insert ccode;


        Test.startTest();

	        ApexPages.StandardController stdController = new ApexPages.StandardController(ccase);

	        AMS_Change_Code_Notification_Controller ctrl = new AMS_Change_Code_Notification_Controller(stdController);

	        ctrl.setNotificationMessage();

        Test.stopTest();

	}
	
}