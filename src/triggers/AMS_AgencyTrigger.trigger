trigger AMS_AgencyTrigger on AMS_Agency__c (before insert, before update, after update) {
    
//    Map<string,Id> agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');
    
//    list<AMS_Agency__c> bindToAccount = new list<AMS_Agency__c>();
//    list<AMS_Agency__c> checkAccounts = new list<AMS_Agency__c>();
//    list<AMS_Agency__c> fillAgencyCodes = new list<AMS_Agency__c>();
//    list<AMS_Agency__c> assignRTAgency = new list<AMS_Agency__c>();
//    List<AMS_Agency__c> iataCodeUpdateAgencies = new List<AMS_Agency__c >();
    
   
//    if(Trigger.isInsert){
//        for(AMS_Agency__c ag : trigger.new){
//			//make sure agency Codes are filled in first
//			//LM: 01/10/2015
//            //if(ag.IATACode__c != null && (ag.C_Code__c == null || ag.C_Code__c == '' || ag.A_Code__c==null || ag.N_Code__c==null))
//            if(AMS_AgencyHelper.isMissingCodes(ag))
//                if(ag.IATACode__c.length() >= 7 )
//                    AMS_AgencyHelper.fillAgencyCodes(ag);
//                else
//                    ag.addError('Invalid Agency IATA Code.');
            
//            /*if(fillAgencyCodes.size() > 0)
//        		AMS_AgencyHelper.fillAgencyCodes(fillAgencyCodes);*/
			
//            String newIATACode = AMS_AgencyHelper.genIATACodeFromCodes(ag);
            
//            if(ag.Account__c==null && newIATACode!='')
//                bindToAccount.add(ag);
//            else if(newIATACode!='')
//                checkAccounts.add(ag);
            
//            //create checkdigit
//            if(newIATACode!='' && ag.Chk_Dgt__c == null){
//                ag.IATACode__c = newIATACode;
//                iataCodeUpdateAgencies.add(ag);
//            }

//            //RP: 01/12/2015 assign recordtype on insert
//            if(ag.RecordTypeId == null)
//                assignRTAgency.add(ag);
//        }
//    }
    
//    if(assignRTAgency.size()>0)
//        AMS_AgencyHelper.assignRT(assignRTAgency);
//    //if(iataCodeUpdateAgencies.size()>0) #AMSFTS
//    //AMS_AgencyHelper.checkDigitCreation(iataCodeUpdateAgencies); #AMSFTS
//    	   //AmsIataCodeGenerator.checkDigitCreation(iataCodeUpdateAgencies);
//    if(bindToAccount.size()>0)
//           AMS_AgencyHelper.addAccountIfEmpty(bindToAccount);    
//    if(checkAccounts.size()>0)
//           AMS_AgencyHelper.Ensure0to1AccountLookup(checkAccounts);

//    if(Trigger.isUpdate){
//        if(Trigger.isBefore){
//            for(AMS_Agency__c ag: Trigger.new){
            
//                //Check if iata code changed
//                String newIATACode = AMS_AgencyHelper.genIATACodeFromCodes(ag);
//                String oldIATACode = AMS_AgencyHelper.genIATACodeFromCodes(trigger.oldMap.get(ag.Id));

//                String newCassN  = AMS_AgencyHelper.getFormattedCassNumber(ag);
//                String oldCassN  = AMS_AgencyHelper.getFormattedCassNumber(trigger.oldMap.get(ag.Id));

//                //DO not allow updates on existing iata codes directly
//                /*if(ag.IATACode__c!=null &&  trigger.oldMap.get(ag.Id).IATACode__c!=null && trigger.oldMap.get(ag.Id).IATACode__c != ag.IATACode__c){
//                    //we cannot change a IATA Code
//                    ag.addError('It is impossible to change an existing IATA code. You can only Delete it.');
//                }
//                else*/ if(ag.IATACode__c!=null &&  trigger.oldMap.get(ag.Id).IATACode__c==null && ag.Chk_Dgt__c == null){
//                    // we just have change the CASS Number
//                    if(ag.RecordTypeId ==agenciesRT.get('CARGO') && (ag.CASS_Number__c==null || ag.CASS_Number__c.length()>3 )){
//                         ag.addError('You cannot assign a IATA Code to a Cargo Agency without having a (max) 3 Digits Cass Number assigned');
//                    }
//                }

//                //Existing Iata Code updated through codes
//                if((oldIATACode!='' && newIATACode != oldIATACode) || (newCassN != oldCassN)){
//                    ag.IATACode__c = newIATACode;
//                    iataCodeUpdateAgencies.add(ag);
//                }

                
//                /*if(oldIATACode!='' && newIATACode != oldIATACode){
//                    //we cannot change a IATA Code
//                    ag.addError('It is impossible to change an existing IATA code. You can only Delete it.');
//                }else if(newIATACode!='' && oldIATACode == '' && ag.Chk_Dgt__c == null){
//                    // we just have change the CASS Number
//                    if(ag.RecordTypeId ==agenciesRT.get('CARGO') && (ag.CASS_Number__c==null || ag.CASS_Number__c.length()>3 )){
//                        ag.addError('You cannot assign a IATA Code to a Cargo Agency without having a (max) 3 Digits Cass Number assigned');
//                    }else {
//                        iataCodeUpdateAgencies.add(ag);
//                    }
//                }
                
//                if(iataCodeUpdateAgencies.size()>0)
//                    AmsIataCodeGenerator.checkDigitCreation(iataCodeUpdateAgencies);*/
//            }

//            //if(iataCodeUpdateAgencies.size()>0) #AMSFTS
//            //AMS_AgencyHelper.checkDigitCreation(iataCodeUpdateAgencies); #AMSFTS
//                //AmsIataCodeGenerator.checkDigitCreation(iataCodeUpdateAgencies);
//        }
//        if(Trigger.isAfter){
//            AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);

//            Set<String> accountIds = new Set<String>();
//            for(AMS_Agency__c ag: Trigger.new){
//                accountIds.add(ag.Account__c);
//            }
//            //AMS_AgencyHelper.updateAccounts(Trigger.oldMap, Trigger.newMap, accountIds); #AMSFTS
//        }
//    }
        
        
//    //Operations assignment update:
//    //we want to set all operation to a dedicated Operation based on their Countries
//    List<AMS_Agency__c > operationHelpercandidate = new List<AMS_Agency__c >();
//    /*
//        //cannot be working on creation because need to have a primary address linled
//    */
//    if(Trigger.isUpdate && Trigger.isAfter)
//        for(AMS_Agency__c  ag:Trigger.new){
//            if(ag.Country__c!=null && ag.IATACode__c !=null ){
//                system.debug('[AMS_AgencyTrigger] updated Primary Address for Agency '+ag.Id);
//                operationHelpercandidate.add(ag);
//            }
//        }
//    /*TO REVIEW ASK JEREMY
//     * else if(Trigger.isUpdate){
//        for(AMS_Agency__c  ag:Trigger.new){
//            //consider agency with iata code with NEW primary Address  OR agencies with Address with new iata code
//            if((ag.Country__c!=trigger.oldMap.get(ag.Id).Country__c && ag.IATACode__c!=null) || (ag.Country__c!=null && ag.IATACode__c!=null && trigger.oldMap.get(ag.Id).IATACode__c==null)){
//                system.debug('[AMS_AgencyTrigger] updated Primary Address for Agency '+ag.Id);
//                operationHelpercandidate.add(ag);
//            }
//        }
//    }*/
//    if(operationHelpercandidate.size()>0){
//        system.debug('[AMS_AgencyTrigger] updating Operation for '+operationHelpercandidate.size()+' Agencies');
//        //AMS_AgencyHelper.updateAgenciesOperations(operationHelpercandidate); #AMSFTS
//    }
//    //DevsTools.sendSFDevsAlertMessage('[AgencyTrigger] Update Agencies operation for '+operationHelpercandidate.size(),'based on '+Trigger.new.size());       
}