trigger trgAccount on Account (before update, before insert) {

    if(!AMS_TriggerExecutionManager.checkExecution(Account.getSObjectType(), 'trgAccount')) { return; }  

    if (!IECConstants.GDPReplication_ProfileIDswithAccess.contains(UserInfo.getProfileId().substring(0, 15)) && !AMS_Utils.isAMSProfile(UserInfo.getProfileId().substring(0, 15))) {
        List<String> fieldsToBeLocked = new List<String>{
            'TradeName__c','BillingStreet','BillingState','ShippingCity','Accreditation_date__c','Description','BillingPostalCode','Source_System__c','Fax','Rating','Name','Phone',
            'IATACode__c','ShippingStreet','Location_Type__c','AIMS_ID__c','WebStar_ID__c','Status__c','ShippingCountry','VAT_Number_2__c','VAT_Number__c','ShippingPostalCode',
            'Website','BillingCountry','Email__c','Expiry_Date__c','Site','BillingCity','Short_Name__c','Accumulated_Irregularities__c','Is_AIMS_Account__c','License_Number__c',
            'Manager_First_Name__c','Manager_Last_Name__c','Passenger_And_Cargo__c','Ticketing_Agent_First_Name__c','Ticketing_Agent_Last_Name__c','Airline_Code__c','BSP_CASS_Code__c',
            'CASS_Number__c','CASS_Number_Xref__c','GDP_Location_Type__c','GDP_Opt_In__c','Incorporation_Type__c'
        };

        Set<Id> countryIds = new Set<Id>(); 

        if (trigger.isBefore && trigger.isInsert) {
            for (Account a : trigger.new){      
                if (a.Is_AIMS_Account__c || a.WebStar_ID__c != null) {
                    //a.addError(Label.Cannot_Update_AIMS_values);
                    countryIds.add(a.IATA_ISO_Country__c);
                }
            }
        }
        else if (trigger.isBefore && trigger.isUpdate) {
            
            // Changes on lock fields are allowed only for countries OSCAR enabled
            // First trial: I note all the countries of the account which have a change in the locked fields
            for (Account a : trigger.new){      
                if (a.Is_AIMS_Account__c || a.WebStar_ID__c != null) {
                    system.debug('Entered as normal user - field validation');
                    // Check if value of fields related to AIMS interface was updated
                    Account oldValue = trigger.oldMap.get(a.Id);    // Get Old Account object values
                        
                    for(String field : fieldsToBeLocked){
                        if(a.get(field) != oldValue.get(field)){
                            system.debug('trgAccount --> field = '+field+ '  - newvalue = '+a.get(field)+' - oldValue = '+oldvalue.get(field));  
                            countryIds.add(a.IATA_ISO_Country__c);
                            break;
                        }
                    }
                }
            }
            
            // If necessary I query the countries and check again the accounts
            if(countryIds.size()>0){
                Map<Id, IATA_ISO_Country__c> idToCountry = new Map<Id, IATA_ISO_Country__c>(IATAIsoCountryDAO.getIsoCountriesByIds(countryIds));

                // First trial: I note all the countries of the account which have a change in the locked fields
                for (Account a : trigger.new){      
                    if (a.Is_AIMS_Account__c || a.WebStar_ID__c != null) {
                        system.debug('Entered as normal user - field validation');
                        // Check if value of fields related to AIMS interface was updated
                        Account oldValue = trigger.oldMap.get(a.Id);    // Get Old Account object values
                        system.debug('trgAccount --> '+a.IATA_ISO_Country__c +' find in the map '+idToCountry.get(a.IATA_ISO_Country__c));    
                        for(String field : fieldsToBeLocked){
                            if(a.get(field) != oldValue.get(field) && 
                               (a.IATA_ISO_Country__c==null || idToCountry.get(a.IATA_ISO_Country__c)==null || idToCountry.get(a.IATA_ISO_Country__c).OSCAR_Enabled__c!=true)){
                                a.addError(Label.Cannot_Update_AIMS_values);
                                break;    
                            }
                        }
                    }
                }
            }
        }
    }
}