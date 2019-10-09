/**
    Controller class used in three different pages:
    ISSP_OperationalCaledar: showing the Operational calendar records in a big Calendar
    ISSP_OperationalCaledarMini: showing the Operational calendar records in a mini Calendar
    ISSP_OperationalCaledarDetail: showing the Operational calendar records in a table
**/
global without sharing class ISSP_OperationalCalendarController {
    
    public class OperationalCalendarException extends Exception {}
    
    private static final map<String,Schema.RecordTypeInfo> MAP_OP_CALENDAR_INFO=Schema.SObjectType.Operational_Calendar__c.getRecordTypeInfosByDeveloperName();
    public static final Schema.RecordTypeInfo RT_ICCS_CALENDAR = MAP_OP_CALENDAR_INFO.get('ICCS_Calendar');
    public static final Schema.RecordTypeInfo RT_ISS_CALENDAR = MAP_OP_CALENDAR_INFO.get('ISS_Calendar');
    public static final Schema.RecordTypeInfo RT_SIS_CALENDAR = MAP_OP_CALENDAR_INFO.get('SIS_Calendar');
    // all fields in object operational calendar in a string ready for a query
    public static final String ALL_FIELDS = String.join(new list<String>(SObjectType.operational_Calendar__c.fields.getMap().keyset()),',');

    public static final set<String> SIS_SUBSTATUS = new set<String>{'ISPA Airline','ISPA Supplier','ISUA Airline','ISUA Supplier'};
    public static final list<String> LIST_MULTIDOWNALOAD_TYPES = new list<String>{
        'BSP International',
        'BSP Domestic',
        'CASS Export',
        'CASS Import'
    };

    public static final list<String> AIRLINE_PROFILES = new list<String>();
    public static final list<String> AGENT_PROFILES = new list<String>();
    static {
        try {
            AIRLINE_PROFILES.addAll(ISSP_CS__c.getValues('ISS OperationalCalendar Airline Profil').Value__c.split(','));
        } catch(Exception e) {
            System.debug('No profiles found in ISSP_CS.ISS OperationalCalendar Airline Profil');
        }
        try {
            AGENT_PROFILES.addAll(ISSP_CS__c.getValues('ISS OperationalCalendar Agency Profile').Value__c.split(','));
        } catch(Exception e) {
            System.debug('No profiles found in ISSP_CS.ISS OperationalCalendar Agency Profile');
        }
    }
    public static final map<String,String> MAP_OPERATION_TYPES = new map<String,String>{
        'P' => 'BSP International',
        'D' => 'BSP Domestic',
        'C' => 'CASS Export',
        'R' => 'CASS Export',
        'I' => 'CASS Import'
    };
    // These countries in the Caribbean region have a special treatment in the query
    public static final map<Id,IATA_ISO_Country__c> SPECIAL_CASE_COUNTRIES = new map<Id,IATA_ISO_Country__c>(
        [SELECT Id, ISO_Code__c FROM IATA_ISO_Country__c WHERE AMS_Settlement_System__r.Name = 'BSP-BQ']);

    // Special Case for CNS, only United States for the moment
    public static final set<Id> SET_CNS_COUNTRIES = new map<Id,IATA_ISO_Country__c>([SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c IN ('US')]).keyset();

    public static final Map<String, Schema.SObjectField> MAP_CALENDAR_FIELDS =
        Schema.getGlobalDescribe().get('operational_Calendar__c').getDescribe().fields.getMap();
    public static final String FIELD_Settlement_Day = MAP_CALENDAR_FIELDS.get('Settlement_Day__c').getDescribe().getLabel();
    public static final String FIELD_Airline_Input_Upload_Cut_Off = MAP_CALENDAR_FIELDS.get('Airline_Input_Upload_Cut_Off__c').getDescribe().getLabel();
    public static final String FIELD_Airline_Correction_Response_Cut_Off = MAP_CALENDAR_FIELDS.get('Airline_Correction_Response_Cut_Off__c').getDescribe().getLabel();
    public static final String FIELD_Remittance_Day = MAP_CALENDAR_FIELDS.get('Remittance_Day__c').getDescribe().getLabel();
    public static final String FIELD_Billing_Availability = MAP_CALENDAR_FIELDS.get('Billing_Availability__c').getDescribe().getLabel();
    public static final String FIELD_Agent_Correction_Cut_Off = MAP_CALENDAR_FIELDS.get('Agent_Correction_Cut_Off__c').getDescribe().getLabel();
    public static final String FIELD_CASS_reports_Availability = MAP_CALENDAR_FIELDS.get('CASS_reports_Availability__c').getDescribe().getLabel();
    
    public static final String THIS_PROFILE = String.ValueOf(UserInfo.getProfileId()).left(15);
    public static Boolean IS_AIRLINE = AIRLINE_PROFILES.contains(THIS_PROFILE);
    public static Boolean IS_AGENT = AGENT_PROFILES.contains(THIS_PROFILE);
    public static map<String,String> MAP_FREQUENCIES;
    static {
        MAP_FREQUENCIES = new map<String,String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get('Remittance_frequency__c').getDescribe();
        for (Schema.PicklistEntry entry: fieldResult.getPicklistValues()) {
            MAP_FREQUENCIES.put(entry.getValue(),entry.getLabel());
        }
    }
    public static map<String,String> MAP_COUNTRIES;
    static {
        map<string,string> ISOFIELDPERLANGUAGE = new map<string,string>{
            'en' => 'IATA_COUNTRY_EN__c',
            'ko' => 'IATA_Contry_KR__c',
            'fr' => 'IATA_Country_FR__c',
            'it' => 'IATA_Country_IT__c',
            'ja' => 'IATA_Country_JP__c',
            'pt' => 'IATA_Country_PT__c',
            'es' => 'IATA_Country_SP__c',
            'zh' => 'IATA_Country_ZH__c'};

        MAP_COUNTRIES = new map<String,String>();
        String locale = UserInfo.getLanguage().left(2).toLowerCase();
        locale = ISOFIELDPERLANGUAGE.containsKey(locale) ? locale: 'en';
        for (IATA_ISO_Country__c country: IATAIsoCountryDAO.getIsoCountries()) {
            try {
                String fieldName = ISOFIELDPERLANGUAGE.get(locale);
                String translatedName = String.ValueOf(country.get(fieldName));
                translatedName = String.isEmpty(translatedName)? country.Name: translatedName;
                MAP_COUNTRIES.put(country.Id,translatedName);
            } catch (Exception e) {
                MAP_COUNTRIES.put(country.Id,country.Name);
            }
        }
    }

    private transient list<EventWrapper> listEvents;
    private transient list<Operational_Calendar__c> listOperations;
    private User user;
    private Contact contact;
    public Account account {get;set;}
    public String defaultOperationType {get; set;}
    public String defaultOperationSubtype {get; set;}
    public String defaultCountry {get; set;}
    public String defaultFrequency {get; set;}
    public Date maxDate {get; set;}
    public Date minDate {get; set;}
    
    //Filters
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
        return JSON.serialize(MAP_FREQUENCIES,true);
    }
    public String getMapCountriesJSON() {
        return JSON.serialize(MAP_COUNTRIES,true);
    }
    public String getSisOptionsJSON() {
        list<String> listSisTypes = new list<String>();
        if (getIsSISAccount()) {
            listSisTypes.add('SIS');
            if (getIsSISICHAccount()) listSisTypes.add('SIS+ICH');
            if (getIsSISACHAccount()) listSisTypes.add('SIS+ACH');
        }
        return JSON.serialize(listSisTypes,true);
    }
    public Boolean getIsMultiButtonVisible() {
        return IS_AIRLINE || this.account.Location_Type__c=='GE';
    }

    /**
        True if this account is able to see SIS information
     */
    public Boolean getIsSISAccount() {
        return (this.account.SIS_Status__c == 'Active' && SIS_SUBSTATUS.contains(this.account.SIS_Sub_Status__c))
            || (this.account.Top_Parent__r.SIS_Status__c == 'Active' && SIS_SUBSTATUS.contains(this.account.Top_Parent__r.SIS_Sub_Status__c));
    }

    /**
        True if this account is able to see ACH information
     */
    public Boolean getIsSISICHAccount() {
        return (this.account.ICH_Member__c || this.account.Top_Parent__r.ICH_Member__c);
    }

    /**
        True if this account is able to see ICH information
     */
    public Boolean getIsSISACHAccount() {
        return (this.account.ACH_Member__c || this.account.Top_Parent__r.ACH_Member__c);
    }

    /**
        True if this account is able to see ICCS information
     */
    public Boolean getIsICCSAccount() {
        return this.account.ICCS_Membership_Status__c == 'Active'
            || this.account.ICCS_Membership_Status__c == 'Member'
            || this.account.Top_Parent__r.ICCS_Membership_Status__c == 'Active'
            || this.account.Top_Parent__r.ICCS_Membership_Status__c == 'Member';
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
            SELECT Id, Profile.Name,
                ContactId, Contact.Id,
                Contact.CNS_Contact__c,
                Contact.AccountId,
                Contact.Account.Id,
                Contact.Account.IATA_ISO_Country__c,
                Contact.Account.Remittance_frequency__c,
                Contact.Account.Location_Class__c,
                Contact.Account.Location_Type__c,
                Contact.Account.SIS_Status__c,
                Contact.Account.SIS_Sub_Status__c,
                Contact.Account.ICH_Member__c,
                Contact.Account.ACH_Member__c,
                Contact.Account.ICCS_Membership_Status__c,
                Contact.Account.Top_Parent__r.SIS_Status__c,
                Contact.Account.Top_Parent__r.SIS_Sub_Status__c,
                Contact.Account.Top_Parent__r.ICH_Member__c,
                Contact.Account.Top_Parent__r.ACH_Member__c,
                Contact.Account.Top_Parent__r.ICCS_Membership_Status__c
            FROM User
            WHERE Id = :UserInfo.getUserId()];
        this.contact = this.user.contact;
        this.account = this.user.contact.account;
        this.defaultCountry = this.account.IATA_ISO_Country__c;
        this.defaultFrequency = this.account.Remittance_frequency__c;
        this.maxDate = Date.newInstance(Date.Today().year()+2, 1, 1);
        this.minDate = Date.newInstance(Date.Today().year()-1, 1, 1);
        initPicklistValues();
        initAdvFilters();
    }
    
    public Set<Id> getSetIds(list<sObject> listObject) {
        try {
            return (new Map<Id,SObject>(listObject)).keySet();
        } catch(Exception e) {
            return new set<Id>();
        }
    }

    public String getDescription() {
        String translatedCountry = MAP_COUNTRIES.get(this.defaultcountry);
        return translatedCountry;
    }

    /**
        Initial values for picklists used in filter section
        this section is only visilbe for airline users
    **/
    public void initPicklistValues() {
        this.setFilter = new set<String>();
        list<String> listResult;
        // finally SIS
        if (getIsSISAccount())  {
            listResult = initPicklistValuesSIS();
            if (!listResult.isEmpty()) {
                this.setFilter.addAll(listResult);
                // set default values for filters
                this.defaultOperationType = 'SIS';
                if (getIsSISICHAccount()) {
                    this.defaultOperationSubtype = 'SIS+ICH';
                } else if (getIsSISACHAccount()) {
                    this.defaultOperationSubtype = 'SIS+ACH';
                } else {
                    this.defaultOperationSubtype = 'SIS';
                }
            } 
        }
        // next ICCS
        if (getIsICCSAccount()) {
            listResult = initPicklistValuesICCS();
            if (!listResult.isEmpty()) {
                this.setFilter.addAll(listResult);
                this.defaultOperationType='ICCS';
            }
        }
        // first BSP/CASS + CNS
        listResult = initPicklistValuesBSPCASS();
        if (!listResult.isEmpty()) {
            this.setFilter.addAll(listResult);
            if (this.defaultOperationType!='CNS') {
                this.defaultOperationType='BSP/CASS';
                this.defaultOperationSubtype = nvl(MAP_OPERATION_TYPES.get(this.account.Location_Class__c));
            }
        }
    }

    public list<String> initPicklistValuesSIS() {
        list<String> listResult = new list<String>();
        // adding remmitance frequencies only for SIS
        for (AggregateResult result: [
                SELECT frequency_code__c
                FROM Operational_Calendar__c
                WHERE RecordTypeId = :RT_SIS_CALENDAR.getRecordTypeId()
                AND Submission_Open__c >= LAST_YEAR
                AND Visible_on_the_portal__c=true
                GROUP BY frequency_code__c
                ORDER BY frequency_code__c ASC]){
            String str = 'SIS' + ',' + result.get('frequency_code__c');
            listResult.add(str);
        }
        return listResult;
    }

    public list<String> initPicklistValuesICCS() {
        list<String> listResult = new list<String>();
        // adding remmitance frequencies only for SIS
        for (AggregateResult result: [
                SELECT cycle__c, Country__c, frequency_code__c, Operation_Currency__c
                FROM Operational_Calendar__c
                WHERE RecordTypeId = :RT_ICCS_CALENDAR.getRecordTypeId()
                AND First_Day__c >= LAST_YEAR
                AND Visible_on_the_portal__c=true
                GROUP BY cycle__c, Country__c, frequency_code__c, Operation_Currency__c
                ORDER BY cycle__c, Country__c, frequency_code__c, Operation_Currency__c ASC]){
            String str = 'ICCS' + ',' + result.get('cycle__c') + ',' + result.get('Country__c') + ',' + result.get('frequency_code__c') + ',' + result.get('Operation_Currency__c');
            listResult.add(str);
        }
        return listResult;
    }

    public list<String> initPicklistValuesBSPCASS() {
        // mapFrequencies, its a relation between countries and their frequencies
        list<AMS_Settlement_System__c> listOp = [
            SELECT Id, Name,  
                ( SELECT Id FROM IATA_ISO_Countries__r),
                ( SELECT Id FROM CASS_COUNTRIES__r),
                ( SELECT frequency_code__c, Operation_Currency__c, Operation_Type__c, Operation_Code__c
                    FROM Operational_Calendars__r
                    WHERE RecordTypeId = :RT_ISS_CALENDAR.getRecordTypeId()
                    AND First_Day__c >= LAST_YEAR
                    AND Visible_on_the_portal__c=true)
            FROM AMS_Settlement_System__c 
        ];
        
        list<String> listResult = new list<String>();
        set<Id> setCountryId = new set<Id>();
        for (AMS_Settlement_System__c op: listOp ) {
            Set<Id> listBSPCountries = getSetIds(op.IATA_ISO_Countries__r);
            Set<Id> listCASSCountries = getSetIds(op.CASS_COUNTRIES__r);
            for (Operational_Calendar__c operation: op.Operational_Calendars__r ) {
                list<Id> listCountryId = new list<Id>();
                if (operation.Operation_Type__c.contains('BSP')) {
                    listCountryId.addAll(listBSPCountries);
                }
                if (operation.Operation_Type__c.contains('CASS')) {
                    listCountryId.addAll(listCASSCountries);
                }
                for (Id countryId: listCountryId) {
                    String groupType = 'BSP/CASS';
                    //special case for CNS, instead of being CASS it is marked as CNS
                    if (SET_CNS_COUNTRIES.contains(countryId) && operation.Operation_Type__c.contains('CASS')) {
                        groupType = 'CNS';
                        if (IS_AGENT && this.user.Contact.CNS_Contact__c) {
                            this.defaultOperationType = 'CNS';
                            this.defaultOperationSubtype = operation.Operation_Type__c;
                            this.defaultCountry = countryId;
                        }
                    }
                    // special case for caribean countries, use only currencies from operations 
                    //with the OperationCode starting with the country Code
                    if (SPECIAL_CASE_COUNTRIES.containsKey(countryId)) {
                        String isocode=SPECIAL_CASE_COUNTRIES.get(countryId).ISO_Code__c;
                        if (operation.Operation_Code__c!=null && operation.Operation_Code__c.startsWith(isocode)) {
                            String str = groupType + ',' + operation.Operation_Type__c + ',' + countryId + ',' + operation.frequency_code__c + ',' + operation.Operation_Currency__c;
                            listResult.add(str);
                            setCountryId.add(countryId);
                        }
                    } else {
                        String str = groupType + ',' + operation.Operation_Type__c + ',' + countryId + ',' + operation.frequency_code__c + ',' + operation.Operation_Currency__c;
                        listResult.add(str);
                        setCountryId.add(countryId);
                    }
                }
            }
        }
        // countries
        map<String,IATA_ISO_Country__c> mapNameCountry = new map<String,IATA_ISO_Country__c>();
        for (IATA_ISO_Country__c country : IATAIsoCountryDAO.getIsoCountriesByIds(setCountryId)) {
            String countryName = country.Name;
            if (countryName==null) countryName = country.Name;
            mapNameCountry.put(countryName, country);
        }
        // create the country list ordered
        this.countryOptions = new list<SelectOption>();
        this.countryOptions.add(new SelectOption('', Label.ANG_ISSP_Picklist_None));
        list<String> listNameCountries = new list<String>(mapNameCountry.keyset());
        listNameCountries.sort();
        for (String countryName: listNameCountries ) {
            IATA_ISO_Country__c country = mapNameCountry.get(countryName);
            this.countryOptions.add(new SelectOption(country.Id, countryName));
        }
        return listResult;
    }

    /**
        Generate the text inside the popup when the mouse is over
    **/
    private static String getEventDescription(Operational_Calendar__c operation, Boolean isAirline) {
        Schema.FieldSet fieldset = null;
        String operationType = nvl(operation.Operation_Type__c);
        if (operation.RecordTypeId==RT_ISS_CALENDAR.getRecordTypeId()) {
            if (operationType.contains('BSP')) {
                if (IS_AIRLINE) {
                    fieldset = SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Hover_For_BSP_Airline;
                }
                if (IS_AGENT) {
                    fieldset = SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Hover_For_BSP_Agency;
                }
            }
            if (operationType.contains('CASS')) {
                if (IS_AIRLINE) {
                    fieldset = SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Hover_For_CASS_Airline;
                }
                if (IS_AGENT) {
                    fieldset = SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Hover_For_CASS_Agency;
                }
            }
        }
        if (operation.RecordTypeId==RT_SIS_CALENDAR.getRecordTypeId()) {
            fieldset = SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Hover_For_SIS;
        }
        String description = '';
        if (fieldset!=null) {
            for(Schema.FieldSetMember f : fieldset.getFields()) {
                String fieldName = f.getFieldPath();
                String fieldLabel = f.getLabel();
                String fieldValue = '<date>' + getFieldValue(operation, f) + '</date>';
                description+= '<strong>' + fieldLabel + '</strong> ' + fieldValue + '</br>';
            }
        }
        return description;
    } 
    
    /**
        Creates a list of events based on queried operational calendars
        these events are created based on the user type, airlines or agent users
    **/
    private static list<EventWrapper> getOperationalCalendarEvents(list<Operational_Calendar__c> listOperations, Boolean isGrouped, String sisType) {
        list<EventWrapper> listEvents = new list<EventWrapper>();
        //using maps for ICCS, it requires to group events by day
        map<Date,EventWrapper> mapICCSEvent1 = new map<Date,EventWrapper>();
        map<Date,EventWrapper> mapICCSEvent2 = new map<Date,EventWrapper>();
        for (Operational_Calendar__c operation: listOperations) {
            String title = operation.Period_Code__c;
            String description = getEventDescription(operation, IS_AIRLINE);
            // The settlement events are shown only for airlines
            if (operation.RecordTypeId==RT_ISS_CALENDAR.getRecordTypeId()) {
                String operationType = nvl(operation.Operation_Type__c);
                if (IS_AIRLINE) {
                    EventWrapper event1 = new EventWrapper();
                    event1.title = getEventTitle(operation, FIELD_Settlement_Day, isGrouped);
                    event1.start = operation.Settlement_Day__c;
                    event1.allDay = true;
                    event1.className = 'settlementEvent';
                    event1.description = description;
                    listEvents.add(event1);
                    if (operationType.contains('CASS')) {
                        EventWrapper event2 = new EventWrapper();
                        event2.title = getEventTitle(operation, FIELD_Airline_Input_Upload_Cut_Off, isGrouped);
                        event2.start = operation.Airline_Input_Upload_Cut_Off__c;
                        event2.allDay = true;
                        event2.className = 'airlineUploadEvent';
                        event2.description = description;
                        listEvents.add(event2);
                        EventWrapper event3 = new EventWrapper();
                        event3.title = getEventTitle(operation, FIELD_Airline_Correction_Response_Cut_Off, isGrouped);
                        event3.start = operation.Airline_Correction_Response_Cut_Off__c;
                        event3.allDay = true;
                        event3.className = 'airlineCorrectionEvent';
                        event3.description = description;
                        listEvents.add(event3);
                    }
                } else {
                    EventWrapper event1 = new EventWrapper();
                    event1.title = getEventTitle(operation, FIELD_Remittance_Day, isGrouped);
                    event1.start = operation.Remittance_Day__c;
                    event1.allDay = true;
                    event1.className = 'remittanceEvent';
                    event1.description = description;
                    listEvents.add(event1);
                    EventWrapper event2 = new EventWrapper();
                    event2.title = getEventTitle(operation, FIELD_Billing_Availability, isGrouped);
                    event2.start = operation.Billing_Availability__c;
                    event2.allDay = true;
                    event2.className = 'billingAvailabilityEvent';
                    event2.description = description;
                    listEvents.add(event2);
                    if (operationType.contains('CASS')) {
                        EventWrapper event3 = new EventWrapper();
                        event3.title = getEventTitle(operation, FIELD_Agent_Correction_Cut_Off, isGrouped);
                        event3.start = operation.Agent_Correction_Cut_Off__c;
                        event3.allDay = true;
                        event3.className = 'agentCorrectionEvent';
                        event3.description = description;
                        listEvents.add(event3);
                        EventWrapper event4 = new EventWrapper();
                        event4.title = getEventTitle(operation, FIELD_CASS_reports_Availability, isGrouped);
                        event4.start = operation.CASS_reports_Availability__c ;
                        event4.allDay = true;
                        event4.className = 'CASSReportsEvent';
                        event4.description = description;
                        listEvents.add(event4);
                    }
                }
            }
            if (operation.RecordTypeId==RT_SIS_CALENDAR.getRecordTypeId()) {
                EventWrapper event1 = new EventWrapper();
                event1.title = 'SIS Submission Open';
                event1.start = operation.Submission_Open__c;
                event1.allDay = true;
                event1.className = 'event_1';
                event1.description = description;
                listEvents.add(event1);
                EventWrapper event2 = new EventWrapper();
                event2.title = 'SIS Submission Deadline';
                event2.start = operation.Submission_Deadline__c;
                event2.allDay = true;
                event2.className = 'event_2';
                event2.description = description;
                listEvents.add(event2);
                EventWrapper event3 = new EventWrapper();
                event3.title = 'SIS Billing Output Generation';
                event3.start = operation.Billing_Output_Generation__c;
                event3.allDay = true;
                event3.className = 'event_3';
                event3.description = description;
                listEvents.add(event3);
                EventWrapper event4 = new EventWrapper();
                event4.title = 'SIS Supporting Documents Link Deadline';
                event4.start = operation.Supporting_Documents_Link_Deadline__c;
                event4.allDay = true;
                event4.className = 'event_4';
                event4.description = description;
                listEvents.add(event4);
                if (sisType!=null && sisType.contains('ICH')) {
                    EventWrapper event5 = new EventWrapper();
                    event5.title = 'SIS ICH Settlement Day';
                    event5.start = operation.Settlement_Day_Associated_Members__c;
                    event5.allDay = true;
                    event5.className = 'event_5';
                    event5.description = description;
                    listEvents.add(event5);
                }
                if (sisType!=null && sisType.contains('ACH')) {
                    EventWrapper event5 = new EventWrapper();
                    event5.title = 'SIS ACH Settlement Day';
                    event5.start = operation.Settlement_Day_ACH_Transactions__c;
                    event5.allDay = true;
                    event5.className = 'event_5';
                    event5.description = description;
                    listEvents.add(event5);
                }
            }
            if (operation.RecordTypeId==RT_ICCS_CALENDAR.getRecordTypeId()) {
                String countryName = MAP_COUNTRIES.get(operation.Country__c);
                //iccs event 1
                Date key1 = operation.ICCS_Cycle_Start_Date__c;
                if (key1!=null) {
                    EventWrapper event1 = mapICCSEvent1.get(key1);
                    if (event1==null) {
                        event1 = new EventWrapper();
                        event1.title = 'ICCS Cycle Start Date';
                        event1.start = key1;
                        event1.allDay = true;
                        event1.className = 'event_1';
                        event1.description = countryName;
                    } else {
                        event1.description += '</br>' + countryName;
                    }
                    mapICCSEvent1.put(key1, event1);
                }
                //iccs event 2
                Date key2 = operation.ICCS_Settlement_Date__c;
                if (key2!=null) {
                    EventWrapper event2 = mapICCSEvent2.get(key2);
                    if (event2==null) {
                        event2 = new EventWrapper();
                        event2.title = 'ICCS Settlement Date';
                        event2.start = key2;
                        event2.allDay = true;
                        event2.className = 'event_2';
                        event2.description = countryName;
                    } else {
                        event2.description += '</br>' + countryName;
                    }
                    mapICCSEvent2.put(key2, event2);
                }
            }
        }
        listEvents.addAll(mapICCSEvent1.values());
        listEvents.addAll(mapICCSEvent2.values());
        return listEvents;
    }
    
    public static String getEventTitle(Operational_Calendar__c operation, String eventName, Boolean isGrouped) {
        if (isGrouped) {
            String operationType = nvl(operation.Operation_Type__c);
            String frequency = MAP_FREQUENCIES.get(operation.frequency_code__c);
            return eventName + '-' + operationType + ' ' + frequency + ' ' + operation.Operation_Currency__c;
        } else {
            return eventName + ' - ' + operation.Operation_Currency__c;
        }
    }
    
    /**
        Query the operational calendar records based on input filters
    **/
    public static list<Operational_Calendar__c> queryListOperations(String operationType, String cycle, String country, String frequency, String currencyCode, Integer billingPeriod) {
        if (String.isBlank(operationType)) {
            throw new OperationalCalendarException(Label.ISSP_OperationalCalendar_Type_Filter_Required);
        }
        if ((operationType.contains('BSP') || operationType.contains('CASS')) && String.isBlank(country)) {
            throw new OperationalCalendarException(Label.ISSP_OperationalCalendar_Country_Filter_Required);
        }
        return runQuery(operationType, cycle, country, frequency, currencyCode, billingPeriod);
    }
    
    /**
        Generate the query string and runs it, used only by queryListOperations()
    **/
    private static list<Operational_Calendar__c> runQuery(String operationType, String cycle, String country, String frequency, String currencyCode, Integer billingPeriod) {
        String query = '';
        Schema.FieldSet fieldset = getDescriptionFieldSet(IS_AIRLINE, operationType);
        if (operationType.contains('BSP') || operationType.contains('CASS')) {
            query = getBspCassQuery(operationType, country, frequency, currencyCode, billingPeriod);
        }
        if (operationType.contains('SIS')) {
            query = getSISQuery(frequency, billingPeriod);
        }
        if (operationType.contains('ICCS')) {
            query = getICCSQuery(cycle, country, billingPeriod);
        }
        System.debug('QUERY: ' + query);
            return Database.query(query);
    }

    private static String getBillingPeriodCondition(Integer billingPeriod, String fieldName) {
        String query = '';
        if (billingPeriod==null) {
            query = '';
        } else if (billingPeriod==Date.today().year()) {
            query += ' AND ' + fieldName + ' = THIS_YEAR';
        } else if (billingPeriod==Date.today().year()+1) {
            query += ' AND ' + fieldName + ' = NEXT_YEAR';
        } else if (billingPeriod==Date.today().year()-1) {
            query += ' AND ' + fieldName + ' = LAST_YEAR';
        } else if ( billingPeriod >= 1 && billingPeriod <= 12 ) {
            query += ' AND ' + fieldName + ' = THIS_YEAR';
            query += ' AND CALENDAR_MONTH(First_Day__c) = ' + billingPeriod;
        } else {
            query += ' AND ' + fieldName + ' >= LAST_YEAR';
        }
        return query;
    }

    private static String getBspCassQuery(String operationType, String country, String frequency, String currencyCode, Integer billingPeriod) {
        String query = 'SELECT ' + ALL_FIELDS
            + ' FROM Operational_Calendar__c'
            + ' WHERE Visible_on_the_portal__c = true';

        // for BSP types it's used a joint object (AMS_Settlement_System__c) to connect to ISO Countries
        if (operationType.contains('BSP')) {
            query+=' AND ISS_operation__c IN ('
                + '     SELECT AMS_Settlement_System__c' +
                + '     FROM IATA_ISO_Country__c'
                + '     WHERE Id = \'' + country + '\')'
                + ' AND RecordtypeId = \'' + RT_ISS_CALENDAR.getRecordtypeId() + '\''
                + ' AND Operation_Type__c = \'' + operationType + '\'';
            // for some countries we have to find only those records where the operation code starts with the country code
            if (SPECIAL_CASE_COUNTRIES.containsKey(country)) {
                String isocode=SPECIAL_CASE_COUNTRIES.get(country).ISO_Code__c;
                query += ' AND Operation_Code__c LIKE \'' + isocode + '%\'';
            }
        // for CASS types it's used a joint object (AMS_Settlement_System__c) to connect to ISO Countries
        // but with a different lookup field than in BSP
        } else if (operationType.contains('CASS')) {
            query+=' AND ISS_operation__c IN ('
                + '     SELECT AMS_Settlement_System_CASS__c' +
                + '     FROM IATA_ISO_Country__c'
                + '     WHERE Id = \'' + country + '\')'
                + ' AND RecordtypeId = \'' + RT_ISS_CALENDAR.getRecordtypeId() + '\''
                + ' AND Operation_Type__c = \'' + operationType + '\'';
        }
        // Rest of the conditions
        if (String.isNotBlank(frequency)) {
            query += ' AND frequency_code__c = \'' + frequency + '\'';
        }
        if (String.isNotBlank(currencyCode)) {
            query += ' AND Operation_Currency__c = \'' + currencyCode + '\'';
        }
        query += getBillingPeriodCondition(billingPeriod,'First_Day__c');
        if (IS_AIRLINE) {
            query += ' ORDER BY Settlement_Day__c ASC';
        } else {
            query += ' ORDER BY Remittance_Day__c ASC';
        }
        return query;
    }

    private static String getSISQuery(String frequency, Integer billingPeriod) {
        String query = 'SELECT ' + ALL_FIELDS
            + ' FROM Operational_Calendar__c'
            + ' WHERE Visible_on_the_portal__c = true'
            + ' AND RecordtypeId = \'' + RT_SIS_CALENDAR.getRecordtypeId() + '\'';
        if (String.isNotBlank(frequency)) {
            query += ' AND frequency_code__c = \'' + frequency + '\'';
        }
        query += getBillingPeriodCondition(billingPeriod,'Submission_Open__c');
        return query;
    }

    private static String getICCSQuery(String cycle, String country, Integer billingPeriod) {
        String query = 'SELECT ' + ALL_FIELDS
            + ' FROM Operational_Calendar__c'
            + ' WHERE Visible_on_the_portal__c = true'
            + ' AND RecordtypeId = \'' + RT_ICCS_CALENDAR.getRecordtypeId() + '\'';
        if (String.isNotBlank(cycle)) {
            query += ' AND Cycle__c = \'' + cycle + '\'';
        }
        if (String.isNotBlank(country)) {
            query += ' AND Country__c = \'' + country + '\'';
        }
        query += getBillingPeriodCondition(billingPeriod,'First_Day__c');
        query += ' ORDER BY ICCS_Settlement_Date__c ASC';
        return query;
    }

    /**
        Find the event list and converts it to JSON, a format valid for javascript
        This is called from the page, usually when a filter changes, only allowed to airlines
    **/
    @RemoteAction
    global static String loadEventsRemote(String operationType, String cycle, String country, String frequency, String currencyCode) {
        list<Operational_Calendar__c> listOperations = queryListOperations(operationType, cycle, country, frequency, currencyCode, null);
        list<EventWrapper> listEvents = getOperationalCalendarEvents(listOperations, false, operationType);
        return JSON.serialize(listEvents,true);
    }
    
    /**
        Get the event list for the mini calendar
        This list is grouped by day, so there is only one event per day and each
        individual event is described in the hover
    **/
    public String getListEventsJSONGrouped() {
        String country = this.defaultCountry;
        String frequency = this.defaultFrequency;
        String cycle = null;
        String currencyCode = null;
        Integer period = null;
        list<Operational_Calendar__c> listOperations = new list<Operational_Calendar__c>();
        list<String> listTypes = new list<String>();
        listTypes.add('BSP International');
        listTypes.add('BSP Domestic');
        listTypes.add('CASS Export');
        listTypes.add('CASS Import');
        if (getIsSISAccount()) {
            if (getIsSISICHAccount()) {
                listTypes.add('SIS+ICH');
            } else if (getIsSISACHAccount()) {
                listTypes.add('SIS+ACH');
            } else {
                listTypes.add('SIS');
            }
        }
        if (getIsICCSAccount()) {
            listTypes.add('ICCS');
        }
        for (String operationType: listTypes) {
            listOperations.addAll(queryListOperations(operationType, cycle, country, frequency, currencyCode,null));
        }
        list<EventWrapper> listEvents = getOperationalCalendarEvents(listOperations, true, null);
        return JSON.serialize(groupEvents(listEvents),true);
    }

    /**
        Find the operational calendar list and converts it to JSON, a format valid for javascript
        This is called from the page, usually when a filter changes, for airlines only
    **/
    @RemoteAction
    global static String loadDetailsRemote(String operationType, String cycle, String country, String frequency, String currencyCode, String billingPeriod) {
        list<Operational_Calendar__c> listOperations = queryListOperations(operationType, cycle, country, frequency, currencyCode, Integer.ValueOf(billingPeriod));
        // patch for CNS, wich is CASS only for US
        try {
            Id countryId = Id.ValueOf(country);
            if (countryId!=null && SET_CNS_COUNTRIES.contains(countryid)) operationType = 'CNS';
        } catch (Exception e) {}
        return serializeOperations(IS_AIRLINE, operationType, listOperations);
    }

    /**
        Finds the appropriate fieldset based on the operation type and if it's airline or agency
    **/
    private static Schema.FieldSet getDescriptionFieldSet(Boolean isAirline, String operationType) {
        if (operationType.contains('BSP')) {
            if (isAirline) {
                return SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Detail_For_BSP_Airline;
            } else {
                return SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Detail_For_BSP_Agency;
            }
        }
        if (operationType.contains('CASS')) {
            if (isAirline) {
                return SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Detail_For_CASS_Airline;
            } else {
                return SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Detail_For_CASS_Agency;
            }
        }
        if (operationType=='CNS') {
            return SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Detail_For_CNS;
        }
        if (operationType=='SIS') {
            return SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Detail_For_SIS;
        }
        if (operationType=='SIS+ACH') {
            return SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Detail_For_SIS_ACH;
        }
        if (operationType=='SIS+ICH') {
            return SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Detail_For_SIS_ICH;
        }
        if (operationType.contains('ICCS')) {
            return SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Detail_For_ICCS;
        }
        throw new OperationalCalendarException('Field Set not found. isAirline ' + isAirline + '  operationType ' + operationType);
    }
    
    public class TableDef {
        public list<HeaderDef> headers;
        public list<list<String>> data;
    }
    public class HeaderDef {
        public String sTitle;
        public String sType;
        public Boolean bVisible;
        public HeaderDef( String sTitle, String sType, Boolean bVisible) {
            this.sTitle = sTitle;
            this.sType = sType;
            this.bVisible  = bVisible ;
        }
    }
    
    /**
        Creates a JSON string having full data to populate the table
        first line is the header, and subsequent the data
    **/
    private static String serializeOperations(Boolean isAirline, String operationType, list<Operational_Calendar__c> listOperations) {
        Schema.FieldSet fieldset = getDescriptionFieldSet(isAirline, operationType);
        TableDef table = new TableDef();
        //headers
        table.headers = new list<HeaderDef>();
        // first 2 headers are empty for the extra colums for calculations
        table.headers.add(new HeaderDef('','string',false));
        table.headers.add(new HeaderDef('','string',false));
        for(Schema.FieldSetMember f : fieldset.getFields()) {
            String stype = String.ValueOf(f.getType()).toLowerCase();
            stype = f.getFieldPath()=='Country__c'? 'string': stype;
            String headerLabel = f.getFieldPath()=='frequency_code__c'? 'Code': f.getLabel();
            table.headers.add(new HeaderDef(headerLabel,stype,true));
        }
        //data
        table.data = new list<list<String>>();
        //find the first non past date
        String dateFieldNameToCompare;
        if (operationType == 'ICCS') {
            dateFieldNameToCompare = 'ICCS_Settlement_Date__c';
        } else {
            dateFieldNameToCompare = isAirline? 'Settlement_Day__c': 'Remittance_Day__c';
        }
        list<Date> listDate = new list<Date>();
        for (Operational_Calendar__c operation: listOperations) {
            Date dt = Date.ValueOf(operation.get(dateFieldNameToCompare));
            if (dt >= Date.today()) listDate.add(dt);
        }
        listDate.sort();
        Date firstNoPastDate = listDate.isEmpty()? Date.today(): listDate.get(0);
        //create structure for rows
        for (Operational_Calendar__c operation: listOperations) {
            list<String> listLine = new list<String>();
            //special columns to define if it's a past, present or future record
            Date dateToCompare = Date.ValueOf(operation.get(dateFieldNameToCompare));
            String rowclass = getDateClassName(dateToCompare, firstNoPastDate);
            listLine.add(rowclass);
            listLine.add(''+operation.LastModifiedDate);
            
            // regular data fields
            for(Schema.FieldSetMember f : fieldset.getFields()) {
                String fieldValue = getFieldValue(operation, f);
                if (f.getFieldPath()=='Country__c') {
                    // convert country Id to country Name
                    fieldValue = MAP_COUNTRIES.get(fieldValue);
                }
                if (f.getFieldPath()=='frequency_code__c') {
                    // convert frequency code to full name
                    fieldValue = MAP_FREQUENCIES.get(fieldValue);
                }
                listLine.add(fieldValue);
            }
            table.data.add(listLine);
        }
        return JSON.serialize(table,true);
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
    
    /**
        Returns the class name, if it's past, present, future or the first non past date
    **/
    public static String getDateClassName(Date dt, Date firstNoPastDate) {
        if (dt == firstNoPastDate) {
            return 'first-nonpast-row';
        }
        if (dt < Date.today()) {
            return 'past-row';
        }
        if (dt == Date.today()) {
            return 'present-row';
        }
        return 'future-row';
    }
    
    public static String nvl(String input) {
        return input==null? '': input;
    }
    
    public static String getFieldValue(Operational_Calendar__c obj, Schema.FieldSetMember f) {
        try {
            if (obj.get(f.getFieldPath()) == null) return '';
            return String.ValueOf((obj.get(f.getFieldPath())));
            
        } catch (Exception e) {
            System.debug('**ERROR in getFieldValue ' + e.getMessage());
            return '';
        }
    }
    
    public static list<EventWrapper> groupEvents(list<EventWrapper> listEvents) {
        map<Date,EventWrapper> mapEvents = new map<Date,EventWrapper>();
        if (listEvents!=null) {
            for (EventWrapper event: listEvents) {
                Date dateKey = Date.ValueOf(event.start);
                EventWrapper newEvent = mapEvents.get(dateKey);
                if (newEvent==null) {
                    newEvent = new EventWrapper();
                    newEvent.title = '';
                    newEvent.start = event.start;
                    newEvent.allDay = event.allDay;
                    newEvent.className = event.className;
                    newEvent.description = '';
                }
                newEvent.description+= event.title + '</br>';
                mapEvents.put(dateKey, newEvent);
            }
        } 
        return mapEvents.values();
    }
    
    public string getUserLanguage() {
        return UserInfo.getLanguage();
    }

    /**
        Find a disclaimer label based on the selected country and type using 
        the custom setting ISSP_Operational_Calendar_Disclaimer__c
    **/
    public String selectedCountry {get; set;}
    public String selectedType {get; set;}
    public String disclaimerLabelName {get; set;}
    public void findDisclaimerLabel() {
        this.disclaimerLabelName = null;
        if (String.isBlank(selectedCountry)) return;
        if (String.isBlank(selectedType)) return;
        try {
            IATA_ISO_Country__c country = IATAIsoCountryDAO.getIsoCountriesByIds(new Set<String>{selectedCountry}).get(0);
            ISSP_Operational_Calendar_Disclaimer__c disclaimer = [
                SELECT Id, Label__c
                FROM ISSP_Operational_Calendar_Disclaimer__c
                WHERE Country__c = :country.ISO_Code__c
                AND Operation_Type__c = :selectedType
            ];
            this.disclaimerLabelName = disclaimer.Label__c;
        } catch (Exception e) {
            this.disclaimerLabelName = null;
        }
    }


    /*** WMO-388 ***/
    public List<SelectOption> operationsOpts {get;set;}
    public List<SelectOption> remittancesOpts {get;set;}
    public List<SelectOption> countriesOpts {get;set;}

    public void initAdvFilters() {
        Schema.DescribeFieldResult remittances = Schema.Account.Remittance_frequency__c.getDescribe();
        operationsOpts = new List<SelectOption>();
        for (String optype: LIST_MULTIDOWNALOAD_TYPES) {
            operationsOpts.add(new SelectOption(optype,optype));
        }
        operationsOpts.sort();
        remittancesOpts = buildFilter(remittances.getPicklistValues());
        countriesOpts = this.countryOptions.clone();
        countriesOpts.remove(0);
    }

    private List<SelectOption> buildFilter(List<Schema.PicklistEntry> ple) {
        List<SelectOption> options = new List<SelectOption>();
        for(Schema.PicklistEntry pickListVal : ple){
            options.add(new SelectOption(pickListVal.getValue(), pickListVal.getLabel()));
        }

        options.sort();
        
        return options;
    }

    public List<SelectOption> selectedOperations {
        get {
            if(selectedOperations == null) {
                selectedOperations = new List<SelectOption>();
            }
            return selectedOperations;
        }
        set;
    }

    public List<SelectOption> selectedFrenquencies {
        get {
            if(selectedFrenquencies == null) {
                selectedFrenquencies = new List<SelectOption>();
            }
            return selectedFrenquencies;
        }
        set;
    }

    public List<SelectOption> selectedCountries {
        get {
            if(selectedCountries == null) {
                selectedCountries = new List<SelectOption>();
            }
            return selectedCountries;
        }
        set;
    }

    @RemoteAction
    public static ZipFileWrapper createZipFile(String option, List<String> operations, List<String> remittance, List<Id> countries, Id accountId) {
        System.debug('countries: ' + countries);

        ZipFileWrapper zfw = new ZipFileWrapper(Label.ISSP_OperationalCalendar + ' - ' + Datetime.now());

        Map<String,Map<String,FileWrapper>> mapFilesByFolder = new Map<String,Map<String,FileWrapper>>();
        list<String> bspcassOperations = new list<String>();
        list<String> otherOperations = new list<String>();
        for (String op: operations) {
            if (op.contains('BSP')) bspcassOperations.add(op);
            if (op.contains('CASS')) bspcassOperations.add(op);
            if (op.contains('SIS')) otherOperations.add(op);
            if (op.contains('ICCS')) otherOperations.add(op);
        }
        mapFilesByFolder.putAll(findDataForBSPCASS(option,bspcassOperations,remittance,countries,accountId));
        mapFilesByFolder.putAll(findDataForOthers(option,otherOperations,remittance,accountId));

        // set folders
        Map<String,FolderWrapper> mapFolders = new Map<String,FolderWrapper>();
        for(String folderName : mapFilesByFolder.keySet()) {
            mapFolders.put(folderName, new FolderWrapper(folderName));
        }
        //set files in folders
        for(String folderName : mapFilesByFolder.keySet()) {
            FolderWrapper fw = mapFolders.get(folderName);
            Map<String,FileWrapper> filesMap = mapFilesByFolder.get(folderName);
            if(filesMap != null && !filesMap.isEmpty()) {
                fw.files.addAll(filesMap.values());
            }

            zfw.nrOfFiles += fw.files.size();
        }

        zfw.folders.addAll(mapFolders.values());
        return zfw;
    }

    public static Map<String,Map<String,FileWrapper>> findDataForBSPCASS(String option, List<String> operations, List<String> remittance, List<Id> countries, Id accountId) {
        Map<String,Map<String,FileWrapper>> mapFilesByFolder = new Map<String,Map<String,FileWrapper>>();
        if (operations.isEmpty()) return mapFilesByFolder;

        Map<Id,Set<IATA_ISO_Country__c>> countriesByOperationMap = fetchCountriesOperations(option, countries, accountId);
        Set<Id> operationsIds = countriesByOperationMap.keySet();

        // get all fields in bsp cass fieldsets
        List<Schema.FieldSetMember> listFieldsetsFields = new List<Schema.FieldSetMember>();
        listFieldsetsFields.addAll(getDescriptionFieldSet(IS_AIRLINE, 'BSP').getFields());
        listFieldsetsFields.addAll(getDescriptionFieldSet(IS_AIRLINE, 'CASS').getFields());
        listFieldsetsFields.addAll(getDescriptionFieldSet(IS_AIRLINE, 'CNS').getFields());
        // get field names from firld sets
        set<String> setFieldNames = new set<String>{'Id','LastModifiedDate','Operation_Type__c','ISS_operation__c','ISS_operation__r.Name'};
        for (Schema.FieldSetMember member: listFieldsetsFields) {
            setFieldNames.add(member.getFieldPath());
        }

        String queryStr = 'SELECT ' + String.join(new list<String>(setFieldNames), ',')
            + ' FROM Operational_Calendar__c'
            + ' WHERE RecordTypeId = \'' + RT_ISS_CALENDAR.getRecordTypeId() + '\''
            + ' AND Visible_on_the_portal__c = true '
            + ' AND First_Day__c = THIS_YEAR '
            + ' AND ISS_operation__c IN :operationsIds ';

        List<String> conditions = new List<String>();
        if(operations != null && !operations.isEmpty()) {
            conditions.add(' Operation_Type__c IN (\''+ String.join(operations, '\',\'') +'\') ');
        }
        if(remittance != null && !remittance.isEmpty()) {
            conditions.add(' Frequency_Code__c IN (\''+ String.join(remittance, '\',\'') +'\') ');
        }
        if(!conditions.isEmpty()) {
            queryStr += ' AND' + String.join(conditions, ' AND ');
        }
        queryStr += ' ORDER BY Settlement_Day__c';

        System.debug('queryStr: ' + queryStr);
        //List<Operational_Calendar__c> operationsCalendar = (List<Operational_Calendar__c>) Database.query(queryStr); 

        
        Integer currentYear = Date.today().year();

        //System.debug('Operations: ' + operationsCalendar);
        for(Operational_Calendar__c opc : Database.query(queryStr)) {
            System.debug('___opc ' + opc);
            Schema.FieldSet fieldSchema = getDescriptionFieldSet(IS_AIRLINE, opc.Operation_Type__c);
            List<Schema.FieldSetMember> fieldsList = fieldSchema.getFields();
            String orientation = fieldsList.size() > 6 ? 'landscape' : 'portrait';
            Set<IATA_ISO_Country__c> countriesByOperationSet = countriesByOperationMap.get(opc.ISS_operation__c);
            Map<String,FileWrapper> filesByCountryOp = mapFilesByFolder.get(opc.Operation_Type__c);
            if(filesByCountryOp == null) {
                filesByCountryOp = new Map<String,FileWrapper>();
                mapFilesByFolder.put(opc.Operation_Type__c, filesByCountryOp);
            }
            for(IATA_ISO_Country__c country : countriesByOperationSet) {
                System.debug('___country ' + country);
                String operationType = opc.Operation_Type__c;
                List<Schema.FieldSetMember> fieldsListSelected = fieldsList;
                // patch to cover CNS case
                if (opc.Operation_Type__c.contains('CASS') && SET_CNS_COUNTRIES.contains(country.Id)) {
                    operationType = 'CNS';
                    fieldsListSelected = getDescriptionFieldSet(IS_AIRLINE, 'CNS').getFields();
                }
                FileWrapper countryFile = filesByCountryOp.get(country.Name);
                if(countryFile == null) {
                    String fileName = Label.ISSP_OperationalCalendar + ' ' + country.Name + '-' + operationType + ' ' + currentYear;
                    countryFile = new FileWrapper(fileName, orientation, fieldsListSelected, country.Name);
                    filesByCountryOp.put(country.Name, countryFile);
                }
                if(countryFile.lastModifiedDate < opc.LastModifiedDate.date()) {
                    countryFile.lastModifiedDate = opc.LastModifiedDate.date();
                }
                List<CellWrapper> row = createRow(opc, fieldsListSelected, 'tableBodyOdd');
                countryFile.table.body.add(row);
            }

            System.debug('countriesByOperationSet: ' + countriesByOperationSet);
        }
        return mapFilesByFolder;
    }

    private static Map<String,Map<String,FileWrapper>> findDataForOthers(String option, List<String> operations, List<String> remittance, Id accountId) {
        Map<String,Map<String,FileWrapper>> mapFilesByFolder = new Map<String,Map<String,FileWrapper>>();
        for (String operation: operations) {
            Id recordtypeId;
            List<Schema.FieldSetMember> fieldsList = new List<Schema.FieldSetMember>();
            //find specifica values for operations
            if (operation.contains('SIS')) {
                recordtypeId = RT_SIS_CALENDAR.getRecordTypeId();
                fieldsList.addAll(getDescriptionFieldSet(IS_AIRLINE, 'SIS').getFields());
                fieldsList.addAll(getDescriptionFieldSet(IS_AIRLINE, 'SIS+ICH').getFields());
                fieldsList.addAll(getDescriptionFieldSet(IS_AIRLINE, 'SIS+ACH').getFields());
                fieldsList = new List<Schema.FieldSetMember>(new set<Schema.FieldSetMember>(fieldsList));
            }
            if (operation.contains('ICCS')) {
                recordtypeId = RT_ICCS_CALENDAR.getRecordTypeId();
                fieldsList.addAll(getDescriptionFieldSet(IS_AIRLINE, 'ICCS').getFields());
            }
            // get field names from firld sets
            set<String> setFieldNames = new set<String>{'Id','Country__c','Country__r.Name'};
            for (Schema.FieldSetMember member: fieldsList) {
                setFieldNames.add(member.getFieldPath());
            }
            //query
            String queryStr = 'SELECT ' + String.join(new list<String>(setFieldNames), ',')
                + ' FROM Operational_Calendar__c'
                + ' WHERE RecordTypeId = \'' + recordtypeId + '\''
                + ' AND Visible_on_the_portal__c = true '
                + ' AND First_Day__c = THIS_YEAR ';

            List<String> conditions = new List<String>();
            if(remittance != null && !remittance.isEmpty()) {
                conditions.add(' Frequency_Code__c IN (\''+ String.join(remittance, '\',\'') +'\') ');
            }
            if(!conditions.isEmpty()) {
                queryStr += ' AND' + String.join(conditions, ' AND ');
            }
            queryStr += ' ORDER BY Settlement_Day__c';

            System.debug('queryStr: ' + queryStr);

            // create files
            String orientation = fieldsList.size() > 6 ? 'landscape' : 'portrait';
            Integer currentYear = Date.today().year();
            for(Operational_Calendar__c opc : Database.query(queryStr)) {
                // create row using the operational calendar record
                String fileName = Label.ISSP_OperationalCalendar + ' ' + opc.Country__r.Name + ' - ' + operation + ' ' + currentYear;
                FileWrapper countryFile = new FileWrapper(fileName, orientation, fieldsList, opc.Country__r.Name);
                List<CellWrapper> row = createRow(opc, fieldsList, 'tableBodyOdd');
                countryFile.table.body.add(row);

                //add the row to the map
                Map<String,FileWrapper> filesByCountryOp = mapFilesByFolder.get(operation);
                if (filesByCountryOp==null) {
                    filesByCountryOp = new Map<String,FileWrapper>();
                }
                filesByCountryOp.put(opc.Country__r.Name, countryFile);
                mapFilesByFolder.put(operation,filesByCountryOp);
            }
        }
        return mapFilesByFolder;
    }

    private static Map<Id,Set<IATA_ISO_Country__c>> fetchCountriesOperations(String option, List<Id> countries, Id accountId) {
        Map<Id,Set<IATA_ISO_Country__c>> mapOperationsToCountries = new Map<Id,Set<IATA_ISO_Country__c>>();
        List<IATA_ISO_Country__c> lstCountries;

        if(option == 'allservices') {
            List<Services_Rendered__c> services = [SELECT ISO_Country_Code__c
                                                   FROM Services_Rendered__c 
                                                   WHERE Services_Rendered_to_Airline__c = :accountId AND ISO_Country_Code__c <> null];
            Set<String> countryCodes = new Set<String>();
            for(Services_Rendered__c service : services) {
                countryCodes.add(service.ISO_Country_Code__c);
            }

            lstCountries = IATAIsoCountryDAO.getIsoCountryByIsoCodes(countryCodes);
        } else if (option == 'custom') {
            lstCountries = IATAIsoCountryDAO.getIsoCountriesByIds(new Set<Id>(countries));
        } else {//all
            lstCountries = IATAIsoCountryDAO.getIsoCountries();
        }

        for(IATA_ISO_Country__c country : lstCountries) {
            if(country.AMS_Settlement_System__c != null) {
                Set<IATA_ISO_Country__c> setCountries = mapOperationsToCountries.get(country.AMS_Settlement_System__c);
                if(setCountries == null) {
                    setCountries = new Set<IATA_ISO_Country__c>();
                    mapOperationsToCountries.put(country.AMS_Settlement_System__c, setCountries);
                }
                setCountries.add(country);
            }

            if(country.AMS_Settlement_System_CASS__c != null) {
                Set<IATA_ISO_Country__c> setCountries = mapOperationsToCountries.get(country.AMS_Settlement_System_CASS__c);
                if(setCountries == null) {
                    setCountries = new Set<IATA_ISO_Country__c>();
                    mapOperationsToCountries.put(country.AMS_Settlement_System_CASS__c, setCountries);
                }
                setCountries.add(country);
            }
        }

        return mapOperationsToCountries;
    }

    private static List<CellWrapper> createRow(Operational_Calendar__c opCalendar, List<Schema.FieldSetMember> fieldsList, String rowStyle) {
        List<CellWrapper> res = new List<CellWrapper>();
        for(Schema.FieldSetMember member : fieldsList) {
            String fieldApiName = member.getFieldPath();
            Object untypedVal = opCalendar.get(fieldApiName);
            String val = member.getType() == Schema.DisplayType.Date ? formatDate((Date) untypedVal) : safeValue(untypedVal);
            if (fieldApiName=='Country__c') val = MAP_COUNTRIES.get(val);
            res.add(new CellWrapper(rowStyle, val));
        }
        return res;
    }

    private static String formatDate(Date dt) {
        if(dt != null) {
            Datetime dtOut = Datetime.newInstance(dt.year(), dt.month(), dt.day(), 0,0,0);   
            return dtOut.format('d MMM yyyy');
        } else {
            return '';
        }
    }

    private static String safeValue(Object val) {
        return val == null ? '' : String.valueOf(val);
    }

    public class ZipFileWrapper {
        public String zipFileName {get;set;}
        public List<FolderWrapper> folders {get;set;}
        public Integer nrOfFiles {get;set;}

        public ZipFileWrapper(String zipFileName) {
            this.zipFileName = zipFileName;
            this.folders = new List<FolderWrapper>();
            this.nrOfFiles = 0;
        }
    }

    public class FolderWrapper {
        public String folderName {get;set;}
        public List<FileWrapper> files {get;set;}

        public FolderWrapper(String folderName) {
            this.folderName = folderName;
            this.files = new List<FileWrapper>();
        }
    }

    public class FileWrapper {
        public Date lastModifiedDate {
            get;
            set {
                lastModifiedDate = value;
                lastModifiedDateStr = formatDate(lastModifiedDate);
            }
        }
        public String lastModifiedDateStr {get;set;}
        public String fileName {get;set;}
        public String countryName {get;set;}
        public String orientation {get;set;}
        public TableBodyWrapper table {get;set;}

        public FileWrapper(String fileName, String orientation, List<Schema.FieldSetMember> fieldsList, String countryName) {
            this.fileName = fileName;
            this.countryName = countryName;
            this.orientation = orientation;
            this.table = new TableBodyWrapper(fieldsList);
            this.lastModifiedDate = Date.newInstance(1900, 1, 1);
        }
    }

    public class TableBodyWrapper {        
        public List<List<CellWrapper>> body {get;set;} 

        public TableBodyWrapper(List<Schema.FieldSetMember> fieldsList) {
            this.body = new List<List<CellWrapper>>();
            List<CellWrapper> headerRow = new List<CellWrapper>();
            for(Schema.FieldSetMember member : fieldsList) {
                headerRow.add(new CellWrapper('tableHeader', member.getLabel()));
            }
            this.body.add(headerRow);
        }
    }

    public class CellWrapper {
        public String style {get;set;}
        public String text {get;set;}

        public CellWrapper(String style, String text) {
            this.style = style;
            this.text = text;
        }
    }
}