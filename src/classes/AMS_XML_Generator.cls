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
    public Map<Id, String> mAg_VS_Segment;
    public Map<Id, List<AMS_Account_Role__c>> mAg_VS_Employees;
    public Map<Id, String> mAg_VS_DPCSystem;
    public Map<Id, Id> mAg_VS_HO;
    
/*  NEWGEN-801 */
    public Map<Id, List<Agency_Authorization__c>> mAgencyAuthorizations;
    public Map<Id, List<ANG_RHC_Information__c>> mAgencyRHCInfos;
/* EOF NEWGEN-801 */
    public List<AMS_Agency_Updates__c> lAgencyUpdates;  
    public List<Agency_Applied_Change_code__c> lAgencyChangeCode; 

    public List<Account> lAgencyArea;

    public List<AMS_Address__c> lAddresses;
    public List<IATA_ISO_Country__c> lCountry;
    public List<IATA_ISO_State__c> lState;
    
    public List<AMS_Account_Role__c> lOwnership;
    
    public List<Account> lOwner;
    public List<Account> lAccount; 
    public List<Contact> lContact;
    public List<Contact> lAgenciesContacts;
    public List<User> lUser;
    public List<AMS_Person__c> lPerson;

    public List<AMS_Account_Role__c> lEmployee;

    //JFO 13/8/2015  deleted for new DM without GDS custom object
    //public List<AMS_Agency_Computer_Reservation__c> lAgComputerReservation;
    //public List<AMS_Computer_Reservation_System__c> lComputerReservation;
    public List<AMS_Inspection__c> lInspection;
    public List<AMS_Agencies_relationhip__c> lAgRelationship;
    public List<AMS_Agencies_relationhip__c> lAgRelationshipParent;
    public List<AMS_Agencies_relationhip__c> lAgRelationshipChild;
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

/*  NEWGEN-801 */

    public List<Agency_Authorization__c> lAgencyAuthorizations;
    public List<ANG_RHC_Information__c> lAgencyRHCInfos;

