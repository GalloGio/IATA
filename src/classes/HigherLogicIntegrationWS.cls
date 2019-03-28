public class HigherLogicIntegrationWS {
	
	public class HigherLogicException extends Exception {}
	
	public class MemberDetails {
		public String LegacyContactKey 	{get;set;}
		public Integer Age 				{get;set;}
		public DateTime Birthday 		{get;set;}
		public DateTime MemberSince 	{get;set;}
		public DateTime MemberExpiresOn {get;set;}
		public String Designation 		{get;set;}
		public String EmailAddress 		{get;set;}
		public String PrefixCode 		{get;set;}
		public String FirstName 		{get;set;}
		public String MiddleName 		{get;set;}
		public String LastName 			{get;set;}
		public String InformalName 		{get;set;}
		public String Gender 			{get;set;}
		public String Ethnicity 		{get;set;}
		public String SuffixCode 		{get;set;}
		public String CompanyName 		{get;set;}
		public String Title 			{get;set;}
		public String ParentMemberKey 	{get;set;}
		public String PrimaryContactLegacyContactKey {get;set;}
		public Boolean ExcludeFromDirectory {get;set;}
		public Boolean IsActive 			{get;set;}
		public Boolean IsMember 			{get;set;}
		public Boolean IsOrganization 		{get;set;}
		public String MemberID 				{get;set;}
		public String Bio 					{get;set;}
		public String WebsiteUrl 			{get;set;}
		public String ProfileImageURL 		{get;set;}
		public String Phone1 		{get;set;}
		public String Phone1Type 	{get;set;}
		public String Phone2 		{get;set;}
		public String Phone2Type 	{get;set;}
		public String Phone3 		{get;set;}
		public String Phone3Type 	{get;set;}
		public String Phone4 		{get;set;}
		public String Phone4Type 	{get;set;}
		public String Address1 		{get;set;}
		public String Address2 		{get;set;}
		public String Address3 		{get;set;}
		public String City 			{get;set;}
		public String State 		{get;set;}
		public String PostalCode 	{get;set;}
		public String Country 		{get;set;}
		public String YouTubeURL 	{get;set;}
		public String FacebookURL 	{get;set;}
		public String TwitterURL 	{get;set;}
		public String GooglePlusURL {get;set;}
		public String LinkedInURL 	{get;set;}
		public String BloggerURL 	{get;set;}
		public String WordPressURL 	{get;set;}
		public String OtherBlogURL 	{get;set;}
	}	
	
	public class Items {
		public MemberDetails MemberDetails {get; set;}
	}
	
	public class HigherLogicRequest {
		public String TenantCode {get; set;}
		public List<Items> Items {get; set;}
	}
	
	public class HigherLogicResponse {
		public String statusCode {get; set;}
		public String responseBody {get; set;}
	}
	
	private static List<ISSP_Web_Service_Log__c> wsServiceLogLst = new List<ISSP_Web_Service_Log__c>();
	
	/**
	* Invokes Higher Logic Push API
	*
	* @param requestBody: HigherLogicRequest
	*
	* @return hlResp: HigherLogicResponse
	*
	*/
	private static HigherLogicResponse invoke(HigherLogicRequest requestBody){
		
		HigherLogicResponse hlResp = new HigherLogicResponse();

		try {
			
			requestBody.TenantCode = '{!$Credential.Username}';
			
			String requestBodyJSON = JSON.serialize(requestBody);
			
			HttpRequest request = new HttpRequest();
			
			request.setEndpoint('callout:Higher_Logic_Push_API');
			request.setHeader('x-api-key', '{!$Credential.Password}');
			request.setMethod('POST');
			request.setHeader('content-type', 'application/json');
			request.setBody(requestBodyJSON);
			
			System.debug(LoggingLevel.FINE, '____ [cls HigherLogicIntegrationWS - invoke] WS Request Body: ' + request.getBody());
			
			Http http = new Http();
			
			HttpResponse response = http.send(request);
			
			System.debug(LoggingLevel.FINE, '____ [cls HigherLogicIntegrationWS - invoke] WS Response: ' + response);

			hlResp.statusCode = String.valueOf(response.getStatusCode());
			hlResp.responseBody = response.getBody();
			
		}
		catch(Exception e){
			
			String exceptionMsg = e.getMessage();
			
			System.debug(LoggingLevel.ERROR, '____ [cls HigherLogicIntegrationWS - invoke] Exception: ' + exceptionMsg);
			
			hlResp.statusCode = 'ERR';
			hlResp.responseBody = exceptionMsg;
		
		}
		
		return hlResp;
		
	}
	
	/**
	* Creates a new instance of MemberDetails
	* considering the sObj information
	* 
	* @param sObject: sObject (User or Account)
	* @param legacyContactsMap: Map<Id, Id> (only used if the sObj is an instance of Account)
	* @param activeUserMap: Map<Id, Boolean> (only used if the sObj is an instance of User)
	*
	* @return memberDetails: MemberDetails
	*
	*/
	private static MemberDetails createMemberDetail(sObject sObj, Map<Id, Id> legacyContactsMap, Map<Id, Boolean> activeUserMap){
		
		MemberDetails memberDetails = new MemberDetails();
		
		// Person Mapping
		if(sObj instanceof User){
			
			User user = (User) sObj;

			Id accountId = user.ContactId == null ? ProvisionKaviAccess.getFakeAccount().Id : user.Contact.AccountId;
			String accountName = user.ContactId == null ? ProvisionKaviAccess.getFakeAccount().Name : user.Contact.Account.Name;
			
			// Active status is defined based on the Portal Application Right
			// PAR with Access Granted => ACTIVE
			// PAR with Access Denied => INACTIVE
			Boolean activeUser = activeUserMap.get(user.Id);
			
			memberDetails.LegacyContactKey 	= user.Id;
			memberDetails.ParentMemberKey	= accountId;
			memberDetails.CompanyName		= accountName;
			memberDetails.FirstName 		= user.FirstName;
			memberDetails.LastName 			= user.LastName;
			memberDetails.Title 			= user.Title;
			memberDetails.Address1			= user.Street;
			memberDetails.City 				= user.City;
			memberDetails.State				= user.State;
			memberDetails.Country 			= user.Country;
			memberDetails.PostalCode	 	= user.PostalCode;
			memberDetails.EmailAddress		= user.Email;
			memberDetails.Phone1			= user.Phone;
			memberDetails.Phone1Type		= 'Work';
			memberDetails.Phone2			= user.MobilePhone;
			memberDetails.Phone2Type		= 'Mobile';
			memberDetails.Phone3			= user.Fax;
			memberDetails.Phone3Type		= 'Fax';
			memberDetails.IsActive			= activeUser;
			memberDetails.IsMember			= true;
			memberDetails.IsOrganization	= false;
			
		}
		// Company Mapping
		else if(sObj instanceof Account){
			
			Account acct = (Account) sObj;
			
			Id legacyContactId = legacyContactsMap.get(acct.Id);
			
			memberDetails.CompanyName						= acct.Name; 
			memberDetails.WebsiteURL						= acct.Website;
			memberDetails.EmailAddress						= acct.Email__c;
			memberDetails.PrimaryContactLegacyContactKey	= legacyContactId;
			memberDetails.LegacyContactKey					= acct.Id;
			memberDetails.Address1			 				= acct.BillingStreet;
			memberDetails.City				 				= acct.BillingCity;
			memberDetails.State 			 				= acct.BillingState;
			memberDetails.Country			 				= acct.BillingCountry;
			memberDetails.PostalCode		 				= acct.BillingPostalCode;
			memberDetails.IsActive			 				= true;
			memberDetails.IsOrganization	 				= true;
			
		}
		
		return memberDetails;
		
	}
	
	/**
	* Creates a new request body for Higher Logic Push API
	* considering the members given (Users and/or Accounts)
	*
	* @param sObjectLst: List<sObject> (Users or Accounts)
	* @param legacyContactMap: Map<Id, Id>
	* @param activeUserMap: Map<Id, Boolean>
	*
	* @return hlRequest: HigherLogicRequest
	*
	*/
	private static HigherLogicRequest createRequestBody(List<sObject> sObjectLst, Map<Id, Id> legacyContactMap, Map<Id, Boolean> activeUserMap){
		
		HigherLogicRequest hlRequest = new HigherLogicRequest();
		
		List<Items> itemsLst = new List<Items>();
		
		for(sObject sObj : sObjectLst){

			MemberDetails memberDetails = createMemberDetail(sObj, legacyContactMap, activeUserMap);

			Items items = new Items();
			
			items.MemberDetails = memberDetails;
			
			itemsLst.add(items);

		}
		
		hlRequest.Items = itemsLst;
		
		return hlRequest;	
	
	}
	
	/**
	* Pushes members (users & accounts) to HigherLogic
	*
	* @param sObjectLst: List<sObject>  
	* @param contactIdMap: Map<Id, Id>
	* @param activeUserMap: Map<Id, Boolean>
	*
	*/
	public static void pushMembers(List<sObject> sObjectLst, Map<Id, Id> contactIdMap, Map<Id, Boolean> activeUserMap){
		
		HigherLogicRequest request = createRequestBody(sObjectLst, contactIdMap, activeUserMap);
		
		HigherLogicResponse response = invoke(request);
		
		processHigherLogicResponse('pushMembers', response);
		
	}
	
	/**
	* Processes the HigherLogic Push API response
	*
	* @param action: String
	* @param wsResponse: HigherLogicResponse
	*
	*/
	private static void processHigherLogicResponse(String action, HigherLogicResponse wsResponse){
		wsServiceLogLst.add(createNewWSLog(action, wsResponse));
	}
	
	/**
	* Creates a new ISSP_Web_Service_Log record
	* considering the web service response
	* 
	* @param wsMethod: String
	* @param wsResponse: HigherLogicResponse
	*
	* @return newLog: ISSP_Web_Service_Log__c
	*
	*/
	private static ISSP_Web_Service_Log__c createNewWSLog(String wsMethod, HigherLogicResponse wsResponse){
		
		ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
		
		newLog.Web_Service__c	 = 'HigherLogicIntegrationWS';
		newLog.Method__c		 = wsMethod;
		newLog.System__c		 = 'Standards Setting Workspace';
		newLog.User__c			 = UserInfo.getUserId();
		newLog.Finished__c		 = System.now();
		newLog.Error_Code__c	 = wsResponse.statusCode;
		newLog.Error_Message__c	 = wsResponse.responseBody;

		if(newLog.Error_Code__c == '200'){
			newLog.Success__c = true;
		}
		
		return newLog;
		
	}
	
	/**
	* Inserts all the collected logs
	*
	*/
	public static void flushWebServiceLogs(){
		
		try{
			
			insert wsServiceLogLst;
			
		} catch (DMLException e){
			
			System.debug(LoggingLevel.ERROR, '____ [cls HigherLogicIntegrationWS - flushWebServiceLogs] Exception: ' + e.getMessage());
			
			for (ISSP_Web_Service_Log__c wslog: wsServiceLogLst) {
				wslog.addError('There was a problem updating the Web Service Log');
			}
			
		}
		
		wsServiceLogLst.clear();
		
	}
	
}