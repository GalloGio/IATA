trigger trgIDCARD_DontAllowDuplicates_PriceTable on Price_Table__c (before insert, before update) {


  if(Trigger.isInsert)
  {
        
         for(Price_Table__c  newPriceTable : trigger.new)
         {
            
            List <Price_Table__c> pTable = [SELECT ISO_Country__c ,Type_Class_of_Agent__c  FROM Price_Table__c  WHERE ISO_Country__c=:newPriceTable.ISO_Country__c  and Type_Class_of_Agent__c=:newPriceTable.Type_Class_of_Agent__c];
             if (pTable.size()>0)
                newPriceTable.ISO_Country__c.addError(' A record with the same ISO Country and Agent type is already created. No Duplicates are allowerd.');
         }
  }


  if(trigger.isUpdate)
  {
         
            for(Price_Table__c pTableNew : Trigger.new)
            {
                
                for(Price_Table__c  pTableOld: Trigger.old)
                {
                
                    if ((pTableNew.ISO_Country__c != pTableOld.ISO_Country__c ) || (pTableNew.Type_Class_of_Agent__c  != pTableOld.Type_Class_of_Agent__c  ))
                    {
                           
                      List <Price_Table__c> pTable = [SELECT ISO_Country__c ,Type_Class_of_Agent__c  FROM Price_Table__c  WHERE ISO_Country__c=: pTableNew.ISO_Country__c  and Type_Class_of_Agent__c=: pTableNew.Type_Class_of_Agent__c];
                        if (pTable.size()>0)
                            pTableNew.ISO_Country__c.addError(' A record with the same ISO Country and Agent type is already created. No Duplicates are allowerd.');
                    }
    
                 }
          }

  }



}