public with sharing class AMS_VoucherInformationTriggerHandler {

  	private static boolean recalculateLastYearFlag = true;

	public static void handleAfterInsert(List<AMS_Voucher_Information__c> newMap) {
		validateVoucherInfoUniqueness(newMap);
	}

	public static void handleAfterUpdate(List<AMS_Voucher_Information__c> newMap) {
		validateVoucherInfoUniqueness(newMap);
	}

	public static void handleAfterUndelete(List<AMS_Voucher_Information__c> newMap) {
		validateVoucherInfoUniqueness(newMap);
	}

	// An account must only have one Voucher Information object attached.
	private static void validateVoucherInfoUniqueness(List<AMS_Voucher_Information__c> vouchersInfo){

		Set<String> accountsWithMultipleVouchers = new Set<String>();
		Set<Id> accounts = new Set<Id>();

		for(AMS_Voucher_Information__c v : vouchersInfo){
			accounts.add(v.Account__c);
		}

		List<AggregateResult> accountVouchersMap = [SELECT  Account__c, Year__c , Count(Id) from AMS_Voucher_Information__c where Account__c = :accounts group by Account__c, Year__c  having Count(id) > 1 ];

		for (AggregateResult ar : accountVouchersMap)  {

				accountsWithMultipleVouchers.add(String.valueOf(ar.get('Account__c')));
		}

		for(AMS_Voucher_Information__c elem : vouchersInfo){

			if(accountsWithMultipleVouchers.contains(elem.Account__c)){
				elem.addError('There is already 1 Voucher Information Attached to the Account ' + elem.Account__c + ' for that year.');
			}

		}

	}
/*
	private static void calculateLastYearsVouchers(List<AMS_Voucher_Information__c> vouchersInfo){

		System.debug('Calculating last years vouchers amount');

		Map<Id,List<AMS_Voucher_Information__c>> vouchersInfoLastYear = new Map<Id,List<AMS_Voucher_Information__c>>();

		Set<Id> accountsVouchers = new Set<Id>();

		Set<String> allYears = new Set<String>();

		for(AMS_Voucher_Information__c vInfo : vouchersInfo){

			Date yearDate = date.parse('01/01/'+vInfo.Year__c);

			yearDate = yearDate.addYears(-1);

			Integer newYear = yearDate.year();

			allYears.add(String.valueOf(newYear));

			accountsVouchers.add(vInfo.Account__c);

		}

		List<AMS_Voucher_Information__c> allVouchers = [SELECT Id, Number_Of_Vouchers__c, Account__c, Year__c from AMS_Voucher_Information__c where Account__c in :accountsVouchers and Year__c in :allYears];

		System.debug('Found the list for past years vouchers' + allVouchers);

		for(AMS_Voucher_Information__c vInfo : allVouchers){

			if(vouchersInfoLastYear.containsKey(vInfo.Account__c))
				vouchersInfoLastYear.get(vInfo.Account__c).add(vInfo);
			else
				vouchersInfoLastYear.put(vInfo.Account__c,new List<AMS_Voucher_Information__c>{vInfo});

		}


		for(AMS_Voucher_Information__c vInfo : vouchersInfo){

			//search for the voucher with the same account, from the last year ...

			List<AMS_Voucher_Information__c> vouchersTotal = vouchersInfoLastYear.get(vInfo.Account__c);

			if(vouchersTotal == null){

				vInfo.Vouchers_Issued_Last_Year__c = 0;
				System.debug('Seting value to zero. (1)');
				continue;
			}

			AMS_Voucher_Information__c voucherFromLastYear = findVoucherFromLastYear(vouchersTotal,vInfo.Year__c);



			if(voucherFromLastYear == null){

				vInfo.Vouchers_Issued_Last_Year__c = 0;
				System.debug('Seting value to zero. (2)');
				continue;
			}

			System.debug('Found last year Voucher Info:' + voucherFromLastYear);

			vInfo.Vouchers_Issued_Last_Year__c = voucherFromLastYear.Number_Of_Vouchers__c;
			System.debug('Seting value to ' + voucherFromLastYear.Number_Of_Vouchers__c);

		}

	}

	private static AMS_Voucher_Information__c findVoucherFromLastYear(List<AMS_Voucher_Information__c> vouchersTotal, String yearInput){

		for(AMS_Voucher_Information__c vInfo: vouchersTotal){

			Date yearDate = date.parse('01/01/'+yearInput);

			yearDate = yearDate.addYears(-1);

			Integer newYear = yearDate.year();

			if(vInfo.Year__c == String.valueOf(newYear)){
				System.debug('Found last years vouchersInfo:' + vInfo);
				return vInfo;
			}
		}

		return null;

	}
*/
}
