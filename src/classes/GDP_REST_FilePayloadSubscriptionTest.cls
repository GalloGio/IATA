/**
 * This a basic test class for GDP_REST_FilePayloadSubscription.cls
 *  - GDP_REST_FilePayloadSubscription: /GSS/v0/FileDataSubscription/
 *
 * Original Author: Sonny Leman
 *
 * Change log:
 *   2016-04-21-sl: initial version
 *
 *
 */

@isTest (SeeAllData=false)
private class GDP_REST_FilePayloadSubscriptionTest {

	// =======================================================================
	private static GDP_File_Description__c fileDescriptionTest01;

	// test data definition
	private static final String GDP_FILE_DESCRIPTION_NAME_SUBSCRIPTION_REF = 'CAC Subscription Details Reference TEST';
	private static final String GDP_FILE_DESCRIPTION_NAME_SUBSCRIPTION_NONREF = 'CAC Subscription Details TEST';
	private static final Integer NUMBER_OF_TEST_SUBSCRIPTION_RECORDS = 100; // number of Zuora_Subscription, Accounts, CAC_Subscription_Detail

	// -----------------------------------------------------------------------
	private static final String accountRecTypeDevName = 'Standard_Account'; //
	private static final String contactRecTypeDevName = 'Standard_Contact'; //

	private static final integer HTTP_STATUS_OK = 200;
	private static final integer HTTP_STATUS_BAD_REQUEST = 400;
	private static final String REQUEST_URI = '/GSS/v0/FileDataSubscription';

	// =======================================================================
	// Basic Test Scenario: good case
	// testSetUp insertTestData should already prepared the test records
	static testMethod void testSubscription_01GoodCase_StandardBatch() {
		List<GDP_File_Description__c> fileDescriptionTestList = [select Id, Name from GDP_File_Description__c where Name = :GDP_FILE_DESCRIPTION_NAME_SUBSCRIPTION_NONREF];
		System.assertEquals(1, fileDescriptionTestList.size(), 'testSubscription_01GoodCase(): Found extra Test File Description with name: '
							+ GDP_FILE_DESCRIPTION_NAME_SUBSCRIPTION_NONREF + ' : '
							+ fileDescriptionTestList.size());
		fileDescriptionTest01 = fileDescriptionTestList[0];

		// RestRequest preparation
		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();

		request.requestURI = REQUEST_URI; // '/GSS/v0/FileDataSubscription';
		request.httpMethod = 'GET';
		request.addParameter('FileSpecificationId', fileDescriptionTest01.Id);

		RestContext.request = request;
		RestContext.response = response;

		Test.startTest();

		//Tests positive scenario with code 200 / HTTP_STATUS_OK
		//GDP_REST_FilePayloadIdCard.Record result =
		GDP_REST_FilePayloadSubscription.getFilePayloadSubscription();

		//System.debug( 'testSubscription_01GoodCase: result:' + result);
		System.debug( 'testSubscription_01GoodCase: responseBody:' + response.responseBody.toString());
		System.debug( 'testSubscription_01GoodCase: response:' + response.responseBody);

		//Assert
		system.debug('testSubscription_01GoodCase getFilePayload responseBody : ' + response.responseBody.toString());
		system.debug('testSubscription_01GoodCase getFilePayload Status Code : ' +  response.statusCode);
		System.assertEquals(HTTP_STATUS_OK, response.statusCode);

		Test.stopTest();

	} // end of testSubscription_01GoodCaseStandardBatch


