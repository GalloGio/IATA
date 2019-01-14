trigger updateAccountFieldBasedOnIATAwebCode on Case (before insert, before update) {

    /*//getting record types*/
    ID SIDRAcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
    ID ProcesscaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');
    ID EuropecaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');
    ID AmericacaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesAmericas');
    ID AfricaMEcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesMENA');
    ID AsiaPacificcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ExternalCasesIDFSglobal');
    ID ChinaAsiacaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_China_North_Asia');
    ID InternalcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE');
    ID InvCollectioncaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Invoicing_Collection_Cases');
    ID CSProcesscaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CS_Process_IDFS_ISS');
    ID SEDAcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SEDA');
    ID ISSPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ISS_Portal_New_Case_RT');//TF - SP9-C5

    try {

        // For completing the Account Concerned (airline BR) automatically when the account is an airline and the IATA Country is specified:
        // list of cases where the country is specified and list of related account Ids
        List<Case> lstCasesWithBSPCountry = new List<Case>();
        List<Id> lstAccountIds = new List<Id>();

        // For completing the Account Concerned automatically when a Web IATA Code is specified:
        // Create a map of the search cases per search strings (keys = Web IATA code)
        Map<String, List<Case>> mapCasesPerWebIATACode = new Map<String, List<Case>>();

        // fill this map with the cases of interest and the processed web iata codes
        for (Case aCase : trigger.New) {
            system.debug('RECORD TYPE: ' + aCase.RecordTypeId);
            /*// check if correct record type*/
            if (   (aCase.RecordTypeId == SIDRAcaseRecordTypeID)
                    || (aCase.RecordTypeId == ProcesscaseRecordTypeID)
                    || (aCase.RecordTypeId == EuropecaseRecordTypeID)
                    || (aCase.RecordTypeId == AmericacaseRecordTypeID)
                    || (aCase.RecordTypeId == AfricaMEcaseRecordTypeID)
                    || (aCase.RecordTypeId == AsiaPacificcaseRecordTypeID)
                    || (aCase.RecordTypeId == ChinaAsiacaseRecordTypeID)
                    || (aCase.RecordTypeId == InternalcaseRecordTypeID)
                    || (aCase.RecordTypeId == InvCollectioncaseRecordTypeID)
                    || (aCase.RecordTypeId == CSProcesscaseRecordTypeID)
                    || (aCase.RecordTypeId == SEDAcaseRecordTypeID)
                    || (aCase.RecordTypeId == ISSPcaseRecordTypeID)//TF - SP9-C5
               )

            {
                system.debug('CORRECT RECORD TYPE');
                system.debug('isInsert: ' + Trigger.isInsert);
                system.debug('isUpdate: ' + Trigger.isUpdate);
                system.debug('Account_Concerned__c: ' + aCase.Account_Concerned__c);

                //system.debug('OLD BSPCountry__c: ' + Trigger.oldMap.get(aCase.Id).BSPCountry__c );
                system.debug('BSPCountry__c: ' + aCase.BSPCountry__c);

                //system.debug('OLD IATAcode__c: ' + Trigger.oldMap.get(aCase.Id).IATAcode__c );
                system.debug('IATAcode__c: ' + aCase.IATAcode__c);
                // Preliminary step for completing the Account Concerned when the account is an airline and the IATA Country is specified
                // get the potentially concerned cases, by choosing those with an IATA Country not null
                if ( aCase.BSPCountry__c != null &&
                        (  (Trigger.isInsert && aCase.Account_Concerned__c == null) ||
                           (Trigger.isUpdate && aCase.BSPCountry__c != Trigger.oldMap.get(aCase.Id).BSPCountry__c)  )  ) {

                    system.debug('INSIDE IF 1');
                    lstCasesWithBSPCountry.add(aCase);

                    lstAccountIds.add(aCase.AccountId);
                }

                // Complete the Account Concerned automatically when a Web IATA Code is specified
                if (   ( Trigger.isInsert && aCase.IATAcode__c != null && aCase.Account_Concerned__c == null )
                        || ( Trigger.isUpdate && aCase.IATAcode__c != null && aCase.IATAcode__c != Trigger.oldMap.get(aCase.Id).IATAcode__c )   ) {

                    system.debug('INSIDE IF 2');
                    /*// this will make sure the IATA code entered by the user would be searched in DB for lengths 7,8,10 and 11*/
                    String WebIATAcode = aCase.IATAcode__c;
                    String WebIATAcode2 = aCase.IATAcode__c;
                    system.debug('IATA CODE 1: ' + WebIATAcode + ' length: ' + WebIATAcode.length());
                    if (WebIATAcode.length() == 8)
                        WebIATAcode = WebIATAcode.substring(0, 7);
                    if (WebIATAcode.length() == 11)
                        WebIATAcode = WebIATAcode.substring(0, 10);
                    system.debug('IATA CODE 2: ' + WebIATAcode + ' length: ' + WebIATAcode.length());
                    /*//in case the user enters 7 digits we need to get the 8th digit  */
                    if (WebIATAcode.length() == 7 && WebIATAcode2.length() == 7) {
                        String t = WebIATAcode.trim();
                        Long a = Long.valueof(t);
                        Long remainder = math.mod(a, 7);
                        WebIATAcode = WebIATAcode  + remainder ;
                    }
                    system.debug('IATA CODE 3: ' + WebIATAcode + ' length: ' + WebIATAcode.length());
                    /* //in case the user enters 10 digits we need to get the 11th digit*/
                    if (WebIATAcode.length() == 10 && WebIATAcode2.length() == 10) {
                        if(WebIATAcode.isNumeric())
                        {
                        String t = WebIATAcode.trim();
                        Long a = Long.valueof(t);
                        Long remainder = math.mod(a, 7);
                        WebIATAcode = WebIATAcode + remainder ;
                        }                        
                    }
                    system.debug('IATA CODE 4: ' + WebIATAcode + ' length: ' + WebIATAcode.length());
                    // Create an entry in the map for the processed key
                    if  (mapCasesPerWebIATACode.get(WebIATAcode) == null) {
                        mapCasesPerWebIATACode.put(WebIATAcode, new List<Case>());
                    }
                    mapCasesPerWebIATACode.get(WebIATAcode).add(aCase);

                    // and another one for the initial (user-entered, unprocessed) key - if it is different from the processed one
                    if (WebIATAcode2 != WebIATAcode) {
                        if  (mapCasesPerWebIATACode.get(WebIATAcode2) == null) {
                            mapCasesPerWebIATACode.put(WebIATAcode2, new List<Case>());
                        }
                        mapCasesPerWebIATACode.get(WebIATAcode2).add(aCase);
                    }

                    // String caseCountry = aCase.BSPCountry__c;

                }
            }
        }

        // Web IATA Code > Account Concerned
        // Match the processed & unprocessed Web IATA Code with the Account Site on the Account records
        system.debug('mapCasesPerWebIATACode.keyset(): ' + mapCasesPerWebIATACode.keyset());
        List<Account> lstMatchedAccounts = new List<Account>();
        if ( !mapCasesPerWebIATACode.keyset().isEmpty()) {
            lstMatchedAccounts = [SELECT Id, Site FROM Account WHERE Site_Index__c IN :mapCasesPerWebIATACode.keyset()];
        }

        // Update the Cases with the Account or Account Concerned info retrieved from the DB - only if the found Account / Account Concerned is different from the Account in the Case
        for (Account acc : lstMatchedAccounts) {
            for (Case c : mapCasesPerWebIATACode.get(acc.Site)) {
                if (c.AccountId != acc.Id) {

                    if ( c.RecordTypeId == EuropecaseRecordTypeID
                            || c.RecordTypeId == AmericacaseRecordTypeID
                            || c.RecordTypeId == AfricaMEcaseRecordTypeID
                            || c.RecordTypeId == AsiaPacificcaseRecordTypeID
                            || c.RecordTypeId == ChinaAsiacaseRecordTypeID
                            || c.RecordTypeId == ISSPcaseRecordTypeID ) {
                        // For these record types, set the Account Concerned field
                        system.debug('FOUND AND SETTING Account Concerned');
                        c.Account_Concerned__c = acc.Id;
                    } else {
                        // For the other record types, keep the initial behaviour of the case and set the Account field on the case
                        system.debug('FOUND AND SETTING Account');
                        c.AccountId = acc.Id;
                    }
                }
            }
        }


        // Airline & IATA Country > Account Concerned
        if (!lstAccountIds.isEmpty()) {
            // Get a map of related accounts - only airlines
            set<String> setAirlineAccountRTs = new set<String> {'IATA_Airline', 'IATA_Airline_BR'};
            Map<Id, Account> mapRelatedAirlineAccountsPerId = new Map<Id, Account>([SELECT Id, Airline_designator__c, IATACode__c, IATA_ISO_Country__r.ISO_Code__c FROM Account
                    WHERE Id IN :lstAccountIds
                    AND RecordType.DeveloperName IN :setAirlineAccountRTs]);

            // continue only if there are airline accounts
            if (!mapRelatedAirlineAccountsPerId.values().isEmpty()) {
                // Get all the ISO Countries & create a map, using the Case BSP Country as key
                List<IATA_ISO_Country__c> lstAllISOCountries = IATAIsoCountryDAO.getIsoCountries();

                Map<String, String> mapCountryCodePerBSPName = new Map<String, String>();
                for (IATA_ISO_Country__c ic : lstAllISOCountries) {
                    mapCountryCodePerBSPName.put(ic.Case_BSP_Country__c, ic.ISO_Code__c);
                }

                // Build a search map for accounts concerned: the key is the searched account site (created with the data from the account on the case + the code
                // of the country on the case), the value is a list of cases
                map<String, List<Case>> mapCasesListPerAccountSite = new map<String, List<Case>>();
                for (Case c : lstCasesWithBSPCountry) {
                    // we only look for the account concerned if it's different from the account on the case, which means the country needs to be different
                    if (mapCountryCodePerBSPName.get(c.BSPCountry__c) != mapRelatedAirlineAccountsPerId.get(c.AccountId).IATA_ISO_Country__r.ISO_Code__c) {
                        // Site = related account 2-letter code + related account iata code + country code of the country on the case
                        String searchedAccSite = mapRelatedAirlineAccountsPerId.get(c.AccountId).Airline_designator__c + ' ' +
                                                 mapRelatedAirlineAccountsPerId.get(c.AccountId).IATACode__c + ' ' +
                                                 mapCountryCodePerBSPName.get(c.BSPCountry__c);

                        if (mapCasesListPerAccountSite.get(searchedAccSite) == null) {
                            mapCasesListPerAccountSite.put(searchedAccSite, new List<Case>());
                        }

                        mapCasesListPerAccountSite.get(searchedAccSite).add(c);
                    }
                }

                if (!mapCasesListPerAccountSite.keyset().isEmpty()) {
                    // search for accounts with that account site
                    lstMatchedAccounts = [SELECT Id, Site FROM Account WHERE Site_Index__c IN :mapCasesListPerAccountSite.keyset() AND RecordType.DeveloperName IN :setAirlineAccountRTs];

                    // update all the cases with the account concerned
                    for (Account acc : lstMatchedAccounts) {

                        for (Case c : mapCasesListPerAccountSite.get(acc.Site)) {
                            if (c.AccountId != acc.Id) {

                                if (c.AccountId != null &&
                                        (c.RecordTypeId == EuropecaseRecordTypeID
                                         || c.RecordTypeId == AmericacaseRecordTypeID
                                         || c.RecordTypeId == AfricaMEcaseRecordTypeID
                                         || c.RecordTypeId == AsiaPacificcaseRecordTypeID
                                         || c.RecordTypeId == ChinaAsiacaseRecordTypeID
                                         || c.RecordTypeId == ISSPcaseRecordTypeID) ) {
                                    // For these record types, set the Account Concerned field
                                    system.debug('FOUND AND SETTING Account Concerned');
                                    c.Account_Concerned__c = acc.Id;
                                } else {
                                    // For the other record types, keep the initial behaviour of the case and set the Account field on the case
                                    system.debug('FOUND AND SETTING Account');
                                    c.AccountId = acc.Id;
                                }
                            }
                        }
                    }
                }
            }

        }

    } catch (Exception e) {
        System.debug('** ERROR ' + e);
    }
}