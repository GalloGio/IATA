/**

    This controller is used per VF page to insert from CSV new settlements and Operation

        
                ===================        TO DO  =============
                System is NOT setting CASS settlement has it should.      
                For the moment we will create settlement with operation for Cass  
        
*/
public class AMS_SettlementsAndOperationLoaderCtrl{
    
    public Blob csvFileBody{get;set;}
    
    public string csvAsString{get;set;}
    
    public String[] csvFileLines{get;set;}
    
    public String fileLoaderType {get;set;}
    
    public Boolean selected {get; set;}
    
    private final static Integer INDEX_BSP = 0;
    
    private final static Integer INDEX_DPC_SYSTEM  = 1;
    
    private final static Integer INDEX_DPC_PROVIDER = 2;
       
    private final static Integer INDEX_OPERATION = 3;
    
    private final static Integer INDEX_ISO_COUNTRY_CODE =4;
    
    private final static Integer COUNTRY_NAME =5;
    
    //public  Map<String,String> dpcPerBSP {get;set;}
    
    
    //NOTE: here one Map should be enought for both bsp and cass... lazy man to rewrite
    //used to save ISS BSP related to a specific country
    public  Map<String,AMS_Settlement_System__c >bspsPerName {get;set;}
    //used to store ISS CASS relat
    public  Map<String,AMS_Settlement_System__c >cassPerName{get;set;}
    //use for ISS which won t be related to a country
    public  Map<String,AMS_Settlement_System__c > unassignedISS{get;set;}
    
    
    //used to save ISS BSP related to a specific country
    public  Map<String,IATA_ISO_Country__c >countriesPerBSPName {get;set;}
    //used to store ISS CASS relat
    public  Map<String,IATA_ISO_Country__c >countriesPerCassName {get;set;}
    
    
    
    public  Map<String,AMS_Operation__c> operations {get;set;}

    public Map<String, IATA_ISO_Country__c> countryMap = new Map<String, IATA_ISO_Country__c>();
    
    private AMS_Settlement_System__c cassSettlement = null;

    public AMS_SettlementsAndOperationLoaderCtrl(){
        selected = false;
        ApexPages.Message infoMessage= new ApexPages.Message(ApexPages.severity.INFO,'Please load Settlement CSV file with columns headers: Region / BSP Countrie(s)/Country ISO / DPC / BSPlink / DPC Provider');
        ApexPages.addMessage(infoMessage);
        infoMessage= new ApexPages.Message(ApexPages.severity.INFO,'Please load Operations CSV file with at least one column called \'Operation Name\'');
        ApexPages.addMessage(infoMessage);
        csvAsString = null;
        
        //set the list of Country
        for(IATA_ISO_Country__c c: IATAIsoCountryDAO.getIsoCountries())
            countryMap.put(c.ISO_Code__c.trim() ,c);
        //load record types for Settlements
        
        bspsPerName= new Map<String,AMS_Settlement_System__c>();
        cassPerName= new Map<String,AMS_Settlement_System__c >();
        countriesPerBSPName= new Map<String,IATA_ISO_Country__c>();
        countriesPerCassName= new Map<String,IATA_ISO_Country__c>();
        unassignedISS = new Map<String,AMS_Settlement_System__c >();
           
    }
  
    public PageReference importCSVFile(){
       if(fileLoaderType =='ISS')
       return importISSCSV();
       return importOperationsCSV();
      
    }
    
        //save the page whatever is the CSV type
    public PageReference saveRecord(){
       if(fileLoaderType =='ISS')
           return saveISSRecord();
       return saveOperationsRecord();
    }
    
    
   
     
     
