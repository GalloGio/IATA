@isTest
private class ISSP_AMS_MSO_Controller_Test {
	
	@isTest static void test_method() {

        Id conRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Id accRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Id agcRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Account acc = new Account (
	        RecordTypeId = accRtId,
	        Name = 'Airline HQ', 
	        IATACode__c = '012',
            Airline_designator__c = 'HQ',
	        IATA_ISO_Country__c = isoc.Id
	        );  
        insert acc;

        Contact con = new Contact (
	        AccountId = acc.id,
	        RecordTypeId = conRtId, 
	        LastName = 'portalUser',
            FirstName = 'firstname',
            Phone = '123456789',
	        User_Portal_Status__c = 'Approved User'
	        );
        insert con;

        Account agencyM =  new Account (
            RecordTypeId = agcRtId,
            Name = 'Agency', 
            Location_Class__c = 'M',
            IATA_ISO_Country__c = isoc.Id,
            Status__c = 'Approved'
            );  
        insert agencyM;

        AMS_Inspection__c app = new AMS_Inspection__c(Airline__c = acc.Id, Account__c = agencyM.Id);
        insert app;

        Account agencyG =  new Account (
            RecordTypeId = agcRtId,
            Name = 'Agency', 
            Location_Class__c = 'G',
            IATA_ISO_Country__c = isoc.Id,
            Status__c = 'Approved'
            );  
        insert agencyG;

        AMS_Inspection__c appG = new AMS_Inspection__c(Airline__c = acc.Id, Account__c = agencyG.Id);
        insert appG;

        AMS_Territory__c ter = new AMS_Territory__c(Appointment__c = app.Id, ISO_Country__c = isoc.Id);
        insert ter;

        AMS_Accreditation_Organization__c org = new AMS_Accreditation_Organization__c (Name = ISSP_AMS_MSO_Controller.IATAORGNAME);
        insert org;

        Account agency2 =  new Account (
            RecordTypeId = agcRtId,
            Name = 'Agency2', 
            Location_Class__c = 'G',
            IATA_ISO_Country__c = isoc.Id,
            Status__c = 'Approved'
            );  
        insert agency2;

        AMS_Inspection__c app2 = new AMS_Inspection__c(Airline__c = acc.Id, Account__c = agency2.Id, Accreditation_Endorsement_organisation__c = org.Id);
        insert app2;


        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)' LIMIT 1];
         
        User newUser = new User(
	        profileId = p.id,
	        username = 'someuser@iata.org',
	        email = 'someuser@iata.org',
	        emailencodingkey = 'UTF-8',
	        localesidkey = 'en_US',
	        languagelocalekey = 'en_US',
	        timezonesidkey = 'America/Los_Angeles',
	        alias='nuser',
	        lastname='lastname',
	        contactId = con.id
	        );
        insert newUser;

        Test.startTest();
        
        System.runAs(newUser){
        	Test.setCurrentPage(Page.ISSP_AMS_MSO);
            ISSP_AMS_MSO_Controller ctrl = new ISSP_AMS_MSO_Controller();
            
            
            
            ctrl.searchText = 'dsd';
            ctrl.refreshMsoGsaList();

            ctrl.searchText = '';
            ctrl.refreshMsoGsaList();

            system.assertEquals(false, ctrl.hasNext);
            system.assertEquals(false, ctrl.hasPrevious);
            system.assertEquals(1, ctrl.pageNumber);
            //system.assertEquals(1, ctrl.totalPages);

            system.assertEquals(5, ctrl.getselectOptionItems().size());
            //system.assertEquals(1, ctrl.lstDisplayAccounts.size()); // only 1 appointment should be returned, the one for agencyM 

            ctrl.first();
            ctrl.last();
            ctrl.previous();
            ctrl.next();

            system.assertEquals('/ISSP_Homepage', ctrl.checkIfUserHasAccessToService().getUrl());


            Test.setCurrentPage(Page.ISSP_AMS_GSA);
            ctrl = new ISSP_AMS_MSO_Controller();

            ctrl.refreshMsoGsaList();
            //system.assertEquals(1, ctrl.lstDisplayAccounts.size());// only 1 appointment should be returned, the one for agencyG - not endorsed by IATA

            ctrl.getCSVHeader();
            
            ctrl.getData();
            ctrl.ssc =new ApexPages.StandardSetController(new List<AMS_Inspection__c>{app});
            list<ISSP_AMS_MSO_Controller.AppointmentWrapper> a = ctrl.lstDisplayAccounts;
            Integer itotalPages = ctrl.totalPages;

        }

        Test.stopTest();

	}
	
}