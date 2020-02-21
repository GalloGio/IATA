/**
  * Description: Utility class to handle error messages and log them into a custom object for further analysis
  * Author: Samy Saied
  * Version: 1.0
  * History:
  */
public with sharing class IECErrorLogger {

	/**
	 * Logs an error record with all details as much as possible
	 * @param idContact: Id of the related contact that generated this error
	 * @param DisplayedMessage: Displayed message to the user if applicable
	 * @param ErrrorMessage: The real error message behind the displayed message, like exception error message
	 * @param ExtraInformation: Any supporting information that can be used to help trace the issue, like variables passed to a function, or Ids of records tryping to update
	 * @param Source: Origin of the error, class, visualforce, or trigger name
	 * @param StackTrace: Full stack trace of error if captured an exception
	 */
	public static void logError(Id idContact, String DisplayedMessage, String ErrorMessage, String ExtraInformation, String Source, String StackTrace) {

		// check if displayed message exceed length of field
		if (String.isNotBlank(DisplayedMessage) && DisplayedMessage.length() > 255) {
			if (ExtraInformation == null)
				ExtraInformation = '';
			ExtraInformation += ' Extra displayed message: ' + DisplayedMessage.substring(255);
			DisplayedMessage = DisplayedMessage.substring(0, 255);
		}

		// check if error message exceed length of field
		if (String.isNotBlank(ErrorMessage) && ErrorMessage.length() > 255) {
			if (ExtraInformation == null)
				ExtraInformation = '';
			ExtraInformation += ' Extra Error message: ' + ErrorMessage.substring(255);
			ErrorMessage = ErrorMessage.substring(0, 255);
		}

		insert new IEC_Error_Log__c(
			Contact__c = idContact
			, Displayed_Message__c = DisplayedMessage
			, Errror_Message__c = ErrorMessage
			, Extra_Information__c = ExtraInformation
			, Source__c = Source
			, Stack_Trace__c = StackTrace
			, Type__c = 'Error'
		);
	}

	/**
	 * Logs and return an error record with all details as much as possible
	 * @param DisplayedMessage: Displayed message to the user if applicable
	 * @param ErrrorMessage: The real error message behind the displayed message, like exception error message
	 * @param ExtraInformation: Any supporting information that can be used to help trace the issue, like variables passed to a function, or Ids of records tryping to update
	 * @param Source: Origin of the error, class, visualforce, or trigger name
	 * @param StackTrace: Full stack trace of error if captured an exception
	 */
	public static IEC_Error_Log__c logBatchError(String DisplayedMessage, String ErrorMessage, String ExtraInformation, String Source, String StackTrace) {

		// check if displayed message exceed length of field
		if (String.isNotBlank(DisplayedMessage) && DisplayedMessage.length() > 255) {
			if (ExtraInformation == null)
				ExtraInformation = '';
			ExtraInformation += ' Extra displayed message: ' + DisplayedMessage.substring(255);
			DisplayedMessage = DisplayedMessage.substring(0, 255);
		}

		// check if error message exceed length of field
		if (String.isNotBlank(ErrorMessage) && ErrorMessage.length() > 255) {
			if (ExtraInformation == null)
				ExtraInformation = '';
			ExtraInformation += ' Extra Error message: ' + ErrorMessage.substring(255);
			ErrorMessage = ErrorMessage.substring(0, 255);
		}

		return new IEC_Error_Log__c(
			Displayed_Message__c = DisplayedMessage
			, Errror_Message__c = ErrorMessage
			, Extra_Information__c = ExtraInformation
			, Source__c = Source
			, Stack_Trace__c = StackTrace
			, Type__c = 'Error'
		);
	}

	/**
	 * Logs an info record with all details as much as possible
	 * @param idContact: Id of the related contact that generated this error
	 * @param DisplayedMessage: Displayed message to the user if applicable
	 * @param ErrrorMessage: The real error message behind the displayed message, like exception error message
	 * @param ExtraInformation: Any supporting information that can be used to help trace the issue, like variables passed to a function, or Ids of records tryping to update
	 * @param Source: Origin of the error, class, visualforce, or trigger name
	 * @param StackTrace: Full stack trace of error if captured an exception
	 */
	public static void logInfo(Id idContact, String DisplayedMessage, String InfoMessage, String ExtraInformation, String Source) {

		// check if displayed message exceed length of field
		if (String.isNotBlank(DisplayedMessage) && DisplayedMessage.length() > 255) {
			if (ExtraInformation == null)
				ExtraInformation = '';
			ExtraInformation += ' Extra displayed message: ' + DisplayedMessage.substring(255);
			DisplayedMessage = DisplayedMessage.substring(0, 255);
		}

		// check if info message exceed length of field
		if (String.isNotBlank(InfoMessage) && InfoMessage.length() > 255) {
			if (ExtraInformation == null)
				ExtraInformation = '';
			ExtraInformation += ' Extra Info message: ' + InfoMessage.substring(255);
			InfoMessage = InfoMessage.substring(0, 255);
		}

		insert new IEC_Error_Log__c(
			Contact__c = idContact
			, Displayed_Message__c = DisplayedMessage
			, Errror_Message__c = InfoMessage
			, Extra_Information__c = ExtraInformation
			, Source__c = Source
			, Stack_Trace__c = null
			, Type__c = 'Info'
		);
	}

	/**
	 * Convert Upsert Errors into an array of Error Log
	 * @param lstUpsertResult: List of upsert results
	 * @param Source: Origin of the error, class, visualforce, or trigger name
	 */
	public static List<IEC_Error_Log__c> captureDMLError(List<Sobject> lstUpsertObjects, List<Database.UpsertResult> lstUpsertResult, String Source, List<String> lstColumnName, List<List<String>> lstColumnData) {
		if (lstUpsertResult == null || lstUpsertResult.size() == 0)
			return null;

		List<IEC_Error_Log__c> lstErrors = new List<IEC_Error_Log__c>();
		integer i = 0, j = 0;
		for (Database.UpsertResult result : lstUpsertResult) {
			if (!result.isSuccess()) {
				IEC_Error_Log__c error = new IEC_Error_Log__c(
					Errror_Message__c = getErrorString(result.getErrors())
					, Source__c = Source
					, Type__c = 'Error'
				);
				if (!lstColumnName.isEmpty()) {
					j = 0;
					error.Extra_Information__c = '';
					for (String col : lstColumnName) {
						error.Extra_Information__c += ', ' + col + ': ' + lstColumnData.get(j).get(i);
						j++;
					}
					error.Extra_Information__c = error.Extra_Information__c.substring(2);
				}
				lstErrors.add(error);
			}

			i++;
		}

		return lstErrors.size() > 0 ? lstErrors : null;
	}

	/**
	 * Convert Array of Database errors into a string
	 * @param dbErrors: array of database errors
	 */
	private static String getErrorString(Database.Error [] dbErrors) {
		if (dbErrors == null) return null;

		String sOutput = '';
		for (Database.Error error : dbErrors) {
			sOutput += ', ' + String.format('{0}: {1}: {2}', new String[] {IECUtil.ArrayToString(error.getFields()), error.getMessage()});
		}

		return (sOutput.length() == 0) ? null : sOutput.substring(2);
	}


	/****************************************************************************************************
		Created by Thai 2016-02-19
			Log an error for an Apex method
	****************************************************************************************************/
	public static void logApexError(String strClassAndMethod, String strData, String strError)
	{
		logApexError(strClassAndMethod, strData, strError, false);
	}
	public static void logApexError(String strClassAndMethod, String strData, String strError, Boolean notifySAP)
	{
		try
		{
			IEC_Error_Log__c log = new IEC_Error_Log__c(Type__c='Error', Source__c=strClassAndMethod, Data__c=strData, Extra_Information__c=strError);
			insert log;
			sendEmailToSupport(log.Id, strClassAndMethod, strData, strError, null, notifySAP);
		}
		catch (Exception e)
		{
			TransformationHelper.sendEmailSupport('IECErrorLogger.logApexError error at ' + system.now()
												, '********** Apex Class/Method **********\n' + strClassAndMethod + '\n'
												+ '********** Input Data **********\n' + strData + '\n'
												+ '********** Input Error **********\n' + strError + '\n'
												+ '********** Stack **********\n' + e.getStackTraceString() + '\n'
												+ '********** Error **********\n'  + e.getMessage());
		}
	} //*** end of "logApexError"


	/****************************************************************************************************
		Created by Thai 2016-02-19
			Log an exception for an Apex method
	****************************************************************************************************/
	public static void logApexException(String strClassAndMethod, String strData, String strError, String strStack)
	{
		logApexException(strClassAndMethod, strData, strError, strStack, false);
	}
	public static void logApexException(String strClassAndMethod, String strData, String strError, String strStack, Boolean notifySAP)
	{
		try
		{
			IEC_Error_Log__c log = new IEC_Error_Log__c(Type__c='Error', Source__c=strClassAndMethod, Data__c=strData, Extra_Information__c=strError, Stack_Trace__c=strStack);
			insert log;
			sendEmailToSupport(log.Id, strClassAndMethod, strData, strError, strStack, notifySAP);
		}
		catch (Exception e)
		{
			TransformationHelper.sendEmailSupport('IECErrorLogger.logApexException error at ' + system.now()
												, '********** Apex Class/Method **********\n' + strClassAndMethod + '\n\n'
												+ '********** Input Data **********\n' + strData + '\n\n'
												+ '********** Input Error **********\n' + strError + '\n\n'
												+ '********** Input Stack **********\n' + strStack + '\n\n'
												+ '********** Stack **********\n' + e.getStackTraceString() + '\n\n'
												+ '********** Error **********\n'  + e.getMessage());
		}
	} //*** end of "logApexException"


	/****************************************************************************************************
		Created by Thai 2016-02-19
			Send an email to support about new error log if applicable
	****************************************************************************************************/
	private static void sendEmailToSupport(Id idLog, String strClassAndMethod, String strData, String strError, String strStack, Boolean notifySAP)
	{
		try
		{
			if (Boolean.valueOf(Utility.getTextSetting('Email to Support after error logging')))
				TransformationHelper.sendEmailSupport('New IEC Error Logged at ' + system.now() + ': ' + String.valueOf(idLog).left(15)
													, '********** Apex Class/Method **********\n' + strClassAndMethod + '\n\n'
													+ '********** Input Error **********\n' + strError + '\n\n'
													+ '********** Input Data **********\n' + strData
													+ (String.isBlank(strStack) ? '' : '\n\n********** Stack **********\n' + strStack));
			if (notifySAP)
				if (!String.isBlank(Utility.getTextSetting('SAP Support Email')))
					Utility.sendEmail(Utility.getTextSetting('SAP Support Email').replace(',', ';').split(';')
									, 'New SAP Error Logged at ' + system.now() + ': ' + String.valueOf(idLog).left(15)
									, '********** Apex Class/Method **********\n' + strClassAndMethod + '\n\n'
									+ '********** Input Error **********\n' + strError + '\n\n'
									+ '********** Input Data **********\n' + strData
									+ (String.isBlank(strStack) ? '' : '\n\n********** Stack **********\n' + strStack)
									, false, null);
		}
		catch (Exception e) {}
	} //*** sendEmailToSupport


	/****************************************************************************************************
		Created by David D 2016/02
			Bulkyfied version of Log an error about an Apex Class
	****************************************************************************************************/
	public static void logErrors(List<IEC_Error_Log__c> errorLogs)
	{
		logErrors(errorLogs, false);
	}
	public static void logErrors(List<IEC_Error_Log__c> errorLogs, Boolean notifySAP)
	{
		try
		{
			insert errorLogs;
			system.debug('errorLogs ' + errorLogs);
			for(IEC_Error_Log__c log : errorLogs)
				sendEmailToSupport(log.Id, log.Source__c, log.Data__c, log.Extra_Information__c, log.Stack_Trace__c, notifySAP);
		}
		catch(Exception e)
		{
			for(IEC_Error_Log__c log : errorLogs)
				sendEmailToSupport(log.Id, log.Source__c, log.Data__c, log.Extra_Information__c, log.Stack_Trace__c, notifySAP);

			system.debug('errorLogs ' + errorLogs);
		}
	}


	public static IEC_Error_Log__c createErrorLog(String strClassAndMethod, String strData, String strError, String strStack)
	{
		return new IEC_Error_Log__c(
			Type__c='Error',
			Source__c=strClassAndMethod,
			Data__c=strData,
			Extra_Information__c=strError,
			Stack_Trace__c=strStack
		);
	}



}
