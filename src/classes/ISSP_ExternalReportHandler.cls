public class ISSP_ExternalReportHandler {

    public static void beforeInsert(List<ISSP_External_Report__c> extRepList) {
        for(ISSP_External_Report__c er : extRepList) {

        	//check if report id is configured to be used
        	List<ISSP_External_Reports_Config__c> externalReportSetting = [SELECT Portal_Service_ID__c FROM ISSP_External_Reports_Config__c WHERE Report_ID__c = :er.Report_ID__c LIMIT 1];

        	if(externalReportSetting.isEmpty()) {
        		er.addError('Report Id \'' + er.Report_ID__c + '\' is not configured to be used');
        	}
        }
    }
    
    public static void afterInsert(List<ISSP_External_Report__c> extRepList) {
        for(ISSP_External_Report__c er : extRepList) {       
            setExternalRecordSharing(er);	
        }
    }

    private static void setExternalRecordSharing(ISSP_External_Report__c er) {
    	//Handling sharing settings for Contacts related to the givin Account
        List<Contact> SharingContacts_List = new List<Contact>([select Id , Name , AccountID From Contact Where AccountId = :er.Account__c OR Account.Top_Parent__c = :er.Report_ID__c]);

        if (!SharingContacts_List.isEmpty()) {
                
            Set<Id> ContactIDs_set = new Set<Id>();
            Set <Id> contactIds_haveAccess = new Set<Id>();
            
            for (Contact con : SharingContacts_List) {
                ContactIDs_set.add(con.id);
            } 

            List<ISSP_External_Reports_Config__c> externalReportSetting = [SELECT Portal_Service_ID__c FROM ISSP_External_Reports_Config__c WHERE Report_ID__c = :er.Report_ID__c LIMIT 1];

            String portalServiceId = externalReportSetting[0].Portal_Service_ID__c;

            //Get contacts with access to the portal service
            List <Portal_Application_Right__c> accessList = [SELECT Id, Contact__c FROM Portal_Application_Right__c
                                                                WHERE Portal_Application__c = :portalServiceId
                                                                AND Right__c = 'Access Granted'
                                                                AND Contact__c IN :ContactIDs_set];
            
            if (!accessList.isEmpty()) {

                for (Portal_Application_Right__c thisAccess : accessList) {
                    contactIds_haveAccess.add(thisAccess.Contact__c);
                }
                 
                //Get all users related to contacts
                List<User> UserSharing_List = new List<User>([SELECT ID,EMAIL FROM User WHERE contactid IN: contactIds_haveAccess]);

                //Give access to specific record to User or Group of Users  
                ExternalFilesUtils.setExternalReportsSharingSetting(UserSharing_List, er, 'Read');
                
            }
        }
    }
}