trigger AMS_CreateOperationName on AMS_Operation__c (before insert) {


    map<String, AMS_Settlement_System__c> settlements = new Map<String,AMS_Settlement_System__c>();
    map<String,AMS_Operation__c> newOperationsName = new Map<String,AMS_Operation__c>();
    for(AMS_Settlement_System__c s:[select Id ,Name,      DPC__c from AMS_Settlement_System__c])
        settlements .put(s.Id,s);
        
        
    map<String, IATA_ISO_Country__c> countries= new Map<String,IATA_ISO_Country__c>();
    for(IATA_ISO_Country__c c:IATAIsoCountryDAO.getIsoCountries())
        countries.put(c.Id,c);
        
        
    for(AMS_Operation__c  op:trigger.new){
       //Operation Name: ZM_BSP _Y_USD_D
       String opname = '';
        
       //  Country: Spain (ES), Zambia (ZM) , etc.
       opname  = countries.get(op.Country__c).ISO_Code__c +'_';
       
       
       //  LOB: CAS/BSP 
       if(op.CASS_Operations__c ==null || op.CASS_Operations__c==''){
           //   BSP Operations: Due to the difference in characters in BSP and CASS. We would need to agree on a Fixed Character to substitute the BSP operations, therefore proposal of  Y.
           
           //TODO
           //  Special case: For Brazil this letter will be a “D” to differentiate the 2 operations having same currency but using 2 different hinge accounts 
           // Ie: BR_BSP_Y_BRL_I, BR_BSP_D_BRL_I
            if(countries.get(op.Country__c).ISO_Code__c=='BR')
                opname  += 'BSP_D_';
            else
                opname  += 'BSP_Y_';
       }
       else{
           opname  += 'CAS_';
           //   CASS Operations: EXP (E) , IMP (I) , Courier (C) , Local (L)
            opname  += op.CASS_Operations__c.substring(0,1)+'_';
       }
       
       
       //   Currency: EUR, USD, etc.
       opname  += op.CurrencyIsoCode+'_';
       
       //   International or Domestic: I or D
       if(op.Market__c=='International')
           opname  +='I';
       else 
           opname  += 'D';      
        op.Name = opName;
        newOperationsName.put(op.Name,op);
    }
    List<AMS_Operation__c > existingOperations = [select Id, Name from AMS_Operation__c where Name in :newOperationsName.keySet()];
    for(AMS_Operation__c  op:existingOperations)
        newOperationsName.get(op.Name).addError('An operation already exists for this Currency/Country/Settlement  '+op.NAme);
}