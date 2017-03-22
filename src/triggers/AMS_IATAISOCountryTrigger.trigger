trigger AMS_IATAISOCountryTrigger on IATA_ISO_Country__c (after insert, after update) {

    if(Trigger.isInsert) {
    	// For each new Country created I'll create a Segment with record type = 'Country' if not exists 
    	List<String> segmentCodes = new List<String>();

    	for(IATA_ISO_Country__c isoc : Trigger.new) {
        	segmentCodes.add(isoc.ISO_Code__c);
        }    
        
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

    // Get all the portal application ids to add (or not) the iSO Country to the list of permitted iso countries (ANG_Country_Coverage__c)
    Set<Id> portalApplicationIds = new Set<Id>();

    for(IATA_ISO_Country__c isoc : Trigger.new) {
        portalApplicationIds.add(isoc.ANG_Portal_Service__c);

        if (Trigger.isUpdate) {
            
            IATA_ISO_Country__c oldCountry = Trigger.oldMap.get(isoc.id);        

            if (oldCountry.ANG_Portal_Service__c != null && isoc.ANG_Portal_Service__c == null) {
                portalApplicationIds.add(oldCountry.ANG_Portal_Service__c);
            }
        }
    }

    List<Portal_Applications__c> portals = [select id, ANG_Country_Coverage__c from Portal_Applications__c where id in :portalApplicationIds];

    boolean flagDone;
    for (IATA_ISO_Country__c isoc : Trigger.new) {
        for (Portal_Applications__c portal : portals) {

            flagDone = false;

            if(portal.ANG_Country_Coverage__c == null) {
                portal.ANG_Country_Coverage__c = '';
            }

            if (Trigger.isUpdate) {
                IATA_ISO_Country__c oldCountry = Trigger.oldMap.get(isoc.id);

                if (oldCountry.ISO_Code__c != isoc.ISO_Code__c) {
                    if (portal.ANG_Country_Coverage__c.contains(oldCountry.ISO_Code__c)) {
                        portal.ANG_Country_Coverage__c = portal.ANG_Country_Coverage__c.replace(oldCountry.ISO_Code__c, isoc.ISO_Code__c);
                        flagDone = true;
                    }
                }

                //
                // Handle the countries that were modified and the association with the portal service was removed.
                //
                if(oldCountry.ANG_Portal_Service__c != null && isoc.ANG_Portal_Service__c == null) {
                    if (flagDone) {
                        portal.ANG_Country_Coverage__c = portal.ANG_Country_Coverage__c.replace(',' + isoc.ISO_Code__c, '');
                        portal.ANG_Country_Coverage__c = portal.ANG_Country_Coverage__c.replace(isoc.ISO_Code__c + ',', '');
                        portal.ANG_Country_Coverage__c = portal.ANG_Country_Coverage__c.replace(isoc.ISO_Code__c , '');
                    } else {
                        portal.ANG_Country_Coverage__c = portal.ANG_Country_Coverage__c.replace(',' + oldCountry.ISO_Code__c, '');
                        portal.ANG_Country_Coverage__c = portal.ANG_Country_Coverage__c.replace(oldCountry.ISO_Code__c + ',', '');
                        portal.ANG_Country_Coverage__c = portal.ANG_Country_Coverage__c.replace(oldCountry.ISO_Code__c , '');
                    }
                    flagDone = true;
                }
            }

            if (!flagDone && !portal.ANG_Country_Coverage__c.contains(isoc.ISO_Code__c)) {
                if (portal.ANG_Country_Coverage__c == '') {
                    portal.ANG_Country_Coverage__c = isoc.ISO_Code__c;
                } else {
                    portal.ANG_Country_Coverage__c += ',' + isoc.ISO_Code__c;
                }
            }
        }
    }

    update portals;

}