/****************************************************************************************************
	Created by Thai 2016-02-19
		Cover code in class "IECErrorLogger"
****************************************************************************************************/
@isTest
private class IECErrorLogger_Test
{


static testMethod void test_AllMethod()
{
	List<IEC_Error_Log__c> lstLog = new List<IEC_Error_Log__c>();

	//*** to cover method "sendEmailToSupport"
	TestDataGenerator.generateApexSetting();
	insert new Apex_Setting__c(Name='Email to Support after error logging', Text_1__c='true');
	insert new Apex_Setting__c(Name='SAP Support Email', Text_1__c=UserInfo.getUserEmail());

	//*** cover exception part in "logApexError", "logApexException" "logErrors"
	IECErrorLogger.logApexError('z'.repeat(300), null, null);
	system.assert(0 == [select count() from IEC_Error_Log__c], 'Invalid count');
	IECErrorLogger.logApexException('z'.repeat(300), null, null, null);
	system.assert(0 == [select count() from IEC_Error_Log__c], 'Invalid count');
	IECErrorLogger.logErrors(new List<IEC_Error_Log__c> { new IEC_Error_Log__c(Displayed_Message__c='z'.repeat(300)) });
	system.assert(0 == [select count() from IEC_Error_Log__c], 'Invalid count');

	//*** cover valid part in "logApexError", "logApexException" "logErrors"
	IECErrorLogger.logApexError('classANDmethod', null, null);
	IECErrorLogger.logApexError('classANDmethod', null, null, true);
	system.assert(2 == [select count() from IEC_Error_Log__c], 'Invalid count');
	IECErrorLogger.logApexException('classANDmethod', null, null, null);
	IECErrorLogger.logApexException('classANDmethod', null, null, null, true);
	system.assert(4 == [select count() from IEC_Error_Log__c], 'Invalid count');
	IECErrorLogger.logErrors(new List<IEC_Error_Log__c> { new IEC_Error_Log__c(Displayed_Message__c='z'.repeat(10)) });
	system.assert(5 == [select count() from IEC_Error_Log__c], 'Invalid count');

	//*** cover "logError"
	delete [select Id from IEC_Error_Log__c];
	IECErrorLogger.logError(null, 'z'.repeat(300), null, null, 'source', 'stack');
	IECErrorLogger.logError(null, null, 'z'.repeat(300), null, 'source', 'stack');
	system.assert(2 == [select count() from IEC_Error_Log__c], 'Invalid count');

	//*** cover "logBatchError"
	lstLog.add(IECErrorLogger.logBatchError('z'.repeat(300), null, null, 'source 1', 'stack'));
	system.assert(lstLog.size() == 1 && lstLog[0].Source__c == 'source 1', 'Invalid data: ' + lstLog);
	lstLog.add(IECErrorLogger.logBatchError(null, 'z'.repeat(300), null, 'source 2', 'stack'));
	system.assert(lstLog.size() == 2 && lstLog[1].Source__c == 'source 2', 'Invalid data: ' + lstLog);

	//*** cover "logInfo"
	delete [select Id from IEC_Error_Log__c];
	IECErrorLogger.logInfo(null, 'z'.repeat(300), null, null, 'source');
	IECErrorLogger.logInfo(null, null, 'z'.repeat(300), null, 'source');
	system.assert(2 == [select count() from IEC_Error_Log__c], 'Invalid count');

	//*** cover "captureDMLError"
	lstLog = IECErrorLogger.captureDMLError(null, null, 'source', null, null);
	system.assert(lstLog == null, 'Invalid error list: ' + lstLog);
	List<Database.UpsertResult> lstResult = Database.upsert(new List<IEC_Error_Log__c> { new IEC_Error_Log__c(Displayed_Message__c='z'.repeat(300)) }, false);
	lstLog = IECErrorLogger.captureDMLError(null, lstResult, 'source', new List<String> {'Displayed_Message__c'}, new List<List<String>> {new List<String> {'zzz'}});
	system.assert(lstLog.size() == 1 && lstLog[0].Source__c == 'source', 'Invalid data: ' + lstLog);

	//*** cover "createErrorLog"
	lstLog.clear();
	lstLog.add(IECErrorLogger.createErrorLog('classANDmethod', null, null, null));
	system.assert(lstLog.size() == 1 && lstLog[0].Source__c == 'classANDmethod', 'Invalid data: ' + lstLog);
} //*** end of "test_AllMethod"


} //*** end of class
