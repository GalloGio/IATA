/**
This Controller is used by VF page to laod IATA Code ranges. it is based on
        
*/
public class AMS_IataCodeRangesLoaderCtrl2{
    
    public Blob csvFileBody{get;set;}
    
    public string csvAsString{get;set;}
    
    public String[] csvFileLines{get;set;}
        
    private final static Integer INDEX_AREA = 0;
    private final static Integer INDEX_COUNTRYCODE = 1;
    private final static Integer INDEX_AREA_CODE = 2;
    private final static Integer INDEX_COUNTRY = 3;
    private static Integer INDEX_START_RANGES = -1;
    private static Integer INDEX_END_RANGES = -1;
    public Map<String, IATA_ISO_Country__c> countryMap = new Map<String, IATA_ISO_Country__c>();  
    public Map<String, IATA_ISO_Country__c> countryMapPerId = new Map<String, IATA_ISO_Country__c>();  
    public Map<String, IATA_ISO_State__c> statesMap = new Map<String, IATA_ISO_State__c>();  
    
    public Map<String, Code_Range__c> newIataCodeRanges {get;set;}
    private Map<String, AMS_Segment__c> programs = new Map<String,AMS_Segment__c>();
    private Id programRT =  RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Segment__c', 'IATA_Code_Programs');
    //List<AMS_Segment__c> newPrograms = null;
    public Map<String,List<Code_Range__c>> newProgramRanges {get;set;}
    public Map<String,AMS_Segment__c> newPrograms {get;set;}
    public Set<String> errorCountries {get;set;}

    public AMS_IataCodeRangesLoaderCtrl2(){
        ApexPages.Message infoMessage= new ApexPages.Message(ApexPages.severity.INFO,'Please load IATA Code CSV file');
        ApexPages.addMessage(infoMessage);
        csvAsString = null;
        
        //set the list of Country
        for(IATA_ISO_Country__c c: IATAIsoCountryDAO.getIsoCountries()){
            countryMap.put(c.Name.toLowerCase().trim() ,c);
            countryMapPerId .put(c.id ,c);
         }
         
        for(IATA_ISO_State__c c : IATAIsoStateDAO.getIsoStates())
            statesMap.put(c.Name.toLowerCase() ,c);

            
        try{
            StaticResource sr = [SELECT Id,NamespacePrefix,SystemModstamp FROM StaticResource WHERE Name = 'Ams_integration' LIMIT 1];
            String prefix = sr.NamespacePrefix;
            if( String.isEmpty(prefix) ) {
                prefix = '';
            } else {
                //If has NamespacePrefix
                prefix += '__';
            }
            //Get the path of MyJsonFile.json file in Zip static resource
            String srPath = '/resource/' + sr.SystemModstamp.getTime() + '/' + prefix + 'Ams_integration/iatacode.csv'; 
            PageReference pg = new PageReference( srPath );
            csvAsString  = pg.getContent().toString();
            parseLines();
        }catch(Exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Systems has failed to load default  ranges');
            ApexPages.addMessage(errorMessage); 
        
        }
    }
  
    public PageReference importCSVFile(){

        if(csvFileBody!=null)
            csvAsString = csvFileBody.toString();
        parseLines();

        errorCountries.clear();
        programs.clear();
        newIataCodeRanges.clear();
        return null;
    }