	// =======================================================================
	// Basic Test Scenario: good case
	static testMethod void testSubscription_02GoodCase_SmallBatch() {
		List<GDP_File_Description__c> fileDescriptionTestList = [select Id, Name from GDP_File_Description__c where Name = :GDP_FILE_DESCRIPTION_NAME_SUBSCRIPTION_NONREF];
		System.assertEquals(1, fileDescriptionTestList.size(), 'testSubscription_01GoodCase(): Found extra Test File Description with name: '
							+ GDP_FILE_DESCRIPTION_NAME_SUBSCRIPTION_NONREF + ' : '
							+ fileDescriptionTestList.size());
		fileDescriptionTest01 = fileDescriptionTestList[0];

		// RestRequest preparation
		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();

		request.requestURI = REQUEST_URI; // '/GSS/v0/FileDataSubscription';
		request.httpMethod = 'GET';
		request.addParameter('FileSpecificationId', fileDescriptionTest01.Id);
		request.addParameter('RequestSizeFactor', '12');

		RestContext.request = request;
		RestContext.response = response;

		Test.startTest();

		//Tests positive scenario with code 200 / HTTP_STATUS_OK
		//GDP_REST_FilePayloadIdCard.Record result =
		GDP_REST_FilePayloadSubscription.getFilePayloadSubscription();

		//System.debug( 'testSubscription_02GoodCase: result:' + result);
		System.debug( 'testSubscription_02GoodCase: responseBody:' + response.responseBody.toString());
		System.debug( 'testSubscription_02GoodCase: response:' + response.responseBody);

		//Assert
		system.debug('testSubscription_02GoodCase getFilePayload responseBody : ' + response.responseBody.toString());
		system.debug('testSubscription_02GoodCase getFilePayload Status Code : ' +  response.statusCode);
		System.assertEquals(HTTP_STATUS_OK, response.statusCode);

		Test.stopTest();

	} // end of testSubscription_02GoodCaseSmallBatch


	// =======================================================================
	// Basic Test Scenario: bad case
	// case 3: use fileSpecificationId that will not return existing one
	static testMethod void testSubscription_03BadCase() {
		List<GDP_File_Description__c> fileDescriptionTestList = [select Id, Name, Reference__c
										from GDP_File_Description__c
										where Name = :GDP_FILE_DESCRIPTION_NAME_SUBSCRIPTION_NONREF];
		System.assertEquals(1, fileDescriptionTestList.size(), 'testSubscription_01GoodCase(): Found extra Test File Description with name: '
								+ GDP_FILE_DESCRIPTION_NAME_SUBSCRIPTION_NONREF + ' : '
								+ fileDescriptionTestList.size());
		fileDescriptionTest01 = fileDescriptionTestList[0];

		String fileSpecificationId;

		RestRequest request;
		RestResponse response;

		Test.startTest();

		// bad case 1: no fileSpecificationId mentioned in the REST API Header
		// RestContext / RestRequest preparation
		request = new RestRequest();
		response = new RestResponse();

		request.requestURI = REQUEST_URI; // '/GSS/v0/FileDataSubscription';
		request.httpMethod = 'GET';

		RestContext.request = request;
		RestContext.response = response;

		try{
			//Test negative scenario with code not 200 / HTTP_STATUS_OK
			system.debug('testSubscription_03BadCase getFilePayloadSubscription with no fileSpecificationId parameter. ');
			GDP_REST_FilePayloadSubscription.getFilePayloadSubscription();
			system.debug('testSubscription_03BadCase getFilePayloadSubscription should fail. ' + response);
			system.debug('testSubscription_03BadCase getFilePayloadSubscription responseBody : ' + response.responseBody.toString());
			system.debug('testSubscription_03BadCase getFilePayloadSubscription Status Code : ' +  response.statusCode);
			System.assertNotEquals(HTTP_STATUS_OK, response.statusCode); // in case the getFilePayload error handling return gracefully
		} catch (Exception ex) {
			//Assert
			system.debug('testSubscription_03BadCase getFilePayloadSubscription expected exception was generated : ' + ex);
			system.debug('testSubscription_03BadCase getFilePayloadSubscription responseBody : ' + response.responseBody);
			system.debug('testSubscription_03BadCase getFilePayloadSubscription Status Code : ' +  response.statusCode);
			System.assertNotEquals(HTTP_STATUS_OK, response.statusCode);
		}

		// --------------------------------------------------------------------
		// bad case 2: bad fileSpecificationId
		// RestContext / RestRequest preparation
		fileSpecificationId = UserInfo.getUserId(); // bad record Id, will found nothing, this ensure incorrect return

		request = new RestRequest();
		response = new RestResponse();

		request.requestURI = REQUEST_URI; // '/GSS/v0/FileDataSubscription';
		request.httpMethod = 'GET';
		request.addParameter('FileSpecificationId', fileSpecificationId );

		RestContext.request = request;
		RestContext.response = response;

		try{
			//Test negative scenario with code not 200 / HTTP_STATUS_OK
			system.debug('testSubscription_03BadCase getFilePayload with bad fileSpecificationId. ');
			GDP_REST_FilePayloadSubscription.getFilePayloadSubscription();
			system.debug('testSubscription_03BadCase getFilePayload should fail. ' + response);
			system.debug('testSubscription_03BadCase getFilePayload responseBody : ' + response.responseBody.toString());
			system.debug('testSubscription_03BadCase getFilePayload Status Code : ' +  response.statusCode);
			System.assertNotEquals(HTTP_STATUS_OK, response.statusCode); // in case the getFilePayload error handling return gracefully
		} catch (Exception ex) {
			//Assert
			system.debug('testSubscription_03BadCase getFilePayload expected exception was generated : ' + ex);
			system.debug('testSubscription_03BadCase getFilePayload responseBody : ' + response.responseBody);
			system.debug('testSubscription_03BadCase getFilePayload Status Code : ' +  response.statusCode);
			System.assertNotEquals(HTTP_STATUS_OK, response.statusCode);
		}

		Test.stopTest();
	} // end of testSubscription_03BadCase


