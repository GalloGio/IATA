public class ANG_TechnicalLogHelper {
	
	public static Technical_Logs__c createTechnicalLog(String operation, Exception e, String log) {
		return createTechnicalLog(operation, (e.getMessage() + '\n' + e.getStackTraceString()), log);
	}

	public static Technical_Logs__c createTechnicalLog(String operation, String status, String log) {
		return new Technical_Logs__c(Operation__c = operation, Status__c = status.left(254), Log__c = log);
	}
	
	public static void commitTechnicalLogs(Technical_Logs__c technicalLogs) {
		try {
			System.debug(LoggingLevel.INFO, '____ [cls ANG_TechnicalLogHelper - commitTechnicalLogs] technicalLogs: ' + technicalLogs);
			insert technicalLogs;
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, '____ [cls ANG_TechnicalLogHelper - commitTechnicalLogs] Exception: '
				+ e.getMessage());
			System.debug(LoggingLevel.ERROR, '____ [cls ANG_TechnicalLogHelper - commitTechnicalLogs] Exception Stacktrace: '
				+ e.getStackTraceString());
		}
	}
}
