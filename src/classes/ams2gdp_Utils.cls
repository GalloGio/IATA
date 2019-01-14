public class ams2gdp_Utils 
{
	public static void notifyBatchOutput(String batchName, Integer totalRecords, Integer errorsCount, List<String> failed_records)
	{
		String email = AMS_2_GDP_Settings__c.getOrgDefaults().Notification_Email__c;
		if(failed_records == null) failed_records = new List<String>();

		Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
			msg.toAddresses = new String[]{email};
			msg.subject = batchName + ' completed'; 
			msg.plainTextBody = batchName+ ' completed with the following output\n'	+'\nRecords Processed: '+totalRecords +'\nFailed Records: '+errorsCount	+'\n ========== '+'\n'+String.join(failed_records, ' ; ');
		try{		
			Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{msg});
		}catch(Exception ex){}		
	}

	public static Map<String, String> getPhoneNumberParts(String full_number, String country_iso_code, Map<String, String> phoneCodesByCountry)
 	{
 		Map<String, String> parts = new Map<String, String>();

 		if(String.isNotBlank(full_number) && String.isNotBlank(country_iso_code) && String.isNotBlank(full_number.replaceAll('[^0-9]','').replaceFirst('^0+(?!$)', '')))
 		{
 			List<String> codes = phoneCodesByCountry.get(country_iso_code).split(':');

			//Remove non numeric characters and leading 0 from phone number 
	 		full_number = full_number.replaceAll('[^0-9]','').replaceFirst('^0+(?!$)', '');
	 		 String phone_segment = full_number; 

	 		//-- Country Dialling Code 
	 		parts.put('isd', codes[0]);	
	 		phone_segment = phone_segment.removeStart(parts.get('isd'));

	 		if(codes[0] == '1')	 		
	 		//if(country_iso_code == 'CA' || country_iso_code == 'US')
	 		{
	 			//-- Canada or USA
	 			if(phone_segment.length() < 10){
	 				parts.put('std',null);
	 				parts.put('phone', phone_segment);}else{
	 				parts.put('std',phone_segment.left(3));
	 				phone_segment = phone_segment.removeStart(parts.get('std'));
	 				parts.put('phone', phone_segment.left(12));	}}
	 		else
	 		{
	 			if(phone_segment.length() > 12){
	 				parts.put('phone', phone_segment.right(12));
	 				phone_segment = phone_segment.removeStart(parts.get('phone'));
	 				parts.put('std',phone_segment.left(6));}else{
	 				parts.put('std',null);
	 				parts.put('phone', phone_segment);}
	 		}

	 		//-- Area Codes & Toll Free codes
	 		/*Set<String> area_codes = new Set<String>(codes[1].split(';'));
	 		
 			String segment = ''; 

 			if(String.isNotBlank(phone_segment))
 			{
 				for(Integer x=0; x<phone_segment.length(); x++)
	 			{
	 				segment = segment+phone_segment.substring(x, x+1); 
	 				
	 				//Area code detected ? 
	 				if(area_codes.contains(segment)) parts.put('std', segment);
	 			}

	 			if(parts.containsKey('std')) phone_segment = phone_segment.removeStart(parts.get('std'));
 			}
			
			//-- Phone 
			parts.put('phone', phone_segment);*/
 		}

		return parts; 
 	}

 	public static void logErrors(List<ams2gdp_Error> errorLogs)
    {
    	List<AMS2GDP_Log__c> logs = new List<AMS2GDP_Log__c>();
    	String email = AMS_2_GDP_Settings__c.getOrgDefaults().Notification_Email__c;
    	List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

    	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    		message.toAddresses = new String[]{email};
			message.subject = 'WARNING - Duplicate founded on '+errorLogs[0].jobName; 

		String body = ''; 


    	for(ams2gdp_Error err : errorLogs)
    	{
    		logs.add(new AMS2GDP_Log__c(Job_Name__c= err.jobName, AMS_Record_Id__c = err.amsRecordId, GDP_Record_Id__c = err.gdpRecordId, Message__c = err.message));

			//Notify GDP Admin if errors are due to duplicates founded
			if(String.isNotBlank(err.message) && err.message.containsIgnoreCase('Duplicate')) {
				/*Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
					msg.toAddresses = new String[]{email};
					msg.subject = 'WARNING - Duplicate founded on '+err.jobName; */
					body +=  err.message + '\n';}	}

    	if(logs.size() > 0) insert logs;
    	if(body != '')	{
    		message.plainTextBody = body;
    		try{
				// System.debug('aaaaaa ' + message);
				// Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
    	}
    		catch(Exception ex){}}
    }

    /**
	 * Wraps the provided string into fixed length chunks
	 * @param StrToWrap: String to wrap
	 * @param WrapLength: Length of the string before wrapping it into a second line
	 */
 	public static List<String> WrapText(String StrToWrap, integer WrapLength) 
 	{
 		List<String> lstLines = new List<String>();
	 	if (!String.isBlank(StrToWrap)) 
	 	{
		 	List<String> lstWords = StrToWrap.split(' ');
		 	
			// Determine whether any of the words is more than specified WrapLength: then wrap by character instead of word
			Boolean bWrapChar = false;
		
			for (String word : lstWords) 
			{
				if (word.length() > WrapLength) {bWrapChar = true;break;}
			}

			
			// Wrap by character instead of word
			if (bWrapChar) 
			{
				integer i = 0;
				for (i = 0; i < (StrToWrap.length() / WrapLength); i++) lstLines.add(StrToWrap.substring(i * WrapLength, (i + 1) * WrapLength));
				
				if (math.mod(StrToWrap.length(), WrapLength) > 0)		lstLines.add(StrToWrap.substring(i * WrapLength, StrToWrap.length()));
			}
			// Wrap string by word
			else 
			{
				String line = '';
				
				for (String word : lstWords) 
				{
					if ((line + ' ' + word).trim().length() < (WrapLength - 1)){line = (line + ' ' + word).trim();}
					else{lstLines.add(line); line = word;}					
				}

				lstLines.add(line);
			}
	 	}	 	
				
		return lstLines; 
	}


	public static void upsertAMS_GDP_Batch(String batchName, Datetime syncStartedDate, Integer errorsCount, Integer totalRecords, List<String> failed_records, Boolean isManual){
        if(isManual){
            upsert new AMS_GDP_Batch__c(
                    Batch_Name__c=batchName,
                    Is_Manual_Replication__c = true,
                    Total_Failed_Records__c = errorsCount,
                    Total_Records_Processed__c = totalRecords,
                    Failed_Records__c = String.join(failed_records, ';').left(32768)
            )Batch_Name__c;
        }else{
            upsert new AMS_GDP_Batch__c(
                    Batch_Name__c=batchName,
                    Is_Manual_Replication__c = false,
                    Last_Sync_Start_Date__c=syncStartedDate,
                    Last_Sync_End_Date__c=Datetime.now(),
                    Total_Failed_Records__c = errorsCount,
                    Total_Records_Processed__c = totalRecords,
                    Failed_Records__c = String.join(failed_records, ';').left(32768)
            )Batch_Name__c; 
        }
    }

}