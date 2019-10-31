public class ANG_RHCCopyRHCForecastBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {

    private final static Date TODAYSDATE = Date.today();

    private List<IATA_ISO_Country__c> lIsoCountry;

    private boolean noRegionInput;

    private Map<String, String> errorMap;
    
    private Map<String, SObject> idToSObjectMap;

    private Set<String> regionSet;

    // Time runningTime eg:  Time = Time.newInstance(hour, minutes, seconds, milliseconds); for Asia (Singapore and Bejing) (5 AM time) would be (5,0,0,0)
    public static void scheduleEasternRegion(Time runnigTime){
        //"China & North Asia" or "Asia & Pacific" 
        Set<String> regionSet = new Set<String>{'China & North Asia','Asia & Pacific'};
      
        if(runnigTime == null) runnigTime = System.now().time().addMinutes(5);

        DateTime runningDateTime = DateTime.newInstanceGMT(System.today(), runnigTime).addHours(-8); //creates date on GMT +timezone adjustmnent

        scheduleRegion(regionSet,null,runningDateTime.time());
    }

    // Time runningTime eg:  Time = Time.newInstance(hour, minutes, seconds, milliseconds); for Americas, Europe and AMAN (5 AM CET) would be (5,0,0,0)
    public static void scheduleWesternRegion(Time runnigTime){
        //"Africa & Middle East" or "Europe" or "Americas" 
        Set<String> regionSet= new Set<String>{'Africa & Middle East','Europe','Americas'};
       
        if(runnigTime == null) runnigTime = System.now().time().addMinutes(5);

        DateTime runningDateTime = DateTime.newInstanceGMT(System.today(), runnigTime).addHours(-1); //creates date on GMT +timezone adjustmnent
        scheduleRegion(regionSet,null,runningDateTime.time());
    }

    private static void scheduleRegion(Set<String> regionList,Date runningDate,Time runningTime){

        ANG_RHCCopyRHCForecastBatch bat = new ANG_RHCCopyRHCForecastBatch(regionList);

        String format ='ss mm HH dd MM ? yyyy';
        
        if(runningDate == null){
            format = 'ss mm HH * * ? *';
            runningDate = System.today();
        }
        
        String sch = Datetime.newInstance(runningDate,runningTime).format(format);
        String jobID = System.schedule('Batch RHC Information - Copy RHC Forecast to RHC Amount Job '+System.now().format('dd/MM/yyyy hh:MM:ss'), sch, bat);

    }

    public void execute(SchedulableContext context){
		
        System.debug('Dudu:executing ANG_RHCCopyRHCForecastBatch');
        
		//check if there are 5 active batch jobs
		//In some cases, might need to add "Status='Queued' " to the criteria
		Set<String> setStatusBatch = new Set<String>{'Processing','Preparing'};

		if(Test.isRunningTest()){
			setStatusBatch.add('Queued');
			test.enqueueBatchJobs(5);
		}
		                
        if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND Status in: setStatusBatch] < 5){ 
			Database.executeBatch(this, 1);
		} else {

            //schedule this same schedulable class again in 30 mins
            Datetime dt = Datetime.now().addMinutes(30);
            String timeForScheduler = dt.format('s m H d M \'?\' yyyy');

            String jobID = System.schedule('Batch RHC Information - Copy RHC Forecast to RHC Amount Job '+timeForScheduler, timeForScheduler, this);

		}

    }

	public ANG_RHCCopyRHCForecastBatch(Set<String> rhcAccountregionsIn) {
        
        errorMap = new Map<String, String>();
        
        idToSObjectMap = new Map<String, SObject>();

        noRegionInput = rhcAccountregionsIn == null || rhcAccountregionsIn.isEmpty();

		Set<String> rhcAccountRegions = (rhcAccountregionsIn == null || rhcAccountregionsIn.isEmpty()) ? new Set<String>() : rhcAccountregionsIn;

        Set<String> setAIMSRegion = new Set<String>();

        for(String localRegion: rhcAccountregions){
                setAIMSRegion.add(localRegion);
        }

        if(!setAIMSRegion.isEmpty())
            lIsoCountry = IATAIsoCountryDAO.getIsoCountriesByRegion(setAIMSRegion);

	}
	
	public Iterable<SObject> start(Database.BatchableContext bc) {
        
        System.debug('lIsoCountry is:'+lIsoCountry);
        
        String query = 'SELECT Id, ANG_RHC_Amount_Forecasted__c, ANG_RME_Amount__c, ANG_RHC_Amount__c, ANG_AccountId__r.IATACODE__c, ANG_AccountId__r.Name from ANG_RHC_Information__c where ANG_Forecasted_RHC_Effective_date__c = :todaysDate';
        
        if(!noRegionInput) {query += ' and ANG_AccountId__r.IATA_ISO_Country__c in :lIsoCountry';}
        
        system.debug('query is:'+query);
        
        return (Iterable<SObject>) Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext bc, List<ANG_RHC_Information__c> scope) {
        
        List<ANG_RHC_Information__c> elementsToUpdate = new List<ANG_RHC_Information__c>();

        for(ANG_RHC_Information__c rhcElement :scope){
            
            system.debug('scope is:'+scope);
                        
            if(rhcElement.ANG_RHC_Amount__c <> rhcElement.ANG_RHC_Amount_Forecasted__c){
                rhcElement.ANG_RHC_Amount__c = rhcElement.ANG_RHC_Amount_Forecasted__c;
                elementsToUpdate.add(rhcElement);
            }

        }

		system.debug('elementsToUpdate are:'+elementsToUpdate);

        if(!elementsToUpdate.isEmpty()){
			
            List<Database.SaveResult> dsrs = Database.Update(elementsToUpdate, false);
            String errMsg;

            Integer index = 0;
            for(Database.SaveResult dsr : dsrs){
                
                if(!dsr.getErrors().isEmpty()){
                    errMsg = dsr.getErrors()[0].getMessage();
                    errorMap.put(elementsToUpdate[index].ANG_AccountId__r.IATACODE__c, errMsg);
                    idToSObjectMap.put(elementsToUpdate[index].ANG_AccountId__r.IATACODE__c, elementsToUpdate[index]);
                }
                index++;
            }
        }

    }

    public void finish(Database.BatchableContext bc) {

        System.debug('[ANG_RHCCopyRHCForecastBatch] Batch executed with ' + errorMap.size() + ' errors.');
     
        if(!errorMap.isEmpty()){

            String objectDescription;
            ANG_RHC_Information__c rhc;
            String errorMessage = '';
            string err;

            for(String id  : errorMap.keySet()){
                err = errorMap.get(id);
                rhc = (ANG_RHC_Information__c) idToSObjectMap.get(id);
                objectDescription = rhc.ANG_AccountId__r.Name + '(' + rhc.ANG_AccountId__r.IATACODE__c+')';
                errorMessage += objectDescription + ':'+err+'\n';
            }
            
            ServiceNow_Helper.SNOWBody theBody = new ServiceNow_Helper.SNOWBody();
            theBody.description = errorMessage;
            ServiceNow_Helper.sendRequestToSNOW(theBody,'SNOW19');

        } 
      
    }
}