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
			agents = null;
			selectAll = false;

			String query = '' // 
					+ ' SELECT Id , CurrencyIsoCode , ANG_AccountId__c , ANG_AccountId__r.IATACode__c , ANG_AccountId__r.IATA_ISO_Country__c, ' // 
					+ '	ANG_RHC_Amount__c, ANG_RHC_Amount_Forecasted__c, ANG_RHC_Amount_Provisional__c, ANG_RHC_Effective_Date__c, ANG_ConsumedRHC_Percent__c, ' // 
					+ '	ANG_ConsumedRHC__c, ANG_AccountId__r.Location_Type__c, ANG_Financial_Security__c ' // 
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
		public boolean bIsSuccess {get; set;}
		public String ErrorDescription	{get; set;}

		public ANG_RHC_Information__c rhcInfo { get; set; }
		public decimal calculatedConsumedRHC { get; set; }

		public decimal ANG_RHC_Amount_Provisional	{get; set;}
		public decimal ANG_RHC_Amount_ProvisionalTMP	{get; set;}
		public decimal ANG_RHC_Amount_Forecasted	{get; set;}
		
		private Agent(ANG_RHC_Information__c r){
			this.selected = false;
			this.bIsSuccess = false;
			this.ErrorDescription = null;

			this.rhcInfo = r;
			this.calculatedConsumedRHC = null;
			
			this.ANG_RHC_Amount_Provisional = null;
			this.ANG_RHC_Amount_ProvisionalTMP = null;
			this.ANG_RHC_Amount_Forecasted = null;
		}
	}

	public PageReference doNothing(){return null;}

	@RemoteAction
	public static ResponseWrapper RequestProvisionalAndCalculateRHC(string RHCId, boolean bCommitRHC){
		ResponseWrapper oResponse = new ResponseWrapper();
		oResponse.RHCId = RHCId;

		ANG_RHC_Information__c theRHC = [SELECT Id , CurrencyIsoCode , ANG_AccountId__c , ANG_AccountId__r.IATACode__c , ANG_AccountId__r.IATA_ISO_Country__c, 
											ANG_RHC_Amount__c, ANG_RHC_Amount_Forecasted__c, ANG_RHC_Amount_Provisional__c, ANG_RHC_Effective_Date__c,ANG_Financial_Security__c,
											ANG_ConsumedRHC__c, ANG_AccountId__r.Location_Type__c, RHC_Amount_Equals_FS_Percent__c,
											ANG_RHC_Amount_Equals_FS__c, ANG_CashCondition__c, ANG_RME_Amount__c, ANG_Account_Country_ISO_Code__c, ANG_ConsumedRHC_Percent__c, ANG_Consumed_RHC_Date__c,
											ANG_ConsumedRHC_Last_Update__c, ANG_Enable_Calculation__c, ANG_Exceeding_Financial_Security__c, ANG_IATA_Code__c, ANG_Minimum_Financial_Security__c, 
											ANG_Provisional_RHC_Last_Update__c, ANG_RME_Amount_Provisional__c, ANG_RME_Amount_Last_Update__c
										FROM ANG_RHC_Information__c where Id = :RHCId];
		
		boolean bProvSuccess = false;
		try{
			ANG_RME_Alert_Service.WebserviceResult RMEResponse = ANG_RME_Alert_Service.requestProvisionalRHC(theRHC, false);
			if(RMEResponse.isSuccess){
				bProvSuccess = true;
				oResponse.ANG_RHC_Amount_Provisional = RMEResponse.res.provisionalRHC;
				//theRHC.ANG_RHC_Amount_Provisional__c = result.res.provisionalRHC;
			}else{
				oResponse.bIsSuccess = false;
				oResponse.ErrorDescription = RMEResponse.description;
			}
		}catch(Exception e){
			oResponse.bIsSuccess = false;
			oResponse.ErrorDescription = e.getMessage();
		}

		if(bProvSuccess){
			try{
				ANG_RHCHelper.calculateRHCAmount(theRHC, bCommitRHC);
				oResponse.ANG_RHC_Amount_Forecasted = theRHC.ANG_RHC_Amount_Forecasted__c;
				
				if(bCommitRHC){
					theRHC.ANG_RME_Amount__c = oResponse.ANG_RHC_Amount_Provisional;
					update theRHC;
				}
				
				oResponse.bIsSuccess = true;
				oResponse.ErrorDescription = '';
			}catch(Exception e){
				oResponse.bIsSuccess = false;
				oResponse.ErrorDescription = e.getMessage();
			}
		}

		return oResponse;
	}

	public string theSerializedResponse	{get; set;}
	
	public class ResponseWrapper{
		public boolean bIsSuccess {get; set;}
		public String ErrorDescription	{get; set;}

		public string RHCId {get; set;}
		public decimal ANG_RHC_Amount_Forecasted {get; set;}
		public decimal ANG_RHC_Amount_Provisional		{get; set;}
	}

	public void AfterProcess(){
		if(string.isNotBlank(theSerializedResponse)){
			bProvisionalRequested = true;
			list<ResponseWrapper> lsWrapper = (list<ResponseWrapper>)JSON.deserialize(theSerializedResponse, list<ResponseWrapper>.class);

			for(ResponseWrapper wr:lsWrapper){
				system.debug('DTULLO ProvisionalRMEWrapper --> ' + wr);
				if(wr.RHCId!='' && agents.containsKey(wr.RHCId)){
					agent ag = agents.get(wr.RHCId);

					ag.bIsSuccess = wr.bIsSuccess;
					ag.ANG_RHC_Amount_Forecasted = wr.ANG_RHC_Amount_Forecasted;
					ag.ANG_RHC_Amount_Provisional = wr.ANG_RHC_Amount_Provisional;
					ag.ErrorDescription = wr.ErrorDescription;
					
					if(ag.rhcInfo.ANG_ConsumedRHC__c == null || ag.rhcInfo.ANG_ConsumedRHC__c ==0){
						ag.calculatedConsumedRHC = null;
					}
					else{
						if(wr.ANG_RHC_Amount_Forecasted == null || wr.ANG_RHC_Amount_Forecasted==0)
							ag.calculatedConsumedRHC = 0;
						else {
							ag.calculatedConsumedRHC = (ag.rhcInfo.ANG_ConsumedRHC__c / wr.ANG_RHC_Amount_Forecasted * 100);
						}
					}
					if(!wr.bIsSuccess)
						ag.selected = false;
				}
			}
		}
	}
}
