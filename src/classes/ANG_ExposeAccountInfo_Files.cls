/***********************************************************
    2018-11-26. Author: Daniele Tullo
	Class to expose to external source account's files
    Currently supported:
        - Financial Assessment document sharing with GDI [INT_078] Jira issue: https://iatasfdc.atlassian.net/browse/NEWGEN-4405
***********************************************************/

public without sharing class ANG_ExposeAccountInfo_Files {
    public static void ANG_ExposeAccountInfo_Files(account accnt, string AttachmentType, string AccountType, string Caller) {
        try{
            /* Removed switch because not supported on final string yet... 'when identifier' is only allowed for switch on enum 
            switch on Caller {
                when ANG_RestServiceHelper.Caller_GDI{
                    ANG_RestServiceHelper.GenerateResponse(json.serialize(new INT078_GDI_SuccessPayload(accnt, AttachmentType, AccountType, Caller)), 200);
                }
            }
            */
            
            if(caller==ANG_RestServiceHelper.Caller_GDI)
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new INT078_GDI_SuccessPayload(accnt, AttachmentType, AccountType, Caller)), 200);
        }
        catch(exception e){
            ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('500', e.getMessage()) ), 500);
        }
    }

    /* Attachments metadata */
	private class Attach{
		public string attachmentName;
		public string attachmentURL;
		
		public string storageLocation;
		public string bucketName;
		
		public Attach(string fName,string AttFullURL, string storloc, string bn){
			this.AttachmentName = fName;
			this.AttachmentURL = AttFullURL; 
			this.StorageLocation = storloc;
			this.BucketName = bn;
		}
	}

    /* INT_078 Succesfull payload */
	private class INT078_GDI_SuccessPayload{
		public string IATACode;
		public string accountType;
		public string caller;
		public string attachmentType;
		public list<Attach> attachments;
		
		public INT078_GDI_SuccessPayload(Account accnt, string AttachmentType, string AccountType, string Caller){
			this.IATACode = accnt.IATACode__c;
			this.AccountType = AccountType;
			this.Caller = Caller;
			this.AttachmentType = AttachmentType;
			this.Attachments = new list<Attach>();
			
			string IFAP_AWSCredentialName = (UserInfo.getOrganizationId().substring(0, 15) == '00D2000000008TF')?'IFAP_PROD':'IFAP_DEV';
			
			if(Caller==ANG_RestServiceHelper.Caller_GDI && AttachmentType=='FinancialStatement'){
				AWSKey__c AWSInfo = [select id, Bucket__c, AWS_ENDPOINT_URL__c from AWSKey__c where name=:IFAP_AWSCredentialName];
				
				set<string> setFinancialYear = new set<string>{string.ValueOf(system.today().year()), string.ValueOf(system.today().year()-1)};
            	
            	list<Case> lsIfap = [select id, CaseNumber, 
            								(Select Id, Full_Name_Unique__c,Name From AmazonFiles__r where Full_Name_Unique__c like 'IFAP/FinancialDocument%') 
            						 from case 
            						 where RecordType.DeveloperName='IATA_Financial_Review' 
            						 	   and IFAP_Financial_Year__c in:setFinancialYear
            						 	   and AccountId =:accnt.Id 
            						 order by CreatedDate desc limit 1];
            	if(!lsIfap.isEmpty()){
            		for(AmazonFile__c AF:lsIfap.get(0).AmazonFiles__r){
            			this.Attachments.add(new Attach(AF.Name, AWSInfo.AWS_ENDPOINT_URL__c + AWSInfo.Bucket__c + '/' + AF.Full_Name_Unique__c, 'Amazon', AWSInfo.Bucket__c));
            		}
            	}
            }
		}
	}
}
