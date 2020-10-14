public without sharing class ADSRService {

	public static final String REPORT_TYPE_AGENT = 'agent';
	public static final String REPORT_TYPE_OPERATIONS = 'operations';
	
	private Account airline;
	private String region;
	private List<String> countryIds;
	private List<String> operationCodes;
	private Account agent;
	private Map<String, Map<String, List<Case_Detail__c>>> caseDetailsByCaseByAgency;
	private Map<String, Decimal> financialSecurityAmountByAgency;
	
	public ADSRService(Account airline, String region, List<String> countries, String operation, String agent) {
		this.caseDetailsByCaseByAgency = new Map<String, Map<String, List<Case_Detail__c>>>();
		this.financialSecurityAmountByAgency = new Map<String, Decimal>();
		this.airline = airline;
		this.region = region;
		this.loadAgent(agent);
		this.loadOperationCodes(countries, operation);
	}
	
	private void loadOperationCodes(List<String> countries, String operation) {
		this.operationCodes = new List<String>();
		this.countryIds = new List<String>();
		
		if (String.isBlank(operation) || countries == null || countries.isEmpty()) {
			return;
		}
		
		this.countryIds.addAll(countries);
		String operationCode = operation == 'CASS' ? 'CAS' : operation;
		String query = 'SELECT Id, Name  FROM AMS_Operation__c WHERE Country__c IN :countries AND Name LIKE \'___' + operationCode
			+ '%\'';
		for (AMS_Operation__c item : (List<AMS_Operation__c>) Database.query(query)) {
			this.operationCodes.add(item.Name);
		}
		
	}
	
	private void loadAgent(String agentCode) {
		if (String.isBlank(agentCode)) {
			return;
		}
		
		List<Account> result = loadAgents(new List<String> { agentCode });
		if (result != null && !result.isEmpty()) {
			this.agent = result[0];
			this.region = result[0].IATA_ISO_Country__r.Region__c;
		}
	}
	
	private List<Account> loadAgents(List<String> agentCodes) {
		List<Account> agents =  [SELECT Id, Name, IATA_ISO_Country__c, IATA_ISO_Country__r.Name, IATA_ISO_Country__r.Region__c, IRIS_Code__c,
					Holds_FS_first_call_letter__c, RecordType.DeveloperName, Location_Type__c, Status__c,
					(SELECT Id, First_Call_Letter__c, Update_AIMS_DEF__c,Total_Defaulted_Amount__c 
					 FROM Cases
					 WHERE RecordType.DeveloperName LIKE 'SIDRA%' AND Update_AIMS_DEF__c != null
					 ORDER BY CreatedDate DESC
					 LIMIT 1),
					(SELECT Id, Name, Change_Code__c, SIDRA_Case__c, SIDRA_Case__r.First_Call_Letter__c, SIDRA_Case__r.Handover_Bankruptcy_Lawyer__c
					 FROM Agencies_Applied_Change_codes__r
					 WHERE Active__c = true
					 ORDER BY CreatedDate DESC),
					(SELECT Id, Name, Security_Status__c
					 FROM Financial_Securities__r
					 WHERE Expiry_Date__c >= TODAY OR Unlimited_Security__c = true
					 ORDER BY CreatedDate DESC)
				FROM Account
				WHERE Recordtype.DeveloperName = 'IATA_Agency'
					AND (IRIS_Code__c IN :agentCodes OR IATACode__c IN :agentCodes)];

		List<Account> financialSecutiryCalculationRecords = [SELECT Id,
				(SELECT Id, Amount__c
				 FROM Financial_Securities__r
				 WHERE Security_Status__c IN ('Active', 'Close to Expiry Date', 'Encashment in progress', 'Pending to be Released')
				 	AND Security_Type__c NOT IN ('MCPG', 'MCBG', 'CCG', 'Transit Account', 'Letter Of Undertaking', 'Parent Company Guarantee'))
				FROM Account
				WHERE Recordtype.DeveloperName = 'IATA_Agency' AND Status__c != 'Approved'
					AND (IRIS_Code__c IN :agentCodes OR IATACode__c IN :agentCodes)];
		
		for(Account agency : financialSecutiryCalculationRecords) {
			Decimal financialSecurityAmount = 0;
			for(Financial_Security__c financialSecurity : agency.Financial_Securities__r) {
				financialSecurityAmount += financialSecurity.Amount__c;
			}
			this.financialSecurityAmountByAgency.put(agency.Id, financialSecurityAmount);
		}

		Set<Id> caseIds = new Set<Id>();
		for(Account currentAgent : agents) {
			this.caseDetailsByCaseByAgency.put(currentAgent.Id, new Map<String, List<Case_Detail__c>>());
			for(Case currentCase : currentAgent.Cases) {
				caseIds.add(currentCase.Id);
				this.caseDetailsByCaseByAgency.get(currentAgent.Id).put(currentCase.Id, new List<Case_Detail__c>());
			}
		}

		List<Case> cases = [SELECT Id, AccountId,
								(SELECT Id, Case__c, Due_date__c
								 FROM Case_Details__r
								 WHERE RecordType.DeveloperName = 'Repayment_Instalment' AND Due_date__c != null
								 ORDER BY Due_date__c DESC
								 LIMIT 1)
							FROM Case
							WHERE Id IN :caseIds
							ORDER BY CreatedDate DESC];
		for(Case currentCase : cases) {
			for(Case_Detail__c detail : currentCase.Case_Details__r) {
				this.caseDetailsByCaseByAgency.get(currentCase.AccountId).get(currentCase.Id).add(detail);
			}
		}
		
		return agents;
	}
	
	public String getAirlineName() {
		return this.airline.Name;
	}
	
	public String getAirlineCode() {
		return String.isBlank(this.airline.IATACode__c) ? this.airline.Airline_Prefix__c : this.airline.IATACode__c;
	}
	
	public String getRegion() {
		return this.region;
	}
	
	public List<String> getMarkets() {
		return this.countryIds;
	}
	
	public List<String> getOperationCodes() {
		return this.operationCodes;
	}
	
	public String getAgentCode() {
		return this.agent.IRIS_Code__c;
	}

	public String getReprotType() {
		if(this.agent == null) {
			return REPORT_TYPE_OPERATIONS;
		}
		return REPORT_TYPE_AGENT;
	}
	
	private List<ADSRExternalAPI.SummaryReportData> getReportData() {
		ADSRExternalAPI api = new ADSRExternalAPI(this);
		return api.getSummaryReportData();
	}
	
	public SummaryReport getSummaryReport() {
		SummaryReport report = new SummaryReport(this.getReprotType(), this.getAirlineCode(), this.getAirlineName());
		List<ADSRExternalAPI.SummaryReportData> data = getReportData();
		
		List<String> agentCodes = new List<String>();
		for (ADSRExternalAPI.SummaryReportData item : data) {
			for (ADSRExternalAPI.SummaryReportDataDetail detail : item.Summary) {
				agentCodes.add(detail.agentCode);
			}
		}
		
		Map<String, AgencyInfo> agents = new Map<String, AgencyInfo>();
		for (Account agent : loadAgents(agentCodes)) {
			Map<String, List<Case_Detail__c>> caseDetails = this.caseDetailsByCaseByAgency.get(agent.Id);
			agents.put(agent.IRIS_Code__c, new AgencyInfo(agent, caseDetails, this.financialSecurityAmountByAgency.get(agent.Id)));
		}
		
		for (ADSRExternalAPI.SummaryReportData item : data) {
			for (ADSRExternalAPI.SummaryReportDataDetail detail : item.Summary) {
				AgencyInfo info = agents.get(detail.agentCode) == null ? new AgencyInfo() : agents.get(detail.agentCode);
				report.addSummaryReportData(detail, item, info);
			}
		}
		
		return report;
	}
	
	private class AgencyInfo {
		private Account agency;
		private Decimal financialSecurityAmount;
		private Map<String, List<Case_Detail__c>> caseDetailsByCase;

		private AgencyInfo() {
			this.caseDetailsByCase = new Map<String, List<Case_Detail__c>>();
		}

		private AgencyInfo(Account agency) {
			this();
			this.agency = agency;
		}

		private AgencyInfo(Account agency, Map<String, List<Case_Detail__c>> caseDetails) {
			this(agency);
			this.caseDetailsByCase = caseDetails;
		}

		private AgencyInfo(Account agency, Map<String, List<Case_Detail__c>> caseDetails, Decimal amount) {
			this(agency, caseDetails);
			this.financialSecurityAmount = amount;
		}
	}

	public class SummaryReport {
		@AuraEnabled
		public String airlineCode;
		@AuraEnabled
		public String airlineName;
		@AuraEnabled
		public List<SummaryReportOperation> groups;
		private Map<String, SummaryReportOperation> indexedGroups;
		private String type;

		public SummaryReport(String reportType, String airlineCode, String airlineName) {
			this.type = reportType;
			this.airlineCode = airlineCode;
			this.airlineName = airlineName;
			
			this.groups = new List<SummaryReportOperation>();
			this.indexedGroups = new Map<String, SummaryReportOperation>();
		}
		
		public void addSummaryReportData(ADSRExternalAPI.SummaryReportDataDetail data, ADSRExternalAPI.SummaryReportData sourceReportData,
			AgencyInfo agentInfo) {
			
			String groupingKey;
			if(REPORT_TYPE_OPERATIONS == this.type) {
				groupingKey = data.operation;
			}
			else {
				groupingKey = data.agentCode;
			}

			SummaryReportOperation reportGroup = indexedGroups.get(groupingKey);
			
			if (reportGroup == null) {
				reportGroup = new SummaryReportOperation();
				this.groups.add(reportGroup);
				this.indexedGroups.put(groupingKey, reportGroup);
			}
			
			reportGroup.addSummaryReportDetail(data, sourceReportData, agentInfo);
		}
	}
	
	public class SummaryReportOperation {
		@AuraEnabled
		public String operation;
		@AuraEnabled
		public Decimal totalCharged;
		@AuraEnabled
		public Decimal totalRecovered;
		@AuraEnabled
		public Decimal totalOutstanding;
		@AuraEnabled
		public String currencyCode;
		@AuraEnabled
		public Decimal exchangeRate;
		@AuraEnabled
		public Decimal totalChargedUSD;
		@AuraEnabled
		public Decimal totalRecoveredUSD;
		@AuraEnabled
		public Decimal totalOutstandingUSD;
		@AuraEnabled
		public Decimal recoveredRate;
		
		public Date minDate;
		public Date maxDate;
		
		@AuraEnabled
		public List<SummaryReportAgency> details;
		private Map<String, SummaryReportAgency> indexedAgencies;
		
		public SummaryReportOperation() {
			this.details = new List<SummaryReportAgency>();
			this.indexedAgencies = new Map<String, SummaryReportAgency>();
			this.totalCharged = 0;
			this.totalRecovered = 0;
			this.totalOutstanding = 0;
			this.totalChargedUSD = 0;
			this.totalRecoveredUSD = 0;
			this.totalOutstandingUSD = 0;
			this.recoveredRate = 0;
		}
		
		public void addSummaryReportDetail(ADSRExternalAPI.SummaryReportDataDetail reportLine, ADSRExternalAPI.SummaryReportData report,
			AgencyInfo agentInfo) {
			
			String agencyKey =  reportLine.agentCode + '_' + reportLine.currencyCode;
			SummaryReportAgency agency = this.indexedAgencies.get(agencyKey);
			if(agency == null) {
				agency = new SummaryReportAgency(reportLine, report, agentInfo);
				this.details.add(agency);
				this.indexedAgencies.put(agencyKey, agency);
			}
			else {
				agency.addDetail(reportLine);
			}

			this.operation = reportLine.operation;
			this.totalCharged += reportLine.charged;
			this.totalRecovered += reportLine.refunded;
			this.totalOutstanding += agency.outstandingIncrement;
			this.currencyCode = reportLine.currencyCode;
			this.exchangeRate = reportLine.exchangeRate;
			this.totalChargedUSD += reportLine.charged * reportLine.exchangeRate;
			this.totalRecoveredUSD = this.totalRecovered * reportLine.exchangeRate;
			this.totalOutstandingUSD += agency.outstandingUSDIncrement;
			this.recoveredRate = this.totalCharged != 0 ? this.totalRecovered / this.totalCharged : this.recoveredRate;
			this.recoveredRate = this.recoveredRate < 0 ? this.recoveredRate * -1 : this.recoveredRate;
		}
	}
	
	public class SummaryReportAgency {
		@AuraEnabled
		public String agentCode;
		@AuraEnabled
		public String agentName;
		@AuraEnabled
		public String defaultDate;
		@AuraEnabled
		public Decimal charged;
		@AuraEnabled
		public Decimal totalDefaultedAmount;
		@AuraEnabled
		public Decimal shareRate;
		@AuraEnabled
		public Decimal refunded;
		@AuraEnabled
		public Decimal refundedRate;
		@AuraEnabled
		public Decimal outstanding;
		@AuraEnabled
		public String currencyCode;
		@AuraEnabled
		public Decimal exchangeRate;
		@AuraEnabled
		public Decimal outstandingUSD;
		@AuraEnabled
		public Decimal totalIndustry;
		@AuraEnabled
		public String financialSecurityStatus;
		@AuraEnabled
		public String agentStatus;
		@AuraEnabled
		public String dueDate;
		public Decimal outstandingIncrement;
		public Decimal outstandingUSDIncrement;
		
		public SummaryReportAgency() {
			this.charged = 0;
			this.refunded = 0;
			this.outstanding = 0;
			this.outstandingUSD = 0;
			this.outstandingIncrement = 0;
			this.outstandingUSDIncrement = 0;
			this.totalDefaultedAmount = 0;
		}
		
		public SummaryReportAgency(ADSRExternalAPI.SummaryReportDataDetail detail, ADSRExternalAPI.SummaryReportData parent,
			AgencyInfo agentInfo) {
			this();
			this.agentCode = detail.agentCode;
			this.agentName = detail.agentName;
			this.defaultDate = this.parseDate(detail.defaultDate);
			this.currencyCode = detail.currencyCode;
			this.exchangeRate = detail.exchangeRate;
			this.totalIndustry = agentInfo.financialSecurityAmount != null && agentInfo.financialSecurityAmount > 0 ?
				agentInfo.financialSecurityAmount : null;
			this.financialSecurityStatus = calculateFinancialSecurityStatus(agentInfo);
			this.agentStatus = calculateAgentStatus(agentInfo);
			this.totalDefaultedAmount = getTotalDefaultedAmount(agentInfo);
			
			this.addDetail(detail);
		}

		public void addDetail(ADSRExternalAPI.SummaryReportDataDetail detail) {
			this.charged += detail.charged;
			this.refunded += detail.refunded;
			this.outstandingUSDIncrement = detail.totalUSD;
			this.outstandingUSD += detail.totalUSD;
			this.refundedRate = this.charged == 0 ? 0 : this.refunded / this.charged;
			this.refundedRate = this.refundedRate < 0 ? this.refundedRate * -1 : this.refundedRate;
			this.outstandingIncrement = this.charged + this.refunded - this.outstanding;
			this.outstanding = this.charged + this.refunded;
			this.shareRate = this.totalDefaultedAmount == 0 ? 0 : this.charged / this.totalDefaultedAmount;
		}
		
		public String parseDate(String inputDate) {
			if (String.isBlank(inputDate)) {
				return '';
			}
			
			inputDate = inputDate.split(' ')[0];
			String[] dateAgs = inputDate.split('-');
			Datetime parsedDate = Datetime.newInstance(Integer.valueOf(dateAgs[2]), Integer.valueOf(dateAgs[1]), Integer.valueOf(dateAgs[0]));
			
			return parsedDate.format('dd MMM YYYY');
		}

		private Decimal getTotalDefaultedAmount(AgencyInfo info) {
			if (info.agency == null || info.agency.Cases == null || info.agency.Cases.isEmpty()) {
				return 0;
			}
			Case sidraCase = info.agency.Cases[0];
			return sidraCase == null || sidraCase.Total_Defaulted_Amount__c == null ? 
					0 :
					sidraCase.Total_Defaulted_Amount__c;
		}
		
		private String calculateFinancialSecurityStatus(AgencyInfo info) {
			String financialSecurityStatus = 'Not Applicable/Claim Process not started';
			if (info.agency != null) {
				if (isValidLocationType(info.agency.Location_Type__c) && info.agency.Status__c == 'Terminated'
					&& isEnchashed(info.agency.Financial_Securities__r)) {
						financialSecurityStatus = 'Financial Security Encashed';
				} else if (isValidLocationType(info.agency.Location_Type__c) && info.agency.Status__c == 'Terminated'
					&& isEnchashmentInProgress(info.agency.Financial_Securities__r)) {
						financialSecurityStatus = 'Final Claim Sent';
				} else if (isFirstCallLetterSent(info.agency.Cases)) {
					financialSecurityStatus = 'First Call Letter Sent';
				}
			}
			return financialSecurityStatus;
		}
		
		private Boolean isValidLocationType(String locationType) {
			return new List<String> { 'HO', 'HE', 'GE' } .contains(locationType);
		}
		
		private Boolean isFirstCallLetterSent(List<Case> sidraCases) {
			if (sidraCases == null || sidraCases.isEmpty()) {
				return false;
			}
			Case sidraCase = sidraCases[0];
			return sidraCase.First_Call_Letter__c == 'Sent';
		}
		
		private Boolean isEnchashmentInProgress(List<Financial_Security__c> securityStatus) {
			return checkFinancialSecurityStatus(securityStatus, 'Encashment in progress');
		}
		
		private Boolean isEnchashed(List<Financial_Security__c> securityStatus) {
			return checkFinancialSecurityStatus(securityStatus, 'Encashed');
		}
		
		private Boolean checkFinancialSecurityStatus(List<Financial_Security__c> securityStatus, String status) {
			if (securityStatus == null) {
				return false;
			}
			for (Financial_Security__c securityInfo : securityStatus) {
				if (securityInfo.Security_Status__c == status) {
					return true;
				}
			}
			return false;
		}
		
		private String calculateAgentStatus(AgencyInfo info) {
			if (info.agency != null) {
				for (Agency_Applied_Change_code__c changeCode : info.agency.Agencies_Applied_Change_codes__r) {
					if ((changeCode.Change_Code__c == 'DFE' || changeCode.Change_Code__c == 'DEF'
						|| changeCode.Change_Code__c == 'RRQ' || changeCode.Change_Code__c == 'RPY'
						|| changeCode.Change_Code__c == 'TER') && changeCode.SIDRA_Case__r != null
						&& changeCode.SIDRA_Case__r.Handover_Bankruptcy_Lawyer__c != null) {
						return 'Legal action';
					} else if (changeCode.Change_Code__c == 'DFE' || changeCode.Change_Code__c == 'DEF'
						|| changeCode.Change_Code__c == 'RRQ') {
						return 'Defaulted';
					} else if (changeCode.Change_Code__c == 'RPY') {
						this.setDueDate(info);
						return 'Repayment Agreement';
					} else if (changeCode.Change_Code__c == 'TER') {
						return 'Terminated';
					} else if (changeCode.Change_Code__c == 'REI' || changeCode.Change_Code__c == 'RCR') {
						return 'Reinstated';
					}
				}
			}
			return '';
		}

		private void setDueDate(AgencyInfo info) {
			if(info.agency.Cases != null && !info.agency.Cases.isEmpty() && info.caseDetailsByCase != null) {
				List<Case_Detail__c> detailsList = info.caseDetailsByCase.get(info.agency.Cases[0].Id);
				if(detailsList != null && !detailsList.isEmpty() && detailsList[0].Due_date__c != null) {
					Datetime dTime = Datetime.newInstance(detailsList[0].Due_date__c.year(), detailsList[0].Due_date__c.month(), detailsList[0].Due_date__c.day());
					this.dueDate = dTime.format('dd MMM YYYY');
				}
			}
		}
	}
	
}