global class AMS_AgencyRegulationAutoRenewal implements Database.Batchable<sObject>, Database.Stateful {

	public class AMS_AgencyRegulationAutoRenewalException extends Exception {}

	public List<AMS_Agency_Regulation__c> agencyRegulations;
	public Map<Id, List<Contact>> keyContactsPerAccount;
	public Map<String, Integer> renewalCertificatesPerAccount;

	private static OrgWideEmailAddress AGENCY_MNGM_OWA;
	public static OrgWideEmailAddress getAgencyManagementOwa() {
		if (AGENCY_MNGM_OWA==null) {
			try {
				AGENCY_MNGM_OWA = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'agencymanagement@iata.org'];
			} catch (Exception e) {
				throw new AMS_AgencyRegulationAutoRenewalException('Could not find the org wide address for agency management ("agencymanagement@iata.org")');
			}
		}
		return AGENCY_MNGM_OWA;
	} 

	public AMS_AgencyRegulationAutoRenewal(List<AMS_Agency_Regulation__c> agencyRegulations, Map<Id, List<Contact>> keyContactsPerAccount, Map<String, Integer> renewalCertificatesPerAccount){
		this.agencyRegulations = agencyRegulations;
		this.keyContactsPerAccount = keyContactsPerAccount;
		this.renewalCertificatesPerAccount = renewalCertificatesPerAccount;
	}

	global Iterable<sObject> start(Database.BatchableContext bc) {
		return agencyRegulations;
	}

	global void execute(Database.BatchableContext BC, List<AMS_Agency_Regulation__c> scope) {
		validateCandidatesForRenewal(scope, keyContactsPerAccount, renewalCertificatesPerAccount);
	}

	global void finish(Database.BatchableContext BC) {

	}

	public static void validateCandidatesForRenewal(List<AMS_Agency_Regulation__c> regulationsRequiringRenewal, Map<Id, List<Contact>> keyContactsPerAccount, Map<String, Integer> renewalCertificatesPerAccount){

		Set<Id> accts = new Set<Id>();
		Set<Id> isoCountries = new Set<Id>();

		//for each regulation candidate for renewal we must check:
		//if all the existing non expired regulations of the same type are going below a threshold
		//only when this happens we should create a renewal

		Map<String, List<AMS_Agency_Regulation__c>> certificatesToRenewPerAccount = new Map<String, List<AMS_Agency_Regulation__c>>();

		// Map<Account Id + Type certificate , List Certificates >
		Map<String, List<AMS_Agency_Regulation__c>> allNonExpiredCertificatesPerAccount = new Map<String, List<AMS_Agency_Regulation__c>>();

		for(AMS_Agency_Regulation__c agReg : regulationsRequiringRenewal){
			if(!certificatesToRenewPerAccount.containsKey(agReg.Account__c+agReg.Type_of_Certificate__c))
				certificatesToRenewPerAccount.put(agReg.Account__c+agReg.Type_of_Certificate__c, new List<AMS_Agency_Regulation__c>());
			certificatesToRenewPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c).add(agReg);

			//all the agregs in context should be put in this list as they should not be expired
			if(!allNonExpiredCertificatesPerAccount.containsKey(agReg.Account__c+agReg.Type_of_Certificate__c))
				allNonExpiredCertificatesPerAccount.put(agReg.Account__c+agReg.Type_of_Certificate__c, new List<AMS_Agency_Regulation__c>());
			allNonExpiredCertificatesPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c).add(agReg);

			accts.add(agReg.Account__c);
		}

		//DGR, TSA, ULD
		Map<Id, AMS_Agency_Regulation__c> allCertificates = new Map<Id, AMS_Agency_Regulation__c>(
			[SELECT Id, Account__c, First_Name__c, Last_Name__c, Position__c, Type_of_Certificate__c, Expired__c, Notification_Sent__c,
				Account__r.IATACode__c, Account__r.IATA_ISO_Country__c, Account__r.Location_Class__c
			FROM AMS_Agency_Regulation__c
			WHERE Account__c IN :accts
			AND Type_of_Certificate__c IN (:AMS_Utils.CERT_DGR, :AMS_Utils.CERT_TSA, :AMS_Utils.CERT_ULD)]
		);

		for(AMS_Agency_Regulation__c agReg : allCertificates.values()){
			if(!agReg.Expired__c && !agReg.Notification_Sent__c){
				if(!allNonExpiredCertificatesPerAccount.containsKey(agReg.Account__c+agReg.Type_of_Certificate__c))
					allNonExpiredCertificatesPerAccount.put(agReg.Account__c+agReg.Type_of_Certificate__c, new List<AMS_Agency_Regulation__c>());
				allNonExpiredCertificatesPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c).add(agReg);
			}
		}

		Map<Id, Account> accountData = new Map<Id, Account>([SELECT Abbreviated_address__c, Abbreviated_name__c, Name, BillingState, BillingCity, IATA_ISO_Country__c,
																Email__c, Fax, Phone, BillingPostalCode, BillingStreet, CASS_Number__c, IATACode__c, Iso_State__c,
																License_Number__c, VAT_Number__c, Is_your_firm_handling_Dangerous_Goods__c, Location_Class__c,
																Location_Type__c, Mobile__c, Operation__c, Remittance_frequency__c, ShippingCity, ShippingCountry,
																ShippingPostalCode, ShippingState, ShippingStreet, Short_Name__c, Solicitation_Flag__c, TradeName__c,
																VAT_Number_2__c, Website, BillingCountry, Region_formula__c, Legal_name__c, IATA_ISO_Country__r.Name,
																IATA_ISO_Country__r.ISO_Code__c, Company_Type__c
															FROM Account WHERE Id IN :accts]);

		for(Account acc: accountData.values())
			isoCountries.add(acc.IATA_ISO_Country__c);

		//minimum requirements for location class 'R'
		Map<String, Integer> minimumHORequirements = new Map<String, Integer>();
		Map<String, Integer> minimumBRRequirements = new Map<String, Integer>();

		for(IATA_ISO_Country__c country : IATAIsoCountryDAO.getIsoCountriesByIds(isoCountries))	{

			for(AMS_Country_Specific_Attribute__c att : country.AMS_Country_Specific_Attributes__r){
				if(att == null) {
				} else if (att.RecordType.DeveloperName == 'DGR_Minimum_Requirements') {
					minimumHORequirements.put(AMS_Utils.CERT_DGR+country.Id+att.Location_Class__c, att.Minimum_DGR_HO__c == null ? 0 : Integer.valueOf(att.Minimum_DGR_HO__c));
					minimumBRRequirements.put(AMS_Utils.CERT_DGR+country.Id+att.Location_Class__c, att.Minimum_DGR_BR__c == null ? 0 : Integer.valueOf(att.Minimum_DGR_BR__c));
					//TSA share the same requirements as DGR
					minimumBRRequirements.put(AMS_Utils.CERT_TSA+country.Id+att.Location_Class__c, att.Minimum_DGR_BR__c == null ? 0 : Integer.valueOf(att.Minimum_DGR_BR__c));
					minimumHORequirements.put(AMS_Utils.CERT_TSA+country.Id+att.Location_Class__c, att.Minimum_DGR_HO__c == null ? 0 : Integer.valueOf(att.Minimum_DGR_HO__c));
				} else if (att.RecordType.DeveloperName == 'ULD_Minimum_Requirements') {
					minimumHORequirements.put(AMS_Utils.CERT_ULD+country.Id+att.Location_Class__c, att.Minimum_DGR_HO__c == null ? 0 : Integer.valueOf(att.Minimum_DGR_HO__c));
					minimumBRRequirements.put(AMS_Utils.CERT_ULD+country.Id+att.Location_Class__c, att.Minimum_DGR_BR__c == null ? 0 : Integer.valueOf(att.Minimum_DGR_BR__c));
				}
			}
		}

		map<String,Map<String, Id>> mapTypeCountryTemplates = new map<String,Map<String, Id>>();
		mapTypeCountryTemplates.put(AMS_Utils.CERT_DGR, getMapEmailTemplates(AMS_Utils.CERT_DGR));
		mapTypeCountryTemplates.put(AMS_Utils.CERT_ULD, getMapEmailTemplates(AMS_Utils.CERT_ULD));
		// for TSA use same templates as for ULD
		mapTypeCountryTemplates.put(AMS_Utils.CERT_TSA, mapTypeCountryTemplates.get(AMS_Utils.CERT_DGR));


		for(AMS_Agency_Regulation__c agReg: regulationsRequiringRenewal){

			Contact comCasecontact;

			if(keyContactsPerAccount!=null && keyContactsPerAccount.get(agReg.Account__c)!= null && !keyContactsPerAccount.get(agReg.Account__c).isEmpty()){
				//find portal admin
				for(Contact c: keyContactsPerAccount.get(agReg.Account__c)){
					if(c.User_Portal_Status__c == 'Approved Admin')
						comCasecontact = c;
				}

				//if no admin is found just use one of the existing keyContacts
				if(comCasecontact == null) comCasecontact = keyContactsPerAccount.get(agReg.Account__c).get(0);
			}

			Account account = allCertificates.get(agReg.Id).Account__r;
			String certificateType = agReg.Type_Of_Certificate__c;

			String key = certificateType + account.IATA_ISO_Country__c + account.Location_Class__c;
			Integer minDgrHO = minimumHORequirements.get(key) == null ? 0 : minimumHORequirements.get(key);
			Integer minDgrBR = minimumBRRequirements.get(key) == null ? 0 : minimumBRRequirements.get(key);

			String accountKey = agReg.Account__c+agReg.Type_of_Certificate__c;

			Integer activeCertificateInAccount = allNonExpiredCertificatesPerAccount.get(accountKey).size();
			Integer certificateToRenewInAccount = certificatesToRenewPerAccount.get(accountKey).size();
			Integer numberOfRemainingCertificatesInAccountToExpire = activeCertificateInAccount-certificateToRenewInAccount;

			if(renewalCertificatesPerAccount.get(accountKey) == -1){
				renewalCertificatesPerAccount.put(accountKey, numberOfRemainingCertificatesInAccountToExpire);
			}

			Integer numberOfActiveCertificates = renewalCertificatesPerAccount.get(accountKey);

			if(isCountBelowThreshold(accountData.get(agReg.Account__c), numberOfActiveCertificates, minDgrHO, minDgrBR, agReg.Type_Of_Certificate__c)){
				
				Boolean is90DaysNotif = agReg.Notification_Date__c == null; //if it's the 90 days notification them the OSCAR is created, otherwise we must query the existing OSCAR
				AMS_OSCAR__c oscar = null;
				if(is90DaysNotif){
					oscar = createStagingArea(agReg, accountData.get(agReg.Account__c), certificatesToRenewPerAccount.get(accountKey), comCasecontact);
					
					agReg.OSCAR__c = oscar.Id;
					update agReg;
				}else{
					if (certificateType == AMS_Utils.CERT_DGR) {
						oscar = [SELECT Id, Region__c,Oscar_Communication_Case_Id__c
							FROM AMS_OSCAR__c
							WHERE Account__c = :agReg.Account__c
							AND AMS_Online_Accreditation__r.DGR_Agency_Regulation__c = :agReg.Id
							AND Process__c = :AMS_Utils.CERTIFICATION
							order by CreatedDate desc
							limit 1];
					}
					if (certificateType == AMS_Utils.CERT_ULD) {
						oscar = [
							SELECT Id, Oscar_Communication_Case_Id__c
							FROM AMS_OSCAR__c
							WHERE Id = :agReg.OSCAR__c];
					}

				}
				if (oscar!=null) {
					map<String,Id> mapCountryTemplates = mapTypeCountryTemplates.get(certificateType);
					Boolean isDGR = (certificateType == AMS_Utils.CERT_DGR || certificateType == AMS_Utils.CERT_TSA);
					sendEmailAlert(keyContactsPerAccount.get(agReg.Account__c), oscar.Id, mapCountryTemplates, oscar.Oscar_Communication_Case_Id__c, getAgencyManagementOwa(), isDGR);
				}

				if(is90DaysNotif){
					renewalCertificatesPerAccount.put(accountKey, renewalCertificatesPerAccount.get(accountKey) + 1);
				}
			}
		}
	}

	private static Boolean isCountBelowThreshold(Account accountData, Integer numberOfActiveCertificates, Integer minimumHODgrRequirements, Integer minimumBRDgrRequirements,String typeOfCertificate){
		// for ULD
		if(typeOfCertificate == AMS_Utils.CERT_ULD) {
			if(accountData.Location_Type__c == AMS_Utils.HO) {
				return numberOfActiveCertificates < minimumHODgrRequirements;
			}
			if(accountData.Location_Type__c == AMS_Utils.BR) {
				return numberOfActiveCertificates < minimumBRDgrRequirements;
			}
			return false;
		}
		// for DGR
		if(accountData.Is_your_firm_handling_Dangerous_Goods__c != 'No'){
			//AMSU-208
			if(accountData.IATA_ISO_Country__r.ISO_Code__c == 'CN' && typeOfCertificate == AMS_Utils.CERT_DGR) {
				if(accountData.Location_Type__c == AMS_Utils.HO) {
					return numberOfActiveCertificates < 2;
				} else {
					return numberOfActiveCertificates < 1;
				}
			}

			//India has this particular exception to the normal behaviour, no check is to be done
			if(accountData.IATA_ISO_Country__r.ISO_Code__c == 'IN' && accountData.Location_Class__c == 'C' && accountData.Location_Type__c == AMS_Utils.BR && accountData.CASS_Number__c != null && Integer.valueOf(accountData.CASS_Number__c) >= 900 && Integer.valueOf(accountData.CASS_Number__c) <= 999)
				return false;
			else if(accountData.Location_Class__c == 'C'){
				if(accountData.Location_Type__c == AMS_Utils.HO && numberOfActiveCertificates < 2 )
					return true;
				else if(accountData.Location_Type__c == AMS_Utils.BR && numberOfActiveCertificates  < 1)
					return true;
			}else if(accountData.Location_Class__c == 'R'){
				//Only America is using DGR for Cass associate.
				if(accountData.Location_Type__c == AMS_Utils.HO && numberOfActiveCertificates < minimumHODgrRequirements )
					return true;
				else if(accountData.Location_Type__c == AMS_Utils.BR && numberOfActiveCertificates < minimumBRDgrRequirements){
					return true;
				}
			}
		}
		return false;
	}

	public static AMS_OSCAR__c createStagingArea(AMS_Agency_Regulation__c agReg, Account accountData, List<AMS_Agency_Regulation__c> regulations, Contact communicationCaseContact){

		//Fetching the assignment rules on case
		AssignmentRule AR = new AssignmentRule();
		AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

		//Creating the DMLOptions for "Assign using active assignment rules" checkbox
		Database.DMLOptions dmlOpts = new Database.DMLOptions();
		dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;

		Case theCommunicationCase = new Case();

		theCommunicationCase.RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM;
		theCommunicationCase.CaseArea__c = 'Accreditation Process';
		theCommunicationCase.AccountId = agReg.Account__c;
		theCommunicationCase.Account_Concerned__c = agReg.Account__c;
		theCommunicationCase.BSPCountry__c = accountData.BillingCountry;
		theCommunicationCase.Reason1__c = 'Certificate ' + agReg.Type_of_certificate__c;
		theCommunicationCase.Region__c = accountData.Region_formula__c;
		theCommunicationCase.SAAM_Deadline_Date__c = agReg.Expiry_Date__c; //FM - AMSU-32
		if(communicationCaseContact != null)
			theCommunicationCase.ContactId = communicationCaseContact.Id;
		if (agReg.Type_Of_Certificate__c == AMS_Utils.CERT_ULD) {
			theCommunicationCase.Subject = 'ULD Renewal - ' + accountData.IATACode__c + ' - ' + accountData.Name;
			AMS_OscarMigrationFromCase.changeSubject = false;
		}
		theCommunicationCase.setOptions(dmlOpts);

		insert theCommunicationCase;

		AMS_Pax_Accreditation_Form__c theStagingArea = new AMS_Pax_Accreditation_Form__c();

		theStagingArea.SAAM_Case__c                             = theCommunicationCase.Id;
		theStagingArea.Abbreviated_Address__c                   = accountData.Abbreviated_address__c;
		theStagingArea.Abbreviated_name__c                      = accountData.Abbreviated_name__c;
		theStagingArea.Accept_terms_and_conditions__c           = True;
		theStagingArea.Account_Name__c                          = accountData.Name;
		theStagingArea.Billing_State__c                         = accountData.BillingState;
		theStagingArea.Branch_Office_City__c                    = accountData.BillingCity;
		theStagingArea.Branch_Office_Country__c                 = accountData.IATA_ISO_Country__c;
		theStagingArea.Branch_Office_Email__c                   = accountData.Email__c;
		theStagingArea.Branch_Office_FAX__c                     = accountData.Fax;
		theStagingArea.Branch_Office_Phone__c                   = accountData.Phone;
		theStagingArea.Branch_Office_Postal_code__c             = accountData.BillingPostalCode;
		theStagingArea.Branch_Office_Street_name_number__c      = accountData.BillingStreet;
		theStagingArea.CASS_Number__c                           = accountData.CASS_Number__c;
		theStagingArea.IATACode__c                              = accountData.IATACode__c;
		theStagingArea.IATA_ISO_State__c                        = accountData.Iso_State__c;
		theStagingArea.ISSP_AMS_License_No__c                   = accountData.License_Number__c;
		theStagingArea.ISSP_AMS_VAT_number__c                   = accountData.VAT_Number__c;
		theStagingArea.Is_your_firm_handling_Dangerous_Goods__c = accountData.Is_your_firm_handling_Dangerous_Goods__c;
		theStagingArea.Location_Class__c                        = accountData.Location_Class__c;
		theStagingArea.Location_Type__c                         = accountData.Location_Type__c;
		theStagingArea.Mobile__c                                = accountData.Mobile__c;
		theStagingArea.Operation__c                             = accountData.Operation__c;
		theStagingArea.Remittance_frequency__c                  = accountData.Remittance_frequency__c;
		theStagingArea.Shipping_City__c                         = accountData.ShippingCity;
		theStagingArea.Shipping_Country__c                      = accountData.ShippingCountry;
		theStagingArea.Shipping_Postal_Code__c                  = accountData.ShippingPostalCode;
		theStagingArea.Shipping_State__c                        = accountData.ShippingState;
		theStagingArea.Shipping_Street__c                       = accountData.ShippingStreet;
		theStagingArea.Short_Name__c                            = accountData.Short_Name__c;
		theStagingArea.Solicitation_Flag__c                     = accountData.Solicitation_Flag__c;
		theStagingArea.Submitted_to_IATA__c                     = True;
		theStagingArea.Trade_Name__c                            = accountData.TradeName__c;
		theStagingArea.VAT_Number_2__c                          = accountData.VAT_Number_2__c;
		theStagingArea.Website__c                               = accountData.Website;
		theStagingArea.ISSP_AMS_Legal_Status__c                 = AMS_AgencyHelper.transformCompanyType(accountData.Company_Type__c);
		//FM 19-07-2017 - AMSU-14 -
		theStagingArea.DGR_Agency_Regulation__c                 = agReg.Id;

		insert theStagingArea;

		Case caseOscar = [SELECT OwnerId FROM Case WHERE Id =: theCommunicationCase.Id LIMIT 1];

		AMS_OSCAR__c theOscar = new AMS_OSCAR__c();
		theOscar.RecordTypeId = AMS_Utils.RECTYPE_CERT;
		theOscar.Account__c = agReg.Account__c;
		theOscar.Process__c = AMS_Utils.CERTIFICATION;
		theOscar.Status__c='Accepted_Future Date';
		theOscar.Change_effective_as_of__c = regulations[0].Expiry_Date__c;
		theOscar.Oscar_Communication_Case_Id__c = theCommunicationCase.Id;
		theOscar.Emails_reference_Id__c = AMS_Utils.caseRefId(UserInfo.getOrganizationId(), theCommunicationCase.Id);
		theOscar.AMS_Online_Accreditation__c = theStagingArea.Id;
		theOscar.OwnerId = caseOscar.OwnerId;
		insert theOscar;

		theCommunicationCase.OSCAR__c = theOscar.Id;
		update theCommunicationCase;

		convertExistingAgencyRegulationsToAccContact(theStagingArea.Id, regulations);

		return theOscar;
	}

	public static void convertExistingAgencyRegulationsToAccContact(Id stagingId, List<AMS_Agency_Regulation__c> regulations){

		List<AMS_Accreditation_Contact__c> accToInsert = new List<AMS_Accreditation_Contact__c>();

		//create trained staff accreditation contact from the existing agency regulations
		//in the accreditation contact we save the link to the agency regulation object.
		for(AMS_Agency_Regulation__c reg  :regulations){

			AMS_Accreditation_Contact__c ac = new AMS_Accreditation_Contact__c();

			ac.RecordTypeId = AMS_Utils.AccreditationContactTrainedStaffRT;
			ac.Certificate_Name__c = reg.Certificate_Name__c;
			ac.First_Name__c = reg.First_Name__c;
			ac.Last_Name__c = reg.Last_Name__c;
			ac.Position_trained_staff__c = reg.Position__c;
			ac.Type_of_Certificate__c = reg.Type_of_Certificate__c;
			ac.AMS_Pax_Accreditation_Form__c = stagingId;
			ac.Certificate_Issued_on__c = reg.Issued_on__c;
			ac.Certificate_Validity__c = reg.Validity__c;
			ac.Valid_until__c = reg.Expiry_Date__c;
			ac.Certificate_Issuer__c = reg.Issuer__c;
			ac.AgencyRegulation__c = reg.Id;
			ac.Air_cargo_transport_business_exp__c = reg.Air_cargo_transport_business_exp__c;
			ac.IATA_FIATA_training_history__c = reg.IATA_FIATA_training_history__c;
			ac.Training_dangerous_goods_completed__c = reg.Training_dangerous_goods_completed__c;
			ac.Registration_number__c = reg.Registration_Number__c; //AMSU-14

			accToInsert.add(ac);

		}

		if(!accToInsert.isEmpty())
			insert accToInsert;

	}

	private static List<OrgWideEmailAddress> getfromAddress(Id OrgWideEmailAddressId) {
		return [select Address,DisplayName from OrgWideEmailAddress where ID = :OrgWideEmailAddressId limit 1];
	}

	public static void sendEmailAlert(List<Contact> recipents, Id oscarId, Map<String, Id> countryTemplates, String oscarCommCaseId, OrgWideEmailAddress owea, boolean isDGR) {
		sendEmailAlert(recipents, oscarId, countryTemplates, oscarCommCaseId, owea, isDGR, null);
	}

	public static void sendEmailAlert(List<Contact> recipents, Id oscarId, Map<String, Id> countryTemplates, String oscarCommCaseId, OrgWideEmailAddress owea, boolean isDGR, Messaging.EmailFileAttachment[] attachments){
		sendEmailAlert(recipents, oscarId, countryTemplates, oscarCommCaseId, owea, isDGR, attachments, true);
	}

	public static List<Messaging.SingleEmailMessage> sendEmailAlert(List<Contact> recipents, Id oscarId, Map<String, Id> countryTemplates, String oscarCommCaseId, OrgWideEmailAddress owea, boolean isDGR, Messaging.EmailFileAttachment[] attachments, Boolean sendEmail) {
		Id templateId;
		Boolean templateToIATA = false;
		List<EmailTemplate> tempIata = new List<EmailTemplate>();

		if(recipents == null){
			templateToIATA = true;

			//getTemplate
			tempIata = [SELECT Id, DeveloperName, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'Info_To_IATA_AMS_DGR_Renewal_Not_Sent'];

			//get region
			List<AMS_OSCAR__c> oscars = [SELECT Id, Region__c FROM AMS_OSCAR__c WHERE Id = :oscarId];
			String region = oscars.get(0).Region__c;

			//get contact from IATA by custom setting
			List<IATA_Contacts_by_Region__c> customSettingValues = IATA_Contacts_by_Region__c.getall().values();
			List<String> emailsToSend = new List<String>();
			for(IATA_Contacts_by_Region__c cR : customSettingValues){
				if(cR.Region__c == region) emailsToSend.add(cR.Contact_Email__c);
			}

			//put the contacts in recipents list
			recipents = [SELECT Id, Email, AccountId, Preferred_Language__c, User_Portal_Status__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c FROM Contact WHERE Email IN :emailsToSend AND IsEmailBounced = false AND (NOT Email LIKE '%.inactive')];
		}

		if(recipents != null){

			List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
			String errorMsg = '';

			List<EmailMessage> mailsToTrackInCase = new List<EmailMessage>();

			//FM 24/10/2017 - AMSU-32 - when DGR case use only one mail message for all the Portal Admin, instead of a mail message per each
			List<String> lPortalAdminsEmailsDGR = new List<String>();
			Map<String, List<String>> mPortalAdminsEmailsDGR = new Map<String, List<String>>();
			Map<String, Contact> mRecipientPortalAdminsEmailsDGR = new Map<String, Contact>();

			for(Contact recipient: recipents){

				if(!isDGR || recipient.BSP_CASS_Payment_contact__c || recipient.Financial_Assessment_Contact__c || templateToIATA){

					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					mail.saveAsActivity = true;
					if(templateToIATA){
						mail.setTemplateId(tempIata.get(0).Id);
					} else {
						mail.setTemplateId(getSpecificLangTemplate(recipient.Preferred_Language__c, countryTemplates));
					}
					mail.setTargetObjectId(recipient.Id);

					if(attachments != null){
						mail.setFileAttachments(attachments);
					}
					mail.setWhatId(oscarId);
					mail.setOrgWideEmailAddressId(owea.Id);
					mailsToSend.add(mail);

				//FM 07-07-2017 - AMSU-14 - added the test for the DGR in order to allow it to send the notification to multiple contacts
				//PS - add to replicate because this method is being used by OSCAR trigger to send email that are not only related to Renewalls... otherwise I'll mess up the NewGen functionalities
				}else if(isDGR){

					//FM 24/10/2017 - AMSU-32
					if(recipient.User_Portal_Status__c == 'Approved Admin'){

						//lPortalAdminsEmailsDGR.add(recipient.Email);
						if(mPortalAdminsEmailsDGR.containsKey(recipient.Preferred_Language__c)){
							List<String> aux = mPortalAdminsEmailsDGR.get(recipient.Preferred_Language__c);
							aux.add(recipient.Email);
							mPortalAdminsEmailsDGR.put(recipient.Preferred_Language__c, aux);
						}else{
							List<String> aux = new List<String>();
							aux.add(recipient.Email);
							mPortalAdminsEmailsDGR.put(recipient.Preferred_Language__c, aux);
							mRecipientPortalAdminsEmailsDGR.put(recipient.Preferred_Language__c,recipient);
						}

					}else{
						Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
						mail.saveAsActivity = true;
						if(templateToIATA){
							mail.setTemplateId(tempIata.get(0).Id);
						} else {
							mail.setTemplateId(getSpecificLangTemplate(recipient.Preferred_Language__c, countryTemplates));
						}
						mail.setTargetObjectId(recipient.Id);
						mail.setWhatId(oscarId);
						mail.setOrgWideEmailAddressId(owea.Id);
						mailsToSend.add(mail);
					}
				}
			}

			//FM 24/10/2017 - AMSU-32
			if(mPortalAdminsEmailsDGR != null && mPortalAdminsEmailsDGR.size() > 0){
				for(String key : mPortalAdminsEmailsDGR.keySet()){
					Messaging.SingleEmailMessage mailPortalAdmin = new Messaging.SingleEmailMessage();
					mailPortalAdmin.saveAsActivity = true;
					mailPortalAdmin.setToAddresses(mPortalAdminsEmailsDGR.get(key));
					if(templateToIATA){
						mailPortalAdmin.setTemplateId(tempIata.get(0).Id);
					} else {
						mailPortalAdmin.setTemplateId(getSpecificLangTemplate(key, countryTemplates));
					}

					Contact auxCont = mRecipientPortalAdminsEmailsDGR.get(key);
					mailPortalAdmin.setTargetObjectId(auxCont.Id);
					mailPortalAdmin.setWhatId(oscarId);
					mailPortalAdmin.setOrgWideEmailAddressId(owea.Id);
					mailsToSend.add(mailPortalAdmin);
				}
			}
			//Return emails to be sent once ANG_:OscarProcess.createPCIComplianceOscars
			if(!sendEmail) return mailsToSend;

			if(!mailsToSend.isEmpty()){

				if (owea.Address==null) {
					owea = getfromAddress(owea.Id)[0];
				}

				CaseTeamRole partnerRole = [SELECT Id FROM CaseTeamRole WHERE Name = 'Partner User Role' LIMIT 1];
				if(!Test.isRunningTest()) Messaging.sendEmail(mailsToSend);
				for(Messaging.SingleEmailMessage mail: mailsToSend){
					EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
					emailMsg.FromAddress = owea.Address;
					emailMsg.FromName = owea.DisplayName;

					if(mail.getToAddresses() != null && !mail.getToAddresses().isEmpty()) {
						emailMsg.ToAddress= String.join(mail.getToAddresses(), ', ');//WMO-383 save all addresses
					}

					if(!String.isBlank(mail.getTargetObjectId())) {
						emailMsg.toIds = new List<Id>{ mail.getTargetObjectId() };
					}

					emailMsg.Subject = mail.getSubject();
					emailMsg.HtmlBody = mail.getHtmlBody();
					emailMsg.ParentId = oscarCommCaseId; //Attach with the case
					emailMsg.MessageDate = system.now();
					emailMsg.Status = '0';
					mailsToTrackInCase.add(emailMsg);
				}

				try {
					insert mailsToTrackInCase;
				} catch(Exception e){
					errorMsg='The following exception has occurred: ' +e.getMessage()+' :: Line number: ' + e.getLineNumber() +' :: Stack trace: ' +e.getStackTraceString();
				}

				if(String.isNotBlank(errorMsg)){
					List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
					for(SalesforceSupportEmails__c supportEmail: SalesforceSupportEmails__c.getAll().values()){
						Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
						mail.setTargetObjectId(supportEmail.Support_User_Id__c);
						mail.setSubject('AMS_AgencyRegulationAutoRenewal.sendEmailAlert failure');
						mail.setPlainTextBody(errorMsg);
						mail.setSaveAsActivity(false);
						mails.add(mail);
					}
					if (!mails.isEmpty()){
						Messaging.sendEmail(mails);
					}
				}

				// add recipients to Case Team
				list<CaseTeamMember > listCaseTeam = new list<CaseTeamMember>();
				for (Contact contact: recipents) {
					listCaseTeam.add(new CaseTeamMember(
						ParentId = oscarCommCaseId,
						MemberId = contact.Id,
						TeamRoleId = partnerRole.Id
					));
				}
				Database.insert(listCaseTeam, false);

			}
		}
		return new List<Messaging.SingleEmailMessage>();
	}

	public static Map<String, Id> getMapEmailTemplates(String type){

		Map<String, Id> multilangTemplates = new Map<String, Id>();

		String devNameLike = 'AMS_' + type + '_Renewal%';
		List<EmailTemplate> listTemplates = [SELECT Id, DeveloperName, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName LIKE :devNameLike];
		Map<String, EmailTemplate> countryTemplates = new Map<String, EmailTemplate>();
		for(EmailTemplate et: listTemplates){
			if(!countryTemplates.containsKey(et.DeveloperName))
				countryTemplates.put(et.DeveloperName, et);
		}

		//map template Ids with their respective language
		List<Schema.Picklistentry> prefLanguages = Contact.getSObjectType().getDescribe().fields.getMap().get('Preferred_Language__c').getDescribe().getPickListValues();

		for(Schema.Picklistentry pe: prefLanguages){
			EmailTemplate langTemplate = countryTemplates.get('AMS_' + type + '_Renewal_' + pe.getValue());

			//English is default and must exist in the system
			if(langTemplate == null) langTemplate = countryTemplates.get('AMS_' + type + '_Renewal_English');

			multilangTemplates.put(pe.getValue(), langTemplate.Id);
		}

		//this should never happen unless picklist values are deleted form the Contact Preferred_Language__c
		if(multilangTemplates.isEmpty()) multilangTemplates.put('English', countryTemplates.get('AMS_' + type + '_Renewal_English').Id);

		return multilangTemplates;

	}

	//return templateId based on lang selected, default English if none is found
	private static Id getSpecificLangTemplate(String lang, Map<String, Id> availableTemplates){
		if(availableTemplates.get(lang) != null) return availableTemplates.get(lang);
		else return availableTemplates.get('English');
	}

}
