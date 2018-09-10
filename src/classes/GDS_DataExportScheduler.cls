global with sharing class GDS_DataExportScheduler implements Schedulable{
    
    private static final String BOM_UTF8 = EncodingUtil.convertFromHex('EFBBBF').toString();
    public static final String REPORT_NAME = 'Terminated Agents - Global';
    public static final String LIBRARY_CS_NAME = 'GDS File Export Library Name';

    public GDS_DataExportScheduler() {
    }

    global void execute(SchedulableContext SC) {
        runProcess();
    }
    
    public void runProcess() {
        list<Agency_Applied_Change_code__c> listChangeCode = [
            SELECT 
                Account__r.IATACode__c,
                Account__r.Name,
                Account__r.Expiry_Date__c,
                Account__r.Status__c,
                Account__r.IATA_ISO_Country__r.Name,
                Change_Code__c
            FROM Agency_Applied_Change_code__c
            WHERE CreatedDate = LAST_MONTH
            AND Change_Code__c = 'TER'
            AND Account__r.Location_Class__c IN ('P','D')
            AND Active__c = true
            AND Account__r.Status__c = 'Terminated'
            AND Account__r.Recordtype.DeveloperName = 'IATA_Agency'
            ORDER BY Account__r.IATACode__c ASC, Account__r.Name ASC];
        
        String csvContent = getCSVContent(listChangeCode);
        String title = REPORT_NAME + ' - ' + DateTime.now().format('YYYY-MMM-dd') + '.csv';
        createDocument(title, csvContent);
    }
    
    /**
        Create a valid CSV file from input Charge Codes List
    **/
    private String getCSVContent(list<Agency_Applied_Change_code__c> listChangeCodes) {
        String content = BOM_UTF8;
        // addding csv header
        content += getStringHeader();
        // addding csv data
        content += getStringRowData(listChangeCodes);
        return content;
    }
    
    /*
        Get report header name in a single string in CSV format
    */
    private String getStringHeader() {
        map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> accountFields = schemaMap.get('Account').getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> changeCodefields = schemaMap.get('Agency_Applied_Change_code__c').getDescribe().fields.getMap();

        list<String> listHeaders = new list<String>{
            accountFields.get('IATACode__c').getDescribe().getLabel(),
            accountFields.get('Name').getDescribe().getLabel(),
            accountFields.get('Status__c').getDescribe().getLabel(),
            accountFields.get('Expiry_Date__c').getDescribe().getLabel(),
            accountFields.get('IATA_ISO_Country__c').getDescribe().getLabel()
        };
        return String.join(listHeaders,',') + '\n';
    }
    
    /*
        Get report data rows in a single string in CSV format
    */
    private String getStringRowData(list<Agency_Applied_Change_code__c> listChangeCodes) {
        String contentData = '';
        for (Agency_Applied_Change_code__c changeCode: listChangeCodes) {
            list<string> listCells = new list<String>{
                stringToCSV(changeCode.Account__r.IATACode__c),
                stringToCSV(changeCode.Account__r.Name),
                stringToCSV(changeCode.Account__r.Status__c),
                stringToCSV(changeCode.Account__r.Expiry_Date__c),
                stringToCSV(changeCode.Account__r.IATA_ISO_Country__r.Name)
            };
            contentData += String.join(listCells,',') + '\n';
        }
        return contentData;
    }
    
    /**
        Transforms input string in a valid field to be used in a csv file
    **/
    private static String stringToCSV(Date input) {
        return stringToCSV(String.ValueOf(input));
    }
    private static String stringToCSV(String input) {
        if (input==null) return '""';
        return  '"' + input.replace('"','\'') + '"';
    }
    
    /*
        Create a library document
    */
    private void createDocument(String title, String content) {
        Savepoint sp = Database.setSavepoint();
        try {
            String libraryName = ISSP_CS__c.getValues(LIBRARY_CS_NAME).Value__c;
            ContentWorkspace library = [SELECT Id FROM ContentWorkspace WHERE Name = :libraryName];
            
            ContentVersion doc = new ContentVersion();
            doc.Title = title;
            doc.PathOnClient = title;
            doc.VersionData = Blob.valueOf(content);
            insert doc;
            
            doc = [select ContentDocumentId from ContentVersion where id = :doc.id];
            
            ContentWorkspaceDoc docLink = new ContentWorkspaceDoc();
            docLink.ContentDocumentId = doc.ContentDocumentId;
            docLink.ContentWorkspaceId = library.id;
            insert docLink;
        } catch (Exception e) {
            System.debug('ERROR in createDocument: ' + e.getMessage());
            Database.rollback(sp);
        }
    }
}