     // load settlement from CSV
     private PageReference importISSCSV(){   
         try{

            
            //set the list of Country
            countryMap.clear();
            for(IATA_ISO_Country__c c: IATAIsoCountryDAO.getIsoCountries())
                countryMap.put(c.ISO_Code__c.trim() ,c);
           
           if(!selected){
               system.debug('[ISS LOADING]  Loading from Uploadd file within country liist =  '+countryMap.size());
           
               csvAsString = csvFileBody.toString();
           }else {
               try{
                    StaticResource sr = [SELECT Id,NamespacePrefix,SystemModstamp FROM StaticResource WHERE Name = 'Ams_integration' LIMIT 1];
                    String prefix = sr.NamespacePrefix;
                    if( String.isNotEmpty(prefix) ) prefix += '__';
                    else prefix = '';
                    //Get the path of MyJsonFile.json file in Zip static resource
                    String srPath = '/resource/' + sr.SystemModstamp.getTime() + '/' + prefix + 'Ams_integration/bsp3.csv'; 
                    PageReference pg = new PageReference( srPath );
                    csvAsString  = pg.getContent().toString();
                }catch(Exception e){
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Systems has failed to load default  operations');
                    ApexPages.addMessage(errorMessage); 
                
                }
           }
           csvFileLines = csvAsString.split('\r\n'); 
            

           //define columns  order from header
           Integer[] colIndex = new Integer[]{-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1};
           string[] csvRecordData = csvFileLines[0].split(',');
           for(Integer i=0;i<csvRecordData.size();i++){
               String h = csvRecordData [i];
               if(h.toLowerCase().equals('bsp'))
                   colIndex [INDEX_BSP ] = i;
               if(h.toLowerCase().contains('dpc provider'))
                   colIndex [INDEX_DPC_PROVIDER ] = i;
               if(h.toLowerCase().contains('dpc system'))
                   colIndex [INDEX_DPC_SYSTEM ] = i;   
               if(h.toLowerCase().contains('iso'))
                   colIndex [INDEX_ISO_COUNTRY_CODE ] = i;
               if(h.toLowerCase().contains('countrie'))
                   colIndex [COUNTRY_NAME ] = i;
           }
           if(colIndex[INDEX_BSP ]==-1 ||colIndex[INDEX_DPC_PROVIDER ]==-1||colIndex[INDEX_ISO_COUNTRY_CODE ]==-1){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'System failed to retreive columns'));
               return null;
           }
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'System successfully loaded columns'));
           
           //load content
           for(Integer i=1;i<csvFileLines.size();i++){
               csvRecordData = csvFileLines[i].split(',');
               system.debug('[ISS LOADING]processing line '+csvFileLines[i]);
               AMS_Settlement_System__c aISS = new AMS_Settlement_System__c();
               //fill data according to the type
               if(csvRecordData[colIndex [INDEX_DPC_PROVIDER]]!=null && csvRecordData[colIndex [INDEX_DPC_PROVIDER]].equals('HP')){
                   system.debug('[ISS LOADING] Process as a CASS ');
                   aISS.Name='CASS-'+csvRecordData[colIndex[INDEX_ISO_COUNTRY_CODE ]];
                   aISS.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c', 'CASS');
               }else {
                   
                   aISS.Name ='BSP-'+csvRecordData[colIndex [INDEX_ISO_COUNTRY_CODE ]];
                   aISS.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c', 'BSP');
                   aISS.BSP_Billing__c =csvRecordData[colIndex [INDEX_ISO_COUNTRY_CODE ]];
               }
               //set the DPC
               aISS.DPC__c = csvRecordData[colIndex [INDEX_DPC_PROVIDER]];
               aISS.DPC_System__c= csvRecordData[colIndex [INDEX_DPC_SYSTEM]];
               //assign Record to countries
               IATA_ISO_Country__c  c = countryMap.get(csvRecordData[colIndex[INDEX_ISO_COUNTRY_CODE]].trim().toUpperCase());
               if(c!=null){
                   system.debug('[ISS LOADING] FIND a matching country '+csvRecordData[colIndex [INDEX_ISO_COUNTRY_CODE]]);
                   if(csvRecordData[colIndex [INDEX_DPC_PROVIDER]]!=null && csvRecordData[colIndex [INDEX_DPC_PROVIDER]].equals('HP')){
                       countriesPerCassName.put(aISS.Name,c);
                       cassPerName.put(aISS.Name,aISS);
                   }
                   else{
                       countriesPerBSPName.put(aISS.Name,c);
                       bspsPerName.put(aISS.Name,aISS);
                   }
               }else{
                   unassignedISS .put(aISS.Name, aISS);
                   system.debug('[ISS LOADING] FAILED to find a matching country -'+csvRecordData[colIndex [INDEX_ISO_COUNTRY_CODE]]+'-');
               }
               
              
           }
            //clean up to check we are not creating duplicate
           for(AMS_Settlement_System__c  anEnv:[select Id, Name from AMS_Settlement_System__c  where Name in :countriesPerCassName.keySet() or Name in :countriesPerBSPName.keySet() or Name in :unassignedISS .keySet()]){
               ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Already existing Billing Environment '+anEnv.Name);
               ApexPages.addMessage(errorMessage);+
               countriesPerBSPName.remove(anEnv.Name);
               unassignedISS .remove(anEnv.Name);
               countriesPerCassName.remove(anEnv.Name);
           }
           
           ApexPages.Message infoMessage = new ApexPages.Message(ApexPages.severity.INFO,'Load '+countriesPerBSPName.size()+' BSP  / '+countriesPerCassName.size()+' CASS / '+unassignedISS .size()+' unassigned \n');
           ApexPages.addMessage(infoMessage );
        }
        catch (Exception e)
        {
            System.debug('An error has occured while importing data  \n'+e.getMessage());
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importin data Please make sure input csv file is correct \n'+e.getMessage()+'\n'+e.getStackTraceString());
            ApexPages.addMessage(errorMessage);
        }  
        
        
         system.debug('[ISS LOADING]  Loading from Uploadd file within country list =  '+countryMap.size());
         return null;
     }
    

    //save the list of settlement [preiviously built
    private PageReference saveISSRecord(){
        ApexPages.getMessages().clear();
        //update countries is needed using new Billing Env.
        Map<String, IATA_ISO_Country__c > countries2Update= new Map<String, IATA_ISO_Country__c >();
        
        //insert BSP
        insert bspsPerName.values();       
        //update countries withing these lookup
        for(AMS_Settlement_System__c s:[select Id, NAme from AMS_Settlement_System__c  where Name in :countriesPerBSPName.keySet() ]){
          IATA_ISO_Country__c c = countriesPerBSPName.get(s.Name);
          if(countries2Update.get(c.Id)!=null) c = countries2Update.get(c.Id);
          c.AMS_Settlement_System__c  = s.Id;
          countries2Update.put(c.Id, c);
        }
        //insert CASS
        insert cassPerName.values();   
        //updae countries withing these lookup
        for(AMS_Settlement_System__c s:[select Id, NAme from AMS_Settlement_System__c  where Name in :countriesPerCassName.keySet() ]){
           IATA_ISO_Country__c c = countriesPerCassName.get(s.Name);
           if(countries2Update.get(c.Id)!=null)
               c = countries2Update.get(c.Id);
           c.AMS_Settlement_System_CASS__c  = s.Id;
           countries2Update.put(c.Id, c);
        }
        //insert unassigned Billing Env.
        insert   unassignedISS.values()  ;
        update countries2Update.values() ;

        return null;
    }
    
    
    
     //load a csv and get list of Operations wichi would be built later 
    private PageReference  importOperationsCSV(){
        //set the list of Country
        countryMap.clear();
        for(IATA_ISO_Country__c c: IATAIsoCountryDAO.getIsoCountries())
            countryMap.put(c.ISO_Code__c.trim() ,c);
         operations = new Map<String,AMS_Operation__c> ();
         try{
         
           if(!selected){
              ApexPages.Message selMessage= new ApexPages.Message(ApexPages.severity.INFO,'selected '+selected);
              ApexPages.addMessage(selMessage); 
              csvAsString = csvFileBody.toString();
           }else {
               try{
                    StaticResource sr = [SELECT Id,NamespacePrefix,SystemModstamp FROM StaticResource WHERE Name = 'Ams_integration' LIMIT 1];
                    String prefix = sr.NamespacePrefix;
                    if( String.isNotEmpty(prefix) ) prefix += '__';
                    else prefix = '';

                    //Get the path of MyJsonFile.json file in Zip static resource
                    String srPath = '/resource/' + sr.SystemModstamp.getTime() + '/' + prefix + 'Ams_integration/operations.csv'; 
                    PageReference pg = new PageReference( srPath );
                    csvAsString  = pg.getContent().toString();
                }catch(Exception e){
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Systems has failed to load default  operations');
                    ApexPages.addMessage(errorMessage); 
                
                }
           }
           csvFileLines = csvAsString.split('\r\n'); 
            
           
               
           //define from Header name the coilums where to look after values
           Integer[] colIndex = new Integer[]{-1,-1,-1,-1,-1,-1,-1,-1,-1};
           string[] csvRecordData = csvFileLines[0].split(',');
           for(Integer i=0;i<csvRecordData.size();i++){
               String h = csvRecordData [i];
               if(h.toLowerCase().equals('operation name'))
                   colIndex [INDEX_OPERATION ] = i;
           }
           if(colIndex[INDEX_OPERATION ]==-1){
               System.debug('[ISS&Operation] System failed to retreive columns');
               ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'System failed to retreive columns'));
               return null;
           }
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'System successfully loaded columns [Index:'+colIndex[INDEX_OPERATION ]+']'));
           System.debug('[ISS&Operation]System successfully loaded columns [Index:'+colIndex[INDEX_OPERATION ]+']');
          
           //build list of Operation from content
           for(Integer i=1;i<csvFileLines.size();i++){
               csvRecordData = csvFileLines[i].split(',');
               String opName = csvRecordData[ colIndex[INDEX_OPERATION ]] ;       
               String[] operationDetails= opName.split('_');
               String curr = operationDetails[3];
               String iso= operationDetails[0];
               String type= operationDetails[1];
               String initLetter= operationDetails[2];
               String lastLetter= operationDetails[4];
               try{
                   
                   
                   AMS_Operation__c operation = new AMS_Operation__c(Name=opName );
                   operation.Country__c = countryMap.get(iso).Id;
                   
                   operation.currencyIsoCode = curr;
                   if(lastLetter=='D') operation.Market__c ='Domestic';
                   else operation.Market__c ='International';

                   if(type=='BSP') operation.Settlement__c= countryMap.get(iso).AMS_Settlement_System__c;
                   else{
                       operation.Settlement__c= countryMap.get(iso).AMS_Settlement_System_CASS__c;
                       //: EXP (E) , IMP (I) , Courier (C) , Local (L)
                       if(initLetter=='E') operation.CASS_Operations__c = 'EXP';
                       if(initLetter=='I') operation.CASS_Operations__c = 'IMP' ;
                       if(initLetter=='C') operation.CASS_Operations__c = 'Courier';
                       if(initLetter=='L') operation.CASS_Operations__c = 'Local';
                   }
                   operations.put(opName ,operation);
                }
                catch (Exception e)
                {
                    System.debug('[Settlement&Operation] operation failed to be created '+e.getStackTraceString());
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Failed to parse  \n'+opName +'. Please check that the Country is existing. data will be ignore.'+iso);
                    ApexPages.addMessage(errorMessage);
                }  
           }
        }
        catch (Exception e)
        {
              System.debug('[Settlement&Operation]An error has occured while importing data Please make sure input csv file is correct \n'+e.getMessage());
              ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importign data Please make sure input csv file is correct \n'+e.getMessage()+'\n'+e.getStackTraceString());
              ApexPages.addMessage(errorMessage);
        }  
        return null;
     }
    
    //save all operation previously built
    private PageReference saveOperationsRecord(){
    
       List<AMS_Operation__c> records = new List<AMS_Operation__c>();
       for(AMS_Operation__c op:operations.values())
       if(op.Settlement__c!=null)
           records.add(op);
       try{
           insert records;
           ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO,'System has created '+records.size()+' Operations in system');
           ApexPages.addMessage(errorMessage);
       }
       catch (Exception e)
       {
           System.debug('[Settlement&Operation] operation failed to be Saved  '+e.getMessage());
           ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while insering data t \n'+e.getMessage());
           ApexPages.addMessage(errorMessage);
       }  
       
       return null;
    }
    
    //return radio options
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('ISS','ISS'));
        options.add(new SelectOption('OPERATIONS','OPERATIONS'));
        return options;
    }

}