	// =======================================================================
	// Additional calls
	// simply added to increase coverage and ensure those little methods callable
	// some of the library below might not been called during current normal run
	static testMethod void testSubscription_04OtherCalls()
	{
		Test.startTest();
		// call inner object FieldStructureCls
		GDP_REST_FilePayloadSubscription.FieldStructureCls fieldStruct = new GDP_REST_FilePayloadSubscription.FieldStructureCls();

		// call public void LoadFieldStructure(...)
		String vFieldAPIName = 'Name|Name|LastModifiedDate|CreatedDate|Id';
		String vFieldType = 'String|String|Date YYYYMMDDHHMM|Date YYYYMMDD|String';
		String vFieldVisible = '1|1|1|1|1';
		String vFieldFilter = 'Name|Target|Status|Type|Name';
		String vFieldFilterValue = 'abc|Agency|Unknown|date|null';
		String vFieldObjectName = 'Account|CAC_Subscription_Detail__c|CAC_Subscription_Detail__c|Account|Agency_Owner__c';
		String vFieldGroup ='Agency|Agency|Agency|Agency|Agency_Owner__c';
		fieldStruct.LoadFieldStructure(vFieldAPIName
										, vFieldType
										, vFieldVisible
										, vFieldFilter
										, vFieldFilterValue
										, vFieldObjectName
										, vFieldGroup);

		// call some filter methods
		fieldStruct.ExtractUniqueFilterValue( 'Account');
		fieldStruct.ExtractFilterSOQL('Account');
		fieldStruct.ExtractFilterSQL('Account', 'Type');

		// ----------------------------------------------
		List<CAC_Subscription_Detail__c> cacSubscriptionDetailList = [select Id, Name from CAC_Subscription_Detail__c limit 1];
		System.assertNotEquals(0, cacSubscriptionDetailList.size(), 'testSubscription_04OtherCalls(): no cacSubscriptionDetailList found.');

		// call inner object DataStructureCls
		GDP_REST_FilePayloadSubscription.DataStructureCls dataStruct = new GDP_REST_FilePayloadSubscription.DataStructureCls(cacSubscriptionDetailList[0]);
		//dataStruct.RetrieveObjectMapId('Agency_Owner__c', 'Name', 'abc');
		//dataStruct.RetrieveObjectMapId('GDP_Phone__c', 'Name', '517');
		dataStruct.RetrieveObjectMapId('GDP_File_Description__c', 'Name', 'abc');

		Test.stopTest();
	} // end of testSubscription_04OtherCalls


