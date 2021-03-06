public with sharing class PortalServiceTIPReportsCtrl {

	/*
	* This class was created for TIP Reports Service 
	* It is based on the previously existing ISSP_TIP_External_Reports_Controller
	* The methods genPublicExpiringAWSLinkIFAP, make_sig and createDocumentTrackerRecord 
	* were moved from the old class. 
	*/

	public static final String REPORT_TYPE_AMAZON = 'Amazon File';
	public static final String REPORT_TYPE_POWERBI = 'Power BI';

	public static final String REPORT_TYPE_AMAZON_LABEL = Label.CSP_Service_TIPReports_AmazonType;
	public static final String REPORT_TYPE_POWERBI_LABEL = Label.CSP_Service_TIPReports_PBIType;

	public static final String PORTAL_ACCESS_GRANTED = 'Access Granted';
	public static final String SEPARATOR = '/';

	public static final String SERVICE_TIP_REPORTS = 'service-tipreports';
	public static final String SERVICE_AIRLINE_DAILY_SALES = 'airline-daily-sales';
	public static final String SERVICE_SMART_LITE = 'smart-lite';

	public static final Map<String,String> MAP_SERVICENAMES_PER_PAGENAME = new Map<String,String>{
		SERVICE_TIP_REPORTS => 'TIP Reports%',
		SERVICE_AIRLINE_DAILY_SALES => 'Airline Daily Sales',
		SERVICE_SMART_LITE => 'SMART Lite'
	};

	public static final Map<String,String> MAP_REPORTYPE_PER_PAGENAME = new Map<String,String>{
		SERVICE_TIP_REPORTS => 'TIP_report',
		SERVICE_AIRLINE_DAILY_SALES => 'Airline Daily Sales',
		SERVICE_SMART_LITE => 'SMART_Lite'
	};

	public static final Map<String,String> MAP_TRACKERTYPE_PER_PAGENAME = new Map<String,String>{
		SERVICE_TIP_REPORTS => 'TIP Report',
		SERVICE_AIRLINE_DAILY_SALES => 'Airline Daily Sales',
		SERVICE_SMART_LITE => 'SMART Lite'
	};

	@AuraEnabled(cacheable=false)
	public static TIPReportPageWrapper getTIPReportPageWrapper(String pageName){
		TIPReportPageWrapper tipReportPageWrapperToReturn = new TIPReportPageWrapper();

		//Check if the current user have access to TIP Reports service
		String userId = UserInfo.getUserId();
		String currentUserContactId;
		String serviceName = MAP_SERVICENAMES_PER_PAGENAME.get(pageName);

		if(!String.isBlank(userId) || !String.isBlank(serviceName)) {
			User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :userId];

			if(currentUser != null) {
				currentUserContactId = currentUser.ContactId;

				if (!String.isBlank(currentUserContactId)) {
					List <Portal_Application_Right__c> appList = [SELECT Id FROM Portal_Application_Right__c
																  WHERE Portal_Application__r.Name LIKE :serviceName
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
			tipReportPageWrapperToReturn.lstTIPReports.addAll(getMetadataReports(pageName));

			//get the reports from the amazon
			if (pageName == SERVICE_TIP_REPORTS) {
				tipReportPageWrapperToReturn.lstTIPReports.addAll(getAmazonReports(currentUserContactId));
			}
		}
		
		return tipReportPageWrapperToReturn;
	}

	/*
	* Method for retrieve reports from Custom Metadata Type
	*/
	private static List<TIPReportWrapperObject> getMetadataReports(String pageName){

		List<TIPReportWrapperObject> lstReportsToReturn = new List<TIPReportWrapperObject>();

		String reportType = MAP_REPORTYPE_PER_PAGENAME.get(pageName);
		if (String.isEmpty(reportType)) return lstReportsToReturn;

		//check if the code is running in a sandbox
		Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

		//Queries the specific metadata object having the Type for the type associated to the given page
		List<PowerBI_Report_Config__mdt> lstMetadataReports = [SELECT Id,DeveloperName, MasterLabel, Group_Id_Dev__c, Group_Id_Prod__c, 
															   Report_Id_Dev__c, Report_Id_Prod__c, LastModifiedDate__c
															   FROM PowerBI_Report_Config__mdt WHERE Type__c = :reportType];

		//If contains record, create a wrapper for each one to return to the page
		if(lstMetadataReports != null && !lstMetadataReports.isEmpty()){

			for(PowerBI_Report_Config__mdt metadataReportAux : lstMetadataReports){
				TIPReportWrapperObject tipReportAux = new TIPReportWrapperObject();
				tipReportAux.reportType = REPORT_TYPE_POWERBI;
				tipReportAux.reportTypeLabel = REPORT_TYPE_POWERBI_LABEL;
				tipReportAux.id = metadataReportAux.Id;
				tipReportAux.developerName = metadataReportAux.DeveloperName;
				tipReportAux.masterLabel = metadataReportAux.MasterLabel;
				tipReportAux.groupId = runningInASandbox ? metadataReportAux.Group_Id_Dev__c : metadataReportAux.Group_Id_Prod__c;
				tipReportAux.reportId = runningInASandbox ? metadataReportAux.Report_Id_Dev__c :  metadataReportAux.Report_Id_Prod__c;
				tipReportAux.lastModifiedDate = metadataReportAux.LastModifiedDate__c;

				lstReportsToReturn.add(tipReportAux);
			}
		}

		return lstReportsToReturn;
	}

	/*
	* Method for retrieve amazon files list for the user
	*/
	private static List<TIPReportWrapperObject> getAmazonReports(String currentUserContactId){

		//List that contains amazon files to return 
		List<TIPReportWrapperObject> lstAmazonToReturn = new List<TIPReportWrapperObject>();

		//Check if user have an account and get either the top parent account if exists or the direct user account
		Contact currentUserContact = [SELECT Id, Account.Id, Account.Top_Parent__c
									 FROM Contact WHERE Id = :currentUserContactId];
		if(currentUserContact.Account.Id == null && currentUserContact.Account.Top_Parent__c == null){
			return lstAmazonToReturn;
		}
		Id userAccountId = currentUserContact.Account.Top_Parent__c != null ? currentUserContact.Account.Top_Parent__c : currentUserContact.Account.Id;

		//get the list of available external reports for that account
		Map<Id,ISSP_External_Report__c> mapExternalReports = new Map<Id,ISSP_External_Report__c>([SELECT Id, CreatedDate
			 					  FROM ISSP_External_Report__c
			 					  WHERE Account__c = :userAccountId
								  ORDER BY CreatedDate DESC]);

		//Based on amazon available external reports, retrieve the existing links for amazon
		List<AmazonFile__c> lstAmazonFiles = [SELECT Id, Name, CreatedDate, Full_Name_Unique__c, sObject_Id__c
											FROM AmazonFile__c
											WHERE isPublic__c = True AND sObject_Id__c in :mapExternalReports.keySet()
											ORDER BY sObject_Id__c ASC ];

		//Iterate over those links and add the wrapper list to display in the page
		if(lstAmazonFiles != null && !lstAmazonFiles.isEmpty()){
			for(AmazonFile__c amazonFileAux : lstAmazonFiles){

				TIPReportWrapperObject tipReportObjectAux = new TIPReportWrapperObject();
				tipReportObjectAux.lastModifiedDate = amazonFileAux.CreatedDate;
				tipReportObjectAux.reportType = REPORT_TYPE_AMAZON;
				tipReportObjectAux.reportTypeLabel = REPORT_TYPE_AMAZON_LABEL;
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
	* Returns a link for the requested amazon file
	*/
	@AuraEnabled(cacheable=false)
	public static string getExpiringLinkIfap(String fileName){
		AmazonCredentials credentials = AmazonCredentials.getCredentials('GenericAttach');
		return genPublicExpiringAWSLinkIFAP(credentials, fileName);
	}

	/*
	* Construct the link to the amazon file based on the amazon credentials and the requested filename.
	*/
	private static string genPublicExpiringAWSLinkIFAP(AmazonCredentials credentials, string filename) {
		String path = credentials.Bucket + SEPARATOR;
		list<string> splittedName = filename.split('/');
		String encoded = '';

		for(String dirNm : filename.split(SEPARATOR )){
			encoded += EncodingUtil.urlENcode(dirNm,'UTF-8') +SEPARATOR ;
		}
		encoded = encoded.removeEnd(SEPARATOR);

		Decimal timeInMili = Math.floor(System.now().getTime()/1000)+300;
		string check = string.valueof(timeInMili);
		if(check.indexOf('E') <> -1)    {
			check =check.substring(0,check.indexOf('E')).replace('.', '');
			check +='9';
		}
		long timeOut= Long.ValueOf(check);

		string stringToSign = 'GET\n\n\n' + timeOut+ '\n/' + path+ encoded ;//+ filename;
		string signature = make_sig(credentials,stringToSign);
		string queryString = '?AWSAccessKeyId=' + credentials.AWSAccessKeyId + '&Expires=' + timeOut+ '&Signature=' + signature;

		PageReference page = new PageReference(credentials.EndpointBaseURL + path+encoded );
		map<String,String> params = page.getParameters();
		params.put('AWSAccessKeyId', credentials.AWSAccessKeyId);
		params.put('Expires', String.ValueOf(timeOut));
		params.put('Signature', signature);

		String result = page.getUrl();
		return result ;
	}

	/*
	* Creates the hash to include in the link
	*/
	private static String make_sig(AmazonCredentials credentials,string canonicalBuffer) {
		String macUrl;
		String signingKey = EncodingUtil.base64Encode(Blob.valueOf(CREDENTIALS.Secret));
		Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(CREDENTIALS.Secret));
		macUrl = EncodingUtil.base64Encode(mac);
		return macUrl;
	}

	/*
	* Creates a tracker record so the business have knowledge the user clicked on the amazon file report
	*/
	@AuraEnabled(cacheable=false)
	public static void createDocumentTrackerRecord(String fileId, String reportId, String pageName){
		ISSP_Document_Tracker__c tracker = new ISSP_Document_Tracker__c(Amazon_File__c = fileId,
	 																	Report_Id__c = reportId,
																		User__c = UserInfo.getUserId(),
																		Type__c = MAP_TRACKERTYPE_PER_PAGENAME.get(pageName));
		insert tracker;
	}

	//Wrapper class to return access to page and the list of reports 
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
		public String reportTypeLabel {get;set;}
		@AuraEnabled
		public String groupId {get; set;}
		@AuraEnabled
		public String reportId {get; set;}
		@AuraEnabled
		public String isspExternalReportId {get; set;}
	}

}
