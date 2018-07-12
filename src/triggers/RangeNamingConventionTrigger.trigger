/**
This trigger is creating the final name for a Range.
IATA Code rnage has a naming convention

**/
trigger RangeNamingConventionTrigger on Code_Range__c (before insert, before update) {
    Map<Id, List<Code_Range__c >> newRangesPerRecordType  = new Map<Id, List<Code_Range__c >>();
    set<id> currentIds = new set<id>();
    for(Code_Range__c  aRange:Trigger.new){
    	if(trigger.isUpdate)
    		currentIds.add(aRange.id);
        if(newRangesPerRecordType.get(aRange.recordtypeId)==null)
            newRangesPerRecordType.put(aRange.recordtypeId, new List<Code_Range__c >());
        newRangesPerRecordType.get(aRange.recordtypeId).add(aRange);
    }
    
    Map<ID , IATA_ISO_Country__c> countries  = new Map<ID , IATA_ISO_Country__c>(IATAIsoCountryDAO.getIsoCountries());
    Map<String , IATA_ISO_State__c> states = new Map<String , IATA_ISO_State__c>(IATAIsoStateDAO.getIsoStates());           
        
    //ITA CODE RANGE
    List<Code_Range__c > newIataCodeRange = newRangesPerRecordType.get(RecordTypeSingleton.getInstance().getRecordTypeId('Code_Range__c', 'IATA_Code'));
    List<Code_Range__c > duplicateIataCodeRange = new List<Code_Range__c >();
    Map<String , Code_Range__c > newIataCodeRangePerName = new Map<String , Code_Range__c >();
    for(Code_Range__c  aRange :newIataCodeRange ){
    	String rName = aRange .Area_Code__c+'-'+aRange.Prefix__c+'-'+countries.get(aRange.IATA_ISO_Country__c).ISO_Code__c +'-'+ aRange.ProgramCode__c+'-['+aRange.Min_Range__c+'-'+aRange.Max_Range__c+']';
        
        if(aRange.IATA_ISO_State__c!=null)
        	rName = aRange .Area_Code__c+'-'+aRange.Prefix__c+'-'+countries.get(aRange.IATA_ISO_Country__c).ISO_Code__c+'-'+states.get(aRange.IATA_ISO_State__c).ISO_Code__c +'-'+ aRange.ProgramCode__c+'-['+aRange .Min_Range__c+'-'+aRange.Max_Range__c+']';
       
        aRange.Name= rName;
        newIataCodeRangePerName.put(aRange.Name, aRange);
    }
    
    if(!currentIds.isEmpty()){
        for(Code_Range__c code : CodeRangeDAO.getCodeRangeByName(newIataCodeRangePerName.keySet())){
	       if(!currentIds.contains(code.id)){
                duplicateIataCodeRange.add(code);
            }
        }
	}else{
		duplicateIataCodeRange  = CodeRangeDAO.getCodeRangeByName(newIataCodeRangePerName.keySet());
    }
    
    for(Code_Range__c dup : duplicateIataCodeRange){
        newIataCodeRangePerName.get(dup.Name).addError('Range '+dup.Name+' cannot be create. An other range already exist with same name');
    }
    
}