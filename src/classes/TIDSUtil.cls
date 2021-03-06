public without sharing class TIDSUtil{

	private static Id tidsrecordtypeId {get;set;} 
	public static ErrorWrapper iataCodeError {get;set;}
	public static List<String> replaceby {get;set;}
	private static TIDS_Error_Message__mdt metadata;
	public static List<Case> cases {get;set;}
	 
	public class ErrorWrapper {
		@AuraEnabled public String caseId='';
		@AuraEnabled public String reason='';
		@AuraEnabled public String info='';
		@AuraEnabled public Boolean hasAnError=false;
		@AuraEnabled public TIDS_Error_Message__mdt error= new TIDS_Error_Message__mdt();
		@AuraEnabled public Date reinstamentDeadline=null;
		@AuraEnabled public Boolean hasReinstatementDeadline=false;
	}
	//Gets the RecordtypeId for TIDS case
	public static Id getTidsRecordTypeId(){
		if (tidsrecordtypeId==null){
			tidsrecordtypeId=RecordTypeSingleton.getInstance().getRecordTypeId('Case', TIDS_Constant.TIDSVALUE);
		}
		return tidsrecordtypeId;
	}
	//Updates the case status 
	//if the update fails it is catch by calling function 
	public static void changeCaseStatus(String caseStatus, String userId){
		if (cases.size()==0){
			return;
		}
		Case tidsCase = new Case();
		tidsCase = cases[0];
		tidsCase.Origin = TIDS_Constant.CASE_ORIGIN;
		tidsCase.CaseArea__c = TIDS_Constant.CASE_AREA;
		tidsCase.Priority = TIDS_Constant.CASE_PRIORITY;
		if (caseStatus==TIDS_Constant.IS_INPROGRESS){
			if (tidsCase.Status == TIDS_Constant.IS_REVIEWED){
				tidsCase.OwnerId=userId;
			}
		}
		tidscase.Status = caseStatus;
		update tidsCase;
		
	}
	//Reads the case record if isDraft is true the will search for any TIDS case with the same
	//Account to reuse the Draft cases
	public static void getTidsCases(string objectId, boolean isDraft){
		cases = new List<Case>();
		if (isDraft){
			Case mycase = searchCase(objectId, TIDS_Constant.IS_DRAFT);
			if (mycase==null){
				return;
			}
			objectId= mycase.Id;
		}
		cases = [SELECT Id
				,CreatedDate
				,CaseNumber
				,Status
				,Decision_Date__c
				,Decision__c
				,BSPCountry__c
				,Reason1__c
				,Customer_recovery__c
				,BounceEmailCounter__c
				,Case_Language__c
				,Subject
				,Reopened_case__c
				,Account_Concerned__c
				,IFAP_Country_ISO__c
				,AccountId
				,Account.IATACode__c
				,Account.RecordType.DeveloperName
				,Account.RecordType.Name
				,ContactId
				,ContactEmail
				,RecordTypeId
				,Account.Location_Class__c
				,Account.Location_Type__c
				,Account.Country_ISO_Code__c
				,Account.Email__c
				,Account.Parent.Email__c
				,Ownerid
				,Previous_case_owner__c
				,Last_Status_Change__c
				,Origin
				,CaseArea__c
				,Priority
		  FROM Case
		  WHERE Id=:objectId
		  Limit 1];
	}
	//Sets the error based on the metadata description or provided error message
	public static void setError(String msg, boolean isexecution){
		if (isexecution) {
			iataCodeError.reason = msg;
		} else {
			iataCodeError.reason = getTIDSMetadataError(msg);
		}
		iataCodeError.hasAnError = true;
	}
	//Gets the business profile
	public static List<AMS_Agency_Profile__c> tidsBusinessProfile(String accountId){
		List<AMS_Agency_Profile__c> businessProfile = [SELECT Id, 
							GR_Code__c, 
							GR_Item__c
							FROM AMS_Agency_Profile__c
							WHERE Account__c=:accountId];
		return businessProfile;
	}
	//Gets all the sholderholders with the percentage and Owners
	//Active=true will be displayed only and kept
	//Active=false will be deleted
	public static List<AMS_Account_Role__c> tidsShareholders(String accountId, boolean isActiveOnly, boolean isOnlyOwnership){
		boolean isActive=true;
		boolean isDeactivated=false;
		String query='Select Id, Percentage__c,Owner_Category__c,Owner_Name__c,Owner_Email__c,Account__c,RecordTypeId,Active__c, Owner_Account__c '+
					' From AMS_Account_Role__c Where Account__c=:accountId';
		if (isActiveOnly){
			query +=' and Active__c=true';
		}
		if (isOnlyOwnership){
			final Id ownershipId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
			query +=' and RecordTypeId=\''+ownershipId+'\'';
		}
		List<AMS_Account_Role__c> shareholders = Database.query(query);
		return shareholders;
	  }
	//composes the returned error message  
	public static String ComposeMessage(Database.Error error){
		String errormessage = '';
		if (error != null){
			errormessage = error.getStatusCode() + ': ' + error.getMessage();
		}
		if (error != null){
			errormessage += ' fields that affected this error: ' + error.getFields();
		}
		return errormessage;
	}
	
	//deletes the documents uploaded and not the data.json
	@AuraEnabled(cacheable=false)
	public static boolean deleteFiles(String attachmentid){
		List<Attachment> attachments = getAttachments(false,' WHERE Id=\''+attachmentid+'\' AND (NOT Name LIKE \'%.json\')',' LIMIT 1');
		if (attachments.size() > 0){
			delete attachments;
		}
		return true;
	}
	
	//saves the TIDS Configuration file
	@AuraEnabled(cacheable=false)
	public static void saveTidsConfiguration(String service, String payload){
		Portal_Applications__c services = getTIDSService();
		addAttachment(services.Id, payload, TIDS_Constant.TIDSCONFIGURATIONFILE);
	}
	//reads the tids terms and condition
	@AuraEnabled(cacheable=false)
	public static String getTidsConfiguration(String service){
		Portal_Applications__c services = getTIDSService();
		return getAttachment(services.Id, TIDS_Constant.TIDSCONFIGURATIONFILE);
	}
   //reads the tids configuration
	@AuraEnabled(cacheable=false)
	public static Attachment  getTermsAndConditions(){
		Portal_Applications__c services = getTIDSService();
		List<Attachment> attachments = getAttachments(false,' WHERE parentId=\''+services.id+'\' AND name=\''+TIDS_Constant.TIDSTERMSANDCONDITIONS+'\'',' LIMIT 1');
		if (attachments.size()>0) {
			return attachments[0];
		}
		return null;
	}
	//returns the portal Tids Service Information
	public static Portal_Applications__c getTIDSService(){
		Portal_Applications__c tidsservice = [SELECT Id,Name
				,TIDS_Non_Eligible_Mailing_Countries__c
				,TIDS_Total_Ownership_Minimum__c
				,TIDS_Total_Ownership_Maximum__c
				,TIDS_Countries_with_Invalid_ISO_States__c
				,TIDS_Non_Eligible_Location_Countries__c
			FROM Portal_Applications__c WHERE Name=:TIDS_Constant.TIDSVALUE Limit 1];
		return tidsservice;
	}
	//Returns the configuration .json to drive the menu
	//and the forms (Address, Mailing...)
	public static String getSettings(String parentid, string type){
		if (String.isEmpty(parentid)){
			return null;
		}
		parentid = String.escapeSingleQuotes(parentid.trim());
		//read the settings file
		List<Attachment> newsettings = getAttachments(true,' WHERE parentId=\''+parentid+'\' AND name=\''+type+'\'',' LIMIT 1');
		if (newsettings.size() > 0){
			Blob body = newsettings[0].Body;
			return body.toString();
		}
		// return the Body Content
		return null;
	}
	//Returns the lastest attachment body content
	public static String getAttachment(String parentId, String fileName){
		String result = '';
		if (parentId==null){
			return result;
		}
		List<Attachment> attachments = getAttachments(true, ' WHERE parentId=\''+parentid+'\' AND name=\''+filename+'\'',' ORDER BY CreatedDate DESC LIMIT 1');
		if (attachments.size() > 0){
			result = EncodingUtil.base64Decode(EncodingUtil.base64Encode(attachments.get(0).Body)).toString();
		}
		return result;
	}
	
	//function returns the data.json body content that drives the 
	//data temporary content
	@AuraEnabled(cacheable=false)
	public static documentWrapper relatedFiles(String parentid){
		list<Attachment> lstConDocs = getAttachments(false,' WHERE parentId=\''+parentid+'\' AND (NOT Name LIKE \'%.json\')',' ORDER BY CreatedDate DESC');
		documentWrapper newdoc = new documentWrapper();
		List<Case> cases = new List<Case>(); 
		cases = [Select Id, Status From Case Where Id=:parentid Limit 1];
		newdoc.isError=0;
		if (cases.size()==0) {
			newdoc.isError=1;
		}
		if (cases[0].status==TIDS_Constant.IS_CLOSED) {
			newdoc.isError=2;
		}
		if (newdoc.isError==0) {
			newdoc.documents=lstConDocs;
		}
		return newdoc;
	}
	private static list<Attachment> getAttachments(boolean isBodyIncluded, String selectWhere, String selectOrder){
		list<Attachment> lstConDocs = new List<Attachment>();
		final String selectClause = 'SELECT Id,'+(isBodyIncluded ? 'Body,':'')+'ParentId,isPrivate,Name,CreatedDate, ContentType FROM Attachment '+selectWhere+selectOrder; 
		lstConDocs = Database.query(selectClause);
		return lstConDocs;
	}
  
	//Attachment wrapper
	public class documentWrapper {
	  @AuraEnabled public integer isError;
	  @AuraEnabled public list<Attachment> documents;
	}
	//function that adds the body content as attachments for the
	//documents uploaded
	public static void addAttachment(Id parentId, String payload, String filename){
		Attachment newAttachment = new Attachment();
		List<Attachment> attachments = getAttachments(true,' WHERE parentId=\''+parentid+'\' AND name=\''+filename+'\'',' ORDER BY CreatedDate DESC LIMIT 1');
		if (attachments.size() > 0){
			newAttachment = attachments.get(0);
		}else{
			newAttachment.ParentId=parentId;
			newAttachment.isPrivate=false;
			newAttachment.Name=filename;
		}
		Blob attachmentBody = Blob.valueOf(payload);
		newAttachment.Body = attachmentBody;
		upsert newAttachment;
	}

	//Save the upload file from the supporting document lwc interface
	@AuraEnabled(cacheable=false)
	public static void saveFile(
		string parentid,
		String filename,
		String fileType,
		string base64data,
		boolean isUnique){
		List<Attachment> attachmentlist = new List<Attachment>();
		Attachment attachment1 = new Attachment();
		if (isUnique){
			List<Attachment> newsettings = getAttachments(false,' WHERE parentId=\''+parentid+'\' AND name=\''+filename+'\'',' LIMIT 1');
			if (newsettings.size() > 0){
				attachment1.Id = newsettings[0].Id;
			}
		}
		if (attachment1.Id == null){
			attachment1.Name = filename;attachment1.ParentId = parentid;
		}
		//Blob body = Blob.valueOf(base64data);
		Blob body = EncodingUtil.Base64Decode(base64data);
		attachment1.body = body;
		attachment1.isPrivate=false;
		attachment1.ContentType = fileType;
		Attachmentlist.add(attachment1);
		upsert Attachmentlist;
		string errormessage = '';
		//Collect issue
		Database.UpsertResult[] lsr = Database.upsert(Attachmentlist, false);
		for (Database.UpsertResult sr : lsr){
			if (!sr.isSuccess()){
				for (Database.Error err : sr.getErrors()){
					errormessage += ComposeMessage(err);
				}
			}
		}
		if (errormessage!=''){
			return;
		}
	}
	@AuraEnabled(cacheable=true)
	public static List<ValueLabel> getGDSValues(){
	 	return getPicklistValues('AIRSYS', 'Is_Displayed_Last__c, Name');
	}
	@AuraEnabled(cacheable=true)
	public static List<ValueLabel> getNumberOfEmployees(){
		return getPicklistValues('APEMP', 'Name');
	}

	@AuraEnabled(cacheable=true)
	public static List<ValueLabel> getPreferedLanguages(){
		return getPicklistValues('PREFLANG', 'Name');
	}

	@AuraEnabled(cacheable=true)
	public static List<ValueLabel> getFocusValues(){
		return getPicklistValues('FOCUSVALUES', 'Name');
	}

	@AuraEnabled(cacheable=true)
	public static List<ValueLabel> companyTypes(){
		return getPicklistValues('LGLTYP', 'Name');
	}

	@AuraEnabled(cacheable=true)
	public static List<ValueLabel> mainMarketSpecialization(){
		return getPicklistValues('APSPEC', 'Name');
	}

	@AuraEnabled(cacheable=true)
	public static List<ValueLabel> principalDestination(){
		return getPicklistValues('APDEST','Name');
	}

	@AuraEnabled(cacheable=true)
	public static List<ValueLabel> salesVolume(){
		return getPicklistValues('APSALE', 'Code__c');
	}

	@AuraEnabled(cacheable=true)
	public static List<ValueLabel> mainActivity(){
		return getPicklistValues('APPRAC', 'Name');
	}
	//Gets all the picklistvalues for code table AIRSYS or Non AIRSYS
	public static List<ValueLabel> getPicklistValues(String criteria,String orderBy){
		List<ValueLabel> values = new List<ValueLabel>();
		final String query ='SELECT Name, Code__c, Valid_For_TIDS__c,Corresponding_AMS_Code__c FROM GDP_Reference_Table__c WHERE Table__c = \'' +
									String.escapeSingleQuotes(criteria) +
									'\' AND Valid_For_TIDS__c = true ORDER BY ' +
									String.escapeSingleQuotes(orderBy);
		List<GDP_Reference_Table__c> gdpValues = Database.query(query);
		for (GDP_Reference_Table__c gdpValue : gdpValues){
			if (criteria=='AIRSYS') {
				values.add(new ValueLabel(gdpValue.Corresponding_AMS_Code__c, gdpValue.Name));
			}
			if (criteria!='AIRSYS') {
				values.add(new ValueLabel(gdpValue.Code__c, gdpValue.Name));
			}
		}
		return values;
	}
	public class ValueLabel {
		@AuraEnabled public String value;
		@AuraEnabled public String label;
		public ValueLabel(String xvalue, String xlabel){
			this.value = xvalue;
			this.label = xlabel;
		}
	}
	//Trigger by the process builder conditional to the case conditions and the type
	//of application
	@InvocableMethod
	public static void tidsNotifications(List<String> caseId){
		getTidsCases(caseId[0],false);
		if (cases.size()==0) {
			return;
		}
		Case tidscase = cases[0];
		Id whatId = tidscase.AccountId;
		Id refId = tidscase.ContactId;
		string template;
		
		if (tidscase.Status==TIDS_Constant.IS_CLOSED
			&& tidscase.Decision__c ==TIDS_Constant.DECISION_APPROVED
			&& tidscase.Subject==TIDS_Constant.CASE_SUBJECT_HEAD_OFFICE){
			//HO Approval
			template='TIDS_HO_Approved_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CUSTOMER
			&& String.isEmpty(tidscase.Decision__c)
			&& tidscase.Subject==TIDS_Constant.CASE_SUBJECT_HEAD_OFFICE){
			//HO Incomplete
			whatId= tidscase.Id;
			template='TIDS_HO_Incomplete_Notification';  
		}else if (tidscase.Status==TIDS_Constant.IS_CLOSED
			&& tidscase.Decision__c ==TIDS_Constant.DECISION_REJECTED
			&& tidscase.Subject==TIDS_Constant.CASE_SUBJECT_HEAD_OFFICE){
			//HO Rejected
			whatId= tidscase.Id;
			template='TIDS_HO_Rejected_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CLOSED
		&& tidscase.Decision__c ==TIDS_Constant.DECISION_APPROVED
		&& tidscase.Subject==TIDS_Constant.CASE_SUBJECT_BRANCH){
			//BR Approved
			Account lastbranch = [Select Id FROM Account Where ParentId=:tidscase.AccountId Order by CreatedDate Desc Limit 1]; 
			if (lastbranch!=null) {
				whatId= lastbranch.Id;
			}
			template='TIDS_BR_Approved_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CUSTOMER
		&& String.isEmpty(tidscase.Decision__c)
		&& tidscase.Subject==TIDS_Constant.CASE_SUBJECT_BRANCH){
			//BR Incomplete
			whatId= tidscase.Id;
			template='TIDS_BR_Incomplete_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CLOSED
		&& tidscase.Decision__c ==TIDS_Constant.DECISION_REJECTED
		&& tidscase.Subject==TIDS_Constant.CASE_SUBJECT_BRANCH){
			//BR Rejected
			whatId= tidscase.Id;
			template='TIDS_BR_Rejected_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CLOSED
		&& tidscase.Decision__c ==TIDS_Constant.DECISION_APPROVED
		&& tidscase.Subject==TIDS_Constant.CASE_SUBJECT_VIRTUAL_BRANCH){
			//VB Approved
			Account lastbranch = [Select Id FROM Account Where ParentId=:tidscase.AccountId Order by CreatedDate Desc Limit 1];
			if (lastbranch!=null) {
				whatId= lastbranch.Id;
			}			
			template='TIDS_VB_Approved_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CUSTOMER
		&& String.isEmpty(tidscase.Decision__c)
		&& tidscase.Subject==TIDS_Constant.CASE_SUBJECT_VIRTUAL_BRANCH){
			//VB Incomplete
			whatId= tidscase.Id;
			template='TIDS_VB_Incomplete_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CLOSED
		&& tidscase.Decision__c ==TIDS_Constant.DECISION_REJECTED
		&& tidscase.Subject==TIDS_Constant.CASE_SUBJECT_VIRTUAL_BRANCH){
			//VB Rejected
			whatId= tidscase.Id;
			template='TIDS_VB_Rejected_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CLOSED
		&& tidscase.Decision__c ==TIDS_Constant.DECISION_APPROVED
		&& tidscase.Subject==TIDS_Constant.CASE_SUBJECT_VIRTUAL_ACCREQ){
			// START VB Access Request
			whatId= tidscase.Id;
			template='TIDS_VB_Service_Request_Approved_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CLOSED
		&& tidscase.Decision__c ==TIDS_Constant.DECISION_APPROVED
		&& tidscase.Subject.startsWith('TIDS - Change of') ){
			// START CR Approved
			whatId= tidscase.Id;
			template='TIDS_CR_Approved_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CUSTOMER
		&& String.isEmpty(tidscase.Decision__c)
		&& tidscase.Subject.startsWith('TIDS - Change of') ){
			// START CR Incomplete
			whatId= tidscase.Id;
			template='TIDS_CR_Incomplete_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CLOSED
		&& tidscase.Decision__c==TIDS_Constant.DECISION_REJECTED
		&& tidscase.Subject.startsWith('TIDS - Change of') ){
			// START CR Rejected
			whatId= tidscase.Id;
			template='TIDS_CR_Rejected_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CLOSED
		&& tidscase.Decision__c==TIDS_Constant.DECISION_APPROVED
		&& tidscase.Subject==TIDS_Constant.CASE_SUBJECT_RELINQUISH ){
			// START HO Relinquish
			whatId= tidscase.AccountId;
			template='TIDS_Parent_Relinquishment_Request_Approved_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CLOSED
		&& tidscase.Decision__c==TIDS_Constant.DECISION_APPROVED
		&& (tidscase.Subject==TIDS_Constant.CASE_SUBJECT_BRANCH_RELINQUISH 
			|| tidscase.Subject==TIDS_Constant.CASE_SUBJECT_VIRTUAL_RELINQUISH)){
			// START BR/VB Relinquish
			whatId= tidscase.AccountId;
			template='TIDS_Child_Relinquishment_Request_Approved_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CLOSED
		&& tidscase.Decision__c==TIDS_Constant.DECISION_APPROVED
		&& tidscase.Subject==TIDS_Constant.CASE_SUBJECT_REINSTATE ){
			// START HO Reinstate
			whatId= tidscase.AccountId;
			template='TIDS_HO_Reinstatement_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CLOSED
		&& tidscase.Decision__c==TIDS_Constant.DECISION_APPROVED
		&& tidscase.Subject==TIDS_Constant.CASE_SUBJECT_BRANCH_REINSTATE ){
			// START BR Reinstate
			whatId= tidscase.AccountId;
			template='TIDS_BR_Reinstatement_Notification';
		}else if (tidscase.Status==TIDS_Constant.IS_CLOSED
		&& tidscase.Decision__c==TIDS_Constant.DECISION_APPROVED
		&& tidscase.Subject==TIDS_Constant.CASE_SUBJECT_VIRTUAL_REINSTATE ){
			// START VB Reinstate
			whatId= tidscase.AccountId;
			template='TIDS_VB_Reinstatement_Notification';
		}
		//no template found for this conditions
		if (string.isEmpty(template)) {
			return;
		}

		sendNotification(whatId,
						refId, 
						getEmailTemplateId(template),  
						getTIDSMetadataError(TIDS_Constant.TIDS_ADM_EMAIL));
	}

	//Return the email Template Id
	public static Id getEmailTemplateId(string emailTemplate){
		List<EmailTemplate> emailtemp = [SELECT Id
		  FROM EmailTemplate
		  WHERE DeveloperName =:emailTemplate LIMIT 1];
		if (emailtemp.size()==0) {
			return null;
		}
		return emailtemp[0].Id;
	}	
	//Sends notifications to the client
	public static void sendNotification(Id whatId, Id refId, Id templateId, String tidsadminemail ){
		if (!String.isBlank(templateId)) {
			postNotification(whatId, refId, templateId, null, tidsadminemail);
		}
	}
	//Physically post the email using template or body content
	//If the refId is not informed the email goes to the Tids admin
	public static void postNotification(Id whatId, Id refId, Id templateId, List<String> bodyContent, String tidsadminemail){
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
		owea = [select Id from OrgWideEmailAddress where Address =:tidsadminemail Or DisplayName=:tidsadminemail Limit 1];
		if (owea.size() > 0){
			email.setOrgWideEmailAddressId(owea[0].Id);
		}
		if (!String.isBlank(templateId)){
			email.setTemplateId(templateId);
			email.setTargetObjectId(refId);
			email.setWhatId(whatId);
		}else{
			email.setSubject(bodyContent[0]);
			email.setPlainTextBody(bodyContent[1]);
			email.setToAddresses(new List<String>{tidsadminemail});
		}
		Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
	}
	
	//TIDS metat data retrieve function
	//Replace elements in the data
	public static string getTIDSMetadataError(String errorCondition){
		getTIDSMetadata(errorCondition);
		if (metadata.Visit_URL__c!=null) {
			return metadata.Visit_URL__c;
		}
		return metadata.Subtitle__c;
	}
	//Gets the TIDSMetadata record based on the error Condition (developername)
	public static TIDS_Error_Message__mdt getTIDSMetadata(String errorCondition){
		List<TIDS_Error_Message__mdt> metadatas = new List<TIDS_Error_Message__mdt>();
		metadata = new TIDS_Error_Message__mdt();
		metadatas = [SELECT
				Id,
				DeveloperName,
				Subtitle__c,
				Description__c,
				Description_P2__c,
				Description_P3__c,
				Create_a_Case__c,
				Close_Vetting__c,
				Open_A_Case_Text__c,
				Visit_URL__c,
				Visit_A_Website_Text__c,
				Discard_Application__c,
				Resume_Application__c,
				Recall_Application__c,
				Yellow_Section_Header__c,
				Yellow_Section_Text__c
			FROM TIDS_Error_Message__mdt
			WHERE DeveloperName=:errorCondition LIMIT 1];
		
		if (metadatas.size()==0) {
			return metadata;
		}
		metadata=metadatas[0];
		if (replaceby!=null){
			contentReplace();
		}
		return metadata;
	}
	//replaces the content information for the conditions
	private static void contentReplace(){
		metadata.Subtitle__c = contentInfo(metadata.Subtitle__c);
		metadata.Description__c = contentInfo(metadata.Description__c);
		metadata.Description_P2__c= contentInfo(metadata.Description_P2__c);
		metadata.Description_P3__c= contentInfo(metadata.Description_P3__c);
	}
	private static String obfuscateEmail(String element){
		if (element.length()<3 && !element.Contains('@')){
			return element;
		}
		string[] parts = element.split('@');
		integer length = parts[0].length();		
		integer middle = Math.round(length / 2);
		integer left =2;
		integer right=2;
		if (length==1 || length==2){
			left=0;
			right=0;
		}else if (length==3){
			left=1;
			right=0;
		}else if (length==4){
			left=1;
			right=1;
		}
		if (length!=0){
			final string afters = '*'.repeat(length-middle-left);
			final string befores= '*'.repeat(middle-left);
			final string part1 = parts[0].substring(middle-left, middle+right);
			element = befores+part1+afters+'@'+parts[1];
		}	
		return element;
	}
	//Changes the content based on the email, case, Status...values of the case
	private static String contentInfo(String content){
		if (String.isEmpty(content)) {return content;}
		integer i=0;
		List<String> toreplace = new List<String>{'{@email}','{@Case}','{@Case Status}','{@ApplicationDecision}','{@CreatedDate}'};
		for(String o:toreplace){
			string element = replaceby[i];
			if (element==null) {
				element='';
			}
			if (i==0){
				element = obfuscateEmail(element);
			}
			content=content.replace(o,element);
			i++;
		}
		return content;
	}
	//Creates a case comment
	public static void createCaseComment(boolean ispublished, String caseId, String comments){
		CaseComment c = new CaseComment();
		c.ParentId = caseId;
		c.isPublished  = ispublished;
		c.CommentBody = comments;
		insert c;
	}
	//Grants access to the portal user once the application is officialy approved
	public static void grantTIDSPortalAccess(Id contactId){
		List<Portal_Application_Right__c> portalright = new List<Portal_Application_Right__c>();
		portalright = [SELECT Id,Right__c,Access_Status_Reason__c 
				FROM Portal_Application_Right__c
				WHERE Contact__c = :contactId
					AND Portal_Application__r.Name=:TIDS_Constant.TIDSVALUE
			 	LIMIT 1];
		if (portalright.size() == 0){
			Portal_Applications__c services =getTidsService();
			//grant contact user TIDS portal access
			Portal_Application_Right__c newportalright = new Portal_Application_Right__c();
			newportalright.Contact__c = contactId;
			newportalright.Right__c = AMS_Utils.PORTAL_APP_ACCESS_GRANTED;
			newportalright.Access_Status_Reason__c = TIDS_Constant.ADM_HOP;
			newportalright.Portal_Application__c = services.Id;
			newportalright.Enable_Notifications__c = true;
			insert newportalright;
		}else{
			portalright[0].Right__c = AMS_Utils.PORTAL_APP_ACCESS_GRANTED;
			portalright[0].Access_Status_Reason__c = TIDS_Constant.ADM_HOP;
			update portalright;
		}
	}

	//User information
	public static user getUserData(Id userId){
		List<user> userdata = new List<user>();
		userdata = [SELECT
			Id,
			Name,
			ContactId,
			AccountId,
			Account.ParentId,
			Account.RecordType.DeveloperName,
			Account.RecordType.Name,
			Account.Country_ISO_Code__c,
			Account.Location_Class__c,
			Account.Location_Type__c,
			Account.Status__c,
			Account.Email__c,
			Account.Parent.Email__c,
			Account.Expiry_Date__c
		FROM User
		WHERE Id=:userId
		LIMIT 1];
		return  userdata[0];
	}
	//lookup case based on the status
	public static Case searchCase(String accountId, String caseStatus){
		Case tidscase = new Case();
		List<Case> cases = [SELECT Id, AccountId, RecordTypeId, Status
			FROM Case
			WHERE Status=:caseStatus
				AND AccountId=:accountId
				AND RecordTypeId=:TIDSUtil.getTidsRecordTypeId() LIMIT 1];
		if (cases.size() > 0){
			tidscase = cases[0];
		}
		return tidscase;
	}
}