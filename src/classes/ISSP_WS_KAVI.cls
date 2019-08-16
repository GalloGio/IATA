public class ISSP_WS_KAVI {

	public static Boolean preventTrigger;

	private static String AGENCY_RECORD_TYPE_ID;
	private static String BRANCH_RECORD_TYPE_ID;
	private static String HEADQUARTER_RECORD_TYPE_ID;

	static{
		preventTrigger = false;
		AGENCY_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		BRANCH_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');
		HEADQUARTER_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
	}

	public static String CLIENT_KEY {       
		get{
			String clientKey='';
			if (ISSP_Kavi_Settings__c.getValues('CLIENT KEY')!=null)
				clientKey = ISSP_Kavi_Settings__c.getValues('CLIENT KEY').value__c;
			return clientKey;
		}
		set{}
	}

	public static String CLIENT_SECRET {       
		get{
			String clientSecret='';
			if(Test.isRunningTest()){
				clientSecret='123123';
			}
			else{           
				if (ISSP_Kavi_Settings__c.getValues('CLIENT SECRET')!=null)
					clientSecret = ISSP_Kavi_Settings__c.getValues('CLIENT SECRET').value__c;
			}
			return clientSecret;
		}
		set{}
	}

	public static String X_KAVI_SITE {       
		get{
			String xKaviSite='';
			if (ISSP_Kavi_Settings__c.getValues('X KAVI SITE')!=null)
				xKaviSite = ISSP_Kavi_Settings__c.getValues('X KAVI SITE').value__c;
			return xKaviSite;
		}
		set{}
	}

	public static String ENDPOINT {       
		get{
			String endpoint='';
			if (ISSP_Kavi_Settings__c.getValues('ENDPOINT')!=null)
				endpoint = ISSP_Kavi_Settings__c.getValues('ENDPOINT').value__c;
			return endpoint;
		}
		set{}
	}

	public static List<String> userUpdateFieldsList = new List<String>{'Username','Title','FirstName','LastName','IsActive'};

	public static List<String> userFieldsList = new List<String>{'Username','Title','FirstName','LastName','Phone','Fax','IsActive','City'
		,'State','Country','Street'};

	public static Map<String,String> accountFieldsMap = new Map<String,String>{'Name'=>'Name','Email__c'=>'EmailAddress','Website'=>'URL','BillingCity'=>'City',
			'BillingStreet'=>'Street','BillingPostalCode'=>'Zip'};



	public class Request_Header {
		public String method                { get; set; }
		public String path                  { get; set; }
		public String content_type          { get; set; }
		public String content_md5           { get; set; }
		public String send_date             { get; set; }
		public String body                  { get; set; }

	}

	public static String retAccountId(Id accountId, Id recordTypeId, String airlineType, Id parentId, Id parent2Id){
		String accId = accountId;
		if((recordTypeId == BRANCH_RECORD_TYPE_ID && airlineType=='Branch' && parentId!=null)
				|| (recordTypeId == AGENCY_RECORD_TYPE_ID && parentId!=null && parent2Id==null))
			accId = parentId;
		else if (recordTypeId == AGENCY_RECORD_TYPE_ID && parentId!=null && parent2Id!=null)
			accId = parent2Id;
		return accId;
	}

	public static void updateKaviUsers(Set<String> newContactsIds, List<User> newUsersList){
		List<Portal_Application_Right__c> portalAppRights = [Select Id,Kavi_user__c,ContactId__c
		                                                     From Portal_Application_Right__c 
		                                                     Where Contact__c In:(newContactsIds)        
		                                                     And    Kavi_user__c = true    
		                                                     And   Portal_Application__r.Name = 'Standards Setting Workspace'];

		Map<Id,Portal_Application_Right__c> contactRightsMap = new Map<Id,Portal_Application_Right__c>();

		for (Portal_Application_Right__c portalAppRight: portalAppRights)
			contactRightsMap.put(portalAppRight.ContactId__c,portalAppRight);

		List<ISSP_Web_Service_Log__c> wsLogs = new List<ISSP_Web_Service_Log__c>();

		for(User newUser :newUsersList){
			if(contactRightsMap.containsKey(newUser.ContactId) || contactRightsMap.containsKey(newUser.ContactKaviId__c)){
				String xmlBody = '';

				for(String fieldApi :userUpdateFieldsList)
					xmlBody += notNull(fieldApi, newUser.get(fieldApi));

				String xmlRequest = '<?xml version="1.0" encoding="utf-8"?>'+
						'<Request xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
						xmlBody +
						notNull('EmailAddress', newUser.Email)+
						'</Request>';
				system.debug('xmlRequest: ' + xmlRequest);

				Blob targetBlob = Blob.valueOf(xmlRequest);
				Blob hash = Crypto.generateDigest('MD5', targetBlob);
				String content_md5 = EncodingUtil.base64Encode(hash);
				Datetime dt = Datetime.now();

				Request_Header reqHeader = new Request_Header();
				reqHeader.method = 'put'; 
				reqHeader.path = '/v1/person/'+(String.valueOf(newUser.Id)).substring(0,15);
				reqHeader.content_type = 'application/xml';
				reqHeader.content_md5 = content_md5;
				reqHeader.send_date = dt.formatGMT('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
				reqHeader.body = xmlRequest;

				String statusCode = sendRequestToKavi(reqHeader);

				wsLogs.add(createNewWSLog('updateKaviUsers', statusCode));

			}
		}
		insert wsLogs;

	}

	@future(callout=true)
	public static void createOrUpdateKaviUsersAccounts(String operation, Set<Id> newContactsIds){
		//PS to grant access to all licenses
		permissionset psID= [select id from permissionset where name = 'HL_UsersAccess'][0];
		List<PermissionSetAssignment> listPsa = new List<PermissionSetAssignment>();
		//New Code to Admit Internal Users
		Map<Id,User> newUsersMap = new Map<Id,User>();
		if (operation == 'create2'){

			Map<Id,User> newUsersMap1 = new Map<Id,User>([Select Id,ContactKaviId__c,Username,Title,FirstName,LastName,Phone,Fax,IsActive,City,MobilePhone,State,Country,Street,Email,PostalCode,Contact.Account.RecordTypeId,Contact.Account.Field_Head_Office__c,Contact.AccountId,Contact.Account.ParentId,Contact.Account.Parent.ParentId
			                                              From User 
			                                              Where ContactKaviId__c In:(newContactsIds)]);
			newUsersMap = newUsersMap1;
		}
		else{
			Map<Id,User> newUsersMap2 = new Map<Id,User>([Select Id,ContactKaviId__c,Username,Title,FirstName,LastName,Phone,Fax,IsActive,City,MobilePhone,State,Country,Street,Email,PostalCode,Contact.Account.RecordTypeId,Contact.Account.Field_Head_Office__c,Contact.AccountId,Contact.Account.ParentId,Contact.Account.Parent.ParentId
			                                              From User 
			                                              Where ContactId In:(newContactsIds)]);
			newUsersMap = newUsersMap2;
		}    

		List<Portal_Application_Right__c> portalAppRights = [Select Id,Kavi_user__c,ContactId__c
		                                                     From Portal_Application_Right__c 
		                                                     Where Contact__c In:(newContactsIds)              
		                                                     And   Right__c = 'Access Granted'
		                                                     And   Portal_Application__r.Name = 'Standards Setting Workspace'];

		Map<Id,Portal_Application_Right__c> contactRightsMap = new Map<Id,Portal_Application_Right__c>();

		for (Portal_Application_Right__c portalAppRight: portalAppRights)
			contactRightsMap.put(portalAppRight.ContactId__c,portalAppRight);

		Set<Id> newAccountsIds = new Set<Id>();

		Map<Id,Id> newRelationship = new Map<Id,Id>();
		List<ISSP_Web_Service_Log__c> wsLogs = new List<ISSP_Web_Service_Log__c>();
		Map<String,String> accountStatusMap = new Map<String,String>();

		for(User newUser :newUsersMap.values()){
			String accId = '';
			if (operation == 'create'){
				accId = retAccountId(newUser.Contact.AccountId,newUser.Contact.Account.RecordTypeId, newUser.Contact.Account.Field_Head_Office__c, newUser.Contact.Account.ParentId, newUser.Contact.Account.Parent.ParentId);
			}
			else accId = provisionKaviAccess.getFakeAccount().Id;
			newAccountsIds.add(accId);
			newRelationship.put(newUser.Id,accId);

		}

		if(operation == 'create' || operation == 'create2'){
			wsLogs.addAll(createOrUpdateKaviAccounts(newAccountsIds,accountStatusMap));
		}

		System.debug('VAMOS A VER QUE TIENE ' + accountStatusMap);
		for(User newUser :newUsersMap.values()){
			String accId = retAccountId(newUser.Contact.AccountId,newUser.Contact.Account.RecordTypeId, newUser.Contact.Account.Field_Head_Office__c, newUser.Contact.Account.ParentId, newUser.Contact.Account.Parent.ParentId);
			if(operation == 'update' || (accountStatusMap.containskey(accId) && accountStatusMap.get(accId)=='200') || operation =='create2'){
				String xmlBody = '';
				System.debug('ENTRO EN La CONDICION');
				for(String fieldApi :userFieldsList)
					xmlBody += notNull(fieldApi, newUser.get(fieldApi));

				String xmlRequest = '<?xml version="1.0" encoding="utf-8"?>'+
						'<Request xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
						xmlBody +
						notNull('EmailAddress', newUser.Email)+
						notNull('Zip', newUser.PostalCode)+
						notNull('Mobile', newUser.MobilePhone)+
						notNull('IsVisibleToGroups', true) +
						'</Request>';
				system.debug('xmlRequest: ' + xmlRequest);

				Blob targetBlob = Blob.valueOf(xmlRequest);
				Blob hash = Crypto.generateDigest('MD5', targetBlob);
				String content_md5 = EncodingUtil.base64Encode(hash);
				Datetime dt = Datetime.now();

				Request_Header reqHeader = new Request_Header();
				reqHeader.method = 'put'; 
				reqHeader.path = '/v1/person/'+(String.valueOf(newUser.Id)).substring(0,15);
				reqHeader.content_type = 'application/xml';
				reqHeader.content_md5 = content_md5;
				reqHeader.send_date = dt.formatGMT('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
				reqHeader.body = xmlRequest;
				System.Debug('This is the REQHEADER sent to KAVI:' + reqHeader);
				String statusCode = sendRequestToKavi(reqHeader);

				wsLogs.add(createNewWSLog('createOrUpdateKaviUsersAccounts', statusCode));

				if (newuser.ContactId != null) {
					if (statusCode.substring(0, 3) == '200' && contactRightsMap.containsKey(newUsersMap.get(newuser.Id).ContactId))
						contactRightsMap.get(newUsersMap.get(newuser.Id).ContactId).Kavi_user__c = true;
				}
				//Extension Code for Internal users
				if (newuser.ContactKaviId__c != null){
					if (statusCode.substring(0, 3) == '200' && contactRightsMap.containsKey(newUsersMap.get(newuser.Id).ContactKaviId__c))
						System.debug('KIKE ENTRO PARA ACTUALIZAR EL VALOR DE PAR DEL CAMPO KAVI_USER_C_');
					contactRightsMap.get(newUsersMap.get(newuser.Id).ContactKaviId__c).Kavi_user__c = true;
					System.debug('KIKE EL VALOR DEL RECORD DE PORTAL APPLICATION RIGHT: ' +  contactRightsMap.get(newUsersMap.get(newuser.Id).ContactKaviId__c).Kavi_user__c);
				}
			}
		}

		if(operation == 'create' || operation == 'create2'){
			wsLogs.addAll(createKaviRelationShip(newRelationship));
			update contactRightsMap.values();
		}

		try{
			insert wsLogs;
		} catch (DMLException e){
			for (ISSP_Web_Service_Log__c wslog: wsLogs) {
				wslog.addError('There was a problem updating this log');}
		}
	}

	//RN-ENHC0012059 grant and remove the permission set to the user
	@future(callout=true) 
	public static void addUserPSA(Set<Id> contactKaviAdd, String action){					
		permissionset psID= [select id from permissionset where name = 'HL_UsersAccess'][0];
		List<PermissionSetAssignment> listPsa = new List<PermissionSetAssignment>();
		List<PermissionSetAssignment> listRemovePsa = new List<PermissionSetAssignment>();
		List<User> userGrantPS = [SELECT id from User where ContactID in:contactKaviAdd];
		for(User u: userGrantPS){		
			listPsa.add(new PermissionSetAssignment (PermissionSetId = psID.id, AssigneeId = u.id));
		}
		if(!listPsa.isEmpty()){ 
			if(action == 'grant'){
				insert listPsa;
			}
		}
		if(action == 'remove'){
			listRemovePsa = [SELECT id from PermissionSetAssignment where AssigneeId in:userGrantPS and PermissionSetId =:psID.id];
            if(!listRemovePsa.isEmpty()){ 
				delete listRemovePsa;
            }
		}
	}


	public static List<ISSP_Web_Service_Log__c> createOrUpdateKaviAccounts(Set<Id> newAccountsIds,Map<String,String> accountStatusMap){

		List<Account> newAccounts = [Select Id,Name,Website,Email__c,BillingCity,Iso_State__r.ISO_Code__c,Inactive_Account__c,IATA_ISO_Country__r.ISO_Code__c,BillingStreet,BillingPostalCode 
		                             From Account 
		                             Where Id In:(newAccountsIds)];

		List<ISSP_Web_Service_Log__c> wsLogs = new List<ISSP_Web_Service_Log__c>();

		for(Account newAccount :newAccounts){
			String xmlBody = '';

			for(String fieldApi :accountFieldsMap.keyset()){
				xmlBody += notNull(accountFieldsMap.get(fieldApi), newAccount.get(fieldApi));
			}

			xmlBody += notNull('IsActive', !newAccount.Inactive_Account__c);

			String xmlRequest = '<?xml version="1.0" encoding="utf-8"?>'+
					'<Request xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
					xmlBody +
					notNull('State', newAccount.Iso_State__r.ISO_Code__c)+
					notNull('Country', newAccount.IATA_ISO_Country__r.ISO_Code__c)+
					'</Request>';
			system.debug('xmlRequest: ' + xmlRequest);

			Blob targetBlob = Blob.valueOf(xmlRequest);
			Blob hash = Crypto.generateDigest('MD5', targetBlob);
			String content_md5 = EncodingUtil.base64Encode(hash);
			Datetime dt = Datetime.now();

			Request_Header reqHeader = new Request_Header();
			reqHeader.method = 'put'; 
			reqHeader.path = '/v1/company/'+newAccount.Id;
			reqHeader.content_type = 'application/xml';
			reqHeader.content_md5 = content_md5;
			reqHeader.send_date = dt.formatGMT('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
			reqHeader.body = xmlRequest;

			String statusCode = sendRequestToKavi(reqHeader);

			accountStatusMap.put(String.valueof(newAccount.Id),statusCode.substring(0,3));

			wsLogs.add(createNewWSLog('createOrUpdateKaviAccounts', statusCode));
		}

		return wsLogs;
	}

	@future(callout=true)
	public static void createOrUpdateKaviAccountsFuture(Set<Id> newAccountsIds){

		List<Account> newAccounts = [Select Id,Name,Website,Email__c,BillingCity,Iso_State__r.ISO_Code__c,IATA_ISO_Country__r.ISO_Code__c,BillingStreet,BillingPostalCode 
		                             From Account 
		                             Where Id In:(newAccountsIds)];

		List<ISSP_Web_Service_Log__c> wsLogs = new List<ISSP_Web_Service_Log__c>();

		for(Account newAccount :newAccounts){
			String xmlBody = '';

			for(String fieldApi :accountFieldsMap.keyset())
				xmlBody += notNull(accountFieldsMap.get(fieldApi), newAccount.get(fieldApi));

			String xmlRequest = '<?xml version="1.0" encoding="utf-8"?>'+
					'<Request xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
					xmlBody +
					notNull('State', newAccount.Iso_State__r.ISO_Code__c)+
					notNull('Country', newAccount.IATA_ISO_Country__r.ISO_Code__c)+
					'</Request>';
			system.debug('xmlRequest: ' + xmlRequest);

			Blob targetBlob = Blob.valueOf(xmlRequest);
			Blob hash = Crypto.generateDigest('MD5', targetBlob);
			String content_md5 = EncodingUtil.base64Encode(hash);
			Datetime dt = Datetime.now();

			Request_Header reqHeader = new Request_Header();
			reqHeader.method = 'put'; 
			reqHeader.path = '/v1/company/'+newAccount.Id;
			reqHeader.content_type = 'application/xml';
			reqHeader.content_md5 = content_md5;
			reqHeader.send_date = dt.formatGMT('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
			reqHeader.body = xmlRequest;

			String statusCode = sendRequestToKavi(reqHeader);

			wsLogs.add(createNewWSLog('createOrUpdateKaviAccounts', statusCode));
		}

		insert wsLogs;
	}

	public static List<ISSP_Web_Service_Log__c> createKaviRelationShip(Map<Id,Id> newRelationship){

		List<ISSP_Web_Service_Log__c> wsLogs = new List<ISSP_Web_Service_Log__c>();

		Boolean IsCompanyContact = true;

		for(Id userId :newRelationship.keyset()){

			String xmlRequest = '<?xml version="1.0" encoding="utf-8"?>'+
					'<Request xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
					notNull('IsCompanyContact', IsCompanyContact)+
					'</Request>';
			system.debug('xmlRequest: ' + xmlRequest);

			Blob targetBlob = Blob.valueOf(xmlRequest);
			Blob hash = Crypto.generateDigest('MD5', targetBlob);
			String content_md5 = EncodingUtil.base64Encode(hash);
			Datetime dt = Datetime.now();

			Request_Header reqHeader = new Request_Header();
			reqHeader.method = 'put'; 
			reqHeader.path = '/v1/person/'+(String.valueOf(userId)).substring(0,15)+'/_company/'+newRelationship.get(userId);
			reqHeader.content_type = 'application/xml';
			reqHeader.content_md5 = content_md5;
			reqHeader.send_date = dt.formatGMT('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
			reqHeader.body = xmlRequest;

			String statusCode = sendRequestToKavi(reqHeader);

			wsLogs.add(createNewWSLog('createKaviRelationShip', statusCode));
		}

		return wsLogs;
	}

	@future(callout=true)
	public static void replaceKaviRelationShip(Map<Id,Id> newAccountByContactIdMap, Map<Id,Id> oldAccountByContactIdMap){

		List<User> newUsers = [Select Id,Username,Title,FirstName,LastName,Phone,Fax,IsActive,City,State,Country,Street,Email,ContactKaviId__c,PostalCode,Contact.AccountId
		                       From User 
		                       Where ContactId In:(newAccountByContactIdMap.keyset())
		                       OR ContactKaviId__c In:(newAccountByContactIdMap.keyset())
		                       ];

		Map<Id,Id> topAccountsMap = new Map<Id,Id>();
		for(Account acc :[Select Id,Parent.ParentId, Field_Head_Office__c,Location_Type__c,RecordTypeId From Account Where Id IN: newAccountByContactIdMap.values() Or Id IN: oldAccountByContactIdMap.values()]){
			String topAccId = retAccountId(acc.Id, acc.RecordTypeId, acc.Field_Head_Office__c, acc.ParentId, acc.Parent.ParentId);
			topAccountsMap.put(acc.Id, topAccId);
		}

		List<ISSP_Web_Service_Log__c> wsLogs = new List<ISSP_Web_Service_Log__c>();
		Set<Id> newAccountsIds = new Set<Id>();
		Map<Id,Id> newRelationship = new Map<Id,Id>();

		for(User newUser :newUsers){

			String xmlRequest = '<?xml version="1.0" encoding="utf-8"?>'+
					'<Request xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
					'</Request>';
			system.debug('xmlRequest: ' + xmlRequest);

			Blob targetBlob = Blob.valueOf(xmlRequest);
			Blob hash = Crypto.generateDigest('MD5', targetBlob);
			String content_md5 = EncodingUtil.base64Encode(hash);
			Datetime dt = Datetime.now();

			Request_Header reqHeader = new Request_Header();
			reqHeader.method = 'delete';
			//Code extension for Internal Users
			if (newUser.ContactKaviId__c != null){
				reqHeader.path = '/v1/person/'+(String.valueOf(newUser.Id)).substring(0,15)+'/_company/'+topAccountsMap.get(oldAccountByContactIdMap.get(newUser.ContactKaviId__c));
			}
			else {
				reqHeader.path = '/v1/person/'+(String.valueOf(newUser.Id)).substring(0,15)+'/_company/'+topAccountsMap.get(oldAccountByContactIdMap.get(newUser.ContactId));  
			}
			reqHeader.content_type = 'application/xml';
			reqHeader.content_md5 = content_md5;
			reqHeader.send_date = dt.formatGMT('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
			reqHeader.body = xmlRequest;

			//Code Extension for internal users
			if (newUser.ContactKaviId__c != null) {

				newAccountsIds.add(topAccountsMap.get(newAccountByContactIdMap.get(newUser.ContactKaviId__c)));
				newRelationship.put(newUser.Id,topAccountsMap.get(newAccountByContactIdMap.get(newUser.ContactKaviId__c)));

			}
			else {

				newAccountsIds.add(topAccountsMap.get(newAccountByContactIdMap.get(newUser.ContactId)));
				newRelationship.put(newUser.Id,topAccountsMap.get(newAccountByContactIdMap.get(newUser.ContactId)));  
			}


			String statusCode = sendRequestToKavi(reqHeader);

			wsLogs.add(createNewWSLog('replaceKaviRelationShip', statusCode));
		}

		wsLogs.addAll(createOrUpdateKaviAccounts(newAccountsIds,new Map<String,String>()));
		wsLogs.addAll(createKaviRelationShip(newRelationship));

		insert wsLogs;
	}

	private static String notNull(String fieldName, Object fieldValue){
		if(fieldValue!=null){
			String target = '&';
			String replacement = '&amp;';						
			String myString = String.valueOf(fieldValue).replace(target, replacement);											
			return '<' + fieldName + '>' + myString + '</' + fieldName + '>';						
		}
		return '';
	}

	public static ISSP_Web_Service_Log__c createNewWSLog(String wsMethod, String statusCode){
		ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
		newLog.Web_Service__c = 'ISSP_WS_KAVI';
		newLog.Method__c = wsMethod;
		newLog.System__c = 'Standards Setting Workspace';
		newLog.User__c = UserInfo.getUserId();
		newLog.Finished__c = System.now();
		newLog.Error_Code__c = statusCode.substring(0,3);
		newLog.Error_Message__c = statusCode.substring(3);

		if (newLog.Error_Code__c == '200')
			newLog.Success__c = true;

		return newLog;
	}

	public static String sendRequestToKavi(Request_Header reqHeader){
		String stringToSign;
		if (reqHeader.method=='put')
			stringToSign = 'method='+ reqHeader.method + '\n' 
			+ 'path=' + reqHeader.path +'\n'
			+ 'content-md5: ' + reqHeader.content_md5 + '\n'
			+ 'content-type: ' + reqHeader.content_type + '\n'
			+ 'date: ' + reqHeader.send_date + '\n'
			+ 'x-kavi-site: ' + X_KAVI_SITE + '\n';          
		else
			stringToSign = 'method='+ reqHeader.method + '\n' 
			+ 'path=' + reqHeader.path +'\n'
			+ 'date: ' + reqHeader.send_date + '\n'
			+ 'x-kavi-site: ' + X_KAVI_SITE + '\n';

		system.debug('stringToSign: \n' + stringToSign);
		Blob secretkey = Blob.valueOf(CLIENT_SECRET);
		Blob hmac = Crypto.generateMac('HMacSHA1', Blob.valueOf(stringToSign), secretkey);
		string signature = EncodingUtil.base64Encode(hmac);
		system.debug('signature: ' + signature);

		string authHeader = 'AuthKaviAPI-SHA1 ' + CLIENT_KEY + ':' + signature;

		HttpRequest req = new HttpRequest();
		req.setMethod(reqHeader.method.touppercase());
		req.setEndpoint(ENDPOINT+reqHeader.path); 
		if (reqHeader.method=='put'){
			req.setHeader('content-type', reqHeader.content_type);
			req.setHeader('content-md5', reqHeader.content_md5);
			req.setBody(reqHeader.body);
		}
		req.setHeader('authorization', authHeader);
		req.setHeader('x-kavi-site', X_KAVI_SITE);
		req.setHeader('date', reqHeader.send_date);


		Http http = new Http();
		try{
			system.debug('authorization: ' + req.getHeader('authorization'));
			system.debug('content-type: ' + req.getHeader('content-type'));
			system.debug('content-md5: ' + req.getHeader('content-md5'));
			system.debug('x-kavi-site: ' + req.getHeader('x-kavi-site'));
			system.debug('date: ' + req.getHeader('date'));

			HTTPResponse res = http.send(req);
			system.debug(res.toString());
			system.debug('response body '+res.getBody());
			return String.valueOf(res.getStatusCode())+res.getBody();    
		}
		catch(Exception e){            
			system.debug('### display exception : '+e);
			return '404'+e.getMessage();
		}

	}
}
