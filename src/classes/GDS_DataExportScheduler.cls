global with sharing class GDS_DataExportScheduler implements Schedulable{
    
    private static final String BOM_UTF8 = EncodingUtil.convertFromHex('EFBBBF').toString();
    public static final String REPORT_NAME = 'Terminated Agents - Global';
    public static final String LIBRARY_NAME = 'Travel Agent';

    public GDS_DataExportScheduler() {
    }

    global void execute(SchedulableContext SC) {
        runProcess();
   	}
    
    public void runProcess() {
        Reports.ReportResults report = runReport(REPORT_NAME);
        String csvContent = getCSVContent(report);
        String title = REPORT_NAME + ' - ' + DateTime.now().format('YYYY-MMM-dd') + '.csv';
        createDocument(title, csvContent);
    }
    
    /**
        Create a valid CSV file for input report name
    **/
    private String getCSVContent(Reports.ReportResults report) {
        String content = BOM_UTF8;
        // addding csv header
        content += getStringHeader(report);
        // addding csv data
        content += getStringRowData(report);
        return content;
    }
    
    /**
        Find and execute a report based on the input name
    **/
    private Reports.ReportResults runReport(String reportName) {
        Report report = [SELECT Id FROM Report WHERE Name = :reportName];
        return Reports.ReportManager.runReport(report.id, true);
    }
    
    /*
        Get report header name in a single string in CSV format
    */
    private String getStringHeader(Reports.ReportResults report) {
        list<String> listHeaders = new list<String>();
        for (String colName: report.getreportMetadata().getdetailColumns()) {
            String header = report.getreportExtendedMetadata().getdetailColumnInfo().get(colName).getLabel();
            listHeaders.add(stringToCSV(header));
        }
        return String.join(listHeaders,',') + '\n';
    }
    
    /*
        Get report data rows in a single string in CSV format
    */
    private String getStringRowData(Reports.ReportResults report) {
        String contentData = '';
        String factMapKey =  'T!T';
        Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)report.getFactMap().get(factMapKey);
        for (Reports.ReportDetailRow detailRow: factDetails.getRows()  ) {
            list<string> listCells = new list<String>();
            for (Reports.ReportDataCell dataCell: detailRow.getDataCells()  ) {
                listCells.add(stringToCSV(dataCell.getLabel()));
            }
            contentData += String.join(listCells,',') + '\n';
        }
        return contentData;
    }
    
    /**
        Transforms input string in a valid field to be used in a csv file
    **/
    private static String stringToCSV(String input) {
        return  '"' + input.replace('"','\'') + '"';
    }
    
    /*
        Create a library document
    */
    private void createDocument(String title, String content) {
        Savepoint sp = Database.setSavepoint();
        try {
            ContentWorkspace library = [SELECT Id FROM ContentWorkspace WHERE Name = :LIBRARY_NAME];
            
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