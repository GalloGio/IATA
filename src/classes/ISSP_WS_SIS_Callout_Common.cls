global with sharing class ISSP_WS_SIS_Callout_Common {
	private static final Boolean IS_SANDBOX{
		get{
			if(IS_SANDBOX == null) IS_SANDBOX = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
			return IS_SANDBOX;
		}
	}

	private static final String SIS_HOST_PROD;
	private static final String SIS_USER_PROD;
	private static final String SIS_PASSWD_PROD;
	private static final String SIS_HOST_QA;
	private static final String SIS_USER_QA;
	private static final String SIS_PASSWD_QA;
	//checks in Custom setting ISSP CS if the value 'SIS_WebService_ON' is set to true
	public static final Boolean SIS_CALLOUTS_ENABLED;

	static {
		try {
			SIS_HOST_PROD = ISSP_CS__c.getInstance('SIS_WebService_HOST_PROD').Value__c;
			SIS_USER_PROD = ISSP_CS__c.getInstance('SIS_WebService_USER_PROD').Value__c;
			SIS_PASSWD_PROD = ISSP_CS__c.getInstance('SIS_WebService_PASS_PROD').Value__c;
		} catch (Exception e) {
			SIS_HOST_PROD = '';
			SIS_USER_PROD = '';
			SIS_PASSWD_PROD = '';
		}
		try {
			SIS_HOST_QA = ISSP_CS__c.getInstance('SIS_WebService_HOST_QA').Value__c;
			SIS_USER_QA = ISSP_CS__c.getInstance('SIS_WebService_USER_QA').Value__c;
			SIS_PASSWD_QA = ISSP_CS__c.getInstance('SIS_WebService_PASS_QA').Value__c;
		} catch (Exception e) {
			SIS_HOST_QA = '';
			SIS_USER_QA = '';
			SIS_PASSWD_QA = '';
		}
		try {
			SIS_CALLOUTS_ENABLED = Boolean.valueOf(ISSP_CS__c.getInstance('SIS_WebService_ON').Value__c);
		} catch (Exception e) {
			SIS_CALLOUTS_ENABLED = false;
		}
	}


	public static final map<String,String> MAP_USER_TYPES = new map<String,String>{
		'Super User' => 'S',
		'User'=> 'R'
	};

	public static ISSP_WS_SIS_Callout.IcpWsInterfaceSoap getWSInterface() {
		ISSP_WS_SIS_Callout.IcpWsInterfaceSoap ws = new ISSP_WS_SIS_Callout.IcpWsInterfaceSoap();
		ws.endpoint_x = IS_SANDBOX? SIS_HOST_QA: SIS_HOST_PROD;
		ws.timeout_x = 120000;
		return ws;
	}

	public static String getUser() {
		return IS_SANDBOX? SIS_USER_QA: SIS_USER_PROD;
	}

	public static String getPass() {
		return IS_SANDBOX? SIS_PASSWD_QA: SIS_PASSWD_PROD;
	}

	public static String addressToString(Address address) {
		String str = nvl(address.getStreet()).normalizeSpace();
		return cleanSpecialChars(str);
	}

	public static String cleanSpecialChars(String str) {
		return AMS_Utils.cleanSpecialChars(str).replace('&',' And ').normalizeSpace();
	}

	private static String nvl(String str) {
		return str==null?'':str;
	}

	public class WSException extends Exception {}

	/**
	 * Retry the same call as in the incoming log and return the new log Id
	 */
	webservice static Id retryCall(Id logId) {
		try {
			ISSP_Web_Service_Log__c log = [
				SELECT Id, System__c, Web_Service__c, Method__c, Error_Code__c, Error_Message__c, Input_Description__c, Account__c, User__c, Contact__c
				FROM ISSP_Web_Service_Log__c
				WHERE Id = :logId
				AND System__c = 'SIS'
				AND Web_Service__c = 'ISSP_WS_SIS_Callout'];

			if (log.Method__c == 'CreateAccount') {
				return ISSP_WS_SIS_Callout_CreateAccount.makeCall(log);
			}
			if (log.Method__c == 'UpdateAccount') {
				return ISSP_WS_SIS_Callout_UpdateAccount.makeCall(log);
			}
			if (log.Method__c == 'ActivateUser') {
				return ISSP_WS_SIS_Callout_ActivateUser.makeCall(log,true);
			}
			if (log.Method__c == 'DeactivateUser') {
				return ISSP_WS_SIS_Callout_ActivateUser.makeCall(log,false);
			}
			if (log.Method__c == 'CreateUser') {
				return ISSP_WS_SIS_Callout_CreateUser.makeCall(log);
			}
			if (log.Method__c == 'UpdateUser') {
				return ISSP_WS_SIS_Callout_UpdateUser.makeCall(log);
			}

			throw new WSException('No retry function was found for ' + log.Web_Service__c + '.' + log.Method__c);

		} catch (Exception e) {
			throw new WSException(e.getMessage());
		}
	}
}
