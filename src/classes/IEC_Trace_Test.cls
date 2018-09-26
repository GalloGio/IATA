/**

	Project: eCommerce Enhancements
	   File: IEC_Trace_Test.cls
	Subject: Test Class for Utility class that handles Trace requests for IEC Application.
	History: 2017-05-02, asantos, Initial Release.

*/
@isTest
public with sharing class IEC_Trace_Test {
	@isTest
	static void testCase01() {
		Test.startTest();

		IEC_Trace.logDebug(null, 'Debug Message', null, null);
		IEC_Trace.logInfo(null, 'Info Message', null, null);
		IEC_Trace.logWarning(null, 'Warning Message', null, null);

		try {
			Integer a = 5 / 0;
		} catch (Exception e) {
			IEC_Trace.logError(null, 'Error Message', null, null, e);
		}
	}

	@isTest
	static void testCase02() {
		Test.startTest();

		IEC_Trace_Setting__c traceSetting = new IEC_Trace_Setting__c(
			Is_Enabled__c = true,
			Trace_Debug__c = true,
			Trace_Error__c = true,
			Trace_Info__c = true,
			Trace_Warning__c = true
		);

		insert traceSetting;

		IEC_Trace.logDebug(null, 'Debug Message', null, null);
		IEC_Trace.logInfo(null, 'Info Message', null, null);
		IEC_Trace.logWarning(null, 'Warning Message', null, null);

		try {
			Integer a = 5 / 0;
		} catch (Exception e) {
			IEC_Trace.logError(null, 'Error Message', null, null, e);
		}
	}

	@isTest
	static void testCase03() {
		Test.startTest();

		IEC_Trace_Setting__c traceSetting = new IEC_Trace_Setting__c(
			Is_Enabled__c = true,
			Trace_Debug__c = true,
			Trace_Error__c = true,
			Trace_Info__c = true,
			Trace_Warning__c = true,
			Timestamp_Format__c = null
		);

		insert traceSetting;

		IEC_Trace.logDebug(null, 'Debug Message', null, null);
		IEC_Trace.logInfo(null, 'Info Message', null, null);
		IEC_Trace.logWarning(null, 'Warning Message', null, null);

		try {
			Integer a = 5 / 0;
		} catch (Exception e) {
			IEC_Trace.logError(null, 'Error Message', null, null, e);
		}

		Test.stopTest();
	}

	@isTest
	static void testCase04() {
		Test.startTest();

		IEC_Trace_Setting__c traceSetting = new IEC_Trace_Setting__c(
			Is_Enabled__c = false,
			Trace_Debug__c = true,
			Trace_Error__c = true,
			Trace_Info__c = true,
			Trace_Warning__c = true,
			Timestamp_Format__c = null
		);

		insert traceSetting;

		IEC_Trace.logDebug(null, 'Debug Message', null, null);
		IEC_Trace.logInfo(null, 'Info Message', null, null);
		IEC_Trace.logWarning(null, 'Warning Message', null, null);

		try {
			Integer a = 5 / 0;
		} catch (Exception e) {
			IEC_Trace.logError(null, 'Error Message', null, null, e);
		}

		Test.stopTest();
	}

	@isTest
	static void testCase05() {
		Test.startTest();

		System.assert(IEC_Trace.isNull(null) == true);

		IEC_Trace_Setting__c ts = new IEC_Trace_Setting__c (
			Is_Enabled__c = true,
			Trace_Debug__c = true,
			Trace_Info__c = true,
			Trace_Warning__c = true,
			Trace_Error__c = true
		);
		insert ts;

		Boolean x = IEC_Trace.isTraceEnabled();

		IEC_Trace.logInfo(null, 'Hello', 'Hi', 'There');
		IEC_Trace.logWarning(null, 'Hello', 'Hi', 'There');
		IEC_Trace.logError(null, 'Hello', 'Hi', 'There', null);

		try {
			Integer a = 5 / 0;
		} catch (Exception e) {
			IEC_Trace.logError(null, 'error message', null, null, e);
		}

		List<IEC_Trace.TraceItem> traceItemList = IEC_Trace.getTraceItemList();

		String traceString = IEC_Trace.exportTrace();
		
		traceString = IEC_Trace.getTraceAsString();
		traceString = IEC_Trace.getTraceAsHTML();

		x = IEC_Trace.isWarningActive;
		x = IEC_Trace.isInfoActive;
		x = IEC_Trace.isDebugActive;
		x = IEC_Trace.isErrorActive;

		delete ts;

		x = IEC_Trace.isTraceEnabled();

		traceString = IEC_Trace.quote(true);

		x = IEC_Trace.isWarningActive;
		x = IEC_Trace.isInfoActive;
		x = IEC_Trace.isDebugActive;
		x = IEC_Trace.isErrorActive;

		traceString = (new IEC_Trace.TraceItem()).getCsv();

		Test.stopTest();
	}
}