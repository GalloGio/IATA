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

    /*** AMSU-121 ***/
    public static CountryStateWrapper getIsoCountries(List<AMS_Pax_Accreditation_Form__c> accreditations) {
        CountryStateWrapper csw = new CountryStateWrapper();

        for(AMS_Pax_Accreditation_Form__c accreditation : accreditations) {
            if(accreditation.Branch_Office_Country__c != null) {
                csw.isoCountriesIds.add(accreditation.Branch_Office_Country__c);
            }

            if(accreditation.Shipping_ISO_Country__c != null) {
                csw.isoCountriesIds.add(accreditation.Shipping_ISO_Country__c);
            }

            if(accreditation.Shipping_ISO_State__c != null) {
                csw.isoStatesIds.add(accreditation.Shipping_ISO_State__c);
            }        
        }

        List<IATA_ISO_Country__c> lstCountries = IATAIsoCountryDAO.getIsoCountriesByIds(csw.isoCountriesIds);

        for(IATA_ISO_Country__c country : lstCountries) {
            if(!String.isBlank(country.AMS_Default_State__c)) {
                csw.defaultIsoStateCodes.add(country.AMS_Default_State__c);
            }
        }

        List<IATA_ISO_State__c> stateListByID = IATAIsoStateDAO.getIsoStatesByIds(csw.isoStatesIds);
        List<IATA_ISO_State__c> stateListByIsoCodes = IATAIsoStateDAO.getIsoStateByIsoCodes(csw.defaultIsoStateCodes);

        Set<IATA_ISO_State__c> lstStates = new Set<IATA_ISO_State__c>(stateListByID);
        lstStates.addAll(stateListByIsoCodes);

        for(IATA_ISO_Country__c country : lstCountries) {
            csw.mapIsoCountries.put(country.Id, country);
        }

        for(IATA_ISO_State__c state : lstStates) {
            csw.mapIsoStates.put(state.Id, state);
        }

        return csw;
    }

    public static void runPopulateStates(list<AMS_Pax_Accreditation_Form__c> newList, map<Id, AMS_Pax_Accreditation_Form__c> oldMap) {
        Boolean needToPopulateState = true;
        if(oldMap != null) {
            needToPopulateState = false;
            for(AMS_Pax_Accreditation_Form__c accr : newList) {
                AMS_Pax_Accreditation_Form__c oldAccr = oldMap.get(accr.Id);
                if(accr.Branch_Office_Country__c != null && (oldAccr.Branch_Office_Country__c != accr.Branch_Office_Country__c || oldAccr.IATA_ISO_State__c != accr.IATA_ISO_State__c)) {
                    needToPopulateState = true;
                }
                if(accr.Shipping_ISO_Country__c != null && (oldAccr.Shipping_ISO_Country__c != accr.Shipping_ISO_Country__c || oldAccr.Shipping_ISO_State__c != accr.Shipping_ISO_State__c)) {
                    needToPopulateState = true;
                }
            }
        }

        if(!needToPopulateState) {
            return;
        }

        CountryStateWrapper csw = getIsoCountries(newList);
        prepopulateBillingIsoState (newList, oldMap, csw);
        fillState(newList, oldMap, csw);
    }

    /*** AMSU-121 **/

    // Automatically set the Billing ISO State to the value of the AMS Default State of the selectedd ISO Country, if the latter is not null
    // Override any user changes
    public static void prepopulateBillingIsoState (list<AMS_Pax_Accreditation_Form__c> newList, map<Id, AMS_Pax_Accreditation_Form__c> oldMap, CountryStateWrapper csw) {

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

        map<Id, IATA_ISO_Country__c> mapCountriesPerId = csw.mapIsoCountries;

        list<IATA_ISO_State__c> lstInvolvedIsoStates = csw.mapIsoStates.values();


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

    /*** AMSU-121 Start ***/
    public static void fillState(List<AMS_Pax_Accreditation_Form__c> accreditations, Map<Id,AMS_Pax_Accreditation_Form__c> oldMap, CountryStateWrapper csw) {
        Set<Id> isoCountriesId = new Set<Id>();
        Set<Id> isoStatesId = new Set<Id>();
        for(AMS_Pax_Accreditation_Form__c accreditation : accreditations) {
            if(!String.isEmpty(accreditation.Shipping_ISO_Country__c)) {
                isoCountriesId.add(accreditation.Shipping_ISO_Country__c);
            }
            if(!String.isEmpty(accreditation.Shipping_ISO_State__c)) {
                isoStatesId.add(accreditation.Shipping_ISO_State__c);
            }
        }

        StatesWrapper states = getMapDefaultIsoStates(csw.mapIsoCountries, csw.mapIsoStates);

        if(oldMap == null) { //insert
            for(AMS_Pax_Accreditation_Form__c accreditation : accreditations) {
                if(accreditation.Shipping_ISO_Country__c != null) {
                    IATA_ISO_State__c defaultState = states.mapDefaultStates.get(accreditation.Shipping_ISO_Country__c);
                    if(defaultState != null) {
                        accreditation.Shipping_ISO_State__c = defaultState.Id;
                    } else if(accreditation.Shipping_ISO_State__c != null) {
                        String shippingState = states.mapStatesNames.get(accreditation.Shipping_ISO_State__c);
                        if(shippingState != null && accreditation.Shipping_State__c != shippingState) {
                            accreditation.Shipping_State__c = shippingState;
                        }
                    }
                }
            }
        } else { //update
            for(AMS_Pax_Accreditation_Form__c accreditation : accreditations) {
                AMS_Pax_Accreditation_Form__c oldRecord = oldMap.get(accreditation.Id);
                if(accreditation.Shipping_ISO_Country__c != null) {
                    IATA_ISO_State__c defaultState = states.mapDefaultStates.get(accreditation.Shipping_ISO_Country__c);
                    String shippingState = states.mapStatesNames.get(accreditation.Shipping_ISO_State__c);
                    if(defaultState != null) {
                        accreditation.Shipping_ISO_State__c = defaultState.Id;
                        if(oldRecord.Shipping_ISO_State__c != accreditation.Shipping_ISO_State__c) {                            
                            accreditation.Shipping_State__c = null; 
                        }                      
                    } else if(oldRecord.Shipping_ISO_State__c != accreditation.Shipping_ISO_State__c) {
                        accreditation.Shipping_State__c = shippingState;
                    }
                }
            }
        }
    }

    private static StatesWrapper getMapDefaultIsoStates(Map<Id, IATA_ISO_Country__c> isoCountries, Map<Id, IATA_ISO_State__c> isoStates) {
        StatesWrapper res = new StatesWrapper();
        Map<String, IATA_ISO_State__c> mapNamesStates = new Map<String, IATA_ISO_State__c>();

        for(IATA_ISO_State__c state : isoStates.values()) {
            if(!String.isBlank(state.ISO_Code__c)) {
                mapNamesStates.put(state.ISO_Code__c, state);
            }
            res.mapStatesNames.put(state.Id, state.Name);
        }

        for(IATA_ISO_Country__c isoCountry : isoCountries.values()) {
            if(!String.isBlank(isoCountry.AMS_Default_State__c)) {
                res.mapDefaultStates.put(isoCountry.Id, mapNamesStates.get(isoCountry.AMS_Default_State__c));
            }
        }

        return res;
    }
    
    public class StatesWrapper {
        public Map<Id, IATA_ISO_State__c> mapDefaultStates {get;set;}
        public Map<Id, String> mapStatesNames {get;set;}

        public StatesWrapper() {
            this.mapDefaultStates = new Map<Id, IATA_ISO_State__c>();
            this.mapStatesNames = new Map<Id, String>();
        }
    }    

    public class CountryStateWrapper {
        public Set<Id> isoCountriesIds {get;set;}
        public Set<Id> isoStatesIds {get;set;}
        public Set<String> defaultIsoStateCodes {get;set;}
        public Map<Id, IATA_ISO_Country__c> mapIsoCountries {get;set;}
        public Map<Id, IATA_ISO_State__c> mapIsoStates {get;set;}

        public CountryStateWrapper() {
            isoCountriesIds = new Set<Id>();
            isoStatesIds = new Set<Id>();
            defaultIsoStateCodes = new Set<String>();
            mapIsoCountries = new Map<Id, IATA_ISO_Country__c>();
            mapIsoStates = new Map<Id, IATA_ISO_State__c>();
        }
    }
    /*** AMSU-121 End ***/

    
}