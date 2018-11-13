/***********************************************************
	2018-10-30. Author: Daniele Tullo
	Class expose a REST webservice with a get resource
	Used to expose account's files
	
	JIRA Issue Reference: 
		- https://iatasfdc.atlassian.net/browse/NEWGEN-4405
	Interface Catalogue:
		INT_XXX

***********************************************************/

@RestResource(urlMapping='/GetAccountFiles/*')
global without sharing class ANG_GetAccountFiles {
	
    @HttpGet
    global static void doGet(){
    	set<string> setValidAccountType = new set<string>{'Agency'};	//Valid account type
		set<string> setValidAttachmentType = new set<string>{'FinancialStatement'};		//Valid type of attachments to return
		set<string> setValidCaller = new set<string>{'GDI'};			//Valid caller
		map<string,string> mapAccountTypeRT = new map<string,string>{'Agency' => 'IATA_Agency'};	//Map from account type to account record-type developername
	
		try{
			RestRequest req = RestContext.request;
            String IATACode = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            string AttachmentType = req.params.get('AttachmentType'); //Type of attachments to search for and to return
            string Caller = req.params.get('Caller');	//Name of the caller (e.g. GDI) 
            string AccountType = req.params.get('AccountType'); //e.g.: Agency
            
            /*** verification ***/
            if(IATACode==null || IATACode== ''){
                GenerateResponse(json.serialize(new ErrorPayload('400', 'No IATA Code received')), 400);
                return;
            }
            
            if(Caller==null || Caller== ''){
                GenerateResponse(json.serialize(new ErrorPayload('400', 'Caller not specified')), 400);
                return;
            }
            
            if(AttachmentType==null || AttachmentType== ''){
                GenerateResponse(json.serialize(new ErrorPayload('400', 'AttachmentType not specified')), 400);
                return;
            }
            
            if(AccountType==null || AccountType== ''){
                GenerateResponse(json.serialize(new ErrorPayload('400', 'AccountType not specified')), 400);
                return;
            }
            
            if(!setValidAccountType.contains(AccountType)){
            	GenerateResponse(json.serialize(new ErrorPayload('406', 'Invalid AccountType')), 406);
                return;
            }
            
            if(!setValidAttachmentType.contains(AttachmentType)){
            	GenerateResponse(json.serialize(new ErrorPayload('406', 'Invalid AttachmentType')), 406);
                return;
            }
            
            if(!setValidCaller.contains(Caller)){
            	GenerateResponse(json.serialize(new ErrorPayload('406', 'Invalid Caller')), 406);
                return;
            }
            
            /*** END OF VERIFICATION ***/
            
            //Fetch the account
           
            list<Account> lsAccnt = [select IATACode__c, Id ,GDI_Status__c from Account where recordtype.developername =:mapAccountTypeRT.get(AccountType) and IATACode__c =:IATACode];
            
			if(lsAccnt.isEmpty()){
                GenerateResponse(json.serialize(new ErrorPayload('404', AccountType + ' ' + IATACode + ' not found')), 404);
                return;
            }
            
            if(lsAccnt.size()>1){
                GenerateResponse(json.serialize(new ErrorPayload('300', 'Multiple records found with IATA Code ' + IATACode + ' !') ), 300);
                return;
            }
            
            Account accnt = lsAccnt.get(0);
            
            //Security: allow GDI to fecth files only if the agency has a GDI Account (pending or open)
            if(Caller=='GDI' && accnt.GDI_Status__c != 'Open' && accnt.GDI_Status__c != 'In Progress'){
            	GenerateResponse(json.serialize(new ErrorPayload('403', 'Not allowed')), 403);
                return;
            }
            
            
            //All is good. Proceeding in generating payload
            GenerateResponse(json.serialize(new SuccessPayload(accnt, AttachmentType, AccountType, Caller)), 200);
		}
        catch(exception e){
            GenerateResponse(json.serialize(new ErrorPayload('500', e.getMessage()) ), 500);
        }
    }
    
    /* ERROR Payload */
    private class ErrorPayload{
        public string sError;
        public string sMessage;
        
        public ErrorPayload(string sError, string sMessage){
            this.sError = sError;
            this.sMessage = sMessage;
        }
    }
	
	/* Attachments metadata */
	private class Attach{
		public string AttachmentName;
		public string AttachmentURL;
		
		public string StorageLocation;
		public string BucketName;
		
		public Attach(string fName,string AttFullURL, string storloc, string bn){
			this.AttachmentName = fName;
			this.AttachmentURL = AttFullURL; 
			this.StorageLocation = storloc;
			this.BucketName = bn;
		}
	}
	
	/* Succesfull payload */
	private class SuccessPayload{
		public string IATACode;
		public string AccountType;
		public string Caller;
		public string AttachmentType;
		public list<Attach> Attachments;
		
		public SuccessPayload(Account accnt, string AttachmentType, string AccountType, string Caller){
			this.IATACode = accnt.IATACode__c;
			this.AccountType = AccountType;
			this.Caller = Caller;
			this.AttachmentType = AttachmentType;
			this.Attachments = new list<Attach>();
			
			string IFAP_AWSCredentialName = (UserInfo.getOrganizationId().substring(0, 15) == '00D2000000008TF')?'IFAP_PROD':'IFAP_DEV';
			
			if(Caller=='GDI' && AttachmentType=='FinancialStatement'){
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
    
    /* Generates the response */
    private static void GenerateResponse(string sBody, integer iStatusCode){
        RestResponse res = RestContext.response;
        res.statusCode = iStatusCode;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(sBody);
    }
}