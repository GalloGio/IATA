
public without sharing class TIDSUtil{
   
    private static Id tidsrecordtypeId {get;set;} 
    public static ErrorWrapper iataCodeError {get;set;}
    public class ErrorWrapper {
		@AuraEnabled public String reason = '';
		@AuraEnabled public Boolean hasAnError = false;
		@AuraEnabled public TIDS_Error_Message__mdt error = new TIDS_Error_Message__mdt();
		@AuraEnabled public Date reinstamentDeadline = null;
		@AuraEnabled public Boolean hasReinstatementDeadline = false;
    }
    public static Id getTidsRecordTypeId(){
        if (tidsrecordtypeId==null){tidsrecordtypeId=RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'TIDS');}
        return tidsrecordtypeId;
    }
    public static List<Case> getTidsCases(string objectId, boolean isDraft){
        List<Case> cases = new List<Case>();
        if (!Schema.sObjectType.Case.isAccessible()){setError('Case is not accessible.'); return cases;}
        if (isDraft){
			cases = [SELECT Id
				FROM Case
				WHERE AccountId=:objectId
					AND RecordTypeId=:getTidsRecordTypeId()
					AND Status = 'Draft' LIMIT 1];
			if (cases.size()==0){return cases;}
			objectId=cases[0].id;
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
              ,RecordTypeId
              ,Account.Location_Class__c
              ,Account.Location_Type__c
              ,Account.Country_ISO_Code__c
              ,Account.Email__c
              ,Account.Parent.Email__c
              ,Ownerid
              ,Previous_case_owner__c
              ,Last_Status_Change__c
          FROM Case
          WHERE Id=:objectId
          Limit 1];
          return cases;
      }

    public static void setError(String msg){
        iataCodeError.reason = msg;
        iataCodeError.hasAnError = true;
    }

    public static List<AMS_Agency_Profile__c> tidsBusinessProfile(String accountId){
        List<AMS_Agency_Profile__c> businessProfile = [SELECT Id, 
                            GR_Code__c, 
                            GR_Item__c
                            FROM AMS_Agency_Profile__c
                            WHERE Account__c=:accountId];
        return businessProfile;
    }

    public static List<AMS_Account_Role__c> tidsShareholders(String accountId){
        List<AMS_Account_Role__c> shareholders = [SELECT Id, 
                Percentage__c, 
                Owner_Category__c, 
                Owner_Name__c, 
                Owner_Email__c,
                Account__c, 
                RecordTypeId, 
                Owner_Account__c 
          FROM AMS_Account_Role__c
          WHERE Account__r.Id=:accountId];
          
        return shareholders;
      }
    public static String ComposeMessage(Database.Error error){
		String errormessage = '';
		if (error != null){errormessage = error.getStatusCode() + ': ' + error.getMessage();}
		if (error != null){errormessage += ' fields that affected this error: ' + error.getFields();}
		return errormessage;
    }
    
    @AuraEnabled(cacheable=false)
	public static boolean deleteFiles(String attachmentid){
		if (!Schema.sObjectType.Attachment.isDeletable()){return false;}
		list<Attachment> lstConDocs = new List<Attachment>();
		lstConDocs = [SELECT Id, Name
			FROM Attachment
			WHERE Id = :attachmentid AND (NOT Name LIKE '%.json')
			LIMIT 1];
		if (lstConDocs.size() > 0){delete lstConDocs;}
		return true;
    }
    

    // TIDS Configuration
    @AuraEnabled(cacheable=false)
    public static void saveTidsConfiguration(String service, String payload){
        final String filename = 'tids-configuration.json';
        Portal_Applications__c services = [SELECT Id
                                            FROM Portal_Applications__c
                                            WHERE Name=:service LIMIT 1];
        addAttachment(services.Id, payload, filename);
    }
    @AuraEnabled(cacheable=false)
    public static String getTidsConfiguration(String service){
      String bodyAsString = null;
      final String filename = 'tids-configuration.json';
      Portal_Applications__c services = [SELECT Id FROM Portal_Applications__c
                                            WHERE Name=:service  LIMIT 1];
      return getAttachment(services.Id, filename);
    }
    //@AuraEnabled(cacheable=false)
	public static String getSettings(String parentid, string type){
		if (parentid == null){return null;}
		parentid = String.escapeSingleQuotes(parentid.trim());
		List<Attachment> newsettings = new List<Attachment>();
		//read the settings file
		newsettings = [SELECT id, Body
			FROM Attachment
			WHERE parentId = :parentid AND name = :type LIMIT 1];

		if (newsettings.size() > 0){Blob body = newsettings[0].Body;return body.toString();}
		// return the Body Content
		return null;
	}
    public static String getAttachment(String parentId, String fileName){
        String result = '';
        if (!Schema.sObjectType.Attachment.isAccessible()){return result;}
        List<Attachment> attachments = [SELECT Id, Body, ParentId, isPrivate, Name
            FROM Attachment
            WHERE ParentId=:parentId AND name=:fileName
            ORDER BY CreatedDate DESC
            LIMIT 1];

        if (attachments.size() > 0){result = EncodingUtil.base64Decode(EncodingUtil.base64Encode(attachments.get(0).Body)).toString();}
        return result;
    }
    
    @AuraEnabled(cacheable=false)
    public static documentWrapper relatedFiles(String parentid){
        list<Attachment> lstConDocs = new List<Attachment>();
        lstConDocs = [SELECT Id, Name, CreatedDate, ContentType
                        FROM Attachment
                        WHERE parentId=:parentid AND (NOT Name LIKE '%.json')
                        ORDER BY CreatedDate DESC];
    
        documentWrapper newdoc = new documentWrapper();
        List<Case> cases = new List<Case>(); 
        cases = [Select Id, Status From Case Where Id=:parentid Limit 1];
        newdoc.isError=0;
        if (cases.size()==0) {newdoc.isError=1;}
        if (cases[0].status=='Closed') {newdoc.isError=2;}
        if (newdoc.isError==0) {newdoc.documents=lstConDocs;}
        return newdoc;
    }
  
  
    public class documentWrapper {
      @AuraEnabled public integer isError;
      @AuraEnabled public list<Attachment> documents;
    }

    public static void addAttachment(Id parentId, String payload, String filename){
        if (!Schema.sObjectType.Attachment.isAccessible()){return;}
		if (!Schema.sObjectType.Attachment.isCreateable()){return;}
		if (!Schema.sObjectType.Attachment.isUpdateable()){return;}
	    Attachment newAttachment = new Attachment();
        List<Attachment> attachments = [SELECT Id, Body, ParentId, isPrivate, Name
          FROM Attachment
          WHERE ParentId=:parentId AND name=:filename
          ORDER BY CreatedDate DESC LIMIT 1];
    
        if (attachments.size() > 0){
            newAttachment = attachments.get(0);
        }else{
            newAttachment.ParentId=parentId;
            newAttachment.isPrivate=false;
            newAttachment.Name=filename;
        }
    
        try {
          Blob attachmentBody = Blob.valueOf(payload);
          newAttachment.Body = attachmentBody;
          upsert newAttachment;
        } catch (Exception e){}
    }

    

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
            List<Attachment> newsettings = new List<Attachment>();
            //read the settings file
            newsettings = [SELECT id, Body, ParentId, ContentType
                FROM Attachment
                WHERE ParentId=:parentid AND name=:filename
                LIMIT 1];

            if (newsettings.size() > 0){attachment1.Id = newsettings[0].Id;}
        }
        if (attachment1.Id == null){attachment1.Name = filename;attachment1.ParentId = parentid;}
        //Blob body = Blob.valueOf(base64data);
        Blob body = EncodingUtil.Base64Decode(base64data);
        attachment1.body = body;
        attachment1.ContentType = fileType;
        Attachmentlist.add(attachment1);
        upsert Attachmentlist;
        string errormessage = '';
        try {
        //Collect issue
        Database.UpsertResult[] lsr = Database.upsert(Attachmentlist, false);
        for (Database.UpsertResult sr : lsr){
            if (!sr.isSuccess()){
                for (Database.Error err : sr.getErrors()){
                    errormessage += ComposeMessage(err);
                }
            }
        }
        if (errormessage!=''){return;}
        } catch (Exception e){}
    }
    @AuraEnabled(cacheable=true)
    public static List<ValueLabel> getGDSValues(){
        final String criteria ='AIRSYS';
		List<ValueLabel> gds = getPicklistValues(criteria, 'Is_Displayed_Last__c, Name');
		return gds;
    }
    @AuraEnabled(cacheable=true)
    public static List<ValueLabel> getNumberOfEmployees(){
        final String criteria = 'APEMP';
        List<ValueLabel> numberOfEmployeesValues = getPicklistValues(criteria, 'Name');
        return numberOfEmployeesValues;
    }

    @AuraEnabled(cacheable=true)
    public static List<ValueLabel> getPreferedLanguages(){
        final String criteria = 'PREFLANG';
        List<ValueLabel> numberOfEmployeesValues = getPicklistValues(criteria, 'Name');
        return numberOfEmployeesValues;
    }

    @AuraEnabled(cacheable=true)
    public static List<ValueLabel> getFocusValues(){
        final String criteria = 'FOCUSVALUES';
        List<ValueLabel> focusValues = getPicklistValues(criteria, 'Name');
        return focusValues;
    }
   
    @AuraEnabled(cacheable=true)
	public static List<ValueLabel> companyTypes(){
		final String criteria = 'LGLTYP';
		List<ValueLabel> companyTypes = getPicklistValues(criteria, 'Name');
		return companyTypes;
	}

	@AuraEnabled(cacheable=true)
	public static List<ValueLabel> mainMarketSpecialization(){
		final String criteria = 'APSPEC';
		List<ValueLabel> marketSpecialization = getPicklistValues(criteria, 'Name');
		return marketSpecialization;
	}

	@AuraEnabled(cacheable=true)
	public static List<ValueLabel> principalDestination(){
		final String criteria = 'APDEST';
		List<ValueLabel> principalDestinations = getPicklistValues(criteria,'Name');
		return principalDestinations;
	}

	@AuraEnabled(cacheable=true)
	public static List<ValueLabel> salesVolume(){
		final String criteria = 'APSALE';
		List<ValueLabel> salesVolume = getPicklistValues(criteria, 'Code__c');
		return salesVolume;
	}

	@AuraEnabled(cacheable=true)
	public static List<ValueLabel> mainActivity(){
		final String criteria = 'APPRAC';
		List<ValueLabel> mainActivities = getPicklistValues(criteria, 'Name');
		return mainActivities;
    }

    
    
    public static List<ValueLabel> getPicklistValues(String criteria,String orderBy){
		List<ValueLabel> values = new List<ValueLabel>();
		final String query ='SELECT Name, Code__c, Valid_For_TIDS__c,Corresponding_AMS_Code__c FROM GDP_Reference_Table__c WHERE Table__c = \'' +
									String.escapeSingleQuotes(criteria) +
									'\' AND Valid_For_TIDS__c = true ORDER BY ' +
									String.escapeSingleQuotes(orderBy);
		List<GDP_Reference_Table__c> gdpValues = Database.query(query);
		for (GDP_Reference_Table__c gdpValue : gdpValues){
            if (criteria=='AIRSYS') {values.add(new ValueLabel(gdpValue.Corresponding_AMS_Code__c, gdpValue.Name));}
            if (criteria!='AIRSYS') {values.add(new ValueLabel(gdpValue.Code__c, gdpValue.Name));}
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

    //Notifications
    
    public static void sendNotification(String caseId, String contactId){
		if (!Schema.sObjectType.EmailTemplate.isAccessible()){TIDSUtil.setError(TIDS_Constant.MSG23);return;}
		if (!Schema.sObjectType.Contact.isAccessible()){TIDSUtil.setError(TIDS_Constant.MSG24); return;}
		List<EmailTemplate> emailtemp = [SELECT Id
			FROM EmailTemplate
			WHERE DeveloperName = 'TIDS_HO_Approval_Notification' LIMIT 1];
		List<Contact> contactList = [SELECT Id, email
			FROM Contact
			WHERE Id = :contactId LIMIT 1];

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.toAddresses = new List<String>{ contactList[0].email };
		if (!Test.isRunningTest()) {email.setTemplateId(emailtemp[0].Id);}
		email.setTargetObjectId(contactList[0].Id);
		email.setWhatId(caseId);

		if (!Test.isRunningTest()) {Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });}
    }
    
    public static void sendNotification(String caseId, String contactId, String emailTemplate){
        sendEmailNotification(caseId, contactId, emailTemplate, null);
     
    }  
    public static void sendEmailNotification(String caseId, String contactId, String emailTemplate, String noreply){
        List<EmailTemplate> emailtemp = [SELECT Id
          FROM EmailTemplate
          WHERE DeveloperName =:emailTemplate Or Name =:emailTemplate LIMIT 1];
        if (emailtemp.size()==0 && !Test.isRunningTest()) {return;}
        List<Contact> contactList = [SELECT Id, email
          FROM Contact
          WHERE Id = :contactId LIMIT 1];
        if (contactList.size()==0) {return;}
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if (noreply!=null){owea = [select Id from OrgWideEmailAddress where Address =:noreply Or DisplayName=:noreply Limit 1];}
        if (owea.size() > 0){email.setOrgWideEmailAddressId(owea[0].Id);}
        
    
        email.toAddresses = new List<String>{ contactList[0].email };
        if (!Test.isRunningTest()) {email.setTemplateId(emailtemp[0].Id);}
        email.setTargetObjectId(contactList[0].Id);
        email.setWhatId(caseId);    
        if (!Test.isRunningTest()) {Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });}
    }
    public static void sendMyEmail(List<EmailMessageWrapper> listEmailMessageWrapper, String emailTemplateNameDeveloperName, String userId) {
        List<Messaging.SendEmailResult> listEmailResult = new List<Messaging.SendEmailResult>();
        List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
        EmailTemplate emailt;
        emailTemplates = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :emailTemplateNameDeveloperName ];
        if (emailTemplates.size()>0) {emailt = emailTemplates[0];}
        Map <Id, OrgWideEmailAddress> orgAddressMap = new Map <Id, OrgWideEmailAddress> ([SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org']);
        Map <String, Id> orgAddressByEmail = new Map <String, Id> ();
        for(OrgWideEmailAddress oea: orgAddressMap.values()){orgAddressByEmail.put(oea.Address, oea.Id);}
        //if(Test.isRunningTest()){return;}
        
        List<Messaging.Singleemailmessage> listSingleEmailMessages = new List<Messaging.Singleemailmessage>();
        for (EmailMessageWrapper emailMessageWrapper : listEmailMessageWrapper) {
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
             if (!orgAddressMap.isEmpty()){
                mail.setOrgWideEmailAddressId(orgAddressByEmail.get('noreply@iata.org'));
             }else{
                mail.setSenderDisplayName('IATA no reply');
                if(emailMessageWrapper.FromAddress != null && emailMessageWrapper.FromAddress.length() > 0){mail.setReplyTo(emailMessageWrapper.FromAddress);}
             }
             if (userId!=null){mail.setTargetObjectId(userId);}
             if (userId==null){
                if(emailMessageWrapper.ToAddress != null && emailMessageWrapper.ToAddress.length() > 0){
                    mail.setToAddresses(new String[] { emailMessageWrapper.ToAddress });
                }else{mail.setTargetObjectId(emailMessageWrapper.ToAddressId);}
            }
            if(emailMessageWrapper.BccAddress != null && emailMessageWrapper.BccAddress.length() > 0) {mail.setBccAddresses(new String[] {emailMessageWrapper.BccAddress });}
            String subject ='';
            if (emailTemplates.size()>0) {subject =emailt.Subject;}
            if(emailMessageWrapper.Subject != null && emailMessageWrapper.Subject.length() > 0) {
                mail.setSubject(emailMessageWrapper.Subject);
                subject = emailMessageWrapper.Subject;
            }
            for(String key: emailMessageWrapper.ParameterSubjectMap.keySet()){subject = subject.replace(key, (emailMessageWrapper.ParameterSubjectMap.get(key) == null ? '' : emailMessageWrapper.ParameterSubjectMap.get(key)));}
            mail.setSubject(subject);
            String htmlBody = '';
            if (emailTemplates.size()>0) {htmlBody = emailt.HtmlValue;}
            String plainBody = '';
            if (emailTemplates.size()>0) {plainBody = emailt.Body;}
            for (String key : emailMessageWrapper.ParameterBodyMap.keySet()) {
                if(htmlBody <> null && emailMessageWrapper.ParameterBodyMap <> null)
                htmlBody = htmlBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
                if(plainBody <> null && emailMessageWrapper.ParameterBodyMap <> null)
                plainBody = plainBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
            }
            mail.setSaveAsActivity(false);
            if (htmlBody <> null){mail.setHtmlBody(htmlBody);}
            if (plainBody <> null){mail.setPlainTextBody(plainBody);}
            listSingleEmailMessages.add(mail);
  
        }
        if(!Test.isRunningTest()){
            listEmailResult = Messaging.sendEmail(listSingleEmailMessages);}
    }
}
