public class AMS_DemoTreeview {

	private static final Set<String> ACTIVE_ACC_STATUS = new Set<String>{AMS_Utils.ACC_S9_APPROVED, AMS_Utils.ACC_S8_CHANGESPROCESSED, AMS_Utils.ACC_S7_UNDERREVIEW,
																	AMS_Utils.ACC_S6_CASHWITHCOMMISSION, AMS_Utils.ACC_S5_CASHNOCOMMISSION, AMS_Utils.ACC_S4_LISTED};

	public Account currentAccount {get;set;}
	public Account parentAccount {get;set;}
	public Boolean isHQ {get;set;}
	public AMS_OSCAR__c currentOscar {get;set;}
	public Map<Id,String> accreditationAreas {get;set;}
	public Map<String,String> accreditationAreasOKNOK {get;set;}
	public Map<String,Boolean> accountsActive {get; set;}
	public Map<Id,Account> acctsMap {get;set;}
	public Id currentCaseId {get;set;}

	public AMS_DemoTreeview(ApexPages.StandardController stdController) {

		Id objectId = ApexPages.currentPage().getParameters().get('id');

		if(objectId == null)
			return;

		SObjectType sObjectType = stdController.getRecord().getSObjectType();

		if(sObjectType == Account.sObjectType){
			this.currentAccount = (Account)stdController.getRecord();
		}

		if(sObjectType == Case.sObjectType){

			this.currentOscar = new AMS_OSCAR__c( Id = [Select OSCAR__c from Case where Id= :objectId LIMIT 1].OSCAR__c);

			this.currentAccount = new Account(Id = [Select Account__c, Account__r.IATACode__c from AMS_OSCAR__c where Id = :currentOscar.Id LIMIT 1].Account__c);
		}


		this.parentAccount = fetchHierchyParent();

	}

	public AMS_DemoTreeview() {

		Id objectId = ApexPages.currentPage().getParameters().get('id');

		if(objectId == null)
			return;

		this.currentCaseId = objectId;

		this.currentOscar = new AMS_OSCAR__c( Id = [Select OSCAR__c from Case where Id= :objectId LIMIT 1].OSCAR__c);

		this.currentAccount = [Select Id, IATACode__c from Account where Id in (Select Account__c from AMS_OSCAR__c where Id = :currentOscar.Id) LIMIT 1];

		this.parentAccount = fetchHierchyParent();

		this.accreditationAreas = fetchAccreditationAreas();

		this.accreditationAreasOKNOK = fetchOKNokAgencies(this.currentOscar);
		System.debug('accreditationAreas are' + accreditationAreas);
	}


	 //Get first Parent in the Hierarchy
	public Account  fetchHierchyParent(){
		Boolean top = false;
		Id objId = this.currentAccount.id;
		List<AMS_Agencies_relationhip__c> lastaux = null;

		while (!top) {
			List<AMS_Agencies_relationhip__c> aux = [select id,Parent_Account__c,Hierarchy__c from AMS_Agencies_relationhip__c where Child_Account__c =: objId];
		if(aux.size() > 0)
		{
			objId = aux.get(0).Parent_Account__c;
			lastaux = aux;
		}
		else
			top = true;
		}

		Id contextId;
		if (lastaux != null)
			contextId = lastaux.get(0).Parent_Account__c;

		else
			contextId= this.currentAccount.id;

		return [select id,Name, IATACode__c, Status__c, BillingCountry, BillingCity, Location_Type__c,Location_Class__c
								from Account  where id =: contextId];
	}

	public Map<Account, List<Account>> getHierchyChilds() {
		Map<Account, List<Account>> accountHierMap = new Map<Account, List<Account>>();
		
		boolean firstRun = true;
		this.acctsMap = new Map<Id, Account>();
		for (AMS_Agencies_relationhip__c relFirstLevel : [SELECT Id, Parent_Account__c, Child_Account__c, Hierarchy__c,
																 Parent_Account__r.IATACode__c, Child_Account__r.IATACode__c
															 FROM AMS_Agencies_relationhip__c
															 WHERE Parent_Account__c = :this.parentAccount.Id]) {
			if (firstRun) { // get Accts Info in the first loop
				firstRun = false;
				this.acctsMap = getFullHierarchyAccountsInfo(relFirstLevel.Hierarchy__c);
			}
			
			accountHierMap.put(this.acctsMap.get(relFirstLevel.Child_Account__c), new List<Account>());
		}
		
		for (AMS_Agencies_relationhip__c relSecondLevel : [SELECT Id, Parent_Account__c, Child_Account__c, Hierarchy__c,
																  Parent_Account__r.IATACode__c, Child_Account__r.IATACode__c
															  FROM AMS_Agencies_relationhip__c
															  WHERE Parent_Account__c IN :accountHierMap.keyset()]) {
			accountHierMap.get(acctsMap.get(relSecondLevel.Parent_Account__c)).add(acctsMap.get(relSecondLevel.Child_Account__c));
		}
		
		return accountHierMap;
	}

	public class HierarchyWrapper {
		public Account account { get; set; }
		public List<Account> children { get; set; }
		public Boolean hasChildren {
			get {
				return !children.isEmpty();
			}
		}
		public HierarchyWrapper(Account account, List<Account> children) {
			this.account = account;
			this.children = children;
		}
	}

