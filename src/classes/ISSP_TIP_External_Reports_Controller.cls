public with sharing class ISSP_TIP_External_Reports_Controller {

	public List<ISSP_External_Report__c> externalReportsList {get;set;}
	public Map<Id, List<AmazonFile__c>> externalReportsMap {get;set;}
	private List<ISSP_External_Report__c> externalReportsListAux;
	private List<AmazonFile__c> amazonFileListAux;
	public static final AmazonCredentials CREDENTIALS = AmazonCredentials.getCredentials('GenericAttach');
	public static final String SEPARATOR = '/';
    

	public PageReference init() {

		//check if user has access to TIP Report
        PageReference pr = new PageReference('/ISSP_Homepage');

        String userId = UserInfo.getUserId();
        String contactId;

        if(!String.isBlank(userId)) {
            List <User> userList = [SELECT Id, ContactId FROM User WHERE Id = :userId];

            if(!userList.isEmpty()) {

                contactId = userList[0].ContactId;

                if (contactId != null && contactId != '') {
                    List <Portal_Application_Right__c> appList = [SELECT Id FROM Portal_Application_Right__c
					                                              WHERE Portal_Application__r.Name LIKE 'TIP Reports%'
																		AND Right__c = 'Access Granted'
																		AND Contact__c = :contactId];
                    if (appList.isEmpty()) {
                        return pr;
                    }
                }
                else{
                    return pr;
                }
            }
            else{
                return pr;
            }
        }
        else{
            return pr;
        }

		externalReportsListAux = new List<ISSP_External_Report__c>();
		externalReportsList = new List<ISSP_External_Report__c>();

		//List<User> userList = [SELECT Id, ContactId FROM User WHERE Id = :Userinfo.getUserId()];
		//Id contactId = userList.isEmpty() ? null : userList[0].ContactId;
		Id accountId;

		List<Contact> contactList = [SELECT Id,
											Account.Id,
											Account.Top_Parent__c
									 FROM Contact
									 WHERE Id = :contactId];

		Contact contact = contactList.isEmpty() ? null : contactList[0];

		if(contact != null) {
			if(contact.Account.Top_Parent__c != null) {
				accountId = contact.Account.Top_Parent__c;
			} else {
				accountId = contact.Account.Id;
			}
		}

		externalReportsListAux = [SELECT Id, CreatedDate
			 					  FROM ISSP_External_Report__c
			 					  WHERE Account__c = :accountId
								  ORDER BY CreatedDate DESC];

		Set<Id> externalReportIds = new Set<Id>();

		for(ISSP_External_Report__c er : externalReportsListAux) { 
			externalReportIds.add(er.Id);	
		}	


		List<AmazonFile__c> amazonFileList = [SELECT Id, Name, CreatedDate, Full_Name_Unique__c, sObject_Id__c 
		 					   				  FROM AmazonFile__c
		 					   				  WHERE isPublic__c = True AND sObject_Id__c in :externalReportIds];

		Map<Id, List<AmazonFile__c>> amazonFileMap = new Map<Id, List<AmazonFile__c>>();

		for(AmazonFile__c af : amazonFileList) {
			if(amazonFileMap.containsKey(af.sObject_Id__c)) {
				amazonFileListAux = amazonFileMap.get(af.sObject_Id__c);
			}
			else {
				amazonFileListAux = new List<AmazonFile__c>();
			}
			amazonFileListAux.add(af);
			amazonFileMap.put(af.sObject_Id__c, amazonFileListAux);	
		}

		externalReportsMap = new Map<Id, List<AmazonFile__c>>();

		for(ISSP_External_Report__c er : externalReportsListAux) {
			if(amazonFileMap.get(er.Id) != null) {
				externalReportsMap.put(er.Id, amazonFileMap.get(er.Id));
				externalReportsList.add(er);
			}
		}

		return null;
	}


	@remoteAction
    public static string getExpiringLinkIfap(string fileName) {
        return  genPublicExpiringAWSLinkIFAP(CREDENTIALS.Bucket + SEPARATOR, fileName);
    }


    private static string genPublicExpiringAWSLinkIFAP(string path, string filename) {

        string  stringToSplit = '/'+filename;
        list<string> splittedName = stringToSplit.split('/');
        splittedName.remove(0);
        string encoded;
        for(string dirNm:splittedName)
            encoded+=  EncodingUtil.urlENcode(dirNm,'UTF-8') +'/';
        encoded = encoded.substring(0,encoded.length()-1).replaceAll('null','');

        Decimal timeInMili = Math.floor(System.now().getTime()/1000)+300;
        string check = string.valueof(timeInMili);
        if(check.indexOf('E') <> -1)    {
            check =check.substring(0,check.indexOf('E')).replace('.', '');
            check +='9';
        }
        long timeOut= Long.ValueOf(check);

        string stringToSign = 'GET\n\n\n' + timeOut+ '\n/' + path+ encoded ;//+ filename;
        string signature = make_sig(stringToSign);
        string queryString = '?AWSAccessKeyId=' + CREDENTIALS.AWSAccessKeyId + '&Expires=' + timeOut+ '&Signature=' + signature;


        PageReference page = new PageReference(CREDENTIALS.EndpointBaseURL + path+encoded );
        map<String,String> params = page.getParameters();
        params.put('AWSAccessKeyId', CREDENTIALS.AWSAccessKeyId);
        params.put('Expires', String.ValueOf(timeOut));
        params.put('Signature', signature);

        String result = page.getUrl();
       //  throw new transformationexception(''+result);
        system.debug('stringToSign  '+  stringToSign + '  queryString  ' + queryString + '   result '  + result );

        return   result ;
     }


     @remoteAction
     public static void createDocumentTrackerRecord(string fileId, string reportId) {
     	ISSP_Document_Tracker__c tracker = new ISSP_Document_Tracker__c(Amazon_File__c = fileId,
     																	Report_Id__c = reportId,
                                                            			User__c = UserInfo.getUserId(),
                                                            			Type__c = 'TIP Report');
        insert tracker;
     }


     private static String make_sig(string canonicalBuffer) {
        String macUrl ;
        String signingKey = EncodingUtil.base64Encode(Blob.valueOf(CREDENTIALS.Secret));
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(CREDENTIALS.Secret));
        macUrl = EncodingUtil.base64Encode(mac);
        return macUrl;
    }
}