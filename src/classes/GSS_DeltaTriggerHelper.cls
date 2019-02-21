/*
* This class is a trigger helper that will be called by all objects and child objects associated
* to reference GDP File description
* Original writer: Alexandre Jaimes 
*
* Change log:
*  - 20160509-sl: check Related_GDP_Products_Account_View Status prior adding new Delta record
*  - 20171023-ab: the Logic to get unique list of delta has been changed to go by GDP Product Account View Id
*  - 20171023-ab: plus Delta type plus Specification Id
*/

//Class to load the fields and object name to use in the comparasion
//ObjectName + FieldName must be unique use map
public class GSS_DeltaTriggerHelper { 
    public class FieldStructureCls {
        public string ObjectName {get;set;}
        public string Fieldname  {get;set;}
        //Includes all FileSpecifications that includes this Object-Field
        public Set<string> SpecficationFile {get;set;}
        //Constructor
        public FieldStructureCls()
        {
            this.ObjectName = '';
            this.Fieldname = '';
            this.SpecficationFile = new set<string>();
        }
    }
    
    
    //UpdateInsertDelete = U/I/D
    public static void calculateDeltas(String UpdateInsertDelete, List<sObject> oldRecords, List<sObject> newRecords){
        //Get the source object name dynamically
        String SourceObjectName = newRecords[0].Id.getSObjectType().GetDescribe().getName();
        
        Boolean OBJECT_ACCREDITATION = 'Accreditation__c' == SourceObjectName ;
        Boolean OBJECT_ACCOUNTVIEW = 'GDP_Products_Account_View__c' == SourceObjectName ;
        Boolean ISINSERT = UpdateInsertDelete == 'I';
        Boolean ISUPDATE = UpdateInsertDelete == 'U';
        Boolean ISDELETE = UpdateInsertDelete == 'D';
        
        
        
        //Question this method will answer : Is there an update to a field that is contained in a 
        //file desctiption?  If yes add a record to the delta junction table, with lastmodified date 
        //and change code (A, B, C, D)
        //A: Add
        //B: Reinstate (Agency Status Code changed from 0 to > 3)
        //C: Change
        //D: Agency Terminated
        
        //Get the list of all reference file specification        
        List<GDP_File_Description__c> filespecicifactionlist = [SELECT Id
                                                                ,Field_API__c
                                                                ,Field_Object_Name__c                                          
                                                                FROM GDP_File_Description__c
                                                                WHERE Is_Reference__c = true
                                                                and Product_type__c in ('GSS','MDP')
                                                                and Id in (Select GDP_File_Description__c From GDP_File_Fields_Description__c Where Do_not_Track__c=false)
                                                               ];
        
        //Nothing to do if there is no Reference file specifications
        if (filespecicifactionlist.size()==0) return;
        
        
        //Build a map of FieldStructureCls to see all the fields that needs to be tracked
        Map<String, FieldStructureCls> fieldstructure = new Map<String,FieldStructureCls>();      
        for(GDP_File_Description__c mySpecificationRecord : filespecicifactionlist)
        {
            //This is always a reference FileSpecification because of where clause above
            String[] FieldsNameList = mySpecificationRecord.Field_API__c.split('\\|');
            String[] ObjectNameList = mySpecificationRecord.Field_Object_Name__c.split('\\|');
            Integer i=-1;
            for(String oName : ObjectNameList)
            {
                i++;
                if (SourceObjectName!=oName) continue;
                //detect here if the field has __r                
                //The logical key to this map is objectname + field name
                //As the trigger helper is called in the context of a single object at the time
                //we keep only the FieldName as key to the map.
                String key = FieldsNameList[i];
                if (key.Contains('__r.')) {
                    String[] vfieldname= key.Split('\\.');
                    key = vfieldname[0].Replace('__r','__c');
                }
                
                FieldStructureCls ds;
                if (!fieldstructure.ContainsKey(key)) ds = new FieldStructureCls();
                else ds = (FieldStructureCls) fieldstructure.get(key);
                ds.ObjectName = oName;
                ds.FieldName = FieldsNameList[i];
                ds.SpecficationFile.add(mySpecificationRecord.Id);
                fieldstructure.put(key,ds);             
            } 
        }
        
        //Add delta records to track the change of code for all related FileSpecification
        Set<String> FirstSpecficationFiles;
        for (string skey : fieldstructure.keySet()) {
            //Get the first set elements to have a set of file specification
            FirstSpecficationFiles = new Set<String>(fieldstructure.get(skey).SpecficationFile);
            break;
        }
        
        
        
        //Create a list of delta that will be inserted
        list<GDP_Delta__c> DeltaList = new list<GDP_Delta__c>();
        //GDP_Delta__c Delta = null;
        
        //Create a map of  RecId-FileSpecId : Delta to check as we go if there is already a code to exit
        //Key of the following map is RecId-FileSpecId
        Map<string,GDP_Delta__c> DeltaMap = New Map<string,GDP_Delta__c> ();
        Set<String> DeltaSet = new Set<String>();
        Set<id> ProcessedRecordSet = new set<id>();
        String key ='';
        Integer position=0; 
        boolean LogDelta=false;
        
        
        
        //Specific treatment of Accreditation__c Status code change
        //Manage Agency Status code change on Accreditation object
        //TODO: verify if the accreditation change is the 'Main' accreditation refered from the Parent object
        //
        if(OBJECT_ACCREDITATION || OBJECT_ACCOUNTVIEW)
        {
            //For the case where there is a change on the Accreditation Status
            //Build a map of Status code referenced by the accreditation status
            Map<Id, GDP_Reference_Table__c> RTid_StatusCodeMap 
                = new Map<Id, GDP_Reference_Table__c>([SELECT Id, Code__c 
                                                       FROM GDP_Reference_Table__c 
                                                       WHERE Table__c = 'STATUS']);
            Set<Id> AccountViewSet = new Set<Id>();
            Set<id> newRecordsIdSet = new Set<Id>();
            Set<id> AccreditationSet = new Set<Id>();           
            for(SObject newrecord : newRecords) 
            {
                if (OBJECT_ACCREDITATION) AccountViewSet.Add((id)newRecord.get('Related_GDP_Products_Account_View__c'));
                if (OBJECT_ACCREDITATION) AccreditationSet.Add((id)newRecord.Id);
                if (OBJECT_ACCOUNTVIEW) newRecordsIdSet.Add((id)newRecord.Id); 
            }
            
            //Map used for the case of an update of accreditation
            //Related_Accreditation_Class__c to Accreditation__r.Status__r.Code__c
            map<id, String> AccreditationStatusMap= new map<id, String>();
            for(Accreditation__c a : [SELECT Id, Status__r.Code__c 
                                      FROM Accreditation__c 
                                      WHERE Related_GDP_Products_Account_View__c IN : newRecordsIdSet]) 
                AccreditationStatusMap.put(a.Id, a.Status__r.Code__c);          
            
            
            Map<Id, GDP_Products_Account_View__c> PAVid_StatusCodeMap = new Map<Id, GDP_Products_Account_View__c>();
            //Find out if there is any accrediation used as lookup from the account view 
            //in the list of accrediation sent in the newRecords list           
            if (OBJECT_ACCREDITATION)   
            {               
                PAVid_StatusCodeMap  
                    = new Map<Id, GDP_Products_Account_View__c>(
                        [SELECT Id
                         , Related_Accreditation_Class__c
                         , Related_Accreditation_Class__r.Status__r.Code__c
                         FROM GDP_Products_Account_View__c 
                         WHERE Id IN : AccountViewSet
                         AND Related_Accreditation_Class__c in :AccreditationSet]); 
                AccreditationSet.Clear();
                for(GDP_Products_Account_View__c newrecord : PAVid_StatusCodeMap.Values()) 
                {
                    AccreditationSet.Add(newrecord.Related_Accreditation_Class__c);
                }
            }                                           
            
            //For the case where there is a change of the Related_Accreditation_Class__c lookup on the GDP_Products_Account_View__c
            //Build a map of Status code referenced by the GDP_Products_Account_View__c
            if (OBJECT_ACCOUNTVIEW)  
                PAVid_StatusCodeMap 
                = new Map<Id, GDP_Products_Account_View__c>(
                    [SELECT Id
                     , Related_Accreditation_Class__c
                     , Related_Accreditation_Class__r.Status__r.Code__c
                     FROM GDP_Products_Account_View__c 
                     WHERE Id IN : newRecordsIdSet]);
            
            
            position=0; 
            for(SObject newrecord : newRecords)    
            { 
                //Manage change of Agency_Status_Code for desactivation and reinstment first
                Integer NewStatusCode=-1;
                Integer OldStatusCode=-1;
                LogDelta=false;
                //Is the Accrediation used by the Account view 
                if(OBJECT_ACCREDITATION && AccreditationSet.Contains(newrecord.Id))
                {
                    try {
                        if (ISINSERT || ISUPDATE) NewStatusCode = Integer.valueOf(RTid_StatusCodeMap.get((Id)newRecord.get('Status__c')).Code__c);              //New Accreditation__c.Status__r.Code__c
                        if (ISUPDATE) OldStatusCode = Integer.valueOf(RTid_StatusCodeMap.get((Id)oldRecords[position].get('Status__c')).Code__c);   //Old Accreditation__c.Status__r.Code__c 
                        if (ISUPDATE && (NewStatusCode != OldStatusCode)) LogDelta=true;
                    }catch(Exception e) {}                  
                    
                }
                if(OBJECT_ACCOUNTVIEW)
                {    
                    //TODO point to correct fields in GDP_Product_Account_View__c Need to test this code.
                    try {
                        if (ISINSERT || ISUPDATE) NewStatusCode = Integer.valueOf(PAVid_StatusCodeMap.get((Id)newRecord.get('Id')).Related_Accreditation_Class__r.Status__r.Code__c);             
                        if (ISUPDATE) OldStatusCode = Integer.valueOf(AccreditationStatusMap.get((Id)oldRecords[position].get('Related_Accreditation_Class__c')));   //
                        if (ISUPDATE && (NewStatusCode != OldStatusCode)) LogDelta=true;
                    }catch(Exception e) {}                  
                }
                
                //System.debug('OldStatusCode: '+ OldStatusCode);               
                //System.debug('NewStatusCode: '+ NewStatusCode);
                
                String StatusChangeCode = '';
                //There is an Agency Status Change! Get the StatusChangeCode
                if (LogDelta)
                { 
                    //System.debug(' Accreditation status code Change Need to dertermine the code (A, B, C, D)');
                    // load all the specification id 
                    if (OldStatusCode == 0 ){
                        if (NewStatusCode >= 4) StatusChangeCode = 'B';  // Reinstatment
                        
                        else {// NewStatusCode < 4
                            // Do nothing the Agency stays inactive
                            
                        }                                 
                    }
                    else if (OldStatusCode  >= 1 && OldStatusCode <= 3){
                        if (NewStatusCode >= 4) StatusChangeCode = 'A';//Activation
                        else {// NewStatusCode < 4
                            // Do nothing the Agency stays inactive
                            
                        }     
                    }
                    else { //OldStatusCode >= 4
                        if (NewStatusCode == 0) 
                            StatusChangeCode = 'D';//Deactivation
                        if (NewStatusCode == 9) 
                            StatusChangeCode = 'C';  //Status Change
                        
                        if (NewStatusCode >= 4 && NewStatusCode <= 8){
                            if(true){  ///TODO
                                //Status Change
                                StatusChangeCode = 'C';                                            
                            }
                            else {
                                // Do nothing the change code is not sent to the Non member
                                
                            }
                        }   
                    }
                    
                    if (!String.isBlank(StatusChangeCode)) 
                    { // GDP Delta record will only be created for those of interest, 
                      // those with Change_Code blank will not have related GDP Delta 
                        for(String SpecificationId : FirstSpecficationFiles)
                        {
                            GDP_Delta__c Delta = new GDP_Delta__c();
                            Delta.GDP_File_Description__c = SpecificationId;
                            if (OBJECT_ACCOUNTVIEW) Delta.Related_GDP_Product_Account_View__c = newrecord.id; 
                            if (OBJECT_ACCREDITATION) Delta.Related_GDP_Product_Account_View__c = (id)newrecord.get('Related_GDP_Products_Account_View__c');
                            Delta.DeltaLastModifiedDate__c = System.Today();
                            Delta.Change_Code__c = StatusChangeCode;
                            key = Delta.Related_GDP_Product_Account_View__c +'|' + Delta.Change_Code__c + '|' + Delta.GDP_File_Description__c;
                            //Key must not be contained 
                            //GDP Product Account View must be valid
                            if(Delta.Related_GDP_Product_Account_View__c != null && DeltaSet.Contains(key)==false){
                                DeltaList.add(Delta);
                                DeltaSet.Add(key);
                                ProcessedRecordSet.add(Delta.Related_GDP_Product_Account_View__c);
                            }
                        }
                    } // if StatusChangeCode is not blank
                }                    
                position++;
            } 
            
        }
        //Add all the Delta Codes to a structure to avoid working on the same record again
        system.debug('ProcessedRecordSet:' +ProcessedRecordSet);
        
        //End of Status code specific treatment
        
        // update in related objects of GDP_Products_Account_View will only be recorded in delta if they are still active
        // therefore, we need to have some info on GDP_Products_Account_View 
        Map<Id, GDP_Products_Account_View__c> pvaIdToObjectMap = null; //new Map<Id, GDP_Products_Account_View__c> ();
        if (!OBJECT_ACCOUNTVIEW) { pvaIdToObjectMap = getRelatedProductAccountView(oldRecords, NewRecords, sourceObjectName);}
        if (OBJECT_ACCOUNTVIEW) { pvaIdToObjectMap = new Map<Id, GDP_Products_Account_View__c> (); for ( SObject obj : newRecords ) {  GDP_Products_Account_View__c objb = (GDP_Products_Account_View__c) obj; pvaIdToObjectMap.put(objb.id, objb);} }
        
        
        //Generic treatment for aby type of objects.
        //Iterate on records, fields, and File specification to detect change and add change code as needed
        //Iterate the list of new records to find if there are modifications
        position=-1;
        
        for(SObject newrecord : newRecords)    
        {   
            position++;
            //Find-Out what is the parent record id to avoid processing again a record that had a status change
            String ParentRecordId = '';
            if (OBJECT_ACCOUNTVIEW) ParentRecordId = newrecord.id;
            //Case of a child object, the "Standard" lookup field name is Related_GDP_Products_Account_View__c. Could fail otherwise.
            if (!OBJECT_ACCOUNTVIEW) ParentRecordId = (id)newrecord.get('Related_GDP_Products_Account_View__c');

            Id new_Account = null;
            Id old_Account = null;
            try {
                new_Account = (id)newrecord.get('Related_GDP_Products_Account_View__c');
                old_Account = (id)oldRecords[position].get('Related_GDP_Products_Account_View__c');
            }catch(Exception e){}
            
            //Reparenting a child record scenario
            //This can create two change codes: one on the original parent and one on the destination parent
            //Verify if Related_GDP_Products_Account_View__c (Parent lookup) changed
            if (ISUPDATE && !OBJECT_ACCOUNTVIEW && (new_Account != old_Account)){
                Boolean isnewPvaNotEmpty=false;
                Boolean isnewAccountNotEmpty=false;
                Boolean isnewIdMapNotEmpty=false;
                Boolean isoldPvaNotEmpty=false;
                Boolean isoldAccountNotEmpty=false;
                Boolean isoldIdMapNotEmpty=false;
               
                try {
                    isnewAccountNotEmpty = (new_Account != null);
                    isnewPvaNotEmpty     = (pvaIdToObjectMap.get(new_Account) != null );
                    isnewIdMapNotEmpty   = (pvaIdToObjectMap.get(new_Account).Agency_Status_Code_Interpreted__c != 0);
               
                }catch (Exception e){}
                try {
                    isoldAccountNotEmpty = (old_Account != null);
                    isoldPvaNotEmpty     = (pvaIdToObjectMap.get(old_Account) != null );
                    isoldIdMapNotEmpty   = (pvaIdToObjectMap.get(old_Account).Agency_Status_Code_Interpreted__c != 0);
                }catch (Exception e){}
                for(String SpecificationId : FirstSpecficationFiles) 
                {   
                    //StatusChangeCode C of new parent Related_GDP_Product_Account_View__c
                    GDP_Delta__c Delta = new GDP_Delta__c();
                    Delta.GDP_File_Description__c = SpecificationId;
                    Delta.DeltaLastModifiedDate__c = System.Today();
                    Delta.Change_Code__c = 'C';
                    Delta.Related_GDP_Product_Account_View__c = new_Account;
                    key = Delta.Related_GDP_Product_Account_View__c +'|'+Delta.Change_Code__c + '|' + SpecificationId;
                    
                    if (isnewAccountNotEmpty && isnewPvanotEmpty && isnewIdMapNotEmpty && DeltaSet.Contains(key)==false){
                        DeltaList.add(Delta);
                        DeltaSet.Add(key);   
                        ProcessedRecordSet.add(Delta.Related_GDP_Product_Account_View__c);                          
                    }
                    //StatusChangeCode C of OLD parent Related_GDP_Product_Account_View__c
                    GDP_Delta__c oDelta = new GDP_Delta__c();
                    oDelta.GDP_File_Description__c = SpecificationId;
                    oDelta.DeltaLastModifiedDate__c = System.Today();
                    oDelta.Change_Code__c = 'C';
                    oDelta.Related_GDP_Product_Account_View__c = (id)oldRecords[position].get('Related_GDP_Products_Account_View__c');
                    key = oDelta.Related_GDP_Product_Account_View__c +'|'+oDelta.Change_Code__c + '|' + SpecificationId;
                  
                    if (isoldAccountNotEmpty && isoldPvaNotEmpty && isoldIdMapNotEmpty &&  DeltaSet.Contains(key)==false){
                        DeltaList.add(oDelta); 
                        DeltaSet.Add(key); 
                        ProcessedRecordSet.add(oDelta.Related_GDP_Product_Account_View__c);  
                    }
                }
            }
            // END Reparenting a child record scenario
                
                
            system.debug('ParentRecordId: ' + ParentRecordId);
            //Check if record already have a delta change if yes, continue
            if(ProcessedRecordSet.contains(ParentRecordId))  continue;
            
            //System.debug('No Agency code Change, need to loop all fields to detect possible change');
            
            //Loop list of fields
            //system.debug('fieldstructure.keyset(): ' +fieldstructure.keyset());
            for(String dskey : fieldstructure.keyset())
            {
                FieldStructureCls ds = (FieldStructureCls) fieldstructure.get(dskey);
                
                try
                {
                    //Code Review
                    LogDelta=false;
                    if (ISUPDATE) {
                        try {if (newRecord.get(ds.FieldName)!=oldRecords[position].get(ds.FieldName)) LogDelta=true;}catch(exception e) {}
                    }
                    if (ISINSERT || ISDELETE) LogDelta=true;
                    
                    //System.debug('field : '+ds.FieldName+' Delta: '+LogDelta);
                    if (LogDelta)
                        for(String SpecificationId : ds.SpecficationFile)
                        {
                            
                            //StatusChangeCode
                            // load all the specification id 
                            GDP_Delta__c Delta = new GDP_Delta__c();
                            Delta.GDP_File_Description__c = SpecificationId;
                            Delta.DeltaLastModifiedDate__c = System.Today();
                            Delta.Change_Code__c = 'C';
                            boolean IsDeltaList = false;
                            //This is the parent object
                            if(OBJECT_ACCOUNTVIEW) {
                                Delta.Related_GDP_Product_Account_View__c = newrecord.id; 
                                if (ISINSERT) {IsDeltaList = true; Delta.Change_Code__c = 'A';}
                                if (ISDELETE) Delta.Change_Code__c = 'D';                                 
                            }
                            else{ //Case of a child object, the "Standard" lookup field name is Related_GDP_Products_Account_View__c. Could fail otherwise.
                                try{
                                    Delta.Related_GDP_Product_Account_View__c = (id)newrecord.get('Related_GDP_Products_Account_View__c');
                                }
                                catch(exception e) {}
                            }
                            key = Delta.Related_GDP_Product_Account_View__c +'|'+Delta.Change_Code__c + '|' + SpecificationId;
                            //System.debug('key1 >>>'+key);
                            if (DeltaSet.Contains(key)) continue;
                            //System.debug('key2 >>>'+key);
                            
                         
                            // change other than Accreditation__c.Status will be only recorded in delta
                            // if the GDP_Products_Account_View is not inactive
                            
                            if((Delta.Related_GDP_Product_Account_View__c != null)
                                && (pvaIdToObjectMap.get(Delta.Related_GDP_Product_Account_View__c) != null)
                               && (pvaIdToObjectMap.get(Delta.Related_GDP_Product_Account_View__c).Agency_Status_Code_Interpreted__c != 0)) {isDeltaList=true;}
                            
                            If (IsDeltaList) {DeltaList.add(Delta); DeltaSet.Add(key);}
                            
                        }
                    if (LogDelta) break;
                    
                }
                catch(Exception e) {
                System.debug('field : '+ds.FieldName+' Error: '+e.getMessage());
                }
            }   
            
           // position++;
        }
        
        //TODO OPTIMIZATION: future serialize statement for batch asynch processing
        System.debug('DeltaList: '+DeltaList);
        if (DeltaList.size()>0) insert DeltaList;
    } // end of calculateDeltas
    
    
    // get the related GDP_Products_Account_View
    // this is only used for objects other than Accreditation
    // all we need to know is whether the GDP_Products_Account_View Agency_Status_Code_Interpreted__c is terminated (0) or not.
    private static Map<Id, GDP_Products_Account_View__c> getRelatedProductAccountView(
            List<SObject> oldRecords, List<SObject> NewRecords
            , String sourceObjectName
        )
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SobjectType objectType = gd.get(sourceObjectName);
        
        Set<Id> pavIdSet = new Set<Id>();
        Id pavId;
       
        for ( SObject obj : oldRecords ) {
            pavId = (Id) obj.get('Related_GDP_Products_Account_View__c');
            if ( pavId != null) pavIdSet.add(pavId);
        }
        for ( SObject obj : newRecords ) {
            pavId = (Id) obj.get('Related_GDP_Products_Account_View__c');
            if ( pavId != null) pavIdSet.add(pavId);
        }
        
        Map<Id, GDP_Products_Account_View__c> relatedProductAccountView = new Map<Id, GDP_Products_Account_View__c>(
            [select Id
                    , Agency_Status_Code_Interpreted__c //  
                    , Related_Accreditation_Class__c
                    , Related_Accreditation_Class__r.Status__r.Code__c
             from GDP_Products_Account_View__c 
             where Id in : pavIdSet
             ]
            );
        return relatedProductAccountView;
    }
}