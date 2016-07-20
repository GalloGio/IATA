trigger CaseBeforInsert on Case (before insert,after insert) {

    if(trigger.isInsert){
        ISSP_Case.preventTrigger = true;
    }

    if(trigger.isBefore){
        set<string> CountryNameSet = new set<string>();
        map<string,IATA_ISO_Country__c> IATAISOCountryMap = new map<string,IATA_ISO_Country__c>();
        
        
        for(Case newCase : trigger.new){
            CountryNameSet.add(newCase.Country_concerned_by_the_query__c);
        }
        
        for(IATA_ISO_Country__c iso : [select Id,ISO_Code__c,Name,Region__c,Case_BSP_Country__c from IATA_ISO_Country__c where Name in:CountryNameSet]){
            IATAISOCountryMap.put(iso.Name ,iso);
        }
        
        for(Case newCase : trigger.new){
            if(IATAISOCountryMap.get(newCase.Country_concerned_by_the_query__c)!=null){
                system.debug('\n\n\n Region__c '+newCase.Region__c +'\n\n\n');
                IATA_ISO_Country__c iso = IATAISOCountryMap.get(newCase.Country_concerned_by_the_query__c);
                newCase.IFAP_Country_ISO__c = iso.ISO_Code__c;
                newCase.BSPCountry__c = iso.Case_BSP_Country__c;
                newCase.Region__c = iso.Region__c;
                 system.debug('\n\n\n Region__c '+newCase.Region__c +'\n\n\n');
            }
            else{
                newCase.Country_concerned_by_the_query__c = newCase.BSPCountry__c;
            }
        }
        
        
        // Fill the Region, IATA Country, Case Area and Reason fields on FAQ Translation Request cases coming from Email2Case
        //FAQTranslationRequestHelper.HandleFAQTranslationRequests(Trigger.new);
    }
    if(trigger.isAfter){
        set<string> casesIds = new set<string>();
        for(Case newCase : trigger.new){
            if(newCase.Origin == 'Portal'){
                User[] users = [Select u.UserType From User u where u.Id =: UserInfo.getUserId()];
                if (users != null && users.size() > 0){
                    if (users[0].UserType == 'PowerPartner' || users[0].UserType == 'Guest'){
                        casesIds.add(newCase.Id);
                    }
                }
            }
        }
        if(casesIds.size() > 0 && !Test.isRunningTest()) ISSP_Utilities.DMLOpt(casesIds);
        
        
        // Create Airline Suspension or DIP Details child records for the cases with the Airline Suspension RT / DIP Review Process RT
        Set<Id> setASCaseIds = new Set<Id>();
        Set<Id> setDIPCaseIds = new Set<Id>();
        
        Id RT_AirlineSuspension_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('Airline_Suspension');
        Id RT_AirlineDeactivation_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('Airline_Deactivation');
        Id RT_FundsManagement_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('Funds_Management');
        Id RT_DIP_Review_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('DIP_Review_Process');
        
        for (Case c : trigger.new) {
            system.debug('aqui c ' + c.RecordTypeId + ' suspensio-recordtype ' + RT_AirlineSuspension_Id);
            if (c.RecordTypeId == RT_AirlineSuspension_Id || c.RecordTypeId == RT_AirlineDeactivation_Id || c.RecordTypeId == RT_FundsManagement_Id) {
                setASCaseIds.add(c.Id);
            } else if (c.RecordTypeId == RT_DIP_Review_Id) {
                setDIPCaseIds.add(c.Id);
            }
            
        }
        
        if (!setASCaseIds.isEmpty()) AirlineSuspensionUtil.CreateAirlineSuspensionRecords(setASCaseIds);
        if (!setDIPCaseIds.isEmpty()) DIPdetailsUtil.CreateDIPDetailsRecords(setDIPCaseIds);
    }
}