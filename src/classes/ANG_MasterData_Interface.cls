@RestResource(urlMapping='/ANG_GetMasterData/*')
global class ANG_MasterData_Interface{
    
    @HttpGet
    global static void doGet(){
        try{
            RestRequest req = RestContext.request;
            String IATACode = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            string sMode = req.params.get('mode');
            boolean bContinue = true;
            
            if(IATACode==null || IATACode== ''){
                GenerateResponse(json.serialize(new ErrorPayload('400', 'No IATA Code received')), 400);
                return;
            }
            
            if(sMode == null || sMode=='') sMode = 's';
            
            list<Account> lsAccnt = [select Is_Branch_Abroad__c, Purge_Flag__c, Accreditation_date__c, Date_Organisation_Status_attained__c, Default_date__c, ANG_Accreditation_Model__c, billingCity, billingCountry, billingPostalCode,
                                            billingState, billingStreet, IATA_ISO_Country__r.BSP_Country_free_text__c, IATA_ISO_Country__r.ISO_Code_Numeric__c, IATA_ISO_Country__r.ISO_Code__c, 
                                            Email__c, fax, IATACode__c, Id, ANG_IEP_Status_FF__c, Location_Class__c, Location_Type__c, Name, Parent.IATACode__c, phone, 
                                            IATA_ISO_Country__r.ANG_Portal_Service__r.Name, IATA_ISO_Country__r.Region__c, Reason__c, Remittance_frequency__c, Status__c, Tax_ID_1__c, TradeName__c, 
                                            VAT_Number__c, ANG_RiskStatus__c, Segmentation__c, Top_Parent__r.IATACode__c,
                                            (Select Id, recordtype.developername, Email_Used_for_BSP_Creation__c, ANG_FormOfPayment_ID__c, Status__c From Agency_Authorizations__r where recordtype.developername in ('BSPLink','FormOfPayment')),  //Accelya Email + FOP
                                            (Select Id, IATACode__c, Status__c From ChildAccounts where Purge_Flag__c = false and IATACode__c != null and recordtype.developername= 'IATA_Agency'), //List of children
                                            (Select Id, ANG_RHC_Amount_Simulation__c, CurrencyIsoCode From RHC_Informations__r) //RHC Information
                                     from Account 
                                     where recordtype.developername = 'IATA_Agency' and IATACode__c =:IATACode];
            
            
            if(lsAccnt.isEmpty()){
                GenerateResponse(json.serialize(new ErrorPayload('404', 'Agency ' + IATACode + ' not found')), 404);
                return;
            }
            
            if(lsAccnt.size()>1){
                GenerateResponse(json.serialize(new ErrorPayload('300', 'Multiple agencies found with IATA Code ' + IATACode + ' !') ), 300);
                return;
            }
            
            //All is good. Proceeding in generating payload
            GenerateResponse(json.serialize(replaceNullForblank(new MasterDataPayload(lsAccnt[0], sMode=='F'))), 200);
        }
        catch(exception e){
            GenerateResponse(json.serialize(new ErrorPayload('500', e.getMessage()) ), 500);
        }
    }
    
    private static void GenerateResponse(string sBody, integer iStatusCode){
        RestResponse res = RestContext.response;
        //RestContext.response;
        res.statusCode = iStatusCode;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(sBody);
        //return res;
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
    
    /* RHC Information */
    private class RHCInfoClass{
        public string RiskStatus;
        public Decimal RHCAmount; //Number + currency
        public string RHCCurrency;
        public RHCInfoClass(string RiskStatus, Decimal RHCAmount, string RHCCurrency){
            this.RiskStatus = RiskStatus==null?'':RiskStatus;
            this.RHCAmount = RHCAmount;
            this.RHCCurrency= RHCCurrency==null?'':RHCCurrency;
        }
    }
    
    /* Form Of Payment */
    private class FOP{
        public string Type;     //CA, CE, EP
        public string Status;
        public FOP(string Type, string Status){
            this.Type = Type==null?'':Type;
            this.Status = Status==null?'':Status;
        }
    }
       

    private static final set<string> IGNORE_FIELDS_SET = new set<string>{'FormOfPayment'};
    private static final set<string> REMOVE_FIELDS_SET = new set<string>{'lsChildren'};

    private class MasterDataPayload{
        /* Agency Information */
        public string isBranchAbroad;
        public boolean PurgeCode;
        public string AccreditationDate;
        public string DefaultDate;
        public string LastStatusChangeDate;
        public string AccelyaEmail;     //From Agency Authorization
        public string AccreditationType;
        public string agencyType;
        public string billingCity;
        public string billingCountry;
        public string billingPostalCode;
        public string billingState;
        public string billingStreet;
        public string bspCountry;
        public string countryCodeNumeric;
        public string countryISOCode;
        public string email;
        public string fax;
        public string IATACode;
        public string id;
        public string IEPStatus;
        public string LocationClass;
        public string locationType;
        public string name;
        public string parentIATACode;
        public string phone;
        public string portalServiceName;
        public string Region;
        public string RelinquishmentCode; //ReasonCode
        public string RemittanceFrequency;
        public string Segmentation; 
        public string status;
        public string TaxID;
        public string TradeName;
        public string vatNumber;        
        public string topParentIATACode;
        public list<FOP> FormOfPayment;
        public RHCInfoClass RHCInfo;    //Risk Information
        public list<string> lsChildren; //List of Children IATA Code
        
        


        /*Constructor*/
        public MasterDataPayload(Account acc, boolean getChildren){
            try{
                this.isBranchAbroad = acc.Is_Branch_Abroad__c;
                this.PurgeCode = acc.Purge_Flag__c;
                this.AccreditationDate = FormatDateMS(acc.Accreditation_date__c);
                this.DefaultDate = FormatDateMS(acc.Default_date__c);
                this.LastStatusChangeDate = String.ValueOf(acc.Date_Organisation_Status_attained__c) ;
                
                this.AccreditationType = acc.ANG_Accreditation_Model__c;
                this.agencyType = '';
                this.billingCity = acc.billingCity;
                this.billingCountry = acc.billingCountry;
                this.billingPostalCode = acc.billingPostalCode;
                this.billingState = acc.billingState;
                this.billingStreet = acc.billingStreet;
                this.bspCountry = acc.IATA_ISO_Country__r.BSP_Country_free_text__c;
                this.countryCodeNumeric = string.valueOf(acc.IATA_ISO_Country__r.ISO_Code_Numeric__c);
                this.countryISOCode = acc.IATA_ISO_Country__r.ISO_Code__c;
                this.email = acc.Email__c;
                this.fax = acc.fax;
                this.IATACode = acc.IATACode__c;
                this.id = acc.Id;
                this.IEPStatus = acc.ANG_IEP_Status_FF__c;
                this.LocationClass = acc.Location_Class__c;
                this.locationType = acc.Location_Type__c;
                this.name = acc.Name;
                this.parentIATACode = acc.Parent.IATACode__c;
                this.phone = acc.phone;
                this.portalServiceName = acc.IATA_ISO_Country__r.ANG_Portal_Service__r.Name;
                this.Region = acc.IATA_ISO_Country__r.Region__c;

                this.RelinquishmentCode =acc.Reason__c!=null?acc.Reason__c.split('-').get(0).leftPad(2,'0'):acc.Reason__c;
                this.RemittanceFrequency = acc.Remittance_frequency__c;
                this.Segmentation = acc.Segmentation__c;
                this.status = acc.Status__c;
                this.TaxID = acc.Tax_ID_1__c;
                this.TradeName = acc.TradeName__c;
                this.vatNumber = acc.VAT_Number__c;
                this.topParentIATACode = acc.Top_Parent__r.IATACode__c;
                
                //Risk Info
                for(ANG_RHC_Information__c rhc:acc.RHC_Informations__r)
                    this.RHCInfo = new RHCInfoClass(acc.ANG_RiskStatus__c, rhc.ANG_RHC_Amount_Simulation__c, rhc.CurrencyIsoCode);
                
                //List  of children IATACode
                //Returned only if specifically requested
                if(getChildren){
                    this.lsChildren= new list<string>();
                    if(!acc.ChildAccounts.isEmpty()){
                       
                        for(Account a:acc.ChildAccounts)
                            this.lsChildren.add(a.IATACode__c);
                    }
                }
                
                //Form of Payment and AcceleyaEmail
                if(!acc.Agency_Authorizations__r.isEmpty()){
                    list<FOP> lsFOP = new list<FOP>();
                    for(Agency_Authorization__c aa:acc.Agency_Authorizations__r){
                        if(aa.RecordType.Developername=='BSPLink'){
                            if(aa.Status__c == 'Active')
                                this.AccelyaEmail = aa.Email_Used_for_BSP_Creation__c;      //From Agency Authorization
                        }
                        else
                            lsFOP.add(new FOP(aa.ANG_FormOfPayment_ID__c, aa.Status__c));
                    }
                    FormOfPayment = lsFOP;
                }
            }
            catch(exception e){
                throw e;
            }
        }
    }
    


    private static string FormatDateMS(date theDate){
        if(theDate==null) return null;
        else return theDate.Year() + '-' + string.valueOf(theDate.Month()).leftPad(2).replace(' ', '0') + '-' + string.valueOf(theDate.Day()).leftPad(2).replace(' ', '0');
    }


    private static object replaceNullForblank(object ob){
        String jsonContent = JSON.serialize(ob);
        Map<String,Object> obj = (Map<String,Object>) JSON.deserializeUntyped(jsonContent);
        for(string at:obj.keyset()){
            if(!IGNORE_FIELDS_SET.contains(at) && obj.get(at) ==null){
                if(REMOVE_FIELDS_SET.contains(at))obj.remove(at);
                else obj.put(at,'');
            }                
        }
        return obj;
    }
}