public class ANG_RHCMassCalculation {

	// ******************************
	// ********** variables *********
	// ******************************
	private Id ifap = AMS_Utils.RECTYPE_IFAP; //need to fetch because dynamic queries only receive direct variables
	public static boolean bProvisionalRequested {get; set;}

	private static final Set<String> regionsToIgnore = new Set<String>{'GVA HO','Europe (Americas Countries)', 'Global'};
	private static final Map<String,String> userCaseRegionsMap = new Map<String,String>{
		'Africa & MENA' => 'Africa & Middle East',
		'Americas' => 'Americas',
		'Asia & Pacific' => 'Asia & Pacific',
		'Asia &  Pacific' => 'Asia & Pacific', // avoid issues with wrong API Picklist value on user.IDFS_Regoin__c
		'China & North Asia' => 'China & North Asia',
		'Europe' => 'Europe'
	};

	public Boolean searched { get; set; }
	public Boolean selectAll { get; set; }

	private static String NONE = '--None--';

	public Integer days {
		get {
			if (days == null)
				days = 0; // default value
			return days;
		}
		set;
	}

	public Boolean validDays {
		get {
			return days != null && days != 0;
		}
	}

	public String country {
		get {
			if (country == null)
				country = NONE; // default value
			return country;
		}
		set;
	}

	public Boolean validCountry {
		get {
			return country != null && country != NONE;
		}
	}

	public String userRegion { get; set; }
	
	public Boolean validRegion {
		get {
			return userRegion != null && userRegion != NONE;
		}
	}

	public List<SelectOption> regions {
		get {
			if (regions == null) {
				regions = new List<SelectOption>();
				regions.add(new SelectOption(NONE, 'Please select region'));
				for (Schema.PicklistEntry f : Case.Region__c.getDescribe().getPickListValues()) {
					if (!regionsToIgnore.contains(f.getValue()))
						regions.add(new SelectOption(f.getValue(), f.getLabel()));
				}
			}
			return regions;
		}
		private set;
	}

	public List<SelectOption> countries {
		get {
			countries = new List<SelectOption>();
			countries.add(new SelectOption(NONE, 'Select country'));
			if (userRegion != null) {
				for (IATA_ISO_Country__c c : [SELECT Id, ISO_Code__c, Name FROM IATA_ISO_Country__c WHERE region__c = :userRegion ORDER BY Name ASC])
					countries.add(new SelectOption(c.Id, c.Name));
			}
			return countries;
		}
		private set;
	}

	public boolean agentsFound	{get; set;}

	public map<id, Agent> agents {get; set;}

	public void PopulateRecordsToDisplay(list<ANG_RHC_Information__c> lsRHC){
		if (agents == null)
			agents = new map<id, Agent>();
		else
			agents.clear();
		
		for (ANG_RHC_Information__c r : lsRHC)
			agents.put(r.id, new Agent(r));
		
		agentsFound = agents.size()>0;
	}

	public ApexPages.StandardSetController paginator {get; set;}
	
	private Map<Id, Decimal> selectedAgents {
		get {
			if (selectedAgents == null)
				selectedAgents = new Map<Id, Decimal>();
			return selectedAgents;
		}
		set;
	}

	private Set<Id> skipBsps {
		get {
			if (skipBsps == null) {
				List<AMS_Settlement_System__c> bsps = [SELECT Id, name
													   FROM AMS_Settlement_System__c
													   WHERE Id IN (SELECT BSP__C
																	FROM ANG_BSP_Attributes__c
																	WHERE RecordTypeId = :ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG
																		AND RHC_Amnt_Calc_Type__c = :ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FIXED_PERC)];
				skipBsps = new Map<Id, AMS_Settlement_System__c>(bsps).keySet();
			}
			return skipBsps;
		}
		set;
	}

	// ******************************
	// ********* constructor ********
	// ******************************
	public ANG_RHCMassCalculation() {bProvisionalRequested=false;}

	// ******************************
	// ********** actions ***********
	// ******************************

