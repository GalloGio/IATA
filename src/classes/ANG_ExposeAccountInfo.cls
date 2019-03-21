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
        set<string> setValidCaller = new set<string>{ANG_RestServiceHelper.Caller_GDI};			//Valid caller
        map<string,string> mapAccountTypeRT = new map<string,string>{'Agency' => 'IATA_Agency'};	//Map from account type to account record-type developername
        set<string> setValidAttachmentType = new set<string>{'FinancialStatement'};		//Valid type of attachments to search for
        set<string> setValidRequest = new set<string>{ANG_RestServiceHelper.URIRequest_AccountFiles, ANG_RestServiceHelper.URIRequest_AccountFinancialInfo};    //Valid type of request, part of URI
        
        try{
            RestRequest req = RestContext.request;
            string[] SplittedURI = req.requestURI.split('/');
            
            if(SplittedURI.size()<4){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'Wrong URI')), 400);
                return;
            }

            string IATACode = SplittedURI[2];   //get the iata code from the request URI
            string requestType = SplittedURI[3];    //get the request tpye from the request URI

            if(!setValidRequest.contains(requestType)){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'Wrong URI')), 400);
                return;
            }

            //Retrieve parameter from the querystring
            string AttachmentType = req.params.get('attachmentType'); //Type of attachments to search for and to return
            string Caller = req.params.get('caller');	//Name of the caller (e.g. GDI) 
            string AccountType = req.params.get('accountType'); //e.g.: Agency

            /*** verification ***/
            if(IATACode==null || IATACode== ''){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'No IATA Code received')), 400);
                return;
            }
            
            if(Caller==null || Caller== ''){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'Caller not specified')), 400);
                return;
            }

            if(AccountType==null || AccountType== ''){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'AccountType not specified')), 400);
                return;
            }

            if(!setValidAccountType.contains(AccountType)){
            	ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'Invalid AccountType')), 400);
                return;
            }
            
            if(!setValidCaller.contains(Caller)){
            	ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'Invalid Caller')), 400);
                return;
            }

            if(requestType==ANG_RestServiceHelper.URIRequest_AccountFiles){
                if(AttachmentType==null || AttachmentType== ''){
                    ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'AttachmentType not specified')), 400);
                    return;
                }

                if(!setValidAttachmentType.contains(AttachmentType)){
                    ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'Invalid AttachmentType')), 400);
                    return;
                }
            }

            //Fetch the account
            /* run the query, different based on caller/request type */
            list<Account> lsAccnt;

            //used to be a switch statement, but it doesn't support reference string yet...
            if(Caller == ANG_RestServiceHelper.Caller_GDI){
                if(requestType==ANG_RestServiceHelper.URIRequest_AccountFiles){
                    lsAccnt = [select IATACode__c, Id ,GDI_Status__c from Account where recordtype.developername =:mapAccountTypeRT.get(AccountType) and IATACode__c =:IATACode];
                }

                if(requestType==ANG_RestServiceHelper.URIRequest_AccountFinancialInfo){
                    lsAccnt = [select Id, IATACode__c , GDI_Status__c, Financial_Review_Result__c, ANG_FA_Opt_out__c
                                    ,(	 //Change Code
                                        Select Id, Change_Code__c, Irregularity_Type__c, Created_Date_To_Show__c
                                        From Agencies_Applied_Change_codes__r
                                        where Created_Date_To_Show__c >= :system.today().addMonths(-6)
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

			if(lsAccnt== null || lsAccnt.isEmpty()){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('404', AccountType + ' ' + IATACode + ' not found')), 404);
                return;
            }
            
            if(lsAccnt.size()>1){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('409', 'Multiple records found with IATA Code ' + IATACode + ' !') ), 409);
                return;
            }
            
            Account accnt = lsAccnt.get(0);
            
            //Security: allow GDI to fecth files only if the agency has a GDI Account (pending or open)
            if(Caller==ANG_RestServiceHelper.Caller_GDI && accnt.GDI_Status__c != 'Open' && accnt.GDI_Status__c != 'In Progress'){
            	ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('403', 'Not allowed')), 403);
                return;
            }
            
            //All is good. Proceeding in generating payload
            /* Removed switch because not supported on final string yet... 'when identifier' is only allowed for switch on enum
            switch on ANG_RestServiceHelper.URIRequests{
                when ANG_RestServiceHelper.mapEnumURIRequest.get(ANG_RestServiceHelper.URIRequest_AccountFiles){
                    ANG_ExposeAccountInfo_Files.ANG_ExposeAccountInfo_Files(accnt, AttachmentType, AccountType, Caller);
                }
                when ANG_RestServiceHelper.mapEnumURIRequest.get(ANG_RestServiceHelper.URIRequest_AccountFinancialInfo){
                    ANG_ExposeAccountInfo_FinancialInfo.ANG_ExposeAccountInfo_FinancialInfo(accnt, Caller, AccountType);
                }
            }*/
           
            if(requestType==ANG_RestServiceHelper.URIRequest_AccountFiles)
                ANG_ExposeAccountInfo_Files.ANG_ExposeAccountInfo_Files(accnt, AttachmentType, AccountType, Caller);
            
            if(requestType==ANG_RestServiceHelper.URIRequest_AccountFinancialInfo)
                ANG_ExposeAccountInfo_FinancialInfo.ANG_ExposeAccountInfo_FinancialInfo(accnt, Caller, AccountType);
        }
        catch(Exception e){
            ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('500', e.getMessage()) ), 500);
        }
    }
}