/* EOF NEWGEN-801 */

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
    public String getAgencySalesOrder(Agency_Applied_Change_code__c agency){
    
        List<Agency_Applied_Change_code__c> lAg = new List<Agency_Applied_Change_code__c>();
                lAg.add(agency);

        return getAgencySalesOrder(lAg);

    }

    //Get XML for Agency SalesOrder to send to AW WS 
    public String getAgencySalesOrder(List<Agency_Applied_Change_code__c> agencies){

        //Begin of XML tags
        Dom.Document doc = new Dom.Document();
    
        Dom.Xmlnode rootNode = doc.createRootElement('sales_orders', null, null);

        //Agency Section
        
        Date dToday = Date.today();
        Datetime dtToday = Datetime.now(); // Returns the current Datetime based on a GMT calendar.

        //Get 1st and last day of month - AMSU-97
        Date dFirstDayOfMonth = Date.today().toStartOfMonth();
        Date dLastDayOfMonth = dfirstDayOfMonth.addDays(Date.daysInMonth(dfirstDayOfMonth.year(), dfirstDayOfMonth.month()) - 1);
        Datetime dtFirstDayOfMonth = datetime.newInstance(dFirstDayOfMonth.year(), dFirstDayOfMonth.month(),dFirstDayOfMonth.day());
        Datetime dtLastDayOfMonth = datetime.newInstance(dLastDayOfMonth.year(), dLastDayOfMonth.month(),dLastDayOfMonth.day());

        /*NEWGEN-3267 START - Discarded from Release 6 NEWGEN
        Map<Id,Id> changeCodeOscarMap = new Map<Id,Id>();
        Map<Id,String> changeCodeCaseNumber = new Map<Id,String>();

        for(Agency_Applied_Change_code__c aacc: agencies){
            if(aacc.OSCAR__c <> null && aacc.OSCAR__r.Oscar_Communication_Case_Id__c <> null){
                changeCodeCaseNumber.put(aacc.Id,aacc.OSCAR__r.Oscar_Communication_Case_Id__c);
            }
            else if(aacc.OSCAR__c <> null)
                changeCodeOscarMap.put(aacc.OSCAR__c,aacc.Id);
        }


        for(Case c: [Select Id, CaseNumber from Case where RecordTypeId = :AMS_Utils.OSCAR_COMUNICATION and OSCAR__c in: changeCodeOscarMap.Values() and ( ParentId = null or Parent.RecordTypeId != :AMS_Utils.OSCAR_COMUNICATION)]){
            changeCodeCaseNumber.put(changeCodeOscarMap.get(c.OSCAR__c),c.Id);
        }
        NEWGEN-3267 END*/
        

        //for(Account ag : agencies){
        for(Agency_Applied_Change_code__c ag : agencies){
            Dom.Xmlnode liNode = rootNode.addChildElement('line_item', null, null);
          
            getElementNode(liNode, 'agency_id', ag.Account__r.IATACode__c );
            getElementNode(liNode, 'hub', ag.Account__r.IATA_ISO_Country__r.IATA_Regional_Office__c);
            
            //Changed on AMSU-97
            //getElementNode(liNode, 'period_from', dtToday.format('yyyyMMdd'));
            //getElementNode(liNode, 'period_to', dtToday.format('yyyyMMdd'));
            getElementNode(liNode, 'period_from', dtFirstDayOfMonth.format('yyyyMMdd'));
            getElementNode(liNode, 'period_to', dtLastDayOfMonth.format('yyyyMMdd'));

            getElementNode(liNode, 'product_id', ag.Account__r.Location_Class__c + ag.Change_Code__c); 
            getElementNode(liNode, 'quantity', '1');

            /*NEWGEN-3267 START - Discarded from Release 6 NEWGEN
            if(changeCodeCaseNumber.get(ag.Id) <> null)
                getElementNode(liNode, 'CaseId', changeCodeCaseNumber.get(ag.Id));
            NEWGEN-3267 END*/
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
    public String getAgencyDetail(Account agency, String[] r, String type, String caseId){

        List<Account> lAg = new List<Account>();
        lAg.add(agency);

        return getAgencyDetail(lAg, r, type, caseId);
    }

    //Get XML for AgencyDetail to send to AW WS (2º step)
    //Type - determinates if it's "MasterData" or "ECC"
    //case -  Brings the OSCAR case Id for getting the ECC data
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

        Id rtAccRoleOwnership = Schema.SObjectType.AMS_Account_Role__c.getRecordTypeInfosByName().get('Ownership').getRecordTypeId();
        Id rtAccRoleEmployee = Schema.SObjectType.AMS_Account_Role__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId();
        
        System.debug('XML Generator - Requested Agencies from MDM PI - ' + agency);
        sDebug += '\nAgencies List:' + agency;
        
        //Get agenc
        setAgencyKeys = (new Map<Id,Account>(agency)).keySet();

        for (Account o : agency) {
            setAgencyCountryKeys.add(o.IATA_ISO_Country__c);
            setAddressStateKeys.add(o.Iso_State__c);
        }
        
        //MAIN
        lAgencyUpdates = [SELECT Account__c,CreatedDate,LastModifiedDate,Id,Update_Type__c, Change_Code__c 
                            FROM AMS_Agency_Updates__c 
                            WHERE Account__c IN :setAgencyKeys
                            AND Integration_System__c = 'SAP PI'   
                            ORDER BY Account__c,LastModifiedDate desc];                       
        
        AMS_Agency_Updates__c auxAU = new AMS_Agency_Updates__c();
        for (AMS_Agency_Updates__c agUpd : lAgencyUpdates) {
        
            //Stores only the 1st record from the agency update query, this one have the latest change code to be used
            if(auxAU == null || agUpd.Account__c != auxAU.Account__c){
                auxAU = agUpd;
                mAg_VS_AgUpdate.put(agUpd.Account__c,agUpd);   
                mAg_VS_ChangeCode.put(agUpd.Account__c,agUpd.Change_Code__c);   
            }            
        }
        

/*  NEWGEN-801 */

        lAgencyChangeCode = [SELECT Account__c,Active__c,Change_Code__c, CreatedDate, Created_Date_To_Show__c,Reason_Code__c,Reason_Description__c 
                                FROM Agency_Applied_Change_code__c 
                                WHERE Change_Code__c != null 
                                AND Active__c = true 
                                AND Account__c in :setAgencyKeys];

/*  EOF NEWGEN-801 */

/*
        lAgencyChangeCode = [SELECT Account__c,Active__c,Change_Code__c, CreatedDate, Created_Date_To_Show__c 
                                FROM Agency_Applied_Change_code__c 
                                WHERE Change_Code__c != null 
                                AND Active__c = true 
                                AND Account__c in :setAgencyKeys];
  */

        for (Agency_Applied_Change_code__c agChgCode : lAgencyChangeCode) {
            mAg_VS_AgChangeCode.put(agChgCode.Account__c,agChgCode);
        }                            

        //Reference
        lAgSegment = [SELECT Account__c,Assignation_Type__c,Id,Name,Segment__c,Segment__r.label__c 
                            FROM AMS_Agency_Segment__c
                            where Segment__r.RecordTypeid = :rtProgram
                            and Account__c in :setAgencyKeys];
  
        for (AMS_Agency_Segment__c agSeg : lAgSegment) {
            mAg_VS_Segment.put(agSeg.Account__c,agSeg.Segment__r.label__c);
        }

        //MAIN
        lAgencyArea = [SELECT Id,IATA_ISO_Country__r.AIMS_Area_ID__c 
                            FROM Account
                            where Id in :setAgencyKeys];
        

        for (Account agArea : lAgencyArea) {
            mAg_VS_AgArea.put(agArea.Id,String.valueOf(agArea.IATA_ISO_Country__r.AIMS_Area_ID__c) );
        }
  
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


        lAgenciesContacts = [SELECT AccountId,AMS_isManager__c,AMS_isTicketingAgent__c,AMS_Position__c,
                            AMS_Valid__c,FirstName,Id,LastName,Name,Person__c,Status__c,Title,Email,
                            Preferred_Language__c,Financial_Assessment_Contact__c  
                            FROM Contact
                             WHERE AccountId in :setAgencyKeys];

        //MAIN
        lOwnership = [SELECT Account__c,Owner_Account__c,Id,Name,Percentage__c,Person__c,Contact__c,RecordTypeId,Employee_type__c    
                            FROM AMS_Account_Role__c WHERE Account__c in :setAgencyKeys
                            AND RecordTypeId = :rtAccRoleOwnership
                            limit :fixLimit];

        for (AMS_Account_Role__c o : lOwnership) {
            setOwnershipKeys.add(o.Owner_Account__c);
            if(o.Person__c != Null){
                setPersonKeys.add(o.Person__c);
            }
            if(o.Contact__c != Null){
                setContactKeys.add(o.Contact__c);
            }
        }
        
        //REFERENCE
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
            //20-06-2017 - Change AMSU-93 - special chars replacement
            o.Name = AMS_Utils.cleanSpecialChars(o.Name);
            setAccountKeys.add(o.Id); 
        }
        
        //MAIN
        lEmployee = [SELECT Account__c,Duty__c,Earning__c,Employee_type__c,Hours__c,Id,isManager__c,isTicketingAgent__c,
                    Name,Person__c,Position__c,Registration_Date__c,Stage__c,Start_date__c,Contact__c,
                    Termination_Date__c,Title__c,Valid__c,RecordTypeId,Owner_Account__c,Percentage__c
                    FROM AMS_Account_Role__c 
                    WHERE RecordTypeId = :rtAccRoleEmployee
                        AND Account__c in :setAgencyKeys
                        AND (isManager__c = True OR isTicketingAgent__c = True )                             
                    limit :fixLimit];
      
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
        }

        
        //MAIN
        lInspection = [SELECT Accreditation_Endorsement_Status_code__c, Account__r.Main_Accreditation_Organization__c,
                        Date_Organisation_Status_attained__c,Id,Name,
                        Account__c,
                        Account__r.Organization_Last_Change_Date__c, 
                        Account__r.Last_Inspection_Date__c,
                        Account__r.Original_Approval_DAte__c,
                        Account__r.Location_Class__c                        
                        FROM AMS_Inspection__c WHERE Account__c in :setAgencyKeys 
                        ORDER BY Date_Organisation_Status_attained__c desc
                        LIMIT :fixLimit];
        
        //MAIN
        lAgRelationship = [SELECT Parent_Account__c,Child_Account__c,Hierarchy__c,HO_Flag__c,Id,Name,Relationship_details__c 
                    FROM AMS_Agencies_relationhip__c 
                    WHERE Child_Account__c in :setAgencyKeys 
                    AND Hierarchy__r.RecordTypeId = :rtHierarchy
                    limit :fixLimit];
        
        for (AMS_Agencies_relationhip__c rel : lAgRelationship) {
            setHierarchyKeys.add(rel.Hierarchy__c);
            
            setAgRelationshipKeys.add(rel.Parent_Account__c);
            mAg_VS_ParentAg.put(rel.Child_Account__c, rel.Parent_Account__c);
        }

        //REFERENCE
        lAgRelationshipHierarchy = [SELECT Id,AIMS_ID__c,
                    CASS_Number__c,Check_Digit__c,IATACode__c,
                    C_Code__c,ParentId,Parent.AIMS_ID__c,
                    IATA_Area__c,Sector__c
                    FROM Account where id in :setAgRelationshipKeys];
        
        //REFERENCE                    
        lAgHierarchy = [SELECT Hierarchy_Name__c,Id,Name,RecordTypeId 
                        FROM AMS_Agencies_Hierarchy__c WHERE Id in :setHierarchyKeys
                        AND RecordTypeId = :rtHierarchy];
        
        Map<Id,Id> mHier_VS_HO;
        mHier_VS_HO = new Map<Id,Id>();

        //Get HO (Head Office) Id
        List<AggregateResult> lAgHO = [SELECT Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c 
                    where Hierarchy__c in :setHierarchyKeys
                    AND Hierarchy__r.RecordTypeId = :rtHierarchy
                    group by Parent_Account__c, Hierarchy__c ];

        for(AggregateResult agHO : lAgHO){
            setHO.add((Id)agHO.get('Parent_Account__c'));
        }

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
        
        for(Id agChildId : lAgChildHOtoCheck){
            if( mAgParentHO.containsKey(agChildId) ){
                mAgParentHO.remove(agChildId);
            }
        }
        
        
        for(Id parentId : mAgParentHO.keySet() ){
            Id auxRelId = (Id)mAgParentHO.get(parentId);
            mHier_VS_HO.put(auxRelId ,parentId); 
            setAccountKeys.add(parentId); 
        }
        
        for (AMS_Agencies_relationhip__c agR : lAgRelationship) {
            mAg_VS_HO.put((Id)agR.Child_Account__c, (Id)mHier_VS_HO.get(agR.Hierarchy__c));
        }

  
        //MAIN
        lAgAirport = [SELECT Airport__c,Account__c FROM AMS_Agency_Airport__c 
                        WHERE Account__c in :setAgencyKeys
                        limit :fixLimit];
  
        for (AMS_Agency_Airport__c airp : lAgAirport) {
            setAirportKeys.add(airp.Airport__c);
            mAgAirport_VS_Airport.put(airp.Airport__c,airp.Account__c);
        }

        //REFERENCE
        lAirport = [SELECT City__c,Code__c,Country__c,Id,Name FROM AMS_Airport__c
                    WHERE id in :setAirportKeys];

        //MAIN
        lAgAffiliation = [SELECT Affiliation__c,Account__c FROM AMS_Agency_Affiliation__c 
                            WHERE Account__c in :setAgencyKeys
                            limit :fixLimit];
  
        for (AMS_Agency_Affiliation__c affil : lAgAffiliation) {
            setAffiliationKeys.add(affil.Affiliation__c);
            mAgAffiliation_VS_Affiliation.put(affil.Affiliation__c,affil.Account__c);
        }

        //REFERENCE
        lAffiliation = [SELECT Affiliation_Code__c,Id,Name FROM AMS_Affiliation__c
                    WHERE id in :setAffiliationKeys];            

        //MAIN
        lAgProfile = [SELECT GR_Code__c,GR_Item__c,Id,Name,Account__c FROM AMS_Agency_Profile__c 
                        WHERE Account__c in :setAgencyKeys
                        limit :fixLimit];
  
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
                    Short_Name__c,Abbreviated_name__c,Sector__c,AIMS_ID__c,BSP_CASS_Code__c, Reason__c FROM Account WHERE Id in :setAccountKeys]; 

        for (Account o : lAccount) {
            //20-06-2017 - Change AMSU-93 - special chars replacement
            o.Name = AMS_Utils.cleanSpecialChars(o.Name);
        }

        //REFERENCE        
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
                                order by Account__c,Created_Date_To_Show__c desc];

        for(Agency_Applied_Change_code__c agAppChangeCode : lAgAppChangeCode){
            if(!mAg_VS_AgChangeCodeFIN.containsKey(agAppChangeCode.Account__c)){
                mAg_VS_AgChangeCodeFIN.put(agAppChangeCode.Account__c,agAppChangeCode);
            }
        }
        //R3.1 - END                         
         
        lAgAppChangeCodeDEF = [SELECT Account__c,Change_Code__c,CreatedDate,Id,Created_Date_To_Show__c FROM Agency_Applied_Change_code__c 
                                where Change_Code__c = 'DEF'
                                and Account__c in :setAgencyKeys
                                order by Account__c,Created_Date_To_Show__c desc];

        for(Agency_Applied_Change_code__c agAppChangeCode : lAgAppChangeCodeDEF){
            if(!mAg_VS_AgChangeCodeDEF.containsKey(agAppChangeCode.Account__c)){
                mAg_VS_AgChangeCodeDEF.put(agAppChangeCode.Account__c,agAppChangeCode);
            }
        }

        Id formOfPaymentRTId   = Schema.Agency_Authorization__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Form Of Payment').getRecordTypeId();

