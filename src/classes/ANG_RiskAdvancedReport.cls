public without sharing class ANG_RiskAdvancedReport {
    public boolean hasResult    {get;set;}
    public boolean hasRun       {get;set;}
    public boolean hasError     {get;set;}
    
    public string selectedTimeFrame {get ; set;}
    public List<SelectOption> getselectOptionTimeFrame() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('24Hours','24 Hours'));
        options.add(new SelectOption('48Hours','48 Hours'));
        options.add(new SelectOption('72Hours','72 Hours'));
        options.add(new SelectOption('5Days','5 Days'));
        options.add(new SelectOption('1Week','1 Week'));
        options.add(new SelectOption('2Weeks','2 Weeks'));
        options.add(new SelectOption('1Month','1 Month'));
        options.add(new SelectOption('3Month','3 Months'));
        options.add(new SelectOption('6Month','6 Months'));

        return options;
    }
    
    public List<string> selectedRegion {get ; set;}
    public List<SelectOption> getSelectOptionRegion() {
        List<SelectOption> options = new List<SelectOption>();
        selectedRegion= new List<String>();
        Schema.DescribeFieldResult fieldResult =
         IATA_ISO_Country__c.Region__c.getDescribe();
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
           for( Schema.PicklistEntry f : ple)
           {
              options.add(new SelectOption(f.getLabel(), f.getValue()));
              selectedRegion.add(f.getValue());
           }       

        return options;
    }
    
    //Controller to initialize
    public ANG_RiskAdvancedReport(){
        selectedTimeFrame = '24Hours';
        hasResult = false;
        hasRun = false;
        hasError = false;
    }
    
    public list<resultWrapper> lsWrapperResult  {get; set;}
    public list<Account> lsResult   {get; set;}
    
    private string FIN = 'FIN';
    private set<string> IRRDEF = new set<string>{'IRR', 'IRS', 'DFE'};
    private set<string> CHICHO = new set<string>{'CHH','CHI','CHO','CIJ','COH',
                                                'COL','CON','COS','HIN','HIS','HNL',
                                                'HNM','HNR','HSL','HSM','HSN','ONL',
                                                'OSL','OSM','OSN','TCL','TCN','TMA',
                                                'TNI','TNL','TSM','UON','UOS','USN'};
    
    public pageReference runReport(){
        lsWrapperResult = new list<resultWrapper>();
        hasRun = true;
        hasResult = false;
        hasError = false;
        
        if(selectedRegion.isEmpty()){
            hasError = true;
            
        }else{
            datetime dtFrom;
            if(selectedTimeFrame=='24Hours') dtFrom = system.now().addDays(-1);
            if(selectedTimeFrame=='48Hours') dtFrom = system.now().addDays(-2);
            if(selectedTimeFrame=='72Hours') dtFrom = system.now().addDays(-3);
            if(selectedTimeFrame=='5Days') dtFrom = system.now().addDays(-5);
            if(selectedTimeFrame=='1Week') dtFrom = system.now().addDays(-7);
            if(selectedTimeFrame=='2Weeks') dtFrom = system.now().addDays(-14);
            if(selectedTimeFrame=='1Month') dtFrom = system.now().addMonths(-1);
            if(selectedTimeFrame=='3Month') dtFrom = system.now().addMonths(-3);
            if(selectedTimeFrame=='6Month') dtFrom = system.now().addMonths(-6);
            
            set<id> setAccntId = new set<id>();
            set<id> setAccntIdWithYellowAfterRed = new set<id>();
            set<id> setAccntIdWithRed = new set<id>();
            
            list<ANG_Risk_Alert__c> lsRiskAlert = [select ANG_Account__c, ANG_Severity__c, CreatedDate, ANG_Agent_Sales__c 
                                                    from ANG_Risk_Alert__c 
                                                    where recordtype.developername = 'Risk_Alert_RTS' 
                                                        and CreatedDate>=:dtFrom 
                                                        and ANG_Account__r.IATA_ISO_Country__r.Region__c in:selectedRegion 
                                                    order by createdDate desc];
            
            for(ANG_Risk_Alert__c ar:lsRiskAlert){
                setAccntId.add(ar.ANG_Account__c);

                if(ar.ANG_Severity__c=='Red' )  
                    setAccntIdWithRed.add(ar.ANG_Account__c);

                if(ar.ANG_Severity__c=='Yellow' && setAccntIdWithRed.contains(ar.ANG_Account__c))   
                    setAccntIdWithYellowAfterRed.add(ar.ANG_Account__c);
            }
            
            if(!setAccntId.isEmpty()){
                hasResult = true;
                map<id, Account> mapAccount = new map<id, Account>();

                for(Account accnt:[Select Name, IATACode__c, Guaranteed_amount__c, IATA_ISO_Country__r.name,
                                                (Select Status__c From Agency_Authorizations__r where recordType.DeveloperName='BSPLink'), 
                                                (Select Change_Code__c, Created_Date_To_Show__c, Irregularity_Type__c 
                                                    From Agencies_Applied_Change_codes__r 
                                                    where (Created_Date_To_Show__c>=:system.now().addMonths(-12) AND (Change_Code__c in:CHICHO OR Change_Code__c in: IRRDEF))
                                                            OR (Created_Date_To_Show__c>=:system.now().addMonths(-24) AND Change_Code__c=:FIN)
                                                    order by Created_Date_To_Show__c DESC
                                                ) 
                                                From Account where id in:setAccntId]){

                    mapAccount.put(accnt.id, accnt);
                }
                        
                        
                /*
                Map<Id,ANG_RHC_Information__c> mapAccIDrhcInfos = new Map<Id,ANG_RHC_Information__c>();
                for (ANG_RHC_Information__c rhc : [SELECT ANG_Financial_Security__c,CurrencyIsoCode,ANG_AccountId__c FROM ANG_RHC_Information__c WHERE  ANG_AccountId__c in :mapAccount.keyset()]){
                    mapAccIDrhcInfos.put(rhc.ANG_AccountId__c, rhc);
                }*/

                for(ANG_Risk_Alert__c ar:lsRiskAlert){
                    resultWrapper rw = new resultWrapper();
                    rw.RiskAlert = ar;
                    Account Accnt = mapAccount.get(ar.ANG_Account__c);
                    list<ChangeCodeWrapper> lsCHICHO = new list<ChangeCodeWrapper>();
                    list<ChangeCodeWrapper> lsIRRDEF = new list<ChangeCodeWrapper>();
                    list<ChangeCodeWrapper> lsFIN = new list<ChangeCodeWrapper>();
                    
                    for(Agency_Applied_Change_code__c aacc:accnt.Agencies_Applied_Change_codes__r){
                        if(aacc.Change_Code__c==FIN)    lsFIN.add(new ChangeCodeWrapper(aacc.Change_Code__c,aacc.Created_Date_To_Show__c)); //lsFIN.add(aacc);
                        if((IRRDEF.contains(aacc.Change_Code__c) && aacc.irregularity_type__c == 'OV2') || aacc.Change_Code__c == 'DFE' )   lsIRRDEF.add(new ChangeCodeWrapper(aacc.Change_Code__c,aacc.Created_Date_To_Show__c)); //lsIRRDEF.add(aacc);
                        if(CHICHO.contains(aacc.Change_Code__c))    lsCHICHO.add(new ChangeCodeWrapper(aacc.Change_Code__c,aacc.Created_Date_To_Show__c)); //lsCHICHO.add(aacc);

                    }
                    
                    if(!Accnt.Agency_Authorizations__r.isEmpty())
                        rw.TAStatus = Accnt.Agency_Authorizations__r[0].Status__c;
                    else
                        rw.TAStatus = '';
                    
                                        
                    if(setAccntIdWithRed.contains(ar.ANG_Account__c))
                        rw.REDAfterYellow = true;

                    
                    rw.theAccount = Accnt;
                    rw.lsCHICHO = lsCHICHO;
                    rw.lsIRRDEF = lsIRRDEF;
                    rw.lsFIN = lsFIN;

                    
                    /*if(!mapAccIDrhcInfos.isEmpty() && mapAccIDrhcInfos.containsKey(Accnt.id) && mapAccIDrhcInfos.get(Accnt.id).ANG_Financial_Security__c != null && mapAccIDrhcInfos.get(Accnt.id).CurrencyIsoCode != null)
                        rw.guaranteedAmount = mapAccIDrhcInfos.get(Accnt.id).ANG_Financial_Security__c.setscale(2) + ' ' +  mapAccIDrhcInfos.get(Accnt.id).CurrencyIsoCode;
                    else*/
                    rw.guaranteedAmount =+ 'USD ' +  Accnt.Guaranteed_amount__c.setscale(2) ;
                   
                   lsWrapperResult.add(rw);
                   system.debug('DTULLO --> ' + lsWrapperResult);
                }
            }
        }
        return null;
    }
    
    
    
    public class resultWrapper{
        public ANG_Risk_Alert__c RiskAlert  {get;set;}
        public Account theAccount   {get;set;}
        public string TAStatus  {get;set;}
        public string guaranteedAmount  {get;set;}
        public list<ChangeCodeWrapper> lsCHICHO {get;set;}
        public list<ChangeCodeWrapper> lsIRRDEF {get;set;}
        public list<ChangeCodeWrapper> lsFIN    {get;set;}
        public boolean REDAfterYellow   {get;set;}
    }

    public class ChangeCodeWrapper{
        public String changeCode {get;set;} 
        public String convertedDate {get;set;}

        public ChangeCodeWrapper(String changeCode, Datetime convertedDate){
            this.changeCode = changeCode;
            this.convertedDate = convertedDate.format('dd-MMM-yyyy');
        }
    }

}