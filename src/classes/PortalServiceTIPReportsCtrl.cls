public with sharing class PortalServiceTIPReportsCtrl {

	/*
	* This class was created for TIP Reports Service 
	* It is based on the existing ISSP_TIP_External_Reports_Controller 
	* and if the page that is using that controller is deleted
	* the controlled should be deleted and the methods  
	* getExpiringLinkIfap and createDocumentTrackerRecord 
	* should be moved to here.
	*/

	public static final String REPORT_TYPE_AMAZON = 'Amazon File';
	public static final String REPORT_TYPE_POWERBI = 'Power BI';

	public static final String PORTAL_ACCESS_GRANTED = 'Access Granted';


	@AuraEnabled(cacheable=false)
	public static TIPReportPageWrapper getTIPReportPageWrapper(){

		TIPReportPageWrapper tipReportPageWrapperToReturn = new TIPReportPageWrapper();
		

		//Check if the current user have access to TIP Reports service
		String userId = UserInfo.getUserId();
		String currentUserContactId;

		if(!String.isBlank(userId)) {
			User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :userId];

			if(currentUser != null) {

				currentUserContactId = currentUser.ContactId;

				if (!String.isBlank(currentUserContactId)) {
					List <Portal_Application_Right__c> appList = [SELECT Id FROM Portal_Application_Right__c
																  WHERE Portal_Application__r.Name LIKE 'TIP Reports%'
																  AND Right__c = :PORTAL_ACCESS_GRANTED
																  AND Contact__c = :currentUserContactId];
					
					if (!appList.isEmpty()) {
						tipReportPageWrapperToReturn.haveAccessToTIPReports = true;
					}
				}
			}
		}
		
		//if user have access to the service, create the reports list
		if(tipReportPageWrapperToReturn.haveAccessToTIPReports){

			//get the reports from the metadata list
			tipReportPageWrapperToReturn.lstTIPReports.addAll(getMetadataReports());

			//get the reports from the amazon
			tipReportPageWrapperToReturn.lstTIPReports.addAll(getAmazonReports(currentUserContactId));

		}
		
		return tipReportPageWrapperToReturn;
	}

	private static List<TIPReportWrapperObject> getMetadataReports(){

		List<TIPReportWrapperObject> lstReportsToReturn = new List<TIPReportWrapperObject>();

		Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

		List<PowerBI_Report_Config__mdt> lstMetadataReports = [SELECT Id,DeveloperName, MasterLabel, Group_Id_Dev__c, Group_Id_Prod__c, 
															   Report_Id_Dev__c, Report_Id_Prod__c
															   FROM PowerBI_Report_Config__mdt WHERE Type__c = 'TIP_report'];

		if(lstMetadataReports != null && !lstMetadataReports.isEmpty()){

			for(PowerBI_Report_Config__mdt metadataReportAux : lstMetadataReports){
				TIPReportWrapperObject tipReportAux = new TIPReportWrapperObject();
				tipReportAux.reportType = REPORT_TYPE_POWERBI;
				tipReportAux.id = metadataReportAux.Id;
				tipReportAux.developerName = metadataReportAux.DeveloperName;
				tipReportAux.masterLabel = metadataReportAux.MasterLabel;

				if(runningInASandbox){
					tipReportAux.groupId = metadataReportAux.Group_Id_Dev__c;
					tipReportAux.reportId = metadataReportAux.Report_Id_Dev__c;
				}else{
					tipReportAux.groupId = metadataReportAux.Group_Id_Prod__c;
					tipReportAux.reportId = metadataReportAux.Report_Id_Prod__c;
				}

				lstReportsToReturn.add(tipReportAux);

			}

		}

		return lstReportsToReturn;
	}

	private static List<TIPReportWrapperObject> getAmazonReports(String currentUserContactId){

		//List that contains amazon files to return 
		List<TIPReportWrapperObject> lstAmazonToReturn = new List<TIPReportWrapperObject>();

		//Check if user have an account and get either the top parent account if exists or the direct user account
		Contact currentUserContact = [SELECT Id, Account.Id, Account.Top_Parent__c
									 FROM Contact WHERE Id = :currentUserContactId];
		System.debug('currentUserContact: ' + currentUserContact);							 
		if(currentUserContact == null && currentUserContact.Account.Id == null && currentUserContact.Account.Top_Parent__c == null){
			return lstAmazonToReturn;
		}
		String userAccountId = currentUserContact.Account.Top_Parent__c != null ? currentUserContact.Account.Top_Parent__c +'' : contact.Account.Id+'';
		System.debug('userAccountId: ' + userAccountId);

		//get the list of available external reports for that account
		Map<Id,ISSP_External_Report__c> mapExternalReports = new Map<Id,ISSP_External_Report__c>([SELECT Id, CreatedDate
			 					  FROM ISSP_External_Report__c
			 					  WHERE Account__c = :userAccountId
								  ORDER BY CreatedDate DESC]);
		System.debug('mapExternalReports: ' + mapExternalReports);

		//Based on amazon available external reports, retrieve the existing links for amazon
		List<AmazonFile__c> lstAmazonFiles = [SELECT Id, Name, CreatedDate, Full_Name_Unique__c, sObject_Id__c
											FROM AmazonFile__c
											WHERE isPublic__c = True AND sObject_Id__c in :mapExternalReports.keySet()
											ORDER BY sObject_Id__c ASC ];
		System.debug('lstAmazonFiles: ' + lstAmazonFiles);

		//Iterate over those links and construct the final list to display in the page
		if(lstAmazonFiles != null && !lstAmazonFiles.isEmpty()){
			for(AmazonFile__c amazonFileAux : lstAmazonFiles){

				TIPReportWrapperObject tipReportObjectAux = new TIPReportWrapperObject();
				tipReportObjectAux.lastModifiedDate = amazonFileAux.CreatedDate;
				tipReportObjectAux.reportType = REPORT_TYPE_AMAZON;
				tipReportObjectAux.id = amazonFileAux.Id;
				tipReportObjectAux.developerName = amazonFileAux.Full_Name_Unique__c;
				tipReportObjectAux.masterLabel = amazonFileAux.Name;
				tipReportObjectAux.isspExternalReportId = amazonFileAux.sObject_Id__c;

				lstAmazonToReturn.add(tipReportObjectAux);
			}
		}

		return lstAmazonToReturn;
	}

	/*
	* Reuses ISSP_TIP_External_Reports_Controller method.
	* If old method is deprecated the contents for getExpiringLinkIfap method should be moved to here. 
	*/
	@AuraEnabled(cacheable=false)
	public static string getExpiringLinkIfap(String fileName){
		return ISSP_TIP_External_Reports_Controller.getExpiringLinkIfap(fileName);
	}
	/*
	* Reuses ISSP_TIP_External_Reports_Controller method.
	* If old method is deprecated the contents for createDocumentTrackerRecord method should be moved to here. 
	*/
	@AuraEnabled(cacheable=false)
	public static void createDocumentTrackerRecord(String fileId, String reportId){
		ISSP_TIP_External_Reports_Controller.createDocumentTrackerRecord(fileId,reportId);
	}

	public class TIPReportPageWrapper {

		@AuraEnabled
		public Boolean haveAccessToTIPReports {get; set;}
		@AuraEnabled
		public List<TIPReportWrapperObject> lstTIPReports{get; set;}

		public TIPReportPageWrapper(){
			this.haveAccessToTIPReports = false;
			this.lstTIPReports = new List<TIPReportWrapperObject>();
		}

		public TIPReportPageWrapper(Boolean haveAccessToTIPReportsAux, List<TIPReportWrapperObject> lstTIPReportsAux){
			this.haveAccessToTIPReports = haveAccessToTIPReportsAux;
			this.lstTIPReports = lstTIPReportsAux;
		}
	}

	public class TIPReportWrapperObject {

		@AuraEnabled
		public DateTime lastModifiedDate {get; set;}
		@AuraEnabled
		public String developerName {get; set;}
		@AuraEnabled
		public String masterLabel {get; set;}
		@auraEnabled
		public String id {get; set;}
		@AuraEnabled
		public String reportType {get; set;}
		@AuraEnabled
		public String groupId {get; set;}
		@AuraEnabled
		public String reportId {get; set;}
		@AuraEnabled
		public String isspExternalReportId {get; set;}

		public TIPReportWrapperObject(){}

	}


}
