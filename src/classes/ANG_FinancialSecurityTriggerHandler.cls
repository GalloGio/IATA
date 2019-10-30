public class ANG_FinancialSecurityTriggerHandler{

	private static final Set<String> statuschangeMatrix = new Set<String> {
				'Close to Expiry DateActive',
				'Close to Expiry DateEncashed',
				'Close to Expiry DateEncashment in progress',
				'Close to Expiry DateExpired',
				'Close to Expiry DateInactive_Addendum',
				'Close to Expiry DateNot Active yet',
				'Close to Expiry DatePending to be Released',
				'Close to Expiry DatePending Validation',
				'Close to Expiry DateReleased',
				'ActiveClose to Expiry Date',
				'ActiveEncashed',
				'ActiveEncashment in progress',
				'ActiveExpired',
				'ActiveInactive_Addendum',
				'ActiveNot Active yet',
				'ActivePending to be Released',
				'ActivePending Validation',
				'ActiveReleased',
				'ExpiredClose to Expiry Date',
				'ExpiredActive',
				'ReleasedClose to Expiry Date',
				'ReleasedActive',
				'EncashedClose to Expiry Date',
				'EncashedActive',
				'Not Active yetClose to Expiry Date',
				'Not Active yetActive',
				'Encashment in progressClose to Expiry Date',
				'Encashment in progressActive',
				'Inactive_AddendumClose to Expiry Date',
				'Inactive_AddendumActive',
				'Pending to be ReleasedClose to Expiry Date',
				'Pending to be ReleasedActive',
				'Pending ValidationClose to Expiry Date',
				'Pending ValidationActive'
            };

	public List<Financial_Security__c> triggerNew = (List<Financial_Security__c>) Trigger.new;
	public List<Financial_Security__c> triggerOld = (List<Financial_Security__c>) Trigger.old;

	public Map<Id, Financial_Security__c> newMap = (Map<Id,Financial_Security__c>) Trigger.newMap;
	public Map<Id, Financial_Security__c> oldMap = (Map<Id,Financial_Security__c>) Trigger.oldMap;

	private Map<string, ANG_RHC_Information__c> map2Insert {
		get{
			if(map2Insert==null){
				map2Insert = new Map<string, ANG_RHC_Information__c>();
			}
			return map2Insert;
		}
		set;
	}
	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************

	private List<Financial_Security__c> financialSecurityToProcessLst = new List<Financial_Security__c>();
	//List of financial securities for which the Minimum FS should be calculated
	private List<Financial_Security__c> calculateMinFsLst = new List<Financial_Security__c>();
	
	private set<id> accIdSet{
		get{
			if(accIdSet==null){
				accIdset = new Set<id>();
				processFinancialSecurities(accIdSet);
			}
			return accIdSet;
		}
		set;
	}

	/**
	 * Build map<ID, Account> for the accounts 
	 * financial Security modified/inserted
	 */
	private Map<Id, Account> accountsMap {
		get{
			if(accountsMap == null){
				accountsMap = fetchAccountsInformation(accIdSet, false);
			}
			return accountsMap;
		}	
		set;	
	}

	/**
	 * Fetch the given accounts and associated information records (RHC & Financial Securities)
	 *
	 * @param  accIdSet:         Set of account Ids associated with the financial securities
	 * @param  fetchFromParents: Decides if the account query should fetch considering also the Top_Parent__c filter
	 * @return                   Returns the account records on an Map<Id, Account>
	 */
	private Map<Id, Account> fetchAccountsInformation(Set<Id> accIdSet, Boolean fetchFromParents){
		Set<String> fsActiveStatus = ANG_Risk_Helper.FS_STATUS_FOR_SUM_SET;
		String accountsQuery = '' +
			'SELECT Id, Top_Parent__c, ANG_isNewGenAgency__c, Location_Type__c, IATA_ISO_Country__r.CurrencyIsoCode, IATA_ISO_Country__r.ANG_RHC_LocationType__c, ' +
			' (SELECT Id, CurrencyIsoCode FROM RHC_Informations__r), ' +
			' (SELECT Id, Amount__c, Account__c, CurrencyIsoCode, Security_Status__c, ANG_ConvertedAmount__c, ANG_Minimum_Financial_Security__c, ANG_Financial_Security_Currency__c, ANG_isToUpdateRHC__c FROM Financial_Securities__r ORDER BY LastModifiedDate DESC) ' +
			'FROM Account WHERE ( Id IN :accIdSet';

		if(fetchFromParents){
			accountsQuery += ' OR Top_Parent__c IN :accIdSet ';
		}

		accountsQuery += ')';

		return new Map<Id, Account>((List<Account>) Database.query(accountsQuery));
	}

	/**
	 * Identifies a list of created/updated/deleted financial security records
	 * for which the Total/Minimum Financial Security Amount calculation should run
	 *
	 * @param  accIdSet: Account Ids associated with financial securities 
	 */
	private void processFinancialSecurities(Set<Id> accIdSet){
		
		List<Financial_Security__c> fsLst = Trigger.isDelete ? triggerOld : triggerNew;

		for(Financial_Security__c fs : fsLst){

			if(Trigger.isUpdate){
				Financial_Security__c oldFs = oldMap.get(fs.id);
				if(fs.Amount__c == oldFs.Amount__c && fs.CurrencyIsoCode == oldFs.CurrencyIsoCode && fs.Security_Status__c == oldFs.Security_Status__c && fs.Account__c == oldFs.Account__c && fs.ANG_Minimum_Financial_Security__c == oldFs.ANG_Minimum_Financial_Security__c && fs.ANG_Financial_Security_Currency__c == oldFs.ANG_Financial_Security_Currency__c){
					continue;
				}
			}
			accIdSet.add(fs.Account__c);
			financialSecurityToProcessLst.add(fs);

			if(fs.ANG_Minimum_Financial_Security__c !=null && fs.ANG_Financial_Security_Currency__c!=null && (Trigger.isInsert || (Trigger.isUpdate && (fs.ANG_Minimum_Financial_Security__c != oldMap.get(fs.id).ANG_Minimum_Financial_Security__c || fs.ANG_Financial_Security_Currency__c != oldMap.get(fs.id).ANG_Financial_Security_Currency__c || fs.Account__c != oldMap.get(fs.id).Account__c)))){
				calculateMinFsLst.add(fs); 
			}

		}

	}

	public void onBeforeInsert(){
		runValidations();
		convertFSAmount();
	}
	public void onAfterInsert(){
		calculateFinancialSecuritiesAmounts(true, true);
		calculateTotalAmmount_Int008();
	}

	public void onBeforeUpdate(){
		runValidations();
		convertFSAmount();
	}
	public void onAfterUpdate(){
		calculateFinancialSecuritiesAmounts(true, true);
		calculateTotalAmmount_Int008();
	}

	public void onBeforeDelete(){		
	}
	public void onAfterDelete(){
		calculateFinancialSecuritiesAmounts(true, false);
	}

	private void convertFSAmount(){
		if(!accIdSet.isEmpty())	ANG_Risk_Helper.convertFSAmount(triggerNew, accountsMap);
	}

	/**
	 * Calculate the Total and Minimum Financial Security amount and 
	 * update the correspondent amounts on the RHC information record
	 *
	 * @param  calculateTotalFs: Decides if the total financial security amount should be updated on the RHC
	 * @param  calculateMinFs:   Decides if the minimum financial security amount should be updated on the RHC 
	 */ 
	private void calculateFinancialSecuritiesAmounts(Boolean calculateTotalFs, Boolean calculateMinFs){
		
		if(accIdSet.isEmpty()){
			return;
		}

		Set<Id> acctsToFetchAllHierarchy = new Set<Id>();
		
		//List of financial securities for which the calculations will consider the entire hierarchy
		List<Financial_Security__c> includeAllAeFsLst = new List<Financial_Security__c>();

		for(Financial_Security__c fs : this.financialSecurityToProcessLst){
			
			//Skip the financial security 
			//is not suposed to update the RHC 
			if(!fs.ANG_isToUpdateRHC__c){
				continue;
			}

			Account acct = this.accountsMap.get(fs.Account__c);

			//If the related country has RHC LocationType = 'Include all AEs'
			//the Total/Minimum Financial Security amounts calculations must consider
			//financial security records from the entire hierarchy (not only HE's)
			if(acct.IATA_ISO_Country__r.ANG_RHC_LocationType__c == 'Include all AEs'){
				Id accId = acct.Top_Parent__c != NULL ? acct.Top_Parent__c : acct.Id;
				acctsToFetchAllHierarchy.add(accId);
				includeAllAeFsLst.add(fs);
			}
			//If it is required to update the Total FS amount on the RHC, 
			//the financial securities in status 'Active' or 'Close to Expiry Date' 
			//associated with the given account must be considered
			else if(calculateTotalFs && acct.RHC_Informations__r.size() == 1){
				decimal fsAmount = ANG_Risk_Helper.sumFSConvertedAmounts(acct.Financial_Securities__r);
				setFinancialSecurityOnRHC(acct, fsAmount);
			}

		}

		System.debug(LoggingLevel.FINE, '____ [cls ANG_FinancialSecurityTriggerHandler - calculateFinancialSecuritiesAmounts] includeAllAeFsLst: ' + includeAllAeFsLst);

		Map<Id, decimal> minFsAmountAggregatedByParent = new Map<Id, decimal>();

		if(!acctsToFetchAllHierarchy.isEmpty()){
			
			//Fetch all hierarchy accounts to process financial securities on associated entities for countries with RHC LocationType = 'Include all AEs'
			Map<Id, Account> allHierarchyAccountsMap = fetchAccountsInformation(acctsToFetchAllHierarchy, true);

			System.debug(LoggingLevel.FINE, '____ [cls ANG_FinancialSecurityTriggerHandler - calculateFinancialSecuritiesAmounts] All Hierarchy to fetch: ' + allHierarchyAccountsMap);

			//Aggregates the Total Financial Security amount per head entity
			Map<Id, decimal> totalFsAmountAggregatedByParent = new Map<Id, decimal>(); 

			for(Account acct : allHierarchyAccountsMap.values()){
				
				System.debug(LoggingLevel.FINE, '____ [cls ANG_FinancialSecurityTriggerHandler - calculateFinancialSecuritiesAmounts] FS List for account: ' + acct.Financial_Securities__r);

				if(acct.Financial_Securities__r != NULL && acct.Financial_Securities__r.size() > 0){
					
					//If the current account has a parent means that we have to aggregate the amounts by the parent
					Id accId = acct.Top_Parent__c != NULL ? acct.Top_Parent__c : acct.Id;

					//Sum all the financial security converted amounts and adds the resulting amount to the parent (if already exists on the map totalFsAmountAggregatedByParent)
					processAggregatedAmountsByAccount(accId, totalFsAmountAggregatedByParent, ANG_Risk_Helper.sumFSConvertedAmounts(acct.Financial_Securities__r));
					
					if(calculateMinFs){

						System.debug(LoggingLevel.FINE, '____ [cls ANG_FinancialSecurityTriggerHandler - calculateFinancialSecuritiesAmounts] Calculate Min FS for all hierarchy');

						Financial_Security__c lastModifiedFs = null;

						//Finds the last modified financial security in status 'Active' or 'Close to Expiry Date'
						//The list of financial securities per account are ordered by LastModifiedDate (DESC) 
						//(see query from fetchAccountsInformation method)  
						for(Financial_Security__c lmFS : acct.Financial_Securities__r){
							if(ANG_Risk_Helper.FS_STATUS_FOR_SUM_SET.contains(lmFS.Security_Status__c)){
								lastModifiedFs = lmFs;
								break;
							}
						}

						if(lastModifiedFs != NULL && lastModifiedFs.ANG_Financial_Security_Currency__c != NULL){
							System.debug(LoggingLevel.FINE, '____ [cls ANG_FinancialSecurityTriggerHandler - calculateFinancialSecuritiesAmounts] lastModifiedFs: ' + lastModifiedFs);
							//Aggregates by head entity (parent) the Minimum Financial Security amount from the given financial security (on the map minFsAmountAggregatedByParent)
							//Converts the Minimum Financial Security amount considering the RHC currency
							processAggregatedAmountsByAccount(accId, minFsAmountAggregatedByParent, ANG_Risk_Helper.currencyConverter(lastModifiedFs.ANG_Financial_Security_Currency__c, lastModifiedFs.ANG_Minimum_Financial_Security__c, ANG_Risk_Helper.accCurMap.get(accId) != NULL ? ANG_Risk_Helper.accCurMap.get(accId) : lastModifiedFs.ANG_Financial_Security_Currency__c));
						}

					}

				}
			}

			if(calculateTotalFs){
				System.debug(LoggingLevel.FINE, '____ [cls ANG_FinancialSecurityTriggerHandler - calculateFinancialSecuritiesAmounts] totalFsAmountAggregatedByParent: ' + totalFsAmountAggregatedByParent);
				for(Financial_Security__c fs : includeAllAeFsLst){
					Account acct = this.accountsMap.get(fs.Account__c);
					Id accId = acct.Top_Parent__c != NULL ? acct.Top_Parent__c : acct.Id;
					//Sets the total financial security amount on the related RHC considering the aggregated amount by head entity (parent)
					setTotalFinancialSecurityAmountOnRHC(accId, accId + ANG_RHCHelper.RHC_INFO_STD_RT, totalFsAmountAggregatedByParent.get(accId));
				}
			}
			
		}

		if(calculateMinFs){
			System.debug(LoggingLevel.FINE, '____ [cls ANG_FinancialSecurityTriggerHandler - calculateFinancialSecuritiesAmounts] calculateMinFsLst: ' + calculateMinFsLst);
			System.debug(LoggingLevel.FINE, '____ [cls ANG_FinancialSecurityTriggerHandler - calculateFinancialSecuritiesAmounts] minFsAmountAggregatedByParent: ' + minFsAmountAggregatedByParent);
			calculateMinimumFS(this.calculateMinFsLst, minFsAmountAggregatedByParent);
		}

		doDml();

	}
	
	/**
	 * Updates the minimum financial security amount on the related RHC records
	 *
	 * @param  fsLst:	Financial securities for which the related RHC records should be updated
	 * @param  minFsAmountAggregatedByParent: Minimum financial amount aggregated by parent (only for countries with RHC Location Type = 'Include all AEs')
	 */
	private void calculateMinimumFS(List<Financial_Security__c> fsLst, Map<Id, decimal> minFsAmountAggregatedByParent){

		ANG_Risk_Helper.accIdSet = this.accountsMap.keySet();

		for(Financial_Security__c fs : fsLst){

			Account acct = this.accountsMap.get(fs.Account__c);

			if(!fs.ANG_isToUpdateRHC__c) continue;

			//If the related country has RHC LocationType = 'Include all AEs'
			//the Minimum Financial Security amount considers 
			//the aggregated amounts for each head entity (parent)
			if(acct.IATA_ISO_Country__r.ANG_RHC_LocationType__c == 'Include all AEs'){
				Id accId = acct.Top_Parent__c != NULL ? acct.Top_Parent__c : acct.Id;
				String rhcKey = accId + ANG_RHCHelper.RHC_INFO_STD_RT;
				setMinFinancialSecurityAmountOnRHC(accId, rhcKey, minFsAmountAggregatedByParent.get(accId));
			}
			else {
				String rhcKey = fs.Account__c + ANG_RHCHelper.RHC_INFO_STD_RT;
				decimal minFsAmount = (ANG_Risk_Helper.FS_STATUS_FOR_SUM_SET.contains(fs.Security_Status__c) && fs.ANG_Financial_Security_Currency__c != NULL) ? ANG_Risk_Helper.currencyConverter(fs.ANG_Financial_Security_Currency__c, fs.ANG_Minimum_Financial_Security__c,ANG_Risk_Helper.accCurMap.get(fs.Account__c)!=null?ANG_Risk_Helper.accCurMap.get(fs.Account__c):fs.ANG_Financial_Security_Currency__c) : null;
				setMinFinancialSecurityAmountOnRHC(acct.Id, rhcKey, minFsAmount);
			}

		}

	}

	/**
	 * Adds a given amount to the given Account Id 
	 * 
	 * @param  accId                    Given Account Id
	 * @param  amountAggregatedByParent Map with aggregated amounts by Account Ids 
	 * @param  sumAmount                Given amount to add
	 */
	private void processAggregatedAmountsByAccount(Id accId, Map<Id, Decimal> amountAggregatedByParent, decimal sumAmount){
		decimal amount = amountAggregatedByParent.get(accId);
		if(amount == NULL){ 
			amount = 0; 
		}
		amountAggregatedByParent.put(accId, (amount + sumAmount));
	}

	/**
	 * Sets the total financial security amount on the account related RHC record 
	 * 
	 * @param  acct:     Given account for which the RHC record should be updated
	 * @param  fsAmount: Financial security amount to be set 
	 */
	private void setFinancialSecurityOnRHC(Account acct, Decimal fsAmount){

		if(acct.RHC_Informations__r.size() == 1){
			ANG_RHC_Information__c rhcInfo = acct.RHC_Informations__r.get(0);
			rhcInfo.ANG_UniqueKey__c = acct.Id + ANG_RHCHelper.RHC_INFO_STD_RT;
			if(rhcInfo.ANG_Financial_Security__c != fsAmount){
				rhcInfo.ANG_Financial_Security__c = fsAmount;
				map2Insert.put(rhcinfo.ANG_UniqueKey__c, rhcinfo);
			}
		}

	}

	/**
	 * Sets the given amount as the RHC minimum financial security amount
	 *
	 * @param  rhcKey:      RHC unique key identifier (Account Id + RHC RecordTypeId) 
	 * @param  minFsAmount: Minimum financial security amount to set
	 */
  private void setMinFinancialSecurityAmountOnRHC(Id AccountID, String rhcKey, Decimal minFsAmount){
		
		ANG_RHC_Information__c rhcInfo = map2Insert.get(rhcKey);
			
		if(rhcInfo == NULL){
			rhcInfo = new ANG_RHC_Information__c();
			rhcInfo.ANG_UniqueKey__c = rhcKey;
			rhcInfo.ANG_AccountId__c = AccountID;
		}

		rhcInfo.ANG_Minimum_Financial_Security__c = minFsAmount;
		map2Insert.put(rhcInfo.ANG_UniqueKey__c, rhcInfo);
	
	}

	/**
	 * Sets the given amount as the RHC total financial security amount
	 *
	 * @param  rhcKey:   RHC unique key identifier (Account Id + RHC RecordTypeId) 
	 * @param  fsAmount: Financial security amount to set
	 */
	private void setTotalFinancialSecurityAmountOnRHC(Id accountId, String rhcKey, Decimal fsAmount){
		
		ANG_RHC_Information__c rhcInfo = map2Insert.get(rhcKey);
			
		if(rhcInfo == NULL){
			rhcInfo = new ANG_RHC_Information__c();
			rhcInfo.ANG_UniqueKey__c = rhcKey;
			rhcInfo.ANG_AccountId__c = accountId;
		}

		rhcInfo.ANG_Financial_Security__c = fsAmount;
		map2Insert.put(rhcInfo.ANG_UniqueKey__c, rhcInfo);

	}

	private void doDml(){
		if(!map2Insert.values().isEmpty()){
			System.debug(LoggingLevel.FINE, '____ [cls ANG_FinancialSecurityTriggerHandler - doDml] RHC Records to upsert: ' + map2Insert);
			upsert map2Insert.values() ANG_UniqueKey__c;
		}
	}

	private void runValidations() {

		Set<Id> accsIds = new Set<Id>();
		List<SObject> fsToValidate = new List<SObject>();

		for(Financial_Security__c fs :triggerNew)
			if(Trigger.isInsert || (Trigger.isUpdate && fs.CurrencyIsoCode != oldMap.get(fs.Id).CurrencyIsoCode) )
				accsIds.add(fs.Account__c);
		
		Map<Id,Account> accsMap = new Map<Id,Account>([SELECT Id FROM Account WHERE Id IN :accsIds AND ANG_Accreditation_Model__c = 'Multicountry']);

		if(accsMap.isEmpty())
			return;

		for (SObject obj:Trigger.new)
			if(accsMap.containsKey(String.valueOf(obj.get('Account__c'))))
				fsToValidate.add(obj);
		
		AMS_Utils.runCurrencyValidations(fsToValidate, 'CurrencyIsoCode');
	}

	private void calculateTotalAmmount_Int008(){

		List<Financial_Security__c> fsList = new List<Financial_Security__c>();

		for(Financial_Security__c fs:triggerNew){
			if(Trigger.isUpdate){
				if(fs.Security_Status__c <> oldMap.get(fs.id).Security_Status__c){
					if(checkStatusChange(fs.Security_Status__c,oldMap.get(fs.id).Security_Status__c))
						fsList.add(fs);
				}else  if(fs.Amount__c <> oldMap.get(fs.id).Amount__c){
					if(fs.Security_Status__c == 'Active' || fs.Security_Status__c == 'Close to Expiry Date')
						fsList.add(fs);
				}
			} 
			else{
				if(Trigger.isInsert){
					if(fs.Security_Status__c == 'Active' || fs.Security_Status__c == 'Close to Expiry Date')
						fsList.add(fs);
				}
			}
		}
		
		if(fsList.isEmpty()) 
			return;

		if(Trigger.isUpdate)
			new ANG_AgencyEventsGenerator(fsList,oldMap,'Financial_Security__c','Account__c').run();

		if(Trigger.isInsert){

			oldMap =  new Map<Id,Financial_Security__c>();
		
			for(Financial_Security__c fs: fsList){
				oldMap.put(fs.Id, new Financial_Security__c(Id=fs.Id));
			}
			
			new ANG_AgencyEventsGenerator(fsList,oldMap,'Financial_Security__c','Account__c').run();

		}
	}

	public boolean checkStatusChange(String oldValue, String newValue){

		return statuschangeMatrix.contains(oldValue+newValue);

	}

	/**
	 * Called by ANG_CaseTriggerHandler when the Case field
	 * Financial_Security_Amount__c is updated, fired the process 
	 * to recalculate the FS Minimum Amount
	 */
	public void updateRHCInfoFSMinimumAmount(Set<Id> accountIds, List<Financial_Security__c> fsLst){
		this.accIdSet = accountIds;
		this.financialSecurityToProcessLst = fsLst;
		this.calculateMinFsLst = fsLst;
		calculateFinancialSecuritiesAmounts(false, true);
	}

	public void updateRhcInformationFSAmounts(Set<Id> accountIds, List<Financial_Security__c> fsLst, Boolean totalFsCalc, Boolean minFsCalc){
		this.accIdSet = accountIds;
		this.financialSecurityToProcessLst = fsLst;
		this.calculateMinFsLst = fsLst;
		calculateFinancialSecuritiesAmounts(totalFsCalc, minFsCalc);
	}

	@future
	public static void triggerFsAmountsRecalculation(Set<Id> accountIds, Boolean totalFsCalc, Boolean minFsCalc){

		List<Financial_Security__c> financialSecurities = new List<Financial_Security__c>(
			[SELECT 
				Id, 
				Amount__c,
				Account__c, 
				Security_Status__c,
				ANG_isToUpdateRHC__c, 
				ANG_Minimum_Financial_Security__c, 
				ANG_Financial_Security_Currency__c 
			 FROM 
			 	Financial_Security__c 
			 WHERE 
			 	Account__c IN :accountIds
			 AND
			 	Security_Status__c IN ('Close to Expiry Date','Active')
			]
		);
		
		System.debug(LoggingLevel.FINE, '____ [cls ANG_FinancialSecurityTriggerHandler - updateRhcInformationFSAmounts] Financial Securities - ' + financialSecurities);

		if(!financialSecurities.isEmpty()){
			ANG_FinancialSecurityTriggerHandler fsth = new ANG_FinancialSecurityTriggerHandler();
			fsth.updateRhcInformationFSAmounts(accountIds, financialSecurities, totalFsCalc, minFsCalc);
		}

	}
    
}
