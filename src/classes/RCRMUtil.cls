public without sharing class RCRMUtil {
        
    /*
     *  Handles the actions of the After Insert trigger for RCRM opportunities
     */
    public static void HandleRCRMOpportunityAfterInsert (Map<Id, Opportunity> mapTriggerNew) {
        
    }
    
    /*
     *  Handles the actions of the Before Update trigger for RCRM opportunities
     */
    public static void HandleRCRMOpportunityBeforeUpdate (Map<Id, Opportunity> mapTriggerNew, Map<Id, Opportunity> mapTriggerOld) {
        
        // Only interested in Opportunities with the RCRM Opportunity record type
        Id RT_RCRM_Opportunity_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'RCRM_Opportunity');
                
        
        //////////////////////////
        // Handle the closing of RCRM opportunities and creation/update of the Contract
        //////////////////////////
        
            map<Id,Opportunity> mapWonOpportunitiesPerId = new map<Id,Opportunity>();
            map<Id,Opportunity> mapLostOpportunitiesPerId = new map<Id,Opportunity>();
            
            for (Opportunity opp : mapTriggerNew.values()) {
                
                system.debug('Opp Amount: ' + opp.Amount + ' - Product Manager: ' + opp.RCRM_Product_Manager__c + ' - Validation Status:' + opp.RCRM_Validation_Status__c);
                // map of opportunities closed WON && that have RCRM products attached and have an amount > 0 (catch errors here)
                if (opp.RecordTypeId == RT_RCRM_Opportunity_Id && 
                    mapTriggerOld.get(opp.Id).StageName != '7. Closed Sales / Sold' && 
                    mapTriggerNew.get(opp.Id).StageName == '7. Closed Sales / Sold' &&
                    opp.Amount != null &&
                    opp.Amount > 0 && 
                    opp.RCRM_Product_Manager__c != null &&
                    opp.RCRM_Validation_Status__c == 'Validated by PM') {
                        Opportunity o = mapTriggerNew.get(opp.Id);
                        system.debug('a ' + o.Owner.Email);
                        mapWonOpportunitiesPerId.put(opp.Id, opp);
                    }
                    
                // map of opportunities closed LOST
                if (opp.RecordTypeId == RT_RCRM_Opportunity_Id && 
                    mapTriggerOld.get(opp.Id).StageName != 'z. Lost' && 
                    mapTriggerNew.get(opp.Id).StageName == 'z. Lost') {
                        mapLostOpportunitiesPerId.put(opp.Id, opp);
                    }
            }
            
            // Handle WON RCRM opportunities
            if (! mapWonOpportunitiesPerId.values().isEmpty()) {
                
                // List of all the OpportunityLineItems related to these opportunities and containing a product from the RCRM project scope
                List<OpportunityLineItem> lstAllRcrmOLIs = [SELECT Id, OpportunityId, Product2Id, Product2.Product_Manager_lookup__c, Product2.Reminder_interval__c, 
                                            Product2.Family, CurrencyIsoCode, PricebookEntryId, UnitPrice, Quantity FROM OpportunityLineItem 
                                            WHERE Product2.RCRM_Product__c = true AND OpportunityId IN :mapWonOpportunitiesPerId.keyset()];
                
                system.debug('Aqui Related OLI: ' + lstAllRcrmOLIs);
                //Create a map of lists of OLIs per Opportunity Id (the goal is to have a list of the RCRM Product Id per Opportunity Id)
                Map<Id, List<OpportunityLineItem>> mapRcrmOLIPerOppId = new Map<Id, List<OpportunityLineItem>>();
                for (OpportunityLineItem oli : lstAllRcrmOLIs) {
                    if (mapRcrmOLIPerOppId.get(oli.OpportunityId) == null) {
                        mapRcrmOLIPerOppId.put(oli.OpportunityId, new List<OpportunityLineItem>());
                    }
                    
                    mapRcrmOLIPerOppId.get(oli.OpportunityId).add(oli);
                }
                
                system.debug('Map of OLIs: ' + mapWonOpportunitiesPerId + ' - ' + mapRcrmOLIPerOppId);
                // Validate opportunity for close, create / update Contract, update RSLs type to Booked 
                RCRMUtil.CreateUpdateContract(mapWonOpportunitiesPerId, mapRcrmOLIPerOppId);
                
                // Create future Opportunity 
                RCRMUtil.CreateFutureOpportunity(mapWonOpportunitiesPerId, mapRcrmOLIPerOppId);  
            }
            
            
            // Handle LOST opportunities
            if (! mapLostOpportunitiesPerId.values().isEmpty()) {
                // Remove estimated stream lines
                RCRMUtil.DeleteRevenueStreamLines(mapLostOpportunitiesPerId);
                
                // If there were renewal opportunities, set the contract renewal status to "Not renewed" for the expiring contracts linked to them
                List<Id> lstExpiringContractIds = new List<Id>();
                for (Opportunity opp : mapLostOpportunitiesPerId.values()) {
                	if (opp.Expiring_contract__c != null) {
                		lstExpiringContractIds.add(opp.Expiring_contract__c);
                	}
                }
                
                if (!lstExpiringContractIds.isEmpty()) {
                	List<Contract> lstExpiringContracts = [SELECT Id, Renewal_Status__c FROM Contract WHERE Id IN :lstExpiringContractIds];
                	
                	for (Contract c : lstExpiringContracts) {
                		c.Renewal_Status__c = 'Not renewed';
                	}
                	
                	update lstExpiringContracts;
                }
                
            }
        
        
        //////////////////////////
        // Handle the update of RCRM opportunities to the stage of "6. Contract stage" and the generation of Revenue Stream Lines
        //////////////////////////
            
            // Get a list of the opportunities that had their stage changed to Contract Preparation and generate RSLs for them 
            map<Id,Opportunity> mapOpportunitiesToGetRSLsPerId = new map<Id,Opportunity>();
            for (Opportunity opp : mapTriggerNew.values()) {
                if (opp.RecordTypeId == RT_RCRM_Opportunity_Id && 
                    mapTriggerOld.get(opp.Id).StageName != '6. Contract stage' && 
                    mapTriggerNew.get(opp.Id).StageName == '6. Contract stage') {
                    	if (opp.Current_Cycle_End_Date__c == null || opp.Start_Date__c == null || opp.Renewal_duration_in_months__c == null) {
                    		opp.addError('You need to set the contract information ( Start Date, Expiry Date and Renewal duration) before passing to the "Contract Stage".');
                    	} else {
                        	mapOpportunitiesToGetRSLsPerId.put(opp.Id, opp);
                    	}
                    }
            }
            
            if (! mapOpportunitiesToGetRSLsPerId.values().isEmpty()) {
                
                // List of all the OpportunityLineItems related to these opportunities and containing a product from the RCRM project scope
                List<OpportunityLineItem> lstAllRcrmOLIs = [SELECT Id, OpportunityId, Product2Id, Product2.Product_Manager_lookup__c, CurrencyIsoCode, PricebookEntryId,
                                            UnitPrice, Quantity FROM OpportunityLineItem WHERE Product2.RCRM_Product__c = true AND OpportunityId IN :mapOpportunitiesToGetRSLsPerId.keyset()];
                
                //Create a map of the OLIs per Opportunity Id (the goal is to have the RCRM Product Id per Opportunity Id)
                Map<Id, List<OpportunityLineItem>> mapRcrmOLIPerOppId = new Map<Id, List<OpportunityLineItem>>();
                for (OpportunityLineItem oli : lstAllRcrmOLIs) {
                    if (mapRcrmOLIPerOppId.get(oli.OpportunityId) == null) {
                        mapRcrmOLIPerOppId.put(oli.OpportunityId, new List<OpportunityLineItem>());
                    }
                    
                    mapRcrmOLIPerOppId.get(oli.OpportunityId).add(oli);
                }
                
                // Remove existing RSLs for these Opportunities (could be RSLs for the future renewal, extending on more/less years than necessary, 
                // or RSLs already generated and the user mistakenly selected this stage again)
                RCRMUtil.DeleteRevenueStreamLines(mapOpportunitiesToGetRSLsPerId);
                
                // Create Revenue Stream Lines for the Opportunities
                RCRMUtil.GenerateRevenueStreamLines(mapOpportunitiesToGetRSLsPerId, mapRcrmOLIPerOppId); 
            }
                    
    }
    
    
    /*
     *  Closes the opportunity and creates or updates the related contract for each of the oppportunities transmitted in the lstOpportunities parameter.
     *  Checks whether it is a new contract, a renewal as-is or an amended contract.
     */
    public static void CreateUpdateContract (Map<Id,Opportunity> mapOpportunitiesPerId, Map<Id, List<OpportunityLineItem>> mapRcrmOLIPerOppId) {
        Id RT_RCRM_Contract_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Contract', 'RCRM_Contract');
        
        system.debug('Entrou no update do contracto');
        // List of Opportunities from the parameter map
        List<Opportunity> lstOpportunities = mapOpportunitiesPerId.values();
        
        // List of Contracts to insert / update (different lists, because new contracts need first to be created and then updated to be activated)
        List<Contract> lstContractsToInsert = new List<Contract>();
        List<Contract> lstContractsToUpdate = new List<Contract>();  
        List<Contract> lstContractsToCancel = new List<Contract>(); // for early renewals     
                
        // Get list of expiring contract IDs
        List<Id> lstExpConIds = new List<Id>();
        
        for (Opportunity opp : lstOpportunities) {
            if (opp.Expiring_contract__c != null) {
                lstExpConIds.add(opp.Expiring_contract__c);
            }
        }
        
        system.debug('Tem opp a expirar.');
        // Get info from the expiring contracts into a map of contracts per contract Id
        Map<Id, Contract> mapExpContractsPerId = new Map<Id, Contract>([SELECT Id, ContractTerm, Booking_value__c, Number_of_times_renewed__c, 
                                                                    Renewal_under_Sales_Responsibility__c, Renewal_Status__c, Current_Opportunity__c, Opportunity_OwnerEmail__c  
                                                                    FROM Contract WHERE Id IN :lstExpConIds]);
        
        system.debug('Oportunidades a listar: ' + lstOpportunities);
        //////////////////////////
        // Get the RCRM OLIs from the opportunities that created/updated the EXPIRING contracts, in order to compare them with the current RCRM OLIs lists
        Map<Id, List<OpportunityLineItem>> mapOLDRcrmOLIPerExpContractId = new  Map<Id, List<OpportunityLineItem>>();
        // get the list of IDs of old opportunities for the expiring contracts
        List<Id> lstExpConOppIds = new List<Id>();
        for (Contract c : mapExpContractsPerId.values()) {
            lstExpConOppIds.add(c.Current_opportunity__c);
        }
        // List of all the OpportunityLineItems related to these opportunities and containing a product from the RCRM project scope
        List<OpportunityLineItem> lstAllOldOppRcrmOLIs = [SELECT Id, OpportunityId, Product2Id, Product2.Product_Manager_lookup__c, CurrencyIsoCode, PricebookEntryId,
                                    UnitPrice, Quantity FROM OpportunityLineItem WHERE Product2.RCRM_Product__c = true AND OpportunityId IN :lstExpConOppIds];
        
        //Create a map of the OLIs per expiring Contract Id
        for (Contract expCon : mapExpContractsPerId.values()) {
            for (OpportunityLineItem oldOLI : lstAllOldOppRcrmOLIs) {
                if (oldOLI.OpportunityId == expCon.Current_Opportunity__c) {
                    if (mapOLDRcrmOLIPerExpContractId.get(expCon.Id) == null) {
                        mapOLDRcrmOLIPerExpContractId.put(expCon.Id, new List<OpportunityLineItem>());
                    }
                    
                    mapOLDRcrmOLIPerExpContractId.get(expCon.Id).add(oldOLI);
                }
            }
        }
        //////////////////////////
        
        system.debug('OLI por Opp Id: ' + mapRcrmOLIPerOppId);
        for (Opportunity opp : lstOpportunities) {

            List<Opportunity> email = [select id, Owner.Email from Opportunity where id = :opp.Id];
            List<Opportunity> emailManager = [select id, RCRM_Product_Manager__r.Email from Opportunity where id = :opp.Id];
            List<Opportunity> emailAltManager = [select id, Alternate_RCRM_Product_Manager__r.Email from Opportunity where id = :opp.Id];
            
            system.debug('Aqui email do owner: ' + email[0].Owner.Email + '+ Aqui email do Manager: ' + emailManager[0].RCRM_Product_Manager__r.Email);
            // Validate Opportunity - a RCRM product needs to be present
            if (mapRcrmOLIPerOppId.get(opp.Id) == null || mapRcrmOLIPerOppId.get(opp.Id).isEmpty()) {
                // No RCRM product present => prevent the opportunity from being closed
                opp.addError('ERROR - The Opportunity cannot be closed because there is no RCRM product attached to it. You need to either add a RCRM product, or change the opportunity record type.');
                
            } else if (opp.Expiring_contract__c == null) {
                
                system.debug('Opp Owner: ' + opp.Owner.Name + ' - Opp Amount:  ' + opp.Amount);
                // NEW CONTRACT
                Contract newContract = new Contract();
                newContract.Name = opp.Name.startsWith('Renewal - ') ? opp.Name.replaceFirst('Renewal - ','') : opp.Name;
                newContract.RecordTypeId = RT_RCRM_Contract_Id;
                newContract.Number_of_times_renewed__c = 0;
                newContract.Replaces_contract__c = null;
                newContract.AccountId = opp.AccountId;
                
                newContract.StartDate = opp.Start_Date__c;
                newContract.Current_Cycle_Start_Date__c = opp.Start_Date__c;
                newContract.Contract_Renewal_Cycle_in_months__c = Integer.valueOf(opp.Renewal_duration_in_months__c);
                newContract.Current_Cycle_End_Date__c = opp.Current_Cycle_End_Date__c;
                
                newContract.Product_Family__c = opp.Product_Family__c;
                newContract.RCRM_Product_Manager__c = opp.RCRM_Product_Manager__c;
                newContract.ContractTerm = Integer.valueOf(opp.Renewal_duration_in_months__c); // required field; we do not use this for RCRM 
                newContract.Renewal_under_Sales_Responsibility__c = opp.Renewal_under_Sales_Responsibility__c; 
                newContract.Booking_value__c = opp.Amount;
                newContract.CurrencyIsoCode = opp.CurrencyIsoCode;
                newContract.Status = 'Draft';
                newContract.Current_Opportunity__c = opp.Id;
                newContract.Opportunity_OwnerEmail__c = email[0].Owner.Email; // Get the owner email from the current Opportunity
                newContract.RCRM_Product_Manager_Email__c = emailManager[0].RCRM_Product_Manager__r.Email;
                newContract.Alternate_RCRM_Product_Manager_Email__c = emailAltManager[0].Alternate_RCRM_Product_Manager__r.Email;

                //send email to Opp owner, RCRM Manager and Alternate RCRM Manager
                
                if (opp.Renewal_under_Sales_Responsibility__c && opp.RCRM_Product_Manager__c != null) {
                    newContract.OwnerId = opp.OwnerId; // we suppose the SM owns the Opportunity, since it's their responsibility - no other way of getting info on the SM
                } else {
                    newContract.OwnerId = opp.RCRM_Product_Manager__c;
                }
                
                lstContractsToInsert.add(newContract);
                
            } else if (mapExpContractsPerId.get(opp.Expiring_contract__c) == null) {
                
                // ERROR - this should not happen, if the Expiring_contract__c is not null then the contract should be in the map
                opp.addError('ERROR - the expiring contract could not be found. Please contact the System Administrator or the Support.');
                
            } else {
                // EXISTING CONTRACT - check if amended contract or new one
                Contract expContract = mapExpContractsPerId.get(opp.Expiring_contract__c);
                                
                // check if the contract is renewed with the same terms
                // opp.Amount == expContract.Booking_value__c >>> amount checked in the RCRMUtil.OLIsContainTheSameProducts method, to include only the RCRM amounts
                if (opp.Renewal_duration_in_months__c == expContract.ContractTerm &&
                    RCRMUtil.OLIsContainTheSameProducts( mapRcrmOLIPerOppId.get(opp.Id), mapOLDRcrmOLIPerExpContractId.get(expContract.Id) ) ) {
                        
                        // SAME TERMS => contract renewed as-is
                        // only update the renewal status, renewal counter and the contract dates and booking value (initial contract might have had other non-rcrm products)
                        expContract.Renewal_Status__c = 'Renewed as-is';
                        expContract.Number_of_times_renewed__c = expContract.Number_of_times_renewed__c + 1;
                        
                        expContract.Current_Cycle_Start_Date__c = opp.Start_Date__c;
		                expContract.Contract_Renewal_Cycle_in_months__c = Integer.valueOf(opp.Renewal_duration_in_months__c);
		                expContract.Current_Cycle_End_Date__c = opp.Current_Cycle_End_Date__c;
                        
                        expContract.Current_Opportunity__c = opp.Id;
                        expContract.Booking_value__c = opp.Amount;
                        expContract.Opportunity_OwnerEmail__c = email[0].Owner.Email; // Get the owner email from the current Opportunity
                        expContract.RCRM_Product_Manager_Email__c = emailManager[0].RCRM_Product_Manager__r.Email;
                        expContract.Alternate_RCRM_Product_Manager_Email__c = emailAltManager[0].Alternate_RCRM_Product_Manager__r.Email;
                        
                        lstContractsToUpdate.add(expContract);
                        
                    } else {
                        
                        // NEW TERMS => contract amended
                        
                        // if it's an early renewal, cancel the expiring contract; otherwise, mark the expiring contract as replaced
                        if (opp.Early_Renewal__c == true) {
                        	lstContractsToCancel.add(expContract);
                        } else {
                        	expContract.Renewal_Status__c = 'Replaced by a new contract';
                        	lstContractsToUpdate.add(expContract);	
                        }
                        
                        Contract newContract = new Contract();
                        newContract.RecordTypeId = RT_RCRM_Contract_Id;
                        newContract.Name = opp.Name.startsWith('Renewal - ') ? opp.Name.replaceFirst('Renewal - ','') : opp.Name;
                        newContract.Number_of_times_renewed__c = 0;
                        newContract.Replaces_contract__c = expContract.Id;
                        newContract.Renewal_Status__c = 'Replaces a previous contract';
                        newContract.AccountId = opp.AccountId;
                        newContract.Product_Family__c = opp.Product_Family__c;
                        newContract.RCRM_Product_Manager__c = opp.RCRM_Product_Manager__c;
                        
		                newContract.StartDate = opp.Start_Date__c;
		                newContract.Current_Cycle_Start_Date__c = opp.Start_Date__c;
		                newContract.Contract_Renewal_Cycle_in_months__c = Integer.valueOf(opp.Renewal_duration_in_months__c);
		                newContract.Current_Cycle_End_Date__c = opp.Current_Cycle_End_Date__c;
		                
                        newContract.ContractTerm = Integer.valueOf(opp.Renewal_duration_in_months__c); // required field; we do not use this for RCRM 
                        newContract.Renewal_under_Sales_Responsibility__c = opp.Renewal_under_Sales_Responsibility__c; 
                        newContract.Booking_value__c = opp.Amount;
                		newContract.CurrencyIsoCode = opp.CurrencyIsoCode;
                        newContract.Status = 'Draft';
                        newContract.Current_Opportunity__c = opp.Id;
                        newContract.Opportunity_OwnerEmail__c = email[0].Owner.Email; // Get the owner email from the current Opportunity
                        newContract.RCRM_Product_Manager_Email__c = emailManager[0].RCRM_Product_Manager__r.Email;
                        newContract.Alternate_RCRM_Product_Manager_Email__c = emailAltManager[0].Alternate_RCRM_Product_Manager__r.Email;
                                                
                        if (opp.Renewal_under_Sales_Responsibility__c) {
                            newContract.OwnerId = opp.OwnerId; // we suppose the SM owns the Opportunity, since it's their responsibility - no other way of getting info on the SM
                        } else {
                            newContract.OwnerId = opp.RCRM_Product_Manager__c;
                        }
                        
                        lstContractsToInsert.add(newContract);
                        
                    }
            }
        }
        
        
        update lstContractsToUpdate;
        
        // create the new contracts
        insert lstContractsToInsert;
        
        CancelContracts(lstContractsToCancel);
        
        // update the status to Activated
        for (Contract con : lstContractsToInsert) {
            con.Status = 'Activated';
        }
        // update to activate them
        update lstContractsToInsert;
        
        List<Contract> lstUpsertedContracts = new List<Contract>();
        lstUpsertedContracts.addAll(lstContractsToInsert);
        lstUpsertedContracts.addAll(lstContractsToUpdate);
        
        // Update the opportunities received as parameter with the IDs of the newly created contracts
        for (Contract con : lstUpsertedContracts) {
            Opportunity tmpOpp = mapOpportunitiesPerId.get(con.Current_Opportunity__c);
            if (tmpOpp != null) {
                tmpOpp.ContractId = con.Id;
                
                // If the opportunity renews the contract as-is, remove the contract from the Expiring Contract field and only keep it in the Contract field
                // This way we keep only the future renewal opp in the future renewal related list @ contract level, and all the historical in the opportunities list
                if (tmpOpp.Expiring_contract__c == con.Id) {
                    tmpOpp.Expiring_contract__c = null;
                }
            }
        }
        
        
        /////////////////
        // Update the Revenue Stream Lines from the closed opportunities and set their contract
        List<Revenue_Stream_Line__c> lstRSLsToUpdate = [SELECT Id, Opportunity__c, Contract__c FROM Revenue_Stream_Line__c WHERE Opportunity__c IN :mapOpportunitiesPerId.keyset()];
        for (Revenue_Stream_Line__c rsl : lstRSLsToUpdate) {
            rsl.Contract__c = mapOpportunitiesPerId.get(rsl.Opportunity__c).ContractId;
        }
        
        try {
        	update lstRSLsToUpdate;
        } catch (Exception e) {
        	system.debug('Error: ' + e.getMessage());
        }
        
    }
    
    
    /*
     *  Creates the future renewal opportunity, the RSLs attached to it and the reminder
     */
    public static void CreateFutureOpportunity (Map<Id,Opportunity> mapOpportunitiesPerId, Map<Id, List<OpportunityLineItem>> mapRcrmOLIPerOppId) {
        // Map of new Opportunities to insert per Id of the old opportunity
        Map<Id,Opportunity> mapNewOppPerOldOppId = new Map<Id,Opportunity>();
        
        Id RT_RCRM_Opportunity_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'RCRM_Opportunity');
        
        // List of the Tasks to be inserted
        List<Task> lstTasksToInsert = new List<Task>();
        
        // Create the new opportunities AND the tasks & reminders
        for (Opportunity opp : mapOpportunitiesPerId.values()) {
            Opportunity newOpp = new Opportunity();
            newOpp.Name = opp.Name.startsWith('Renewal - ') ? opp.Name : 'Renewal - ' + opp.Name;
            newOpp.CurrencyIsoCode = opp.CurrencyIsoCode;
            newOpp.AccountId = opp.AccountId;
            newOpp.RecordTypeId = RT_RCRM_Opportunity_Id;
        	newOpp.Start_Date__c = opp.Current_Cycle_End_Date__c.addDays(1);
        	newOpp.Current_Cycle_End_Date__c = newOpp.Start_Date__c.addMonths(Integer.valueOf(opp.Renewal_duration_in_months__c)).addDays(-1);
        	newOpp.Renewal_duration_in_months__c = opp.Renewal_duration_in_months__c;
        	//newOpp.CloseDate = opp.CloseDate.addMonths(Integer.valueOf(opp.Renewal_duration_in_months__c));
        	newOpp.CloseDate = opp.Current_Cycle_End_Date__c;
            newOpp.Renewal_under_Sales_Responsibility__c = opp.Renewal_under_Sales_Responsibility__c; 
            newOpp.Amount = opp.Amount;
            newOpp.Product_Family__c = opp.Product_Family__c;
            newOpp.StageName = 'Future renewal';
            //newOpp.Type = 'Estimated revenue';
            newOpp.Expiring_contract__c = opp.ContractId;
            newOpp.Sales_Team__c = opp.Sales_Team__c;
                        
            // Get the reminder interval as the highest reminder interval amongst the products on the opportunity
            Integer reminderInterval = 0; 
            
            if (mapRcrmOLIPerOppId.get(opp.Id) != null) {
	            for (OpportunityLineItem oli : mapRcrmOLIPerOppId.get(opp.Id)) {
	                if (oli.Product2.Reminder_interval__c != null && oli.Product2.Reminder_interval__c > reminderInterval) { 
	                    reminderInterval = integer.valueOf(oli.Product2.Reminder_interval__c);
	                }
	            }
            }
            // set the reminder date on the opportunity
            newOpp.Reminder_date__c = opp.Current_Cycle_End_Date__c.addMonths(-reminderInterval);
            
            // Create the task
            Task newTask = new Task();
            newTask.Description = 'Renewal of the contract';
            newTask.ActivityDate = opp.Current_Cycle_End_Date__c.addMonths(-reminderInterval);
            newTask.ReminderDateTime = opp.Current_Cycle_End_Date__c.addMonths(-reminderInterval);
            newTask.Status = 'Not Started';
            newTask.Subject = 'RCRM Contract Renewal - ' + ( opp.Name.startsWith('Renewal - ') ? opp.Name.replaceFirst('Renewal - ','') : opp.Name );
            newTask.WhatId = opp.ContractId;
            newTask.IsReminderSet = true;
            newTask.ReminderDateTime = opp.Current_Cycle_End_Date__c.addMonths(-reminderInterval);
            
            // Set the opportunity & task owner
            if (opp.Renewal_under_Sales_Responsibility__c && opp.RCRM_Product_Manager__c != null) {
                newOpp.OwnerId = opp.OwnerId;
                newTask.OwnerId = opp.OwnerId;
            } else {
                newOpp.OwnerId = opp.RCRM_Product_Manager__c;
                newTask.OwnerId = opp.RCRM_Product_Manager__c;
            }
            
            mapNewOppPerOldOppId.put(opp.Id, newOpp);
            lstTasksToInsert.add(newTask);
        }
        
        // Insert the new Opportunities
        insert mapNewOppPerOldOppId.values();
        insert lstTasksToInsert;
        
        // Create the OpportunityLineItems for the RCRM products
        List<OpportunityLineItem> lstNewOLIsToInsert = new List<OpportunityLineItem>();
        for (Id oldOppId : mapOpportunitiesPerId.keyset()) {
            // The OLIs from the old opportunity
            List<OpportunityLineItem> lstOldOLIs = mapRcrmOLIPerOppId.get(oldOppId);
            
            // The new OLIs for the future opportunity
            for (OpportunityLineItem oldOLI : lstOldOLIs) {
                OpportunityLineItem newOLI = new OpportunityLineItem();
                newOLI.OpportunityId = mapNewOppPerOldOppId.get(oldOppId).Id;
                newOLI.Quantity = oldOLI.Quantity;
                //newOLI.CurrencyIsoCode = oldOLI.CurrencyIsoCode;
                newOLI.PricebookEntryId = oldOLI.PricebookEntryId;
                newOLI.UnitPrice = oldOLI.UnitPrice;
                
                lstNewOLIsToInsert.add(newOLI);
            }
        }
        
        insert lstNewOLIsToInsert;
        
                
        //////////////////////
        // Create Revenue Stream Lines 
        
        // Create a map of the newly inserted future renewal opportunities per Id
        map<Id,Opportunity> mapOpportunitiesToGetRSLsPerId = new map<Id,Opportunity>();
        for (Opportunity opp : mapNewOppPerOldOppId.values()) {
            mapOpportunitiesToGetRSLsPerId.put(opp.Id, opp);
        }
        
        if (! mapOpportunitiesToGetRSLsPerId.values().isEmpty()) {
            // List of the OpportunityLineItems related to these future opportunities
            List<OpportunityLineItem> lstNewOLIs = [SELECT Id, OpportunityId, Product2Id, Product2.Product_Manager_lookup__c, CurrencyIsoCode, PricebookEntryId,
                                        UnitPrice, Quantity FROM OpportunityLineItem WHERE OpportunityId IN :mapOpportunitiesToGetRSLsPerId.keyset()];
                        
            Map<Id, List<OpportunityLineItem>> mapFutureRcrmOLIPerOppId = new Map<Id, List<OpportunityLineItem>>();
            
            for (OpportunityLineItem oli : lstNewOLIs) {
                if (mapFutureRcrmOLIPerOppId.get(oli.OpportunityId) == null) {
                    mapFutureRcrmOLIPerOppId.put(oli.OpportunityId, new List<OpportunityLineItem>());
                }
                
                mapFutureRcrmOLIPerOppId.get(oli.OpportunityId).add(oli);               
            }
            
            // Create Revenue Stream Lines for the future renewal Opportunities
            RCRMUtil.GenerateRevenueStreamLines(mapOpportunitiesToGetRSLsPerId, mapFutureRcrmOLIPerOppId);
        }
        //////////////////////
        
    }
    
    
    
    /*
     * Generates the Revenue Stream Lines for each of the oppportunities transmitted in the lstOpportunities parameter
     */
    public static void GenerateRevenueStreamLines(Map<Id,Opportunity> mapOpportunitiesPerId, Map<Id, List<OpportunityLineItem>> mapRcrmOLIPerOppId){
        List<Revenue_Stream_Line__c> lstRSLToInsert = new List<Revenue_Stream_Line__c>();
        
        for (Opportunity opp : mapOpportunitiesPerId.values()) {
            // Get the full length of the contract, in days
            
            Integer StartYear = opp.Start_Date__c.year(); 
            Integer EndYear = opp.StageName != 'Future renewal' ? opp.Current_Cycle_End_Date__c.year() : ( opp.Start_Date__c.isSameDay(date.newInstance(StartYear, 1, 1)) ? StartYear + 2 : StartYear + 3);
            
            // Validate that there are RCRM products attached to the opp
            if (mapRcrmOLIPerOppId.get(opp.Id) == null || mapRcrmOLIPerOppId.get(opp.Id).isEmpty()) {
            	opp.addError('This opportunity has no RCRM products attached. You need to add the RCRM products before passing to the "Contract Stage".');
            } else {
	            // Create the RSLs for each product in particular
	            for (OpportunityLineItem oli : mapRcrmOLIPerOppId.get(opp.Id)) {
	                
	                Double RSLTotal = 0;
	                //Double YearlyAmount = Double.valueOf(oli.UnitPrice) * Double.valueOf(oli.Quantity) / Double.valueOf(opp.Duration_years__c);
	                Double YearlyAmount = Double.valueOf ( Double.valueOf(oli.UnitPrice) * Double.valueOf(oli.Quantity) / ( Double.valueOf(opp.Start_Date__c.daysBetween(opp.Current_Cycle_End_Date__c)) / 365 ) ).round();
	                
	                // calculate the annualized values proportionally to the period of time out of the total amount
	                for (Integer i = StartYear; i <= EndYear; i++) {
	                    
	                    Revenue_Stream_Line__c rsl = new Revenue_Stream_Line__c();
	                    rsl.Opportunity__c = opp.Id;
	                    rsl.CurrencyIsoCode = opp.CurrencyIsoCode;
	                    rsl.Contract__c = opp.Revenue_Type__c == 'Booked' ? opp.ContractId : opp.Expiring_contract__c;
	                    rsl.Customer__c = opp.AccountId;
	                    
	                    rsl.Product__c = oli.Product2Id;
	                    
	                    if (i == StartYear) {
	                        // first interval might not be the full year
	                        rsl.Start_Date__c = opp.Start_Date__c;
	                        rsl.End_Date__c = date.newInstance(i, 12, 31);
	                        rsl.Annualized_value__c = double.valueOf(Double.valueOf (rsl.Start_Date__c.daysBetween(rsl.End_Date__c)) / 365 * YearlyAmount).round();
	                        RSLTotal += rsl.Annualized_value__c;
	                        
	                    } else if (i == EndYear) {
	                        // last interval might not be the full year
	                        rsl.Start_Date__c = date.newInstance(i, 1, 1);
	                        
	                        //rsl.Annualized_value__c = Double.valueOf (365) / Double.valueOf (ContractLengthInDays) * Double.valueOf (opp.Amount);
	                        if (opp.StageName != 'Future renewal') {
	                            rsl.End_Date__c = opp.Current_Cycle_End_Date__c;
	                            // Put the difference left up to the total opportunity amount, to insure the annualized values of the RSLs add up to the opportunity amount
	                            rsl.Annualized_value__c = Double.valueOf(oli.UnitPrice) * Double.valueOf(oli.Quantity) - RSLTotal;
	                        } else {
	                            rsl.End_Date__c = opp.Start_Date__c.addYears(3).addDays(-1);
	                            // if future renewal opportunity, put in the proportional value 
	                            rsl.Annualized_value__c = Double.valueOf ( Double.valueOf (rsl.Start_Date__c.daysBetween(opp.Start_Date__c.addYears(3).addDays(-1))) / 365 * YearlyAmount ).round();
	                        }
	                        
	                    } else {
	                        // middle intervals are always full years
	                        rsl.Start_Date__c = date.newInstance(i, 1, 1);
	                        rsl.End_Date__c = date.newInstance(i, 12, 31);
	                        rsl.Annualized_value__c = YearlyAmount;
	                        RSLTotal += rsl.Annualized_value__c;
	                    }
	                    
	                    lstRSLToInsert.add(rsl);
	                    
	                } // for (Integer i = StartYear; i <= EndYear; i++)
	                
	            } // for (OpportunityLineItem oli : mapRcrmOLIPerOppId.get(opp.Id))
            } // validation that there are RCRM products attached to the opp
        }
        
        insert lstRSLToInsert;
    }
    
    
    /*
     *  Deletes the Revenue Stream Lines linked to the opportunities received as parameter
     */
    public static void DeleteRevenueStreamLines (Map<Id,Opportunity> mapOpportunitiesPerId) {
        List<Revenue_Stream_Line__c> lstRSLToDelete = [SELECT Id FROM Revenue_Stream_Line__c WHERE Opportunity__c IN :mapOpportunitiesPerId.keyset()];
        
        delete lstRSLToDelete;
    }
    
    
    /*
     * Compares two lists of OLIs and returns true if they contain the same Product Ids
     * Doesn't compare anything else (prices, quantities etc.), just the IDs
     */
    private static Boolean OLIsContainTheSameProducts (List<OpportunityLineItem> OldList, List<OpportunityLineItem> NewList) {
        Set<Id> setNew = new Set<Id>();
        Set<Id> setOld = new Set<Id>();
        
        Double oldAmount = 0;
        Double newAmount = 0;
        
        for (OpportunityLineItem oli: OldList) {
            setOld.add(oli.Product2Id);
            oldAmount += oli.Quantity * oli.UnitPrice;
        }
        
        for (OpportunityLineItem oli: NewList) {
            setNew.add(oli.Product2Id);
            newAmount += oli.Quantity * oli.UnitPrice;
        }
        
        return setOld.containsAll(setNew) && setNew.containsAll(setOld) && oldAmount == newAmount;
     }
     
     
    /*
     * Cancels a contract by deleting its future booked revenue lines
     */
    public static void CancelContracts (List<Contract> lstContracts) {
    	// set of contract ids
    	Set<Id> setContractIds = new Set<Id>();
    	for (Contract con : lstContracts) {
    		setContractIds.add(con.Id);
    		con.Renewal_Status__c = 'Canceled';
    	}
    	
    	// get the booked RSLs for the next years and remove them
    	Date lastDayOfCurrentYear = date.newInstance(date.today().year(), 12, 31);
    	List<Revenue_Stream_Line__c> lstRSLToDelete = [SELECT Id FROM Revenue_Stream_Line__c WHERE Contract__c IN :setContractIds AND Start_Date__c > :lastDayOfCurrentYear AND Revenue_Type__c = 'Booked'];
        
        delete lstRSLToDelete;
        
        update lstContracts;
    }
}