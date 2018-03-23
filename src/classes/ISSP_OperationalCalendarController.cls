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
    public static final String FIELD_Settlement_Day = MAP_CALENDAR_FIELDS.get('Settlement_Day__c').getDescribe().getLabel();
    public static final String FIELD_Airline_Input_Upload_Cut_Off = MAP_CALENDAR_FIELDS.get('Airline_Input_Upload_Cut_Off__c').getDescribe().getLabel();
    public static final String FIELD_Airline_Correction_Response_Cut_Off = MAP_CALENDAR_FIELDS.get('Airline_Correction_Response_Cut_Off__c').getDescribe().getLabel();
    public static final String FIELD_Remittance_Day = MAP_CALENDAR_FIELDS.get('Remittance_Day__c').getDescribe().getLabel();
    public static final String FIELD_Billing_Availability = MAP_CALENDAR_FIELDS.get('Billing_Availability__c').getDescribe().getLabel();
    public static final String FIELD_Agent_Correction_Cut_Off = MAP_CALENDAR_FIELDS.get('Agent_Correction_Cut_Off__c').getDescribe().getLabel();
    private final map<string,string> ISOFIELDPERLANGUAGE = new map<string,string>{  
        'en' => 'IATA_COUNTRY_EN__c',
        'ko' => 'IATA_Contry_KR__c',
        'fr' => 'IATA_Country_FR__c',
        'it' => 'IATA_Country_IT__c',
        'ja' => 'IATA_Country_JP__c',
        'pt' => 'IATA_Country_PT__c',
        'es' => 'IATA_Country_SP__c',
        'zh' => 'IATA_Country_ZH__c'};
    public static Boolean IS_AIRLINE = queryIsAirline();

    private transient list<EventWrapper> listEvents;
    private transient list<Operational_Calendar__c> listOperations;
    private User user;
    private Contact contact;
    public Account account {get;set;}
    public String defaultCountry {get; set;}
    public Integer minYear {get; set;}
    public Integer maxYear {get; set;}
    
    //Filters
    public Boolean showFilters {get;set;}
    public list<SelectOption> countryOptions {get;set;}
    public map<Id,set<String>> mapFrequencies{get;set;}
    public map<Id,set<String>> mapOperationTypes{get;set;}
    public map<Id,set<String>> mapCurrencies{get;set;}
    
    /**** GETTERS ****/
    public String getMapFrequenciesJson() {
        return JSON.serialize(this.mapFrequencies,true);
    }
    public String getMapOperationTypesJson() {
        return JSON.serialize(this.mapOperationTypes,true);
    }
    public String getMapCurrenciesJson() {
        return JSON.serialize(this.mapCurrencies,true);
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
    
    private static Boolean queryIsAirline() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        return AIRLINE_PROFILES.contains(p.Name);
    }
    /**** END GETTERS ****/
    
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
        this.mapFrequencies = new map<Id,set<String>>();
        this.mapOperationTypes = new map<Id,set<String>>();
        this.mapCurrencies = new map<Id,set<String>>();
        this.defaultCountry = this.account.IATA_ISO_Country__c;
        if (IS_AIRLINE) {
            this.minYear = Date.Today().year()-1;
            this.maxYear = Date.Today().year()+1;
            initPicklistValues();
        } else {
            this.minYear = Date.Today().year();
            this.maxYear = Date.Today().year();
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
                ( SELECT Id, Name FROM IATA_ISO_Countries__r),
                ( SELECT frequency_code__c, Operation_Currency__c, Operation_Type__c
                    FROM Operational_Calendars__r
                    WHERE First_Day__c >= LAST_YEAR)
            FROM AMS_Settlement_System__c
        ];
        this.mapFrequencies = new map<Id,set<String>>();
        this.mapOperationTypes = new map<Id,set<String>>();
        this.mapCurrencies = new map<Id,set<String>>();
        for (AMS_Settlement_System__c op: listOp ) {
            for (IATA_ISO_country__c country: op.IATA_ISO_Countries__r ) {
                // init frequency set
                set<String> setFrequency = this.mapFrequencies.get(country.Id);
                if (setFrequency==null) setFrequency = new set<String>();
                //init setOperationTypes
                set<String> setOperationTypes = this.mapOperationTypes.get(country.Id);
                if (setOperationTypes==null) setOperationTypes = new set<String>();
                //init mapCurrencies
                set<String> setCurrencies = this.mapCurrencies.get(country.Id);
                if (setCurrencies==null) setCurrencies = new set<String>();
                
                for (Operational_Calendar__c operation: op.Operational_Calendars__r ) {
                    if (String.isNotBlank(operation.frequency_code__c)) {
                        setFrequency.add(operation.frequency_code__c);
                    }
                    if (String.isNotBlank(operation.Operation_Type__c)) {
                        setOperationTypes.add(operation.Operation_Type__c);
                    }
                    if (String.isNotBlank(operation.Operation_Currency__c)) {
                        setCurrencies.add(operation.Operation_Currency__c);
                    }
                }
                if (setFrequency.size()>0) {
                    this.mapFrequencies.put(country.Id, setFrequency);
                }
                if (setOperationTypes.size()>0) {
                    this.mapOperationTypes.put(country.Id, setOperationTypes);
                }
                if (setCurrencies.size()>0) {
                    this.mapCurrencies.put(country.Id, setCurrencies);
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
                WHERE Id IN :this.mapOperationTypes.keyset()
            ]) {
            String countryName = (String)country.get(fieldName);
            if (countryName==null) countryName = country.Name;
            this.countryOptions.add(new SelectOption(country.Id, countryName));
        }
    }
    
    /**
        Creates a list of events based on queried operational calendars
        these events are created based on the user type, airlines or agent users
    **/
    private static list<EventWrapper> getOperationalCalendarEvents(String country, String frequency, String operationType, String currencyCode) {
        list<EventWrapper> listEvents = new list<EventWrapper>();

        list<Operational_Calendar__c> listOperations = queryListOperations(country, frequency, operationType, currencyCode);
        for (Operational_Calendar__c operation: listOperations) {
            // The settlement events are shown only for airlines
            if (IS_AIRLINE) {
                EventWrapper event1 = new EventWrapper();
                event1.title = FIELD_Settlement_Day + ' - ' + operation.Operation_Currency__c;
                event1.start = operation.Settlement_Day__c;
                event1.allDay = true;
                event1.className = 'settlementEvent';
                listEvents.add(event1);
                EventWrapper event2 = new EventWrapper();
                event2.title = FIELD_Airline_Input_Upload_Cut_Off + ' - ' + operation.Operation_Currency__c;
                event2.start = operation.Airline_Input_Upload_Cut_Off__c;
                event2.allDay = true;
                event2.className = 'airlineUploadEvent';
                listEvents.add(event2);
                EventWrapper event3 = new EventWrapper();
                event3.title = FIELD_Airline_Correction_Response_Cut_Off + ' - ' + operation.Operation_Currency__c;
                event3.start = operation.Airline_Correction_Response_Cut_Off__c;
                event3.allDay = true;
                event3.className = 'airlineCorrectionEvent';
                listEvents.add(event3);
            } else {
                EventWrapper event1 = new EventWrapper();
                event1.title = FIELD_Remittance_Day + ' - ' + operation.Operation_Currency__c;
                event1.start = operation.Remittance_Day__c;
                event1.allDay = true;
                event1.className = 'remittanceEvent';
                listEvents.add(event1);
                EventWrapper event2 = new EventWrapper();
                event2.title = FIELD_Billing_Availability + ' - ' + operation.Operation_Currency__c;
                event2.start = operation.Billing_Availability__c;
                event2.allDay = true;
                event2.className = 'billingAvailabilityEvent';
                listEvents.add(event2);
                EventWrapper event3 = new EventWrapper();
                event3.title = FIELD_Agent_Correction_Cut_Off + ' - ' + operation.Operation_Currency__c;
                event3.start = operation.Agent_Correction_Cut_Off__c;
                event3.allDay = true;
                event3.className = 'agentCorrectionEvent';
                listEvents.add(event3);
            }
        }
        return listEvents;
    }
    
    /**
        Query the operational calendar records based on input filters
    **/
    private static list<Operational_Calendar__c> queryListOperations(String country, String frequency, String operationType, String currencyCode) {
        if (String.isBlank(country)) {
            throw new OperationalCalendarException(Label.ISSP_OperationalCalendar_Country_Filter_Required);
        }
        if (String.isBlank(operationType)) {
            throw new OperationalCalendarException(Label.ISSP_OperationalCalendar_BSPCASS_Filter_Required);
        }
        
        String query = 'SELECT Id,RecordTypeId,First_Day__c,Frequency_code__c,HAR_Day__c,ISS_operation__c,Last_Day__c,Name,Operation_Code__c,'
            + ' Operation_Currency__c,Operation_Period_code__c,Operation_Type__c,Period_Code__c,Remittance_Day__c,Settlement_Day__c,'
            + ' EP_Settlement_date__c, Billing_Availability__c, Airline_Input_Upload_Cut_Off__c, CASS_reports_Availability__c,'
            + ' Agent_Correction_Cut_Off__c, Airline_Correction_Response_Cut_Off__c '
            + ' FROM Operational_Calendar__c'
            + ' WHERE ISS_operation__c IN ('
            + '     SELECT AMS_Settlement_System__c '
            + '     FROM IATA_ISO_Country__c'
            + '     WHERE Id = :country)'
            + ' AND First_Day__c >= LAST_YEAR'
            + ' AND Operation_Type__c = \'' + operationType + '\'';
            
            if (String.isNotBlank(frequency)) {
                query += ' AND frequency_code__c = \'' + frequency + '\'';
            }
            if (String.isNotBlank(currencyCode)) {
                query += ' AND Operation_Currency__c = \'' + currencyCode + '\'';
            }
            System.debug('QUERY: ' + query);
            return Database.query(query);
    }
    
    /**
        This method only gets the events to show an agent user, it will be executed only once at the beggining
    **/
    public void loadEventsForAgent() {
        this.listEvents = new list<EventWrapper>();
        String country = this.account.IATA_ISO_Country__c;
        String frequency = this.account.Remittance_frequency__c;
        String operationType = MAP_OPERATION_TYPES.get(this.account.Location_Class__c);
        this.listEvents.addAll(getOperationalCalendarEvents(country, frequency, operationType, ''));
        for (EventWrapper event: this.listEvents) {
            if (event.start!=null && event.start.year() < this.minYear) this.minYear = event.start.year();
            if (event.start!=null && event.start.year() > this.maxYear) this.maxYear = event.start.year();
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
        list<EventWrapper> listEvents = getOperationalCalendarEvents(country, frequency, operationType, currencyCode);
        return JSON.serialize(listEvents,true);
    }
    
    @RemoteAction
    global static String loadDetailsRemote(String country, String frequency, String operationType, String currencyCode) {
        if (!IS_AIRLINE) return '';
        list<Operational_Calendar__c> listOperations = queryListOperations(country, frequency, operationType, currencyCode);
        return JSON.serialize(listOperations,true);
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
    }
}