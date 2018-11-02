global class ANG_BatchAggregatePwcData implements Database.Batchable<Account>, Database.Stateful {

    /****** FILTERS ON ACCOUNT ********/
    private static final set<String> locationClassesLimit = new set<String> {'P', 'C', 'D', 'R'};       //Location class to filter
    private static final set<String> locationTypesLimit = new set<String> {'HO', 'AO', 'BR', 'SA', 'HE', 'AE'}; //Location type to filter
    private static final String iataAgencyRecordType = 'IATA_AGENCY';   //Account record type to filter
    private static final set<string> AccountStatusLimit = new set<string> {'Listed', 'Cash basis/no commission', 'Cash basis/with commission', 'Under review', 'Changes processed', 'Approved'};
    
    /****** FILTERS ON CHANGE CODE ******/
    private static final set<String> ownShaChangeCodes = new set<String> {'CHC', 'CHO', 'CHI', 'CHJ', 'CCL', 'CCN', 'CIJ', 'CNL', 'COL', 'CON', 'COS', 'CSC', 'HIN', 'HIS', 'HNL', 'HSL', 'HSM', 'HSN', 'ONL', 'OSL', 'OSM', 'OSN', 'SCL', 'SCM', 'SCN'};   //All change of owner/shareholding change code, including ones generated in case of multiple changes
    private static final set<String> DefaultChangeCodes = new set<String> {'DEF','DFE'};    //Default change code
    private static final set<String> DefaultWithdrawalChangeCodes = new set<String> {'DWD','DFW'};  //Default withdrawal change code
    private static final set<String> IRRsChangeCodes = new set<String> {'IRR','IRW','IRS'}; //Irregularity change code
    private static final set<String> NewGenOwnShaChangeCodes = new set<String> {'CCL', 'CCN', 'CHC', 'CHO', 'CNM', 'COH', 'CON', 'COS', 'CSC', 'CSM', 'HNM', 'HNR', 'MCH', 'OSN', 'SCN', 'SNI', 'TCL', 'TCN', 'TMA', 'TNI', 'TNL', 'TSM', 'UON', 'UOS', 'USN'}; //All change of owner/shareholding change code used by Newgen agencies, including ones generated in case of multiple changes
    
    /****** FILTERS ON RISK EVENTS  *****/
    private static final List<String> REStatus = new List<String> {'Active'};   //Agency Risk's status to filter by 
    
    /****** FILTERS ON COUNTRY ATTRIBUTE TABLE *****/
    private static final string sRTDevNameDEF_LFC = 'DEF_LFC';  //Recordtype.developername of country attributes (Default - Local Financial Criteria)
    private static final string sRTDevNameIRRS_LFC = 'IRRS_LFC';    //Recordtype.developername of country attributes (Irregularity - Local Financial Criteria)
    public map<string, AMS_Country_Specific_Attribute__c> mapAttibPerCountry;   //Index: concatenation of ISOCode + _ +  + Location_Class + _ + RecordType of attributes

    private List<String> upsertErrors = new List<String>();
    
    //Debug
    public datetime dStartTime;
    
    global ANG_BatchAggregatePwcData(){
        mapAttibPerCountry = new map<string, AMS_Country_Specific_Attribute__c>();
        
        //Add to the countries' attributes map all the defaults (12 months for each type)
        for(IATA_ISO_Country__c co:[select ISO_Code__c from IATA_ISO_Country__c]){
            for(string locClass:locationClassesLimit){
                mapAttibPerCountry.put(co.ISO_Code__c + '_' + locClass + '_' + sRTDevNameDEF_LFC, new AMS_Country_Specific_Attribute__c(Months_Count__c = 12));
                mapAttibPerCountry.put(co.ISO_Code__c + '_' + locClass + '_' + sRTDevNameIRRS_LFC, new AMS_Country_Specific_Attribute__c(Months_Count__c = 12));
            }
        }
        
        //get all countries specific attributes and replace the value in the map
        for(AMS_Country_Specific_Attribute__c attr:[select Location_Class__c, Months_Count__c, IATA_ISO_Country__r.Iso_Code__c, recordType.DeveloperName, Irregularity_Type__c
                                                    from AMS_Country_Specific_Attribute__c
                                                    where recordtype.developerName in (:sRTDevNameDEF_LFC, :sRTDevNameIRRS_LFC)]){
            mapAttibPerCountry.put(attr.IATA_ISO_Country__r.ISO_Code__c + '_' + attr.Location_Class__c + '_' + attr.recordType.DeveloperName, attr);
        }
        
        //DEBUG
        dStartTime = system.now();
    }
    
    global Iterable<Account> start(Database.BatchableContext batchableContext) {
        //Query the accounts
        string sQuery = 'SELECT Id ' +
                'FROM Account ' +
                'WHERE RecordType.developername = :iataAgencyRecordType ' +
                'AND IATA_ISO_Country__c != \'\' ' + 
                'AND Location_Class__c IN :locationClassesLimit ' +
                'AND Location_Type__c IN :locationTypesLimit ' + 
                'AND status__c in: AccountStatusLimit ' + 
                'AND WebStar_ID__c = null ' + 
                'AND (Purge_Flag__c=false OR Purge_Flag__c=null)' +
                'AND ANG_FA_Opt_out__c = false';

        return (Iterable<Account>) Database.getQueryLocator(sQuery);
    }

    global void execute(Database.BatchableContext batchableContext, List<account> scope) {

        set<id> setAccntId = new set<id>();
        set<string> setAllChangeCodes = new set<string>();
        
        for(Account a:scope)    setAccntId.add(a.Id);
        
        setAllChangeCodes.addAll(ownShaChangeCodes);
        setAllChangeCodes.addAll(DefaultChangeCodes);
        setAllChangeCodes.addAll(DefaultWithdrawalChangeCodes);
        setAllChangeCodes.addAll(IRRsChangeCodes);
        setAllChangeCodes.addAll(NewGenOwnShaChangeCodes);
        
        //Additional query: is getting the change codes and the risk events for all the accounts in the scope
        list<Account> lsAccntToProcess = [select id, IATA_ISO_Country__r.Iso_Code__c, Location_Class__c, ANG_IsNewGenAgency__c, Accumulated_Irregularities__c, ANG_RiskStatus__c
                                          //Agency_Applied_Change_code__c
                                          ,(Select Id, Change_Code__c, Created_Date_To_Show__c, DEF_Non_Payment2__c, Operation__c, Irregularities_Points__c, Irregularity_Type__c
                                            From Agencies_Applied_Change_codes__r
                                            where Change_Code__c in: setAllChangeCodes
                                            order by Created_Date_To_Show__c)
                                          //ANG_Agency_Risk_Event__c
                                          ,(Select Id, ANG_Event_Status__c, ANG_Risk_Type__r.ANG_Risk_ID__c, ANG_Risk_Type__r.Name
                                            From Location_Risk_Events__r where ANG_Event_Status__c in :REStatus AND ANG_AccountId__r.Location_Type__c = 'HE')
                                          //Existing Aggregation
                                          ,(Select id, AMS_PWC_INT_OWNSHA_LASTDATE__c From Account_Aggregation_for_Integrations__r where Aggregation_System__c='PWC' limit 1)
                                          //get main Contact's language
                                          ,(Select Preferred_Language__c From Contacts where Status__c = 'Active' and (User_Portal_Status__c = 'Approved Admin' OR Financial_Assessment_Contact__c = true) order by User_Portal_Status__c limit 1) 
                                           from account where id in:setAccntId];
        
        list<ANG_Account_Aggregation_for_Integrations__c> lsAggregationToInsert = new list<ANG_Account_Aggregation_for_Integrations__c>();
        
        for(Account accnt:lsAccntToProcess){
            integer iSumIrr = 0;
            integer iDefault = 0;
            integer iDefNonPay = 0;
            integer iShare = 0;
            date dLastShare = null;
            integer iREFinSecurity = 0;
            integer iREFinStatement = 0;
            integer iRENonPayment = 0;
            integer iREPrejColl = 0;
            integer iREUnreportedChange = 0;
            integer iREWrongCurrency = 0;
            string hasOwnerShareChange = 'N';
            string sLang = 'ENG';
            
            string IRRTypeToCheck = 'All';
            integer iMonthDEF = 12;
            integer iMonthIRR = 12;
            
            boolean bIRRTImeFrameHigher = true;
            
            //GetContact language
            if(!accnt.contacts.isEmpty()){
                for(contact con: accnt.contacts)
                    sLang = sGetLanguage(con.Preferred_Language__c);
            }
            
            if(mapAttibPerCountry.containsKey(accnt.IATA_ISO_Country__r.ISO_Code__c + '_' + accnt.Location_Class__c + '_' + sRTDevNameIRRS_LFC)){
                iMonthIRR = integer.valueOf(mapAttibPerCountry.get(accnt.IATA_ISO_Country__r.ISO_Code__c + '_' + accnt.Location_Class__c + '_' + sRTDevNameIRRS_LFC).Months_Count__c);
                
                if(iMonthIRR == 12){
                    bIRRTImeFrameHigher = false;
                    iSumIrr = integer.valueOf((accnt.Accumulated_Irregularities__c==null?0:accnt.Accumulated_Irregularities__c));
                }
                
                if(mapAttibPerCountry.get(accnt.IATA_ISO_Country__r.ISO_Code__c + '_' + accnt.Location_Class__c + '_' + sRTDevNameIRRS_LFC).Irregularity_Type__c !='' )
                    IRRTypeToCheck = mapAttibPerCountry.get(accnt.IATA_ISO_Country__r.ISO_Code__c + '_' + accnt.Location_Class__c + '_' + sRTDevNameIRRS_LFC).Irregularity_Type__c;
                    if(IRRTypeToCheck=='' || IRRTypeToCheck == null)    IRRTypeToCheck = 'All';
            }
            
            if(mapAttibPerCountry.containsKey(accnt.IATA_ISO_Country__r.ISO_Code__c + '_' + accnt.Location_Class__c + '_' + sRTDevNameDEF_LFC))
                iMonthDEF = integer.valueOf(mapAttibPerCountry.get(accnt.IATA_ISO_Country__r.ISO_Code__c + '_' + accnt.Location_Class__c + '_' + sRTDevNameDEF_LFC).Months_Count__c);
            
            //Loop through RiskEvent. NEwGen agencies only
            if(accnt.ANG_IsNewGenAgency__c){
                for(ANG_Agency_Risk_Event__c RE:accnt.Location_Risk_Events__r){
                    if(re.ANG_Risk_Type__r.ANG_Risk_ID__c=='9') iREFinSecurity = iREFinSecurity + 1;
                    if(re.ANG_Risk_Type__r.ANG_Risk_ID__c=='5') iREFinStatement = iREFinStatement + 1;
                    if(re.ANG_Risk_Type__r.ANG_Risk_ID__c=='4') iRENonPayment = iRENonPayment + 1;
                    if(re.ANG_Risk_Type__r.ANG_Risk_ID__c=='11')    iREPrejColl = iREPrejColl + 1;
                    if(re.ANG_Risk_Type__r.ANG_Risk_ID__c=='7') iREUnreportedChange = iREUnreportedChange + 1;
                    if(re.ANG_Risk_Type__r.ANG_Risk_ID__c=='3') iREWrongCurrency = iREWrongCurrency + 1;
                }
            }
            
            //Loop through Change Code
            for(Agency_Applied_Change_code__c cc:accnt.Agencies_Applied_Change_codes__r){
                
                //Last Share Change Date and count of change ownership/hierarchy
                if(ownShaChangeCodes.contains(cc.Change_Code__c) || NewGenOwnShaChangeCodes.contains(cc.Change_Code__c)){
                    if(cc.Created_Date_To_Show__c >= system.today().addMonths(-12)){
                        if(dLastShare==null || cc.Created_Date_To_Show__c>dLastShare)
                            dLastShare = date.ValueOf(cc.Created_Date_To_Show__c);
                        
                        hasOwnerShareChange = 'Y';
                        iShare = iShare +1;
                    }
                }
                
                //DEFAULT and DEFAULT NON-Payment
                if(DefaultChangeCodes.contains(cc.Change_Code__c) || DefaultWithdrawalChangeCodes.contains(cc.Change_code__c)){
                    //SUM DEFAULT
                    if(cc.Created_Date_To_Show__c >= system.today().addMonths(-1*iMonthDEF)){
                        if(DefaultChangeCodes.contains(cc.Change_Code__c)){
                            iDefault = iDefault + 1;
                            
                            //SUM DEFAULT NON-PAYMENT
                            iDefNonPay = iDefNonPay + 1;
                        }else{
                            iDefault = iDefault - 1;    //DEF WHITDRAWAL
                        }
                    }
                }
                
                //IRREGULARITIES
                //SKIP For newgen agencies (write 0)
                if(accnt.ANG_IsNewGenAgency__c){
                    iSumIrr = 0;
                }else{
                    if(IRRsChangeCodes.contains(cc.Change_Code__c)){
                        //To be done only if timeframe <> 12 months OR irregularity type to check <> 'All'
                        if(bIRRTImeFrameHigher || IRRTypeToCheck != 'All'){
                            if(cc.Created_Date_To_Show__c >= system.today().addMonths(-1*iMonthIRR)){
                                if(IRRTypeToCheck=='All' || (IRRTypeToCheck!='All' && IRRTypeToCheck==cc.Irregularity_Type__c)){
                                    if((cc.Change_Code__c=='IRR' && (cc.Operation__c == '' || cc.Operation__c == null || cc.Operation__c == 'A')) || cc.Change_Code__c=='IRS'){
                                        iSumIrr = iSumIrr + integer.valueOf(cc.Irregularities_Points__c);
                                    }
                                    
                                    if((cc.Change_Code__c=='IRR' && cc.Operation__c == 'W') || cc.Change_Code__c=='IRW'){
                                        iSumIrr = iSumIrr - integer.valueOf(cc.Irregularities_Points__c);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            lsAggregationToInsert.add(
                new ANG_Account_Aggregation_for_Integrations__c(
                        Account__c = accnt.id
                        , Aggregation_System__c = 'PWC'
                        , AMS_PWC_INT_DEF__c = (iDefault==null || iDefault<0?0:iDefault)
                        , AMS_PWC_INT_DEFNONPAY__c = (iDefNonPay==null || iDefNonPay<0?0:iDefNonPay)
                        , AMS_PWC_INT_IRRS__c = (iSumIrr==null || iSumIrr<0?0:iSumIrr)
                        , AMS_PWC_INT_OWNSHA_CHANGE__c = hasOwnerShareChange
                        , AMS_PWC_INT_OWNSHA_LASTDATE__c = dLastShare
                        , ANG_RE_FIN_SECURITY__c = iREFinSecurity
                        , ANG_RE_FIN_STATEMENT__c = iREFinStatement
                        , ANG_RE_NONPAYMENT__c = iRENonPayment
                        , ANG_RE_PREJ_COLL_FUNDS__c = iREPrejColl
                        , ANG_RE_UNREPORTED_CHNG__c = iREUnreportedChange
                        , ANG_RE_WRONG_CURRENCY__c = iREWrongCurrency
                        , ANG_Risk_Status__c = accnt.ANG_RiskStatus__c
                        , UniqueKey__c = accnt.id + '_PWC'
                )
            );
            
        }
        
        if(!lsAggregationToInsert.isEmpty()){
            //loop through list of result. If any error, send via email
            List<Database.UpsertResult> upsertResults = database.Upsert(lsAggregationToInsert, ANG_Account_Aggregation_for_Integrations__c.Fields.UniqueKey__c, false);

            String errors;
            for (Database.UpsertResult ur: upsertResults){
                errors = '';
                if (!ur.isSuccess()){
                    for (Database.Error dbErrors  :ur.getErrors()){
                        errors = '\n\tMESSAGE: '+dbErrors.getMessage() + ' | FIELDS: '+String.join(dbErrors.getFields(),',')  + '.';
                    }
                    upsertErrors.add('\nUpsert error on entity with ID: '+ur.getId() +' | DESCRIPTION:  '+errors +'\n');
                }
            }
        }
        
    }

    global void finish(Database.BatchableContext batchableContext) {

        //Send email to support if any error is found
        if (!upsertErrors.isEmpty()){

            System.debug('[ANG_BatchAggregatePwcData] upsertErrors: '+upsertErrors);
            List<String> emailAddresses = new List<String>();
            for (SalesforceSupportEmails__c supportEmail: SalesforceSupportEmails__c.getAll().values()){ 
                emailAddresses.add(supportEmail.Support_Email__c);
                //add more email addresses if needed
            }

            if (!emailAddresses.isEmpty()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(emailAddresses);    
                mail.setSubject('PWC Batch Completed With Errors');
                mail.setSenderDisplayName('Batch Processing Completed');
                mail.setPlainTextBody('Batch Process has been completed. Start Time: ' + dStartTime + '; endTime ' + system.now() + '\n\nERRORS:\n' + String.join(upsertErrors,'\n'));
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
        }
    }
    
    private static string sGetLanguage(string sLang){
        if(sLang==null || sLang == '') return 'ENG';
        if(sLang.toUpperCase()=='CHINESE') return 'CHI';
        if(sLang.toUpperCase()=='ENGLISH') return 'ENG';
        if(sLang.toUpperCase()=='FRENCH') return 'FRE';
        if(sLang.toUpperCase()=='KOREAN') return 'KOR';
        if(sLang.toUpperCase()=='ITALIAN') return 'ITA';
        if(sLang.toUpperCase()=='JAPANESE') return 'JPN';
        if(sLang.toUpperCase()=='PORTUGUESE') return 'POR';
        if(sLang.toUpperCase()=='SPANISH') return 'SPA';
        return 'ENG';
    }
    
}