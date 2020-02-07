public with sharing class ADSRService {
    
    private String airlineCode;
    private String selectedRegion;
    private String choosenMarkets;
    private String operationCode;
    private String agentCode;

    public ADSRService(String airline, String region, String markets, String operation, String agent) {
        this.airlineCode = airline;
        this.selectedRegion = region;
        this.choosenMarkets = markets;
        this.operationCode = operation;
        this.agentCode = agent;
    }

    public String getAirlineCode(){
        return this.airlineCode;
    }

    public String getRegion(){
        return this.selectedRegion;
    }

    public String getMarkets(){
        return this.choosenMarkets;
    }

    public String getOperationCode(){
        return this.operationCode;
    }

    public String getAgentCode(){
        return this.agentCode;
    }

    public List<ADSRExternalAPI.SummaryReportData> getReportData(){
        ADSRExternalAPI api = new ADSRExternalAPI(this);
        return api.getSummaryReportData();
    }

    public SummaryReport getSummaryReport(){
        SummaryReport report = new SummaryReport(this.airlineCode);
        List<ADSRExternalAPI.SummaryReportData> data = getReportData();
        
        for(ADSRExternalAPI.SummaryReportData item : data){
            report.addSummaryReportData(item);
        }

        return report;
    }

    public class SummaryReport {
        @AuraEnabled public String airlineCode;
        @AuraEnabled public List<SummaryReportGroup> groups;

        public SummaryReport(String airlineCode){
            this.groups = new List<SummaryReportGroup>();
        }

        public void addSummaryReportData(ADSRExternalAPI.SummaryReportData data){
            SummaryReportGroup reportGroup = null;

            for(SummaryReportGroup currentGroup : this.groups){
                if(data.Operation == currentGroup.operation){
                    reportGroup = currentGroup;
                    break;
                }
            }

            if(reportGroup == null){
                reportGroup = new SummaryReportGroup();
                this.groups.add(reportGroup);
            }

            reportGroup.addSummaryReportDetail(data);
        }
    }

    public class SummaryReportGroup {
        @AuraEnabled public String operation;
        @AuraEnabled public Decimal totalCharged;
        @AuraEnabled public Decimal totalRecovered;
        @AuraEnabled public Decimal totalOutstanding;
        @AuraEnabled public String currencyCode;
        @AuraEnabled public Decimal exchangeRate;
        @AuraEnabled public Decimal totalChargedUSD;
        @AuraEnabled public Decimal totalRecoveredUSD;
        @AuraEnabled public Decimal totalOutstandingUSD;
        @AuraEnabled public Decimal recoveredRate;

        public Date minDate;
        public Date maxDate;

        @AuraEnabled public List<SummaryReportDetail> details;

        public SummaryReportGroup(){
            this.details = new List<SummaryReportDetail>();
            this.totalCharged = 0;
            this.totalRecovered = 0;
            this.totalOutstanding = 0;
            this.totalChargedUSD = 0;
            this.totalRecoveredUSD = 0;
            this.totalOutstandingUSD = 0;
        }

        public void addSummaryReportDetail(ADSRExternalAPI.SummaryReportData reportLine){
            SummaryReportDetail detail = new SummaryReportDetail(reportLine);
            this.details.add(detail);
            
            /*Date currentDate = Date.parse(reportLine.DateValue);
            if(this.minDate == null || this.minDate > currentDate){
                this.minDate = currentDate;
            }
            if(this.maxDate == null || this.maxDate < currentDate){
                this.maxDate = currentDate;
            }*/

            this.operation = reportLine.Operation;
            this.totalCharged += detail.charged;
            this.totalRecovered = null; //TODO
            this.totalOutstanding = detail.outstanding;
            this.currencyCode = reportLine.CurrencyCode;
            this.exchangeRate = reportLine.ExchangeRate;
            this.totalChargedUSD += detail.charged * detail.exchangeRate;
            this.totalRecoveredUSD = null; //TODO
            this.totalOutstandingUSD = null; //TODO
            this.recoveredRate = null; //TODO
        }
    }

    public class SummaryReportDetail {
        @AuraEnabled public String agentCode;
        @AuraEnabled public String agentName;
        @AuraEnabled public String defaultDate;
        @AuraEnabled public Decimal charged;
        @AuraEnabled public Decimal shareRate;
        @AuraEnabled public Decimal refunded;
        @AuraEnabled public Decimal refundedRate;
        @AuraEnabled public Decimal outstanding;
        @AuraEnabled public String currencyCode;
        @AuraEnabled public Decimal exchangeRate;
        @AuraEnabled public Decimal outstandingUSD;
        @AuraEnabled public Decimal totalIndustry;
        @AuraEnabled public String financialSecurityStatus;
        @AuraEnabled public String agentStatus; 

        public SummaryReportDetail(){

        }

        public SummaryReportDetail(ADSRExternalAPI.SummaryReportData detail){
            this.agentCode = detail.AgentCode;
            this.agentName = detail.AgentName;
            this.defaultDate = detail.DefaultDate;
            this.charged = detail.Charged;
            this.shareRate = null; //TODO: open point
            this.refunded = detail.Refunded;
            this.refundedRate = detail.Charged == 0 ? 0 : detail.Refunded / detail.Charged;
            this.outstanding = detail.Charged - detail.Refunded;
            this.currencyCode = detail.CurrencyCode;
            this.exchangeRate = detail.ExchangeRate;
            this.outstandingUSD = detail.TotalUSD;
            this.totalIndustry = null; //TODO: open point
            this.financialSecurityStatus = null; //TODO: see mapping
            this.agentStatus = null; //TODO: see mapping
        }

    }

}