	public void search() {
		System.debug(loggingLevel.DEBUG, '____ [cls ANG_RHCMassCalculation - search] searching');
		searched = validCountry || validDays; // true when valid search filters, false otherwise

		if(searched){
			paginator = null;
			
			if(agents!=null)
				agents.clear();
			selectedAgents.clear();
			selectAll = false;

			String query = '' // 
					+ ' SELECT Id , CurrencyIsoCode , ANG_AccountId__c , ANG_AccountId__r.IATACode__c , ANG_AccountId__r.IATA_ISO_Country__c, ' // 
					+ '	ANG_RHC_Amount__c, ANG_RHC_Amount_Forecasted__c, ANG_RHC_Amount_Provisional__c, ANG_RHC_Effective_Date__c, ANG_ConsumedRHC_Percent__c, ' // 
					+ '	ANG_Forecasted_RHC_Effective_date__c, ANG_ConsumedRHC__c, ANG_AccountId__r.Location_Type__c, ANG_Financial_Security__c ' // 
					+ ' FROM ANG_RHC_Information__c' // 
					+ ' WHERE ANG_CashCondition__c = false' // 
					+ ' 	AND ANG_AccountId__r.IATACode__c <> \'\' ' // 
					+ ' 	AND ANG_RHC_Amount_Equals_FS__c = false ' // 
					+ ' 	AND ANG_AccountId__r.ANG_CashCondition__c = false ' //
					+ ' 	AND ANG_AccountId__r.IATA_ISO_Country__r.AMS_Settlement_System__c NOT IN :skipBsps ' // 
					+ ' 	AND ANG_AccountId__r.ANG_Accreditation_Model__c = \'' + AMS_Utils.ACCREDITATIONMODEL_CASH + '\' ' // 
					+ ' 	AND ANG_AccountId__r.Location_Type__c != \'' + AMS_Utils.GE + '\'';
				
				if (validCountry)
					query += '' // 
						+ ' AND ANG_AccountId__r.IATA_ISO_Country__c = :country ' // 
						+ ' AND ANG_AccountId__r.Region_formula__c = :userRegion ';
				
				if (validDays)
					query += '' // 
						+ ' AND ANG_AccountId__c IN (SELECT AccountId ' // 
						+ ' 						 FROM Case ' // 
						+ ' 						 WHERE RecordTypeId = :ifap ' // 
						+ ' 							AND isClosed = true ' // 
						+ ' 							AND ClosedDate = LAST_N_DAYS:' + days + ' ' // 
						+ ' 							AND Region__c = :userRegion)';
				
				query += ' ORDER BY ANG_AccountId__r.IATACode__c ASC ';

			paginator = new ApexPages.StandardSetController(Database.query(query));
			paginator.setPageSize(100);
			PopulateRecordsToDisplay((list<ANG_RHC_Information__c>)paginator.getRecords());
		}
	}

	public void regionSelected() {
		days = 0;
		country = NONE;
	}

	public Integer pageNumber {
		get {
			return paginator.getPageNumber();
		}
		set;
	}

	public void previous() {
		paginator.previous();
		PopulateRecordsToDisplay((list<ANG_RHC_Information__c>)paginator.getRecords());
	}
	
	public void next() {
		paginator.next();
		PopulateRecordsToDisplay((List<ANG_RHC_Information__c>)paginator.getRecords());
	}
	
	public void last() {
		paginator.last();
		PopulateRecordsToDisplay((List<ANG_RHC_Information__c>)paginator.getRecords());
	}
	
	public void first() {
		paginator.first();
		PopulateRecordsToDisplay((List<ANG_RHC_Information__c>)paginator.getRecords());
	}


	public Integer totalPages{
		get{
			return Math.ceil((Decimal)paginator.getResultSize()/100).intValue();
		}
	}

	// ******************************
	// ********** wrappers **********
	// ******************************
	public class Agent {
		public Boolean selected { get; set; }
		
		public Boolean hasProvResult { get; set; }
		public Boolean hasProvError { get; set; }
		public string ProvErrorDesc	{get; set;}

		public boolean hasRHCResult	{get; set;}
		public boolean hasRHCError	{get; set;}
		public string RHCErrorDesc	{get; set;}
		
