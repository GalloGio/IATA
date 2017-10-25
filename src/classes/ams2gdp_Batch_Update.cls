global class ams2gdp_Batch_Update implements Database.Batchable<sObject> , Database.Stateful 
{
    public String query;
    public String job;  
    public String jobParams;
    
    public Integer errorsCount;
    public Integer totalRecords;
    public List<String> failed_records;

     
    global ams2gdp_Batch_Update(String j, String p) 
    {
        job = j;
        jobParams = p;

        if(job == 'updateGDPProductsAccountView')
        {
            query = 'SELECT AMS_GDP_Key__c, AIMS_Id__c, Webstar_Id__c,IATA_Code__c, CASS_Number__c, Check_Digit__c FROM GDP_Products_Account_View__c WHERE AMS_GDP_Key__c = null AND (AIMS_Id__c != null OR Webstar_Id__c!=null) ';
        }
        else if(job == 'updateGDS')
        {
            query = 'SELECT AMS_GDP_Key__c, AIMS_Id__c, Webstar_Id__c, Computer_Reservation_System__r.Code__c, GDS_ID__c FROM GDS__c WHERE AMS_GDP_Key__c = null AND Computer_Reservation_System__r.Code__c != null AND RecordType.DeveloperName = \'GDP\' AND (AIMS_Id__c != null OR Webstar_Id__c!=null)';
        }
        else if(job == 'updateAccountCategory')
        {
            query = 'SELECT AMS_GDP_Key__c, AIMS_Id__c, Webstar_Id__c, Category_Code__r.Code__c, Category_ID__c FROM Account_Category__c WHERE AMS_GDP_Key__c = null AND Category_Code__r.Code__c != null AND RecordType.DeveloperName = \'GDP\' AND (AIMS_Id__c != null OR Webstar_Id__c!=null)';
        }
        else if(job == 'updateAccreditation')
        {
            query = 'SELECT AMS_GDP_Key__c, RecordType.DeveloperName, AIMS_Id__c, Webstar_Id__c, Accreditation_ID__c, Endorsed_Accredited_By_Formula__c  FROM Accreditation__c WHERE AMS_GDP_Key__c = null AND Related_GDP_Products_Account_View__c!=null AND Endorsed_Accredited_By_Formula__c IN (\'IATA\',\'IATAN\',\'DOM\') AND Status__r.Code__c IN (\'0\',\'4\',\'5\',\'6\',\'7\',\'8\',\'9\') AND RecordType.DeveloperName = \'GDP\' ';
        }
        else if(job == 'updateGDPPhone')
        {
            query = 'SELECT AMS_GDP_Key__c, Related_Account__r.Id, RecordType.DeveloperName, AIMS_Id__c, Webstar_Id__c, Phone_Type__c,  Related_GDP_Products_Account_View__c FROM GDP_Phone__c WHERE AMS_GDP_Key__c = null AND RecordType.DeveloperName = \'GDP\' AND Related_GDP_Products_Account_View__c!=null AND (AIMS_Id__c != null OR Webstar_Id__c!=null)';
        }
        else if(job == 'updateGDPAddress')
        {
            query = 'SELECT AMS_GDP_Key__c, Related_Account__r.Id, RecordType.DeveloperName, AIMS_Id__c, Webstar_Id__c, Address_Type__c, Related_Account__c, Related_GDP_Products_Account_View__c FROM GDP_Address__c WHERE AMS_GDP_Key__c = null AND RecordType.DeveloperName = \'GDP\' AND Related_GDP_Products_Account_View__c!=null AND (AIMS_Id__c != null OR Webstar_Id__c!=null)';
        }
        else if(job == 'updateAgencyOwner')
        {
            query = 'SELECT AIMS_ID__c, RecordType.DeveloperName, Webstar_Id__c, Related_GDP_Products_Account_View__c, Related_Account__c FROM Agency_Owner__c  WHERE AMS_GDP_Key__c = null AND RecordType.DeveloperName = \'GDP\' ';
        }
        else if(job == 'updateAssocAffiliationMembership')
        {
            query = 'SELECT Id, RecordType.DeveloperName, AIMS_Id__c, Webstar_Id__c, Related_Account__c, AMS_GDP_Mapping_Key__c,Related_GDP_Products_Account_View__r.AMS_GDP_Key__c,Assoc_Affiliation_Code__r.Code__c FROM Assoc_Affiliation_Membership__c WHERE AMS_GDP_Key__c = null AND RecordType.DeveloperName = \'GDP\' ';
        }
        else if(job == 'updateAdjacentAirport')
        {
            query = 'SELECT AMS_GDP_Formula_Key__c, AIMS_Id__c, Webstar_Id__c, RecordType.DeveloperName, Related_Account__c, AMS_GDP_Key__c, Related_GDP_Products_Account_View__r.AMS_GDP_Key__c,AirportCode__r.Code__c FROM Adjacent_Airport__c WHERE AMS_GDP_Key__c = null AND RecordType.DeveloperName = \'GDP\'';
        }
        else if(job == 'updateAgencyProfileSpecialization')
        {
            query = 'SELECT Id, AIMS_ID__c, WebStar_ID__c FROM GDP_Agency_Profile_Specialization__c WHERE AMS_GDP_Key__c = null AND (AIMS_Id__c != null OR Webstar_Id__c!=null) AND RecordType.DeveloperName = \'GDP\' ';
        }
        else if(job == 'updateGSATerritory')
        {
            query = 'SELECT Id, AIMS_Id__c, Airline_Code__c, Territory_ISO_Country__c, Territory_IATA_Numeric_Country_Code__c FROM GSA_Territory__c WHERE AMS_GDP_Key__c = null AND AIMS_Id__c != null';
        }
         else if(job == 'updateAMSAppointment')
        {
            query = 'SELECT Id FROM AMS_Inspection__c WHERE Account__r.Main_Accreditation_Organization__c IN (\'IATAN\',\'IATA\',\'DOM\')';
        }
        else if(job == 'clearLogs')
        {
            query = 'SELECT Id FROM AMS2GDP_Log__c  ';
        }
        else if(job == 'clearGDPRecords')
        {
            query = 'SELECT Id FROM '+jobParams+' ';
        } 
        else if(job == 'clearLiveRecords')
        {
            query = 'SELECT Id FROM '+jobParams+' WHERE RecordType.DeveloperName = \'Live\' ';
        }
        /*else if(job == 'clearKeyValues')
        {
            query = 'SELECT Id FROM '+jobParams+' WHERE AMS_GDP_Key__c != null ';
        }     */  
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        errorsCount = 0;
        totalRecords = 0;   
        failed_records = new List<String>();

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        //-- Total records to be processed
        if(totalRecords == null) totalRecords = 0; 
        
        totalRecords += scope.size();

        if(job == 'updateGDPProductsAccountView') updateGDPProductsAccountView((List<GDP_Products_Account_View__c>) scope);
        else if(job == 'updateGDS') updateGDS((List<GDS__c>) scope);
        else if(job == 'updateAccountCategory') updateAccountCategory((List<Account_Category__c>) scope);
        else if(job == 'updateAccreditation') updateAccreditation((List<Accreditation__c>) scope);
        else if(job == 'updateGDPPhone') updateGDPPhone((List<GDP_Phone__c>) scope);
        else if(job == 'updateGDPAddress') updateGDPAddress((List<GDP_Address__c>) scope);
        else if(job == 'updateAgencyOwner') updateAgencyOwner((List<Agency_Owner__c>) scope);
        else if(job == 'updateAssocAffiliationMembership') updateAssocAffiliationMembership((List<Assoc_Affiliation_Membership__c>) scope);
        else if(job == 'updateAdjacentAirport') updateAdjacentAirport((List<Adjacent_Airport__c>) scope);
        else if(job == 'updateAgencyProfileSpecialization') updateAgencyProfileSpecialization((List<GDP_Agency_Profile_Specialization__c>) scope);
        else if(job == 'updateGSATerritory') updateGSATerritory((List<GSA_Territory__c>) scope);
        else if(job == 'updateAMSAppointment') updateAMSAppointment((List<AMS_Inspection__c>) scope);
        else if(job =='clearLogs') clearData(scope);
        else if(job =='clearGDPRecords') clearData(scope);
        else if(job == 'clearLiveRecords') clearData(scope);
        //else if (job == 'clearKeyValues') clearKeyValues(scope);        
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        //--Send completion notification 
        ams2gdp_Utils.notifyBatchOutput(job, totalRecords, null, null);
    }

    public static void clearData(List<sObject> data)
    {
        delete data; 
    }

    /*public static void clearKeyValues(List<sObject> data)
    {
        for(sObject o : data)
            o.put('AMS_GDP_Key__c', null);

        update data; 
    }*/

    public static void updateGDPProductsAccountView(List<GDP_Products_Account_View__c> gdp_products_account_views)
    {
        Set<String> aims_ids = new Set<String>();           
        Set<String> webstar_ids = new Set<String>();
        Set<String> iata_uniq_codes = new Set<String>();

        for(GDP_Products_Account_View__c prod : gdp_products_account_views)
        {
            if(String.isNotBlank(prod.AIMS_Id__c)) aims_ids.add(prod.AIMS_Id__c.removeEnd('GDP'));
            if(String.isNotBlank(prod.Webstar_Id__c)) webstar_ids.add(prod.Webstar_Id__c.removeEnd('GDP'));

            String iata_code = prod.IATA_Code__c; 
            if(String.isNotBlank(prod.CASS_Number__c)) iata_code += prod.CASS_Number__c; 
            iata_code += prod.Check_Digit__c;
            
            iata_uniq_codes.add(iata_code);
        }

        Map<String, String> accountsByLegacyId = new Map<String, String>(); 
        for(Account acc: [SELECT Id, AIMS_Id__c, Webstar_Id__c,IATACode__c FROM Account WHERE AIMS_Id__c IN :aims_ids OR Webstar_Id__c IN:webstar_ids OR IATACode__c IN :iata_uniq_codes])
        {
            if(String.isNotBlank(acc.AIMS_Id__c)) accountsByLegacyId.put(acc.AIMS_Id__c, acc.Id);
            if(String.isNotBlank(acc.Webstar_Id__c)) accountsByLegacyId.put(acc.Webstar_Id__c, acc.Id);
            if(String.isNotBlank(acc.IATACode__c)) accountsByLegacyId.put(acc.IATACode__c, acc.Id);
        }

        for(GDP_Products_Account_View__c prod : gdp_products_account_views)
        {
            String iata_code = prod.IATA_Code__c; 
            if(String.isNotBlank(prod.CASS_Number__c)) iata_code += prod.CASS_Number__c; 
            iata_code += prod.Check_Digit__c;

            if(String.isNotBlank(prod.AIMS_Id__c) && accountsByLegacyId.containsKey(prod.AIMS_ID__c.removeEnd('GDP')))
            { prod.AMS_GDP_Key__c = accountsByLegacyId.get(prod.AIMS_ID__c.removeEnd('GDP'));   }
            else if(String.isNotBlank(prod.Webstar_Id__c) && accountsByLegacyId.containsKey(prod.Webstar_Id__c.removeEnd('GDP')))
            {  prod.AMS_GDP_Key__c = accountsByLegacyId.get(prod.Webstar_Id__c.removeEnd('GDP'));  }
            else if(accountsByLegacyId.containsKey(iata_code))  {
                prod.AMS_GDP_Key__c = accountsByLegacyId.get(iata_code);    }
        }
        
        Database.update(gdp_products_account_views, false);
        
    }

    public static void updateGDS(List<GDS__c> lst)
    {
        Set<String> aims_ids = new Set<String>();           
        Set<String> webstar_ids = new Set<String>();

        for(GDS__c item : lst)
        {
            Integer gds_id = Integer.valueOf(item.GDS_ID__c);
            if(String.isNotBlank(item.AIMS_Id__c)) aims_ids.add(item.AIMS_Id__c.removeEnd(gds_id+'GDP'));
            if(String.isNotBlank(item.Webstar_Id__c)) webstar_ids.add(item.Webstar_Id__c.removeEnd(gds_id+'GDP'));          
        }

        Map<String, String> accountsByLegacyId = new Map<String, String>(); 
        for(Account acc: [SELECT Id, AIMS_Id__c, Webstar_Id__c FROM Account WHERE AIMS_Id__c IN :aims_ids OR Webstar_Id__c IN:webstar_ids])
        {
            if(String.isNotBlank(acc.AIMS_Id__c)) accountsByLegacyId.put(acc.AIMS_Id__c, acc.Id);
            if(String.isNotBlank(acc.Webstar_Id__c)) accountsByLegacyId.put(acc.Webstar_Id__c, acc.Id);
        }

        for(GDS__c item : lst)
        {
            Integer gds_id = Integer.valueOf(item.GDS_ID__c);
            if(String.isNotBlank(item.AIMS_Id__c) && accountsByLegacyId.containsKey(item.AIMS_ID__c.removeEnd(gds_id+'GDP'))) item.AMS_GDP_Key__c = accountsByLegacyId.get(item.AIMS_ID__c.removeEnd(gds_id+'GDP')) + '-' + item.Computer_Reservation_System__r.Code__c;
            else if(String.isNotBlank(item.Webstar_Id__c) && accountsByLegacyId.containsKey(item.Webstar_Id__c.removeEnd(gds_id+'GDP'))) item.AMS_GDP_Key__c = accountsByLegacyId.get(item.Webstar_Id__c.removeEnd(gds_id+'GDP')) + '-' + item.Computer_Reservation_System__r.Code__c;           
        }
        Database.update(lst,false);
    }
    
    public static void updateAccountCategory(List<Account_Category__c> lst)
    {
        Set<String> aims_ids = new Set<String>();           
        Set<String> webstar_ids = new Set<String>();

        for(Account_Category__c item : lst)
        {
            Integer cat_id = Integer.valueOf(item.Category_ID__c);
            if(String.isNotBlank(item.AIMS_Id__c)) aims_ids.add(item.AIMS_Id__c.removeEnd(cat_id+'GDP'));
            if(String.isNotBlank(item.Webstar_Id__c)) webstar_ids.add(item.Webstar_Id__c.removeEnd(cat_id+'GDP'));
        }

        Map<String, String> accountsByLegacyId = new Map<String, String>(); 
        for(Account acc: [SELECT Id, AIMS_Id__c, Webstar_Id__c FROM Account WHERE AIMS_Id__c IN :aims_ids OR Webstar_Id__c IN:webstar_ids])
        {
            if(String.isNotBlank(acc.AIMS_Id__c)) accountsByLegacyId.put(acc.AIMS_Id__c, acc.Id);
            if(String.isNotBlank(acc.Webstar_Id__c)) accountsByLegacyId.put(acc.Webstar_Id__c, acc.Id);
        }

        for(Account_Category__c item : lst)
        {
            Integer cat_id = Integer.valueOf(item.Category_ID__c);
            if(String.isNotBlank(item.AIMS_Id__c) && accountsByLegacyId.containsKey(item.AIMS_ID__c.removeEnd(cat_id+'GDP'))) item.AMS_GDP_Key__c = accountsByLegacyId.get(item.AIMS_ID__c.removeEnd(cat_id+'GDP')) + '-' + item.Category_Code__r.Code__c;
            else if(String.isNotBlank(item.Webstar_Id__c) && accountsByLegacyId.containsKey(item.Webstar_Id__c.removeEnd(cat_id+'GDP'))) item.AMS_GDP_Key__c = accountsByLegacyId.get(item.Webstar_Id__c.removeEnd(cat_id+'GDP')) + '-' + item.Category_Code__r.Code__c;
            
        }
        Database.update(lst,false);
    }

    public static void updateAccreditation(List<Accreditation__c> accreditations)
    {
        //-- Get Legacy Ids 
        Set<String> legacy_ids = new Set<String>(); 
        for(Accreditation__c acc : accreditations)
        {
            Integer acc_id = Integer.valueOf(acc.Accreditation_ID__c);
            //{EXTERNAL_ID}ACC{ACCREDITATION_ID}[GDP]
            if(String.isNotBlank(acc.AIMS_Id__c))
            {
                String aims_id = acc.AIMS_Id__c.removeEnd('ACC'+acc_id+'GDP');     
                legacy_ids.add(aims_id+acc.Endorsed_Accredited_By_Formula__c);
            }

            //{EXTERNAL_ID}{PHONE_TYPE}[GDP]
            if(String.isNotBlank(acc.Webstar_Id__c))
            {
                String webstar_id = acc.Webstar_Id__c.removeEnd('ACC'+acc_id+'GDP');   
                legacy_ids.add(webstar_id+acc.Endorsed_Accredited_By_Formula__c);
            }
        }

        //-- Find corresponding AMS Address :: SOQL 2
        Map<String, String> inspectionsByLegacyId = new Map<String, String>(); 
        for(AMS_Inspection__c ins: [SELECT Id, Legacy_External_Id__c, Legacy_System__c FROM AMS_Inspection__c WHERE Legacy_External_Id__c IN :legacy_ids])
        {
            if(String.isNotBlank(ins.Legacy_External_Id__c)) inspectionsByLegacyId.put(ins.Legacy_External_Id__c, ins.Id);   
                         
        }

        for(Accreditation__c acc : accreditations)
        {
            Integer acc_id = Integer.valueOf(acc.Accreditation_ID__c);
            if(String.isNotBlank(acc.AIMS_Id__c))
            {
                String aims_key = acc.AIMS_Id__c.removeEnd('ACC'+acc_id+'GDP');
                    aims_key = aims_key+acc.Endorsed_Accredited_By_Formula__c;

                if(inspectionsByLegacyId.containsKey(aims_key)) acc.AMS_GDP_Key__c = inspectionsByLegacyId.get(aims_key)+'GDP';
                
            }
            else if(String.isNotBlank(acc.Webstar_Id__c))
            {
                String webstar_key = acc.Webstar_Id__c.removeEnd('ACC'+acc_id+'GDP');
                    webstar_key = webstar_key+acc.Endorsed_Accredited_By_Formula__c;

                if(inspectionsByLegacyId.containsKey(webstar_key)) acc.AMS_GDP_Key__c = inspectionsByLegacyId.get(webstar_key)+'GDP'; 
            }
        }

        //DML 1
        Database.update(accreditations,false);              
    }

   /* public static void updateGDPPhone(List<GDP_Phone__c> gdp_phones)
    {
        Set<String> legacy_ids = new Set<String>(); 
        for(GDP_Phone__c phone : gdp_phones)
        {
            //{EXTERNAL_ID}{PHONE_TYPE}[GDP]
            if(String.isNotBlank(phone.AIMS_Id__c))
            {
               
                String aims_id = phone.AIMS_Id__c.removeEnd('GDP');
                    aims_id =aims_id.substring(0,aims_id.length()-2);                   
                    
                legacy_ids.add('AGT-'+aims_id);
                legacy_ids.add('ADD-'+aims_id);
            }

            //{EXTERNAL_ID}{PHONE_TYPE}[GDP]
            if(String.isNotBlank(phone.Webstar_Id__c))
            {
                String webstar_id = phone.Webstar_Id__c.removeEnd('GDP');
                    webstar_id = webstar_id.substring(0,webstar_id.length()-2);
        
                legacy_ids.add(webstar_id);
            }
        }

        //-- Find corresponding AMS Address :: SOQL 2
        Map<String, String> addressesByLegacyId = new Map<String, String>(); 
        for(AMS_Address__c adr: [SELECT Id, Legacy_External_Id__c, Legacy_System__c FROM AMS_Address__c WHERE Legacy_External_Id__c IN :legacy_ids])
        {
            
            if(String.isNotBlank(adr.Legacy_External_Id__c))
            {
                if(adr.Legacy_System__c == 'Webstar') addressesByLegacyId.put(adr.Legacy_External_Id__c, adr.Id);
                else
                {
                    String key = adr.Legacy_External_Id__c.removeStart('AGT-');
                        key = key.removeStart('ADD-');
                    addressesByLegacyId.put(key, adr.Id);
                }                   
            }               
        }

        for(GDP_Phone__c phone : gdp_phones)
        {
            if(String.isNotBlank(phone.AIMS_Id__c))
            {
                String aims_id = phone.AIMS_Id__c.removeEnd('GDP');
                aims_id =aims_id.substring(0,aims_id.length()-2);                                   
                
                String key = addressesByLegacyId.get(aims_id); 
                if(phone.Phone_Type__c == 'Phone 1') key += '-P1';
                else if(phone.Phone_Type__c == 'Phone 2') key += '-P2';
                else if(phone.Phone_Type__c == 'Fax') key += '-FX';

                if(addressesByLegacyId.containsKey(aims_id))
                {
                    if(phone.RecordType.DeveloperName == 'GDP') phone.AMS_GDP_Key__c = key+'GDP';
                    else phone.AMS_GDP_Key__c = key;
                }       
                  
            }
            else if(String.isNotBlank(phone.Webstar_Id__c))
            {
                
                String webstar_id = phone.Webstar_Id__c.removeEnd('GDP');
                    webstar_id = webstar_id.substring(0,webstar_id.length()-2);

                String key = addressesByLegacyId.get(webstar_id); 
                if(phone.Phone_Type__c == 'Phone 1') key += '-P1';
                else if(phone.Phone_Type__c == 'Phone 2') key += '-P2';
                else if(phone.Phone_Type__c == 'Fax') key += '-FX';
                
                if(addressesByLegacyId.containsKey(webstar_id)){

                    if(phone.RecordType.DeveloperName == 'GDP') phone.AMS_GDP_Key__c = key+'GDP';
                    else  phone.AMS_GDP_Key__c = key;
                }
                
            }
        }

        //DML 1
        Database.update(gdp_phones, false);      
    }*/

 public static void updateGDPPhone(List<GDP_Phone__c> gdp_phones)
    {
        Set<String> legacy_ids = new Set<String>(); 
        for(GDP_Phone__c phone : gdp_phones)
        {
            //{EXTERNAL_ID}{PHONE_TYPE}[GDP]
            if(String.isNotBlank(phone.Related_Account__r.Id))
            {
               if(phone.Phone_Type__c=='Phone 1')
               phone.AMS_GDP_Key__c  = phone.Related_Account__r.Id+'-P1GDP';
               else if(phone.Phone_Type__c=='Fax')
               phone.AMS_GDP_Key__c  = phone.Related_Account__r.Id+'-FXGDP';                
                       
            }
          
        }        
        //DML 1
        Database.update(gdp_phones, false);      
    }

public static void updateGDPAddress(List<GDP_Address__c> gdp_address)
    {
        Set<String> legacy_ids = new Set<String>(); 
        for(GDP_Address__c address : gdp_address)
        {
            //{EXTERNAL_ID}{PHONE_TYPE}[GDP]
            if(String.isNotBlank(address.Related_Account__r.Id))
            {               
              if(address.Address_Type__c=='Location')  address.AMS_GDP_Key__c  = address.Related_Account__r.Id + 'LOCGDP'; 
              else if(address.Address_Type__c=='Mailing')  address.AMS_GDP_Key__c  = address.Related_Account__r.Id + 'MAIGDP'; 
            }          
        }

        
        //DML 1
        Database.update(gdp_address, false);      
    }

   /* public static void updateGDPAddress(List<GDP_Address__c> gdp_address)
    {
    
        Set<String> legacy_ids = new Set<String>(); 
        
        for(GDP_Address__c address : gdp_address)
        {
            //{EXTERNAL_ID}{ADDRESS_TYPE}[GDP]
            if(String.isNotBlank(address.AIMS_Id__c))
            {
               
                String aims_id = address.AIMS_Id__c.removeEnd('MAI');
                    aims_id =aims_id.removeEnd('LOC');                  
                    
                legacy_ids.add('AGT-'+aims_id);
                legacy_ids.add('ADD-'+aims_id);
            }

            //{EXTERNAL_ID}{ADDRESS_TYPE}[GDP]
            if(String.isNotBlank(address.Webstar_Id__c))
            {
                String webstar_id = address.Webstar_Id__c.removeEnd('MAIGDP');
                    webstar_id = webstar_id.removeEnd('LOCGDP');
        
                legacy_ids.add(webstar_id);
            }
        }

        //-- Find corresponding AMS Address :: SOQL 2
        Map<String, String> addressesByLegacyId = new Map<String, String>(); 
        for(AMS_Address__c adr: [SELECT Id, Legacy_External_Id__c, Legacy_System__c, Address_Type__c FROM AMS_Address__c WHERE Legacy_External_Id__c IN :legacy_ids])
        {
            String adType;
           
            if(!String.isBlank(adr.Address_Type__c)){
                if(adr.Address_Type__c=='Primary') adType='LOC';
                else if(adr.Address_Type__c=='Mailing') adType= 'MAI';
            }

            if(String.isNotBlank(adr.Legacy_External_Id__c))
            {
                if(adr.Legacy_System__c == 'Webstar') addressesByLegacyId.put(adr.Legacy_External_Id__c+adType, adr.Id);
                else
                {
                    String key = adr.Legacy_External_Id__c.removeStart('AGT-');
                        key = key.removeStart('ADD-');
                    addressesByLegacyId.put(key+adType, adr.Id);
                }                   
            }               
        }

        for(GDP_Address__c address : gdp_address)
        {
            if(String.isNotBlank(address.AIMS_Id__c))
            {
                String aims_id = address.AIMS_Id__c.removeEnd('GDP');
                    //String aims_id = address.AIMS_Id__c.removeEnd('MAI');
                    //aims_id =aims_id.removeEnd('LOC');                                        
                
                if(addressesByLegacyId.containsKey(aims_id)) address.AMS_GDP_Key__c = addressesByLegacyId.get(aims_id)+'GDP';
               
            }
            else if(String.isNotBlank(address.Webstar_Id__c))
            {
                
                String webstar_id = address.Webstar_Id__c.removeEnd('GDP');
                if(addressesByLegacyId.containsKey(webstar_id))  address.AMS_GDP_Key__c = addressesByLegacyId.get(webstar_id)+'GDP';
                
            }
        }

        //DML 1
        Database.update(gdp_Address,false);
    }*/

    public static void updateAgencyOwner(List<Agency_Owner__c> agency_owner)
    {
        Set<String> GDPcommonKeys = new Set<String>();

        for(Agency_Owner__c ag:agency_owner)
        {
            GDPcommonKeys.add(ag.AIMS_ID__c);
        }

        //find corresponding AMS key

        Map<String, String> accountRoleMap = new Map<String, String>(); 

        for(AMS_Account_Role__c aRole: [SELECT Id, Legacy_External_Id__c FROM AMS_Account_Role__c WHERE Legacy_External_Id__c IN : GDPcommonKeys])
        {
            if(String.isNotBlank(aRole.Legacy_External_Id__c)) accountRoleMap.put(aRole.Legacy_External_Id__c, aRole.Id); 
        }


        if(agency_owner.size() > 0)
        {
            for(Agency_Owner__c ag : agency_owner)
            {

                if(ag.RecordType.DeveloperName == 'GDP') ag.AMS_GDP_Key__c =accountRoleMap.get(ag.AIMS_ID__c)+'GDP';
                else ag.AMS_GDP_Key__c =accountRoleMap.get(ag.AIMS_ID__c) ;
            }
            Database.update(agency_owner,false); 
        }
    }

    public static void updateAdjacentAirport(List<Adjacent_Airport__c> adjacent_airport)
    {
        Set<String> GDPcommonKeys = new Set<String>();
        Set<String> GDPCommonAccounts = new Set<String>();

        for(Adjacent_Airport__c airp:adjacent_airport)
        {
            //GDPcommonKeys.add(airp.AMS_GDP_Formula_Key__c);
            if(airp.RecordType.DeveloperName=='Live') GDPCommonAccounts.add(airp.Related_Account__c);
            else GDPCommonAccounts.add(airp.Related_GDP_Products_Account_View__r.AMS_GDP_Key__c);
        }

        //find corresponding AMS key

        Map<String, String> agencyAirportkeysMap = new Map<String, String>(); 

        for(AMS_Agency_Airport__c amsAir: [
            SELECT Id, AMS_2_GDP_Key__c,Airport__r.Code__c,Account__c
            FROM AMS_Agency_Airport__c 
            WHERE Account__c IN :GDPCommonAccounts])
        {
            if(String.isNotBlank(amsAir.AMS_2_GDP_Key__c))
            {
                agencyAirportkeysMap.put(amsAir.AMS_2_GDP_Key__c, amsAir.Id);   
                if(!String.isBlank(amsAir.Account__c))
                agencyAirportkeysMap.put(String.valueOf(amsAir.Account__c).substring(0, 15)+'-'+amsAir.Airport__r.Code__c,amsAir.Id);       
            }               
        }


        if(adjacent_airport.size() > 0)
        {
            for(Adjacent_Airport__c air : adjacent_airport)
            {
                
                if(air.RecordType.DeveloperName == 'GDP' && String.isNotBlank(air.Related_GDP_Products_Account_View__r.AMS_GDP_Key__c)) air.AMS_GDP_Key__c =agencyAirportkeysMap.get(air.Related_GDP_Products_Account_View__r.AMS_GDP_Key__c.left(15)+'-'+air.AirportCode__r.Code__c)+'GDP';
                else air.AMS_GDP_Key__c =agencyAirportkeysMap.get(air.AMS_GDP_Formula_Key__c) ;
            }
            Database.update(adjacent_airport, false); 
        }
    }

    public static void updateAssocAffiliationMembership(List<Assoc_Affiliation_Membership__c> affil_member)
    {
        
        Set<String> GDPcommonKeys = new Set<String>();
        Set<String> CommonAccounts = new Set<String>();

        for(Assoc_Affiliation_Membership__c aff:affil_member)
        {
            //GDPcommonKeys.add(aff.AMS_GDP_Mapping_Key__c);
            if(aff.RecordType.DeveloperName=='Live') CommonAccounts.add(aff.Related_Account__c);
            else CommonAccounts.add(aff.Related_GDP_Products_Account_View__r.AMS_GDP_Key__c);
        }

        Map<String,String> agencyAffiliationMap=new Map<String,String>();

        for(AMS_Agency_Affiliation__c affiliations: [SELECT Id, Name, Legacy_External_ID__c, Account__c, Legacy_System__c, Affiliation__r.Name, Affiliation__r.Affiliation_Code__c FROM AMS_Agency_Affiliation__c WHERE Account__c in : CommonAccounts] )
        {
            String AccountId;
            if(!String.isBlank(affiliations.Account__c))
            {
                AccountId = String.valueOf(affiliations.Account__c).substring(0, 15);
                agencyAffiliationMap.put(AccountId+affiliations.Affiliation__r.Affiliation_Code__c,affiliations.Id);
            }            
        }

        if(affil_member.size() > 0)
        {
            for(Assoc_Affiliation_Membership__c af : affil_member)
            {
                if(af.RecordType.DeveloperName == 'GDP' && String.isNotBlank(af.Related_GDP_Products_Account_View__r.AMS_GDP_Key__c)) 
                {

                    if(String.isNotBlank(agencyAffiliationMap.get(af.Related_GDP_Products_Account_View__r.AMS_GDP_Key__c.left(15)+af.Assoc_Affiliation_Code__r.Code__c)))
                    {
                        af.AMS_GDP_Key__c =agencyAffiliationMap.get(af.Related_GDP_Products_Account_View__r.AMS_GDP_Key__c.left(15)+af.Assoc_Affiliation_Code__r.Code__c)+'GDP';
                    }
                    else af.AMS_GDP_Key__c=null;
                }
                else{af.AMS_GDP_Key__c =agencyAffiliationMap.get(af.AMS_GDP_Mapping_Key__c) ;}
            }
            Database.update(affil_member,false); 
        }
    }

    public static void updateAgencyProfileSpecialization(List<GDP_Agency_Profile_Specialization__c> lst)
    {
        //-- Key = Account_ID+'GDP'
        Set<String> legacy_ids = new Set<String>();
        
        for(GDP_Agency_Profile_Specialization__c gdp : lst)
        {
            if(gdp.AIMS_ID__c!=null) legacy_ids.add(gdp.AIMS_ID__c.removeEnd('GDP'));
            if(gdp.WebStar_ID__c!=null) legacy_ids.add(gdp.WebStar_ID__c.removeEnd('GDP'));
        }

        Map<String, String> accountsByLegacyId = new Map<String, String>(); 
        for(Account acc: [SELECT Id, AIMS_Id__c, Webstar_Id__c FROM Account WHERE AIMS_Id__c IN :legacy_ids OR Webstar_Id__c IN:legacy_ids])
        {
            if(String.isNotBlank(acc.AIMS_Id__c)) accountsByLegacyId.put(acc.AIMS_Id__c, acc.Id);
            if(String.isNotBlank(acc.Webstar_Id__c)) accountsByLegacyId.put(acc.Webstar_Id__c, acc.Id);
        }

        for(GDP_Agency_Profile_Specialization__c gdp : lst)
        {
            if(String.isNotBlank(gdp.AIMS_Id__c) && accountsByLegacyId.containsKey(gdp.AIMS_ID__c.removeEnd('GDP'))) gdp.AMS_GDP_Key__c = accountsByLegacyId.get(gdp.AIMS_ID__c.removeEnd('GDP'));
            else if(String.isNotBlank(gdp.Webstar_Id__c) && accountsByLegacyId.containsKey(gdp.Webstar_Id__c.removeEnd('GDP'))) gdp.AMS_GDP_Key__c = accountsByLegacyId.get(gdp.Webstar_Id__c.removeEnd('GDP'));
        }

        Database.update(lst,false); 
    }

    public static void updateGSATerritory(List<GSA_Territory__c> lst)
    {
        Set<String> keys = new Set<String>();
        for(GSA_Territory__c gsa: lst)
        {
            keys.add(gsa.AIMS_Id__c+gsa.Airline_Code__c+gsa.Territory_ISO_Country__c+gsa.Territory_IATA_Numeric_Country_Code__c);
        }


        Map<String, String> territoryByLegacyId = new Map<String, String>(); 
        for(AMS_Territory__c ams : [SELECT Id, Legacy_Id__c FROM AMS_Territory__c WHERE Legacy_Id__c IN  :keys])
        {
            territoryByLegacyId.put(ams.Legacy_Id__c, ams.Id);
        }

        for(GSA_Territory__c gsa: lst)
        {
            String key = gsa.AIMS_Id__c+gsa.Airline_Code__c+gsa.Territory_ISO_Country__c+gsa.Territory_IATA_Numeric_Country_Code__c;
            if(territoryByLegacyId.containsKey(key)) gsa.AMS_GDP_Key__c = territoryByLegacyId.get(key)+'GDP';
        }

        Database.update(lst,false); 
    }
    public static void updateAMSAppointment(List<AMS_Inspection__c> lst)
    {
        Database.update(lst,false); 
    }
}