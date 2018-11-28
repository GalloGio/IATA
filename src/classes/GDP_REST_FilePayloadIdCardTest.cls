/**
 * This a basic test class for GDP_REST_FilePayloadIdCard.cls
 * 
 */
@isTest
private class GDP_REST_FilePayloadIdCardTest {
	
	// =======================================================================
	// test data definition
	private static final Integer NUMBER_OF_ACCOUNTS = 9;
	
	private static List<Contact> contactList;
	private static List<Account> accountList;
	private static List<ID_Card_Application__c> idCardApplicationList;
	private static List<ID_Card__c> idCardList;
	private static GDP_File_Description__c fileDescriptionTest01;
	
	// supporting variables
	private static Boolean testDataCreated = false; // this is to allow parallel test run
	
	private static Set<String> sObjectTypeSet = new set<String> { 'Account', 'Contact' };
	
	// -----------------------------------------------------------------------
	private static final String accountRecTypeDevName = 'Standard_Account'; // 
	private static final String contactRecTypeDevName = 'Standard_Contact'; // 
	
	private static final integer HTTP_STATUS_OK = 200;
	private static final integer HTTP_STATUS_BAD_REQUEST = 400;
	
	// =======================================================================
	// Basic Test Scenario: good case
	static testMethod void testIdCard_01GoodCase() {
		if (!testDataCreated)
		{
			insertTestData(); // prepare account, contact, idCard data
		}
		
		// RestRequest preparation
		RestRequest request = new RestRequest(); 
		RestResponse response = new RestResponse();
		
		request.requestURI = '/GSS/v0/FileDataIDCard';  
		request.httpMethod = 'GET';
		request.addParameter('FileSpecificationId', fileDescriptionTest01.Id);
		
		RestContext.request = request;
		RestContext.response = response;
		
		Test.startTest();
		
		//Tests positive scenario with code 200 / HTTP_STATUS_OK
		//GDP_REST_FilePayloadIdCard.Record result = 
		GDP_REST_FilePayloadIdCard.getFilePayload(); 
		
		//System.debug( 'testIdCard_01GoodCase: result:' + result);
		System.debug( 'testIdCard_01GoodCase: responseBody:' + response.responseBody.toString());
		System.debug( 'testIdCard_01GoodCase: response:' + response.responseBody);
		
		//Assert
		system.debug('testIdCard_01GoodCase getFilePayload responseBody : ' + response.responseBody.toString());
		system.debug('testIdCard_01GoodCase getFilePayload Status Code : ' +  response.statusCode);
		System.assertEquals(HTTP_STATUS_OK, response.statusCode);
		
		Test.stopTest(); 
		
	} // end of testIdCard_01GoodCase
	
	
	// =======================================================================
	// Basic Test Scenario: bad case
	// case 1: use fileSpecificationId that will not return existing one
	static testMethod void testIdCard_02BadCase() {
		if (!testDataCreated)
		{
			insertTestData(); // prepare account, contact, idCard data
		}
		
		String fileSpecificationId; 
		
		RestRequest request;  
		RestResponse response;
		
		Test.startTest();
		
		// bad case 1: no fileSpecificationId mentioned in the REST API Header
		// RestContext / RestRequest preparation
		request = new RestRequest(); 
		response = new RestResponse();
		
		request.requestURI = '/GDP/v01/IdCard';  
		request.httpMethod = 'GET';
		
		RestContext.request = request;
		RestContext.response = response;
		
		try{
			//Test negative scenario with code not 200 / HTTP_STATUS_OK
			system.debug('testIdCard_02BadCase getFilePayload with no fileSpecificationId parameter. ');
			GDP_REST_FilePayloadIdCard.getFilePayload(); 
			system.debug('testIdCard_02BadCase getFilePayload should fail. ' + response);
			system.debug('testIdCard_02BadCase getFilePayload responseBody : ' + response.responseBody.toString());
			system.debug('testIdCard_02BadCase getFilePayload Status Code : ' +  response.statusCode);
			System.assertNotEquals(HTTP_STATUS_OK, response.statusCode); // in case the getFilePayload error handling return gracefully
		} catch (Exception ex) {
			//Assert
			system.debug('testIdCard_02BadCase getFilePayload expected exception was generated : ' + ex);
			system.debug('testIdCard_02BadCase getFilePayload responseBody : ' + response.responseBody);
			system.debug('testIdCard_02BadCase getFilePayload Status Code : ' +  response.statusCode);
			System.assertNotEquals(HTTP_STATUS_OK, response.statusCode);
		}
		
		// --------------------------------------------------------------------
		// bad case 2: bad fileSpecificationId
		// RestContext / RestRequest preparation
		fileSpecificationId = contactList[0].Id; // bad record Id, will found nothing, this ensure incorrect return 
		
		request = new RestRequest(); 
		response = new RestResponse();
		
		request.requestURI = '/GDP/v01/IdCard';  
		request.httpMethod = 'GET';
		request.addParameter('FileSpecificationId', fileSpecificationId );
		
		RestContext.request = request;
		RestContext.response = response;
		
		try{
			//Test negative scenario with code not 200 / HTTP_STATUS_OK
			system.debug('testIdCard_02BadCase getFilePayload with bad fileSpecificationId. ');
			GDP_REST_FilePayloadIdCard.getFilePayload(); 
			system.debug('testIdCard_02BadCase getFilePayload should fail. ' + response);
			system.debug('testIdCard_02BadCase getFilePayload responseBody : ' + response.responseBody.toString());
			system.debug('testIdCard_02BadCase getFilePayload Status Code : ' +  response.statusCode);
			System.assertNotEquals(HTTP_STATUS_OK, response.statusCode); // in case the getFilePayload error handling return gracefully
		} catch (Exception ex) {
			//Assert
			system.debug('testIdCard_02BadCase getFilePayload expected exception was generated : ' + ex);
			system.debug('testIdCard_02BadCase getFilePayload responseBody : ' + response.responseBody);
			system.debug('testIdCard_02BadCase getFilePayload Status Code : ' +  response.statusCode);
			System.assertNotEquals(HTTP_STATUS_OK, response.statusCode);
		}
		
		
		// --------------------------------------------------------------------
		// bad case 3: bad GDP_File_Description
		// modify sample fileSpecificationId
		 
		// make the GDP_File_Description not suitable for this.
		GDP_File_Description__c modifiedFileSpecRef = new GDP_File_Description__c( Id = fileDescriptionTest01.Reference__c
				, Payload_Procedure__c = 'Agency'
				, Product_Type__c = 'MDP' );
		update modifiedFileSpecRef;
		
		GDP_File_Description__c modifiedFileSpec = new GDP_File_Description__c( Id = fileDescriptionTest01.Id
				, Payload_Procedure__c = 'Agency'
				, Product_Type__c = 'MDP' );
		update modifiedFileSpec;
		
		fileSpecificationId = fileDescriptionTest01.Id; // this is a good one, but not for CAC Id_Card
		 
		// RestContext / RestRequest preparation
		request = new RestRequest(); 
		response = new RestResponse();
		
		request.requestURI = '/GDP/v01/IdCard';  
		request.httpMethod = 'GET';
		request.addParameter('FileSpecificationId', fileSpecificationId );
		
		RestContext.request = request;
		RestContext.response = response;
		
		try{
			//Test negative scenario with code not 200 / HTTP_STATUS_OK
			system.debug('testIdCard_02BadCase getFilePayload with bad GDP_File_Description records ');
			GDP_REST_FilePayloadIdCard.getFilePayload(); 
			system.debug('testIdCard_02BadCase getFilePayload should fail. ' + response);
			system.debug('testIdCard_02BadCase getFilePayload responseBody : ' + response.responseBody.toString());
			system.debug('testIdCard_02BadCase getFilePayload Status Code : ' +  response.statusCode);
			System.assertNotEquals(HTTP_STATUS_OK, response.statusCode); // in case the getFilePayload error handling return gracefully
		} catch (Exception ex) {
			//Assert
			system.debug('testIdCard_02BadCase getFilePayload expected exception was generated : ' + ex);
			system.debug('testIdCard_02BadCase getFilePayload responseBody : ' + response.responseBody);
			system.debug('testIdCard_02BadCase getFilePayload Status Code : ' +  response.statusCode);
			System.assertNotEquals(HTTP_STATUS_OK, response.statusCode);
		}
		
		
		Test.stopTest(); 
		
	} // end of testIdCard_02BadCase
	
	
	
