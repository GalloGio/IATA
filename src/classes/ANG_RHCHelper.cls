public class ANG_RHCHelper {

	// *********************************************************
	// ******************* Static Variables ********************
	// *********************************************************

	//RHC Information standard record type
	public static final String RHC_INFO_STD_RT = 'RHC_Information';

	public static final String RECTYPE_STDRHCINFO = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_RHC_Information__c').get(RHC_INFO_STD_RT);
	public static final String RECTYPE_RISKALERT_RHC = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_Risk_Alert__c').get('Risk_Alert');
	public static final String RECTYPE_RISKALERT_RTS = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_Risk_Alert__c').get('Risk_Alert_RTS');
	public static final String RECTYPE_RHCATTRIBUTE = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_Country_Specific_Attribute__c').get('RHC_Risk_Alert');

	//Risk Alert 
	public static final String RISK_ALERT_DIRECTION_UP = 'UP';
	public static final String RISK_ALERT_DIRECTION_DOWN = 'DOWN';
    //RHC Portal Service Name
    public static final String RISK_PROFILE_AND_RHC_PORTAL_SERVICE ='Risk Profile and RHC';

    public static final String DEFAULT_CODE = 'WW';
	// *********************************************************
	// *********************** Methods *************************
	// *********************************************************


	public static void createRHCInfo(Set<Id> accountIds, Boolean sumFS) {
		
		List<Account> accountsRetreived = [SELECT Id, IATA_ISO_Country__r.CurrencyIsoCode,IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode, ANG_CashCondition__c, (SELECT Id, CurrencyIsoCode, Security_Status__c, ANG_ConvertedAmount__c, Amount__c FROM Financial_Securities__r), (SELECT Id, ANG_Financial_Security__c from RHC_Informations__r where RecordTypeId = :RECTYPE_STDRHCINFO) FROM Account WHERE Id IN :accountIds];
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
				ANG_UniqueKey__c = a.Id+RHC_INFO_STD_RT,
				ANG_CashCondition__c = a.ANG_CashCondition__c,
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


		Id devRecordTypeId = Schema.SObjectType.AMS_Country_Specific_Attribute__c.getRecordTypeInfosByName().get('Minimum RHC Amount').getRecordTypeId();

		Set<Id> accountsIds = new Set<Id>();
		for(ANG_RHC_Information__c rhc : rhcInfo) {
			accountsIds.add(rhc.ANG_AccountId__c);
		}

		Map<Id, Account> accountsMap = new Map<Id, Account>([Select id, IATA_ISO_Country__c From Account Where id in: accountsIds]);

		Set<Id> isoSet = new Set<Id>();
		for(Id key : accountsMap.keySet()) {
			isoSet.add(accountsMap.get(key).IATA_ISO_Country__c);
		}
		
		List<AMS_Country_Specific_Attribute__c> csa = [Select id, IATA_ISO_Country__c, IATA_ISO_Country__r.Iso_code__c, ANG_Minimum_RHC_Amount__c From AMS_Country_Specific_Attribute__c Where RecordTypeId =: devRecordTypeId And (IATA_ISO_Country__c IN :isoSet OR IATA_ISO_Country__r.Iso_code__c =: DEFAULT_CODE)];

		Map<String, Decimal> csaMap = new Map<String, Decimal>();
		for(AMS_Country_Specific_Attribute__c a : csa) csaMap.put((isoSet.contains(a.IATA_ISO_Country__c) ? String.valueOf(a.IATA_ISO_Country__c) : DEFAULT_CODE), a.ANG_Minimum_RHC_Amount__c);

		for(ANG_RHC_Information__c rhc : rhcInfo){

			if(rhc.ANG_CashCondition__c && rhc.ANG_Financial_Security__c > 0){
				rhc.ANG_RHC_Amount__c = rhc.ANG_Financial_Security__c;
				rhc.ANG_RHC_Amount_Forecasted__c = rhc.ANG_Financial_Security__c;
			}else{
				if(!rhc.ANG_CashCondition__c) rhc.ANG_RME_Amount__c = rhc.ANG_RHC_Amount_Provisional__c;

				Decimal fsAmount = rhc.ANG_Financial_Security__c == null ? 0 : rhc.ANG_Financial_Security__c;
				Decimal rmeAmount = rhc.ANG_RME_Amount__c == null ? 0 : rhc.ANG_RME_Amount__c;
				Decimal provisionalRHC = rhc.ANG_RHC_Amount_Provisional__c == null ? 0 : rhc.ANG_RHC_Amount_Provisional__c;
				Decimal exceedingFS = rhc.ANG_Exceeding_Financial_Security__c == null ? 0 : rhc.ANG_Exceeding_Financial_Security__c;

				if (fsAmount > (rmeAmount + exceedingFS)) rhc.ANG_RHC_Amount__c = fsAmount;
				else rhc.ANG_RHC_Amount__c = rmeAmount + exceedingFS;

				if (fsAmount > (provisionalRHC + exceedingFS)) rhc.ANG_RHC_Amount_Forecasted__c = fsAmount;
				else rhc.ANG_RHC_Amount_Forecasted__c = provisionalRHC + exceedingFS;
			}

			//
			// Minimum RHC amount 
			//
			// The minimum rhc amount is defined in the AMS Country Specific Attributes for the account's ISO country.
			// if that is not defined the we get the AMS Country Specific Attributes for the ww country (All countries)
			//
			// Then if the calculated RHC amount is lower than the minimum RHC amount the the RHC amount = minimum RHC amount.
			//						
			Decimal minimumRHCAmount = null;

			if(csaMap.containsKey(accountsMap.get(rhc.ANG_AccountId__c).IATA_ISO_Country__c) && csaMap.get(accountsMap.get(rhc.ANG_AccountId__c).IATA_ISO_Country__c) != null)
				minimumRHCAmount = csaMap.get(accountsMap.get(rhc.ANG_AccountId__c).IATA_ISO_Country__c);
			else
				minimumRHCAmount = csaMap.get(DEFAULT_CODE);

			//
			// Apply the rule
			//
			if(minimumRHCAmount != null) {
				minimumRHCAmount = ANG_Risk_Helper.currencyConverter('USD', minimumRHCAmount, rhc.CurrencyIsoCode);

				if(rhc.ANG_RHC_Amount__c < minimumRHCAmount) {
					rhc.ANG_RHC_Amount__c = minimumRHCAmount;					
				}

				if(rhc.ANG_RHC_Amount_Forecasted__c < minimumRHCAmount) {
					rhc.ANG_RHC_Amount_Forecasted__c = minimumRHCAmount;					
				}
			}
			
		}
	}

	public class Email {
		Id targetId;
		Id whatId;
		Id templateId;

		public Email(Id targetId, Id whatId, Id templateId){
			this.targetId = targetId;
			this.whatId = whatId;
			this.templateId = templateId;
		}
	}

	

	public static void sendMailUpdate(List<Email> messages) {
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

		OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply@iata.org'];

		for(Email m : messages){
			System.debug(loggingLevel.FINE, '____ [cls ANG_RHCHelper - sendMailUpdate] message parameters - '+m);

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTargetObjectId(m.targetId);
			mail.setWhatId(m.whatId);
			mail.setTemplateId(m.templateId);

			if (!owea.isEmpty()) mail.setOrgWideEmailAddressId(owea[0].Id);
			else{
				mail.setSenderDisplayName(ENV.AccessToApplicationServiceRequested_Email_Subject);
				mail.setReplyTo(ENV.Reply_Email);
			} 

			emails.add(mail);
		}
		
		try{
			if(!Test.isRunningTest()) Messaging.sendEmail(emails); 
		}catch(Exception e){
			System.debug(loggingLevel.ERROR, '____ [cls ANG_RHCHelper - sendMailUpdate] Failed to send email to users - '+e.getMessage());
		}
	}

	public class RiskAlertMailService implements Queueable {

		private List<Email> mails;
		private Set<Id> alertIds;

		public RiskAlertMailService(List<Email> mails, Set<Id> alertIds){
			this.mails = mails;
			this.alertIds = alertIds;
		}

		public void execute(QueueableContext context) {
			sendMailUpdate(mails);

			List<ANG_Risk_Alert__c> alerts = new List<ANG_Risk_Alert__c>();
			for(Id alertId : alertIds) alerts.add(new ANG_Risk_Alert__c(Id = alertId, ANG_email_sent__c = true));

			update alerts;
		}
	}
}
