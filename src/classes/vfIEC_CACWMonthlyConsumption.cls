/**
* @author Alexandre Jaimes
* @date 2016
* @group CACW
* @description This is the controller used to show the monthly and historic consumption for CACWeb
* 
* Change logs:
*  - 20160708-Sonny Leman: bug fix on calculating the Max API for unused CAC Subscription for IEC_CACWDetail 
*
*/
public  class vfIEC_CACWMonthlyConsumption {
    private final vfIEC_CACW iecCacWeb;

    public String segment {
        public get {
            if (segment == null) {
                segment = 'Monthly';
                if (ApexPages.currentPage().getParameters().containsKey('Segment')) segment = ApexPages.currentPage().getParameters().get('Segment');
            }
            return segment;
        }
        public set {
            if (value != 'Daily' && value != 'Monthly' && value != 'Yearly') throw new ConsumptionReportException('Unknown segment');

            segment = value;

            ApexPages.currentPage().getParameters().put('Segment', value);
        }
    }
    public Date startDate {
        public get {
            if (startDate == null) {
                if (segment == 'Daily') {
                    startDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
                } else if (segment == 'Monthly') {
                    startDate = Date.newInstance(s.Zuora__SubscriptionStartDate__c.year(), s.Zuora__SubscriptionStartDate__c.month(), 1);
                } else if (segment == 'Yearly') {
                    startDate = Date.newInstance(s.Zuora__SubscriptionStartDate__c.year(), 1, 1);
                }
            }

            return startDate;
        }
        public set;
    }

    // Workaround for not being able to use commandLink/apex:param on a date property
    public String startDateText {public get;public set {startDate = Date.valueOf(value);}}

    public Date endDate {
        public get {
            if (endDate == null) {
                if (segment == 'Daily') {
                    endDate = Date.newInstance(startDate.year(), startDate.month(), Date.daysInMonth(startDate.year(), startDate.month()));
                } else if (segment == 'Monthly') {
                    endDate = Date.newInstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));
                } else if (segment == 'Yearly') {
                    endDate = Date.newInstance(Date.today().year(), 12, 31);
                }
            }

            if (endDate > Date.today()) endDate = Date.today();

