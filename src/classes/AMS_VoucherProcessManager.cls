public class AMS_VoucherProcessManager {

	public Set<Id> countriesSet;

	public AMS_Voucher_Process_Run__c process;

	public AMS_VouchersCalculationBatch processBatch;

	public AMS_VoucherProcessManager(AMS_Voucher_Process_Run__c process) {
		this.process = process;
	}

	public void setCountries(Set<Id> countries){
		this.countriesSet = countries;
	}

	public Id runVouchersProcess(String yearToProcess){

		processBatch = new AMS_VouchersCalculationBatch(countriesSet,process, yearToProcess);

		Id batchCountryAverageId = Database.executeBatch(processBatch, 200);

		process.Average_Country_Calculation_Batch__c = batchCountryAverageId;

		update process;

		return batchCountryAverageId;

	}


}
