@isTest
private class IDCardCheckUserAdminOrAutProcessTest {

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

        //create a contact
        Contact con = new Contact();
        con.LastName = 'IDCard';
        con.FirstName = 'Contact';
        con.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        con.AccountId = acc.Id;
        con.Email = 'idcardcontact@test.idcard';
        con.VER_Number_2__c = '1234';
        insert con;

        //create an idcard
      	ID_Card__c idCard = new ID_Card__c();
        idCard.Related_Contact__c = con.id;
        idCard.Valid_To_Date__c = Date.today().addMonths(5);
        idCard.Name_on_ID_Card__c = 'test';
        idCard.VER_Number__c = '1234';
        idCard.Sent_to_AIMS_on__c = Datetime.now();
        idCard.Received_From_AIMS__c = Datetime.now();
        insert idCard;

        //create the users

        List<User> usersToInsert = new List<User>();

        Profile testProfileidfs = [SELECT Id FROM Profile WHERE Name = 'IDFS Passenger - Distribution Solutions'];
		User testUser1 = New User();
		testUser1.Alias = 'idcard';
		testUser1.Email='idcardIDFS@test.idcard';
		testUser1.EmailEncodingKey='UTF-8';
		testUser1.LastName='Testing';
		testUser1.LanguageLocaleKey='en_US';
		testUser1.LocaleSidKey='en_US';
		testUser1.ProfileId = testProfileidfs.Id;
		testUser1.TimeZoneSidKey='America/Los_Angeles';
		testUser1.UserName='idcardIDFS@test.idcard';
		testUser1.License_Cost_Center__c = 'ISF005CH01';
		usersToInsert.add(testUser1);

		Profile testProfilesysadmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User testUser2 = New User();
		testUser2.Alias = 'idcardS';
		testUser2.Email='idcardSysAdmin@test.idcard';
		testUser2.EmailEncodingKey='UTF-8';
		testUser2.LastName='Testing';
		testUser2.LanguageLocaleKey='en_US';
		testUser2.LocaleSidKey='en_US';
		testUser2.ProfileId = testProfilesysadmin.Id;
		testUser2.TimeZoneSidKey='America/Los_Angeles';
		testUser2.UserName='idcardSysAdmin@test.idcard';
		testUser2.License_Cost_Center__c = 'ISF005CH01';
		usersToInsert.add(testUser2);

		Profile testProfileidfsautoprocess = [SELECT Id FROM Profile WHERE Name = 'Restricted Profile - automated process'];
		User testUser3 = New User();
		testUser3.Alias = 'idcardA';
		testUser3.Email='idcardAutoProcess@test.idcard';
		testUser3.EmailEncodingKey='UTF-8';
		testUser3.LastName='Testing';
		testUser3.LanguageLocaleKey='en_US';
		testUser3.LocaleSidKey='en_US';
		testUser3.ProfileId = testProfileidfsautoprocess.Id;
		testUser3.TimeZoneSidKey='America/Los_Angeles';
		testUser3.UserName='idcardAutoProcess@test.idcard';
		testUser3.License_Cost_Center__c = 'ISF005CH01';
		usersToInsert.add(testUser3);

		insert usersToInsert;
    }
	
	@isTest static void testSentToAIMSNull() {
		// Sent_to_AIMS_on__c = null - nothing to do - no error
		List<ID_Card__c> idcards = [SELECT Id, Sent_to_AIMS_on__c FROM ID_Card__c];

		try
    	{
        	idcards.get(0).Sent_to_AIMS_on__c = null;
        	update idcards;
        	System.assert(true); //no exception - everything went as expected
        } 
        catch (DmlException e) 
        {
        	System.assert(false); //the action should not trow an exception
    	}
	}
	

	@isTest static void testReceivedFromAIMSNotNull() {
		//Sent_to_AIMS_on__c != null
		//&& profileName[0].name.toLowerCase() != 'restricted profile - automated process'
		//&& !profileName[0].name.containsIgnoreCase('system administrator')
		//&& Received_From_AIMS__c != null
		//nothing to do - no error

		List<ID_Card__c> idcards = [SELECT Id, Sent_to_AIMS_on__c FROM ID_Card__c];
		List<User> users = [SELECT Id FROM User WHERE Email='idcardIDFS@test.idcard'];

		System.runAs(users.get(0)){
			try
	    	{
	        	idcards.get(0).Sent_to_AIMS_on__c = Datetime.now().addDays(-1);
	        	update idcards;
	        	System.assert(true); //no exception - everything went as expected
	        } 
	        catch (DmlException e) 
	        {
	        	System.assert(false); //the action should not trow an exception
	    	}
		}
	}


	@isTest static void testAutomatedProcessUser() {
		//Sent_to_AIMS_on__c != null
		//&& profileName[0].name.toLowerCase() == 'restricted profile - automated process'
		//&& !profileName[0].name.containsIgnoreCase('system administrator')
		//&& Received_From_AIMS__c != null
		//nothing to do - no error

		List<ID_Card__c> idcards = [SELECT Id, Sent_to_AIMS_on__c FROM ID_Card__c];
		List<User> users = [SELECT Id FROM User WHERE Email='idcardAutoProcess@test.idcard'];

		System.runAs(users.get(0)){
			try
	    	{
	        	idcards.get(0).Sent_to_AIMS_on__c = Datetime.now().addDays(-1);
	        	update idcards;
	        	System.assert(true); //no exception - everything went as expected
	        } 
	        catch (DmlException e) 
	        {
	        	System.assert(false); //the action should not trow an exception
	    	}
		}
	}


	@isTest static void testSysAdminUser() {
		//Sent_to_AIMS_on__c != null
		//&& profileName[0].name.toLowerCase() != 'restricted profile - automated process'
		//&& profileName[0].name.containsIgnoreCase('system administrator')
		//&& Received_From_AIMS__c != null
		//nothing to do - no error

		List<ID_Card__c> idcards = [SELECT Id, Sent_to_AIMS_on__c FROM ID_Card__c];
		List<User> users = [SELECT Id FROM User WHERE Email='idcardSysAdmin@test.idcard'];

		System.runAs(users.get(0)){
			try
	    	{
	        	idcards.get(0).Sent_to_AIMS_on__c = Datetime.now().addDays(-1);
	        	update idcards;
	        	System.assert(true); //no exception - everything went as expected
	        } 
	        catch (DmlException e) 
	        {
	        	System.assert(false); //the action should not trow an exception
	    	}
		}
	}


	@isTest static void testAddError() {
		//Sent_to_AIMS_on__c != null
		//&& profileName[0].name.toLowerCase() != 'restricted profile - automated process'
		//&& !profileName[0].name.containsIgnoreCase('system administrator')
		//&& Received_From_AIMS__c == null
		//add the error

		List<ID_Card__c> idcards = [SELECT Id, Sent_to_AIMS_on__c FROM ID_Card__c];
		List<User> users = [SELECT Id FROM User WHERE Email='idcardIDFS@test.idcard'];

		System.runAs(users.get(0)){
			try
	    	{
	        	idcards.get(0).Received_From_AIMS__c = null;
	        	update idcards;
	        	System.assert(false); //the action should trow an exception
	        } 
	        catch (DmlException e) 
	        {
	        	System.assert(e.getNumDml() == 1);
	    	}
		}
	}
	
}