	// ==============================================================
	// prepare test data: Account, Contact, ID_Card_Application, ID_Card
	// also initiate and insert GDP_File_Description along with the its reference and related fields
	private static void insertTestData()
	{
		testDataCreated = true; 
		
		// insert accounts and contacts
		accountList = new List<Account>();
		for (Integer i=0;i<NUMBER_OF_ACCOUNTS;i++)
		{
			accountList.add(createAccount (0, accountRecTypeDevName));
		} 
		insert accountList;
		
		Integer ctcIdx=0;
		contactList = new List<Contact>();
		for (Account acct : accountList)
		{
			contactList.add(createContact(ctcIdx, acct.Id, contactRecTypeDevName ) );
			ctcIdx++;
		}
		insert contactList;
		
		// --------------------------------------------------------------------
		// create ID_Card Application and ID_Card
		idCardApplicationList = new List<ID_Card_Application__c>();
		idCardList = new List<ID_Card__c>();
		
		Integer idCardIdx = 0;
		for (Contact ctc : contactList)
		{
			idCardApplicationList.add(createIdCardApplication(idCardIdx, ctc) );
			idCardList.add( createIdCard(idCardIdx,ctc));
			idCardIdx++;
		}
		insert idCardApplicationList;
		
		// include link to ID_Card_Application
		for ( idCardIdx=0;idCardIdx<idCardList.size();idCardIdx++)
		{
			idCardList[idCardIdx].ID_Card_Application__c = idCardApplicationList[idCardIdx].Id;
		}
		insert idCardList;
		
		
		// --------------------------------------------------------------------
		// create and insert GDP_File_Description
		fileDescriptionTest01 = getTestFileDescription();
		
		
	} // insertTestData
	
