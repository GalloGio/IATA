public with sharing class AMS_XML_Generator {
    
    public List<RecordType> lRecordType;

    //Map that will store all referenced objects
    public Map<Id, sObject> msObject;

    public Map<String,AMS_WAD_Settings__c> mWadNameValues;
    public Map<String,AMS_WAD_Settings__c> mWadFieldValues;

    public Map<String,String> mXMLTagValues;
    public Map<String,String> mXMLFieldValues;

    public Map<Id, AMS_Agency_Updates__c> mAg_VS_AgUpdate;
    public Map<Id, String> mAg_VS_AgArea;
    public Map<Id, String> mAg_VS_AgSiteType;
    public Map<Id, Id> mAg_VS_ParentAg;
    public Map<Id, Id> mAgComputerReservation_VS_ComputerReservation;
    public Map<Id, Id> mAgAirport_VS_Airport;
    public Map<Id, Id> mAgAffiliation_VS_Affiliation;
    public Map<Id, Id> mAg_VS_Person;
    public Map<Id, Id> mEmp_VS_Person;
    public Map<Id, AMS_Agency__c> mAg_VS_Agency;
    public Map<Id, String> mAg_VS_Segment;
    public Map<Id, List<AMS_Employee__c>> mAg_VS_Employees;
    public Map<Id, Id> mAg_VS_HO;

    public List<AMS_Agency_Updates__c> lAgencyUpdates;      
    public List<AMS_Address__c> lAgencyArea;
    public List<AMS_Address__c> lAddresses;
    public List<IATA_ISO_Country__c> lCountry;
    public List<IATA_ISO_State__c> lState;
    public List<AMS_Agency_Ownership__c> lOwnership;
    public List<AMS_Owner__c> lOwner;
    public List<Account> lAccount;
    public List<Contact> lContact;
    public List<User> lUser;
    public List<AMS_Person__c> lPerson;
    public List<AMS_Employee__c> lEmployee;
    //JFO 13/8/2015  deleted for new DM without GDS custom object
    //public List<AMS_Agency_Computer_Reservation__c> lAgComputerReservation;
    //public List<AMS_Computer_Reservation_System__c> lComputerReservation;
    public List<AMS_Inspection__c> lInspection;
    public List<AMS_Agencies_relationhip__c> lAgRelationship;
    public List<AMS_Agencies_relationhip__c> lAgRelationshipParent;
    public List<AMS_Agencies_relationhip__c> lAgRelationshipChild;
    public List<AMS_Agency__c> lAgRelationshipHierarchy;
    public List<AMS_Agencies_Hierarchy__c> lAgHierarchy;
    public List<AMS_Agency_Airport__c> lAgAirport;
    public List<AMS_Airport__c> lAirport;
    public List<AMS_Agency_Profile__c> lAgProfile;
    public List<AMS_Agency_Affiliation__c> lAgAffiliation;
    public List<AMS_Affiliation__c> lAffiliation;
    public List<AMS_Fields_Translation__c> lFieldsTranslation;
    public List<AMS_Agency_Segment__c> lAgSegment;
    
    
    Boolean bSetFields = False;
    SET<String> sFieldsToTranslate = new SET<String>();
    SET<String> sFieldsToInclude = new SET<String>();
    SET<String> sFieldsToExclude = new SET<String>();

    public String sDebug = '';
    
    //CONSTRUCTOR                                            
    public AMS_XML_Generator() {

        //Get values from Custom Setting Object - AMS_WAD_Settings__c
        /*
        if(mWadNameValues == null) {
            mWadNameValues = new Map<String,AMS_WAD_Settings__c>();
            mWadFieldValues = new Map<String,AMS_WAD_Settings__c>();
            for (AMS_WAD_Settings__c wadSett : [SELECT Name, Field__c, Size__c, Position__c FROM AMS_WAD_Settings__c]) {
                mWadNameValues.put(wadSett.Name.toLowerCase(), wadSett);  
                mWadFieldValues.put(wadSett.Field__c == null ? '' : wadSett.Field__c.toLowerCase(), wadSett);   
            }
        } else {
            mWadNameValues = new Map<String,AMS_WAD_Settings__c>();
            mWadFieldValues = new Map<String,AMS_WAD_Settings__c>();
        } 
        */

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

    }

    //Get XML for AgencyList to send to AW WS (1º step)
    public String getAgencyList(List<String> agenciesIDs, String groupBy, String indicator, String[] headerParams){

        //Begin of XML tags
        Dom.Document doc = new Dom.Document();
    
        Dom.Xmlnode rootNode = doc.createRootElement('AgencyList', null, null);

        //Header Section
        Dom.Xmlnode headerNode = rootNode.addChildElement('Header', null, null);

        getElementNode(headerNode, 'PreviousID', headerParams[0]);
        getElementNode(headerNode, 'GroupID', headerParams[1]);
        getElementNode(headerNode, 'ChunkSize', headerParams[2]);
        getElementNode(headerNode, 'ChunkKey', headerParams[3]);
        getElementNode(headerNode, 'ChunkTotal', headerParams[4]);

        //Agency Section
        

        for(String agId : agenciesIDs){
            Dom.Xmlnode agNode = rootNode.addChildElement('Agency', null, null);

            getElementNode(agNode, 'AgencyID', agId);
            getElementNode(agNode, 'GroupBy', groupBy);
            getElementNode(agNode, 'Indicator', indicator);

        }

        system.debug('--------- doc: ' + doc.toXmlString());        
        return doc.toXmlString();   

    }

    //Get XML for Agency SalesOrder to send to AW WS 
    public String getAgencySalesOrder(AMS_Agency__c agency){
    
        List<AMS_Agency__c> lAg = new List<AMS_Agency__c>();
        lAg.add(agency);

        return getAgencySalesOrder(lAg);

    }

    //Get XML for Agency SalesOrder to send to AW WS 
    public String getAgencySalesOrder(List<AMS_Agency__c> agencies){

        //Begin of XML tags
        Dom.Document doc = new Dom.Document();
    
        Dom.Xmlnode rootNode = doc.createRootElement('sales_orders', null, null);

        //Header Section
        //Dom.Xmlnode headerNode = rootNode.addChildElement('Header', null, null);

        //getElementNode(headerNode, 'PreviousID', headerParams[0]);
        //getElementNode(headerNode, 'GroupID', headerParams[1]);
        //getElementNode(headerNode, 'ChunkSize', headerParams[2]);
        //getElementNode(headerNode, 'ChunkKey', headerParams[3]);
        //getElementNode(headerNode, 'ChunkTotal', headerParams[4]);

        //Agency Section
        
        Date dToday = Date.today();
        Datetime dtToday = Datetime.now(); // Returns the current Datetime based on a GMT calendar.

        for(AMS_Agency__c ag : agencies){
            Dom.Xmlnode liNode = rootNode.addChildElement('line_item', null, null);

            getElementNode(liNode, 'agency_id', ag.Id);
            getElementNode(liNode, 'hub', ag.Country__r.IATA_Regional_Office__c);
            getElementNode(liNode, 'period_from', dtToday.format('yyyyMMdd'));
            getElementNode(liNode, 'period_to', dtToday.format('yyyyMMdd'));
            getElementNode(liNode, 'product_id', ag.Location_Class__c + 'NEW');
            getElementNode(liNode, 'quantity', '1');

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
        
        mHeaderValues.put('copymsg', '(C) International Air Transport Association (IATA) 2015. All rights reserved. No part of this file may be reproduced, stored in a retrieval system or transmitted in any form or by any means without prior permission from IATA.');
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
    public String getAgencyDetail(AMS_Agency__c agency, String[] r){

        List<AMS_Agency__c> lAg = new List<AMS_Agency__c>();
        lAg.add(agency);

        return getAgencyDetail(lAg, r);
    }

    //Get XML for AgencyDetail to send to AW WS (2º step)
    public String getAgencyDetail(List<AMS_Agency__c> agency, String[] r){
        Integer inicioCPU = Limits.getCpuTime();
        Integer inicioCPUx = Limits.getLimitCpuTime();
        
        //Map that will store all referenced objects
        msObject = new Map<Id, sObject>();

        mAg_VS_AgUpdate = new Map<Id, AMS_Agency_Updates__c>();
        mAg_VS_AgArea = new Map<Id, String>();
        mAg_VS_AgSiteType = new Map<Id, String>();
        mAg_VS_ParentAg = new Map<Id, Id>();
        mAgComputerReservation_VS_ComputerReservation = new Map<Id, Id>();
        mAgAirport_VS_Airport = new Map<Id, Id>();
        mAgAffiliation_VS_Affiliation = new Map<Id, Id>();
        mAg_VS_Person = new Map<Id, Id>();
        mEmp_VS_Person = new Map<Id, Id>();
        mAg_VS_Segment = new Map<Id, String>();
        mAg_VS_Employees = new Map<Id, List<AMS_Employee__c>>();
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
        
        //Get AMS_Segment__c RecordType ID for "IATA Code Programs"
        Id rtProgram = Schema.SObjectType.AMS_Segment__c.getRecordTypeInfosByName().get('IATA Code Programs').getRecordTypeId();
        //Get AMS_Agencies_Hierarchy__c RecordType ID for "MAIN"
        Id rtHierarchy = Schema.SObjectType.AMS_Agencies_Hierarchy__c.getRecordTypeInfosByName().get('MAIN').getRecordTypeId();

        System.debug('XML Generator - Requested Agencies from MDM PI - ' + agency);
        sDebug += '\nAgencies List:' + agency;
        
        //Get agenc
        //for (AMS_Agency__c ag : agency) {
        //    if(ag.Id != Null){
        //      setAgencyKeys.add(ag.Id);
        //    }
        //}
        setAgencyKeys = (new Map<Id,AMS_Agency__c>(agency)).keySet();

        //System.debug('XML Generator - setAgencyKeys - ' + setAgencyKeys);

        for (AMS_Agency__c o : agency) {
            setAccountKeys.add(o.Account__c);
            setAgencyCountryKeys.add(o.Country__c);
        }
        
        //MAIN
        lAgencyUpdates = [SELECT Agency__c,Id,Name,RelationShip__c,Update_Type__c 
                            FROM AMS_Agency_Updates__c
                            where Agency__c in :setAgencyKeys];

        for (AMS_Agency_Updates__c agUpd : lAgencyUpdates) {
            mAg_VS_AgUpdate.put(agUpd.Agency__c,agUpd);
        }
        
       //Reference
        lAgSegment = [SELECT Agency__c,Assignation_Type__c,Id,Name,Segment__c,Segment__r.label__c 
                            FROM AMS_Agency_Segment__c
                            where Segment__r.RecordTypeid = :rtProgram
                            and Agency__c in :setAgencyKeys];

        for (AMS_Agency_Segment__c agSeg : lAgSegment) {
            mAg_VS_Segment.put(agSeg.Agency__c,agSeg.Segment__r.label__c);
        }

        //MAIN
        lAgencyArea = [SELECT Agency__c,Site_type__c,Country__r.AIMS_Area_ID__c 
                            FROM AMS_Address__c
                            where Agency__c in :setAgencyKeys];

        for (AMS_Address__c agArea : lAgencyArea) {
            mAg_VS_AgArea.put(agArea.Agency__c,String.valueOf(agArea.Country__r.AIMS_Area_ID__c) );
            mAg_VS_AgSiteType.put(agArea.Agency__c,String.valueOf(agArea.Site_type__c) );
        }

        //MAIN - 
        lAddresses = [SELECT Address_1__c,Address_2__c,Address_3__c,Agency__c,Address_Type__c,TTY__c,
                                    AMS_ZipCode__c,City__c,Country_postal_abbreviation__c,Country__c,Email__c,
                                    Id,Legacy_External_ID__c,Legacy_System__c,Name,Site_type__c,State__c,
                                    Telephone__c,Telephone_Int__c,Telephone_STD__c,
                                    Fax__c,Fax_Int__c,Fax_STD__c,
                                    Mobile__c,Mobile_Int__c,Mobile_STD__c,
                                    Website__c,Country__r.Id,State__r.Id
                                    FROM AMS_Address__c 
                                    where Agency__c in :setAgencyKeys];

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
        lState = [SELECT Name,ISO_Code__c FROM IATA_ISO_State__c where Id in :setAddressStateKeys];

        //MAIN
        lOwnership = [SELECT Agency__c,AMS_Agency_Owner__c,Id,Name,Percentage__c FROM AMS_Agency_Ownership__c WHERE Agency__c in :setAgencyKeys];
        
        for (AMS_Agency_Ownership__c o : lOwnership) {
            setOwnershipKeys.add(o.AMS_Agency_Owner__c);
        }

        //REFERENCE
        lOwner = [SELECT Account__c,Id,Name,Person__c FROM AMS_Owner__c WHERE Id in :setOwnershipKeys];
        
        for (AMS_Owner__c o : lOwner) {
            setAccountKeys.add(o.Account__c);
            if(o.Person__c != Null){
                setPersonKeys.add(o.Person__c);
            }
        }

        //MAIN
        lEmployee = [SELECT Agency__c,DUTY__c,Earning__c,Employee_type__c,Hours__c,Id,isManager__c,isTicketingAgent__c,
                    Name,Person__c,Position__c,Registration_Date__c,Stage__c,Start_date__c,
                    Termination_Date__c,Title__c,Valid__c, Last_synchronization__c 
                    FROM AMS_Employee__c WHERE Agency__c in :setAgencyKeys and (isManager__c = True OR isTicketingAgent__c = True ) limit 100];

        for (AMS_Employee__c emp : lEmployee) {
            setEmployeeKeys.add(emp.Id);
            if(emp.Person__c != Null){
                setPersonKeys.add(emp.Person__c);
            }
            mEmp_VS_Person.put(emp.Id, emp.Person__c);
            if(!mAg_VS_Person.containsKey(emp.Agency__c)){
                mAg_VS_Person.put(emp.Agency__c, emp.Person__c);
            }
            
            if(mAg_VS_Employees.containsKey(emp.Agency__c)){
                List<AMS_Employee__c> lEmp = mAg_VS_Employees.get(emp.Agency__c);
                lEmp.add(emp);
                mAg_VS_Employees.remove(emp.Agency__c);
                mAg_VS_Employees.put(emp.Agency__c, lEmp);
            }else{
                List<AMS_Employee__c> lEmp = new List<AMS_Employee__c>();
                lEmp.add(emp);
                mAg_VS_Employees.put(emp.Agency__c, lEmp);
            }
        }

        
        //MAIN
        lInspection = [SELECT Accreditation_Endorsement_Status_code__c, Accreditation_Endorsement_organisation__r.Air_Code__c,
                        Date_Organisation_Status_attained__c,Id,Name,Agency__c,Agency__r.Organization_Last_Change_Date__c, 
                        Agency__r.Last_Inspection_Date__c,Agency__r.Original_Approval_DAte__c,Agency__r.Location_Class__c                        
                        FROM AMS_Inspection__c WHERE Agency__c in :setAgencyKeys];

        //MAIN
        lAgRelationship = [SELECT Parent_agency__c,Child_Agency__c,Hierarchy__c,HO_Flag__c,Id,Name,Relationship_details__c 
                    FROM AMS_Agencies_relationhip__c WHERE Child_Agency__c in :setAgencyKeys AND Hierarchy__r.RecordTypeId = :rtHierarchy];
                       
       
        for (AMS_Agencies_relationhip__c rel : lAgRelationship) {
            setHierarchyKeys.add(rel.Hierarchy__c);
            //COMENT on SPRINT 5
            //setAgRelationshipKeys.add(rel.Child_Agency__c);

            setAgRelationshipKeys.add(rel.Parent_agency__c);
            mAg_VS_ParentAg.put(rel.Child_Agency__c, rel.Parent_agency__c);
        }

        //REFERENCE
        lAgRelationshipHierarchy = [SELECT Account__c,Administrator__c,Airline_Code__c,
                    A_Code__c,BSP_Code__c,CASS_Number__c,Chk_Dgt__c,
                    Company_Type__c,C_Code__c,DPC_Operation__c,IATACode__c,Id,
                    Last_Inspection_Date__c,Legacy_External_ID__c,
                    Legacy_System__c,Legal_Name_2__c,Legal_Name_3__c,License_Number__c,
                    Location_Category__c,Location_Class__c,Name,GDS__c,
                    N_Code__c,Organization_Last_Change_Date__c,
                    Original_Approval_DAte__c,Other_Tax_Reference_Number__c,OwnerId,
                    Parent_Reference_Number__c,Phone_Number__c,Primary_address__c,
                    Recert_Expiry_Date__c,RecordTypeId,RecordType.name,
                    Reference_Number__c,STD_Code__c,SystemModstamp,Tax_Reference_Number__c,
                    Trading_Name_1__c,Trading_Name_2__c,Unique_ID__c,Verification_Date__c 
                    FROM AMS_Agency__c where id in :setAgRelationshipKeys];

        //REFERENCE                    
        lAgHierarchy = [SELECT Hierarchy_Name__c,Id,Name,RecordTypeId 
                        FROM AMS_Agencies_Hierarchy__c WHERE Id in :setHierarchyKeys
                        AND RecordTypeId = :rtHierarchy];
        
        Map<Id,Id> mHier_VS_HO;
        mHier_VS_HO = new Map<Id,Id>();

        //Get HO (Head Office) Id
        List<AggregateResult> lAgHO = [SELECT Parent_agency__c, Hierarchy__c FROM AMS_Agencies_relationhip__c 
                    where Hierarchy__c in :setHierarchyKeys
                    and HO_Flag__c = 'True' AND Hierarchy__r.RecordTypeId = :rtHierarchy
                    group by Parent_agency__c, Hierarchy__c ];
        for(AggregateResult agHO : lAgHO){
            mHier_VS_HO.put((Id)agHO.get('Hierarchy__c') ,(Id)agHO.get('Parent_agency__c'));   
        }
        for (AMS_Agencies_relationhip__c agR : lAgRelationship) {
            mAg_VS_HO.put((Id)agR.Child_Agency__c, (Id)mHier_VS_HO.get(agR.Hierarchy__c));
        }

        //MAIN
        lAgAirport = [SELECT Airport__c,Agency__c FROM AMS_Agency_Airport__c WHERE Agency__c in :setAgencyKeys];

        for (AMS_Agency_Airport__c airp : lAgAirport) {
            setAirportKeys.add(airp.Airport__c);
            mAgAirport_VS_Airport.put(airp.Airport__c,airp.Agency__c);
        }

        //REFERENCE
        lAirport = [SELECT City__c,Code__c,Country__c,Id,Name FROM AMS_Airport__c
                    WHERE id in :setAirportKeys];

        //MAIN
        lAgAffiliation = [SELECT Affiliation__c,Agency__c FROM AMS_Agency_Affiliation__c WHERE Agency__c in :setAgencyKeys];

        for (AMS_Agency_Affiliation__c affil : lAgAffiliation) {
            setAffiliationKeys.add(affil.Affiliation__c);
            mAgAffiliation_VS_Affiliation.put(affil.Affiliation__c,affil.Agency__c);
        }

        //REFERENCE
        lAffiliation = [SELECT Affiliation_Code__c,Id,Name FROM AMS_Affiliation__c
                    WHERE id in :setAffiliationKeys];            

        //MAIN
        lAgProfile = [SELECT GR_Code__c,GR_Item__c,Id,Name,Agency__c FROM AMS_Agency_Profile__c 
                    WHERE Agency__c in :setAgencyKeys];

        //REFERENCE                  
        lAccount = [SELECT Id,Name,Short_Name__c FROM Account WHERE Id in :setAccountKeys];

        //REFERENCE        
        //Sprint 7: removed "Contact__c,User__c, User__r.Name"
        lPerson = [SELECT Email__c,First_Name__c,Id,
                        Language_of_correspondence__c,
                        Lastname__c,Last_Case_Assigned_Date_Time__c,
                        Logged_on__c,Log_on_picklist__c,Maximum_cases_at_one_time__c,Maximum_case_workload__c,
                        Name,Next_case_request_date_time__c,Phone__c,Region__c,Request_next_case__c 
                        FROM AMS_Person__c WHERE Id in :setPersonKeys]; //Contact__c,Contact__r.Name,
        
        //Sprint 7: "User__c" was removed from the Person data... 
        //for (AMS_Person__c p : lPerson) {
        //    //setContactKeys.add(p.Contact__c);
        //    setUserKeys.add(p.User__c);
        //}

        //Sprint 7: "Contact__c" was removed from the Person data... 
        //for(Contact c: [select id, Name, Person__c from Contact where Person__c In :setPersonKeys]){
        //    setContactKeys.add(c.id);
        //}

        //REFERENCE                        
        //Sprint 7: "Contact__c" was removed from the Person data... 
        //lContact = [SELECT Id,Name FROM Contact WHERE Id in :setContactKeys];                       

        //REFERENCE       
        //Sprint 7: "User__c" was removed from the Person data...                  
        //lUser = [SELECT Id,Name FROM User WHERE Id in :setUserKeys];                    
       
        //MAIN
        lFieldsTranslation = [SELECT Address__c,Agency_Hierarchy__c,Agency__c,AMSAirport__c,AMSEmployee__c,AMSOwner__c,
                                    AMSPerson__c,Contact__c,Field_name__c,IATA_ISO_Country__c,
                                    IATA_ISO_State__c,Id,Language__c,Name,Translation__c,User__c 
                                    FROM AMS_Fields_Translation__c 
                                    where (Agency__c in :setAgencyKeys
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
        //msObject.putAll(lContact);
        //msObject.putAll(lUser);
        
        
        //Header Values
        Map<String, String> mHeaderValues = new Map<String, String>();
        Date dToday = Date.today();
        Datetime dtToday = Datetime.now(); // Returns the current Datetime based on a GMT calendar.
        
        mHeaderValues.put('copymsg', '(C) International Air Transport Association (IATA) 2015. All rights reserved. No part of this file may be reproduced, stored in a retrieval system or transmitted in any form or by any means without prior permission from IATA.');
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
        
        
        
        Map<String, Map<String, List<AMS_Agency__c>>> bsp_dpc_ag = new Map<String, Map<String, List<AMS_Agency__c>>>();
        
        //List<AggregateResult> agBspDpc = [SELECT Agency__c,Operation__r.Settlement__r.Name, Operation__r.Settlement__r.DPC__c
        //                                            FROM AMS_Agency_Operations__c where Agency__c in :setAgencyKeys 
        //                                            group by Agency__c,Operation__r.Settlement__r.Name, Operation__r.Settlement__r.DPC__c 
        //                                            order by Operation__r.Settlement__r.Name, Operation__r.Settlement__r.DPC__c];

        String sPasCargo = agency[0].RecordType.Name;
        List<AggregateResult> agBspDpc = new List<AggregateResult>();
        if(sPasCargo.equalsIgnoreCase('PASSENGER') ){
            agBspDpc = [SELECT id Agency__c,Country__r.name,
                                            Country__r.AMS_Settlement_System__r.name bsp,
                                            Country__r.AMS_Settlement_System__r.DPC_System__c dpc
                                        FROM AMS_Agency__c where id in :setAgencyKeys 
                                        group by id, Country__r.name,
                                            Country__r.AMS_Settlement_System__r.name,
                                            Country__r.AMS_Settlement_System__r.DPC_System__c];
        }else{
            agBspDpc = [SELECT id Agency__c, Country__r.name,
                                            Country__r.AMS_Settlement_System_CASS__r.name bsp,
                                            Country__r.AMS_Settlement_System_CASS__r.DPC_System__c dpc
                                            FROM AMS_Agency__c where id in :setAgencyKeys 
                                            group by id, Country__r.name,
                                            Country__r.AMS_Settlement_System_CASS__r.name,
                                            Country__r.AMS_Settlement_System_CASS__r.DPC_System__c];
        }
       
        String auxBSP = '';
        String auxDPC = '';
        List<AMS_Agency__c> lAuxAgBspDpc = new List<AMS_Agency__c>();
        Map<Id,AMS_Agency__c> mlAuxAgBspDpc = new Map<Id,AMS_Agency__c>();
        
        //Map agency Id with AMS_Settlement_System__c Info
        Map<Id,AggregateResult> lAgencyOperations = new Map<Id,AggregateResult>();
            
        for (AggregateResult agOp : agBspDpc) {
            
            //fill Map agency Id with AMS_Settlement_System__c
            lAgencyOperations.put((Id)agOp.get('Agency__c'), agOp);
                
            AMS_Agency__c auxAg = (AMS_Agency__c)msObject.get((Id) agOp.get('Agency__c') );
      
            auxBSP = agOp.get('bsp') == Null ? 'null' : (String)agOp.get('bsp');
            auxDPC = agOp.get('dpc') == Null ? 'null' : (String)agOp.get('dpc');
      
            //add all agencies to compare later, because not all agencies have relation with AMS_Agency_Operations__c
            if(!mlAuxAgBspDpc.containsKey(auxAg.Id)){
                lAuxAgBspDpc.add(auxAg);
                mlAuxAgBspDpc.put(auxAg.Id,auxAg);
            }
            
            //Check BSP
            if(bsp_dpc_ag.containsKey(auxBSP)){
                Map<String, List<AMS_Agency__c>> mAuxAgDPC = bsp_dpc_ag.get(auxBSP);
                
                //Check DPC
                if(mAuxAgDPC.containsKey(auxDPC)){
                    List<AMS_Agency__c> l = mAuxAgDPC.get(auxDPC);
                    l.add(auxAg);
                    mAuxAgDPC.remove(auxDPC);
                    mAuxAgDPC.put(auxDPC,l);
                }else{
                    List<AMS_Agency__c> l = new List<AMS_Agency__c>();
                    l.add(auxAg);
                    mAuxAgDPC.put(auxDPC,l);
                }
                
                bsp_dpc_ag.remove(auxBSP);
                bsp_dpc_ag.put(auxBSP,mAuxAgDPC);
                
            }else{
                Map<String, List<AMS_Agency__c>> mAuxAgDPC = new Map<String, List<AMS_Agency__c>>();
                List<AMS_Agency__c> l = new List<AMS_Agency__c>();
                l.add(auxAg);
                mAuxAgDPC.put(auxDPC,l);
                bsp_dpc_ag.put(auxBSP,mAuxAgDPC);
            }
           
        }
       
        Map<Id, AMS_Agency__c> mAg = new Map<Id, AMS_Agency__c>(lAuxAgBspDpc);


        //add all agencies to compare later, because not all agencies have relation with AMS_Agency_Operations__c
        for (AMS_Agency__c ag : agency) {

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
                    Map<String, List<AMS_Agency__c>> mAuxAgDPC = bsp_dpc_ag.get(auxBSP);
                    
                    //Check DPC
                    if(mAuxAgDPC.containsKey(auxDPC)){
                        List<AMS_Agency__c> l = mAuxAgDPC.get(auxDPC);
                        l.add(ag);
                        mAuxAgDPC.remove(auxDPC);
                        mAuxAgDPC.put(auxDPC,l);
                    }else{
                        List<AMS_Agency__c> l = new List<AMS_Agency__c>();
                        l.add(ag);
                        mAuxAgDPC.put(auxDPC,l);
                    }
                    
                    bsp_dpc_ag.remove(auxBSP);
                    bsp_dpc_ag.put(auxBSP,mAuxAgDPC);
                    
                }else{
                    Map<String, List<AMS_Agency__c>> mAuxAgDPC = new Map<String, List<AMS_Agency__c>>();
                    List<AMS_Agency__c> l = new List<AMS_Agency__c>();
                    l.add(ag);
                    mAuxAgDPC.put(auxDPC,l);
                    bsp_dpc_ag.put(auxBSP,mAuxAgDPC);
                }
            }
        }

        for(String sBSP : bsp_dpc_ag.keySet()){
            Map<String, List<AMS_Agency__c>> mAuxAgDPC = bsp_dpc_ag.get(sBSP); 
            for(String sDPC : mAuxAgDPC.keySet()){
                List<AMS_Agency__c> l = mAuxAgDPC.get(sDPC);

                //get 1st agency, since all agencies must be from the same country the 1st will work!
                AMS_Agency__c agForCtry = l[0];

                //get Country related to the agency 
                IATA_ISO_Country__c ctry;
                ctry = (IATA_ISO_Country__c)msObject.get(agForCtry.Country__c);

                //BEGIN Country tag
                Dom.Xmlnode countryNode = AMS_AgenciesNode.addChildElement('country', null, null);

                getElementNode(countryNode, 'name', ctry.Name);

                if(sPasCargo.equalsIgnoreCase('PASSENGER') ){
                    getElementNode(countryNode, 'bsp', sBSP);
                    getElementNode(countryNode, 'cass', Null);
                }else{
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
               
                //agenciesNode.setAttribute('bsp', sBSP.equalsIgnoreCase('null') ? '' : sBSP);
                //agenciesNode.setAttribute('dpc', sDPC.equalsIgnoreCase('null') ? '' : sDPC);
                //}catch(Exception e){
                //    myvariable += 'bsp_dpc_ag.keySet(): ' + bsp_dpc_ag.keySet();
                //    myvariable += '\n|| sBSP: ' + sBSP;
        
                //    throw new transformationException( ' ' + myvariable);
                //}

                for (AMS_Agency__c ag : l) {

                    Dom.Xmlnode agencyNode = agenciesNode.addChildElement('agency', null, null);
                    getAgencyNode(agencyNode, ag, True, False);
                
                    
                    Dom.Xmlnode addressNode = agencyNode.addChildElement('addresses', null, null);
                    if(lAddresses.size() > 0){
                        for (AMS_Address__c add : lAddresses) {
                            if(add.Agency__c == ag.Id){
                                getObjectData(addressNode, 'AMS_Address__c', add );
                            }
                            
                
                        }
                    //}else{
                        //addressNode.addTextNode('Missing');
                    }
                    
                    Dom.Xmlnode ownershipNode = agencyNode.addChildElement('agency_ownerships', null, null);
                    if(lOwnership.size() > 0){
                        for (AMS_Agency_Ownership__c own : lOwnership) {
                            if(own.Agency__c == ag.Id){
                                getObjectData(ownershipNode, 'AMS_Agency_Ownership__c', own );
                            }
                        }
                    //}else{
                        //ownershipNode.addTextNode('Missing');
                    }
                    
                    Dom.Xmlnode employeesNode = agencyNode.addChildElement('employees', null, null);
                    if(lEmployee.size() > 0){
                        
                        List<AMS_Employee__c> lEmpXML = mAg_VS_Employees.get(ag.Id);
                        
                        if(lEmpXML == Null){    //to avoid Null value
                            lEmpXML = new List<AMS_Employee__c>();
                        }
                        
                        for (AMS_Employee__c emp : lEmpXML) {
                                getObjectData(employeesNode, 'AMS_Employee__c', emp );
                        }
                    //}else{
                        //employeesNode.addTextNode('Missing');
                    }
        
                    Boolean bHaveInspections = False;
                    Dom.Xmlnode inspectionNode = agencyNode.addChildElement('inspections', null, null);
                    if(lInspection.size() > 0){
                        for (AMS_Inspection__c insp : lInspection) {
                            if(insp.Agency__c == ag.Id){                
                                bHaveInspections = True;
                                getObjectData(inspectionNode, 'AMS_Inspection__c', insp );
                            }
                        }
    
                        if(bHaveInspections){
                            Datetime dtOrganization_Last_Change_Date = ag.Organization_Last_Change_Date__c == Null ? Null : Datetime.newInstance(ag.Organization_Last_Change_Date__c.year(), ag.Organization_Last_Change_Date__c.month(),ag.Organization_Last_Change_Date__c.day());
                            Datetime dtLast_Inspection_Date = ag.Last_Inspection_Date__c == Null ? Null : Datetime.newInstance(ag.Last_Inspection_Date__c.year(), ag.Last_Inspection_Date__c.month(),ag.Last_Inspection_Date__c.day());
                            Datetime dtOriginal_Approval_DAte = ag.Original_Approval_DAte__c == Null ? Null : Datetime.newInstance(ag.Original_Approval_DAte__c.year(), ag.Original_Approval_DAte__c.month(),ag.Original_Approval_DAte__c.day());
                           
                            getElementNode(inspectionNode, 'last_inspection_date', dtLast_Inspection_Date == Null ? Null : String.valueOf(dtLast_Inspection_Date.format('yyyyMMdd')));
                            getElementNode(inspectionNode, 'location_class', mAg_VS_Segment.get(ag.Id));
                            getElementNode(inspectionNode, 'original_approval_date', dtOriginal_Approval_DAte == Null ? Null : String.valueOf(dtOriginal_Approval_DAte.format('yyyyMMdd')));
                            getElementNode(inspectionNode, 'organization_last_change_date', dtOrganization_Last_Change_Date == Null ? Null : String.valueOf(dtOrganization_Last_Change_Date.format('yyyyMMdd')));
                            
                        }

                    //}else{
                    //    inspectionNode.addTextNode('Missing');
                    }
                    
                    Boolean bHier = False;
                    Dom.Xmlnode agRelationshipsNode = agencyNode.addChildElement('agency_relationships', null, null);
                    if(lAgRelationship.size() > 0){
                        for (AMS_Agencies_relationhip__c rel : lAgRelationship) {
                            //if(rel.Parent_agency__c == ag.Id || rel.Child_Agency__c == ag.Id){
                            if(rel.Parent_agency__c == ag.Id ){
                                bHier = True;
                                getObjectData(agRelationshipsNode, 'AMS_Agencies_relationhip__c', rel );
                            }
                        }
                    //}else{
                    //    agRelationshipsNode.addTextNode('Missing');
                    }
                    if(!bHier){
                        AMS_Agency__c parentAg = (AMS_Agency__c)msObject.get(mAg_VS_ParentAg.get(ag.Id));
                        
                        Dom.Xmlnode agRelationshipNode = agRelationshipsNode.addChildElement('agencies_relationship', null, null);
                        Dom.Xmlnode agRelationshipHierNode = agRelationshipNode.addChildElement('hierarchies', null, null);
                        Dom.Xmlnode agRelationshipHO_FlagNode = agRelationshipNode.addChildElement('ho_flag', null, null);
                        Dom.Xmlnode agRelationshipIdNode = agRelationshipNode.addChildElement('id', null, null);
                        Dom.Xmlnode agRelationshipNameNode = agRelationshipNode.addChildElement('name', null, null);
                        Dom.Xmlnode agRelationshipRelDetailsNode = agRelationshipNode.addChildElement('relationship_details', null, null);
                        
                        if(parentAg != Null){
                            agRelationshipHO_FlagNode.addTextNode('False');
                            Dom.Xmlnode auxAgencyNode = agRelationshipNode.addChildElement('parent_agency', null, null);
                            getAgencyNode(auxAgencyNode, parentAg,False, True);
                        }else{
                            agRelationshipHO_FlagNode.addTextNode('True');
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
                            if(prof.Agency__c == ag.Id){
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
        
        //System.debug('getAgencyDetail inicioCPU:' + inicioCPU);
        //System.debug('getAgencyDetail fimCPU:' + fimCPU);
        //System.debug('getAgencyDetail inicioCPUx:' + inicioCPUx);
        //System.debug('getAgencyDetail fimCPUx:' + fimCPUx);
        
        return doc.toXmlString();   
    }


    //Get XML for AgencyDetail to send to AW WS (2º step)
    public String getAgencyHierarchy(AMS_Agency__c agency, String[] r){

        List<AMS_Agency__c> lAg = new List<AMS_Agency__c>();
        lAg.add(agency);

        return getAgencyHierarchy(lAg, r);
    }

    //Get XML for Agency Hierarchy to send to AW WS (2º step)
    public String getAgencyHierarchy(List<AMS_Agency__c> agency, String[] r){
        
        //Map that will store all referenced objects
        msObject = new Map<Id, sObject>();

        lEmployee = new List<AMS_Employee__c>();

        mAg_VS_AgUpdate = new Map<Id, AMS_Agency_Updates__c>();
        mAg_VS_AgArea = new Map<Id, String>();
        mAg_VS_AgSiteType = new Map<Id, String>();
        mAg_VS_ParentAg = new Map<Id, Id>();
        mAgComputerReservation_VS_ComputerReservation = new Map<Id, Id>();
        mAgAirport_VS_Airport = new Map<Id, Id>();
        mAgAffiliation_VS_Affiliation = new Map<Id, Id>();
        mAg_VS_Person = new Map<Id, Id>();
        mEmp_VS_Person = new Map<Id, Id>();
        mAg_VS_Agency = new Map<Id, AMS_Agency__c>();
        mAg_VS_HO = new Map<Id, Id>();
        
        SET<Id> setAgencyKeys = new SET<Id>();
        SET<Id> setHierarchyKeys = new SET<Id>();
        SET<Id> setAgRelationshipKeys = new SET<Id>();

        //Get agenc
        for (AMS_Agency__c ag : agency) {
            setAgencyKeys.add(ag.Id);
        }

        //MAIN
        lAgencyUpdates = [SELECT Agency__c,Id,Name,RelationShip__c,Update_Type__c 
                            FROM AMS_Agency_Updates__c
                            where Agency__c in :setAgencyKeys];

        for (AMS_Agency_Updates__c agUpd : lAgencyUpdates) {
            mAg_VS_AgUpdate.put(agUpd.Agency__c,agUpd);
        }
        

        


        //MAIN
        lAgRelationshipParent = [SELECT Child_Agency__c,Parent_agency__c,Hierarchy__c,HO_Flag__c,Id,Name,Relationship_details__c 
                    FROM AMS_Agencies_relationhip__c WHERE Child_Agency__c in :setAgencyKeys];

        //MAIN
        lAgRelationshipChild = [SELECT Child_Agency__c,Parent_agency__c,Hierarchy__c,HO_Flag__c,Id,Name,Relationship_details__c 
                    FROM AMS_Agencies_relationhip__c WHERE Parent_agency__c in :setAgencyKeys];            
                       
        lAgRelationship = new List<AMS_Agencies_relationhip__c>();

        if(lAgRelationshipParent != Null && lAgRelationshipParent.size() > 0){
            lAgRelationship.addAll(lAgRelationshipParent);
        }
        if(lAgRelationshipChild != Null && lAgRelationshipChild.size() > 0){
            lAgRelationship.addAll(lAgRelationshipChild);
        }

        for (AMS_Agencies_relationhip__c rel : lAgRelationshipParent) {
            setHierarchyKeys.add(rel.Hierarchy__c);
            setAgRelationshipKeys.add(rel.Parent_agency__c);
            mAg_VS_ParentAg.put(rel.Child_Agency__c, rel.Parent_agency__c);
        }

        for (AMS_Agencies_relationhip__c rel : lAgRelationshipChild) {
            setHierarchyKeys.add(rel.Hierarchy__c);
            setAgRelationshipKeys.add(rel.Child_Agency__c);

            mAg_VS_ParentAg.put(rel.Child_Agency__c, rel.Parent_agency__c);
        }

        //REFERENCE
        lAgRelationshipHierarchy = [SELECT Account__c,Administrator__c,Airline_Code__c,
                    A_Code__c,BSP_Code__c,CASS_Number__c,Chk_Dgt__c,
                    Company_Type__c,C_Code__c,DPC_Operation__c,IATACode__c,Id,
                    Last_Inspection_Date__c,Legacy_External_ID__c,
                    Legacy_System__c,Legal_Name_2__c,Legal_Name_3__c,License_Number__c,
                    Location_Category__c,Location_Class__c,Name,GDS__c,
                    N_Code__c,Organization_Last_Change_Date__c,
                    Original_Approval_DAte__c,Other_Tax_Reference_Number__c,OwnerId,
                    Parent_Reference_Number__c,Phone_Number__c,Primary_address__c,
                    Recert_Expiry_Date__c,RecordTypeId,RecordType.name,
                    Reference_Number__c,STD_Code__c,SystemModstamp,Tax_Reference_Number__c,
                    Trading_Name_1__c,Trading_Name_2__c,Unique_ID__c,Verification_Date__c,
                    Site_type__c
                    FROM AMS_Agency__c where id in :setAgRelationshipKeys];

        for (AMS_Agency__c agRel : lAgRelationshipHierarchy) {
            mAg_VS_Agency.put(agRel.Id, agRel);
        }

        //REFERENCE                    
        lAgHierarchy = [SELECT Hierarchy_Name__c,Id,Name,RecordTypeId,RecordType.name
                        FROM AMS_Agencies_Hierarchy__c WHERE Id in :setHierarchyKeys];

        //MAIN
        lAgencyArea = [SELECT Agency__c,Site_type__c,Country__r.AIMS_Area_ID__c 
                            FROM AMS_Address__c
                            where Agency__c in :setAgRelationshipKeys];

        for (AMS_Address__c agArea : lAgencyArea) {
            mAg_VS_AgArea.put(agArea.Agency__c,String.valueOf(agArea.Country__r.AIMS_Area_ID__c) );
            mAg_VS_AgSiteType.put(agArea.Agency__c,String.valueOf(agArea.Site_type__c) );
        }

        //REFERENCE                        
        lRecordType = [SELECT Id,Name FROM RecordType];
        
        msObject.putAll(lAgHierarchy);
        msObject.putAll(lAgRelationship);
        msObject.putAll(lAgRelationshipHierarchy);
        msObject.putAll(lRecordType);
        
        //Header Values
        Map<String, String> mHeaderValues = new Map<String, String>();
        Date dToday = Date.today();
        Datetime dtToday = Datetime.now(); // Returns the current Datetime based on a GMT calendar.
        
        mHeaderValues.put('copymsg', '(C) International Air Transport Association (IATA) 2015. All rights reserved. No part of this file may be reproduced, stored in a retrieval system or transmitted in any form or by any means without prior permission from IATA.');
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
        PreviousIdNode.addTextNode('Dummy');
        Dom.Xmlnode GroupIDNode = ResponseHeaderNode.addChildElement('group_id', null, null);
        GroupIDNode.addTextNode(r[0]);
        Dom.Xmlnode ChunkSizeNode = ResponseHeaderNode.addChildElement('chunk_size', null, null);
        ChunkSizeNode.addTextNode(r[1]);
        Dom.Xmlnode ChunkKeyNode = ResponseHeaderNode.addChildElement('chunk_key', null, null);
        ChunkKeyNode.addTextNode(r[2]);
        Dom.Xmlnode ChunkTotalNode = ResponseHeaderNode.addChildElement('chunk_total', null, null);
        ChunkTotalNode.addTextNode(r[3]);

        Dom.Xmlnode AMS_AgenciesNode = rootNode.addChildElement('agency_hierarchy', null, null);

        ////Header Section
        getHeaderNode(AMS_AgenciesNode, mHeaderValues);
        
        //BEGIN Agencies
        Dom.Xmlnode agenciesNode = AMS_AgenciesNode.addChildElement('agencies', null, null);
        agenciesNode.setAttribute('bsp', 'BSP');
        agenciesNode.setAttribute('dpc', 'DPC');

        
        for (AMS_Agency__c ag : agency) {

            Dom.Xmlnode agencyNode = agenciesNode.addChildElement('agency', null, null);
            getAgencyNode(agencyNode, ag, False, True);
        
           
//<hierarchies>
//        <!--Zero or more repetitions:-->
//        <agencies_hierarchy>
//          <id>string</id>
//          <name>string</name>
//          <record_type>string</record_type>
//          <hierarchy_name>string</hierarchy_name>
//          <!--Zero or more repetitions:-->
//          <agency_relationships>
//            <!--Zero or more repetitions:-->
//            <agencies_relationship>
//              <id>string</id>
//              <name>string</name>
//              <ho_flag>string</ho_flag>
//              <relationship_details>string</relationship_details>
//              <!--Optional:-->
//              <parent_agency>
//                <area>s</area>
//              <!--Zero or more repetitions:-->
//              <child_agencies>
//                <child_agency>
            Set<Id> done = new Set<Id>();

            Dom.Xmlnode hierarchyNode = agencyNode.addChildElement('hierarchies', null, null);
            if(lAgRelationship.size() > 0){
                for (AMS_Agencies_relationhip__c rel : lAgRelationship) {
                    if(rel.Parent_agency__c == ag.Id || rel.Child_Agency__c == ag.Id){
                        //getObjectData(agRelationshipsNode, 'AMS_Agencies_relationhip__c', rel );

                        if(!done.contains(rel.Hierarchy__c)){

                            done.add(rel.Hierarchy__c);

                            AMS_Agencies_Hierarchy__c hier = (AMS_Agencies_Hierarchy__c)msObject.get(rel.Hierarchy__c);

                            Dom.Xmlnode agHierarchyNode = hierarchyNode.addChildElement('agencies_hierarchy', null, null);
                            getElementNode(agHierarchyNode, 'id', hier.Id);
                            getElementNode(agHierarchyNode, 'name', hier.Name);
                            getElementNode(agHierarchyNode, 'record_type', hier.recordType.Name);
                            getElementNode(agHierarchyNode, 'hierarchy_name', hier.Hierarchy_Name__c);

                            Dom.Xmlnode agRelationshipsNode = agHierarchyNode.addChildElement('agency_relationships', null, null);
                            if(lAgRelationship.size() > 0){
                                for (AMS_Agencies_relationhip__c rel2 : lAgRelationship) {

                                    if((rel2.Parent_agency__c == ag.Id || rel2.Child_Agency__c == ag.Id )
                                            && rel2.Hierarchy__c == hier.Id){
                                        
                                        Dom.Xmlnode agRelationshipNode = agRelationshipsNode.addChildElement('agencies_relationship', null, null);
                                        getElementNode(agRelationshipNode, 'id', rel2.Id);
                                        getElementNode(agRelationshipNode, 'name', rel2.Name);
                                        getElementNode(agRelationshipNode, 'ho_flag', rel2.HO_Flag__c == Null ? 'False':rel2.HO_Flag__c);
                                        getElementNode(agRelationshipNode, 'relationship_details', rel2.Relationship_details__c);



                                        //Dom.Xmlnode parentAgsNode = agRelationshipNode.addChildElement('parent_agencies', null, null);
                                        //Dom.Xmlnode childAgsNode = agRelationshipNode.addChildElement('child_agencies', null, null);
                                        Dom.Xmlnode parentAgNode = agRelationshipNode.addChildElement('parent_agency', null, null);
                                        Dom.Xmlnode childAgNode = agRelationshipNode.addChildElement('child_agency', null, null);

                                        if(rel2.Parent_agency__c != null && rel2.Parent_agency__c != ag.Id){
                                            //Dom.Xmlnode parentAgNode = parentAgsNode.addChildElement('parent_agency', null, null);
                                            AMS_Agency__c agParent = mAg_VS_Agency.get(rel2.Parent_agency__c);
                                            getAgencyNode(parentAgNode, agParent, False, True);
                                        }
                                        if(rel2.Child_Agency__c != null && rel2.Child_Agency__c != ag.Id){
                                            //Dom.Xmlnode childAgNode = childAgsNode.addChildElement('child_agency', null, null);
                                            AMS_Agency__c agChild = mAg_VS_Agency.get(rel2.Child_Agency__c);

//System.debug('----- rel2.Child_Agency__c: ' + rel2.Child_Agency__c);
//System.debug('----- agChild: ' + agChild);                                            
                                            
                                            getAgencyNode(childAgNode, agChild, False, True);
                                        }

                                    }
                                }
                            //}else{
                            //    agRelationshipsNode.addTextNode('Missing');
                            }
                        }
                    }
                }
            //}else{
            //    agRelationshipsNode.addTextNode('Missing');
            }

        }

        ////Header Section
        getFooterNode(AMS_AgenciesNode, agency.size());

        system.debug('--------- doc: ' + doc.toXmlString());     
        system.debug(sDebug);
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


    public void getAgencyNode(Dom.Xmlnode agencyNode, AMS_Agency__c agency, Boolean lookupParent, Boolean redux){

        //get account related to the agency, just in case it's necessary (was needed for the short name, but no more)
        Account acc;
        acc = (Account)msObject.get(agency.Account__c);

        //Only Lookups the Parent for the Main Agency data, the ones on the Hierarchy are not looked up!
        AMS_Agency__c parentAg;
        if(lookupParent){
            parentAg = (AMS_Agency__c)msObject.get(mAg_VS_ParentAg.get(agency.Id));
            if(parentAg == Null){
                parentAg = new AMS_Agency__c();
            }
        }else{
            parentAg = new AMS_Agency__c();
        }

     
        //get "Lang" from Person object
        AMS_Person__c oPerson;
        if(mAg_VS_Person.containsKey(agency.Id)){
            oPerson = (AMS_Person__c) msObject.get(mAg_VS_Person.get(agency.Id));
        }else{
            oPerson = new AMS_Person__c();
            oPerson.Language_of_correspondence__c = '';
        }
        
        //get "Manager" and "Ticketing Agent" First and Last Names from Person object
        AMS_Person__c oEmpPerson;

        Id iQta = Null;
        Id iQmp = Null;
        String sQtal_name = '';
        String sQtaf_name = '';
        String sQmpl_name = '';
        String sQmpf_name = '';
    
        for(AMS_Employee__c emp : lEmployee){
            if(emp.Agency__c == agency.Id){

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
        } 
    


        //Get Parent Agency
        //AMS_Agency__c parentAg = (AMS_Agency__c)msObject.get(mAg_VS_ParentAg.get(agency.Id));
        
        /*Agencies Section*/
        
        if(!redux){

             //Indicates if record is A=Added, C=Changed or D=Deleted.  Changes files only, blank for Masters.
            AMS_Agency_Updates__c agUpd = mAg_VS_AgUpdate.get(agency.Id);

            String sRec_id = '';
            
            //Validates if it's Null, null values belong to parent and child agencies processing
            if(agUpd != null){
                sRec_id = agUpd.Update_Type__c.equalsIgnoreCase('Create_Sent') ? 'A' : 
                                    agUpd.Update_Type__c.equalsIgnoreCase('Update_Sent') ? 'C' : 
                                        agUpd.Update_Type__c.equalsIgnoreCase('Delete_Sent') ? 'D' : 'A';
            }

            
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

        //Sprint 7: Inserting "agref" and "agxref" for Agencies with Legacy "AIMS", for now we use the legacy ID
        if(((String)agency.Legacy_System__c).startsWithIgnoreCase('AIMS')){
            //getElementNode(agencyNode, 'ag_ref', agency.Legacy_External_ID__c == Null?'':agency.Legacy_External_ID__c);
            //getElementNode(agencyNode, 'ag_x_ref', parentAg.Legacy_External_ID__c == Null?'':parentAg.Legacy_External_ID__c);
            getElementNode(agencyNode, 'ag_ref', agency.Legacy_External_ID__c);
            getElementNode(agencyNode, 'ag_x_ref', parentAg.Legacy_External_ID__c);
        }else{
            getElementNode(agencyNode, 'ag_ref', Null);
            getElementNode(agencyNode, 'ag_x_ref', Null);
        }

        if(!redux){
             getElementNode(agencyNode, 'ho_id',  mAg_VS_HO.get(agency.Id));
        }


        //Sprint 7: Inserting "LCtryCode" in the Agencies since now we are using the "C_Code" as country code
        getElementNode(agencyNode, 'l_country_code', agency.C_Code__c);

        getElementNode(agencyNode, 'iata_code', agency.IATACode__c);
        getElementNode(agencyNode, 'iata_chk', String.valueOf(agency.Chk_Dgt__c));        
        
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
            getElementNode(agencyNode, 'site_type', agency.Site_Type__c);
            getElementNode(agencyNode, 'air_code', agency.Airline_Code__c);
            //getElementNode(agencyNode, 'legal_1', agency.Name);
            //getElementNode(agencyNode, 'legal_2', agency.Legal_Name_2__c);
            //getElementNode(agencyNode, 'legal_3', agency.Legal_Name_3__c);
            //getElementNode(agencyNode, 'dba_1', agency.Trading_Name_1__c);
            //getElementNode(agencyNode, 'dba_2', agency.Trading_Name_2__c);
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.name', 'legal_1', agency.Name);
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Legal_Name_2__c', 'legal_2', agency.Legal_Name_2__c);
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Legal_Name_3__c', 'legal_3', agency.Legal_Name_3__c);
            
            //short_name
            getElementNode(agencyNode, 'short_name', agency.Abbreviated_name__c);

            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Trading_Name_1__c', 'dba_1', agency.Trading_Name_1__c);
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Trading_Name_2__c', 'dba_2', agency.Trading_Name_2__c);
            

            //Removed from XML
            //getElementNode(agencyNode, 'XArea', '1');
            //getElementNode(agencyNode, 'XIATACode', parentAg.IATACode__c);
            //getElementNode(agencyNode, 'XIATAChk', String.valueOf(parentAg.Chk_Dgt__c));
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
            getElementNode(agencyNode, 'pas_cgo', agency.recordType.Name.equalsIgnoreCase('passenger')?'P':'C');
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Company_Type__c', 'co_type', agency.Company_Type__c);
            getElementNode(agencyNode, 'solicit', agency.Solicitation_Flag__c == True ? 'Y' : 'N');
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Tax_Reference_Number__c', 'tax_ref_1', agency.Tax_Reference_Number__c);
            getElementTranslatedNode(agencyNode, agency.Id, 'ams_agency__c.Other_Tax_Reference_Number__c', 'tax_ref_2', agency.Other_Tax_Reference_Number__c);
            getElementNode(agencyNode, 'bsp_code', agency.BSP_Code__c);


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

    public static String PadZeros(String s, Integer Len) {
        while (s.length() < Len) s = '0' + s;
        return s;
    }
    
    public String getPersonLanguageOfCorrespondence(String value){
        if(value == Null){
            return '';
        }else if(value.equalsIgnoreCase('EN')){
            return 'ENG';
        }else if(value.equalsIgnoreCase('FR')){
            return 'FRE';
        }else if(value.equalsIgnoreCase('SP')){
            return 'SPA';
        }
        return '';
    }

    //Get the WAD files values to include
    public String getWadValue(String name, String type){
        
        name = name.toLowerCase();

        if(mWadNameValues.containsKey(name)){
            AMS_WAD_Settings__c wadSett = mWadNameValues.get(name); 
            if(type.equalsIgnoreCase('Size')){
                return String.valueOf(wadSett.Size__c);
            }else if(type.equalsIgnoreCase('Position')){
                return String.valueOf(wadSett.Position__c);
            }
        }else if(mWadFieldValues.containsKey(name)){
            AMS_WAD_Settings__c wadSett = mWadFieldValues.get(name); 
            if(type.equalsIgnoreCase('Size')){
                return String.valueOf(wadSett.Size__c);
            }else if(type.equalsIgnoreCase('Position')){
                return String.valueOf(wadSett.Position__c);
            }
        }

        return '';
    } 


    //Set WAD attributes to the XML Element
    public void getWadAttributes(Dom.Xmlnode node, String field){
        if(mWadNameValues.containsKey(field.toLowerCase()) || mWadFieldValues.containsKey(field.toLowerCase())){
            //node.setAttribute('wadsize', getWadValue(field,'Size'));
            //node.setAttribute('wadposition', getWadValue(field,'Position'));
        }
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

                if(strObject.equalsIgnoreCase('ams_agency__c') && ft.Agency__c == iid){
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
                                    //    String sValue = String.valueOf(obj.get(f));
                                    //    String sISO_code = '';
                                    //    String sCountryCode = '';
                                    //    if(sValue.length() == 4){
                                    //        sISO_code = sValue.substring(0,2);
                                    //        sCountryCode = sValue.substring(2,4);
                                    //    }else{
                                    //        sISO_code = sValue;
                                    //        sCountryCode = '';
                                    //    }
                                    //    auxNode.addTextNode(sISO_code );
                                    //    Dom.Xmlnode auxNodeCountryCode = auxParentNode.addChildElement('country_code', null, null);
                                    //    auxNodeCountryCode.addTextNode(sCountryCode );
                                    //}else 
                                        
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

                                }else if(f.equalsIgnoreCase('Parent_agency__c')){ //Special threatment for the Parent agencies on the Hierarchy data

                                    Dom.Xmlnode auxAgencyNode = auxParentNode.addChildElement(displayFieldName, null, null);
                                    getAgencyNode(auxAgencyNode, (AMS_Agency__c)msObject.get((Id)obj.get(f)),False, True);

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

        } catch (SObjectException e)    { 
            //getObjectData SObjectException e:System.SObjectException: SObject row was retrieved via SOQL without querying the requested field: AMS_Employee__c.IsDeleted
            System.Debug('----getObjectData SObjectException e:'+ e);
        } 
        
    }



}