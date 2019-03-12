public class ANG_RHCHelper {

	// *********************************************************
	// ******************* Static Variables ********************
	// *********************************************************

	//RHC Information standard record type
	public static final String RHC_INFO_STD_RT = 'RHC_Information';

	public static final String RECTYPE_STDRHCINFO = RecordTypeSingleton.getInstance().getRecordTypeID('ANG_RHC_Information__c', RHC_INFO_STD_RT);
	public static final String RECTYPE_RISKALERT_RHC = RecordTypeSingleton.getInstance().getRecordTypeID('ANG_Risk_Alert__c', 'Risk_Alert');
	public static final String RECTYPE_RISKALERT_RTS = RecordTypeSingleton.getInstance().getRecordTypeID('ANG_Risk_Alert__c', 'Risk_Alert_RTS');
	public static final String RECTYPE_RHCATTRIBUTE = RecordTypeSingleton.getInstance().getRecordTypeID('AMS_Country_Specific_Attribute__c', 'RHC_Risk_Alert');
    public static final String RECTYPE_RHC_AMOUNT_CONFIG     = RecordTypeSingleton.getInstance().getRecordTypeId('ANG_BSP_Attributes__c', 'RHC_Amount_Conf');
    public static final String RECTYPE_CASH_CONDITION_CONFIG = RecordTypeSingleton.getInstance().getRecordTypeId('ANG_BSP_Attributes__c', 'Cash_Condition_Conf');
    
	//Risk Alert 
	public static final String RISK_ALERT_DIRECTION_UP = 'UP';
	public static final String RISK_ALERT_DIRECTION_DOWN = 'DOWN';
    //RHC Portal Service Name
    public static final String RISK_PROFILE_AND_RHC_PORTAL_SERVICE ='Risk Profile and RHC';

    public static final String DEFAULT_CODE = 'WW';

    public static final String RHC_AMOUNT_CALC_TYPE_FIXED_PERC = 'Fixed Percentage';
    public static final String RHC_AMOUNT_CALC_TYPE_FORMULA = 'Formula';

	// *********************************************************
	// *********************** Methods *************************
	// *********************************************************

	public static void createRHCInfo(Set<Id> accountIds, Boolean sumFS) {
		
		List<Account> accountsRetreived = [SELECT Id, IATA_ISO_Country__r.CurrencyIsoCode,IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode, IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c , ANG_CashCondition__c, (SELECT Id, CurrencyIsoCode, Security_Status__c, ANG_ConvertedAmount__c, Amount__c FROM Financial_Securities__r), (SELECT Id, ANG_Financial_Security__c FROM RHC_Informations__r WHERE RecordTypeId = :RECTYPE_STDRHCINFO) FROM Account WHERE Id IN :accountIds];
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
				CurrencyIsoCode = a.IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode,
				ANG_RHC_Amount_Equals_FS__c = a.IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c
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
		Set<Id> accountsIds = new Set<Id>();

		for(ANG_RHC_Information__c rhc : rhcInfo) {
			if(!rhc.ANG_RHC_Amount_Equals_FS__c){
				accountsIds.add(rhc.ANG_AccountId__c);
			}
		}

		Map<Id, String> accountsBspMap = new Map<Id, Id>();
		Map<Id, Account> accountsMap = new Map<Id, Account>();
		Map<Id, String> isoCountries = new Map<Id, String>();
		Map<String, AMS_Country_Specific_Attribute__c> attributes = new Map<String, AMS_Country_Specific_Attribute__c>();

		if(!accountsIds.isEmpty()){
			for(Account a : [SELECT Id, IATA_ISO_Country__c, IATA_ISO_Country__r.AMS_Settlement_System__c, Financial_Assessment_Points__c, ANG_RiskStatus__c FROM Account WHERE Id IN :accountsIds]) {
				isoCountries.put(a.Id, a.IATA_ISO_Country__c);
				accountsBspMap.put(a.Id, a.IATA_ISO_Country__r.AMS_Settlement_System__c);
				accountsMap.put(a.Id, a);
			}
			
			//for accounts where the RHC Amount is NOT equal to FS, we need to check the minimum
			Id minRHCrt = RecordTypeSingleton.getInstance().getRecordTypeID('AMS_Country_Specific_Attribute__c', 'Minimum_RHC_Amount');

			for(AMS_Country_Specific_Attribute__c a : [SELECT
														Id
														, IATA_ISO_Country__c
														, IATA_ISO_Country__r.Iso_code__c
														, ANG_Minimum_RHC_Amount__c
														, CurrencyIsoCode
													FROM AMS_Country_Specific_Attribute__c
													WHERE RecordTypeId =: minRHCrt 
													AND (IATA_ISO_Country__c IN :isoCountries.values() OR IATA_ISO_Country__r.Iso_code__c =: DEFAULT_CODE)]){
				attributes.put(a.IATA_ISO_Country__r.Iso_code__c == DEFAULT_CODE ? DEFAULT_CODE : String.valueOf(a.IATA_ISO_Country__c), a);
			}

		}
		
		Map<String, ANG_BSP_Attributes__c> bspAttributesMap = fetchBSPAttributesConfig(accountsBspMap.values());

		for(ANG_RHC_Information__c rhc : rhcInfo){
		
			Decimal fsAmount = (rhc.ANG_Financial_Security__c == NULL) ? 0 : rhc.ANG_Financial_Security__c;
			Decimal rhcAmountFsPercent = (rhc.RHC_Amount_Equals_FS_Percent__c == NULL) ? 0 : rhc.RHC_Amount_Equals_FS_Percent__c;

			//If RHC equal FS % condition is applied on the agent
			//retrieve % of FS from the RHC information (rhcAmountFsPercent) 
			//and calculate RHC amount
			if(rhc.ANG_RHC_Amount_Equals_FS__c){
				System.debug(LoggingLevel.FINE, '____ [cls ANG_RHCHelper - calculateRHCAmount] RHC Amount Equals FS');
				applyRhcAmountFsPercentage(rhc, fsAmount, rhcAmountFsPercent);
				continue;
			}

			//Fetch BSP associated with the given account
			String relatedBspId = accountsBspMap.get(rhc.ANG_AccountId__c);

			//If cash condition is TRUE on the agent
			//fetch the cash condition record from BSP Attributes
			//and apply RHC amount = % FS
			if(rhc.ANG_CashCondition__c && fsAmount > 0){
				System.debug(LoggingLevel.FINE, '____ [cls ANG_RHCHelper - calculateRHCAmount] Cash Condition');
				ANG_BSP_Attributes__c bspAttrCash = bspAttributesMap.get(relatedBspId + RECTYPE_CASH_CONDITION_CONFIG);
				Decimal fsPercentage = (bspAttrCash.FS_Percentage__c == null) ? 0 : bspAttrCash.FS_Percentage__c;
				applyRhcAmountFsPercentage(rhc, fsAmount, fsPercentage);
				continue;
			}

			Account acct = accountsMap.get(rhc.ANG_AccountId__c);

			String currentBspAttrKey = (relatedBspId + RECTYPE_RHC_AMOUNT_CONFIG + acct.ANG_RiskStatus__c);

			ANG_BSP_Attributes__c bspAttrRhc = null; 

			//Find the correct BSP Attribute configuration based on
			//BSP Id + BSP Attribute RecordType Id (RHC Amount Conf) + Agent Risk Status.
			//If the agent contains Financial Assessment Points finds the BSP attribute
			//that contains the interval [Min FA Points ~ Max FA Points]
			for(ANG_BSP_Attributes__c bspAttr : bspAttributesMap.values()){
				
				String bspAttrKey = (String.valueOf(bspAttr.BSP__c) + 
									 String.valueOf(bspAttr.RecordTypeId) + 
									 bspAttr.Risk_Status__c); 
				
				//If the agent has financial assessment points 
				//considers the point interval from the configuration on BSP Attribute record. 
				//Otherwise assessment points interval are not considered  
				if(currentBspAttrKey == bspAttrKey && 
					(acct.Financial_Assessment_Points__c == NULL || 
					 (bspAttr.Max_FA_Points__c >= acct.Financial_Assessment_Points__c &&
					  bspAttr.Min_FA_Points__c <= acct.Financial_Assessment_Points__c)
					)
				){
					bspAttrRhc = bspAttr;
					break;
				}

			}

			System.debug(LoggingLevel.FINE, '____ [cls ANG_RHCHelper - calculateRHCAmount] BSP Attribute to use: ' + bspAttrRhc);

			//If the field "RHC Amount Calculation Type" is "Fixed Percentage", 
			//then apply RHC amount and forecasted = % of FS from the BSP Attributes record
			if(bspAttrRhc != NULL && bspAttrRhc.RHC_Amnt_Calc_Type__c == RHC_AMOUNT_CALC_TYPE_FIXED_PERC){
				System.debug(LoggingLevel.FINE, '____ [cls ANG_RHCHelper - calculateRHCAmount] RHC Calculation Type: ' + RHC_AMOUNT_CALC_TYPE_FIXED_PERC);
				double fsPercentage = (bspAttrRhc.FS_Percentage__c == null) ? 0 : bspAttrRhc.FS_Percentage__c;
				applyRhcAmountFsPercentage(rhc, fsAmount, fsPercentage);
			} 
			else {
				System.debug(LoggingLevel.FINE, '____ [cls ANG_RHCHelper - calculateRHCAmount] RHC Calculation Type: Formula');
				Decimal rmeAmount = rhc.ANG_RME_Amount__c == null ? 0 : rhc.ANG_RME_Amount__c;
				Decimal provisionalRHC = rhc.ANG_RHC_Amount_Provisional__c == null ? 0 : rhc.ANG_RHC_Amount_Provisional__c;
				Decimal exceedingFS = rhc.ANG_Exceeding_Financial_Security__c == null ? 0 : rhc.ANG_Exceeding_Financial_Security__c;

				if (fsAmount > (rmeAmount + exceedingFS)) rhc.ANG_RHC_Amount__c = fsAmount;
				else rhc.ANG_RHC_Amount__c = rmeAmount + exceedingFS;

				if (fsAmount > (provisionalRHC + exceedingFS)) rhc.ANG_RHC_Amount_Forecasted__c = fsAmount;
				else rhc.ANG_RHC_Amount_Forecasted__c = provisionalRHC + exceedingFS;

				// The minimum rhc amount is defined in the AMS Country Specific Attributes for the account's ISO country.
				// if that is not defined then we get the AMS Country Specific Attributes for the ww country (All countries)
				// If the calculated RHC amount is lower than the minimum RHC amount the the RHC amount = minimum RHC amount.
				
				AMS_Country_Specific_Attribute__c att = attributes.get( attributes.containsKey(isoCountries.get(rhc.ANG_AccountId__c)) ? isoCountries.get(rhc.ANG_AccountId__c) : DEFAULT_CODE );
				if(rhc.ANG_CashCondition__c || att == null) continue;

				Decimal minimumRHCAmount = ANG_Risk_Helper.currencyConverter(att.CurrencyIsoCode, att.ANG_Minimum_RHC_Amount__c, rhc.CurrencyIsoCode);

				if(rhc.ANG_RHC_Amount__c < minimumRHCAmount) rhc.ANG_RHC_Amount__c = minimumRHCAmount;
				if(rhc.ANG_RHC_Amount_Forecasted__c < minimumRHCAmount) rhc.ANG_RHC_Amount_Forecasted__c = minimumRHCAmount;
			}

		}
	}

	/**
	* Calculates the RHC Amount that will correspond
	* to a percent of the financial security amount
	* 
	* @param rhc: ANG_RHC_Information__c
	* @param fsAmount: Decimal
	* @param fsPercentage: Decimal 
	*
	*/
	private static void applyRhcAmountFsPercentage(ANG_RHC_Information__c rhc, Decimal fsAmount, Decimal fsPercentage){
		System.debug(LoggingLevel.FINE, '____ [cls ANG_RHCHelper - applyRhcAmountFsPercentage] FS Amount: ' + fsAmount);
		System.debug(LoggingLevel.FINE, '____ [cls ANG_RHCHelper - applyRhcAmountFsPercentage] FS Percentage to apply: ' + fsPercentage);
		Decimal rhcAmount = (fsAmount * fsPercentage/100);
		System.debug(LoggingLevel.FINE, '____ [cls ANG_RHCHelper - rhcAmount] RHC Amount: ' + rhcAmount);
		rhc.ANG_RHC_Amount__c = rhcAmount;
		rhc.ANG_RHC_Amount_Forecasted__c = rhcAmount;
	}

	/**
	* Fetches the BSP Attributes configuration
	* for a given set of BSP Ids
	* 
	* @param bspIdSet: List<Id>
	* @return bspAttributesLst: Map<String, ANG_BSP_Attributes__c>
	*
	*/
	private static Map<String, ANG_BSP_Attributes__c> fetchBSPAttributesConfig(List<Id> bspIdSet){

		List<ANG_BSP_Attributes__c> bspAttributesLst = new List<ANG_BSP_Attributes__c>(
			[SELECT
				Id,
				BSP__c,
				UniqueKey__c,
				RecordTypeId,
				Risk_Status__c,
				FS_Percentage__c,
				Min_FA_Points__c,
				Max_FA_Points__c,
				RHC_Amnt_Calc_Type__c,
				Limit_Cash_Condition__c
			 FROM
			 	ANG_BSP_Attributes__c
			 WHERE
			 	BSP__c IN :bspIdSet
			]
		);

		Map<String, ANG_BSP_Attributes__c> bspAttributesMap = new Map<String, ANG_BSP_Attributes__c>();

		for(ANG_BSP_Attributes__c bspAttr : bspAttributesLst){
			//For RHC Amount Conf Rec Type the unique key is:
			//	BSP Id + RHC Amount Conf Record Type Id 
			//For Cash Condition Conf Rec Type the unique key is:
			//	BSP Id + Cash Condition Conf Record Type Id + Risk Status + Min FA Points
			bspAttributesMap.put(bspAttr.UniqueKey__c, bspAttr);
		}

		return bspAttributesMap;

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

		OrgWIdeEmailAddress[] owea = [SELECT Id FROM OrgWIdeEmailAddress WHERE Address = 'noreply@iata.org'];

		for(Email m : messages){
			System.debug(loggingLevel.FINE, '____ [cls ANG_RHCHelper - sendMailUpdate] message parameters - '+m);

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTargetObjectId(m.targetId);
			mail.setWhatId(m.whatId);
			mail.setTemplateId(m.templateId);

			if (!owea.isEmpty()) mail.setOrgWIdeEmailAddressId(owea[0].Id);
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

			if(alertIds == null || alertIds.isEmpty()) return;

			List<ANG_Risk_Alert__c> alerts = new List<ANG_Risk_Alert__c>();
			for(Id alertId : alertIds) alerts.add(new ANG_Risk_Alert__c(Id = alertId, ANG_email_sent__c = true));

			update alerts;
		}
	}
}
