global class AMS_AgencyRegulationAutoRenewal implements Database.Batchable<sObject>, Database.Stateful {

	public List<AMS_Agency_Regulation__c> agencyRegulations;
	public Map<Id, List<Contact>> keyContactsPerAccount;
	public Map<String, Integer> renewalCertificatesPerAccount;

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

		//DGR, TSA and CATA
		Map<Id, AMS_Agency_Regulation__c> allCertificates = new Map<Id, AMS_Agency_Regulation__c>([SELECT Id, Account__c, First_Name__c, Last_Name__c, Position__c, Type_of_Certificate__c, Account__r.IATACode__c, Account__r.IATA_ISO_Country__c, Account__r.Location_Class__c, Expired__c, Notification_Sent__c FROM AMS_Agency_Regulation__c WHERE Account__c IN :accts AND (Type_of_Certificate__c = 'DGR' OR Type_of_Certificate__c = 'TSA' OR Type_of_Certificate__c = 'CATA')]);

		system.debug('allCertificates: ' + allCertificates);

		for(AMS_Agency_Regulation__c agReg : allCertificates.values()){
			if(!agReg.Expired__c && !agReg.Notification_Sent__c){
				if(!allNonExpiredCertificatesPerAccount.containsKey(agReg.Account__c+agReg.Type_of_Certificate__c))
					allNonExpiredCertificatesPerAccount.put(agReg.Account__c+agReg.Type_of_Certificate__c, new List<AMS_Agency_Regulation__c>());
				allNonExpiredCertificatesPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c).add(agReg);
			}
		}

		system.debug('allNonExpiredCertificatesPerAccount ' + allNonExpiredCertificatesPerAccount);
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
		Map<String, Integer> minimumHODgrRequirements = new Map<String, Integer>();
		Map<String, Integer> minimumBRDgrRequirements = new Map<String, Integer>();

		for(IATA_ISO_Country__c country : IATAIsoCountryDAO.getIsoCountriesByIds(isoCountries))	{

			system.debug('country.AMS_Country_Specific_Attributes__r ' + country.AMS_Country_Specific_Attributes__r);
			for(AMS_Country_Specific_Attribute__c att : country.AMS_Country_Specific_Attributes__r){
				if(att != null && att.RecordType.Name == 'DGR Minimum Requirements' ){
					minimumHODgrRequirements.put(''+country.Id+att.Location_Class__c, att.Minimum_DGR_HO__c == null ? 0 : Integer.valueOf(att.Minimum_DGR_HO__c));
					minimumBRDgrRequirements.put(''+country.Id+att.Location_Class__c, att.Minimum_DGR_BR__c == null ? 0 : Integer.valueOf(att.Minimum_DGR_BR__c));
				}
			}
		}

		Map<String, Id> countryTemplates = DGRemailTemplates('DGR');
        Map<String, Id> countryTemplatesCATA = DGRemailTemplates('CATA');
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'agencymanagement@iata.org'];

		for(AMS_Agency_Regulation__c agReg: regulationsRequiringRenewal){

			Contact comCasecontact;

            if(keyContactsPerAccount!=null && keyContactsPerAccount.get(agReg.Account__c)!= null && !keyContactsPerAccount.get(agReg.Account__c).isEmpty()){
				system.debug('keyContactsPerAccount ' + keyContactsPerAccount);
				//find portal admin
				for(Contact c: keyContactsPerAccount.get(agReg.Account__c)){
					if(c.User_Portal_Status__c == 'Approved Admin')
						comCasecontact = c;
				}

				system.debug('CHECK comcasecontact' + keyContactsPerAccount.get(agReg.Account__c).get(0));
				//if no admin is found just use one of the existing keyContacts
				if(comCasecontact == null) comCasecontact = keyContactsPerAccount.get(agReg.Account__c).get(0);
			}

			if(agReg.Type_Of_Certificate__c == AMS_Utils.CERT_DGR){
				//only create renewal if account is going below DGR requirements
				String key = allCertificates.get(agReg.Id).Account__r.IATA_ISO_Country__c + allCertificates.get(agReg.Id).Account__r.Location_Class__c;
				system.debug('key value ' + key);
				Integer minDgrHO = minimumHODgrRequirements.get(key) == null ? 0 : minimumHODgrRequirements.get(key);
				system.debug('minDgrHO ' + minDgrHO);
				Integer minDgrBR = minimumBRDgrRequirements.get(key) == null ? 0 : minimumBRDgrRequirements.get(key);
				system.debug('minDgrBR ' + minDgrBR);

				//FM 07-07-2017 - AMSU-14
				Boolean is90DaysNotif = true; //if it's the 90 days notification them the OSCAR is created, otherwise we must query the existing OSCAR
				if(agReg.Notification_Date__c != null){
					is90DaysNotif = false;
				}

				Integer activeDGRInAccount = allNonExpiredCertificatesPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c).size();
				Integer dgrToRenewInAccount = certificatesToRenewPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c).size();
				Integer numberOfRemainingDGRInAccountToExpire = activeDGRInAccount-dgrToRenewInAccount;

				System.debug('DGR renewalCertificatesPerAccount before if: ' + renewalCertificatesPerAccount);

				if(renewalCertificatesPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c) == -1){
					renewalCertificatesPerAccount.put(agReg.Account__c+agReg.Type_of_Certificate__c, numberOfRemainingDGRInAccountToExpire);
				}

				System.debug('DGR renewalCertificatesPerAccount after if: ' + renewalCertificatesPerAccount);

				Integer numberOfActiveDGR = renewalCertificatesPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c);

				System.debug('DGR numberOfActiveDGR: ' + numberOfActiveDGR);

				system.debug('creating renewal for DGR ' + numberOfRemainingDGRInAccountToExpire);
				if(isCountBelowThreshold(accountData.get(agReg.Account__c), numberOfActiveDGR, minDgrHO, minDgrBR,agReg.Type_Of_Certificate__c)){

					system.debug('creating renewal for DGR');

					//FM 07-07-2017 - AMSU-14 - only create OSCAR on the 90 days notification otherwise we need to query the existing one
					AMS_OSCAR__c oscar = null;
					if(is90DaysNotif){
						oscar = createStagingArea(agReg, accountData.get(agReg.Account__c), certificatesToRenewPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c), comCasecontact);
						agReg.OSCAR__c = oscar.Id;
						update agReg;
					}else{
						String sContactName = agReg.First_Name__c + ' ' +agReg.Last_Name__c;
						
						oscar = [SELECT Id, Region__c,Oscar_Communication_Case_Id__c FROM AMS_OSCAR__c WHERE Account__c = :agReg.Account__c
										AND AMS_Online_Accreditation__r.DGR_Agency_Regulation__c = :agReg.Id
										AND Process__c = :AMS_Utils.CERTIFICATION
										order by CreatedDate desc
										limit 1];
					}
					
					System.debug('oscar: ' + oscar);
					sendEmailAlert(keyContactsPerAccount.get(agReg.Account__c), oscar.Id, countryTemplates, oscar.Oscar_Communication_Case_Id__c, owea[0], true);

					//FM 07-07-2017 - AMSU-14 - only create OSCAR on the 90 days notification
					if(is90DaysNotif){
						renewalCertificatesPerAccount.put(agReg.Account__c+agReg.Type_of_Certificate__c, renewalCertificatesPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c) + 1);
					}
				}
			}
			else if(agReg.Type_Of_Certificate__c == AMS_Utils.CERT_CATA){
				system.debug('creating renewal for CATA');


				Integer activeCATAInAccount = allNonExpiredCertificatesPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c).size();
				Integer cATAToRenewInAccount = certificatesToRenewPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c).size();
				Integer numberOfRemainingCATAInAccountToExpire = activeCATAInAccount-cATAToRenewInAccount;

				if(renewalCertificatesPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c) == -1){
					renewalCertificatesPerAccount.put(agReg.Account__c+agReg.Type_of_Certificate__c,  numberOfRemainingCATAInAccountToExpire);
				}

				Integer numberOfActiveCATA = renewalCertificatesPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c);

				system.debug('creating renewal for CATA ' + numberOfRemainingCATAInAccountToExpire);

				if(isCountBelowThreshold(accountData.get(agReg.Account__c), numberOfActiveCATA, 0, 0,agReg.Type_Of_Certificate__c)){

                    System.debug('## enter isCountBelowThreshold CATA');

					AMS_OSCAR__c oscar = createStagingArea(agReg, accountData.get(agReg.Account__c), certificatesToRenewPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c), comCasecontact);

					sendEmailAlert(keyContactsPerAccount.get(agReg.Account__c), oscar.Id, countryTemplatesCATA, oscar.Oscar_Communication_Case_Id__c, owea[0], true);

					renewalCertificatesPerAccount.put(agReg.Account__c+agReg.Type_of_Certificate__c, renewalCertificatesPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c) + 1);
				}

			}
			else if(agReg.Type_Of_Certificate__c == AMS_Utils.CERT_TSA){
				//only create renewal if account is going below DGR requirements
				String key = allCertificates.get(agReg.Id).Account__r.IATA_ISO_Country__c + allCertificates.get(agReg.Id).Account__r.Location_Class__c;
				system.debug('key value ' + key);
				Integer minDgrHO = minimumHODgrRequirements.get(key) == null ? 0 : minimumHODgrRequirements.get(key);
				system.debug('minDgrHO ' + minDgrHO);
				Integer minDgrBR = minimumBRDgrRequirements.get(key) == null ? 0 : minimumBRDgrRequirements.get(key);
				system.debug('minDgrBR ' + minDgrBR);

				Integer activeDGRInAccount = allNonExpiredCertificatesPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c).size();
				Integer dgrToRenewInAccount = certificatesToRenewPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c).size();
				Integer numberOfRemainingTSAInAccountToExpire = activeDGRInAccount-dgrToRenewInAccount;


				if(renewalCertificatesPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c) == -1){
					renewalCertificatesPerAccount.put(agReg.Account__c+agReg.Type_of_Certificate__c, numberOfRemainingTSAInAccountToExpire);
				}

				Integer numberOfActiveTSA = renewalCertificatesPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c);

				if(isCountBelowThreshold(accountData.get(agReg.Account__c), numberOfActiveTSA, minDgrHO, minDgrBR,agReg.Type_Of_Certificate__c)){

					system.debug('creating renewal for TSA');
					AMS_OSCAR__c oscar = createStagingArea(agReg, accountData.get(agReg.Account__c), certificatesToRenewPerAccount.get(agReg.Account__c+agReg.Type_of_Certificate__c), comCasecontact);

					sendEmailAlert(keyContactsPerAccount.get(agReg.Account__c), oscar.Id, countryTemplates, oscar.Oscar_Communication_Case_Id__c, owea[0], true);
				}
			}
		}
    }

    private static Boolean isCountBelowThreshold(Account accountData, Integer numberOfActiveCertificates, Integer minimumHODgrRequirements, Integer minimumBRDgrRequirements,String typeOfCertificate){

        if(accountData.Is_your_firm_handling_Dangerous_Goods__c != 'No'){
        	//AMSU-208
        	if(accountData.IATA_ISO_Country__r.ISO_Code__c == 'CN' && typeOfCertificate == AMS_Utils.CERT_DGR) {
        		if(accountData.Location_Type__c == AMS_Utils.HO) {
        			return numberOfActiveCertificates < 2;
    			} else {
    				return numberOfActiveCertificates < 1;
    			}
        	}

            //China
            if(typeOfCertificate == AMS_Utils.CERT_CATA && accountData.IATA_ISO_Country__r.ISO_Code__c == 'CN' && accountData.Location_Class__c == 'C' && numberOfActiveCertificates == 0)
            	return true;
            //India has this particular exception to the normal behaviour, no check is to be done
            else if(accountData.IATA_ISO_Country__r.ISO_Code__c == 'IN' && accountData.Location_Class__c == 'C' && accountData.Location_Type__c == AMS_Utils.BR && accountData.CASS_Number__c != null && Integer.valueOf(accountData.CASS_Number__c) >= 900 && Integer.valueOf(accountData.CASS_Number__c) <= 999)
            	return false;
            else if(accountData.Location_Class__c == 'C'){
                if(accountData.Location_Type__c == AMS_Utils.HO && numberOfActiveCertificates < 2 )
                    return true;
                else if(accountData.Location_Type__c == AMS_Utils.BR && numberOfActiveCertificates  < 1)
                    return true;
            }else if(accountData.Location_Class__c == 'R'){
                //Only America is using DGR for Cass associate.
                if(accountData.Location_Class__c == AMS_Utils.HO && numberOfActiveCertificates < minimumHODgrRequirements )
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
        //theCommunicationCase.Subject = 'DGR renewal - ' + accountData.Name + ' - ' + accountData.IATACode__c;
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
        theStagingArea.DGR_Agency_Regulation__c					= agReg.Id;	

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

        system.debug('createStagingArea oscar: '+ theOscar);

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

    public static void sendEmailAlert(List<Contact> recipents, Id oscarId, Map<String, Id> countryTemplates, String oscarCommCaseId, OrgWideEmailAddress owea, boolean isDGR) {

		sendEmailAlert(recipents, oscarId, countryTemplates, oscarCommCaseId, owea, isDGR, null);
    }

    public static void sendEmailAlert(List<Contact> recipents, Id oscarId, Map<String, Id> countryTemplates, String oscarCommCaseId, OrgWideEmailAddress owea, boolean isDGR, Messaging.EmailFileAttachment[] attachments) {
        
        Id templateId;
        Boolean templateToIATA = false;
        List<EmailTemplate> tempIata = new List<EmailTemplate>();

        if(recipents == null)
        {
        	templateToIATA = true;

        	//getTemplate
        	tempIata = [SELECT Id, DeveloperName, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'Info_To_IATA_AMS_DGR_Renewal_Not_Sent'];
        	
        	//get region
        	List<AMS_OSCAR__c> oscars = [SELECT Id, Region__c FROM AMS_OSCAR__c WHERE Id = :oscarId];
        	String region = oscars.get(0).Region__c;

        	//get contact from IATA by custom setting
        	List<IATA_Contacts_by_Region__c> customSettingValues = IATA_Contacts_by_Region__c.getall().values();
        	List<String> emailsToSend = new List<String>();
			for(IATA_Contacts_by_Region__c cR : customSettingValues)
			{
				if(cR.Region__c == region)
					emailsToSend.add(cR.Contact_Email__c);
			}
        	
        	//put the contacts in recipents list
        	recipents = [SELECT Id, Email, AccountId, Preferred_Language__c, User_Portal_Status__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c FROM Contact WHERE Email IN :emailsToSend];
        	System.debug('IATA recipents list: ' + recipents);
        }

        if(recipents != null){

            List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();

            system.debug('DGR sendEmailAlert: country templates ' + countryTemplates);
            system.debug('DGR sendEmailAlert: recipents ' + recipents);

            List<EmailMessage> mailsToTrackInCase = new List<EmailMessage>();

            //FM 24/10/2017 - AMSU-32 - when DGR case use only one mail message for all the Portal Admin, instead of a mail message per each
            List<String> lPortalAdminsEmailsDGR = new List<String>();
            Map<String, List<String>> mPortalAdminsEmailsDGR = new Map<String, List<String>>();
            Map<String, Contact> mRecipientPortalAdminsEmailsDGR = new Map<String, Contact>();

            for(Contact recipient: recipents){

                if(!isDGR || recipient.BSP_CASS_Payment_contact__c || recipient.Financial_Assessment_Contact__c || templateToIATA){

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.saveAsActivity = true;
                    mail.setToAddresses(new List<String>{recipient.Email});
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

                	system.debug('DGR sendEmailAlert: isDGR ' + isDGR);

                	//FM 24/10/2017 - AMSU-32 
					if(recipient.User_Portal_Status__c == 'Approved Admin'){

						system.debug('DGR sendEmailAlert: Entrei!! - recipient.User_Portal_Status__c ' + recipient.User_Portal_Status__c);
						system.debug('DGR sendEmailAlert: Pref Lang ' + recipient.Preferred_Language__c);

						//lPortalAdminsEmailsDGR.add(recipient.Email);
						if(mPortalAdminsEmailsDGR.containsKey(recipient.Preferred_Language__c)){
							system.debug('DGR sendEmailAlert: Already contain record for Pref Lang : ' + recipient.Preferred_Language__c);
							List<String> aux = mPortalAdminsEmailsDGR.get(recipient.Preferred_Language__c);
							aux.add(recipient.Email);
							mPortalAdminsEmailsDGR.put(recipient.Preferred_Language__c, aux);
						}else{
							system.debug('DGR sendEmailAlert: NO record for Pref Lang : ' + recipient.Preferred_Language__c);
							List<String> aux = new List<String>();
							aux.add(recipient.Email);
							mPortalAdminsEmailsDGR.put(recipient.Preferred_Language__c, aux);
							mRecipientPortalAdminsEmailsDGR.put(recipient.Preferred_Language__c,recipient);
						}

						system.debug('DGR sendEmailAlert: mPortalAdminsEmailsDGR ' + mPortalAdminsEmailsDGR);


					}else{
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.saveAsActivity = true;
                    mail.setToAddresses(new List<String>{recipient.Email});
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
            		
					system.debug('DGR sendEmailAlert: key : ' + key);
					system.debug('DGR sendEmailAlert: List : mPortalAdminsEmailsDGR.get(key) : ' + mPortalAdminsEmailsDGR.get(key));

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

            system.debug('DGR sendEmailAlert: mailsToSend : ' + mailsToSend);

            if(!mailsToSend.isEmpty()){
                if(!Test.isRunningTest()) Messaging.sendEmail(mailsToSend);
                for(Messaging.SingleEmailMessage mail: mailsToSend)
                {
                    EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
                    emailMsg.ToAddress=(mail.getToAddresses())[0];
                    emailMsg.Subject = mail.getSubject();
                    emailMsg.HtmlBody = mail.getHtmlBody();
                    emailMsg.ParentId = oscarCommCaseId; //Attach with the case
                    emailMsg.MessageDate = system.now();
                    emailMsg.Status = '0';
                    mailsToTrackInCase.add(emailMsg);
                }
                insert mailsToTrackInCase;
            }

        }
    }

    private static Map<String, Id> DGRemailTemplates(String type){

        Map<String, Id> multilangTemplates = new Map<String, Id>();

        String devNameLike = 'AMS_' + type + '_Renewal%';
        List<EmailTemplate> etDGR = [SELECT Id, DeveloperName, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName LIKE :devNameLike];
        Map<String, EmailTemplate> countryTemplates = new Map<String, EmailTemplate>();
        for(EmailTemplate et: etDGR){
            if(!countryTemplates.containsKey(et.DeveloperName))
                countryTemplates.put(et.DeveloperName, et);
        }

        system.debug('CHECK countryTemplates ' + countryTemplates);

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

        system.debug(type + ' templates mapping ' + multilangTemplates);

        return multilangTemplates;

    }

    //return templateId based on lang selected, default English if none is found
    private static Id getSpecificLangTemplate(String lang, Map<String, Id> availableTemplates){
        if(availableTemplates.get(lang) != null) return availableTemplates.get(lang);
        else return availableTemplates.get('English');
    }

}