	// ==============================================================
	// prepare test data: Zuora__Subscription, CAC_Subscription_Detail,
	// also initiate and insert GDP_File_Description along with the its reference and related fields
	//
	@testSetup private static void insertTestData()
	{
		// create IATA_ISO_Country__c
		IATA_ISO_Country__c testCountry = new IATA_ISO_Country__c (
			AIMS_Area_Name__c='Canada',
			ISO_Code__c='CA',
			AIMS_Area_ID__c='1'
		);
		insert testCountry;

		GDP_File_Description__c gdpFileDescriptionSub = prepareGdpFileDescriptionCacSubscription();
		List<Zuora__Subscription__c> zuoraSubscriptionList = prepareZuoraSubscriptions(NUMBER_OF_TEST_SUBSCRIPTION_RECORDS);

		// create CAC subscription detail for each zuora subscription
		List<CAC_Subscription_Detail__c> subscriptionDetailList = createCACSubscriptionDetailList( zuoraSubscriptionList,  gdpFileDescriptionSub.Id);

	} // insertTestData


	// ========================================================================
	// prepare the GDP File Description for CAC Subscription, including its reference
	// return only the non reference GDP File Description
	private static GDP_File_Description__c prepareGdpFileDescriptionCacSubscription()
	{
		GDP_File_Description__c gdpFileDescriptionSubRef = new GDP_File_Description__c( Atom__c = '255'
			, Name = GDP_FILE_DESCRIPTION_NAME_SUBSCRIPTION_REF // 'CAC Subscription Details Reference TEST'
			, Description__c = 'CAC Subscription Details Reference TEST'
			, Maximum_API_Request__c = 1000
			, Payload_Procedure__c = 'Subscription'
			, Product_Type__c = 'CAC'
			, Reference_Clause__c = 'Subscription__r.Zuora__SubscriptionStartDate__c <= TODAY AND subscription__r.Zuora__SubscriptionEndDate__c >=TODAY AND  Subscription__r.Zuora__Status__c = \'Active\''
			, Reference__c = null
			, Service_Target__c = 'Subscription'
			);
		insert gdpFileDescriptionSubRef;


		// add fields to the reference file description
		List<GDP_File_Fields_Description__c> gdpFileFieldList = new List<GDP_File_Fields_Description__c>();
		gdpFileFieldList.add(new GDP_File_Fields_Description__c(API_Name__c = 'Service_Specification__c', API_Object_Name__c = 'CAC_Subscription_Detail__c', GDP_File_Description__c = gdpFileDescriptionSubRef.Id, Hidden_Column__c = false, Name__c = 'ServiceSpecification', Position__c = 10, Size__c = 18, Target__c = 'Agency', TXT_Hidden_Column__c = false, Type__c = 'String', Visible__c = true, XML_Hidden_Column__c = true));
		gdpFileFieldList.add(new GDP_File_Fields_Description__c(API_Name__c = 'Id', API_Object_Name__c = 'CAC_Subscription_Detail__c', GDP_File_Description__c = gdpFileDescriptionSubRef.Id, Hidden_Column__c = false, Name__c = 'ServiceProduct', Position__c = 20, Size__c = 18, Target__c = 'Agency', TXT_Hidden_Column__c = false, Type__c = 'String', Visible__c = true, XML_Hidden_Column__c = true));
		gdpFileFieldList.add(new GDP_File_Fields_Description__c(API_Name__c = 'lastmodifieddate', API_Object_Name__c = 'GDP_File_Production__c', GDP_File_Description__c = gdpFileDescriptionSubRef.Id, Hidden_Column__c = false, Name__c = 'Lastmodifieddate', Position__c = 30, Size__c = 12, Target__c = 'Agency', TXT_Hidden_Column__c = false, Type__c = 'Date YYYYMMDDHHMM', Visible__c = true, XML_Hidden_Column__c = true));
		gdpFileFieldList.add(new GDP_File_Fields_Description__c(API_Name__c = 'Reference__r.Service_Target__c', API_Object_Name__c = 'GDP_File_Description__c', GDP_File_Description__c = gdpFileDescriptionSubRef.Id, Hidden_Column__c = false, Name__c = 'ServiceTarget', Position__c = 40, Size__c = 15, Target__c = 'Agency', TXT_Hidden_Column__c = false, Type__c = 'String', Visible__c = true, XML_Hidden_Column__c = true));
		gdpFileFieldList.add(new GDP_File_Fields_Description__c(API_Name__c = 'Status__c', API_Object_Name__c = 'CAC_Subscription_Detail__c', GDP_File_Description__c = gdpFileDescriptionSubRef.Id, Hidden_Column__c = false, Name__c = 'ResponseContent', Position__c = 50, Size__c = 2000, Target__c = 'Agency', TXT_Hidden_Column__c = false, Type__c = 'String', Visible__c = true, XML_Hidden_Column__c = true));
		gdpFileFieldList.add(new GDP_File_Fields_Description__c(API_Name__c = 'Shared_Group__c', API_Object_Name__c = 'CAC_Subscription_Detail__c', GDP_File_Description__c = gdpFileDescriptionSubRef.Id, Hidden_Column__c = false, Name__c = 'ResponseType', Position__c = 55, Size__c = 20, Target__c = 'Agency', TXT_Hidden_Column__c = false, Type__c = 'String', Visible__c = true, XML_Hidden_Column__c = true));
		gdpFileFieldList.add(new GDP_File_Fields_Description__c(API_Name__c = 'Service_Token__c', API_Object_Name__c = 'CAC_Subscription_Detail__c', GDP_File_Description__c = gdpFileDescriptionSubRef.Id, Hidden_Column__c = false, Name__c = 'ResponseCode', Position__c = 60, Size__c = 400, Target__c = 'Agency', TXT_Hidden_Column__c = false, Type__c = 'String', Visible__c = true, XML_Hidden_Column__c = true));
		gdpFileFieldList.add(new GDP_File_Fields_Description__c(API_Name__c = 'Max_API_Call_Per_Month__c', API_Object_Name__c = 'CAC_Subscription_Detail__c', GDP_File_Description__c = gdpFileDescriptionSubRef.Id, Hidden_Column__c = false, Name__c = 'MaxAPICallPerMonth', Position__c = 70, Size__c = 10, Target__c = 'Agency', TXT_Hidden_Column__c = false, Type__c = 'String', Visible__c = true, XML_Hidden_Column__c = true));
		insert gdpFileFieldList;

		// create the non reference file description
		GDP_File_Description__c gdpFileDescriptionSub = new GDP_File_Description__c( Atom__c = '255'
			, Name = GDP_FILE_DESCRIPTION_NAME_SUBSCRIPTION_NONREF // 'CAC Subscription Details TEST'
			, Description__c = 'CAC Subscription Details TEST'
			, File_Format__c = 'Database'
			, File_Naming_Convention__c = 'subscription.txt'
			, Frequency__c = 'Daily'
			, Magnitude__c = 'Master'
			, Product_Type__c = 'CAC'
			, Reference__c = gdpFileDescriptionSubRef.Id
		);
		insert gdpFileDescriptionSub;
		return gdpFileDescriptionSub;
	} // prepareGdpFileDescriptionCacSubscription


