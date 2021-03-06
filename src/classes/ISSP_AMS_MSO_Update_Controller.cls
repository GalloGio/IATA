public without sharing class ISSP_AMS_MSO_Update_Controller {

	public static final String ACTION_CORRECTION  = 'correction';
	public static final String ACTION_TERMINATION = 'termination';


	public String action {get; set;}
	public String step {get; set;}
	public String applyLanguage {get; set;}

	private static User currentUser;

	public Account msoAccount {get; set;}
	public Contact currentUserContact {get; set;}
	public Case oscarCase {get; set;}
	public AMS_Pax_Accreditation_Form__c accreditationForm {get; set;}
	public AMS_OSCAR__c oscar {get; set;}


	public String countrySelected {get; set;}
	public String billingState {get; set;}
	public List<SelectOption> countryISOCodeList {get;set;}
	public List<SelectOption> billingStatesList {get; set; }

	public static List<IATA_ISO_City__c> billingCityList;

	public String billingCity{get;set;}

	public static String billingCityListStr {get { return JSON.serialize(billingCityList); } set;}

	private static final string ISO_8859_1_regEx = '^[\\x00-\\x7F\\xA0-\\xFF]+$';  //Reg exp to limit inputted chars to ISO-8859-1

	//CNS
	public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
	public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
	public String commParamFirst { get { if(communityName=='CNS'){ return '?CommunityName='+ communityName;} return ''; } set;}


	public ISSP_AMS_MSO_Update_Controller() {
		action = ApexPages.currentPage().getParameters().get('action');
		Id caseId = ApexPages.currentPage().getParameters().get('caseId');
		Id msoId = ApexPages.currentPage().getParameters().get('msoId');

		step = ApexPages.currentPage().getParameters().get('step');
		if (step == null) step = 'form';

		currentUser = [SELECT Id, ContactId, Contact.isEmailBounced, Contact.Email FROM User WHERE Id = :UserInfo.getUserId()];
		currentUserContact = [SELECT Id, AccountId, Account.Name, Account.RecordType.DeveloperName FROM Contact WHERE Id = :currentUser.ContactId];

		applyLanguage = UserInfo.getLanguage();
		if (applyLanguage != 'en_US' && applyLanguage != 'es' && applyLanguage != 'fr')
			applyLanguage = 'en_US';

		list<Account> lstAcc = new list<Account>([SELECT Id, Name, TradeName__c, Short_Name__c, BillingStreet, BillingPostalCode, BillingCity, IATACode__c, IATA_ISO_Country__c, IATA_ISO_Country__r.Name, Iso_State__c, Iso_State__r.Name, Email__c, Phone, Fax, Company_Type__c, License_Number__c, Solicitation_Flag__c, VAT_Number__c, Website, ShippingStreet, ShippingPostalCode, ShippingCity, Operation__c, Abbreviated_name__c, Abbreviated_address__c, Remittance_frequency__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c, IATA_ISO_Billing_State__c, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_State__c, Link_agent_name__c, Accreditation_date__c, Expiry_Date__c, Status__c, Geoname_Billing_City__c,Geoname_Billing_City__r.Name,Geoname_Shipping_City__c FROM Account WHERE Id = :msoId]);

		System.debug('lstAcc: ' + lstAcc);

		if (String.isBlank(action) || String.isBlank(msoId) || lstAcc.isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_MSO_Invalid_Request));
		} else {

			msoAccount = lstAcc[0];
			System.debug('msoAccount: ' + msoAccount);
			if (caseId == null) {
				oscarCase = new Case();
			} else {
				oscarCase = [SELECT Id, CaseNumber, IATAcode__c, OSCAR__c, OSCAR__r.Account__c FROM Case WHERE Id = :caseId];
			}

			oscar = new AMS_OSCAR__c(Id = oscarCase.OSCAR__c);

			if (action == ACTION_CORRECTION) {
				if (oscarCase.Id == null) {
					accreditationForm = new AMS_Pax_Accreditation_Form__c();
					accreditationForm.Branch_Office_Street_name_number__c = msoAccount.BillingStreet;
					accreditationForm.Branch_Office_Postal_code__c = msoAccount.BillingPostalCode;
					accreditationForm.Branch_Office_City__c = msoAccount.BillingCity;
					accreditationForm.Branch_Office_Email__c = msoAccount.Email__c;
					accreditationForm.Branch_Office_Phone__c = msoAccount.Phone;
					accreditationForm.IATA_ISO_State__c = msoAccount.IATA_ISO_Billing_State__c;
					accreditationForm.Branch_Office_Country__c = msoAccount.IATA_ISO_Country__c;
					accreditationForm.IATACode__c = msoAccount.IATACode__c;
					accreditationForm.Account_Name__c = msoAccount.Name;
					accreditationForm.Short_Name__c = msoAccount.Short_Name__c;
					accreditationForm.Trade_Name__c = msoAccount.TradeName__c;
					accreditationForm.ISSP_AMS_License_No__c = msoAccount.License_Number__c;
					accreditationForm.ISSP_AMS_VAT_number__c = msoAccount.VAT_Number__c;
					accreditationForm.Website__c = msoAccount.Website;
					accreditationForm.Shipping_Street__c = msoAccount.ShippingStreet;
					accreditationForm.Shipping_Postal_Code__c = msoAccount.ShippingPostalCode;
					accreditationForm.Branch_Office_FAX__c = msoAccount.Fax;
					accreditationForm.Shipping_City__c = msoAccount.ShippingCity;
					accreditationForm.Operation__c = msoAccount.Operation__c;
					accreditationForm.Abbreviated_name__c = msoAccount.Abbreviated_name__c;
					accreditationForm.Abbreviated_Address__c = msoAccount.Abbreviated_address__c;
					accreditationForm.Remittance_frequency__c = msoAccount.Remittance_frequency__c;
					accreditationForm.Solicitation_Flag__c = msoAccount.Solicitation_Flag__c;
					accreditationForm.VAT_Number_2__c = msoAccount.VAT_Number_2__c;
					accreditationForm.CASS_Number__c = msoAccount.CASS_Number__c;
					accreditationForm.Location_Class__c = msoAccount.Location_Class__c;
					accreditationForm.Location_Type__c = msoAccount.Location_Type__c;
					accreditationForm.Mobile__c = msoAccount.Mobile__c;
					accreditationForm.Is_your_firm_handling_Dangerous_Goods__c = msoAccount.Is_your_firm_handling_Dangerous_Goods__c;
					accreditationForm.Shipping_ISO_Country__c = msoAccount.IATA_ISO_Shipping_Country__c;
					accreditationForm.Shipping_ISO_State__c = msoAccount.IATA_ISO_Shipping_State__c;
					accreditationForm.Link_agent_name__c = msoAccount.Link_agent_name__c;
					accreditationForm.Geoname_Billing_City__c = msoAccount.Geoname_Billing_City__c;
					accreditationForm.Geoname_Shipping_City__c = msoAccount.Geoname_Shipping_City__c;

				} else {
					accreditationForm = [SELECT Id, Account_Name__c, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c, Branch_Office_City__c, Branch_Office_Phone__c, Branch_Office_Email__c, IATACode__c, IATA_ISO_State__c, IATA_ISO_State__r.Name, Branch_Office_Country__c, Branch_Office_Country__r.Name, Short_Name__c, Trade_Name__c, ISSP_AMS_License_No__c, ISSP_AMS_VAT_number__c, Website__c, Shipping_Street__c, Shipping_Postal_Code__c, Branch_Office_FAX__c, Shipping_City__c, Operation__c, Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c, Shipping_ISO_Country__c, Shipping_ISO_State__c, Link_agent_name__c, Geoname_Billing_City__c,Geoname_Billing_City__r.Name,Geoname_Shipping_City__c FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__c = :oscarCase.Id];
				}

				refreshStates();
				countrySelected = accreditationForm.Branch_Office_Country__c;
				billingState = accreditationForm.IATA_ISO_State__c;
				refreshCities();
				billingCity = accreditationForm.Geoname_Billing_City__c;

				if (step == 'view') {
					String auxCtry = '';
					for(Integer i=0 ; i < countryISOCodeList.size() ; i++ ){
						if(countryISOCodeList.get(i).getValue() == countrySelected){
							auxCtry = countryISOCodeList.get(i).getLabel();
						}
					}
					String auxState = '';
					System.debug('billingState: ' + billingState);
					System.debug('billingStatesList: ' + billingStatesList);

					for(Integer i=0 ; i < billingStatesList.size() ; i++ ){
						System.debug('billingStatesList.get(i).getValue(): ' + billingStatesList.get(i).getValue());
						System.debug('billingStatesList.get(i).getLabel(): ' + billingStatesList.get(i).getLabel());
						if(billingStatesList.get(i).getValue() == billingState){
							auxState = billingStatesList.get(i).getLabel();
						}
					}

					String auxCity = '';
					for(Integer i=0 ; i < billingCityList.size() ; i++ ){
						if(billingCityList.get(i).Id == billingCity){
							auxCity = billingCityList.get(i).Name;
						}
					}

					countrySelected = auxCtry;
					billingState = auxState;
					billingCity = auxCity;

				}

			}else if (action == ACTION_TERMINATION) {
				System.debug('action FM: ' + action);
				System.debug('step: ' + step);

				Account acc = [Select Id, IATA_ISO_Country__c, Iso_State__c, Geoname_Billing_City__c from Account where Id = :msoId];

				countrySelected = acc.IATA_ISO_Country__c;
				billingState = acc.Iso_State__c;
				billingCity = acc.Geoname_Billing_City__c;

				System.debug('countrySelected: ' + countrySelected);
				System.debug('billingState: ' + billingState);
				System.debug('billingCity: ' + billingCity);
			}

		}
	}

	public void refreshStates(){
		list<IATA_ISO_Country__c> isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(
			IATAIsoCountryDAO.getIsoCountriesByIds(new Set<ID>{msoAccount.IATA_ISO_Country__c}), 'Name');

		IATA_ISO_Country__c iso = isoList[0];

		billingStatesList = new List<SelectOption>();
		for (IATA_ISO_State__c s : iso.IATA_ISO_States__r) {
			if(s.Valid_For_Address__c)
				billingStatesList.add(new SelectOption(s.Id, s.Name));
			}

		countryISOCodeList = new List<SelectOption>();

		if (applyLanguage == 'es') {
			if (iso.IATA_Country_SP__c != null)
				countryISOCodeList.add(new SelectOption(iso.Id , iso.IATA_Country_SP__c));
			else
				countryISOCodeList.add(new SelectOption(iso.Id , iso.Name));
		} else if (applyLanguage == 'fr') {
			if (iso.IATA_Country_FR__c != null)
				countryISOCodeList.add(new SelectOption(iso.Id, iso.IATA_Country_FR__c));
			else
				countryISOCodeList.add(new SelectOption(iso.Id, iso.Name));
		} else {
			countryISOCodeList.add(new SelectOption(iso.Id, iso.Name));
		}

	}

	public void refreshCities(){

		billingCityList = new List<IATA_ISO_City__c>([SELECT Id, Name, GeonameName__c, GeonameAlternateNames__c
													  FROM Iata_Iso_City__c
													  WHERE IATA_ISO_State__c = :billingState AND IATA_ISO_State__r.IATA_ISO_Country__c = :countrySelected AND Status__c <> 'Pending']);
	}

	public Pagereference securityCheck() {
		// checkIfUserHasAccessToService
		if (currentUserContact.Account.RecordType.DeveloperName != 'IATA_Airline' && currentUserContact.Account.RecordType.DeveloperName != 'IATA_Airline_BR')
			return new Pagereference('/ISSP_Homepage');

		User u = [SELECT Id, ContactId From User WHERE Id =: UserInfo.getUserId()];
		if(u != null){
			List<Portal_Application_Right__c> par;
			par = [SELECT Id, Terms_Acceptance__c FROM Portal_Application_Right__c WHERE Contact__c =: u.ContactId AND Right__c = 'Access Granted' AND (Contact_User_Portal_Status__c = 'Approved User' OR Contact_User_Portal_Status__c = 'Approved Admin') AND Application_Start_URL__c = '/ISSP_AMS_MSO'];

			if(par.size()==0) // No access right => return to home page
				return new PageReference('/ISSP_Homepage');
		}


		// check if success step -> then close the OSCAR
		if (step == 'success' && oscarCase != null && oscarCase.OSCAR__c != null) {
			system.debug('Success step - closing the OSCAR; action = ' + action);

			if (action == 'correction') {
				closeOscar(oscarCase.OSCAR__c, oscarCase.Id, currentUser.ContactId, ACTION_CORRECTION);
			} else if (action == 'termination') {
				closeOscar(oscarCase.OSCAR__c, oscarCase.Id, currentUser.ContactId, ACTION_TERMINATION);
			}
		}


		return null;
	}

	public Pagereference cancel() {
		return new Pagereference('/ISSP_AMS_MSO');
	}

	// create / update the MSO Account, Oscar, Communication Case, Accreditation Form and Appointment
	public PageReference save() {
		billingCity = String.isBlank(billingCity)?null:billingCity;
		// validate selection
		Boolean isValid = true;
		Pattern p = Pattern.compile(ISO_8859_1_regEx);

		if (countrySelected == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_MSO_Country_ErrMsg));
			isValid = false;
		}

		if (billingState == null && billingStatesList.size()>1) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_MSO_Billing_State_ErrMsg));
			isValid = false;
		}

		if (accreditationForm.Branch_Office_Email__c != null && accreditationForm.Branch_Office_Email__c != '') { // email is optional
			if (accreditationForm.Branch_Office_Email__c.indexOf('@') < 1 || accreditationForm.Branch_Office_Email__c.indexOf('.', accreditationForm.Branch_Office_Email__c.indexOf('@') + 2) < 0 || accreditationForm.Branch_Office_Email__c.length() < accreditationForm.Branch_Office_Email__c.lastIndexOf('.')+3) {
				isValid = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid email address'));
			}
		}

		// Verify only latin characters have been used in the address, city & postal code
		if (accreditationForm.Branch_Office_Street_name_number__c != null && !p.matcher(accreditationForm.Branch_Office_Street_name_number__c).matches()) {
			accreditationForm.Branch_Office_Street_name_number__c.addError(Label.ISSP_EnterValidString);
			isValid = false;
		}

		if (accreditationForm.Branch_Office_Postal_code__c != null && !p.matcher(accreditationForm.Branch_Office_Postal_code__c).matches()) {
			accreditationForm.Branch_Office_Postal_code__c.addError(Label.ISSP_EnterValidString);
			isValid = false;
		}

		if (accreditationForm.Branch_Office_City__c != null && !p.matcher(accreditationForm.Branch_Office_City__c).matches()) {
			accreditationForm.Branch_Office_City__c.addError(Label.ISSP_EnterValidString);
			isValid = false;
		}

		if (!isValid) {
			return null;
		}

		try {

			IATA_ISO_Country__c selectedCountryInfo = IATAIsoCountryDAO.getIsoCountriesByIds(new Set<ID>{countrySelected}).get(0);

			if (oscarCase.Id == null) {
				// create new OSCAR
				oscar.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CORRECTION');//oscarRT.Id;
				oscar.Name = 'tempName'; //oscarCase.CaseNumber;
				oscar.Process__c = AMS_Utils.COR;
				oscar.Account__c = msoAccount.Id;
				insert oscar;

				// avoid sending notification email
				Id noEmailContactId = null;
				if (ISSP_CS__c.getValues('No Notification Email Contact Id') != null && ISSP_CS__c.getValues('No Notification Email Contact Id').Value__c != null)
					noEmailContactId = ISSP_CS__c.getValues('No Notification Email Contact Id').Value__c;

				// create new OSCAR Communication case
				oscarCase.AccountId = currentUserContact.AccountId;
				oscarCase.ContactId = noEmailContactId; //currentUser.ContactId;
				oscarCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');//caseRT.Id;
				oscarCase.Subject = 'MSO code Corrections - (' + msoAccount.IATACode__c + ') - ' + currentUserContact.Account.Name;
				oscarCase.CaseArea__c = 'Accreditation Process';
				oscarCase.Reason1__c = 'Corrections';
				oscarCase.Origin = 'Portal';
				oscarCase.Type_of_customer__c = 'IATA Travel Agent';
				oscarCase.OSCAR__c = oscar.Id;
				oscarCase.Status = 'Draft';
				oscarCase.IATAcode__c = msoAccount.IATACode__c;
				oscarCase.Country_concerned_by_the_query__c = selectedCountryInfo.Name;
				insert oscarCase;

				oscarCase = [SELECT Id, CaseNumber FROM Case WHERE Id =:oscarCase.Id];

				// create new accreditation form
				accreditationForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'GeneralOnlineAccreditation');//accreditationRT.Id;
				accreditationForm.SAAM_Case__c = oscarCase.Id;
				accreditationForm.IATA_ISO_State__c = billingState;
				accreditationForm.Branch_Office_Country__c = countrySelected;
				accreditationForm.Geoname_Billing_City__c = billingCity;
				insert accreditationForm;

				oscar.AMS_Online_Accreditation__c = accreditationForm.Id;
				oscar.Name = oscarCase.CaseNumber;
				update oscar;


			} else {
				accreditationForm.IATA_ISO_State__c = billingState;
				accreditationForm.Branch_Office_Country__c = countrySelected;
				accreditationForm.Geoname_Billing_City__c = billingCity;
				upsert accreditationForm;
			}
		} catch (Exception ex) {
			ApexPages.addMessages(ex);
			return null;
		}

		return new PageReference('/ISSP_AMS_MSO_Update?action=' + ACTION_CORRECTION + '&msoId=' + msoAccount.Id + '&step=review&caseId=' + oscarCase.Id);
	}

	public PageReference terminate() {
		try {
				IATA_ISO_Country__c selectedCountryInfo = IATAIsoCountryDAO.getIsoCountriesByIds(new Set<ID>{countrySelected}).get(0);

				// create new OSCAR
				oscar.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'VOLUNTARY_RELINQUISHMENT');
				oscar.Name = 'tempName';
				oscar.Process__c = AMS_Utils.VOLRELINQUISH_CA;
				oscar.Account__c = msoAccount.Id;
				insert oscar;

				// avoid sending notification email
				Id noEmailContactId = null;
				if (ISSP_CS__c.getValues('No Notification Email Contact Id') != null && ISSP_CS__c.getValues('No Notification Email Contact Id').Value__c != null)
					noEmailContactId = ISSP_CS__c.getValues('No Notification Email Contact Id').Value__c;

				// create new OSCAR Communication case
				oscarCase.AccountId = currentUserContact.AccountId;
				oscarCase.ContactId = noEmailContactId; //currentUser.ContactId;
				oscarCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
				//oscarCase.Subject = 'MSO code Termination - ' + currentUserContact.Account.Name + ' - Self-service (IATA Portal)';
				//Termination of MSO code - (IATA Code) - Airline name
				oscarCase.Subject = 'MSO code Termination - (' + msoAccount.IATACode__c + ') - ' + currentUserContact.Account.Name;
				oscarCase.CaseArea__c = 'Accreditation Process';
				oscarCase.Reason1__c = 'CLO - Closure';
				oscarCase.Origin = 'Portal';
				oscarCase.Type_of_customer__c = 'IATA Travel Agent';
				oscarCase.OSCAR__c = oscar.Id;
				oscarCase.Status = 'Draft';
				oscarCase.IATAcode__c = msoAccount.IATACode__c;
				oscarCase.Country_concerned_by_the_query__c = selectedCountryInfo.Name;
				insert oscarCase;

				closeOscar(String.valueOf(oscar.Id));

		} catch (Exception ex) {
			ApexPages.addMessages(ex);
			return null;
		}

		return new PageReference('/ISSP_AMS_MSO_Update?action=' + ACTION_TERMINATION + '&msoId=' + msoAccount.Id + '&step=success&caseId=' + oscarCase.Id);
	}

	@future
	public static void closeOscar(String oscarId){
		AMS_OSCAR__c oscar = new AMS_OSCAR__c();
		oscar.Id = oscarId;
		// AUTOMATICALLY APPROVE & TERMINATE
		// pass sanity check
		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Change_effective_as_of__c = Date.today();
		update oscar;

		//Close Oscar
		oscar.STEP31__C = AMS_Utils.PASSED;
		update oscar;
	}

	public PageReference submitAndApproveCase() {
		try {
			oscar.AMS_Correction_change_code__c = 'COR';
			oscar.STEP6__c = AMS_Utils.PASSED;
			update oscar;


		} catch (Exception ex){
			ApexPages.addMessages(ex);
			system.debug('error processing the OSCAR: ' + ex.getMessage());
			return new PageReference('/ISSP_AMS_MSO_Update?action=' + ACTION_CORRECTION + '&msoId=' + msoAccount.Id + '&step=pending&caseId=' + oscarCase.Id);
			// don't block, as the OSCAR has been correctly created at this point
			// it just fails to be automatically processed, so it will have to be processed manually
		}

		return new PageReference('/ISSP_AMS_MSO_Update?action=' + ACTION_CORRECTION + '&msoId=' + msoAccount.Id + '&step=success&caseId=' + oscarCase.Id);
	}

	public PageReference cancelRequest() {
		System.debug('oscar: ' +  oscar);
		oscar.Status__c = 'Closed_Withdrawn';
		update oscar;

		string retURL = ApexPages.currentPage().getParameters().get('retURL');
		return new Pagereference('/ISSP_AMS_MSO_Update?action=' + ACTION_CORRECTION + '&msoId=' + msoAccount.Id + '&step=view');
	}

	public PageReference goBackToForm() {
		return new PageReference('/ISSP_AMS_MSO_Update?action=' + ACTION_CORRECTION + '&msoId=' + msoAccount.Id + '&step=form&caseId=' + oscarCase.Id);
	}

	//FM AMSU-119
	public PageReference goToEdit() {
		return new PageReference('/ISSP_AMS_MSO_Update?action=' + ACTION_CORRECTION + '&msoId=' + msoAccount.Id + '&step=form');
	}
	//FM AMSU-119
	public PageReference goToView() {
		return new PageReference('/ISSP_AMS_MSO_Update?action=' + ACTION_CORRECTION + '&msoId=' + msoAccount.Id + '&step=view');
	}
	//FM AMSU-119
	public PageReference goToTermination() {
		return new PageReference('/ISSP_AMS_MSO_Update?action=' + ACTION_TERMINATION + '&msoId=' + msoAccount.Id );
	}

	//@future
	public static void closeOscar(Id oscarId, Id caseId, Id contactId, String actionType) {
		try {
			Case c = [SELECT Id, IATAcode__c, Do_Not_Send_Notification__c FROM Case WHERE Id = :caseId];

			if (actionType == ACTION_TERMINATION) {
				CaseComment successComment = new CaseComment();
				successComment.ParentId = caseId;
				successComment.isPublished = true;
				successComment.CommentBody = Label.ISSP_AMS_MSO_Termination_Request_Successfull + ': ' + c.IATAcode__c;
				insert successComment;

			} else if (actionType == ACTION_CORRECTION) {
				CaseComment successComment = new CaseComment();
				successComment.ParentId = caseId;
				successComment.isPublished = true;
				successComment.CommentBody = Label.ISSP_AMS_MSO_Update_Request_Successfull + ': ' + c.IATAcode__c;
				insert successComment;
			}

			Case oscarCase = new Case(Id = caseId, ContactId = contactId, Do_Not_Send_Notification__c = true); // mark notification sent, to not send it again in case of page refresh / browser "back"
			update oscarCase;

			AMS_OSCAR__c oscar = new AMS_OSCAR__c(Id = oscarId);
			oscar.Status__c = 'Closed';
			update oscar;

			if (c.Do_Not_Send_Notification__c == false)
				sendConfirmationEmail(caseId, contactId, actionType == ACTION_CORRECTION);

		} catch (DmlException ex) {
			system.debug('Error closing the OSCAR: ' + ex.getMessage());
		}
	}


	private static void sendConfirmationEmail(Id caseId, Id contactId, Boolean isCorrection) {
		if(!currentUser.Contact.IsEmailBounced && String.isNotBlank(currentUser.Contact.Email) && !currentUser.Contact.Email.endsWithIgnoreCase('.inactive')) {
			String emailTemplateName = isCorrection ? 'IDFS_Case confirmation - MSO Correction self-service' : 'IDFS_Case confirmation - MSO Termination self-service';

			SYSTEM.DEBUG('Selected template: ' + emailTemplateName);

			List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
			List<EmailTemplate> ets = [SELECT Name, Id FROM EmailTemplate WHERE Name = :emailTemplateName];

			if (ets.isEmpty()) return;

			EmailTemplate et = ets[0];

			OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'];

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTemplateID(et.Id);
			if ( owea.size() > 0 ) {
				mail.setOrgWideEmailAddressId(owea[0].Id);
			}

			mail.setTargetObjectId(contactId);
			mail.setWhatId(caseId);
			mail.setSaveAsActivity(true);

			emails.add(mail);
			if (!Test.IsRunningTest()) {
				//SYSTEM.DEBUG('Sending confirmation email');
				Messaging.SendEmailResult [] r = Messaging.sendEmail(emails);
			}
		}
	}

}
