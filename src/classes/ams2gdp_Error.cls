public class ams2gdp_Error 
{
	public String jobName;
	public String amsRecordId;
	public String gdpRecordId;
	public String message;


	//public ams2gdp_Error(){}
	
	public ams2gdp_Error(String job, String ams, String gdp, String msg)
	{
		jobName = job;
		amsRecordId = ams;
		gdpRecordId = gdp; 
		message = msg;
	}

	public static ams2gdp_Error Exception2Error(String jobName, Exception ex)
	{
		return new ams2gdp_Error(jobName,null,null,ex.getMessage() + '\n' + ex.getStackTraceString());
	}

	public static List<ams2gdp_Error> formatUpsertResult(List<sObject> records, List<Database.UpsertResult> save_results, String jobName, String externalKey)
	{
		List<ams2gdp_Error> errors = new List<ams2gdp_Error>();

		system.debug('**records**'+records+'**'+save_results+'**job**'+jobName+'**key**'+externalKey);
		for(Integer x = 0; x<records.size(); x++)
		{
			Database.UpsertResult res = save_results[x];
			sObject rec = records[x];

			//Upsert failed ?
			if(!res.isSuccess())
			{
				for(Database.Error err: res.getErrors())
				{
					String msg = 'Error Code: ' + err.getStatusCode()
						+'\nFields: '+ err.getFields()
						+'\nMessage: ' + err.getMessage();

					String externalKeyValue = (String)rec.get(externalKey); 
					if(String.isNotBlank(externalKeyValue))
						externalKeyValue = externalKeyValue.left(18);

					errors.add(new ams2gdp_Error(jobName, (String)rec.get(externalKey), res.getId(), msg));
				}
			}
		}

		system.debug('errors-----'+errors);

		return errors;		
	}

}