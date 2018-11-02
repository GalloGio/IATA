/**
 * Batch Class to Synchronize AMS_Agency_Airport__c => Adjacent_Airport__c
 * @author Bhanu Chandra Bulusu<bulusub@iata.org>
 * @version 1.0
 */

global class ams2gdp_Batch_AMS_Agency_Airport implements Database.Batchable<sObject> , Database.Stateful 
{    
    public String query;
	public Integer errorsCount;
	public Integer totalRecords;
	public List<String> failed_records;
	public Datetime syncStartedDate;
	public Boolean processNextBatch;
	public Boolean throwException;
	public String batchName;
	public List<String> extraIds;
    Set<String> locationsSet;
    Set<String> statusSet;
	public Boolean isManual;

	public void init(Boolean runNext, List<String> ids, Boolean manual)
	{
		isManual = manual==null ? false : manual;
		batchName = 'Job 8: Adjacent Airport'; 
		processNextBatch = runNext;
		extraIds = ids;

		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('Account');

		String fields = ' Id, Name, Airport__r.Code__c, Account__c ';

		//-- Query conditions 
		// String accreditation_condition = 'SELECT Related_Account__c '
		// 	+	'FROM Accreditation__c '
		// 	+	'WHERE Endorsed_Accredited_By_Formula__c IN (\'IATA\',\'IATAN\',\'DOM\')'
		// 	+	'	AND Status__r.Code__c IN (\'0\',\'4\',\'5\',\'6\',\'7\',\'8\',\'9\') ';

		List<String> conditions = new List<String>{'Account__r.RecordTypeId= \''+recordTypes.get('Agency')+'\''
			, 'Account__r.IATACode__c != null'
            , 'Account__r.Main_Accreditation_Organization__c IN (\'IATA\',\'IATAN\',\'DOM\') '
            , 'Account__r.CNS_Agency__c = false'
			, 'Account__r.CNS_Account__c = false'
			// , 'Account__c IN ('+accreditation_condition+')'
		}; 

		if(extraIds!=null && extraIds.size() > 0) {
			 if(extraIds[0]=='none'){	
			 conditions.add('Id=null');}
			 else{
			//Run batch on specific Ids 
			List<String> specificIds = new List<String>(); 
			for(String s: extraIds)
			{
				if(s.length() >= 15)
					specificIds.add(s.left(15));
			}

			if(specificIds.size() > 0)	conditions.add('Id IN (\''+String.join(specificIds,'\', \'')+'\')');}
		}else{
            if(!String.isBlank(AMS_2_GDP_Settings__c.getOrgDefaults().Status__c)) {
				statusSet = new Set<String>(AMS_2_GDP_Settings__c.getOrgDefaults().Status__c.split(';'));
				conditions.add('Account__r.Status__c IN  :statusSet ');

			}
			if(!String.isBlank(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c)) {
				locationsSet = new Set<String>(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c.split(';'));
				conditions.add('Account__r.Location_Class__c IN:  locationsSet');
			}
			AMS_GDP_Batch__c batchInfo = ams2gdp_Selector.getBatchInfo(batchName);
			if(batchInfo != null)
			{
				//Run only on the deltas 
				String deltaConditions = String.format('LastModifiedDate >= {0}'
					,new List<String>{batchInfo.Last_Sync_Start_Date__c.addDays(-2).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'','GMT')});

				if(String.isNotBlank(batchInfo.Failed_Records__c))
				{
					// Reprocess failed records 
					List<String> failedRecordIds = new List<String>(); 
					for(String s: batchInfo.Failed_Records__c.split(';'))
					{
						if(s.length() >= 15)
							failedRecordIds.add(s.left(15));
					}
					if(failedRecordIds.size() > 0)
						deltaConditions += ' OR Id IN (\'' + String.join(failedRecordIds, '\' , \'') + '\') ';
				}

				conditions.add('('+deltaConditions+')');
			}
		}

		query = String.format('SELECT {0} '
			+	'FROM AMS_Agency_Airport__c '
			+ 	'WHERE {1} ', 
			new List<String>{fields,String.join(conditions, ' AND ')}
		);

		/*String accreditation_condition = 'SELECT Related_Account__c '
			+	'FROM Accreditation__c '
			+	'WHERE Endorsed_Accredited_By_Formula__c IN (\'IATA\',\'IATAN\',\'DOM\')'
			+	'	AND Status__r.Code__c IN (\'0\',\'4\',\'5\',\'6\',\'7\',\'8\',\'9\') ';


		String batch_info_condition = ''; 
		AMS_GDP_Batch__c batch_info = ams2gdp_Selector.getBatchInfo(batchName); 

		if(batch_info != null)
		{
			batch_info_condition = String.format(' AND (LastModifiedDate >= {0} ', new List<String>{batch_info.Last_Sync_Start_Date__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')});
			
			//-- Include failed records
			if(String.isNotBlank(batch_info.Failed_Records__c))
			{
				batch_info_condition += ' OR Id IN (\'' + String.join(batch_info.Failed_Records__c.split(';'), '\' , \'') + '\') ';
			}
			batch_info_condition += ' )';
		}

		query = String.format('SELECT {0} '
			+	'FROM AMS_Agency_Airport__c '
			+ 	'WHERE (Account__r.RecordTypeId= {1} AND Account__r.IATACode__c != null AND Account__c IN ({2}) {3}) ',
			new List<String>{fields,'\''+recordTypes.get('Agency')+'\'',accreditation_condition, batch_info_condition}
		);*/
	}
    
    global ams2gdp_Batch_AMS_Agency_Airport() 
    {
    	init(false, null, null);
    }
    
    global ams2gdp_Batch_AMS_Agency_Airport(Boolean runNext, Boolean manual)
	{
		init(runNext,null, manual);
    }

    global ams2gdp_Batch_AMS_Agency_Airport(Boolean runNext, List<String> extra, Boolean manual)
	{
		init(runNext,extra,manual);	
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        syncStartedDate = Datetime.now();
        errorsCount = 0;    
        totalRecords = 0;
        failed_records = new List<String>();

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<AMS_Agency_Airport__c> scope) {
        totalRecords += scope.size();

        List<Adjacent_Airport__c> records2Save = new List<Adjacent_Airport__c>();

        // Process Errors 
		List<ams2gdp_Error> errors =  new List<ams2gdp_Error>();

        try
        {
        	records2Save=ams2gdp_BusinessLogic.formatAgencyAirport2AdjacentAirport(scope);	

        	//-- Raise exception for Unit Tests
			if(Test.isRunningTest() &&   throwException) insert new Account();	
        }
        catch(Exception ex)
        {
        	errors.add(ams2gdp_Error.Exception2Error(batchName, ex));
        }
      
        List<Database.UpsertResult> save_results = Database.upsert(records2Save,Adjacent_Airport__c.AMS_GDP_Key__c.getDescribe().getSObjectField(),false);
		
        //--Check if there is orphan GDP records 
		for(Adjacent_Airport__c aa: records2Save)
		{
			if(aa.Related_GDP_Products_Account_View__c == null)
			{
				errors.add(new ams2gdp_Error(batchName,aa.AMS_GDP_Key__c.left(18), null, 'ORPHAN_RECORD'));
			}
		}

      	// Process Errors 
		errors.addAll(ams2gdp_Error.formatUpsertResult(records2save, save_results, batchName, 'AMS_GDP_Key__c'));

		//Log the current Errors
		if(!errors.isEmpty())
		{
            errorsCount = errorsCount + errors.size();
			ams2gdp_Utils.logErrors(errors);

			//-- Save failed records
			Set<String> set_failed_records = new Set<String>(failed_records);

			for(ams2gdp_Error failed_rec : errors)
            {
               if(String.isNotBlank(failed_rec.amsRecordId))
				set_failed_records.add(failed_rec.amsRecordId.left(18));
			
                failed_records =new List<String>(set_failed_records);
            }
		}
    
    }
    
    global void finish(Database.BatchableContext BC) {
    	if(processNextBatch)Database.executeBatch(new ams2gdp_Batch_AMS_Agency_Profile(true, isManual));
		ams2gdp_Utils.upsertAMS_GDP_Batch(batchName, syncStartedDate, errorsCount, totalRecords, failed_records, isManual);
		//--Send completion notification 
		ams2gdp_Utils.notifyBatchOutput(batchName, totalRecords, errorsCount, failed_records);	      
    }    
}