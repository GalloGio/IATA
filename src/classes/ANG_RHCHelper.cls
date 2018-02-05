public class ANG_RHCHelper {

	// *********************************************************
	// ******************* Static Variables ********************
	// *********************************************************

	//RHC Information standard record type
	public static final String RHC_INFO_STD_RT = 'RHC_Information';

	public static final String RECTYPE_STDRHCINFO = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_RHC_Information__c').get(RHC_INFO_STD_RT);

	//Risk Alert 
	public static final String RISK_ALERT_DIRECTION_UP = 'UP';

	// *********************************************************
	// *********************** Methods *************************
	// *********************************************************


	public static void createRHCInfo(Set<Id> accountIds, Boolean sumFS) {
		
		List<Account> accountsRetreived = [SELECT Id, IATA_ISO_Country__r.CurrencyIsoCode,IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode, (SELECT Id, CurrencyIsoCode, Security_Status__c, ANG_ConvertedAmount__c, amount__c FROM Financial_Securities__r), (SELECT Id, ANG_Financial_Security__c from RHC_Informations__r where RecordTypeId = :RECTYPE_STDRHCINFO) FROM Account WHERE Id IN :accountIds];
		List<Account> accountsToProcess = new List<Account>();
		List<Account> accountsToSUMFS = new List<Account>();

		for(Account acct: accountsRetreived){

			if(acct.RHC_Informations__r.isEmpty())
				accountsToProcess.add(acct);
			else{
				if(acct.RHC_Informations__r.get(0).ANG_Financial_Security__c == null || acct.RHC_Informations__r.get(0).ANG_Financial_Security__c == 0)
					accountsToSUMFS.add(acct);
			}

		}

		createRHCInfo(accountsToProcess, sumFS);
		ANG_Risk_Helper.sumFSAmount(accountsToSUMFS);
	}

	public static void createRHCInfo(List<Account> accounts, Boolean sumFS) {
		if(accounts.isEmpty()) return;

		List<ANG_RHC_Information__c> rhcInfos = new List<ANG_RHC_Information__c>();

		for(Account a : accounts){
			rhcInfos.add(new ANG_RHC_Information__c(
				ANG_AccountId__c = a.Id,
				RecordTypeId = RECTYPE_STDRHCINFO,
				ANG_UniqueKey__c=a.id+RHC_INFO_STD_RT,
				CurrencyIsoCode = a.IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode
			));
		}

		insert rhcInfos;

		if(sumFS) ANG_Risk_Helper.sumFSAmount(accounts);
	}

	public static void deactivateRHCInfo(Set<Id> accounts) {
		deactivateRHCInfo([SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c IN :accounts]);
	}

	public static void deactivateRHCInfo(List<ANG_RHC_Information__c> rhcInfos) {
		if(!rhcInfos.isEmpty()) delete rhcInfos;
	}

	public static void moveRHCInfos(List<ANG_RHC_Information__c> rhcInfos, Map<Id, Id> newParents) {
		for(ANG_RHC_Information__c rhcInfo : rhcInfos) rhcInfo.ANG_AccountId__c = newParents.get(rhcInfo.ANG_AccountId__c);

		if(!rhcinfos.isEmpty()) update rhcInfos;
	}

	/*public static void calculateRHCAmount(List<Account> accounts) {
		calculateRHCAmount([SELECT Id, ANG_CashCondition__c, ANG_Financial_Security__c, ANG_RHC_Amount__c, ANG_RHC_Amount_Forecasted__c, ANG_RME_Amount__c, ANG_Exceeding_Financial_Security__c, ANG_RHC_Amount_Provisional__c FROM ANG_RHC_Information__c WHERE ANG_AccountId__c IN :accounts]);
	}*/
	
	public static void calculateRHCAmount(List<ANG_RHC_Information__c> rhcInfo) {
		//calculates RHC and forescasted RHC amount based on business rules. this is not done on a formula field, because terminated accounts should not have the value changed
		for(ANG_RHC_Information__c rhc : rhcInfo){

			if(rhc.ANG_CashCondition__c && rhc.ANG_Financial_Security__c > 0){
				rhc.ANG_RHC_Amount__c = rhc.ANG_Financial_Security__c;
				rhc.ANG_RHC_Amount_Forecasted__c = rhc.ANG_Financial_Security__c;
			}else{
				Decimal fsAmount = rhc.ANG_Financial_Security__c == null ? 0 : rhc.ANG_Financial_Security__c;
				Decimal rmeAmount = rhc.ANG_RME_Amount__c == null ? 0 : rhc.ANG_RME_Amount__c;
				Decimal provisionalRHC = rhc.ANG_RHC_Amount_Provisional__c == null ? 0 : rhc.ANG_RHC_Amount_Provisional__c;
				Decimal exceedingFS = rhc.ANG_Exceeding_Financial_Security__c == null ? 0 : rhc.ANG_Exceeding_Financial_Security__c;

				if (fsAmount > (rmeAmount + exceedingFS)) rhc.ANG_RHC_Amount__c = fsAmount;
				else rhc.ANG_RHC_Amount__c = rmeAmount + exceedingFS;


				if (fsAmount > (provisionalRHC + exceedingFS)) rhc.ANG_RHC_Amount_Forecasted__c = fsAmount;
				else rhc.ANG_RHC_Amount_Forecasted__c = provisionalRHC + exceedingFS;
			}
		}
	}
	@future
	public static void sendMailUpdateRiskAlert(String contactId,String rhcId,String templateId,String riskAlertId){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       	mail.setTargetObjectId(contactId);//contact
       	mail.setWhatId(rhcId);//account
        mail.setTemplateId(templateID);
        mail.setOrgWideEmailAddressId ([select Id from OrgWideEmailAddress where address ='noreply@iata.org'].id);
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>{mail};
		try{
			if(!Test.isRunningTest())Messaging.SendEmailResult[] resultList=Messaging.sendEmail(emails); 
		}catch(Exception  e){
			system.debug('Failed to send email to users');
		}


		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c();
		ara.id=riskAlertId;
		ara.ANG_email_sent__c= true;

		upsert ara;

	}
}