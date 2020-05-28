public without sharing class ADSRService {

	public static final String REPORT_TYPE_AGENT = 'agent';
	public static final String REPORT_TYPE_OPERATIONS = 'operations';
	
	private Account airline;
	private String region;
	private List<String> countryIds;
	private List<String> operationCodes;
	private Account agent;
	
	public ADSRService(Account airline, String region, List<String> countries, String operation, String agent) {
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
		return [SELECT Id, Name, IATA_ISO_Country__c, IATA_ISO_Country__r.Name, IATA_ISO_Country__r.Region__c, IRIS_Code__c,
					Holds_FS_first_call_letter__c, RecordType.DeveloperName, Location_Type__c, Status__c,
					(SELECT Id, First_Call_Letter__c, Update_AIMS_DEF__c
					FROM Cases
					WHERE RecordType.DeveloperName LIKE 'SIDRA%'
					ORDER BY CreatedDate DESC
					LIMIT 1),
					(SELECT Id, Name, Change_Code__c, SIDRA_Case__c, SIDRA_Case__r.First_Call_Letter__c, SIDRA_Case__r.Handover_Bankruptcy_Lawyer__c
					 FROM Agencies_Applied_Change_codes__r
					 WHERE Active__c = true
					 ORDER BY CreatedDate DESC),
					(SELECT Id, Name, Security_Status__c
					 FROM Financial_Securities__r
					 WHERE Expiry_Date__c >= TODAY
					 ORDER BY CreatedDate DESC)
				FROM Account
				WHERE Recordtype.DeveloperName = 'IATA_Agency'
					AND IRIS_Code__c IN :agentCodes];
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
		
		Map<String, Account> agents = new Map<String, Account>();
		for (Account agent : loadAgents(agentCodes)) {
			agents.put(agent.IRIS_Code__c, agent);
		}
		
		for (ADSRExternalAPI.SummaryReportData item : data) {
			for (ADSRExternalAPI.SummaryReportDataDetail detail : item.Summary) {
				report.addSummaryReportData(detail, item, agents.get(detail.agentCode));
			}
		}
		
		return report;
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
			Account agentInfo) {
			
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
			Account agentInfo) {
			
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
		public Decimal outstandingIncrement;
		public Decimal outstandingUSDIncrement;
		
		public SummaryReportAgency() {
			this.charged = 0;
			this.refunded = 0;
			this.outstanding = 0;
			this.outstandingUSD = 0;
			this.outstandingIncrement = 0;
			this.outstandingUSDIncrement = 0;
		}
		
		public SummaryReportAgency(ADSRExternalAPI.SummaryReportDataDetail detail, ADSRExternalAPI.SummaryReportData parent,
			Account agentInfo) {
			this();
			this.agentCode = detail.agentCode;
			this.agentName = detail.agentName;
			this.defaultDate = this.parseDate(detail.defaultDate);
			this.shareRate = parent.aLShareVStotalIndustry;
			this.currencyCode = detail.currencyCode;
			this.exchangeRate = detail.exchangeRate;
			this.totalIndustry = parent.totalIndustry;
			this.financialSecurityStatus = calculateFinancialSecurityStatus(agentInfo);
			this.agentStatus = calculateAgentStatus(agentInfo);

			this.addDetail(detail);
		}

		public void addDetail(ADSRExternalAPI.SummaryReportDataDetail detail) {
			this.charged += detail.charged;
			this.refunded += detail.refunded;
			this.outstandingUSDIncrement = detail.totalUSD;
			this.outstandingUSD += detail.totalUSD;
			this.refundedRate = this.charged == 0 ? 0 : this.refunded / this.charged;
			this.outstandingIncrement = this.charged + this.refunded - this.outstanding;
			this.outstanding = this.charged + this.refunded;
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
		
		private String calculateFinancialSecurityStatus(Account info) {
			String financialSecurityStatus = 'Not Applicable/Claim Process not started';
			if (info != null) {
				if (isFirstCallLetterSent(info.Cases)) {
					financialSecurityStatus = 'First Call Letter Sent';
				} else if (isValidLocationType(info.Location_Type__c) && info.Status__c == 'Terminated'
					&& isEnchashmentInProgress(info.Financial_Securities__r)) {
						financialSecurityStatus = 'First Claim Sent';
				} else if (isValidLocationType(info.Location_Type__c) && info.Status__c == 'Terminated'
					&& isEnchashed(info.Financial_Securities__r)) {
						financialSecurityStatus = 'Financial Security Encashed';
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
			return sidraCase.Update_AIMS_DEF__c != null && sidraCase.First_Call_Letter__c == 'Sent';
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
		
		private String calculateAgentStatus(Account info) {
			if (info != null) {
				for (Agency_Applied_Change_code__c changeCode : info.Agencies_Applied_Change_codes__r) {
					if (changeCode.Change_Code__c == 'DFE' || changeCode.Change_Code__c == 'DEF') {
						return 'Defaulted';
					} else if (changeCode.Change_Code__c == 'RPY') {
						return 'Repayment Agreement';
					} else if (changeCode.Change_Code__c == 'TER') {
						return 'Terminated';
					} else if (changeCode.Change_Code__c == 'REI') {
						return 'Reinstated';
					} else if (changeCode.SIDRA_Case__r != null
						&& changeCode.SIDRA_Case__r.Handover_Bankruptcy_Lawyer__c != null) {
						return 'Legal action';
					}
				}
			}
			return '';
		}
	}
	
}