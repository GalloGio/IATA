public class ANG_RHCHelper {

	public class RiskInformationUpdateWrapper {
		Id contactId;
		Id accountId;
		String riskStatus;
		String cashConditions;
		String rhcAmount;
		String currencyIsoCode;
		String rhcEffectiveDate;
		String templateLanguage;
	}

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

	private static final Set<String> skipPercentageCalcBspSet = new Set<String>{
		'BSP-HK',
		'BSP-MO'
	};

	private static final String RISK_RHC_UPDATE_TEMPLATE = 'Risk_Information_Update';

	public static Set<Id> updateNotificationAlreadySent = new Set<Id>();

	private static final String YES = 'Yes';
	private static final String NO = 'No';

	// *********************************************************
	// *********************** Methods *************************
	// *********************************************************

	public static void createRHCInfo(Set<Id> accountIds, Boolean sumFS) {

		List<Account> accountsRetreived = [SELECT Id, IATA_ISO_Country__r.CurrencyIsoCode, IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode,
											   IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c, ANG_CashCondition__c,
											   (SELECT Id, CurrencyIsoCode, Security_Status__c, ANG_ConvertedAmount__c, Amount__c
												FROM Financial_Securities__r),
											   (SELECT Id, ANG_Financial_Security__c, ANG_RHC_Amount__c
												FROM RHC_Informations__r
												WHERE RecordTypeId = :RECTYPE_STDRHCINFO)
										   FROM Account
										   WHERE Id IN :accountIds];

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

	public static void calculateRHCAmount(List<ANG_RHC_Information__c> rhcInfo) {
		//calculates RHC and forescasted RHC amount based on business rules. this is not done on a formula field, because terminated accounts should not have the value changed
		Set<Id> accountsIds = new Set<Id>();

		for(ANG_RHC_Information__c rhc : rhcInfo) accountsIds.add(rhc.ANG_AccountId__c);

		Map<Id, String> accountsBspMap = new Map<Id, Id>();
		Map<Id, Account> accountsMap = new Map<Id, Account>();
		Map<Id, String> isoCountries = new Map<Id, String>();
		Map<String, AMS_Country_Specific_Attribute__c> attributes = new Map<String, AMS_Country_Specific_Attribute__c>();

		if(!accountsIds.isEmpty()){

			for (Account a : [SELECT Id, IATA_ISO_Country__c, IATA_ISO_Country__r.ISO_Code__c, IATA_ISO_Country__r.AMS_Settlement_System__c,
								  Financial_Assessment_Points__c, ANG_RiskStatus__c, Remittance_frequency__c, ANG_Accreditation_Model__c,
								  (SELECT id, ANG_RHC_Amount_Equals_FS__c FROM RHC_Informations__r)
							  FROM Account
							  WHERE Id IN :accountsIds]) {

				if(!a.RHC_Informations__r.isEmpty() && !a.RHC_Informations__r[0].ANG_RHC_Amount_Equals_FS__c) 	isoCountries.put(a.Id, a.IATA_ISO_Country__r.Iso_Code__c);

				accountsBspMap.put(a.Id, a.IATA_ISO_Country__r.AMS_Settlement_System__c);
				accountsMap.put(a.Id, a);
			}

			Set<String> isoCountriesSet = new Set<String>{DEFAULT_CODE};
			isoCountriesSet.addAll(isoCountries.values());

			//for accounts where the RHC Amount is NOT equal to FS, we need to check the minimum
			for(IATA_ISO_Country__c isoCountry : IATAIsoCountryDAO.getIsoCountryByIsoCodes(isoCountriesSet)){
				for(AMS_Country_Specific_Attribute__c attr : isoCountry.AMS_Country_Specific_Attributes__r){
					if(attr.RecordType.DeveloperName == 'Minimum_RHC_Amount'){
						attributes.put(isoCountry.Iso_Code__c, attr);
					}
				}
			}
		}

		Map<String, ANG_BSP_Attributes__c> bspAttributesMap = fetchBSPAttributesConfig(accountsBspMap.values());

		for(ANG_RHC_Information__c rhc : rhcInfo){

			Account acct = accountsMap.get(rhc.ANG_AccountId__c);

			Boolean isMulticountry = (acct.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY);

			Decimal fsAmount = (rhc.ANG_Financial_Security__c == null) ? 0 : rhc.ANG_Financial_Security__c;
			Decimal rhcAmountFsPercent = (rhc.RHC_Amount_Equals_FS_Percent__c == null) ? 0 : rhc.RHC_Amount_Equals_FS_Percent__c;

			Boolean shouldApplyRhcPercentage = ! isMulticountry || rhcAmountFsPercent != 0;

			// If RHC equal FS % condition is applied on the agent
			// retrieve % of FS from the RHC information (rhcAmountFsPercent) and calculate RHC amount
			if (rhc.ANG_RHC_Amount_Equals_FS__c && shouldApplyRhcPercentage) {
				System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RHCHelper - calculateRHCAmount] RHC Amount Equals FS');
				applyRhcAmountFsPercentage(rhc, fsAmount, rhcAmountFsPercent);
				continue;
			}

			//Fetch BSP associated with the given account
			String relatedBspId = accountsBspMap.get(rhc.ANG_AccountId__c);

			//If cash condition is TRUE on the agent
			//fetch the cash condition record from BSP Attributes
			//and apply RHC amount = % FS
			if (rhc.ANG_CashCondition__c && fsAmount >= 0)
			{
				System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RHCHelper - calculateRHCAmount] Cash Condition');
				Decimal fsPercentage = null;

				if (isMulticountry) {
					fsPercentage = 100;
					System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RHCHelper - calculateRHCAmount] Apply 100% percentage for multicountry agent');
				} else {
					ANG_BSP_Attributes__c bspAttrCash = bspAttributesMap.get(relatedBspId + '.' + RECTYPE_CASH_CONDITION_CONFIG);
					fsPercentage = (bspAttrCash == null || bspAttrCash.FS_Percentage__c == null) ? 0 : bspAttrCash.FS_Percentage__c;
					System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RHCHelper - calculateRHCAmount] Consider cash condition BSP Attribute');
				}

				applyRhcAmountFsPercentage(rhc, fsAmount, fsPercentage);
				continue;
			}

			//If we are processing a RHC information record
			//related with a multicountry hierarchy
			//jump into the formula calculation
			if(isMulticountry){
				System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RHCHelper - calculateRHCAmount] Apply formula calculation for multicountry agent');
				applyRhcFormulaCalculations(rhc, fsAmount, isoCountries, attributes);
				continue;
			}

			String currentBspAttrKey = (relatedBspId + RECTYPE_RHC_AMOUNT_CONFIG + acct.ANG_RiskStatus__c);

			ANG_BSP_Attributes__c bspAttrRhc = null;

			//Find the correct BSP Attribute configuration based on
			//BSP Id + BSP Attribute RecordType Id (RHC Amount Conf) + Agent Risk Status.
			//If the agent contains Financial Assessment Points finds the BSP attribute
			//that contains the interval [Min FA Points ~ Max FA Points]
			for(ANG_BSP_Attributes__c bspAttr : bspAttributesMap.values()){

				if(bspAttr.RecordTypeId == RECTYPE_CASH_CONDITION_CONFIG){
					continue;
				}

				String bspAttrKey = (String.valueOf(bspAttr.BSP__c) +
									 String.valueOf(bspAttr.RecordTypeId) +
									 bspAttr.Risk_Status__c);

				//If the agent has financial assessment points
				//considers the point interval from the configuration on BSP Attribute record.
				//Otherwise assessment points interval are not considered
				if(currentBspAttrKey == bspAttrKey &&
					(acct.Financial_Assessment_Points__c == null ||
					 (bspAttr.Max_FA_Points__c >= acct.Financial_Assessment_Points__c &&
						bspAttr.Min_FA_Points__c <= acct.Financial_Assessment_Points__c)
					)
				){
					bspAttrRhc = bspAttr;
					break;
				}

			}

			System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RHCHelper - calculateRHCAmount] BSP Attribute to use: ' + bspAttrRhc);

			//If the field "RHC Amount Calculation Type" is "Fixed Percentage",
			//then apply RHC amount and forecasted = % of FS from the BSP Attributes record
			Boolean fixedPercentageCalc =
				bspAttrRhc != null &&
				bspAttrRhc.RHC_Amnt_Calc_Type__c == RHC_AMOUNT_CALC_TYPE_FIXED_PERC;

			//If the current BSP is Hong Kong or Macau and
			//the agent does not have financial assessment points
			//skips the fixed percentage calculation
			Boolean skipFixedPercentageCalc =
				fixedPercentageCalc &&
				(acct.Financial_Assessment_Points__c == null) &&
				skipPercentageCalcBspSet.contains(bspAttrRhc.BSP__r.Name);

			if(fixedPercentageCalc && !skipFixedPercentageCalc){
				System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RHCHelper - calculateRHCAmount] RHC Calculation Type: ' + RHC_AMOUNT_CALC_TYPE_FIXED_PERC);
				double fsPercentage = (bspAttrRhc.FS_Percentage__c == null) ? 0 : bspAttrRhc.FS_Percentage__c;
				applyRhcAmountFsPercentage(rhc, fsAmount, fsPercentage);
			}
			else {
				System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RHCHelper - calculateRHCAmount] RHC Calculation Type: Formula');
				applyRhcFormulaCalculations(rhc, fsAmount, isoCountries, attributes);
			}

		}
	}

	/**
	 * Apply RHC formula calculation type according to the following logic:
	 *  - Higher amount between Total FS provided and the Sum of Provisional RHC Amount and Exceeding
	 *
	 * @param  rhc                        rhc information record
	 * @param  fsAmount                   total fs provided amount
	 * @param  isoCountries               maps the Id with the ISO Country Code
	 * @param  attributes                 country specific attributes of type 'Minimum RHC Amount'
	 */
	private static void applyRhcFormulaCalculations(ANG_RHC_Information__c rhc, Decimal fsAmount, Map<Id, String> isoCountries, Map<String, AMS_Country_Specific_Attribute__c> attributes)
	{
		Decimal rmeAmount = rhc.ANG_RME_Amount__c == null ? 0 : rhc.ANG_RME_Amount__c;
		Decimal provisional = rhc.ANG_RHC_Amount_Provisional__c == null ? 0 : rhc.ANG_RHC_Amount_Provisional__c;
		Decimal minFs = rhc.ANG_Minimum_Financial_Security__c == null ? 0 : rhc.ANG_Minimum_Financial_Security__c;
		Decimal fs = fsAmount;

		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RHCHelper - applyRhcFormulaCalculations] rmeAmount: ' + rmeAmount);
		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RHCHelper - applyRhcFormulaCalculations] provisionalRHC: ' + provisional);
		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RHCHelper - applyRhcFormulaCalculations] minFs: ' + minFs);
		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RHCHelper - applyRhcFormulaCalculations] fs: ' + fs);

		// Exceeding FS = FS - Min FS
		Decimal exceedingFs = fs - minFs;
		// % of Exceeding FS = Exceeding FS / Min FS
		Decimal percentageOfExceedingFs = exceedingFs / (minFs == 0 ? 1 : minFs);

		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RHCHelper - applyRhcFormulaCalculations] exceedingFs: ' + exceedingFs);
		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RHCHelper - applyRhcFormulaCalculations] percentageOfExceedingFs: ' + percentageOfExceedingFs);

		// The minimum rhc amount is defined in the AMS Country Specific Attributes for the account's ISO country.
		// if that is not defined then we get the AMS Country Specific Attributes for the ww country (All countries)
		// If the calculated RHC amount is lower than the minimum RHC amount the the RHC amount = minimum RHC amount.
		Decimal minimumRHCAmount = 0;
		AMS_Country_Specific_Attribute__c att = attributes.get(attributes.containsKey(isoCountries.get(rhc.ANG_AccountId__c)) ? isoCountries.get(rhc.ANG_AccountId__c) : DEFAULT_CODE);
		if (! rhc.ANG_CashCondition__c && att != null)
			minimumRHCAmount = ANG_Risk_Helper.currencyConverter(att.CurrencyIsoCode, att.ANG_Minimum_RHC_Amount__c, rhc.CurrencyIsoCode);

		System.debug(LoggingLevel.FINE, '____ [cls ANG_RHCHelper - applyRhcFormulaCalculations] minimumRHCAmount: ' + minimumRHCAmount);

		// MAX between FS, minimumRHCAmount and the new RHC ammount
		// RHC amount = (rmeAmount|Provisional) + % of Exceeding FS * (rmeAmount|Provisional)
		Decimal newRhcAmountForecasted = provisional + (percentageOfExceedingFs * provisional).setScale(0);

		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RHCHelper - applyRhcFormulaCalculations] newRhcAmountForecasted: ' + newRhcAmountForecasted);

		Decimal newRHCForecastedValue = Math.Max(fs, Math.Max(newRhcAmountForecasted, minimumRHCAmount));
		rhc.ANG_RHC_Amount_Forecasted__c = Math.min(newRHCForecastedValue, 9999999999999999.99);


		Decimal newRHCAmount = rmeAmount + (percentageOfExceedingFs * rmeAmount).setScale(0);

		Decimal newRHCValue = Math.Max(fs, Math.Max(newRHCAmount, minimumRHCAmount));
		rhc.ANG_RHC_Amount__c = Math.min(newRHCValue, 9999999999999999.99);

		System.debug(LoggingLevel.FINE, '____ [cls ANG_RHCHelper - applyRhcFormulaCalculations] Set RHC Forecasted Amount as: ' + newRHCForecastedValue);
	}

	/**
	* Calculates the RHC Amount Forecasted that will correspond
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

		/*NEWGEN-4881 - comment logic to set ANG_RHC_Amount*/
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

		Map<String, ANG_BSP_Attributes__c> bspAttributesMap = new Map<String, ANG_BSP_Attributes__c>();

		if(bspIdSet.isEmpty()) return bspAttributesMap;

		List<ANG_BSP_Attributes__c> bspAttributesLst = new List<ANG_BSP_Attributes__c>(
			[SELECT
				Id,
				BSP__c,
				BSP__r.Name,
				UniqueKey__c,
				RecordTypeId,
				Risk_Status__c,
				FS_Percentage__c,
				Min_FA_Points__c,
				Max_FA_Points__c,
				RHC_Amnt_Calc_Type__c,
				Limit_Cash_Condition__c
			 FROM ANG_BSP_Attributes__c
			 WHERE BSP__c IN :bspIdSet
			]
		);

		for(ANG_BSP_Attributes__c bspAttr : bspAttributesLst){
			//For RHC Amount Conf Rec Type the unique key is:
			//	BSP Id + RHC Amount Conf Record Type Id
			//For Cash Condition Conf Rec Type the unique key is:
			//	BSP Id + Cash Condition Conf Record Type Id + Risk Status + Min FA Points
			bspAttributesMap.put(bspAttr.UniqueKey__c, bspAttr);
		}

		return bspAttributesMap;

	}

	public static void handleRiskOrForecastedRhcAmountUpdates(Set<Id> accountIdSet){

		Map<String, Set<Id>> contactsPerAccount = ANG_ISSP_IEPMailRecipientsUtils.getRecipientsPortalServices(accountIdSet, new Set<String>{ANG_RHCHelper.RISK_PROFILE_AND_RHC_PORTAL_SERVICE});

		if(contactsPerAccount.isEmpty()) return;

		Set<Id> contactIdSet = new Set<Id>();
		for(Set<Id> idsSet : contactsPerAccount.values()){
			contactIdSet.addAll(idsSet);
		}

		Map<Id, Contact> contactMap = new Map<Id, Contact>(
			[SELECT
				Id,
				Preferred_Language__c,
				IsEmailBounced,
				Email
			 FROM Contact
			 WHERE Id IN :contactIdSet
			]
		);

		List<ANG_RHC_Information__c> rhcLst = new List<ANG_RHC_Information__c>(
			[SELECT
				Id,
				CurrencyIsoCode,
				ANG_AccountId__c,
				ANG_RHC_Amount__c,
				ANG_RHC_Amount_Forecasted__c,
				ANG_RHC_Effective_Date__c,
				ANG_AccountId__r.ANG_HE_RiskStatus__c,
				ANG_AccountId__r.ANG_HE_CashCondition__c
			 FROM ANG_RHC_Information__c
			 WHERE ANG_AccountId__c IN :accountIdSet
			]
		);

		if(rhcLst.isEmpty()){
			return;
		}

		Map<Id, ANG_RHC_Information__c> rhcMap = new Map<Id, ANG_RHC_Information__c>();

		for(ANG_RHC_Information__c rhcInfo : rhcLst){
			rhcMap.put(rhcInfo.ANG_AccountId__c, rhcInfo);
		}

		List<RiskInformationUpdateWrapper> riuwLst = new List<RiskInformationUpdateWrapper>();

		for(Id accountId : contactsPerAccount.keySet()){

			ANG_RHC_Information__c rhc = rhcMap.get(accountId);

			if(rhc != null){

				for(Id contactId : contactsPerAccount.get(String.valueOf(accountId).substring(0, 15))){
					RiskInformationUpdateWrapper riuw = new RiskInformationUpdateWrapper();
					riuw.contactId = contactId;
					riuw.accountId = accountId;

					riuw.riskStatus = '';

					if(rhc.ANG_AccountId__r.ANG_HE_RiskStatus__c != null){
						riuw.riskStatus = rhc.ANG_AccountId__r.ANG_HE_RiskStatus__c;
					}

					riuw.cashConditions = rhc.ANG_AccountId__r.ANG_HE_CashCondition__c ? YES : NO;
					riuw.currencyIsoCode = rhc.CurrencyIsoCode;

					riuw.rhcAmount = '';

					if(rhc.ANG_RHC_Amount__c != NULL){
						riuw.rhcAmount = rhc.ANG_RHC_Amount__c.format();
					}

					riuw.rhcEffectiveDate = '';

					if(rhc.ANG_RHC_Effective_Date__c != NULL){
						riuw.rhcEffectiveDate = (rhc.ANG_RHC_Effective_Date__c.month() + '/' +
																							rhc.ANG_RHC_Effective_Date__c.day() + '/' +
																							rhc.ANG_RHC_Effective_Date__c.year());
					}

					riuw.templateLanguage = contactMap.get(contactId).Preferred_Language__c;
					riuwLst.add(riuw);
				}

			}

		}

		System.debug(LoggingLevel.FINE, '____ [cls ANG_RHCHelper - handleRiskOrForecastedRhcAmountUpdates] Risk Information Wrapper - ' + riuwLst);

		triggerRiskOrForecastedRhcAmountNotifications(riuwLst, contactMap);

	}

	private static void triggerRiskOrForecastedRhcAmountNotifications(List<RiskInformationUpdateWrapper> infoLst, Map<Id, Contact> contactMap){

		Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate>();

		List<EmailTemplate> emailTemplates = new List<EmailTemplate>(
			[SELECT
				Id,
				Body,
				Subject,
				HtmlValue,
				DeveloperName
			 FROM EmailTemplate
			 WHERE DeveloperName LIKE :RISK_RHC_UPDATE_TEMPLATE + '%'
			 	AND IsActive = TRUE
			]
		);

		for(EmailTemplate et : emailTemplates){
			emailTemplateMap.put(et.DeveloperName, et);
		}

		List<Notification_Template__c> notificationTemplates = new List<Notification_Template__c>(
			[SELECT
				Id,
				Name,
				Identifier__c
			 FROM Notification_Template__c
			 WHERE Identifier__c = :RISK_RHC_UPDATE_TEMPLATE
			]
		);

		List<Email> emailLst = new List<Email>();

		Map<Id, RiskInformationUpdateWrapper> riuwNotificationsMap = new Map<Id, RiskInformationUpdateWrapper>();

		List<String> notificationTargets = new List<String>();

		for(RiskInformationUpdateWrapper wrap : infoLst){

			EmailTemplate template = emailTemplateMap.get(RISK_RHC_UPDATE_TEMPLATE + '_' + wrap.templateLanguage);

			if(template == null) template = emailTemplateMap.get(RISK_RHC_UPDATE_TEMPLATE);

			String htmlBody = template.HtmlValue;
			htmlBody = htmlBody.replace('#RISK_STATUS#', wrap.riskStatus);
			htmlBody = htmlBody.replace('#CASH_CONDITIONS#', wrap.cashConditions);
			htmlBody = htmlBody.replace('#RHC_AMOUNT#', String.valueOf(wrap.rhcAmount) + ' ' + wrap.CurrencyIsoCode);
			htmlBody = htmlBody.replace('#RHC_EFFECTIVE_DATE#', (wrap.rhcEffectiveDate == null ? '' :String.valueOf(wrap.rhcEffectiveDate)));

			String plainBody = template.Body;
			plainBody = plainBody.replace('#RISK_STATUS#', wrap.riskStatus);
			plainBody = plainBody.replace('#CASH_CONDITIONS#', wrap.cashConditions);
			plainBody = plainBody.replace('#RHC_AMOUNT#', String.valueOf(wrap.rhcAmount) + ' ' + wrap.CurrencyIsoCode);
			plainBody = plainBody.replace('#RHC_EFFECTIVE_DATE#', (wrap.rhcEffectiveDate == null ? '' :String.valueOf(wrap.rhcEffectiveDate)));

			if(contactMap.containsKey(wrap.contactId) && !contactMap.get(wrap.contactId).IsEmailBounced && !contactMap.get(wrap.contactId).Email.endsWithIgnoreCase('.inactive'))
				emailLst.add(new Email(wrap.contactId, wrap.accountId, template.Subject, plainBody, htmlBody));

			updateNotificationAlreadySent.add(wrap.accountId);

			if(!notificationTemplates.isEmpty()){
				notificationTargets.add(wrap.contactId + ':' + notificationTemplates[0].Name);
				riuwNotificationsMap.put(wrap.ContactId, wrap);
			}

		}

		System.debug(LoggingLevel.FINE, '____ [cls ANG_RHCHelper - triggerRiskOrForecastedRhcAmountNotifications] Email List - ' + emailLst);

		if(!System.isBatch() && !System.isQueueable()){
			System.enqueueJob(new RiskAlertMailService(emailLst, null));
		}
		else {
			sendMailUpdate(emailLst);
		}

		createRiskAndRhcPortalNotifications(notificationTargets, riuwNotificationsMap);

	}

	private static void createRiskAndRhcPortalNotifications(List<String> notificationTargets, Map<Id, RiskInformationUpdateWrapper> riuwNotificationsMap){

		if(notificationTargets.isEmpty()) return;

		List<Notification__c> notifications = new List<Notification__c>();

		for(Notification__c nt : ISSP_CreateNotification.createnotification(notificationTargets, false)){
			RiskInformationUpdateWrapper riuw = riuwNotificationsMap.get(nt.Contact__c);
			nt.Message__c = nt.Message__c
							.replace('#RISK_STATUS#', riuw.riskStatus)
							.replace('#CASH_CONDITION#', riuw.cashConditions)
							.replace('#RHC_AMOUNT#', String.valueOf(riuw.rhcAmount) + ' ' + riuw.CurrencyIsoCode)
							.replace('#RHC_EFFECTIVE_DATE#', (riuw.rhcEffectiveDate == null ? '' :String.valueOf(riuw.rhcEffectiveDate)));
			notifications.add(nt);
		}

		System.debug(LoggingLevel.FINE, '____ [cls ANG_RHCHelper - triggerRiskOrForecastedRhcAmountNotifications] Notifications - ' + notifications);

		if(!notifications.isEmpty()){
			insert notifications;
		}

	}

	public class Email {
		Id targetId;
		Id whatId;
		Id templateId;
		String subject;
		String plainBody;
		String htmlBody;
		Boolean isTemplate;

		public Email(Id targetId, Id whatId, Id templateId){
			this.targetId = targetId;
			this.whatId = whatId;
			this.templateId = templateId;
			this.isTemplate = true;
		}

		public Email(Id targetId, Id whatId, String subject, String plainBody, String htmlBody){
			this.targetId = targetId;
			this.whatId = whatId;
			this.subject = subject;
			this.plainBody = plainBody;
			this.htmlBody = htmlBody;
			this.isTemplate = false;
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

			if(m.isTemplate){
				mail.setTemplateId(m.templateId);
			}
			else {
				mail.setSubject(m.subject);
				mail.setHtmlBody(m.htmlBody);
				mail.setPlainTextBody(m.plainBody);
			}

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
