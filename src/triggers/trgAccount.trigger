trigger trgAccount on Account (before update, before insert) {
    if (!IECConstants.GDPReplication_ProfileIDswithAccess.contains(UserInfo.getProfileId().substring(0, 15))) {
        if (trigger.isBefore && trigger.isInsert) {
            for (Account a : trigger.new){      
                if (a.Is_AIMS_Account__c || a.WebStar_ID__c != null) {
                    a.addError(Label.Cannot_Update_AIMS_values);
                }
            }
        }
        else if (trigger.isBefore && trigger.isUpdate) {
            for (Account a : trigger.new){      
                if (a.Is_AIMS_Account__c || a.WebStar_ID__c != null) {
                    system.debug('Entered as normal user - field validation');
                    // Check if value of fields related to AIMS interface was updated
                    Account oldValue = trigger.oldMap.get(a.Id);    // Get Old Account object values
                        
                    // Error messages are displayed beside updated fields. Only when its an AIMS field.
                    if (a.TradeName__c != oldValue.TradeName__c) a.TradeName__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.BillingStreet != oldValue.BillingStreet) a.BillingStreet.addError(Label.Cannot_Update_AIMS_values);
                    if (a.BillingState != oldValue.BillingState) a.BillingState.addError(Label.Cannot_Update_AIMS_values);
                    if (a.ShippingCity != oldValue.ShippingCity) a.ShippingCity.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Accreditation_date__c != oldValue.Accreditation_date__c) a.Accreditation_date__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Description != oldValue.Description) a.Description.addError(Label.Cannot_Update_AIMS_values);
                    if (a.BillingPostalCode != oldValue.BillingPostalCode) a.BillingPostalCode.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Source_System__c != oldValue.Source_System__c) a.Source_System__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Fax != oldValue.Fax) a.Fax.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Rating != oldValue.Rating) a.Rating.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Name != oldValue.Name) a.Name.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Phone != oldValue.Phone) a.Phone.addError(Label.Cannot_Update_AIMS_values);
                    if (a.IATACode__c != oldValue.IATACode__c) a.IATACode__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.ShippingStreet != oldValue.ShippingStreet) a.ShippingStreet.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Location_Type__c != oldValue.Location_Type__c) a.Location_Type__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.AIMS_ID__c != oldValue.AIMS_ID__c) a.AIMS_ID__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.WebStar_ID__c != oldValue.WebStar_ID__c) a.WebStar_ID__c.addError(Label.Cannot_Update_AIMS_values);
             //      if (a.Type != oldValue.Type) a.Type.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Status__c != oldValue.Status__c) a.Status__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.ShippingCountry != oldValue.ShippingCountry) a.ShippingCountry.addError(Label.Cannot_Update_AIMS_values);
                    if (a.VAT_Number_2__c != oldValue.VAT_Number_2__c) a.VAT_Number_2__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.VAT_Number__c != oldValue.VAT_Number__c) a.VAT_Number__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.ShippingPostalCode != oldValue.ShippingPostalCode) a.ShippingPostalCode.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Website != oldValue.Website) a.Website.addError(Label.Cannot_Update_AIMS_values);
                    if (a.BillingCountry != oldValue.BillingCountry) a.BillingCountry.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Email__c != oldValue.Email__c) a.Email__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Expiry_Date__c != oldValue.Expiry_Date__c) a.Expiry_Date__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Site != oldValue.Site) a.Site.addError(Label.Cannot_Update_AIMS_values);
                    if (a.BillingCity != oldValue.BillingCity) a.BillingCity.addError(Label.Cannot_Update_AIMS_values);
                   // if (a.Financial_Year_End__c != oldValue.Financial_Year_End__c) a.Financial_Year_End__c.addError(Label.Cannot_Update_AIMS_values);
                   // if (a.Fin_statements_submission_deadline__c != oldValue.Fin_statements_submission_deadline__c) a.Fin_statements_submission_deadline__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Short_Name__c != oldValue.Short_Name__c) a.Short_Name__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Accumulated_Irregularities__c != oldValue.Accumulated_Irregularities__c) a.Accumulated_Irregularities__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Is_AIMS_Account__c != oldValue.Is_AIMS_Account__c) a.Is_AIMS_Account__c.addError(Label.Cannot_Update_AIMS_values);
        
                    if (a.License_Number__c != oldValue.License_Number__c) a.License_Number__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Manager_First_Name__c != oldValue.Manager_First_Name__c) a.Manager_First_Name__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Manager_Last_Name__c != oldValue.Manager_Last_Name__c) a.Manager_Last_Name__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Passenger_And_Cargo__c != oldValue.Passenger_And_Cargo__c) a.Passenger_And_Cargo__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Ticketing_Agent_First_Name__c != oldValue.Ticketing_Agent_First_Name__c) a.Ticketing_Agent_First_Name__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Ticketing_Agent_Last_Name__c != oldValue.Ticketing_Agent_Last_Name__c) a.Ticketing_Agent_Last_Name__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Airline_Code__c != oldValue.Airline_Code__c) a.Airline_Code__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.BSP_CASS_Code__c != oldValue.BSP_CASS_Code__c) a.BSP_CASS_Code__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.CASS_Number__c != oldValue.CASS_Number__c) a.CASS_Number__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.CASS_Number_Xref__c != oldValue.CASS_Number_Xref__c) a.CASS_Number_Xref__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.GDP_Location_Type__c != oldValue.GDP_Location_Type__c) a.GDP_Location_Type__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.GDP_Opt_In__c != oldValue.GDP_Opt_In__c) a.GDP_Opt_In__c.addError(Label.Cannot_Update_AIMS_values);
                    if (a.Incorporation_Type__c != oldValue.Incorporation_Type__c) a.Incorporation_Type__c.addError(Label.Cannot_Update_AIMS_values);
                }
            }
        }
    }
}