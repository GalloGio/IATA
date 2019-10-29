@isTest
private class IDCardGenerateAndAssignCINTest {
	
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
        con2.Email = 'idcard2contact@test.idcard';
        con2.VER_Number_2__c = '1232';
        cons.add(con2);

        insert cons;

        //create the idcard single application
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
        idCardApp.UIR__c = 'PT000001';
        idCardApps.add(idCardApp);

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
        idCardApp2.UIR__c = 'PT000002';
        idCardApps.add(idCardApp2);

        insert idCardApps;

        //create a case
        List<Case> caseList = new List<Case>();
		Case cs = new Case();
		cs.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');
		cs.Related_ID_Card_Application__c = idCardApps.get(0).Id;
		cs.Subject = 'Case ID Card Test';
		cs.AccountId = acc.Id;
		caseList.add(cs); 

        //create a case
		Case cs2 = new Case();
		cs2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');
		cs2.Related_ID_Card_Application__c = idCardApps.get(1).Id;
		cs2.Subject = 'Case ID Card Test 2';
		cs2.AccountId = acc.Id;
		caseList.add(cs2);

		insert caseList;

		ID_Card__c idCard = new ID_Card__c();
        idCard.Related_Contact__c = cons.get(1).Id;
        idCard.Valid_To_Date__c = Date.today().addMonths(5);
        idCard.Name_on_ID_Card__c = 'test2';
        idCard.VER_Number__c = '1232';
        idCard.ID_Card_Application__c = idCardApps.get(1).Id;
        idCard.LastName__c = 'LASTNAME2';
        idCard.FirstName__c = 'FIRSTNAME2';
        idCard.Date_of_Birth__c = Date.newInstance(1989,11,25);
        idCard.Gender__c = 'FEMALE';
        idCard.Position__c = 'Employee';
        idCard.Duties__c = 'Sales';
        idCard.Hours_per_week__c  = '35 h or more';
        idCard.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS'); 
        insert idCard;
    }

    @isTest
    static void testCINCreationSuccess() {
    	//CIN creation LAS89F112551EI1PT
    	//3 first characters of lastname - LAS
    	//2 last digits of birth year - 89
    	//first character of firstname - F
    	//birth month (number) - 11
    	//birth day (number) - 25
    	//increment digits according gender (M-00; F-50) - 51
    	//position code (Employee) - E
    	//duty code (Sales) - I
    	//hour worked code (35 h or more) - 1
    	//2 first digit of application's UIR - country ISO Code - PT

    	delete [SELECT Id FROM ID_Card__c];

    	ID_Card_Application__c idCardApp = [SELECT Id FROM ID_Card_Application__c WHERE Last_Name__c = 'LASTNAME1' LIMIT 1];
    	Contact con = [SELECT Id FROM Contact WHERE LastName = 'IDCard' LIMIT 1];

    	ID_Card__c idCard = new ID_Card__c();
        idCard.Related_Contact__c = con.Id;
        idCard.Valid_To_Date__c = Date.today().addMonths(5);
        idCard.Name_on_ID_Card__c = 'test';
        idCard.VER_Number__c = '1234';
        idCard.ID_Card_Application__c = idCardApp.Id;
        idCard.LastName__c = 'LASTNAME';
        idCard.FirstName__c = 'FIRSTNAME';
        idCard.Date_of_Birth__c = Date.newInstance(1989,11,25);
        idCard.Gender__c = 'FEMALE';
        idCard.Position__c = 'Employee';
        idCard.Duties__c = 'Sales';
        idCard.Hours_per_week__c  = '35 h or more';
        idCard.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');

        Test.startTest();
        insert idCard;
        Test.stopTest();

        ID_Card__c idCardToCheck = [SELECT Id, CIN__c FROM ID_Card__c LIMIT 1];

        System.assertEquals('LAS89F112551EI1PT', idCardToCheck.CIN__c);
    }

    @isTest
    static void testCINNotNeeded() {
    	//shouln't generate CIN__c because the RecordType is not AIMS

    	delete [SELECT Id FROM ID_Card__c];

    	ID_Card_Application__c idCardApp = [SELECT Id FROM ID_Card_Application__c LIMIT 1];
    	Contact con = [SELECT Id FROM Contact LIMIT 1];

    	ID_Card__c idCard = new ID_Card__c();
        idCard.Related_Contact__c = con.Id;
        idCard.Valid_To_Date__c = Date.today().addMonths(5);
        idCard.Name_on_ID_Card__c = 'test';
        idCard.VER_Number__c = '1234';
        idCard.ID_Card_Application__c = idCardApp.Id;
        idCard.LastName__c = 'LASTNAME';
        idCard.FirstName__c = 'FIRSTNAME';
        idCard.Date_of_Birth__c = Date.newInstance(1989,11,25);
        idCard.Gender__c = 'FEMALE';
        idCard.Position__c = 'Employee';
        idCard.Duties__c = 'Sales';
        idCard.Hours_per_week__c  = '35 h or more';
        idCard.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'WebStar');

        Test.startTest();
        insert idCard;
        Test.stopTest();

        ID_Card__c idCardToCheck = [SELECT Id, CIN__c FROM ID_Card__c LIMIT 1];

        System.assertEquals(null, idCardToCheck.CIN__c);
    }

    @isTest
    static void testCINCreationFailed() {
    	//shouln't generate CIN__c because the idcard doesn't have fristname and lastname

    	delete [SELECT Id FROM ID_Card__c];

    	ID_Card_Application__c idCardApp = [SELECT Id FROM ID_Card_Application__c LIMIT 1];
    	Contact con = [SELECT Id FROM Contact LIMIT 1];

    	ID_Card__c idCard = new ID_Card__c();
        idCard.Related_Contact__c = con.Id;
        idCard.Valid_To_Date__c = Date.today().addMonths(5);
        idCard.Name_on_ID_Card__c = 'test';
        idCard.VER_Number__c = '1234';
        idCard.ID_Card_Application__c = idCardApp.Id;
        idCard.Date_of_Birth__c = Date.newInstance(1989,11,25);
        idCard.Gender__c = 'FEMALE';
        idCard.Position__c = 'Employee';
        idCard.Duties__c = 'Sales';
        idCard.Hours_per_week__c  = '35 h or more';
        idCard.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');

        Test.startTest();
        insert idCard;
        Test.stopTest();

        ID_Card__c idCardToCheck = [SELECT Id, CIN__c FROM ID_Card__c LIMIT 1];

        System.assertEquals(null, idCardToCheck.CIN__c);
    }

    @isTest
    static void testCINCreationIncremented() {
    	//CIN should be the similar to the one generated in testCINCreationSuccess but with incrementation

    	ID_Card_Application__c idCardApp = [SELECT Id FROM ID_Card_Application__c WHERE Last_Name__c = 'LASTNAME1' LIMIT 1];
    	Contact con = [SELECT Id FROM Contact WHERE LastName = 'IDCard' LIMIT 1];

    	ID_Card__c idCard = new ID_Card__c();
        idCard.Related_Contact__c = con.Id;
        idCard.Valid_To_Date__c = Date.today().addMonths(5);
        idCard.Name_on_ID_Card__c = 'test';
        idCard.VER_Number__c = '1234';
        idCard.ID_Card_Application__c = idCardApp.Id;
        idCard.LastName__c = 'LASTNAME';
        idCard.FirstName__c = 'FIRSTNAME';
        idCard.Date_of_Birth__c = Date.newInstance(1989,11,25);
        idCard.Gender__c = 'FEMALE';
        idCard.Position__c = 'Employee';
        idCard.Duties__c = 'Sales';
        idCard.Hours_per_week__c  = '35 h or more';
        idCard.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');

        Test.startTest();
        insert idCard;
        Test.stopTest();

        ID_Card__c idCardToCheck = [SELECT Id, CIN__c FROM ID_Card__c WHERE Id =: idCard.Id LIMIT 1];

        System.assertEquals('LAS89F112552EI1PT', idCardToCheck.CIN__c);
    }
	
}