	// ========================================================================
	// create and insert ZuoraSubscriptions along with required Accounts and Zuora__CustomerAccount
	private static List<Zuora__Subscription__c> prepareZuoraSubscriptions(Integer numOfAccounts)
	{
		// create accounts
		List<Account> acctList = createAccountList(numOfAccounts);

		// create Zuora__CustomerAccount / billing account, here Zuora__Zuora_Id and IINETUserID will be generated
		List<Zuora__CustomerAccount__c> zuoraAcctList = createBillingAccountList(acctList);
		System.assertEquals( numOfAccounts, zuoraAcctList.size(), 'prepareZuoraSubscriptions(): In this test case, each Account should have exactly one Zuora__CustomerAccount/Billing Account.');
		// i think we might skip creating product and product category.

		// create Subscription for each accountList/zuoraAccountList, one for each
		List<Zuora__Subscription__c> zSubscriptionList = createZuoraSubscriptionList( acctList, zuoraAcctList);

		return zSubscriptionList;
	} // end of prepareZuoraSubscriptions

	// ========================================================================
	// create and insert account list as many as numOfRecs
	// assume that the BillingCountry already defined in IATA_ISO_Country
	private static List<Account> createAccountList( Integer numOfRecs)
	{
		String baseName = 'TestAcct';
		String accountType = 'IATA Passenger Sales Agent';
		List<Account> acctList = new List<Account>();
		for (Integer idx=0;idx<numOfRecs;idx++)
		{
			Account newAccount = new Account( Name = baseName + String.valueOf(idx).trim()
						, BillingCity = 'test'
						, BillingCountry = 'Canada'
						, Type = accountType
						, Location_Type__c = 'BR'
					);
			acctList.add(newAccount);
		}
		insert acctList;
		return acctList;
	} // end of createAccountList

