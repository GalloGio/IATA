/**
This trigger is creating the final name for a Range.
IATA Code rnage has a naming convention

**/
trigger RangeNamingConventionTrigger on Code_Range__c (before insert, before update) {
    Map<string, Id>  rangesRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Code_Range__c'}).get('Code_Range__c');
    Map<Id, List<Code_Range__c >> newRangesPerRecordType  = new Map<Id, List<Code_Range__c >>();
    set<id> currentIds = new set<id>();
    for(Code_Range__c  aRange:Trigger.new){
    	if(trigger.isUpdate)
    		currentIds.add(aRange.id);
        if(newRangesPerRecordType.get(aRange.recordtypeId)==null)
            newRangesPerRecordType.put(aRange.recordtypeId, new List<Code_Range__c >());
        newRangesPerRecordType.get(aRange.recordtypeId).add(aRange);
    }
    
    Map<String , IATA_ISO_Country__c> countries  = new Map<String , IATA_ISO_Country__c>();
    for(IATA_ISO_Country__c c:[select Id, Name ,ISO_Code__c from IATA_ISO_Country__c ])
        countries.put(c.Id, c);
    Map<String , IATA_ISO_State__c> states= new Map<String , IATA_ISO_State__c>();
    for(IATA_ISO_State__c s:[select Id, Name ,ISO_Code__c from IATA_ISO_State__c])
        states.put(s.Id, s);
            
    
    //process Naming convention
    
    //ITA CODE RANGE
    List<Code_Range__c > newIataCodeRange = newRangesPerRecordType.get(rangesRT.get('IATA_Code'));
    List<Code_Range__c > duplicateIataCodeRange = new List<Code_Range__c >();
    Map<String , Code_Range__c > newIataCodeRangePerName = new Map<String , Code_Range__c >();
    for(Code_Range__c  aRange :newIataCodeRange ){
    	String rName = aRange .Area_Code__c+'-'+aRange.Prefix__c+'-'+countries.get(aRange.IATA_ISO_Country__c).ISO_Code__c +'-'+ aRange.ProgramCode__c+'-['+aRange.Min_Range__c+'-'+aRange.Max_Range__c+']';
        //String rName = aRange .Area_Code__c+'-'+aRange .Country_Code__c+'-'+countries.get(aRange.IATA_ISO_Country__c).ISO_Code__c+'-['+aRange .Max_Range__c+'-'+aRange.Min_Range__c+']';
        
        if(aRange.IATA_ISO_State__c!=null)
        	rName = aRange .Area_Code__c+'-'+aRange.Prefix__c+'-'+countries.get(aRange.IATA_ISO_Country__c).ISO_Code__c+'-'+states.get(aRange.IATA_ISO_State__c).ISO_Code__c +'-'+ aRange.ProgramCode__c+'-['+aRange .Min_Range__c+'-'+aRange.Max_Range__c+']';
            //rName = aRange .Area_Code__c+'-'+aRange .Country_Code__c+'-'+countries.get(aRange.IATA_ISO_Country__c).ISO_Code__c+'-'+states.get(aRange.IATA_ISO_State__c).ISO_Code__c+'-['+aRange .Min_Range__c+'-'+aRange.Max_Range__c+']';
       
        aRange.Name= rName;
        newIataCodeRangePerName.put(aRange.Name, aRange);
    }
    
    if(!currentIds.isEmpty())
	    duplicateIataCodeRange  = [select Id, Name from Code_Range__c  where Name in :newIataCodeRangePerName.keySet() and id not in :currentIds];
	else
		duplicateIataCodeRange  = [select Id, Name from Code_Range__c  where Name in :newIataCodeRangePerName.keySet()];
    
    for(Code_Range__c   dup:duplicateIataCodeRange  ){
        newIataCodeRangePerName.get(dup.Name).addError('Range '+dup.Name+' cannot be create. An other range already exist with same name');
    }
    
    //OTHER?
    //DA FUCK IS THE PREVIOUS COMMENT?!?!?
}