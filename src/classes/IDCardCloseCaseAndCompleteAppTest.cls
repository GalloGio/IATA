@isTest
private class IDCardCloseCaseAndCompleteAppTest {
	
	@testSetup 
    static void testSetup(){

    	//create a country
		IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
        country.Name = 'Portugal';
        country.ISO_Code_Numeric__c = 620;
        country.AIMS_Area_ID__c = '2';
        country.ISO_Code__c = 'PT';
        insert country;

		//create an account
		Account acc = new Account();
		acc.Name = 'Account Test';
		acc.IATACode__c = '1234567';
        acc.Type = 'IATA Passenger Sales Agent';
		acc.IATA_ISO_Country__c = country.Id;
        acc.Location_Type__c = 'HO';
        acc.Location_Class__c = 'P';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        insert acc;

        //create the contacts
        List<Contact> cons = new List<Contact>();
        Contact con = new Contact();
        con.LastName = 'IDCard';
        con.FirstName = 'Contact';
        con.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        con.AccountId = acc.Id;
        con.Email = 'idcardcontact@test.idcard';
        con.VER_Number_2__c = '1234';
        cons.add(con);

        Contact con2 = new Contact();
        con2.LastName = 'IDCard2';
        con2.FirstName = 'Contact';
        con2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        con2.AccountId = acc.Id;
        con2.Email = 'idcardcontact2@test.idcard';
        con2.VER_Number_2__c = '1235';
        cons.add(con2);

        //create a contact
        Contact con3 = new Contact();
        con3.LastName = 'IDCard3';
        con3.FirstName = 'Contact3';
        con3.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        con3.AccountId = acc.Id;
        con3.Email = 'idcardcontact3@test.idcard';
        con3.VER_Number_2__c = '1236';
        cons.add(con3);

        insert cons;

        //create a mass application
		ID_Card_Application__c idCardMassApp = new ID_Card_Application__c();
		idCardMassApp.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
        idCardMassApp.First_Name__c = 'FIRSTNAME';
        idCardMassApp.Last_Name__c = 'LASTNAME';
        idCardMassApp.Displayed_Name__c = 'FIRSTNAME LASTNAME';
        idCardMassApp.IATA_Code__c = '1234567';
        insert idCardMassApp;

        //create a case
		Case cs = new Case();
		cs.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');
		cs.Related_ID_Card_Application__c = idCardMassApp.Id;
		cs.Subject = 'Case ID Card Test';
		cs.AccountId = acc.Id;
		insert cs;

        //create the idcard single applications
        List<ID_Card_Application__c> idCardApps = new List<ID_Card_Application__c>();
		ID_Card_Application__c idCardApp = new ID_Card_Application__c();
		idCardApp.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
		idCardApp.Title__c = 'Mr';
        idCardApp.First_Name__c = 'FIRSTNAME1';
        idCardApp.Last_Name__c = 'LASTNAME1';
        idCardApp.Date_of_Birth__c = Date.newInstance(1980,12,12);
        idCardApp.Displayed_Name__c = 'FIRSTNAME LASTNAME 1';
        idCardApp.Type_of_application__c = 'New';
        idCardApp.IATA_Code__c = '1234567';
        idCardApp.Email_admin__c = 'testidcard1@testmassapp.test';
        idCardApp.Mass_order_Application__c = idCardMassApp.Id;
        idCardApps.add(idCardApp);

        //create the idcard single applications
		ID_Card_Application__c idCardApp2 = new ID_Card_Application__c();
		idCardApp2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
		idCardApp2.Title__c = 'Mr';
        idCardApp2.First_Name__c = 'FIRSTNAME2';
        idCardApp2.Last_Name__c = 'LASTNAME2';
        idCardApp2.Date_of_Birth__c = Date.newInstance(1980,12,12);
        idCardApp2.Displayed_Name__c = 'FIRSTNAME LASTNAME 2';
        idCardApp2.Type_of_application__c = 'New';
        idCardApp2.IATA_Code__c = '1234567';
        idCardApp2.Email_admin__c = 'testidcard2@testmassapp.test';
        idCardApp2.Mass_order_Application__c = idCardMassApp.Id;
        idCardApps.add(idCardApp2);

        //create the idcard single applications
		ID_Card_Application__c idCardApp3 = new ID_Card_Application__c();
		idCardApp3.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
		idCardApp3.Title__c = 'Mr';
        idCardApp3.First_Name__c = 'FIRSTNAME3';
        idCardApp3.Last_Name__c = 'LASTNAME3';
        idCardApp3.Date_of_Birth__c = Date.newInstance(1980,12,12);
        idCardApp3.Displayed_Name__c = 'FIRSTNAME LASTNAME 3';
        idCardApp3.Type_of_application__c = 'New';
        idCardApp3.IATA_Code__c = '1234567';
        idCardApp3.Email_admin__c = 'testidcard3@testmassapp.test';
        idCardApp3.Mass_order_Application__c = idCardMassApp.Id;
        idCardApps.add(idCardApp3);

        insert idCardApps;    

        //create the idcards
        List<ID_Card__c> idcards = new List<ID_Card__c>();
      	ID_Card__c idCard = new ID_Card__c();
        idCard.Related_Contact__c = cons.get(0).id;
        idCard.Valid_To_Date__c = Date.today().addMonths(5);
        idCard.Name_on_ID_Card__c = 'test';
        idCard.VER_Number__c = '1234';
        idCard.ID_Card_Application__c = idCardApps.get(0).Id;
        idcards.add(idCard);       

        //create an idcard
      	ID_Card__c idCard2 = new ID_Card__c();
        idCard2.Related_Contact__c = cons.get(1).id;
        idCard2.Valid_To_Date__c = Date.today().addMonths(5);
        idCard2.Name_on_ID_Card__c = 'test2';
        idCard2.VER_Number__c = '1235';
        idCard2.ID_Card_Application__c = idCardApps.get(1).Id;
        idcards.add(idCard2);

        //create an idcard
      	ID_Card__c idCard3 = new ID_Card__c();
        idCard3.Related_Contact__c = cons.get(2).id;
        idCard3.Valid_To_Date__c = Date.today().addMonths(5);
        idCard3.Name_on_ID_Card__c = 'test3';
        idCard3.VER_Number__c = '1236';
        idCard3.ID_Card_Application__c = idCardApps.get(2).Id;
        idcards.add(idCard3);

        insert idcards;
    }