/*  NEWGEN-801 */

        lAgencyAuthorizations = [SELECT Id, ANG_FormOfPayment_ID__c,Account__c from Agency_Authorization__c where Account__c in :setAgencyKeys and RecordTypeId =:formOfPaymentRTId and Status__c = 'Active' ];

        if(mAgencyAuthorizations == null)
            mAgencyAuthorizations =  new Map<Id, List<Agency_Authorization__c>>();

        for(Agency_Authorization__c aa: lAgencyAuthorizations){
            if(mAgencyAuthorizations.get(aa.Account__c) == null)
                mAgencyAuthorizations.put(aa.Account__c, new List<Agency_Authorization__c>{aa});
            else
                mAgencyAuthorizations.get(aa.Account__c).add(aa);
        }


        lAgencyRHCInfos = [SELECT Id,ANG_RHC_Amount__c, CurrencyIsoCode,ANG_AccountId__c from ANG_RHC_Information__c where ANG_AccountId__c in :setAgencyKeys];

        if(mAgencyRHCInfos == null)
            mAgencyRHCInfos =  new Map<Id, List<ANG_RHC_Information__c>>();

        for(ANG_RHC_Information__c rhcInfo: lAgencyRHCInfos){
            if(mAgencyRHCInfos.get(rhcInfo.ANG_AccountId__c) == null)
                mAgencyRHCInfos.put(rhcInfo.ANG_AccountId__c, new List<ANG_RHC_Information__c>{rhcInfo});
            else
                mAgencyRHCInfos.get(rhcInfo.ANG_AccountId__c).add(rhcInfo);
        }
