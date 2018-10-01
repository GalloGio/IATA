trigger CaseBeforInsert on Case (before insert,after insert) {

    if(trigger.isInsert){
        ISSP_Case.preventTrigger = true;
    }
    
    if(trigger.isBefore){
        set<string> CountryNameSet = new set<string>();
        map<string,IATA_ISO_Country__c> IATAISOCountryMap = new map<string,IATA_ISO_Country__c>();
        List<Mapping_for_CSR_Cases__c> CSRCasesMapping = Mapping_for_CSR_Cases__c.getAll().values();
        List<Case> parentAccount;
        List<Contact> accountFromRelatedContact;
        
        for(Case newCase : trigger.new){
            CountryNameSet.add(newCase.Country_concerned_by_the_query__c);
        }
        
        for(IATA_ISO_Country__c iso : IATAIsoCountryDAO.getIsoCountryByCountriesName(CountryNameSet)){
            IATAISOCountryMap.put(iso.Name ,iso);
        }
        
        for(Case newCase : trigger.new){
            Id RT_Fin_Sec_Monitoring_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Security_Monitoring');
            Id Financtial_Sec_Monitoring_Id = RecordTypeSingleton.getInstance().getRecordTypeId('EmailTemplate__c', 'FSM');
            
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
            
            if(newCase.RecordTypeId == RT_Fin_Sec_Monitoring_Id){ // INC244104 - Start
 
                List<Account> acc = [SELECT Id, Sector__c, Category__c, IATA_ISO_Country__c FROM Account WHERE Id = :newCase.AccountId limit 1];
                Financial_Monitoring_Template__c cs = new Financial_Monitoring_Template__c();
                List<String> listCategories = new List<String>();
                String categoryValues;
                Boolean exist = false;
                
                if(!acc.isEmpty()){
                    cs = Financial_Monitoring_Template__c.getInstance(acc[0].Sector__c);
                    if(cs != null){ //it means that the sector is in the Custom Setting
                        categoryValues = cs.Category__c;
                        listCategories = categoryValues.split(',');

                        for(String cat : listCategories){
                            if(cat == acc[0].Category__c)
                                exist = true;
                        }
                    }
                }
 
                if(exist == true){
                    EmailTemplate__c templateToUse = [SELECT id, Name, Agent_Type__c,IATA_ISO_Country__c 
                                                        FROM  EmailTemplate__c 
                                                        WHERE Agent_Type__c =: cs.Email_Template_Agency_Type__c AND IATA_ISO_Country__c = :acc[0].IATA_ISO_Country__c limit 1];
 
                    if(templateToUse != null)
                        newCase.Reminder_EmailTemplate__c = templateToUse.Id;
                }                
            } // INC244104 - End       
            
            // INC237713 - Start
            String caseParentId = newCase.ParentId;
            
             for(Mapping_for_CSR_Cases__c m : CSRCasesMapping){
                String contactId = m.Contact_Id__c;

                if(m.Record_Type_Id__c == newCase.RecordTypeId && m.DPC_System__c == newCase.DPC_Software__c){
                    accountFromRelatedContact = [SELECT Id, AccountId from Contact where Id = :contactId];
                    parentAccount = [SELECT Id, AccountId from Case where Id = :caseParentId];
                    
                    if(contactId != null) newCase.ContactId = contactId;
                    
                    if(accountFromRelatedContact.size()>0)newCase.AccountId = accountFromRelatedContact[0].AccountId;

                    if(parentAccount.size()>0) newCase.Account_Concerned__c = parentAccount[0].AccountId;
                    
                    if(accountFromRelatedContact.size()>0 && parentAccount.size()>0) 
                        newCase.Visible_on_ISS_Portal__c = m.Access_to_portal__c;
                }
             } // INC237713 - End
        }
        

        
        
        
        // Fill the Region, IATA Country, Case Area and Reason fields on FAQ Translation Request cases coming from Email2Case
        //FAQTranslationRequestHelper.HandleFAQTranslationRequests(Trigger.new);
    }
    if(trigger.isAfter){
        set<ID> casesIds = new set<ID>();
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
        
        Id RT_AirlineSuspension_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Suspension');
        Id RT_AirlineDeactivation_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Deactivation');
        Id RT_FundsManagement_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Funds_Management');
        Id RT_DIP_Review_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'DIP_Review_Process');
        
        for (Case c : trigger.new) {
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