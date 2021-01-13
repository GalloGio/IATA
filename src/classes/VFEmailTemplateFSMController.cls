public without sharing class VFEmailTemplateFSMController {

	public Id caseObjId {
		get;
		set {
			if ( this.caseObjId == null ) {
				this.caseObjId = value;
				init();
			}
		}
	}

	public Case caseObj { get; set; }
	public EmailTemplate__c template { get; set; }

	public String greeting{ get; set; }
	public String section1{ get; set; }
	public String section2{ get; set; }
	public String section3{ get; set; }
	public String signature{ get; set; }
	public String text1{ get; set; }

	public VFEmailTemplateFSMController() {

	}

	public void init() {
		this.caseObj = [ Select Id, caseNumber, Reminder_EmailTemplate__c, Account.Name, CurrencyISOCode, Financial_Security_Amount_2__c, FS_Deadline_Date__c, IATAcode__c, Account.AIMS_ID__c from Case where id = :this.caseObjId];
		this.template = [
			Select Id, Greeting_Line__c, Body_Section_1__c,Body_Section_2__c,Body_Section_3__c, Signature_Details__c, Text_1__c
			From EmailTemplate__c
			Where id = :this.caseObj.Reminder_EmailTemplate__c ];

		this.greeting = updateField( this.template.Greeting_Line__c, '<ACCOUNT NAME>', this.caseObj.Account.Name);
		this.section1 = updateField( this.template.Body_Section_1__c, '&lt;FS CURRENCY&gt;', this.caseObj.CurrencyISOCode);
		if ( this.caseObj.Financial_Security_Amount_2__c == null ) {
			this.caseObj.Financial_Security_Amount_2__c = 0;
		}
		this.section1 = updateField( this.section1, '&lt;FS AMOUNT&gt;', this.caseObj.Financial_Security_Amount_2__c.format() );
		this.section1 = updateField( this.section1, '&lt;FS DEADLINE&gt;', String.ValueOf( this.caseObj.FS_Deadline_Date__c) + ' (YYYY-MM-DD)' );
		this.section2 = this.template.Body_Section_2__c;
		this.section3 = this.template.Body_Section_3__c;
		this.signature = updateField( this.template.Signature_Details__c, '&lt;CASE&gt;', String.ValueOf( this.caseObj.CaseNumber) );
		this.text1 = updateField( this.template.Text_1__c, '<IATA CODE>', String.ValueOf( this.caseObj.Account.AIMS_ID__c ) );

	}

	private String updateField( Object input, String replaceFrom, String replaceTo) {
		String fieldValue =  String.ValueOf( input );
		system.debug('fieldValue ' + fieldValue);
		try {
			system.debug('replaceFrom / replaceTo ' + replaceFrom + ' ' + replaceTo);
			replaceTo = replaceTo==null?'':replaceTo;
			fieldValue = fieldValue.replace( replaceFrom, replaceTo);
			system.debug('fieldValue ' + fieldValue);
			return  fieldValue;

		} catch ( Exception e ) {
			return fieldValue;
		}
	}

	/*
	private void updateField( EmailTemplate__c obj, String fieldName, String replaceFrom, String replaceTo) {
		try {
			system.debug('obj ' + obj);
			system.debug('fieldName ' + fieldName);
			String fieldValue =  String.ValueOf( obj.get(fieldName) );
			system.debug('fieldValue ' + fieldValue);
			system.debug('replaceFrom / replaceTo ' + replaceFrom + ' ' + replaceTo);
			replaceTo = replaceTo==null?'':replaceTo;
			fieldValue = fieldValue.replace( replaceFrom, replaceTo);
			system.debug('fieldValue ' + fieldValue);
			obj.put(fieldName, fieldValue);
		} catch ( Exception e ) {}
	}
	*/

	public String getImageHeader() {
		Document imageHeader = [Select Id from Document where Name = 'FSM Email Template Header'];
		return URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + imageHeader.Id + '&oid=' + UserInfo.getOrganizationId();
	}

}
