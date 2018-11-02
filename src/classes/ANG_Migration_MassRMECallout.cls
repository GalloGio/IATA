global class ANG_Migration_MassRMECallout {
    public string theSerializedResultFromRME			{get; set;}
    public list<RMEResponseWrapper> lsRMEWrapperWSOK	{get; set;}
    public list<RMEResponseWrapper> lsRMEWrapperWSErr	{get; set;}
    public string selectedCnt 							{get; set;}
    public boolean bQueryExecuted						{get; set;}
    public boolean bHasError							{get; set;}
    public boolean bHasSuccess							{get; set;}
    public string sType 								{get; set;}
    
    public map<integer, list<RMEResponseWrapper>> mapRMEWrapperWSOk	{get; set;}
    public map<integer, list<RMEResponseWrapper>> mapRMEWrapperWSErr	{get; set;}
    
    public list<selectOption> lsCountry	{get{
    		lsCountry = new list<SelectOption>();
    		lsCountry.add(new selectOption('-','None'));
    		for(IATA_Iso_country__c cnt :[select Id, ISO_Code__c, Name from IATA_Iso_Country__c order by Name asc])
    			lsCountry.add(new selectOption(cnt.ISO_Code__c, cnt.Name));
    		
    		return lsCountry;
    	} set;}
    	
    public list<selectOption> lsTypeOfCall	{get{
    		lsTypeOfCall = new list<SelectOption>();
    		lsTypeOfCall.add(new selectOption('Country','Search by country'));
    		lsTypeOfCall.add(new selectOption('AccountID','Search by Account IDs'));
    		lsTypeOfCall.add(new selectOption('IATACode','Search by IATA Codes'));
    		return lsTypeOfCall;
    	} set;}
    
    public string TypeOfCall	{get; set;}
    public string lsCodeOrId	{get; set;}
    
    public ANG_Migration_MassRMECallout(){
        selectedCnt = '-';
        TypeOfCall = 'Country';
        lsCodeOrId = '';
        if(bHasError==null) bHasError = false;
        if(lsRMEWrapperWSOK==null) lsRMEWrapperWSOK = new  list<RMEResponseWrapper>();
        if(lsRMEWrapperWSErr==null) lsRMEWrapperWSErr = new  list<RMEResponseWrapper>();
        if(mapRMEWrapperWSOk==null) mapRMEWrapperWSOk = new  map<integer, list<RMEResponseWrapper>>();
        if(mapRMEWrapperWSErr==null) mapRMEWrapperWSErr = new  map<integer, list<RMEResponseWrapper>>();
        if(bHasSuccess==null) bHasSuccess = false;
        sType = '';
    }
    
    public pageReference NewSearch(){
        PageReference page = new PageReference('/apex/ANG_Migration_MassRMECallout');
        page.setRedirect(true);
        return page;
    }
    
    public pageReference afterCallout(){
    	list<RMEResponseWrapper> lsRMEWrapperTmp = new list<RMEResponseWrapper>();
    	set<id> setRHCId = new set<id>();
    	lsRMEWrapperTmp = (list<RMEResponseWrapper>)JSON.deserialize(theSerializedResultFromRME, list<RMEResponseWrapper>.class);
    	
    	for(RMEResponseWrapper rw:lsRMEWrapperTmp){
    		if(rw.RHCId != null)	setRHCId.add(rw.RHCId);
    		if(sType=='')	sType = rw.sType;
    	}
    	
    	map<id, ANG_RHC_Information__c> mapRHC = new map<id, ANG_RHC_Information__c>();
    	for(ANG_RHC_Information__c rhc:[select id, ANG_ConsumedRHC__c, ANG_ConsumedRHC_Last_Update__c, ANG_Provisional_RHC_Last_Update__c, ANG_ConsumedRHC_Percent__c, ANG_RHC_Amount_Provisional__c, CurrencyIsoCode from ANG_RHC_Information__c where id in:setRHCId])
    		 mapRHC.put(rhc.Id,  rhc);
    	integer IndexMap = 1;
    	integer iCounter = 1;
    	//Enrich wrapper with data just got from RME
    	for(RMEResponseWrapper rw:lsRMEWrapperTmp){
    		IndexMap = integer.valueOf(iCounter/1000);
    		list<RMEResponseWrapper> tmpLSOk;
    		list<RMEResponseWrapper> tmpLSErr;
    		
    		if(mapRMEWrapperWSErr.containsKey(IndexMap)) tmpLSErr = mapRMEWrapperWSErr.get(IndexMap);
    		else tmpLSErr = new list<RMEResponseWrapper>();
    		
    		if(mapRMEWrapperWSOk.containsKey(IndexMap)) tmpLSOk = mapRMEWrapperWSOk.get(IndexMap);
    		else tmpLSOk = new list<RMEResponseWrapper>();
    		
    		if(rw.RHCId != null){
    			if(mapRHC.containsKey(rw.RHCId)){
	    			rw.ProvAmnt = mapRHC.get(rw.RHCId).ANG_RHC_Amount_Provisional__c;
	    			rw.sCurrency = mapRHC.get(rw.RHCId).CurrencyIsoCode;
	    			rw.ConsumedRHC = mapRHC.get(rw.RHCId).ANG_ConsumedRHC__c;
	    			rw.ConsumedRHCPerc = mapRHC.get(rw.RHCId).ANG_ConsumedRHC_Percent__c;
	    			
	    			if(rw.sType == 'ConsumedRHC')
	    				rw.sLastUpd = string.ValueOf(mapRHC.get(rw.RHCId).ANG_ConsumedRHC_Last_Update__c);
	    			else
	    				rw.sLastUpd = string.ValueOf(mapRHC.get(rw.RHCId).ANG_Provisional_RHC_Last_Update__c);
    			} 
    		}
    		
    		if(rw.isSuccess){
    			bHasSuccess = true;
    			tmpLSOk.add(rw);
    			mapRMEWrapperWSOk.put(IndexMap, tmpLSOk);
    			lsRMEWrapperWSOK.add(rw);
    		}else{
    			bHasError = true;
    			tmpLSErr.add(rw);
    			mapRMEWrapperWSErr.put(IndexMap, tmpLSErr);
    			
    			lsRMEWrapperWSErr.add(rw);
    		}
    		
    		iCounter++;
    	}
    	lsRMEWrapperTmp = null;
    	setRHCId = null;
    	theSerializedResultFromRME =  null;
		return null;
   	}
    
    public PageReference doNothing(){return null;}
    public void SearchPerformed(){bQueryExecuted = true; }
    
    global class RMEResponseWrapper{
    	public boolean isSuccess	{get; set;}
    	public string description	{get; set;}
    	public string iataCode		{get; set;}
    	public string RHCId			{get; set;}
    	public string AccntId		{get; set;}
    	public string sCurrency		{get; set;}
    	public decimal ProvAmnt		{get; set;}
    	public decimal ConsumedRHC	{get; set;}
    	public decimal ConsumedRHCPerc	{get; set;}
    	public string sLastUpd		{get; set;}
    	public string sType			{get; set;}
    }
    
    
    
    @RemoteAction
    global static WebserviceResult SendRequestToRME(string AccountID, string sType){
    	if(sType=='ProvisionalRHC')
    		return requestProvisionalRHC(AccountID);
    	else
    	if(sType=='ConsumedRHC')
    		return requestBalanceUpdate(AccountID);
    	else
    		return null;//should never arrive here
    }
    
    
    global class WebserviceResult {
		webservice Boolean isSuccess;
		webservice String description;
		webservice String iataCode;

		private RHCMessage res;

		private WebserviceResult(){
			isSuccess = true;
		}
	}
	
	
	webservice static WebserviceResult requestBalanceUpdate(String accountId){
		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_ConsumedRHC__c, ANG_RHC_Amount__c, ANG_ConsumedRHC_Percent__c, ANG_ConsumedRHC_Last_Update__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account where Id = :accountId];
		WebserviceResult result = doRequest(acc.IATACode__c, 'BTN_Bal'); //results are saved on the private varible "result"
		if(result.isSuccess){
			if(result.res.iataCode != acc.IATACode__c){
				result.isSuccess = false;
				result.description = 'Iata Code Mismatch. Sent: ' + acc.IATACode__c + '; Received ' + result.res.iataCode;
			}
			else if (result.res.storedBaseCurrency != acc.RHC_Informations__r[0].CurrencyIsoCode){
				result.isSuccess = false;
				result.description = 'RHC Currency mismatch. RHC Currency set: ' + acc.RHC_Informations__r[0].CurrencyIsoCode + '; Received ' + result.res.storedBaseCurrency;
			}
			else if(result.res.storedRHCValue != acc.RHC_Informations__r[0].ANG_RHC_Amount__c){
				result.isSuccess = false;
				result.description = 'RHC Amount Mismatch. RHC Amount set: ' + acc.RHC_Informations__r[0].ANG_RHC_Amount__c + '; Received ' + result.res.storedRHCValue;
			}
			else{
				try{
					ANG_RHC_Information__c rhcInfo = acc.RHC_Informations__r[0];
					rhcInfo.ANG_ConsumedRHC__c = result.res.consumedRHCAmount;
					rhcInfo.ANG_ConsumedRHC_Percent__c = result.res.consumedRHCPercentage*100;
					rhcInfo.ANG_ConsumedRHC_Last_Update__c = result.res.eventTime.date();
					update rhcInfo;
				}catch(Exception e) {
					result.isSuccess = false;
					result.description = 'Error while updating RHC Information: ' + e.getMessage();
				}
			}
		}

		return result;
	}
	
	
	webservice static WebserviceResult requestProvisionalRHC(String accountId){
		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_RME_Amount__c, ANG_RHC_Amount_Provisional__c, ANG_Provisional_RHC_Last_Update__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account where Id = :accountId];
		WebserviceResult result = doRequest(acc.IATACode__c, 'BTN_Prov'); //results are saved on the private varible "result"
		if(result.isSuccess){
			if(result.res.iataCode != acc.IATACode__c){
				result.isSuccess = false;
				result.description = 'Iata Code Mismatch. Sent: ' + acc.IATACode__c + '; Received ' + result.res.iataCode;
			}
			else if (result.res.storedBaseCurrency != acc.RHC_Informations__r[0].CurrencyIsoCode){
				result.isSuccess = false;
				result.description = 'RHC Currency Mismatch. RHC Currency set: ' + acc.RHC_Informations__r[0].CurrencyIsoCode + '; Received ' + result.res.storedBaseCurrency;
			}
			else if(result.res.storedRHCValue != acc.RHC_Informations__r[0].ANG_RHC_Amount__c){
				result.isSuccess = false;
				result.description = 'RHC Amount Mismatch. RHC Amount set: ' + acc.RHC_Informations__r[0].ANG_RHC_Amount__c + '; Received ' + result.res.storedRHCValue;
			}
			else{
				try{
					//First step: update RHC with results from webservice
					ANG_RHC_Information__c rhcInfo = acc.RHC_Informations__r[0];
					rhcInfo.ANG_RHC_Amount_Provisional__c = result.res.provisionalRHC;
					rhcInfo.ANG_Provisional_RHC_Last_Update__c = System.today();
					update rhcInfo;
					
					//Second step: confirm RHC
					ANG_RHC_Information__c rhcInfo2 = [select id, ANG_CashCondition__c, ANG_FINANCIAL_SECURITY__C, ANG_RHC_AMOUNT_FORECASTED__C, ANG_RME_Amount__c from ANG_RHC_Information__c where id=:acc.RHC_Informations__r[0].Id];
					if(rhcInfo2.ANG_CashCondition__c){
						rhcInfo2.ANG_RME_Amount__c = rhcInfo2.ANG_FINANCIAL_SECURITY__C;
					}else{
						if(rhcInfo2.ANG_RHC_AMOUNT_FORECASTED__C > rhcInfo2.ANG_FINANCIAL_SECURITY__C)
							rhcInfo2.ANG_RME_Amount__c = rhcInfo2.ANG_RHC_AMOUNT_FORECASTED__C;
						else
							rhcInfo2.ANG_RME_Amount__c = rhcInfo2.ANG_FINANCIAL_SECURITY__C;
					}
					
					update rhcInfo2;
				}catch(Exception e) {
					result.isSuccess = false;
					result.description = 'Error while updating RHC Information: ' + e.getMessage();
				}
			}
		}
		return result;
	}
	
	private static WebserviceResult doRequest(String iataCode, String mappingName){
		ANG_CalloutMapping__c params = ANG_CalloutMapping__c.getInstance(mappingName);

		WebserviceResult result = new WebserviceResult();
		result.iataCode = iataCode;

		//do callout
		HttpRequest req = new HttpRequest();
		req.setHeader('Content-Type', 'application/json');
		req.setMethod(params.Action__c);
		req.setTimeout(120000);
		req.setEndpoint('callout:' + params.Named_Credential__c + params.Credential__c.replace('{agencyId}', iataCode) + '?client_id=' + params.client_id__c + '&client_secret=' + params.client_secret__c);

		//parse result
		HttpResponse res;

		try {
			res = new Http().send(req);

			if(res.getStatusCode() >= 200 && res.getStatusCode() < 300){
				result.res = (RHCMessage)JSON.deserializeStrict(res.getBody(), RHCMessage.class);
			}else{
				result.isSuccess = false;
				result.description = res.getStatusCode() + ' - ' + res.getStatus();
			}
		} catch(Exception e) {
			result.isSuccess = false;
			result.description = e.getMessage();
		}

		return result;
	}
	
	public class RHCMessage{
		//Basic info
		public String iataCode;
		public String eventId;
		public String eventType;
		public Decimal schemaVersion;
		public Datetime eventTime;

		//Balance Update AND RHC alert
		public String storedBaseCurrency;
		public Decimal storedRHCValue;
		public Decimal provisionalRHC;
		public Decimal consumedRHCAmount;
		public Decimal consumedRHCPercentage;

		//Used on INT 033: Request Provisional RHC (button)
		public String title;
		public String transactionId;
		public String api;
		public String code;
	}
}