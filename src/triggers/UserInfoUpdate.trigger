trigger UserInfoUpdate on Case (before insert, before update) 
{   
    //getting record types
    ID SIDRAcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
    ID SIDRABRcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA_BR');
    
    List<User> currentUser;   
    Boolean isCurrentUserInit = false;            

    // Update L.Faccio ----------------
    //When a case is closed, I save the user who closed the case.
    for(Case c : Trigger.new){
        if((Trigger.isInsert && c.Status == 'Closed') || 
            (Trigger.isUpdate && Trigger.oldMap.get(c.Id).Status != 'Closed' && c.Status == 'Closed')){
            
            c.WhoClosedCase__c = UserInfo.getUserId();
        }if(c.Status != 'Closed')
            c.WhoClosedCase__c = null;
    }
    // END Update L.Faccio --------------

    try
    {           
        // if on insert and new case
         if (Trigger.isInsert)
         {            
            for (Case aCase: Trigger.New) 
            {                
                if ((aCase.RecordTypeId == SIDRAcaseRecordTypeID) || (aCase.RecordTypeId == SIDRABRcaseRecordTypeID ))
                {                    
                    //check if fields are not null then update name field
                    // CS_Contact_Result__c          updates    CS_Rep_Contact_Customer__c
                    // Update_AIMS_IRR__c            updates    CS_Rep_Acc_IRR_DEF__c    
                    // Update_AIMS_DEF__c            updates    CS_Rep_Acc_DEF__c
                    /// Update_AIMS_IRRWITH__c        updates   CS_Rep_ACC_IRR_Withdrawal__c
                    // Update_AIMS_REI_DEFWITH__c    updates    CS_Rep_Acc_REI__c            
                    //  Update_AIMS_TER__c            updates    CS_Rep_ACC_TER__c
                    
                    if (isCurrentUserInit == false)
                    {
                        currentUser = [Select Id, FirstName, LastName, ProfileId from User where Id =: UserInfo.getUserId() limit 1];
                        isCurrentUserInit = true;
                    }
                    if (currentUser.size() > 0)
                    {                      
                        if (aCase.CS_Contact_Result__c != null)
                            aCase.CS_Rep_Contact_Customer__c = currentUser[0].Id ;
                        if (aCase.Update_AIMS_IRR__c != null)
                            aCase.CS_Rep_Acc_IRR_DEF__c = currentUser[0].Id ; 
                        if (aCase.Update_AIMS_DEF__c != null)
                            aCase.CS_Rep_Acc_DEF__c = currentUser[0].Id ; 
                        if (aCase.Update_AIMS_IRRWITH__c != null)
                            aCase.CS_Rep_ACC_IRR_Withdrawal__c = currentUser[0].Id ; 
                        if (aCase.Update_AIMS_REI_DEFWITH__c != null)
                            aCase.CS_Rep_Acc_REI__c = currentUser[0].Id ; 
                        if (aCase.Update_AIMS_TER__c != null)
                            aCase.CS_Rep_ACC_TER__c = currentUser[0].Id ; 
                    }
                }                
            }
         }    
    
        //if on update existing case
         else if (Trigger.isUpdate) 
         {
             for (Case updatedCase: Trigger.New) 
             {
                 if ((updatedCase.RecordTypeId == SIDRAcaseRecordTypeID) || (updatedCase.RecordTypeId == SIDRABRcaseRecordTypeID ))
                 {
                     //User currentUser = [Select Id, FirstName, LastName, ProfileId from User where Id =: UserInfo.getUserId() limit 1];
                     //compare with old values       
                     Case oldCase = Trigger.oldMap.get(updatedCase.ID);
                     
                     if (isCurrentUserInit == false)
                    {
                        currentUser = [Select Id, FirstName, LastName, ProfileId from User where Id =: UserInfo.getUserId() limit 1];
                        isCurrentUserInit = true;
                    }
                    if (currentUser.size() > 0)
                    {                      
                        //update name field if values changed
                        if (updatedCase.CS_Contact_Result__c != oldCase.CS_Contact_Result__c)
                            updatedCase.CS_Rep_Contact_Customer__c = currentUser[0].Id ;
                        if (updatedCase.Update_AIMS_IRR__c != oldCase.Update_AIMS_IRR__c)
                            updatedCase.CS_Rep_Acc_IRR_DEF__c = currentUser[0].Id ; 
                        if (updatedCase.Update_AIMS_DEF__c != oldCase.Update_AIMS_DEF__c)
                            updatedCase.CS_Rep_Acc_DEF__c = currentUser[0].Id ; 
                        if (updatedCase.Update_AIMS_IRRWITH__c != oldCase.Update_AIMS_IRRWITH__c)
                            updatedCase.CS_Rep_ACC_IRR_Withdrawal__c = currentUser[0].Id ; 
                        if (updatedCase.Update_AIMS_REI_DEFWITH__c != oldCase.Update_AIMS_REI_DEFWITH__c)
                            updatedCase.CS_Rep_Acc_REI__c = currentUser[0].Id ; 
                        if (updatedCase.Update_AIMS_TER__c != oldCase.Update_AIMS_TER__c)
                            updatedCase.CS_Rep_ACC_TER__c = currentUser[0].Id ; 
                    }                    
                }
            }
         }
    }
    catch(Exception e)
    {
        System.debug('** Error' + e);
    }
}