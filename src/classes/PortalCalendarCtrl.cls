public with sharing class PortalCalendarCtrl {

    //#########################################################################
    //
    // migration and adaptation from the ISSP_OperationalCalendarController 
    // class
    //
    //#########################################################################

    public class OperationalCalendarException extends Exception {}

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
    
    public static final Map<String, Schema.SObjectField> MAP_CALENDAR_FIELDS =
        Schema.getGlobalDescribe().get('operational_Calendar__c').getDescribe().fields.getMap();
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

    private static CalendarControllerProperties getCalendarControllerProperties(){
        CalendarControllerProperties calendarProp = new CalendarControllerProperties();

        calendarProp.user = [
            SELECT Id, Profile.Name, ContactId, Contact.Id, Contact.AccountId,
                Contact.Account.Id,
                Contact.Account.IATA_ISO_Country__c,
                Contact.Account.Remittance_frequency__c,
                Contact.Account.Location_Class__c
            FROM User
            WHERE Id = :UserInfo.getUserId()];
        calendarProp.contact = calendarProp.user.contact;
        calendarProp.account = calendarProp.user.contact.account;
        calendarProp.setFilter = new set<String>();
        calendarProp.defaultCountry = calendarProp.account.IATA_ISO_Country__c;
        calendarProp.defaultOperationType = nvl(MAP_OPERATION_TYPES.get(calendarProp.account.Location_Class__c));
        calendarProp.defaultFrequency = calendarProp.account.Remittance_frequency__c;
        calendarProp.maxDate = Date.newInstance(Date.Today().year()+2, 1, 1);
        calendarProp.minDate = Date.newInstance(Date.Today().year()-1, 1, 1);
        //initPicklistValues();
        if (IS_AIRLINE) {
            calendarProp.description = calendarProp.defaultcountryTranslated + ' - BSP/CASS Calendar';
        } else {
            calendarProp.description = calendarProp.defaultcountryTranslated + ' ' + calendarProp.defaultOperationType;
        }

        return calendarProp;
    }

    public class CalendarControllerProperties {

        @AuraEnabled
        public User user {get; set;}
        @AuraEnabled
        public Contact contact;
        @AuraEnabled
        public Account account {get;set;}
        @AuraEnabled
        public String defaultCountry {get; set;}
        @AuraEnabled
        public String defaultOperationType {get; set;}
        @AuraEnabled
        public String defaultFrequency {get; set;}
        @AuraEnabled
        public Date maxDate {get; set;}
        @AuraEnabled
        public Date minDate {get; set;}
        @AuraEnabled
        public String  description {get; set;}
        @AuraEnabled
        public String defaultcountryTranslated;
        @AuraEnabled
        public String defaultFrequencyTranslated;
        
        //Filters
        @AuraEnabled
        public list<SelectOption> countryOptions {get;set;}
        @AuraEnabled
        public set<String> setFilter{get;set;}

        public CalendarControllerProperties(){}

    }

    @AuraEnabled
    public static List<EventWrapper> getOperationalCalendarEventsBetweenDates(){
    //public static List<EventWrapper> getOperationalCalendarEventsBetweenDates(Date initialDate, Date finalDate){

        CalendarControllerProperties calendarProp = PortalCalendarCtrl.getCalendarControllerProperties();

        String country = calendarProp.defaultCountry;
        String frequency = calendarProp.defaultFrequency;
        String operationType = IS_AIRLINE? null: calendarProp.defaultOperationType;
        String currencyCode = null;
        Integer period = null;
        list<Operational_Calendar__c> listOperations = queryListOperations(country, frequency, operationType, currencyCode, period);
        list<EventWrapper> listEvents = getOperationalCalendarEvents(listOperations, false);
        
        return listEvents;
        
        //return JSON.serialize(groupEvents(listEvents),true);
    }

    /**
        Creates a list of events based on queried operational calendars
        these events are created based on the user type, airlines or agent users
    **/
    private static list<EventWrapper> getOperationalCalendarEvents(list<Operational_Calendar__c> listOperations, Boolean isGrouped) {
        list<EventWrapper> listEvents = new list<EventWrapper>();
        for (Operational_Calendar__c operation: listOperations) {
            String operationType = nvl(operation.Operation_Type__c);
            Boolean isCASS = operationType.contains('CASS');
            String title = operation.Period_Code__c;
            String description = getEventDescription(operation, isCASS, IS_AIRLINE);
            // The settlement events are shown only for airlines
            if (IS_AIRLINE) {
                EventWrapper event1 = new EventWrapper();
                event1.title = getEventTitle(operation, FIELD_Settlement_Day, isGrouped);
                event1.start = operation.Settlement_Day__c;
                event1.allDay = true;
                event1.className = 'settlementEvent';
                event1.description = description;
                listEvents.add(event1);
                if (isCASS) {
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
                if (isCASS) {
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
        return listEvents;
    }

    /**
        Generate the text inside the popup when the mouse is over
    **/
    private static String getEventDescription(Operational_Calendar__c operation, Boolean isCASS, Boolean isAirline) {
        Schema.FieldSet fieldset;
        if (isAirline) {
            if (isCASS) {
                fieldset = SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Hover_For_CASS_Airline;
            } else {
                fieldset = SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Hover_For_BSP_Airline;
            }
        } else {
            //AGENTS
            if (isCASS) {
                fieldset = SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Hover_For_CASS_Agency;
            } else {
                fieldset = SObjectType.operational_Calendar__c.FieldSets.ISSP_Page_Hover_For_BSP_Agency;
            }
        }
        String description = '';
        for(Schema.FieldSetMember f : fieldset.getFields()) {
            String fieldName = f.getFieldPath();
            String fieldLabel = f.getLabel();
            String fieldValue = '<date>' + getFieldValue(operation, f) + '</date>';
            description+= '<strong>' + fieldLabel + '</strong> ' + fieldValue + '</br>';
        }
        return description;
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
    public static list<Operational_Calendar__c> queryListOperations(String country, String frequency, String operationType, String currencyCode, Integer billingPeriod) {
        if (String.isBlank(country)) {
            throw new OperationalCalendarException(Label.ISSP_OperationalCalendar_Country_Filter_Required);
        }
        if (String.isBlank(operationType)) {
            // if the operation type is not defines we have to run the query for all available types
            list<Operational_Calendar__c> listOperations = new list<Operational_Calendar__c>();
            for (String opType: new set<String>(MAP_OPERATION_TYPES.values())) {
                listOperations.addAll(runQuery(country, frequency, opType, currencyCode, billingPeriod));
            }
            return listOperations;
        } else {
            return runQuery(country, frequency, operationType, currencyCode, billingPeriod);
        }
    }

    /**
        Generate the query string and runs it, used only by queryListOperations()
    **/
    private static list<Operational_Calendar__c> runQuery(String country, String frequency, String operationType, String currencyCode, Integer billingPeriod) {
        Boolean isBSP = operationType.contains('BSP');
        String lookupField = isBSP? 'AMS_Settlement_System__c': 'AMS_Settlement_System_CASS__c';
        String query = 'SELECT Id,RecordTypeId,First_Day__c,Frequency_code__c,HAR_Day__c,ISS_operation__c,Last_Day__c,Name,Operation_Code__c,'
            + ' Operation_Currency__c,Operation_Period_code__c,Operation_Type__c,Period_Code__c,Remittance_Day__c,Settlement_Day__c,'
            + ' EP_Settlement_date__c, Billing_Availability__c, Airline_Input_Upload_Cut_Off__c, CASS_reports_Availability__c,'
            + ' Agent_Correction_Cut_Off__c, Airline_Correction_Response_Cut_Off__c, LastModifiedDate'
            + ' FROM Operational_Calendar__c'
            + ' WHERE ISS_operation__c IN ('
            + '     SELECT ' + lookupField
            + '     FROM IATA_ISO_Country__c'
            + '     WHERE Id = \'' + country + '\')'
            + ' AND Visible_on_the_portal__c = true'
            + ' AND Operation_Type__c = \'' + operationType + '\'';
            // for some countries we have to find only those records where the operation code starts with the country code
            if (isBSP && SPECIAL_CASE_COUNTRIES.containsKey(country)) {
                String isocode=SPECIAL_CASE_COUNTRIES.get(country).ISO_Code__c;
                query += ' AND Operation_Code__c LIKE \'' + isocode + '%\'';
            }
            if (String.isNotBlank(frequency)) {
                query += ' AND frequency_code__c = \'' + frequency + '\'';
            }
            if (String.isNotBlank(currencyCode)) {
                query += ' AND Operation_Currency__c = \'' + currencyCode + '\'';
            }
            if (billingPeriod==Date.today().year()) {
                query += ' AND First_Day__c = THIS_YEAR';
            } else if (billingPeriod==Date.today().year()+1) {
                query += ' AND First_Day__c = NEXT_YEAR';
            } else if (billingPeriod==Date.today().year()-1) {
                query += ' AND First_Day__c = LAST_YEAR';
            } else if ( billingPeriod >= 1 && billingPeriod <= 12 ) {
                query += ' AND First_Day__c = THIS_YEAR';
                query += ' AND CALENDAR_MONTH(First_Day__c) = ' + billingPeriod;
            } else {
                query += ' AND First_Day__c >= LAST_YEAR';
            }
            //query += ' ORDER BY Period_Code__c ASC';
            if (IS_AIRLINE) {
                query += ' ORDER BY Settlement_Day__c ASC';
            } else {
                query += ' ORDER BY Remittance_Day__c ASC';
            }
            
            System.debug('QUERY: ' + query);
            return Database.query(query);
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

    private class EventWrapper {
        @AuraEnabled
        public Integer id {get; set;}
        @AuraEnabled
        public String title {get; set;}
        @AuraEnabled
        public DateTime start {get; set;}
        @AuraEnabled
        public DateTime finish {get; set;}
        @AuraEnabled
        public Boolean allDay {get; set;}
        @AuraEnabled
        public String url {get; set;}
        @AuraEnabled
        public String className {get; set;}
        @AuraEnabled
        public String color {get; set;}
        @AuraEnabled
        public String backgroundColor {get; set;}
        @AuraEnabled
        public String borderColor {get; set;}
        @AuraEnabled
        public String textColor {get; set;}
        @AuraEnabled
        public String description {get; set;}
    }


    //#########################################################################
    //
    // this methods are for the calendar days
    //
    //#########################################################################
    
    @AuraEnabled
    public static MonthWrapper getInitialMonthPage(String browserDate, String requestedDate){

        Date requestedDateAux = Date.valueOf(requestedDate);
        System.debug(requestedDateAux);

        Date browserDateAux = Date.valueOf(browserDate);
        System.debug(browserDateAux);
        
        return PortalCalendarCtrl.getMonth(browserDateAux, requestedDateAux);
    }
    
    @AuraEnabled
    public static MonthWrapper getNextMonth(String browserDate, Integer monthNumber, Integer yearNumber){
        Integer monthNumberInt = Integer.valueOf(monthNumber);
        Integer yearNumberInt = Integer.valueOf(yearNumber);
        
		Date oldDate = Date.newInstance(yearNumberInt, monthNumberInt, 1);
        Date newDate = oldDate.addMonths(1);
		System.debug('newDate: ' + newDate);

        Date browserDateAux = Date.valueOf(browserDate);
        System.debug(browserDateAux);
        
        return PortalCalendarCtrl.getMonth(browserDateAux, newDate);
    }
    
    @AuraEnabled
    public static MonthWrapper getPreviousMonth(String browserDate, Integer monthNumber, Integer yearNumber){
		Integer monthNumberInt = Integer.valueOf(monthNumber);
        Integer yearNumberInt = Integer.valueOf(yearNumber);
        
		Date oldDate = Date.newInstance(yearNumberInt, monthNumberInt, 1);
        Date newDate = oldDate.addMonths(-1);
		System.debug('newDate: ' + newDate);

        Date browserDateAux = Date.valueOf(browserDate);
        System.debug(browserDateAux);
        
        return PortalCalendarCtrl.getMonth(browserDateAux, newDate);
    }

    public static MonthWrapper getMonth(Date browserDate, Date requestedDate){
        MonthWrapper monthToReturn = new MonthWrapper();
        
        List<DayWrapper> lstDays = new List<DayWrapper>();
        //Insert the first blank spaces until the first day of the week
        Integer numBlankDays = PortalCalendarCtrl.getNumberEmptyDays(DateTime.newInstance(requestedDate.year(), requestedDate.month(), 1));
        while(numBlankDays > 0){
            lstDays.add(new DayWrapper(true, false, 0, false));
            numBlankDays--;
        }
        System.debug('lstDays before: ' + lstDays);

        List<EventWrapper> lstEvents = PortalCalendarCtrl.getOperationalCalendarEventsBetweenDates();

        //the actual month days after the blank days
        Integer thisMonthDays = Date.daysInMonth(requestedDate.year(), requestedDate.month());

        for(Integer i = 1; i <= thisMonthDays; i++){
            DayWrapper dayWrapperAux = new DayWrapper();
            dayWrapperAux.dayNumber = i;
			
            Date newDate = Date.newInstance(requestedDate.year(), requestedDate.month(), i);

            List<EventWrapper> lstEventsAux = new List<EventWrapper>();
            for(EventWrapper ewAux : lstEvents){
                if(newDate == ewAux.start.date()){
                    lstEventsAux.add(ewAux);
                }
            }

            dayWrapperAux.lstEvents = lstEventsAux;

            if(browserDate == newDate){
            	dayWrapperAux.isHighlighted = true;
            }else{
                dayWrapperAux.isHighlighted = false;
            }
            dayWrapperAux.isEmpty = false;
            dayWrapperAux.isSelected = false;
            
            lstDays.add(dayWrapperAux);
        }
        System.debug('lstDays after: ' + lstDays);


        //create the weeks
        Integer i = 0;
        Integer j = 0;

        monthToReturn.lstWeeks = new List<WeekWrapper>();

        WeekWrapper weekWrapperAux = new WeekWrapper();
        weekWrapperAux.lstDays = new List<DayWrapper>();
        weekWrapperAux.weekNumber = j;

        for(DayWrapper dayWrapperAux : lstDays){
            weekWrapperAux.lstDays.add(dayWrapperAux);
            i++;

            if(i == 7){
                i = 0;
                j++;
                
                //add the week to the month wrapper
                monthToReturn.lstWeeks.add(weekWrapperAux);

                //create the next week
                weekWrapperAux = new WeekWrapper();
                weekWrapperAux.lstDays = new List<DayWrapper>();
                weekWrapperAux.weekNumber = j;
            }
        }

        //add the last week
        if(i != 0){
            monthToReturn.lstWeeks.add(weekWrapperAux);
        }

        monthToReturn.monthName = PortalCalendarCtrl.getMonthName(DateTime.newInstance(requestedDate.year(), requestedDate.month(), requestedDate.day()));
        monthToReturn.monthNumber = requestedDate.month();
        monthToReturn.monthYear = requestedDate.year();
        
        return monthToReturn;
    }
    
    public static Integer getNumberEmptyDays(DateTime dateAux){
        String currentWeekDay = dateAux.format('EEEE');
        Integer daysToReturn = 0;
        
        switch on currentWeekDay {
    		when 'Monday' {		
                daysToReturn = 0;
            }
            when 'Tuesday' {		
                daysToReturn = 1;
            }
            when 'Wednesday' {		
                daysToReturn = 2;
            }
            when 'Thursday' {		
                daysToReturn = 3;
            }
            when 'Friday' {		
                daysToReturn = 4;
            }
            when 'Saturday' {		
                daysToReturn = 5;
            }
            when else {
				daysToReturn = 6;
            }
        }
        
        System.debug('daysToReturn: ' + daysToReturn);
        
        return daysToReturn;
    }
    
    public static String getMonthName(DateTime dateAux){
		return dateAux.format('MMMMM');
        
        //In case the format does not return the name in the current user language - uncoment this and 
        //replace the strings with custom labels with translation
        /*
        Integer monthNumber = dateAux.year();
		String monthName = '';
        switch on monthNumber {
    		when 1 {		
                monthName = 'January';
            }
            when 2 {		
                monthName = 'February';
            }
            when 3 {		
                monthName = 'March';
            }
            when 4 {		
                monthName = 'April';
            }
            when 5 {		
                monthName = 'May';
            }
            when 6 {		
                monthName = 'June';
            }
            when 7 {		
                monthName = 'Jully';
            }
            when 8 {		
                monthName = 'August';
            }
            when 9 {		
                monthName = 'September';
            }
            when 10 {		
                monthName = 'October';
            }
            when 11 {		
                monthName = 'November';
            }
            when else {
				monthName = 'December';
            }
        }
        return monthName;*/
    }

    public class MonthWrapper{
        @AuraEnabled
        public String monthName;
        @AuraEnabled
        public List<WeekWrapper> lstWeeks;
        @AuraEnabled
        public Integer monthNumber;
        @AuraEnabled
        public Integer monthYear;
        
        public MonthWrapper(){}
    }

    public class WeekWrapper{
        @AuraEnabled
        public Integer weekNumber;
        @AuraEnabled
        public List<DayWrapper> lstDays;

        public WeekWrapper(){}
    }
    
    public class DayWrapper{
        @AuraEnabled
        public Boolean isEmpty;
        @AuraEnabled
        public Boolean isHighlighted;
        @AuraEnabled
        public Integer dayNumber;
        @AuraEnabled
        public Boolean isSelected;
        @AuraEnabled
        public List<EventWrapper> lstEvents;
        
        public DayWrapper(){}
        
        public DayWrapper(Boolean isEmptyAux, Boolean isHighlightedAux, Integer dayNumberAux, Boolean isSelectedAux){
            this.isEmpty = isEmptyAux;
            this.isHighlighted = isHighlightedAux;
            this.dayNumber = dayNumberAux;
            this.isSelected = isSelectedAux;
        }
    }

    @AuraEnabled
    public static String goToOldPortalCalendar(){

        return OneIdUtils.getCommunityRedirection (OneIdUtils.Mode.ISSP, 'ISSP_OperationalCalendar');

    }

}
