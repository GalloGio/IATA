public with sharing class AMS_PurgeIATACodeController {

	public Id aMS_PurgeAccountBatchId{get;set;}

	public boolean batchStatusBool{get;set;}

	public boolean pollerBool{get;set;}

	public boolean canExecutePurge{get;set;}

	public String purgeStatus{get;set;}

	public String selectedTab{get;set;}

	public Id fullPurgeId{get;set;}

	public Id litePurgeId{get;set;}

    public Set<String> notesFullPurge{
        get{
                        
                        notesFullPurge = new Set<String>();
                        notesFullPurge.add('This section is a searchable area. Please search for Terminated agencies to purge.');
                        notesFullPurge.add('Full purge will search for all agencies with status “Terminated“ (field: Account.Status__c) and with the termination date (field: Expiry_Date__c) less than 1st of January of the current year-10 (e.g.: In 2017, all terminated agencies before 1st of January 2007 will be searched). Approval date has to be filled in. Also it will not search for Agencies with no IATA Code.');
                        notesFullPurge.add('After searching for the Agencies, a CSV with Agency Information will be available.');
                        notesFullPurge.add('To use this information, please add two aditional columns at the end of the sheet: To NOT Purge SFDC(ToNOTPurgeSFDC) and To NOT Purge External (ToNOTPurgeExternal).');
                        notesFullPurge.add('A maximum of 10.000 records will be extracted.');

                return notesFullPurge;
        }
        set;
	}

    public List<String> noteListFullPurge{
            get{
                    return new List<String>(notesFullPurge);
            }
            set;
    }

    public Set<String> notesLitePurge{
        get{
                        
                        notesLitePurge = new Set<String>();
						notesLitePurge.add('This section is a searchable area. Please search for Terminated agencies to purge.');
                        notesLitePurge.add('Lite purge will search for all agencies with status “Not accreditated” (field: Account.Status__c) and with a change code “DIS” created before today minus 6 months.Also it will not search for Agencies with no IATA Code.');
                        notesLitePurge.add('After searching for the Agencies, a CSV with Agency Information will be available.');
                        notesFullPurge.add('To use this information, please add two aditional columns at the end of the sheet: To NOT Purge SFDC(ToNOTPurgeSFDC) and To NOT Purge External (ToNOTPurgeExternal).');
                        notesLitePurge.add('A maximum of 10.000 records will be extracted.');

                return notesLitePurge;
        }
        set;
	}

    public List<String> noteListLitePurge{
            get{
                    return new List<String>(notesLitePurge);
            }
            set;
    }



    public Set<String> notesUpload{
        get{
                        
                        notesUpload = new Set<String>();
						notesUpload.add('This section is used to perform the IATA Code Purge.');
                        notesUpload.add('Please upload the csv file as per instructed. The contents must be the same as the ones extracted with 2 more columns : Not to Purge SFDC and Not to Purge External System');
                        notesFullPurge.add('To use this information, please add two aditional columns at the end of the sheet: To NOT Purge SFDC(ToNOTPurgeSFDC) and To NOT Purge External (ToNOTPurgeExternal).');                        
                        notesUpload.add('All the agencies and GDP Productus matching Id of the Agencies will be updated, exeption made for the ones marked as X in the last 2 columns.');

                return notesUpload;
        }
        set;
	}

    public List<String> noteListUpload{
            get{
                    return new List<String>(notesUpload);
            }
            set;
    }




    

    public string nameFile{get;set;}
    
    public Blob contentFile{get;set;}
    
    String[] filelines = new String[]{};
    
    public List<AMS_PurgeIATACodeController.PurgeFileContent> purgeFileContentList{get;set;}

	public AMS_PurgeIATACodeController() {
		
		selectedTab = 'tab1';

		canExecutePurge = false;

		batchStatusBool = false;

		pollerBool = false;

        purgeStatus = 'Processing...';

		fetchSOQLObjects();

        purgeFileContentList = new List<AMS_PurgeIATACodeController.PurgeFileContent>();

	}

	public void checkBatchStatus(){

		

		List<AsyncApexJob> runningJob =  [Select Id, Status, ApexClass.Name From AsyncApexJob where id =: aMS_PurgeAccountBatchId order by CreatedDate DESC limit 1];

		System.debug('Job List is:'+ runningJob);

		if(!runningJob.isEmpty()) {

			AsyncApexJob job = runningJob.get(0);

			if(job.Status == 'Completed') {
        		purgeStatus = job.Status;
            	pollerBool = false;
            } else {

            	purgeStatus = job.Status;

				pollerBool = true;
            }
		}else
			pollerBool = true;
	}

	public void fetchSOQLObjects(){

		List<AMS_SOQL_Query_Export__c> result = new List<AMS_SOQL_Query_Export__c>();

		result = [SELECT Id from AMS_SOQL_Query_Export__c where Name = 'Full Purge IATA Code' LIMIT 1];

		if(!result.isEmpty())
			fullPurgeId = result.get(0).Id;

		result = [SELECT Id from AMS_SOQL_Query_Export__c where Name = 'Lite Purge IATA Code' LIMIT 1];

		if(!result.isEmpty())
		 	litePurgeId = result.get(0).Id;
	}

	    /***This function reads the CSV file and inserts records into the Account object. ***/
    public Pagereference ReadFile()
    {
        try{
                //Convert the uploaded file which is in BLOB format into a string
                nameFile =blobToString( contentFile,'ISO-8859-1');
                
                //Now sepatate every row of the excel file
                filelines = nameFile.split('\n');
                
                //Iterate through every line and create a Account record for each row
                purgeFileContentList = new List<AMS_PurgeIATACodeController.PurgeFileContent>();

                for (Integer i=1;i<filelines.size();i++)
                {
                    String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');
                    
                    System.debug('String is ' + filelines[i]);
                    System.debug('Size of file is ' + inputvalues.size());

                    AMS_PurgeIATACodeController.PurgeFileContent pfc = new AMS_PurgeIATACodeController.PurgeFileContent();

                    pfc.Identifier = inputvalues[0];
                    pfc.IATACode = inputvalues[1];       
                    pfc.C_Code = inputvalues[2];
                    pfc.A_Code = inputvalues[3];
                    pfc.N_Code = inputvalues[4];
                    pfc.Site = inputvalues[5];
        			pfc.Name = inputvalues[6];
        			pfc.LocationType = inputvalues[7];
        			pfc.LocationClass = inputvalues[8];
        			pfc.ExpiryDate = inputvalues[9];
        			pfc.AccreditationDate = inputvalues[10];
        			pfc.ToNOTPurgeSFDC = inputvalues[11];
        			pfc.ToNOTPurgeExternal = inputvalues[12];

                    purgeFileContentList.add(pfc);
                }
         }
         catch(Exception e){
                 ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured reading the CSV file'+e.getMessage());
                ApexPages.addMessage(errormsg);
         }       
  		
  		selectedTab = 'tab3';

  		canExecutePurge = true;

        return null;
    }


	/**
         This function convers the input CSV file in BLOB format into a string
        @param input    Blob data representing correct string in @inCharset encoding
        @param inCharset    encoding of the Blob data (for example 'ISO 8859-1')
     */
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }

    public void runPurgeProcess(){

    	batchStatusBool = true;

    	canExecutePurge = false;

    	pollerBool = false;

    	Set<Id> accountsToPurge = new Set<Id>();

    	if(purgeFileContentList.isEmpty())
    		return; // nothing to do

    	for(PurgeFileContent pfc : purgeFileContentList){

    		if(isFieldXorNull(pfc.ToNOTPurgeSFDC) || isFieldXorNull(pfc.ToNOTPurgeExternal) || pfc.Identifier == null || pfc.Identifier == '' ){
    			continue;
			}

			accountsToPurge.add(pfc.Identifier);

    	}

    	System.debug('Accounts to purge list is:' + accountsToPurge);


    	if(!accountsToPurge.isEmpty()){

    		AMS_PurgeAccountBatch pab = new AMS_PurgeAccountBatch(accountsToPurge);

    		aMS_PurgeAccountBatchId = Database.executeBatch(pab,200);

    	}

    	checkBatchStatus();

    }

    public boolean isFieldXorNull(String field){

    	return field == 'X' || field == 'x';
    }

    public class PurgeFileContent{

    	public String Identifier{get;set;}
		public String IATACode{get;set;}
		public String C_Code{get;set;}
		public String A_Code{get;set;}
		public String N_Code{get;set;}
		public String Site{get;set;}
		public String Name{get;set;}
		public String LocationType{get;set;}
		public String LocationClass{get;set;}
		public String ExpiryDate{get;set;}
		public String AccreditationDate{get;set;}
		public String ToNOTPurgeSFDC{get;set;}
		public String ToNOTPurgeExternal{get;set;}


    	public PurgeFileContent(){

    	}


    }

}