	// ========================================================================
	// create and insert billing account list for a given account list
	private static List<Zuora__CustomerAccount__c> createBillingAccountList( List<Account> acctList)
	{
		String baseIinetId = 'a10';
		String baseZuoraId = '12345678901234567890123456789'; // max length=32, for Zuora__Zuora_Id__c

		List<Zuora__CustomerAccount__c> billingAccountList = new List<Zuora__CustomerAccount__c>();
		for (Integer idx=0;idx<acctList.size();idx++)
		{
			String idxStr = String.valueOf(idx).trim().leftpad(3,'0');
			Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(
				name = acctList[idx].name
				, Zuora__Account__c = acctList[idx].Id
				, Zuora__Zuora_Id__c = baseZuoraId + idxStr
				, IINETUserID__c = baseIinetid + idxStr
				);
		   billingAccountList.add(billingAccount);
		}
		insert billingAccountList;
		return billingAccountList;
	} // end of createBillingAccountList

	// ========================================================================
	// create and insert active subscriptions  for the given account list / billing account list
	// assume that acctList and zuoraAcctList have the same size
	private static List<Zuora__Subscription__c> createZuoraSubscriptionList(List<Account> acctList, List<Zuora__CustomerAccount__c> zuoraAcctList)
	{
		String baseZuoraId = '22345678901234567890123456789'; // max length=32, for Zuora__Zuora_Id__c
		System.assertEquals( acctList.size(), zuoraAcctList.size(), 'createZuoraSubscriptionList, different acct & billing account list size:'
								+ acctList.size() + ':' + zuoraAcctList.size());
		List<Zuora__Subscription__c>  zSubscriptionList = new List<Zuora__Subscription__c>();
		for (Integer idx=0;idx<acctList.size();idx++)
		{
			String idxStr = String.valueOf(idx).trim().leftpad(3,'0');
			Zuora__Subscription__c  zSubscription = new Zuora__Subscription__c (
				Name = acctList[idx].Name+' Subscription'
				, Zuora__Account__c = acctList[idx].Id
				, Zuora__CustomerAccount__c = zuoraAcctList[idx].Id
				, Zuora__Zuora_Id__c = baseZuoraId + idxStr
				, Zuora__SubscriptionStartDate__c = Date.today().addYears(-1)
				, Zuora__SubscriptionEndDate__c = Date.today().addYears(1).addDays(idx)
				, Zuora__Status__c = 'Active'
				);
			zSubscriptionList.add(zSubscription);
		}
		insert zSubscriptionList;
		return zSubscriptionList;
	} // end of createZuoraSubscription

	// ========================================================================
	// create and insert CAC_Subscription_Detail for each subscription
	// all will be assigned same GDP_File_Description
	// normally, this is done using GDP_File_Description_To_Rate_Plan__c which we skip for simplifying this test class
	private static List<CAC_Subscription_Detail__c> createCACSubscriptionDetailList( List<Zuora__Subscription__c> zSubscriptionList
				, Id gdpFileDescSubsId // GDP_File_Description.Id for CACWEB subscription
			)
	{
		List<CAC_Subscription_Detail__c>  subDetList = new List<CAC_Subscription_Detail__c>();

		for (Integer idx=0;idx<zSubscriptionList.size();idx++)
		{
			String idxStr = String.valueOf(idx).trim().leftpad(3,'0');

			// insert file subscription detail
			CAC_Subscription_Detail__c subDet = new CAC_Subscription_Detail__c(Name = zSubscriptionList[idx].Name
				, Subscription__c = zSubscriptionList[idx].Id
				, Service_Specification__c = gdpFileDescSubsId
				, Share_Authorized_Usage__c = true
				, Max_API_Call_Per_Month__c = 100
				, Service_Activation_Date__c = System.today().addDays(-idx)
				, Status__c='Active'
				);
			subDetList.add(subDet);
		}
		insert subDetList;
		return subDetList;
	} // end of createCACSubscriptionDetailList

}
