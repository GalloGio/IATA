global class AMS_VouchersCreationBatch implements Database.Batchable<sObject>, Database.Stateful  {
	
	public final Integer GOVERNORLIMIT = 10000;

	public final Integer VOUCHERSPERPDF = 1000;

	String query;

	public List<AMS_Voucher_Information__c> allVouchersInfo;

	public Map<IATA_ISO_Country__c,Decimal> averageMetrics;

	public Set<IATA_ISO_Country__c> countries;

	public Map<String,Integer> vouchersPerCountry{get;set;}

	List<AMS_Voucher__c> vouchers{get;set;}

	public Set<Id> vouchersToPrint{get;set;}

	public AMS_Voucher_Region__c region;

	public Map<String,AMS_Voucher_Region__c> regionsMap;

	public AMS_Voucher_Process_Run__c process;

	public List<Attachment> attachments;

	public Integer totalVouchersCreated;

	global AMS_VouchersCreationBatch(Map<IATA_ISO_Country__c,Decimal> averageMetrics, AMS_Voucher_Process_Run__c process, String yearToProcess) {

		totalVouchersCreated = 0;

		attachments = new List<Attachment>();

		vouchersToPrint = new Set<Id>();

		this.process = process;

		this.regionsMap = new Map<String,AMS_Voucher_Region__c>();

		this.averageMetrics = averageMetrics;

		this.countries = averageMetrics.keySet();

		allVouchersInfo = new List<AMS_Voucher_Information__c>();

		//String yearToProcess = String.valueOf(System.today().year());

		this.query = 'SELECT Id, Account__c, Exchange_Rate__c, Amount_Currency__c, Number_Of_Vouchers__c , Account__r.IATA_ISO_Country__r.Region__c , AmountLastYearSales__c , Account__r.IATA_ISO_Country__c, Account__r.IATA_ISO_Country__r.Name, Account__r.Location_Class__c,Account__r.IATA_ISO_Country__r.AMS_Max_Vouchers_Per_Year__c, Account__r.IATA_ISO_Country__r.AMS_Vouchers_Benchmark__c FROM AMS_Voucher_Information__c WHERE IsAgencyEligible__c = true and Year__c = \'' + yearToProcess + '\' and Account__r.IATA_ISO_Country__c in :countries';
	
		List<AMS_Voucher_Region__c> regions = [SELECT Id, Name from AMS_Voucher_Region__c];

		for(AMS_Voucher_Region__c reg: regions){

			regionsMap.put(reg.Name,reg);

		}

		System.debug('Entry query for vouchers to create on AMS_VouchersCreationBatch:' + this.query);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<AMS_Voucher_Information__c> scope) {
	
		// just get the region for the first (they should be the same !!)

		region = regionsMap.get(scope.get(0).Account__r.IATA_ISO_Country__r.Region__c);

		Map<Id,Integer> vouchersToCreate = new Map<Id,Integer>();

		for(AMS_Voucher_Information__c vInfo: scope){

			//If an Agency already has vouchers assigned for a specific Year, 
			//it will not generate more vouchers. In this case the agency needs to remove the assigned vouchers to be ready to run again.
			if(vInfo.Number_Of_Vouchers__c > 0){
				continue;
			}

			Decimal totalAgencySales = vInfo.AmountLastYearSales__c / vInfo.Exchange_Rate__c;
			Decimal countryAverage = averageMetrics.get(vInfo.Account__r.IATA_ISO_Country__r);
			Integer maxAmountVouchersCountry = Integer.ValueOf(vInfo.Account__r.IATA_ISO_Country__r.AMS_Max_Vouchers_Per_Year__c);
			Decimal countryBenchmark = Integer.ValueOf(vInfo.Account__r.IATA_ISO_Country__r.AMS_Vouchers_Benchmark__c);

			Integer nVouchers = AMS_VoucherCalculationHelper.calculateNumberOfVouchers(totalAgencySales,countryAverage,maxAmountVouchersCountry,countryBenchmark);

			vouchersToCreate.put(vInfo.Id, nVouchers);
			
		}

		vouchers = AMS_VoucherCalculationHelper.createVouchersForAgencies(vouchersToCreate,process.Id,totalVouchersCreated,VOUCHERSPERPDF,region.Name);

		totalVouchersCreated += vouchers.size();

		if(!vouchers.isEmpty()){
	
			if(vouchers.size() > GOVERNORLIMIT)
				divideAndConquer(vouchers);
			else
				insert vouchers;

		}

		for(AMS_Voucher__c voucher: vouchers){

			vouchersToPrint.add(voucher.Id);
		}

	}
	

	global void finish(Database.BatchableContext BC) {
		
		System.debug('Finishing AMS_VoucherPDFCreationBatch and sending ' + vouchersToPrint.size() + ' vouchers to print.');

		AMS_VoucherPDFCreationBatch pdfCreationBatch = new AMS_VoucherPDFCreationBatch(vouchersToPrint,region,process);

		Id pdfCreationBatchId = Database.executeBatch(pdfCreationBatch,VOUCHERSPERPDF);

		process.Vouchers_PDF_Creation_Batch__c = pdfCreationBatchId;

		update process;

	}

	public void insertVouchers(List<AMS_Voucher__c> vouchers){

		if(vouchers.size() > GOVERNORLIMIT)
			divideAndConquer(vouchers);
		else
			insert vouchers;
		
	}

	public void divideAndConquer(List<AMS_Voucher__c> vouchers){

		insert vouchers;
	}

	
}