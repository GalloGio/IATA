public without sharing class ADSRExternalAPI {

    public static final String ADSR_API_ENDPOINT = 'callout:ADSR_API';

    public static final Integer INVALID_OPERATION_CODE = 400;
    public static final Integer MISSING_PARAMETERS_CODE = 404;

    public static final String REGION_PARAMETER = 'Region';
    public static final String AIRLINE_CODE_PARAMETER = 'AirlineCode';
    public static final String OPERATION_CODE_PARAMETER = 'OperationCode';
    public static final String AGENT_CODE_PARAMETER = 'AgentCode';

    private String selectedRegion;
    private String airlineCode;
    private String operationCode;
    private String agentCode;

    private Http networkConnection;
    private HttpRequest request;
    private HttpResponse response;

    public ADSRExternalAPI(ADSRService service){
        this(service.getAirlineCode(), service.getRegion(), service.getOperationCode(), service.getAgentCode());
    }

    public ADSRExternalAPI(String airline, String region, String operation, String agent) {
        this.airlineCode = airline;
        this.selectedRegion = region;
        this.operationCode = operation;
        this.agentCode = agent;

        this.networkConnection = new Http();
        this.request = new HttpRequest();

        request.setEndpoint(ADSR_API_ENDPOINT);
        request.setMethod('GET');

        this.setRequestParameters();
    }

    private void setRequestParameters(){
        String endpoint = this.request.getEndpoint();
        if(!endpoint.contains('?')){
            endpoint += '?';
        }
        else {
            endpoint += '&';
        }

        endpoint += REGION_PARAMETER + '=' + this.selectedRegion
                    + '&' + AIRLINE_CODE_PARAMETER + '=' + this.airlineCode
                    + '&' + OPERATION_CODE_PARAMETER + '=' + this.operationCode
                    + '&' + AGENT_CODE_PARAMETER + '=' + this.agentCode;
        
        this.request.setEndpoint(endpoint);
    }

    public List<SummaryReportData> getSummaryReportData(){
        
        /*this.response = this.networkConnection.send(this.request);
        Integer status = this.response.getStatusCode();
        String content = this.response.getBody();

        if(INVALID_OPERATION_CODE == status){
            throw new InvalidOperationException(content);
        }
        else if(MISSING_PARAMETERS_CODE == status){
            throw new MissingParametersException(content);
        }*/

      
        String url_file_ref = '/resource/ADSR_API_Mock';

        PageReference file_ref = new PageReference(url_file_ref);
        String content = file_ref.getContent().toString();
        
        List<SummaryReportData> report = deserializeData(content);
        return report;
    }

    public static List<SummaryReportData> deserializeData(String jsonString){
        List<SummaryReportData> result = new List<SummaryReportData>();

        Map<String, Object> jsonObject = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

        List<Object> dataList = (List<Object>) jsonObject.get('AirlineDefaultSummaryReport');
        for(Object dataRecord : dataList){
            result.add(new SummaryReportData((Map<String, Object>)dataRecord));
        }

        return result;
    }

    public class SummaryReportData {
        public String Operation;
        public String AirlineCode;
        public String AgentCode;
        public String AgentName;
        public String DefaultDate;
        public Decimal Charged;
        public Decimal Refunded;
        public String CurrencyCode;
        public Decimal ExchangeRate;
        public Decimal TotalUSD;
        public String DateValue;
        public String BillingPeriod;
        public String ADCMNumber;

        public SummaryReportData(Map<String, Object> data) {
            this.Operation = (String) data.get('Operation');
            this.AirlineCode = (String) data.get('AirlineCode');
            this.AgentCode = (String) data.get('AgentCode');
            this.AgentName = (String) data.get('AgentName');
            this.DefaultDate = (String) data.get('DefaultDate');
            this.Charged = (Decimal) data.get('Charged');
            this.Refunded = (Decimal) data.get('Refunded');
            this.CurrencyCode = (String) data.get('Currency');
            this.ExchangeRate = (Decimal) data.get('ExchangeRate');
            this.TotalUSD = (Decimal) data.get('TotalUSD');
            this.DateValue = (String) data.get('Date');
            this.BillingPeriod = (String) data.get('BillingPeriod');
            this.ADCMNumber = (String) data.get('ADCMNumber');
        }
    }

    public class InvalidOperationException extends Exception {

    }

    public class MissingParametersException extends Exception {
        
    }
}