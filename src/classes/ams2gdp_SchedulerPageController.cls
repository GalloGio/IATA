public with sharing class ams2gdp_SchedulerPageController
{
	public String jobName{get;set;}
    public String recordIds{get;set;}
    public Boolean processNext{get;set;}
    public String query{get;set;}
    public List<String> jobIds{get;set;}
    public Boolean isManual {get; set;}

	public List<SelectOption> availableJobs{get;set;}
	public List<AsyncApexJob> jobs{get{
		List<AsyncApexJob> theJobs;

		if(jobIds.size() == 0)
		{
			Datetime dt = Datetime.now().addHours(-1);
			theJobs =  [
				SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, ApexClass.Name, MethodName, CompletedDate, JobType FROM AsyncApexJob
				WHERE CreatedBy.Id = :UserInfo.getUserId() AND CompletedDate >= :dt
	            ORDER BY Status, CompletedDate DESC
			];
		}
		else
		{
			theJobs =  [
				SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, ApexClass.Name, MethodName, CompletedDate, JobType FROM AsyncApexJob
				WHERE Id IN :jobIds
			];
		}

		return theJobs;

	}set;}


	public ams2gdp_SchedulerPageController()
	{
		if(jobIds == null)
		{
			jobIds = new List<String>();
		}

		availableJobs = new List<SelectOption>();
        	availableJobs.add(new SelectOption('', ' === Select Job ==='));
			availableJobs.add(new SelectOption('ams2gdp_Batch_Account', 'Job 1: GDP Products - Account View'));
			availableJobs.add(new SelectOption('ams2gdp_Batch_Inspection','Job 2: Accreditation'));
			availableJobs.add(new SelectOption('ams2gdp_Batch_Territory','Job 3: GSA Territory'));
			availableJobs.add(new SelectOption('ams2gdp_Batch_Account2','Job 4: GDS & Account Category'));
			availableJobs.add(new SelectOption('ams2gdp_Batch_Address', 'Job 5: Address & Phone'));
			availableJobs.add(new SelectOption('ams2gdp_Batch_Agency_Affiliation', 'Job 6: Assoc Affiliation Membership'));
			availableJobs.add(new SelectOption('ams2gdp_Batch_AMS_Account_Role','Job 7: Agency Owner'));
			availableJobs.add(new SelectOption('ams2gdp_Batch_AMS_Agency_Airport','Job 8: Adjacent Airport'));
			availableJobs.add(new SelectOption('ams2gdp_Batch_AMS_Agency_Profile','Job 9: Agency Profile and Specialization'));
			availableJobs.add(new SelectOption('ams2gdp_Batch_AMS_Agency_Authorization','Job 10: Agency Authorization'));

			availableJobs.add(new SelectOption('ams2gdp_Batch_Update','=== Clear Error Logs ==='));
	}

	public void refresh()
	{

	}

	public void executeJob()
	{
        List<String> specificRecordIds = new List<String>();
        if(String.isNotBlank(recordIds))
        {
            //-- Process spectific records
            for(String s: recordIds.split(';')){
            	s= s.trim();
                if(s.length() >=15) specificRecordIds.add(s.left(15));
            }
        }

		if(jobName == 'ams2gdp_Batch_Account')
		{
            

            if(processNext && specificRecordIds.size() >0)
            {
            	ams2gdp_Batch_Account batch = new ams2gdp_Batch_Account(false,specificRecordIds, isManual);
	            query = batch.query;
	            jobIds.add(Database.executeBatch(batch));

	            //Start Job 2
	            //New version of inspection batches runs receiving directly from a list of accounts
	            List<String> ids2 = specificRecordIds;
	            if(ids2.isEmpty()) ids2.add('none');
	            jobIds.add(Database.executeBatch(new ams2gdp_Batch_Inspection(false,ids2, isManual)));


	            //Start Job 3
	            List<String> ids3 = ams2gdp_Selector.getAMS_TerritoryIdsByAccountIds(specificRecordIds);
	            if(ids3.isEmpty()) ids3.add('none');
	            jobIds.add(Database.executeBatch(new ams2gdp_Batch_Territory(false,ids3, isManual)));

	            //Start Job 4
	            List<String> ids4 = specificRecordIds;
	            jobIds.add(Database.executeBatch(new ams2gdp_Batch_Account2(false,ids4, isManual)));

	            //Start Job 5
	           // List<String> ids5 = ams2gdp_Selector.getAMS_AddressIdsByAccountIds(specificRecordIds);
	            List<String> ids5 =specificRecordIds;
	            jobIds.add(Database.executeBatch(new ams2gdp_Batch_Address(false,ids5, isManual)));

	            //Start Job 6
	            List<String> ids6 = ams2gdp_Selector.getAMS_Agency_AffiliationIdsByAccountIds(specificRecordIds);
	            if(ids6.isEmpty()) ids6.add('none');
	            jobIds.add(Database.executeBatch(new ams2gdp_Batch_Agency_Affiliation(false,ids6, isManual)));

	            //Start Job 7
	            List<String> ids7 = ams2gdp_Selector.getAMS_Account_RoleIdsByAccountIds(specificRecordIds);
	            if(ids7.isEmpty()) ids7.add('none');
	            jobIds.add(Database.executeBatch(new ams2gdp_Batch_AMS_Account_Role(false,ids7, isManual)));

	            //Start Job 8
	            List<String> ids8 = ams2gdp_Selector.getAMS_Agency_AirportIdsByAccountIds(specificRecordIds);
	            if(ids8.isEmpty()) ids8.add('none');
	            jobIds.add(Database.executeBatch(new ams2gdp_Batch_AMS_Agency_Airport(false,ids8, isManual)));

	            //Start Job 9
	            List<String> ids9 = ams2gdp_Selector.getAMS_Agency_ProfileIdsByAccountIds(specificRecordIds);
	            if(ids9.isEmpty()) ids9.add('none');
	            jobIds.add(Database.executeBatch(new ams2gdp_Batch_AMS_Agency_Profile(false,ids9, isManual)));

	            //Start Job 10
	            List<String> ids10 = specificRecordIds;
	            if(ids10.isEmpty()) ids10.add('none');
	            jobIds.add(Database.executeBatch(new ams2gdp_Batch_AMS_Agency_Authorization(false,ids10, isManual)));

	            //Start Job 1 again
				jobIds.add(Database.executeBatch(new ams2gdp_Batch_Account(false,specificRecordIds,isManual)));
            	
            }
            else
            {
            	ams2gdp_Batch_Account batch = new ams2gdp_Batch_Account(processNext,specificRecordIds, isManual);
	            query = batch.query;
	            jobIds.add(Database.executeBatch(batch));
            }
		}
		else if(jobName == 'ams2gdp_Batch_Account2')
		{
            ams2gdp_Batch_Account2 batch = new ams2gdp_Batch_Account2(false,specificRecordIds, isManual);
            query = batch.query;
			jobIds.add(Database.executeBatch(batch));
		}
		else if(jobName == 'ams2gdp_Batch_Address')
		{
			ams2gdp_Batch_Address batch = new ams2gdp_Batch_Address(false,specificRecordIds, isManual);
			query = batch.query;
			jobIds.add(Database.executeBatch(batch));
		}
		else if(jobName == 'ams2gdp_Batch_Agency_Affiliation')
		{
			ams2gdp_Batch_Agency_Affiliation batch = new ams2gdp_Batch_Agency_Affiliation(false,specificRecordIds, isManual);
			query = batch.query;
			jobIds.add(Database.executeBatch(batch));
		}
		else if(jobName == 'ams2gdp_Batch_AMS_Account_Role')
		{
			ams2gdp_Batch_AMS_Account_Role batch = new ams2gdp_Batch_AMS_Account_Role(false,specificRecordIds, isManual);
			query = batch.query;
			jobIds.add(Database.executeBatch(batch));
		}
		else if(jobName == 'ams2gdp_Batch_AMS_Agency_Airport')
		{
			ams2gdp_Batch_AMS_Agency_Airport batch = new ams2gdp_Batch_AMS_Agency_Airport(false,specificRecordIds, isManual);
			query = batch.query;
			jobIds.add(Database.executeBatch(batch));
		}
		else if(jobName == 'ams2gdp_Batch_AMS_Agency_Authorization')
		{
			ams2gdp_Batch_AMS_Agency_Authorization batch = new ams2gdp_Batch_AMS_Agency_Authorization(false,specificRecordIds, isManual);
			query = batch.query;
			jobIds.add(Database.executeBatch(batch));
		}
		else if(jobName == 'ams2gdp_Batch_AMS_Agency_Profile')
		{
			ams2gdp_Batch_AMS_Agency_Profile batch = new ams2gdp_Batch_AMS_Agency_Profile(false,specificRecordIds, isManual);
			query = batch.query;
			jobIds.add(Database.executeBatch(batch));
		}
		else if(jobName == 'ams2gdp_Batch_Inspection')
		{
			ams2gdp_Batch_Inspection batch = new ams2gdp_Batch_Inspection(false,specificRecordIds, isManual);
			query = batch.query;
			jobIds.add(Database.executeBatch(batch));
		}
		else if(jobName == 'ams2gdp_Batch_Territory')
		{
			ams2gdp_Batch_Territory batch = new ams2gdp_Batch_Territory(false,specificRecordIds, isManual);
			query = batch.query;
			jobIds.add(Database.executeBatch(batch));
		}
		else if(jobName == 'ams2gdp_Batch_Update')
		{
			jobIds.add(Database.executeBatch(new ams2gdp_Batch_Update('clearLogs', null)));
		}
	}
}