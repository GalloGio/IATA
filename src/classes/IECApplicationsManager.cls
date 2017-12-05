/*
 * IECApplicationsManager 
 * Change log:
 *  20160324-sl: change getListProductAccessByContactByProductCategory/getListProductAccessByContactBySubscriptionNumber to use getSubscriptionEvergreenNameListByBillingContactId
 *  20160531-sl: createProductAccessOnNewSubscription() will not create IEC_Product_Access record for ProductCategory_SF_EBROADCAST; add isEbcAccessGrantedForContact
 *  20160617-sl: createProductAccessOnNewSubscription() will always create IEC_Product_Access record regardless ProductCategory
 *  20160803-sl: merge the version from ebroadcast development to new repository (20160728).
 *
 */
public without sharing class IECApplicationsManager {
    public static List<Id> cachedAgencyIds;
    
    /**
     * Returns true if the provided agency is valid (status >= 4)
     * @param IATACode The IATA code of the agency
     * @return True if the agency is valid, false if the agency is invalid or not found
     */
    public static Boolean isAgencyActive(String IATACode) {
        
        if (String.isBlank(IATACode)) return false;
        
        IATACode = IATACode.trim();
        
        // active agencies have a status code >= 4
        List<GDP_Products_Account_View__c> agencylist = [SELECT Name 
                                    FROM GDP_Products_Account_View__c 
                                    WHERE (IATA_Code__c = :IATACode or Agency_Code__c =: IATACode)
                                        AND Agency_Status_Code__c >= 4 limit 1];

        return (agencyList != null && agencyList.size() > 0);
    }
    
    /**
     * Search for an ID Card matching an agent VER code
     * @param verCode The agent's VER code
     * @return If agent and associated agency is valid: an ID Card
     *         If agent existed but is no longer valid (or agency): an ID Card with an empty status
     *         If agent not found: null
     */ 
    private static ID_Card__c getAgentByVerCode(String verCode) {

        if (String.isBlank(verCode)) return null;
        
        verCode = verCode.trim();
        
        List<ID_Card__c> lstAgent;
        Boolean bValid = false;
    
        // query id card based on VER
        lstAgent = [SELECT Name_on_ID_Card__c, Type_of_ID_Card__c, Valid_To_Date__c, Agency_IATA_Code__c, Agency_Name__c, Card_Status__c, Is_Active_Card__c, Blacklisted__c
                    FROM ID_Card__c 
                    WHERE VER_Number__c = :verCode and Is_Active_Card__c = true and Blacklisted__c = false order by Valid_To_Date__c desc limit 1 ];
            
        if (lstAgent != null && lstAgent.size() > 0) {
            
            ID_Card__c idCard = lstAgent[0];

            // check the ID Card agains the following business rules:
            // - status must be Approved or Printed/Delivered or Valid ID Card or Sent ID Card
            // - must be active
            // - must not be expired
            // - must not be blacklisted
            
            if ((idCard.Card_Status__c == IECConstants.ID_Card_Status_Approved || 
                    idCard.Card_Status__c == IECConstants.ID_Card_Status_PrintedDelivered || 
                    idCard.Card_Status__c == IECConstants.ID_Card_Status_Valid_ID_Card ||
                    idCard.Card_Status__c == IECConstants.ID_Card_Status_Sent_ID_Card ) 
                && idCard.Is_Active_Card__c
                && idCard.Valid_To_Date__c >= Date.today()
                && !idCard.Blacklisted__c ) {
                    
                bValid = isAgencyActive(idCard.Agency_IATA_Code__c);
            }
                
            // if agent and agency are valid
            if (bValid) 
                return idCard;
            // agent or agency are not valid
            else 
                return new ID_Card__c(Card_Status__c = '');
        }
    
        return null;
    }
    
    
    private static List<GDP_Products_Account_View__c> getAgencyByIATACode(String IATACode, String CASSCode) {
        
        if (String.isBlank(IATACode)) return null;
         IATACode = IATACode.trim();
        

        List<GDP_Products_Account_View__c> lstAgency;

        String CACCodesStr = CAC_and_GAD_Settings__c.getInstance('Excluded Values').Excluded_CAC_Location_Classes__c;
        List<String> CACCodesList = CACCodesStr.split(';');
        
        if (CASSCode == null || CASSCode == '') {
            lstAgency = 
                [SELECT g.Name, g.Trading_Name__c, g.Legal_Name__c, g.Last_Date_of_Update__c, g.Agency_Code__c,
                    g.Related_Accreditation_Class__r.Status__r.Name, g.Related_Accreditation_Class__r.Status__r.Definition__c, g.Related_Accreditation_Class__r.Status__r.Code__c, g.Related_Accreditation_Class__r.Class__r.Name , g.Related_Accreditation_Class__r.Class__r.Definition__c, 
                    g.Incorporation_Type__r.Name, g.Incorporation_Type__r.Definition__c, 
                    g.Location_Type__r.Name, g.Location_Type__r.Definition__c, g.Related_Main_Phone__r.Number__c, g.Related_Main_Phone__r.Name, g.Related_Accreditation_Class__r.Date__c,
                    g.Related_GDP_Address__r.Address_ISO_Country_Code__c, g.Related_GDP_Address__r.Address_Line_1__c, g.Related_GDP_Address__r.Address_Line_2__c, g.Related_GDP_Address__r.Address_State_Name__c, g.Related_GDP_Address__r.Address_Postal_Code__c, 
                    g.Related_GDP_Address__r.Address_City__c, g.Related_GDP_Address__r.Address_Country_Name__c, g.Related_Accreditation_Class__r.Status__c
                FROM GDP_Products_Account_View__c g
                WHERE g.IATA_Code__c = :IATACode
                    AND Related_Accreditation_Class__r.Class__r.Code__c NOT IN :CACCodesList limit 2];
        }
        else {
            CASSCode = CASSCode.trim();
            
            lstAgency = 
                [SELECT g.Name, g.Trading_Name__c, g.Legal_Name__c, g.Last_Date_of_Update__c, g.Agency_Code__c,
                    g.Related_Accreditation_Class__r.Status__r.Name, g.Related_Accreditation_Class__r.Status__r.Definition__c, g.Related_Accreditation_Class__r.Status__r.Code__c,  g.Related_Accreditation_Class__r.Class__r.Name , g.Related_Accreditation_Class__r.Class__r.Definition__c,
                    g.Incorporation_Type__r.Name, g.Incorporation_Type__r.Definition__c, 
                    g.Location_Type__r.Name, g.Location_Type__r.Definition__c, g.Related_Main_Phone__r.Number__c, g.Related_Main_Phone__r.Name, g.Related_Accreditation_Class__r.Date__c,
                    g.Related_GDP_Address__r.Address_ISO_Country_Code__c, g.Related_GDP_Address__r.Address_Line_1__c, g.Related_GDP_Address__r.Address_Line_2__c, g.Related_GDP_Address__r.Address_State_Name__c, g.Related_GDP_Address__r.Address_Postal_Code__c, 
                    g.Related_GDP_Address__r.Address_City__c, g.Related_GDP_Address__r.Address_Country_Name__c
                FROM GDP_Products_Account_View__c g
                WHERE g.IATA_Code__c = :IATACode AND g.CASS_Number__c = : CASSCode
                    AND Related_Accreditation_Class__r.Class__r.Code__c NOT IN :CACCodesList limit 2];
        }

        return (!lstAgency.isEmpty()) ? lstAgency : null;
    }
    
    /**
     * Returns an agency by its ID
     * @param sAgencyID The Agency ID
     * @return A GDP_Products_Account_View__c object
     */
    public static GDP_Products_Account_View__c getAgencyByID(String sAgencyID) {
        return [SELECT IATA_Code__c, Name, Trading_Name__c, Legal_Name__c, Last_Date_of_Update__c, Agency_Code__c,
                    Related_Accreditation_Class__r.Status__r.Name, Related_Accreditation_Class__r.Status__r.Definition__c, Related_Accreditation_Class__r.Status__r.Code__c, Country_Name__c,
                    Incorporation_Type__r.Name, Incorporation_Type__r.Definition__c, Sub_Continent__c, City__c,
                    Location_Type__r.Name, Location_Type__r.Definition__c, State_Province__c, Location_Address__c,
                    Location_Type__r.Code__c, Related_Accreditation_Class__c, 
                    Related_Accreditation_Class__r.Class__r.Definition__c, Related_Accreditation_Class__r.Date__c,
                    Zip_Postal_Code__c, Parent_GDP_Account_View__c, Email_Address__c, Country_ISO_Code__c,
                    Related_Accreditation_Class__r.Class__r.Name, Related_Main_Phone__r.Name, Related_Main_Phone__r.Number__c,
                    Related_GDP_Address__r.Address_ISO_Country_Code__c, Related_GDP_Address__r.Address_Line_1__c, Related_GDP_Address__r.Address_Line_2__c, Related_GDP_Address__r.Address_State_Name__c, Related_GDP_Address__r.Address_Postal_Code__c, 
                    Related_GDP_Address__r.Address_City__c, Related_GDP_Address__r.Address_Country_Name__c
                FROM GDP_Products_Account_View__c
                WHERE Id = :sAgencyID limit 1];
    }
    
    private static List<GDP_Products_Account_View__c> getAgencyByAgencyCode(String agencyCode, String checkCode, String CASSCode) {
        
        if (String.isBlank(agencyCode)) return null;
         agencyCode = agencyCode.trim();
        
        List<GDP_Products_Account_View__c> lstAgency;

        String CACCodesStr = CAC_and_GAD_Settings__c.getInstance('Excluded Values').Excluded_CAC_Location_Classes__c;
        List<String> CACCodesList = CACCodesStr.split(';');
        
        system.debug('** - getAgencyByAgencyCode: agencyCode = ' + agencyCode + ', checkCode = ' + checkCode + ', CASSCode = ' + CASSCode);
        
        if (checkCode != null && checkCode != '') {
            checkCode = checkCode.trim();
            
            if (CASSCode == null || CASSCode == '') {
                //No CASS Code --> Query for IATA + Check codes
                lstAgency = 
                    [SELECT g.Name, g.Trading_Name__c, g.Legal_Name__c, g.Last_Date_of_Update__c, g.Agency_Code__c,
                        g.Related_Accreditation_Class__r.Status__r.Name, g.Related_Accreditation_Class__r.Status__r.Definition__c, g.Related_Accreditation_Class__r.Status__r.Code__c,  g.Related_Accreditation_Class__r.Class__r.Name , g.Related_Accreditation_Class__r.Class__r.Definition__c,
                        g.Incorporation_Type__r.Name, g.Incorporation_Type__r.Definition__c, 
                        g.Location_Type__r.Name, g.Location_Type__r.Definition__c, g.Related_Main_Phone__r.Number__c, g.Related_Main_Phone__r.Name, g.Related_Accreditation_Class__r.Date__c,
                        g.Related_GDP_Address__r.Address_ISO_Country_Code__c, g.Related_GDP_Address__r.Address_Line_1__c, g.Related_GDP_Address__r.Address_Line_2__c, g.Related_GDP_Address__r.Address_State_Name__c, g.Related_GDP_Address__r.Address_Postal_Code__c, 
                        g.Related_GDP_Address__r.Address_City__c, g.Related_GDP_Address__r.Address_Country_Name__c
                    FROM GDP_Products_Account_View__c g
                    WHERE g.IATA_Code__c = :agencyCode and g.Check_Digit__c = :checkCode
                        AND Related_Accreditation_Class__r.Class__r.Code__c NOT IN :CACCodesList limit 2];

            }
            else {
                
                //Query for IATA + Check + CASS codes
                //String searchCode = agencyCode + checkCode + CASSCode;
                //R.A. Jan 6 2015 modify based on formula field 
                CASSCode = CASSCode.trim();                
                String searchCode = agencyCode  + CASSCode + checkCode;
                
                lstAgency = 
                    [SELECT g.Name, g.Trading_Name__c, g.Legal_Name__c, g.Last_Date_of_Update__c, g.Agency_Code__c,
                        g.Related_Accreditation_Class__r.Status__r.Name, g.Related_Accreditation_Class__r.Status__r.Definition__c, g.Related_Accreditation_Class__r.Status__r.Code__c,  g.Related_Accreditation_Class__r.Class__r.Name , g.Related_Accreditation_Class__r.Class__r.Definition__c,
                        g.Incorporation_Type__r.Name, g.Incorporation_Type__r.Definition__c, 
                        g.Location_Type__r.Name, g.Location_Type__r.Definition__c, g.Related_Main_Phone__r.Number__c, g.Related_Main_Phone__r.Name, g.Related_Accreditation_Class__r.Date__c,
                        g.Related_GDP_Address__r.Address_ISO_Country_Code__c, g.Related_GDP_Address__r.Address_Line_1__c, g.Related_GDP_Address__r.Address_Line_2__c, g.Related_GDP_Address__r.Address_State_Name__c, g.Related_GDP_Address__r.Address_Postal_Code__c, 
                        g.Related_GDP_Address__r.Address_City__c, g.Related_GDP_Address__r.Address_Country_Name__c
                    FROM GDP_Products_Account_View__c g
                    WHERE g.Agency_Code__c = : searchCode
                        AND Related_Accreditation_Class__r.Class__r.Code__c NOT IN :CACCodesList limit 2];


            }
            
        }
        else {
            //Query for Agency Code
            lstAgency = 
                [SELECT g.Name, g.Trading_Name__c, g.Legal_Name__c, g.Last_Date_of_Update__c, g.Agency_Code__c,
                    g.Related_Accreditation_Class__r.Status__r.Name, g.Related_Accreditation_Class__r.Status__r.Definition__c, g.Related_Accreditation_Class__r.Status__r.Code__c,  g.Related_Accreditation_Class__r.Class__r.Name , g.Related_Accreditation_Class__r.Class__r.Definition__c,
                    g.Incorporation_Type__r.Name, g.Incorporation_Type__r.Definition__c, 
                    g.Location_Type__r.Name, g.Location_Type__r.Definition__c, g.Related_Main_Phone__r.Number__c, g.Related_Main_Phone__r.Name, g.Related_Accreditation_Class__r.Date__c,
                    g.Related_GDP_Address__r.Address_ISO_Country_Code__c, g.Related_GDP_Address__r.Address_Line_1__c, g.Related_GDP_Address__r.Address_Line_2__c, g.Related_GDP_Address__r.Address_State_Name__c, g.Related_GDP_Address__r.Address_Postal_Code__c, 
                    g.Related_GDP_Address__r.Address_City__c, g.Related_GDP_Address__r.Address_Country_Name__c
                FROM GDP_Products_Account_View__c g
                WHERE g.Agency_Code__c = :agencyCode
                    AND Related_Accreditation_Class__r.Class__r.Code__c NOT IN :CACCodesList limit 2];

        }
                
        return (!lstAgency.isEmpty()) ? lstAgency : null;
    }
    
    /**
     * Advance search for agencies based on a series of filters
     * @param oAdvancedFilters A IEC_Application_Filter__c object containing the filters
     * @return A list of GDP_Products_Account_View__c objects
     */
    private static List<GDP_Products_Account_View__c> getAgencyByAdvancedFilters(IEC_Application_Filter__c oAdvancedFilters, String sProductCategoryCode) {
        return getAgencyByAdvancedFilters(oAdvancedFilters, sProductCategoryCode, true);
    }
    
    private static List<GDP_Products_Account_View__c> getAgencyByAdvancedFilters(IEC_Application_Filter__c oAdvancedFilters, String sProductCategoryCode, Boolean bReturnAllFields) {


        String sQueryFields;
        
        if(bReturnAllFields)
             sQueryFields = 'SELECT Account_View__c, Account_View__r.Id, Account_View__r.Agency_Code__c, Account_View__r.Agency_Status__c, Account_View__r.IATA_Code__c, Account_View__r.Name, Account_View__r.Agency_Status_Code__c, Account_View__r.Airline_Code__c, Account_View__r.BSP_CASS_Code__c, Account_View__r.CASS_Number__c, Account_View__r.Email_Address__c'
                                + ', Account_View__r.Incorporation_Type__c, Account_View__r.Legal_Name__c, Account_View__r.Location_Type__r.Name, Account_View__r.Parent_GDP_Account_View__c, Account_View__r.Trading_Name__c, Account_View__r.City__c, Account_View__r.Zip_Postal_Code__c, Account_View__r.Related_Accreditation_Class__r.Class__r.Name'
                                + ', Account_View__r.Sub_Continent__c, Account_View__r.Country_Name__c, Account_View__r.Related_Accreditation_Class__r.Class__r.Definition__c, Account_View__r.Related_Accreditation_Class__r.Class__r.Code__c, Account_View__r.State_Province__c, Account_View__r.Related_Accreditation_Class__c' 
                                + ' FROM GDP_Products_Account_Snapshot__c';
        else
             sQueryFields = 'SELECT Account_View__r.Id FROM GDP_Products_Account_Snapshot__c';
    
    
        String sQueryWhere = '';
        String [] splittedStateCode;
        List<String> sQueryWhereClauses = new List<String>();
        if (cachedAgencyIds == null) {
            // if GAD, filter out the Cargo agencies
            if (sProductCategoryCode == IECConstants.ProductCategory_SF_CACFREE
                || sProductCategoryCode == IECConstants.ProductCategory_SF_CACPRO
                || sProductCategoryCode == IECConstants.ProductCategory_SF_CACWEB){
                
                String CACCodesStr = CAC_and_GAD_Settings__c.getInstance('Excluded Values').Excluded_CAC_Location_Classes__c;
                List<String> CACCodesList = CACCodesStr.split(';');

                sQueryWhereClauses.add('Related_Accreditation_Class_Code__c NOT IN :CACCodesList');
            
            }else if (sProductCategoryCode == IECConstants.ProductCategory_SF_GAD){
                
                String GADCodesStr = CAC_and_GAD_Settings__c.getInstance('Excluded Values').Excluded_GAD_Location_Classes__c;
                List<String> GADCodesList = GADCodesStr.split(';');

                sQueryWhereClauses.add('Related_Accreditation_Class_Code__c NOT IN :GADCodesList');
           
            }
            else if (sProductCategoryCode == IECConstants.ProductCategory_SF_PAL)
                sQueryWhereClauses.add('Related_Accreditation_Class_Code__c IN (\'P\', \'D\', \'V\')');
            else if (sProductCategoryCode == IECConstants.ProductCategory_SF_CAL)
                sQueryWhereClauses.add('Related_Accreditation_Class_Code__c IN (\'C\')');
            else if (sProductCategoryCode == IECConstants.ProductCategory_SF_ASL)
                sQueryWhereClauses.add('Related_Accreditation_Class_Code__c IN (\'M\', \'G\', \'X\', \'K\')');
        
            // if a test is running, only return GDP_Products_Account_View__c created in a test class with the test flag in the AIMS ID field
            if (Test.isRunningTest())
                sQueryWhereClauses.add('AIMS_ID__c LIKE \'' + IECTestUtil.TEST_CLASS_AIMSID + '%\'');
            
            /////////////////////
            // Agency location
            
            // sub-continent
            if (String.isNotblank(oAdvancedFilters.Sub_Continent__c) && oAdvancedFilters.Sub_Continent__c != 'All') {
                sQueryWhereClauses.add('Sub_Continent__c = \'' + oAdvancedFilters.Sub_Continent__c + '\'');
            }
            
            // country
            if (String.isNotblank(oAdvancedFilters.Country__c) && oAdvancedFilters.Country__c != '(All)' && oAdvancedFilters.Country__c != 'All') {
                sQueryWhereClauses.add('Country_ISO_Code__c IN ' + addSingleQuotesToListedValues(oAdvancedFilters.Country__c));
            }
            
            // state/province
            if (String.isNotblank(oAdvancedFilters.State__c) && !oAdvancedFilters.State__c.startsWith('--') && oAdvancedFilters.State__c != '(All)' && oAdvancedFilters.State__c != 'All' && oAdvancedFilters.State__c != 'None' && oAdvancedFilters.State__c != 'null') {
                splittedStateCode = oAdvancedFilters.State__c.split('-');
                system.debug('###########################  oAdvancedFilters.State__c : ' + oAdvancedFilters.State__c);
                sQueryWhereClauses.add('State_Province_Code__c IN ' + addSingleQuotesToListedValues(splittedStateCode[1])); 
            }
            
            // City
            if (String.isNotblank(oAdvancedFilters.City__c)) {
                if (IECConstants.parseGADSearchTypeToEnum(oAdvancedFilters.City_Search_Type__c) == IECConstants.GADSearchType.ExactMatch)
                    sQueryWhereClauses.add('City__c = \'' + oAdvancedFilters.City__c + '\'');
                else if (IECConstants.parseGADSearchTypeToEnum(oAdvancedFilters.City_Search_Type__c) == IECConstants.GADSearchType.StartsWith)
                    sQueryWhereClauses.add('City__c LIKE \'' + oAdvancedFilters.City__c + '%\'');
                else
                    sQueryWhereClauses.add('City__c LIKE \'%' + oAdvancedFilters.City__c + '%\'');
            }
            
            // Zip/postal code
            if (String.isNotblank(oAdvancedFilters.Zip_Code__c)) {
                if (IECConstants.parseGADSearchTypeToEnum(oAdvancedFilters.Zip_Code_Search_Type__c) == IECConstants.GADSearchType.ExactMatch)
                    sQueryWhereClauses.add('Zip_Postal_Code__c = \'' + oAdvancedFilters.Zip_Code__c + '\'');
                else if (IECConstants.parseGADSearchTypeToEnum(oAdvancedFilters.Zip_Code_Search_Type__c) == IECConstants.GADSearchType.StartsWith)
                    sQueryWhereClauses.add('Zip_Postal_Code__c LIKE \'' + oAdvancedFilters.Zip_Code__c + '%\'');
                else
                    sQueryWhereClauses.add('Zip_Postal_Code__c LIKE \'%' + oAdvancedFilters.Zip_Code__c + '%\'');
            }
            
            /////////////////
            // IATA Code
            
            if (String.isNotBlank(oAdvancedFilters.IATA_Code__c)) {
                if (sProductCategoryCode == IECConstants.ProductCategory_SF_CAL) {
                	sQueryWhereClauses.add('Agency_Code__c LIKE \'' + oAdvancedFilters.IATA_Code__c + '%\'');
                } else {
                    if (oAdvancedFilters.IATA_Code__c.length() == 7) {
                        sQueryWhereClauses.add('IATA_Code__c = \'' + oAdvancedFilters.IATA_Code__c + '\'');
                    } else if (oAdvancedFilters.IATA_Code__c.length() == 8) {
                        String sIATACode = oAdvancedFilters.IATA_Code__c.substring(0,7);
                        String sCheckCode = oAdvancedFilters.IATA_Code__c.substring(7,8);
                        sQueryWhereClauses.add('IATA_Code__c = \'' + sIATACode + '\' AND Check_Digit__c = \'' + sCheckCode + '\'');
                    }
                    // simulate Starts With
                    else {
                    	sQueryWhereClauses.add('IATA_Code__c LIKE \'' + oAdvancedFilters.IATA_Code__c + '%\'');
                    }
                }
            }
            
            //////////////////
            // Agency name
            
            if (String.isNotblank(oAdvancedFilters.Agency_Name__c)) {
                                                       
                // define operator
                String sAgencyNameOperatorAndValue;
                if (IECConstants.parseGADSearchTypeToEnum(oAdvancedFilters.Agency_Name_Search_Type__c) == IECConstants.GADSearchType.ExactMatch)
                    sAgencyNameOperatorAndValue = ' = \'' + String.escapeSingleQuotes(oAdvancedFilters.Agency_Name__c) + '\'';
                else if (IECConstants.parseGADSearchTypeToEnum(oAdvancedFilters.Agency_Name_Search_Type__c) == IECConstants.GADSearchType.StartsWith)
                    sAgencyNameOperatorAndValue = ' LIKE \'' + String.escapeSingleQuotes(oAdvancedFilters.Agency_Name__c) + '%\'';
                else
                    sAgencyNameOperatorAndValue = ' LIKE \'%' + String.escapeSingleQuotes(oAdvancedFilters.Agency_Name__c) + '%\'';
                    
                // define
                if (IECConstants.parseGADAgencyNameSearchByToEnum(oAdvancedFilters.Agency_Name_Search_Condition__c) == IECConstants.GADAgencyNameSearchBy.TradingName)
                    sQueryWhereClauses.add('Trading_Name__c' + sAgencyNameOperatorAndValue);
                else if (IECConstants.parseGADAgencyNameSearchByToEnum(oAdvancedFilters.Agency_Name_Search_Condition__c) == IECConstants.GADAgencyNameSearchBy.LegalName)
                    sQueryWhereClauses.add('Legal_Name__c' + sAgencyNameOperatorAndValue);
                else
                    sQueryWhereClauses.add('(Trading_Name__c' + sAgencyNameOperatorAndValue + ' OR Legal_Name__c' + sAgencyNameOperatorAndValue + ')');
            }
            
            
            ////////////////
            // Agency Type
            
            // Hierarchy
            if (String.isNotblank(oAdvancedFilters.Hierarchy__c) && oAdvancedFilters.Hierarchy__c != 'All') {
                sQueryWhereClauses.add('Location_Type_Name__c IN ' + addSingleQuotesToListedValues('(' + oAdvancedFilters.Hierarchy__c.replaceAll(';', ', ') + ')'));
            }

            // Agency Program
            if (String.isNotblank(oAdvancedFilters.Agency_Program__c)) {
                
                // if Agency program is All, look at the Area of Activity
                if ((oAdvancedFilters.Agency_Program__c == '(All)' || oAdvancedFilters.Agency_Program__c == 'All') && oAdvancedFilters.Area_of_Activity__c != 'All') {
                    List<String> lstAgencyProgramCodes = getAgencyProgramCodesByAreaOfActivity(oAdvancedFilters.Area_of_Activity__c);
                    sQueryWhereClauses.add('Related_Accreditation_Class_Code__c IN ' + addSingleQuotesToListedValues('(' + String.join(lstAgencyProgramCodes, ', ') + ')') + ' AND Related_Accreditation_Class_Table__c = \'ORGCLASS\'');
                }
                else if (oAdvancedFilters.Agency_Program__c != '(All)' && oAdvancedFilters.Agency_Program__c != 'All')
                    sQueryWhereClauses.add('Related_Accreditation_Class_Code__c IN ' + addSingleQuotesToListedValues(oAdvancedFilters.Agency_Program__c) + ' AND Related_Accreditation_Class_Table__c = \'ORGCLASS\'');
            }

            if (sQueryWhereClauses.size() > 0) {
                sQueryWhere = ' WHERE ' + String.join(sQueryWhereClauses, ' AND ');
            }
            
            //////////////////
            // Agency Profile
            
            // (future development)
        } else { // Added by Mathieu Beausoleil
            sQueryWhere = ' WHERE Account_View__c in :cachedAgencyIds';
        }
        
        //////////////////////////////
        // Order By Agency Name 
        // (Trading by default, or Legal if filtered by)
        
        // define

        if(bReturnAllFields) {
            if (IECConstants.parseGADAgencyNameSearchByToEnum(oAdvancedFilters.Agency_Name_Search_Condition__c) == IECConstants.GADAgencyNameSearchBy.LegalName)
                sQueryWhere += ' ORDER BY Legal_Name__c ASC';
            else
                sQueryWhere += ' ORDER BY Trading_Name__c ASC';
        }
        
        sQueryWhere += ' LIMIT ' + String.valueOf(vfIECGAD.MAX_RESULTS + 1);
        system.debug('ALEX - getAgencyByAdvancedFilters query: ' + sQueryFields + sQueryWhere);
        
        List<GDP_Products_Account_View__c> results = new List<GDP_Products_Account_View__c>();
        for(GDP_Products_Account_Snapshot__c aSnapshot : Database.query(sQueryFields + sQueryWhere)) {
            if (aSnapshot.Account_View__c == null) continue;

            results.add(aSnapshot.Account_View__r);
        }

        return results;
    }
    
    /**
     * Search agencies by the Zip/Postal code
     * @param sZipPostalCode The zip/postal code
     * @param sSearchType The search type (matches IECConstants.GADSearchType)
     * @return A list of GDP_Products_Account_View__c
     */
     /*
    private static List<GDP_Products_Account_View__c> getAgencyByZipPostalCode(String sZipPostalCode, String sSearchType, String sProductCategoryCode) {
        
        String sQueryFields = 'SELECT Agency_Code__c, Agency_Status__c, IATA_Code__c, Name, Agency_Status_Code__c, Airline_Code__c, BSP_CASS_Code__c, CASS_Number__c, Email_Address__c'
                                + ', Incorporation_Type__c, Legal_Name__c, Location_Type__r.Name, Parent_GDP_Account_View__c, Trading_Name__c, City__c, Zip_Postal_Code__c'
                                + ', Sub_Continent__c, Country_Name__c, Related_Accreditation_Class__r.Class__r.Definition__c, State_Province__c, Related_Accreditation_Class__c' 
                                + ' FROM GDP_Products_Account_View__c';
        String sQueryWhere = ' WHERE Agency_Status_Code__c >= 4';
        
        // if GAD, filter out the Cargo agencies
        if (sProductCategoryCode == IECConstants.ProductCategory_SF_GAD)
            sQueryWhere += ' AND (NOT(Related_Accreditation_Class__r.Class__r.Definition__c = \'Cargo\' AND Related_Accreditation_Class__r.Class__r.Code__c = \'C\'))';
        
        // if a test is running, only return GDP_Products_Account_View__c created in a test class with the test flag in the AIMS ID field
        if (Test.isRunningTest())
            sQueryWhere += ' AND AIMS_ID__c LIKE \'' + IECTestUtil.TEST_CLASS_AIMSID + '%\'';


        /////////////////////
        // Zip/Postal code 

        if (IECConstants.parseGADSearchTypeToEnum(sSearchType) == IECConstants.GADSearchType.ExactMatch)
            sQueryWhere += ' AND Zip_Postal_Code__c = \'' + sZipPostalCode + '\'';
        else if (IECConstants.parseGADSearchTypeToEnum(sSearchType) == IECConstants.GADSearchType.StartsWith)
            sQueryWhere += ' AND Zip_Postal_Code__c LIKE \'' + sZipPostalCode + '%\'';
        else
            sQueryWhere += ' AND Zip_Postal_Code__c LIKE \'%' + sZipPostalCode + '%\'';
            
            
        //////////////////////////////
        // Order By Agency Name 
        
        sQueryWhere += ' ORDER BY Trading_Name__c ASC';
            
        system.debug('ALEX - getAgencyByZipPostalCode query: ' + sQueryFields + sQueryWhere);
            
        // execute the query
        return Database.query(sQueryFields + sQueryWhere);
    }
    */
    
    /**
     * Track global usage and consume customer subscription usage
     * @param oCustomer The IECCustomer object related to the customer
     * @param sProductCategoryCode The product category code
     * @param sSearchTarget Agency or Agent (use IECConstants.IECUsageTrackerSearchTarget_Agency or IECConstants.IECUsageTrackerSearchTarget_Agent)
     * @param sStatusOfSearch Success or Fail (use IECConstants.IECUsageTrackerSearchStatus_Fail or IECConstants.IECUsageTrackerSearchStatus_Success)
     */          
    private static void trackAndConsumeUsage(IECCustomer oCustomer, String sProductCategoryCode, String sSearchTarget, String sStatusOfSearch) {
        system.debug('angielaz: ' + oCustomer);
        trackAndConsumeUsage(oCustomer.RelatedContact.Id,  sProductCategoryCode,  sSearchTarget,  sStatusOfSearch);
    }
    
    //moved to a future method to reduce query time and optimize the returned result speed
    @future            
    private static void trackAndConsumeUsage(Id iCustomerId, String sProductCategoryCode, String sSearchTarget, String sStatusOfSearch) {
        
        try {
            IEC_Product_Access__c oProductAccess = null;
            List<GDP_Products_Account_View__c> lstAgency = null;
            
            // get the list of Product Access related to the customer and the given product category (sorted by EffectiveStartDate ASC)
            List<IEC_Product_Access__c> lstAccess = getListProductAccessByContactByProductCategory(iCustomerId, sProductCategoryCode);
            
            // find the oldest Product Access object that still has usage left (if not unlimited). Will be used to consume usage from.
            if(!lstAccess.isEmpty() || lstAccess != null){
                for (IEC_Product_Access__c prodAccess : lstAccess) {
                    if (prodAccess.Usage_Unlimited__c
                        || prodAccess.Usage_Qty_consumed__c == null
                        || prodAccess.Usage_Qty_consumed__c < prodAccess.Usage_Qty_Start__c) {
                        oProductAccess = prodAccess;
                        break;
                    }
                }
            }
    
            // find the latest subscription history
            if(oProductAccess != null){
                IEC_Subscription_History__c oSubHist = IECSubscriptionManager.getSubscriptionHistoryByName(oProductAccess.Subscription_Number__c);
                
                Contact relatedContact = IECUserManager.getContactById(iCustomerId);
                // track global usage
                trackLiveUsage(sProductCategoryCode, sStatusOfSearch, sSearchTarget, relatedContact, oSubHist);
                
                // consume subscription usage of customer
                incrementUsageCounterByProductAccess(oProductAccess, 1);
            }
        }
        catch (Exception ex) {
            system.debug('Cannot track and consume usage for customer contact id ' + iCustomerId + ' Product Category: ' + sProductCategoryCode + ' Exception: ' + ex.getMessage());
            throw new IECApplicationException('Cannot track and consume usage for customer contact id ' + iCustomerId + ' Product Category: ' + sProductCategoryCode, ex);
        }
    } 
    
    /**
     * Search agency by IATA code, track live usage (global stats) and consume usage on the subscription (via the Product Access object)
     * @param IATACode The IATA code to search for
     * @param CASSCode The CASS code
     * @param checkCode The "check" code (8th digit)
     * @param sProductCategoryCode The code of the Application
     * @param oCustomer The object representing the customer
     * @return A list of GDP_Products_Account_View__c
     */
    public static List<GDP_Products_Account_View__c> customerSearchAgencyByIATACode(String IATACode, String CASSCode, String checkCode, String sProductCategoryCode, IECCustomer oCustomer) {

        List<GDP_Products_Account_View__c> lstAgency = null;
        
        
        // Perform search
        if (String.isBlank(checkCode) )
            lstAgency = getAgencyByIATACode(IATACode, CASSCode);
        else
            lstAgency = getAgencyByAgencyCode(IATACode, checkCode, CASSCode);
        
        // if multiple results found (for CAC), return to page controller and UI will ask for check code (do not track usage)
        if ((sProductCategoryCode == IECConstants.ProductCategory_SF_CACPRO || sProductCategoryCode == IECConstants.ProductCategory_SF_CACFREE) && lstAgency != null && lstAgency.size() > 1)
            return lstAgency; 
        
        // if no results, track usage as invalid agency
        else if (lstAgency == null || lstAgency.size() == 0) {
            trackAndConsumeUsage(oCustomer, sProductCategoryCode, IECConstants.IECUsageTrackerSearchTarget_Agency, IECConstants.IECUsageTrackerSearchStatus_Fail);
        }
        // if exactly 1 result, track usage as valid 
        else if (lstAgency.size() == 1) {
            trackAndConsumeUsage(oCustomer, sProductCategoryCode, IECConstants.IECUsageTrackerSearchTarget_Agency, IECConstants.IECUsageTrackerSearchStatus_Success);
        }

        // return what has been found (null or 1 agency)
        return lstAgency;
    }
    
    /**
     * Search agency by advanced filters for a specified customer (tracks the usage)
     * @param oFilters The advance filters
     * @param sProductCategoryCode The product category code (should be GAD)
     * @param oCustomer The customer
     * @return A list of GDP_Products_Account_View__c
     */
    public static List<GDP_Products_Account_View__c> customerSearchAgencyByAdvancedFilters(IEC_Application_Filter__c oFilters, String sProductCategoryCode, IECCustomer oCustomer) {

        List<GDP_Products_Account_View__c> lstAgency = null;

        // Perform search
        lstAgency = getAgencyByAdvancedFilters(oFilters, sProductCategoryCode);

        // if no results, track usage as invalid agency
        if (lstAgency == null || lstAgency.size() == 0) {
            trackAndConsumeUsage(oCustomer, sProductCategoryCode, IECConstants.IECUsageTrackerSearchTarget_Agency, IECConstants.IECUsageTrackerSearchStatus_Fail);
        }
        // if 1 or more result, track usage as valid 
        else {
            trackAndConsumeUsage(oCustomer, sProductCategoryCode, IECConstants.IECUsageTrackerSearchTarget_Agency, IECConstants.IECUsageTrackerSearchStatus_Success);
        }

        // return what has been found (null or 1 agency)
        return lstAgency;
    }
    
    /**
     * Search agency by IATA code, track live usage (global stats) for anonymous user
     * @param IATACode The IATA code to search for
     * @param CASSCode The CASS code
     * @param checkCode The "check" code (8th digit)
     * @param sProductCategoryCode The code of the Application
     * @return A list of GDP_Products_Account_View__c
     */
    public static List<GDP_Products_Account_View__c> anonymousSearchAgencyByIATACode(String IATACode, String CASSCode, String checkCode, String sProductCategoryCode) {
        
        List<GDP_Products_Account_View__c> lstAgency = null;
        
        // Perform search
        if (String.isBlank(checkCode))
            lstAgency = getAgencyByIATACode(IATACode, CASSCode);
        else
            lstAgency = getAgencyByAgencyCode(IATACode, checkCode, CASSCode);
        
        // if multiple results found, return to page controller and UI will ask for check code (do not track usage)
        if (lstAgency != null && lstAgency.size() > 1)
            return lstAgency; 
        
        // if no results, track usage as invalid agency
        else if (lstAgency == null || lstAgency.size() == 0) {
            trackLiveUsage(sProductCategoryCode, IECConstants.IECUsageTrackerSearchStatus_Fail, IECConstants.IECUsageTrackerSearchTarget_Agency, null, null);
        }
        // if exactly 1 result, track usage as valid 
        else if (lstAgency.size() == 1) {
            trackLiveUsage(sProductCategoryCode, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agency, null, null);
        }

        // return what has been found (null or 1 agency)
        return lstAgency;
    }
    
    /**
     * Search agent by VER number, track live usage (global stats) and consume usage on the subscription (via the Product Access object)
     * @param verCode The VER number to search for
     * @param sProductCategoryCode The code of the Application
     * @param oCustomer The object representing the customer
     * @return An object ID_Card__c. If null or Card_Status__c is empty, the agent is invalid
     */
    public static ID_Card__c customerSearchAgentByVER(String verCode, String sProductCategoryCode, IECCustomer oCustomer) {

        // Perform search
        ID_Card__c  oSearchAgent = getAgentByVerCode(verCode);
        
        // if multiple results found, return to page controller and UI will ask for check code (do not track usage)
        if (oSearchAgent == null || oSearchAgent.Card_Status__c == '') {
            trackAndConsumeUsage(oCustomer, sProductCategoryCode, IECConstants.IECUsageTrackerSearchTarget_Agent, IECConstants.IECUsageTrackerSearchStatus_Fail);
        }
        else {
            trackAndConsumeUsage(oCustomer, sProductCategoryCode, IECConstants.IECUsageTrackerSearchTarget_Agent, IECConstants.IECUsageTrackerSearchStatus_Success);
        }

        // return what has been found (null or 1 agent)
        return oSearchAgent;
    }
    
    /**
     * Search agent by VER number, track live usage (global stats) for anonymous users
     * @param verCode The VER number to search for
     * @param sProductCategoryCode The code of the Application
     * @return An object ID_Card__c. If null or Card_Status__c is empty, the agent is invalid
     */
    public static ID_Card__c anonymousSearchAgentByVER(String verCode, String sProductCategoryCode) {
        
        ID_Card__c oSearchAgent = null;

        // Perform search
        oSearchAgent = getAgentByVerCode(verCode);
        
        // if multiple results found, return to page controller and UI will ask for check code (do not track usage)
        if (oSearchAgent == null || oSearchAgent.Card_Status__c == '')
            trackLiveUsage(sProductCategoryCode, IECConstants.IECUsageTrackerSearchStatus_Fail, IECConstants.IECUsageTrackerSearchTarget_Agent, null, null);
        else 
            trackLiveUsage(sProductCategoryCode, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agent, null, null);

        // return what has been found (null or 1 agent)
        return oSearchAgent;
    }
    
    /**
     * Inserts a IEC_Product_Access__c granting access to a specific user for a Product/Application
     * @param sContactId
     * @param oSubscription
     */
    /*@future (callout=true)*/
    public static void createProductAccessOnNewSubscription(Id sContactId, Zuora__Subscription__c oSubscription, String sInvoiceNumber) {
    	createProductAccessOnNewSubscription(sContactId, oSubscription, sInvoiceNumber, true);
    }

    /*@future (callout=true)*/
    public static void createProductAccessOnNewSubscription(Id sContactId, Zuora__Subscription__c oSubscription, String sInvoiceNumber, Boolean bOrderIsPaid) {
        try {
            // validate arguments
            if (String.isBlank(sContactId)) throw new IECApplicationException('Contact is null');
            if (oSubscription == null) throw new IECApplicationException('Subscription is null');
            if (String.isBlank(oSubscription.Product_Rate_Plan_Information__c)) throw new IECApplicationException('Rate Plan Info is null');

            // query all needed fields on Product Rate Plan Info
            List<Product_Rate_Plan_Information__c> lstRatePlanInfos = IECProductManager.getProductRatePlansInformationById(oSubscription.Product_Rate_Plan_Information__c);
            if (lstRatePlanInfos.isEmpty()) throw new IECApplicationException('Cannot find Product Rate Plan Info');
            
            IEC_Product_Access__c oProductAccess = new IEC_Product_Access__c();
            oProductAccess.Related_Contact__c = sContactId;
            oProductAccess.Related_Rate_Plan_Info__c = lstRatePlanInfos.get(0).Id;
            oProductAccess.Zuora_Subscription_Id__c = oSubscription.Zuora__Zuora_Id__c;
            oProductAccess.Subscription_Number__c = oSubscription.Name;
            oProductAccess.Invoice_Number__c = sInvoiceNumber;
            oProductAccess.Usage_Qty_consumed__c = 0;
            
            if (lstRatePlanInfos.get(0).Subscription_Usage_Qty__c != null && lstRatePlanInfos.get(0).Subscription_Usage_Qty__c >= 0) {
                oProductAccess.Usage_Qty_Start__c = lstRatePlanInfos.get(0).Subscription_Usage_Qty__c;
                oProductAccess.Usage_Qty_Left__c = oProductAccess.Usage_Qty_Start__c;
            }
            else {
                oProductAccess.Usage_Unlimited__c = true;
            }
            
            oProductAccess.Active__c = bOrderIsPaid;
            oProductAccess.Effective_Start_Date__c = oSubscription.Zuora__SubscriptionStartDate__c;
            oProductAccess.Effective_End_Date__c = oSubscription.Zuora__SubscriptionEndDate__c;
            
            insert oProductAccess;
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not insert Product Access: ' + ex.getMessage());
        }
    } 
    
    /**
     * Adjusts existing IEC_Product_Access__c according to the new changes in the subscription
     * @param sContactId
     * @param oSubscription: The update subscription
     * @param oProductAccess: Existing product access that needs update according to the changes in the subscription
     */
    public static void adjustProductAccessOnSubscription(Id sContactId, Zuora__Subscription__c oSubscription, String sInvoiceNumber, IEC_Product_Access__c oProductAccess) {
        try {
            // validate arguments
            if (String.isBlank(sContactId)) throw new IECApplicationException('Contact is null');
            if (oSubscription == null) throw new IECApplicationException('Subscription is null');
            if (String.isBlank(oSubscription.Product_Rate_Plan_Information__c)) throw new IECApplicationException('Rate Plan Info is null');
            
            // eBroadcast subscription does not need to have ProductAccess 
            if (oProductAccess == null)
            { // verify if this is expected
                // query all needed fields on Product Rate Plan Info
                List<Product_Rate_Plan_Information__c> lstRatePlanInfos = IECProductManager.getProductRatePlansInformationById(oSubscription.Product_Rate_Plan_Information__c);
                if (lstRatePlanInfos.isEmpty()) throw new IECApplicationException('Cannot find Product Rate Plan Info');
                
                Product_Rate_Plan_Information__c oProductRatePlan = lstRatePlanInfos.get(0);
                if (oProductRatePlan.Related_Product_Information__r.Related_Product_Category__r.Name != IECConstants.ProductCategory_SF_EBROADCAST) 
                {
                	throw new IECApplicationException( 'Product Access is null for non EBROADCAST SubscriptionId:' + oSubscription.Id);
                }
                // Subscription Product Category is EBROADCAST, do nothing and return.  
                return;
            }
            
            // Update product access information
            oProductAccess.Related_Contact__c = sContactId;
            oProductAccess.Zuora_Subscription_Id__c = oSubscription.Zuora__Zuora_Id__c;
            oProductAccess.Invoice_Number__c = sInvoiceNumber;
            
            // Update Product Access dates if necessary
            oProductAccess.Effective_Start_Date__c = oSubscription.Zuora__SubscriptionStartDate__c;
            oProductAccess.Effective_End_Date__c = oSubscription.Zuora__SubscriptionEndDate__c;
            
            // Update Product Access 'Active' flag if necessary
            oProductAccess.Active__c = (oSubscription.Zuora__Status__c == 'Active');

            // If rate plan has changed on the subscription for either of the following reason:
            //  - Upgrade in the same product group
            //  - Cross product amendment between two different product groups
            if (oProductAccess.Related_Rate_Plan_Info__c != oSubscription.Product_Rate_Plan_Information__c) {
                // query all needed fields on Product Rate Plan Info
                List<Product_Rate_Plan_Information__c> lstRatePlanInfos = IECProductManager.getProductRatePlansInformationById(oSubscription.Product_Rate_Plan_Information__c);
                if (lstRatePlanInfos.isEmpty()) throw new IECApplicationException('Cannot find Product Rate Plan Info');
                    
                oProductAccess.Related_Rate_Plan_Info__c = lstRatePlanInfos.get(0).Id;

                if (lstRatePlanInfos.get(0).Subscription_Usage_Qty__c != null && lstRatePlanInfos.get(0).Subscription_Usage_Qty__c > 0) {
                    oProductAccess.Usage_Qty_Start__c = lstRatePlanInfos.get(0).Subscription_Usage_Qty__c;
                    oProductAccess.Usage_Qty_Left__c = oProductAccess.Usage_Qty_Start__c - oProductAccess.Usage_Qty_consumed__c;
                    oProductAccess.Usage_Unlimited__c = false;
                }
                else {
                    oProductAccess.Usage_Qty_Start__c = null;
                    oProductAccess.Usage_Qty_Left__c = null; 
                    oProductAccess.Usage_Unlimited__c = true;
                }
            }
            
            update oProductAccess;
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not update Product Access: ' + ex.getMessage());
        }
    }
    
    /** 
     * Returns the latest version from a list of Zuora Subscription (since ZOQL doesn't do sorting)
     * @param lstSubs The list of subscription to look in
     * @return A Zuora.zObject representing the latest subscription
     */
    /*private static Zuora.zObject getLastVersionFromZuoraSubscriptionList(List<Zuora.zObject> lstSubs) {
        
        if (lstSubs == null || lstSubs.isEmpty())
            return null;
        
        Zuora.zObject oLatestSub = null;
        
        for (Zuora.zObject sub : lstSubs) {
            if (oLatestSub == null || ((Integer)sub.getValue('Version') > (Integer)oLatestSub.getValue('Version')))
                oLatestSub = sub;
        }
        
        return oLatestSub;
    }*/
    
    /**
     * Returns the list of Product Access that are currently effective for a Product Category, for a given Contact
     * @param idContact ID of the Contact associated to the customer
     * @param sProductCategory
     */
    public static List<IEC_Product_Access__c> getListProductAccessByContactByProductCategory(Id idContact, String sProductCategory) {
        List<String> evergreenSubscriptionName = getSubscriptionEvergreenNameListByBillingContactId(idContact);
        return [SELECT Id, Active__c, Usage_Qty_Start__c, Usage_Qty_Left__c, Usage_Unlimited__c, Usage_Qty_consumed__c
                , Effective_Start_Date__c, Effective_End_Date__c, Subscription_Number__c
                FROM IEC_Product_Access__c
                WHERE Effective_Start_Date__c <= Today
                    AND ( Effective_End_Date__c >= Today OR Subscription_Number__c in : evergreenSubscriptionName)
                    AND Active__c = true
                    AND Related_Contact__c = :idContact
                    AND Related_Rate_Plan_Info__r.Related_Product_Information__r.Related_Product_Category__r.Name = :sProductCategory
                ORDER BY Effective_End_Date__c];
    }
    
    /**
     * Returns the list of Product Access that are currently effective for a Subscription Number, for a given Contact
     * @param idContact ID of the Contact associated to the customer
     * @param sSubscriptionNumber
     */
    public static List<IEC_Product_Access__c> getListProductAccessByContactBySubscriptionNumber(Id idContact, String sSubscriptionNumber) {
        List<String> evergreenSubscriptionName = getSubscriptionEvergreenNameListByBillingContactId(idContact);
        return [SELECT Id, Active__c, Usage_Qty_Start__c, Usage_Qty_Left__c, Usage_Unlimited__c, Usage_Qty_consumed__c
                , Effective_Start_Date__c, Effective_End_Date__c, Subscription_Number__c
                FROM IEC_Product_Access__c
                WHERE Effective_Start_Date__c <= Today
                    AND ( Effective_End_Date__c >= Today OR Subscription_Number__c in : evergreenSubscriptionName)
                    AND Active__c = true
                    AND Related_Contact__c = :idContact
                    AND Subscription_Number__c = :sSubscriptionNumber
                ORDER BY Effective_End_Date__c];
    }
    
    /**
     * Returns the list of Evergreen Subscription Names for a given ContactId
     */
    private static List<String> getSubscriptionEvergreenNameListByBillingContactId(Id idContact) {
        List<Zuora__Subscription__c> subscriptionList = [SELECT Id, Name, Zuora__Zuora_Id__c
                	//,  Zuora__TermSettingType__c
                FROM Zuora__Subscription__c
                WHERE Zuora__CustomerAccount__r.Contact__c = :idContact
                     AND Zuora__TermSettingType__c = 'EVERGREEN'
                ORDER BY Name];
        List<String> subscriptionNameList = new List<String> ();
        for (Zuora__Subscription__c zuoraSub : subscriptionList)
        {
            subscriptionNameList.add(zuoraSub.Name);
        }
        return subscriptionNameList;
    } // end of getSubscriptionEvergreenNameListByBillingAccountId
    
    
    /** 
     * Checks whether contact has access to a specific ProductCategory
     * @param idContact Id of the Contact in question
     * @param ProductCategory Product Category that needs checking
     * @return Number indicating whether user has access to the product category
     *    -999: User has access to the service with unlimited usage
     *      -1: User has no access to the service
     *       0: User has access to the service but no usage available
     *     >=1: User has access to the service and the returned number is the remaining usage count
     * @ASSUMPTION: All subscription will count towards the same user and usage will be added as one counter per contact, not per subscription
     */
    public static integer ContactHasAccessToProductCategory(Id idContact, String sProductCategory) {
        if (idContact == null || String.isBlank(sProductCategory))
            return -1;
        
        List<IEC_Product_Access__c> lstAccess = getListProductAccessByContactByProductCategory(idContact, sProductCategory);

        if (lstAccess.size() > 0) {
            integer iUsageCount= 0;
            
            for (IEC_Product_Access__c access : lstAccess) {
                // Stop counting and return unlimited
                if (access.Usage_Unlimited__c)
                    return -999;
                
                iUsageCount +=  (Integer)access.Usage_Qty_Left__c;
            }

            return iUsageCount;
        }
        else
            return -1;
    }
    
    /** 
     * Checks whether contact has access to a specific Subscription
     * @param idContact Id of the Contact in question
     * @param sSubscriptionName Subscription Number that needs checking
     * @return Number indicating whether user has access to the product category
     *    -999: User has access to the service with unlimited usage
     *      -1: User has no access to the service
     *       0: User has access to the service but no usage available
     *     >=1: User has access to the service and the returned number is the remaining usage count
     * @ASSUMPTION: All subscription will count towards the same user and usage will be added as one counter per contact, not per subscription
     */
    public static integer ContactHasAccessToSubscriptionName(Id idContact, String sSubscriptionName) {
        if (idContact == null || String.isBlank(sSubscriptionName))
            return -1;
        
        List<IEC_Product_Access__c> lstAccess = getListProductAccessByContactBySubscriptionNumber(idContact, sSubscriptionName);

        if (lstAccess.size() > 0) {
            integer iUsageCount= 0;
            
            for (IEC_Product_Access__c access : lstAccess) {
                // Stop counting and return unlimited
                if (access.Usage_Unlimited__c)
                    return -999;
                
                iUsageCount +=  (Integer)access.Usage_Qty_Left__c;
            }

            return iUsageCount;
        }
        else
            return -1;
    }
    
    /** 
     * Increments the usage of a Product Access
     * @param oProductAccess The Product Access to consume the usage from
     * @param iValueConsumed The amount of usage to consume
     */
    private static void incrementUsageCounterByProductAccess(IEC_Product_Access__c oProductAccess, Integer iValueConsumed) {
        
        // validations (not likely to happen because they are validated prior to this point)
        if (oProductAccess.Active__c == false) throw new IECApplicationException('Cannot increment usage counter, Product Access is not active');
        if (oProductAccess.Effective_Start_Date__c > Date.today() || oProductAccess.Effective_End_Date__c < Date.today()) throw new IECApplicationException('Cannot increment usage counter, Product Access is not effective');
        if (!oProductAccess.Usage_Unlimited__c && oProductAccess.Usage_Qty_consumed__c >= oProductAccess.Usage_Qty_Start__c) throw new IECApplicationException('Cannot increment usage counter, no usage left');
        
        // fix for old data
        if (oProductAccess.Usage_Qty_consumed__c == null)
            oProductAccess.Usage_Qty_consumed__c = 0;
            
        // still decrement Qty Left field
        if (!oProductAccess.Usage_Unlimited__c)
            oProductAccess.Usage_Qty_Left__c -= iValueConsumed;
        
        oProductAccess.Usage_Qty_consumed__c += iValueConsumed;
        update oProductAccess;
    }
    
    /**
     * Records a usage counter for a given application, for a given contact (optional) and a given Subscription History (optional)
     * @param sApplicationType The Application type. Refers to the Product Category code (use IECConstants.ProductCategory_SF_XXX)
     * @param sSearchStatus The result of the usage (sucess or fail). Use IECConstants.IECUsageTrackerSearchStatus_XXX
     * @param sSearchTarget What is being searched (agents or agencies). Use IECConstants.IECUsageTrackerSearchTarget_XXX
     * @param oContact The Contact object associated to the customer
     * @param oSubhist The Subscription History that allows usage to be consumed
     * @return The id of the object IEC_Usage_Tracker_Live__c that was created
     */
    public static Id trackLiveUsage(String sApplicationType, String sSearchStatus, String sSearchTarget, Contact oContact, IEC_Subscription_History__c oSubhist) {
        
        // validate mandatory fields
        if (String.isBlank(sApplicationType)) throw new IECApplicationException('Application Type field is mandatory');
        if (String.isBlank(sSearchStatus)) throw new IECApplicationException('Search status field is mandatory');
        if (String.isBlank(sSearchTarget)) throw new IECApplicationException('Search Target field is mandatory');
        
        try {
            IEC_Usage_Tracker_Live__c oUsageTracker = new IEC_Usage_Tracker_Live__c(
                Related_Application_Type__c = sApplicationType,
                Search_Status__c = sSearchStatus,
                Search_Target__c = sSearchTarget,
                Date__c = Datetime.now(),
                Counter__c = 1,
                RelatedContact__c = (oContact == null ? null : oContact.Id),
                Related_Subscription_History__c = (oSubhist == null ? null : oSubhist.Id)
            );
            
            insert oUsageTracker;
            
            return oUsageTracker.Id;
        }
        catch (Exception ex) {
            system.debug('ALEX - Cannot track live usage: ' + ex.getMessage() + '\r\n' + ex.getStacktraceString());
            throw ex;
        }
    }
    
    /**
     * Returns a list of Product Access by Product Category and Contact
     * @param idContact Id of the Contact
     * @param sProductCategory The product category
     * @return List of Product Access for this contact
     */
    public static List<IEC_Product_Access__c> getProductAccessByContact(Id idContact, String sProductCategory) {
        if (idContact == null) throw new IECApplicationException('idContact cannot be null');
        if (String.isBlank(sProductCategory)) throw new IECApplicationException('sProductCategory cannot be null');
            
        // get the list of Product Access for the contact by product, ordered by the Effectived End Date DESC
        List<IEC_Product_Access__c> lstAccess =
            [SELECT Id, Usage_Qty_Start__c, Usage_Qty_Left__c, Usage_Unlimited__c, Effective_End_Date__c, Usage_Qty_consumed__c
            FROM IEC_Product_Access__c
            WHERE Related_Contact__c = :idContact
                AND Related_Rate_Plan_Info__r.Related_Product_Information__r.Related_Product_Category__r.Name = :sProductCategory
            ORDER BY Effective_End_Date__c desc];
        
        return (lstAccess == null || lstAccess.size() == 0) ? null : lstAccess;
    }
    
    /**
     * Returns a list of Product Access by subscription number
     */
    public static List<IEC_Product_Access__c> getProductAccessBySubscriptionNumber(string sSubscriptionNumber) {
        List<IEC_Product_Access__c> lstAccess =
            [SELECT Id, Effective_Start_Date__c, Effective_End_Date__c, Active__c, Related_Contact__c, Usage_Qty_Start__c, Usage_Qty_Left__c, Usage_Unlimited__c
                    , Subscription_Number__c, Related_Rate_Plan_Info__c, Usage_Qty_consumed__c, Zuora_Subscription_Id__c
            FROM IEC_Product_Access__c
            WHERE Subscription_Number__c = :sSubscriptionNumber
            ORDER BY Effective_End_Date__c];
        return lstAccess;
    }
    
    /**
     * Returns a map of Product Access by subscription number
     */
    public static Map<String,List<IEC_Product_Access__c>> getProductAccessBySubscriptionNumbers(set<string> sSubscriptionNumbers) {
        Map<String,List<IEC_Product_Access__c>> productAccessBySubscriptionNumbers = new Map<String,List<IEC_Product_Access__c>>();
        List<IEC_Product_Access__c> lstAccess =
            [SELECT Id, Effective_Start_Date__c, Effective_End_Date__c, Active__c, Related_Contact__c, Usage_Qty_Start__c, Usage_Qty_Left__c, Usage_Unlimited__c
                    , Subscription_Number__c, Related_Rate_Plan_Info__c, Usage_Qty_consumed__c, Zuora_Subscription_Id__c
            FROM IEC_Product_Access__c
            WHERE Subscription_Number__c in :sSubscriptionNumbers and Active__c =true
            ORDER BY Effective_End_Date__c];
        if(lstAccess != null && !lstAccess.isEmpty()){
            for(IEC_Product_Access__c pa : lstAccess){
                if(!productAccessBySubscriptionNumbers.containsKey(pa.Subscription_Number__c))
                    productAccessBySubscriptionNumbers.put(pa.Subscription_Number__c, new List<IEC_Product_Access__c>());
                productAccessBySubscriptionNumbers.get(pa.Subscription_Number__c).add(pa);
            }
        }
        return productAccessBySubscriptionNumbers;
    }
    
    /**
     * Returns the Effective End Date of the furthest subscription, 
     * for a given customer for a given product category
     * @param idContact Id of the Contact
     * @param sProductCategory The product category
     * @return The Effective End Date of the furthest subscription
     */
    public static Date getLastEnddateOfProductAccess(Id idContact, String sProductCategory) {
        
        if (idContact == null) throw new IECApplicationException('idContact cannot be null');
        if (String.isBlank(sProductCategory)) throw new IECApplicationException('sProductCategory cannot be null');
            
        // get the list of Product Access for the contact by product, ordered by the Effectived End Date DESC
        List<IEC_Product_Access__c> lstAccess =
            [SELECT Id, Usage_Qty_Start__c, Usage_Qty_Left__c, Usage_Unlimited__c, Effective_End_Date__c
            FROM IEC_Product_Access__c
            WHERE Effective_Start_Date__c <= Today
                AND Effective_End_Date__c >= Today
                AND Active__c = true
                AND Related_Contact__c = :idContact
                AND Related_Rate_Plan_Info__r.Related_Product_Information__r.Related_Product_Category__r.Name = :sProductCategory
            ORDER BY Effective_End_Date__c desc];
        
        if (lstAccess == null || lstAccess.size() == 0)
            return null;
            
        Datetime dtFurthestSubscriptionEndDate = lstAccess.get(0).Effective_End_Date__c;
        return (dtFurthestSubscriptionEndDate != null ? dtFurthestSubscriptionEndDate.date() : null);
    }
    
    /**
     * Returns the number of days between today and the end date of the furthest subscription, 
     * for a given customer for a given product category
     * @param idContact Id of the Contact
     * @param sProductCategory The product category
     * @return The number of days left
     */
    public static integer getDaysLeftForAccessByProductCategory(Id idContact, String sProductCategory) {

        if (idContact == null) throw new IECApplicationException('idContact cannot be null');
        if (String.isBlank(sProductCategory)) throw new IECApplicationException('sProductCategory cannot be null');

        Date dtFurthestSubscriptionEndDate = getLastEnddateOfProductAccess(idContact, sProductCategory);

        return (dtFurthestSubscriptionEndDate != null ? Date.today().daysBetween(dtFurthestSubscriptionEndDate) : 0);
    }
    
    /**
     * Returns the Effective End Date of the selected subscription
     * @param sSubscriptionName The Subscription Number
     * @return The Effective End Date of the specified subscription
     */
    public static Date getEnddateOfSubscriptionName(String sSubscriptionName) {

        if (String.isBlank(sSubscriptionName)) throw new IECApplicationException('sSubscriptionName cannot be null');
            
        // get the list of Product Access for subscription number
        List<IEC_Product_Access__c> lstAccess =
            [SELECT Id, Usage_Qty_Start__c, Usage_Qty_Left__c, Usage_Unlimited__c, Effective_End_Date__c
            FROM IEC_Product_Access__c
            WHERE Effective_Start_Date__c <= Today
                AND Effective_End_Date__c >= Today
                AND Active__c = true
                AND Subscription_Number__c = :sSubscriptionName];
        
        if (lstAccess == null || lstAccess.size() == 0)
            return null;
            
        Datetime dtSubscriptionEndDate = lstAccess.get(0).Effective_End_Date__c;
        return (dtSubscriptionEndDate != null ? dtSubscriptionEndDate.date() : null);
    }
    
    /**
     * Returns the number of days between today and the end date of the subscription
     * @param sSubscriptionName The Subscription Number
     * @return The number of days left
     */
    public static integer getDaysLeftForAccessBySubscriptionName(String sSubscriptionName) {

        if (String.isBlank(sSubscriptionName)) throw new IECApplicationException('sSubscriptionName cannot be null');

        Date dtSubscriptionEndDate = getEnddateOfSubscriptionName(sSubscriptionName);

        return (dtSubscriptionEndDate != null ? Date.today().daysBetween(dtSubscriptionEndDate) : 0);
    }
    
    /**
     * Get a saved filters used for the application searching 
     * @param sFilter Id of the filter
     * @return Saved filter
     */
    public static IEC_Application_Filter__c LoadFilterById(String sFilter) {
        try {
            List<IEC_Application_Filter__c> lstFilters =
                [SELECT Agency_Name__c, Agency_Name_Search_Condition__c, Agency_Name_Search_Type__c
                    , Agency_Program__c, Area_of_Activity__c, City__c, City_Search_Type__c, IATA_Code__c
                    , Filter_Name__c, Hierarchy__c, Related_Contact__c, Sub_Continent__c, Zip_Code__c
                    , Zip_Code_Search_Type__c, Country__c, State__c, Filter_Type__c, System_Generated__c
                FROM IEC_Application_Filter__c
                WHERE Id = :sFilter limit 1];
            
            return lstFilters.size() > 0 ? lstFilters.get(0) : null;
        }
        catch (Exception e) {
            throw new IECApplicationException('Could not load filters with ID: ' + sFilter + ' for the following error: ' + e.getMessage());
        }
        return null;
    }
    
    /**
     * Get a list of saved filters used for the application searching 
     * @param idContact Id of the Contact
     * @return Saved filter list
     */
    public static List<IEC_Application_Filter__c> LoadFilterByContact(String ProductLine, Id idContact, Boolean bSystemGenerated) {
        String NullProductLine=null;
        if (ProductLine!='GAD') NullProductLine=ProductLine;
        try {
            
            List<IEC_Application_Filter__c> lstFilters =
                [SELECT Agency_Name__c
                    , Agency_Name_Search_Condition__c
                    , Agency_Name_Search_Type__c
                    , Agency_Program__c
                    , Area_of_Activity__c
                    , City__c
                    , City_Search_Type__c
                    , Filter_Name__c, Hierarchy__c
                    , Related_Contact__c
                    , Sub_Continent__c
                    , Zip_Code__c
                    , Zip_Code_Search_Type__c
                    , Country__c
                    , State__c
                    , Filter_Type__c
                    , System_Generated__c
                    , Product_Line__c
                FROM IEC_Application_Filter__c
                WHERE Related_Contact__c = :idContact
                    AND System_Generated__c = :bSystemGenerated
                    AND (Product_Line__c=:ProductLine OR Product_Line__c = :NullProductLine)
                ORDER BY CreatedDate];
            
            return lstFilters;
        }
        catch (Exception e) {
            throw new IECApplicationException('Could not load filters with Contact ID: ' + idContact + ' for the following error: ' + e.getMessage());
        }
        return null;
    }
     /**
     * Get a list of saved filters used for the application searching 
     * @param idContact Id of the Contact
     * @return Saved filter list
     */
    public static List<IEC_Application_Filter__c> LoadFilterByContact( Id idContact, Boolean bSystemGenerated) {
        return LoadFilterByContact('GAD', idContact, bSystemGenerated);
    }
    
    /**
     * Gets list options for a specified picklist dynamically through the schema description
     * @param fieldResult: The field schema to determine the picklist values underneath
     **/
    public static List<SelectOption> GetListOptions(Schema.DescribeFieldResult fieldResult) {
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for(Schema.PicklistEntry p : ple)
            options.add(new SelectOption(p.getValue(), p.getValue()));
            
        return options;
    }
    
    /**
     * Returns a textual representation of all the selected advanced filters
     * @param sApplicationFilterID The id of a IEC Application Filters
     * @return A string
     */
    public static String getStringRepresentationOfApplicationFilter(String sApplicationFilterID) {
        
        String sTemp = '';
        IEC_Application_Filter__c oAppFilter = LoadFilterById(sApplicationFilterID);
        
        if (oAppFilter == null)
            throw new IECApplicationException('Application filter not found for id ' + sApplicationFilterID);
            
        
        /////////////////////
        // Agency location
        
        // sub-continent
        if (String.isNotblank(oAppFilter.Sub_Continent__c) && oAppFilter.Sub_Continent__c != 'All')
            sTemp += 'Sub Continent = ' + oAppFilter.Sub_Continent__c + ' AND ';
        
        // country
        if (String.isNotblank(oAppFilter.Country__c) && oAppFilter.Country__c != 'All' && oAppFilter.Country__c != '(All)' && oAppFilter.Country__c != '()') {
            List<String> lstCountryISOCodes = oAppFilter.Country__c.removeStart('(').removeEnd(')').remove(' ').split(',');
            sTemp += 'Country = (' + String.join(IECUtil.GetCountryNameFromISOCode(lstCountryISOCodes), ', ') + ') AND ';
        }
        
        // state/province
        if (String.isNotblank(oAppFilter.State__c) && !oAppFilter.State__c.startsWith('--') && oAppFilter.State__c != '(All)' && oAppFilter.State__c != 'All' && oAppFilter.State__c != 'None' && oAppFilter.State__c != 'null') {
            List<String> lstStateISOCodes = oAppFilter.State__c.removeStart('(').removeEnd(')').remove(' ').split(',');
            sTemp += 'State/Province = (' + String.join(IECUtil.GetStateNameFromISOCode(lstStateISOCodes), ', ') + ') AND ';
        }
        
        // City
        if (String.isNotblank(oAppFilter.City__c)) {
            sTemp += 'City ';
            if (IECConstants.parseGADSearchTypeToEnum(oAppFilter.City_Search_Type__c) == IECConstants.GADSearchType.ExactMatch)
                sTemp += '= \'' + oAppFilter.City__c + '\' AND ';
            else if (IECConstants.parseGADSearchTypeToEnum(oAppFilter.City_Search_Type__c) == IECConstants.GADSearchType.StartsWith)
                sTemp += 'Starts With \'' + oAppFilter.City__c + '\' AND ';
            else
                sTemp += 'Contains \'' + oAppFilter.City__c  + '\' AND ';
        }
        
        // Zip/Postal Code
        if (String.isNotBlank(oAppFilter.Zip_Code__c)) {
            if (IECConstants.parseGADSearchTypeToEnum(oAppFilter.Zip_Code_Search_Type__c) == IECConstants.GADSearchType.ExactMatch)
                sTemp += 'Zip/Postal Code = \'' + oAppFilter.Zip_Code__c + '\'';
            else if (IECConstants.parseGADSearchTypeToEnum(oAppFilter.Zip_Code_Search_Type__c) == IECConstants.GADSearchType.StartsWith)
                sTemp += 'Zip/Postal Code Starts With \'' + oAppFilter.Zip_Code__c + '\'';
            else
                sTemp += 'Zip/Postal Code Contains \'' + oAppFilter.Zip_Code__c + '\'';
        }
        
        /////////////////
        // IATA Code
        
        if (String.isNotBlank(oAppFilter.IATA_Code__c)) {
            if (oAppFilter.IATA_Code__c.length() == 7 || oAppFilter.IATA_Code__c.length() == 8)
                sTemp += 'IATA Code = \'' + oAppFilter.IATA_Code__c + '\' AND ';
            else
                sTemp += 'IATA Code Starts With \'' + oAppFilter.IATA_Code__c + '\' AND ';
        }
        
        ////////////////
        // Agency name
        
        if (String.isNotblank(oAppFilter.Agency_Name__c)) {

            // define operator
            String sAgencyNameOperatorAndValue;
            if (IECConstants.parseGADSearchTypeToEnum(oAppFilter.Agency_Name_Search_Type__c) == IECConstants.GADSearchType.ExactMatch)
                sAgencyNameOperatorAndValue = ' = \'' + oAppFilter.Agency_Name__c + '\' AND ';
            else if (IECConstants.parseGADSearchTypeToEnum(oAppFilter.Agency_Name_Search_Type__c) == IECConstants.GADSearchType.StartsWith)
                sAgencyNameOperatorAndValue = 'Starts With \'' + oAppFilter.Agency_Name__c + '\' AND ';
            else
                sAgencyNameOperatorAndValue = 'Contains \'' + oAppFilter.Agency_Name__c + '\' AND ';
                
            // define
            if (IECConstants.parseGADAgencyNameSearchByToEnum(oAppFilter.Agency_Name_Search_Condition__c) == IECConstants.GADAgencyNameSearchBy.TradingName)
                sTemp += 'Trading Name ' + sAgencyNameOperatorAndValue;
            else if (IECConstants.parseGADAgencyNameSearchByToEnum(oAppFilter.Agency_Name_Search_Condition__c) == IECConstants.GADAgencyNameSearchBy.LegalName)
                sTemp += 'Legal Name ' + sAgencyNameOperatorAndValue;
            else
                sTemp += '(Trading Name ' + sAgencyNameOperatorAndValue.replace(' AND ', '') + ' OR Legal Name ' + sAgencyNameOperatorAndValue.replace(' AND ', '') + ') AND ';
        }
        
        
        ////////////////
        // Agency Type
        
        // Area of activity
        if (String.isNotBlank(oAppFilter.Area_of_Activity__c) && oAppFilter.Area_of_Activity__c != 'All') {
            sTemp += 'Area of Activity = \'' + oAppFilter.Area_of_Activity__c + '\' AND ';
        }
        
        // Hierarchy (Location Type)
        if (String.isNotblank(oAppFilter.Hierarchy__c) && oAppFilter.Hierarchy__c != 'All') {
            sTemp += 'Hierarchy = (' + oAppFilter.Hierarchy__c.replaceAll(';', ', ') + ') AND ';
        }
        
        // Agency Program
        if (String.isNotblank(oAppFilter.Agency_Program__c) && oAppFilter.Agency_Program__c != 'All' && oAppFilter.Agency_Program__c != '(All)'  && oAppFilter.Agency_Program__c != '()') {
            List<String> lstAgencyProgramCodes = oAppFilter.Agency_Program__c.removeStart('(').removeEnd(')').remove(' ').split(',');
            sTemp += 'Agency Program = (' + String.join(IECUtil.GetAgencyProgramNameFromCode(lstAgencyProgramCodes), ', ') + ') AND ';
        }
        
        // trim the last ' AND '
        if (sTemp.endsWith(' AND '))
            sTemp = sTemp.substring(0, sTemp.lastIndexOf(' AND '));
        
        return sTemp;
    }
    
    /**
     * For each items in a concatenated list (a, b, c)
     * surrounds the value with single quotes ('a', 'b', 'c')
     * @param sValues The concatenated values
     * @return The concatenated list with the single quotes
     */
    private static String addSingleQuotesToListedValues(String sValues) {
        if (sValues.indexOf('(') == -1) sValues = '(' + sValues;
        if (sValues.indexOf(')') == -1) sValues = sValues + ')';
        String sList = sValues.replace('(', '(\'');
        sList = sList.replace(', ', '\', \'');
        sList = sList.replace(')', '\')');
        return sList;
    }
    
    /**
     * Returns the number of results based on the given application filters
     * @param sApplicationFilterID The IEC Application Filters ID
     * @return The number of results
     */
    public static Integer getNumberOfResultsByAppFilterID(IECCustomer oCustomer, String sApplicationFilterID, String sProductCategoryCode) {
        IEC_Application_Filter__c oAppFilter = LoadFilterById(sApplicationFilterID);
        
        if (oAppFilter == null) {
            throw new IECApplicationException('Application filter not found for id ' + sApplicationFilterID);
        }


        List<GDP_Products_Account_View__c> lstAccounts = getAgencyByAdvancedFilters(oAppFilter, sProductCategoryCode,false);

        if (lstAccounts == null || lstAccounts.size() == 0) {
            trackAndConsumeUsage(oCustomer, sProductCategoryCode, IECConstants.IECUsageTrackerSearchTarget_Agency, IECConstants.IECUsageTrackerSearchStatus_Fail);
        } else if (lstAccounts.size() > vfIECGAD.MAX_RESULTS) {
            trackAndConsumeUsage(oCustomer, sProductCategoryCode, IECConstants.IECUsageTrackerSearchTarget_Agency, IECConstants.IECUsageTrackerSearchStatus_Success);
        }

        Map<Id, GDP_Products_Account_View__c> lstAccountsMap = new Map<Id, GDP_Products_Account_View__c>();
        System.debug(lstAccounts);
        lstAccountsMap.putAll(lstAccounts);
        Set<Id> lstAccountsIds = lstAccountsMap.keySet();
        cachedAgencyIds = new List<Id>(lstAccountsIds);

        return (lstAccounts == null ? 0 : lstAccounts.size());
    }
    
    /**
     * Returns the list of Agency Program codes part of an area of activity
     * @param sAreaOfActivity The Area of activity of the agency
     * @return A list of Agency Program codes
     */
    public static List<String> getAgencyProgramCodesByAreaOfActivity(String sAreaOfActivity) {
        List<String> lstProgramCodes = new List<String>();

        for (IEC_Agency_Type__c agencyType : [SELECT Agency_Program_Code__c FROM IEC_Agency_Type__c WHERE Area_of_Activity__c = :sAreaOfActivity]) {
            lstProgramCodes.add(agencyType.Agency_Program_Code__c);
        }
            
        return lstProgramCodes;
    }
    
    /**
     * Returns true if the application filter has no filtering value
     */
    public static Boolean isApplicationFilterEmpty(/*String sApplicationFilterId*/IEC_Application_Filter__c oAppFilter) {
        //IEC_Application_Filter__c oAppFilter = LoadFilterById(sApplicationFilterID);
        
        if (oAppFilter == null)
            throw new IECApplicationException('Application filter is null');
            
        return ((String.isBlank(oAppFilter.Sub_Continent__c) || oAppFilter.Sub_Continent__c == 'All')
                && (String.isBlank(oAppFilter.Country__c) || oAppFilter.Country__c == '(All)')
                && (String.isBlank(oAppFilter.State__c) || oAppFilter.State__c == '(All)')
                && String.isBlank(oAppFilter.City__c)
                && String.isBlank(oAppFilter.Zip_Code__c)
                && String.isBlank(oAppFilter.IATA_Code__c)
                && String.isBlank(oAppFilter.Agency_Name__c)
                && (String.isBlank(oAppFilter.Hierarchy__c) || oAppFilter.Hierarchy__c == 'All')
                && (String.isBlank(oAppFilter.Agency_Program__c) || oAppFilter.Agency_Program__c == '(All)')
                && (String.isBlank(oAppFilter.Area_of_Activity__c) || oAppFilter.Area_of_Activity__c == 'All'));
    }
    
    
    /**
     * isEbcAccessGrantedForContact returns true if the idContact (community user) has access to eBroadcast
     * oBillingAccount is used only to cache the last Zuora__CustomerAccount__c for isEbcAccessGrantedForContact 
     */
	private static Zuora__CustomerAccount__c oBillingAccount;
	// isEbcAccessGrantedForContact with option to refresh the previously cached resetBillingAccount
	public static Boolean isEbcAccessGrantedForContact(Id idContact, Boolean resetBillingAccount)
	{
		if (resetBillingAccount) {
			oBillingAccount = null;
		}
		return isEbcAccessGrantedForContact(idContact);
	} // isBillingAccountEbcChecked
	
	public static Boolean isEbcAccessGrantedForContact(Id idContact)
	{
		if (oBillingAccount == null || oBillingAccount.Contact__c != idContact)
		{ // initialize oBillingAccount if necessary
			List<Zuora__CustomerAccount__c> oZBillingAcctList = [select Id
					, eBroadcast_Product_Access__c
					// , eBroadcast_Add_On_Access__c
				from Zuora__CustomerAccount__c
				where Contact__c = : idContact
					and  Zuora__Status__c = 'Active'
				order by CreatedDate desc limit 1];
			oBillingAccount = ( oZBillingAcctList.size()==0) ? null : oZBillingAcctList[0]; 
		}
		Boolean result = (oBillingAccount != null) && (oBillingAccount.eBroadcast_Product_Access__c);
		return result;
	} // isBillingAccountEbcChecked
	
	

}