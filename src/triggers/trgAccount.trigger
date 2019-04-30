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

        List<IATA_ISO_Country__c> countryListId;

        if (trigger.isBefore && trigger.isUpdate) {
            
            // Changes on lock fields are allowed only for countries OSCAR enabled
            // First trial: I note all the countries of the account which have a change in the locked fields
            for (Account a : trigger.new){      
                if (a.Is_AIMS_Account__c || a.WebStar_ID__c != null) {
                    system.debug('Entered as normal user - field validation');
                    // Check if value of fields related to AIMS interface was updated
                    Account oldValue = trigger.oldMap.get(a.Id);    // Get Old Account object values
                        
                    for(String field : fieldsToBeLocked){
                        system.debug('trgAccount --> field = '+field+ '  - newvalue = '+a.get(field)+' - oldValue = '+oldvalue.get(field));  

                        if(a.get(field) != oldValue.get(field)){

                            countryListId = new List<IATA_ISO_Country__c>();
                            countryListId = IATAIsoCountryDAO.getIsoCountriesByIds(new Set<Id>{a.IATA_ISO_Country__c});

                            if(a.IATA_ISO_Country__c != null || !countryListId.isEmpty()) { 
                                if(countryListId.get(0).OSCAR_Enabled__c != true){
                                    a.addError(Label.Cannot_Update_AIMS_values);
                                    break;  
                                }
                            }else {
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