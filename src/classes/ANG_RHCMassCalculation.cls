public class ANG_RHCMassCalculation {

	// ******************************
	// ********** variables *********
	// ******************************
	private Id ifap = AMS_Utils.RECTYPE_IFAP; //need to fetch because dynamic queries only receive direct variables
	private Id batchId;
	private Datetime submitTime;

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
	public Boolean running { get; set; }

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

	public List<Agent> agents {
		get {
			if (agents == null)
				agents = new List<Agent>();
			if (searched && agents.isEmpty()) {
				for (ANG_RHC_Information__c r : (List<ANG_RHC_Information__c>) paginator.getRecords())
					agents.add(new Agent(r, selectedAgents.get(r.ANG_AccountId__c), calculatedAgents.contains(r.ANG_AccountId__c)));
			}
			return agents;
		}
		set;
	}

	public ApexPages.StandardSetController paginator {
		get {
			if (paginator == null) {
				paginator = new ApexPages.StandardSetController(Database.getQueryLocator(rhcQuery));
				paginator.setPageSize(500);
				paginator.setPageNumber(pageNumber);
			}
			return paginator;
		}
		private set;
	}
	
	private Map<Id, Decimal> selectedAgents {
		get {
			if (selectedAgents == null)
				selectedAgents = new Map<Id, Decimal>();
			return selectedAgents;
		}
		set;
	}

	private Set<Id> calculatedAgents {
		get {
			if (calculatedAgents == null)
				calculatedAgents = new Set<Id>();
				System.debug(loggingLevel.FINE, '____ [cls ANG_RHCMassCalculation - calculatedAgents getter] calculatedAgents - ' + calculatedAgents);
			return calculatedAgents;
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

	private String rhcQuery {
		get {
			String query = '' // 
				+ ' SELECT Id , CurrencyIsoCode , ANG_AccountId__c , ANG_AccountId__r.IATACode__c , ANG_AccountId__r.IATA_ISO_Country__c, ' // 
				+ '	ANG_RHC_Amount__c, ANG_RHC_Amount_Forecasted__c, ANG_RHC_Amount_Provisional__c, ANG_RHC_Effective_Date__c,' // 
				+ '	ANG_Forecasted_RHC_Effective_date__c, ANG_ConsumedRHC__c ' // 
				+ ' FROM ANG_RHC_Information__c' // 
				+ ' WHERE ANG_CashCondition__c = false' // 
				+ ' 	AND ANG_RHC_Amount_Equals_FS__c = false ' // 
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
			return query;
		}
	}

	// ******************************
	// ********* constructor ********
	// ******************************
	public ANG_RHCMassCalculation() {

	}

	// ******************************
	// ********** actions ***********
	// ******************************

	public void search() {
		System.debug(loggingLevel.FINE, '____ [cls ANG_RHCMassCalculation - search] searching');
		searched = validCountry || validDays; // true when valid search filters, false otherwise
		paginator = null;
		agents.clear();
		selectedAgents.clear();
		calculatedAgents.clear();
		selectAll = false;
	}

	public void calculate(){
		setSelected();

		batchId = Database.executeBatch(new ANG_UpdateRHCInformationBatch(selectedAgents.keySet(), ANG_UpdateRHCInformationBatch.Process.PROVISIONAL, false), 1);
		running = true;
		submitTime = System.now();
	}

	public void fetchResults() {
		AsyncApexJob batchJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
								 FROM AsyncApexJob
								 WHERE Id = :batchId];
		
		// while it does not complete, check for temporary results
		for (ANG_RHC_Information__c r : [SELECT Id, ANG_AccountId__c
										 FROM ANG_RHC_Information__c
										 WHERE ANG_AccountId__c IN :selectedAgents.keySet()
											 AND LastModifiedDate > :submitTime]) {
			calculatedAgents.add(r.ANG_AccountId__c);
		}
		
		running = batchJob.status != 'Ended' && batchJob.status != 'Completed';
		
		System.debug(loggingLevel.FINE, '____ [cls ANG_RHCMassCalculation - fetchResults] calculatedAgents - ' + calculatedAgents);
		
		// need to re"draw" table to fetch new values.
		paginator = null;
		agents.clear();
	}

	public void regionSelected() {
		days = 0;
		country = NONE;
	}

	// ******************************
	// ******** pagination **********
	// ******************************

	public void first() {
		pageNumber = 1;
		deselectAll();
	}
	public void next() {
		if (paginator.getHasNext())
			pageNumber++;
		deselectAll();
	}
	public void previous() {
		if (paginator.getHasPrevious())
			pageNumber--;
		deselectAll();
	}
	public void last() {
		pageNumber = totalPages;
		deselectAll();
	}

	public Integer totalPages{
		get{
			System.debug(loggingLevel.FINE, '____ [cls ANG_RHCMassCalculation - totalPages getter] result size - ' + paginator.getResultSize());
			System.debug(loggingLevel.FINE, '____ [cls ANG_RHCMassCalculation - totalPages getter] page size - ' + paginator.getPageSize());
			System.debug(loggingLevel.FINE, '____ [cls ANG_RHCMassCalculation - totalPages getter] total pages - ' + Math.ceil((Decimal)paginator.getResultSize()/(Decimal)paginator.getPageSize()).intValue());

			return Math.ceil((Decimal)paginator.getResultSize()/(Decimal)paginator.getPageSize()).intValue();
		}
	}

	public Integer pageNumber {
		get{
			if(pageNumber == null) pageNumber = paginator.getPageNumber();
			return pageNumber;
		}
		set{
			setSelected(); //call to persist selected agents
			if (value <= 1) paginator.setPageNumber(1);
			else if(value > totalPages) paginator.setPageNumber(totalPages);
			else paginator.setPageNumber(value);

			pageNumber = paginator.getPageNumber();
		}
	}

	private void deselectAll() {
		selectAll = false;
		selectedAgents.clear();
		for (Agent a : agents)
			a.selected = false;
	}

	// ******************************
	// ********** helpers ***********
	// ******************************

	public void setSelected(){
		for(Agent a : agents){
			if(a.selected) selectedAgents.put(a.rhcInfo.ANG_AccountId__c, a.currentAmount);
			else selectedAgents.remove(a.rhcInfo.ANG_AccountId__c);
		}

		agents.clear(); //re"draw" table

		System.debug(loggingLevel.FINE, '____ [cls ANG_RHCMassCalculation - setSelected] selectedAgents - ' + selectedAgents);
	}

	// ******************************
	// ********** wrappers **********
	// ******************************
	public class Agent {
		public Boolean selected { get; set; }
		public Boolean hasResult { get; set; }
		public Decimal currentAmount { get; set; }
		public ANG_RHC_Information__c rhcInfo { get; set; }
		public String calculatedConsumedRHC { get; set; }

		private Agent(ANG_RHC_Information__c r, Decimal currentAmount, Boolean hasResult){
			this.selected = currentAmount != null;
			this.hasResult = hasResult;
			this.rhcInfo = r;

			this.currentAmount = selected ? currentAmount : r.ANG_RHC_Amount__c;
			if (r.ANG_ConsumedRHC__c != null && r.ANG_RHC_Amount_Forecasted__c != null) {
				calculatedConsumedRHC = r.ANG_RHC_Amount_Forecasted__c == 0
					? null
					: (r.ANG_ConsumedRHC__c / r.ANG_RHC_Amount_Forecasted__c * 100).setScale(2).round(System.RoundingMode.HALF_EVEN) + '%';
			}
		}
	}
}
