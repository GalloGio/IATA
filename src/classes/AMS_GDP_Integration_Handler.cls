/** 
 *
 */
public class AMS_GDP_Integration_Handler {

    private static String ERROR_MESSAGE = 'Error: ';
    private static String SUCCESS_MESSAGE = 'Success: ';
    @testVisible private static String DATE_FORMAT = 'YYYY-MM-DD';

    /** 
     *
     */    
    public static String gdpProductsAccountView(AMS_GDP_Objects.ProductAccountView pac) {
        
        try {    
            
            Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(String.valueOf('GDP_Products_Account_View__c').toLowerCase()).getDescribe().Fields.getMap();

            GDP_Products_Account_View__c pacSF = new GDP_Products_Account_View__c();
            updateField(pacSF, 'WebStar_ID__c', pac.EXTERNALID, fMap);
            updateField(pacSF, 'IATA_Code__c', pac.IATACODE, fMap);
            updateField(pacSF, 'CASS_Number__c', pac.IATACASS, fMap);
            updateField(pacSF, 'Location_Type__c', getSfId('GDP_Reference_Table__c', 'Name', pac.LOCATIONTYPE), fMap);
            updateField(pacSF, 'Legal_Name_1__c', pac.LEGALNAME, fMap);
            updateField(pacSF, 'Trading_Name_1__c', pac.DBA, fMap);
            updateField(pacSF, 'Email_Address__c', pac.EMAIL, fMap);
            updateField(pacSF, 'Website__c', pac.WEBADDRESS, fMap);
            updateField(pacSF, 'Passenger_And_Cargo__c', pac.PC, fMap);
            updateField(pacSF, 'Incorporation_Type__c', getSfId('GDP_Reference_Table__c', 'Code__c', pac.LEGALTYPE), fMap);
            updateField(pacSF, 'GDP_Opt_In__c', pac.SOLICITATION, fMap);
            updateField(pacSF, 'Ticketing_Agent_First_Name__c', (pac.QTANAME != null ? pac.QTANAME.substringBefore('') : null), fMap);
            updateField(pacSF, 'Ticketing_Agent_Last_Name__c', (pac.QTANAME != null ? pac.QTANAME.substringAfter('') : null), fMap);
            updateField(pacSF, 'Manager_First_Name__c', (pac.QMPNAME != null ? pac.QMPNAME.substringBefore('') : null), fMap);
            updateField(pacSF, 'Manager_Last_Name__c', (pac.QMPNAME != null ? pac.QMPNAME.substringAfter('') : null), fMap);
            updateField(pacSF, 'Tax_ID_1__c', pac.TAXID, fMap);
            updateField(pacSF, 'License_Number__c', 'N', fMap);
            updateField(pacSF, 'Preferred_Language__c', 'N', fMap);
            
            upsert pacSF;
            
            return SUCCESS_MESSAGE + pacSF.Id;
        } catch(Exception e) {
            
            return ERROR_MESSAGE+e.getMessage();
        }
    }
    
    /** 
     *
     */
    public static String gdpAddress(AMS_GDP_Objects.Address a) {
    
        try {

            Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(String.valueOf('GDP_Address__c').toLowerCase()).getDescribe().Fields.getMap();

            GDP_Address__c aSF = new GDP_Address__c();
            updateField(aSF, 'WebStar_ID__c', a.EXTERNALID, fMap);
            updateField(aSF, 'Address_Line_1__c', a.ADDRESS, fMap);
            updateField(aSF, 'Address_Line_2__c', a.ADDRESS2, fMap);
            updateField(aSF, 'Address_Line_3__c', a.SUITE3, fMap);
            updateField(aSF, 'Address_City__c', a.CITY, fMap);
            updateField(aSF, 'IATA_ISO_State__c', getSfId('IATA_ISO_State__c', 'Name', a.STATECODE), fMap);
            updateField(aSF, 'IATA_ISO_Country__c',getSfId('IATA_ISO_Country__c', 'Name', a.COUNTRY), fMap);
            updateField(aSF, 'Address_Postal_Code__c', a.ZIP, fMap);
            
            return SUCCESS_MESSAGE+aSF.Id;
        } catch(Exception e) {
            
            return ERROR_MESSAGE+e.getMessage();
        }
    }
    
