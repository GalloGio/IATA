public class AMS_CountrySpecificAttributeHandler {

    public static Map<Id,Map<String,Decimal>> mapCountryToThreshold {get;set;}
    private static final Id IRR_FOR_FS_RT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Irregularities_for_FS_Request'); 
    private static final Id IRR_THRESHOLD_RT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Irregularity_Threshold'); 

    public static void beforeInsert(List<AMS_Country_Specific_Attribute__c> records) {
        List<AMS_Country_Specific_Attribute__c> recordsToValidate = new List<AMS_Country_Specific_Attribute__c>();
        mapCountryToThreshold = new Map<Id,Map<String,Decimal>>();

        for(AMS_Country_Specific_Attribute__c record : records) {
            if(record.RecordTypeId == IRR_FOR_FS_RT) {
                recordsToValidate.add(record);
                mapCountryToThreshold.put(record.IATA_ISO_Country__c, new Map<String,Decimal>());
            }
        }

        if(!recordsToValidate.isEmpty()) {
            validateThreshold(recordsToValidate);
        }
    }

    public static void beforeUpdate(List<AMS_Country_Specific_Attribute__c> records, Map<Id,AMS_Country_Specific_Attribute__c> oldMap) {
        List<AMS_Country_Specific_Attribute__c> recordsToValidate = new List<AMS_Country_Specific_Attribute__c>();
        mapCountryToThreshold = new Map<Id,Map<String,Decimal>>();

        for(AMS_Country_Specific_Attribute__c record : records) {
            AMS_Country_Specific_Attribute__c oldRecord = oldMap.get(record.Id);
            if(record.RecordTypeId == IRR_FOR_FS_RT && oldRecord.Threshold__c <> record.Threshold__c) {
                recordsToValidate.add(record);
                mapCountryToThreshold.put(record.IATA_ISO_Country__c, new Map<String,Decimal>());
            }
        }

        if(!recordsToValidate.isEmpty()) {
            validateThreshold(recordsToValidate);
        }
    }

    private static void validateThreshold(List<AMS_Country_Specific_Attribute__c> records) {
        List<AMS_Country_Specific_Attribute__c> irrAttrs = [SELECT IATA_ISO_Country__c, Location_Class__c, Threshold__c
                                                            FROM AMS_Country_Specific_Attribute__c 
                                                            WHERE RecordTypeId = :IRR_THRESHOLD_RT AND IATA_ISO_Country__c IN :mapCountryToThreshold.keySet()];
        
        for(AMS_Country_Specific_Attribute__c irrAttr : irrAttrs) {
            Map<String,Decimal> mapClassToThreshold = mapCountryToThreshold.get(irrAttr.IATA_ISO_Country__c);
            if(mapClassToThreshold == null) {
                mapClassToThreshold = new Map<String,Decimal>();
                mapCountryToThreshold.put(irrAttr.IATA_ISO_Country__c, mapClassToThreshold);
            }

            Decimal currThreshold = mapClassToThreshold.get(irrAttr.Location_Class__c);
            if(currThreshold == null || irrAttr.Threshold__c < currThreshold) {
                mapClassToThreshold.put(irrAttr.Location_Class__c, irrAttr.Threshold__c);
            }
        }

        for(AMS_Country_Specific_Attribute__c record : records) {
            Map<String,Decimal> mapClassToThreshold = mapCountryToThreshold.get(record.IATA_ISO_Country__c);
            
            if(mapClassToThreshold == null) {
                continue;
            }

            Decimal classThreshold = mapClassToThreshold.get(record.Location_Class__c);
            if(classThreshold <> null && classThreshold <= record.Threshold__c) {
                record.addError(Label.AMS_CountrySAttr_Validation);
            }
        }
    }
	
} 