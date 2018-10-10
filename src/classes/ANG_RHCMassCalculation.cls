public class ANG_RHCMassCalculation {

    // ******************************
    // ********** variables *********
    // ******************************
    private Id ifap = AMS_Utils.RECTYPE_CASEIFAP; //need to fetch because dynamic queries only receive direct variables
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


    public Integer days {
        get{
            if(days == null) days = 30; //default value
            return days;
        }
        set;
    }

    public String userRegion {
        get{
            if(userRegion == null){
                userRegion = [SELECT IDFS_Region__c FROM User WHERE Id = :UserInfo.getUserId()][0].IDFS_Region__c;
                if(!String.isBlank(userRegion)) userRegion = userCaseRegionsMap.get(userRegion);
            }
            return userRegion;
        }
        set;
    }

    public List<SelectOption> regions {
        get{
            if(regions == null){
                regions = new List<SelectOption>();
                for( Schema.PicklistEntry f : Case.Region__c.getDescribe().getPickListValues()){
                    if(!regionsToIgnore.contains(f.getValue())) regions.add(new SelectOption(f.getValue(), f.getLabel()));
                } 
            }
            return regions;
        }
        private set;
    }

    public List<Agent> agents { 
        get{
            if(agents == null) agents = new List<Agent>();
            if(searched && agents.isEmpty()){
                for(ANG_RHC_Information__c r : (List<ANG_RHC_Information__c>)paginator.getRecords()) agents.add(new Agent(r, selectedAgents.get(r.ANG_AccountId__c), calculatedAgents.contains(r.ANG_AccountId__c)));
            }
            return agents;
        }
        set;
    }

    public ApexPages.StandardSetController paginator {
        get{
            if(paginator == null){
                paginator = new ApexPages.StandardSetController(Database.getQueryLocator(rhcQuery));
                paginator.setPageSize(500);
                paginator.setPageNumber(pageNumber);
            }
            return paginator;
        }
        private set;
    }

    private Map<Id, Decimal> selectedAgents{
        get{
            if(selectedAgents == null) selectedAgents = new Map<Id, Decimal>();
            return selectedAgents;
        }
        set;
    }

    private Set<Id> calculatedAgents{
        get{
            if(calculatedAgents == null) calculatedAgents = new Set<Id>();
            System.debug(loggingLevel.FINE, '____ [cls ANG_RHCMassCalculation - calculatedAgents getter] calculatedAgents - ' + calculatedAgents);
            return calculatedAgents;
        }
        set;
    }

    private String rhcQuery{
        get{
            return 'SELECT ' +
                        'Id' +
                        ', CurrencyIsoCode' +
                        ', ANG_AccountId__c' +
                        ', ANG_AccountId__r.IATACode__c' +
                        ', ANG_AccountId__r.IATA_ISO_Country__c' +
                        ', ANG_RHC_Amount__c' +
                        ', ANG_RHC_Amount_Forecasted__c' +
                        ', ANG_RHC_Amount_Provisional__c' +
                    ' FROM ANG_RHC_Information__c' +
                    ' WHERE ANG_CashCondition__c = false' +
                    ' AND ANG_AccountId__c IN (SELECT AccountId FROM Case WHERE RecordTypeId = :ifap AND isClosed = true AND ClosedDate = LAST_N_DAYS:'+days+' AND Region__c = :userRegion)';
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
        searched = true;
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

    public void fetchResults(){
        AsyncApexJob batchJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :batchId];

        //while it does not complete, check for temporary results
        for(ANG_RHC_Information__c r : [SELECT Id, ANG_AccountId__c FROM ANG_RHC_Information__c WHERE ANG_AccountId__c IN :selectedAgents.keySet() AND LastModifiedDate > :submitTime]) calculatedAgents.add(r.ANG_AccountId__c);

        running = (batchJob.status == 'Ended' || batchJob.status == 'Completed') ? false : true;

        System.debug(loggingLevel.FINE, '____ [cls ANG_RHCMassCalculation - fetchResults] calculatedAgents - ' + calculatedAgents);

        //need to re"draw" table to fetch new values.
        paginator = null;
        agents.clear();
    }

    // ******************************
    // ******** pagination **********
    // ******************************

    public void first(){
        pageNumber = 1;
    }
    public void next(){
        if(paginator.getHasNext()) pageNumber++;
    }
    public void previous(){
        if(paginator.getHasPrevious()) pageNumber--;
    }
    public void last(){
        pageNumber = totalPages;
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

        private Agent(ANG_RHC_Information__c r, Decimal currentAmount, Boolean hasResult){
            this.selected = currentAmount != null;
            this.hasResult = hasResult;
            this.rhcInfo = r;

            this.currentAmount = selected ? currentAmount : r.ANG_RHC_Amount__c;
        }
    }
}