    private void parseLines(){
        newProgramRanges = new Map<String,List<Code_Range__c>>();
        newPrograms = new Map<String,AMS_Segment__c> ();    
        for(AMS_Segment__c c:[select Name, Label__c from AMS_Segment__c where RecordTypeId = :programRT]){
            newPrograms .put(c.Label__c.toLowerCase() ,c);
            newProgramRanges.put(c.Label__c.toLowerCase(),new List<Code_Range__c>());
        }
        newIataCodeRanges = new Map<String,Code_Range__c>();
        boolean b = false;
        boolean b2 = false;
        boolean b3 = false;
        boolean b4 = false; 
        

        errorCountries  = new Set<String>();
        StringBuilder sb = new StringBuilder();
        try{
           
           csvFileLines = csvAsString.split('\r\n'); 
  
           //define from Header name the coilums where to look after values
           Integer[] colIndex = new Integer[]{0,1,2,3,5,6,7,8,10,11,12,13,14,15,16,17,18,19,20};
           List<List<Integer>> rangesIndex = new List<List<Integer>>{
                                           new Integer[]{0,0},new Integer[]{0,0},new Integer[]{0,0},new Integer[]{0,0},
                                           new Integer[]{0,0},new Integer[]{0,0},new Integer[]{0,0},new Integer[]{0,0},
                                           new Integer[]{0,0},new Integer[]{0,0},new Integer[]{0,0},new Integer[]{0,0},
                                           new Integer[]{0,0},new Integer[]{0,0},new Integer[]{0,0},new Integer[]{0,0},
                                           new Integer[]{0,0},new Integer[]{0,0},new Integer[]{0,0},new Integer[]{0,0}
                                           };
           string[] csvRecordData = csvFileLines[0].split(';');
           system.debug('[IATA CODE GENERATION] parsing line '+csvRecordData);
           for(Integer i=0;i<csvRecordData.size();i++){
               String h = csvRecordData [i];
               if(h.toLowerCase().equals('area'))
                   colIndex [INDEX_AREA] = i;
               else if(h.toLowerCase().equals('area code'))
                   colIndex [INDEX_AREA_CODE ] = i;               
               else if(h.toLowerCase().equals('country code'))
                   colIndex [INDEX_COUNTRYCODE ] = i;
               else if(h.toLowerCase().equals('country'))    
                   colIndex [INDEX_COUNTRY ] = i;
               else if(h.isAlphanumeric()){
                   rangesIndex[i] =  new Integer[]{Integer.valueOf(rangesIndex[i-1][1]), Integer.valueOf(h)};
                   if(INDEX_START_RANGES ==-1)
                       INDEX_START_RANGES = i;
                   INDEX_END_RANGES  =  i;
               }
           }
            system.debug('[IATA CODE GENERATION] parsing header result INDEX_AREA='+colIndex [INDEX_AREA]+' /  INDEX_AREA_CODE='+colIndex [INDEX_AREA_CODE]+' /  INDEX_COUNTRYCODE='+colIndex [INDEX_COUNTRYCODE]+' / INDEX_COUNTRY= '+colIndex [INDEX_COUNTRY]);
         /*for(String s:statesMap.keySet())
          system.debug('[IATA CODE GENERATION] states:  '+s+'=>'+statesMap.get(s).Name);*/
           //build list of Operation from content
           for(Integer i=1;i<csvFileLines.size();i++){
               csvRecordData = csvFileLines[i].split(';');
               system.debug('[IATA CODE GENERATION] parsing line '+csvRecordData);
               try{
                   String countryName =csvRecordData [colIndex [INDEX_COUNTRY]].toLowerCase().trim(); 
                   IATA_ISO_Country__c isoCountry = null;
                   IATA_ISO_State__c isoState=null;
                   if(countryMap.get(countryName )!=null){
                       isoCountry= countryMap.get(countryName ) ;
                   }else if(statesMap.get(countryName)!=null){
                       System.debug('[IATA CODE GENERATION] found State for Range country will be'+statesMap.get(countryName ).IATA_ISO_Country__c);
                       isoState= statesMap.get(countryName ) ;
                       isoCountry = countryMapPerId.get(statesMap.get(countryName ).IATA_ISO_Country__c );
                       //for countries which have a default state with same name than country:
                       if(isoState.Name==isoCountry.Name||isoState.Name ==isoCountry.AIMS_Area_Name__c){
                           isoState=null;
                           isoCountry= countryMap.get(countryName ) ;
                       }
                   }else 
                     System.debug('[IATA CODE GENERATION] Failed to find a country or state for value '+countryName);
                   if(isoCountry !=null){
                       Integer area= Integer.valueOf(csvRecordData [colIndex [INDEX_AREA]]);
                       Integer areaCode= Integer.valueOf(csvRecordData [colIndex [INDEX_AREA_CODE ]]);
                       String countryCode= csvRecordData [colIndex [INDEX_COUNTRYCODE ]];
                       for(Integer j =INDEX_START_RANGES ; j<INDEX_END_RANGES +1;j++  ){
                           Integer minR= rangesIndex[j][0]+1;
                           Integer maxR= rangesIndex[j][1];
                           AMS_Segment__c program = null ;
                          
                           String rName = areaCode+'-'+countryCode+'-'+isoCountry.ISO_Code__c+'-['+minR+'-'+maxR+']';
                           if(isoState!=null)
                               rName = areaCode+'-'+countryCode+'-'+isoCountry.ISO_Code__c+'-'+isoState.ISO_Code__c+'-['+minR+'-'+maxR+']';
                           String  value = csvRecordData [j].toLowerCase().trim();
                           if(programs.get(value)!=null){
                                program=programs.get(value);
                           }
        
                           
                           if(!value.contains('See Area') &&value!='') {
                            //new PROGRAMS
                                

                              program = newPrograms.get(value) ;
                              List<Code_Range__c> l = new List<Code_Range__c>();
                              //create program and assign range to this one.
                              if(program==null){
                                    program = new AMS_Segment__c(Label__c = csvRecordData [j], RecordTypeId=programRT);
                                    newPrograms.put(value,program);
                                    newProgramRanges.put(value,l);
                                    system.debug('[IATA CODE GENERATION] creating new programs '+value);
                                    sb.add('[IATA CODE GENERATION] New program created : '+program.Label__c+' \r\n' );
                              }else {
                                   l =  newProgramRanges.get(value);
                                   system.debug('[IATA CODE GENERATION] program found  '+(program.Id ==null?'TOCREATE':'EXISTING'));
                              }
                              //programs.put(program.Label__c.toLowerCase(),program);
                              Code_Range__c newRange = new Code_Range__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Code_Range__c', 'IATA_Code'),
                                                                          Name =rName,Area__c=area, Area_Code__c=areaCode, 
                                                                          IATA_ISO_Country__c=isoCountry.Id, Country_Code__c= countryCode, 
                                                                          Max_Range__c= maxR, Min_Range__c=minR );
                              if(isoState!=null)
                                   newRange.IATA_ISO_State__c = isoState.Id;
                                   
                              /*if(l==null)
                                  system.debug('[IATA CODE GENERATION]Failed to retrieved list of ranges from new program ');
                              else
                                  system.debug('[IATA CODE GENERATION]Successfully retrieved list of ranges from new program ');*/
                              system.debug('[IATA CODE GENERATION] creating new Range '+newRange );
                              l.add(newRange);
                              newIataCodeRanges.put(rName.trim(),newRange);
                              //b2 = true;
                              
                             
                           }else {
                             system.debug('[IATA CODE GENERATION] On element is not recognized as a valid range attribute '+value +' on line '+i);
                             sb.add('[IATA CODE GENERATION] On element is not recognized as a valid range attribute '+value +' on line '+i+'\r\n' );
                           }
                       }
                   
                   } else {
                       System.debug('[IATA CODE GENERATION] Failed to find ISO Country for Name '+countryName  +' on line '+i);
                       b3 = true;
                       sb.add('[IATA CODE GENERATION] Failed to find ISO Country for Name '+countryName +' on line '+i+'\r\n' );
                       errorCountries.add(csvRecordData [colIndex [INDEX_COUNTRY]]);
                   }
                                  }
                catch (Exception e)
                {
                    System.debug('[IATA CODE GENERATION] IATA CODE RANGE failed to be generated '+e.getStackTraceString());
                    sb.add('[IATA CODE GENERATION] IATA CODE RANGE failed to be generated '+e.getStackTraceString()+' on line '+i+'\r\n' );
                    b4=true;
                }  
           }
        }
        catch (Exception e)
        {
            b2 = true;
            System.debug('[IATA CODE GENERATION] Fatal System error '+e.getStackTraceString());
            sb.add('[IATA CODE GENERATION]Fatal System error '+e.getStackTraceString()+'\r\n' );
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'[IATA CODE GENERATION]  IATA CODE RANGE system error '+e.getStackTraceString());
            ApexPages.addMessage(errorMessage);
        }  
        
        //clean DATA
        List<Code_Range__c> crs = CodeRangeDAO.getAllCodeRanges();
        
        System.debug('[IATA CODE GENERATION] Existing Ranges : '+crs.size());
        for(Code_Range__c c:crs){  
               newIataCodeRanges.remove(c.Name);
               System.debug('[IATA CODE GENERATION] Already existing range : '+c.Name);
               sb.add('[IATA CODE GENERATION]Already existing range : '+c.Name+'\r\n' );
               b= true;
        }
        if(b){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.WARNING,'[IATA CODE GENERATION] Some range were already existing  ');
            ApexPages.addMessage(errorMessage);
            
        }
        if(b2){
            ApexPages.Message infoMessage = new ApexPages.Message(ApexPages.severity.INFO,'[IATA CODE GENERATION] some values were raising exceptions. See logs ');
            ApexPages.addMessage(infoMessage );
        }
        if(b3){
              ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'[IATA CODE GENERATION]Some countries name are not exisiting ISO country name. See logs ');
              ApexPages.addMessage(errorMessage);
        }
        if(b4){
             ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'[IATA CODE GENERATION] IATA CODE RANGE failed to be generated. See logs');
             ApexPages.addMessage(errorMessage);
        }
        if(b||b2||b3||b4){
              List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
              List<String> receivers = new List<String>();
              for(User u:[Select Id,Name,Email from User where Id=:userinfo.getuserId()])
                  receivers.add(u.Email);
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
              mail.setSubject('[IATA CODE GENERATION] Loader Issue cause '+b+' / '+b2+' / '+b3+' / '+b4);
              mail.setToAddresses(receivers) ;           
              mail.setPlainTextBody(sb.getStringValue());
              emails.add( mail);
              if(!Test.isRunningTest()) Messaging.sendEmail(emails);    
        }    
        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO,'Systems has loaded '+newIataCodeRanges.size()+' ranges');
        ApexPages.addMessage(errorMessage); 
        for(String s:newIataCodeRanges.keySet()){
            System.debug('[IATA CODE GENERATION] '+s);
        }
    }
    
        //save the page whatever is the CSV type
    public PageReference saveRecord(){
        List<AMS_Segment__c > p2Add = new List<AMS_Segment__c >();
        for(AMS_Segment__c  r:newPrograms.values()){
           if(p2Add.size()==200){
               insert p2Add  ;
               p2Add.clear();
           }
           p2Add.add(r);
        } 
        //insert p2Add;
        upsert p2Add;
        List<Code_Range__c > toAdd = new List<Code_Range__c >();
        for(Code_Range__c  r:newIataCodeRanges.values()){
           if(toAdd.size()==200){
               insert toAdd  ;
               toAdd.clear();
           }
           toAdd.add(r);
        } 
        insert toAdd  ;
        toAdd.clear();
        for(String  v:newPrograms.keySet()){
            
            for(Code_Range__c  r:newProgramRanges.get(v)){
            
                r.program__c =newPrograms.get(v).Id;
                if(toAdd.size()==200){
                   insert toAdd  ;
                   toAdd.clear();
                }
                toAdd.add(r);
            }
        } 
        insert toAdd  ;
        return null;
    }
}