public without sharing class AMS_VoucherCalculationHelper {

	public static Integer calculateNumberOfVouchers(Decimal totalAgencySales, Decimal countryAverage, Integer maxAmountVouchersCountry, Decimal countryBenchmark){

		//	MAX(country max vouchers, (2 * Total sales % MIN(Country average, Country benchmark)))

		countryAverage = countryAverage.round(System.RoundingMode.HALF_EVEN);

		return Integer.Valueof(Math.Min(maxAmountVouchersCountry,(  2 * (totalAgencySales / Math.min(countryAverage, countryBenchmark) ).round(System.RoundingMode.FLOOR))  ));


		//return Integer.Valueof(Math.Min(maxAmountVouchersCountry,Math.min ( (  2 * (totalAgencySales / Math.min(countryAverage, countryBenchmark) ).round(System.RoundingMode.FLOOR)) - 3 , 0 )));
		
		//return Integer.Valueof(Math.Min(maxAmountVouchersCountry,(  2 * (totalAgencySales / Math.min(countryAverage, countryBenchmark) ))));

	}

	public static Map<IATA_ISO_Country__c,Decimal> calculateAverageCountries(List<AMS_Voucher_Information__c> agencyVoucherInfoList){

		// we are assuning that the list of AMS_Voucher_Information__c is the list with elegible so no extra validation is needed.
		// first let's separate the vouchers info per country
		// the list has to have information about the Country

		Map<IATA_ISO_Country__c,List<AMS_Voucher_Information__c>> voucherInfoPercountry = divideVouchersInfoPerCountry(agencyVoucherInfoList);

		Map<IATA_ISO_Country__c,Decimal> toReturn = new Map<IATA_ISO_Country__c,Decimal>();

		for(IATA_ISO_Country__c country : voucherInfoPercountry.keySet()){

			List<AMS_Voucher_Information__c> vouchersInfo = voucherInfoPercountry.get(country);

			Decimal average = calculateAverageCountry(vouchersInfo);

			toReturn.put(country, average);

		}

		return toReturn;
	}

	private static Map<IATA_ISO_Country__c,List<AMS_Voucher_Information__c>> divideVouchersInfoPerCountry(List<AMS_Voucher_Information__c> agencyVoucherInfoList){

		Map<IATA_ISO_Country__c,List<AMS_Voucher_Information__c>> toReturn = new Map<IATA_ISO_Country__c,List<AMS_Voucher_Information__c>>();

		for(AMS_Voucher_Information__c vInfo : agencyVoucherInfoList){

			if(toReturn.containsKey(vInfo.Account__r.IATA_ISO_Country__r)){

				toReturn.get(vInfo.Account__r.IATA_ISO_Country__r).add(vInfo);
			}
			else{
				toReturn.put(vInfo.Account__r.IATA_ISO_Country__r,new List<AMS_Voucher_Information__c>{vInfo});
			}
		}

		return toReturn; 

	}

	private static Decimal calculateAverageCountry(List<AMS_Voucher_Information__c> vouchersInfo){

		Decimal totalSum = 0;

		for(AMS_Voucher_Information__c vInfo: vouchersInfo){

			totalSum += vInfo.AmountLastYearSales__c / vInfo.Exchange_Rate__c;

		}

		return totalSum / vouchersInfo.size();

	}

	public static List<AMS_Voucher__c> createVouchersForAgencies(Map<Id,Integer> vouchersInfoVouchers, Id processId, Integer vouchersAlreadyCreated, Integer voucherPerPdf, String regionName){

		Datetime nowDate = Datetime.now();
		
		String formattedDate = nowDate.format('yyyyMMddhmm');

        String filename = '';


		List<AMS_Voucher__c> toReturn = new List<AMS_Voucher__c>();

		Integer it = 0;

		for(Id vouchersInfo : vouchersInfoVouchers.keySet()){


			Integer numberOfVouchersToCreate = vouchersInfoVouchers.get(vouchersInfo);

			for( Integer i = 0 ; i < numberOfVouchersToCreate; i++){

				Integer runExec = Integer.valueOf((Decimal.valueOf(vouchersAlreadyCreated + it + 1) / Decimal.valueOf(voucherPerPdf)).round(System.RoundingMode.FLOOR));

				filename = 'Vouchers_'+ regionName + '_' + (runExec+1) + '_' + formattedDate + '.pdf';

				AMS_Voucher__c v = new AMS_Voucher__c(Voucher_Information__c = vouchersInfo, AMS_Voucher_Process_Run__c = processId, SequenceNumber__c = String.valueOf(i+1) + ' of ' + numberOfVouchersToCreate, runExecution__c = runExec, Pdf_Attachment_File__c = filename);

				toReturn.add(v);

				it++;
			}
			
		}

		return toReturn;

	}



}