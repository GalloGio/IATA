public with sharing class ISSP_WS_SIS_Callout_CreateUser {

	public static final String ERROR_FEDERATIONID_DUPLICATE = 'SISERR_15003'; // FederationID failed duplicate check
	public static final list<String> LIST_FIELD_NAMES = new list<String>{};
	public static String TEST_RESPONSE='';

	public class RequestData {
		String IcpUserName;
		String IcpPassword;
		String SISMemberID;
		String FederationID;
		String FirstName;
		String LastName;
		String EmailAddress;
		String UserType;

		public String toXML() {
			String xml = '<IcpRequestMessage>';
			xml += '<IcpUserName>' + this.IcpUserName + '</IcpUserName>';
			xml += '<IcpPassword>' + this.IcpPassword + '</IcpPassword>';
			xml += '<SISMemberID>' + this.SISMemberID + '</SISMemberID>';
			xml += '<FederationID>' + this.FederationID + '</FederationID>';
			xml += '<FirstName>' + this.FirstName + '</FirstName>';
			xml += '<LastName>' + this.LastName + '</LastName>';
			xml += '<EmailAddress>' + this.EmailAddress + '</EmailAddress>';
			xml += '<UserType>' + this.UserType + '</UserType>';
			xml += '</IcpRequestMessage>';
			return xml;
		}
	}

	public class ResponseData {
		public Boolean IsSuccess;
		public String ErrorCode;
		public String ErrorDescription;
		public String requestString;
		public Id userId;
		public Id contactId;

		public ResponseData(Exception e, String requestString){
			this.IsSuccess = false;
			this.ErrorCode = e.getTypeName();
			this.ErrorDescription = e.getMessage();
			this.requestString = requestString;
		}

		public ResponseData(String xmlString, String requestString) {
			try {
				this.requestString = requestString;
				Dom.Document doc = new Dom.Document();
				doc.load(xmlString);
				map<String,String> mapValues = new map<String,String>();
				for (Dom.XmlNode node : doc.getRootElement().getChildElements()) {
					mapValues.put(node.getName(), node.getText());
				}
				this.IsSuccess = Boolean.valueOf(mapValues.get('IsSuccess'));
				this.ErrorCode = mapValues.get('ErrorCode');
				this.ErrorDescription = mapValues.get('ErrorDescription');
			} catch (Exception e) {
				e.setMessage('Error parsing response ' + xmlString);
			}
		}
	}

	public static ResponseData createUser(User user, Contact contact) {
		String requestString = '';
		try {
			//create request
			RequestData request = new RequestData();
			request.IcpUserName = ISSP_WS_SIS_Callout_Common.getUser();
			request.IcpPassword = ISSP_WS_SIS_Callout_Common.getPass();
			request.SISMemberID = nvl(contact.Account.SIS_ID__c);
			request.FederationID = nvl(user.FederationIdentifier);
			request.FirstName = ISSP_WS_SIS_Callout_Common.cleanSpecialChars(contact.FirstName);
			request.LastName = ISSP_WS_SIS_Callout_Common.cleanSpecialChars(contact.LastName);
			request.EmailAddress = nvl(contact.Email);
			request.UserType = nvl(ISSP_WS_SIS_Callout_Common.MAP_USER_TYPES.get(contact.SIS_Contact_Type__c));
			requestString = request.toXML();
			System.debug(requestString);
			//make ws call
			ISSP_WS_SIS_Callout.IcpWsInterfaceSoap ws = ISSP_WS_SIS_Callout_Common.getWSInterface();
			String xmlResponse = Test.isRunningTest()? TEST_RESPONSE: ws.createUser(requestString);

			//prepare response
			ResponseData response = new ResponseData(xmlResponse, requestString);
			response.userId = user==null? null: user.Id;
			response.contactId = contact==null? null: contact.Id;
			return response;

		} catch (Exception e) {
			ResponseData response = new ResponseData(e, requestString);
			response.userId = user==null? null: user.Id;
			response.contactId = contact==null? null: contact.Id;
			return response;
		}
	}

	public static Id makeCall(ISSP_Web_Service_Log__c log) {
		String requestString = log.Input_Description__c;

		//make ws call
		ISSP_WS_SIS_Callout.IcpWsInterfaceSoap ws = ISSP_WS_SIS_Callout_Common.getWSInterface();
		String xmlResponse = Test.isRunningTest()? TEST_RESPONSE: ws.createUser(requestString);

		//prepare response
		ResponseData response = new ResponseData(xmlResponse, requestString);
		response.userId = log.User__c;
		response.contactId = log.Contact__c;
	
		//insert log
		ISSP_Web_Service_Log__c newLog = createLog(response);
		insert newLog;

		return newLog.Id;
	}

	public static ISSP_Web_Service_Log__c createLog(ResponseData responseData) {
		ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
		newLog.Web_Service__c = 'ISSP_WS_SIS_Callout';
		newLog.Method__c = 'CreateUser';
		newLog.System__c = 'SIS';
		newLog.Login_Ip__c = ISSP_WS_SIS_Common.getLoginIP();
		newLog.Input_Description__c = responseData.requestString;
		newLog.Success__c = responseData.IsSuccess;
		newLog.Error_Code__c = responseData.ErrorCode;
		newLog.Error_Message__c = responseData.ErrorDescription;
		newLog.Finished__c = system.now();
		newLog.User__c = responseData.userId;
		newLog.Contact__c = responseData.contactId;
		return newLog;
	}

	private static String nvl(String str) {
		return str==null?'':str;
	}
}