	// ========================================================================
	// create account (not inserting)
	// the goal of this method is to populate most (required) fields
	private static Account createAccount( Integer acctNumber
										, String recTypeDevName) 
	{ 
		Id accountRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', recTypeDevName);
		
		Account newAccount = new Account ( 
					Name = 'testAccount-' + String.valueOf( acctNumber).trim() 
					, Type='IATA Passenger Sales Agent'
					, Site='test' 
					, Phone = '514-555-' + String.valueOf(1000 + acctNumber) 
					, BillingStreet = String.valueOf(99+acctNumber).trim() + 'Unknown Street' 
					, BillingCity = 'Montreal'
					, BillingState = 'Quebec'
					, BillingCountry = 'Canada'
					, BillingPostalCode = 'H3G 1T4'
					);
		if (accountRecTypeId!=null) {
			newAccount.RecordTypeId = accountRecTypeId;
		}
		return newAccount;
	} // createAccount
	
	// =======================================================================
	// create contact record, populate the required field here.
	private static Contact createContact( Integer ctcNumber
				, Id accountId
				, String recTypeDevName
				) 
	{ 
		Id contactRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', recTypeDevName);
		
		Contact newContact = new Contact ( 
					FirstName = 'testContact' + String.valueOf( ctcNumber)
					, LastName = 'Test'
					, Email = 'ctc'+ String.valueOf(ctcNumber) + '@test.iata.org'
					, Phone = '514-123-' + String.valueOf(1000 + ctcNumber)
					, MailingStreet = String.valueOf(ctcNumber).trim() + 'Unknown Street' 
					, MailingCity = 'Montreal'
					, MailingState = 'Quebec'
					, MailingCountry = 'Canada'
					, MailingPostalCode = 'H3G 1T4' );
		if ( accountId != null) 
		{ // only set AccountId if it exists
			newContact.AccountId = accountId; 
		}
		if (contactRecTypeId!=null) {
			newContact.RecordTypeId = contactRecTypeId;
		}
		return newContact;
	}
	
	
	// ==============================================================
	// create ID_Card (not inserting)
	// the goal of this method is to populate most (required) fields
	private static ID_Card_Application__c createIdCardApplication( Integer idx
											, Contact relatedContact
											) 
	{ 
		ID_Card_Application__c newIdApplicationCard = new ID_Card_Application__c ( 
					First_Name__c = relatedContact.FirstName
					, Last_Name__c = relatedContact.LastName
					, AgencyShare_Confirmation__c = true
					, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application')
					//, Agency_IATA_Code__c = '00000001' 
					);
		return newIdApplicationCard;
	} // createIdCard
	
