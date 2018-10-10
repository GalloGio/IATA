public with sharing class ISSP_AMS_EBulletin {

    private static Id DAILY_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_eBulletin_Profile__c', 'Daily');
    private static Id WEEKLY_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_eBulletin_Profile__c', 'Weekly');

    private static final string ISO_8859_1_regEx = '^[\\x00-\\x7F\\xA0-\\xFF]+$';  //Reg exp to limit inputted chars to ISO-8859-1

    public Map<String,IATA_ISO_Country__c> mCountries;

    public List<String> dailyCountry {get; set;}
    public List<String> weeklyCountry {get; set;}
    public List<String> dailyCountryName {get; set;}
    public List<String> weeklyCountryName {get; set;}

    public List<WrapperReports> dailyFileDownloadList {get; set;}
    public Boolean isAvailableToShowDaily{get;set;}
    public Set<Id> dailyAllIdsList {get; set;}
    public String dailyFileDownloadListJSON {
        get{
            return JSON.serialize(dailyAllIdsList);
        }
        set{}
    }
    public List<WrapperReports> weeklyFileDownloadList {get; set;}
    public Boolean isAvailableToShowWeekly{get;set;}
    public Set<Id> weeklyAllIdsList {get; set;}
    public String weeklyFileDownloadListJSON {
        get{
            return JSON.serialize(weeklyAllIdsList);
        }
        set{}
    }
    
    
    public String daysOfWeek { get; set; }
    public String week { get; set; }
    public String todayPeriod { get; set; }
    public String todayOption { get; set; }
    
    public String pDateStart { get; set; }
    public String pWeekStart { get; set; }
    public String pWeekEnd { get; set; }
    

    //Start date for weekly data.
    public String eBulletin_StartDate { get; set; }
    public String eBulletin_StartDate_year { get; set; }
    public String eBulletin_StartDate_month { get; set; }
    public String eBulletin_StartDate_day { get; set; }

    public AMS_eBulletin_Profile__c newFormDaily {get; set;}
    public AMS_eBulletin_Profile__c newFormWeekly {get; set;}
    public Contact con {get; set;}
    public String displayLanguage {get; set;}
    public String displayLanguageDatePicker {get; set;}
    public String userGuideLink {get; set;}

    public boolean bIsAdmin {get; set;}     //identify if a user is administrator or not
    public String applyLanguage {get; set;}
    public string stepNumber {get; set;}

    public boolean param {get; set;}
    public boolean isStepHome {get; set;}
    public boolean isStep1 {get; set;}
    public boolean isStep1_1 {get; set;}
    public boolean isStep1_2 {get; set;}
    public boolean isStep2 {get; set;}
    public boolean isStep3 {get; set;}
    public boolean isFirstTime {get; set;}
    public boolean onOff {get; set;}
    public boolean dailyOnOff {get; set;}
    public boolean weeklyOnOff {get; set;}
    public boolean dailyCountrySelectAll {get; set;}
    public boolean weeklyCountrySelectAll {get; set;}
    public List<SelectOption> dailyCountrySelected {get; set;}
    public List<SelectOption> weeklyCountrySelected {get; set;}
    public List <ISSP_PDF_Per_Region__c> pdfUserGuide {get; set;}
    
    public IATA_ISO_Country__c isocountry {get; set;}

    public static String objectBaseQuery = 'Agency_Applied_Change_code__c';
    public static String objectHistBaseQuery = 'AMS_Agency_A_Change_code_History__c';
    public static String eBulletinCSVFormat = '","';
    public static AMS_EBulletinReportHelper.AMSEBulletinFilters filters;
    public Id batchRecordsId {get;set;}
    public Boolean isBatchProcessing {get;set;}
    @TestVisible private static Set<String> ccNamesToRecoverAux;
    @TestVisible private static List<String> countriesFilterAux;
    @TestVisible private static List<String> locClsListAux;
    private static Datetime filterFromCCDateAux;
    private static Datetime filterToCCDateAux;
    public Boolean isGettingReportDaily {get;set;}
    public Boolean isGettingReportWeekly {get;set;}
    
    public ISSP_AMS_EBulletin() {

        applyLanguage = UserInfo.getLanguage();
        displayLanguage = UserInfo.getLanguage();

        //set iso code to match datpicker format, in case of "english" the value is set to empty
        //displayLanguageDatePicker = displayLanguage.equalsIgnoreCase('en_US') || displayLanguage.equalsIgnoreCase('in')  ? '' : displayLanguage.replace('_', '-');
        displayLanguageDatePicker = displayLanguage.equalsIgnoreCase('en_US')  ? '' : displayLanguage.replace('_', '-');


        //Get the custom setting with the name of the userguide custom setting (ex: "EBULLETIN-USERGUIDE-")
        String paramUserGuide = ISSP_CS__c.getValues('eBulletin_UserGuide').Value__c;
        userGuideLink = getUserGuideFileLink(paramUserGuide, displayLanguage);

        newFormDaily = new AMS_eBulletin_Profile__c();
        newFormWeekly = new AMS_eBulletin_Profile__c();

        //mark "FirstTime" as true, below if we get records for this user we mark it as "false"
        isFirstTime = true;

        dailyCountrySelectAll = false;
        weeklyCountrySelectAll = false;

        if(newFormDaily.RecordTypeId == null){
            newFormDaily.RecordTypeId = DAILY_RECORD_TYPE_ID;
            newFormDaily.User__c = Userinfo.getuserid();
        }

        if(newFormWeekly.RecordTypeId == null){
            newFormWeekly.RecordTypeId = WEEKLY_RECORD_TYPE_ID;
            newFormWeekly.User__c = Userinfo.getuserid();
        }

        eBulletin_StartDate = ISSP_CS__c.getValues('eBulletin_StartDate').Value__c;
        eBulletin_StartDate_year = eBulletin_StartDate.split('/').get(2);
        eBulletin_StartDate_month = eBulletin_StartDate.split('/').get(1);
        eBulletin_StartDate_day = eBulletin_StartDate.split('/').get(0);

        fetchAMSProcessForm();
        
        popContact();  //Get the contact details of currently logged in user
        isocountry = fetchISOCountry(con.Account.IATA_ISO_Country__r.ISO_Code__c);

        fillMapCountries();

        //Set Countries to picklist
        dailyCountry = newFormDaily.CountriesList__c == null ? new List<String>() : newFormDaily.CountriesList__c.split(';');
        weeklyCountry = newFormWeekly.CountriesList__c == null ? new List<String>() : newFormWeekly.CountriesList__c.split(';');

        dailyCountryName = getCountryName(dailyCountry);
        weeklyCountryName = getCountryName(weeklyCountry);      

        dailyCountrySelected = populateSelectedCountries(dailyCountry);
        weeklyCountrySelected = populateSelectedCountries(weeklyCountry);


        //Checks if timezone is empty, if so fill in with the user timezone
        TimeZone tz = UserInfo.getTimeZone();
        if(newFormDaily.TimeZone__c == null){
            newFormDaily.TimeZone__c = tz.toString();
        }
        if(newFormWeekly.TimeZone__c == null){
            newFormWeekly.TimeZone__c = tz.toString();
        }


        //system.debug('dailyCountry: ' + dailyCountry);
        //system.debug('weeklyCountry: ' + weeklyCountry);

        if (ApexPages.currentPage().getParameters().containsKey('step')){
            stepNumber = ApexPages.currentPage().getParameters().get('step');
            param = true;
        }else{
            stepNumber = '0';
            param = false;
        }
        
        isStepHome = false;
        isStep1 = false;
        isStep1_1 = false;
        isStep1_2 = false;
        isStep2 = false;
        isStep3 = false;

        if(stepNumber.equalsIgnoreCase('Home')){
            isStepHome = true;
        }else if(stepNumber.equalsIgnoreCase('1')){
            isStep1 = true;
        }else if(stepNumber.equalsIgnoreCase('1_1')){
            isStep1_1 = true;
        }else if(stepNumber.equalsIgnoreCase('1_2')){
            isStep1_2 = true;
        }else if(stepNumber.equalsIgnoreCase('2')){
            isStep2 = true;
        }else if(stepNumber.equalsIgnoreCase('3')){
            isStep3 = true;
        }else{
            //No Parameter area, when loading 1st time it passes here!

            System.debug('1st time');
            System.debug('newFormDaily: ' + newFormDaily);
            System.debug('newFormWeekly: ' + newFormWeekly);

            //Check if is "firstTime", this will lead the user for 1st step or 2nd step
            if(isFirstTime){
                isStep1_1 = true;   
                newFormDaily.Opt_in__c = newFormDaily.Opt_in__c == null? true : newFormDaily.Opt_in__c;
                newFormWeekly.Opt_in__c = newFormWeekly.Opt_in__c == null? true : newFormWeekly.Opt_in__c;
            }else{
                isStep2 = true;     
            }

        }    

        System.debug('isStep1: ' + isStep1);
        System.debug('isStep2: ' + isStep2);
        System.debug('isStep3: ' + isStep3);

        //Set Selected value for the "day" field in the Daily selection
        daysOfWeek = Datetime.now().format('dd/MM/yyyy');
        todayOption = daysOfWeek;

        //Set Selected value for the "Week" field in the Weekly selection
        Datetime dtToday = Datetime.now();
        Date myDate = Date.today();
        Date weekStart;
        Boolean isDayBefore = false;
        weekStart = myDate.toStartofWeek()+5;
        if(dtToday < weekStart){
            weekStart = myDate.toStartofWeek()-2;
            isDayBefore = true;
        }
        String weekDayDtToday = dtToday.format('EEEE');
        Datetime dtWeekStart = Datetime.newInstance(weekStart.year(), weekStart.month(),weekStart.day());
        Datetime dtWeekEnd = dtWeekStart;
        String weekDay = dtWeekEnd.format('EEEE');
        while(!weekDay.equalsIgnoreCase('Thursday') && dtWeekEnd >= dtWeekStart){
            dtWeekEnd = dtWeekEnd.addDays(+1);
            weekDay = dtWeekEnd.format('EEEE');
        }
        week = dtWeekStart.format('dd/MM/yyyy')+ '-' +dtWeekEnd.format('dd/MM/yyyy');

        batchRecordsId = null;
        isBatchProcessing = false;
        isGettingReportDaily = false;
        isGettingReportWeekly = false;
        weeklyFileDownloadList = new List<WrapperReports>();
        isAvailableToShowWeekly = false;
        dailyFileDownloadList = new List<WrapperReports>();
        isAvailableToShowDaily = false;

    }

    public PageReference checkRedirect(){
        //If the param "Step" have the "home" value the page will not be redirected 
        if(isStepHome){
            return null;
              //when NOT 1st time the page is redirected to the daily record    
        }else if(!isFirstTime){
            return goToStep2();
        }
        else{
            return null;
        }
    }

    //Get the User Guide Document link
    public String getUserGuideFileLink(String param, String lang){
        
        String sRet = '';
        String defaultLang = 'en_US';

        String paramString = param + '%';

        pdfUserGuide = [SELECT Name, Address__c, Link_To_PDF__c FROM ISSP_PDF_Per_Region__c
                                           WHERE Name Like :paramString ];

        //If we get result we go thru the records to find the one with the choosen lang 
        if(pdfUserGuide.size() > 0){
        
            for(ISSP_PDF_Per_Region__c pdf : pdfUserGuide){

                //Check for choosen Lang
                if(pdf.Name.toLowerCase().contains(lang.toLowerCase()) ){
                    sRet = pdf.Link_To_PDF__c;
                      //Check for Default Lang, only set's the value if the value is still empty        
                }else if(pdf.Name.toLowerCase().contains(defaultLang.toLowerCase()) ){
                    if(sRet.equalsIgnoreCase('')){
                        sRet = pdf.Link_To_PDF__c;
                    }
                }

            }

            
        }
        return sRet;
    }


    public List<SelectOption> getTimeZone(){
      List<SelectOption> options = new List<SelectOption>();
      Schema.DescribeFieldResult fieldResult =User.TimeZoneSidKey.getDescribe();
      List<Schema.PicklistEntry> PkListEntry = fieldResult.getPicklistValues();
      for( Schema.PicklistEntry  pkEnt : PkListEntry) {
          options.add(new SelectOption(pkEnt.getValue(),pkEnt.getLabel()));
       }       
       return options;
    }

    public List<SelectOption> getItemsDaysOfWeek() {

        Datetime dtToday = Datetime.now();
        String weekDay = dtToday.format('EEEE');

        
        //while(!weekDay.equalsIgnoreCase('Saturday')){
        //  dtToday = dtToday.addDays(-1);
        //  weekDay = dtToday.format('EEEE');
        //}

        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption(dtToday.format('dd/MM/yyyy'),' ' + dtToday.format(' EEEE, d MMMM, yyyy'),dtToday > Datetime.now()?true:false));
        options.add(new SelectOption(dtToday.addDays(-1).format('dd/MM/yyyy'),' ' + dtToday.addDays(-1).format(' EEEE, d MMMM, yyyy'),dtToday.addDays(-1) > Datetime.now()?true:false));
        options.add(new SelectOption(dtToday.addDays(-2).format('dd/MM/yyyy'),' ' + dtToday.addDays(-2).format(' EEEE, d MMMM, yyyy'),dtToday.addDays(-2) > Datetime.now()?true:false));
        options.add(new SelectOption(dtToday.addDays(-3).format('dd/MM/yyyy'),' ' + dtToday.addDays(-3).format(' EEEE, d MMMM, yyyy'),dtToday.addDays(-3) > Datetime.now()?true:false));
        options.add(new SelectOption(dtToday.addDays(-4).format('dd/MM/yyyy'),' ' + dtToday.addDays(-4).format(' EEEE, d MMMM, yyyy'),dtToday.addDays(-4) > Datetime.now()?true:false));
        options.add(new SelectOption(dtToday.addDays(-5).format('dd/MM/yyyy'),' ' + dtToday.addDays(-5).format(' EEEE, d MMMM, yyyy'),dtToday.addDays(-5) > Datetime.now()?true:false));
        options.add(new SelectOption(dtToday.addDays(-6).format('dd/MM/yyyy'),' ' + dtToday.addDays(-6).format(' EEEE, d MMMM, yyyy'),dtToday.addDays(-6) > Datetime.now()?true:false));

        //Sets today Option for validation on the VFP in order to present the period (midnight or last execution)
        todayOption = options.get(0).getValue();
        //for(SelectOption so: options){
        //  if(!so.getDisabled()){
        //      todayOption = so.getValue();
        //  }
        //}

        return options; 
    }

    public List<SelectOption> getItemsWeeks() {

        Datetime dtToday = Datetime.now();
        Date myDate = Date.today();
        
        //for Test Porpuses
        //Datetime dtToday = Datetime.now()+3;
        //Date myDate = Date.today()+3;
        
        Date weekStart;
        Boolean isDayBefore = false;

        //Sets the start of the week for a Friday (+5)
        weekStart = myDate.toStartofWeek()+5;

        //Checks if today date is before or after the friday select above, if is before we set the friday before as a starting point.
        if(dtToday < weekStart){
            weekStart = myDate.toStartofWeek()-2;
            isDayBefore = true;
        }

        String weekDayDtToday = dtToday.format('EEEE');

        Datetime dtWeekStart = Datetime.newInstance(weekStart.year(), weekStart.month(),weekStart.day());

        Datetime dtWeekEnd = dtWeekStart;
        String weekDay = dtWeekEnd.format('EEEE');

        while(!weekDay.equalsIgnoreCase('Thursday') && dtWeekEnd >= dtWeekStart){
            dtWeekEnd = dtWeekEnd.addDays(+1);
            weekDay = dtWeekEnd.format('EEEE');
        }

        Integer i = 0;

        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption(dtWeekStart.format('dd/MM/yyyy')+ '-' +dtWeekEnd.format('dd/MM/yyyy') , dtWeekStart.format(' EEEE, d MMMM') + ' - ' + dtWeekEnd.format(' EEEE, d MMMM yyyy'))); 

        List<String> splitDate = eBulletin_StartDate.split('/');
        Datetime startDate = Datetime.newInstance(Integer.valueOf(splitDate.get(2)), Integer.valueOf(splitDate.get(1)), Integer.valueOf(splitDate.get(0)));
        
        //Integer iDays = dtToday.g - startDate;
        integer iDays = Integer.valueOf((dtToday.getTime() - startDate.getTime())/(1000*60*60*24));

        //check if the start date is bigger than a year, if so we set the limit to 365 days instead of the calculated days 
        if(iDays > 365){
            iDays = 365;
        }

        for(i=-7; i > -iDays; i = i - 7){
            options.add(new SelectOption(dtWeekStart.addDays(i).format('dd/MM/yyyy')+ '-' +dtWeekEnd.addDays(i).format('dd/MM/yyyy') , dtWeekStart.addDays(i).format(' EEEE, d MMMM') + ' - ' + dtWeekEnd.addDays(i).format(' EEEE, d MMMM yyyy'))); 
        }
        
        return options; 
    }

    public List<SelectOption> countryNameListSelectOptionDaily {
        get {

            List<SelectOption> auxListSO = countryNameListSelectOption('Daily');
            List<SelectOption> auxListSO_clone = countryNameListSelectOption('Daily');

            //Checks if "Select All" is checked or not
            if(!dailyCountrySelectAll){
                
                //Remove Select values from the "Selected" list that doens't exist anymore on the "to select" list
                for(Integer i=dailyCountrySelected.size()-1; i >= 0 ; i--){
                    Boolean bExist = false;
                    for(SelectOption auxSO2 : auxListSO){
                        if(dailyCountrySelected.get(i).getValue() == auxSO2.getValue()){
                            bExist = true;
                        }
                    }
                    if(!bExist){
                        dailyCountrySelected.remove(i);
                    }
                }
                

                //system.debug('Initial auxListSO.size(): ' + auxListSO.size());
                //system.debug('Initial auxListSO_clone.size(): ' + auxListSO_clone.size());


                //Remove Selected Values from the "to select" list
                for(Integer i=auxListSO_clone.size()-1; i >= 0 ; i--){
                    //system.debug('i: ' + i + ' || auxListSO.size(): ' + auxListSO.size());
                    Boolean bExist = false;
                    for(SelectOption auxSO2 : dailyCountrySelected){
                        if(auxListSO.get(i) != null && auxSO2.getValue() != null && auxListSO.get(i).getValue() == auxSO2.getValue()){
                            auxListSO.remove(i);
                            break;
                        }
                    }

                }
            }else{
                dailyCountrySelected.clear();
                dailyCountrySelected = auxListSO;
                auxListSO = new List<SelectOption>();
            }

            return auxListSO;
        }
        set;
    }

    public List<SelectOption> countryNameListSelectOptionWeekly {
        get {
            List<SelectOption> auxListSO = countryNameListSelectOption('Weekly');
            List<SelectOption> auxListSO_clone = countryNameListSelectOption('Weekly');

            //Checks if "Select All" is checked or not
            if(!weeklyCountrySelectAll){

                //Remove Select values from the "Selected" list that doens't exist anymore on the "to select" list
                for(Integer i=weeklyCountrySelected.size()-1; i >= 0 ; i--){
                    Boolean bExist = false;
                    for(SelectOption auxSO2 : auxListSO){
                        if(weeklyCountrySelected.get(i).getValue() == auxSO2.getValue()){
                            bExist = true;
                        }
                    }
                    if(!bExist){
                        weeklyCountrySelected.remove(i);
                    }
                }

                //system.debug('Weekly Initial auxListSO.size(): ' + auxListSO.size());
                //system.debug('Weekly Initial auxListSO_clone.size(): ' + auxListSO_clone.size());

                
                //Remove Selected Values from the "to select" list
                for(Integer i=auxListSO_clone.size()-1; i >= 0 ; i--){
                    //system.debug('Weekly i: ' + i + ' || auxListSO.size(): ' + auxListSO.size());
                    Boolean bExist = false;
                    for(SelectOption auxSO2 : weeklyCountrySelected){
                        if(auxListSO.get(i) != null && auxSO2.getValue() != null && auxListSO.get(i).getValue() == auxSO2.getValue()){
                            auxListSO.remove(i);
                            break;
                        }
                    }

                }
            }else{
                weeklyCountrySelected.clear();
                weeklyCountrySelected = auxListSO;
                auxListSO = new List<SelectOption>();
            }

            return auxListSO;
            
        }
        set;
    }

    public void dailyCountrySelectAll(){
        List<SelectOption> auxListSO = countryNameListSelectOption('Daily');
        if(dailyCountrySelectAll){
            dailyCountrySelected.clear();
            for(SelectOption auxSO : auxListSO){
                dailyCountrySelected.add(auxSO);
            } 
        }else{
            dailyCountrySelected.clear();
        }
    }

    public void weeklyCountrySelectAll(){
        List<SelectOption> auxListSO = countryNameListSelectOption('Weekly');
        if(weeklyCountrySelectAll){
            weeklyCountrySelected.clear();
            for(SelectOption auxSO : auxListSO){
                weeklyCountrySelected.add(auxSO);
            } 
        }else{
            weeklyCountrySelected.clear();
        }
    }

    public List<SelectOption> populateSelectedCountries(List<String> lSelectedCountries){

        List<SelectOption> auxSO = new List<SelectOption>();

        for(String aux : lSelectedCountries){
            
            System.debug('populateSelectedCountries - mCountries:' + mCountries);
            if(!mCountries.containsKey(aux)){
                continue;
            }
            

            IATA_ISO_Country__c iso = mCountries.get(aux);

            if (applyLanguage == 'es') {
                if (iso.IATA_Country_SP__c != null)
                    auxSO.add(new SelectOption(iso.ISO_Code__c , iso.IATA_Country_SP__c));
                else
                    auxSO.add(new SelectOption(iso.ISO_Code__c , iso.Name));
            } else if (applyLanguage == 'fr') {
                if (iso.IATA_Country_FR__c != null)
                    auxSO.add(new SelectOption(iso.ISO_Code__c, iso.IATA_Country_FR__c));
                else
                    auxSO.add(new SelectOption(iso.ISO_Code__c, iso.Name));
            } else {
                auxSO.add(new SelectOption(iso.ISO_Code__c , iso.Name));
            }       
        }
        return auxSO;
    }

    public List<String> getCountryName(List<String> lCountries){

        List<String> auxSO = new List<String>();

        //System.debug('getCountryName - lCountries: ' + lCountries);
        //System.debug('getCountryName - lCountries.size(): ' + lCountries.size());
        //System.debug('getCountryName - lCountries.isEmpty(): ' + lCountries.isEmpty());

        for(String aux : lCountries){
            
            //System.debug('getCountryName - mCountries: ' + mCountries);
            //System.debug('getCountryName - aux: ' + aux);

            IATA_ISO_Country__c iso = mCountries.get(aux);

            if(iso != null){
                //System.debug('getCountryName - IATA_ISO_Country__c - iso: ' + iso);

                if (applyLanguage == 'es') {
                    if (iso.IATA_Country_SP__c != null)
                        auxSO.add(iso.IATA_Country_SP__c);
                    else
                        auxSO.add(iso.Name);
                } else if (applyLanguage == 'fr') {
                    if (iso.IATA_Country_FR__c != null)
                        auxSO.add(iso.IATA_Country_FR__c);
                    else
                        auxSO.add(iso.Name);
                } else {
                    auxSO.add(iso.Name);
                }   
            }   
        }
        return auxSO;
    }

    public List<SelectOption> countryNameListSelectOption(String sType) {
        
        List<SelectOption> options = new List<SelectOption>();

        Set<String> sRegion = new Set<String>();

        AMS_eBulletin_Profile__c newForm;

        if( sType.equalsIgnoreCase('Daily') ){
            newForm = newFormDaily;
        }else if( sType.equalsIgnoreCase('Weekly') ){
            newForm = newFormWeekly;
        }

        if(newForm.Area_1__c == true){
            sRegion.add('Americas');
        }
        if(newForm.Area_2__c == true){
            sRegion.add('Europe');
            sRegion.add('Africa & Middle East');
        }
        if(newForm.Area_3__c == true){
            sRegion.add('China & North Asia');
            sRegion.add('Asia & Pacific');
        }


        if(sRegion.size() > 0){
            list<IATA_ISO_Country__c> isoList;
            if (applyLanguage == 'es') {
                isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByRegion(sRegion), 'IATA_Country_SP__c');
            } else if (applyLanguage == 'fr') {
                isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByRegion(sRegion), 'IATA_Country_FR__c');
            } else {
                isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByRegion(sRegion), 'Name');
            }

            //options.add(new SelectOption('', Label.ISSP_SELECT_COUNTRY));
            for (IATA_ISO_Country__c iso : isoList) {
                if(iso.Case_BSP_Country__c != null && iso.Case_BSP_Country__c != '' && iso.Region__c != 'USA'){
                    if (applyLanguage == 'es') {
                        if (iso.IATA_Country_SP__c != null)
                            options.add(new SelectOption(iso.ISO_Code__c , iso.IATA_Country_SP__c));
                        else
                            options.add(new SelectOption(iso.ISO_Code__c , iso.Name));
                    } else if (applyLanguage == 'fr') {
                        if (iso.IATA_Country_FR__c != null)
                            options.add(new SelectOption(iso.ISO_Code__c, iso.IATA_Country_FR__c));
                        else
                            options.add(new SelectOption(iso.ISO_Code__c, iso.Name));
                    } else {
                        options.add(new SelectOption(iso.ISO_Code__c , iso.Name));
                    }
                }
            }
        }

        if(options.isEmpty()){
            options.add(new SelectOption('--- Select an Area ---', '--- Select an Area ---'));
        }

        return options;

    }



    public void fillMapCountries() {

        if(mCountries == null){
            mCountries = new Map<String,IATA_ISO_Country__c>();
        
            List<IATA_ISO_Country__c> isoList;
            
            isoList = IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull();
            
            for (IATA_ISO_Country__c iso : isoList) {
                if(iso.Region__c != 'USA'){
                    mCountries.put(iso.ISO_Code__c , iso);
                }
            }
        }

    }


   
    public void fetchAMSProcessForm() {
        List <AMS_eBulletin_Profile__c> newForms = [
                    SELECT Agency_Info_Agency_Changes__c,Agency_Info_Defaults__c,Agency_Info_Irregularities__c,Agency_Info_New_Aplication_Processes__c,
                        Agency_Info_Reviews__c,Agency_Info_Termination_Closures__c,Area_1__c,Area_2__c,Area_3__c,CountriesList__c,CreatedDate,Daily_Frequency__c,
                        Id,LastModifiedDate,Name,Opt_out_Bulletin__c,Program_Cargo__c,Program_CASS_Associates__c,Program_Passage__c,Program_Domestic__c,Suspend_Subscription__c,
                        RecordTypeId,User__c, TimeZone__c,Opt_in__c,StatusDisplay__c,Last_Run__c,Agency_Info_Reinstatements__c
                    FROM AMS_eBulletin_Profile__c
                    WHERE User__c = :Userinfo.getuserid()
                    LIMIT 2
                ];

        system.debug('fetchAMSProcessForm newForms: ' + newForms);

        if (newForms.size() > 0) {

            //Since we got records we mark "firstTime" as false
            isFirstTime = false;

            for(AMS_eBulletin_Profile__c aux: newForms){
                if(aux.RecordTypeId == DAILY_RECORD_TYPE_ID){
                    newFormDaily = aux;
                }
                if(aux.RecordTypeId == WEEKLY_RECORD_TYPE_ID){
                    newFormWeekly = aux;    
                }
            }
        }
    }


    private void popContact() {
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        system.debug('user.ContactId ' + user.ContactId);
        con = DAL_ISSP.getContact(user.ContactId);

        if (con.User_Portal_Status__c == 'Administrator' || con.User_Portal_Status__c == 'Approved Admin' || con.User_Portal_Status__c == 'Regional Administrator' || con.User_Portal_Status__c == 'R. Administrator' )
            bIsAdmin = true;
    }

    public Pagereference securityCheck() {

        

        return null;
    }


    public String getMultiSelectToSave(List<String> vals) {
        String res = '';
        Boolean Start = true;
        
        if(vals != null && vals.size() > 0) {           
            for(String Str : vals) {
                if(Start) {
                    res = Str;
                    Start = false;
                } else {               
                    res = res + ';' + Str;
                }
            }
        }
        
        return res;
    }

     public String getMultiSelectOptionsToSave(List<SelectOption> vals) {
        String res = '';
        Boolean Start = true;
        
        if(vals != null && vals.size() > 0) {           
            for(SelectOption val : vals) {
                if(Start) {
                    res = val.getValue();
                    Start = false;
                } else {               
                    res = res + ';' + val.getValue();
                }
            }
        }
        
        return res;
    }

    public Pagereference saveAMSFormAndStay() {
        try {
            system.debug('Salesforce saveAMSFormAndStay: start ' + newFormDaily);
            boolean bRes = saveAMSForm();
            system.debug('Salesforce saveAMSFormAndStay bRes: ' + bRes);

            if (!validateCharactersInForm())
                return null;
            
            if(bRes && isStep1_1)
                return goToStep1_1();

            if(bRes && isStep1_2)
                return goToStep1_2();

        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }


    public boolean saveAMSForm() {

        boolean bRes = true;

        
        system.debug('Salesforce saveAMSForm newFormDaily: ' + newFormDaily);
        system.debug('Salesforce saveAMSForm newFormWeekly: ' + newFormWeekly);

        system.debug('Salesforce saveAMSForm dailyCountry: ' + dailyCountry);
        system.debug('Salesforce saveAMSForm weeklyCountry: ' + weeklyCountry);
        
        //newFormDaily.CountriesList__c = getMultiSelectToSave(dailyCountry);
        //newFormWeekly.CountriesList__c = getMultiSelectToSave(weeklyCountry);
        newFormDaily.CountriesList__c = getMultiSelectOptionsToSave(dailyCountrySelected);
        newFormWeekly.CountriesList__c = getMultiSelectOptionsToSave(weeklyCountrySelected);

        system.debug('Salesforce saveAMSForm newFormDaily: ' + newFormDaily);
        system.debug('Salesforce saveAMSForm newFormWeekly: ' + newFormWeekly);


        //Since on the form the timezone is set to the Daily form we just give the same value to the WEEKLY one
        newFormWeekly.TimeZone__c = newFormDaily.TimeZone__c;

        try {

            upsert newFormDaily;
            upsert newFormWeekly;

           
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
            system.debug('Salesforce saveAMSForm ex: ' + ex);
            bRes = false;
       
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            system.debug('Salesforce saveAMSForm ex: ' + ex);
            bRes = false;
       
        }
        return bRes;
    }


    public Pagereference saveAMSFormAndGoBack() {

        try {
            //system.debug('kerensen Zohar goToFinalStep newForm: ' + newForm);
            //system.debug('kerensen Zohar goToFinalStep newCase: ' + newCase);

            //newForm.Validation_ERRORS__c = FALSE;
            boolean bRes = saveAMSForm();
            
            if (!validateCharactersInForm())
                return null;
            
            if(bRes && isStep2)
                return goToStep1();

            if(bRes && isStep3)
                return goToStep2();
                    
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }

    public Pagereference saveAMSFormAndGoForward() {

        try {
            //system.debug('kerensen Zohar goToFinalStep newForm: ' + newForm);
            //system.debug('kerensen Zohar goToFinalStep newCase: ' + newCase);

            //newForm.Validation_ERRORS__c = FALSE;
            boolean bRes = saveAMSForm();
            
            if (!validateCharactersInForm())
                return null;
            
            if(bRes && isStep1)
                return goToStep2();

            if(bRes && isStep1_1)
                return goToStep2();

            if(bRes && isStep1_2)
                return goToStep3();

            if(bRes && isStep2)
                return goToStep3();


        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }

    public Pagereference saveAMSFormAndGoSideways() {

        try {
            //system.debug('kerensen Zohar goToFinalStep newForm: ' + newForm);
            //system.debug('kerensen Zohar goToFinalStep newCase: ' + newCase);

            //newForm.Validation_ERRORS__c = FALSE;
            Boolean bToSave = false;
            if(isStep1_1 && newFormDaily.Opt_in__c ){
                bToSave = true;
            }

            if(isStep1_2 && newFormWeekly.Opt_in__c){
                bToSave = true;
            }

            boolean bRes = true;

            //only saves if the "Opt-in" is checked
            if(bToSave){
                bRes = saveAMSForm();
            }

            if (!validateCharactersInForm())
                return null;
            
            if(bRes && isStep1_1)
                return goToStep1_2();

            if(bRes && isStep1_2)
                return goToStep1_1();

        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }


    public Pagereference suspendSubscription() {

        ApexPages.Message myMsg;
        

        if(newFormDaily.Suspend_Subscription__c){
            newFormDaily.Suspend_Subscription__c = false;
            newFormWeekly.Suspend_Subscription__c = false;
            myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your Subscription was successfully activated!');
        }else{
            newFormDaily.Suspend_Subscription__c = true;
            newFormWeekly.Suspend_Subscription__c = true;           
            myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your Subscription was successfully suspended!');
        }

        try {
            boolean bRes = saveAMSForm();

            system.debug('suspendSubscription - newFormDaily.CountriesList__c: ' + newFormDaily.CountriesList__c);
            system.debug('suspendSubscription - newFormWeekly.CountriesList__c: ' + newFormWeekly.CountriesList__c);

            system.debug('suspendSubscription - before - dailyCountry: ' + dailyCountry);
            system.debug('suspendSubscription - before - weeklyCountry: ' + weeklyCountry);

            dailyCountry = newFormDaily.CountriesList__c == null ? new List<String>() : newFormDaily.CountriesList__c.split(';');
            weeklyCountry = newFormWeekly.CountriesList__c == null ? new List<String>() : newFormWeekly.CountriesList__c.split(';');

            system.debug('suspendSubscription - after - dailyCountry: ' + dailyCountry);
            system.debug('suspendSubscription - after - weeklyCountry: ' + weeklyCountry);

            dailyCountryName = getCountryName(dailyCountry);
            weeklyCountryName = getCountryName(weeklyCountry);
            
            ApexPages.addMessage(myMsg);
                    
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        
        //return new Pagereference('/ISSP_AMS_EBulletin');
        return null;
        
    }

    public boolean validateCharactersInForm() {
        boolean errorFound = false;
        Pattern p = Pattern.compile(ISO_8859_1_regEx);

        if (errorFound)
            return false;

        return true;
    }

    public Pagereference goToStepHome() {
        return new Pagereference('/ISSP_EBulletin_Home?step=home');
    }
 
    public Pagereference goToStep1() {
        return new Pagereference('/ISSP_AMS_EBulletin?step=1');
    }

     public Pagereference goToStep1_1() {
        return new Pagereference('/ISSP_AMS_EBulletin?step=1_1');
    }

     public Pagereference goToStep1_2() {
        return new Pagereference('/ISSP_AMS_EBulletin?step=1_2');
    }

    public Pagereference goToStep2() {
        return new Pagereference('/ISSP_AMS_EBulletin?step=2');
    }

    public Pagereference goToStep3() {
        return new Pagereference('/ISSP_AMS_EBulletin?step=3');
    }

    public Pagereference dailyReportDownload() {
        //System.debug('dailyReportDownload');

        //'dd/MM/yyyy'

        List<String> splitDate = pDateStart.split('/');
        System.debug('splitDate - ' + splitDate);

        Datetime startDate = Datetime.newInstance(Integer.valueOf(splitDate.get(2)), Integer.valueOf(splitDate.get(1)), Integer.valueOf(splitDate.get(0)));
        Datetime endDate = startDate.addDays(1);
        String period = todayPeriod == null?'':todayPeriod;

        //System.debug('startDate - ' + startDate);
        //System.debug('period - ' + period);

        Id res;
        try{

            if(period == 'last' && newFormDaily.Last_Run__c != null && newFormDaily.Last_Run__c > startDate)
                startDate = newFormDaily.Last_Run__c;

            filters = new AMS_EBulletinReportHelper.AMSEBulletinFilters(newFormDaily, startDate, endDate);

            System.debug('Initializing...');

            String header = getHeader();
            System.debug('ISSP_AMS_EBulletin - dailyReportDownload - header: ' + header);
            dailyFileDownloadList = new List<WrapperReports>();
            isAvailableToShowDaily = false;
            dailyAllIdsList = new Set<Id>();
            getRecords(header, newFormDaily, endDate, startDate);

        }catch(Exception e){
            dailyFileDownloadList = new List<WrapperReports>();
            isAvailableToShowDaily = false;
            dailyAllIdsList = new Set<Id>();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
            isGettingReportDaily = false;
        }

        return null;
    }

    
    public Pagereference weeklyReportDownload() {

        System.debug('weeklyReportDownload');

        System.debug('week - ' + week);
        System.debug('Salesforce saveAMSForm newFormWeekly: ' + newFormWeekly.Id);
        System.debug('Salesforce saveAMSForm pWeekStart: ' + pWeekStart);
        System.debug('Salesforce saveAMSForm pWeekEnd: ' + pWeekEnd);

        List<String> splitStartDate = pWeekStart.split('/');
        List<String> splitEndDate = pWeekEnd.split('/');

        Datetime startDate = Datetime.newInstance(Integer.valueOf(splitStartDate.get(2)), Integer.valueOf(splitStartDate.get(1)), Integer.valueOf(splitStartDate.get(0)));
        Datetime endDate = Datetime.newInstance(Integer.valueOf(splitEndDate.get(2)), Integer.valueOf(splitEndDate.get(1)), Integer.valueOf(splitEndDate.get(0)),23,59,59);
        String period = '';
        
        //System.debug('startDate - ' + startDate);
        //System.debug('endDate - ' + endDate);

        Id res;
        try{
            //get header of the pdf
            if(period == 'last' && newFormWeekly.Last_Run__c != null && newFormWeekly.Last_Run__c > startDate)
                startDate = newFormWeekly.Last_Run__c;

            filters = new AMS_EBulletinReportHelper.AMSEBulletinFilters(newFormWeekly, startDate, endDate);

            System.debug('Initializing...');

            String header = getHeader();
            System.debug('ISSP_AMS_EBulletin - weeklyReportDownload - header: ' + header);
            weeklyFileDownloadList = new List<WrapperReports>();
            isAvailableToShowWeekly = false;
            weeklyAllIdsList = new Set<Id>();
            getRecords(header, newFormWeekly, endDate, startDate);

        }catch(Exception e){
            weeklyFileDownloadList = new List<WrapperReports>();
            isAvailableToShowWeekly = false;
            weeklyAllIdsList = new Set<Id>();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
            isGettingReportWeekly = false;
        }

        return null;
    }


    @TestVisible private static String getHeader(){

        System.debug('Get CSV Header...');
        
        AMS_EBulletinReportHelper.getEBulletinFields(filters,objectBaseQuery,eBulletinCSVFormat);

        return AMS_EBulletinReportHelper.headerCSV;
    }


    private void getRecords(String header, AMS_eBulletin_Profile__c eBulletinProfile, Datetime endDate, Datetime startDate){
        
        System.debug('Get CSV Records...');

        String query = getQuery();

        System.debug('ISSP_AMS_EBulletin - getRecords - query: ' + query);
        System.debug('ISSP_AMS_EBulletin - getRecords - ccNamesToRecoverAux: ' + ccNamesToRecoverAux);
        System.debug('ISSP_AMS_EBulletin - getRecords - countriesFilterAux: ' + countriesFilterAux);
        System.debug('ISSP_AMS_EBulletin - getRecords - locClsListAux: ' + locClsListAux);

        AMS_EBulletinRecordsBatch batchRecords = new AMS_EBulletinRecordsBatch(header, query, eBulletinProfile, endDate, startDate, ccNamesToRecoverAux, countriesFilterAux, locClsListAux, false);
        isBatchProcessing = true;
        batchRecordsId = Database.executeBatch(batchRecords, 200);
    }

    @TestVisible private static String getQuery(){

        System.debug('Get query...');
        
        return AMS_EBulletinReportHelper.getEBulletinRecordsQuery(filters,objectBaseQuery,eBulletinCSVFormat,false);

    }

    public static void updateQueryVariables(Set<String> ccNamesToRecover, List<String> countriesFilter, List<String> locClsList) {

        ccNamesToRecoverAux = ccNamesToRecover;
        countriesFilterAux = countriesFilter;
        locClsListAux = locClsList;
    }


    public void isGettingReportStartDaily(){
        isGettingReportDaily = true;
    }

    public void isGettingReportStartWeekly(){
        isGettingReportWeekly = true;
    }


    public PageReference checkBatchStatus() {

        System.debug('ISSP_AMS_EBulletin - checkBatchStatus');

        List<AsyncApexJob> aaj = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE Id = :batchRecordsId];

        System.debug('ISSP_AMS_EBulletin - checkBatchStatus - aaj: ' + aaj);

        if(!aaj.isEmpty()){

            if(aaj.get(0).Status == 'Completed' && aaj.get(0).ExtendedStatus != null && aaj.get(0).ExtendedStatus.contains('01')){

                jobCompletedWithoutAttachment('01');

                System.debug('ISSP_AMS_EBulletin - checkBatchStatus - job completed without records');

            } else if(aaj.get(0).Status == 'Completed') {

                String nameAtt = String.valueOf(batchRecordsId) + '%';
                System.debug('ISSP_AMS_EBulletin - checkBatchStatus - nameAtt: ' + nameAtt);
                List<Attachment> attachments = new List<Attachment>();
                attachments = [SELECT Id, Name FROM Attachment WHERE Name LIKE :nameAtt];

                if(!attachments.isEmpty()) {

                    isBatchProcessing = false;
                    isGettingReportWeekly = false;
                    isGettingReportDaily = false;
                    isAvailableToShowWeekly = true;
                    isAvailableToShowDaily = true;   
                    System.debug('ISSP_AMS_EBulletin - checkBatchStatus - job completed with records');

                    Integer index = 1;

                    for(Attachment att : attachments) {

                        if(attachments.size() == 1) {

                            att.Name = att.Name.removeStart(batchRecordsId + '_');

                        } else {

                            att.Name = att.Name.replace(batchRecordsId, 'Part' + index);
                            index++;
                        }

                        if(att.Name.containsIgnoreCase('weekly')) {

                            weeklyFileDownloadList.add(new WrapperReports(att.Id, att.Name));
                            weeklyAllIdsList.add(att.Id);

                        } else {

                            dailyFileDownloadList.add(new WrapperReports(att.Id, att.Name));
                            dailyAllIdsList.add(att.Id);
                        }
                    }

                    update attachments;

                    if(attachments.get(0).Name.containsIgnoreCase('weekly')) {

                        AMS_EBulletinReportHelper.updateEbulletinProfile(system.now(), newFormWeekly.Id, weeklyAllIdsList);

                    } else {

                        fetchAMSProcessForm();
                        AMS_EBulletinReportHelper.updateEbulletinProfile(system.now(), newFormDaily.Id, dailyAllIdsList);
                    }
                } else {

                    isBatchProcessing = true;
                    isGettingReportWeekly = true;
                    isGettingReportDaily = true;
                    isAvailableToShowWeekly = false;
                    isAvailableToShowDaily = false;
                    System.debug('ISSP_AMS_EBulletin - checkBatchStatus - job completed waiting for attachment');

                }

            } else if(aaj.get(0).Status == 'Aborted' || aaj.get(0).Status == 'Failed') {

                jobCompletedWithoutAttachment('00');

                System.debug('ISSP_AMS_EBulletin - checkBatchStatus - job failed or aborted with message : ' + aaj.get(0).ExtendedStatus);

            } else {

                isBatchProcessing = true;
                isGettingReportWeekly = true;
                isGettingReportDaily = true;
                isAvailableToShowWeekly = false;
                isAvailableToShowDaily = false;
                System.debug('ISSP_AMS_EBulletin - checkBatchStatus - job processing');

            }

        } else {

            jobCompletedWithoutAttachment('00');

            System.debug('ISSP_AMS_EBulletin - checkBatchStatus - job not found');
        }

        return null;
    }

    private void jobCompletedWithoutAttachment(String error) {

        isBatchProcessing = false;
        isGettingReportWeekly = false;
        isGettingReportDaily = false;

        weeklyFileDownloadList = new List<WrapperReports>();
        isAvailableToShowWeekly = false;
        weeklyAllIdsList = new Set<Id>();
        dailyFileDownloadList = new List<WrapperReports>();
        isAvailableToShowDaily = false;
        dailyAllIdsList = new Set<Id>();

        ApexPages.Message myMsg;

        if(error.equals('01')){
            myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Label.ISSP_AMS_eBulletin_ErrorMsg_01);
        } else {
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_eBulletin_ErrorMsg_00);
        }
        
        ApexPages.addMessage(myMsg);
    }

    
    public IATA_ISO_Country__c fetchISOCountry(string isocode) {

        IATA_ISO_Country__c isocountry = IATAIsoCountryDAO.getIsoCountryByIsoCodes(new Set<String>{isocode})[0];

        return isocountry;
    }

    /*** AMSU-62 ***/
    public PageReference clearAllDaily() {
        dailyCountrySelected = new List<SelectOption>();
        dailyCountrySelectAll = false;

        Id userId = Userinfo.getUserId();
        TimeZone tz = UserInfo.getTimeZone();
        Boolean editDaily = newFormDaily.Opt_in__c;
        Id recordId = newFormDaily.Id;

        newFormDaily = new AMS_eBulletin_Profile__c(Id= recordId, Opt_in__c= editDaily, RecordTypeId= DAILY_RECORD_TYPE_ID, 
            User__c= userId, TimeZone__c= tz.toString());

        return null;
    }

    public PageReference clearAllWeekly() {
        weeklyCountrySelected = new List<SelectOption>();
        weeklyCountrySelectAll = false;

        Id userId = Userinfo.getUserId();
        TimeZone tz = UserInfo.getTimeZone();
        Boolean editWeekly = newFormWeekly.Opt_in__c;
        Id recordId = newFormWeekly.Id;
        
        newFormWeekly = new AMS_eBulletin_Profile__c(Id= recordId, Opt_in__c= editWeekly, RecordTypeId= WEEKLY_RECORD_TYPE_ID, 
            User__c= userId, TimeZone__c= tz.toString());

        return null;
    }

    @RemoteAction
    public static List<FileDef> getAllAttachmentsToZip(String attachmentsToZipString) {

        List<FileDef> listFileDef = new List<FileDef>();
        Set<Id> attachmentsToZip = new Set<Id>();

        JSONParser parser = JSON.createParser(attachmentsToZipString);
        attachmentsToZip = (Set<Id>)parser.readValueAs(Set<Id>.class);

        for (Attachment attach : [SELECT Id, Name, Body FROM Attachment WHERE Id IN :attachmentsToZip]) {
            FileDef filedef = new FileDef();
            filedef.name = attach.Name;
            filedef.url='';
            filedef.data= EncodingUtil.base64Encode(attach.Body);
            listFileDef.add(filedef);
        }

        return listFileDef;
    }

    public class FileDef {
        String name;
        String url;
        String data;
    }

    public class WrapperReports {
        
        public String urlReport{get;set;}
        public String nameReport{get;set;}

        public WrapperReports(String attachmentId, String attachmentName){
            this.urlReport = '/servlet/servlet.FileDownload?file=' + attachmentId;
            this.nameReport = attachmentName;
        }

    }

}