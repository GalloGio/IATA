public with sharing class ISSP_TIP_Enrolment_Controller {


	public String applyLanguage {get; set;}
	public String displayLanguage {get; set;}
	public User user {get; set;}
	public Contact con {get; set;}
	public Account account {get; set;}
	private Id accountID {get; set;}
	private Case newCase {get; set;}
	private List <Case> accountCases {get; set;}

	public String conID {get; set;}
	public Contact newContact {get;set;} 
	public List <Contact> contactList {get; set;}
	public Boolean isEmailDuplicated {get; set;}


	public ISSP_TIP_Enrolment_Controller() {

		applyLanguage = UserInfo.getLanguage();
		displayLanguage = UserInfo.getLanguage();

		user = DAL_ISSP.getUser(Userinfo.getUserId());
		con = DAL_ISSP.getContact(user.ContactId);
		accountID = con.AccountId;
		fetchHQAccountDetails();
		getISOCountry();

		accountCases = [SELECT ID,Reason1__c,RecordTypeid,RecordType.Name,CaseArea__c,Status,Visible_on_ISS_Portal__c,Subject,Region__c,
						Origin,BSPCountry__c,Country_concerned_by_the_query__c,Description
						FROM Case 
							WHERE RecordTypeid = :TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID 
							AND Accountid = :account.id 
							AND Visible_on_ISS_Portal__c = true
							AND Reason1__c = :TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT
							AND CaseArea__c = :TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS 
							AND Status = 'Draft'
						LIMIT 1]; 

		fillContactList();
		newContact = new Contact();
	}

	public Pagereference submitToIATA() {

		//confirm that required fields are fill
				//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter value'));
		
		if(String.isEmpty(account.Name)){
			account.Name.addError('Please fill the Legal name');
			return null;
		}

		if(String.isEmpty(account.PhoneNational__c)){
			account.PhoneNational__c.addError('Please fill the Office Phone');
			return null;
		}

		if(String.isEmpty(account.Email__c)){
			account.Email__c.addError('Please fill the Office Email');
			return null;
		}
/*
		if(account.BillingAddress == null || account.BillingAddress ==''){
			account.BillingAddress.addError('Please fill the Billing Address');
			return null;
		}*/

		if(String.isEmpty(account.BillingStreet)){
			account.BillingStreet.addError('Please fill the Billing Street');
			return null;
		}

		if(String.isEmpty(account.BillingCity)){
			account.BillingCity.addError('Please fill the Billing City');
			return null;
		}
		
		if(String.isEmpty(account.TIP_HQ_Location__c)){
			account.TIP_HQ_Location__c.addError('Please Choose the Location of Headquarter');
			return null;
		}

		//confirm that primary contact is choosen
		Boolean hasPrimaryContact = false;
		for(Contact c : contactList){
			if (c.Primary_Contact__c) hasPrimaryContact = true;
		}

		if(!hasPrimaryContact){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select a primary contact'));
			return null;
		//contactList[0].Primary_Contact__c = true;
		//upsert contactList;
		}

		//Update or create case with status Open
		updateCase();
		newcase.Status = 'Open';
		
		//force case auto-response rules to fire
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.EmailHeader.triggerAutoResponseEmail= true;
		newCase.setOptions(dmo);

		update account;
		upsert newCase;


		//------------------ queue exists??-----------------------

		//assign to TIP HO queue
		List<Group> groups =  [SELECT Id FROM Group WHERE Type = 'Queue' AND NAME = 'Cases_Transparency_in_Payment_Service' LIMIT 1];
		
		if(groups == null || groups.isEmpty()) System.debug('ERROR! Cases_Transparency_in_Payment_Service Queue not found proceeding without assign');
		else{
			newCase.OwnerId = groups[0].id;
			upsert newcase;
		}

		//take to acknowledgement page (which page is this?)
		return new Pagereference('/ISSP_TIP_Home'); //wrong page
	}

	public Pagereference saveAsDraft() {

		updateCase();
		update account;
		upsert newCase;
		try{
			upsert contactList;
		}catch(Exception e){}
		return new Pagereference('/ISSP_TIP_Home');
	}

	public void fetchHQAccountDetails () {
		account = [
						SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Legal_name__c,
						TradeName__c, Membership_status__c, IATACode__c, Sector__c, Category__c, Due_Diligence_Status__c,
						Due_Diligence_Remarks__c, Level_of_risk__c, Email__c, Website, Phone, PhoneNational__c, Fax, FaxNational__c,
						Mobile__c, MobileNational__c , Location_Type__c, ParentId, ShippingStreet, ShippingCity, ShippingState,
						ShippingPostalCode, ShippingCountry, VAT_Number__c, Short_Name__c, Location_Class__c, IATA_ISO_Country__c,TIP_Documents__c,
						Iso_State__c, Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c, Solicitation_Flag__c,
						VAT_Number_2__c, CASS_Number__c,Company_Type__c,RecordTypeid, RecordType.DeveloperName,Status__c,IATA_ISO_Country__r.ISO_Code__c,ANG_Accreditation_Model__c,
						IATA_ISO_Country__r.Name, IATA_ISO_Country__r.region__c, TIP_HQ_Location__c
						FROM Account
						WHERE Id = :accountID
								   LIMIT 1
					];
	}

	private void updateCase(){

		newCase = new Case();
		if(accountCases != null && !accountCases.isEmpty()){ newCase = accountCases[0]; }
		newcase.RecordTypeid = TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID;
		newcase.Accountid = account.id; 
		newcase.Visible_on_ISS_Portal__c = true;
		newcase.Reason1__c = TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT;
		newcase.CaseArea__c = TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS; 
		newcase.Status = 'Draft';
		newcase.Subject = 'Request for Enlistment as Payment provider - ' + account.name;
		newCase.Description = 'Request for Enlistment as Payment provider';
		newcase.Region__c = account.IATA_ISO_Country__r.region__c;
		newcase.Origin = 'Portal';
		newcase.BSPCountry__c = account.IATA_ISO_Country__r.Name;
		newcase.Country_concerned_by_the_query__c = account.IATA_ISO_Country__r.Name;
	}

	public List<SelectOption> getISOCountry() {
		List<SelectOption> options = new List<SelectOption>();		
		options.add(new SelectOption('',Label.ISSP_SELECT_COUNTRY));
		for(IATA_ISO_Country__c iso:[select Id,Name,ISO_Code__c, IEC_Zip_Postal_Code_required__c from IATA_ISO_Country__c
									where Name != 'All Countries' and Name != 'NO COUNTRY' order by Name]){
			options.add(new SelectOption(iso.Id,iso.Name));
		}
		return options;
	}

	private void fillContactList() {
		contactList = [SELECT id,Name, Email,Salutation, FirstName, LastName, Phone, Primary_Contact__c,MobileNational__c,Membership_Function__c,Title,MobilePhone

				FROM Contact
				WHERE Status__c = 'Active' and Accountid = :accountID];
	}

	public void updateRadioButtonStatus() {
		ID contactID = Apexpages.currentPage().getParameters().get('contactIDtoPrimary');
		for (Contact c: contactList) {
			c.Primary_Contact__c = false;
			if(c.id == contactID) c.Primary_Contact__c = true;
		}
	}

	public void createContact(){
		newContact.AccountId = accountID;
		/*if(String.isEmpty(newContact.Membership_Function__c)) {
			Apexpages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter value'));
			return;
		}*/
		try{
			upsert newContact;
			isEmailDuplicated = false;
			system.debug('##done inserting: ' +isEmailDuplicated);
		}catch(Exception e){
			system.debug('##Error inserting: ' +isEmailDuplicated);
			isEmailDuplicated = true;
			return;
		}
		fillContactList();
		newContact = new Contact();
	}

	public Pagereference setContactToEdit(){
		
		String contactID = Apexpages.currentPage().getParameters().get('contactIDToEdit');
		if (String.isBlank(contactID)) newContact = new Contact();
		else{
			for (Contact c: contactList) {
				if(c.id == contactID) newContact = c;
			}
		}
		return null;

	}

	public PageReference securityCheck(){
		if(account.recordtypeid != TIP_Utils.STANDARD_ACCOUNT_RECORD_TYPE_ID || con.User_Portal_Status__c != ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM ) return new Pagereference('/ISSP_TIP_Home');
		return null;
	}
}