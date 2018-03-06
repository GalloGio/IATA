public class AMS_AccreditationOnlineTriggerHelper {

    public static void prepopulateAbbreviatedFields(AMS_Pax_Accreditation_Form__c a, AMS_Pax_Accreditation_Form__c olda){
        
        Integer length = 0;
        if(AMS_Utils.LocationClassCARGO.contains(a.Location_Class__c))    length = 60;
        else if(AMS_Utils.LocationClassPASSENGER.contains(a.Location_Class__c))   length = 30;
        
        // abbreviated field is populated automatically if
        // abbreviated is null
        // OR
        // is update, full field is changed and abbreviated is not

        if(a.Abbreviated_address__c == null || (olda!=null && a.Branch_Office_Street_name_number__c!=olda.Branch_Office_Street_name_number__c && a.Abbreviated_address__c == olda.Abbreviated_address__c)){
            String str = a.Branch_Office_Street_name_number__c;
            if(str!=null && str.length()>length) str = str.substring(0,length);
            a.Abbreviated_address__c = str;
        }

        
        if(a.Abbreviated_name__c == null || (olda!=null && a.Account_Name__c!=olda.Account_Name__c && a.Abbreviated_name__c == olda.Abbreviated_name__c)){
            String str = a.Account_Name__c;
            if(str!=null && str.length()>length) str = str.substring(0,length);
            a.Abbreviated_name__c = str;
        }
        
    }

    // Automatically set the Billing ISO State to the value of the AMS Default State of the selectedd ISO Country, if the latter is not null
    // Override any user changes
    public static void prepopulateBillingIsoState (list<AMS_Pax_Accreditation_Form__c> newList, map<Id, AMS_Pax_Accreditation_Form__c> oldMap){

        list<Id> lstInvolvedISOCountriesIds = new list<Id>();
        set<String> setDefaultISOStatesCodes = new set<String>();
        map<String, Id> mapIsoStatesPerCodeKey = new map<String, Id>();
        
        for (AMS_Pax_Accreditation_Form__c accForm : newList) {
            if (accForm.Branch_Office_Country__c != null && (oldMap == null || oldMap.get(accForm.Id).Branch_Office_Country__c != accForm.Branch_Office_Country__c || oldMap.get(accForm.Id).IATA_ISO_State__c != accForm.IATA_ISO_State__c)) {
                lstInvolvedISOCountriesIds.add(accForm.Branch_Office_Country__c);
            }
        }
        system.debug('[AccreditationTriggerHelper] lstInvolvedISOCountriesIds: ' + lstInvolvedISOCountriesIds);

        if (lstInvolvedISOCountriesIds.isEmpty())
            return;

        map<Id, IATA_ISO_Country__c> mapCountriesPerId = new map<Id, IATA_ISO_Country__c>([SELECT Id, ISO_Code__c, AMS_Default_State__c FROM IATA_ISO_Country__c WHERE Id IN :lstInvolvedISOCountriesIds AND AMS_Default_State__c <> null]);
        
        for (IATA_ISO_Country__c country : mapCountriesPerId.values()) {
                setDefaultISOStatesCodes.add(country.AMS_Default_State__c);
        }
        system.debug('[AccreditationTriggerHelper] setDefaultISOStatesCodes: ' + setDefaultISOStatesCodes);
        if (setDefaultISOStatesCodes.isEmpty())
            return;
        
        list<IATA_ISO_State__c> lstInvolvedIsoStates = [SELECT Id, ISO_Code__c, IATA_ISO_Country__c, IATA_ISO_Country__r.ISO_Code__c FROM IATA_ISO_State__c WHERE ISO_Code__c IN :setDefaultISOStatesCodes AND IATA_ISO_Country__c IN :lstInvolvedISOCountriesIds];

        for (IATA_ISO_State__c state : lstInvolvedIsoStates) {
            mapIsoStatesPerCodeKey.put(state.IATA_ISO_Country__r.ISO_Code__c + '-' + state.ISO_Code__c, state.Id);
        }
        system.debug('[AccreditationTriggerHelper] mapIsoStatesPerCodeKey: ' + mapIsoStatesPerCodeKey);
        // set default state as billing iso state
        for (AMS_Pax_Accreditation_Form__c accForm : newList) {
            system.debug('[AccreditationTriggerHelper] set values: accForm key ' + mapCountriesPerId.get(accForm.Branch_Office_Country__c).ISO_Code__c + '-' + mapCountriesPerId.get(accForm.Branch_Office_Country__c).AMS_Default_State__c);
            if (accForm.Branch_Office_Country__c != null && (oldMap == null || oldMap.get(accForm.Id).Branch_Office_Country__c != accForm.Branch_Office_Country__c || oldMap.get(accForm.Id).IATA_ISO_State__c != accForm.IATA_ISO_State__c))
                if (mapCountriesPerId.get(accForm.Branch_Office_Country__c) != null && mapCountriesPerId.get(accForm.Branch_Office_Country__c).AMS_Default_State__c != null && mapIsoStatesPerCodeKey.get(mapCountriesPerId.get(accForm.Branch_Office_Country__c).ISO_Code__c + '-' + mapCountriesPerId.get(accForm.Branch_Office_Country__c).AMS_Default_State__c) != null) {
                    accForm.IATA_ISO_State__c = mapIsoStatesPerCodeKey.get(mapCountriesPerId.get(accForm.Branch_Office_Country__c).ISO_Code__c + '-' + mapCountriesPerId.get(accForm.Branch_Office_Country__c).AMS_Default_State__c);
                    system.debug('[AccreditationTriggerHelper] setting value for form ');
                }
        }
    }
    
}