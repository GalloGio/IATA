public class IECEBC_ExceptionHandler {

	// exception classes
	public class UnexpectedResponse_Exception extends Exception{
	}

	public class Other_Exception extends Exception{
		public String ErrorCode {get; set;}
		public String ErrorMessage {get; set;}
	}

	public class InvalidPlaceHolder_Exception extends Exception {
		public List<String> AttributeNames {get; set;}
		public String ErrorCode {get; set;}
		public String ErrorMessage {get; set;}
	}

	// exception records list
	private static list<IEC_Error_Log__c> exceptionList = new list<IEC_Error_Log__c>();

	// add exception to list
	public static void addException (String message, Exception ex)
	{
		IEC_Error_Log__c log = new IEC_Error_Log__c(
			Displayed_Message__c = message,
		   	Extra_Information__c = '' + ex.getLineNumber(),
			Errror_Message__c = ex.getMessage(),
			IATACODE__c = '',
			Source__c = '' + ex.getCause(),
			Stack_Trace__c = ex.getStackTraceString(),
			Type__c = 'Error'
		);
		exceptionList.add(log);
	}

	// add exception to list
	public static void addInvalidPlaceHolderException (String message, InvalidPlaceHolder_Exception ex)
	{
		IEC_Error_Log__c log = new IEC_Error_Log__c(
			Displayed_Message__c = message,
			Extra_Information__c = 'Error in the following merge fields names: ',
			Errror_Message__c = ex.getMessage(),
			IATACODE__c = '',
			Source__c = '' + ex.getCause(),
			Stack_Trace__c = ex.getStackTraceString(),
			Type__c = 'Error'
		);
		for(String a : ex.AttributeNames){
			log.Extra_Information__c += a;
	   	}
		exceptionList.add(log);
	}

	// save exception to SFDC
	public static void saveExceptionLog()
	{
		if(!exceptionList.isEmpty())
		{
			insert(exceptionList);
		}
   	}
}
