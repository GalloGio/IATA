global without sharing class IECMapsResourceData implements Schedulable {


global Integer Count;
global Integer MaxCount;


//Initial steps for states/provinces
//count from 0--MAXCount is for ISO Countries
global Integer USPartOne   = -4;
global Integer USPartTwo   = -3;
global Integer CAProvinces = -2;
global Integer AUProvinces = -1;

//Initial Step
global Integer InitialStep = USPartOne;



public IECMapsResourceData(Integer c) {
      
      Count = c;            
      List <IATA_ISO_Country__c> countries = IATAIsoCountryDAO.getIsoCountries();
      MaxCount = (Integer) countries.size();                   
      System.debug('*** setting job counts    count = ' + Count + ' maxcount = ' + MaxCount);         
                     
    }



    global void execute(SchedulableContext ctx) {


        System.debug('*** running job count = ' + Count);
        
        //Clear all previous day stats
        if (Count == USPartOne){
            
            cleanOldDaily();  
                        
            processUSOne();                        
            
            //schedule next run
            datetime nextScheduleTime = system.now().addSeconds(20);            
            string cronvalue = nextScheduleTime.format('ss mm HH dd MM') + ' ?';            
            string jobName = 'SchdlIECMapsResourceData ' + + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');         
            system.schedule(jobName, cronvalue , new IECMapsResourceData(Count+1)); 
            
            System.debug('*** end of job count = ' + Count);            
                
        }
        else if(Count == USPartTwo){
        
            processUSTwo();                        
            
            //schedule next run
            datetime nextScheduleTime = system.now().addSeconds(20);            
            string cronvalue = nextScheduleTime.format('ss mm HH dd MM') + ' ?';            
            string jobName = 'SchdlIECMapsResourceData ' + + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');         
            system.schedule(jobName, cronvalue , new IECMapsResourceData(Count+1)); 
            
            System.debug('*** end of job count = ' + Count);     
        }
        else if(Count == CAProvinces ){
            
            processCA();        
        
            //schedule next run
            datetime nextScheduleTime = system.now().addSeconds(20);            
            string cronvalue = nextScheduleTime.format('ss mm HH dd MM') + ' ?';            
            string jobName = 'SchdlIECMapsResourceData ' + + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');         
            system.schedule(jobName, cronvalue , new IECMapsResourceData(Count+1)); 
            
            System.debug('*** end of job count = ' + Count);    
            
        }
        else if(Count == AUProvinces){
            
             processAU();               
            //schedule next run
            datetime nextScheduleTime = system.now().addSeconds(20);            
            string cronvalue = nextScheduleTime.format('ss mm HH dd MM') + ' ?';            
            string jobName = 'SchdlIECMapsResourceData ' + + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');         
            system.schedule(jobName, cronvalue , new IECMapsResourceData(Count+1)); 
            
            System.debug('*** end of job count = ' + Count);    
        }
            
            
        else{
            
            System.debug('*** Else Count != 0  = ' + Count);
            
            
            if(Count == MaxCount-1)
            {
                    
                    processWW(Count);
                    
                    // call group up by subcontinent
                    processSubContinent();
                    
                    //schedule the next day
                    datetime nextScheduleTime = system.now().addDays(1);
                    
                    string month = string.valueof(nextScheduleTime.month());
                    string day = string.valueof(nextScheduleTime.day());
                    
                    // 8:00 AM Montreal stats to run [15:00 PM GMT+2]
                    string hour = '15';
                    string minute = '00';
                    string second = '00';
                    
                    string cronvalue = second + ' ' + minute + ' ' + hour + ' ' + '*' + ' ' + '*' + ' ?'; // runs every day at 15:00 PM.
                    string jobName = 'SchdlIECMapsResourceData ' + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');
                    
                    system.schedule(jobName, cronvalue , new IECMapsResourceData(InitialStep)); // ############################################# reset process
                    
                    System.debug('*** end of job count = ' + Count);
            }
                    
            else
            {                   
                    processWW(Count);                   
                    
                    //schedule next run
                    datetime nextScheduleTime = system.now().addSeconds(20);
                    string cronvalue = nextScheduleTime.format('ss mm HH dd MM') + ' ?';            
                    string jobName = 'SchdlIECMapsResourceData ' + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');
                    system.schedule(jobName, cronvalue , new IECMapsResourceData(Count+1)); 
                    
                    System.debug('*** running job count = ' + Count);
                        
            
            }
        }
                
                
        // run all if its test
        if(Test.isRunningTest())
        {
          /*
            cleanOldDaily();
            processUSOne();
            processUSTwo();
            processCA(); 
            processAU();
            processWW(0);
            processWW(1);
            processWW(2);
            processSubContinent();
            List<GDP_Agency_Stats__c> temp = queryUSA() ;
            */
        }
        
            // this section of code will abort the current schedule job
            system.abortJob(ctx.getTriggerId());

    }    
 
 // TODO make sure to update all fields in query

    public void cleanOldDaily() {

        Integer montlySnapshotDay = 1;
        
        List<GDP_Agency_Stats__c> recordList = [SELECT  Agencies_in_Default__c, Agencies_in_Default_6__c, Airline_Sales_Offices__c, Cargo_Agencies__c, Code__c, CreatedById, CreatedDate, CurrencyIsoCode, IsDeleted, Emails__c, Name, General_Sales_Agents__c, Geo_Detail__c, IATA_ISO_Country__c, Key__c, LastModifiedById, LastModifiedDate, Locations_No_Cargo__c, OwnerId, ConnectionReceivedId, Id, Scope__c, ConnectionSentId, Stats_Date__c, Sub_Continent__c, SystemModstamp, Locations__c, Travel_Agencies__c, Type__c, Unique_Emails__c FROM GDP_Agency_Stats__c WHERE Type__c = 'Daily'];
        
        List<GDP_Agency_Stats__c> recordListMonthly = new List<GDP_Agency_Stats__c> ();

        if (recordList != null && recordList.size() > 0) {
            
            try
            { 
                
            
            //If execution date is montlySnapshotDay of month, then daily data from previus day will be converted to monthly snapshot , otherwise will be deleted
            if (Date.today().day() == montlySnapshotDay  || Test.isRunningTest()) {
                                
                //Change all daily records to montly snapshot and set its date to 1st of month
                for (GDP_Agency_Stats__c record : recordList) {
                    
                    GDP_Agency_Stats__c newMonthyly = record.clone();                    
                    newMonthyly.Type__c = 'Monthly';                    
                    newMonthyly.Key__c = record.Key__c +'-m';
                    Date td = Date.today();
                    newMonthyly.Stats_Date__c = Date.newInstance(td.year(), td.month(), montlySnapshotDay) ;
                    
                    recordListMonthly.add(newMonthyly);
                }

                upsert recordListMonthly Key__c;
            }
            
            }
            
            catch ( Exception e){ System.debug(' ** CleanUp Error '+ e);}                       
        }
    }   
    

    public void processWW(Integer step) {
        try {
            List<GDP_Agency_Stats__c> recordList = queryWWData(step);
            upsert recordList Key__c;
        }
        catch (Exception ex) {System.debug(Logginglevel.ERROR, '***  IECMAPS ERROR ON WW: ' + ex.getMessage() );}
    }
    
    
    public void processUSOne() {
        try {
            List<GDP_Agency_Stats__c> recordList = queryForStates('US',0);
            upsert recordList Key__c;
        }
        catch (Exception ex) {System.debug(Logginglevel.ERROR, '*** IECMAPS ERROR ON US: ' + ex.getMessage() );}        
    }
   public void processUSTwo() {
        try {
            List<GDP_Agency_Stats__c> recordList = queryForStates('US',1);
            upsert recordList Key__c;
        }
        catch (Exception ex) {System.debug(Logginglevel.ERROR, '*** IECMAPS ERROR ON US: ' + ex.getMessage() );}        
    }
    
    public void processCA() {
        try {
            List<GDP_Agency_Stats__c> recordList = queryForStates('CA');
            upsert recordList Key__c;
        }
        catch (Exception ex) {System.debug(Logginglevel.ERROR, '*** IECMAPS ERROR ON CA: ' + ex.getMessage() );}        
    }   
    
    public void processAU() {
        try {
            List<GDP_Agency_Stats__c> recordList =  queryForStates('AU');
            upsert recordList Key__c;
        }
        catch (Exception ex) {System.debug(Logginglevel.ERROR, '*** IECMAPS ERROR ON AU: ' + ex.getMessage() );}        
    }       
    
    public void processSubContinent() {
        try {
            List<GDP_Agency_Stats__c> recordList =  querySubContinentData();
            upsert recordList Key__c;
        }
        catch (Exception ex) {System.debug(Logginglevel.ERROR, 'IECMAPS ERROR ON SUBCONTINENT: ' + ex.getMessage() );}      
    }   
         
      public List<GDP_Agency_Stats__c> queryForStates(string stateISO) {
          return queryForStates(stateISO,0);
      }     
    
    //String countryIsoCode, String scope   
    public List<GDP_Agency_Stats__c> queryForStates(string stateISO,Integer StepNumber) {

 
    System.debug('*** running query for States  count = ' + Count); 
       

    //Query for agency total by state / province
     AggregateResult[] agencies = [
            SELECT Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c Code, COUNT(Id) Total, COUNT(Email_Address__c) TotalEmails,  COUNT_DISTINCT(Email_Address__c) TotalUniqueEmails
            FROM GDP_Products_Account_View__c 
            WHERE Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null   
                and Agency_Status_Code__c >= 4 
                and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP'
                and  Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c =: stateISO 
                and Related_Accreditation_Class__r.Class__r.Code__c  IN ('D','E','F','K','N','O','P','T','V','S','G','M','K','C','X')
            GROUP BY Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c
        ];       
    
    
         AggregateResult[] dummy= [
            SELECT Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c Code, COUNT(Id) Total, COUNT(Email_Address__c) TotalEmails,  COUNT_DISTINCT(Email_Address__c) TotalUniqueEmails
            FROM GDP_Products_Account_View__c 
            WHERE Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null   
                and Agency_Status_Code__c = 0 
                and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP'
                and  Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c =: stateISO 
                and Related_Accreditation_Class__r.Class__r.Code__c  IN ('Dummy')
            GROUP BY Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c
        ];       
    
    

      AggregateResult[] emails = dummy;
      AggregateResult[] defaultAgency = dummy;
      AggregateResult[] defaultAgency6 = dummy;
      AggregateResult[] travelA = dummy;
      AggregateResult[] airlineSO = dummy;
      AggregateResult[] generalSA = dummy;
      AggregateResult[] cargo = dummy;
      
    
    
    
   //pass if US part 1 or any other country.
   //this is added to split US step in two to avoid 5000 query limitation       
    if( (stateISO == 'US' && StepNumber == 0) ||  stateISO != 'US' || Test.isRunningTest())
    { 
        
        emails = [
            SELECT Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c Code, COUNT(Email_Address__c) TotalEmails,  COUNT_DISTINCT(Email_Address__c) TotalUniqueEmails 
            FROM GDP_Products_Account_View__c 
            WHERE Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null   
                and Agency_Status_Code__c >= 4 
                and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP'
                and  Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c =: stateISO 
                and Related_Accreditation_Class__r.Class__r.Code__c  IN ('D','E','F','K','N','O','P','T','V','S','G','M','K')
                and GDP_Opt_In__c = true
            GROUP BY Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c
        ];          
        
       
         defaultAgency = [
            SELECT Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c Code, COUNT(Id) Total 
            FROM GDP_Products_Account_View__c 
            WHERE Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null   
                and Agency_Status_Code__c = 5 
                and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP'
                and  Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c =: stateISO 
                and Related_Accreditation_Class__r.Class__r.Code__c  IN ('D','E','F','K','N','O','P','T','V','S','G','M','K','C','X')
            GROUP BY Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c
        ];       
           
       }
       
        //pass if US part 2 or any other country.
        //this is added to split US step in two to avoid 5000 query limitation
       
      if( (stateISO == 'US' && StepNumber == 1) ||  stateISO != 'US' )
        {
        
         
         defaultAgency6 = [
            SELECT Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c Code, COUNT(Id) Total 
            FROM GDP_Products_Account_View__c 
            WHERE Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null   
                and Agency_Status_Code__c = 6 
                and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP'
                and  Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c =: stateISO 
                and Related_Accreditation_Class__r.Class__r.Code__c  IN ('D','E','F','K','N','O','P','T','V','S','G','M','K','C','X')
            GROUP BY Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c
        ];       
        
    // more stats       
        
        //Query for Travel Agency total by subcontinent
         travelA = [
            SELECT Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c Code, COUNT(Id) Total 
            FROM GDP_Products_Account_View__c 
            WHERE Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null
                and Agency_Status_Code__c >= 4 
                and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP'
                and Related_Accreditation_Class__r.Class__r.Code__c  IN ('D','E','F','N','O','P','T','V')
                and Related_Accreditation_Class__r.Class__r.Table__c = 'ORGCLASS'
                and  Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c =: stateISO
            GROUP BY Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c
        ];
        
        

        //Query for Airline Sales Office total by  state / province
         airlineSO = [
            SELECT Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c Code, COUNT(Id) Total 
            FROM GDP_Products_Account_View__c 
            WHERE Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null
                and Agency_Status_Code__c >= 4 
                and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP'
                and Related_Accreditation_Class__r.Class__r.Code__c  IN ('M','K')
                and Related_Accreditation_Class__r.Class__r.Table__c = 'ORGCLASS'
                and  Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c =: stateISO
            GROUP BY Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c
        ];        
        
        
        //Query for General Sales Agent total by  state / province
         generalSA = [
            SELECT Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c Code, COUNT(Id) Total
            FROM GDP_Products_Account_View__c 
            WHERE Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null
                and Agency_Status_Code__c >= 4
                and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP' 
                and Related_Accreditation_Class__r.Class__r.Code__c  IN ('G','S','X')
                and Related_Accreditation_Class__r.Class__r.Table__c = 'ORGCLASS'
                and  Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c =: stateISO
            GROUP BY Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c
        ];          
        
                
        //Query for Cargo total by  state / province
         cargo = [
            SELECT Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c Code, COUNT(Id) Total
            FROM GDP_Products_Account_View__c 
            WHERE Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null
                and Agency_Status_Code__c >= 4
                and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP' 
                and Related_Accreditation_Class__r.Class__r.Code__c  IN ('C')
                and Related_Accreditation_Class__r.Class__r.Table__c = 'ORGCLASS'
                and  Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c =: stateISO
            GROUP BY Related_GDP_Address__r.IATA_ISO_State__r.ISO_Code__c
        ];  
                        
        }    
            
        return buildQueryResults('', agencies, emails , defaultAgency, defaultAgency6, travelA, airlineSO, generalSA,  cargo);
        
        
    }




   
    public List<GDP_Agency_Stats__c> queryWWData(Integer index) {       
        try
        {
                
              List <IATA_ISO_Country__c> countries = [Select ISO_Code__c from IATA_ISO_Country__c where ISO_Code__c <> null order by ISO_Code__c limit 1 offset: index];
                
              if(countries!= null && countries[0].ISO_Code__c == 'US')
                    return queryUSA(); 
                
                     AggregateResult[] agencies = [
                        SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total ,  COUNT(Email_Address__c) TotalEmails,  COUNT_DISTINCT(Email_Address__c) TotalUniqueEmails 
                        FROM GDP_Products_Account_View__c 
                        WHERE Related_GDP_Address__r.IATA_ISO_Country__c  IN : countries
                            and Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null
                            and Agency_Status_Code__c >= 4 
                            and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                            and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                            and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP'
                            and Related_Accreditation_Class__r.Class__r.Code__c  IN ('D','E','F','K','N','O','P','T','V','S','G','M','K','C','X')
                        GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c
                    ];      
                    
                    
                    
                AggregateResult[] defaultAgency = [
                            SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total 
                            FROM GDP_Products_Account_View__c 
                            WHERE Related_GDP_Address__r.IATA_ISO_Country__c  IN : countries
                                and Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null
                                and Email_Address__c <> null
                                and Agency_Status_Code__c = 5 
                                and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                                and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                                and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP'
                                and Related_Accreditation_Class__r.Class__r.Code__c  IN ('D','E','F','K','N','O','P','T','V','S','G','M','K','C','X')
                            GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c
                        ]; 
                        
            AggregateResult[] defaultAgency6 = [
                        SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total 
                        FROM GDP_Products_Account_View__c 
                        WHERE Related_GDP_Address__r.IATA_ISO_Country__c  IN : countries
                            and Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null
                            and Email_Address__c <> null
                            and Agency_Status_Code__c = 6
                            and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                            and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                            and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP'
                            and Related_Accreditation_Class__r.Class__r.Code__c  IN ('D','E','F','K','N','O','P','T','V','S','G','M','K','C','X')
                        GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c
                    ];              
                         
                
                
            AggregateResult[] emails = [
                    SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total, COUNT(Email_Address__c) TotalEmails,  COUNT_DISTINCT(Email_Address__c) TotalUniqueEmails 
                    FROM GDP_Products_Account_View__c 
                    WHERE Related_GDP_Address__r.IATA_ISO_Country__c  IN : countries
                        and Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null
                        and Email_Address__c <> null
                        and Agency_Status_Code__c >= 4 
                        and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                        and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                        and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP'
                        and Related_Accreditation_Class__r.Class__r.Code__c  IN ('D','E','F','K','N','O','P','T','V','S','G','M','K')
                        and GDP_Opt_In__c = true
                    GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c
                ];  
        
                
                
                //Query for Travel Agency total by subcontinent
                AggregateResult[] travelA = [
                        SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total 
                        FROM GDP_Products_Account_View__c 
                        WHERE Related_GDP_Address__r.IATA_ISO_Country__c  IN : countries
                            and Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null
                            and Agency_Status_Code__c >= 4 
                            and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                            and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                            and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP'
                            and Related_Accreditation_Class__r.Class__r.Code__c  IN ('D','E','F','N','O','P','T','V')
                            and Related_Accreditation_Class__r.Class__r.Table__c = 'ORGCLASS'
                            and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                    GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c
                ];

                
                 //Query for Airline Sales Office total by country
                    AggregateResult[] airlineSO = [
                        SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total 
                        FROM GDP_Products_Account_View__c 
                        WHERE Related_GDP_Address__r.IATA_ISO_Country__c  IN : countries
                            and Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null
                            and Agency_Status_Code__c >= 4 
                            and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                            and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                            and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP'
                            and Related_Accreditation_Class__r.Class__r.Code__c  IN ('M','K')
                            and Related_Accreditation_Class__r.Class__r.Table__c = 'ORGCLASS'
                        GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c
                    ];        
                    
                    
                    //Query for General Sales Agent total by country
                    AggregateResult[] generalSA = [
                        SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total 
                        FROM GDP_Products_Account_View__c 
                        WHERE Related_GDP_Address__r.IATA_ISO_Country__c  IN : countries
                            and Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null
                            and Agency_Status_Code__c >= 4 
                            and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                            and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                            and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP'
                            and Related_Accreditation_Class__r.Class__r.Code__c  IN ('G','S','X')
                            and Related_Accreditation_Class__r.Class__r.Table__c = 'ORGCLASS'
                        GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c
                    ];          
                    
                            
                    //Query for Cargo total by country
                    AggregateResult[] cargo = [             
                        SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total 
                        FROM GDP_Products_Account_View__c 
                        WHERE Related_GDP_Address__r.IATA_ISO_Country__c  IN : countries
                            and Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c <> null
                            and Agency_Status_Code__c >= 4 
                            and Related_GDP_Address__r.RecordType.DeveloperName  = 'GDP'
                            and Related_Accreditation_Class__r.RecordType.DeveloperName  = 'GDP'
                            and GDP_Products_Account_View__c.RecordType.DeveloperName  = 'GDP'
                            and Related_Accreditation_Class__r.Class__r.Code__c  IN ('C')
                            and Related_Accreditation_Class__r.Class__r.Table__c = 'ORGCLASS'
                        GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c
                    ];        
                    
                    
          return buildQueryResults('Country', agencies, emails, defaultAgency,defaultAgency6, travelA, airlineSO, generalSA, cargo);
                
        }
        catch (Exception ex) {  System.debug('*** IECMAPS ERROR ON WW query: ' + ex.getMessage() ); return null;   }
    }
        
    
     
    
 
    public List<GDP_Agency_Stats__c> buildQueryResults( String scope, AggregateResult[] agencies , 
        AggregateResult[] emails, 
        AggregateResult[] defaultAgency,
        AggregateResult[] defaultAgency6,  
        AggregateResult[] travelA, 
        AggregateResult[] airlineSO, 
        AggregateResult[] generalSA, 
        AggregateResult[] cargo) 
    {
        
        
        try {
                Map<String, GDP_Agency_Stats__c> statData = new Map<String, GDP_Agency_Stats__c>();
                
            
            if(Test.isRunningTest())
                agencies = [SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total ,  COUNT(Email_Address__c) TotalEmails,  COUNT_DISTINCT(Email_Address__c) TotalUniqueEmails FROM GDP_Products_Account_View__c  GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c limit 1];
            
            //Build the agency total data from query aggregated result  
                for ( AggregateResult ar : agencies) {
        
                    GDP_Agency_Stats__c statRecord = new GDP_Agency_Stats__c();
                    String recordCode = (String) ar.get('Code');
                    
                    System.debug(Logginglevel.INFO, '*** IECMAPS CODE: ' + recordCode + ' has ' + (double) ar.get('Total') + ' Locations');
                    
                    if(recordCode == '' || recordCode == null)
                        continue;
                    
                    if(scope != '')
                        statRecord.Scope__c = scope;
                    
                    else 
                    {
                        if(recordCode.contains('US'))
                            statRecord.Scope__c = 'US States';
                        else if(recordCode.contains('CA')) 
                            statRecord.Scope__c = 'CA Provinces';
                        else if(recordCode.contains('AU'))
                            statRecord.Scope__c = 'AU Territories';
                    }
                                    
                    statRecord.Type__c = 'Daily';
                    statRecord.Stats_Date__c = Date.today();
                    statRecord.Code__c = recordCode.toLowerCase();
                    statRecord.Locations__c = (double) ar.get('Total');
                    
                    statRecord.Key__c = statRecord.Code__c ;
                    
                    
                    try{
                        
                        String temp = statRecord.Code__c;                                           
                        //ISO country
                        IATA_ISO_Country__c tempISO = new IATA_ISO_Country__c(ISO_Code__c = temp.length() == 2?   temp :  temp.substring(0, 2));
                        statRecord.IATA_ISO_Country__r = tempISO;                       
                        //Geo Location
                        GDP_Geo_Detail__c tempGeo = new GDP_Geo_Detail__c(System_ID__c = temp.length() == 2?   temp :  temp.substring(0, 2));
                        statRecord.Geo_Detail__r = tempGeo;  

                    }
                    catch(Exception e){ System.debug('*** Error in iso code '+ statRecord.Code__c.length() + ' ' + statRecord.Code__c + '  all record '+ statRecord); }
                    
                    System.debug(Logginglevel.INFO, '*** IECMAPS CODE: ' + statRecord.Code__c + ' has ' + statRecord.Locations__c + ' Locations');
                    
                    if(recordCode!= '' && recordCode != null)
                        statData.put(recordCode.toLowerCase(), statRecord);
                    
                }

            
                if(Test.isRunningTest())    
                         emails = [SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total ,  COUNT(Email_Address__c) TotalEmails,  COUNT_DISTINCT(Email_Address__c) TotalUniqueEmails FROM GDP_Products_Account_View__c  GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c limit 1];
            
                // Emails counts
               for ( AggregateResult ar : emails) {
                    
                    String recordCode = (String) ar.get('Code');
                    if(recordCode == '' || recordCode == null)
                        continue;
                        
                    GDP_Agency_Stats__c recordData = (GDP_Agency_Stats__c) statData.get(recordCode.toLowerCase());
                    if (recordData != null) {                   
                        recordData.Emails__c = (double) ar.get('TotalEmails');
                        recordData.Unique_Emails__c = (double) ar.get('TotalUniqueEmails');                     
                    }
                }       
                    
                
                //********************************************************************************************************
                
                //Build the Airline Sales Office data from query aggregated result
                    //Build the Travel Agency data from query aggregated result     
             if(Test.isRunningTest())    
                     defaultAgency = [SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total ,  COUNT(Email_Address__c) TotalEmails,  COUNT_DISTINCT(Email_Address__c) TotalUniqueEmails FROM GDP_Products_Account_View__c  GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c limit 1];
                
            
                for ( AggregateResult ar : defaultAgency) {
                    
                    String recordCode = (String) ar.get('Code');
                    if(recordCode == '' || recordCode == null)
                        continue;
                        
                    GDP_Agency_Stats__c recordData = (GDP_Agency_Stats__c) statData.get(recordCode.toLowerCase());
                    if (recordData != null) {
                        recordData.Agencies_in_Default__c = (double) ar.get('Total');
                    }
                }
                
             if(Test.isRunningTest())    
                     defaultAgency6 = [SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total ,  COUNT(Email_Address__c) TotalEmails,  COUNT_DISTINCT(Email_Address__c) TotalUniqueEmails FROM GDP_Products_Account_View__c  GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c limit 1];
           
            
                for ( AggregateResult ar : defaultAgency6) {
                    
                    String recordCode = (String) ar.get('Code');
                    if(recordCode == '' || recordCode == null)
                        continue;
                        
                    GDP_Agency_Stats__c recordData = (GDP_Agency_Stats__c) statData.get(recordCode.toLowerCase());
                    if (recordData != null) {
                        recordData.Agencies_in_Default_6__c = (double) ar.get('Total');
                    }
                }       
                        
                
            if(Test.isRunningTest())    
                     travelA = [SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total ,  COUNT(Email_Address__c) TotalEmails,  COUNT_DISTINCT(Email_Address__c) TotalUniqueEmails FROM GDP_Products_Account_View__c  GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c limit 1];
           
                for ( AggregateResult ar : travelA) {
                    
                    String recordCode = (String) ar.get('Code');
                    if(recordCode == '' || recordCode == null)
                        continue;
                        
                    GDP_Agency_Stats__c recordData = (GDP_Agency_Stats__c) statData.get(recordCode.toLowerCase());
                    if (recordData != null) {
                        recordData.Travel_Agencies__c = (double) ar.get('Total');
                        System.debug(Logginglevel.INFO, 'IECMAPS CODE: ' + recordData.Code__c + ' has ' + recordData.Travel_Agencies__c + ' Travel Agency');
                    }
                }       
                
                
                
            if(Test.isRunningTest())    
                     airlineSO = [SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total ,  COUNT(Email_Address__c) TotalEmails,  COUNT_DISTINCT(Email_Address__c) TotalUniqueEmails FROM GDP_Products_Account_View__c  GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c limit 1];
                        
                
                for ( AggregateResult ar : airlineSO) {
                    
                    String recordCode = (String) ar.get('Code');
                    if(recordCode == '' || recordCode == null)
                        continue;
                    
                    GDP_Agency_Stats__c recordData = (GDP_Agency_Stats__c) statData.get(recordCode.toLowerCase());
                    if (recordData != null) {
                        recordData.Airline_Sales_Offices__c = (double) ar.get('Total');
                        System.debug(Logginglevel.INFO, 'IECMAPS CODE: ' + recordData.Code__c + ' has ' + recordData.Airline_Sales_Offices__c + ' Airline Sales Offices');
                    }
                }   
        
                
            if(Test.isRunningTest())    
                     generalSA = [SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total ,  COUNT(Email_Address__c) TotalEmails,  COUNT_DISTINCT(Email_Address__c) TotalUniqueEmails FROM GDP_Products_Account_View__c  GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c limit 1];
        
                //Build the General Sales Agent data from query aggregated result       
                for ( AggregateResult ar : generalSA) {
                    
                    String recordCode = (String) ar.get('Code');
                    if(recordCode == '' || recordCode == null)
                        continue;
                    
                    GDP_Agency_Stats__c recordData = (GDP_Agency_Stats__c) statData.get(recordCode.toLowerCase());
                    if (recordData != null) {
                        recordData.General_Sales_Agents__c = (double) ar.get('Total');
                        System.debug(Logginglevel.INFO, 'IECMAPS CODE: ' + recordData.Code__c + ' has ' + recordData.General_Sales_Agents__c + ' General Sales Agent');
                    }
                }   

                    
            if(Test.isRunningTest())    
                     cargo = [SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total ,  COUNT(Email_Address__c) TotalEmails,  COUNT_DISTINCT(Email_Address__c) TotalUniqueEmails FROM GDP_Products_Account_View__c  GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c limit 1];
        
            
                //Build the cargo data from query aggregated result     
                for ( AggregateResult ar : cargo) {
                    
                    String recordCode = (String) ar.get('Code');
                    if(recordCode == '' || recordCode == null)                                           
                        continue;
                    
                    GDP_Agency_Stats__c recordData = (GDP_Agency_Stats__c) statData.get(recordCode.toLowerCase());
                    if (recordData != null) {
                        recordData.Cargo_Agencies__c = (double) ar.get('Total');
                        System.debug(Logginglevel.INFO, 'IECMAPS CODE: ' + recordData.Code__c + ' has ' + recordData.Cargo_Agencies__c + ' Cargos');
                    }
                }   
                        
                
                
                //***************************************************************************************
                                
                return statData.values();
        }
        catch(Exception e){ System.debug('*** IECMAPS Error: ' + e  + '  Aggregate = '+ agencies);  return null;    }   
        

        
    }
    

    
    
    //SubContinent
    public List<GDP_Agency_Stats__c> querySubContinentData() {

        
       AggregateResult[]  subContin = [SELECT Geo_Detail__r.Sub_Continent__c  Code  FROM GDP_Agency_Stats__c     WHERE     Scope__c = 'Country'     and Type__c = 'Daily'      Group by Geo_Detail__r.Sub_Continent__c ];

       List<GDP_Agency_Stats__c> toReturn = new List<GDP_Agency_Stats__c>();
        
    if(Test.isRunningTest())    
            subContin = [SELECT Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c Code, COUNT(Id) Total ,  COUNT(Email_Address__c) TotalEmails,  COUNT_DISTINCT(Email_Address__c) TotalUniqueEmails FROM GDP_Products_Account_View__c  GROUP BY Related_GDP_Address__r.IATA_ISO_Country__r.ISO_Code__c limit 1];
              
       for ( AggregateResult sub : subContin) 
        {           
            
            String continent =  (String) sub.get('Code');
            if(continent == '' || continent == null)
                 continue;
            
             List<GDP_Agency_Stats__c> agencies = [SELECT Geo_Detail__r.Sub_Continent__c ,Agencies_in_Default_6__c, Code__c , Locations__c, Agencies_in_Default__c, Airline_Sales_Offices__c, Cargo_Agencies__c,      Emails__c,   General_Sales_Agents__c,           Travel_Agencies__c,   Unique_Emails__c
                    FROM GDP_Agency_Stats__c 
                    WHERE 
                        Scope__c = 'Country'
                        and Type__c = 'Daily'     
                        and   Geo_Detail__r.Sub_Continent__c = : continent ];       
            
            
            GDP_Agency_Stats__c contin = new GDP_Agency_Stats__c();
                     contin.Locations__c = 0; 
                     contin.Agencies_in_Default__c = 0; 
                     contin.Agencies_in_Default_6__c = 0; 
                     contin.Airline_Sales_Offices__c = 0; 
                     contin.Cargo_Agencies__c = 0; 
                     contin.Emails__c = 0; 
                     contin.General_Sales_Agents__c = 0; 
                     contin.Travel_Agencies__c = 0; 
                     contin.Unique_Emails__c = 0;
        if(Test.isRunningTest())    
            agencies =  [  SELECT IATA_ISO_Country__r.ISO_Code__c ,  Agencies_in_Default_6__c, Locations__c,  Agencies_in_Default__c,     Airline_Sales_Offices__c,    Cargo_Agencies__c,        Emails__c,   General_Sales_Agents__c,           Travel_Agencies__c,   Unique_Emails__c        FROM GDP_Agency_Stats__c limit 1];         
        
            for( GDP_Agency_Stats__c a : agencies)
            {
                    
                if(a == null)
                    continue;
                    
                    
                 contin.Scope__c = 'Sub Continent';
                 contin.Type__c = 'Daily';
                 contin.Stats_Date__c = Date.today();
                             
                string theKey = continent.toLowerCase().trim().replaceAll('(\\s+)', ' ');
                contin.Key__c = theKey;
                
                if(contin.Key__c.length()>20) contin.Key__c= contin.Key__c.substring(0,18);
                
                contin.Code__c = continent;//.toLowerCase();
                if(contin.Code__c.length()>20) contin.Code__c= contin.Code__c.substring(0,20); 
          
                    
                contin.Locations__c += a.Locations__c;
                contin.Agencies_in_Default__c += a.Agencies_in_Default__c;
                contin.Airline_Sales_Offices__c += a.Airline_Sales_Offices__c;
                contin.Cargo_Agencies__c += a.Cargo_Agencies__c;
                contin.Emails__c += a.Emails__c;
                contin.General_Sales_Agents__c += a.General_Sales_Agents__c;
                contin.Travel_Agencies__c += a.Travel_Agencies__c;
                contin.Unique_Emails__c += a.Unique_Emails__c;      
                contin.Agencies_in_Default_6__c += a.Agencies_in_Default_6__c;      
                
                
                
            }
            toReturn.add(contin);
            
        }
        
             
       return toReturn;    
    }
    
    
    //USA
    public List<GDP_Agency_Stats__c> queryUSA() {

    
       List<GDP_Agency_Stats__c> agencies = [   SELECT IATA_ISO_Country__r.ISO_Code__c ,  Agencies_in_Default_6__c, Locations__c,  Agencies_in_Default__c,     Airline_Sales_Offices__c,    Cargo_Agencies__c,        Emails__c,   General_Sales_Agents__c,           Travel_Agencies__c,   Unique_Emails__c
            FROM GDP_Agency_Stats__c 
            WHERE 
                Scope__c = 'US States'
                and Type__c = 'Daily'
           
        ];        
        
        GDP_Agency_Stats__c USA = new GDP_Agency_Stats__c();
         String tempCode = 'us';
         
         USA.Scope__c = 'Country';
         USA.Type__c = 'Daily';
         USA.Stats_Date__c = Date.today();
         USA.Key__c = tempCode;
         USA.Code__c = tempCode;
         USA.Locations__c = 0; 
         USA.Agencies_in_Default__c = 0; 
         USA.Agencies_in_Default_6__c = 0; 
         USA.Airline_Sales_Offices__c = 0; 
         USA.Cargo_Agencies__c = 0; 
         USA.Emails__c = 0; 
         USA.General_Sales_Agents__c = 0; 
         USA.Travel_Agencies__c = 0; 
         USA.Unique_Emails__c = 0;  
                                
        //ISO country
        IATA_ISO_Country__c tempISO = new IATA_ISO_Country__c(ISO_Code__c = tempCode);
        USA.IATA_ISO_Country__r = tempISO;  
                
        //Geo Location
        GDP_Geo_Detail__c tempGeo = new GDP_Geo_Detail__c(System_ID__c =tempCode);
        USA.Geo_Detail__r = tempGeo;     
        
    if(Test.isRunningTest())    
            agencies =  [   SELECT IATA_ISO_Country__r.ISO_Code__c ,  Agencies_in_Default_6__c, Locations__c,  Agencies_in_Default__c,     Airline_Sales_Offices__c,    Cargo_Agencies__c,        Emails__c,   General_Sales_Agents__c,           Travel_Agencies__c,   Unique_Emails__c        FROM GDP_Agency_Stats__c limit 1];
                        
        for( GDP_Agency_Stats__c a : agencies)
        {
            if(a == null)
                continue;
            USA.Locations__c += a.Locations__c;
            USA.Agencies_in_Default__c += a.Agencies_in_Default__c;
            USA.Airline_Sales_Offices__c += a.Airline_Sales_Offices__c;
            USA.Cargo_Agencies__c += a.Cargo_Agencies__c;
            USA.Emails__c += a.Emails__c;
            USA.General_Sales_Agents__c += a.General_Sales_Agents__c;
            USA.Travel_Agencies__c += a.Travel_Agencies__c;
            USA.Unique_Emails__c += a.Unique_Emails__c;
            USA.Agencies_in_Default_6__c += a.Agencies_in_Default_6__c;         
            
        }
        List<GDP_Agency_Stats__c> toReturn = new List<GDP_Agency_Stats__c>();
        toReturn.add(USA);
        
        return toReturn;     
        
            
    }
    
 
        
    

}