/**

	Project: eCommerce Enhancements
	   File: IEC_Trace.cls
	Subject: Utility class to handle Trace requests for IEC Application.
	History: 2017-05-02, asantos, Initial Release.
             2017-05-07, asantos, Added the export to CSV functionality.

*/
public with sharing class IEC_Trace {
	public static final Integer LOG_LEVEL_DEBUG = 1000;
	public static final Integer LOG_LEVEL_INFO = 1;
	public static final Integer LOG_LEVEL_WARNING = 10;
	public static final Integer LOG_LEVEL_ERROR = -1;

	private static final String DEFAULT_TIMESTAMP_FORMAT = 'yyyy-MM-dd HH:mm:ss.SSS z';
	
	private static final Integer MAX_MESSAGE_LENGTH = 512;
	private static final Integer MAX_INPUT_LENGTH = 4096;
	private static final Integer MAX_OUTPUT_LENGTH = 4096;
	private static final Integer MAX_EXCEPTION_MESSAGE_LENGTH = 512;
	private static final Integer MAX_EXCEPTION_STACK_TRACE_LENGTH = 1024;
	
	private static IEC_Trace_Setting__c traceSetting = initializeTraceSetting();

	private static final Map<Integer,String> traceTypeMap = new Map<Integer,String> {
		LOG_LEVEL_DEBUG 	=> 'Debug',
		LOG_LEVEL_INFO		=> 'Info',
		LOG_LEVEL_WARNING	=> 'Warning',
		LOG_LEVEL_ERROR		=> 'Error'
	};

	public static List<TraceItem> traceBuffer = new List<TraceItem>();

	public static List<TraceItem> getTraceItemList() {
		return traceBuffer;
	}

	public static String exportTrace() {
		String content = getExportTraceHeader() + '\n';
		
		for (TraceItem item : traceBuffer) {
			content += item.getCsv() + '\n';
		}

		return EncodingUtil.base64Encode(Blob.valueOf(content));
	}

	public static String getTraceAsString() {
		String content = getExportTraceHeader() + '\n';
		
		for (TraceItem item : traceBuffer) {
			content += item.getCsv() + '\n';
		}

		return content;
	}

	public static String getTraceAsHTML() {
		String content = '<ul>';

		for (TraceItem item : traceBuffer) {
			content += '<li>' + item.getHtml() + '</li>\n';
		}

		content += '</ul>';

		return content;
	}

	@testVisible
	private static Boolean isNull(String param) {
		if (param == null) {
			return true;
		} else {
			return false;
		}
	}

	public static Boolean isTraceEnabled() {
		if (traceSetting == null) {
			traceSetting = initializeTraceSetting();
		}

		if (traceSetting != null) {
			return traceSetting.Is_Enabled__c;
		} else {
			return false;
		}
	}

	public static String getExportTraceHeader() {
		String result = '';
		List<String> fieldList = new List<String>();

		fieldList.add(quote('traceType'));
		fieldList.add(quote('timestamp'));
		fieldList.add(quote('message'));
		fieldList.add(quote('isException'));
		fieldList.add(quote('input'));
		fieldList.add(quote('output'));
		fieldList.add(quote('exceptionMessage'));
		fieldList.add(quote('exceptionStackTrace'));
		fieldList.add(quote('sessionId'));
		fieldList.add(quote('userId'));
		fieldList.add(quote('userType'));
		fieldList.add(quote('contactId'));
		fieldList.add(quote('username'));
		fieldList.add(quote('userEmail'));
		fieldList.add(quote('userFullName'));
		fieldList.add(quote('profileId'));
		fieldList.add(quote('roleId'));

		result = String.join(fieldList, ',');

		return result;
	}


	public static String quote(String arg) {
		return '"' + arg + '"';
	}

	public static String quote(Boolean arg) {
		return '"' + (arg != null && arg == true ? 'true' : 'false') + '"';
	}

	public class TraceItem {
		public String sessionId { get; set; }
		public String traceType { get; set; }
		public String userId { get; set; }
		public String userType { get; set; }
		public String contactId { get; set; }
		public String username { get; set; }
		public String userEmail { get; set; }
		public String userFullName { get; set; }
		public String profileId { get; set; }
		public String roleId { get; set; }
		public String message { get; set; }
		public String timestamp { get; set; }
		public Boolean isException { get; set; }
		public String input { get; set; }
		public String output { get; set; }
		public String exceptionMessage { get; set; }
		public String exceptionStackTrace { get; set; }

		public String getCsv() {
			String result = '';
			List<String> fieldList = new List<String>();

			fieldList.add(quote(traceType));
			fieldList.add(quote(timestamp));
			fieldList.add(quote(message));
			fieldList.add(quote(isException));
			fieldList.add(quote(input));
			fieldList.add(quote(output));
			fieldList.add(quote(exceptionMessage));
			fieldList.add(quote(exceptionStackTrace));
			fieldList.add(quote(sessionId));
			fieldList.add(quote(userId));
			fieldList.add(quote(userType));
			fieldList.add(quote(contactId));
			fieldList.add(quote(username));
			fieldList.add(quote(userEmail));
			fieldList.add(quote(userFullName));
			fieldList.add(quote(profileId));
			fieldList.add(quote(roleId));

			result = String.join(fieldList, ',');

			return result;
		}

		public String getHtml() {
			String html = '';

			html += traceType + ',&nbsp;ContactId ' + contactId + ',&nbsp;' + timestamp + ',&nbsp;' + message + ', input=' + input + ',&nbsp;output=' + output + ',&nbsp;exceptionMessage=' + exceptionMessage + ',&nbsp;exceptionStackTrace=' + exceptionStackTrace;

			return html;
		}
	}

	/**

		Sample Usage:

				IEC_Trace.logDebug(null, 'Hello World',null, null);

				IEC_Trace.logInfo(null, 'Info me', null, null);

				IEC_Trace.logWarning(null, 'Warning me', null, null);

				try {
					// ... some DML or apex code that throws exception
				} catch (Exception e) {
					IEC_Trace.logError(null, 'Exception', null, null, e);
				}

	*/


	/**
		logDebug() - log a debug message.


	*/
	public static void logDebug(Id contactId, String message, String input, String output) {
		commonLog(LOG_LEVEL_DEBUG, contactId, message, input, output, null);
	}

	/**
		logInfo() - log an info message.


	*/
	public static void logInfo(Id contactId, String message, String input, String output) {
		commonLog(LOG_LEVEL_INFO, contactId, message, input, output, null);
	}

	/**
		logWarning() - log a warning message.


	*/
	public static void logWarning(Id contactId, String message, String input, String output) {
		commonLog(LOG_LEVEL_WARNING, contactId, message, input, output, null);
	}

	/**
		logError() - log an error message.


	*/
	public static void logError(Id contactId, String message, String input, String output, Exception exceptionCaught) {
		commonLog(LOG_LEVEL_ERROR, contactId, message, input, output, exceptionCaught);
	}

	@testVisible
	private static IEC_Trace_Setting__c initializeTraceSetting() {
		IEC_Trace_Setting__c setting = IEC_Trace_Setting__c.getInstance();

		if (setting.Timestamp_Format__c == null) {
			setting.Timestamp_Format__c = DEFAULT_TIMESTAMP_FORMAT;
		}

		return setting;
	}

	@testVisible
	private static void commonLog(
		Integer logLevel,
		Id contactId,
		String message,
		String input,
		String output,
		Exception exceptionCaught
	) {
		try {
			if (isLogLevelActive(logLevel) == true) {			
				String traceMessage = message;
				String traceExceptionCaughtMessage;
				String traceExceptionCaughtStackTrace;
				Datetime traceDatetime = System.now();
				String traceTimestamp;

				if (exceptionCaught != null) {
					traceExceptionCaughtMessage = exceptionCaught.getMessage();
					traceExceptionCaughtStackTrace = exceptionCaught.getStackTraceString();
				}

				if (message != null && message.length() > MAX_MESSAGE_LENGTH) {
					traceMessage = message.substring(0, MAX_MESSAGE_LENGTH);
				}

				if (traceExceptionCaughtMessage != null && traceExceptionCaughtMessage.length() > MAX_EXCEPTION_MESSAGE_LENGTH) {
					traceExceptionCaughtMessage = traceExceptionCaughtMessage.substring(0, MAX_EXCEPTION_MESSAGE_LENGTH);
				}

				if (traceExceptionCaughtStackTrace != null && traceExceptionCaughtStackTrace.length() > MAX_EXCEPTION_STACK_TRACE_LENGTH) {
					traceExceptionCaughtStackTrace = traceExceptionCaughtStackTrace.substring(0, MAX_EXCEPTION_STACK_TRACE_LENGTH);
				}

				traceTimestamp = traceDatetime.format(traceSetting.Timestamp_Format__c);

				TraceItem trace = new TraceItem();

				trace.sessionId				= UserInfo.getSessionId();
				trace.traceType				= traceTypeMap.get(logLevel);
				trace.userId 				= UserInfo.getUserId();
				trace.userType				= UserInfo.getUserType();
				trace.contactId				= contactId;
				trace.userEmail				= UserInfo.getUserEmail();
				trace.userFullName 			= UserInfo.getName();
				trace.username 				= UserInfo.getUserName();
				trace.profileId 			= UserInfo.getProfileId();
				trace.roleId 				= UserInfo.getUserRoleId();
				trace.message 				= traceMessage;
				trace.timestamp 			= traceTimestamp;
				trace.isException			= exceptionCaught != null;
				trace.input 				= input;
				trace.output 				= output;
				trace.exceptionMessage 		= traceExceptionCaughtMessage;
				trace.exceptionStackTrace 	= traceExceptionCaughtStackTrace;

				addTrace(trace);
			} // else is discarded
		} catch (Exception e) {
			// Ignore failures of this method
			System.debug('IEC_Trace.commonLog: Exception Caught: ' + e.getMessage());
		}
	}

	public static Boolean isErrorActive {
		get {
			return isLogLevelActive(LOG_LEVEL_ERROR);
		}
	}

	public static Boolean isWarningActive {
		get {
			return isLogLevelActive(LOG_LEVEL_WARNING);	
		}
	}

	public static Boolean isInfoActive {
		get {
			return isLogLevelActive(LOG_LEVEL_INFO);	
		}
	}

	public static Boolean isDebugActive {
		get {
			return isLogLevelActive(LOG_LEVEL_DEBUG);
		}
	}

	@testVisible
	private static Boolean isLogLevelActive(Integer level) {
		System.debug('UserId: ' + UserInfo.getUserId() + ', Level: ' + level + ', TraceEnabled: ' + traceSetting.Is_Enabled__c + ', TraceDebug: ' + traceSetting.Trace_Debug__c + ', TraceInfo: ' + traceSetting.Trace_Info__c + ', TraceWarning: ' + traceSetting.Trace_Warning__c + ', TraceError: ' + traceSetting.Trace_Error__c);

		if (traceSetting.Is_Enabled__c == true) {
			if (level == LOG_LEVEL_DEBUG && traceSetting.Trace_Debug__c) {
				return true;
			} else if (level == LOG_LEVEL_INFO && traceSetting.Trace_Info__c) {
				return true;
			} else if (level == LOG_LEVEL_WARNING && traceSetting.Trace_Warning__c) {
				return true;
			} else if (level == LOG_LEVEL_ERROR && traceSetting.Trace_Error__c) {
				return true;
			}
		}

		return false;
	}
	
	@testVisible
	private static void addTrace(TraceItem traceItem) {
		if (traceItem != null) {
			traceBuffer.add(traceItem);
		}
	}
}