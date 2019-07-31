public with sharing class CNS_EBulletin {

    private static Id DAILY_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_eBulletin_Profile__c', 'Daily');
    private static Id WEEKLY_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_eBulletin_Profile__c', 'Weekly');

    private static final string ISO_8859_1_regEx = '^[\\x00-\\x7F\\xA0-\\xFF]+$';  //Reg exp to limit inputted chars to ISO-8859-1

    public Map<String,IATA_ISO_Country__c> mCountries;

    public List<String> dailyCountry {get; set;}
    public List<String> weeklyCountry {get; set;}
    public List<String> dailyCountryName {get; set;}
    public List<String> weeklyCountryName {get; set;}

    public String dailyFileDownload {get; set;}
    public String weeklyFileDownload {get; set;}
    
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

    public AMS_eBulletin_Profile__c newFormDaily {get {
        
        return this.newFormDaily;
        
    } set;}
    public AMS_eBulletin_Profile__c newFormWeekly {get {
        
        return this.newFormWeekly;
        
    } set;}
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
    

    public CNS_EBulletin() {

        applyLanguage = UserInfo.getLanguage();
        displayLanguage = UserInfo.getLanguage();

        //set iso code to match datpicker format, in case of "english" the value is set to empty
        displayLanguageDatePicker = displayLanguage.equalsIgnoreCase('en_US') || displayLanguage.equalsIgnoreCase('in')  ? '' : displayLanguage.replace('_', '-');

        //Get the custom setting with the name of the userguide custom setting (ex: "EBULLETIN-USERGUIDE-")
        String paramUserGuide = ISSP_CS__c.getValues('eBulletin_UserGuide').Value__c;
        userGuideLink = getUserGuideFileLink(paramUserGuide, displayLanguage);

        newFormDaily = new AMS_eBulletin_Profile__c();
        newFormWeekly = new AMS_eBulletin_Profile__c();

        //for CNS 1st time is always false!
        isFirstTime = false;

        dailyCountrySelectAll = false;
        weeklyCountrySelectAll = false;

        if(newFormDaily.RecordTypeId == null){
            newFormDaily.RecordTypeId = DAILY_RECORD_TYPE_ID;
            //For CNS we don't need a user
            //newFormDaily.User__c = Userinfo.getuserid();
        }

        if(newFormWeekly.RecordTypeId == null){
            newFormWeekly.RecordTypeId = WEEKLY_RECORD_TYPE_ID;
            //For CNS we don't need a user
            //newFormWeekly.User__c = Userinfo.getuserid();
        }

        eBulletin_StartDate = ISSP_CS__c.getValues('eBulletin_StartDate').Value__c;
        eBulletin_StartDate_year = eBulletin_StartDate.split('/').get(2);
        eBulletin_StartDate_month = eBulletin_StartDate.split('/').get(1);
        eBulletin_StartDate_day = eBulletin_StartDate.split('/').get(0);

        fetchAMSProcessForm();

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

            // FOR CNS - entry point is always step2
            //Check if is "firstTime", this will lead the user for 1st step or 2nd step
            //if(isFirstTime){
            //    isStep1_1 = true;   
            //    newFormDaily.Opt_in__c = newFormDaily.Opt_in__c == null? true : newFormDaily.Opt_in__c;
            //    newFormWeekly.Opt_in__c = newFormWeekly.Opt_in__c == null? true : newFormWeekly.Opt_in__c;
            //}else{
                isStep2 = true;     
            //}
        }    
        
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

        //popContact();  //Get the contact details of currently logged in user

        batchRecordsId = null;
        isBatchProcessing = false;
        isGettingReportDaily = false;
        isGettingReportWeekly = false;
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

                //Remove Selected Values from the "to select" list
                for(Integer i=auxListSO_clone.size()-1; i >= 0 ; i--){

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

        for(String aux : lCountries){

            IATA_ISO_Country__c iso = mCountries.get(aux);

            if(iso != null){

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
                isoList = isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByRegion(sRegion), 'IATA_Country_FR__c');
            } else {
                isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByRegion(sRegion), 'Name');
            }

            for (IATA_ISO_Country__c iso : isoList) {
                if(iso.Case_BSP_Country__c != null && iso.Case_BSP_Country__c != ''){
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
            
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'Name');
            
            for (IATA_ISO_Country__c iso : isoList) {
                mCountries.put(iso.ISO_Code__c , iso);
            }
        }
    }

    public void fetchAMSProcessForm() {
        
        System.debug('fetchAMSProcessForm - begin');
        
        List <AMS_eBulletin_Profile__c> newForms = [
                    SELECT Agency_Info_Agency_Changes__c,Agency_Info_Defaults__c,Agency_Info_Irregularities__c,Agency_Info_New_Aplication_Processes__c,
                        Agency_Info_Reviews__c,Agency_Info_Termination_Closures__c,Area_1__c,Area_2__c,Area_3__c,CountriesList__c,CreatedDate,Daily_Frequency__c,
                        Id,LastModifiedDate,Name,Opt_out_Bulletin__c,Program_Cargo__c,Program_CASS_Associates__c,Program_Passage__c,Program_Domestic__c,Suspend_Subscription__c,
                        RecordTypeId,User__c, TimeZone__c,Opt_in__c,StatusDisplay__c,Last_Run__c,Agency_Info_Reinstatements__c
                    FROM AMS_eBulletin_Profile__c
                    WHERE CNS__c = true
                    LIMIT 2
                ];

        System.debug('fetchAMSProcessForm - newForms.size(): ' + newForms.size());
        
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
                
                System.debug('fetchAMSProcessForm - newFormDaily: ' + newFormDaily);
                System.debug('fetchAMSProcessForm - newFormWeekly: ' + newFormWeekly);
            }
        }else{
            //No records returned - 1st time we create the Daily and Weekly records for CNS
            isFirstTime = true;
            
            //Fetch country list for CNS
            //
            List<IATA_ISO_Country__c> isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name');
            String sCountryList = '';
                 
            Boolean Start = true;
        
            for (IATA_ISO_Country__c iso : isoList) {
                if(iso.CNS_Country__c == true){
                    if(Start) {
                        sCountryList = iso.ISO_Code__c;
                        Start = false;
                    } else {               
                        sCountryList = sCountryList + ';' + iso.ISO_Code__c;
                    }
                }
            }

            System.debug('sCountryList: ' + sCountryList);
            
            //Daily
            newFormDaily.RecordTypeId = DAILY_RECORD_TYPE_ID;
            newFormDaily.Program_Cargo__c = true;
            newFormDaily.Program_CASS_Associates__c = true;
            newFormDaily.Program_Domestic__c = true;
            newFormDaily.Program_Passage__c = true;
            newFormDaily.Agency_Info_Irregularities__c = true;
            newFormDaily.Agency_Info_Defaults__c = true;
            newFormDaily.Agency_Info_Termination_Closures__c = true;
            newFormDaily.Agency_Info_Reviews__c = true;
            newFormDaily.CountriesList__c = sCountryList;
            newFormDaily.Opt_in__c = true;
            newFormDaily.Opt_out_Bulletin__c = true;
            newFormDaily.CNS__c = true;
                    
            //Weekly
            newFormWeekly.RecordTypeId = WEEKLY_RECORD_TYPE_ID;    
            newFormWeekly.Program_Cargo__c = true;
            newFormWeekly.Program_CASS_Associates__c = true;
            newFormWeekly.Program_Domestic__c = true;
            newFormWeekly.Program_Passage__c = true;
            newFormWeekly.Agency_Info_Agency_Changes__c = true;
            newFormWeekly.Agency_Info_Defaults__c = true;
            newFormWeekly.Agency_Info_Irregularities__c = true;
            newFormWeekly.Agency_Info_New_Aplication_Processes__c = true;
            newFormWeekly.Agency_Info_Reviews__c = true;
            newFormWeekly.Agency_Info_Termination_Closures__c = true;
            newFormWeekly.CountriesList__c = sCountryList;
            newFormWeekly.Opt_in__c = true;
            newFormWeekly.Opt_out_Bulletin__c = true;
            newFormWeekly.CNS__c = true;
            
        }
    }

    /*private void popContact() {
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        if(user.ContactId != null){
            system.debug('user.ContactId ' + user.ContactId);
            con = DAL_ISSP.getContact(user.ContactId);
    
            if (con.User_Portal_Status__c == 'Administrator' || con.User_Portal_Status__c == 'Approved Admin' || con.User_Portal_Status__c == 'Regional Administrator' || con.User_Portal_Status__c == 'R. Administrator' )
                bIsAdmin = true;
        }else{
            //TODO CNS ### check if admin?
            //bIsAdmin = true;
        }
    }*/

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
            boolean bRes = saveAMSForm();

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

        //only saves records on the 1st time
        if(isFirstTime){
        
            //newFormDaily.CountriesList__c = getMultiSelectOptionsToSave(dailyCountrySelected);
            //newFormWeekly.CountriesList__c = getMultiSelectOptionsToSave(weeklyCountrySelected);
    
            //Since on the form the timezone is set to the Daily form we just give the same value to the WEEKLY one
            newFormWeekly.TimeZone__c = newFormDaily.TimeZone__c;
    
            try {
    
                upsert newFormDaily;
                upsert newFormWeekly;
            } catch (DmlException ex) {
                ApexPages.addMessages(ex);
                bRes = false;
           
            } catch (Exception ex) {
                ApexPages.addMessages(ex);
                bRes = false;
            }
        }
        return bRes;
    }

    public Pagereference saveAMSFormAndGoBack() {

        try {

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

            dailyCountry = newFormDaily.CountriesList__c == null ? new List<String>() : newFormDaily.CountriesList__c.split(';');
            weeklyCountry = newFormWeekly.CountriesList__c == null ? new List<String>() : newFormWeekly.CountriesList__c.split(';');

            dailyCountryName = getCountryName(dailyCountry);
            weeklyCountryName = getCountryName(weeklyCountry);
            
            ApexPages.addMessage(myMsg);
                    
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        
        return null;
        
    }

    public boolean validateCharactersInForm() {
        boolean errorFound = false;
        Pattern p = Pattern.compile(ISO_8859_1_regEx);

        if (errorFound)
            return false;

        return true;
    }
 
    public Pagereference goToStep1() {
        Pagereference pageRef = Page.CNS_EBulletin;
        pageref.getParameters().put('step','1');
        pageref.setRedirect(true);
        return pageref;
    }

     public Pagereference goToStep1_1() {
        Pagereference pageRef = Page.CNS_EBulletin;
        pageref.getParameters().put('step','1_1');
        pageref.setRedirect(true);
        return pageref;
    }

     public Pagereference goToStep1_2() {
        Pagereference pageRef = Page.CNS_EBulletin;
        pageref.getParameters().put('step','1_2');
        pageref.setRedirect(true);
        return pageref;
    }

    public Pagereference goToStep2() {
        Pagereference pageRef = Page.CNS_EBulletin;
        pageref.getParameters().put('step','2');
        pageref.setRedirect(true);
        return pageref;
    }

    public Pagereference goToStep3() {
        Pagereference pageRef = Page.CNS_EBulletin;
        pageref.getParameters().put('step','3');
        pageref.setRedirect(true);
        return pageref;
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
            System.debug('CNS_EBulletin - dailyReportDownload - header: ' + header);
            dailyFileDownload = '';
            getRecords(header, newFormDaily, endDate, startDate);

        }catch(Exception e){
            dailyFileDownload = '';
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
            System.debug('CNS_EBulletin - weeklyReportDownload - header: ' + header);
            weeklyFileDownload = '';
            getRecords(header, newFormWeekly, endDate, startDate);

        }catch(Exception e){
            weeklyFileDownload = '';
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

        System.debug('CNS_EBulletin - getRecords - query: ' + query);
        System.debug('CNS_EBulletin - getRecords - ccNamesToRecoverAux: ' + ccNamesToRecoverAux);
        System.debug('CNS_EBulletin - getRecords - countriesFilterAux: ' + countriesFilterAux);
        System.debug('CNS_EBulletin - getRecords - locClsListAux: ' + locClsListAux);

        AMS_EBulletinRecordsBatch batchRecords = new AMS_EBulletinRecordsBatch(header, query, eBulletinProfile, endDate, startDate, ccNamesToRecoverAux, countriesFilterAux, locClsListAux, true);
        isBatchProcessing = true;
        batchRecordsId = Database.executeBatch(batchRecords, 200);
    }

    @TestVisible private static String getQuery(){

        System.debug('Get query...');
        
        return AMS_EBulletinReportHelper.getEBulletinRecordsQuery(filters,objectBaseQuery,eBulletinCSVFormat,true);

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

        System.debug('CNS_EBulletin - checkBatchStatus');

        List<AsyncApexJob> aaj = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE Id = :batchRecordsId];

        System.debug('CNS_EBulletin - checkBatchStatus - aaj: ' + aaj);

        if(!aaj.isEmpty()){

            if(aaj.get(0).Status == 'Completed' && aaj.get(0).ExtendedStatus != null && aaj.get(0).ExtendedStatus.contains('01')){

                jobCompletedWithoutAttachment('01');

                System.debug('CNS_EBulletin - checkBatchStatus - job completed without records');

            } else if(aaj.get(0).Status == 'Completed') {

                String nameAtt = String.valueOf(batchRecordsId) + '%';
                System.debug('CNS_EBulletin - checkBatchStatus - nameAtt: ' + nameAtt);
                List<Attachment> attachment = new List<Attachment>();
                attachment = [SELECT Id, Name FROM Attachment WHERE Name LIKE :nameAtt];

                if(!attachment.isEmpty()) { 

                    isBatchProcessing = false;
                    isGettingReportWeekly = false;
                    isGettingReportDaily = false;   
                    System.debug('CNS_EBulletin - checkBatchStatus - job completed with records');

                    String name = attachment.get(0).Name;
                    attachment.get(0).Name = name.removeStart(batchRecordsId + '_');
                    update attachment;

                    if(name.containsIgnoreCase('weekly')) {

                        AMS_EBulletinReportHelper.updateEbulletinProfile(system.now(), newFormWeekly.Id, new Set<Id>{attachment.get(0).id});
                        weeklyFileDownload = '/servlet/servlet.FileDownload?file=' + attachment.get(0).id;

                    } else {

                        AMS_EBulletinReportHelper.updateEbulletinProfile(system.now(), newFormDaily.Id, new Set<Id>{attachment.get(0).id});
                        dailyFileDownload = '/servlet/servlet.FileDownload?file=' + attachment.get(0).id;
                    }
                } else {

                    isBatchProcessing = true;
                    isGettingReportWeekly = true;
                    isGettingReportDaily = true;
                    System.debug('CNS_EBulletin - checkBatchStatus - job completed waiting for attachment');


                }

            } else if(aaj.get(0).Status == 'Aborted' || aaj.get(0).Status == 'Failed') {

                jobCompletedWithoutAttachment('00');

                System.debug('CNS_EBulletin - checkBatchStatus - job failed or aborted with message : ' + aaj.get(0).ExtendedStatus);

            } else {

                isBatchProcessing = true;
                isGettingReportWeekly = true;
                isGettingReportDaily = true;
                System.debug('CNS_EBulletin - checkBatchStatus - job processing');

            }

        } else {

            jobCompletedWithoutAttachment('00');

            System.debug('CNS_EBulletin - checkBatchStatus - job not found');
        }

        return null;
    }

    private void jobCompletedWithoutAttachment(String error) {

        isBatchProcessing = false;
        isGettingReportWeekly = false;
        isGettingReportDaily = false;

        weeklyFileDownload = '';
        dailyFileDownload = '';

        ApexPages.Message myMsg;

        if(error.equals('01')){
            myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Label.ISSP_AMS_eBulletin_ErrorMsg_01);
        } else {
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_eBulletin_ErrorMsg_00);
        }
        
        ApexPages.addMessage(myMsg);
    }
}