    /** 
     *
     */
    public static String gdpPhone(AMS_GDP_Objects.Phone p) {
    
        try {

            Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(String.valueOf('GDP_Phone__c').toLowerCase()).getDescribe().Fields.getMap();

            GDP_Phone__c pSF = new GDP_Phone__c();
            updateField(pSF, 'WebStar_ID__c', p.EXTERNALID, fMap);
            updateField(pSF, 'ISD_Code__c', p.COUNTRYCODE, fMap);
            updateField(pSF, 'Phone_Type__c', 'Phone 1', fMap);
            updateField(pSF, 'STD_Code__c', p.AREACODE, fMap);
            updateField(pSF, 'Number__c', p.PHONENUMBER, fMap);

            return SUCCESS_MESSAGE+pSF.Id;
        } catch(Exception e) {
            
            return ERROR_MESSAGE+e.getMessage();
        }
    }
    
    /** 
     *
     */
    public static String gds(AMS_GDP_Objects.GDS gds) {
    
        try {

            Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(String.valueOf('GDS__c').toLowerCase()).getDescribe().Fields.getMap();

            GDS__c gdsSF = new GDS__c();
            updateField(gdsSF, 'WebStar_ID__c', gds.EXTERNALID, fMap);

            if(gds.RESERVATIONSYSTEM != null && gds.RESERVATIONSYSTEM != '') {

                updateField(gdsSF, 'Computer_Reservation_System__c', getSfId('GDP_Reference_Table__c', 'System__c', gds.RESERVATIONSYSTEM), fMap);
                updateField(gdsSF, 'GDS_ID__c', '1', fMap);            
            } else if(gds.RESERVATIONSYSTEM2 != null && gds.RESERVATIONSYSTEM2 != '') {

                updateField(gdsSF, 'Computer_Reservation_System__c', getSfId('GDP_Reference_Table__c', 'System__c', gds.RESERVATIONSYSTEM2), fMap);
                updateField(gdsSF, 'GDS_ID__c', '2', fMap);
            } else if(gds.RESERVATIONSYSTEM3 != null && gds.RESERVATIONSYSTEM3 != '') {

                updateField(gdsSF, 'Computer_Reservation_System__c', getSfId('GDP_Reference_Table__c', 'System__c', gds.RESERVATIONSYSTEM3), fMap);
                updateField(gdsSF, 'GDS_ID__c', '3', fMap);
            } else if(gds.RESERVATIONSYSTEM4 != null && gds.RESERVATIONSYSTEM4 != '') {

                updateField(gdsSF, 'Computer_Reservation_System__c', getSfId('GDP_Reference_Table__c', 'System__c', gds.RESERVATIONSYSTEM4), fMap);
                updateField(gdsSF, 'GDS_ID__c', '4', fMap);
            }

            return SUCCESS_MESSAGE+gdsSF.Id;
        } catch(Exception e) {
            
            return ERROR_MESSAGE+e.getMessage();
        }
    }
    
