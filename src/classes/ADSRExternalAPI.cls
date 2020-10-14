public without sharing class ADSRExternalAPI {
	
	public static final String ADSR_API_ENDPOINT = 'callout:Mulesoft_credentials_v1/airline-default-summary-reports';
	
	public static final Integer INVALID_OPERATION_CODE = 400;
	public static final Integer MISSING_PARAMETERS_CODE = 404;
	public static final Integer ERROR_CODE = 500;
	
	public static final String IRIS_MISSING_PARAMETER = 'Missing_Parameter';
	public static final String IRIS_INVALID_OPERATION = 'Invalid_Operation';
	public static final String IRIS_ERROR = 'IRIS_Error';
	
	public static final String REGION_PARAMETER = 'region';
	public static final String AIRLINE_CODE_PARAMETER = 'airlineCode';
	public static final String OPERATION_CODE_PARAMETER = 'operationCode';
	public static final String AGENT_CODE_PARAMETER = 'agentCode';
	
	public static final Map<String, String> REGION_CODE_MAPPING = new Map<String, String> {
		'Africa & Middle East' => 'AMM', 'Americas' => 'MIA', 'Asia & Pacific' => 'SIN', 'China & North Asia' => 'BJS', 'Europe' => 'MAD'
	};
	
	private String selectedRegion;
	private String airlineCode;
	private String operationCodes;
	private String agentCode;
	
	private Http networkConnection;
	private HttpRequest request;
	private HttpResponse response;
	
	public ADSRExternalAPI(ADSRService service) {
		this(service.getAirlineCode(), service.getRegion(), service.getOperationCodes(), service.getAgentCode());
	}
	
	public ADSRExternalAPI(String airline, String region, List<String> operation, String agent) {
		this.airlineCode = airline;
		this.selectedRegion = REGION_CODE_MAPPING.get(region);
		this.operationCodes = operation != null && !operation.isEmpty() ? String.join(operation, ' ') : '';
		this.agentCode = agent;
		
		this.networkConnection = new Http();
		this.request = new HttpRequest();
		
		request.setEndpoint(ADSR_API_ENDPOINT);
		request.setMethod('GET');
		request.setTimeout(30000);
		
		this.setRequestParameters();
	}
	
	private void setRequestParameters() {
		String endpoint = this.request.getEndpoint();
		if (!endpoint.contains('?')) {
			endpoint += '?';
		} else {
			endpoint += '&';
		}
		
		endpoint += REGION_PARAMETER + '=' + this.selectedRegion + '&' + AIRLINE_CODE_PARAMETER + '=' + this.airlineCode;
		endpoint += !String.isBlank(this.operationCodes) ? '&' + OPERATION_CODE_PARAMETER + '=' + this.operationCodes : '';
		endpoint += !String.isBlank(this.agentCode) ? '&' + AGENT_CODE_PARAMETER + '=' + this.agentCode : '';
		
		this.request.setEndpoint(endpoint);
	}
	
	public List<SummaryReportData> getSummaryReportData() {
		
		this.response = this.networkConnection.send(this.request);
		Integer status = this.response.getStatusCode();
		String content = this.response.getBody();
		
		if (INVALID_OPERATION_CODE == status || MISSING_PARAMETERS_CODE == status) {
			
			Map<String, Object> output = (Map<String, Object>) JSON.deserializeUntyped(content);
			Map<String, Object> errorInfo = (Map<String, Object>) output.get('apiStatus');
			if (errorInfo == null) {
				List<Object> errorInfos = (List<Object>) output.get('errors');
				errorInfo = (Map<String, Object>) errorInfos.get(0);
			}
			
			String type = null;
			if (INVALID_OPERATION_CODE == status) {
				type = IRIS_INVALID_OPERATION;
			} else if (MISSING_PARAMETERS_CODE == status) {
				type = IRIS_MISSING_PARAMETER;
			}
			
			String description = !String.isBlank((String) errorInfo.get('description'))
				? (String) errorInfo.get('description')
				: (String) errorInfo.get('detail');
			
			throw new IRISException(type, (String) errorInfo.get('title'), description, (String) errorInfo.get('link'), (String) errorInfo.get('transactionId'));
			
		} else if (ERROR_CODE == status) {
			
			Map<String, Object> output = (Map<String, Object>) JSON.deserializeUntyped(content);
			List<Object> errorInfos = (List<Object>) output.get('errors');
			Map<String, Object> errorInfo = (Map<String, Object>) errorInfos.get(0);
			
			throw new IRISException(IRIS_ERROR, (String) errorInfo.get('title'), (String) errorInfo.get('detail'), (String) errorInfo.get('link'),
				(String) errorInfo.get('transactionId'));
		}
		
		List<SummaryReportData> report = deserializeData(content);
		return report;
	}
	
	public static List<SummaryReportData> deserializeData(String jsonString) {
		List<SummaryReportData> result = new List<SummaryReportData>();
		
		Map<String, List<SummaryReportData>> jsonObject = (Map<String, List<SummaryReportData>>) JSON.deserialize(jsonString,
			Map<String, List<SummaryReportData>>.class);
		
		result = jsonObject.get('data');
		
		return result;
	}
	
	public class SummaryReportData {
		public Decimal totalIndustry;
		public Decimal aLShareVStotalIndustry;
		public List<SummaryReportDataDetail> summary;
		
	}
	
	public class SummaryReportDataDetail {
		public String operation;
		public String airlineCode;
		public String agentCode;
		public String agentName;
		public String defaultDate;
		public Decimal charged;
		public Decimal refunded;
		public String currencyCode;
		public Decimal exchangeRate;
		public Decimal totalUSD;
		public String summaryDate;
		public String billingPeriod;
		public String aDCMNumber;
		
	}
	
	public class IRISException extends Exception {
		@AuraEnabled
		public String title;
		@AuraEnabled
		public String transactionId;
		@AuraEnabled
		public String detail;
		@AuraEnabled
		public String link;
		@AuraEnabled
		public String type = 'IRIS_Error';
		
		public IRISException(String type, String title, String detail, String link, String transactionId) {
			this.type = type;
			this.title = title;
			this.detail = detail;
			this.link = link;
			this.transactionId = transactionId;
		}
	}
	
}