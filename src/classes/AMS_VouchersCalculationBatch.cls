global class AMS_VouchersCalculationBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;

	public List<AMS_Voucher_Information__c> allVouchersInfo;

	public Set<Id> countriesToProcess;

	public AMS_Voucher_Process_Run__c process;

	public Map<IATA_ISO_Country__c,Decimal> averageMetrics;

	public String yearToProcess;

	// this batch is responsible for calculating the average sales for each country.
	// this consists on 
	global AMS_VouchersCalculationBatch(Set<Id> countriesToProcess,AMS_Voucher_Process_Run__c process, String yearToProcess) {
		
		this.yearToProcess = yearToProcess;

		this.process = process;

		this.countriesToProcess = countriesToProcess;

		allVouchersInfo = new List<AMS_Voucher_Information__c>();

		this.query = 'SELECT Id, Account__c, Exchange_Rate__c, Amount_Currency__c, AmountLastYearSales__c , Account__r.IATA_ISO_Country__r.Region__c, Account__r.IATA_ISO_Country__c, Account__r.IATA_ISO_Country__r.Name,Account__r.IATA_ISO_Country__r.AMS_Max_Vouchers_Per_Year__c, Account__r.IATA_ISO_Country__r.AMS_Vouchers_Benchmark__c, Account__r.Location_Class__c FROM AMS_Voucher_Information__c WHERE IsAgencyEligibleForCountryAverage__c = true and Year__c = \'' + yearToProcess + '\' and Account__r.IATA_ISO_Country__c in :countriesToProcess';
	
		System.debug('Entry query for AMS_VouchersCalculationBatch:' + this.query);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<AMS_Voucher_Information__c> scope) {
	
		allVouchersInfo.addAll(scope);
	}
	
	global void finish(Database.BatchableContext BC) {
		
		System.debug('AMS_VouchersCalculationBatch: Calculating all the countries average... for ' + allVouchersInfo.size() + ' vouchers info.');
		
		if(allVouchersInfo.isEmpty()){
			System.debug('Did not find any vouchers info to process due to either lack of regists or eligibility.');
			
			process.Status__c = 'Ended';
			
			update process;

			return;
		}

		averageMetrics = AMS_VoucherCalculationHelper.calculateAverageCountries(allVouchersInfo);

		AMS_VouchersCreationBatch creationBatch = new AMS_VouchersCreationBatch(averageMetrics,process,yearToProcess);

		Integer scopeRun = calculateMaxRunScope(allVouchersInfo);

        Integer numberOfVouchersInfo = Math.min(Math.Max(scopeRun,1),50);
        
        System.debug('__AMS_VouchersCalculationBatch__ Running with ' + numberOfVouchersInfo +  ' scopes.');
        
		Id aMS_VouchersCreationBatchId = Database.executeBatch(creationBatch,numberOfVouchersInfo);

		process.AMS_Vouchers_Creation_Batch__c = aMS_VouchersCreationBatchId;

		process.Country_Averages__c = processMetricsForAverage(averageMetrics);

		update process;

	}

	private Integer calculateMaxRunScope(List<AMS_Voucher_Information__c> vouchersInfo){

		Decimal maxNumber = 50;

		for(AMS_Voucher_Information__c vInfo : vouchersInfo){

			if(vInfo.Account__r.IATA_ISO_Country__r.AMS_Max_Vouchers_Per_Year__c > maxNumber)
				maxNumber = vInfo.Account__r.IATA_ISO_Country__r.AMS_Max_Vouchers_Per_Year__c;
		}

		return Integer.valueOf(1000 / maxNumber);

	}

	private String processMetricsForAverage(Map<IATA_ISO_Country__c,Decimal> averageMetrics){

		String toReturn = '';

		Set<IATA_ISO_Country__c> countriesSet =  averageMetrics.keySet(); 

		for(IATA_ISO_Country__c cnt : countriesSet){

			toReturn += (cnt.Name + ':' + averageMetrics.get(cnt) + '\n');

		}

		return toReturn;

	}
}