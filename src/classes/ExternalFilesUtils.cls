public class ExternalFilesUtils {

	public static void setExternalReportsSharingSetting(List<User> inUserList , ISSP_External_Report__c inNewReport , String inPermissionType)
    {
        List<ISSP_External_Report__Share> externalReportShares  = new List<ISSP_External_Report__Share>();
        
        for (User us : inUserList)
        {
            // Create a new ISSP_External_Report__Share record to be inserted in to the Job_Share table.
            ISSP_External_Report__Share externalReportShare = new ISSP_External_Report__Share();
            
            // Populate the ISSP_External_Report__Share record with the ID of the record to be shared.
            externalReportShare.ParentId = inNewReport.Id;
            
            // Then, set the ID of user or group being granted access.  
            externalReportShare.UserOrGroupId = us.Id;
            
            // Specify  the AccessLevel (Edit / Read )
            externalReportShare.AccessLevel = inPermissionType;  
    
            // Add the new Share record to the list of new Share records.
            externalReportShares.add(externalReportShare);
        }
    
        // Insert all of the newly created Share records and capture save result 
        Database.SaveResult[] jobShareInsertResult = Database.insert(externalReportShares,false);
    }
}