		public string AccntId {get; set;}
		public ANG_RHC_Information__c rhcInfo { get; set; }
		public Decimal currentAmount { get; set; }
		public decimal calculatedConsumedRHC { get; set; }
		
		//
		//public boolean hasError	{get; set;}
		//public string ErrorDescription	{get; set;}
		
		public decimal ANG_RHC_Amount_Provisional	{get; set;}
		public decimal ANG_RHC_Amount_ProvisionalTMP	{get; set;}
		public decimal ANG_RHC_Amount_Forecasted	{get; set;}

		private Agent(ANG_RHC_Information__c r){
			this.selected = false;
			
			this.hasProvResult = false;
			this.hasProvError = false;
			this.ProvErrorDesc = null;

			this.hasRHCResult = false;
			this.hasRHCError = false;
			this.RHCErrorDesc = null;

			this.AccntId = r.ANG_AccountId__c;
			this.rhcInfo = r;
			this.currentAmount = r.ANG_RHC_Amount__c;
			this.calculatedConsumedRHC = null;
			
			this.ANG_RHC_Amount_Provisional = null;
			this.ANG_RHC_Amount_ProvisionalTMP = null;
			this.ANG_RHC_Amount_Forecasted = null;
		}
	}

	public PageReference doNothing(){return null;}

	@RemoteAction
	public static ANG_RME_Alert_Service.WebserviceResult RequestProvisionalToRME(string RHCId){
		ANG_RHC_Information__c theRHC = [SELECT Id , CurrencyIsoCode , ANG_AccountId__c , ANG_AccountId__r.IATACode__c , ANG_AccountId__r.IATA_ISO_Country__c, 
											ANG_RHC_Amount__c, ANG_RHC_Amount_Forecasted__c, ANG_RHC_Amount_Provisional__c, ANG_RHC_Effective_Date__c,ANG_Financial_Security__c,
											ANG_Forecasted_RHC_Effective_date__c, ANG_ConsumedRHC__c, ANG_AccountId__r.Location_Type__c, RHC_Amount_Equals_FS_Percent__c,
											ANG_RHC_Amount_Equals_FS__c, ANG_CashCondition__c, ANG_RME_Amount__c, ANG_Account_Country_ISO_Code__c, ANG_ConsumedRHC_Percent__c, ANG_Consumed_RHC_Date__c,
											ANG_ConsumedRHC_Last_Update__c, ANG_Enable_Calculation__c, ANG_Exceeding_Financial_Security__c, ANG_IATA_Code__c, ANG_Minimum_Financial_Security__c, 
											ANG_Provisional_RHC_Last_Update__c, ANG_RME_Amount_Provisional__c, ANG_RME_Amount_Last_Update__c
										FROM ANG_RHC_Information__c where Id = :RHCId];

		return ANG_RME_Alert_Service.requestProvisionalRHC(theRHC, false);
	}

	@RemoteAction
	public static CalculateRHCWrapper CalculateRHCAmount(string RHCId, string ProvisionalRHC, boolean bCommitRHC){
		ANG_RHC_Information__c theRHC = [SELECT Id , CurrencyIsoCode , ANG_AccountId__c , ANG_AccountId__r.IATACode__c , ANG_AccountId__r.IATA_ISO_Country__c, 
											ANG_RHC_Amount__c, ANG_RHC_Amount_Forecasted__c, ANG_RHC_Amount_Provisional__c, ANG_RHC_Effective_Date__c,ANG_Financial_Security__c,
											ANG_Forecasted_RHC_Effective_date__c, ANG_ConsumedRHC__c, ANG_AccountId__r.Location_Type__c, RHC_Amount_Equals_FS_Percent__c,
											ANG_RHC_Amount_Equals_FS__c, ANG_CashCondition__c, ANG_RME_Amount__c, ANG_Account_Country_ISO_Code__c, ANG_ConsumedRHC_Percent__c, ANG_Consumed_RHC_Date__c,
											ANG_ConsumedRHC_Last_Update__c, ANG_Enable_Calculation__c, ANG_Exceeding_Financial_Security__c, ANG_IATA_Code__c, ANG_Minimum_Financial_Security__c, 
											ANG_Provisional_RHC_Last_Update__c, ANG_RME_Amount_Provisional__c, ANG_RME_Amount_Last_Update__c
										FROM ANG_RHC_Information__c where Id = :RHCId];
		
		CalculateRHCWrapper oReturn = new CalculateRHCWrapper();
		try{
			if(ProvisionalRHC!=null && ProvisionalRHC!='')
				theRHC.ANG_RHC_Amount_Provisional__c = decimal.valueOf(ProvisionalRHC);
			
			ANG_RHCHelper.calculateRHCAmount(theRHC, bCommitRHC);
			
			oReturn.ForecastedRHC = theRHC.ANG_RHC_Amount_Forecasted__c;
			oReturn.RHCId = theRHC.Id;

			if(bCommitRHC)	update theRHC;

			oReturn.hasRHCResult = true;
		}catch(exception e){
			oReturn.hasRHCError = true;
			oReturn.RHCErrorDesc = e.getMessage();
		}
		
		
		return oReturn;
	}

