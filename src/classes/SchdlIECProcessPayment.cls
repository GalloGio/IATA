/**
	* Description: This class contains schedulable class for processing SAP Payments and sending them to Zuora
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/

global class SchdlIECProcessPayment implements Schedulable {
	global void execute(SchedulableContext sc) {
		// Only run the job if the schedule interface is activated through the custom settings
		if (IECConstants.SAPSettings_ZuoraInterfaceActive) {
			BtchIECProcessPayment btchProc = new BtchIECProcessPayment();
			btchProc.query =
				'SELECT Zuora_Billing_Account_ID__c, Zuora_Invoice_ID__c, Pay_Method__c, Total_Amount__c,'
				+ '		Payment_Date__c, SAP_Invoice_Number__c'
				+ '	FROM IEC_SAP_Invoice__c'
				+ '	WHERE Status__c = \'' + IECConstants.IECSAPInvoice_Status_ZuoraReady + '\'';
			// Only process 50 records at a time (Zuora Limitation)
			Database.executeBatch(btchProc, 50);
		}

		// This section of code will schedule the next execution X minutes from now depending on the configured setting
		datetime nextScheduleTime = system.now().addMinutes(IECConstants.SAPSettings_SchedulePeriod);
		string minute = string.valueof(nextScheduleTime.minute());
		string second = string.valueof(nextScheduleTime.second ());
		string cronvalue = second + ' ' + minute + ' * * * ?' ;
		string jobName = 'SchdlIECProcessPayment ' + nextScheduleTime.format('hh:mm');

		system.schedule(jobName, cronvalue , new SchdlIECProcessPayment());

		// this section of code will abort the current schedule job
		system.abortJob(sc.getTriggerId());
	}
}
