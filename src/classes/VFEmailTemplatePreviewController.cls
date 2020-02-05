public with sharing class VFEmailTemplatePreviewController {

	/*
	public String caseId{get;
		set{
			caseId= value;
			VFEmailTemplateController();
		}
	}
	*/

	public String contactId {
		get;
		set{
			contactId = value;
			//VFEmailTemplateController();
		}
	}

	public String emailTemplateId {
		get;
		set{
			emailTemplateId = value;
			//VFEmailTemplateController();
		}
	}

	public String subject {
		get;
		set;
	}

	public String financialReviewType {
		get;
		set;
	}

	public String deadlineDate {
		get;
		set;
	}

	public String financialYear {
		get;
		set {
			financialYear = value;
			VFEmailTemplateController();
		}
	}


	public Boolean isEnglish {get;set;}

	public String checkValue{get;set;}

	public boolean displayReminderContent {get;set;}

	//public String caseURL {get{return URL.getSalesforceBaseUrl().toExternalform() + '/' + 'secur/login_portal.jsp?orgId='+UserInfo.getOrganizationId()+'&portalId=060W00000004cAb'+'&retURL='+caseId;}set;}
	//public String caseURL {get{return 'http://theiatahub.ifapnew.cs4.force.com/ifaplogin?caseId='+caseId;}set;}
	 public String caseURL {get{return 'www.iata.org/ifap';}set;}


	public String ContactName {get; set;}
	public String caseNumber {get;set;}
	public String IATAcodeTag{get;set;}
	public String reviewType {get;set;}

	public String accountName {get;set;}
	public String FScurrency {get;set;}
	public String FSammount {get;set;}

	public String agentType {get;set;}

	public String agentCode {get;set;}

	public String ISOCode {get;set;}

	public String emailBody1 {get;set;}

	public String emailBody2 {get;set;}

	public String emailBody3 {get;set;}

	 public String text1 {get;set;}
		public String text2 {get;set;}
		 public String text3 {get;set;}
			public String text4 {get;set;}
			 public String text5 {get;set;}

	public String uploadInst {get;set;}

	public String uploadInstPortal {get;set;}

	public String deadline {get; set;}
	public String year {get;set;}
	public String FSdeadline {get; set;}

	public String greeting{get; set;}

	public String signature{get; set;}

	public Datetime casedate;

	EmailTemplate__c e;

	public boolean displayDeadline {get;set;}

	public void VFEmailTemplateController() {

	IATAcodeTag = 'IATA numeric code:';

	try {

			//if (contactId.length() > 15)
				//contactId = contactId.substring(0, 15);

		// get contact
		Contact theContact = [Select c.FirstName, c.LastName, c.Email, c.Account.Name, c.Account.IATACode__c from Contact c where c.Id = :contactId limit 1];

		caseNumber = '1234567'; //c.caseNumber;
		ContactName = theContact.Email; //c.Contact.Email;

		// get the Email template
		e = [Select e.Body_Section_1__c, e.Body_section_2__c, e.body_section_3__c, e.upload_instructions__c, e.Upload_Instructions_Portal__c, e.signature_details__c, e.greeting_line__c, e.Deadline_Date_Required__c, e.Text_1__c, e.Text_2__c, e.Text_3__c, e.Text_4__c, e.Text_5__c from EmailTemplate__c e where e.Id = :emailTemplateId limit 1];

		if(deadlineDate != null) {
			if(e.Deadline_Date_Required__c) {
				displayDeadline = true;
			}
		}

		isEnglish = true;
		//reviewType = e.review_type__c;
		emailBody2 = e.Body_section_2__c != null ? e.Body_section_2__c.replace('sfdc_richtext', '') : '';
		emailBody3 = e.body_section_3__c != null ? e.body_section_3__c.replace('sfdc_richtext', '') : '';
		uploadInst = e.upload_instructions__c != null ? e.upload_instructions__c.replace('sfdc_richtext', '') : '';
		uploadInstPortal = e.Upload_Instructions_Portal__c != null ? e.Upload_Instructions_Portal__c.replace('sfdc_richtext', '') : '';

		deadline = deadlineDate;
		year = financialYear; //c.IFAP_Financial_Year__c;
		signature = e.signature_details__c;
		greeting = e.greeting_line__c;
		emailBody1 = e.Body_Section_1__c != null ? e.Body_Section_1__c.replace('sfdc_richtext', '') : '';

		//New
		text1 = e.Text_1__c;
		text2 = e.Text_2__c;
		text3 = e.Text_3__c;
		text4 = e.Text_4__c;
		text5 = e.Text_5__c;

		agentCode = theContact.Account.IATACode__c;
		FScurrency= '??'; //c.Financial_Security_Currency__c;
		FSammount = '123.45'; //String.valueOf(c.Financial_Security_Amount__c);
		accountName = theContact.Account.Name;
		FSdeadline  = deadlineDate; //c.Formatted_FS_Deadline_Date__c;// String.valueOf(c.FS_Deadline_Date__c);
	}
	catch(Exception ex) {
		emailBody2 = 'Exception!!!!' + ex;
	}
}
}
