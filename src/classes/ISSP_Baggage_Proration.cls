public without sharing class ISSP_Baggage_Proration {

    private static Integer HISTORY_NUMBER_OF_MONTHS = Integer.valueOf(ISSP_CS__c.getValues('Baggage History - Number Of Months').Value__c)*(-1);
    private static final String AGENTID = 'BREANDAN';
    private static final String RECORDTYPE = 'ON-HAND';
    
    public String con { get; set; }

    //public List<PIR_Form__c> formList {get; set;}
    public List<Baggage_Claim_Comment__c> commentList {get; set;}
    public List<PIR_Form__c> PIR_List {get;set;}
    public List<Baggage_Claim__c> PIRClaim_List {get;set;}
    public List<Baggage_Claim_Comment__c> PIRComment_List {get;set;}
    public List<Flight_Information__c> Flight_Information_List {get;set;}
    public List<PIR_Bag_Information__c> Bag_Information_List {get;set;}
    public List<AmazonFile__c> attach_List {get;set;}
    
    public String PIRId { get; set; }
    public String PIRClaimId { get; set; }
    public String PIRCommentId { get; set; }
    
    public PIR_Form__c PIR {get;set;}
    public Baggage_Claim__c PIRClaim {get;set;}
    public Baggage_Claim_Comment__c PIRComment {get;set;}
    
    public Boolean isEdit {get; set;}
    public Boolean allowEdit {get; set;}
    public Boolean isNew {get; set;}
    public Boolean isValidRef {get; set;}
    

    public String segmentSelectedNum {get; set;}
    
    private String sortDirection = 'ASC';
    private String sortExp  = 'CreatedDate';
    private String claimsSortDirection = 'ASC';
    private String claimsSortExp  = 'Name'; 
    public string selectedList {get;set;} 
    public map<string,ISSP_Baggage_Claim_List_View__c> listViewMap {get;set;} 
    public list<string> ListViewNameList {get;set;}

    public Account AirlineAccount {get;set;}
    public string airlineCode {get;set;}
    public string airlineIssuingCode;
    public string stationCode = 'ATL';
    public string PIR_Ref {get;set;}

    public string proceedToPaymentDate {get; set;}

    public static final String EXAMPLE_RESPONSE = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'
            +'<WTR_ReadRecordRS xmlns="http://sita.aero/WTR_ReadRecordRS/7/0" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">'
                +'<WTR_DelayedBagRecReadRS xmlns="http://sita.aero/WTR_DelayedBagRecReadRS/7/0" xmlns:common="http://sita.aero/wtr/common/7/0" Version="0.1">'
                    +'<Success/>'
                    +'<DiaryInfo>'
                        +'<common:CreateDate>2016-06-17T14:26:00+00:00</common:CreateDate>'
                        +'<common:TracingDate>2016-06-17T00:00:00+00:00</common:TracingDate>'
                        +'<common:ControllingStation>ATL</common:ControllingStation>'
                    +'</DiaryInfo>'
                    +'<kuku2>haha!</kuku2>'
                    +'<DelayedBagGroup>'
                        +'<common:DelayedBags>'
                            +'<common:DelayedBag Seq="1">'
                                +'<common:ColorTypeDesc Suspended="false">'
                                    +'<common:ColorCode>BK</common:ColorCode>'
                                    +'<common:TypeCode>1</common:TypeCode>'
                                    +'<common:Descriptor>'
                                        +'<common:MtrlElement>T</common:MtrlElement>'
                                        +'<common:OtherElement>K</common:OtherElement>'
                                        +'<common:OtherElement>W</common:OtherElement>'
                                    +'</common:Descriptor>'
                                +'</common:ColorTypeDesc>'
                                +'<common:BagTag Suspended="false">'
                                    +'<common:AirlineCode>XS</common:AirlineCode>'
                                    +'<common:TagSequence>123456</common:TagSequence>'
                                +'</common:BagTag>'
                            +'</common:DelayedBag>'
                            +'<common:DelayedBag Seq="2">'
                                +'<common:ColorTypeDesc Suspended="false">'
                                    +'<common:ColorCode>BK</common:ColorCode>'
                                    +'<common:TypeCode>1</common:TypeCode>'
                                    +'<common:Descriptor>'
                                        +'<common:MtrlElement>T</common:MtrlElement>'
                                        +'<common:OtherElement>K</common:OtherElement>'
                                        +'<common:OtherElement>W</common:OtherElement>'
                                    +'</common:Descriptor>'
                                +'</common:ColorTypeDesc>'
                                +'<common:BagTag Suspended="false">'
                                    +'<common:AirlineCode>XS</common:AirlineCode>'
                                    +'<common:TagSequence>123457</common:TagSequence>'
                                +'</common:BagTag>'
                            +'</common:DelayedBag>'
                        +'</common:DelayedBags>'
                        +'<common:BaggageItinerary>'
                            +'<common:FlightDateOrARNK>'
                                +'<common:FlightDate>'
                                    +'<common:AirlineCode>XS</common:AirlineCode>'
                                    +'<common:FlightNumber>456</common:FlightNumber>'
                                    +'<common:Date>2016-06-17</common:Date>'
                                +'</common:FlightDate>'
                            +'</common:FlightDateOrARNK>'
                        +'</common:BaggageItinerary>'
                    +'</DelayedBagGroup>'
                    +'<Passengers>'
                        +'<common:Names>'
                            +'<common:Name Seq="1">BREANDAN</common:Name>'
                            +'<common:Name Seq="2">Lastname</common:Name>'
                        +'</common:Names>'
                        +'<common:Initials>'
                            +'<common:Intial Seq="1">B</common:Intial>'
                        +'</common:Initials>'
                        +'<common:Title>MR</common:Title>'
                        +'<common:ContactInfo>'
                            +'<common:PermanentAddress>'
                                +'<common:AddressLine Seq="1">ADDRESS</common:AddressLine>'
                                +'<common:Country Code="IR"/>'
                            +'</common:PermanentAddress>'
                            +'<common:CellPhones>'
                                +'<common:Phone Seq="1">12345678910</common:Phone>'
                            +'</common:CellPhones>'
                            +'<common:Emails>'
                                +'<common:Email Seq="1">TESTMAIL@SITA.AERO</common:Email>'
                            +'</common:Emails>'
                            +'<common:Country>'
                                +'<common:CountryCode>IR</common:CountryCode>'
                            +'</common:Country>'
                        +'</common:ContactInfo>'
                        +'<common:AutoMsgOption>EMAIL</common:AutoMsgOption>'
                        +'<common:Itinerary>'
                            +'<common:FlightSegments>'
                                +'<common:Flight>'
                                    +'<common:FlightSegment>'
                                        +'<common:FlightAndDate>'
                                            +'<common:AirlineCode>XS</common:AirlineCode>'
                                            +'<common:FlightNumber>951</common:FlightNumber>'
                                            +'<common:Date>2016-06-17</common:Date>'
                                        +'</common:FlightAndDate>'
                                        +'<common:OriginDestination>'
                                            +'<common:Origin>ATL</common:Origin>'
                                            +'<common:Destination>DUB</common:Destination>'
                                        +'</common:OriginDestination>'
                                    +'</common:FlightSegment>'
                                    +'<common:FlightSegment>'
                                        +'<common:FlightAndDate>'
                                            +'<common:AirlineCode>XS</common:AirlineCode>'
                                            +'<common:FlightNumber>952</common:FlightNumber>'
                                            +'<common:Date>2017-05-17</common:Date>'
                                        +'</common:FlightAndDate>'
                                        +'<common:OriginDestination>'
                                            +'<common:Origin>ATL</common:Origin>'
                                            +'<common:Destination>USA</common:Destination>'
                                        +'</common:OriginDestination>'
                                    +'</common:FlightSegment>'
                                +'</common:Flight>'
                            +'</common:FlightSegments>'
                            +'<common:AdditionalRoutes>'
                                +'<common:Route>JFK</common:Route>'
                            +'</common:AdditionalRoutes>'
                        +'</common:Itinerary>'
                    +'</Passengers>'
                    +'<SMSInfo>'
                        +'<Text Seq="1">17JUN/1426GMT /XS /1708031/FROM AUTO SMS/CP 12345678910/'
                        +'From: MAHESH / 1 Bag(s) missed flight / File Reference:'
                        +'ATLXS10703 / Name on Record: BREANDAN / Please Check with'
                        +'Baggage Service Office</Text>'
                    +'</SMSInfo>'
                    +'<EmailInfo>'
                        +'<Text Seq="1">17JUN/1426GMT XS TESTMAIL/A/SITA/D/AERO'
                            +'Dear Customer'
                            +'This message is system generated automatically.'
                            +'Please do not reply to this e-mail.'
                            +'From: MAHESH / 1 Bag(s) missed flight / File Reference:'
                            +'ATLXS10703 / Name on Record: BREANDAN / Please Check with'
                            +'Baggage Service Office'
                            +'Please check the status of your bag online at:'
                            +'http://SITA.COM</Text>'
                        +'<Text Seq="2">17JUN/1530GMT XS TESTMAIL/A/SITA/D/AERO'
                            +'Dear Customer'
                            +'This message is system generated automatically.'
                            +'Please do not reply to this e-mail.'
                            +'FROM XS FILE REF ATLXS10703 To help locate your item'
                            +'faster. Please complete the inventory form.  For details'
                            +'visit our website and view your file or call the airline.'
                            +'Please check the status of your bag online at:'
                            +'http://SITA.COM</Text>'
                    +'</EmailInfo>'
                    +'<RecordHistory>'
                        +'<common:History>AHL  17JUN/1426GMT AG A FROM WWS WT BY XS</common:History>'
                        +'<common:History>SMS  17JUN/1426GMT /XS /1708031/FROM AUTO SMS/CP 12345678910/'
                             +'From: MAHESH / 1 Bag(s) missed flight / File Reference:'
                             +'ATLXS10703 / Name on Record: BREANDAN / Please Check with'
                             +'Baggage Service Office</common:History>'
                        +'<common:History>SEA  17JUN/1426GMT /XS/ FROM AUTO SEA/ SE TESTMAIL/A/SITA/D/AERO'
                             +'Dear Customer'
                             +'This message is system generated automatically.'
                             +'Please do not reply to this e-mail.'
                             +'From: MAHESH / 1 Bag(s) missed flight / File Reference:'
                             +'ATLXS10703 / Name on Record: BREANDAN / Please Check with'
                             +'Baggage Service Office'
                             +'Please check the status of your bag online at:'
                             +'http://SITA.COM</common:History>'
                        +'<common:History>SMS  17JUN/1426GMT /XS /1708031/STATUS/'
                            +'UNDELIVERABLE: PHONE NUMBER INCORRECT</common:History>'
                        +'<common:History>SEA  17JUN/1530GMT /XS/ FROM AUTO SEA/ SE TESTMAIL/A/SITA/D/AERO'
                             +'Dear Customer'
                             +'This message is system generated automatically.'
                             +'Please do not reply to this e-mail.'
                             +'FROM XS FILE REF ATLXS10703 To help locate your item'
                             +'faster. Please complete the inventory form.  For details'
                             +'visit our website and view your file or call the airline.'
                             +'Please check the status of your bag online at:'
                             +'http://SITA.COM</common:History>'
                        +'<common:MatchHistory>1   MCH  17JUN/1430 OHD ATLXS10179   TAG MATCH</common:MatchHistory>'
                        +'<common:MatchHistory>2   MCH  17JUN/1430 OHD ATLXS10181   TAG MATCH</common:MatchHistory>'
                        +'<common:MatchHistory>3   MCH  17JUN/1430 OHD ATLXS10333   TAG MATCH</common:MatchHistory>'
                        +'<common:MatchHistory>-   MCH  17JUN/1433 MATCH ON DELAY</common:MatchHistory>'
                        +'<common:MatchHistory>4  MCH  19JUN/0827 OHD ATLXS10333   - 72 TN/CT/FD/RT ATL</common:MatchHistory>'
                        +'<common:MatchHistory>5  MCH  20JUN/1351 OHD ATLXS10340   - 68 TN/CT/RT ATL</common:MatchHistory>'
                    +'</RecordHistory>'
                    +'<RecordStatus>OPEN</RecordStatus>'
                +'</WTR_DelayedBagRecReadRS>'
            +'</WTR_ReadRecordRS>';
    
    //////////////////
    public class DatePicker 
    {
        public String datename {get; set;}
    }
    //////////////////////////
    
    public ISSP_Baggage_Proration(){

    }
    
    public PageReference pageLoad_List(){
        //formList = [SELECT Id, Name, Airline_issuing__c, Airport_Arrival__c, 
        //Passenger_s_First_Name__c, Last_Name__c, PIR_File_Ref__c, Amount__c FROM PIR_Form__c];
        return null;
    }
    
    public List<PIR_Form__c> formList{
        get{
        system.debug('getting form list');
        List<PIR_Form__c> allForms = (List<PIR_Form__c>)setConForm.getRecords();
        return allForms;
        }
        set;
    }
    

    @AuraEnabled (cacheable=false)    
    public static List<PIR_Form__c> getPIRFormList(){
        system.debug('getFormList - init');
        ISSP_Baggage_Proration bp = new ISSP_Baggage_Proration();
        ApexPages.StandardSetController auxSetConForm = bp.setConForm;
        system.debug('getFormList - getting form list');
        
        List<PIR_Form__c> allForms = (List<PIR_Form__c>)auxSetConForm.getRecords();
        system.debug('getFormList - allForms: ' + allForms);
        
        return allForms;
    }

    public ApexPages.StandardSetController setConForm {
        get{
            system.debug('getting setConForm');
            if(setConForm == null){
                Set<Id> nonExpiredPirFormIds = new Set<Id>();
                Datetime expirationDate = system.now().addMonths(HISTORY_NUMBER_OF_MONTHS);
                List<PIR_Form__c>  pirFormsList = [SELECT Id, (SELECT Id, Date_Time_Proceed_to_payment__c FROM Baggage_Claims__r) FROM PIR_Form__c WHERE Is_Archived__c = false Limit 50000];
                for(PIR_Form__c pirForm :pirFormsList){
                    if (pirForm.Baggage_Claims__r.size()==0)
                        nonExpiredPirFormIds.add(pirForm.Id);
                    else{
                        for(Baggage_Claim__c baggageClaim : pirForm.Baggage_Claims__r){
                            if (baggageClaim.Date_Time_Proceed_to_payment__c == null || baggageClaim.Date_Time_Proceed_to_payment__c >= expirationDate){
                                nonExpiredPirFormIds.add(pirForm.Id);
                                break;
                            }
                        }
                    }
                }
                size = 50;
                List <User> userList = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
                Set <Id> accountIds = new Set <Id>();

                if (!userList.isEmpty()){
                    String contactId = userList[0].ContactId;
                    system.debug('contactId:' + contactId);
                    if (contactId != null && contactId != ''){
                        List <Contact> contactList = [SELECT Id, AccountId, Account.Top_Parent__c
                                                    FROM Contact WHERE Id = :contactId];
                        system.debug('contactList: '+contactList);
                        if (!contactList.isEmpty()){
                            system.debug('accountId:' + contactList[0].AccountId);
                            system.debug('topAccountId:' + contactList[0].Account.Top_Parent__c);
                            if (contactList[0].AccountId != null){
                                system.debug('adding accountId');
                                accountIds.add(contactList[0].AccountId);
                            }
                            if (contactList[0].Account.Top_Parent__c != null){
                                system.debug('adding topAccountId');
                                accountIds.add(contactList[0].Account.Top_Parent__c);
                            }
                            if (!accountIds.isEmpty()){

                                String theQuery = 'SELECT Id, Name, Airline_issuing__c, Created_Date_Formated__c, Airport_Arrival__c, Airline_Code__c, Passenger_s_First_Name__c, Last_Name__c, PIR_Currency_of_conversion__c, CreatedDate, PIR_File_Ref__c, Amount__c, Airline_issuing__r.Name';
                                theQuery = theQuery + ' FROM PIR_Form__c';
                                theQuery = theQuery + ' WHERE Id IN :nonExpiredPirFormIds'; 
                                theQuery = theQuery + ' AND Airline_issuing__c in :accountIds';
                                if (sortExpression != null && sortExpression != ''){
                                    theQuery = theQuery + ' ORDER BY ' + sortExpression + ' ' + sortDirection + ' NULLS LAST LIMIT 10000';
                                }
                                system.debug('QUERY FORM: ' + theQuery);
                                setConForm = new ApexPages.StandardSetController(Database.getQueryLocator(theQuery));
                                system.debug('setConForm: ' + setConForm);
                                setConForm.setPageSize(size);
                                noOfRecords = setConForm.getResultSize();
                            }
                        }
                    }
                }
            }
            return setConForm;
        }set;
    }
    
    // ++ claim list page
    public PageReference pageLoad_ClaimList(){
        initClaimList();
        return null;
    }
    
    public class listViewAux {
        @AuraEnabled List<String> listViewValues {get;set;}
        @AuraEnabled map<string,ISSP_Baggage_Claim_List_View__c> mapListView {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static listViewAux getListViewNameList() {
        List <ISSP_Baggage_Claim_List_View__c> csListViews = ISSP_Baggage_Claim_List_View__c.getAll().values();
        listViewAux result = new listViewAux();
        result.listViewValues = new list<string>();
        result.mapListView = new map<string,ISSP_Baggage_Claim_List_View__c>();
        for(ISSP_Baggage_Claim_List_View__c listViewItem : csListViews) {
            result.mapListView.put(listViewItem.Name,listViewItem);
            result.listViewValues.add(listViewItem.Name);
        }
        result.listViewValues.sort();
        return result;
    }

    @AuraEnabled (cacheable=true)    
    public static List<Baggage_Claim__c> getRequests(string selectedValue, map<string,ISSP_Baggage_Claim_List_View__c> mapListView, string sortExpression, string sortDirection){
        System.debug('selectedValue: ' +selectedValue);
        ISSP_Baggage_Proration bp = new ISSP_Baggage_Proration();
        bp.selectedList = selectedValue;
        bp.listViewMap = mapListView;
        if (!string.isBlank(sortExpression)) {
            bp.sortExpression = sortExpression;
        }
        if (!string.isBlank(sortDirection)) {
            bp.sortDirection = sortDirection;
        }
        ApexPages.StandardSetController auxSetCon = bp.setCon;
        List<Baggage_Claim__c> allRecords = (List<Baggage_Claim__c>)auxSetCon.getRecords();
        return allRecords;
    }

    public void initClaimList(){
        List <ISSP_Baggage_Claim_List_View__c> csListViews = ISSP_Baggage_Claim_List_View__c.getAll().values();
        ListViewNameList = new list<string>();
        listViewMap = new map<string,ISSP_Baggage_Claim_List_View__c>();
        for(ISSP_Baggage_Claim_List_View__c listViewItem : csListViews){
            listViewMap.put(listViewItem.Name,listViewItem);
            ListViewNameList.add(listViewItem.Name);
        }
        ListViewNameList.sort();
        selectedList = ListViewNameList.get(0);
    }
    
    public List<Baggage_Claim__c> getClaimList(){
        system.debug('getting claim list');   
        List<Baggage_Claim__c> allClaims = (List<Baggage_Claim__c>)setCon.getRecords();
        return allClaims;
    }
    
    public Integer noOfRecords{get; set;}
    public Integer size{get;set;}
    public ApexPages.StandardSetController setCon {
        get{
            system.debug('getting setcon');
            system.debug('on setcon:' + selectedList);
            System.debug('setCon: ' +setCon);
            if(setCon == null){
                size = 50;
                List <User> userList = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
                Set <Id> accountIds = new Set <Id>();
                String theQuery = 'SELECT CreatedDate';
                for(Schema.FieldSetMember f : this.getBaggageFields()) {
                    theQuery +=  ', '+f.getFieldPath() ;
                }
                theQuery +=  ', '+'PIR_Currency__c';
                theQuery = theQuery + ' FROM Baggage_Claim__c';
                if (!userList.isEmpty()){
                    String contactId = userList[0].ContactId;
                    system.debug('contactId:' + contactId);
                    if (contactId != null && contactId != ''){
                        List <Contact> contactList = [SELECT Id, AccountId, Account.Top_Parent__c
                                                    FROM Contact WHERE Id = :contactId];
                        system.debug('contactList: '+contactList);
                        if (!contactList.isEmpty()){
                            system.debug('accountId:' + contactList[0].AccountId);
                            system.debug('topAccountId:' + contactList[0].Account.Top_Parent__c);
                            if (contactList[0].AccountId != null){
                                system.debug('adding accountId');
                                accountIds.add(contactList[0].AccountId);
                            }
                            if (contactList[0].Account.Top_Parent__c != null){
                                system.debug('adding topAccountId');
                                accountIds.add(contactList[0].Account.Top_Parent__c);
                            }
                            if (!accountIds.isEmpty()){
                                System.debug('listViewMap: ' +listViewMap);
                                System.debug('selectedList: ' +selectedList);
                                if (listViewMap.containsKey(selectedList)){
                                    system.debug('is list: ' + listViewMap.get(selectedList).Name);
                                    if (listViewMap.get(selectedList).SOQL_Filter__c != null){
                                        theQuery = theQuery + ' ' + listViewMap.get(selectedList).SOQL_Filter__c + ' :accountIds';
                                        theQuery = theQuery + ' AND ';
                                    }
                                    else
                                        theQuery = theQuery + ' WHERE ';
                                    system.debug('sortExpression: ' + sortExpression);
                                    system.debug('sortDirection: ' + sortDirection);
                                    Datetime expirationDate = system.now().addMonths(HISTORY_NUMBER_OF_MONTHS);
                                    String formatedExpDt = expirationDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                                    theQuery = theQuery + '(Date_Time_Proceed_to_payment__c = null OR Date_Time_Proceed_to_payment__c >= '+ formatedExpDt +')';
                                    if (sortExpression != null && sortExpression != ''){
                                        theQuery = theQuery + ' ORDER BY ' + sortExpression + ' ' + sortDirection + ' NULLS LAST LIMIT 10000';
                                    }
                                    system.debug('theQuery '+theQuery);
                                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(theQuery));
                                    setCon.setPageSize(size);
                                    noOfRecords = setCon.getResultSize();
                                }
                            }
                        }
                    }
                }
            }
            return setCon;
        }set;
    }
    
    public Pagereference refresh(){ 
        system.debug('selectedList: ' + selectedList);
        setCon = null;
        return null;
    }
    
    public Pagereference refreshFormList(){ 
        setConForm = null;
        return null;
    }
    
    public List<Schema.FieldSetMember> getBaggageFields() {
        return selectedList==null||selectedList==''?
        new list<Schema.FieldSetMember>():
        sObjectType.Baggage_Claim__c.FieldSets.getMap().get(listViewMap.get(selectedList).Field_Set_API_Name__c).getFields();
    }
    
    public String sortExpression {
        get { return sortExp; }
        set {
            if (value == sortExp){
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            }
            else{
                sortDirection = 'ASC';
            }
            sortExp = value;
        }
    }
    
    public String getSortDirection() { 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value) {  
        sortDirection = value;
    }

    public String claimsSortExpression {
        get { return claimsSortExp; }
        set {
            if (value == claimsSortExp){
                claimsSortDirection = (claimsSortDirection == 'ASC')? 'DESC' : 'ASC';
            }
            else{
                claimsSortDirection = 'ASC';
            }
            claimsSortExp = value;
        }
    }
    
    public String getClaimsSortDirection() { 
        if (claimsSortExpression == null || claimsSortExpression == '')
            return 'ASC';
        else
            return claimsSortDirection;
    }
    
    public void setClaimsSortDirection(String value) {  
        claimsSortDirection = value;
    }
    // -- claim list page
    
    //public PageReference pageLoad_Form(){
    // public static PIR_Form__c getPIRForm(string recid){
    @AuraEnabled (cacheable=false)    
    public static PIRFromWrapper getPIRForm(string recid){
        
      
        // isEdit = false;
        Boolean isEdit = false;
        // allowEdit = false;
        Boolean allowEdit = false;
        // sortExpression = 'Name';
        String sortExpression = 'Name';
        // PIR = new PIR_Form__c();
        PIR_Form__c PIR = new PIR_Form__c();
        // PIRId = Apexpages.currentPage().getParameters().get('id');
        String PIRId = recid;
        // string action = Apexpages.currentPage().getParameters().get('action');
        string action = 'edit';

        Boolean isNew = false;

        List<PIR_Form__c> PIR_List;
        List<Flight_Information__c> Flight_Information_List;
        List<PIR_Bag_Information__c> Bag_Information_List;
        String airlineIssuingCode;
        Account pirAccount;

        if (PIRId != null && PIRId != ''){
            // isNew = false;
            
            List <UserRecordAccess> shareList = [SELECT RecordId, HasEditAccess FROM UserRecordAccess
                                            WHERE UserId = :UserInfo.getUserId() AND RecordId = :PIRId];
            system.debug('shareList: ' + shareList);
            if (!shareList.isEmpty()){
                system.debug('accesslevel: ' + shareList[0].HasEditAccess);
                if (shareList[0].HasEditAccess == true){
                    allowEdit = true;
                    if (action == 'edit'){
                        isEdit = true;
                    }
                }
            }
            
            PIR_List = new List<PIR_Form__c >([select id , Name , Airline_issuing__c, Airport_Arrival__c, Airline_Code__c, Amount__c,
                                          Email_Prorate_Dept_Airline_issuing__c, CreatedDate, Created_Date_Formated__c,PIR_File_Type__c,
                                          Passenger_s_First_Name__c,Passenger_s_initials__c, Last_Name__c, 
                                          PIR_File_Ref__c,PIR_Currency_Claim__c,PIR_Passenger_Claim_Amount__c,
                                          Title__c, CurrencyIsoCode, Airline_issuing__r.Name,PIR_Currency_of_conversion__c,
                                          CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name
                                                   From PIR_Form__c
                                                   Where Id =: PIRId ]);
                                                   
            if(PIR_List != null && PIR_List .size() > 0){
                PIR = PIR_List [0];
              
                Flight_Information_List = new List<Flight_Information__c >([select id, Name, PIR_Flight_Date_Formated__c,
                                                PIR_Airline__c, PIR_Ref__c,PIR_Amount_Due__c,To__c,
                                                PIR_Flight_Date__c,PIR_Flight_Number__c,PIR_From__c,Currency__c,
                                                PIR_Percentage__c,PIR_Segment_1__c,PIR_Ticket_Number__c,PIR_Miles__c
                                                From Flight_Information__c
                                                Where PIR_Ref__c =: PIRId 
                                                Order By PIR_Segment_1__c]);
                                               
                
                Bag_Information_List = new List<PIR_Bag_Information__c >([select id, Name,
                                                Bag_Number__c,Bag_Tag_Number__c,PIR_Color__c,PIR_Form__c,Type__c
                                                From PIR_Bag_Information__c
                                                Where PIR_Form__c =: PIRId 
                                                Order By Bag_Number__c]);

                
                for(Integer i=1 ;i<11 ;i++){
                    System.debug('i: '+i);
                    if(i<5 && Flight_Information_List.size()<i){
                        Flight_Information_List.add(new Flight_Information__c(PIR_Segment_1__c = String.valueOf(i), PIR_Ref__c = PIRId));
                    }
                    else if(i<5 && Flight_Information_List[i-1].PIR_Flight_Date__c != null){
                        Datetime flightDateTime = datetime.newInstance(Flight_Information_List[i-1].PIR_Flight_Date__c.year(), Flight_Information_List[i-1].PIR_Flight_Date__c.month(),Flight_Information_List[i-1].PIR_Flight_Date__c.day());
                        Flight_Information_List[i-1].PIR_Flight_Date_Formated__c = getFormatedDate(flightDateTime);
                    }

                    if(Bag_Information_List.size()<i){
                        Bag_Information_List.add(new PIR_Bag_Information__c(Bag_Number__c = String.valueOf(i), PIR_Form__c = PIRId));
                    }
                }

                system.debug('Flight_Information_List '+Flight_Information_List);
                system.debug('Bag_Information_List '+Bag_Information_List);
                
            }
        }
        else{
            List <User> userList = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            if (!userList.isEmpty()){
                String contactId = userList[0].ContactId;
                if (contactId != null && contactId != ''){
                    List <Contact> contactList = [SELECT Id, AccountId FROM Contact WHERE Id = :contactId];
                    if (!contactList.isEmpty()){
                        PIR.Airline_issuing__c = contactList[0].AccountId;
                    }
                }
            }
            isEdit = true;
            isNew = true;
            allowEdit = true;
        }

        if (PIR.Airline_issuing__c != null){
            List <Account> accountList = [SELECT Id, Airline_designator__c, Name FROM Account WHERE Id = :PIR.Airline_issuing__c];
            if (!accountList.isEmpty()){
                airlineIssuingCode = accountList[0].Airline_designator__c;
                pirAccount = accountList[0];
            }
        }

        List<Baggage_Claim__c> PIRClaims = new List<Baggage_Claim__c>();
        if(PIR_List != null && PIR_List .size() > 0){ 
                PIRClaims = Database.query(
                                ' select id, Parent_PIR_Form__c, Status__c,'+
                                ' Airline_receiving__c, Name, Airline_issuing__c,'+
                                ' Is_Segment_1_Selected__c,Is_Segment_4_Selected__c,Is_Bag_1_Selected__c,Is_Bag_2_Selected__c,Is_Bag_3_Selected__c,'+
                                ' Is_Bag_4_Selected__c,Is_Bag_5_Selected__c,Is_Bag_6_Selected__c,Is_Bag_7_Selected__c,Is_Bag_8_Selected__c,Is_Bag_9_Selected__c,'+
                                ' Is_Bag_10_Selected__c,X2_letter_Airline_Code__c,Airline_receiving_name__c,PIR_Currency__c,PIR_File_Ref__c,'+
                                ' Parent_PIR_Form__r.Amount__c,Parent_PIR_Form__r.PIR_Currency_of_conversion__c,Parent_PIR_Form__r.PIR_Currency_Claim__c,'+
                                ' Parent_PIR_Form__r.PIR_Passenger_Claim_Amount__c,PIR_Total_Prorated_Amount_Due__c,PIR_Request_Sent_Date__c,Passenger_s_First_Name__c,'+
                                ' Days_to_Go_vs_60_Day_Limit__c,Request_Sent_Date_Formated__c,Passenger_s_Last_Name__c'+
                                ' From Baggage_Claim__c'+
                                ' Where Parent_PIR_Form__c = :PIRId'
                            );
        }

        List<Baggage_Claim_Comment__c> PIRComment = new List<Baggage_Claim_Comment__c>();
        if(PIR_List != null && PIR_List .size() > 0){
                PIRComment   = Database.query(
                                                ' SELECT id, PIR_File_Ref__c,'+
                                                ' Baggage_Claim__c, Baggage_Claim__r.Name, Name,'+
                                                ' Baggage_Claim__r.Parent_PIR_Form__c, Baggage_Claim__r.Parent_PIR_Form__r.Name,'+
                                                ' Comments__c, Account__c, CreatedBy.Name, CreatedDate'+
                                                ' From Baggage_Claim_Comment__c'+
                                                ' Where Baggage_Claim__r.Parent_PIR_Form__c = :PIRId'                       
                                            );
        }

        PIRFromWrapper pirFormWrap;
        if (PIRId != null && PIRId != ''){
            pirFormWrap = new PIRFromWrapper(PIR, pirAccount, Flight_Information_List, Bag_Information_List, PIRClaims, PIRComment ); 
        }else{
            PIR_Form__c auxPIR = new PIR_Form__c();
            List<Flight_Information__c> auxFlight_Information_List = new List<Flight_Information__c>();
            List<PIR_Bag_Information__c> auxBag_Information_List = new List<PIR_Bag_Information__c>();
           
            pirFormWrap = new PIRFromWrapper(PIR, pirAccount, auxFlight_Information_List, auxBag_Information_List, PIRClaims, PIRComment ); 
        }

        // return null;
        // return PIR_List[0];
        return pirFormWrap;
    }

    public PageReference fetchPirFormInfo() {
        isValidRef = false;
        if(PIR_Ref == null || PIR_Ref == '')
            return null;
        if(airlineIssuingCode == null || airlineIssuingCode.length() != 2)
            return null;

        Integer statusCode = ISSP_WS_WorldTracer.readBaggageInformation(new ISSP_WS_WorldTracer.requestInfo(RECORDTYPE, PIR_Ref, airlineIssuingCode, stationCode, AGENTID));
        if(statusCode == 200)
            isValidRef = true;

        return null;
    }


    public PageReference fetchAirlineAccountDetails() {
        String qAirlineCode;
        AirlineAccount = new Account();

        if(airlineCode == null || airlineCode.length() != 2)
            return null;

        qAirlineCode = airlineCode + '%';

        List<Account> airlineaccounts = ISSP_Utilities.getAirlineAccounts(qAirlineCode);

        System.debug('qAirlineCode '+qAirlineCode);
        if(airlineaccounts.size() > 0 ){ 
            AirlineAccount = airlineaccounts[0];
            PIRClaim.Airline_receiving__c = AirlineAccount.Id;
            PIRClaim.Airline_receiving_name__c = AirlineAccount.Name;
        } 

        return null;


    }
    

    // public PageReference CalloutforWS(){
    //     ClearFormForNewCallout();
    //     // AutoFillData();
    //     return null;
    // }

    // public void ClearFormForNewCallout(){
    //     if(Flight_Information_List != null){
    //         Flight_Information_List.clear();
    //     }
    //     if(Bag_Information_List != null){
    //         Bag_Information_List.clear();
    //     }
    //     PIR.Passenger_s_First_Name__c = '';
    //     PIR.Last_Name__c='';
    //     PIR.Title__c = '';
    // }
    // Added by OA
    /**
     * [parseXMLResponse description]
     * @author Ofir A.
     * @param -
     * @return nothing
     * @Description this function use member data from this class (PIR.PIR_File_Ref__c)
     * and send it as SOAP request.
     */
    //public PageReference AutoFillData(){
    @AuraEnabled (cacheable=false)    
    public static PIRFromWrapper AutoFillData(PIR_Form__c PIR){

        System.debug('PIR='+PIR);
        ISSP_Baggage_Proration bp = new ISSP_Baggage_Proration();

        bp.PIR = PIR;
        PIRFromWrapper wrapper;

        System.debug('PIR.PIR_File_Ref__c='+bp.PIR.PIR_File_Ref__c);
        if ( !String.isBlank(bp.PIR.PIR_File_Ref__c) ) { 
            //call nettracer if PIR file ref lenght == 9
            if(bp.PIR.PIR_File_Ref__c.length()==8){
                //working example for nettracer:  fillIncidentInformation('CB'+ 'SB' + '600003295', 'DAMAGED');
                wrapper = bp.fillIncidentInformation(bp.PIR.Airport_Arrival__c + bp.PIR.Airline_Code__c + bp.PIR.PIR_File_Ref__c, bp.PIR.PIR_File_Type__c);
                system.debug('##: '+bp.PIR.Airport_Arrival__c + bp.PIR.Airline_Code__c + bp.PIR.PIR_File_Ref__c+' - '+ bp.PIR.PIR_File_Type__c);

            // else call SITA webtracer    
            }else if (bp.PIR.PIR_File_Ref__c.length()==5){

      
                 String xmlBodyReqSigned = '<soapenv:Envelope xmlns:hal="http://sita.aero/hal" xmlns:ns="http://sita.aero/WTR_ReadRecordRQ/9/0" xmlns:ns1="http://www.iata.org/IATA/2007/00" xmlns:ns2="http://sita.aero/wtr/common/9/0" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header><wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"></wsse:Security></soapenv:Header>'+
                //signHeader+
                
                    '<soapenv:Body xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
                        
                        '<wtr:WTR_ReadRecordRQ Version="0.1" xmlns:iata="http://www.iata.org/IATA/2007/00" xmlns:wtr="http://sita.aero/WTR_ReadRecordRQ/8/0" xmlns:common="http://sita.aero/wtr/common/8/0">'+
                        // '<wtr:WTR_ReadRecordRQ Version="0.1" xmlns:iata="http://www.iata.org/IATA/2007/00" xmlns:wtr="http://sita.aero/WTR_ReadRecordRQ/9/0" xmlns:common="http://sita.aero/wtr/common/9/0">'+
                                        
                            '<wtr:POS>'+
                                '<iata:Source AirlineVendorID="'+bp.PIR.Airline_Code__c+'"/>'+
                            '</wtr:POS>'+
                            '<wtr:RecordID>'+
                                '<common:RecordType>'+bp.PIR.PIR_File_Type__c+'</common:RecordType>'+
                                '<common:RecordReference AirlineCode="'+bp.PIR.Airline_Code__c+'" ReferenceNumber="'+bp.PIR.PIR_File_Ref__c+'" StationCode="'+bp.PIR.Airport_Arrival__c+'" />'+
                            '</wtr:RecordID>'+
                                '<wtr:AgentID>TESTAGNT</wtr:AgentID>'+
                        '</wtr:WTR_ReadRecordRQ>'+
                    '</soapenv:Body>'+
                '</soapenv:Envelope>';
                
                System.debug('1 xmlBodyReqSigned: '+xmlBodyReqSigned);
                System.debug(xmlBodyReqSigned);
                

                //working example (only works hardcoded since SITA created this dummy data with AirlineVendorID != AirlineCode):
                /*
                '<soapenv:Body xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
                    
                    '<wtr:WTR_ReadRecordRQ Version="0.1" xmlns:iata="http://www.iata.org/IATA/2007/00" xmlns:wtr="http://sita.aero/WTR_ReadRecordRQ/8/0" xmlns:common="http://sita.aero/wtr/common/8/0">'+
                        '<wtr:POS>'+
                            '<iata:Source AirlineVendorID="XB"/>'+
                        '</wtr:POS>'+
                        '<wtr:RecordID>'+
                            '<common:RecordType>DELAYED</common:RecordType>'+
                            '<common:RecordReference AirlineCode="0K" ReferenceNumber="10001" StationCode="ZZZ" />'+
                        '</wtr:RecordID>'+
                            '<wtr:AgentID>TEST</wtr:AgentID>'+
                    '</wtr:WTR_ReadRecordRQ>'+

                '</soapenv:Body>'+
                '</soapenv:Envelope>';
                */
       

                // Old body (deprecated):
                /*
        
                    '<soapenv:Body xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
                      '<ns:WTR_ReadRecordRQ Version="0.1">'+
                         '<ns:POS>'+
                            '<ns1:Source AirlineVendorID="XB">'+
                            '</ns1:Source>'+
                         '</ns:POS>'+
                         '<ns:RecordID>'+
                            '<ns2:RecordType>DELAYED</ns2:RecordType>'+
                            '<ns2:RecordReference AirlineCode="0K" ReferenceNumber="10001" StationCode="ZZZ"/>'+
                         '</ns:RecordID>'+
                         '<ns:AgentID>TESTAGENT</ns:AgentID>'+
                      '</ns:WTR_ReadRecordRQ>'+
                   '</soapenv:Body>'+
                '</soapenv:Envelope>';        
                */

                Dom.Document xmlDoc = new Dom.Document();
                xmlDoc.load(xmlBodyReqSigned);
                
                Dom.XMLNode root = xmlDoc.getRootElement();
                //system.debug('getChildren(): '+root.getChildren()[0]);
                Crypto.signXML('RSA-SHA1', (root.getChildren()[0]).getChildren()[0], null, 'wtrcertificate');
                //system.debug('the signed doc: '+doc.toXmlString());
                String xmlSignedString = xmlDoc.toXmlString();
                
                // Instantiate a new http object
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                Http http = new Http();

                req.setEndpoint('https://webservice-qa.worldtracer.aero'); //https://webservice-qa.worldtracer.aero
                //req.setEndpoint('https://webservice.worldtracer.aero'); //https://webservice-qa.worldtracer.aero
                req.setClientCertificateName('wtrcertificate');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
                req.setBody(xmlSignedString);
                // System.debug('req='+req);
                // System.debug('req body='+req.getBody());
       
                String responseXML = '';
                try {
                    res = http.send(req);
                    System.debug('res='+res.toString());
       
                    responseXML = res.getBody();
                    system.debug('SRUL responseXML: '+responseXML);
                    
                    Technical_Logs__c tlog = new Technical_Logs__c();
                    tlog.Status__c = 'Success';
                    tlog.Operation__c = 'BagProrate SITA get Data';
                    DateTime dtStart = system.now();
                    tlog.start_date__c = dtStart;
                    String sLog = '';
                    String sLogRecord = PIR.Airport_Arrival__c +' - '+ PIR.Airline_Code__c +' - '+ PIR.PIR_File_Ref__c+' - '+ PIR.PIR_File_Type__c;
                    sLog += 'req body='+req.getBody() + '\n\n';
                    sLog += 'SRUL responseXML: '+responseXML;
       
                    //write Log
                    DateTime dtEnd = system.now();
                    tlog.End_Date__c = dtEnd;
                    tlog.Log__c = sLog;
                    tlog.Record__c = sLogRecord;
                    try {
                        upsert tlog;
                    }catch (Exception ex) {
                            System.debug('Log writing error: ' + ex.getMessage());
                    }    
       
                    wrapper = bp.parseXMLResponse(responseXML);
                } catch(System.CalloutException e) {
                    //responseXML = EXAMPLE_RESPONSE; JF-why???
                    System.debug('Callout error: '+ e);
                    System.debug('responseXML='+responseXML); 
                }

               
            /* now we relly on the PIR_File_Ref__C size
            }
            //if(responseXML.contains('<Errors') && responseXML.contains('RECORD NOT FOUND')){
            if(responseXML.contains('<Errors')){
                //Airline_Code__c = 'CB', PIR_File_Ref__c ='SB' + PIR_File_Type__c = '600003295' will get a sure response from the second web service only (response from the first will contain errors)
                fillIncidentInformation(PIR.Airport_Arrival__c + PIR.Airline_Code__c + PIR.PIR_File_Ref__c, PIR.PIR_File_Type__c);
                system.debug('##: '+PIR.Airport_Arrival__c + PIR.Airline_Code__c + PIR.PIR_File_Ref__c+' - '+ PIR.PIR_File_Type__c);
                // fillIncidentInformation('CB'+ 'SB' + '600003295', 'DAMAGED');
            }else{
                System.debug('responseXML='+responseXML);
                try{
                    parseXMLResponse(responseXML);
                }catch(Exception ex) {
                    System.debug('ex='+ex);
                }   
            }
            */
            }
        }
        return wrapper;
    }  

    /**
     * [parseXMLResponse description]
     * @author Ofir A.
     * @param Response as XML
     * @return nothing
     * @description This function parse the xml and retrieve and set that data in class variables
     * the data should be retrieve is: First name, Last name, Title, Bag_Information_List, Flight_Information_List, Route
     */
    private PIRFromWrapper parseXMLResponse(String toParse){
        Dom.Document doc = new Dom.Document();
        doc.load(toParse);
        dom.XmlNode xroot = doc.getRootElement();
        system.debug('xroot: ' + xroot.getName());
        dom.XmlNode response = xroot.getChildren()[1].getChildren()[0].getChildren()[0];

        List<String> errorsList = new List<String>();
        //dom.XmlNode statusElement = response.getChildren()[0];
        system.debug('response: ' + response.getName());
        if (response.getName()=='Errors'){
                String errormsg = 'Reason for error: ';
                for(dom.XmlNode child : response.getChildren()){
                    System.debug('found errors: ' + child.getText());
                    errormsg += child.getText() + ', ';
                    errorsList.add(child.getText());
                }
                errormsg = errormsg.substring(0, errormsg.length()-2);
                 System.debug('found errors: ' + errormsg);
                //  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errormsg));
               
                return new PIRFromWrapper(null, null, null, null, null, null, errorsList ); 

        }
        for (Dom.XMLNode ch : response.getChildren()){ // all childs of "WTR_DelayedBagRecReadRS" (success, DiaryInfo, ..)
            system.debug('Dom.XMLNode ch: ' + ch.getName());
            if (ch.getName()=='Errors'){
                String errormsg = 'Reason for error: ';
                for(dom.XmlNode child : ch.getChildren()){
                    System.debug('found errors: ' + child.getText());
                    errormsg += child.getText() + ', ';
                    errorsList.add(child.getText());
                }
                errormsg = errormsg.substring(0, errormsg.length()-2);
                 System.debug('found errors: ' + errormsg);
                //  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errormsg));
                //  return null;
                return new PIRFromWrapper(null, null, null, null, null, null, errorsList ); 
        	}else if (ch.getName()=='DelayedBagGroup' || ch.getName()=='WTR_DelayedBagRecReadRS'){

                Bag_Information_List = new List<PIR_Bag_Information__c>();
                
                Dom.XmlNode delayedBags = ch.getChildren()[1];
                for(Dom.XMLNode delayedBag : delayedBags.getChildren()){
                    
                    PIR_Bag_Information__c bagItem = new PIR_Bag_Information__c();

                    for (Dom.XMLNode delayedBag_data : delayedBag.getChildren()){
                        System.debug('delayedBag_data.getName() '+delayedBag_data.getName());
                        if (delayedBag_data.getName()=='ColorTypeDesc'){
                            for(Dom.XmlNode colorType : delayedBag_data.getChildren()){
                                if(colorType.getName()=='ColorCode') bagItem.PIR_Color__c = colorType.getText();
                                else if(colorType.getName()=='TypeCode') bagItem.Type__c = colorType.getText();
                            }
                        }else if(delayedBag_data.getName()=='BagTag'){
                            for (Dom.XMLNode bagTag : delayedBag_data.getChildren()){
                                if (bagTag.getName()=='TagSequence') bagItem.Bag_Tag_Number__c = bagTag.getText();
                            }
                        }
                    }
                    Bag_Information_List.add(bagItem);
                    System.debug('Bag_Information_List '+Bag_Information_List);
                }
            }else if (ch.getName()=='Passengers'){

                Flight_Information_List = new List<Flight_Information__c>();

                for (Dom.XMLNode passengers_data : ch.getChildren()){
                    if (passengers_data.getName()=='Names'){
                        // Get all names to list
                        List<String> names = new List<String>();
                        for (Dom.XMLNode nameTag : passengers_data.getChildren()){
                            names.add(nameTag.getText());
                        }
                        if (!names.isEmpty()) {
                            PIR.Passenger_s_First_Name__c = names.get(0);
                            names.remove(0);    // remove first name from list
                            // combine all other names to one last name
                            PIR.Last_Name__c='';
                            for (String name : names){
                                if (PIR.Last_Name__c != '') PIR.Last_Name__c+= ' ';
                                PIR.Last_Name__c += name;
                            }
                        }
                    }else if (passengers_data.getName()=='Title'){
                        PIR.Title__c = passengers_data.getText();
                    }else if (passengers_data.getName()=='Itinerary'){
                        List<Flight_Information__c> tempFlightList = new List<Flight_Information__c>();
                        for (Dom.XMLNode itinerary_data : passengers_data.getChildren()){

                            if (itinerary_data.getName()=='FlightSegments'){
                                for(Dom.XMLNode flightSegment : itinerary_data.getChildren()[0].getChildren()) {
                                    Flight_Information__c flightItem = new Flight_Information__c();
                                    for (Dom.XMLNode flightSegment_data : flightSegment.getChildren()){
                                        if (flightSegment_data.getName()=='FlightAndDate'){
                                            for(Dom.XMLNode flightAndDate_data : flightSegment_data.getChildren()){
                                                if (flightAndDate_data.getName()=='FlightNumber') flightItem.PIR_Flight_Number__c = flightAndDate_data.getText();
                                                else if (flightAndDate_data.getName()=='Date'){
                                                    String d = flightAndDate_data.getText();
                                                    String [] dParts = d.split('-');
                                                    // flightItem.PIR_Flight_Date__c = date.parse(dParts[1]+'/'+dParts[2]+'/'+dParts[0]);
                                                    // flightItem.PIR_Flight_Date__c = date.parse(dParts[0]+'-'+dParts[1]+'-'+dParts[2]);
                                                    flightItem.PIR_Flight_Date__c = date.newInstance(Integer.valueof(dParts[0]), Integer.valueof(dParts[1]), Integer.valueof(dParts[2]));

                                                    Datetime flightDateTime = datetime.newInstance(flightItem.PIR_Flight_Date__c.year(), flightItem.PIR_Flight_Date__c.month(),flightItem.PIR_Flight_Date__c.day());
                                                    flightItem.PIR_Flight_Date_Formated__c = getFormatedDate(flightDateTime);
                                                }
                                            }
                                        }else if (flightSegment_data.getName()=='OriginDestination'){
                                            for(Dom.XMLNode originDestination_data : flightSegment_data.getChildren()){
                                                if (originDestination_data.getName()=='Origin') flightItem.PIR_From__c = originDestination_data.getText();
                                                else if (originDestination_data.getName()=='Destination')  flightItem.To__c = originDestination_data.getText(); 
                                            }
                                        }
                                    }
                                    tempFlightList.add(flightItem);
                                }
                            }else if (itinerary_data.getName()=='AdditionalRoutes'){
                                for (Dom.XMLNode additionalRoutes_data : itinerary_data.getChildren()){
                                    if (additionalRoutes_data.getName()=='Route'){
                                        String route = additionalRoutes_data.getText();
                                        for (Flight_Information__c flightListItem : tempFlightList){
                                            flightListItem.PIR_Airline__c = route;
                                        }
                                    }
                                }
                            }
                        }
                        Flight_Information_List.addAll(tempFlightList);
                    }
                }
            }
        }
        
        System.debug('Bag_Information_List='+Bag_Information_List);
        System.debug('Flight_Information_List='+Flight_Information_List);

        PIRFromWrapper pirFormWrap = new PIRFromWrapper(PIR, null, Flight_Information_List, Bag_Information_List, null, null ); 

        // return null;
        // return PIR_List[0];
        return pirFormWrap;
    }
    // End modifications

    /**
        String sWrapper - in reality this is a stringify Wrapper that we deserialize into the Wrapper class
     */
    @AuraEnabled (cacheable=false)    
    public static String saveForm(String sWrapper, String operation){
        
        String sRes = '';
        System.debug('saveForm ## sWrapper: '+sWrapper);
        PIRFromWrapper wrapper = (PIRFromWrapper)JSON.deserialize(sWrapper, PIRFromWrapper.class);

        System.debug('saveForm ## wrapper: '+wrapper);

        ISSP_Baggage_Proration bp = new ISSP_Baggage_Proration();

        // bp.PIR = paramPIR;
        // bp.Flight_Information_List = paramFlight_Information_List;
        // bp.Bag_Information_List = paramBag_Information_List;

        bp.PIR = wrapper.PIR;
        bp.Flight_Information_List = wrapper.PIRFlightInformation;
        bp.Bag_Information_List = wrapper.PIRBagInformation;

        if(operation == 'NEW'){
            bp.isNew = true;
            bp.isEdit = false;
        }else{
            bp.isNew = false;
            bp.isEdit = true;
        }

        System.debug('## Saving Form...');
        System.debug('## isNew: '+bp.isNew);
        System.debug('## isEdit: '+bp.isEdit);
        System.debug('## PIR: '+bp.PIR);
        System.debug('## Flight_Information_List: '+bp.Flight_Information_List);
        System.debug('## Bag_Information_List: '+bp.Bag_Information_List);
        if (bp.isNew){
            try{
                bp.PIR.Created_Date_Formated__c = getFormatedDate(system.now());
                insert bp.PIR;
            }
            catch(Exception e){
                // Apexpages.addMessages(e);
                System.debug('Exception: ' + e);
                return e.getMessage();
            }
            for(Flight_Information__c fi : bp.Flight_Information_List){
                fi.PIR_Ref__c = bp.PIR.Id;
            }
            for(PIR_Bag_Information__c bi : bp.Bag_Information_List){
                bi.PIR_Form__c = bp.PIR.Id;
            }
            sRes = ISSP_Utilities.saveBaggageForm(bp.Flight_Information_List, bp.Bag_Information_List);
            // PageReference pr2 = new PageReference('/apex/ISSP_Baggage_Proration_Form?id='+PIR.Id+'&mid=M6S1');
            // pr2.setRedirect(true);
            // return pr2;
        }
        else if (bp.isEdit){
            try{
                update bp.PIR;
            }
            catch(Exception e){
                // Apexpages.addMessages(e);
                System.debug('Exception: ' + e);
                return e.getMessage();
            }
            for(Flight_Information__c fi : bp.Flight_Information_List){
                fi.PIR_Ref__c = bp.PIR.Id;
            }
            for(PIR_Bag_Information__c bi : bp.Bag_Information_List){
                bi.PIR_Form__c = bp.PIR.Id;
            }
            sRes = ISSP_Utilities.saveBaggageForm(bp.Flight_Information_List, bp.Bag_Information_List);
            // PageReference pr = new PageReference('/apex/ISSP_Baggage_Proration_Form?id='+PIRId+'&mid=M6S1');
            // pr.setRedirect(true);
            // return pr;
        }
        if(sRes == 'OK'){
            sRes = sRes +'-'+bp.PIR.Id;
        }
        return sRes;
    }

    @AuraEnabled 
    public static Baggage_Claim_Comment__c getBaggageClaimComment(String PIRId){
        Baggage_Claim_Comment__c PIRComment = new Baggage_Claim_Comment__c();
        PIRComment   = Database.query(
                                        ' SELECT id, PIR_File_Ref__c,'+
                                        ' Baggage_Claim__c, Baggage_Claim__r.Name, Name,'+
                                        ' Baggage_Claim__r.Parent_PIR_Form__c, Baggage_Claim__r.Parent_PIR_Form__r.Name,'+
                                        ' Comments__c, Account__c, CreatedBy.Name, CreatedDate'+
                                        ' From Baggage_Claim_Comment__c'+
                                        ' Where Baggage_Claim__r.Parent_PIR_Form__c = :'+ PIRId +
                                        ' LIMIT 1'                      
                                    );
        return PIRComment;
    }

   
    @AuraEnabled  
    public static BaggageClaimWrapper getBaggageClaim(String baggageClaimId){
        Baggage_Claim__c PIRClaim_List = new Baggage_Claim__c ();
            PIRClaim_List = [
                            select id , Name ,Airline_receiving__c,
                            Parent_PIR_Form__c, PIR_File_Ref__c, Request_Sent_Date_Formated__c,
                            Airline_issuing__c, Airline_Issuing_Id__c, Airport_Arrival__c,  
                            Date_Time_Proceed_to_payment__c, Days_Baggage_Claim_duration__c, Days_to_Go_vs_60_Day_Limit__c,
                            Email_Prorate_Dept_Airline_issuing__c, Email_Prorate_Dept_Airline_receiving__c, 
                            Passenger_s_First_Name__c,
                            Passenger_s_initials__c, Passenger_s_Last_Name__c, 
                            Status__c, PIR_Currency__c,
                            Title__c, Calculation_details__c, CurrencyIsoCode,
                            Airline_receiving_formula__c,Airline_receiving__r.Email_Prorate__c,
                            Is_Segment_2_Selected__c,Is_Segment_3_Selected__c,Is_Segment_1_Selected__c,Is_Segment_4_Selected__c,
                            Is_Bag_1_Selected__c,Is_Bag_2_Selected__c,Is_Bag_3_Selected__c,
                            Is_Bag_4_Selected__c,Is_Bag_5_Selected__c,Is_Bag_6_Selected__c,Is_Bag_7_Selected__c,Is_Bag_8_Selected__c,Is_Bag_9_Selected__c,
                            Is_Bag_10_Selected__c,X2_letter_Airline_Code__c,Airline_receiving_name__c,
                            Parent_PIR_Form__r.Amount__c,Parent_PIR_Form__r.PIR_Currency_of_conversion__c,Parent_PIR_Form__r.PIR_Currency_Claim__c,
                            Parent_PIR_Form__r.PIR_Passenger_Claim_Amount__c,PIR_Total_Prorated_Amount_Due__c,PIR_Request_Sent_Date__c,
                            CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, CreatedDate,
                            (SELECT Id, Prorate_Request__c, Name, Description__c, Size_MB__c, Full_Name_Unique__c, CreatedDate FROM AmazonFiles__r ORDER BY CreatedDate)
                            From Baggage_Claim__c
                            Where Id =: baggageClaimId ];
        

        List<Flight_Information__c > Flight_Information_List = new List<Flight_Information__c >([select id, Name, PIR_Flight_Date_Formated__c,
                                            PIR_Airline__c, PIR_Ref__c,PIR_Amount_Due__c,To__c,
                                            PIR_Flight_Date__c,PIR_Flight_Number__c,PIR_From__c,Currency__c,
                                            PIR_Percentage__c,PIR_Segment_1__c,PIR_Ticket_Number__c,PIR_Miles__c
                                            From Flight_Information__c
                                            Where PIR_Ref__c =: PIRClaim_List.Parent_PIR_Form__c 
                                            Order By PIR_Segment_1__c]);
        for(Integer i=1 ;i<11 ;i++){
            if(i<5 && Flight_Information_List.size()<i){
                Flight_Information_List.add(new Flight_Information__c(PIR_Segment_1__c = String.valueOf(i), PIR_Ref__c = baggageClaimId));
            }
            else if(i<5 && Flight_Information_List[i-1].PIR_Flight_Date__c != null){
                Datetime flightDateTime = datetime.newInstance(Flight_Information_List[i-1].PIR_Flight_Date__c.year(), Flight_Information_List[i-1].PIR_Flight_Date__c.month(),Flight_Information_List[i-1].PIR_Flight_Date__c.day());
                Flight_Information_List[i-1].PIR_Flight_Date_Formated__c = getFormatedDate(flightDateTime);
            }
        }     

         List<PIR_Bag_Information__c > Bag_Information_List = new List<PIR_Bag_Information__c >([select id, Name,
                                            Bag_Number__c,Bag_Tag_Number__c,PIR_Color__c,PIR_Form__c,Type__c
                                            From PIR_Bag_Information__c
                                            Where PIR_Form__c =: PIRClaim_List.Parent_PIR_Form__c  
                                            Order By Bag_Number__c]);

            
            for(Integer i=1 ;i<11 ;i++){
                if(Bag_Information_List.size()<i){
                    Bag_Information_List.add(new PIR_Bag_Information__c(Bag_Number__c = String.valueOf(i), PIR_Form__c = baggageClaimId));
                }
            }     


            
        List<Baggage_Claim_Comment__c> PIRComment_List  = new List<Baggage_Claim_Comment__c>();
        
        String  sortDirection = 'ASC';
        String  sortExpression = 'Name';
                 PIRComment_List = new List<Baggage_Claim_Comment__c >([
                            select id, Account__c, Name ,Comments__c, Baggage_Claim__c,
                            PIR_File_Ref__c, Email_Prorate_Dept_Airline_issuing__c, Email_Prorate_Dept_Airline_receiving__c, 
                            Baggage_Claim__r.Name, Baggage_Claim__r.PIR_File_Ref__c, CreatedBy.Name, CreatedDate
                            From Baggage_Claim_Comment__c
                            Where Baggage_Claim__c =: baggageClaimId 
                            ORDER BY Name ASC  NULLS LAST ]);


        
        return new BaggageClaimWrapper(Flight_Information_List, Bag_Information_List, PIRClaim_List, PIRComment_List);
    }

    @AuraEnabled (cacheable=true)    
    public static List<Flight_Information__c> getFlightInformationList(String PIRId){
        system.debug('getFlightInformationList - init');
        List<Flight_Information__c > Flight_Information_List = new List<Flight_Information__c >([select id, Name, PIR_Flight_Date_Formated__c,
                                            PIR_Airline__c, PIR_Ref__c,PIR_Amount_Due__c,To__c,
                                            PIR_Flight_Date__c,PIR_Flight_Number__c,PIR_From__c,Currency__c,
                                            PIR_Percentage__c,PIR_Segment_1__c,PIR_Ticket_Number__c,PIR_Miles__c
                                            From Flight_Information__c
                                            Where PIR_Ref__c =: PIRId 
                                            Order By PIR_Segment_1__c]);
              
        system.debug('getFlightInformationList 00 - getFlightInformationList: ' + Flight_Information_List);                              
        for(Integer i=1 ;i<11 ;i++){
            System.debug('i: '+i);
            if(i<5 && Flight_Information_List.size()<i){
                Flight_Information_List.add(new Flight_Information__c(PIR_Segment_1__c = String.valueOf(i), PIR_Ref__c = PIRId));
            }
            else if(i<5 && Flight_Information_List[i-1].PIR_Flight_Date__c != null){
                Datetime flightDateTime = datetime.newInstance(Flight_Information_List[i-1].PIR_Flight_Date__c.year(), Flight_Information_List[i-1].PIR_Flight_Date__c.month(),Flight_Information_List[i-1].PIR_Flight_Date__c.day());
                Flight_Information_List[i-1].PIR_Flight_Date_Formated__c = getFormatedDate(flightDateTime);
            }
        }
        system.debug('getFlightInformationList 11 - getFlightInformationList: ' + Flight_Information_List);
        
        return Flight_Information_List;
    }

    
    @AuraEnabled (cacheable=true)    
    public static List<PIR_Bag_Information__c> getBagInformationList(String PIRId){
        system.debug('getBagInformationList - init'+ PIRId);

            List<PIR_Bag_Information__c > Bag_Information_List = new List<PIR_Bag_Information__c >([select id, Name,
                                            Bag_Number__c,Bag_Tag_Number__c,PIR_Color__c,PIR_Form__c,Type__c
                                            From PIR_Bag_Information__c
                                            Where PIR_Form__c =: PIRId 
                                            Order By Bag_Number__c]);

            
            system.debug('end 000 getBagInformationList: ' + Bag_Information_List);
            for(Integer i=1 ;i<11 ;i++){
                if(Bag_Information_List.size()<i){
                    Bag_Information_List.add(new PIR_Bag_Information__c(Bag_Number__c = String.valueOf(i), PIR_Form__c = PIRId));
                }
            }
            system.debug('end 111 getBagInformationList: ' + Bag_Information_List);
        
        return Bag_Information_List;
    }


    public PageReference pageLoad_Claim(){       
        isEdit = false;
        allowEdit = false;
        sortExpression = 'Name';
        PIRClaim = new Baggage_Claim__c();
        PIRClaimId = Apexpages.currentPage().getParameters().get('id');
        String parentId = Apexpages.currentPage().getParameters().get('parentId');
        string action = Apexpages.currentPage().getParameters().get('action');
        system.debug('PIRClaimId: ' + PIRClaimId);
        system.debug('parentId: ' + parentId);
        system.debug('action: ' + action);
        if (PIRClaimId != null && PIRClaimId != ''){
            isNew = false;
            List <UserRecordAccess> shareList = [SELECT RecordId, HasEditAccess FROM UserRecordAccess
                                            WHERE UserId = :UserInfo.getUserId() AND RecordId = :PIRClaimId];
            system.debug('shareList: ' + shareList);
            if (!shareList.isEmpty()){
                system.debug('accesslevel: ' + shareList[0].HasEditAccess);
                if (shareList[0].HasEditAccess == true){
                    allowEdit = true;
                    if (action == 'edit'){
                        isEdit = true;
                    }
                }
            }
            
            PIRClaim_List = new List<Baggage_Claim__c >([
                            select id , Name ,Airline_receiving__c,
                            Parent_PIR_Form__c, PIR_File_Ref__c, Request_Sent_Date_Formated__c,
                            Airline_issuing__c, Airline_Issuing_Id__c, Airport_Arrival__c,  
                            Date_Time_Proceed_to_payment__c, Days_Baggage_Claim_duration__c, Days_to_Go_vs_60_Day_Limit__c,
                            Email_Prorate_Dept_Airline_issuing__c, Email_Prorate_Dept_Airline_receiving__c, 
                            Passenger_s_First_Name__c,
                            Passenger_s_initials__c, Passenger_s_Last_Name__c, 
                            Status__c, PIR_Currency__c,
                            Title__c, Calculation_details__c, CurrencyIsoCode,
                            Airline_receiving_formula__c,Airline_receiving__r.Email_Prorate__c,
                            Is_Segment_2_Selected__c,Is_Segment_3_Selected__c,Is_Segment_1_Selected__c,Is_Segment_4_Selected__c,
                            Is_Bag_1_Selected__c,Is_Bag_2_Selected__c,Is_Bag_3_Selected__c,
                            Is_Bag_4_Selected__c,Is_Bag_5_Selected__c,Is_Bag_6_Selected__c,Is_Bag_7_Selected__c,Is_Bag_8_Selected__c,Is_Bag_9_Selected__c,
                            Is_Bag_10_Selected__c,X2_letter_Airline_Code__c,Airline_receiving_name__c,
                            Parent_PIR_Form__r.Amount__c,Parent_PIR_Form__r.PIR_Currency_of_conversion__c,Parent_PIR_Form__r.PIR_Currency_Claim__c,
                            Parent_PIR_Form__r.PIR_Passenger_Claim_Amount__c,PIR_Total_Prorated_Amount_Due__c,PIR_Request_Sent_Date__c,
                            CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, CreatedDate,
                            (SELECT Id, Prorate_Request__c, Name, Description__c, Size_MB__c, Full_Name_Unique__c, CreatedDate FROM AmazonFiles__r ORDER BY CreatedDate)
                            From Baggage_Claim__c
                            Where Id =: PIRClaimId ]);
                       
            system.debug('PIRClaim_List: ' + PIRClaim_List);                                                   
            system.debug('PIRClaim_List.AmazonFiles__r: ' + PIRClaim_List[0].AmazonFiles__r);
            if(PIRClaim_List != null && PIRClaim_List.size() > 0){
                PIRClaim = PIRClaim_List[0];
                attach_List = PIRClaim.AmazonFiles__r;
                if (PIRClaim.Date_Time_Proceed_to_payment__c!=null)
                    proceedToPaymentDate = getFormatedDate(PIRClaim.Date_Time_Proceed_to_payment__c);

            }
            system.debug('PIRClaim: ' + PIRClaim); 
            system.debug('PIRClaim.AmazonFiles__r: ' + PIRClaim.AmazonFiles__r);  
            system.debug('attach_List: ' + attach_List);  
        }
        else if (action == 'new' && parentId != null && parentId != ''){
            List <UserRecordAccess> shareList = [SELECT RecordId, HasEditAccess FROM UserRecordAccess
                                            WHERE UserId = :UserInfo.getUserId() AND RecordId = :parentId];
            system.debug('parent shareList: ' + shareList);
            if (!shareList.isEmpty()){
                system.debug('parent edit: ' + shareList[0].HasEditAccess );
                if (shareList[0].HasEditAccess == true){
                    allowEdit = true;
                    if (action == 'new'){
                        PIRClaim.Parent_PIR_Form__c = parentId;
                        isEdit = true;
                        isNew = true;
                        allowEdit = true;
                    }
                    else{
                        return null;
                    }
                }
                else{
                    return null;
                }
            }
            else{
                return null;
            }
        }


        Flight_Information_List = new List<Flight_Information__c >([select id, Name,PIR_Ref__r.Amount__c,
                                                PIR_Airline__c, PIR_Ref__c,PIR_Amount_Due__c,To__c,PIR_Flight_Date_Formated__c,
                                                PIR_Flight_Date__c,PIR_Flight_Number__c,PIR_From__c,Currency__c,
                                                PIR_Percentage__c,PIR_Segment_1__c,PIR_Ticket_Number__c,PIR_Miles__c
                                                From Flight_Information__c
                                                Where PIR_Ref__c =: PIRClaim.Parent_PIR_Form__c 
                                                Order By PIR_Segment_1__c]);

        Bag_Information_List = new List<PIR_Bag_Information__c >([select id, Name,
                                        Bag_Number__c,Bag_Tag_Number__c,PIR_Color__c,PIR_Form__c,Type__c
                                        From PIR_Bag_Information__c
                                        Where PIR_Form__c =: PIRClaim.Parent_PIR_Form__c 
                                        Order By Bag_Number__c]);

        Integer existingBagListSize = Bag_Information_List.size();
        for(Integer i=1 ;i<11 ;i++){
            system.debug('## i: '+i);
            if(i<5 && Flight_Information_List.size()<i)
                Flight_Information_List.add(new Flight_Information__c(PIR_Segment_1__c = String.valueOf(i), PIR_Ref__c = PIRClaim.Parent_PIR_Form__c));
            else if(i<5){
                Flight_Information_List[i-1].PIR_Segment_1__c = String.valueOf(i);
                if(Flight_Information_List[i-1].PIR_Flight_Date__c != null){
                    Datetime flightDateTime = datetime.newInstance(Flight_Information_List[i-1].PIR_Flight_Date__c.year(), Flight_Information_List[i-1].PIR_Flight_Date__c.month(),Flight_Information_List[i-1].PIR_Flight_Date__c.day());
                    Flight_Information_List[i-1].PIR_Flight_Date_Formated__c = getFormatedDate(flightDateTime);
                }        
            }

            if(Bag_Information_List.size()<i && i >= existingBagListSize){
                Bag_Information_List.add(new PIR_Bag_Information__c(Bag_Number__c = String.valueOf(i), PIR_Form__c = PIRClaim.Parent_PIR_Form__c));
            }else{
                Bag_Information_List[i-1].Bag_Number__c = String.valueOf(i);
            }
        }
        System.debug('##Flight_Information_List: '+Flight_Information_List);
        System.debug('##Bag_Information_List: '+Bag_Information_List);

        return null;
    }

    @AuraEnabled (cacheable=true)  
    public static List<String> getPickListValuesIntoList(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Baggage_Claim__c.Status__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
    
    @AuraEnabled (cacheable=true)  
    public static List<String> getPickListValuesBaggageInformationPIRColor(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = PIR_Bag_Information__c.PIR_Color__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }

    
    @AuraEnabled (cacheable=true)  
    public static List<String> getPickListValuesBaggageInformationType(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = PIR_Bag_Information__c.Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }


    @AuraEnabled
    public static List<Baggage_Claim_Comment__c> getAllClaimCommentsList(String baggageClaim){  
        List<Baggage_Claim_Comment__c> PIRComment_List  = new List<Baggage_Claim_Comment__c>();
        
        String  sortDirection = 'ASC';
        String  sortExpression = 'Name';
                 PIRComment_List = new List<Baggage_Claim_Comment__c >([
                            select id, Account__c, Name ,Comments__c, Baggage_Claim__c,
                            PIR_File_Ref__c, Email_Prorate_Dept_Airline_issuing__c, Email_Prorate_Dept_Airline_receiving__c, 
                            Baggage_Claim__r.Name, Baggage_Claim__r.PIR_File_Ref__c, CreatedBy.Name, CreatedDate
                            From Baggage_Claim_Comment__c
                            Where Baggage_Claim__c =: baggageClaim 
                            ORDER BY Name ASC  NULLS LAST ]);
        return PIRComment_List;
    }

    public List<Baggage_Claim_Comment__c> getClaimCommentsList(){  
        List<Baggage_Claim_Comment__c> PIRComment  = new List<Baggage_Claim_Comment__c>();
        if(PIRClaim_List != null && PIRClaim_List .size() > 0) 
                PIRComment   = Database.query(
                                                ' SELECT id, Name, Comments__c, Account__c, CreatedBy.Name, CreatedDate'+
                                                ' From Baggage_Claim_Comment__c'+
                                                ' Where Baggage_Claim__c = :PIRClaimId'+
                                                ' ORDER BY ' + sortExpression + ' ' + sortDirection + ' NULLS LAST'                       
                                            );
        return PIRComment;
    }

    public List<Baggage_Claim_Comment__c> getFormCommentsList(){  
        List<Baggage_Claim_Comment__c> PIRComment = new List<Baggage_Claim_Comment__c>();
        if(PIR_List != null && PIR_List .size() > 0)
                PIRComment   = Database.query(
                                                ' SELECT id, PIR_File_Ref__c,'+
                                                ' Baggage_Claim__c, Baggage_Claim__r.Name, Name,'+
                                                ' Baggage_Claim__r.Parent_PIR_Form__c, Baggage_Claim__r.Parent_PIR_Form__r.Name,'+
                                                ' Comments__c, Account__c, CreatedBy.Name, CreatedDate'+
                                                ' From Baggage_Claim_Comment__c'+
                                                ' Where Baggage_Claim__r.Parent_PIR_Form__c = :PIRId'+
                                                ' ORDER BY ' + sortExpression + ' ' + sortDirection + ' NULLS LAST'                       
                                            );
        return PIRComment;
    }

    public List<Baggage_Claim__c> getFormClaimsList(){ 
        List<Baggage_Claim__c> PIRClaims = new List<Baggage_Claim__c>();
        if(PIR_List != null && PIR_List .size() > 0) 
                PIRClaims = Database.query(
                                ' select id, Parent_PIR_Form__c, Status__c,'+
                                ' Airline_receiving__c, Name, Airline_issuing__c,'+
                                ' Is_Segment_1_Selected__c,Is_Segment_4_Selected__c,Is_Bag_1_Selected__c,Is_Bag_2_Selected__c,Is_Bag_3_Selected__c,'+
                                ' Is_Bag_4_Selected__c,Is_Bag_5_Selected__c,Is_Bag_6_Selected__c,Is_Bag_7_Selected__c,Is_Bag_8_Selected__c,Is_Bag_9_Selected__c,'+
                                ' Is_Bag_10_Selected__c,X2_letter_Airline_Code__c,Airline_receiving_name__c,PIR_Currency__c,PIR_File_Ref__c,'+
                                ' Parent_PIR_Form__r.Amount__c,Parent_PIR_Form__r.PIR_Currency_of_conversion__c,Parent_PIR_Form__r.PIR_Currency_Claim__c,'+
                                ' Parent_PIR_Form__r.PIR_Passenger_Claim_Amount__c,PIR_Total_Prorated_Amount_Due__c,PIR_Request_Sent_Date__c,Passenger_s_First_Name__c,'+
                                ' Days_to_Go_vs_60_Day_Limit__c,Request_Sent_Date_Formated__c,Passenger_s_Last_Name__c'+
                                ' From Baggage_Claim__c'+
                                ' Where Parent_PIR_Form__c = :PIRId'+
                                ' ORDER BY ' + claimsSortExpression + ' ' + claimsSortDirection + ' NULLS LAST'   
                            );
        return PIRClaims;
    }

    public static String getFormatedDate(Datetime dateField){      
        return dateField.format('dd MMM yyyy').toUpperCase();
    }



    
    // public PageReference saveClaim(){
    //     system.debug('saveClaim isNew: ' + isNew);
    //     system.debug('saveClaim isEdit: ' + isEdit);

    //     if (PIRClaim.Airline_receiving__c != null && ISSP_Utilities.getAirlineAccountEmail(PIRClaim.Airline_receiving__c) == null){
    //         PIRClaim.Email_Prorate_Dept_Airline_receiving__c = null;
    //         PIRClaim.Email_Prorate_Dept_Airline_receiving__c.addError('The Airline Receiving selected does not have an Email specified for its Prorate Department. The \'Email (Prorate Dept.) Airline receiving\' field cannot be empty. Please contact IATA.');           
    //         return null;
            
    //     }
       
    //     /*
    //     PIRClaim.put('Is_Segment_'+segmentSelectedNum+'_Selected__c',true);
    //     for(Integer i=1 ;i<5 ;i++){
    //         if(segmentSelectedNum!=String.valueof(i))
    //             PIRClaim.put('Is_Segment_'+String.valueof(i)+'_Selected__c',false);
    //     }
    //     */

    //     calculateFinalAmount();

    //     if (isNew){
    //         //insert PIRClaim;
    //         try{
    //             ISSP_Utilities.saveBaggageClaim(PIRClaim, Flight_Information_List, Bag_Information_List, 'new'); // using another class beccause of "without sharing"
    //         }
    //         catch(Exception e){
    //             Apexpages.addMessages(e);
    //             return null;
    //         }
    //         PageReference pr2 = new PageReference('/apex/ISSP_Baggage_Proration_Claim?id='+PIRClaim.Id+'&mid=M6S2');
    //         pr2.setRedirect(true);
    //         return pr2;
    //     }
    //     else if (isEdit){
    //         //update PIRClaim;
    //         try{
    //             ISSP_Utilities.saveBaggageClaim(PIRClaim, Flight_Information_List, Bag_Information_List, 'save'); // using another class beccause of "without sharing"
    //         }
    //         catch(Exception e){
    //             Apexpages.addMessages(e);
    //             return null;
    //         }
    //         PageReference pr = new PageReference('/apex/ISSP_Baggage_Proration_Claim?id='+PIRClaimId+'&mid=M6S2');
    //         pr.setRedirect(true);
    //         return pr;
    //     }
    //     return null;
    // }

    private void calculateFinalAmount(){
        PIRClaim.PIR_Total_Prorated_Amount_Due__c = 0.00;
        Double amount = PIRClaim.Parent_PIR_Form__r.Amount__c;
        if (isNew){
            List<PIR_Form__c> PIR_Form_List = [select id , Amount__c From PIR_Form__c Where Id =: PIRClaim.Parent_PIR_Form__c ];
            if(PIR_Form_List != null && PIR_Form_List.size() > 0)
                amount = PIR_Form_List[0].Amount__c;
        }
        for(Flight_Information__c flightInfo :Flight_Information_List){
            System.debug('## flightInfo.PIR_Segment_1__c: '+flightInfo.PIR_Segment_1__c);
            Boolean isSegmentChecked = (Boolean)PIRClaim.get('Is_Segment_'+flightInfo.PIR_Segment_1__c+'_Selected__c');
            //Boolean isSegmentChecked = (Boolean)PIRClaim.get('Is_Segment_'+'1'+'_Selected__c');
            if(amount!=null && flightInfo.PIR_Percentage__c!=null && isSegmentChecked)
                PIRClaim.PIR_Total_Prorated_Amount_Due__c += (amount * (flightInfo.PIR_Percentage__c / 100));
        }
    }
    
    // public PageReference pageLoad_Comment(){
    //     isEdit = false;
    //     allowEdit = false;
    //     PIRComment = new Baggage_Claim_Comment__c();
    //     PIRCommentId = Apexpages.currentPage().getParameters().get('id');
    //     String parentId = Apexpages.currentPage().getParameters().get('parentId');
    //     string action = Apexpages.currentPage().getParameters().get('action');
    //     system.debug('PIRCommentId: ' + PIRCommentId);
    //     system.debug('parentId: ' + parentId);
    //     system.debug('action: ' + action);
    //     if (PIRCommentId != null && PIRCommentId != ''){
    //         isNew = false;
    //         /*
    //         List <UserRecordAccess> shareList = [SELECT RecordId, HasEditAccess FROM UserRecordAccess
    //                                         WHERE UserId = :UserInfo.getUserId() AND RecordId = :PIRCommentId];
    //         system.debug('shareList: ' + shareList);
    //         if (!shareList.isEmpty()){
    //             system.debug('accesslevel: ' + shareList[0].HasEditAccess);
    //             if (shareList[0].HasEditAccess == true){
    //                 allowEdit = true;
    //                 if (action == 'edit'){
    //                     isEdit = true;
    //                 }
    //             }
    //         }
    //         */
            
    //         PIRComment_List = new List<Baggage_Claim_Comment__c >([
    //                         select id , Name ,Comments__c, Baggage_Claim__c,
    //                         PIR_File_Ref__c, Email_Prorate_Dept_Airline_issuing__c, Email_Prorate_Dept_Airline_receiving__c, 
    //                         Baggage_Claim__r.Name, Baggage_Claim__r.PIR_File_Ref__c, CreatedBy.Name, CreatedDate
    //                         From Baggage_Claim_Comment__c
    //                         Where Id =: PIRCommentId ]);
                                                   
    //         if(PIRComment_List != null && PIRComment_List .size() > 0){
    //             PIRComment = PIRComment_List [0];
    //         }
    //     }
    //     else if (action == 'new' && parentId != null && parentId != ''){
    //         List <UserRecordAccess> shareList = [SELECT RecordId, HasEditAccess FROM UserRecordAccess
    //                                         WHERE UserId = :UserInfo.getUserId() AND RecordId = :parentId];
    //         system.debug('parent shareList: ' + shareList);
    //         if (!shareList.isEmpty()){
    //             system.debug('parent edit: ' + shareList[0].HasEditAccess );
    //             if (!shareList.isEmpty()){
    //             //if (shareList[0].HasEditAccess == true){
    //                 allowEdit = true;
    //                 if (action == 'new'){
    //                     PIRComment.Baggage_Claim__c = parentId;
    //                     isEdit = true;
    //                     isNew = true;
    //                     allowEdit = true;
    //                 }
    //                 else{
    //                     return null;
    //                 }
    //             }
    //             else{
    //                 return null;
    //             }
    //         }
    //         else{
    //             return null;
    //         }
    //     }
    //     return null;
    // }
    @AuraEnabled
    public static Account fetchAirlineAccountDetailsAura(string airlineCode, id accontIssuingId) {
        String qAirlineCode;
        Account AirlineAccount = new Account();

        if(airlineCode == null || airlineCode.length() != 2)
            return null;

        qAirlineCode = airlineCode + '%';

        List<Account> airlineaccounts = ISSP_Utilities.getAirlineAccounts(qAirlineCode);

        System.debug('qAirlineCode '+qAirlineCode);
        if(airlineaccounts.size() > 0 && (airlineaccounts[0].id != accontIssuingId)){ 
            AirlineAccount = airlineaccounts[0];
            /*PIRClaim.Airline_receiving__c = AirlineAccount.Id;
            PIRClaim.Airline_receiving_name__c = AirlineAccount.Name;*/
        } 

        return AirlineAccount;


    }

    @AuraEnabled
    public static String UpdateClaim(String sWrapper, Baggage_Claim__c PIRClaim){
        
        System.debug('saveForm ## sWrapper: '+sWrapper);
        BaggageClaimWrapper wrapper = (BaggageClaimWrapper)JSON.deserialize(sWrapper, BaggageClaimWrapper.class);

        System.debug('saveForm ## wrapper: '+wrapper);
        System.debug('saveForm ## PIRClaim: '+PIRClaim);
        System.debug('saveForm ## PIRClaim.Id: '+PIRClaim.Id);
        
        //Baggage_Claim__c PIRClaim =  wrapper.PIRBagClaim;
        List<Flight_Information__c> Flight_Information_List = wrapper.PIRFlightInformation;
        List<PIR_Bag_Information__c> bag_Information_List =  wrapper.PIRBagInformation;

        if (PIRClaim.Airline_receiving__c != null && ISSP_Utilities.getAirlineAccountEmail(PIRClaim.Airline_receiving__c) == null){
            PIRClaim.Email_Prorate_Dept_Airline_receiving__c = null;       
            return 'The Airline Receiving selected does not have an Email specified for its Prorate Department. The \'Email (Prorate Dept.) Airline receiving\' field cannot be empty. Please contact IATA.';
            
        }

        calculateFinalAmountAura(PIRClaim, Flight_Information_List);
        try{
            if(PIRClaim.Id != null){
                ISSP_Utilities.saveBaggageClaim(PIRClaim, Flight_Information_List, Bag_Information_List, 'save'); // using another class beccause of "without sharing"
            }else{
                ISSP_Utilities.saveBaggageClaim(PIRClaim, Flight_Information_List, Bag_Information_List, 'new'); // using another class beccause of "without sharing"
            }
        }
        catch(Exception e){
            System.debug('Exception: ' + e);
            System.debug('Exception: ' + e.getStackTraceString());
            return String.valueOf(e);
        }
        return 'OK-'+PIRClaim.Id;
    }

    
    public static void calculateFinalAmountAura(Baggage_Claim__c PIRClaim, List<Flight_Information__c> Flight_Information_List){
        PIRClaim.PIR_Total_Prorated_Amount_Due__c = 0.00;
        Double amount = PIRClaim.Parent_PIR_Form__r.Amount__c;

        for(Flight_Information__c flightInfo : Flight_Information_List){
            System.debug('## flightInfo.PIR_Segment_1__c: '+flightInfo.PIR_Segment_1__c);
            Boolean isSegmentChecked = (Boolean)PIRClaim.get('Is_Segment_'+flightInfo.PIR_Segment_1__c+'_Selected__c');
            //Boolean isSegmentChecked = (Boolean)PIRClaim.get('Is_Segment_'+'1'+'_Selected__c');
            system.debug('amount'+amount);
            system.debug('flightInfo.PIR_Percentage__c'+flightInfo.PIR_Percentage__c);
            system.debug('isSegmentChecked'+isSegmentChecked);
            if(amount!=null && flightInfo.PIR_Percentage__c!=null && isSegmentChecked)
                PIRClaim.PIR_Total_Prorated_Amount_Due__c += (amount * (flightInfo.PIR_Percentage__c / 100));
        }
    }


    @AuraEnabled
    public static String saveNewComment(String sWrapper){
        try{
            PIRFCommentWrapper wrapper = (PIRFCommentWrapper)JSON.deserialize(sWrapper, PIRFCommentWrapper.class);
            Baggage_Claim_Comment__c newComment = new Baggage_Claim_Comment__c();
            newComment.Baggage_Claim__c = wrapper.Baggage_Claim;
            newComment.Comments__c = wrapper.Comments;
            insert newComment;
            System.debug('newComment'+ newComment);
        }
        catch(Exception e){
            return String.valueOf(e);
        }
        return 'ok';
    }
    
    // public PageReference saveComment(){
    //     if (isNew){
    //         insert PIRComment;
    //         PageReference pr2 = new PageReference('/apex/ISSP_Baggage_Proration_Comment?id='+PIRComment.Id+'&mid=M6S2');
    //         pr2.setRedirect(true);
    //         return pr2;
    //     }
    //     /*
    //     else if (isEdit){
    //         update PIRComment;
    //         PageReference pr = new PageReference('/apex/ISSP_Baggage_Proration_Comment?id='+PIRCommentId);
    //         pr.setRedirect(true);
    //         return pr;
    //     }       
    //     */
    //     return null;
    // }

    public PIRFromWrapper fillIncidentInformation(String incidentId, String incidentType) {
        //String incidentId = 'CBSB600003295';
        //String incidentType = '';
        System.debug('## fillIncidentInformation');
        String netTracerSessionId = getNetTracerSessionId();
        PIRFromWrapper wrapper = retrieveAndFillIncidentInformation(netTracerSessionId, incidentId, incidentType);
        logOffNetTracer(netTracerSessionId);
        System.debug('## END fillIncidentInformation');
        return wrapper;
    }

    public String getNetTracerSessionId() {
        coreWsNettracerBagnetCom.NTCoreServiceSOAP11port_http calloutClass = new coreWsNettracerBagnetCom.NTCoreServiceSOAP11port_http();
        return calloutClass.authenticate('iatatest', 'Nettracer123', 'B6');
    }

    public PIRFromWrapper retrieveAndFillIncidentInformation(String netTracerSessionId, String incidentId, String incidentType) {
        system.debug('@ retrieveAndFillIncidentInformation - netTracerSessionId: ' + netTracerSessionId + ', incidentId: ' + incidentId + ', incidentType: ' + incidentType);
        coreWsNettracerBagnetCom.NTCoreServiceSOAP11port_http calloutClass = new coreWsNettracerBagnetCom.NTCoreServiceSOAP11port_http();
        ISSP_Baggage_Proration bp = new ISSP_Baggage_Proration();
        bp.PIR = new PIR_Form__c();
        if (String.isNotBlank(netTracerSessionId)) {
            pojoCoreWsNettracerBagnetComXsd.WS_Incident wsIncident = calloutClass.getIncident(netTracerSessionId, incidentId, incidentType);
            System.debug('wsIncident [NetTracer]: '+wsIncident);
            if (wsIncident != null) {
                if (wsIncident.passengers != null && wsIncident.passengers.size() > 0) {
                    PIR.Passenger_s_First_Name__c = wsIncident.passengers[0].firstname;
                    PIR.Last_Name__c = wsIncident.passengers[0].lastname;
                    PIR.Title__c = wsIncident.passengers[0].jobtitle;
                }
                
                if (wsIncident.itineraries != null && wsIncident.itineraries.size() > 0) {
                    Flight_Information_List = new List<Flight_Information__c>();
                    Integer iPIR_Segment_1 = 1;
                    for (pojoCoreWsNettracerBagnetComXsd.WS_Itinerary itinerary : wsIncident.itineraries) {
                        Flight_Information__c flightItem = new Flight_Information__c();
                        flightItem.PIR_Segment_1__c = String.valueOf(iPIR_Segment_1++);
                        flightItem.PIR_Flight_Number__c = itinerary.flightnum;
                        Flight_Information_List.add(flightItem);
                    }
                }
                if (wsIncident.items != null && wsIncident.items.size() > 0) {
                    bag_Information_List = new List<PIR_Bag_Information__c>();
                    Integer iBag_Number = 1;
                    for (pojoCoreWsNettracerBagnetComXsd.WS_Item item : wsIncident.items) {
                        PIR_Bag_Information__c bagItem = new PIR_Bag_Information__c();
                        bagItem.Bag_Number__c = String.valueOf(iBag_Number++);
                        bagItem.Bag_Tag_Number__c = String.valueOf(item.bagnumber);
                        bagItem.PIR_Color__c = item.color;
                        bagItem.Type__c = item.itemtype;
                        bag_Information_List.add(bagItem);
                    }
                }
            }
        }
        system.debug('\n\n PIR: ' + PIR);
        system.debug('Flight_Information_List: ' + Flight_Information_List);
        system.debug('bag_Information_List: ' + bag_Information_List + '\n\n');

        return new PIRFromWrapper(PIR,null, Flight_Information_List, bag_Information_List, null, null);
    }

    public void logOffNetTracer(String netTracerSessionId) {
        coreWsNettracerBagnetCom.NTCoreServiceSOAP11port_http calloutClass = new coreWsNettracerBagnetCom.NTCoreServiceSOAP11port_http();
        calloutClass.logoff(netTracerSessionId);
    }

    /**
        Get alink to access to an amazon file, this link is time limited
    **/
    @RemoteAction
    @AuraEnabled 
    public static string getExpiringLink(string fileName ) {
        Integer secondsValid = 300;
        String link = AmazonRest.genPublicExpiringAWSLink( fileName, WrapperAttach.CREDENTIAL, secondsValid);
        return link;
    }


    public class BaggageClaimWrapper {
        
        @AuraEnabled 
        public List<Flight_Information__c> PIRFlightInformation {get;set;}
        @AuraEnabled
        public List<PIR_Bag_Information__c> PIRBagInformation {get;set;}
        @AuraEnabled
        public Baggage_Claim__c PIRBagClaim {get;set;}
        @AuraEnabled
        public List<Baggage_Claim_Comment__c> PIRComments {get;set;}
        
        public BaggageClaimWrapper(List<Flight_Information__c> PIRFlightInformation,
                                        List<PIR_Bag_Information__c> PIRBagInformation, 
                                        Baggage_Claim__c PIRBagClaim,
                                        List<Baggage_Claim_Comment__c> PIRComments){

            this.PIRFlightInformation = PIRFlightInformation;
            this.PIRBagInformation = PIRBagInformation;
            this.PIRBagClaim = PIRBagClaim;
            this.PIRComments = PIRComments;
            
        }
    }

    public class PIRFCommentWrapper {
        
        @AuraEnabled 
        public String Comments {get;set;}
        @AuraEnabled
        public String Baggage_Claim {get;set;}
        

        public PIRFCommentWrapper(String Comments,
                                        String Baggage_Claim){
            this.Comments = Comments;                                            
            this.Baggage_Claim = Baggage_Claim;
            
        }
    }

    
    public class PIRFromWrapper {
        
        @AuraEnabled 
        public PIR_Form__c PIR {get;set;}
        @AuraEnabled
        public Account PIRAccount {get;set;}
        @AuraEnabled 
        public List<Flight_Information__c> PIRFlightInformation {get;set;}
        @AuraEnabled
        public List<PIR_Bag_Information__c> PIRBagInformation {get;set;}
        @AuraEnabled
        public List<Baggage_Claim__c> PIRBagClaim {get;set;}
        @AuraEnabled
        public List<Baggage_Claim_Comment__c> PIRComments {get;set;}
        @AuraEnabled
        public List<String> Errors {get;set;}
        
        public PIRFromWrapper(){}

        public PIRFromWrapper(PIR_Form__c PIR,
                                        Account PIRAccount,
                                        List<Flight_Information__c> PIRFlightInformation,
                                        List<PIR_Bag_Information__c> PIRBagInformation, 
                                        List<Baggage_Claim__c> PIRBagClaim,
                                        List<Baggage_Claim_Comment__c> PIRComments){
            this(PIR,PIRAccount,PIRFlightInformation,PIRBagInformation,PIRBagClaim,PIRComments,new List<String>());                               
                                        }

        public PIRFromWrapper(PIR_Form__c PIR,
                                        Account PIRAccount,
                                        List<Flight_Information__c> PIRFlightInformation,
                                        List<PIR_Bag_Information__c> PIRBagInformation, 
                                        List<Baggage_Claim__c> PIRBagClaim,
                                        List<Baggage_Claim_Comment__c> PIRComments,
                                        List<String> Errors){
            this.PIR = PIR;                                            
            this.PIRAccount = PIRAccount;
            this.PIRFlightInformation = PIRFlightInformation;
            this.PIRBagInformation = PIRBagInformation;
            this.PIRBagClaim = PIRBagClaim;
            this.PIRComments = PIRComments;
            this.Errors = Errors;
            
        }
    }

    @AuraEnabled
    public static Map <String, String> getselectOptions(string objObject, string fld) {
        system.debug('objObject --->' + objObject);
        system.debug('fld --->' + fld);
        Map < String, String > allOpts = new Map < String, String > ();

        // Get the object type of the SObject.
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(objObject);

        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

        

        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();

        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = fieldMap.get(fld).getDescribe().getPickListValues();

        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.put(a.getValue(), a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        // allOpts.sort();
        return allOpts;
    }
}