            return endDate;
        }
        public set;
    }

    // Workaround for not being able to use commandLink/apex:param on a date property
    public String endDateText {public get;public set {endDate = Date.valueOf(value);}}

    public Zuora__Subscription__c s {
        public get {
            if (s == null) {
                s = [Select Id, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c From Zuora__Subscription__c Where Name = :iecCacWeb.ctrSubsInfo.sSelectedSubscriptionName];
            }

            return s;
        }
        private set;
    }


    public CACWebAPIPeriodConsumption  aPeriodConsumption {
        public get {
            if (aPeriodConsumption == null) {
                aPeriodConsumption = new CACWebAPIPeriodConsumption();
                aPeriodConsumption.periodStartDate = startDate;
                aPeriodConsumption.periodEndDate = endDate;
                aPeriodConsumption.APICallsForPeriodConsumed = 0;
            }

            return aPeriodConsumption;
        }
        private set;
    }
    public list<CACWebAPIPeriodConsumption> PeriodConsumptionHistory    {
        public get {
            if (PeriodConsumptionHistory == null) {

                // Build list of records with 0 consumption
                Map<String, CACWebAPIPeriodConsumption> matrix = new Map<String, CACWebAPIPeriodConsumption>();
                Date matrixRowPeriodStart = startDate;
                if (segment == 'Monthly') {
                    matrixRowPeriodStart = Date.newInstance(matrixRowPeriodStart.year(), matrixRowPeriodStart.month(), 1);
                } else if (segment == 'Yearly') {
                    matrixRowPeriodStart = Date.newInstance(matrixRowPeriodStart.year(), 1, 1);
                }

                do {
                    CACWebAPIPeriodConsumption p = new CACWebAPIPeriodConsumption();
                    p.periodStartDate = matrixRowPeriodStart;
                    p.APICallsForPeriodConsumed = 0;
                    String key;
                    Date nextPeriodStart;


                    if (segment == 'Daily') {
                        p.label = '{0,date, EEE, d MMM yyyy}';
                        p.periodEndDate = p.periodStartDate;
                        key = String.valueOf(matrixRowPeriodStart.year()) + String.valueOf(matrixRowPeriodStart.month()).leftPad(2) + String.valueOf(matrixRowPeriodStart.day()).leftPad(2);
                        nextPeriodStart = matrixRowPeriodStart.addDays(1);
                    } else if (segment == 'Monthly') {
                        nextPeriodStart = matrixRowPeriodStart.addMonths(1);
                        p.label = '{0,date, MMMMM yyyy}';
                        p.detailSegment = 'Daily';
                        p.periodEndDate = nextPeriodStart.addDays(-1);
                        key = String.valueOf(matrixRowPeriodStart.year()) + String.valueOf(matrixRowPeriodStart.month()).leftPad(2);

                    } else if (segment == 'Yearly') {
                        nextPeriodStart = matrixRowPeriodStart.addYears(1);

                        p.label = '{0, date, yyyy}';
                        p.detailSegment = 'Monthly';
                        p.periodEndDate = nextPeriodStart.addDays(-1);
                        key = String.valueOf(matrixRowPeriodStart.year());
                    }

                    matrix.put(key, p);


                    matrixRowPeriodStart = nextPeriodStart;

                } while(matrixRowPeriodStart <= endDate);

                // Override the records consumption with the data that is available
                List<UsageAggregateResult> aggrResults = getAggregateResult();

                for(UsageAggregateResult aggrResult : aggrResults) {
                    Integer used = Integer.valueOf(aggrResult.cntTotal);
                    aPeriodConsumption.APICallsForPeriodConsumed += used;
                    String key;

                    CACWebAPIPeriodConsumption p = new CACWebAPIPeriodConsumption();
                    if (segment == 'Daily') {
                        p.periodStartDate = Date.newInstance(Integer.valueOf(aggrResult.year), Integer.valueOf(aggrResult.month), Integer.valueOf(aggrResult.day));
                        p.periodEndDate = p.periodStartDate;
                        key = String.valueOf(p.periodStartDate.year()) + String.valueOf(p.periodStartDate.month()).leftPad(2) + String.valueOf(p.periodStartDate.day()).leftPad(2);
                    } else if (segment == 'Monthly') {
                        p.periodStartDate = Date.newInstance(Integer.valueOf(aggrResult.year), Integer.valueOf(aggrResult.month), 1);
                        p.periodEndDate = Date.newInstance(p.periodStartDate.year(), p.periodStartDate.month(), Date.daysInMonth(p.periodStartDate.year(), p.periodStartDate.month()));
                        key = String.valueOf(p.periodStartDate.year()) + String.valueOf(p.periodStartDate.month()).leftPad(2);
                    } else if (segment == 'Yearly') {
                        p.periodStartDate = Date.newInstance(Integer.valueOf(aggrResult.year), 1, 1);
                        p.periodEndDate = Date.newInstance(p.periodStartDate.year(), 12, 31);
                        key = String.valueOf(p.periodStartDate.year());
                    }

                    p.APICallsForPeriodConsumed = used;
                    p.label = matrix.get(key).label;
                    p.detailSegment = matrix.get(key).detailSegment;
                    p.APICallsForPeriodAllowed = Integer.ValueOf(aggrResult.maxusage); // this APICallsForPeriodAllowed will be corrected later in applySubscriptionDetails
                    
                    /*p.APICallsForPeriodAllowed = matrix.get(key).APICallsForPeriodAllowed;
                    p.Credits = matrix.get(key).Credits;*/

                    matrix.put(key, p);
                }

                if (segment == 'Monthly') {
                    applySubscriptionDetails(matrix);
                }

                PeriodConsumptionHistory = new list<CACWebAPIPeriodConsumption>();
                List<CACWebAPIPeriodConsumption> matrixValues = matrix.values();
                for(Integer i = matrixValues.size() - 1; i >= 0; i--) {
                    PeriodConsumptionHistory.add(matrixValues[i]);
                }
            }

            return PeriodConsumptionHistory;
        }
        private set;
    }

    public PageReference rerender() {
        PeriodConsumptionHistory = null;
        aPeriodConsumption = null;
        return null;
    }
    
    //read all the attachments for the given Subscription and report them to the visual force page
    public List<Attachment> ReadAttachment
    {
     public get {
        List<CAC_Subscription_Detail__c> caclist = new List<CAC_Subscription_Detail__c>();
        
        caclist=[SELECT id
                      ,Service_Specification__c
                   FROM CAC_Subscription_Detail__c 
                   WHERE Subscription__c = :s.Id
                   Limit 1000];
                   
        Set<id> aset = new Set<Id>();
        for(CAC_Subscription_Detail__c c:caclist)
        {
          aset.add(c.Service_Specification__c);
        }
        List<Attachment> attachment = new List<Attachment>();
        attachment = [Select id
                        ,name
                        ,Body
                        From Attachment
                        Where ParentId=:aset
                      Limit 1000];
        return attachment;
      }
        private set;
                      
    }
    
    // ========================================================================
    // applySubscriptionDetails uses SubscriptionDetails to complete the CACWebAPIPeriodConsumption: 
    // credit and APICallsForPeriodAllowed 
    // the complexity lies on the can of service upgrade, where the system deactivated previous CAC_Subscription_Detail
    // but not putting the execution date
    // to know the current APICallsForPeriodAllowed is easy, but to know the previous period APICallsForPeriodAllowed might be more difficult
    // for current version: APICallsForPeriodAllowed is set to the current valid values.
    private void applySubscriptionDetails(Map<String, CACWebAPIPeriodConsumption> matrix) 
    {
        List<CAC_Subscription_Detail__c> details = [
            Select Max_API_Call_Per_Month__c,
                CreatedDate,
                Status__c, 
                (Select Id, Credit__c, Date__c From CAC_Subscription_Credits__r Where Date__c >= :startDate AND Date__c <= :endDate),
                (SELECT NewValue,OldValue, CreatedDate FROM Histories WHERE Field = 'Max_API_Call_Per_Month__c' ORDER BY CreatedDate DESC)
            From CAC_Subscription_Detail__c
            Where Subscription__c = :s.Id
            AND Status__c='Active'
            order by CreatedDate desc
        ];

        Map<Date, Integer> credits = new Map<Date, Integer>();
        Map<Date, Integer> limits = new Map<Date, Integer>();
        Integer originalLimit = 0;
        decimal currentSubscriptionMaxApiCallPerMonth = 0;
        for(CAC_Subscription_Detail__c detail : details) {
            currentSubscriptionMaxApiCallPerMonth += (detail.Max_API_Call_Per_Month__c == null)? 0 : detail.Max_API_Call_Per_Month__c; 
            
            for(CAC_Subscription_Credit__c detailCredit : detail.CAC_Subscription_Credits__r) {
                Integer credit = (credits.containsKey(detailCredit.Date__c) ? (credits.get(detailCredit.Date__c)) : 0);
                credit += Integer.valueOf(detailCredit.Credit__c);
                credits.put(detailCredit.Date__c, credit);
            }

            System.debug(detail.Histories);

            Integer i = 0;
            Date lastDateChecked;
            for(CAC_Subscription_Detail__History detailHistory : detail.Histories) {
                i++;
                if (i == detail.Histories.size()) { // Store the original value
                    originalLimit += Integer.valueOf(detailHistory.OldValue);
                }

                Date d = Date.newInstance(detailHistory.CreatedDate.year(), detailHistory.CreatedDate.month(), detailHistory.CreatedDate.day());

                if (d == lastDateChecked) continue;
                lastDateChecked = d;

                Integer l = (limits.containsKey(d) ? (limits.get(d)) : 0);
                System.debug(l);

                l += Integer.valueOf(detailHistory.NewValue);
                limits.put(d, l);
            }

            if (detail.Histories == null || detail.Histories.size() == 0) originalLimit += Integer.valueOf(detail.Max_API_Call_Per_Month__c);
        }

        if (!limits.containsKey(matrix.values()[0].periodStartDate)) limits.put(matrix.values()[0].periodStartDate, originalLimit);

        Integer previousLimit; 
        List<String> matrixKeys = new List<String>(matrix.keySet());
        matrixKeys.sort();


        for(String key : matrixKeys) {
            CACWebAPIPeriodConsumption p = matrix.get(key);
            
            for(Date d : credits.keySet()) {
                if (p.periodStartDate > d || p.periodEndDate < d) continue;
                p.Credits += credits.get(d);
            }
            
            // this will set the APICallForPeriodAllowed for the current valid values
            // for historical value, the value might be incorrect
            p.APICallsForPeriodAllowed = Integer.valueOf(currentSubscriptionMaxApiCallPerMonth); // this corrects previous maxusage calculation
            // SL Note: need to check about why the code below was commented out.
        }
    } // end of applySubscriptionDetails

    
    public Class UsageAggregateResult
    {
        public decimal  cntTotal {get;set;}
        public integer  year {get;set;}
        public integer  month {get;set;}
        public integer  day {get;set;}
        public decimal  maxusage {get;set;}
        public Id Subscription {get;set;}
        public Id SubscriptionDetail  {get;set;}
        
        public UsageAggregateResult(integer vyear, integer vmonth, integer vday, decimal vcounter ,decimal vmaxusage , Id vSubscriptionId,  Id vSubscriptionDetailId)
        {
          cntTotal=vcounter;
          year=vyear;
          month=vmonth;
          day=vday;
          Subscription=vSubscriptionid;
          SubscriptionDetail=vSubscriptionDetailId;
          maxusage=vmaxusage;
        }
    }

    // ========================================================================
    // getAggregateResult return the list of UsageAggregateResult
    // based on IEC_Compiled_Usage_Tracker for this Zuora__Subscription
    // usageMax is IEC_Compiled_Usage_Tracker.Max_API_Call_Per_Month__c
    // cntTotal is the sum of IEC_Compiled_Usage_Tracker__c.Counter
    // calculation for usagemax is only correct if all active CAC_Subscription_Detail has related IEC_Compiled_Usage_Tracker 
    private List<UsageAggregateResult> getAggregateResult() {
        
        List<IEC_Compiled_Usage_Tracker__c> ulist = new List<IEC_Compiled_Usage_Tracker__c>();
        ulist=[SELECT
                    Counter__c,
                    CAC_Subscription_Detail__c,
                    CAC_Subscription_Detail__r.Max_API_Call_Per_Month__c,
                    Max_API_Call_Per_Month__c,
                    Date__c
                FROM IEC_Compiled_Usage_Tracker__c 
                WHERE CAC_Subscription_Detail__r.Subscription__c = :s.Id
                    AND Date__c >= :startDate
                    AND Date__c <= :endDate                 
                ORDER BY Date__c Asc
               LIMIT 100000];
            
            
        //compute statistics by period of time
        decimal usagemax=0;
        integer year=0;
        integer month=0;
        integer day=0;
        String monthkey='';
        String daykey='';
        String key='';
        Map<String, UsageAggregateResult> umap = new Map<String, UsageAggregateResult>();
        for(IEC_Compiled_Usage_Tracker__c u:ulist)  {
             monthkey='';
             daykey='';

             usagemax=u.Max_API_Call_Per_Month__c;
             if(usagemax==null) usagemax=u.CAC_Subscription_Detail__r.Max_API_Call_Per_Month__c;
             if(usagemax==0) usagemax=u.CAC_Subscription_Detail__r.Max_API_Call_Per_Month__c;
             year=u.Date__c.Year();
             month=u.Date__c.Month();
             day=u.Date__c.Day();
             if (day<10) daykey='0';
             if (month<10) monthkey='0';
             //if (segment == 'Daily') 
             if (segment == 'Monthly') day=0;
             if (segment == 'Yearly') {month=0; day=0;}
             
             key = String.ValueOf(year) + monthkey + String.ValueOf(month)+ daykey + String.ValueOf(day);
             if (umap.ContainsKey(key))
             {
                 UsageAggregateResult usage=umap.get(key);
                 if (u.Counter__c!=null) usage.cntTotal += u.Counter__c;
                 usage.maxusage=usagemax;
                 
             }else
             {
                UsageAggregateResult usage= new UsageAggregateResult(year, month, day, u.Counter__c, usagemax , s.Id , u.CAC_Subscription_Detail__c); 
                umap.put(key,usage);
             }
             
        }
        return umap.Values();
    }
      
    /* 
    * @description extension's constructor. Uses main controller as input parameter
    */
    public vfIEC_CACWMonthlyConsumption(vfIEC_CACW controller) {
        this.iecCacWeb = controller;

        if (ApexPages.currentPage().getUrl().indexOf('IEC_CACWMonthlyConsumption') != -1 || ApexPages.currentPage().getUrl().indexOf('IEC_CACWDetail') != -1) {
            segment = 'Monthly';
            startDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
            endDate = Date.newInstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));
        }
    }
    
    /*
    * @description this inner class is a single period consumption information
    */
        public class CACWebAPIPeriodConsumption{
            public Date periodStartDate                     {public get; private set;}
            // Workaround for not being able to use commandLink/apex:param on a date property
            public String periodStartDateText               {public get {return String.valueOf(periodStartDate);}private set;}
            public Date periodEndDate                       {public get; private set;}
            // Workaround for not being able to use commandLink/apex:param on a date property
            public String periodEndDateText                 {public get {return String.valueOf(periodEndDate);}private set;}
            public String label                             {public get; private set;}
            public String detailSegment                     {public get; private set;}
            public Integer Credits      {
                public get {
                    if (Credits == null) Credits = 0;
                    return Credits;
                }
                private set;
            }
            public Integer TotalAllowed {
                public get {
                    return APICallsForPeriodAllowed + Credits;
                }
            }
            public Integer APICallsForPeriodAllowed         {
                public get {
                    if (APICallsForPeriodAllowed == null) APICallsForPeriodAllowed = 0;
                    return APICallsForPeriodAllowed;
                }
                private set;
            }
            public Integer APICallsForPeriodConsumed        {
                public get {
                    if (APICallsForPeriodConsumed == null) APICallsForPeriodConsumed = 0;
                    return APICallsForPeriodConsumed;
                }
                private set;
            }
            public Integer APICallsForPeriodLeft            {get{ return TotalAllowed-APICallsForPeriodConsumed;}}
            public decimal APICallsUsedPercentage           {get { 
                if (APICallsForPeriodAllowed == 0) return null;
                                                                return (APICallsForPeriodAllowed != 0 ) ?  
                                                                    Math.Round(1.0*APICallsForPeriodConsumed / APICallsForPeriodAllowed * 100) : 
                                                                    0; }
                                                            }
    
            public CACWebAPIPeriodConsumption() {}

            /*
             * @description Calculated from formula:
             * Projected Service Run Out Date  = ROUND(APICallsForPeriodAllowed MULTIPLIED by Current Day of the Month DIVIDED by Consumption Used)
             * ROUND shall be done to the lowest value.
             **/
            public Date ProjectedServiceRunOutDate {
                get{
                    if(APICallsForPeriodConsumed != 0){
                        Date lastDate = (periodEndDate <= Date.today() ? periodEndDate : Date.today());
                        if (lastDate < periodStartDate) lastDate = periodStartDate;

                        Decimal avgPerDay = (1.0 * APICallsForPeriodConsumed / (periodStartDate.daysBetween(lastDate) + 1));
                        Decimal daysToReachLimit = (1.0 * TotalAllowed / avgPerDay);

                        return Date.newInstance( periodStartDate.Year()
                                            ,periodStartDate.Month()
                                            ,Integer.valueOf(daysToReachLimit.round(System.RoundingMode.DOWN)));
                        /*
                        return Date.newInstance( Date.Today().Year()
                                            ,Date.Today().Month()
                                            ,((1.0 * TotalAllowed * Date.Today().day()) / APICallsForPeriodConsumed).round(System.RoundingMode.CEILING).intValue() );*/
                    }
                    else
                        return null;
                }
            }
            
            /*
             * @description Calculated from formula:
             * Projected Service Run Out Date  = ROUND(APICallsForPeriodAllowed MULTIPLIED by Current Day of the Month DIVIDED by Consumption Used)
             * ROUND shall be done to the lowest value.
             **/
            public Date ProjectedServiceRunOutDateMonthlyAllowed {
                get{
                    if(APICallsForPeriodConsumed != 0){
                        Date lastDate = (periodEndDate <= Date.today() ? periodEndDate : Date.today());
                        if (lastDate < periodStartDate) lastDate = periodStartDate;

                        Decimal avgPerDay = (1.0 * APICallsForPeriodConsumed / (periodStartDate.daysBetween(lastDate) + 1));
                        Decimal daysToReachLimit = (1.0 * APICallsForPeriodAllowed / avgPerDay);

                        return Date.newInstance( periodStartDate.Year()
                                            ,periodStartDate.Month()
                                            ,Integer.valueOf(daysToReachLimit.round(System.RoundingMode.DOWN)));
                        /*
                        return Date.newInstance( Date.Today().Year()
                                            ,Date.Today().Month()
                                            ,((1.0 * TotalAllowed * Date.Today().day()) / APICallsForPeriodConsumed).round(System.RoundingMode.CEILING).intValue() );*/
                    }
                    else
                        return null;
                }
            }
            
             /*
             * @description Returns Projected Monthly Consumpion
             * Projected Monthly Consumpion = UsedRequest / currentDay * Days in Current month
             **/
            public Integer ProjectedConsumptionAtEndOfMonth {
                get{
                    if(APICallsForPeriodConsumed != 0){
                        Date lastDate = (periodEndDate <= Date.today() ? periodEndDate : Date.today());
                        if (lastDate < periodStartDate) lastDate = periodStartDate;

                        Decimal avgPerDay = (1.0 * APICallsForPeriodConsumed / (periodStartDate.daysBetween(lastDate) + 1));

                        return Integer.valueOf((avgPerDay * Date.daysInMonth(periodStartDate.year(), periodStartDate.month())).round(System.RoundingMode.CEILING));
                    }
                    else
                        return null;
                    /*
                    return  Integer.valueOf((1.0 * APICallsForPeriodConsumed / 
                            Date.Today().day() * 
                            Date.daysInMonth(Date.Today().year(), Date.Today().month())).round(System.RoundingMode.CEILING));*/
                }
            }
            
            /*
             * @description The "Recommendation" section shall display conditionally: 
             * if the Projected Service Run Out Date < Last day of current Month, 
             * we will show the paragraph, else no, the section stays invisible to the user.
             **/
            public boolean showRecommendation{
                get{
                    if (ProjectedServiceRunOutDate <= Date.newInstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()))) return true;
                    return false;
                }
            }
            /*
             * @description The "Recommendation" section shall display conditionally: 
             * if the Projected Service Run Out Date < Last day of current Month, 
             * we will show the paragraph, else no, the section stays invisible to the user.
             **/
            public boolean showRecommendationMonthlyAllowed{
                get{
                    if (ProjectedServiceRunOutDateMonthlyAllowed <= Date.newInstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()))) return true;
                    return false;
                }
            }   
        }   


    public class ConsumptionReportException extends Exception {}
}