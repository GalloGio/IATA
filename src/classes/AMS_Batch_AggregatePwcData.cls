/**
 * On that version, the maximum scope allowed for Database.executeBatch is 49
 * because in for(Account account : scope) loop, there's a call to two methods
 * that contains a query : 49 + 49 + 1 = 99 (- 100 SOQL Apex limit)
 */
global class AMS_Batch_AggregatePwcData implements Database.Batchable<Account> {
	public static boolean bIsAMS_Batch_AggregatePwcDataRunning = false;
	
    /**
     * Attributes
     */
    @TestVisible private String query;
    private static final String iataAgencyRecordType = 'IATA_AGENCY';
    private static final List<String> locationClassesLimit = new List<String> {'P', 'C', 'D', 'R'};
    private static final List<String> locationTypesLimit = new List<String> {'HO', 'AO', 'BR', 'SA'};
    private static final Integer irrsDefaultTimeframe = 12; // In months
    private static final Integer defDefaultTimeframe = 12; // In months
    private static final Integer defNonPayDefaultTimeframe = 12; // In months
    private static final Integer ownShaDefaultTimeframe = 12; // In months
    private static final List<String> ownShaChangeCodes = new List<String> {'CHC', 'CHO', 'CHI', 'CHJ', 'CCL', 'CCN', 'CIJ', 'CNL', 'COL', 'CON', 'COS', 'CSC', 'HIN', 'HIS', 'HNL', 'HSL', 'HSM', 'HSN', 'ONL', 'OSL', 'OSM', 'OSN', 'SCL', 'SCM', 'SCN'};
    //WHY THIS SET CONTAINS LESS ITEMS THEN THE ONE ABOVE IF THEY SHOULD CHECK THE SAME THING!?!?!
    //private static final List<String> ownShaLastDateCodes = new List<String> {'CHO', 'CHI', 'CIJ', 'COL', 'CON', 'COS', 'HIN', 'HIS', 'HNL', 'HSL', 'HSM', 'HSN', 'ONL', 'OSL', 'OSM', 'OSN'};
    private static final List<String> ownShaLastDateCodes = new List<String> {'CHC', 'CHO', 'CHI', 'CHJ', 'CCL', 'CCN', 'CIJ', 'CNL', 'COL', 'CON', 'COS', 'CSC', 'HIN', 'HIS', 'HNL', 'HSL', 'HSM', 'HSN', 'ONL', 'OSL', 'OSM', 'OSN', 'SCL', 'SCM', 'SCN'};
    private static final Id recordTypeDefLfcId =  RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'DEF_LFC');
    private static final Id recordTypeIrrsLfcId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'IRRS_LFC');
    private static final Id recordTypeIrrCpeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'IRR_CPE');
    private static final String emailTo = 'brueggerj@iata.org';
    private Map<Id, List<AMS_Country_Specific_Attribute__c>> lfcTimeframesByAccount;
    private Map<Id, List<AMS_Country_Specific_Attribute__c>> irregularityTypeExceptionsByAccount;
    private Map<Id, Datetime> currentOwnShaLastdate;
    private Map<Id, AMS_AggregatePwcData> aggregatePwcDataByAgency;
    private List<Account> accountsToUpdate;
    private Set<Id> accountWithoutUpdateIds;

    /**
     * Default constructor
     */
    public AMS_Batch_AggregatePwcData() {
        query = 'SELECT Id, IATA_ISO_Country__c, Location_Class__c, AMS_PWC_INT_OWNSHA_LASTDATE__c ' +
                'FROM Account ' +
                'WHERE RecordType.developername = :iataAgencyRecordType ' +
                'AND Location_Class__c IN :locationClassesLimit ' +
                'AND Location_Type__c IN :locationTypesLimit';
    }

    /**
     * Retieve all accounts required
     */
    global Iterable<Account> start(Database.BatchableContext batchableContext) {
        return (Iterable<Account>) Database.getQueryLocator(query);
    }

    /**
     * Execute method for PwC interfaces
     */
    global void execute(Database.BatchableContext batchableContext, List<account> scope) {
    	AMS_Batch_AggregatePwcData.bIsAMS_Batch_AggregatePwcDataRunning = true;
        processBatch(scope);
    }

    /**
     * Inform end-user with an e-mail
     */
    global void finish(Database.BatchableContext batchableContext) {

        // Send an e-mail for debug purpose
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{emailTo});
        mail.setSenderDisplayName('Batch Processing Completed');
        mail.setPlainTextBody('Batch Process has been completed.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});

    }

    /**
     * Process part for PwC calculation
     */
    private void processBatch(List<account> scope) {

        // (Re)set needed collection, to have only current chunk
        this.lfcTimeframesByAccount = new Map<Id, List<AMS_Country_Specific_Attribute__c>>();
        this.irregularityTypeExceptionsByAccount = new Map<Id, List<AMS_Country_Specific_Attribute__c>>();
        this.currentOwnShaLastdate = new Map<Id, Datetime>();
        this.aggregatePwcDataByAgency = new Map<Id, AMS_AggregatePwcData>();
        this.accountsToUpdate = new List<Account>();
        this.accountWithoutUpdateIds = new Set<Id>();

        // Current account IDs
        Set<Id> accountIds = new Set<Id>();
        for(Account account : scope) {

            // Fill this set
            accountIds.add(account.Id);

            // If there's no linked country
            if(account.IATA_ISO_Country__c != null) {

                // Update right collections with current scope
                updateLfcTimeframesByAccount(account.Id, account.IATA_ISO_Country__c, account.Location_Class__c);
                updateIrregularityTypeExceptionsByAccount(account.Id, account.IATA_ISO_Country__c, account.Location_Class__c);
                if(account.AMS_PWC_INT_OWNSHA_LASTDATE__c != null) this.currentOwnShaLastdate.put(account.Id, account.AMS_PWC_INT_OWNSHA_LASTDATE__c);

            }

        }

        // Get agency applied change codes
        List<Agency_Applied_Change_code__c> agencyAppliedChangeCodes = [
            SELECT Id, Change_Code__c, Created_Date_To_Show__c, Account__c, DEF_Non_Payment2__c, Operation__c, Irregularities_Points__c, Account__r.Location_class__c, Irregularity_Type__c
            FROM Agency_Applied_Change_code__c
            WHERE Account__c IN :accountIds];

        // For all changes
        for(Agency_Applied_Change_code__c agencyAppliedChangeCode : agencyAppliedChangeCodes) {

            // Current date time
            DateTime currentDate = DateTime.now();

            // Get the type of calculation that must be operated there
            Integer calculationType = checkCalculationType(agencyAppliedChangeCode.Change_Code__c, agencyAppliedChangeCode.Account__c);

            // And make the right calculation
            if(calculationType == 1) {

                // For DEF : Only if this entry is in the right DEF timeframe
                if(currentDate < agencyAppliedChangeCode.Created_Date_To_Show__c.addMonths(defDefaultTimeframe)) {

                    // Positive (DEF) and negative (DWD)
                    if(agencyAppliedChangeCode.Change_Code__c.equals('DEF')) {
                        updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'DEF', 1, null);
                    } else if(agencyAppliedChangeCode.Change_Code__c.equals('DWD')) {
                        updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'DWD', 1, null);
                    }

                }

                // For DEFNONPAY, only if this entry is in the right DEFNONPAY timeframe
                if((agencyAppliedChangeCode.Change_Code__c.equals('DEF') && agencyAppliedChangeCode.DEF_Non_Payment2__c == true) && (currentDate < agencyAppliedChangeCode.Created_Date_To_Show__c.addMonths(defNonPayDefaultTimeframe))) {
                    updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'DEFNONPAY', 1, null);
                }

            } else if(calculationType == 2) {

                // Retrieve this collection
                List<AMS_Country_Specific_Attribute__c> countrySpecificAttributes = this.lfcTimeframesByAccount.get(agencyAppliedChangeCode.Account__c);

                // Set the default timeframe in case there's no matching
                Integer lfcTimeDefToUse = defDefaultTimeframe;

                // For each attribute
                for(AMS_Country_Specific_Attribute__c countrySpecificAttribute : countrySpecificAttributes) {

                    // If there's matching with record type (DEF) & location class
                    if(countrySpecificAttribute.RecordTypeId == recordTypeDefLfcId && countrySpecificAttribute.Location_Class__c == agencyAppliedChangeCode.Account__r.Location_Class__c) {

                        // Update lifeframe variable
                        lfcTimeDefToUse = countrySpecificAttribute.Months_Count__c.intValue();

                    }

                }

                // Only if this entry is in the right timeframe
                if(currentDate < agencyAppliedChangeCode.Created_Date_To_Show__c.addMonths(lfcTimeDefToUse)) {

                    // All managed types
                    if(agencyAppliedChangeCode.Change_Code__c.equals('DEF')) {
                        updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'DEF', 1, null);
                    } else if(agencyAppliedChangeCode.Change_Code__c.equals('DWD')) {
                        updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'DWD', 1, null);
                    }

                }

            } else if(calculationType == 3) {

                // Only if this entry is in the right IRRS timeframe
                if(currentDate < agencyAppliedChangeCode.Created_Date_To_Show__c.addMonths(irrsDefaultTimeframe)) {

                    // To prevent a null pointer exception
                    if(agencyAppliedChangeCode.Irregularities_Points__c != null) {

                        // Positive and negative
                        if((agencyAppliedChangeCode.Change_Code__c == 'IRR' && (agencyAppliedChangeCode.Operation__c == 'A' || agencyAppliedChangeCode.Operation__c == '' || agencyAppliedChangeCode.Operation__c == null)) || (agencyAppliedChangeCode.Change_Code__c == 'IRS')) {
                            updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'IRRS_POS', agencyAppliedChangeCode.Irregularities_Points__c.intValue(), null);
                        } else if((agencyAppliedChangeCode.Change_Code__c == 'IRR' && (agencyAppliedChangeCode.Operation__c == 'W' || agencyAppliedChangeCode.Operation__c == 'D')) || (agencyAppliedChangeCode.Change_Code__c == 'IRW')) {
                            updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'IRRS_NEG', agencyAppliedChangeCode.Irregularities_Points__c.intValue(), null);
                        }

                    }

                }

            } else if(calculationType == 4 || calculationType == 5 || calculationType == 6) {

                // Will be defined by change code type
                Integer lfcTimeIrrsToUse;

                // If there's LFC for that change code
                if(calculationType == 4 || calculationType == 6) {

                    // Retrieve this collection
                    List<AMS_Country_Specific_Attribute__c> countrySpecificAttributes = this.lfcTimeframesByAccount.get(agencyAppliedChangeCode.Account__c);

                    // Set the default timeframe in case there's no matching
                    lfcTimeIrrsToUse = irrsDefaultTimeframe;

                    // For each attribute
                    for(AMS_Country_Specific_Attribute__c countrySpecificAttribute : countrySpecificAttributes) {

                        // If there's matching with record type (IRRS) & location class
                        if(countrySpecificAttribute.RecordTypeId == recordTypeIrrsLfcId && countrySpecificAttribute.Location_Class__c == agencyAppliedChangeCode.Account__r.Location_Class__c) {

                            // Update lifeframe variable
                            lfcTimeIrrsToUse = countrySpecificAttribute.Months_Count__c.intValue();

                        }

                    }

                } else {

                    // Change code 5, so default IRRS timeframe
                    lfcTimeIrrsToUse = irrsDefaultTimeframe;

                }

                // Only if this entry is in the right timeframe
                if(currentDate < agencyAppliedChangeCode.Created_Date_To_Show__c.addMonths(lfcTimeIrrsToUse)) {

                    // To prevent a null pointer exception
                    if(agencyAppliedChangeCode.Irregularities_Points__c != null) {

                        // If this a country without exception
                        if(!this.irregularityTypeExceptionsByAccount.containsKey(agencyAppliedChangeCode.Account__c)) {

                            // Positive and negative
                            if((agencyAppliedChangeCode.Change_Code__c == 'IRR' && (agencyAppliedChangeCode.Operation__c == 'A' || agencyAppliedChangeCode.Operation__c == '' || agencyAppliedChangeCode.Operation__c == null)) || (agencyAppliedChangeCode.Change_Code__c == 'IRS')) {
                                updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'IRRS_POS', agencyAppliedChangeCode.Irregularities_Points__c.intValue(), null);
                            } else if((agencyAppliedChangeCode.Change_Code__c == 'IRR' && (agencyAppliedChangeCode.Operation__c == 'W' || agencyAppliedChangeCode.Operation__c == 'D')) || (agencyAppliedChangeCode.Change_Code__c == 'IRW')) {
                                updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'IRRS_NEG', agencyAppliedChangeCode.Irregularities_Points__c.intValue(), null);
                            }

                        } else {

                            // Get all irregularityTypeExceptions for this account
                            List<AMS_Country_Specific_Attribute__c> irregularityTypeExceptions = this.irregularityTypeExceptionsByAccount.get(agencyAppliedChangeCode.Account__c);

                            // Create a variable to validate the whole collection
                            Boolean validAgencyAppliedChangeCode = true;

                            // For each element
                            for(AMS_Country_Specific_Attribute__c irregularityTypeException : irregularityTypeExceptions) {

                                // Check matching on location class & irregularity type
                                if(irregularityTypeException.Location_Class__c != agencyAppliedChangeCode.Account__r.Location_Class__c || irregularityTypeException.Irregularity_Type__c != agencyAppliedChangeCode.Irregularity_Type__c) {

                                    // Update linked variable
                                    validAgencyAppliedChangeCode = false;

                                }

                            }

                            // Check if this entry must take in account
                            if(validAgencyAppliedChangeCode == true) {

                                // Positive and negative
                                if((agencyAppliedChangeCode.Change_Code__c == 'IRR' && (agencyAppliedChangeCode.Operation__c == 'A' || agencyAppliedChangeCode.Operation__c == '' || agencyAppliedChangeCode.Operation__c == null)) || (agencyAppliedChangeCode.Change_Code__c == 'IRS')) {
                                    updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'IRRS_POS', agencyAppliedChangeCode.Irregularities_Points__c.intValue(), null);
                                } else if((agencyAppliedChangeCode.Change_Code__c == 'IRR' && (agencyAppliedChangeCode.Operation__c == 'W' || agencyAppliedChangeCode.Operation__c == 'D')) || (agencyAppliedChangeCode.Change_Code__c == 'IRW')) {
                                    updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'IRRS_NEG', agencyAppliedChangeCode.Irregularities_Points__c.intValue(), null);
                                }

                            }

                        }

                    }

                }

            } else { // calculationType = 7

                // Only if this entry is in the right own/share timeframe
                if(currentDate < agencyAppliedChangeCode.Created_Date_To_Show__c.addMonths(ownShaDefaultTimeframe)) {

                    // Variables to check if there's a matching
                    Boolean ownshaChangeUpdate = false;
                    Boolean ownshaLastDateUpdate = false;

                    // For each possible code - own/share change
                    for(String ownShaChangeCode : ownShaChangeCodes) {

                        // If matching, update our variable
                        if(agencyAppliedChangeCode.Change_Code__c.equals(ownShaChangeCode)) {
                            ownshaChangeUpdate = true;
                        }

                    }

                    // For each possible code - own/share last date
                    for(String ownShaLastDateCode : ownShaLastDateCodes) {

                        // If matching, update our variable
                        if(agencyAppliedChangeCode.Change_Code__c.equals(ownShaLastDateCode)) {
                            ownshaLastDateUpdate = true;
                        }

                    }

                    // Tag this account for update - own/share change
                    if(ownshaChangeUpdate == true) {
                        updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'OWNSHA_CHANGE', 0, null);
                    }

                    // Tag this account for update - own/share last date
                    if(ownshaLastDateUpdate == true) {

                        // If there's already a date for that account before the batch
                        if(currentOwnShaLastdate.containsKey(agencyAppliedChangeCode.Account__c)) {

                            // Retrieve that date
                            DateTime ownShaLastdateBat = currentOwnShaLastdate.get(agencyAppliedChangeCode.Account__c);

                            // If there's already a date for that account in that chunk
                            if(aggregatePwcDataByAgency.containsKey(agencyAppliedChangeCode.Account__c)) {

                                // Retrieve that date
                                DateTime ownShaLastdateChu = aggregatePwcDataByAgency.get(agencyAppliedChangeCode.Account__c).getOwnShaLastDate();

                                // If this date is not null
                                if(ownShaLastdateChu != null) {

                                    // If our date is "bigger" than current one
                                    if (agencyAppliedChangeCode.Created_Date_To_Show__c > ownShaLastdateChu) {

                                        // And if this date is "bigger", update our collection
                                        if (ownShaLastdateBat < agencyAppliedChangeCode.Created_Date_To_Show__c) {
                                            updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'OWNSHA_LASTDATE', 0, agencyAppliedChangeCode.Created_Date_To_Show__c);
                                        }

                                    }

                                } else {

                                    // Update our collection
                                    updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'OWNSHA_LASTDATE', 0, agencyAppliedChangeCode.Created_Date_To_Show__c);

                                }

                            } else {

                                // If this date is "bigger", update our collection
                                if(ownShaLastdateBat < agencyAppliedChangeCode.Created_Date_To_Show__c) {
                                    updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'OWNSHA_LASTDATE', 0, agencyAppliedChangeCode.Created_Date_To_Show__c);
                                }

                            }

                        } else {

                            // If there's already a date for that account in that chunk
                            if(aggregatePwcDataByAgency.containsKey(agencyAppliedChangeCode.Account__c)) {

                                // Retrieve that date
                                DateTime ownShaLastdateChu = aggregatePwcDataByAgency.get(agencyAppliedChangeCode.Account__c).getOwnShaLastDate();

                                // If this date is not null
                                if(ownShaLastdateChu != null) {

                                    // If our date is "bigger" than current one
                                    if(agencyAppliedChangeCode.Created_Date_To_Show__c > ownShaLastdateChu) {

                                        // Update our collection
                                        updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'OWNSHA_LASTDATE', 0, agencyAppliedChangeCode.Created_Date_To_Show__c);

                                    }

                                } else {

                                    // Otherwise, update our collection
                                    updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'OWNSHA_LASTDATE', 0, agencyAppliedChangeCode.Created_Date_To_Show__c);

                                }

                            } else {

                                // Otherwise, update our collection
                                updateAggregatePwcData(agencyAppliedChangeCode.Account__c, 'OWNSHA_LASTDATE', 0, agencyAppliedChangeCode.Created_Date_To_Show__c);

                            }

                        }

                    }

                }

            }

        }

        // In our new collection
        for(Id accountId : aggregatePwcDataByAgency.keySet()) {

            // Get current element
            AMS_AggregatePwcData aggregatePwcData = aggregatePwcDataByAgency.get(accountId);

            // Create a new Account object with right ID
            Account account = new Account(Id = accountId);

            // Update DEF, DEFNONPAY, IRRS, OWNSHACHANGE & OWNSHALASTDATE results
            account.AMS_PWC_INT_DEF__c = aggregatePwcData.getDefCount() - aggregatePwcData.getDwdCount();
            account.AMS_PWC_INT_DEFNONPAY__c = aggregatePwcData.getDefNonPaymentCount();
            account.AMS_PWC_INT_IRRS__c = aggregatePwcData.getIrrsPositiveCount() - aggregatePwcData.getIrrsNegativeCount();
            if(aggregatePwcData.getOwnShaChange() == true) account.AMS_PWC_INT_OWNSHA_CHANGE__c = 'Y';
            if(aggregatePwcData.getOwnShaLastDate() != null) account.AMS_PWC_INT_OWNSHA_LASTDATE__c = aggregatePwcData.getOwnShaLastDate();

            // And add this element in the collection for update
            this.accountsToUpdate.add(account);

        }

        // Loop in current scope of accounts
        for(Id accountId : accountIds) {

            // Check if this element is not on our collection and update linked set if so
            if(!aggregatePwcDataByAgency.keySet().contains(accountId)) this.accountWithoutUpdateIds.add(accountId);

        }

        // For all other accounts
        for(Id accountWithoutUpdateId : this.accountWithoutUpdateIds) {

            // Create a new Account object with right ID
            Account account = new Account(Id = accountWithoutUpdateId);

            // Update DEF, DEFNONPAY & IRRS result with 0 value
            account.AMS_PWC_INT_DEF__c = 0;
            account.AMS_PWC_INT_DEFNONPAY__c = 0;
            account.AMS_PWC_INT_IRRS__c = 0;

            // And add this element in the collection for update
            this.accountsToUpdate.add(account);

        }

        // Update all linked records
        if(!this.accountsToUpdate.isEmpty()) {
            update this.accountsToUpdate;
        }

    }

    /**
     * Update lfcTimeframesByAccount collection
     */
    private void updateLfcTimeframesByAccount(Id accountId, Id isoCountryId, String locationClass) {

        // Try to retrieve right record
        List<AMS_Country_Specific_Attribute__c> countrySpecificAttribute = [
            SELECT Id, Location_Class__c, Months_Count__c, RecordTypeId
            FROM AMS_Country_Specific_Attribute__c
            WHERE IATA_ISO_Country__c = :isoCountryId
            AND Location_Class__c = :locationClass
            AND (RecordTypeId = :recordTypeDefLfcId
            OR  RecordTypeId = :recordTypeIrrsLfcId)
            LIMIT 1];

        // If there's a record
        if(!countrySpecificAttribute.isEmpty()) {

            // If there's already an/some entry/entries for that account ID
            if (this.lfcTimeframesByAccount.containsKey(accountId)) {

                // Retrieve linked collection
                List<AMS_Country_Specific_Attribute__c> currentCountrySpecificAttributes = this.lfcTimeframesByAccount.get(accountId);

                // Update it with this new element
                AMS_Country_Specific_Attribute__c newcurrentCountrySpecificAttribute = countrySpecificAttribute.get(0);
                currentCountrySpecificAttributes.add(newcurrentCountrySpecificAttribute);

                // Update lfcTimeframesByAccount with all elements
                this.lfcTimeframesByAccount.remove(accountId);
                this.lfcTimeframesByAccount.put(accountId, currentCountrySpecificAttributes);

            } else {

                // Update lfcTimeframesByAccount with this single element
                List<AMS_Country_Specific_Attribute__c> countrySpecificAttributes = new List<AMS_Country_Specific_Attribute__c>();
                AMS_Country_Specific_Attribute__c newcurrentCountrySpecificAttribute = countrySpecificAttribute.get(0);
                countrySpecificAttributes.add(newcurrentCountrySpecificAttribute);
                this.lfcTimeframesByAccount.put(accountId, countrySpecificAttributes);

            }

        }

    }

    /**
     *  Update irregularityTypeExceptionsByAccount collection
     */
    private void updateIrregularityTypeExceptionsByAccount(Id accountId, Id isoCountryId, String locationClass) {

        // Try to retrieve right record
        List<AMS_Country_Specific_Attribute__c> countrySpecificAttribute = [
            SELECT Id, Location_Class__c, Irregularity_Type__c
            FROM AMS_Country_Specific_Attribute__c
            WHERE IATA_ISO_Country__c = :isoCountryId
            AND Location_Class__c = :locationClass
            AND (RecordTypeId = :recordTypeIrrCpeId)
            LIMIT 1];

        // If there's a record
        if(!countrySpecificAttribute.isEmpty()) {

            // If there's already an/some entry/entries for that account ID
            if(this.irregularityTypeExceptionsByAccount.containsKey(accountId)) {

                // Retrieve linked collection
                List<AMS_Country_Specific_Attribute__c> currentCountrySpecificAttributes = this.irregularityTypeExceptionsByAccount.get(accountId);

                // Update it with this new element
                AMS_Country_Specific_Attribute__c newcurrentCountrySpecificAttribute = countrySpecificAttribute.get(0);
                currentCountrySpecificAttributes.add(newcurrentCountrySpecificAttribute);

                // Update irregularityTypeExceptionsByAccount with all elements
                this.irregularityTypeExceptionsByAccount.remove(accountId);
                this.irregularityTypeExceptionsByAccount.put(accountId, currentCountrySpecificAttributes);

            } else {

                // Update irregularityTypeExceptionsByAccount with this single element
                List<AMS_Country_Specific_Attribute__c> countrySpecificAttributes = new List<AMS_Country_Specific_Attribute__c>();
                AMS_Country_Specific_Attribute__c newcurrentCountrySpecificAttribute = countrySpecificAttribute.get(0);
                countrySpecificAttributes.add(newcurrentCountrySpecificAttribute);
                this.irregularityTypeExceptionsByAccount.put(accountId, countrySpecificAttributes);

            }

        }

    }

    /**
     * Check what operation should be executed. This method return one of those values :
     * - 1 = DEF default
     * - 2 = DEF with LFC
     * - 3 = IRRS default
     * - 4 = IRRS with LFC only
     * - 5 = IRRS with CPE only
     * - 6 = IRRS with LFC and irregularity exception
     * - 7 = All other that can be only own/share change & own/share last date (will be tested anyway)
     */
    private Integer checkCalculationType(String changeCode, Id accountId) {

        // Default is own/share change & own/share last date
        Integer changeCodeType = 7;

        // Check if this code can impacted by LFC or an irregularity exception
        if((changeCode.equals('DEF') || changeCode.equals('DWD')) || (changeCode.equals('IRR') || changeCode.equals('IRS') || changeCode.equals('IRW'))) {

            // If this for DEF calculation
            if(changeCode.equals('DEF') || changeCode.equals('DWD')) {

                // In this case, should be default timeframe
                if(!this.lfcTimeframesByAccount.containsKey(accountId)) {
                    changeCodeType = 1;
                } else {
                    changeCodeType = 2;
                }

            } else { // And for IRRS calculation

                // In this case, should be default timeframe
                if(!this.lfcTimeframesByAccount.containsKey(accountId)) {

                    // And it that case, no irregularity exception
                    if(!this.irregularityTypeExceptionsByAccount.containsKey(accountId)) {
                        changeCodeType = 3;
                    } else {
                        changeCodeType = 5;
                    }

                } else if(!this.irregularityTypeExceptionsByAccount.containsKey(accountId)) {
                    changeCodeType = 4;
                } else {
                    changeCodeType = 6;
                }

            }

        }

        // And return change code type
        return changeCodeType;

    }

    /**
     * Update aggregatePwcDataByAgency collection with customised aggregate data
     */
    private void updateAggregatePwcData(Id accountId, String changeCode, Integer points, DateTime createdDateToShow) {

        // Check if this account already exists
        if(this.aggregatePwcDataByAgency.containsKey(accountId)) {

            // So, retrieve it
            AMS_AggregatePwcData aggregatePwcData = this.aggregatePwcDataByAgency.get(accountId);

            // Update right attribute
            if(changeCode.equals('DEF')) {
                aggregatePwcData.setDefCount(aggregatePwcData.getDefCount() + points);
            } else if(changeCode.equals('DWD')) {
                aggregatePwcData.setDwdCount(aggregatePwcData.getDwdCount() + points);
            } else if(changeCode.equals('DEFNONPAY')) {
                aggregatePwcData.setDefNonPaymentCount(aggregatePwcData.getDefNonPaymentCount() + points);
            } else if(changeCode.equals('IRRS_POS')) {
                aggregatePwcData.setIrrsPositiveCount(aggregatePwcData.getIrrsPositiveCount() + points);
            } else if(changeCode.equals('IRRS_NEG')) {
                aggregatePwcData.setIrrsNegativeCount(aggregatePwcData.getIrrsNegativeCount() + points);
            } else if(changeCode.equals('OWNSHA_CHANGE')) {
                aggregatePwcData.setOwnshaChange(true);
            } else if(changeCode.equals('OWNSHA_LASTDATE')) {
                aggregatePwcData.setOwnShaLastDate(createdDateToShow);
            }

            // And update this element in our collection
            this.aggregatePwcDataByAgency.remove(accountId);
            this.aggregatePwcDataByAgency.put(accountId, aggregatePwcData);

        } else {

            // Otherwise, create it
            AMS_AggregatePwcData aggregatePwcData = new AMS_AggregatePwcData();

            // Update right attribute
            if(changeCode.equals('DEF')) {
                aggregatePwcData.setDefCount(aggregatePwcData.getDefCount() + points);
            } else if(changeCode.equals('DWD')) {
                aggregatePwcData.setDwdCount(aggregatePwcData.getDwdCount() + points);
            } else if(changeCode.equals('DEFNONPAY')) {
                aggregatePwcData.setDefNonPaymentCount(aggregatePwcData.getDefNonPaymentCount() + points);
            } else if(changeCode.equals('IRRS_POS')) {
                aggregatePwcData.setIrrsPositiveCount(aggregatePwcData.getIrrsPositiveCount() + points);
            } else if(changeCode.equals('IRRS_NEG')) {
                aggregatePwcData.setIrrsNegativeCount(aggregatePwcData.getIrrsNegativeCount() + points);
            } else if(changeCode.equals('OWNSHA_CHANGE')) {
                aggregatePwcData.setOwnshaChange(true);
            } else if(changeCode.equals('OWNSHA_LASTDATE')) {
                aggregatePwcData.setOwnShaLastDate(createdDateToShow);
            }

            // And add this element in our collection
            this.aggregatePwcDataByAgency.put(accountId, aggregatePwcData);

        }

    }

}