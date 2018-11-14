/***********************************************************
	2018-10-30. Author: Daniele Tullo
	Class expose a REST webservice which expose account's additional info, such as
        - account's files
        - Non-payment Info
	
	JIRA Issue Reference: 
		- https://iatasfdc.atlassian.net/browse/NEWGEN-4405  - Account Files
        - 
	Interface Catalogue:
		INT_078 (Files)
        INT_014 (NonPaymentInfo)

***********************************************************/

@RestResource(urlMapping='/account-details/*')
global without sharing class ANG_ExposeAccountInfo {

    @HttpGet
    global static void doGet(){
        set<string> setValidAccountType = new set<string>{'Agency'};	//Valid account type
        set<string> setValidCaller = new set<string>{'GDI'};			//Valid caller
        map<string,string> mapAccountTypeRT = new map<string,string>{'Agency' => 'IATA_Agency'};	//Map from account type to account record-type developername
        set<string> setValidAttachmentType = new set<string>{'FinancialStatement'};		//Valid type of attachments to search for
        set<string> setValidRequest = new set<string>{'account-files','account-financial-info'};    //Valid type of request, part of URI
        
        try{
            RestRequest req = RestContext.request;
            string[] SplittedURI = req.requestURI.split('/');
            
            if(SplittedURI.size()<4){
                GenerateResponse(json.serialize(new ErrorPayload('400', 'Wrong URI')), 400);
                return;
            }

            string IATACode = SplittedURI[2];   //get the iata code from the request URI
            string requestType = SplittedURI[3];    //get the request tpye from the request URI

            if(!setValidRequest.contains(requestType)){
                GenerateResponse(json.serialize(new ErrorPayload('400', 'Wrong URI')), 400);
                return;
            }

            //Retrieve parameter from the querystring
            string AttachmentType = req.params.get('attachmentType'); //Type of attachments to search for and to return
            string Caller = req.params.get('caller');	//Name of the caller (e.g. GDI) 
            string AccountType = req.params.get('accountType'); //e.g.: Agency

            /*** verification ***/
            if(IATACode==null || IATACode== ''){
                GenerateResponse(json.serialize(new ErrorPayload('400', 'No IATA Code received')), 400);
                return;
            }
            
            if(Caller==null || Caller== ''){
                GenerateResponse(json.serialize(new ErrorPayload('400', 'Caller not specified')), 400);
                return;
            }

            if(AccountType==null || AccountType== ''){
                GenerateResponse(json.serialize(new ErrorPayload('400', 'AccountType not specified')), 400);
                return;
            }

            if(!setValidAccountType.contains(AccountType)){
            	GenerateResponse(json.serialize(new ErrorPayload('400', 'Invalid AccountType')), 400);
                return;
            }
            
            if(!setValidCaller.contains(Caller)){
            	GenerateResponse(json.serialize(new ErrorPayload('400', 'Invalid Caller')), 400);
                return;
            }

            if(requestType=='account-files'){
                if(AttachmentType==null || AttachmentType== ''){
                    GenerateResponse(json.serialize(new ErrorPayload('400', 'AttachmentType not specified')), 400);
                    return;
                }

                if(!setValidAttachmentType.contains(AttachmentType)){
                    GenerateResponse(json.serialize(new ErrorPayload('400', 'Invalid AttachmentType')), 400);
                    return;
                }
            }

            //Fetch the account
            /* run the query, different based on caller/request type */
            list<Account> lsAccnt;
            switch on Caller {
               when  'GDI'{
                    switch on requestType{
                        when 'account-files'{
                            lsAccnt = [select IATACode__c, Id ,GDI_Status__c from Account where recordtype.developername =:mapAccountTypeRT.get(AccountType) and IATACode__c =:IATACode];
                        }
                        when 'account-financial-info'{
                            lsAccnt = [select Id, IATACode__c , GDI_Status__c, Financial_Review_Result__c, ANG_FA_Opt_out__c
                                            ,(	 //Change Code
                                                Select Id, Change_Code__c, Irregularity_Type__c, Created_Date_To_Show__c
                                                From Agencies_Applied_Change_codes__r
                                                where Created_Date_To_Show__c >= LAST_N_MONTHS:6
                                                and (
                                                    Change_Code__c in ('LSP', 'DFE', 'RCR', 'DFW', 'LSW')
                                                    OR
                                                    (Change_Code__c in ('IRR', 'IRW') AND Irregularity_Type__c='OV2')
                                                )
                                            )
                                        from Account 
                                        where recordtype.developername =:mapAccountTypeRT.get(AccountType) and IATACode__c =:IATACode];
                        }
                   }
               }
               //when else {
               //    sQuery = 'select id from account where IATACode__c = \'asdfghjklasdfghjklasdfghj\''; //nothing will be found
               //}
            }

			if(lsAccnt.isEmpty()){
                GenerateResponse(json.serialize(new ErrorPayload('404', AccountType + ' ' + IATACode + ' not found')), 404);
                return;
            }
            
            if(lsAccnt.size()>1){
                GenerateResponse(json.serialize(new ErrorPayload('409', 'Multiple records found with IATA Code ' + IATACode + ' !') ), 409);
                return;
            }
            
            Account accnt = lsAccnt.get(0);
            
            //Security: allow GDI to fecth files only if the agency has a GDI Account (pending or open)
            if(Caller=='GDI' && accnt.GDI_Status__c != 'Open' && accnt.GDI_Status__c != 'In Progress'){
            	GenerateResponse(json.serialize(new ErrorPayload('403', 'Not allowed')), 403);
                return;
            }
            
            //All is good. Proceeding in generating payload
            switch on Caller {
               when 'GDI'{
                    switch on requestType{
                        when 'account-files'{
                            GenerateResponse(json.serialize(new INT078_SuccessPayload(accnt, AttachmentType, AccountType, Caller)), 200);
                        }
                        when 'account-financial-info'{
                            GenerateResponse(json.serialize(new INT014_SuccessPayloadGDI(accnt, Caller, AccountType)), 200);
                        }
                   }
               }
            }
            
        }
        catch(Exception e){
            GenerateResponse(json.serialize(new ErrorPayload('500', e.getMessage()) ), 500);
        }
    }


    /* Generates the response */
    private static void GenerateResponse(string sBody, integer iStatusCode){
        RestResponse res = RestContext.response;
        res.statusCode = iStatusCode;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(sBody);
    }


/*********************************
    PAYLOADS
*********************************/
    /* ERROR Payload - Common to all request */
    private class ErrorPayload{
        public string sError;
        public string sMessage;
        
        public ErrorPayload(string sError, string sMessage){
            this.sError = sError;
            this.sMessage = sMessage;
        }
    }

/***************
    INT_078
***************/
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
	private class INT078_SuccessPayload{
		public string IATACode;
		public string accountType;
		public string caller;
		public string attachmentType;
		public list<Attach> attachments;
		
		public INT078_SuccessPayload(Account accnt, string AttachmentType, string AccountType, string Caller){
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

/***************
    INT_014
***************/

    /* Succesfull payload when the caller is GDI */
	private class INT014_SuccessPayloadGDI{
		public string IATACode;
		public string lastFinancialReviewResult;
		public string caller;
		public string accountType;
		
		public string hasNonPayment = 'No';
		public date nonPaymentDate = null;
		public string hasDefault = 'No';
		public date defaultDate = null;
		public string hasReinstatement = 'No';
		public date resintatementDate = null;
		public string hasWithdrawal = 'No';
		public date withdrawalDate = null;
		
		public INT014_SuccessPayloadGDI(Account accnt, string Caller, string AccountType){
			this.Caller = Caller;
			this.AccountType = AccountType;
			
			map<string, date> mapCC = new map<string, date>();
			
			this.IATACode = accnt.IATACode__c;
			if(boolean.valueOf(accnt.ANG_FA_Opt_out__c) || string.isBlank(accnt.Financial_Review_Result__c))
				this.LastFinancialReviewResult = 'n\\a';
			else{
				if(accnt.Financial_Review_Result__c.startsWithIgnoreCase('Satisfactory'))
					this.LastFinancialReviewResult = 'Satisfactory';
				else
					this.LastFinancialReviewResult = 'Unsatisfactory';
			}
			
			for(Agency_Applied_Change_code__c CC:accnt.Agencies_Applied_Change_codes__r){
				switch on CC.Change_Code__c {
					when 'IRR', 'LSP'{
						this.hasNonPayment = 'Yes';
						if(this.NonPaymentDate==null || date.valueOf(cc.Created_Date_To_Show__c)>this.NonPaymentDate)
							this.NonPaymentDate = date.valueOf(cc.Created_Date_To_Show__c);
					}
					
					when 'DFE'{
						this.HasDefault = 'Yes';
						if(this.DefaultDate==null || date.valueOf(cc.Created_Date_To_Show__c)>this.DefaultDate)
							this.DefaultDate = date.valueOf(cc.Created_Date_To_Show__c);
					}
					
					when 'RCR'{
						this.hasReinstatement = 'Yes';
						if(this.ResintatementDate==null || date.valueOf(cc.Created_Date_To_Show__c)>this.ResintatementDate)
							this.ResintatementDate = date.valueOf(cc.Created_Date_To_Show__c);
					}
					
					when 'IRW', 'DFW', 'LSW' {
						this.hasWithdrawal = 'Yes';
						if(this.WithdrawalDate==null || date.valueOf(cc.Created_Date_To_Show__c)>this.WithdrawalDate)
							this.WithdrawalDate = date.valueOf(cc.Created_Date_To_Show__c);
					}
				}
			}
		}
	}
}