	public string theSerializedProvisional {get; set;}
	public string theSerializedRHCWrapper {get; set;}

	public void AfterProvisional(){
		bProvisionalRequested = true;
		list<ProvisionalRMEWrapper> lsProvisionalWrapper = new list<ProvisionalRMEWrapper>();
		lsProvisionalWrapper = (list<ProvisionalRMEWrapper>)JSON.deserialize(theSerializedProvisional, list<ProvisionalRMEWrapper>.class);
		
		for(ProvisionalRMEWrapper wr:lsProvisionalWrapper){
			system.debug('DTULLO ProvisionalRMEWrapper --> ' + wr);
			if(wr.RHCId!='' && agents.containsKey(wr.RHCId)){
				agent ag = agents.get(wr.RHCId);
				if(wr.hasProvResult){
					ag.hasProvResult = true;
					ag.ANG_RHC_Amount_Provisional = wr.ProvAmnt;
				} else {
					ag.hasProvError = true;
					ag.ProvErrorDesc = wr.ProvErrorDesc;
				}
			}
		}
	}

	public void AfterRHCCalculation(){
		list<CalculateRHCWrapper> lsRHCWrapper = new list<CalculateRHCWrapper>();
		lsRHCWrapper = (list<CalculateRHCWrapper>)JSON.deserialize(theSerializedRHCWrapper, list<CalculateRHCWrapper>.class);
		
		for(CalculateRHCWrapper wr:lsRHCWrapper){
			if(wr.RHCId!='' && agents.containsKey(wr.RHCId)){
				agent ag = agents.get(wr.RHCId);
				if(wr.hasRHCResult){
					ag.hasRHCResult = true;
					ag.ANG_RHC_Amount_Forecasted = wr.ForecastedRHC;
					if(ag.rhcInfo.ANG_ConsumedRHC__c == null || ag.rhcInfo.ANG_ConsumedRHC__c ==0)
						ag.calculatedConsumedRHC = null;
					else{
						if(wr.ForecastedRHC == null || wr.ForecastedRHC==0)
							ag.calculatedConsumedRHC = null;
						else {
							ag.calculatedConsumedRHC = (ag.rhcInfo.ANG_ConsumedRHC__c / wr.ForecastedRHC * 100);
						}
					}
				}else{
					ag.hasRHCError = true;
					ag.RHCErrorDesc = wr.RHCErrorDesc;
				}
			}
		}
	}

	public class CalculateRHCWrapper{
		public boolean hasRHCResult {get; set;}
		public boolean hasRHCError {get; set;}
		public string RHCErrorDesc	{get; set;}

		public string RHCId	{get; set;}
		public decimal ForecastedRHC {get; set;}
	}

	public class ProvisionalRMEWrapper{
		public boolean hasProvResult{get; set;}
		public boolean hasProvError	{get; set;}
		public string ProvErrorDesc	{get; set;}

		public string RHCId			{get; set;}
		public decimal ProvAmnt		{get; set;}
	}
}
