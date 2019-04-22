public class AcctNoDupe {
    
    /* acct fields innvolved:
    Reason_for_creation__c
    ParentID
    Id
    IATA_ISO_Country__c
    Airline_designator__c
    IATACode__c
         */     
    public static map<integer, Account> PerformSearch(map<Integer,Account> TriggerNewMap,  map<Integer, Case> CasePerInt){
             
        final set<string> REASONSFORCREATIONTOEXCLUDE = new set<string>{'Created by customer','Headquarter is missing','Airline Headquarter applying for a code','New for E&F'};
        
        final string IATA_Airline = 'IATA_Airline';
        
        map<Id, list<Integer>> intAccPerIso = new map<Id, list<Integer>>();
        map<string, list<Integer>> intAccPerSite= new map<string, list<Integer>>();
        
        map<Id,list<integer>> acctIdPerParentAccts = new map<Id,list<integer>>();
        /* we need to retrieve the recordType of the Parent accts */
        for(Integer i: TriggerNewMap.Keyset()){
            if(!REASONSFORCREATIONTOEXCLUDE.contains(TriggerNewMap.get(i).Reason_for_creation__c) ){
                
                if(TriggerNewMap.get(i).parentID == null){      
                    if(CasePerInt <> null && CasePerInt.get(i) <> null)
                        CasePerInt.get(i).addError('No parent Account found on the Airline: please link the Airline to an Headquarter' );
                    else
                        TriggerNewMap.get(i).addError('No parent Account found on the Airline: please link the Airline to an Headquarter' );
                    TriggerNewMap.remove(i);
                }
                
                if(TriggerNewMap.get(i) <> null && acctIdPerParentAccts.get(TriggerNewMap.get(i).ParentID) == null)
                    acctIdPerParentAccts.put(TriggerNewMap.get(i).ParentID,new list<Integer>()); 
                if(TriggerNewMap.get(i) <> null )
                    acctIdPerParentAccts.get(TriggerNewMap.get(i).ParentID).add(i);
            }               
                
        }
        /* we need to retrieve the recordType of the Parent accts actual validation of the previuos step */
        set<Id> ParentAccIDs = acctIdPerParentAccts.keySet();

        for(Account a:[SELECT Id,RecordType.DeveloperName FROM Account where id IN: ParentAccIDs])
            for(integer i: acctIdPerParentAccts.get(a.Id)){
                if(a.RecordType.DeveloperName <> IATA_Airline){
                    if(CasePerInt <> null && CasePerInt.get(i) <> null)
                        CasePerInt.get(i).addError('The parent Account must be an Airline Headquarter when the industry is Airline ' );
                    else
                        TriggerNewMap.get(i).addError('The parent Account must be an Airline Headquarter when the industry is Airline ' );
                    TriggerNewMap.remove(i);
                }
            }
        
        /* we need to check if that the parentID <> null && parent reocrd type = Headquarter */
        /* we cache the Iso countries IDs cause we neeed to search for the iso COde */
        for(Integer i: TriggerNewMap.Keyset()){

              if(intAccPerIso.get(TriggerNewMap.get(i).IATA_ISO_Country__c) == null)
                    intAccPerIso.put(TriggerNewMap.get(i).IATA_ISO_Country__c,new list<Integer>()); 
                intAccPerIso.get(TriggerNewMap.get(i).IATA_ISO_Country__c).add(i);
        
        }
        map<Integer,String> IsoCodePerACcID = new map<Integer,String>();
        
        /* we search for the ISO code cause we need it to search for the Site*/
        set<Id> iataIsoIDs = intAccPerIso.keySet(); 

        for(IATA_ISO_Country__c ISO: IATAIsoCountryDAO.getIsoCountriesByIds(iataIsoIDs)){
            for(integer i: intAccPerIso.get(ISO.ID))    
                IsoCodePerACcID.put(i,ISO.ISO_Code__c);                                                        
        }
                                                   
        string site;
        string designator;
        string IataCode;
        string IsoCode;
        set<Id> IdsOfTheAccountsThemSelves = new set<Id>();
        /* We build the map to track the acctsite per list of possible accts ( nb everything to uppercase cause of the key of the maps are Case Sensitive) */
        for(Integer i: TriggerNewMap.Keyset()){
        
            if(REASONSFORCREATIONTOEXCLUDE.contains(TriggerNewMap.get(i).Reason_for_creation__c) )
                continue;
          
            designator =  TriggerNewMap.get(i).Airline_designator__c <> null ?  TriggerNewMap.get(i).Airline_designator__c.toUpperCase() : '';
            IataCode   =  TriggerNewMap.get(i).IATACode__c  <> null ? TriggerNewMap.get(i).IATACode__c.toUpperCase() : '';
            IsoCode    =  IsoCodePerACcID.get(i) <> null ? IsoCodePerACcID.get(i).toUpperCase() : '';
            
            site = TransformationHelper.buildSiteForAcli( IataCode, designator, IsoCode, null);
            
            if(TriggerNewMap.get(i).id <> null)
                IdsOfTheAccountsThemSelves.add(TriggerNewMap.get(i).id);
            site = site.toUpperCase(); 

            if(intAccPerSite.get(site) == null)
                intAccPerSite.put(site,new list<Integer>()); 
            intAccPerSite.get(site).add(i); 
        }
        
       /* we perform the search on SFDC in Between the HQs and the BRanches only*/
       
           set<string> sites = intAccPerSite.KeySet();
           for(Account a: [SELECT id,IATACode__c,Airline_designator__c, IATA_ISO_Country__r.ISO_Code__c
                        FROM Account
                        WHERE Site_index__c IN: sites
                        AND recordtype.developername IN('IATA_Airline','IATA_Airline_br','Standard_Account') 
                        AND ID NOT IN: IdsOfTheAccountsThemSelves ]){
                
                if( a.Airline_designator__c == null && a.IATACode__c == null)    
                    continue;
                    
                designator =  a.Airline_designator__c <> null ?  a.Airline_designator__c.toUpperCase() : '';
                IataCode   =  a.IATACode__c  <> null ? a.IATACode__c.toUpperCase() : '';
                IsoCode    =   a.IATA_ISO_Country__r.Iso_Code__c <> null ?  a.IATA_ISO_Country__r.Iso_Code__c.toUpperCase() : '';
                
                site =TransformationHelper.buildSiteForAcli(IataCode ,designator, IsoCOde,null);           
                
                site = site <> null ? site.toUpperCase() : '';  
                String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';   
                 
                for(integer I:intAccPerSite.get(site)){
                    if(CasePerInt <> null && CasePerInt.get(i) <> null)
                        CasePerInt.get(i).addError('The Airline already exists! (  '+ fullFileURL +a.Id+ ' )  Site : ' + site);
                    else if(TriggerNewMap.get(i) <> null &&  !REASONSFORCREATIONTOEXCLUDE.contains(TriggerNewMap.get(i).Reason_for_creation__c)) {   
                        TriggerNewMap.get(i).addError('The Airline already exists! (  '+ fullFileURL +a.Id+ ' )  Site : ' + site);
                    TriggerNewMap.remove(i);}
                }
            } 
        return TriggerNewMap;
        
    }
}