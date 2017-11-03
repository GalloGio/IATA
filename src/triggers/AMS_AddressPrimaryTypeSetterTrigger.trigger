/**
This trigger is used to set / unset the Primary tag on addresses and agencies

Only thing: by deleting all address we won t have primary any more... but .. ok

*/
trigger AMS_AddressPrimaryTypeSetterTrigger on AMS_Address__c (before insert, before update, after insert, after update, after delete) {
    
    if(!AMS_TriggerExecutionManager.checkExecution(AMS_Address__c.getSObjectType(), 'AMS_AddressPrimaryTypeSetterTrigger')) { return; }
    

    if(trigger.isBefore){
        if(trigger.isUpdate)
            AMS_AddressTriggerHandler.handleBeforeUpdate(trigger.new);
        if(trigger.isInsert)
            AMS_AddressTriggerHandler.handleBeforeInsert(trigger.new);
    }


    Map<String,AMS_Address__c> addressMapPerAgency = new Map<String,AMS_Address__c > ();
    //list of Agency id 
    Set<Id> l = new Set<Id>();
    //before insert/update: set the Primary tag on address if needed
    if(trigger.isBefore && !Trigger.isDelete){
        for(AMS_Address__c add:trigger.new){
            if(add.Address_Type__c!=null  && !add.Address_Type__c.contains('Primary') && addressMapPerAgency.get(add.account__c)==null){
                addressMapPerAgency .put(add.account__c,add);
                l.add(add.account__c);
                system.debug('[AMS_AddressPrimaryTypeSetterTrigger] add one agency to process '+add.account__c);
            }
        }
        if(addressMapPerAgency.size()>0 ){
            //look for agencies without a primary address: we set the new one to  primary
            if(addressMapPerAgency.size()==1)
            system.debug('[AMS_AddressPrimaryTypeSetterTrigger] select Id ,Primary_address__c  from Account where  Id not  in (select account__c from AMS_Address__c where Address_Type__c includes (Primary) and account__c =XX  ) and Id = XX');
            
            if(Trigger.isUpdate){
                List<Account> agts = [select Id ,Primary_address__c  from Account where  Id  not in (select Account__c from AMS_Address__c where Address_Type__c includes ('Primary') and Account__c in :l and id not in :Trigger.newMap.keySet())  and Id in :l];
                system.debug('[AMS_AddressPrimaryTypeSetterTrigger before update] found '+agts.size()+' agencies without primary address in updated address related agts');
                if(agts.size() > 0){
                    for(AMS_Address__c add:trigger.new){
                        add.Address_Type__c.addError('You cannot remove Primary address. In order to remove from this address please add primary to another address.');
                    }
                }
            }else if(Trigger.isInsert){
                List<Account> agts = [select Id ,Primary_address__c  from Account where  Id  not in (select Account__c from AMS_Address__c where Address_Type__c includes ('Primary') and Account__c in :l)  and Id in :l];
                system.debug('[AMS_AddressPrimaryTypeSetterTrigger before insert] found '+agts.size()+' agencies without primary address in updated address related agts');
                for(Account  agt:agts ){
                    addressMapPerAgency.get(agt.Id).Address_Type__c = addressMapPerAgency.get(agt.Id).Address_Type__c+';Primary';
                    system.debug('[AMS_AddressPrimaryTypeSetterTrigger] Find one add to update to Primary');
                }
            }
       }



       // you cannot change Account Id field on Address before you mark that address as NOT PRIMARY
        if(trigger.isUpdate){
        
            for(AMS_Address__c add:trigger.new){

                if(trigger.oldMap.get(add.Id).Account__c != null && trigger.oldMap.get(add.Id).Account__c != add.Account__c && trigger.oldMap.get(add.Id).Address_Type__c.contains('Primary'))
                    add.Account__c.addError('You cannot update the Account Id in a Primary Type Address - Please update the type before updating the Account Id');

            }
        }


    }
    //after Insert/Update: update the agency Primnary lookup [need to have Address Id to do it]
    else if(trigger.isAfter && !Trigger.isDelete){

        //FM 14-10-2015 - INC:10933 
        Map<String,AMS_Address__c > addressMapPerAgencyForAccUpd = new Map<String,AMS_Address__c > ();
        List<AMS_Address__c> addToBeReportedForAccountUpdate = new List<AMS_Address__c>(); 

        for(AMS_Address__c add:trigger.new){
            if(add.Address_Type__c != null && add.Address_Type__c.contains('Primary')){
                system.debug('[AMS_AddressPrimaryTypeSetterTrigger] find one address which is new Primary after update '+add.Id);
                addressMapPerAgency.put(add.account__c,add);
                l.add(add.account__c);
            }
            //FM 14-10-2015 - INC:10933 
            if(add.Address_Type__c != null && (add.Address_Type__c.contains('Primary') || add.Address_Type__c.contains('Billing')  || add.Address_Type__c.contains('Shipping'))){
                addressMapPerAgencyForAccUpd.put(add.account__c,add);
            }
        }
        if(addressMapPerAgency.size()>0 ){
            
            List<Account> agts = [select Id ,Primary_address__c,Phone_Number__c,Phone_Number_Int__c,Phone_Number_STD__c, Website, Email__c, Phone, Fax from Account where Id in :l];

            for(Account  agt:agts ){
                system.debug('[AMS_AddressPrimaryTypeSetterTrigger] one agency to update : '+agt.Id);
                agt.Primary_address__c = addressMapPerAgency.get(agt.Id).Id;
                if(addressMapPerAgency.get(agt.Id).State__c != null)
                    agt.Iso_State__c = addressMapPerAgency.get(agt.Id).State__c;
                //here we update agency & the account according to address.
                //if phone number is null we update it
                if(agt.Phone_Number_STD__c==null)
                    agt.Phone_Number_STD__c = addressMapPerAgency.get(agt.Id).Telephone_STD__c ;
                if(agt.Phone_Number_Int__c==null)
                    agt.Phone_Number_Int__c = addressMapPerAgency.get(agt.Id).Telephone_Int__c ;
                if(agt.Phone_Number__c==null)
                    agt.Phone_Number__c = addressMapPerAgency.get(agt.Id).Telephone__c ;
                
            }
            //save external records [not addresses]
            if(agts.size() > 0)
                update agts ;

            //should replace other Address to something else than Primary
            List<AMS_Address__c > otherAddresses = [select Id,Address_Type__c from AMS_Address__c  where Account__c in :l and Id not in :Trigger.newMap.keySet() and  Address_Type__c includes ('Primary') ];
            for(AMS_Address__c  a:otherAddresses){
                a.Address_Type__c  = a.Address_Type__c.replace('Primary','');
            }
            if(otherAddresses.size() > 0)
                update otherAddresses;
        }

        
        //FM 14-10-2015 - INC:10933 
        //Check if Primary and Billing exist in order to update account billing address
        if(addressMapPerAgencyForAccUpd.size()>0){

            List<AMS_Address__c> addresses = [select Id, Address_Type__c, Account__c,Address_1__c,Address_2__c,Address_3__c,City__c,
                                                Country__r.ISO_code__c,State__r.Name,AMS_ZipCode__c, TTY__c, Website__c, Email__c, Telephone_Int__c, Telephone_STD__c, Telephone__c, Fax_Int__c, Fax_STD__c, Fax__c 
                                                from AMS_Address__c where account__c in :addressMapPerAgencyForAccUpd.keySet()];

            Map<Id, List<AMS_Address__c>> mAgAddress = new Map<Id, List<AMS_Address__c>>(); 

            for(AMS_Address__c add : addresses){
                List<AMS_Address__c> auxAdd = mAgAddress.get(add.Account__c);
                if(auxAdd != Null && auxAdd.size() > 0){
                  auxAdd.add(add);
                  mAgAddress.remove(add.Account__c);
                  mAgAddress.put(add.Account__c,auxAdd);
                }else{
                  auxAdd = new List<AMS_Address__c>();
                  auxAdd.add(add);
                  mAgAddress.put(add.Account__c,auxAdd);  
                }          
            } 

            for(Id ag : mAgAddress.keySet()){
              List<AMS_Address__c > auxAddresses = mAgAddress.get(ag);
              Map<Id, AMS_Address__c> mAddresses = new Map<Id, AMS_Address__c>(auxAddresses);

              Boolean bBilling = false;
              Id idBilling;
              Boolean bPrimary = false;
              Id idPrimary;
              Boolean bShipping = false;
              Id idShipping;

              for(AMS_Address__c add : auxAddresses){
                if(add.Address_Type__c!= null && add.Address_Type__c.contains('Billing')){
                  bBilling = true;
                  idBilling = add.Id;
                }
                if(add.Address_Type__c!= null && add.Address_Type__c.contains('Primary')){
                  bPrimary = true;
                  idPrimary = add.Id;
                }
                if(add.Address_Type__c!= null && add.Address_Type__c.contains('Shipping')){
                  bShipping = true;
                  idShipping = add.Id;
                }
              }

              if(bPrimary){
                addToBeReportedForAccountUpdate.add(mAddresses.get(idPrimary));
              }else if(bBilling){
                addToBeReportedForAccountUpdate.add(mAddresses.get(idBilling));
              }

              if(bShipping && idShipping != idPrimary)
                addToBeReportedForAccountUpdate.add(mAddresses.get(idShipping));
            }
        }

		System.debug('************************************** hop: '+addToBeReportedForAccountUpdate);
        //FM 14-10-2015 - INC:10933
        if(addToBeReportedForAccountUpdate.size()>0)
                AMS_AddressHelper.updateBillingShippingAddressesOnAccount(addToBeReportedForAccountUpdate);
       
        System.debug('addToBeReportedForAccountUpdate2: ' + addToBeReportedForAccountUpdate);
        //FM 14-10-2015 - END
    }
    //deletion: need to find a new address to set as the primary
    else if(Trigger.isDelete) {
        //deletion: need to find a new address to set as the primary
        for(AMS_Address__c add:trigger.Old){
            if(add.Address_Type__c!=null  && add.Address_Type__c.contains('Primary')){
                add.Address_Type__c.addError('Cannot delete Primary Address! In order to Delete set another address as Primary!');
            }
        }
    }
}