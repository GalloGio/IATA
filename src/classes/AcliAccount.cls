global  class AcliAccount  {

    //ACLI Enhancements
    //Portal Service Name
    /*public static String PORTAL_SERVICE_NAME_ACLI  = 'NOT SET';

    static {
        ISSP_Portal_Service_Ids__c serviceIdInstance = ISSP_Portal_Service_Ids__c.getInstance();
        if (serviceIdInstance != null && !String.isBlank(serviceIdInstance.ACLI_IATA_Airlines_and_Location_Codes_Na__c)){
            AcliAccount.PORTAL_SERVICE_NAME_ACLI = serviceIdInstance.ACLI_IATA_Airlines_and_Location_Codes_Na__c;
        }
    }

    */private static final map<String,String> MAP_REASONS = new map<String,String>{
        'ACP' => '3 Digit Form',
        'DES' => 'Designator Form',
        'LOS' => 'Location ID Form'
    };


    public string AirlineName {get;set;}
    public string AccountingCode {get;set;}
    public string ThreeLetterCode {get;set;}
    public string TwoCaracterCode {get;set;}
    public string Address {get;set;}
    public string City {get;set;}
    public string State {get;set;}
    public string Country {get;set;}
    public string PostalCode {get;set;}
    public boolean SITA{get;set;}
    public boolean ARINC{get;set;}
    public boolean IATA{get;set;}
    public boolean ATA{get;set;}
    public string TypeOfOperations{get;set;}
    public string AccountingCodeSecondaryFLag{get;set;}
    public string AirlinePrefix {get;set;}
    public string AirlinePrefixSecFlag {get;set;}
    // New from Oct 2015
    public string AcliSAPId {get;set;} // CustomerNumber
    public string AcliStatus {get;set;}
    public string AocExpiryDate {get;set;} // Airline Operating Certificate valdity date
    //public boolean MITA {get;set;} // MITA Member
    public string ApplicationId {get;set;}
    public string CodingApplicationStatus {get;set;}
    public string CodingApplicationReceptionDate {get;set;}
    // /new

    public boolean ExistingInSFDC {get;set;}
    public string AccountSite {get;set;}
    public string IsoCountryID {get;set;}

    public Datetime LastModifiedDate  {get;set;}
    public string IsoCountrySFDC {get;set;}
    public string RealSite{get;set;}
    public string IsoCode{get;set;}
    public string AccKey {get;set;}
    public string AcctID {get;set;}
    public string Membership_status {get; set;}
    public string reason {get; set;}

    public AcliAccount( String Line, boolean stateOFF ){

        this.ExistingInSFDC = false;
        this.AirlineName =  Line.substring(0,80).trim();
        this.AccountingCode =  Line.substring(80,84).trim();
        this.ThreeLetterCode =  Line.substring(84,87).trim();
        this.TwoCaracterCode = Line.substring(87,90).trim();
        //this.DuplicateFlagIndicator =  Line.substring(89,90) == '*' ? true: false;
        this.Address =  Line.substring(90,170).trim();
        this.City =  Line.substring(170,195).trim();
        this.State =  Line.substring(195,215).trim() == 'Not Available' ? '': Line.substring(195,215).trim() ;
        this.Country =  Line.substring(215,259).trim();
        this.PostalCode =  Line.substring(259,269).trim();
        this.SITA = Line.substring(373,374) == 'Y' ? true: false;
        this.ARINC = Line.substring(374,375) == 'Y' ? true: false;
        this.IATA = Line.substring(375,376) == 'Y' ? true: false;
        this.ATA = Line.substring(376,377) == 'Y' ? true: false;

        /*
        this.TypeOfOperations =Line.substring(377,378);
        this.AccountingCodeSecondaryFlag = Line.substring(378,379);
        this.AirlinePrefix =  Line.substring(379,382);
        this.AirlinePrefixSecFlag  =Line.substring(382,383);
        */

        // new mapping from Oct 2015
        // March 2016 removed the use of MITA field, this field is managed manually
        //this.MITA = Line.substring(377,378) == 'Y' ? true: false;

        this.TypeOfOperations = Line.substring(378,379).trim();
        this.AccountingCodeSecondaryFlag = Line.substring(379,380).trim();
        this.AirlinePrefix = Line.substring(380,383).trim();
        this.AirlinePrefixSecFlag = Line.substring(383,384).trim();

        this.AcliSAPId = Line.substring(384,394).trim();
        this.AcliStatus =  Line.substring(394,395) == 'X' ? 'Active Company' : 'Inactive Company';
        this.ApplicationId = Line.substring(403,413).trim();
        this.CodingApplicationStatus = Line.substring(414,444).trim();

        if (Line.substring(395,403).trim() != '' && Line.substring(395,403).trim() != '0' && Line.substring(395,403).trim() != '00000000') {
            this.AocExpiryDate = Line.substring(395,403).substring(0,4) + '-' + Line.substring(395,403).substring(4,6) + '-' + Line.substring(395,403).substring(6,8);
        }
        if (Line.substring(444,452).trim() != '' && Line.substring(444,452).trim() != '0' && Line.substring(444,452).trim() != '00000000') {
            this.CodingApplicationReceptionDate = Line.substring(444,452).substring(0,4) + '-' + Line.substring(444,452).substring(4,6) + '-' + Line.substring(444,452).substring(6,8);
        }
        this.reason = MAP_REASONS.get(Line.substring(452,455).trim());

        // /new


         //this.AccKey =  AirlineName + AccountingCode +ThreeLetterCode + TwoCaracterCode +DuplicateFlagIndicator + Country    ;
         this.AccKey =  AirlineName + AccountingCode +ThreeLetterCode + TwoCaracterCode + Country    ;
         IATA_ISO_Country__c iataLocal  =   IsoSingleton.getInstance().IsoCountriesPerAcliCountryNames.get(Country.trim());

         if(iataLocal <> null){
            this.IsoCode =  iataLocal.ISO_Code__c;
            this.IsoCountryID =iataLocal.Id;
            this.IsoCountrySFDC = iataLocal.name;
         }

         this.AccountSite = TransformationHelper.buildSiteForAcli(AccountingCode, TwoCaracterCode,IsoCode, AirlinePrefix ) ;
         this.RealSite = AccountSite;
        string bilstate = this.State <> null && this.State.trim() <> '' ? this.State:'';
         this.AccountSite =  this.AccountSite <> null ? this.AccountSite.toUpperCase() : this.AccountSite;
       if(!stateOFF && bilstate <> ''  )this.AccountSite +=bilstate.trim();



    }

    public Boolean updateAccount(Account account){
        Boolean isUpdated = false;

        if (nvl(account.IATACode__c) != nvl(this.AccountingCode)) {
            isUpdated = true;
            account.Old_IATA_Code__c = account.IATACode__c;
            account.IATACode__c=this.AccountingCode;
        }

        if (nvl(account.Airline_designator__c) != nvl(this.TwoCaracterCode)) {
            isUpdated = true;
            account.Old_Airline_designator__c = account.Airline_designator__c;
            account.Airline_designator__c=this.TwoCaracterCode;
        }

        if (nvl(account.Airline_Prefix__c) != nvl(this.AirlinePrefix)) {
            isUpdated = true;
            account.Old_Airline_Prefix__c = account.Airline_Prefix__c;
            account.Airline_Prefix__c=this.AirlinePrefix;
        }

        isUpdated |= nvl(account.ICAO_designator__c) != nvl(this.ThreeLetterCode);
        account.ICAO_designator__c=this.ThreeLetterCode;

        isUpdated |= account.Membership_SITA__c != this.SITA;
        account.Membership_SITA__c=this.SITA;

        isUpdated |= account.Memmership_ARINC__c != this.ARINC;
        account.Memmership_ARINC__c=this.ARINC;

        isUpdated |= account.IATA_Member__c != this.IATA;
        account.IATA_Member__c=this.IATA;

        isUpdated |= account.Memmership_ATA__c != this.ATA;
        account.Memmership_ATA__c=this.ATA;

        isUpdated |= nvl(account.Type_of__c) != nvl(this.TypeOfOperations);
        account.Type_of__c=this.TypeOfOperations;

        isUpdated |= nvl(account.Account_code_secondary_flag__c) != nvl(this.AccountingCodeSecondaryFlag);
        account.Account_code_secondary_flag__c=this.AccountingCodeSecondaryFlag;

        isUpdated |= nvl(account.ACLI_Status__c) != nvl(this.AcliStatus);
        account.ACLI_Status__c = this.AcliStatus;

        isUpdated |= nvl(account.ACLI_SAP_Id__c) != nvl(this.AcliSAPId);
        account.ACLI_SAP_Id__c = this.AcliSAPId;

        //isUpdated |= account.MITA_Member__c != this.MITA;
        //account.MITA_Member__c = this.MITA;

        Date expiryDate = getDate(this.AocExpiryDate);
        isUpdated |= account.AOC_Expiry_Date__c != expiryDate;
        account.AOC_Expiry_Date__c = expiryDate;

        ACLI_Sector_Category__c sectorCategory = ACLI_Sector_Category__c.getInstance(this.TypeOfOperations);
        if ( sectorCategory != null) {
            isUpdated |= nvl(account.Sector__c) != nvl(sectorCategory.Sector__c);
            account.Sector__c = sectorCategory.Sector__c;

            isUpdated |= nvl(account.Category__c) != nvl(sectorCategory.Category__c);
            account.Category__c = sectorCategory.Category__c;
        }

        isUpdated |= nvl(account.Name_on_AOC__c) != nvl(this.AirlineName);
        account.Name_on_AOC__c =  this.AirlineName;

        isUpdated |= nvl(account.billingStreet) != nvl(this.Address);
        account.billingStreet=this.Address;

        isUpdated |= nvl(account.billingCity) != nvl(this.City);
        account.billingCity=this.City;

        isUpdated |= nvl(account.billingState) != nvl(this.State);
        account.billingState = this.State;

        isUpdated |= nvl(account.billingPostalCode) != nvl(this.PostalCode);
        account.billingPostalCode=this.PostalCode;

        if ( this.Country != null && nvl(account.billingCountry) != this.Country) {
            isUpdated = true;
            account.billingCountry=this.Country;
        }

        // if the country is not specified in the ACLI file it is not changed
        if ( this.IsoCountryID != null && nvl(account.IATA_ISO_Country__c) != this.IsoCountryID) {
            isUpdated = true;
            account.IATA_ISO_Country__c=this.IsoCountryID;
        }

        return isUpdated;
    }

    public static String nvl(String input) {
        return input==null? '': input;
    }

    public static Account createAcctFromAcliAccount(AcliAccount acliacc){
            try{
                Account a;
                if(acliacc <>null) {
                    a = new Account(
                                        //Accounting_Code__c=acliacc.ThreeLetterCode ,   acliacc one could be deleted
                                        id = acliacc.AcctID,
                                        Name = acliacc.AirlineName,
                                        Name_on_AOC__c =  acliacc.AirlineName,
                                        IATACode__c = acliacc.AccountingCode,
                                        Airline_designator__c=acliacc.TwoCaracterCode ,
                                        ICAO_designator__c   =acliacc.ThreeLetterCode ,
                                        Membership_SITA__c=acliacc.SITA ,
                                        Memmership_ARINC__c=acliacc.ARINC ,
                                        IATA_Member__c=acliacc.IATA ,
                                        Memmership_ATA__c=acliacc.ATA ,
                                        Type_of__c=acliacc.TypeOfOperations ,
                                        Account_code_secondary_flag__c=acliacc.AccountingCodeSecondaryFlag ,
                                        Airline_Prefix__c=acliacc.AirlinePrefix ,
                                        ACLI_Status__c = acliacc.AcliStatus,
                                        ACLI_SAP_Id__c = acliacc.AcliSAPId,
                                        //MITA_Member__c = acliacc.MITA,
                                        AOC_Expiry_Date__c = getDate(acliacc.AocExpiryDate),
                                        IsPartner = true
                                        );

                    if (ACLI_Sector_Category__c.getInstance(acliacc.TypeOfOperations) != null) {
                        a.Sector__c = ACLI_Sector_Category__c.getInstance(acliacc.TypeOfOperations).Sector__c;
                        a.Category__c = ACLI_Sector_Category__c.getInstance(acliacc.TypeOfOperations).Category__c;
                    }

                    if (acliacc.Membership_status != 'IATA member') {
                        // this data is only for MER to edit
                        a.billingStreet=acliacc.Address;
                        a.billingCity=acliacc.City;
                        a.billingState = acliacc.State;
                        a.billingCountry=acliacc.Country;
                        a.billingPostalCode=acliacc.PostalCode;
                        a.IATA_ISO_Country__c=acliacc.IsoCountryID;
                    }
                }
                return a;

                }catch(Exception e){

                    throw new transformationException( ' ' + e.getmessage() + e.getStackTraceString() );
                    return null;
                }

        }

    private static Date getDate(String str) {
        try {
            return Date.valueOf(str);
        } catch (Exception e) {
            return null;
        }
    }

    public static String firstLineCSV(){

        string fline = 'ID,Name_on_AOC__c,IATACode__c,Airline_designator__c,ICAO_designator__c,'
                        +'billingStreet,billingCity,billingState,billingCountry,billingPostalCode,Membership_SITA__c,'
                        +'Memmership_ARINC__c,IATA_Member__c,Memmership_ATA__c,Type_of__c,'
                        +'Account_code_secondary_flag__c,Airline_Prefix__c,IATA_ISO_Country__c,ACLI_Status__c,'
                        +'MITA_Member__c,ACLI_SAP_Id__c,AOC_Expiry_Date__c,Membership_status__c'
                        +'\r\n';
            return fline;

    }
    public static String lineOfAcliFromACct(Account a){
            try{
                string  backUpAcct = '"';
                        backUpAcct +=     a.ID <> null ?   string.valueOf(a.ID) : '' ;
                        backUpAcct += '","' ;
                        backUpAcct +=    a.Name_on_AOC__c <> null ?   a.Name_on_AOC__c  : ''  ;
                        backUpAcct += '","' ;
                        backUpAcct +=   a.IATACode__c <> null ?   a.IATACode__c : '';
                        backUpAcct +=  '","' ;
                        backUpAcct +=    a.Airline_designator__c <> null ?   a.Airline_designator__c : ''  ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.ICAO_designator__c <> null ?  a.ICAO_designator__c : ''   ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.billingStreet <> null ?   a.billingStreet: '' ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.billingCity <> null ? a.billingCity: ''  ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.billingState <> null ? a.billingState: '' ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.billingCountry <> null ? a.billingCountry: ''  ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.billingPostalCode <> null ? a.billingPostalCode: '' ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.Membership_SITA__c == true? 'true' : 'false'     ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.Memmership_ARINC__c == true? 'true' : 'false'    ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.IATA_Member__c  == true? 'true' : 'false'  ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.Memmership_ATA__c  == true ? 'true' : 'false'   ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.Type_of__c <> null ? a.Type_of__c: ''  ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.Account_code_secondary_flag__c <> null ? a.Account_code_secondary_flag__c: ''  ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.Airline_Prefix__c <> null ? a.Airline_Prefix__c: '' ;
                        backUpAcct +='","' ;
                        backUpAcct +=    a.IATA_ISO_Country__c<> null? string.valueOf(a.IATA_ISO_Country__c): ''  ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.ACLI_Status__c <> null ? a.ACLI_Status__c: ''   ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.ACLI_SAP_Id__c <> null ? a.ACLI_SAP_Id__c: ''   ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.AOC_Expiry_Date__c <> null ? String.valueOf(a.AOC_Expiry_Date__c) : ''   ;
                        backUpAcct +='","' ;
                        backUpAcct +=   a.Membership_status__c <> null ? String.valueOf(a.Membership_status__c) : ''   ;
                        backUpAcct +=  '"\r\n' ;

                        system.debug('### generating lineOfAcliFromACct: ' + backUpAcct);

                return backUpAcct;

                }catch(Exception e){
                    system.debug('### backup generation error: ' + e.getmessage() + ' - ' + e.getStackTraceString());
                    throw new transformationException( ' ' + e.getmessage() + e.getStackTraceString() );

                    return null;
                }

        }

}