    @isTest
    static void testCompleteAppNotClosedCase() {
    	//Card_Status__c == 'Valid ID Card'

    	ID_Card__c idCard = [SELECT Id, Card_Status__c FROM ID_Card__c LIMIT 1];

    	idCard.Card_Status__c = 'Valid ID Card';

    	Test.startTest();
    	update idCard;
    	Test.stopTest();

    	List<ID_Card_Application__c> idCardApps = [SELECT Id, Application_Status__c FROM ID_Card_Application__c WHERE RecordTypeId =: RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation')];

    	Map<String,Integer> mapResultApps = new Map<String,Integer>();
    	mapResultApps.put('Completed', 0);
    	mapResultApps.put('Not Completed', 0);

    	for(ID_Card_Application__c app : idCardApps){
    		if(app.Application_Status__c == 'Completed') {
    			mapResultApps.put('Completed', mapResultApps.get('Completed') + 1);
			} else {
				mapResultApps.put('Not Completed', mapResultApps.get('Not Completed') + 1);
			}
    	}

    	System.assertEquals(2, mapResultApps.get('Not Completed'));
    	System.assertEquals(1, mapResultApps.get('Completed'));

    	List<Case> caseList = [SELECT Id, Status FROM Case];

    	System.assertNotEquals('Closed', caseList.get(0).Status);
    }

    @isTest
    static void testCompleteAppClosedCase() {
    	//Card_Status__c == 'Valid ID Card'

    	List<ID_Card__c> idCards = [SELECT Id, Card_Status__c FROM ID_Card__c];

    	for(ID_Card__c idCard : idCards)
    		idCard.Card_Status__c = 'Valid ID Card';

    	Test.startTest();
    	update idCards;
    	Test.stopTest();

    	List<ID_Card_Application__c> idCardApps = [SELECT Id, Application_Status__c FROM ID_Card_Application__c WHERE RecordTypeId =: RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation')];

    	Map<String,Integer> mapResultApps = new Map<String,Integer>();
    	mapResultApps.put('Completed', 0);
    	mapResultApps.put('Not Completed', 0);

    	for(ID_Card_Application__c app : idCardApps){
    		if(app.Application_Status__c == 'Completed') {
    			mapResultApps.put('Completed', mapResultApps.get('Completed') + 1);
			} else {
				mapResultApps.put('Not Completed', mapResultApps.get('Not Completed') + 1);
			}
    	}

    	System.assertEquals(0, mapResultApps.get('Not Completed'));
    	System.assertEquals(3, mapResultApps.get('Completed'));

    	List<Case> caseList = [SELECT Id, Status FROM Case];

    	System.assertEquals('Closed', caseList.get(0).Status);
    }

    @isTest
    static void testNotCompleteAppNotClosedCase() {
    	//Card_Status__c == 'Valid ID Card'

    	ID_Card__c idCard = [SELECT Id, Card_Status__c FROM ID_Card__c LIMIT 1];

    	idCard.Card_Status__c = 'ID Card Pending/In Progress';

    	Test.startTest();
    	update idCard;
    	Test.stopTest();

    	List<ID_Card_Application__c> idCardApps = [SELECT Id, Application_Status__c FROM ID_Card_Application__c WHERE RecordTypeId =: RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation')];

    	Map<String,Integer> mapResultApps = new Map<String,Integer>();
    	mapResultApps.put('Completed', 0);
    	mapResultApps.put('Not Completed', 0);

    	for(ID_Card_Application__c app : idCardApps){
    		if(app.Application_Status__c == 'Completed') {
    			mapResultApps.put('Completed', mapResultApps.get('Completed') + 1);
			} else {
				mapResultApps.put('Not Completed', mapResultApps.get('Not Completed') + 1);
			}
    	}

    	System.assertEquals(3, mapResultApps.get('Not Completed'));
    	System.assertEquals(0, mapResultApps.get('Completed'));

    	List<Case> caseList = [SELECT Id, Status FROM Case];

    	System.assertNotEquals('Closed', caseList.get(0).Status);
    }
	
}