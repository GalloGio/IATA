global without sharing class ISSP_OperationalCalendarController {
    
    public class OperationalCalendarException extends Exception {}
    
    public static final set<String> AIRLINE_PROFILES = new set<String>{
        'ISS Portal Airline Delegated Admin User',
        'ISS Portal Airline User',
        'ISS Portal Airline User (Partner)'};
    public static final set<String> AGENT_PROFILES = new set<String>{
        'ISS Portal Agency Delegated Admin User',
        'ISS Portal Agency User',
        'ISS Portal Agency User (Partner)'};
    public static final map<String,String> MAP_OPERATION_TYPES = new map<String,String>{
        'P' => 'BSP International',
        'D' => 'BSP Domestic',
        'C' => 'CASS Export',
        'R' => 'CASS Export',
        'I' => 'CASS Import'
    };
    
    public static final Map<String, Schema.SObjectField> MAP_CALENDAR_FIELDS =
        Schema.getGlobalDescribe().get('operational_Calendar__c').getDescribe().fields.getMap();
    public static final String FIELD_First_Day = MAP_CALENDAR_FIELDS.get('First_Day__c').getDescribe().getLabel();
    public static final String FIELD_Last_Day = MAP_CALENDAR_FIELDS.get('Last_Day__c').getDescribe().getLabel();
    public static final String FIELD_Settlement_Day = MAP_CALENDAR_FIELDS.get('Settlement_Day__c').getDescribe().getLabel();
    public static final String FIELD_Airline_Input_Upload_Cut_Off = MAP_CALENDAR_FIELDS.get('Airline_Input_Upload_Cut_Off__c').getDescribe().getLabel();
    public static final String FIELD_Airline_Correction_Response_Cut_Off = MAP_CALENDAR_FIELDS.get('Airline_Correction_Response_Cut_Off__c').getDescribe().getLabel();
    public static final String FIELD_Remittance_Day = MAP_CALENDAR_FIELDS.get('Remittance_Day__c').getDescribe().getLabel();
    public static final String FIELD_Billing_Availability = MAP_CALENDAR_FIELDS.get('Billing_Availability__c').getDescribe().getLabel();
    public static final String FIELD_Agent_Correction_Cut_Off = MAP_CALENDAR_FIELDS.get('Agent_Correction_Cut_Off__c').getDescribe().getLabel();
    public static final String FIELD_CASS_reports_Availability = MAP_CALENDAR_FIELDS.get('CASS_reports_Availability__c').getDescribe().getLabel();
    
    private final map<string,string> ISOFIELDPERLANGUAGE = new map<string,string>{
        'en' => 'IATA_COUNTRY_EN__c',
        'ko' => 'IATA_Contry_KR__c',
        'fr' => 'IATA_Country_FR__c',
        'it' => 'IATA_Country_IT__c',
        'ja' => 'IATA_Country_JP__c',
        'pt' => 'IATA_Country_PT__c',
        'es' => 'IATA_Country_SP__c',
        'zh' => 'IATA_Country_ZH__c'};
    public static Profile THIS_PROFILE = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
    public static Boolean IS_AIRLINE = AIRLINE_PROFILES.contains(THIS_PROFILE.Name);
    public static Boolean IS_AGENT = AGENT_PROFILES.contains(THIS_PROFILE.Name);

    private transient list<EventWrapper> listEvents;
    private transient list<Operational_Calendar__c> listOperations;
    private User user;
    private Contact contact;
    public Account account {get;set;}
    public String defaultCountry {get; set;}
    public String defaultOperationType {get; set;}
    public Date maxDate {get; set;}
    public Date minDate {get; set;}
    
    //Filters
    public Boolean showFilters {get;set;}
    public list<SelectOption> countryOptions {get;set;}
    public set<String> setFilter{get;set;}
    
    /**** GETTERS ****/
    public String getListFiltersJson() {
        return JSON.serialize(this.setFilter,true);
    }
    public list<Operational_Calendar__c> getListOperations() {
        return this.listOperations;
    }
    public Boolean getIsAirline() {
        return IS_AIRLINE;
    }
    public String getListEventsJSON() {
        return JSON.serialize(this.listEvents,true);
    }
    public String getMapFrequenciesJSON() {
        map<String,String> mapFrequencies = new map<String,String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get('Remittance_frequency__c').getDescribe();
        for (Schema.PicklistEntry entry: fieldResult.getPicklistValues()) {
            mapFrequencies.put(entry.getValue(),entry.getLabel());
        }
        return JSON.serialize(mapFrequencies,true);
    }
    /**** END GETTERS ****/
    
    /**
    Returns true only if the user is in list of available profiles to use this page
    **/
    public static Boolean isAllowedAccess() {
        return (IS_AIRLINE || IS_AGENT);
    }
    
    /**** CONTROLLER ****/
    public ISSP_OperationalCalendarController() {
        this.user = [
            SELECT Id, Profile.Name, ContactId, Contact.Id, Contact.AccountId,
                Contact.Account.Id,
                Contact.Account.IATA_ISO_Country__c,
                Contact.Account.Remittance_frequency__c,
                Contact.Account.Location_Class__c
            FROM User
            WHERE Id = :UserInfo.getUserId()];
        this.contact = this.user.contact;
        this.account = this.user.contact.account;
        this.showFilters = IS_AIRLINE;
        this.setFilter = new set<String>();
        this.defaultCountry = this.account.IATA_ISO_Country__c;
        this.defaultOperationType = MAP_OPERATION_TYPES.get(this.account.Location_Class__c);
        this.maxDate = Date.newInstance(Date.Today().year()+1, 1, 1);
        this.minDate = Date.newInstance(Date.Today().year()-1, 1, 1);
        if (IS_AIRLINE) {
            initPicklistValues();
        } else {
            loadEventsForAgent();
        }
    }
    
    /**
        Initial values for picklists used in filter section
        this section is only visilbe for airline users
    **/
    public void initPicklistValues() {
        // mapFrequencies, its a relation between countries and their frequencies
        list<AMS_Settlement_System__c> listOp = [
            SELECT Id, Name,  
                ( SELECT Id FROM IATA_ISO_Countries__r),
                ( SELECT Id FROM CASS_COUNTRIES__r),
                ( SELECT frequency_code__c, Operation_Currency__c, Operation_Type__c
                    FROM Operational_Calendars__r
                    WHERE First_Day__c >= LAST_YEAR)
            FROM AMS_Settlement_System__c 
        ];
        
        set<Id> setCountryId = new set<Id>();
        for (AMS_Settlement_System__c op: listOp ) {
            Id BSPCountryId = op.IATA_ISO_Countries__r.isEmpty()? null: op.IATA_ISO_Countries__r[0].Id;
            Id CASSCountryId = op.CASS_COUNTRIES__r.isEmpty()? null: op.CASS_COUNTRIES__r[0].Id;
            for (Operational_Calendar__c operation: op.Operational_Calendars__r ) {
                Id countryId = null;
                if (operation.Operation_Type__c.contains('BSP')) {
                    countryId = BSPCountryId;
                }
                if (operation.Operation_Type__c.contains('CASS')) {
                    countryId = CASSCountryId;
                }
                if (countryId!=null) {
                    String str = countryId + ',' + operation.Operation_Type__c + ',' + operation.frequency_code__c + ',' + operation.Operation_Currency__c;
                    this.setFilter.add(str);
                    setCountryId.add(countryId);
                }
            }
        }
        // countries
        String fieldName = getIsoCountryFieldName();
        this.countryOptions = new list<SelectOption>();
        for (IATA_ISO_Country__c country: [SELECT Id, Name,
                    IATA_COUNTRY_EN__c, IATA_Country_ZH__c, IATA_Country_SP__c,
                    IATA_Country_PT__c, IATA_Country_JP__c, IATA_Country_IT__c,
                    IATA_Country_FR__c, IATA_Contry_KR__c
                FROM IATA_ISO_Country__c 
                WHERE Id IN :setCountryId
            ]) {
            String countryName = (String)country.get(fieldName);
            if (countryName==null) countryName = country.Name;
            this.countryOptions.add(new SelectOption(country.Id, countryName));
        }
    }
    
    /**
        Generate the text inside the popup when the mouse is over
    **/
    private static String getEventDescription(Operational_Calendar__c operation, Boolean isCASS, Boolean isAirline) {
        list<String> listFiledNames;
        if (isAirline) {
            if (isCASS) {
                listFiledNames = new list<String>{'First_Day__c','Last_Day__c','Airline_Input_Upload_Cut_Off__c','CASS_reports_Availability__c','Agent_Correction_Cut_Off__c','Airline_Correction_Response_Cut_Off__c','Billing_Availability__c','Remittance_Day__c','Settlement_Day__c'};
            } else {
                listFiledNames = new list<String>{'First_Day__c','Last_Day__c','Billing_Availability__c','Remittance_Day__c','Settlement_Day__c'};
            }
        } else {
            //AGENTS
            if (isCASS) {
                listFiledNames = new list<String>{'First_Day__c','Last_Day__c','CASS_reports_Availability__c','Agent_Correction_Cut_Off__c','Billing_Availability__c','Remittance_Day__c'};
            } else {
                listFiledNames = new list<String>{'First_Day__c','Last_Day__c','Billing_Availability__c','Remittance_Day__c'};
            }
        }
        String description = '';
        for (String fieldName: listFiledNames) {
            String label = MAP_CALENDAR_FIELDS.get(fieldName).getDescribe().getLabel();
            String value = dateToString((DateTime)operation.get(fieldName));
            description+= '<strong>' + label + '</strong> ' + value + '</br>';
        }
        return description;
    } 
    
    /**
        Creates a list of events based on queried operational calendars
        these events are created based on the user type, airlines or agent users
    **/
    private static list<EventWrapper> getOperationalCalendarEvents(list<Operational_Calendar__c> listOperations, String operationType) {
        list<EventWrapper> listEvents = new list<EventWrapper>();
        Boolean isCASS = operationType.contains('CASS');
        for (Operational_Calendar__c operation: listOperations) {
            String title = operation.Period_Code__c;
            String description = getEventDescription(operation, isCASS, IS_AIRLINE);
            // The settlement events are shown only for airlines
            if (IS_AIRLINE) {
                EventWrapper event1 = new EventWrapper();
                event1.title = FIELD_Settlement_Day + ' - ' + operation.Operation_Currency__c;
                event1.start = operation.Settlement_Day__c;
                event1.allDay = true;
                event1.className = 'settlementEvent';
                event1.description = description;
                listEvents.add(event1);
                if (isCASS) {
                    EventWrapper event2 = new EventWrapper();
                    event2.title = FIELD_Airline_Input_Upload_Cut_Off + ' - ' + operation.Operation_Currency__c;
                    event2.start = operation.Airline_Input_Upload_Cut_Off__c;
                    event2.allDay = true;
                    event2.className = 'airlineUploadEvent';
                    event2.description = description;
                    listEvents.add(event2);
                    EventWrapper event3 = new EventWrapper();
                    event3.title = FIELD_Airline_Correction_Response_Cut_Off + ' - ' + operation.Operation_Currency__c;
                    event3.start = operation.Airline_Correction_Response_Cut_Off__c;
                    event3.allDay = true;
                    event3.className = 'airlineCorrectionEvent';
                    event3.description = description;
                    listEvents.add(event3);
                }
            } else {
                EventWrapper event1 = new EventWrapper();
                event1.title = FIELD_Remittance_Day + ' - ' + operation.Operation_Currency__c;
                event1.start = operation.Remittance_Day__c;
                event1.allDay = true;
                event1.className = 'remittanceEvent';
                event1.description = description;
                listEvents.add(event1);
                EventWrapper event2 = new EventWrapper();
                event2.title = FIELD_Billing_Availability + ' - ' + operation.Operation_Currency__c;
                event2.start = operation.Billing_Availability__c;
                event2.allDay = true;
                event2.className = 'billingAvailabilityEvent';
                event2.description = description;
                listEvents.add(event2);
                if (isCASS) {
                    EventWrapper event3 = new EventWrapper();
                    event3.title = FIELD_Agent_Correction_Cut_Off + ' - ' + operation.Operation_Currency__c;
                    event3.start = operation.Agent_Correction_Cut_Off__c;
                    event3.allDay = true;
                    event3.className = 'agentCorrectionEvent';
                    event3.description = description;
                    listEvents.add(event3);
                    EventWrapper event4 = new EventWrapper();
                    event4.title = FIELD_CASS_reports_Availability + ' - ' + operation.Operation_Currency__c;
                    event4.start = operation.CASS_reports_Availability__c ;
                    event4.allDay = true;
                    event4.className = 'CASSReportsEvent';
                    event4.description = description;
                    listEvents.add(event4);
                }
            }
        }
        return listEvents;
    }
    
    /**
        Query the operational calendar records based on input filters
    **/
    public static list<Operational_Calendar__c> queryListOperations(String country, String frequency, String operationType, String currencyCode, Integer billingPeriod) {
        if (String.isBlank(country)) {
            throw new OperationalCalendarException(Label.ISSP_OperationalCalendar_Country_Filter_Required);
        }
        if (String.isBlank(operationType)) {
            throw new OperationalCalendarException(Label.ISSP_OperationalCalendar_BSPCASS_Filter_Required);
        }
        String lookupField = operationType.contains('CASS')? 'AMS_Settlement_System_CASS__c': 'AMS_Settlement_System__c';
        String query = 'SELECT Id,RecordTypeId,First_Day__c,Frequency_code__c,HAR_Day__c,ISS_operation__c,Last_Day__c,Name,Operation_Code__c,'
            + ' Operation_Currency__c,Operation_Period_code__c,Operation_Type__c,Period_Code__c,Remittance_Day__c,Settlement_Day__c,'
            + ' EP_Settlement_date__c, Billing_Availability__c, Airline_Input_Upload_Cut_Off__c, CASS_reports_Availability__c,'
            + ' Agent_Correction_Cut_Off__c, Airline_Correction_Response_Cut_Off__c '
            + ' FROM Operational_Calendar__c'
            + ' WHERE ISS_operation__c IN ('
            + '     SELECT ' + lookupField
            + '     FROM IATA_ISO_Country__c'
            + '     WHERE Id = :country)'
            + ' AND Operation_Type__c = \'' + operationType + '\'';
            
            if (String.isNotBlank(frequency)) {
                query += ' AND frequency_code__c = \'' + frequency + '\'';
            }
            if (String.isNotBlank(currencyCode)) {
                query += ' AND Operation_Currency__c = \'' + currencyCode + '\'';
            }
            if (billingPeriod==Date.today().year()) {
                query += ' AND First_Day__c = THIS_YEAR';
            } else if ( billingPeriod >= 1 && billingPeriod <= 12 ) {
                query += ' AND CALENDAR_MONTH(First_Day__c) = ' + billingPeriod;
            } else {
                query += ' AND First_Day__c >= LAST_YEAR';
            }
            
            System.debug('QUERY: ' + query);
            return Database.query(query);
    }
    
    /**
        This method only gets the events to show an agent user, it will be executed only once at the beggining
    **/
    public void loadEventsForAgent() {
        String country = this.defaultcountry;
        String frequency = this.account.Remittance_frequency__c;
        String operationType = MAP_OPERATION_TYPES.get(this.account.Location_Class__c);
        String currencyCode = '';
        try {
            this.listOperations = queryListOperations(country, frequency, operationType, currencyCode, Date.today().year());
        } catch (Exception e) {
            this.listOperations = new list<Operational_Calendar__c>();
        }
        this.listEvents = getOperationalCalendarEvents(this.listOperations, operationType);
        for (EventWrapper event: this.listEvents) {
            if (event.start!=null && event.start.date() > this.maxDate){
                // first day of next event's month
                Date firstDayMonth = Date.newInstance(event.start.year(), event.start.month(),1);
                this.maxDate = firstDayMonth.addMonths(1);
            }
        }
    }
    
    /**
        Get the country fild value where is located the translated name of the country
    **/
    public String getIsoCountryFieldName() {
        String locale = UserInfo.getLanguage();
        locale =  locale==null ? 'en': locale.left(2);
        return ISOFIELDPERLANGUAGE.get(locale.toLowerCase());
    }
    
    /**
        Find the event list and converts it to JSON, a format valid for javascript
        This is called from the page, usually when a filter changes, only allowed to airlines
    **/
    @RemoteAction
    global static String loadEventsRemote(String country, String frequency, String operationType, String currencyCode) {
        if (!IS_AIRLINE) return '';
        list<Operational_Calendar__c> listOperations = queryListOperations(country, frequency, operationType, currencyCode,null);
        list<EventWrapper> listEvents = getOperationalCalendarEvents(listOperations, operationType);
        return JSON.serialize(listEvents,true);
    }
    
    /**
        Find the operational calendar list and converts it to JSON, a format valid for javascript
        This is called from the page, usually when a filter changes, for airlines only
    **/
    @RemoteAction
    global static String loadDetailsRemoteForAirlines(String country, String frequency, String operationType, String currencyCode, String billingPeriod) {
        if (!IS_AIRLINE) return '';
        list<list<String>> listResults = new list<list<String>>();
        for (Operational_Calendar__c operation: queryListOperations(country, frequency, operationType, currencyCode, Integer.ValueOf(billingPeriod))) {
            list<String> listLine = new list<String>();
            listLine.add(nvl(operation.Period_Code__c));
            listLine.add(dateToString(operation.First_Day__c));
            listLine.add(dateToString(operation.Last_Day__c));
            if (operationType.contains('CASS')) {
                listLine.add(dateToString(operation.Airline_Input_Upload_Cut_Off__c));
                listLine.add(dateToString(operation.CASS_reports_Availability__c));
                listLine.add(dateToString(operation.Agent_Correction_Cut_Off__c));
                listLine.add(dateToString(operation.Airline_Correction_Response_Cut_Off__c));
            } else {
                listLine.add('-');
                listLine.add('-');
                listLine.add('-');
                listLine.add('-');
            }
            listLine.add(dateToString(operation.Billing_Availability__c));
            listLine.add(dateToString(operation.Remittance_Day__c));
            listLine.add(dateToString(operation.Settlement_Day__c));
            listResults.add(listLine);
        }
        return JSON.serialize(listResults,true);
    }
    
    /**
        Find the operational calendar list and converts it to JSON, a format valid for javascript
        This is called from the page, usually when a filter changes, for agents only
    **/
    @RemoteAction
    global static String loadDetailsRemoteForAgents(String billingPeriod) {
        if (!IS_AGENT) return '';
        User user = [
            SELECT Id,
                Contact.Account.IATA_ISO_Country__c,
                Contact.Account.Remittance_frequency__c,
                Contact.Account.Location_Class__c
            FROM User
            WHERE Id = :UserInfo.getUserId()];
        String country = user.Contact.Account.IATA_ISO_Country__c;
        String frequency = user.Contact.Account.Remittance_frequency__c;
        String operationType = MAP_OPERATION_TYPES.get(user.Contact.Account.Location_Class__c);
        String currencyCode = '';
        
        list<list<String>> listResults = new list<list<String>>();
        for (Operational_Calendar__c operation: queryListOperations(country, frequency, operationType, currencyCode, Integer.ValueOf(billingPeriod))) {
            list<String> listLine = new list<String>();
            listLine.add(nvl(operation.Period_Code__c));
            listLine.add(dateToString(operation.First_Day__c));
            listLine.add(dateToString(operation.Last_Day__c));
            if (operationType.contains('CASS')) {
                listLine.add(dateToString(operation.CASS_reports_Availability__c));
                listLine.add(dateToString(operation.Agent_Correction_Cut_Off__c));
            } else {
                listLine.add('-');
                listLine.add('-');
            }
            listLine.add(dateToString(operation.Billing_Availability__c));
            listLine.add(dateToString(operation.Remittance_Day__c));
            listResults.add(listLine);
        }
        return JSON.serialize(listResults,true);
    }

    private class EventWrapper {
        public Integer id;
        public String title;
        public DateTime start;
        public DateTime finish;
        public Boolean allDay;
        public String url;
        public String className;
        public String color;
        public String backgroundColor;
        public String borderColor;
        public String textColor;
        public String description;
    }
    
    public static String nvl(String input) {
        return input==null? '': input;
    }
    
    public static String dateToString(DateTime input) {
        return input==null? '': input.format('dd MMM YYYY');
    }
}