	// ==============================================================
	// create ID_Card (not inserting)
	// the goal of this method is to populate most (required) fields
	private static ID_Card__c createIdCard( Integer idx
											, Contact relatedContact
											) 
	{ 
		System.assertNotEquals( null, relatedContact.Id, 'contact id should not be null.' );
		ID_Card__c newIdCard = new ID_Card__c ( 
					FirstName__c = relatedContact.FirstName
					, LastName__c = relatedContact.LastName
					, Name_on_ID_Card__c = 'Test ' + String.valueOf(idx).trim()
					//, Agency_IATA_Code__c = '00000001' 
					, Related_Contact__c = relatedContact.Id
					, Card_Status__c = 'Sent ID Card'
					, Blacklisted__c = false
					, Valid_To_Date__c = Date.today().addMonths(5).addDays(idx)
					);
		return newIdCard;
	} // createIdCard
	
	// =======================================================================
	// initiate and insert file description along with the its related fields 
	private static GDP_File_Description__c getTestFileDescription()
	{
		//Create the reference File Description
		GDP_File_Description__c fileDescriptionReference = new GDP_File_Description__c(
				File_Format__c='TXT'
				, Frequency__c='Daily'
				, Reference__c=null
				, Class__c=''
				, Magnitude__c='Master'
				, Field_Label__c=''
				, Description__c='Test Reference File Description for ID_Card'
				, File_Naming_Convention__c='Name'
				, Product_Type__c = 'CAC'
				, Payload_Procedure__c = 'IDCard'
			);
		insert fileDescriptionReference;
		
		//Create a non reference File Description
		GDP_File_Description__c fileDescriptionTest = new GDP_File_Description__c(
				File_Format__c='TXT'
				, Frequency__c='Daily'
				, Reference__c = fileDescriptionReference.id
				, Class__c=''
				, Magnitude__c='Master'
				, Field_Label__c=''
				, Description__c='Test Non-Reference File Description for ID_Card'
				, File_Naming_Convention__c='Name'
				
				, Product_Type__c = 'CAC'
				, Payload_Procedure__c = 'IDCard'
			);
		insert fileDescriptionTest;
		
		// --------------------------------------------------------------------
		// create related fields of the reference file description
		
		//Create Field to have the setup for id and name
		List<GDP_File_Fields_Description__c> fileFieldDescriptionList = new List<GDP_File_Fields_Description__c>();
		fileFieldDescriptionList.add(new GDP_File_Fields_Description__c(API_Name__c='Name', API_Object_Name__c='ID_Card__c'
			, Name__c='Name'
			, Position__c=1
			, Size__c=80
			, Target__c='Agency'
			, Type__c='String'
			, GDP_File_Description__c=fileDescriptionReference.Id
			, Filter_Field_API_Name__c='', Filter_Field_Value__c=''
			, Hidden_Column__c=false, TXT_Hidden_Column__c=false, XML_Hidden_Column__c=false
			, Visible__c=true
			));
		
		fileFieldDescriptionList.add(new GDP_File_Fields_Description__c(API_Name__c='Agency_Name__c', API_Object_Name__c='ID_Card__c'
			, Name__c='Agency Name'
			, Position__c=3
			, Size__c=255
			, Target__c='Agency'
			, Type__c='String'
			, GDP_File_Description__c=fileDescriptionReference.Id
			, Filter_Field_API_Name__c='', Filter_Field_Value__c=''
			, Hidden_Column__c=false, TXT_Hidden_Column__c=false, XML_Hidden_Column__c=false
			, Visible__c=true
			));
		
		fileFieldDescriptionList.add(new GDP_File_Fields_Description__c(API_Name__c='Card_Status__c', API_Object_Name__c='ID_Card__c'
			, Name__c='Card Status'
			, Position__c=4
			, Size__c=20
			, Target__c='Agency'
			, Type__c='String'
			, GDP_File_Description__c=fileDescriptionReference.Id
			, Filter_Field_API_Name__c='', Filter_Field_Value__c=''
			, Hidden_Column__c=false, TXT_Hidden_Column__c=false, XML_Hidden_Column__c=false
			, Visible__c=true
			));
		
		fileFieldDescriptionList.add(new GDP_File_Fields_Description__c(API_Name__c='Valid_To_Date__c', API_Object_Name__c='ID_Card__c'
			, Name__c='Valid To Date'
			, Position__c=5
			, Size__c=20
			, Target__c='Agency'
			, Type__c='Date YYYYMMDD'
			, GDP_File_Description__c=fileDescriptionReference.Id
			, Filter_Field_API_Name__c='', Filter_Field_Value__c=''
			, Hidden_Column__c=false, TXT_Hidden_Column__c=false, XML_Hidden_Column__c=false
			, Visible__c=true
			));
		
		fileFieldDescriptionList.add(new GDP_File_Fields_Description__c(API_Name__c='Received_From_AIMS__c', API_Object_Name__c='ID_Card__c'
			, Name__c='Received From AIMS'
			, Position__c=6
			, Size__c=20
			, Target__c='Agency'
			, Type__c='Datetime'
			, GDP_File_Description__c=fileDescriptionReference.Id
			, Filter_Field_API_Name__c='', Filter_Field_Value__c=''
			, Hidden_Column__c=false, TXT_Hidden_Column__c=false, XML_Hidden_Column__c=false
			, Visible__c=true
			));
		
		fileFieldDescriptionList.add(new GDP_File_Fields_Description__c(API_Name__c='Blacklisted__c', API_Object_Name__c='ID_Card__c'
			, Name__c='Blacklisted__c'
			, Position__c=7
			, Size__c=20
			, Target__c='Agency'
			, Type__c='Boolean'
			, GDP_File_Description__c=fileDescriptionReference.Id
			, Filter_Field_API_Name__c='', Filter_Field_Value__c=''
			, Hidden_Column__c=false, TXT_Hidden_Column__c=false, XML_Hidden_Column__c=false
			, Visible__c=true
			));
		
		fileFieldDescriptionList.add(new GDP_File_Fields_Description__c(API_Name__c='Fee_Applicable__c', API_Object_Name__c='ID_Card__c'
			, Name__c='Fee_Applicable__c'
			, Position__c=8
			, Size__c=20
			, Target__c='Agency'
			, Type__c='Decimal'
			, GDP_File_Description__c=fileDescriptionReference.Id
			, Filter_Field_API_Name__c='', Filter_Field_Value__c=''
			, Hidden_Column__c=false, TXT_Hidden_Column__c=false, XML_Hidden_Column__c=false
			, Visible__c=true
			));
		
		fileFieldDescriptionList.add(new GDP_File_Fields_Description__c(API_Name__c='Related_Contact__r.Status__c', API_Object_Name__c='ID_Card__c'
			, Name__c='Contact Status'
			, Position__c=11
			, Size__c=20
			, Target__c='Agency'
			, Type__c='String'
			, GDP_File_Description__c=fileDescriptionReference.Id
			, Filter_Field_API_Name__c='', Filter_Field_Value__c=''
			, Hidden_Column__c=false, TXT_Hidden_Column__c=false, XML_Hidden_Column__c=false
			, Visible__c=true
			));
		
		fileFieldDescriptionList.add(new GDP_File_Fields_Description__c(API_Name__c='Related_Contact__r.Start_Date_Agency_Year__c', API_Object_Name__c='ID_Card__c'
			, Name__c='Start_Date_Agency_Year__c'
			, Position__c=12
			, Size__c=4
			, Target__c='Agency'
			, Type__c='Integer'
			, GDP_File_Description__c=fileDescriptionReference.Id
			, Filter_Field_API_Name__c='', Filter_Field_Value__c=''
			, Hidden_Column__c=false, TXT_Hidden_Column__c=false, XML_Hidden_Column__c=false
			, Visible__c=true
			));
		
		insert fileFieldDescriptionList;
		
		return fileDescriptionTest;
	} // prepare fileDescription

}