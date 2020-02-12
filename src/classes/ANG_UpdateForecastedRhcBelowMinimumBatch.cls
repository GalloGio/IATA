global class ANG_UpdateForecastedRhcBelowMinimumBatch implements Database.Batchable<sObject> {

	global String query;

	public ANG_UpdateForecastedRhcBelowMinimumBatch(String query){
		this.query = query;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		if(String.isBlank(this.query)){
			this.query =
				' SELECT															' +
				'	Id,																' +
				'	CurrencyIsoCode,												' +
				'	ANG_RHC_Amount_Forecasted__c,									' +
				'	ANG_Forecasted_RHC_Effective_date__c,							' +
				'	ANG_AccountId__r.Remittance_frequency__c,						' +
				'	ANG_AccountId__r.IATA_ISO_Country__r.AMS_Settlement_System__c	' +
				' FROM ANG_RHC_Information__c										' +
				' WHERE																' +
				'	ANG_RHC_Amount_Forecasted__c < USD10000							' +
				' AND ANG_RHC_Amount_Equals_FS__c = false							' +
				' AND ANG_CashCondition__c = false									' +
				' AND ANG_AccountId__r.Location_Type__c = \'HE\'					' +
				' AND ANG_AccountId__r.ANG_Accreditation_Model__c = \'Cash\'		' +
				' AND ANG_AccountId__r.Status__c NOT IN (\'New application pending\',\'Listed\', \'Not accreditated\',\'Not in operation\',\'Terminated\', null, \'\') ' +
				' AND ANG_AccountId__r.Type = \'IATA Passenger Sales Agent\' ' +
				' AND ANG_AccountId__r.IATA_ISO_Country__r.ISO_Code__c not in (\'BD\', \'CN\', \'TW\', \'HK\', \'LB\', \'MY\', \'PK\', \'SG\', \'LK\', \'UA\') ';
		}
		return Database.getQueryLocator(this.query);
	}

	global void execute(Database.BatchableContext BC, List<ANG_RHC_Information__c> rhcLst) {

		Map<ID, List<Account>> mapBspIdAccountList = new Map<ID, List<Account>>();
		Map<ID, Date> mapBillingPeriodPerAccount = new Map<ID, Date>();
		Set<String> remittanceFrequencySet = new Set<String>();

		// Map bsps with accounts records
		for(ANG_RHC_Information__c rhcInfo : rhcLst){

			Account acct = rhcInfo.ANG_AccountId__r;

			remittanceFrequencySet.add(acct.Remittance_frequency__c);

			Id bspId = acct.IATA_ISO_Country__r.AMS_Settlement_System__c;

			if(!mapBspIdAccountList.containsKey(bspId)){
				mapBspIdAccountList.put(bspId, new List<Account>());
			}

			mapBspIdAccountList.get(bspId).add(acct);
		}

		Map<Id, Map<String, Date>> mapBSPwithOperationalCalendars = new Map<Id, Map<String, Date>>();

		//Fetch next billing period from calendars
		AggregateResult[] groupedResults =
			[SELECT MIN(First_Day__c), ISS_operation__c, Frequency_code__c
			 FROM Operational_Calendar__c
			 WHERE
				 ISS_operation__c IN :mapBspIdAccountList.keySet()
			 AND Frequency_code__c in :remittanceFrequencySet
			 AND First_Day__c > TODAY
			 GROUP BY ISS_Operation__c, Frequency_Code__c
			 ORDER BY ISS_operation__c, Frequency_code__c ASC
			];

		// Fetch calendar records for the given bsp and remittance frequency
		for(AggregateResult oppCalendar : groupedResults){

			Id issOperation = (Id) oppCalendar.get('ISS_operation__c');
			String frequencyCode = (String) oppCalendar.get('Frequency_code__c');
			Date nextBillingDate = (Date)oppCalendar.get('expr0');

			//Map to group for all the bsps with the specific Account's remittance frequencies
			if(!mapBSPwithOperationalCalendars.containsKey(issOperation)){
				mapBSPwithOperationalCalendars.put(issOperation, new Map<String, Date>());
			}

			//Only load the 1st billing Period for the BSP with a specific Remittance Frequency
			if(!mapBSPwithOperationalCalendars.get(issOperation).containsKey(frequencyCode)){
				mapBSPwithOperationalCalendars.get(issOperation).put(frequencyCode, nextBillingDate);
			}

		}

		List<Account> accountsByBSP = null;
		for(Id bspId : mapBSPwithOperationalCalendars.keySet()){

			//Load accounts list by BSP
			accountsByBSP = mapBspIdAccountList.get(bspId);
			Map<String, Date> mapFrequencyCodeFirstBiilingPeriod = mapBSPwithOperationalCalendars.get(bspId);

			for(Account acc : accountsByBSP){
				Date firstBillPeriod = mapFrequencyCodeFirstBiilingPeriod.get(acc.Remittance_frequency__c);
				//Map for each account the new First Billing Period.
				if(firstBillPeriod != null){
					mapBillingPeriodPerAccount.put(acc.id, firstBillPeriod);
				}
			}
		}

		List<ANG_RHC_Information__c> rhcToUpdateLst = new List<ANG_RHC_Information__c>();

		//Update the RHC forecasted amount if BELOW 10000 USD
		for(ANG_RHC_Information__c rhcInfo : rhcLst){

			Decimal amount = ANG_Risk_Helper.currencyConverter('USD', 10000, rhcInfo.CurrencyIsoCode);

			Boolean toUpdate = false;

			if(rhcInfo.ANG_RHC_Amount_Forecasted__c < amount){
				rhcInfo.ANG_RHC_Amount_Forecasted__c = amount;
				rhcInfo.ANG_Forecasted_RHC_Effective_date__c = mapBillingPeriodPerAccount.get(rhcInfo.ANG_AccountId__c);
				toUpdate = true;
			}

			if(toUpdate){
				rhcToUpdateLst.add(rhcInfo);
			}

		}

		if(!rhcToUpdateLst.isEmpty()){
			update rhcToUpdateLst;
		}
	}

	global void finish(Database.BatchableContext BC) {

	}
}