    /** 
     *
     */
    public static String gdpAgencyProfileSpecialization(AMS_GDP_Objects.AgencyProfileSpecialization aps) {
    
        try {

            Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(String.valueOf('GDP_Agency_Profile_Specialization__c').toLowerCase()).getDescribe().Fields.getMap();

            GDP_Agency_Profile_Specialization__c apsSF = new GDP_Agency_Profile_Specialization__c();
            updateField(apsSF, 'WebStar_ID__c', aps.EXTERNALID, fMap);
            updateField(apsSF, 'Market_Focus_Leisure__c', getSfId('GDP_Reference_Table__c', 'Code__c', aps.MARKETFOCUSLEISURE), fMap);
            updateField(apsSF, 'Market_Focus_Corporate__c', getSfId('GDP_Reference_Table__c', 'Code__c', aps.MARKETFOCUSCOPORATE), fMap);
            updateField(apsSF, 'Sales_Volume__c', getSfId('GDP_Reference_Table__c', 'Code__c', aps.TOTALANNUALSALES), fMap);
            updateField(apsSF, 'Sales_Air__c', getSfId('GDP_Reference_Table__c', 'Code__c', aps.PERCENTAIR), fMap);
            updateField(apsSF, 'Sales_Sea__c', getSfId('GDP_Reference_Table__c', 'Code__c', aps.PERCENTCRUISE), fMap);
            updateField(apsSF, 'Sales_Land__c', getSfId('GDP_Reference_Table__c', 'Code__c', aps.PERCENTLAND), fMap);
            updateField(apsSF, 'Main_Market_Specialization__c', getSfId('GDP_Reference_Table__c', 'Code__c', aps.SPECIALITY1), fMap);
            updateField(apsSF, 'Secondary_Market_Specialization__c', getSfId('GDP_Reference_Table__c', 'Code__c', aps.SPECIALITY2), fMap);
            updateField(apsSF, 'Tertiary_Market_Specialization__c', getSfId('GDP_Reference_Table__c', 'Code__c', aps.SPECIALITY3), fMap);
            //updateField(apsSF, 'Tertiary_Market_Specialization__c', aps.PROFILE, fMap);
            updateField(apsSF, 'Main_Activity__c', getSfId('GDP_Reference_Table__c', 'Code__c', aps.PRINCIPALACTIVITY), fMap);
            
            return SUCCESS_MESSAGE+apsSF.Id;
        } catch(Exception e) {
            
            return ERROR_MESSAGE+e.getMessage();
        }
    }

    /** 
     *
     */
    public static String agencyOwner(AMS_GDP_Objects.AgencyOwner ao) {
    
        try {

            Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(String.valueOf('Agency_Owner__c').toLowerCase()).getDescribe().Fields.getMap();

            Agency_Owner__c aoSF = new Agency_Owner__c();
            updateField(aoSF, 'WebStar_ID__c', ao.EXTERNALID, fMap);
            updateField(aoSF, 'OwnerId', getSfId('User', 'Name', ao.OWNER), fMap);
            
            return SUCCESS_MESSAGE+aoSF.Id;
        } catch(Exception e) {
            
            return ERROR_MESSAGE+e.getMessage();
        }
    }
    
    /** 
     *
     */
    public static String accreditation(AMS_GDP_Objects.Accreditation a) {
    
        try {

            Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(String.valueOf('Accreditation__c').toLowerCase()).getDescribe().Fields.getMap();

            Accreditation__c aSF = new Accreditation__c();
            updateField(aSF, 'WebStar_ID__c', a.EXTERNALID, fMap);
            updateField(aSF, 'Last_re_inspection_date__c', a.VERIFICATIONDATE, fMap);
            updateField(aSF, 'Original_approval_date__c', a.RC, fMap);
            updateField(aSF, 'Status__c', getSfId('GDP_Reference_Table__c', 'Code__c', a.STATUS), fMap);
            updateField(aSF, 'Date__c', a.EFFECTIVEDATE, fMap);
            updateField(aSF, 'Class__c', getSfId('GDP_Reference_Table__c', 'Code__c', a.ORGCLASS), fMap);
            //updateField(aSF, 'Accreditation_ID__c', '1', fMap);
            //updateField(aSF, 'Accreditation_ID__c', '2', fMap);
            updateField(aSF, 'Last_change_date__c', a.LASTMODDATE, fMap);
            
            return SUCCESS_MESSAGE+aSF.Id;
        } catch(Exception e) {
            
            return ERROR_MESSAGE+e.getMessage();
        }
    }
    