/* EOF NEWGEN-801 */

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
        msObject.putAll(lAgenciesContacts);
        
        
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
        
        
        Map<String, Map<String, List<Account>>> bsp_dpc_ag = new Map<String, Map<String, List<Account>>>();
        Map<String, Map<String, List<Account>>> bsp_dpc_ag_Ordered = new Map<String, Map<String, List<Account>>>();
    
        
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
        List<Account> lAuxAgBspDpc = new List<Account>();
        Map<Id,Account> mlAuxAgBspDpc = new Map<Id,Account>();
        
        //Map agency Id with AMS_Settlement_System__c Info
        Map<Id,AggregateResult> lAgencyOperations = new Map<Id,AggregateResult>();
            
        for (AggregateResult agOp : agBspDpc) {
            
            //fill Map agency Id with AMS_Settlement_System__c
            lAgencyOperations.put((Id)agOp.get('Account__c'), agOp);
            Account auxAg = (Account)msObject.get((Id) agOp.get('Account__c') );
        
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
        }
       
        Map<Id, Account> mAg = new Map<Id, Account>(lAuxAgBspDpc);
        System.debug('mAg - '+mAg);

        //add all agencies to compare later, because not all agencies have relation with AMS_Agency_Operations__c
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
                    Map<String, List<Account>> mAuxAgDPC = bsp_dpc_ag.get(auxBSP);
                    
                    //Check DPC
                    if(mAuxAgDPC.containsKey(auxDPC)){
                        List<Account> l = mAuxAgDPC.get(auxDPC);
                        l.add(ag);
                        mAuxAgDPC.remove(auxDPC);
                        mAuxAgDPC.put(auxDPC,l);
                    }else{
                        List<Account> l = new List<Account>();
                        l.add(ag);
                        mAuxAgDPC.put(auxDPC,l);
                    }
                    
                    bsp_dpc_ag.remove(auxBSP);
                    bsp_dpc_ag.put(auxBSP,mAuxAgDPC);
                    
                }else{
                    Map<String, List<Account>> mAuxAgDPC = new Map<String, List<Account>>();
                    List<Account> l = new List<Account>();
                    l.add(ag);
                    mAuxAgDPC.put(auxDPC,l);
                    bsp_dpc_ag.put(auxBSP,mAuxAgDPC);
                }
            }
        }
        

        mAg_VS_DPCSystem = new Map<Id, String>();

        //Order the agencies in order to return on the same order they were asked!
        for(Integer i=0;i<orderedAgencyIds.size();i++){

            for(String sBSP : bsp_dpc_ag.keySet()){
                Map<String, List<Account>> mAuxAgDPC = bsp_dpc_ag.get(sBSP);

                for(String sDPC : mAuxAgDPC.keySet()){
                    List<Account> l = mAuxAgDPC.get(sDPC);

                    for(Account auxL: l){

                        //Stores the DPC System info for the agencies
                        mAg_VS_DPCSystem.put(auxL.Id, sDPC);

                        if(String.valueOf(auxL.Id).equalsIgnoreCase(orderedAgencyIds[i])){
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

        System.debug('mAg_VS_DPCSystem : ' + mAg_VS_DPCSystem);
        //System.debug('bsp_dpc_ag: ' + bsp_dpc_ag);
        //System.debug('bsp_dpc_ag_Ordered: ' + bsp_dpc_ag_Ordered);



        for(String sBSP : bsp_dpc_ag_Ordered.keySet()){            
            Map<String, List<Account>> mAuxAgDPC = bsp_dpc_ag.get(sBSP);

            for(String sDPC : mAuxAgDPC.keySet()){
                List<Account> l = mAuxAgDPC.get(sDPC);

                //get 1st agency, since all agencies must be from the same country the 1st will work!
                Account agForCtry = l[0];
                String sPasCargo = l[0].Sector__c == Null?'':l[0].Sector__c;

                //get Country related to the agency 
                IATA_ISO_Country__c ctry;
                ctry = (IATA_ISO_Country__c)msObject.get(agForCtry.IATA_ISO_Country__c);

                //BEGIN Country tag
                Dom.Xmlnode countryNode = AMS_AgenciesNode.addChildElement('country', null, null);


                getElementNode(countryNode, 'name', ctry.Name);
                getElementNode(countryNode, 'iso_code', ctry.ISO_Code__c);

                if(sPasCargo.equalsIgnoreCase('Travel Agent') ){
                    getElementNode(countryNode, 'bsp', sBSP);
                    getElementNode(countryNode, 'cass', Null);
                }else if(sPasCargo.equalsIgnoreCase('Cargo Agent') ){
                    getElementNode(countryNode, 'bsp', Null);
                    getElementNode(countryNode, 'cass', sBSP);
                }
                
                getElementNode(countryNode, 'dpc_system', sDPC);

                getElementNode(countryNode, 'hub', ctry.IATA_Regional_Office__c);

                Dom.Xmlnode filtersNode = countryNode.addChildElement('filters', null, null);
                getElementNode(filtersNode, 'name', Null);
                getElementNode(filtersNode, 'value', Null);


                //BEGIN Agencies
                Dom.Xmlnode agenciesNode = countryNode.addChildElement('agencies', null, null);
               

                //Order the agencies in order to return on the same order they were asked!
                List<Account> lAgOrdered = new List<Account>();
                Map<Id, Account> mapAgToOrder = new Map<Id, Account>(l);
                for(Integer i=0;i<orderedAgencyIds.size();i++){
                    if(mapAgToOrder.containsKey(orderedAgencyIds[i])){
                        lAgOrdered.add(mapAgToOrder.get(orderedAgencyIds[i]) );
                    }
                } 
                
                for(Integer j=0;j<lAgOrdered.size();j++){

                    Account ag = lAgOrdered[j];

                    Dom.Xmlnode agencyNode = agenciesNode.addChildElement('agency', null, null);

                    getAgencyNode(agencyNode, ag, True, False);

                    
                    Dom.Xmlnode addressNode = agencyNode.addChildElement('addresses', null, null);
                    
                    AMS_Address__c billingAdd = new AMS_Address__c();
                    

                    billingAdd.Account__c = ag.Id;
                    billingAdd.Address_Type__c = 'Billing;Primary';

                    String[] billingStreet;

                    
                    //2017-03-23 - AMSU-93
                    //billingStreet = AMS_Utils.splitAccName(ag.BillingStreet == null?'':ag.BillingStreet);
                    billingStreet = AMS_Utils.splitAccName(ag.BillingStreet == null?'':AMS_Utils.cleanSpecialChars(ag.BillingStreet));
                    
                    billingAdd.Address_1__c = billingStreet[0];
                    billingAdd.Address_2__c = billingStreet[1];
                    billingAdd.Address_3__c = billingStreet[2];

                    //2017-03-23 - AMSU-93
                    //billingAdd.City__c = ag.BillingCity;
                    billingAdd.City__c = AMS_Utils.cleanSpecialChars(ag.BillingCity);
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
                        //2017-03-23 - AMSU-93
                        //abbreviatedStreet = AMS_Utils.splitAccName(ag.Abbreviated_address__c == null ? '' : ag.Abbreviated_address__c);
                        abbreviatedStreet = AMS_Utils.splitAccName(ag.Abbreviated_address__c == null ? '' : AMS_Utils.cleanSpecialChars(ag.Abbreviated_address__c));

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

                        //2017-03-23 - AMSU-93
                        //String[] shippingStreet = AMS_Utils.splitAccName(ag.ShippingStreet == null ? '' : ag.ShippingStreet);
                        String[] shippingStreet = AMS_Utils.splitAccName(ag.ShippingStreet == null ? '' : AMS_Utils.cleanSpecialChars(ag.ShippingStreet));
                        
                        shippingAdd.Address_1__c = shippingStreet[0];
                        shippingAdd.Address_2__c = shippingStreet[1];
                        shippingAdd.Address_3__c = shippingStreet[2];

                        //2017-03-23 - AMSU-93
                        //shippingAdd.City__c = ag.ShippingCity;
                        shippingAdd.City__c = ag.ShippingCity == null ? '' : AMS_Utils.cleanSpecialChars(ag.ShippingCity);
                        
                        if(ag.ShippingState != null ){
                            if(AMS_Utils.iataIsoStates.get(ag.ShippingState.trim().toLowerCase()) != null){
                                shippingAdd.State__c = AMS_Utils.iataIsoStates.get(ag.ShippingState.trim().toLowerCase()).Id;
                            }else{
                                shippingAdd.State__c = null;
                            }                            
                        }
                            
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
                            if(add.Account__c == ag.Id){

                                if(add.Id != null){
                                    //removes ignored address types from the string
                                    for(String addressType : lIgnoredAddressTypes){
                                        add.Address_Type__c = add.Address_Type__c.replace(addressType+';', '');
                                        add.Address_Type__c = add.Address_Type__c.replace(';'+addressType, '');
                                    }
                                }

                                //2017-03-23 - AMSU-93
                                add.Address_1__c = AMS_Utils.cleanSpecialChars(add.Address_1__c);
                                add.Address_2__c = AMS_Utils.cleanSpecialChars(add.Address_2__c);
                                add.Address_3__c = AMS_Utils.cleanSpecialChars(add.Address_3__c);
                                add.City__c = AMS_Utils.cleanSpecialChars(add.City__c);
                                //if address is a valid addres, add new node.
                                if(String.isNotEmpty(add.Address_Type__c)) getObjectData(addressNode, 'AMS_Address__c', add );
                            }
                        }
                    }
                    

                    Dom.Xmlnode accountRoleNode = agencyNode.addChildElement('account_roles', null, null);
                    if(lOwnership.size() > 0){
                        for (AMS_Account_Role__c own : lOwnership) {    
                            if(own.Account__c == ag.Id){
                                getObjectData(accountRoleNode, 'AMS_Account_Role__c', own );
                            }
                        }
                    }
                    if(lEmployee.size() > 0){
                        
                        List<AMS_Account_Role__c> lEmpXML = mAg_VS_Employees.get(ag.Id);
                        
                        if(lEmpXML == Null){    //to avoid Null value
                            lEmpXML = new List<AMS_Account_Role__c>();
                        }
                        
                        for (AMS_Account_Role__c emp : lEmpXML) {
                                getObjectData(accountRoleNode, 'AMS_Account_Role__c', emp );
                        }
                    }

                    Boolean bHaveInspections = False;
                    Dom.Xmlnode inspectionNode = agencyNode.addChildElement('endorsements', null, null);

                    Agency_Applied_Change_code__c auxAgAppChangeCode = mAg_VS_AgChangeCode.get(ag.Id);

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
                            

                        Datetime dtDefault_date = ag.Default_date__c == Null ? Null : Datetime.newInstance(ag.Default_date__c.year(), ag.Default_date__c.month(),ag.Default_date__c.day());
                        getElementNode(agEndorsementNode, 'organization_last_change_date', dtDefault_date == Null ? Null : String.valueOf(dtDefault_date.format('yyyyMMdd')));

                        /*** AMSU-158 Begin ***/
                        if(String.isNotBlank(ag.Reason__c)) {
                            List<String> reasonParsed = ag.Reason__c.split('-');
                            String code = '';
                            String description = '';

                            if(!reasonParsed.isEmpty()) {
                                String firstElem = reasonParsed.remove(0);
                                if(firstElem.isNumeric()) {
                                    code = firstElem;
                                } else if(reasonParsed.isEmpty()) {
                                        reasonParsed.add(firstElem);
                                    }
                                description = String.join(reasonParsed, '-');
                            }

                            getElementNode(agEndorsementNode, 'accreditation_endorsement_reason_code',  code);
                            getElementNode(agEndorsementNode, 'accreditation_endorsement_reason_description',  description);
                        }
                        /*** AMSU-158 End ***/
                    }
                   
                    Boolean bHier = False;
                    Boolean bHierChild = False;
                    Dom.Xmlnode agRelationshipsNode = agencyNode.addChildElement('agency_relationships', null, null);
                    if(lAgRelationship.size() > 0){
                        for (AMS_Agencies_relationhip__c rel : lAgRelationship) {
                            if(rel.Parent_Account__c == ag.Id ){
                                bHier = True;
                            }
                            if(rel.Child_Account__c == ag.Id ){
                                bHierChild = True;
                            }
                        }
                    }
                
                    if(!bHier || bHierChild){
                        Account parentAg = (Account)msObject.get(mAg_VS_ParentAg.get(ag.Id));
                        
                        if(parentAg != Null){
                            Dom.Xmlnode agRelationshipNode = agRelationshipsNode.addChildElement('agencies_relationship', null, null);
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
                    }
        
                    Dom.Xmlnode profileNode = agencyNode.addChildElement('profiles', null, null);
                    if(lAgProfile.size() > 0){
                        for (AMS_Agency_Profile__c prof : lAgProfile) {
                            if(prof.Account__c == ag.Id){
                                getObjectData(profileNode, 'AMS_Agency_Profile__c', prof );
                            }
                        }
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

    public void getAgencyNode(Dom.Xmlnode agencyNode, Account agency, Boolean lookupParent, Boolean redux){
       
        Account parentAg;
        String sLang = '';

        //get "Manager" and "Ticketing Agent" First and Last Names from Person object
        AMS_Person__c oEmpPerson;
        Contact oEmpContact;

        Id iQta = Null;
        Id iQmp = Null;
        String sQtal_name = '';
        String sQtaf_name = '';
        String sQmpl_name = '';
        String sQmpf_name = '';

        if(lookupParent){
            parentAg = (Account)msObject.get(mAg_VS_ParentAg.get(agency.Id));
            if(parentAg == Null){
                parentAg = new Account();
            }
        }else{
            parentAg = new Account();
        }
     
        /*
            AMSU-79 - 
            IF DPC_System = MAESTRO we send the values...
            IF NOT DPC_System = MAESTRO we send the fields empty
        */
        String sAgDPC = mAg_VS_DPCSystem.get(agency.Id);
        


        //Get:
        // - "Manager" first and last name 
        // - "Lang"
        for(Contact auxContact : lAgenciesContacts){

            //check only the contacts belonging to the account            
            if(agency.Id == auxContact.AccountId){

                //Get "Lang" from Contact Preferred_Language__c, on 1st record with Value that is the value that will be set
                if(sLang.equalsIgnoreCase('') && auxContact.Preferred_Language__c != null){
                    if( auxContact.Preferred_Language__c.equalsIgnoreCase('English') ){
                        sLang = 'EN';
                    }
                    if( auxContact.Preferred_Language__c.equalsIgnoreCase('French') ){
                        sLang = 'FR';
                    }
                    if( auxContact.Preferred_Language__c.equalsIgnoreCase('Spanish') ){
                        sLang = 'SP';
                    } 
                }

                //Only fills Manager name when the DPC is "Maestro"
                if(sAgDPC != null && sAgDPC.equalsIgnoreCase('Maestro')){
                    //get Manager first and Last name, 1st record where Financial_Assessment_Contact__c is set to true is the one to be used
                    if( iQmp == null && auxContact.Financial_Assessment_Contact__c ){
                        iQmp = auxContact.Id;
                        
                        //FM - 24-05-2017 - AMSU-92
                        //sQmpf_name = auxContact.FirstName;
                        //sQmpl_name = auxContact.LastName;
                        sQmpf_name = 'UNKNOWN';
                        sQmpl_name = 'UNKNOWN';
                    }
                }
            }

        }


        //if no Values were returned from the contact we try to get "Lang" from Person object or contact related to the account role 
        if(sLang.equalsIgnoreCase('')){
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

            if(oPerson != null && oPerson.Language_of_correspondence__c != null && !oPerson.Language_of_correspondence__c.equalsIgnoreCase('')){
                sLang = oPerson.Language_of_correspondence__c;
            }
        }
    
        //Only fills Manager name when the DPC is "Maestro"
        if(sAgDPC != null && sAgDPC.equalsIgnoreCase('Maestro')){
                
            //Get:
            // - Manager first and Last name, but only if no manager was found on the account contacts
            // - Ticketing agent first and Last name
            // both from Person object or contact related to the account role
            for(AMS_Account_Role__c emp : lEmployee){    
                if(emp.Account__c == agency.Id){

                    if(emp.Person__c != null){
                        if(mEmp_VS_Person.containsKey(emp.Id)){
                            oEmpPerson = (AMS_Person__c) msObject.get(mEmp_VS_Person.get(emp.Id));
                        }else{
                            oEmpPerson = new AMS_Person__c();
                            oEmpPerson.First_Name__c = '';
                            oEmpPerson.Lastname__c = '';
                        }

                        if(iQmp == null && emp.isManager__c){
                            iQmp = oEmpPerson.Id;

                            //FM - 24-05-2017 - AMSU-92
                            //sQmpf_name = oEmpPerson.First_Name__c;
                            //sQmpl_name = oEmpPerson.Lastname__c;
                            sQmpf_name = 'UNKNOWN';
                            sQmpl_name = 'UNKNOWN';
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

                        if(iQmp == null && emp.isManager__c){
                            iQmp = oEmpContact.Id;

                            //FM - 24-05-2017 - AMSU-92
                            //sQmpf_name = oEmpContact.FirstName;
                            //sQmpl_name = oEmpContact.LastName;
                            sQmpf_name = 'UNKNOWN';
                            sQmpl_name = 'UNKNOWN';
                        }
                        if(emp.isTicketingAgent__c){
                            iQta = oEmpContact.Id;
                            sQtaf_name = oEmpContact.FirstName;
                            sQtal_name = oEmpContact.LastName;
                        }
                    }
                }
            }
        } 
    
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
        getElementNode(agencyNode, 'area', mAg_VS_AgArea.get(agency.Id));
        getElementNode(agencyNode, 'ams_id', agency.Id);

        if(!redux){
            //Sprint 10: removed condition for Inserting "agref" and "agxref", Now they are always inserted
            //Sprint 7: Inserting "agref" and "agxref" for Agencies with Legacy "AIMS", for now we use the legacy ID
            getElementNode(agencyNode, 'ag_ref', agency.AIMS_ID__c == Null?Null:agency.AIMS_ID__c);
            getElementNode(agencyNode, 'ag_x_ref', parentAg.AIMS_ID__c == Null?Null:parentAg.AIMS_ID__c);

        
            Id auxAgHOid = (Id)mAg_VS_HO.get(agency.Id);
            //system.debug('mAg_VS_HO-agency.Id: ' + agency.Id);
            //system.debug('mAg_VS_HO: ' + mAg_VS_HO);
            Account auxAgHO = (Account) msObject.get(auxAgHOid);
            //system.debug('auxAgHO: ' + auxAgHO);

            getElementNode(agencyNode, 'ho_id', agency.Top_Parent__r.IATACode__c != null ? agency.Top_Parent__r.IATACode__c : auxAgHO != Null ? auxAgHO.IATACode__c : Null); 
        
            //Sprint 7: Inserting "LCtryCode" in the Agencies since now we are using the "C_Code" as country code
            getElementNode(agencyNode, 'l_country_code', agency.C_Code__c);
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
        
        if(!redux){
            getElementNode(agencyNode, 'change_code', sChangeCode); 

            getElementNode(agencyNode, 'site_type', agency.Location_Type__c);

            getElementNode(agencyNode, 'air_code', agency.Airline_Code__c);
            
            //20-06-2017 - Change AMSU-93 - special chars replacement
            //List<String> lsLegalName = AMS_Utils.splitAccName(agency.Name);
            List<String> lsLegalName = AMS_Utils.splitAccName(AMS_Utils.cleanSpecialChars(agency.Name));
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.name', 'legal_1', lsLegalName[0] == ''?null:lsLegalName[0]);

            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Legal_Name_2__c', 'legal_2', lsLegalName[1] == ''?null:lsLegalName[1]);
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Legal_Name_3__c', 'legal_3', lsLegalName[2] == ''?null:lsLegalName[2]);

            //short_name
            //DECISION R3.1 - Always send "Abbreviated_name__c"
            //20-06-2017 - Change AMSU-93 - special chars replacement
            //getElementNode(agencyNode, 'short_name', agency.Abbreviated_name__c); 
            getElementNode(agencyNode, 'short_name', AMS_Utils.cleanSpecialChars(agency.Abbreviated_name__c)); 
            
            List<String> lsTradeName = Null;
            if(agency.TradeName__c != Null){
                //20-06-2017 - Change AMSU-93 - special chars replacement
                //lsTradeName = AMS_Utils.splitAccTradeName(agency.TradeName__c);
                lsTradeName = AMS_Utils.splitAccTradeName(AMS_Utils.cleanSpecialChars(agency.TradeName__c));
            }else{
                lsTradeName = new List<String>();
                lsTradeName.add(''); //1
                lsTradeName.add(''); //2 
            }
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Trading_Name_1__c', 'dba_1', lsTradeName[0] == ''?null:lsTradeName[0]);
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Trading_Name_2__c', 'dba_2', lsTradeName[1] == ''?null:lsTradeName[1]);
            

            //Sprint 7: Insert Category, replacing the "cat_1", "cat_2" and "cat_3" fields by multipick list values 
            Dom.Xmlnode nodeCat = agencyNode.addChildElement('cat', null, null);
            if(agency.Location_Category__c != Null){
                String sCatValue = agency.Location_Category__c;
                List<String> splitCat = sCatValue.split(';',0);     //split the values by ";"
                for (String s : splitCat){
                    getElementNode(nodeCat, 'cat_code', s);
                }            
            }
            
            getElementNode(agencyNode, 'pas_cgo', sPasCargo);
            
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Company_Type__c', 'co_type', agency.Company_Type__c);
            
            getElementNode(agencyNode, 'solicit', agency.GDP_Opt_In__c == True ? 'Y' : 'N');
            
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Tax_Reference_Number__c', 'tax_ref_1', agency.VAT_Number__c);
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Other_Tax_Reference_Number__c', 'tax_ref_2', agency.VAT_Number_2__c);
            
            getElementNode(agencyNode, 'bsp_code', agency.BSP_CASS_Code__c);
            
            Dom.Xmlnode nodeAffil = agencyNode.addChildElement('affil', null, null);
            String sAffil = '';
            List<String> lAffil = new List<String>();
            if(lAffiliation.size() > 0){
                for (AMS_Affiliation__c affil : lAffiliation) {
                    Id idAff = mAgAffiliation_VS_Affiliation.get(affil.Id);
                    if(idAff == agency.Id){
                        getElementNode(nodeAffil, 'affil_code', affil.Affiliation_Code__c);
                    }
                }
            }

            getElementNode(agencyNode, 'license', agency.License_Number__c);
            getElementNode(agencyNode, 'lang', getPersonLanguageOfCorrespondence(sLang) );

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
           
            getElementNode(agencyNode, 'location_class',agency.Location_Class__c);
            
            getElementNode(agencyNode, 'email',agency.Email__c);
            getElementNode(agencyNode, 'tty',agency.TTY__c);
            getElementNode(agencyNode, 'website',agency.Website);

            //getElementNode(agencyNode, 'eth_2', String.valueof(agency.BSP_CASS_Participant__c));
            getElementNode(agencyNode, 'eth_2', Null); //Empty, reserved field
            getElementNode(agencyNode, 'eth_3', Null); //Empty, reserved field

/*  NEWGEN-801 */


            //Dom.Xmlnode nodeAT = agencyNode.addChildElement('accreditation_types', null, null);
            List<String> lAT = agency.ANG_Accreditation_Model__c == null ? new List<String>() : agency.ANG_Accreditation_Model__c.split(';');

            if(!lAT.isEmpty()){
                for (String at : lAT) {
                    //getElementNode(nodeAT, 'accreditation_type', at);
                    getElementNode(agencyNode, 'accreditation_type', at);
                }
            }

            Dom.Xmlnode nodeRF = agencyNode.addChildElement('remittance_frequencies', null, null);
            List<String> lRF = agency.Remittance_frequency__c == null ? new List<String>() : agency.Remittance_frequency__c.split(';');

            if(!lRF.isEmpty()){
                for (String rf : lRF) {
                    getElementNode(nodeRF, 'remittance_frequency', rf);
                }
            }

            getElementNode(agencyNode, 'risk_status',agency.ANG_RiskStatus__c);
            getElementNode(agencyNode, 'iep_status',agency.ANG_IEP_Status_FF__c);
            getElementNode(agencyNode, 'segmentation',agency.Segmentation__c);
            getElementNode(agencyNode, 'purge_code',agency.Purge_Flag__c ? 'true' : 'false');
            getElementNode(agencyNode, 'is_branch_abroad',agency.Is_Branch_Abroad__c);


            //Authorizations Codes
            
            Dom.Xmlnode nodeAauthorizationsNode = agencyNode.addChildElement('authorizations', null, null);

            List<Agency_Authorization__c> agencyAuthl = mAgencyAuthorizations.get(agency.Id);

            if(agencyAuthl == null){

                getElementNode(nodeAauthorizationsNode, 'form_of_payment_id',null);
            
            }else{
                
                for(Agency_Authorization__c aaElem: agencyAuthl){

                    getElementNode(nodeAauthorizationsNode, 'form_of_payment_id',aaElem.ANG_FormOfPayment_ID__c);
                
                }
            }

            //Relinquishment Code
            
            Dom.Xmlnode nodeRelish = agencyNode.addChildElement('relinquishment', null, null);

            if(agency.Status__c == AMS_Utils.ACC_S0_TERMINATED){
                
                Agency_Applied_Change_code__c aacc = mAg_VS_AgChangeCode.get(agency.Id);

                if(aacc != null){
                    getElementNode(nodeRelish, 'relinquishment_codes',aacc.Reason_Code__c);
                    getElementNode(nodeRelish, 'relinquishment_description',aacc.Reason_Description__c);
                }
                else{
                    getElementNode(nodeRelish, 'relinquishment_codes',null);
                    getElementNode(nodeRelish, 'relinquishment_description',null);
                }

            }else{
                    getElementNode(nodeRelish, 'relinquishment_codes',null);
                    getElementNode(nodeRelish, 'relinquishment_description',null);
            }

            if(agency.IATA_ISO_Country__r.BSP__c == 'Yes')
                getElementNode(agencyNode, 'bsp_iso_country',agency.IATA_ISO_Country__r.BSP_Country_free_text__c);
            else
                getElementNode(agencyNode, 'bsp_iso_country',null);

            //RHC Amount
            
            Dom.Xmlnode nodeRHCAmt = agencyNode.addChildElement('rhc_information', null, null);

            List<ANG_RHC_Information__c> rhcLst = mAgencyRHCInfos.get(agency.Id);

            if(rhcLst == null){

                    getElementNode(nodeRHCAmt, 'rhc_amount',null);
                    getElementNode(nodeRHCAmt, 'currency',null);
            
            }else{
                
                for(ANG_RHC_Information__c rhcLstElem: rhcLst){

                    getElementNode(nodeRHCAmt, 'rhc_amount',String.valueOf(rhcLstElem.ANG_RHC_Amount__c));
                    getElementNode(nodeRHCAmt, 'currency',rhcLstElem.CurrencyIsoCode);
                
                }
            }

/* EOF NEWGEN-801 */
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
        if(value != null){
            auxNode.addTextNode(value);
        }

    }

    public void getElementTranslatedNode(Dom.Xmlnode node, Id iid, String strObject, String field, String value){
        Dom.Xmlnode auxNode = node.addChildElement(field, null, null);
        
        Boolean bToTranslate = sFieldsToTranslate.contains(strObject.toLowerCase()) ? True : False;
        
        if(bToTranslate){
            List<String> splitObj = strObject.toLowerCase().split('\\.',0);
            getTranslationNode(auxNode, iid, splitObj.get(0), splitObj.get(1), value);
        }else{
            if(value != null){
                auxNode.addTextNode(value);     
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

                if(strObject.equalsIgnoreCase('Account') && ft.Account__c == iid){
                    bTranslate = True;
                }else if(strObject.equalsIgnoreCase('ams_address__c') && ft.Address__c == iid){
                    bTranslate = True;
                }else if(strObject.equalsIgnoreCase('ams_agency_Hierarchy__c') && ft.Agency_Hierarchy__c == iid){
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
                    if(sObjectName.equalsIgnoreCase('iata_iso_state__c') && f.equalsIgnoreCase('iso_code_standard__c')){
                        displayFieldName = 'state_iso_code';
                    }

                    displayFieldName = getXMLTag(displayFieldName);

                    //Set the plural for some fields
                    if(displayFieldName.substring(displayFieldName.length()-1, displayFieldName.length()).equalsIgnoreCase('y')){
                        displayFieldNamePlural = displayFieldName.substring(0,displayFieldName.length()-1) + 'ies';
                    }else{
                        displayFieldNamePlural = displayFieldName + 's';
                    }
                    displayFieldNamePlural = getXMLTag(displayFieldNamePlural);

                    Schema.DisplayType FldType = M.get(f).getDescribe().getType();

                    //Validates if not Multiplicklist or Reference (Lookup), because this need to be created separetly
                    Dom.Xmlnode auxNode = null;
                    if (FldType != Schema.DisplayType.MultiPicklist && 
                        FldType != Schema.DisplayType.Reference){
                        auxNode = auxParentNode.addChildElement(displayFieldName, null, null);
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

                                        getTranslationNode(auxNodeStateName, (Id) obj.get('Id'), sObjectName, f, sAuxName );
                                        Dom.Xmlnode auxNodeCountryCode = auxParentNode.addChildElement('numeric_code', null, null);
                                        if(sCountryCode != Null){
                                            auxNodeCountryCode.addTextNode(sCountryCode );
                                        }
                                    }else 
                                        
                                    if(displayFieldName.equalsIgnoreCase('language_of_correspondence') ){ 
                                        //Sprint 7: Removed "contacts", this part was hardcoded for XSD v103 because contacts was changed from "Person" object to the "employee" Obj
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
                                    auxSplitNode.addTextNode(s);
                                }
                            
                            } else if (FldType == Schema.DisplayType.Reference){
                                
                                //Check if it's a recordtype!
                                if(f.equalsIgnoreCase('recordtypeid')){
                                    auxNode = auxParentNode.addChildElement('record_type', null, null);
                                    RecordType rt = (RecordType)msObject.get((Id)obj.get(f));

                                    auxNode.addTextNode(String.valueOf(rt.Name) );

                                }else if(f.equalsIgnoreCase('Accreditation_Endorsement_organisation__c')){ //Get org aircode from child element

                                    Dom.Xmlnode auxInspectionNode = auxParentNode.addChildElement(displayFieldName, null, null);
                                    AMS_Inspection__c x = (AMS_Inspection__c)obj;
                                    String sAuxValue = (String)x.Account__r.Main_Accreditation_Organization__c;
                                    auxInspectionNode.addTextNode(sAuxValue);

                                }else if(f.equalsIgnoreCase('Parent_Account__c')){ //Special threatment for the Parent agencies on the Hierarchy data

                                    Dom.Xmlnode auxAgencyNode = auxParentNode.addChildElement(displayFieldName, null, null);
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
                                    getTranslationNode(auxNode, (Id) obj.get('Id'), sObjectName, f, String.valueOf(obj.get(f) ));
                                }
                            }
                            
                            //Checks the below types and create the Node, since otherwise it would not be created...  
                            if (FldType == Schema.DisplayType.MultiPicklist ||
                                FldType == Schema.DisplayType.Reference){
                                auxNode = auxParentNode.addChildElement(displayFieldNamePlural, null, null);
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
                String sAuxValue = (String)x.Account__r.Main_Accreditation_Organization__c;
                
                Account ag = (Account)msObject.get(x.Account__c);

                Datetime dtOrganization_Last_Change_Date = ag.Organization_Last_Change_Date__c == Null ? Null : Datetime.newInstance(ag.Organization_Last_Change_Date__c.year(), ag.Organization_Last_Change_Date__c.month(),ag.Organization_Last_Change_Date__c.day());
                Datetime dtLast_Inspection_Date = ag.Last_Inspection_Date__c == Null ? Null : Datetime.newInstance(ag.Last_Inspection_Date__c.year(), ag.Last_Inspection_Date__c.month(),ag.Last_Inspection_Date__c.day());
                Datetime dtOriginal_Approval_DAte = ag.Original_Approval_DAte__c == Null ? Null : Datetime.newInstance(ag.Original_Approval_DAte__c.year(), ag.Original_Approval_DAte__c.month(),ag.Original_Approval_DAte__c.day());
               
                getElementNode(auxParentNode, 'last_inspection_date', dtLast_Inspection_Date == Null ? Null : String.valueOf(dtLast_Inspection_Date.format('yyyyMMdd')));
                getElementNode(auxParentNode, 'original_approval_date', dtOriginal_Approval_DAte == Null ? Null : String.valueOf(dtOriginal_Approval_DAte.format('yyyyMMdd')));
                getElementNode(auxParentNode, 'organization_last_change_date', dtOrganization_Last_Change_Date == Null ? Null : String.valueOf(dtOrganization_Last_Change_Date.format('yyyyMMdd')));
            }       

        } catch (SObjectException e)    { 
            System.Debug('----getObjectData SObjectException e:'+ e);
        } 
    }


    /*** AMSU-158 ***/
    public class NotificationsSender implements Queueable {
        public Set<Account> accounts {get;set;}

        public NotificationsSender(Set<Account> accounts) {
            this.accounts = accounts;
        }

        public void execute(QueueableContext context) {
            String body = 'Id, Reason\n';
            for(Account acc : accounts) {
                body += acc.Id + ',' + (String.isBlank(acc.Reason__c) ? '' : acc.Reason__c).escapeCSV() + '\n';
            }

            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            Blob csvReport = Blob.valueOf(body);
            csvAttc.setFileName('XML Generator errors report.csv');
            csvAttc.setBody(csvReport);

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.subject = 'XML Generator errors report';
            message.setPlainTextBody('XML Generator errors - Check attachment with execution results - ' + DateTime.now());
            message.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};        
            
            if(!Test.isRunningTest() && !String.isBlank(Label.AMS_XML_GEN_ERROR_RECEIVER)) {
                List<String> emailAddresses = Label.AMS_XML_GEN_ERROR_RECEIVER.split(';');
                message.setToaddresses(emailAddresses);
                Messaging.sendEmail(messages);
            }
        }
    }

}