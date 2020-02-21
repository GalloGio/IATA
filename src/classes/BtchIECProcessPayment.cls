/**
	* Description: This class contains batchable class for processing SAP Payments and sending them to Zuora
	* Note: Using batch to avoid two issues:
	*		1- Supporting Callout on Schedulable Jobs
	*		2- Zuora has limit on 50 items for create() api method
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/

global class BtchIECProcessPayment implements Database.Batchable<sObject>, Database.AllowsCallouts {
		public String query;

		global Database.querylocator start(Database.BatchableContext BC){
				return Database.getQueryLocator(query);
		}

		global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<Zuora.zObject> lstZPmt = new List<Zuora.zObject>();
		List<IEC_SAP_Invoice__c> lstSAPInv = new List<IEC_SAP_Invoice__c>();

				for(sObject s : scope) {
			IEC_SAP_Invoice__c SAPInv = (IEC_SAP_Invoice__c) s;
			lstZPmt.add(IECZuoraHelper.CreateZuoraPayment(SAPInv.Zuora_Billing_Account_ID__c, SAPInv.Zuora_Invoice_ID__c, SAPInv.Pay_Method__c, SAPInv.Total_Amount__c, SAPInv.Payment_Date__c, SAPInv.SAP_Invoice_Number__c));
			lstSAPInv.add(SAPInv);
		}

		if (!lstZPmt.isEmpty()) {
			List<Zuora.zApi.SaveResult> lstResults = (Test.isRunningTest())
				? new List<Zuora.zApi.SaveResult> {IECTestUtil.createSampleSaveResult(true)}
				: IECZuoraHelper.createApiCall(lstZPmt);

			for (integer x = 0; x < lstResults.size(); x++) {
				Zuora.zApi.SaveResult result = lstResults.get(x);
				IEC_SAP_Invoice__c SAPInv = lstSAPInv.get(x);

				if (result.Success) {
					SAPInv.Status__c = IECConstants.IECSAPInvoice_Status_SentToZuora;
					SAPInv.Status_Date__c = Datetime.now();
					SAPInv.Error_Message__c = null;
				}
				else {
					SAPInv.Status__c = IECConstants.IECSAPInvoice_Status_ZuoraError;
					SAPInv.Status_Date__c = Datetime.now();
					SAPInv.Error_Message__c = IECZuoraHelper.getErrorMessagesString(result.Errors, ', ');
				}
			}

			update lstSAPInv;
		}
		}

		global void finish(Database.BatchableContext BC) {
	}
}