	public List<HierarchyWrapper> fullHierarchy {
		get {
			if (fullHierarchy == null) {
				Map<Account, List<Account>> m = getHierchyChilds();
				fullHierarchy = new List<HierarchyWrapper>();
				for (Account a : m.keySet())
					fullHierarchy.add(new HierarchyWrapper(a, m.get(a)));
			}

			return fullHierarchy;
		}
		set;
	}

	private Map<Id, Account> getFullHierarchyAccountsInfo(Id hierarchyId) {
		
		Set<Id> acctIds = new Set<Id>();
		
		for (AMS_Agencies_relationhip__c relHier : [SELECT id, Child_Account__c, Parent_Account__c, Parent_Account__r.IATACode__c,
														Child_Account__r.IATACode__c
													FROM AMS_Agencies_relationhip__c
													WHERE Hierarchy__c = :hierarchyId]) {
			acctIds.add(relHier.Child_Account__c);
			acctIds.add(relHier.Parent_Account__c);
		}
		
		return new Map<Id, Account>([SELECT id, Name, IATACode__c, Status__c, BillingCountry, BillingCity, Location_Type__c,
										 Location_Class__c
									 FROM Account
									 WHERE id IN :acctIds]);
	}

	private Map<Id,String> fetchAccreditationAreas(){

		Map<Id,String> toReturn = new Map<Id,String>();

		Map <Account,List<Account>> mapHierarchy = getHierchyChilds();

		List<List<Account>> allAccountsMap = mapHierarchy.values();

		Set<Id> accountIds = new Set<Id>();

		System.debug('allAccountsMap are:'+allAccountsMap);
		System.debug('mapHierarchy are:'+mapHierarchy);

		For(List<Account> lstAccounts :allAccountsMap)
			For(Account acct: lstAccounts)
				accountIds.add(acct.Id);

		For(Account acct: mapHierarchy.keySet()){
			accountIds.add(acct.Id);
		}

		accountIds.add(this.parentAccount.id);

		System.debug('accountIds are ' + accountIds);

	   List<AMS_Pax_Accreditation_Form__c> accreditationAreas =  [select Id,HO_Account__c from AMS_Pax_Accreditation_Form__c where HO_Account__c in:accountIds and SAAM_Case__c = :currentCaseId];

	   For(AMS_Pax_Accreditation_Form__c pax: accreditationAreas){

			toReturn.put(pax.HO_Account__c,pax.Id);

	   }


		For(Id accountId: accountIds){
			if(toReturn.get(accountId) == null)
				toReturn.put(accountId,'XXX');
	   }

	   system.debug('toReturn is:'+toReturn);

	   return toReturn;
	}

	public Map<String,String> fetchOKNokAgencies(AMS_OSCAR__c oscarId){

		Map<String,String> toReturn = new Map<String,String>();

		AMS_OSCAR__C oscar =  [Select Id ,IATA_Codes_OK__c, IATA_Codes_NOK__c from AMS_OSCAR__c where Id= :oscarId.Id LIMIT 1];

		String iatacodesOK = oscar.IATA_Codes_OK__c;
		String iatacodesNOK = oscar.IATA_Codes_NOK__c;

		if(oscar.IATA_Codes_OK__c <> null){
			iatacodesOK = iatacodesOK.replace('\r\n', '');
			iatacodesOK = iatacodesOK.replace('\n', '');
			iatacodesOK = iatacodesOK.replace('\r', '');
		}
		if(oscar.IATA_Codes_NOK__c <> null){
			iatacodesNOK = iatacodesNOK.replace('\r\n', '');
			iatacodesNOK = iatacodesNOK.replace('\n', '');
			iatacodesNOK = iatacodesNOK.replace('\r', '');
		}

		List<String> iATA_Codes_OK =  oscar.IATA_Codes_OK__c == null ? new List<String>() : iatacodesOK.split(',');
		List<String> iATA_Codes_NOK = oscar.IATA_Codes_NOK__c == null ? new List<String>() : iatacodesNOK.split(',');

		Set<String> iATA_Codes_OK_set = new Set<String>();
		Set<String> iATA_Codes_NOK_set = new Set<String>();

		iATA_Codes_OK_set.addAll(iATA_Codes_OK);
		iATA_Codes_NOK_set.addAll(iATA_Codes_NOK);

		For(String iataOK: iATA_Codes_OK)
			toReturn.put(iataOK,'OK');

		For(String iataNOK: iATA_Codes_NOK)
			toReturn.put(iataNOK,'NOK');

		accountsActive = new Map<String,Boolean>();

		For(Account acct: acctsMap.values()){

			if(toReturn.get(acct.IATACode__c) == null)
				toReturn.put(acct.IATACode__c,'UNK');

			accountsActive.put(acct.IATaCode__c, ACTIVE_ACC_STATUS.contains(acct.status__c));


		}

		if(toReturn.get(this.parentAccount.IATACode__c) == null){

			if(iATA_Codes_OK_set.contains(this.parentAccount.IATACode__c))
				toReturn.put(this.parentAccount.IATACode__c,'OK');
			else if(iATA_Codes_NOK_set.contains(this.parentAccount.IATACode__c))
				toReturn.put(this.parentAccount.IATACode__c,'NOK');
			else toReturn.put(this.parentAccount.IATACode__c,'UNK');
		}

		System.debug('toReturn is ' + toReturn);

		return toReturn;
	}


}