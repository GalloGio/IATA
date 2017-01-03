public with sharing class AMS_XML_Generator {
    
    public List<RecordType> lRecordType;

    //Map that will store all referenced objects
    public Map<Id, sObject> msObject;

    public Map<String,AMS_WAD_Settings__c> mWadNameValues;
    public Map<String,AMS_WAD_Settings__c> mWadFieldValues;

    public Map<String,String> mXMLTagValues;
    public Map<String,String> mXMLFieldValues;

    public Map<Id, AMS_Agency_Updates__c> mAg_VS_AgUpdate;
    public Map<Id, String> mAg_VS_ChangeCode;
    public Map<Id, Agency_Applied_Change_code__c> mAg_VS_AgChangeCode;
    public Map<Id, Agency_Applied_Change_code__c> mAg_VS_AgChangeCodeFIN;
    public Map<Id, Agency_Applied_Change_code__c> mAg_VS_AgChangeCodeDEF;
    public Map<Id, String> mAg_VS_AgArea;
    public Map<Id, String> mAg_VS_AgSiteType;
    public Map<Id, Id> mAg_VS_ParentAg;
    public Map<Id, Id> mAgComputerReservation_VS_ComputerReservation;
    public Map<Id, Id> mAgAirport_VS_Airport;
    public Map<Id, Id> mAgAffiliation_VS_Affiliation;
    public Map<Id, Id> mAg_VS_Person;
    public Map<Id, Id> mAg_VS_Contact;
    public Map<Id, Id> mEmp_VS_Person;
    public Map<Id, Id> mEmp_VS_Contact;
    //public Map<Id, AMS_Agency__c> mAg_VS_Agency; - #AMSFTS
    public Map<Id, String> mAg_VS_Segment;
    //public Map<Id, List<AMS_Employee__c>> mAg_VS_Employees; - #AMSFTS
    public Map<Id, List<AMS_Account_Role__c>> mAg_VS_Employees;
    
    public Map<Id, Id> mAg_VS_HO;

    public List<AMS_Agency_Updates__c> lAgencyUpdates;  
    public List<Agency_Applied_Change_code__c> lAgencyChangeCode; 

    //public List<AMS_Address__c> lAgencyArea; - #AMSFTS
    public List<Account> lAgencyArea;

    public List<AMS_Address__c> lAddresses;
    public List<IATA_ISO_Country__c> lCountry;
    public List<IATA_ISO_State__c> lState;
    
    //public List<AMS_Agency_Ownership__c> lOwnership; - #AMSFTS
    public List<AMS_Account_Role__c> lOwnership;
    
    //public List<AMS_Owner__c> lOwner; - #AMSFTS
    public List<Account> lOwner;
    public List<Account> lAccount; 
    public List<Contact> lContact;
    public List<User> lUser;
    public List<AMS_Person__c> lPerson;

    //public List<AMS_Employee__c> lEmployee; - #AMSFTS
    public List<AMS_Account_Role__c> lEmployee;

    //JFO 13/8/2015  deleted for new DM without GDS custom object
    //public List<AMS_Agency_Computer_Reservation__c> lAgComputerReservation;
    //public List<AMS_Computer_Reservation_System__c> lComputerReservation;
    public List<AMS_Inspection__c> lInspection;
    public List<AMS_Agencies_relationhip__c> lAgRelationship;
    public List<AMS_Agencies_relationhip__c> lAgRelationshipParent;
    public List<AMS_Agencies_relationhip__c> lAgRelationshipChild;
    //public List<AMS_Agency__c> lAgRelationshipHierarchy; - #AMSFTS
    public List<Account> lAgRelationshipHierarchy;
    public List<AMS_Agencies_Hierarchy__c> lAgHierarchy;
    public List<AMS_Agency_Airport__c> lAgAirport;
    public List<AMS_Airport__c> lAirport;
    public List<AMS_Agency_Profile__c> lAgProfile;
    public List<AMS_Agency_Affiliation__c> lAgAffiliation;
    public List<AMS_Affiliation__c> lAffiliation;
    public List<AMS_Fields_Translation__c> lFieldsTranslation;
    public List<AMS_Agency_Segment__c> lAgSegment;
    public List<Agency_Applied_Change_code__c> lAgAppChangeCode;
    public List<Agency_Applied_Change_code__c> lAgAppChangeCodeDEF;
    

    public List<String> orderedAgencyIds;
    
    
    Boolean bSetFields = False;
    SET<String> sFieldsToTranslate = new SET<String>();
    SET<String> sFieldsToInclude = new SET<String>();
    SET<String> sFieldsToExclude = new SET<String>();

    //could use a custom setting for the future 
    Set<String> lIgnoredAddressTypes = new Set<String>{'Primary', 'Billing', 'Shipping', 'Old'};

    public Integer fixLimit = 100;

    public String sDebug = '';
    
    //CONSTRUCTOR                                            
    public AMS_XML_Generator() {

        
        //Get values from Custom Setting Object - AMS_XML_Tags__c
        if(mXMLTagValues == null) {
            mXMLTagValues = new Map<String,String>();
            for (AMS_XML_Tags__c xmlTag : [SELECT Id,Name,Name__c,Tag__c FROM AMS_XML_Tags__c]) {
                mXMLTagValues.put(xmlTag.Name__c.toLowerCase(), xmlTag.Tag__c.toLowerCase());  

            }
        } else {
            mXMLTagValues = new Map<String,String>();
        } 

        //Get values from Custom Setting Object - AMS_XML_fields__c
        if(!bSetFields) {
            bSetFields = True;
            
            for (AMS_XML_Fields__c xmlField : [SELECT Field__c,Id,Name,Object__c,Operation_Type__c FROM AMS_XML_Fields__c order by Operation_Type__c]) {
              
                if( xmlField.Operation_Type__c.equalsIgnoreCase('translate') ){
                    sFieldsToTranslate.add(xmlField.Object__c.toLowerCase()+'.'+xmlField.Field__c.toLowerCase());
                }else if(xmlField.Operation_Type__c.equalsIgnoreCase('include')){
                    sFieldsToInclude.add(xmlField.Object__c.toLowerCase()+'.'+xmlField.Field__c.toLowerCase());
                }else if(xmlField.Operation_Type__c.equalsIgnoreCase('exclude')){
                    sFieldsToExclude.add(xmlField.Field__c.toLowerCase());
                }
            }
        } 

        System.debug('***** mXMLTagValues: ' + mXMLTagValues);
        System.debug('***** sFieldsToInclude: ' + sFieldsToInclude);

    }

   

    //Get XML for Agency SalesOrder to send to AW WS 
    //public String getAgencySalesOrder(AMS_Agency__c agency){ #AMSFTS
    //public String getAgencySalesOrder(Account agency){
    public String getAgencySalesOrder(Agency_Applied_Change_code__c agency){
    
        //List<AMS_Agency__c> lAg = new List<AMS_Agency__c>(); #AMSFTS
        //List<Account> lAg = new List<Account>();
        List<Agency_Applied_Change_code__c> lAg = new List<Agency_Applied_Change_code__c>();
                lAg.add(agency);

        return getAgencySalesOrder(lAg);

    }

    //Get XML for Agency SalesOrder to send to AW WS 
    //public String getAgencySalesOrder(List<AMS_Agency__c> agencies){ #AMSFTS
    //public String getAgencySalesOrder(List<Account> agencies){
    public String getAgencySalesOrder(List<Agency_Applied_Change_code__c> agencies){

        //Begin of XML tags
        Dom.Document doc = new Dom.Document();
    
        Dom.Xmlnode rootNode = doc.createRootElement('sales_orders', null, null);

        //Agency Section
        
        Date dToday = Date.today();
        Datetime dtToday = Datetime.now(); // Returns the current Datetime based on a GMT calendar.

        //for(Account ag : agencies){
        for(Agency_Applied_Change_code__c ag : agencies){
            Dom.Xmlnode liNode = rootNode.addChildElement('line_item', null, null);

          
            getElementNode(liNode, 'agency_id', ag.Account__r.IATACode__c );
            getElementNode(liNode, 'hub', ag.Account__r.IATA_ISO_Country__r.IATA_Regional_Office__c);
            getElementNode(liNode, 'period_from', dtToday.format('yyyyMMdd'));
            getElementNode(liNode, 'period_to', dtToday.format('yyyyMMdd'));
            getElementNode(liNode, 'product_id', ag.Account__r.Location_Class__c + ag.Change_Code__c); 
            getElementNode(liNode, 'quantity', '1');
            //#AMSFTS - END
            
        }

        system.debug('--------- doc: ' + doc.toXmlString());        
        return doc.toXmlString();   

    }

    //Get XML for Error Message to send to AW WS
    public String getErrorMessage(String ids, String[] r){

        List<String> lAg = new List<String>();
        lAg.add(ids);

        return getErrorMessage(lAg, r);
    }
    
    //Get XML for Error Message to send to AW WS 
    public String getErrorMessage(List<String> ids, String[] r ){
        
        //Header Values
        Map<String, String> mHeaderValues = new Map<String, String>();
        Date dToday = Date.today();
        Datetime dtToday = Datetime.now(); // Returns the current Datetime based on a GMT calendar.
        
        mHeaderValues.put('copymsg', AMS_SAP_Settings__c.getOrgDefaults().Copy_Right_Message__c);
        mHeaderValues.put('version', 'v1');
        mHeaderValues.put('rec_id', 'H');
        mHeaderValues.put('priority', 'High');
        mHeaderValues.put('prodsys', 'AMS');
        mHeaderValues.put('proddate', dtToday.format('yyyyMMdd'));
        mHeaderValues.put('prodtime', dtToday.format('HHmmss'));

        //Begin of XML tags
        Dom.Document doc = new Dom.Document();
    
        Dom.Xmlnode rootNode = doc.createRootElement('agencies_message', null, null);

        Dom.Xmlnode ResponseHeaderNode = rootNode.addChildElement('response_header', null, null);
        
        Dom.Xmlnode PreviousIdNode = ResponseHeaderNode.addChildElement('previous_id', null, null);
        PreviousIdNode.addTextNode('');
        Dom.Xmlnode GroupIDNode = ResponseHeaderNode.addChildElement('group_id', null, null);
        GroupIDNode.addTextNode(r[0]);
        Dom.Xmlnode ChunkSizeNode = ResponseHeaderNode.addChildElement('chunk_size', null, null);
        ChunkSizeNode.addTextNode(r[1]);
        Dom.Xmlnode ChunkKeyNode = ResponseHeaderNode.addChildElement('chunk_key', null, null);
        ChunkKeyNode.addTextNode(r[2]);
        Dom.Xmlnode ChunkTotalNode = ResponseHeaderNode.addChildElement('chunk_total', null, null);
        ChunkTotalNode.addTextNode(r[3]);
        Dom.Xmlnode ErrorFlagNode = ResponseHeaderNode.addChildElement('error_flag', null, null);
        ErrorFlagNode.addTextNode('TRUE');


        Dom.Xmlnode AMS_AgenciesNode = rootNode.addChildElement('agency_data', null, null);

        ////Header Section
        getHeaderNode(AMS_AgenciesNode, mHeaderValues);

        //BEGIN Country tag
        Dom.Xmlnode countryNode = AMS_AgenciesNode.addChildElement('country', null, null);

        getElementNode(countryNode, 'name', Null);
        getElementNode(countryNode, 'bsp', Null);
        getElementNode(countryNode, 'cass', Null);
        getElementNode(countryNode, 'dpc_system', Null);
        getElementNode(countryNode, 'hub', Null);

        //TODO - Check what's necessary here!
        Dom.Xmlnode filtersNode = countryNode.addChildElement('filters', null, null);
        getElementNode(filtersNode, 'name', Null);
        getElementNode(filtersNode, 'value', Null);
        
        //BEGIN Agencies
        Dom.Xmlnode agenciesNode = countryNode.addChildElement('agencies', null, null);
  
        for (String sId : ids) {
            Dom.Xmlnode agencyNode = agenciesNode.addChildElement('agency', null, null);
            getElementNode(agencyNode, 'ams_id', sId);
        }

        //Footer Section
        getFooterNode(AMS_AgenciesNode, ids.size());

        //DataTrace Section
        getDataTraceNode(AMS_AgenciesNode, r);

        system.debug('--------- doc: ' + doc.toXmlString());     
        system.debug(sDebug);
        
        return doc.toXmlString();
    }
    
    
    //Get XML for AgencyDetail to send to AW WS (2º step)
    //public String getAgencyDetail(AMS_Agency__c agency, String[] r){  #AMSFTS
    public String getAgencyDetail(Account agency, String[] r, String type, String caseId){

        //List<AMS_Agency__c> lAg = new List<AMS_Agency__c>(); #AMSFTS
        List<Account> lAg = new List<Account>();
        lAg.add(agency);

        return getAgencyDetail(lAg, r, type, caseId);
    }

    //Get XML for AgencyDetail to send to AW WS (2º step)
    //Type - determinates if it's "MasterData" or "ECC"
    //case -  Brings the OSCAR case Id for getting the ECC data
    //public String getAgencyDetail(List<AMS_Agency__c> agency, String[] r){ - #AMSFTS
    public String getAgencyDetail(List<Account> agency, String[] r, String type, String caseId){
        
        Integer inicioCPU = Limits.getCpuTime();
        Integer inicioCPUx = Limits.getLimitCpuTime();
        
        //Map that will store all referenced objects
        msObject = new Map<Id, sObject>();

        mAg_VS_AgUpdate = new Map<Id, AMS_Agency_Updates__c>();
        mAg_VS_ChangeCode = new Map<Id, String>(); 
        mAg_VS_AgChangeCode = new Map<Id, Agency_Applied_Change_code__c>();
        mAg_VS_AgChangeCodeFIN = new Map<Id, Agency_Applied_Change_code__c>();
        mAg_VS_AgChangeCodeDEF = new Map<Id, Agency_Applied_Change_code__c>();
        mAg_VS_AgArea = new Map<Id, String>();
        mAg_VS_AgSiteType = new Map<Id, String>();
        mAg_VS_ParentAg = new Map<Id, Id>();
        mAgComputerReservation_VS_ComputerReservation = new Map<Id, Id>();
        mAgAirport_VS_Airport = new Map<Id, Id>();
        mAgAffiliation_VS_Affiliation = new Map<Id, Id>();
        mAg_VS_Person = new Map<Id, Id>();
        mAg_VS_Contact = new Map<Id, Id>();
        mEmp_VS_Person = new Map<Id, Id>();
        mEmp_VS_Contact = new Map<Id, Id>();
        mAg_VS_Segment = new Map<Id, String>();
        //mAg_VS_Employees = new Map<Id, List<AMS_Employee__c>>(); - #AMSFTS
        mAg_VS_Employees = new Map<Id, List<AMS_Account_Role__c>>();
        mAg_VS_HO = new Map<Id, Id>();

        SET<Id> setAgencyKeys;
        SET<Id> setAgencyCountryKeys = new SET<Id>();
        SET<Id> setAddressKeys = new SET<Id>();
        SET<Id> setAddressCountryKeys = new SET<Id>();
        SET<Id> setAddressStateKeys = new SET<Id>();
        SET<Id> setOwnershipKeys = new SET<Id>();
        SET<Id> setComputerReservationKeys = new SET<Id>();
        SET<Id> setAccountKeys = new SET<Id>();
        SET<Id> setEmployeeKeys = new SET<Id>();
        SET<Id> setPersonKeys = new SET<Id>();
        SET<Id> setContactKeys = new SET<Id>();
        SET<Id> setUserKeys = new SET<Id>();
        SET<Id> setHierarchyKeys = new SET<Id>();
        SET<Id> setAgRelationshipKeys = new SET<Id>();
        SET<Id> setAirportKeys = new SET<Id>();
        SET<Id> setAffiliationKeys = new SET<Id>();
        SET<Id> setHO = new SET<Id>();


        orderedAgencyIds = r[5].split(',');
        System.debug('orderedAgencyIds:' + orderedAgencyIds);

        //Get AMS_Segment__c RecordType ID for "IATA Code Programs"
        Id rtProgram = Schema.SObjectType.AMS_Segment__c.getRecordTypeInfosByName().get('IATA Code Programs').getRecordTypeId();
        //Get AMS_Agencies_Hierarchy__c RecordType ID for "MAIN"
        Id rtHierarchy = Schema.SObjectType.AMS_Agencies_Hierarchy__c.getRecordTypeInfosByName().get('MAIN').getRecordTypeId();

        //Begin - #AMSFTS
        Id rtAccRoleOwnership = Schema.SObjectType.AMS_Account_Role__c.getRecordTypeInfosByName().get('Ownership').getRecordTypeId();
        Id rtAccRoleEmployee = Schema.SObjectType.AMS_Account_Role__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId();
        //END - #AMSFTS

        System.debug('XML Generator - Requested Agencies from MDM PI - ' + agency);
        sDebug += '\nAgencies List:' + agency;
        
        //Get agenc
        setAgencyKeys = (new Map<Id,Account>(agency)).keySet();

        //System.debug('XML Generator - setAgencyKeys - ' + setAgencyKeys);

        for (Account o : agency) {
            //setAccountKeys.add(o.Account__c); 
            setAgencyCountryKeys.add(o.IATA_ISO_Country__c);
            setAddressStateKeys.add(o.Iso_State__c);
        }
        //END - #AMSFTS

        //MAIN
        //Begin - #AMSFTS
        //lAgencyUpdates = [SELECT Agency__c,Id,Name,RelationShip__c,Update_Type__c 
        //                    FROM AMS_Agency_Updates__c
        //                    where Agency__c in :setAgencyKeys];
        //lAgencyUpdates = [SELECT Account__c,Id,Name,RelationShip__c,Update_Type__c 
        //                    FROM AMS_Agency_Updates__c
        //                    where Account__c in :setAgencyKeys
        //                    order by CreatedDate DESC];

        lAgencyUpdates = [SELECT Account__c,CreatedDate,LastModifiedDate,Id,Update_Type__c, Change_Code__c 
                            FROM AMS_Agency_Updates__c 
                            WHERE Account__c IN :setAgencyKeys 
                            ORDER BY Account__c,LastModifiedDate desc];                       
        //END - #AMSFTS                                        

        AMS_Agency_Updates__c auxAU = new AMS_Agency_Updates__c();
        for (AMS_Agency_Updates__c agUpd : lAgencyUpdates) {
            //mAg_VS_AgUpdate.put(agUpd.Agency__c,agUpd); #AMSFTS

            //Stores only the 1st record from the agency update query, this one have the latest change code to be used
            if(auxAU == null || agUpd.Account__c != auxAU.Account__c){
                auxAU = agUpd;
                mAg_VS_AgUpdate.put(agUpd.Account__c,agUpd);   
                mAg_VS_ChangeCode.put(agUpd.Account__c,agUpd.Change_Code__c);   
            }            
        }
        

        lAgencyChangeCode = [SELECT Account__c,Active__c,Change_Code__c, CreatedDate, Created_Date_To_Show__c 
                                FROM Agency_Applied_Change_code__c 
                                WHERE Change_Code__c != null 
                                AND Active__c = true 
                                AND Account__c in :setAgencyKeys];
        
        for (Agency_Applied_Change_code__c agChgCode : lAgencyChangeCode) {
            mAg_VS_AgChangeCode.put(agChgCode.Account__c,agChgCode);
        }                            

        //Reference
        lAgSegment = [SELECT Account__c,Assignation_Type__c,Id,Name,Segment__c,Segment__r.label__c 
                            FROM AMS_Agency_Segment__c
                            where Segment__r.RecordTypeid = :rtProgram
                            and Account__c in :setAgencyKeys];
        //END - #AMSFTS                     

        for (AMS_Agency_Segment__c agSeg : lAgSegment) {
            //mAg_VS_Segment.put(agSeg.Agency__c,agSeg.Segment__r.label__c); #AMSFTS
            mAg_VS_Segment.put(agSeg.Account__c,agSeg.Segment__r.label__c);
        }

        //MAIN
        lAgencyArea = [SELECT Id,IATA_ISO_Country__r.AIMS_Area_ID__c 
                            FROM Account
                            where Id in :setAgencyKeys];
        

        for (Account agArea : lAgencyArea) {
            mAg_VS_AgArea.put(agArea.Id,String.valueOf(agArea.IATA_ISO_Country__r.AIMS_Area_ID__c) );
        }
        //END - #AMSFTS

        //MAIN - 
        lAddresses = [SELECT Address_1__c,Address_2__c,Address_3__c,Account__c,Address_Type__c,TTY__c,
                                    AMS_ZipCode__c,City__c,Country_postal_abbreviation__c,Country__c,Email__c,
                                    Id,Legacy_External_ID__c,Legacy_System__c,Name,State__c,
                                    Telephone__c,Telephone_Int__c,Telephone_STD__c,
                                    Fax__c,Fax_Int__c,Fax_STD__c,
                                    Mobile__c,Mobile_Int__c,Mobile_STD__c,
                                    Website__c,Country__r.Id,State__r.Id
                                    FROM AMS_Address__c 
                                    WHERE Account__c in :setAgencyKeys
                                    AND Send_to_External_System__c = true
                                    limit :fixLimit];
        //END - #AMSFTS                                    

        for (AMS_Address__c add : lAddresses) {
            setAddressKeys.add(add.Id);
            setAddressCountryKeys.add(add.Country__c);
            setAddressStateKeys.add(add.State__c);
        }

        //REFERENCE
        lCountry = [SELECT AIMS_Area_ID__c,AIMS_Area_Name__c,AIMS_Region__c,BSP_Country_free_text__c,Case_BSP_Country__c,
                CASS_Country_free_text__c,Country_Manager__c,IATA_Regional_Office__c,Id,International_dialing_code_ISD__c,
                ISO_Code__c,Name,Region__c,SLA_Type__c,Sub_Region__c,Country_Manager__r.Name
                FROM IATA_ISO_Country__c where Id in :setAddressCountryKeys or Id in :setAgencyCountryKeys];
        
        //REFERENCE
        lState = [SELECT Name,ISO_Code__c,ISO_CODE_STANDARD__c FROM IATA_ISO_State__c where Id in :setAddressStateKeys];

        //MAIN
        //Begin - #AMSFTS
        //lOwnership = [SELECT Agency__c,AMS_Agency_Owner__c,Id,Name,Percentage__c 
        //                  FROM AMS_Agency_Ownership__c WHERE Agency__c in :setAgencyKeys];
        
        lOwnership = [SELECT Account__c,Owner_Account__c,Id,Name,Percentage__c,Person__c,Contact__c,RecordTypeId,Employee_type__c    
                            FROM AMS_Account_Role__c WHERE Account__c in :setAgencyKeys
                            AND RecordTypeId = :rtAccRoleOwnership
                            limit :fixLimit];
        //END - #AMSFTS 

        //Begin - #AMSFTS
        //for (AMS_Agency_Ownership__c o : lOwnership) {
        //    setOwnershipKeys.add(o.AMS_Agency_Owner__c);
        //}
        for (AMS_Account_Role__c o : lOwnership) {
            setOwnershipKeys.add(o.Owner_Account__c);
            if(o.Person__c != Null){
                setPersonKeys.add(o.Person__c);
            }
            if(o.Contact__c != Null){
                setContactKeys.add(o.Contact__c);
            }
        }
        //END - #AMSFTS 

        //REFERENCE
        //Begin - #AMSFTS
        //lOwner = [SELECT Account__c,Id,Name,Person__c FROM AMS_Owner__c WHERE Id in :setOwnershipKeys];
        //for (AMS_Owner__c o : lOwner) {
        //    setAccountKeys.add(o.Account__c); 
        //    if(o.Person__c != Null){
        //        setPersonKeys.add(o.Person__c);
        //    }
        //}

        lOwner = [SELECT Airline_Code__c,A_Code__c,
                    CASS_Number__c,Check_Digit__c,GDS__c,
                    Company_Type__c,C_Code__c,IATACode__c,Id,Location_Type__c,
                    Last_Inspection_Date__c,Last_synchronization__c,
                    License_Number__c,Location_Category__c,Location_Class__c,Name,GDP_Opt_In__c,
                    N_Code__c,Organization_Last_Change_Date__c,
                    Original_Approval_DAte__c,VAT_Number_2__c,OwnerId,
                    Phone_Number__c, Phone, Fax, Primary_address__c,
                    RecordTypeId,RecordType.Name,
                    STD_Code__c,VAT_Number__c,
                    TradeName__c,Unique_ID__c,Verification_Date__c,IATA_ISO_Country__c, IATA_ISO_Country__r.Name,
                    Short_Name__c,Abbreviated_name__c,Sector__c,AIMS_ID__c,BSP_CASS_Code__c
                    FROM Account WHERE Id in :setOwnershipKeys];

        for (Account o : lOwner) {
            setAccountKeys.add(o.Id); 
        }
        //Begin - #AMSFTS


        //MAIN
        lEmployee = [SELECT Account__c,Duty__c,Earning__c,Employee_type__c,Hours__c,Id,isManager__c,isTicketingAgent__c,
                    Name,Person__c,Position__c,Registration_Date__c,Stage__c,Start_date__c,Contact__c,
                    Termination_Date__c,Title__c,Valid__c,RecordTypeId,Owner_Account__c,Percentage__c
                    FROM AMS_Account_Role__c 
                    WHERE RecordTypeId = :rtAccRoleEmployee
                        AND Account__c in :setAgencyKeys
                        AND (isManager__c = True OR isTicketingAgent__c = True )                             
                    limit :fixLimit];
      
        //for (AMS_Employee__c emp : lEmployee) { - #AMSFTS 
        for (AMS_Account_Role__c emp : lEmployee) {    
            setEmployeeKeys.add(emp.Id);
            if(emp.Person__c != Null){
                setPersonKeys.add(emp.Person__c);
            }
            if(emp.Contact__c != Null){
                setContactKeys.add(emp.Contact__c);
            }
            mEmp_VS_Person.put(emp.Id, emp.Person__c);
            mEmp_VS_Contact.put(emp.Id, emp.Contact__c);
            //Begin - #AMSFTS
            //if(!mAg_VS_Person.containsKey(emp.Agency__c)){
            //    mAg_VS_Person.put(emp.Agency__c, emp.Person__c);
            //}
            if(emp.Person__c != null){
                if(!mAg_VS_Person.containsKey(emp.Account__c)){
                    mAg_VS_Person.put(emp.Account__c, emp.Person__c);
                }
            }
            if(emp.Contact__c != null){
                if(!mAg_VS_Contact.containsKey(emp.Account__c)){
                    mAg_VS_Contact.put(emp.Account__c, emp.Contact__c);
                }
            }
            //END - #AMSFTS
            if(mAg_VS_Employees.containsKey(emp.Account__c)){
                List<AMS_Account_Role__c> lEmp = mAg_VS_Employees.get(emp.Account__c);
                lEmp.add(emp);
                mAg_VS_Employees.remove(emp.Account__c);
                mAg_VS_Employees.put(emp.Account__c, lEmp);
            }else{
                List<AMS_Account_Role__c> lEmp = new List<AMS_Account_Role__c>();
                lEmp.add(emp);
                mAg_VS_Employees.put(emp.Account__c, lEmp);
            }
            //END - #AMSFTS
        }

        
        //MAIN
        //Begin - #AMSFTS
        //lInspection = [SELECT Accreditation_Endorsement_Status_code__c, Accreditation_Endorsement_organisation__r.Air_Code__c,
        //                Date_Organisation_Status_attained__c,Id,Name,Agency__c,Agency__r.Organization_Last_Change_Date__c, 
        //                Agency__r.Last_Inspection_Date__c,Agency__r.Original_Approval_DAte__c,Agency__r.Location_Class__c                        
        //                FROM AMS_Inspection__c WHERE Agency__c in :setAgencyKeys];
        lInspection = [SELECT Accreditation_Endorsement_Status_code__c, Accreditation_Endorsement_organisation__r.Air_Code__c,
                        Date_Organisation_Status_attained__c,Id,Name,
                        Account__c,
                        Account__r.Organization_Last_Change_Date__c, 
                        Account__r.Last_Inspection_Date__c,
                        Account__r.Original_Approval_DAte__c,
                        Account__r.Location_Class__c                        
                        FROM AMS_Inspection__c WHERE Account__c in :setAgencyKeys 
                        ORDER BY Date_Organisation_Status_attained__c desc
                        LIMIT :fixLimit];
        //to add later when I've the correct codes
        //AND Accreditation_Endorsement_organisation__r.Air_Code__c in ('IATA','IATAN','DOM','ARC','ATAC','DAPA','TSCOM','TRUE') 

        //END - #AMSFTS

        //MAIN
        //Begin - #AMSFTS
        //lAgRelationship = [SELECT Parent_agency__c,Child_Agency__c,Hierarchy__c,HO_Flag__c,Id,Name,Relationship_details__c 
        //            FROM AMS_Agencies_relationhip__c WHERE Child_Agency__c in :setAgencyKeys AND Hierarchy__r.RecordTypeId = :rtHierarchy];
        lAgRelationship = [SELECT Parent_Account__c,Child_Account__c,Hierarchy__c,HO_Flag__c,Id,Name,Relationship_details__c 
                    FROM AMS_Agencies_relationhip__c 
                    WHERE Child_Account__c in :setAgencyKeys 
                    AND Hierarchy__r.RecordTypeId = :rtHierarchy
                    limit :fixLimit];
        //END - #AMSFTS               
       
        for (AMS_Agencies_relationhip__c rel : lAgRelationship) {
            setHierarchyKeys.add(rel.Hierarchy__c);
            
            //Begin - #AMSFTS
            //setAgRelationshipKeys.add(rel.Parent_agency__c);
            //mAg_VS_ParentAg.put(rel.Child_Agency__c, rel.Parent_agency__c);
            setAgRelationshipKeys.add(rel.Parent_Account__c);
            mAg_VS_ParentAg.put(rel.Child_Account__c, rel.Parent_Account__c);
            //END - #AMSFTS   
        }

        //REFERENCE
        lAgRelationshipHierarchy = [SELECT Id,AIMS_ID__c,
                    CASS_Number__c,Check_Digit__c,IATACode__c,
                    C_Code__c,ParentId,Parent.AIMS_ID__c,
                    IATA_Area__c,Sector__c
                    FROM Account where id in :setAgRelationshipKeys];
        //END - #AMSFTS   

        //REFERENCE                    
        lAgHierarchy = [SELECT Hierarchy_Name__c,Id,Name,RecordTypeId 
                        FROM AMS_Agencies_Hierarchy__c WHERE Id in :setHierarchyKeys
                        AND RecordTypeId = :rtHierarchy];
        
        Map<Id,Id> mHier_VS_HO;
        mHier_VS_HO = new Map<Id,Id>();

        //Get HO (Head Office) Id
        //Begin - #AMSFTS
        //List<AggregateResult> lAgHO = [SELECT Parent_agency__c, Hierarchy__c FROM AMS_Agencies_relationhip__c 
        //            where Hierarchy__c in :setHierarchyKeys
        //            and HO_Flag__c = 'True' AND Hierarchy__r.RecordTypeId = :rtHierarchy
        //            group by Parent_agency__c, Hierarchy__c ];
        List<AggregateResult> lAgHO = [SELECT Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c 
                    where Hierarchy__c in :setHierarchyKeys
                    AND Hierarchy__r.RecordTypeId = :rtHierarchy
                    group by Parent_Account__c, Hierarchy__c ];

        for(AggregateResult agHO : lAgHO){
            setHO.add((Id)agHO.get('Parent_Account__c'));
        }

        //lAgHO = [SELECT Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c 
        //            where Hierarchy__c in :setHierarchyKeys
        //            AND Hierarchy__r.RecordTypeId = :rtHierarchy
        //            AND Parent_Account__c in :setHO
        //            AND Child_Account__c not in :setHO
        //            group by Parent_Account__c, Hierarchy__c];   
        List<AggregateResult> lAgParentHO = [SELECT Parent_Account__c,Hierarchy__c FROM AMS_Agencies_relationhip__c 
                    where Hierarchy__c in :setHierarchyKeys
                    AND Hierarchy__r.RecordTypeId = :rtHierarchy
                    group by Hierarchy__c,Parent_Account__c]; 

        Map<Id,Id> mAgParentHO = new Map<Id,Id>();
        for(AggregateResult agAux1 : lAgParentHO){
            mAgParentHO.put( (Id)agAux1.get('Parent_Account__c') , (Id)agAux1.get('Hierarchy__c') );
        }

        List<AggregateResult> lAgChildHO = [SELECT Child_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c 
                    where Hierarchy__c in :setHierarchyKeys
                    AND Hierarchy__r.RecordTypeId = :rtHierarchy
                    group by Hierarchy__c, Child_Account__c];      

        List<Id> lAgChildHOtoCheck = new List<Id>();
        for(AggregateResult agAux2 : lAgChildHO){
            lAgChildHOtoCheck.add( (Id)agAux2.get('Child_Account__c') );
        }                           
        //END - #AMSFTS  
        
        for(Id agChildId : lAgChildHOtoCheck){
            if( mAgParentHO.containsKey(agChildId) ){
                mAgParentHO.remove(agChildId);
            }
        }
        
        
        //for(AggregateResult agHO : lAgHO){
        //    mHier_VS_HO.put((Id)agHO.get('Hierarchy__c') ,(Id)agHO.get('Parent_Account__c'));   
        //    setAccountKeys.add((Id)agHO.get('Parent_Account__c')); 
        //}
        for(Id parentId : mAgParentHO.keySet() ){
            Id auxRelId = (Id)mAgParentHO.get(parentId);
            mHier_VS_HO.put(auxRelId ,parentId); 
            setAccountKeys.add(parentId); 
        }
        
        for (AMS_Agencies_relationhip__c agR : lAgRelationship) {
            mAg_VS_HO.put((Id)agR.Child_Account__c, (Id)mHier_VS_HO.get(agR.Hierarchy__c));
        }

        //System.debug('mHier_VS_HO: ' + mHier_VS_HO);
        //System.debug('mAg_VS_HO: ' + mAg_VS_HO);

        //MAIN
        //Begin - #AMSFTS
        //lAgAirport = [SELECT Airport__c,Agency__c FROM AMS_Agency_Airport__c WHERE Agency__c in :setAgencyKeys];
        lAgAirport = [SELECT Airport__c,Account__c FROM AMS_Agency_Airport__c 
                        WHERE Account__c in :setAgencyKeys
                        limit :fixLimit];
        //END - #AMSFTS   

        for (AMS_Agency_Airport__c airp : lAgAirport) {
            setAirportKeys.add(airp.Airport__c);
            //Begin - #AMSFTS
            //mAgAirport_VS_Airport.put(airp.Airport__c,airp.Agency__c);
            mAgAirport_VS_Airport.put(airp.Airport__c,airp.Account__c);
            //END - #AMSFTS  
        }

        //REFERENCE
        lAirport = [SELECT City__c,Code__c,Country__c,Id,Name FROM AMS_Airport__c
                    WHERE id in :setAirportKeys];

        //MAIN
        //Begin - #AMSFTS
        //lAgAffiliation = [SELECT Affiliation__c,Agency__c FROM AMS_Agency_Affiliation__c WHERE Agency__c in :setAgencyKeys];
        lAgAffiliation = [SELECT Affiliation__c,Account__c FROM AMS_Agency_Affiliation__c 
                            WHERE Account__c in :setAgencyKeys
                            limit :fixLimit];
        //END - #AMSFTS

        for (AMS_Agency_Affiliation__c affil : lAgAffiliation) {
            setAffiliationKeys.add(affil.Affiliation__c);
            //Begin - #AMSFTS
            //mAgAffiliation_VS_Affiliation.put(affil.Affiliation__c,affil.Agency__c);
            mAgAffiliation_VS_Affiliation.put(affil.Affiliation__c,affil.Account__c);
            //END - #AMSFTS
        }

        //REFERENCE
        lAffiliation = [SELECT Affiliation_Code__c,Id,Name FROM AMS_Affiliation__c
                    WHERE id in :setAffiliationKeys];            

        //MAIN
        //Begin - #AMSFTS
        //lAgProfile = [SELECT GR_Code__c,GR_Item__c,Id,Name,Agency__c FROM AMS_Agency_Profile__c 
        //            WHERE Agency__c in :setAgencyKeys];
        lAgProfile = [SELECT GR_Code__c,GR_Item__c,Id,Name,Account__c FROM AMS_Agency_Profile__c 
                        WHERE Account__c in :setAgencyKeys
                        limit :fixLimit];
        //END - #AMSFTS

        //REFERENCE                  
        lAccount = [SELECT Airline_Code__c,A_Code__c,
                    CASS_Number__c,Check_Digit__c,GDS__c,
                    Company_Type__c,C_Code__c,IATACode__c,Id,Location_Type__c,
                    Last_Inspection_Date__c,Last_synchronization__c,
                    License_Number__c,Location_Category__c,Location_Class__c,Name,GDP_Opt_In__c,
                    N_Code__c,Organization_Last_Change_Date__c,
                    Original_Approval_DAte__c,VAT_Number_2__c,OwnerId,
                    Phone_Number__c, Phone, Fax, Primary_address__c,
                    RecordTypeId,RecordType.Name,
                    STD_Code__c,VAT_Number__c,
                    TradeName__c,Unique_ID__c,Verification_Date__c,IATA_ISO_Country__c, IATA_ISO_Country__r.Name,
                    Short_Name__c,Abbreviated_name__c,Sector__c,AIMS_ID__c,BSP_CASS_Code__c FROM Account WHERE Id in :setAccountKeys]; 

        //REFERENCE        
        //Sprint 7: removed "Contact__c,User__c, User__r.Name"
        lPerson = [SELECT Email__c,First_Name__c,Id,
                        Language_of_correspondence__c,
                        Lastname__c,Last_Case_Assigned_Date_Time__c,
                        Logged_on__c,Log_on_picklist__c,Maximum_cases_at_one_time__c,Maximum_case_workload__c,
                        Name,Next_case_request_date_time__c,Phone__c,Region__c,Request_next_case__c 
                        FROM AMS_Person__c WHERE Id in :setPersonKeys]; //Contact__c,Contact__r.Name,
        
        lContact = [SELECT AccountId,AMS_isManager__c,AMS_isTicketingAgent__c,AMS_Position__c,
                            AMS_Valid__c,FirstName,Id,LastName,Name,Person__c,Status__c,Title,Email,Preferred_Language__c  
                            FROM Contact
                             WHERE Id in :setContactKeys];

        //R3.1 - For inspections/appointments/Endorsments "Org1Adate" field (<original_approval_date>string</original_approval_date>)
        lAgAppChangeCode = [SELECT Account__c,Change_Code__c,CreatedDate,Id,Created_Date_To_Show__c FROM Agency_Applied_Change_code__c 
                                where Change_Code__c = 'FIN'
                                and Account__c in :setAgencyKeys
                                order by Account__c,CreatedDate desc];

        for(Agency_Applied_Change_code__c agAppChangeCode : lAgAppChangeCode){
            if(!mAg_VS_AgChangeCodeFIN.containsKey(agAppChangeCode.Account__c)){
                mAg_VS_AgChangeCodeFIN.put(agAppChangeCode.Account__c,agAppChangeCode);
            }
        }
        //R3.1 - END                         
         
        lAgAppChangeCodeDEF = [SELECT Account__c,Change_Code__c,CreatedDate,Id,Created_Date_To_Show__c FROM Agency_Applied_Change_code__c 
                                where Change_Code__c = 'DEF'
                                and Account__c in :setAgencyKeys
                                order by Account__c,CreatedDate desc];

        for(Agency_Applied_Change_code__c agAppChangeCode : lAgAppChangeCodeDEF){
            if(!mAg_VS_AgChangeCodeDEF.containsKey(agAppChangeCode.Account__c)){
                mAg_VS_AgChangeCodeDEF.put(agAppChangeCode.Account__c,agAppChangeCode);
            }
        }

        //MAIN
        lFieldsTranslation = [SELECT Address__c,Agency_Hierarchy__c,Account__c,AMSAirport__c,AMSEmployee__c,AMSOwner__c,
                                    AMSPerson__c,Contact__c,Field_name__c,IATA_ISO_Country__c,
                                    IATA_ISO_State__c,Id,Language__c,Name,Translation__c,User__c 
                                    FROM AMS_Fields_Translation__c 
                                    where (Account__c in :setAgencyKeys
                                        or Address__c in :setAddressKeys
                                        or Agency_Hierarchy__c in :setHierarchyKeys
                                        or AMSAirport__c in :setAirportKeys
                                        or AMSEmployee__c in :setEmployeeKeys
                                        or AMSOwner__c in :setOwnershipKeys
                                        or AMSPerson__c in :setPersonKeys
                                        or Contact__c in :setContactKeys
                                        or IATA_ISO_Country__c in :setAddressCountryKeys
                                        or IATA_ISO_State__c in :setAddressStateKeys
                                        or User__c in :setUserKeys)];
        //END - #AMSFTS

        //Field_name__c
        
        //REFERENCE                        
        lRecordType = [SELECT Id,Name FROM RecordType];
       
        msObject.putAll(lAddresses);
        msObject.putAll(lCountry);
        msObject.putAll(lState);
        msObject.putAll(lOwner);
        msObject.putAll(lAgHierarchy);
        msObject.putAll(lAgRelationship);
        msObject.putAll(lAgRelationshipHierarchy);
        msObject.putAll(lAccount); 
        msObject.putAll(lPerson);
        msObject.putAll(lRecordType);
        msObject.putAll(agency);
        msObject.putAll(lContact);
        //msObject.putAll(lUser);
        
        
        //Header Values
        Map<String, String> mHeaderValues = new Map<String, String>();
        Date dToday = Date.today();
        Datetime dtToday = Datetime.now(); // Returns the current Datetime based on a GMT calendar.
        
        
        mHeaderValues.put('copymsg', AMS_SAP_Settings__c.getOrgDefaults().Copy_Right_Message__c);
        mHeaderValues.put('version', 'v1');
        mHeaderValues.put('rec_id', 'H');
        mHeaderValues.put('priority', 'High');
        mHeaderValues.put('prodsys', 'AMS');
        mHeaderValues.put('proddate', dtToday.format('yyyyMMdd'));
        mHeaderValues.put('prodtime', dtToday.format('HHmmss'));

        //Begin of XML tags
        Dom.Document doc = new Dom.Document();
    
        Dom.Xmlnode rootNode = doc.createRootElement('agencies_message', null, null);

        Dom.Xmlnode ResponseHeaderNode = rootNode.addChildElement('response_header', null, null);
        
        Dom.Xmlnode PreviousIdNode = ResponseHeaderNode.addChildElement('previous_id', null, null);
        PreviousIdNode.addTextNode('');
        Dom.Xmlnode GroupIDNode = ResponseHeaderNode.addChildElement('group_id', null, null);
        GroupIDNode.addTextNode(r[0]);
        Dom.Xmlnode ChunkSizeNode = ResponseHeaderNode.addChildElement('chunk_size', null, null);
        ChunkSizeNode.addTextNode(r[1]);
        Dom.Xmlnode ChunkKeyNode = ResponseHeaderNode.addChildElement('chunk_key', null, null);
        ChunkKeyNode.addTextNode(r[2]);
        Dom.Xmlnode ChunkTotalNode = ResponseHeaderNode.addChildElement('chunk_total', null, null);
        ChunkTotalNode.addTextNode(r[3]);
        Dom.Xmlnode ErrorFlagNode = ResponseHeaderNode.addChildElement('error_flag', null, null);
        ErrorFlagNode.addTextNode('FALSE');


        Dom.Xmlnode AMS_AgenciesNode = rootNode.addChildElement('agency_data', null, null);

        ////Header Section
        getHeaderNode(AMS_AgenciesNode, mHeaderValues);
        
        
        //Begin - #AMSFTS
        //Map<String, Map<String, List<AMS_Agency__c>>> bsp_dpc_ag = new Map<String, Map<String, List<AMS_Agency__c>>>();
        Map<String, Map<String, List<Account>>> bsp_dpc_ag = new Map<String, Map<String, List<Account>>>();
        Map<String, Map<String, List<Account>>> bsp_dpc_ag_Ordered = new Map<String, Map<String, List<Account>>>();
        //END - #AMSFTS

        //String sPasCargo = agency[0].Sector__c == Null?'':agency[0].Sector__c;

        //List<AggregateResult> agBspDpc = new List<AggregateResult>();
        //if(sPasCargo.equalsIgnoreCase('Travel Agent') ){
        //    agBspDpc = [SELECT id Account__c,IATA_ISO_Country__r.name,
        //                                    IATA_ISO_Country__r.AMS_Settlement_System__r.name bsp,
        //                                    IATA_ISO_Country__r.AMS_Settlement_System__r.DPC_System__c dpc
        //                                FROM Account where id in :setAgencyKeys 
        //                                group by id, IATA_ISO_Country__r.name,
        //                                    IATA_ISO_Country__r.AMS_Settlement_System__r.name,
        //                                    IATA_ISO_Country__r.AMS_Settlement_System__r.DPC_System__c];
        //}else if(sPasCargo.equalsIgnoreCase('Cargo Agent') ){
        //    agBspDpc = [SELECT id Account__c, IATA_ISO_Country__r.name,
        //                                    IATA_ISO_Country__r.AMS_Settlement_System_CASS__r.name bsp,
        //                                    IATA_ISO_Country__r.AMS_Settlement_System_CASS__r.DPC_System__c dpc
        //                                    FROM Account where id in :setAgencyKeys 
        //                                    group by id, IATA_ISO_Country__r.name,
        //                                    IATA_ISO_Country__r.AMS_Settlement_System_CASS__r.name,
        //                                    IATA_ISO_Country__r.AMS_Settlement_System_CASS__r.DPC_System__c];
        //}
        //END - #AMSFTS

        SET<Id> setAgencyPaxKeys = new SET<Id>();
        SET<Id> setAgencyCargoKeys = new SET<Id>();
        for (Account ag : agency) {
            if( ag.Sector__c.equalsIgnoreCase('Travel Agent') ){
                setAgencyPaxKeys.add(ag.Id);
            }else if(ag.Sector__c.equalsIgnoreCase('Cargo Agent') ){
                setAgencyCargoKeys.add(ag.Id);
            }
        }

        List<AggregateResult> agBspDpc = new List<AggregateResult>();
        List<AggregateResult> agBspDpcPax = new List<AggregateResult>();
        List<AggregateResult> agBspDpcCargo = new List<AggregateResult>();
        
        agBspDpcPax = [SELECT id Account__c,IATA_ISO_Country__r.name,
                                            IATA_ISO_Country__r.AMS_Settlement_System__r.name bsp,
                                            IATA_ISO_Country__r.AMS_Settlement_System__r.DPC_System__c dpc
                                        FROM Account where id in :setAgencyPaxKeys 
                                        group by id, IATA_ISO_Country__r.name,
                                            IATA_ISO_Country__r.AMS_Settlement_System__r.name,
                                            IATA_ISO_Country__r.AMS_Settlement_System__r.DPC_System__c];
        
        agBspDpcCargo = [SELECT id Account__c, IATA_ISO_Country__r.name,
                                            IATA_ISO_Country__r.AMS_Settlement_System_CASS__r.name bsp,
                                            IATA_ISO_Country__r.AMS_Settlement_System_CASS__r.DPC_System__c dpc
                                            FROM Account where id in :setAgencyCargoKeys 
                                            group by id, IATA_ISO_Country__r.name,
                                            IATA_ISO_Country__r.AMS_Settlement_System_CASS__r.name,
                                            IATA_ISO_Country__r.AMS_Settlement_System_CASS__r.DPC_System__c];


        agBspDpc.addAll(agBspDpcPax);
        agBspDpc.addAll(agBspDpcCargo);

       
        String auxBSP = '';
        String auxDPC = '';
        //Begin - #AMSFTS
        //List<AMS_Agency__c> lAuxAgBspDpc = new List<AMS_Agency__c>();
        //Map<Id,AMS_Agency__c> mlAuxAgBspDpc = new Map<Id,AMS_Agency__c>();
        List<Account> lAuxAgBspDpc = new List<Account>();
        Map<Id,Account> mlAuxAgBspDpc = new Map<Id,Account>();
        //END - #AMSFTS
        
        //Map agency Id with AMS_Settlement_System__c Info
        Map<Id,AggregateResult> lAgencyOperations = new Map<Id,AggregateResult>();
            
        for (AggregateResult agOp : agBspDpc) {
            
            //Begin - #AMSFTS
            //fill Map agency Id with AMS_Settlement_System__c
            //lAgencyOperations.put((Id)agOp.get('Agency__c'), agOp);
            //AMS_Agency__c auxAg = (AMS_Agency__c)msObject.get((Id) agOp.get('Agency__c') );
            lAgencyOperations.put((Id)agOp.get('Account__c'), agOp);
            Account auxAg = (Account)msObject.get((Id) agOp.get('Account__c') );
            //END - #AMSFTS
      
            auxBSP = agOp.get('bsp') == Null ? 'null' : (String)agOp.get('bsp');
            auxDPC = agOp.get('dpc') == Null ? 'null' : (String)agOp.get('dpc');
      
            //add all agencies to compare later, because not all agencies have relation with AMS_Agency_Operations__c
            if(!mlAuxAgBspDpc.containsKey(auxAg.Id)){
                lAuxAgBspDpc.add(auxAg);
                mlAuxAgBspDpc.put(auxAg.Id,auxAg);
            }
           
            //Check BSP
            if(bsp_dpc_ag.containsKey(auxBSP)){
                Map<String, List<Account>> mAuxAgDPC = bsp_dpc_ag.get(auxBSP); 
                
                //Check DPC
                if(mAuxAgDPC.containsKey(auxDPC)){
                    List<Account> l = mAuxAgDPC.get(auxDPC);
                    l.add(auxAg);
                    mAuxAgDPC.remove(auxDPC);
                    mAuxAgDPC.put(auxDPC,l);
                }else{
                    List<Account> l = new List<Account>();
                    l.add(auxAg);
                    mAuxAgDPC.put(auxDPC,l);
                }
                
                bsp_dpc_ag.remove(auxBSP);
                bsp_dpc_ag.put(auxBSP,mAuxAgDPC);
                
            }else{
                Map<String, List<Account>> mAuxAgDPC = new Map<String, List<Account>>();
                List<Account> l = new List<Account>();
                l.add(auxAg);
                mAuxAgDPC.put(auxDPC,l);
                bsp_dpc_ag.put(auxBSP,mAuxAgDPC);
            }
            //END - #AMSFTS
        }
       
        //Map<Id, AMS_Agency__c> mAg = new Map<Id, AMS_Agency__c>(lAuxAgBspDpc); - #AMSFTS
        Map<Id, Account> mAg = new Map<Id, Account>(lAuxAgBspDpc);


        //add all agencies to compare later, because not all agencies have relation with AMS_Agency_Operations__c
        //for (AMS_Agency__c ag : agency) { - #AMSFTS
        for (Account ag : agency) {

            if(!mAg.containsKey(ag.Id)){
                
                AggregateResult auxAgOp = lAgencyOperations.get(ag.Id);
            
                if(auxAgOp != Null){
                    auxBSP = auxAgOp.get('bsp') == Null ? 'null' : (String)auxAgOp.get('bsp');
                    auxDPC = auxAgOp.get('dpc') == Null ? 'null' : (String)auxAgOp.get('dpc');
                }else{
                    auxBSP = 'null';
                    auxDPC = 'null';
                }
                
                //Check BSP
                if(bsp_dpc_ag.containsKey(auxBSP)){
                    //Map<String, List<AMS_Agency__c>> mAuxAgDPC = bsp_dpc_ag.get(auxBSP); - #AMSFTS
                    Map<String, List<Account>> mAuxAgDPC = bsp_dpc_ag.get(auxBSP);
                    
                    //Check DPC
                    if(mAuxAgDPC.containsKey(auxDPC)){
                        //List<AMS_Agency__c> l = mAuxAgDPC.get(auxDPC); - #AMSFTS
                        List<Account> l = mAuxAgDPC.get(auxDPC);
                        l.add(ag);
                        mAuxAgDPC.remove(auxDPC);
                        mAuxAgDPC.put(auxDPC,l);
                    }else{
                        //List<AMS_Agency__c> l = new List<AMS_Agency__c>(); - #AMSFTS
                        List<Account> l = new List<Account>();
                        l.add(ag);
                        mAuxAgDPC.put(auxDPC,l);
                    }
                    
                    bsp_dpc_ag.remove(auxBSP);
                    bsp_dpc_ag.put(auxBSP,mAuxAgDPC);
                    
                }else{
                    //Begin - #AMSFTS
                    //Map<String, List<AMS_Agency__c>> mAuxAgDPC = new Map<String, List<AMS_Agency__c>>();
                    //List<AMS_Agency__c> l = new List<AMS_Agency__c>();
                    Map<String, List<Account>> mAuxAgDPC = new Map<String, List<Account>>();
                    List<Account> l = new List<Account>();
                    //END - #AMSFTS
                    l.add(ag);
                    mAuxAgDPC.put(auxDPC,l);
                    bsp_dpc_ag.put(auxBSP,mAuxAgDPC);
                }
            }
        }

        //Map<String, Map<String, List<Account>>> bsp_dpc_ag_Ordered = new Map<String, Map<String, List<Account>>>();

        

        

        //Order the agencies in order to return on the same order they were asked!
        
        for(Integer i=0;i<orderedAgencyIds.size();i++){

            for(String sBSP : bsp_dpc_ag.keySet()){
                Map<String, List<Account>> mAuxAgDPC = bsp_dpc_ag.get(sBSP);

                for(String sDPC : mAuxAgDPC.keySet()){
                    List<Account> l = mAuxAgDPC.get(sDPC);

                    for(Account auxL: l){
                        if(String.valueOf(auxL.Id).equalsIgnoreCase(orderedAgencyIds[i])){
                            //lAgOrdered.add(mapAgToOrder.get(orderedAgencyIds[i]) );

                            List<Account> aux1 = new List<Account>();
                            aux1.add(auxL);
                            Map<String, List<Account>> aux2 = new Map<String, List<Account>>();
                            aux2.put(sDPC, aux1);
                            bsp_dpc_ag_Ordered.put(sBSP, aux2);
                        }
                    }

                }

            }

            
        } 

        System.debug('bsp_dpc_ag: ' + bsp_dpc_ag);
        System.debug('bsp_dpc_ag_Ordered: ' + bsp_dpc_ag_Ordered);



        //for(String sBSP : bsp_dpc_ag.keySet()){
        for(String sBSP : bsp_dpc_ag_Ordered.keySet()){            
            //Map<String, List<AMS_Agency__c>> mAuxAgDPC = bsp_dpc_ag.get(sBSP); - #AMSFTS
            Map<String, List<Account>> mAuxAgDPC = bsp_dpc_ag.get(sBSP);

            for(String sDPC : mAuxAgDPC.keySet()){
                //List<AMS_Agency__c> l = mAuxAgDPC.get(sDPC); - #AMSFTS
                List<Account> l = mAuxAgDPC.get(sDPC);

                //get 1st agency, since all agencies must be from the same country the 1st will work!
                //AMS_Agency__c agForCtry = l[0]; - #AMSFTS
                Account agForCtry = l[0];
                String sPasCargo = l[0].Sector__c == Null?'':l[0].Sector__c;

                //get Country related to the agency 
                IATA_ISO_Country__c ctry;
                //ctry = (IATA_ISO_Country__c)msObject.get(agForCtry.Country__c); - #AMSFTS
                ctry = (IATA_ISO_Country__c)msObject.get(agForCtry.IATA_ISO_Country__c);

                //BEGIN Country tag
                Dom.Xmlnode countryNode = AMS_AgenciesNode.addChildElement('country', null, null);


                getElementNode(countryNode, 'name', ctry.Name);
                getElementNode(countryNode, 'iso_code', ctry.ISO_Code__c);

                //if(sPasCargo.equalsIgnoreCase('PASSENGER') ){ - #AMSFTS
                if(sPasCargo.equalsIgnoreCase('Travel Agent') ){
                    getElementNode(countryNode, 'bsp', sBSP);
                    getElementNode(countryNode, 'cass', Null);
                }else if(sPasCargo.equalsIgnoreCase('Cargo Agent') ){
                    getElementNode(countryNode, 'bsp', Null);
                    getElementNode(countryNode, 'cass', sBSP);
                }
                
                getElementNode(countryNode, 'dpc_system', sDPC);


                getElementNode(countryNode, 'hub', ctry.IATA_Regional_Office__c);

                //TODO - Check what's necessary here!
                Dom.Xmlnode filtersNode = countryNode.addChildElement('filters', null, null);
                getElementNode(filtersNode, 'name', Null);
                getElementNode(filtersNode, 'value', Null);


                //BEGIN Agencies
                Dom.Xmlnode agenciesNode = countryNode.addChildElement('agencies', null, null);
                //try{
               

                //Order the agencies in order to return on the same order they were asked!
                List<Account> lAgOrdered = new List<Account>();
                Map<Id, Account> mapAgToOrder = new Map<Id, Account>(l);
                for(Integer i=0;i<orderedAgencyIds.size();i++){
                    if(mapAgToOrder.containsKey(orderedAgencyIds[i])){
                        lAgOrdered.add(mapAgToOrder.get(orderedAgencyIds[i]) );
                    }
                } 

                
                //for (AMS_Agency__c ag : l) { - #AMSFTS
                //for (Account ag : l) {
                for(Integer j=0;j<lAgOrdered.size();j++){

                    Account ag = lAgOrdered[j];

                    Dom.Xmlnode agencyNode = agenciesNode.addChildElement('agency', null, null);

                    //BEGIN - #AMSFTS
                    getAgencyNode(agencyNode, ag, True, False);

                    
                    Dom.Xmlnode addressNode = agencyNode.addChildElement('addresses', null, null);
                    
                    AMS_Address__c billingAdd = new AMS_Address__c();
                    

                    billingAdd.Account__c = ag.Id;
                    billingAdd.Address_Type__c = 'Billing;Primary';

                    String[] billingStreet;

                    billingStreet = AMS_Utils.splitAccName(ag.BillingStreet == null?'':ag.BillingStreet);
                    
                    billingAdd.Address_1__c = billingStreet[0];
                    billingAdd.Address_2__c = billingStreet[1];
                    billingAdd.Address_3__c = billingStreet[2];

                    billingAdd.City__c = ag.BillingCity;
                    billingAdd.State__c = ag.Iso_State__c;
                    billingAdd.Country__c = ag.IATA_ISO_Country__c;
                    billingAdd.AMS_ZipCode__c = ag.BillingPostalCode;

                    List<String> lPhone = splitPhone(ag.Phone, ag.IATA_ISO_Country__r.Name);
                    if(lPhone != null){
                        billingAdd.Telephone_Int__c = lPhone[0];
                        billingAdd.Telephone_STD__c = lPhone[1];
                        billingAdd.Telephone__c     = lPhone[2];
                    }
                    
                    List<String> lFax = splitPhone(ag.Fax, ag.IATA_ISO_Country__r.Name);
                    if(lFax != null){
                        billingAdd.Fax_Int__c = lFax[0];
                        billingAdd.Fax_STD__c = lFax[1];
                        billingAdd.Fax__c     = lFax[2];
                    }

                    System.debug(loggingLevel.Debug, '____ [cls AMS_XML_Generator - getAgencyDetail] billingAdd - ' + billingAdd);
                    lAddresses.add(billingAdd);

                    //R3.1 - Fix to include abbreviated address if not empty
                    if(ag.Abbreviated_address__c != null){
                        AMS_Address__c abbreviatedAdd = new AMS_Address__c();
                        abbreviatedAdd = billingAdd.clone(false, true);

                        String[] abbreviatedStreet;
                        abbreviatedStreet = AMS_Utils.splitAccName(ag.Abbreviated_address__c == null ? '' : ag.Abbreviated_address__c);

                        abbreviatedAdd.Address_Type__c = 'Abbreviated';

                        abbreviatedAdd.Address_1__c = abbreviatedStreet[0];
                        abbreviatedAdd.Address_2__c = abbreviatedStreet[1];
                        abbreviatedAdd.Address_3__c = abbreviatedStreet[2];

                        lAddresses.add(abbreviatedAdd);
                    }

                    if(!AMS_Utils.isAddressEmpty(ag, 'Shipping')){
                        AMS_Address__c shippingAdd = new AMS_Address__c();
                        shippingAdd.Account__c = ag.Id;
                        shippingAdd.Address_Type__c = 'Shipping';

                        String[] shippingStreet = AMS_Utils.splitAccName(ag.ShippingStreet == null ? '' : ag.ShippingStreet);
                        shippingAdd.Address_1__c = shippingStreet[0];
                        shippingAdd.Address_2__c = shippingStreet[1];
                        shippingAdd.Address_3__c = shippingStreet[2];

                        shippingAdd.City__c = ag.ShippingCity;
                        
                        //shippingAdd.State__c = ag.ShippingState == null ? null : AMS_Utils.iataIsoStates.get(ag.ShippingState.trim().toLowerCase()).Id;
                        if(ag.ShippingState != null ){
                            if(AMS_Utils.iataIsoStates.get(ag.ShippingState.trim().toLowerCase()) != null){
                                shippingAdd.State__c = AMS_Utils.iataIsoStates.get(ag.ShippingState.trim().toLowerCase()).Id;
                            }else{
                                shippingAdd.State__c = null;
                            }                            
                        }
                            
                        //shippingAdd.Country__c = ag.ShippingCountry == null ? null : AMS_Utils.iataIsoCountries.get(ag.ShippingCountry.trim().toLowerCase()).Id;
                        if(ag.ShippingCountry != null ){
                            if(AMS_Utils.iataIsoCountries.get(ag.ShippingCountry.trim().toLowerCase()) != null){
                                shippingAdd.Country__c = AMS_Utils.iataIsoCountries.get(ag.ShippingCountry.trim().toLowerCase()).Id;
                            }else{
                                shippingAdd.Country__c = null;
                            }                            
                        }

                        shippingAdd.AMS_ZipCode__c = ag.ShippingPostalCode;
                        
                        System.debug(loggingLevel.Debug, '____ [cls AMS_XML_Generator - getAgencyDetail] shippingAdd - ' + shippingAdd);
                        lAddresses.add(shippingAdd);
                    }
                    
                    if(lAddresses.size() > 0){
                        for (AMS_Address__c add : lAddresses) {
                            //if(add.Agency__c == ag.Id){ - #AMSFTS
                            if(add.Account__c == ag.Id){

                                if(add.Id != null){
                                    //removes ignored address types from the string
                                    for(String addressType : lIgnoredAddressTypes){
                                        add.Address_Type__c = add.Address_Type__c.replace(addressType+';', '');
                                        add.Address_Type__c = add.Address_Type__c.replace(';'+addressType, '');
                                    }
                                }
                                //if address is a valid addres, add new node.
                                if(String.isNotEmpty(add.Address_Type__c)) getObjectData(addressNode, 'AMS_Address__c', add );
                            }
                            
                
                        }
                    //}else{
                        //addressNode.addTextNode('Missing');
                    }
                    

                    Dom.Xmlnode accountRoleNode = agencyNode.addChildElement('account_roles', null, null);
                    if(lOwnership.size() > 0){
                        //for (AMS_Agency_Ownership__c own : lOwnership) { - #AMSFTS
                        for (AMS_Account_Role__c own : lOwnership) {    
                            //if(own.Agency__c == ag.Id){ - #AMSFTS
                            if(own.Account__c == ag.Id){
                                getObjectData(accountRoleNode, 'AMS_Account_Role__c', own );
                            }
                        }
                    //}else{
                        //ownershipNode.addTextNode('Missing');
                    }
                    if(lEmployee.size() > 0){
                        
                        List<AMS_Account_Role__c> lEmpXML = mAg_VS_Employees.get(ag.Id);
                        
                        if(lEmpXML == Null){    //to avoid Null value
                            lEmpXML = new List<AMS_Account_Role__c>();
                        }
                        
                        for (AMS_Account_Role__c emp : lEmpXML) {
                                getObjectData(accountRoleNode, 'AMS_Account_Role__c', emp );
                        }
                    //}else{
                        //employeesNode.addTextNode('Missing');
                    }

                    //End - #AMSFTS
        
                    Boolean bHaveInspections = False;
                    Dom.Xmlnode inspectionNode = agencyNode.addChildElement('endorsements', null, null);

                    Agency_Applied_Change_code__c auxAgAppChangeCode = mAg_VS_AgChangeCode.get(ag.Id);

                    
                    //Inspection data not to send anymore! Decision done on R3.1, in exchange we gather information from the “account” data and “Applied Change Code”
                    //if(lInspection.size() > 0){
                    //    for (AMS_Inspection__c insp : lInspection) {
                    //        //if(insp.Agency__c == ag.Id){ - #AMSFTS    
                    //        if(insp.Account__c == ag.Id){                
                    //            bHaveInspections = True;

                    //            //Set the "Date_Organisation_Status_attained" value to the created date of the active change code
                    //            if(auxAgAppChangeCode != null){
                    //                insp.Date_Organisation_Status_attained__c = auxAgAppChangeCode.CreatedDate.date();
                    //            }

                    //            getObjectData(inspectionNode, 'AMS_Inspection__c', insp );
                    //        }
                    //    }
                    //}
                 

                    //R3.1 - If we don't have inspections we still need to send the agency status 
                    if(!bHaveInspections){
                        Dom.Xmlnode agEndorsementNode = inspectionNode.addChildElement('endorsement', null, null);
                        getElementNode(agEndorsementNode, 'accreditation_endorsement_status_code',  AMS_Utils.getIATANumericStatus(ag.Status__c) );

                        //Set the "Date_Organisation_Status_attained" value to the created date of the active change code
                        if(auxAgAppChangeCode != null){
                            Datetime dtOrgStatusAttained = Datetime.newInstance(auxAgAppChangeCode.Created_Date_To_Show__c.year(), auxAgAppChangeCode.Created_Date_To_Show__c.month(),auxAgAppChangeCode.Created_Date_To_Show__c.day());
                            getElementNode(agEndorsementNode, 'date_organisation_status_attained', dtOrgStatusAttained == Null ? Null : String.valueOf(dtOrgStatusAttained.format('yyyyMMdd')));
                        }

                        Datetime dtLast_Inspection_Date = ag.Last_Inspection_Date__c == Null ? Null : Datetime.newInstance(ag.Last_Inspection_Date__c.year(), ag.Last_Inspection_Date__c.month(),ag.Last_Inspection_Date__c.day());
                        getElementNode(agEndorsementNode, 'last_inspection_date', dtLast_Inspection_Date == Null ? Null : String.valueOf(dtLast_Inspection_Date.format('yyyyMMdd')));
                

                        //Set the "original_approval_date" value to the created date of the "FIN" change code
                        Agency_Applied_Change_code__c auxAgAppChangeCodeFIN = mAg_VS_AgChangeCodeFIN.get(ag.Id);
                        
                        if(ag.Accreditation_date__c != null){
                            Datetime dtAccreditation_date = Datetime.newInstance(ag.Accreditation_date__c.year(), ag.Accreditation_date__c.month(),ag.Accreditation_date__c.day());
                            getElementNode(agEndorsementNode, 'original_approval_date', dtAccreditation_date == Null ? Null : String.valueOf(dtAccreditation_date.format('yyyyMMdd')));
                        }else if(ag.Original_Approval_DAte__c != null){
                            Datetime dtOriginal_Approval_DAte = ag.Original_Approval_DAte__c == Null ? Null : Datetime.newInstance(ag.Original_Approval_DAte__c.year(), ag.Original_Approval_DAte__c.month(),ag.Original_Approval_DAte__c.day());
                            getElementNode(agEndorsementNode, 'original_approval_date', dtOriginal_Approval_DAte == Null ? Null : String.valueOf(dtOriginal_Approval_DAte.format('yyyyMMdd')));
                        }else if(auxAgAppChangeCodeFIN != null){
                            Datetime dtOriginal_Approval_DAte = Datetime.newInstance(auxAgAppChangeCodeFIN.Created_Date_To_Show__c.year(), auxAgAppChangeCodeFIN.Created_Date_To_Show__c.month(),auxAgAppChangeCodeFIN.Created_Date_To_Show__c.day());
                            getElementNode(agEndorsementNode, 'original_approval_date', dtOriginal_Approval_DAte == Null ? Null : String.valueOf(dtOriginal_Approval_DAte.format('yyyyMMdd')));
                        }else{
                            //If none of the options above is valid no value is sent!
                            getElementNode(agEndorsementNode, 'original_approval_date',  Null);
                        }
                            

                        Datetime dtOrganization_Last_Change_Date = ag.Organization_Last_Change_Date__c == Null ? Null : Datetime.newInstance(ag.Organization_Last_Change_Date__c.year(), ag.Organization_Last_Change_Date__c.month(),ag.Organization_Last_Change_Date__c.day());
                        getElementNode(agEndorsementNode, 'organization_last_change_date', dtOrganization_Last_Change_Date == Null ? Null : String.valueOf(dtOrganization_Last_Change_Date.format('yyyyMMdd')));
                    
                        //FM 24-11-2016
                        
                        //Get Record with "Default" (DEF) change code information
                        Agency_Applied_Change_code__c auxAgAppChangeCodeDEF = mAg_VS_AgChangeCodeDEF.get(ag.Id);
                        String sIATANumericStatus = AMS_Utils.getIATANumericStatus(ag.Status__c);

                        //If Terminated need to insert another Endorsement entry with the default information, but only if this exist
                        // the default status code is set to '5' - "Cash basis/no commission"
                        if((sIATANumericStatus == '0' || sIATANumericStatus == '6') && auxAgAppChangeCodeDEF != null){

                            Dom.Xmlnode agEndorsementNodeDEF = inspectionNode.addChildElement('endorsement', null, null);
                            getElementNode(agEndorsementNodeDEF, 'accreditation_endorsement_status_code',  '5' );

                            //Set the "Date_Organisation_Status_attained" value to the created date of the "DEF" change code
                            Datetime dtOrgStatusAttained = Datetime.newInstance(auxAgAppChangeCodeDEF.Created_Date_To_Show__c.year(), auxAgAppChangeCodeDEF.Created_Date_To_Show__c.month(),auxAgAppChangeCodeDEF.Created_Date_To_Show__c.day());
                            getElementNode(agEndorsementNodeDEF, 'date_organisation_status_attained', dtOrgStatusAttained == Null ? Null : String.valueOf(dtOrgStatusAttained.format('yyyyMMdd')));
                            
                            getElementNode(agEndorsementNodeDEF, 'last_inspection_date', dtLast_Inspection_Date == Null ? Null : String.valueOf(dtLast_Inspection_Date.format('yyyyMMdd')));
                    
                            if(ag.Accreditation_date__c != null){
                                Datetime dtAccreditation_date = Datetime.newInstance(ag.Accreditation_date__c.year(), ag.Accreditation_date__c.month(),ag.Accreditation_date__c.day());
                                getElementNode(agEndorsementNodeDEF, 'original_approval_date', dtAccreditation_date == Null ? Null : String.valueOf(dtAccreditation_date.format('yyyyMMdd')));
                            }else if(ag.Original_Approval_DAte__c != null){
                                Datetime dtOriginal_Approval_DAte = ag.Original_Approval_DAte__c == Null ? Null : Datetime.newInstance(ag.Original_Approval_DAte__c.year(), ag.Original_Approval_DAte__c.month(),ag.Original_Approval_DAte__c.day());
                                getElementNode(agEndorsementNodeDEF, 'original_approval_date', dtOriginal_Approval_DAte == Null ? Null : String.valueOf(dtOriginal_Approval_DAte.format('yyyyMMdd')));
                            }else if(auxAgAppChangeCodeFIN != null){
                                Datetime dtOriginal_Approval_DAte = Datetime.newInstance(auxAgAppChangeCodeFIN.Created_Date_To_Show__c.year(), auxAgAppChangeCodeFIN.Created_Date_To_Show__c.month(),auxAgAppChangeCodeFIN.Created_Date_To_Show__c.day());
                                getElementNode(agEndorsementNodeDEF, 'original_approval_date', dtOriginal_Approval_DAte == Null ? Null : String.valueOf(dtOriginal_Approval_DAte.format('yyyyMMdd')));
                            }else{
                                //If none of the options above is valid no value is sent!
                                getElementNode(agEndorsementNodeDEF, 'original_approval_date',  Null);
                            }

                            getElementNode(agEndorsementNodeDEF, 'organization_last_change_date', dtOrganization_Last_Change_Date == Null ? Null : String.valueOf(dtOrganization_Last_Change_Date.format('yyyyMMdd')));
                    
                        }

                    }
                    
                   
                    Boolean bHier = False;
                    Boolean bHierChild = False;
                    Dom.Xmlnode agRelationshipsNode = agencyNode.addChildElement('agency_relationships', null, null);
                    if(lAgRelationship.size() > 0){
                        for (AMS_Agencies_relationhip__c rel : lAgRelationship) {
                            //if(rel.Parent_agency__c == ag.Id || rel.Child_Agency__c == ag.Id){
                            //if(rel.Parent_agency__c == ag.Id ){ - #AMSFTS    
                            if(rel.Parent_Account__c == ag.Id ){
                                bHier = True;
                                //getObjectData(agRelationshipsNode, 'AMS_Agencies_relationhip__c', rel );
                            }
                            if(rel.Child_Account__c == ag.Id ){
                                bHierChild = True;
                            }
                        }
                    //}else{
                    //    agRelationshipsNode.addTextNode('Missing');
                    }
                
                    if(!bHier || bHierChild){
                        //AMS_Agency__c parentAg = (AMS_Agency__c)msObject.get(mAg_VS_ParentAg.get(ag.Id)); - #AMSFTS    
                        Account parentAg = (Account)msObject.get(mAg_VS_ParentAg.get(ag.Id));
                        
                        if(parentAg != Null){
                            Dom.Xmlnode agRelationshipNode = agRelationshipsNode.addChildElement('agencies_relationship', null, null);
                            //agRelationshipHO_FlagNode.addTextNode('False');
                            Dom.Xmlnode auxAgencyNode = agRelationshipNode.addChildElement('parent_agency', null, null);
                            getAgencyNode(auxAgencyNode, parentAg,False, True);
                        }
                    }
                   
                    if( (!bHier && !bHierChild) || (bHier && !bHierChild)){
                        //For HO agencies - put the HO own data on the relationship 
                        if(AMS_Utils.LocationTypeAllHOTypes.contains(ag.Location_Type__c) ){
                            Dom.Xmlnode agRelationshipNode = agRelationshipsNode.addChildElement('agencies_relationship', null, null);
                            Dom.Xmlnode auxAgencyNode = agRelationshipNode.addChildElement('parent_agency', null, null);
                            getAgencyNode(auxAgencyNode, ag,False, True);
                        }
                    }

                    
                    
                    Dom.Xmlnode airportsNode = agencyNode.addChildElement('airports', null, null);
                    if(lAirport.size() > 0){
                        for (AMS_Airport__c airp : lAirport) {
                            Id idAg = mAgAirport_VS_Airport.get(airp.Id);
                            if(idAg == ag.Id){
                                getObjectData(airportsNode, 'AMS_Airport__c', airp );
                            }
                        }
                    //}else{
                    //    airportsNode.addTextNode('Missing');
                    }
        
                    Dom.Xmlnode profileNode = agencyNode.addChildElement('profiles', null, null);
                    if(lAgProfile.size() > 0){
                        for (AMS_Agency_Profile__c prof : lAgProfile) {
                            //if(prof.Agency__c == ag.Id){ - #AMSFTS 
                            if(prof.Account__c == ag.Id){
                                getObjectData(profileNode, 'AMS_Agency_Profile__c', prof );
                            }
                        }
                    //}else{
                 //       profileNode.addTextNode('Missing');
                    }
                    
                }
                
            }
            
        }
        

        //Footer Section
        getFooterNode(AMS_AgenciesNode, agency.size());

        //DataTrace Section
        getDataTraceNode(AMS_AgenciesNode, r);

        system.debug('--------- doc: ' + doc.toXmlString());     
        system.debug(sDebug);
        Integer fimCPU = Limits.getCpuTime();
        Integer fimCPUx = Limits.getLimitCpuTime();
        
      
        
        return doc.toXmlString();   
    }




    public void getHeaderNode(Dom.Xmlnode rootNode, Map<String, String> mValues){
        
        //Header Section
        Dom.Xmlnode headerNode = rootNode.addChildElement('header', null, null);

        getElementNode(headerNode, 'copy_msg', mValues.get('copymsg'));
        getElementNode(headerNode, 'version', mValues.get('version'));
        getElementNode(headerNode, 'rec_id', mValues.get('rec_id'));
        getElementNode(headerNode, 'priority', mValues.get('priority'));
        getElementNode(headerNode, 'prod_sys', mValues.get('prodsys'));
        getElementNode(headerNode, 'prod_date', mValues.get('proddate'));
        getElementNode(headerNode, 'prod_time', mValues.get('prodtime'));

    }

    public void getFooterNode(Dom.Xmlnode rootNode, Integer agencyCount){
        
        //Footer Section
        Dom.Xmlnode headerNode = rootNode.addChildElement('footer', null, null);

        getElementNode(headerNode, 'trailer', String.valueOf(agencyCount));

    }

    public void getDataTraceNode(Dom.Xmlnode rootNode, String[] r){
        
        //data_trace Section
        Dom.Xmlnode dataTraceNode = rootNode.addChildElement('data_trace', Null, Null);
        Dom.Xmlnode tracingNode = dataTraceNode.addChildElement('tracing', Null, Null);

        getElementNode(tracingNode, 'unique_id', '');
        getElementNode(tracingNode, 'step_text', '');
        getElementNode(tracingNode, 'time_stamp', '');

    }

    //public void getAgencyNode(Dom.Xmlnode agencyNode, AMS_Agency__c agency, Boolean lookupParent, Boolean redux){ - #AMSFTS
    public void getAgencyNode(Dom.Xmlnode agencyNode, Account agency, Boolean lookupParent, Boolean redux){

       
        Account parentAg;

        if(lookupParent){
            parentAg = (Account)msObject.get(mAg_VS_ParentAg.get(agency.Id));
            if(parentAg == Null){
                parentAg = new Account();
            }
        }else{
            parentAg = new Account();
        }
        //End - #AMSFTS
     
        //get "Lang" from Person object
        AMS_Person__c oPerson;
        if(mAg_VS_Person.containsKey(agency.Id)){
            oPerson = (AMS_Person__c) msObject.get(mAg_VS_Person.get(agency.Id));
        }else{
            oPerson = new AMS_Person__c();
            oPerson.Language_of_correspondence__c = '';
        }

        if(mAg_VS_Contact.containsKey(agency.Id)){
            Contact oContact = (Contact) msObject.get(mAg_VS_Contact.get(agency.Id));

            if(oPerson.Language_of_correspondence__c == '' && oContact.Preferred_Language__c != null){
                if( oContact.Preferred_Language__c.equalsIgnoreCase('English') ){
                    oPerson.Language_of_correspondence__c = 'EN';
                }
                if( oContact.Preferred_Language__c.equalsIgnoreCase('French') ){
                    oPerson.Language_of_correspondence__c = 'FR';
                }
                if( oContact.Preferred_Language__c.equalsIgnoreCase('Spanish') ){
                    oPerson.Language_of_correspondence__c = 'SP';
                } 
            }
        }
        
        //get "Manager" and "Ticketing Agent" First and Last Names from Person object
        AMS_Person__c oEmpPerson;
        Contact oEmpContact;

        Id iQta = Null;
        Id iQmp = Null;
        String sQtal_name = '';
        String sQtaf_name = '';
        String sQmpl_name = '';
        String sQmpf_name = '';
    
        //for(AMS_Employee__c emp : lEmployee){ - #AMSFTS 
        for(AMS_Account_Role__c emp : lEmployee){    
            //if(emp.Agency__c == agency.Id){ - #AMSFTS
            if(emp.Account__c == agency.Id){

                if(emp.Person__c != null){
                    if(mEmp_VS_Person.containsKey(emp.Id)){
                        oEmpPerson = (AMS_Person__c) msObject.get(mEmp_VS_Person.get(emp.Id));
                    }else{
                        oEmpPerson = new AMS_Person__c();
                        oEmpPerson.First_Name__c = '';
                        oEmpPerson.Lastname__c = '';
                    }

                    if(emp.isManager__c){
                        iQmp = oEmpPerson.Id;
                        sQmpf_name = oEmpPerson.First_Name__c;
                        sQmpl_name = oEmpPerson.Lastname__c;
                    }
                    if(emp.isTicketingAgent__c){
                        iQta = oEmpPerson.Id;
                        sQtaf_name = oEmpPerson.First_Name__c;
                        sQtal_name = oEmpPerson.Lastname__c;
                    }
                }

                if(emp.Contact__c != null){
                    if(mEmp_VS_Contact.containsKey(emp.Id)){
                        oEmpContact = (Contact) msObject.get(mEmp_VS_Contact.get(emp.Id));
                    }else{
                        oEmpContact = new Contact();
                        oEmpContact.FirstName = '';
                        oEmpContact.LastName = '';
                    }

                    if(emp.isManager__c){
                        iQmp = oEmpContact.Id;
                        sQmpf_name = oEmpContact.FirstName;
                        sQmpl_name = oEmpContact.LastName;
                    }
                    if(emp.isTicketingAgent__c){
                        iQta = oEmpContact.Id;
                        sQtaf_name = oEmpContact.FirstName;
                        sQtal_name = oEmpContact.LastName;
                    }
                }
            }
        } 
    


        //Get Parent Agency
        //AMS_Agency__c parentAg = (AMS_Agency__c)msObject.get(mAg_VS_ParentAg.get(agency.Id));
        
        /*Agencies Section*/
        String sRec_id = Null;
        String sChangeCode = Null;

        //Get the type of agency, used for some fields in order to get different values foe each type
        String sPasCargo = Null;
        if(agency.Sector__c != Null && agency.Sector__c.equalsIgnoreCase('Travel Agent') ){
            sPasCargo = 'P';
        }else if(agency.Sector__c != Null && agency.Sector__c.equalsIgnoreCase('Cargo Agent') ){
            sPasCargo = 'C';
        }

        //Indicates if record is A=Added, C=Changed or D=Deleted.  Changes files only, blank for Masters.
        AMS_Agency_Updates__c agUpd = mAg_VS_AgUpdate.get(agency.Id);
        Agency_Applied_Change_code__c agChangeCode = mAg_VS_AgChangeCode.get(agency.Id);
        String auxChangeCode = mAg_VS_ChangeCode.get(agency.Id);

        
        //if(agChangeCode != Null){
        //    sRec_id = AMS_Utils.getRecIdFromChangeCode(agChangeCode.Change_Code__c);
        //    sChangeCode = agChangeCode.Change_Code__c;
        if(auxChangeCode != Null){
            sRec_id = AMS_Utils.getRecIdFromChangeCode(auxChangeCode);
            sChangeCode = auxChangeCode;   
        }else{
            //in case of no change code!!
            sRec_id = 'C';
        }
            
        if(!redux){

            getElementNode(agencyNode, 'rec_id', sRec_id);

            //File Identifier AM-Airline Master, AC-Airline Changes, TM-Third Party Master, TC-Third Party Changes 
            getElementNode(agencyNode, 'file_id', 'AC');
        }

        //IATA Areas 
        //1 - The Americas
        //2 - Europe, Africa, Middle East
        //3 - Asia, Australia, Oceania
        //TODO - Need to check how to get the value, do I use the legacy system to check it? 
        //AIMS1 - 2
        //AIMS2 - 1
        //AIMS3 - 3
        //Webstar - 1
        //CAIMS - 3
        getElementNode(agencyNode, 'area', mAg_VS_AgArea.get(agency.Id));
        getElementNode(agencyNode, 'ams_id', agency.Id);

        if(!redux){
            //Sprint 10: removed condition for Inserting "agref" and "agxref", Now they are always inserted
            //Sprint 7: Inserting "agref" and "agxref" for Agencies with Legacy "AIMS", for now we use the legacy ID
            //if(((String)agency.Legacy_System__c).startsWithIgnoreCase('AIMS')){
                //Begin - #AMSFTS
                //getElementNode(agencyNode, 'ag_ref', agency.Legacy_External_ID__c == Null?'':agency.Legacy_External_ID__c);
                //getElementNode(agencyNode, 'ag_x_ref', parentAg.Legacy_External_ID__c == Null?'':parentAg.Legacy_External_ID__c);
            
                getElementNode(agencyNode, 'ag_ref', agency.AIMS_ID__c == Null?Null:agency.AIMS_ID__c);
                getElementNode(agencyNode, 'ag_x_ref', parentAg.AIMS_ID__c == Null?Null:parentAg.AIMS_ID__c);
                //End - #AMSFTS
                //getElementNode(agencyNode, 'ag_ref', agency.Legacy_External_ID__c);
                //getElementNode(agencyNode, 'ag_x_ref', parentAg.Legacy_External_ID__c);
            //}else{
            //    getElementNode(agencyNode, 'ag_ref', Null);
            //    getElementNode(agencyNode, 'ag_x_ref', Null);
            //}

        
            //getElementNode(agencyNode, 'ho_id',  mAg_VS_HO.get(agency.Id));
            Id auxAgHOid = (Id)mAg_VS_HO.get(agency.Id);
            system.debug('mAg_VS_HO-agency.Id: ' + agency.Id);
            system.debug('mAg_VS_HO: ' + mAg_VS_HO);
            Account auxAgHO = (Account) msObject.get(auxAgHOid);
            system.debug('auxAgHO: ' + auxAgHO);
            //getElementNode(agencyNode, 'ho_id', auxAgHO != Null ? auxAgHO.IATACode__c : Null); 

            getElementNode(agencyNode, 'ho_id', agency.Top_Parent__r.IATACode__c != null ? agency.Top_Parent__r.IATACode__c : auxAgHO != Null ? auxAgHO.IATACode__c : Null); 
        

            //Sprint 7: Inserting "LCtryCode" in the Agencies since now we are using the "C_Code" as country code
            //Begin - #AMSFTS
            getElementNode(agencyNode, 'l_country_code', agency.C_Code__c);
            //Getting the 1st 2 digits of the IATA code corresponding to the "C_CODE"
            //getElementNode(agencyNode, 'l_country_code', agency.IATACode__c == Null?'':agency.IATACode__c.substring(0,3));
            //End - #AMSFTS
        }

        if(agency.IATACode__c != null && agency.IATACode__c.length() > 7){
                getElementNode(agencyNode, 'iata_code', agency.IATACode__c.substring(0, 7) );
                
        }else{
                getElementNode(agencyNode, 'iata_code', agency.IATACode__c);
        }

        getElementNode(agencyNode, 'iata_chk', String.valueOf(agency.Check_Digit__c)); 
        
        String sCASS = '';
        if(agency.CASS_Number__c != Null){
            sCASS = String.valueOf(agency.CASS_Number__c);
            if(sCASS.indexOf('.',0) > 0){
                sCASS = sCASS.substring(0,sCASS.indexOf('.',0)); //remove '.0' from the end...
            }
        }
        getElementNode(agencyNode, 'cass_num', sCASS.equalsIgnoreCase('') ? Null : PadZeros(sCASS, 3) );     
        //getElementNode(agencyNode, 'site_type', mAg_VS_AgSiteType.get(agency.Id)); //FM : Removed on S5, using the one from address
        //getElementNode(agencyNode, 'site_type', String.valueOf(agency.Site_Type__c)); //RP: site type moved to agency //FM: Removed to test S5 used the one on Address
        

        if(!redux){
            getElementNode(agencyNode, 'change_code', sChangeCode); //- #AMSFTS

            //getElementNode(agencyNode, 'site_type', agency.Site_Type__c); - #AMSFTS
            getElementNode(agencyNode, 'site_type', agency.Location_Type__c);

            getElementNode(agencyNode, 'air_code', agency.Airline_Code__c);
            
            List<String> lsLegalName = AMS_Utils.splitAccName(agency.Name);
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.name', 'legal_1', lsLegalName[0] == ''?null:lsLegalName[0]);

            //getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Legal_Name_2__c', 'legal_2', agency.Legal_Name_2__c); - #AMSFTS
            //getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Legal_Name_3__c', 'legal_3', agency.Legal_Name_3__c); - #AMSFTS
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Legal_Name_2__c', 'legal_2', lsLegalName[1] == ''?null:lsLegalName[1]);
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Legal_Name_3__c', 'legal_3', lsLegalName[2] == ''?null:lsLegalName[2]);

            //short_name
            //DECISION R3.1 - Always send "Abbreviated_name__c"
            getElementNode(agencyNode, 'short_name', agency.Abbreviated_name__c); 
            //getElementNode(agencyNode, 'short_name', agency.Short_Name__c);

            //getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Trading_Name_1__c', 'dba_1', agency.Trading_Name_1__c); - #AMSFTS
            //getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Trading_Name_2__c', 'dba_2', agency.Trading_Name_2__c); - #AMSFTS
            

            List<String> lsTradeName = Null;
            if(agency.TradeName__c != Null){
                lsTradeName = AMS_Utils.splitAccTradeName(agency.TradeName__c);
            }else{
                lsTradeName = new List<String>();
                lsTradeName.add(''); //1
                lsTradeName.add(''); //2 
            }
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Trading_Name_1__c', 'dba_1', lsTradeName[0] == ''?null:lsTradeName[0]);
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Trading_Name_2__c', 'dba_2', lsTradeName[1] == ''?null:lsTradeName[1]);
            

            //Sprint 7: Insert Category, replacing the "cat_1", "cat_2" and "cat_3" fields by multipick list values 
            //getElementNode(agencyNode, 'cat_1', agency.Location_Category__c);
            //getElementNode(agencyNode, 'cat_2', Null); //Empty, all values on field "cat_1"
            //getElementNode(agencyNode, 'cat_3', Null); //Empty, all values on field "cat_1"
            Dom.Xmlnode nodeCat = agencyNode.addChildElement('cat', null, null);
            if(agency.Location_Category__c != Null){
                String sCatValue = agency.Location_Category__c;
                List<String> splitCat = sCatValue.split(';',0);     //split the values by ";"
                for (String s : splitCat){
                    getElementNode(nodeCat, 'cat_code', s);
                }            
            }
            //Begin - #AMSFTS
            //getElementNode(agencyNode, 'pas_cgo', agency.recordType.Name.equalsIgnoreCase('passenger')?'P':'C');
            //String sPasCargo = Null;
            //if(agency.Sector__c != Null && agency.Sector__c.equalsIgnoreCase('Travel Agent') ){
            //    sPasCargo = 'P';
            //}else if(agency.Sector__c != Null && agency.Sector__c.equalsIgnoreCase('Cargo Agent') ){
            //    sPasCargo = 'C';
            //}
            getElementNode(agencyNode, 'pas_cgo', sPasCargo);
            //END - #AMSFTS

            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Company_Type__c', 'co_type', agency.Company_Type__c);
            
            //getElementNode(agencyNode, 'solicit', agency.Solicitation_Flag__c == True ? 'Y' : 'N'); - #AMSFTS
            getElementNode(agencyNode, 'solicit', agency.GDP_Opt_In__c == True ? 'Y' : 'N');
            
            //Begin - #AMSFTS
            //getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Tax_Reference_Number__c', 'tax_ref_1', agency.Tax_Reference_Number__c);
            //getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Other_Tax_Reference_Number__c', 'tax_ref_2', agency.Other_Tax_Reference_Number__c);
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Tax_Reference_Number__c', 'tax_ref_1', agency.VAT_Number__c);
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Other_Tax_Reference_Number__c', 'tax_ref_2', agency.VAT_Number_2__c);
            //END - #AMSFTS

            //getElementNode(agencyNode, 'bsp_code', agency.BSP_Code__c); - #AMSFTS
            getElementNode(agencyNode, 'bsp_code', agency.BSP_CASS_Code__c);
            
            Dom.Xmlnode nodeAffil = agencyNode.addChildElement('affil', null, null);
            String sAffil = '';
            List<String> lAffil = new List<String>();
            if(lAffiliation.size() > 0){
                for (AMS_Affiliation__c affil : lAffiliation) {
                    Id idAff = mAgAffiliation_VS_Affiliation.get(affil.Id);
                    if(idAff == agency.Id){
                        //sAffil = sAffil.equalsIgnoreCase('')? affil.Name : sAffil + ';' + affil.Name;
                        //lAffil.add(affil.Affiliation_Code__c);
                        getElementNode(nodeAffil, 'affil_code', affil.Affiliation_Code__c);
                    }
                }
            }

            //getElementNode(agencyNode, 'affil_1', lAffil.size() > 0 ? lAffil.get(0) : Null); //FM : Removed S5
            //getElementNode(agencyNode, 'affil_2', lAffil.size() > 1 ? lAffil.get(1) : Null);
            //getElementNode(agencyNode, 'affil_3', lAffil.size() > 2 ? lAffil.get(2) : Null);
            getElementNode(agencyNode, 'license', agency.License_Number__c);
            getElementNode(agencyNode, 'lang', getPersonLanguageOfCorrespondence(oPerson.Language_of_correspondence__c) );


            getElementTranslatedNode(agencyNode, iQta, 'AMS_Person__c.Lastname__c', 'qtal_name', sQtal_name);
            getElementTranslatedNode(agencyNode, iQta, 'AMS_Person__c.First_Name__c', 'qtaf_name', sQtaf_name);
            getElementTranslatedNode(agencyNode, iQmp, 'AMS_Person__c.Lastname__c', 'qmpl_name', sQmpl_name);
            getElementTranslatedNode(agencyNode, iQmp, 'AMS_Person__c.First_Name__c', 'qmpf_name', sQmpf_name);
                    

            Dom.Xmlnode nodeGDS = agencyNode.addChildElement('gds', null, null);

            List<String> lGDS = agency.GDS__c == null ? new List<String>() : agency.GDS__c.split(';');
            if(lGDS.size() > 0){
                for (String gds : lGDS) {
                    getElementNode(nodeGDS, 'gds_code', gds);
                }
            }

            Datetime dtOrganization_Last_Change_Date = agency.Organization_Last_Change_Date__c == Null ? Null : Datetime.newInstance(agency.Organization_Last_Change_Date__c.year(), agency.Organization_Last_Change_Date__c.month(),agency.Organization_Last_Change_Date__c.day());
            Datetime dtLast_Inspection_Date = agency.Last_Inspection_Date__c == Null ? Null : Datetime.newInstance(agency.Last_Inspection_Date__c.year(), agency.Last_Inspection_Date__c.month(),agency.Last_Inspection_Date__c.day());
            Datetime dtOriginal_Approval_DAte = agency.Original_Approval_DAte__c == Null ? Null : Datetime.newInstance(agency.Original_Approval_DAte__c.year(), agency.Original_Approval_DAte__c.month(),agency.Original_Approval_DAte__c.day());
           
            //getElementNode(agencyNode, 'last_inspection_date', dtLast_Inspection_Date == Null ? Null : String.valueOf(dtLast_Inspection_Date.format('yyyyMMdd')));
            ////getElementNode(agencyNode, 'location_class2', mAg_VS_Segment.get(agency.Id));
            getElementNode(agencyNode, 'location_class',agency.Location_Class__c);
            //getElementNode(agencyNode, 'original_approval_date', dtOriginal_Approval_DAte == Null ? Null : String.valueOf(dtOriginal_Approval_DAte.format('yyyyMMdd')));
            //getElementNode(agencyNode, 'organization_last_change_date', dtOrganization_Last_Change_Date == Null ? Null : String.valueOf(dtOrganization_Last_Change_Date.format('yyyyMMdd')));
            
            getElementNode(agencyNode, 'email',agency.Email__c);
            getElementNode(agencyNode, 'tty',agency.TTY__c);
            getElementNode(agencyNode, 'website',agency.Website);

            getElementNode(agencyNode, 'eth_2', Null); //Empty, reserved field
            getElementNode(agencyNode, 'eth_3', Null); //Empty, reserved field
            //Removed from XML
            //getElementNode(agencyNode, 'XIATACass', String.valueOf(parentAg.CASS_Number__c));
            //getElementNode(agencyNode, 'operations', agency.DPC_Operation__c);

        }

    }


   


    /*****************************************
        Utility Methods section
    ******************************************/

    /**
    Split the phone number from a String, removing spaces and non-numeric Chars 
    Returns List with:
        [0] - INT code     - size 6
        [1] - STD codes    - size 6
        [2] - phone number - size 12
    */
    public List<String> splitPhone(String num, String countryName){ 
        
        //Check for value
        if(String.isEmpty(num)){
            return null;
        }
        List<String> lRes = new String[3];
        
        Boolean isIntNumber = num.startsWith('00') || num.startsWith('+');

        String code;
        String numRes = '';
        Integer i=0;


        //Remove spaces and special chars
        while(i < num.length()){
            String s = num.substring(i,i+1);

            if (s.isNumeric()){
                numRes += s;
            }
            //system.debug('s: ' + s + ' || numRes:' + numRes);
            i++;
        }

        ITU_Country_Code__c country = ITU_Country_Code__c.getAll().get(countryName);
        if(country != null){

            List<String> countryCodes = country.Code__c.split(',');

            if(isIntNumber){

                numRes = numRes.removeStart('00');

                for(String c : countryCodes){
                    if(numRes.startsWith(c)) code = c;
                }

                if(String.isEmpty(code)) code = countryCodes[0];
                else numRes = numRes.substring(code.length());

            }
            else code = countryCodes[0];
        }

        if(String.isNotEmpty(code)) lRes.add(0, '00'+code);
            
        if(numRes.length() <= 12){
            lRes.add(2, numRes);
        }else if(numRes.length() <= 18){
            lRes.add(1, numRes.substring(0, numRes.length()-12));
            lRes.add(2, numRes.substring(numRes.length()-12));
        }else{
            lRes.add(1, numRes.substring(numRes.length()-18, numRes.length()-12));  
            lRes.add(2, numRes.substring(numRes.length()-12));
        }

        return lRes;
    }

    public static String PadZeros(String s, Integer Len) {
        while (s.length() < Len) s = '0' + s;
        return s;
    }
    
    public String getPersonLanguageOfCorrespondence(String value){
        if(value == Null){
            return Null;
        }else if(value.equalsIgnoreCase('EN')){
            return 'ENG';
        }else if(value.equalsIgnoreCase('FR')){
            return 'FRE';
        }else if(value.equalsIgnoreCase('SP')){
            return 'SPA';
        }
        return Null;
    }

    

    //Get the WAD files values to include
    public String getXMLTag(String name){
        String auxName = name.toLowerCase();
        //System.Debug('----mXMLTagValues :'+ name +'-'+ mXMLTagValues.containsKey(auxName)+'-'+ mXMLTagValues.get(auxName));
        if(mXMLTagValues.containsKey(auxName)){
            return mXMLTagValues.get(auxName);
        }
        return name;
    } 
   
    //Set's a Element node as a child of the given node and the WAD attributtes if they exists
    public void getElementNode(Dom.Xmlnode node, String field, String value){
        Dom.Xmlnode auxNode = node.addChildElement(field, null, null);
        //getWadAttributes(auxNode, field);
        if(value != null){
            auxNode.addTextNode(value);
        //}else{
        //    auxNode.addTextNode('Missing');
        }

    }

    public void getElementTranslatedNode(Dom.Xmlnode node, Id iid, String strObject, String field, String value){
        Dom.Xmlnode auxNode = node.addChildElement(field, null, null);
        //getWadAttributes(auxNode, field);
        
        Boolean bToTranslate = sFieldsToTranslate.contains(strObject.toLowerCase()) ? True : False;
        
        if(bToTranslate){
            List<String> splitObj = strObject.toLowerCase().split('\\.',0);
            getTranslationNode(auxNode, iid, splitObj.get(0), splitObj.get(1), value);
        }else{
            if(value != null){
                auxNode.addTextNode(value);     
            //}else{
         //       auxNode.addTextNode('Missing');
            }
        }
    }


    public void getTranslationNode(Dom.Xmlnode node, Id iid, String strObject, String field, String value){
        if(value != null){
            node.setAttribute('value', value);
        }else{
            node.setAttribute('value', '');
        }
        Dom.Xmlnode translationsNode = node.addChildElement('translations', null, null);

        for(AMS_Fields_Translation__c ft : lFieldsTranslation){
            Boolean bTranslate = False;
            if(field.equalsIgnoreCase(ft.Field_name__c)){

                //if(strObject.equalsIgnoreCase('ams_agency__c') && ft.Agency__c == iid){ - #AMSFTS
                if(strObject.equalsIgnoreCase('Account') && ft.Account__c == iid){
                    bTranslate = True;
                }else if(strObject.equalsIgnoreCase('ams_address__c') && ft.Address__c == iid){
                    bTranslate = True;
                }else if(strObject.equalsIgnoreCase('ams_agency_Hierarchy__c') && ft.Agency_Hierarchy__c == iid){
                    bTranslate = True;  
                }else if(strObject.equalsIgnoreCase('AMS_Airport__c') && ft.AMSAirport__c == iid){
                    bTranslate = True;
                }else if(strObject.equalsIgnoreCase('AMS_Employee__c') && ft.AMSEmployee__c == iid){
                    bTranslate = True;
                }else if(strObject.equalsIgnoreCase('AMS_Owner__c') && ft.AMSOwner__c == iid){
                    bTranslate = True;
                }else if(strObject.equalsIgnoreCase('AMS_Person__c') && ft.AMSPerson__c == iid){
                    bTranslate = True;
                }else if(strObject.equalsIgnoreCase('IATA_ISO_Country__c') && ft.IATA_ISO_Country__c == iid){
                    bTranslate = True;
                }else if(strObject.equalsIgnoreCase('IATA_ISO_State__c') && ft.IATA_ISO_State__c == iid){
                    bTranslate = True;
                }else if(strObject.equalsIgnoreCase('User') && ft.User__c == iid){
                    bTranslate = True;
                }else if(strObject.equalsIgnoreCase('Contact') && ft.Contact__c == iid){
                    bTranslate = True;
                }

                if(bTranslate){
                    Dom.Xmlnode translationNode = translationsNode.addChildElement('translation', null, null);
                    translationNode.setAttribute('language', ft.Language__c);
                    translationNode.setAttribute('value', ft.Translation__c);
                }
            }
        }
    }

    public void getObjectData(Dom.Xmlnode node, String sObjectName, sObject obj ){
        getObjectData( node, sObjectName, obj, True );
    }
    
    //Creates the XML structure of a Object, if a REFERENCE (Lookup) field exists its recursive
    public void getObjectData(Dom.Xmlnode node, String sObjectName, sObject obj, Boolean bLookups ){

        //System.Debug('----getObjectData sObjectName:'+ sObjectName);
        //System.Debug('----getObjectData obj:'+ obj);
        String displayObjectName = sObjectName;
        String displayFieldName = '';
        String displayFieldNamePlural = '';

        Boolean bToTranslate = False;

        try { 

            //remove the "__c" from the field names
            if(displayObjectName.contains('__c')){
                displayObjectName = displayObjectName.substringBeforeLast('__c');
            }
            displayObjectName = getXMLTag(displayObjectName);

            Dom.Xmlnode auxParentNode = node.addChildElement(displayObjectName, null, null);

            Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);

            Schema.DescribeSObjectResult r = t.getDescribe();
            
            Map<String, Schema.SObjectField> M = r.fields.getMap();

            List<String> lOrdered = new List<String>();

            lOrdered.addAll(M.keySet());

            lOrdered.sort(); //Order fields in order to be consisted on all environments and to match the order of the XSD

            for (String f : lOrdered){

                displayFieldName = f;

                
                String sToInclude = sObjectName+'.'+f;
                sToInclude = sToInclude.toLowerCase();

                String sToExclude = f;
                sToExclude = sToExclude.toLowerCase();          


                //validate if the field is on the exclude list and also on the include list
                if(!sFieldsToExclude.contains(sToExclude) && sFieldsToInclude.contains(sToInclude)){
                    
                    bToTranslate = sFieldsToTranslate.contains(sToInclude) ? True : False;

                    //remove the "__c" from the field names
                    if(displayFieldName.contains('__c')){
                        displayFieldName = displayFieldName.substringBeforeLast('__c');
                    }

                    //Special case for ISO_State
                    //if(sObjectName.equalsIgnoreCase('iata_iso_state__c') && f.equalsIgnoreCase('iso_code__c')){
                    if(sObjectName.equalsIgnoreCase('iata_iso_state__c') && f.equalsIgnoreCase('iso_code_standard__c')){
                        displayFieldName = 'state_iso_code';
                    }

                    displayFieldName = getXMLTag(displayFieldName);

                    //Set the plural for some fields
                    if(displayFieldName.substring(displayFieldName.length()-1, displayFieldName.length()).equalsIgnoreCase('y')){
                        displayFieldNamePlural = displayFieldName.substring(0,displayFieldName.length()-1) + 'ies';
                    }else{
                        //TODO remove for Sprint 5
                        //if(!displayFieldName.equalsIgnoreCase('accreditation_endorsement_organisation')){
                            displayFieldNamePlural = displayFieldName + 's';
                        //}else{
                        //    displayFieldNamePlural = displayFieldName;
                        //}
                    }
                    displayFieldNamePlural = getXMLTag(displayFieldNamePlural);

                    Schema.DisplayType FldType = M.get(f).getDescribe().getType();

                    //Validates if not Multiplicklist or Reference (Lookup), because this need to be created separetly
                    Dom.Xmlnode auxNode = null;
                    if (FldType != Schema.DisplayType.MultiPicklist && 
                        FldType != Schema.DisplayType.Reference){
                        auxNode = auxParentNode.addChildElement(displayFieldName, null, null);

                        //Check if theres a value before adding the attributes
                        //if(!getWadValue(sToInclude,'Size').equalsIgnoreCase('') ){
                            //auxNode.setAttribute('wadsize', getWadValue(sToInclude,'Size'));
                            //auxNode.setAttribute('wadposition', getWadValue(sToInclude,'Position'));
                        //}
                    }
        
                    try { 
                        if(obj.get(f)  != null){
                            if (FldType == Schema.DisplayType.Id || 
                                    FldType == Schema.DisplayType.String || 
                                    FldType == Schema.DisplayType.TextArea || 
                                    FldType == Schema.DisplayType.Double ||  
                                    FldType == Schema.DisplayType.Picklist ||
                                    FldType == Schema.DisplayType.Percent ||
                                    FldType == Schema.DisplayType.Phone ||
                                    FldType == Schema.DisplayType.Email ||
                                    FldType == Schema.DisplayType.Time ||
                                    FldType == Schema.DisplayType.Combobox ||
                                    FldType == Schema.DisplayType.Address){
                                
                                if(bToTranslate){
                                    //TODO add translations tag method
                                    getTranslationNode(auxNode, (Id) obj.get('Id'), sObjectName, f, String.valueOf(obj.get(f) ));
                                }else{
                                    //Special case - need to split field in 2...
                                    //Sprint 7: Removed "country_code" from "State"... "ISO_CODE" stay has is...
                                    ////Special case - need to split field in 2...
                                    //if(sObjectName.equalsIgnoreCase('iata_iso_state__c') && f.equalsIgnoreCase('iso_code__c')){
                                    if(sObjectName.equalsIgnoreCase('iata_iso_state__c') && f.equalsIgnoreCase('iso_code_standard__c')){
                                        
                                        IATA_ISO_State__c auxState =  (IATA_ISO_State__c)obj;
                                        String sAuxName = auxState.Name;
                                        String sValue = String.valueOf(obj.get(f));
                                        String sISO_code = '';
                                        String sCountryCode = '';
                                        if(sValue.length() == 4){
                                            sISO_code = sValue.substring(0,2);
                                            sCountryCode = sValue.substring(2,4);
                                        //Test to check US, Canada and Australia states
                                        }else if(sValue.indexOf('-') > 1){
                                            sISO_code = sValue.substring(sValue.indexOf('-')+1,sValue.length());
                                            sCountryCode = Null;
                                        }else{
                                            sISO_code = sValue;
                                            sCountryCode = Null;
                                        }

                                        auxNode.addTextNode(sISO_code );
                                        Dom.Xmlnode auxNodeStateName = auxParentNode.addChildElement('name', null, null);
                                        //auxNodeStateName.addTextNode(sAuxName );
                                        getTranslationNode(auxNodeStateName, (Id) obj.get('Id'), sObjectName, f, sAuxName );
                                        Dom.Xmlnode auxNodeCountryCode = auxParentNode.addChildElement('numeric_code', null, null);
                                        if(sCountryCode != Null){
                                            auxNodeCountryCode.addTextNode(sCountryCode );
                                        }
                                    }else 
                                        
                                    if(displayFieldName.equalsIgnoreCase('language_of_correspondence') ){ 
                                        //Sprint 7: Removed "contacts", this part was hardcoded for XSD v103 because contacts was changed from "Person" object to the "employee" Obj
                                        //FM: TODO - Remove for S6 tests.... FM- Removed...
                                        //Dom.Xmlnode auxNodeContacts = auxParentNode.addChildElement('contacts', null, null);    
                                        //Dom.Xmlnode auxNodeContactsId = auxNodeContacts.addChildElement('id', null, null);    
                                        //auxNodeContactsId.addTextNode('id' );
                                        //Dom.Xmlnode auxNodeContactsName = auxNodeContacts.addChildElement('name', null, null);    
                                        //auxNodeContactsName.addTextNode('name' );

                                        auxNode.addTextNode(getPersonLanguageOfCorrespondence(String.valueOf(obj.get(f) ) ) );                                             
                                    
                                    }else{
                                        auxNode.addTextNode(String.valueOf(obj.get(f) ) );      
                                    }
                                }
                                
                     
                            } else if (FldType == Schema.DisplayType.DateTime){
                                Datetime dt = Datetime.valueOf(obj.get(f));
                                auxNode.addTextNode(obj.get(f)  == null ? '' : dt.format('yyyyMMdd') );
                           } else if (FldType == Schema.DisplayType.Date){
                                Date d = Date.valueOf(obj.get(f));
                                Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());

                                auxNode.addTextNode(obj.get(f)  == null ? '' : dt.format('yyyyMMdd') );
                            } else if (FldType == Schema.DisplayType.Boolean){
                                auxNode.addTextNode(obj.get(f)  == null ? '' : Boolean.valueOf(obj.get(f)) ? 'True' : 'False' );
                            } else if (FldType == Schema.DisplayType.MultiPicklist){
            
                                String sValue = String.valueOf(obj.get(f));

                                //split the values by ";"
                                List<String> splitObj = sValue.split(';',0);    

                                Dom.Xmlnode splitNode = auxParentNode.addChildElement(displayFieldNamePlural, null, null);

                                for (String s : splitObj){
                                    Dom.Xmlnode auxSplitNode = splitNode.addChildElement(displayFieldName, null, null);

                                    //Check if theres a value before adding the attributes
                                    //if(!getWadValue(sToInclude,'Size').equalsIgnoreCase('') ){
                                        //auxSplitNode.setAttribute('wadsize', getWadValue(sToInclude,'Size'));
                                        //auxSplitNode.setAttribute('wadposition', getWadValue(sToInclude,'Position'));
                                    //}

                                    auxSplitNode.addTextNode(s);
                                }
                            
                            } else if (FldType == Schema.DisplayType.Reference){
                                
                                //Check if it's a recordtype!
                                if(f.equalsIgnoreCase('recordtypeid')){
                                    auxNode = auxParentNode.addChildElement('record_type', null, null);
                                    RecordType rt = (RecordType)msObject.get((Id)obj.get(f));

                                    //Check if theres a value before adding the attributes
                                    //if(!getWadValue(sToInclude,'Size').equalsIgnoreCase('') ){
                                        //auxNode.setAttribute('wadsize', getWadValue(sToInclude,'Size'));
                                        //auxNode.setAttribute('wadposition', getWadValue(sToInclude,'Position'));
                                    //}

                                    auxNode.addTextNode(String.valueOf(rt.Name) );

                                }else if(f.equalsIgnoreCase('Accreditation_Endorsement_organisation__c')){ //Get org aircode from child element

                                    Dom.Xmlnode auxInspectionNode = auxParentNode.addChildElement(displayFieldName, null, null);
                                    AMS_Inspection__c x = (AMS_Inspection__c)obj;
                                    String sAuxValue = (String)x.Accreditation_Endorsement_organisation__r.Air_Code__c;
                                    auxInspectionNode.addTextNode(sAuxValue);

                                }else if(f.equalsIgnoreCase('Parent_Account__c')){ //Special threatment for the Parent agencies on the Hierarchy data

                                    Dom.Xmlnode auxAgencyNode = auxParentNode.addChildElement(displayFieldName, null, null);
                                    //getAgencyNode(auxAgencyNode, (AMS_Agency__c)msObject.get((Id)obj.get(f)),False, True); - #AMSFTS
                                    getAgencyNode(auxAgencyNode, (Account)msObject.get((Id)obj.get(f)),False, True);

                                }else{

                                    auxNode = auxParentNode.addChildElement(displayFieldNamePlural, null, null);

                                    if(bLookups){
                                        Schema.DescribeFieldResult ref =  M.get(f).getDescribe();
                    
                                        if(msObject.containsKey((Id)obj.get(f))){
                                            getObjectData(auxNode, ref.getReferenceTo()[0].getDescribe().getName(), msObject.get((Id)obj.get(f)) );
                                        }
                                    }
                                }
                            } 
                        }else{
                            if (FldType == Schema.DisplayType.Id || 
                                    FldType == Schema.DisplayType.String || 
                                    FldType == Schema.DisplayType.TextArea || 
                                    FldType == Schema.DisplayType.Double ||  
                                    FldType == Schema.DisplayType.Picklist ||
                                    FldType == Schema.DisplayType.Percent ||
                                    FldType == Schema.DisplayType.Phone ||
                                    FldType == Schema.DisplayType.Email ||
                                    FldType == Schema.DisplayType.Time ||
                                    FldType == Schema.DisplayType.Combobox ||
                                    FldType == Schema.DisplayType.Address){
                                
                                if(bToTranslate){
                                    //TODO add translations tag method
                                    getTranslationNode(auxNode, (Id) obj.get('Id'), sObjectName, f, String.valueOf(obj.get(f) ));
                                }else{
                                    //Sprint 7: Removed "contacts", this part was hardcoded for XSD v103 because contacts was changed from "Person" object to the "employee" Obj
                                    ////Special case - need to split field in 2...
                                    //if(displayFieldName.equalsIgnoreCase('language_of_correspondence') ){ //FM: TODO - Remove for S6 tests....
                                    //    Dom.Xmlnode auxNodeContacts = auxParentNode.addChildElement('contacts', null, null);    
                                    //    Dom.Xmlnode auxNodeContactsId = auxNodeContacts.addChildElement('id', null, null);    
                                    //    auxNodeContactsId.addTextNode('id' );
                                    //    Dom.Xmlnode auxNodeContactsName = auxNodeContacts.addChildElement('name', null, null);    
                                    //    auxNodeContactsName.addTextNode('name' );
                                    //}
                                }
                            }
                            
                            //Checks the below types and create the Node, since otherwise it would not be created...  
                            if (FldType == Schema.DisplayType.MultiPicklist ||
                                FldType == Schema.DisplayType.Reference){
                                auxNode = auxParentNode.addChildElement(displayFieldNamePlural, null, null);
                                //auxNode.addTextNode('Missing');  
                       //     }else{
                       //         auxNode.addTextNode('Missing');    
                            }
                        }    
        
                        
        
                    } catch (SObjectException e)    { 
                        //getObjectData SObjectException e:System.SObjectException: SObject row was retrieved via SOQL without querying the requested field: AMS_Employee__c.IsDeleted
                        System.Debug('----getObjectData SObjectException e:'+ e);
                    }
                }
            }

            //Sprint 8 - workarounf while fields are not created on SFDC
            if(sObjectName.equalsIgnoreCase('AMS_Address__c') ){
                getElementNode(auxParentNode, 'toll', Null);
                getElementNode(auxParentNode, 'toll_int', Null);
                getElementNode(auxParentNode, 'toll_std', Null);
            }

            //Sprint 12 - workaround while fields are not created on SFDC
            if(sObjectName.equalsIgnoreCase('AMS_Inspection__c') ){
                AMS_Inspection__c x = (AMS_Inspection__c)obj;
                String sAuxValue = (String)x.Accreditation_Endorsement_organisation__r.Air_Code__c;
                
                Account ag = (Account)msObject.get(x.Account__c);

                Datetime dtOrganization_Last_Change_Date = ag.Organization_Last_Change_Date__c == Null ? Null : Datetime.newInstance(ag.Organization_Last_Change_Date__c.year(), ag.Organization_Last_Change_Date__c.month(),ag.Organization_Last_Change_Date__c.day());
                Datetime dtLast_Inspection_Date = ag.Last_Inspection_Date__c == Null ? Null : Datetime.newInstance(ag.Last_Inspection_Date__c.year(), ag.Last_Inspection_Date__c.month(),ag.Last_Inspection_Date__c.day());
                Datetime dtOriginal_Approval_DAte = ag.Original_Approval_DAte__c == Null ? Null : Datetime.newInstance(ag.Original_Approval_DAte__c.year(), ag.Original_Approval_DAte__c.month(),ag.Original_Approval_DAte__c.day());
               
                getElementNode(auxParentNode, 'last_inspection_date', dtLast_Inspection_Date == Null ? Null : String.valueOf(dtLast_Inspection_Date.format('yyyyMMdd')));
                //getElementNode(auxParentNode, 'location_class',ag.Location_Class__c);
                getElementNode(auxParentNode, 'original_approval_date', dtOriginal_Approval_DAte == Null ? Null : String.valueOf(dtOriginal_Approval_DAte.format('yyyyMMdd')));
                getElementNode(auxParentNode, 'organization_last_change_date', dtOrganization_Last_Change_Date == Null ? Null : String.valueOf(dtOrganization_Last_Change_Date.format('yyyyMMdd')));
            }       

        } catch (SObjectException e)    { 
            //getObjectData SObjectException e:System.SObjectException: SObject row was retrieved via SOQL without querying the requested field: AMS_Employee__c.IsDeleted
            System.Debug('----getObjectData SObjectException e:'+ e);
        } 
        
    }



}