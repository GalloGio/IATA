public without sharing class ADSRService {
	
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
					(SELECT Id, Name, Change_Code__c, SIDRA_Case__c, SIDRA_Case__r.First_Call_Letter__c, SIDRA_Case__r.Handover_Bankruptcy_Lawyer__c
					 FROM Agencies_Applied_Change_codes__r
					 WHERE Active__c = true),
					(SELECT Id, Name, Security_Status__c FROM Financial_Securities__r WHERE Expiry_Date__c >= TODAY)
				FROM Account
				WHERE Recordtype.DeveloperName = 'IATA_Agency'
					AND IRIS_Code__c IN :agentCodes];
	}
	
	public String getAirlineName() {
		return this.airline.Name;
	}
	
	public String getAirlineCode() {
		return this.airline.Airline_Code__c;
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
	
	private List<ADSRExternalAPI.SummaryReportData> getReportData() {
		ADSRExternalAPI api = new ADSRExternalAPI(this);
		return api.getSummaryReportData();
	}
	
	public SummaryReport getSummaryReport() {
		SummaryReport report = new SummaryReport(this.getAirlineCode(), this.getAirlineName());
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
		public List<SummaryReportGroup> groups;
		
		public SummaryReport(String airlineCode, String airlineName) {
			this.airlineCode = airlineCode;
			this.airlineName = airlineName;
			this.groups = new List<SummaryReportGroup>();
		}
		
		public void addSummaryReportData(ADSRExternalAPI.SummaryReportDataDetail data, ADSRExternalAPI.SummaryReportData sourceReportData,
			Account agentInfo) {
			SummaryReportGroup reportGroup = null;
			
			for (SummaryReportGroup currentGroup : this.groups) {
				if (data.operation == currentGroup.operation) {
					reportGroup = currentGroup;
					break;
				}
			}
			
			if (reportGroup == null) {
				reportGroup = new SummaryReportGroup();
				this.groups.add(reportGroup);
			}
			
			reportGroup.addSummaryReportDetail(data, sourceReportData, agentInfo);
		}
	}
	
	public class SummaryReportGroup {
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
		public List<SummaryReportDetail> details;
		
		public SummaryReportGroup() {
			this.details = new List<SummaryReportDetail>();
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
			SummaryReportDetail detail = new SummaryReportDetail(reportLine, report, agentInfo);
			this.details.add(detail);
			
			this.operation = reportLine.operation;
			this.totalCharged += detail.charged;
			this.totalRecovered += detail.refunded;
			this.totalOutstanding += detail.outstanding;
			this.currencyCode = reportLine.currencyCode;
			this.exchangeRate = reportLine.exchangeRate;
			this.totalChargedUSD += detail.charged * detail.exchangeRate;
			this.totalRecoveredUSD = this.totalRecovered * detail.exchangeRate;
			this.totalOutstandingUSD += detail.outstandingUSD;
			this.recoveredRate = this.totalCharged != 0 ? this.totalRecovered / this.totalCharged : this.recoveredRate;
		}
	}
	
	public class SummaryReportDetail {
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
		
		public SummaryReportDetail() {
			
		}
		
		public SummaryReportDetail(ADSRExternalAPI.SummaryReportDataDetail detail, ADSRExternalAPI.SummaryReportData parent,
			Account agentInfo) {
			this.agentCode = detail.agentCode;
			this.agentName = detail.agentName;
			this.defaultDate = this.parseDate(detail.defaultDate);
			this.charged = detail.charged;
			this.shareRate = parent.aLShareVStotalIndustry;
			this.refunded = detail.refunded;
			this.refundedRate = detail.charged == 0 ? 0 : detail.refunded / detail.charged;
			this.outstanding = detail.charged - detail.refunded;
			this.currencyCode = detail.currencyCode;
			this.exchangeRate = detail.exchangeRate;
			this.outstandingUSD = detail.totalUSD;
			this.totalIndustry = parent.totalIndustry;
			this.financialSecurityStatus = calculateFinancialSecurityStatus(agentInfo);
			this.agentStatus = calculateAgentStatus(agentInfo);
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
			if (info != null) {
				if (isValidLocationType(info.Location_Type__c) && info.Holds_FS_first_call_letter__c == 0) {
					return 'Not Applicable';
				} else if (isFirstCallLetterSent(info.Agencies_Applied_Change_codes__r)) {
					return 'First Call Letter Sent';
				} else if (isValidLocationType(info.Location_Type__c) && info.Status__c == 'Terminated'
					&& isEnchashmentInProgress(info.Financial_Securities__r)) {
					return 'First Claim Sent';
				} else if (isValidLocationType(info.Location_Type__c) && info.Status__c == 'Terminated'
					&& isEnchashed(info.Financial_Securities__r)) {
					return 'Financial Security Encashed';
				}
			}
			return '';
		}
		
		private Boolean isValidLocationType(String locationType) {
			return new List<String> { 'HO', 'HE', 'GE' } .contains(locationType);
		}
		
		private Boolean isFirstCallLetterSent(List<Agency_Applied_Change_code__c> changeCodes) {
			if (changeCodes == null) {
				return false;
			}
			for (Agency_Applied_Change_code__c changeCode : changeCodes) {
				if (changeCode.SIDRA_Case__r.First_Call_Letter__c == 'Sent') {
					return true;
				}
			}
			return false;
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