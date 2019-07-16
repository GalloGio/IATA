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

	private static Set<String> newgenLocationTypes = new Set<String>{AMS_Utils.HE, AMS_Utils.AE};

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

	private set<id> accIdSet{
		get{
			if(accIdSet==null){
				accIdset = new set<id>();
				if(Trigger.isDelete){
					for(Financial_Security__c fs:triggerOld){
						accIdSet.add(fs.Account__c);
					}
				}else{
					for(Financial_Security__c fs:triggerNew){	
						if(Trigger.isUpdate && fs.Amount__c == oldMap.get(fs.id).Amount__c && fs.CurrencyIsoCode == oldMap.get(fs.id).CurrencyIsoCode && fs.Security_Status__c ==oldMap.get(fs.id).Security_Status__c && fs.Account__c == oldMap.get(fs.id).Account__c 
							&& fs.ANG_Minimum_Financial_Security__c == oldMap.get(fs.id).ANG_Minimum_Financial_Security__c && fs.ANG_Financial_Security_Currency__c == oldMap.get(fs.id).ANG_Financial_Security_Currency__c) continue;
							accIdSet.add(fs.Account__c);
					}
				}							
			}
			return accIdSet;
		}
		set;
	}

	/**
	 * Get all the Parent account ID 
	 * to be used on the query to load all the account hiearchy
 	 */
	private Set<ID> parentIDSet{
		get{
			if(parentIDSet == null){
				parentIDSet = new Set<ID>();
				for(Account acc : mapAccount.values()){
					if(acc.IATA_ISO_Country__r.ANG_RHC_LocationType__c == 'Include all AEs' && acc.ParentId != null) parentIDSet.add(acc.ParentId);
					else parentIDSet.add(acc.ID);
				}
			}
			return parentIDSet;
		}			
		set;
	}


	/**
	 * Build map<ID, Account> for the accounts 
	 * financial Security modified/inserted
	 */
	private Map<Id, Account> mapAccount{
		get{
			if(mapAccount == null){
				mapAccount = fetchAccountsInformation(accIdSet, null, newgenLocationTypes);
			}
			return mapAccount;
		}	
		set;	
	}

	private Map<Id, Account> fetchAccountsInformation(Set<Id> accIdSet, Set<Id> parentIdSet, Set<String> locationTypesSet){
		
		String accountsQuery = '' +
			'SELECT Id, ParentId, Location_Type__c, IATA_ISO_Country__r.CurrencyIsoCode, IATA_ISO_Country__r.ANG_RHC_LocationType__c, ' +
			' (SELECT Id, CurrencyIsoCode FROM RHC_Informations__r), ' +
			' (SELECT Id, Amount__c, Account__c, CurrencyIsoCode, Security_Status__c, ANG_ConvertedAmount__c, ANG_Minimum_Financial_Security__c, ANG_Financial_Security_Currency__c FROM Financial_Securities__r) ' +
			'FROM Account WHERE Location_Type__c IN :locationTypesSet AND (Id IN :accIdSet';

		if(parentIdSet != NULL && !parentIdSet.isEmpty()){
			accountsQuery += ' OR Id IN :parentIdSet OR ParentId IN :parentIdSet ';
		}

		accountsQuery += ') ';

		return new Map<Id, Account>((List<Account>) Database.query(accountsQuery));
	}
	
	public void onBeforeInsert(){
		convertFSAmount();
	}
	public void onAfterInsert(){
		calculateFSTotal_updateMinimumFS();
		//updateMinimumFS();
		calculateTotalAmmount_Int008();
	}

	public void onBeforeUpdate(){
		convertFSAmount();
	}
	public void onAfterUpdate(){
		calculateFSTotal_updateMinimumFS();
		//updateMinimumFS();
		calculateTotalAmmount_Int008();
	}

	public void onBeforeDelete(){		
	}
	public void onAfterDelete(){
		calculateFSTotal_updateMinimumFS();
	}

	private void convertFSAmount(){
		if(!accIdSet.isEmpty())	ANG_Risk_Helper.convertFSAmount(triggerNew, mapAccount);
	}

	private void calculateFSTotal_updateMinimumFS(){

		if(!accIdSet.isEmpty()){
			//Map used to calculate the Total FS 
			Map<ID, Decimal> totalFinancialSecurityPerAccount = new Map<ID, Decimal>();
			//Map used to calculate the Minimum FS 
			Map<ID, Decimal> minimumFinancialSecurityPerAccount = new Map<ID, Decimal>();
			//List of accounts to be matched with the RHC Information objects
			List<Account> parentAccount = new List<Account>();

			Map<ID, Account> accountMap = null;
			if(accIdSet.containsAll(parentIDSet)){
				accountMap = mapAccount;
			}
			else {
				//Get all accounts in the hierarchy - Only for Countries with ANG_RHC_LocationType__c == 'Include all AEs'
				accountMap = fetchAccountsInformation(accIdSet, parentIdSet, newgenLocationTypes);
			}

			//Iterate accounList - create new FS list and new map account
			//Ensure that all the Financial Security of the hierarchy has the same currency 
			list<Financial_Security__c> fsListToConvert = new list<Financial_Security__c>();
			Map<ID, Account> mapAccountbyId = new Map<ID, Account>();
			Map<Id, List<Financial_Security__c>> financialSecurityByAccountID = new Map<Id, List<Financial_Security__c>>();

			Map<ID, Financial_Security__c> mapFinancialSecurities = new Map<ID, Financial_Security__c>();

			for(Account acc : accountMap.values()){
				financialSecurityByAccountID.put(acc.id, new List<Financial_Security__c>());

				//Fill parentAccount list to update the RHC Infomation object
				if(acc.RHC_Informations__r.size() == 1)	parentAccount.add(acc);
				
				for(Financial_Security__c fs : acc.Financial_Securities__r){
					financialSecurityByAccountID.get(acc.id).add(fs);
					
					if(newMap != null && !newMap.containsKey(fs.id)) {
						fsListToConvert.add(fs);
						mapAccountbyId.put(acc.id, acc);
					}
				}
			}

			//Align all the FS currencies with the RHC Information currency
			if(!fsListToConvert.isEmpty() && !mapAccountbyId.isEmpty()) ANG_Risk_Helper.convertFSAmount(fsListToConvert, mapAccountbyId);

			//Calculate the Minimum and Total FS
			for(Account acc :accountMap.values()){

				if(!financialSecurityByAccountID.get(acc.id).isEmpty()){
					
					ID accountID = acc.ParentId != NULL && acc.IATA_ISO_Country__r.ANG_RHC_LocationType__c == 'Include all AEs' ? acc.ParentId : acc.id ;
					
					//Total FS calculation
					totalFinancialSecurityPerAccount.put(accountID, getCurrentFSValue(totalFinancialSecurityPerAccount.get(accountID)) + ANG_Risk_Helper.sumFSConvertedAmounts(financialSecurityByAccountID.get(acc.id)));
					
					//Minimum FS calculation
					for(Financial_Security__c fs : financialSecurityByAccountID.get(acc.id)){

						if(fs.ANG_Minimum_Financial_Security__c !=null && fs.ANG_Financial_Security_Currency__c!=null && ANG_Risk_Helper.FS_STATUS_FOR_SUM_SET.contains(fs.Security_Status__c)){
                            String rhcCurrencyCode = accountMap.get(accountID).RHC_Informations__r.isEmpty() ? null : accountMap.get(accountID).RHC_Informations__r.get(0).CurrencyIsoCode;
							minimumFinancialSecurityPerAccount.put(accountID, 
								getCurrentFSValue(minimumFinancialSecurityPerAccount.get(accountID)) + ANG_Risk_Helper.currencyConverter(fs.ANG_Financial_Security_Currency__c , fs.ANG_Minimum_Financial_Security__c, rhcCurrencyCode != null ? rhcCurrencyCode : fs.ANG_Financial_Security_Currency__c));
						}
					}
				}
			}
			
			//Match information with RHC Information
			for(Account acc : parentAccount){

				ANG_RHC_Information__c rhcinfo=new ANG_RHC_Information__c(
					id =acc.RHC_Informations__r.get(0).id,
					ANG_UniqueKey__c=acc.id+ANG_RHCHelper.RHC_INFO_STD_RT,
					ANG_AccountId__c=acc.id,
					ANG_Financial_Security__c = totalFinancialSecurityPerAccount.containsKey(acc.Id) ? totalFinancialSecurityPerAccount.get(acc.Id) : 0,
					ANG_Minimum_Financial_Security__c = minimumFinancialSecurityPerAccount.containsKey(acc.Id) ? minimumFinancialSecurityPerAccount.get(acc.ID) : 0
				);					
				map2Insert.put(rhcinfo.ANG_UniqueKey__c,rhcinfo);
			}
		}
		//Apply RHC changes
		doDml();	
	}

	/**
	 * Get current Financial Security value  
	 * based on the received parameter
	 */
	private Decimal getCurrentFSValue(Decimal currentFS){
		if(currentFS == null) return 0; 
		else return currentFS; 
	}


	private void doDml(){
		if(!map2Insert.values().isEmpty())upsert map2Insert.values() ANG_UniqueKey__c;
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
	public void updateRHCInfoFSMinimumAmount(Set<Id> accountIDs){
		accIdSet = accountIDs;
		calculateFSTotal_updateMinimumFS();
	}

}
