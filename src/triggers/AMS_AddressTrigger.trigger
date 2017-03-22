/**************************************************************************************************
 *  This trigger is in charge of setting the country state, according to the primary address one  *
 **************************************************************************************************/

trigger AMS_AddressTrigger on AMS_Address__c (after insert,   after update, after delete) {

  if(!AMS_TriggerExecutionManager.checkExecution(AMS_Address__c.getSObjectType(), 'AMS_AddressTrigger')) { return; }

  //Clear the Account Address If the AMS_Address is deleted 
  if(Trigger.isAfter && Trigger.isDelete) ams2gdp_TriggerHelper.clearAccountAddresses(Trigger.old);

  if(Trigger.isAfter && Trigger.isUpdate) ams2gdp_TriggerHelper.updateAccountAddresses(Trigger.oldMap, Trigger.newMap);

  if(Trigger.isAfter && Trigger.isInsert) ams2gdp_TriggerHelper.updateAccountAddresses(null, Trigger.newMap);
         
    /*
    Map<String,AMS_Address__c > addressMapPerAgency = new Map<String,AMS_Address__c > ();
    if(trigger.isInsert || Trigger.isUpdate){
        for(AMS_Address__c add:trigger.new)
            if(add.State__c!=null  && (addressMapPerAgency .get(add.agency__c)==null || add.Address_Type__c.contains('Primary'))){
                addressMapPerAgency .put(add.agency__c,add);
            }

    }
    if(addressMapPerAgency.size()>0){
        List<Ams_agency__c > toUpdateAgts = new List<Ams_agency__c >();
        List<Ams_agency__c > agts = [select Id, Iso_State__c from Ams_agency__c where Iso_State__c= null and Id in:addressMapPerAgency.keySet()];
        for(Ams_agency__c  agt:agts ){
            agt.Iso_State__c  = addressMapPerAgency .get(agt.Id).State__c;
            toUpdateAgts .add(agt);
        }
        update toUpdateAgts ;
    }

   
    // Here we should ahve the code to replicate Account  billing / shippi ng addresses
    List<AMS_Address__c> addToBeReportedMS = new List<AMS_Address__c>();
    for(AMS_Address__c add : Trigger.new){
        if(add.Address_Type__c.contains('Primary')  ||add.Address_Type__c.contains('Billing') || add.Address_Type__c.contains('Shipping') ){//else
            addToBeReportedMS.add(add);
        }
    }
    if(addToBeReportedMS.size()>0)
            AMS_AddressHelper.setBillingShippingAddressesOnAccount(addToBeReportedMS);

    
 }
 
 
 
 
 
 
 
 

 
             ================================================================================================
                                                PREVIOUS VERSION OF PRIMARY MNGT
                                                   MODE TO DEDICATED TRIGGER
             ================================================================================================ 
 
 
    List<AMS_Address__c> addToBeChecked = new List<AMS_Address__c>();
    List<AMS_Address__c> addPrimary = new List<AMS_Address__c>();
    List<AMS_Address__c> addToBeReported = new List<AMS_Address__c>();
    List<AMS_Address__c> addToBeReportedMS = new List<AMS_Address__c>();
    List<AMS_Address__c> addToBeReportedOldPrimary = new List<AMS_Address__c>();

    Map<Id,AMS_Address__c> ag_AddressPrimary = new Map<Id,AMS_Address__c>();

    List<Id> addToBeDeleted = new List<Id>();
    SET<Id> setAddressKeys = new SET<Id>();
    SET<Id> setAgencyKeys = new SET<Id>();
    
    if(Trigger.isInsert || Trigger.isUpdate){
      for(AMS_Address__c add : Trigger.new){
        setAddressKeys.add(add.Id);
        setAgencyKeys.add(add.Agency__c);
      }

      //get all addresses belonging to the address bieng inserted/updated by the trigger
      addToBeChecked = [Select Id, Agency__c, Address_Type__c from AMS_Address__c where Agency__c in :setAgencyKeys and Id not in :setAddressKeys];

      //Populates the list with the primary address of each agency pickup by the trigger
      for(AMS_Address__c add : addToBeChecked){
        if(add.Address_Type__c.contains('Primary')){
          addPrimary.add(add);
          ag_AddressPrimary.put(add.Agency__c, add);
        }
      }
    }

    

    if(Trigger.isInsert || Trigger.isUndelete){
        for(AMS_Address__c add : Trigger.new){

          AMS_Address__c oldPrimaryAddress = ag_AddressPrimary.get(add.Agency__c);

            if(add.Address_Type__c.contains('Primary') || add.Address_Type__c.contains('Billing')){//adding Billing for primary address because of AMS-485
                addToBeReported.add(add);
          }
            if(add.Address_Type__c.contains('Billing') || add.Address_Type__c.contains('Shipping') ){//else
            addToBeReportedMS.add(add);
          }

          //Checks if a primary address already existed for the agency, if so it marks it to be modified
          if(oldPrimaryAddress != null && add.Address_Type__c.contains('Primary') ){
            addToBeReportedOldPrimary.add(oldPrimaryAddress);
          }

        }
    }else if(Trigger.isUpdate){
        for(AMS_Address__c add : Trigger.new){
            AMS_Address__c oadd = Trigger.oldMap.get(add.id);

            AMS_Address__c oldPrimaryAddress = ag_AddressPrimary.get(add.Agency__c);

            System.debug('------ oadd.Address_Type__c: ' + oadd.Address_Type__c);
            System.debug('------ add.Address_Type__c: ' + add.Address_Type__c);
          
            //if(oadd.Address_Type__c.contains('Primary') && !add.Address_Type__c.contains('Primary') && !add.Address_Type__c.contains('Old') ){
            //  add.Address_Type__c.addError('Cannot change from Primary Address! In order to Change set another address as Primary!');
            //}else 
            //
            if(add.Address_Type__c == Null){
              add.Address_Type__c.addError('Must have a value!');
            }else if(!oadd.Address_Type__c.contains('Primary') && add.Address_Type__c.contains('Primary') ){
                addToBeReported.add(add);        
            }else     
            if (add.Address_Type__c.contains('Primary') && (oadd.Address_1__c!=add.Address_1__c ||
                                                   oadd.Address_2__c!=add.Address_2__c ||
                                                   oadd.Address_3__c!=add.Address_3__c ||
                                                   oadd.State__c!=add.State__c ||
                                                   oadd.Country__c!=add.Country__c ||
                                                   oadd.AMS_ZipCode__c!=add.AMS_ZipCode__c ||
                                                   oadd.City__c!=add.City__c)
               )
              addToBeReported.add(add);
            
          //else if(oadd.Address_Type__c.contains('Primary') && !add.Address_Type__c.contains('Primary') )
          //       addToBeDeleted.add(add.Agency__c);

            //Checks if a primary address already existed for the agency, if so it marks it to be modified
          System.debug('------ oldPrimaryAddress: ' + oldPrimaryAddress);
          System.debug('------ oadd.Address_Type__c: ' + oadd.Address_Type__c);
            
          if(oldPrimaryAddress != null && oadd.Address_Type__c!='Primary' && add.Address_Type__c.contains('Primary') ){
            System.debug('------ oldPrimaryAddress: ' + oldPrimaryAddress);
            addToBeReportedOldPrimary.add(oldPrimaryAddress);
          }     
        }
        //FM - 22-09-2016 - stop creating "agency update" Records
        //if(Trigger.isAfter )
        //    AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);
        
        
        
    }else if(Trigger.isDelete){

        for(AMS_Address__c add : Trigger.old){
          setAgencyKeys.add(add.Agency__c);
        }
        

        //get all addresses belonging to the address bieng inserted/updated by the trigger
        addToBeChecked = [Select Id, Agency__c, Agency__r.Primary_address__c, Address_Type__c from AMS_Address__c where Agency__c in :setAgencyKeys and Agency__r.Primary_address__c <> Null];

        Map<Id, AMS_Address__c> mAddToBeChecked = new Map<Id, AMS_Address__c>();
        for(AMS_Address__c addAux : addToBeChecked){
          if(addAux.Agency__r.Primary_address__c == addAux.Id){
            mAddToBeChecked.put(addAux.Id, addAux);
          }
        } 
       
        for(AMS_Address__c add : Trigger.old){
            if(add.Address_Type__c.contains('Primary') || mAddToBeChecked.containsKey(add.Id)){
                //addToBeDeleted.add(add.Agency__c);
            add.Agency__c.addError('Cannot delete Primary Address! In order to Delete set another address as Primary!');
          }
        }
    }
    
    //System.debug('------ addToBeDeleted: ' + addToBeDeleted.size());
    //System.debug('------ addToBeDeleted: ' + addToBeDeleted);
    //if(addToBeDeleted.size()>0)
    //    AMS_AddressHelper.deletePrimaryAddressesOnAgencies(addToBeDeleted);
        System.debug('------ addToBeReported: ' + addToBeReported.size());
        System.debug('------ addToBeReported: ' + addToBeReported);
        if(addToBeReported.size()>0)
            AMS_AddressHelper.setPrimaryAddressesOnAgencies(addToBeReported);
        
        if(addToBeReportedMS.size()>0)
            AMS_AddressHelper.setBillingShippingAddressesOnAccount(addToBeReportedMS);
    
        //System.debug('------ addToBeReportedOldPrimary: ' + addToBeReportedOldPrimary.size());
        if(addToBeReportedOldPrimary.size()>0)
            AMS_AddressHelper.UpdatePrimaryAddresses(addToBeReportedOldPrimary);    
        
        //Validate missing primary address
        addToBeChecked = [Select Id, Agency__c, Address_Type__c from AMS_Address__c where Agency__c in :setAgencyKeys order by Agency__c];
        
        Id currentId = Null;
        Boolean bChangedAg = False;
        Boolean bPrimary = False;
        Integer countAg = 1;
        AMS_Address__c auxAdd;
        
        System.debug('------ addToBeChecked END: ' + addToBeChecked);
    
        //Populates the list with the primary address of each agency pickup by the trigger
        for(AMS_Address__c add : addToBeChecked){
            if(currentId == Null){
                currentId = add.Agency__c;
            }else if(currentId != add.Agency__c){
                countAg++;
                bChangedAg = True;
                
                if(!bPrimary){
                    add.Address_Type__c.addError('Cannot change from Primary Address! In order to Change set another address as Primary!');
                }
                bPrimary = False;
            }
                
            if(add.Address_Type__c != Null && add.Address_Type__c.contains('Primary')){
                bPrimary = True;
            }
        }
        
        //in case there's only 1 agency being tested
        if(countAg == 1){
            if(!bPrimary){
                for(AMS_Address__c add : Trigger.new){
                    add.Address_Type__c.addError('Cannot change from Primary Address! In order to Change set another address as Primary!');
                }
                
            }
        }
        */
        }