    /** 
     *
     */
    public static String accountCategory(AMS_GDP_Objects.AccountCategory ac) {
    
        try {

            Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(String.valueOf('Account_Category__c').toLowerCase()).getDescribe().Fields.getMap();

            Account_Category__c acSF = new Account_Category__c();
            updateField(acSF, 'WebStar_ID__c', ac.EXTERNALID, fMap);
            updateField(acSF, 'Category_Code__c', getSfId('GDP_Reference_Table__c', 'Code__c', ac.LOCATIONCAT), fMap);
            updateField(acSF, 'Category_ID__c', getSfId('GDP_Reference_Table__c', 'Code__c', ac.LOCATIONCAT2), fMap);
            
            return SUCCESS_MESSAGE+acSF;
        } catch(Exception e) {
            
            return ERROR_MESSAGE+e.getMessage();
        }
    }
    
    /**
     *
     */
    private static String getSfId(String sObj, String field, String param) {
        
        if(param != null && param != '') {
        
            List<sObject> sObjs = Database.query('select Id from '+sObj+' where '+field+'= \''+param.trim().toUpperCase()+'\'');
            
            if(sObjs.size() > 0) return sObjs[0].Id;
        }
        
        return null;
    }
    
    /**
     *
     */
    private static void updateField(sObject sObj, String fieldNameParam, String fieldValueParam, Map<String,Schema.SObjectField> fMap) {
    
        String fieldName = fieldNameParam.trim().toUpperCase();
        String fieldValue = (fieldValueParam == null ? '' : fieldValueParam.trim());
        String fieldType = fMap.get(fieldName).getDescribe().getType().Name();
        String DATE_SEPARATOR = (DATE_FORMAT == null ? null : (DATE_FORMAT.contains('/') ? '/' : '-'));

        if(fieldValueParam == null || fieldValueParam == '') sObj.put(fieldName, null);
        else if(fieldType == 'DATE'){ 
                
            if(DATE_FORMAT == null) sObj.put(fieldName, (fieldValue == null ? null : Date.valueOf(fieldValue)));    
            else{
                
                List<String> dtList = fieldValue.split(DATE_SEPARATOR);
                List<String> dtFormatList = DATE_FORMAT.split(DATE_SEPARATOR);
                List<String> dtOutputList = new List<String>{'', '', ''};

                for(Integer i = 0; i < dtFormatList.size(); i++){
                    
                    if(dtFormatList[i] == 'YYYY'){
                        
                        dtOutputList[2] = dtList[i];
                    }else if(dtFormatList[i] == 'MM'){
                        
                        dtOutputList[1] = dtList[i];
                    }else if(dtFormatList[i] == 'DD'){
                        
                        dtOutputList[0] = dtList[i];
                    }
                }

                sObj.put(fieldName, Date.valueOf(dtOutputList[2]+'-'+dtOutputList[1]+'-'+dtOutputList[0])); 
            }
        }
        else if(fieldType == 'DATETIME') sObj.put(fieldName, (fieldValue == null ? null : Datetime.valueOf(fieldValue)));
        else if(fieldType == 'DECIMAL' || fieldType == 'CURRENCY') sObj.put(fieldName, (fieldValue == null ? null : Decimal.valueOf(fieldValue)));
        else if(fieldType == 'INTEGER') sObj.put(fieldName, (fieldValue == null ? null : Integer.valueOf(fieldValue)));
        else if(fieldType == 'LONG') sObj.put(fieldName, (fieldValue == null ? null : Long.valueOf(fieldValue)));
        else if(fieldType == 'DOUBLE') sObj.put(fieldName, (fieldValue == null ? null : Double.valueOf(fieldValue)));
        else if(fieldType == 'BOOLEAN') sObj.put(fieldName, (fieldValue.toUpperCase() == 'TRUE'));
        else sObj.put(fieldName, fieldValue);
    }
}