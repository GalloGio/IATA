/***********************************************************
	2018-11-26. Author: Daniele Tullo
	Class expose a REST webservice which creates account's additional info, such as
        - OSCAR
        - 
	
	JIRA Issue Reference: 
		- https://iatasfdc.atlassian.net/browse/NEWGEN-4366  - 
        - 
	Interface Catalogue:
		INT_077

    Sample URI
    /services/apexrest/account-create-details/<iataCode>/gdi-create-offer?caller=GDI&accountType=Agency

    Sample body
    [

    ]
***********************************************************/

@RestResource(urlMapping='/account-create-details/*')
global without sharing class ANG_CreateAccountDetails {
    
    @HttpPost
    global static void doPost(){
        set<string> setValidAccountType = new set<string>{'Agency'};	//Valid account type
        set<string> setValidCaller = new set<string>{ANG_RestServiceHelper.Caller_GDI};			//Valid caller
        map<string,string> mapAccountTypeRT = new map<string,string>{'Agency' => 'IATA_Agency'};	//Map from account type to account record-type developername
        set<string> setValidRequest = new set<string>{ANG_RestServiceHelper.URIRequest_GDIOffer};    //Valid type of request, part of URI

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

            //Fetch the account
            /* run the query, different based on caller/request type */
            list<Account> lsAccnt;
            if(Caller==ANG_RestServiceHelper.Caller_GDI){
                if (requestType==ANG_RestServiceHelper.URIRequest_GDIOffer)
                    lsAccnt = [SELECT IATACode__c, Id, Name, GDI_Status__c, BillingCountry, Region_formula__c, ANG_Accreditation_Model__c,
                                    (SELECT Id, Email, User_Portal_Status__c, Financial_Assessment_Contact__c, BSP_CASS_Payment_contact__c 
                                        FROM Contacts WHERE Status__c = 'Active')
                                FROM Account WHERE recordtype.developername =:mapAccountTypeRT.get(AccountType) AND IATACode__c =:IATACode];
            }

			if(lsAccnt==null || lsAccnt.isEmpty()){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('404', AccountType + ' ' + IATACode + ' not found')), 404);
                return;
            }
            
            if(lsAccnt.size()>1){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('409', 'Multiple records found with IATA Code ' + IATACode + ' !') ), 409);
                return;
            }
            
            Account accnt = lsAccnt.get(0);
            
            //Security: allow GDI to create records only if the agency has a GDI Account (pending or open)
            if(Caller==ANG_RestServiceHelper.Caller_GDI && accnt.GDI_Status__c != 'Open' && accnt.GDI_Status__c != 'In Progress'){
            	ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('403', 'Not allowed')), 403);
                return;
            }
            
            //All is good. Proceeding in creating records
            if(Caller==ANG_RestServiceHelper.Caller_GDI){
                if (requestType==ANG_RestServiceHelper.URIRequest_GDIOffer)
                    ANG_CreateAccountDetails_Oscar.ANG_Create_GDIOscar(accnt, req.requestBody);
            }
        }catch(Exception e){
            ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('500', e.getMessage()) ), 500);
        }
    }
}


