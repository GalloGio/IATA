public class AMS_IATAISOCountryTriggerHandler {
	public List<IATA_ISO_Country__c> triggerNew = (List<IATA_ISO_Country__c>) Trigger.new;
    //public List<IATA_ISO_Country__c> triggerOld = (List<IATA_ISO_Country__c>) Trigger.old;

    //public Map<Id, IATA_ISO_Country__c> newMap = (Map<Id,IATA_ISO_Country__c>) Trigger.newMap;
    public Map<Id, IATA_ISO_Country__c> oldMap = (Map<Id,IATA_ISO_Country__c>) Trigger.oldMap;

    // ************************************************************
    // ****************** distribution methods ********************
    // ************************************************************

    public void onAfterInsert() {
		handleAMSSegmentCountry();
		handlePortalApplication(false);
    }

    public void onAfterUpdate() {
		handlePortalApplication(true);
    }

    private void handleAMSSegmentCountry() {
    	// For each new Country created I'll create a Segment with record type = 'Country' if not exists 
    	List<String> segmentCodes = new List<String>();

    	for(IATA_ISO_Country__c isoc : triggerNew) {
        	segmentCodes.add(isoc.ISO_Code__c);
        }    
        
        Id countryrt = Schema.getGlobalDescribe().get('AMS_Segment__c').getDescribe().getRecordTypeInfosByName().get('Country Area').getRecordTypeId();
        Map<String, AMS_Segment__c> codeToSegment = new Map<String, AMS_Segment__c>();
        for(AMS_Segment__c seg : [SELECT ID, Label__c , CountryISOCode__c
        							FROM AMS_Segment__c 
        							WHERE CountryISOCode__c IN : segmentCodes])
        	codeToSegment.put(seg.CountryISOCode__c, seg);
       

    	List<AMS_Segment__c> newSegments = new List<AMS_Segment__c>();
        for(IATA_ISO_Country__c isoc : triggerNew)
            if(codeToSegment.get(isoc.ISO_Code__c) == null){
                AMS_Segment__c seg = new AMS_Segment__c(RecordTypeId=countryrt, 
                                                   Label__c=isoc.Name, 
                                                   CountryISOCode__c=isoc.ISO_Code__c);
        		newSegments.add(seg);
                codeToSegment.put(seg.CountryISOCode__c, seg);
            }
        insert newSegments;

        List<AMS_Segment_Country__c> nton = new List<AMS_Segment_Country__c>();
        for(IATA_ISO_Country__c isoc : triggerNew){
            nton.add(new AMS_Segment_Country__c(
            	Country__c = isoc.id,
                Segment__c = codeToSegment.get(isoc.ISO_Code__c).id
            ));
        }
        insert nton;    	
    }

    private void handlePortalApplication(Boolean isUpdate) {

		Set<Id> portalApplicationIds = new Set<Id>();

	    for(IATA_ISO_Country__c isoc : triggerNew) {
	        portalApplicationIds.add(isoc.ANG_Portal_Service__c);

	        if (isUpdate) {
	            
	            IATA_ISO_Country__c oldCountry = oldMap.get(isoc.id);        

	            if (oldCountry.ANG_Portal_Service__c != null) {
	                portalApplicationIds.add(oldCountry.ANG_Portal_Service__c);
	            }
	        }
	    }
	    
	    List<Portal_Applications__c> portals = [select id, ANG_Country_Coverage__c from Portal_Applications__c where id in :portalApplicationIds];

	    boolean flagDone;
	    for (IATA_ISO_Country__c isoc : triggerNew) {

	    	System.debug('isoc.ISO_Code__c-->' + isoc.ISO_Code__c);

			System.debug('isoc.ANG_Portal_Service__c-->' + isoc.ANG_Portal_Service__c);

	        for (Portal_Applications__c portal : portals) {

	            flagDone = false;

	            if(portal.ANG_Country_Coverage__c == null) {
	                portal.ANG_Country_Coverage__c = '';
	            }

	            if (isUpdate) {
	                IATA_ISO_Country__c oldCountry = oldMap.get(isoc.id);

	                System.debug('oldCountry.ANG_Portal_Service__c-->' + oldCountry.ANG_Portal_Service__c);

	                
	                if (oldCountry.ISO_Code__c != isoc.ISO_Code__c) {
	                    if (portal.ANG_Country_Coverage__c.contains(oldCountry.ISO_Code__c)) {
	                        portal.ANG_Country_Coverage__c = portal.ANG_Country_Coverage__c.replace(oldCountry.ISO_Code__c, isoc.ISO_Code__c);
	                        flagDone = true;
	                    }
	                }
					
	                //
	                // Handle the countries that were modified and the association with the portal service was removed.
	                //
	                if(oldCountry.ANG_Portal_Service__c != null && isoc.ANG_Portal_Service__c == null ) {

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
	                } else {
	                	if (isoc.ANG_Portal_Service__c != null && oldCountry.ANG_Portal_Service__c != null && isoc.ANG_Portal_Service__c != oldCountry.ANG_Portal_Service__c) {
	                		if (oldCountry.ANG_Portal_Service__c == portal.id) {
		                        portal.ANG_Country_Coverage__c = portal.ANG_Country_Coverage__c.replace(',' + oldCountry.ISO_Code__c, '');
		                        portal.ANG_Country_Coverage__c = portal.ANG_Country_Coverage__c.replace(oldCountry.ISO_Code__c + ',', '');
		                        portal.ANG_Country_Coverage__c = portal.ANG_Country_Coverage__c.replace(oldCountry.ISO_Code__c , '');
		                        flagDone = true;
	                		}
	                	}
	                }
	            }

  	        	if(isoc.ANG_Portal_Service__c == portal.id) {
		            if (!flagDone && !portal.ANG_Country_Coverage__c.contains(isoc.ISO_Code__c) && isoc.ANG_Portal_Service__c != null) {
		                if (portal.ANG_Country_Coverage__c == '') {
		                    portal.ANG_Country_Coverage__c = isoc.ISO_Code__c;
		                } else {
		                    portal.ANG_Country_Coverage__c += ',' + isoc.ISO_Code__c;
		                }
		            }	        		
	        	}
	        }
	    }

	    update portals;

    }
}