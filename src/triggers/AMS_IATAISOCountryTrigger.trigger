trigger AMS_IATAISOCountryTrigger on IATA_ISO_Country__c (after insert) {


	// For each new Country created I'll create a Segment with record type = 'Country' if not exists 
	List<String> segmentCodes = new List<String>();
	for(IATA_ISO_Country__c isoc : Trigger.new)
    	segmentCodes.add(isoc.ISO_Code__c); 
    
    
    Id countryrt = Schema.getGlobalDescribe().get('AMS_Segment__c').getDescribe().getRecordTypeInfosByName().get('Country Area').getRecordTypeId();
    Map<String, AMS_Segment__c> codeToSegment = new Map<String, AMS_Segment__c>();
    for(AMS_Segment__c seg : [SELECT ID, Label__c , CountryISOCode__c
    							FROM AMS_Segment__c 
    							WHERE CountryISOCode__c IN : segmentCodes])
    	codeToSegment.put(seg.CountryISOCode__c, seg);
   

	List<AMS_Segment__c> newSegments = new List<AMS_Segment__c>();
    for(IATA_ISO_Country__c isoc : Trigger.new)
        if(codeToSegment.get(isoc.ISO_Code__c) == null){
            AMS_Segment__c seg = new AMS_Segment__c(RecordTypeId=countryrt, 
                                               Label__c=isoc.Name, 
                                               CountryISOCode__c=isoc.ISO_Code__c);
    		newSegments.add(seg);
            codeToSegment.put(seg.CountryISOCode__c, seg);
        }
    insert newSegments;

    List<AMS_Segment_Country__c> nton = new List<AMS_Segment_Country__c>();
    for(IATA_ISO_Country__c isoc : Trigger.new){
        nton.add(new AMS_Segment_Country__c(
        	Country__c = isoc.id,
            Segment__c = codeToSegment.get(isoc.ISO_Code__c).id
        ));
    }
    insert nton;
}