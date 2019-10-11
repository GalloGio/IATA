public class AMS_ManageCertificatesController {
	public Id certCaseId {
		get {
			String paramCaseId = ApexPages.currentPage().getParameters().get('caseId');
			certCaseId = certCaseId == null ? paramCaseId : certCaseId;
			return certCaseId;
		}
		set;
	}
	public FileConfiguration fileConfig {
		get {
			if(fileConfig == null) {
				fileConfig = new FileConfiguration(); 
			}
			return fileConfig;
		}
		set;
	}
	public GenericData dataConfig {
		get {
			if(dataConfig == null) {
				dataConfig = new GenericData(certCaseId, null);
			}
			return dataConfig;
		}
		set;
	}

	public AMS_ManageCertificatesController() {}

	@RemoteAction
	public static String createAmazonFile(Id caseId, String uploadedFileName, String uploadedFileIdentifier, Integer uploadedFileSize) {
		String folder = '500/' + caseId +'/';

		try {
			AmazonFile__c amazonFile = new AmazonFile__c(
				Name = uploadedFileName,
				Full_Name_Unique__c = folder + uploadedFileName,
				File_Identifier__c = uploadedFileIdentifier,
				File_Identifier_picklist__c = uploadedFileIdentifier,
				Review_Status__c = 'Pending',
				RecordTypeId = Schema.SObjectType.AmazonFile__c.RecordTypeInfosByName.get('AMS File').RecordTypeId,
				Size_MB__c = uploadedFileSize* 0.000001, //convert to MB
				isPublic__c = true,
				Case__c = caseId
			);
			insert amazonFile;

			return amazonFile.Id;
		} catch(Exception e) {
			return e.getMessage();
		}
	}

	public PageReference enableEditMode() {
		dataConfig.editMode = true;
		dataConfig.fileNames = null;
		return null;
	}

	public PageReference cancel() {
		dataConfig.loadTrainnedStaff();
		dataConfig.editMode = false;
		dataConfig.hasError = false;
		dataConfig.errorMessages = null;
		dataConfig.fileNames = null;
		return null;		
	}

	public PageReference addStaffMember() {
		AMS_Accreditation_Contact__c accContact = new AMS_Accreditation_Contact__c();
		accContact.RecordTypeId = AMS_Utils.AccreditationContactTrainedStaffRT;
		accContact.Type_Of_Certificate__c = 'DGR';
		Person p = new Person(accContact, false, dataConfig.trainedStaffList.size(), true, null);
		dataConfig.mapCasePerStaff.put(dataConfig.trainedStaffList.size(), null);
		dataConfig.trainedStaffList.add(p);
		return null;
	}

	public PageReference updateCertificates() {
		Savepoint sp = Database.setSavepoint();
		dataConfig.hasError = false;
		dataConfig.errorMessages = null;

		List<AMS_Accreditation_Contact__c> contactsToCheckCase = new List<AMS_Accreditation_Contact__c>();
		List<AMS_Accreditation_Contact__c> contactsToUpsert = new List<AMS_Accreditation_Contact__c>();
		List<Person> staffMembersToAddCase = new List<Person>();

		Set<String> errorsLst = new Set<String>();
		Date minValidDate = Date.today().addDays(90);
		for(Person p : dataConfig.trainedStaffList) {
			if(p.accContact.Valid_until__c < minValidDate) {
				errorsLst.add('All certificates must be valid on the next 90 days.');
			}
			if(p.accContact.Certificate_Issued_on__c > Date.today()) {
				errorsLst.add('All certificates must be issued on past date.');
			}

			if(!p.hasCaseOpenCase) {
				contactsToCheckCase.add(p.accContact);
				staffMembersToAddCase.add(p);
			} else {
				contactsToUpsert.add(p.accContact);
			}
		}

		if(!errorsLst.isEmpty()) {
			dataConfig.hasError = true;
			dataConfig.errorMessages = String.join(new List<String>(errorsLst), '\n');
			return null;
		}

		Id stgAreaId;
		Id oscarId;		
		Id caseId;
		if(!contactsToCheckCase.isEmpty()) {
			Id caseRT = AMS_Utils.RECTYPE_OSCARCOMM;
			Id oscarRT = AMS_Utils.RECTYPE_CERT;
			String oscarProcess = AMS_Utils.CERTIFICATION;
			List<Case> cases = [SELECT Id, OSCAR__c, OSCAR__r.AMS_Online_Accreditation__c
								FROM Case 
								WHERE RecordTypeId = :caseRT AND Reason1__c = 'Certificate DGR' AND AccountId = :dataConfig.accountId AND 
									IsClosed = false AND OSCAR__r.RecordTypeId = :oscarRT AND OSCAR__r.Process__c = :oscarProcess LIMIT 1];
			
			if(cases.isEmpty()) {
				List<Id> ids = createCertificationCase();
				stgAreaId = ids[0];
				oscarId = ids[1];
				caseId = ids[2];
			} else {
				oscarId =  cases[0].OSCAR__c;
				stgAreaId = cases[0].OSCAR__r.AMS_Online_Accreditation__c;
				caseId = cases[0].Id;
			}

			for(Person p : staffMembersToAddCase) {
				p.accContact.AMS_Pax_Accreditation_Form__c = stgAreaId;
				p.caseId = caseId;
				dataConfig.mapCasePerStaff.put(p.index, caseId);
				contactsToUpsert.add(p.accContact);
			}
		}

		Set<String> fileNames = new Set<String> (dataConfig.fileNames.split(':'));
		System.debug('fileNames: ' + fileNames);
		System.debug('caseId: ' + caseId);
		List<AmazonFile__c> duplicatedFiles = [SELECT Id, Case__r.CaseNumber FROM AmazonFile__c WHERE Case__c = :caseId AND Name IN :fileNames];
		if(!duplicatedFiles.isEmpty()) {
			dataConfig.hasError = true;
			dataConfig.errorMessages = 'Failed to attach new certificates to case ' + duplicatedFiles[0].Case__r.CaseNumber + '\n';
			dataConfig.errorMessages += 'All files on the case must have unique names.';
			return null;
		}

		try {
			System.debug('contactsToUpsert: ' + contactsToUpsert);

			upsert contactsToUpsert;

			System.debug('agRegsToUpdate: ' + contactsToUpsert);

			List<AMS_Agency_Regulation__c> agRegsToUpdate = new List<AMS_Agency_Regulation__c>();
			for(AMS_Accreditation_Contact__c accContact : contactsToUpsert) {
				System.debug('accContact.AgencyRegulation__r.OSCAR__c: ' + accContact.AgencyRegulation__r.OSCAR__c);
				if(accContact.AgencyRegulation__c != null && accContact.AgencyRegulation__r.OSCAR__c == null) {
					AMS_Agency_Regulation__c agReg = new AMS_Agency_Regulation__c();
					agReg.Id = accContact.AgencyRegulation__c;
					agReg.OSCAR__c = oscarId;
					agRegsToUpdate.add(agReg);
				}
			}

			System.debug('agRegsToUpdate: ' + agRegsToUpdate);

			if(!agRegsToUpdate.isEmpty()) {
				update agRegsToUpdate;
			}
		} catch(Exception e) {
			Database.rollback(sp);
			dataConfig.hasError = true;
			dataConfig.errorMessages = e.getMessage();
			return null;
		}

		dataConfig.editMode = false;
		dataConfig.fileNames = null;
		return null;
	}

	private List<Id> createCertificationCase() {
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule = true;

		Account acc = [SELECT Id, BillingCountry, Region_formula__c, Abbreviated_address__c, Abbreviated_name__c, Name, BillingState, BillingCity,
							  IATA_ISO_Country__c, Email__c, Fax, Phone, BillingPostalCode, BillingStreet, CASS_Number__c, IATACode__c, Iso_State__c,
							  License_Number__c, VAT_Number__c, Is_your_firm_handling_Dangerous_Goods__c, Location_Class__c, Location_Type__c, Mobile__c,
							  Operation__c, Remittance_frequency__c, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet,
							  Short_Name__c, Solicitation_Flag__c, TradeName__c, VAT_Number_2__c, Website, Company_Type__c 
					   FROM Account 
					   WHERE Id = :dataConfig.accountId];

		Case cse = new Case();
		cse.RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM;
		cse.CaseArea__c = 'Accreditation Process';
		cse.AccountId = acc.Id;
		cse.Account_Concerned__c = acc.Id;
		cse.BSPCountry__c = acc.BillingCountry;
		cse.Reason1__c = 'Certificate DGR';
		cse.Region__c = acc.Region_formula__c;
		cse.ContactId = dataConfig.contactId;
		cse.setOptions(dmo);
		insert cse;

		AMS_Pax_Accreditation_Form__c stgArea = new AMS_Pax_Accreditation_Form__c();
		stgArea.SAAM_Case__c = cse.Id;
		stgArea.Abbreviated_Address__c = acc.Abbreviated_address__c;
		stgArea.Abbreviated_name__c = acc.Abbreviated_name__c;
		stgArea.Accept_terms_and_conditions__c = true;
		stgArea.Account_Name__c = acc.Name;
		stgArea.Billing_State__c = acc.BillingState;
		stgArea.Branch_Office_City__c = acc.BillingCity;
		stgArea.Branch_Office_Country__c = acc.IATA_ISO_Country__c;
		stgArea.Branch_Office_Email__c = acc.Email__c;
		stgArea.Branch_Office_FAX__c = acc.Fax;
		stgArea.Branch_Office_Phone__c = acc.Phone;
		stgArea.Branch_Office_Postal_code__c = acc.BillingPostalCode;
		stgArea.Branch_Office_Street_name_number__c = acc.BillingStreet;
		stgArea.CASS_Number__c = acc.CASS_Number__c;
		stgArea.IATACode__c = acc.IATACode__c;
		stgArea.IATA_ISO_State__c = acc.Iso_State__c;
		stgArea.ISSP_AMS_License_No__c = acc.License_Number__c;
		stgArea.ISSP_AMS_VAT_number__c = acc.VAT_Number__c;
		stgArea.Is_your_firm_handling_Dangerous_Goods__c = acc.Is_your_firm_handling_Dangerous_Goods__c;
		stgArea.Location_Class__c = acc.Location_Class__c;
		stgArea.Location_Type__c = acc.Location_Type__c;
		stgArea.Mobile__c = acc.Mobile__c;
		stgArea.Operation__c = acc.Operation__c;
		stgArea.Remittance_frequency__c = acc.Remittance_frequency__c;
		stgArea.Shipping_City__c = acc.ShippingCity;
		stgArea.Shipping_Country__c = acc.ShippingCountry;
		stgArea.Shipping_Postal_Code__c = acc.ShippingPostalCode;
		stgArea.Shipping_State__c = acc.ShippingState;
		stgArea.Shipping_Street__c = acc.ShippingStreet;
		stgArea.Short_Name__c = acc.Short_Name__c;
		stgArea.Solicitation_Flag__c = acc.Solicitation_Flag__c;
		stgArea.Submitted_to_IATA__c = true;
		stgArea.Trade_Name__c = acc.TradeName__c;
		stgArea.VAT_Number_2__c = acc.VAT_Number_2__c;
		stgArea.Website__c = acc.Website;
		stgArea.ISSP_AMS_Legal_Status__c = AMS_AgencyHelper.transformCompanyType(acc.Company_Type__c);
		insert stgArea;

		cse = [SELECT OwnerId FROM Case WHERE Id =: cse.Id];

		AMS_OSCAR__c oscar = new AMS_OSCAR__c();
		oscar.RecordTypeId = AMS_Utils.RECTYPE_CERT;
		oscar.Account__c = acc.Id;
		oscar.Process__c = AMS_Utils.CERTIFICATION; 
		oscar.Status__c='Accepted_Future Date'; 
		oscar.Oscar_Communication_Case_Id__c = cse.Id;
		oscar.Emails_reference_Id__c = AMS_Utils.caseRefId(UserInfo.getOrganizationId(), cse.Id);
		oscar.AMS_Online_Accreditation__c = stgArea.Id;
		oscar.OwnerId = cse.OwnerId;
        insert oscar;

        cse.OSCAR__c = oscar.Id;
        update cse;

		return new List<Id> {stgArea.Id, oscar.Id, cse.Id};
	}

	public PageReference refreshList() {
		dataConfig.loadTrainnedStaff();
		if(!dataConfig.hasError) {
			dataConfig.editMode = false;
			dataConfig.trainnedStaffIds = '';
			dataConfig.fileNames = null;
		}
		return null;
	}

	public PageReference redirectToTrainedStaffPage() {
		PageReference ret = new PageReference('/ISSP_CertificationCases?MainNav=Services&subNav=TrainedStaff');
		ret.setRedirect(true);
		return ret;
	}

	public class Person {
		public AMS_Accreditation_Contact__c accContact {get;set;}
		public Boolean hasCaseOpenCase {get;set;}
		public Integer index {get;set;}
		public Boolean isNewContact {get;set;}
		public Id caseId {get;set;}

		public Person(AMS_Accreditation_Contact__c accContact, Boolean hasCaseOpenCase, Integer index, Boolean isNewContact, Id caseId) {
			this.accContact = accContact;
			this.hasCaseOpenCase = hasCaseOpenCase;
			this.index = index;
			this.isNewContact = isNewContact;
			this.caseId = caseId;
		}
	}

	public class GenericData {
		public Id caseId {get;set;}
		public Id accountId {get;set;}
		public Boolean hasError {get;set;}
		public String errorMessages {get;set;}
		public Boolean editMode {get;set;}
		public Boolean isPortalAdmin {get;set;}
		public Id contactId {get;set;}
		public List<Person> trainedStaffList {get;set;}
		public String trainnedStaffIds {get;set;}
		public String fileNames {get;set;}
		public Map<Integer,Id> mapCasePerStaff {get;set;}
		public String mapCasePerStaffStr {
			get {
				return JSON.serialize(mapCasePerStaff);
			}
			set;
		}

		public GenericData(Id caseId, Id accountId) {
			this.caseId = caseId;
			this.accountId = accountId;
			this.hasError = false;
			this.editMode = false;
			User u = [SELECT ContactId, Contact.User_Portal_Status__c FROM User WHERE Id = :UserInfo.getUserId()];
			this.isPortalAdmin = u.Contact.User_Portal_Status__c.contains('Admin');	
			this.contactId = u.ContactId;	
			mapCasePerStaff = new Map<Integer,String>();
			loadTrainnedStaff();			
		}

		public void loadTrainnedStaff() {
			System.debug('Load Trainned Staff');

			this.trainedStaffList = new List<Person>();

			System.debug('caseId: ' + caseId);

			if(caseId != null) {
				loadRenewalStaff();
			} else {
				loadNewCertificatesStaff();
			}
		}

		private void loadRenewalStaff() {
			System.debug('Load Renewal Staff');

			String query = 'SELECT Id, '; 
			query += '(SELECT Id, AMS_Pax_Accreditation_Form__c, First_name__c, Last_Name__c, Valid_until__c, Certificate_Issuer__c, Position_trained_staff__c, ';
			query += ' Certificate_Issued_on__c, Email__c, Company__c, AgencyRegulation__c, AgencyRegulation__r.OSCAR__c, Type_Of_Certificate__c FROM AMS_Accreditation_Contacts__r) ';
			query += 'FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__c = :caseId';

			System.debug('query: ' + query);
			System.debug('caseId: ' + caseId);
			
			List<AMS_Pax_Accreditation_Form__c> stgArea = (List<AMS_Pax_Accreditation_Form__c>) Database.query(query);
			if(stgArea.isEmpty()) {
				return;
			}
			Integer index = 0;
			for(AMS_Accreditation_Contact__c accContact : stgArea[0].AMS_Accreditation_Contacts__r) {
				trainedStaffList.add(new Person(accContact, true, index, false, caseId));
				mapCasePerStaff.put(index, caseId);
				index++;
			}
		}

		private void loadNewCertificatesStaff() {
			if(String.isBlank(trainnedStaffIds)) {
				return;
			}

			List<String> idsList = trainnedStaffIds.split(',');
			String query = 'SELECT Id, First_name__c, Last_Name__c, Expiry_Date__c, Issuer__c, Position__c, Account__c, Email__c, Issued_on__c, OSCAR__c, ';
			query += 'OSCAR__r.Status__c, OSCAR__r.AMS_Online_Accreditation__c, Type_Of_Certificate__c ';
			query += 'FROM AMS_Agency_Regulation__c WHERE Id IN :idsList';
			
			List<AMS_Agency_Regulation__c> agRegs = (List<AMS_Agency_Regulation__c>) Database.query(query);
			List<AMS_Agency_Regulation__c> agRegsWithCase = new List<AMS_Agency_Regulation__c>();
			Set<Id> stgAreaIds = new Set<Id>();
			Integer index = 0;
			for(AMS_Agency_Regulation__c agReg : agRegs) {
				if(agReg.OSCAR__c != null && String.isNotBlank(agReg.OSCAR__r.Status__c) && !agReg.OSCAR__r.Status__c.contains('Closed')) {
					agRegsWithCase.add(agReg);
					stgAreaIds.add(agReg.OSCAR__r.AMS_Online_Accreditation__c);
				} else {
					trainedStaffList.add(new Person(buildAccreditationContact(agReg), false, index, false, null));
					index++;
				}
			}

			if(!agRegsWithCase.isEmpty()) {
				query = 'SELECT Id, AMS_Pax_Accreditation_Form__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__c, First_name__c, Last_Name__c, Valid_until__c, Type_Of_Certificate__c, ';
				query += 'Certificate_Issuer__c, Position_trained_staff__c, Certificate_Issued_on__c, Email__c, Company__c, AgencyRegulation__c, AgencyRegulation__r.OSCAR__c ';
				query += 'FROM AMS_Accreditation_Contact__c WHERE AgencyRegulation__c IN :agRegsWithCase AND AMS_Pax_Accreditation_Form__c IN :stgAreaIds';	
				List<AMS_Accreditation_Contact__c> accContacts = (List<AMS_Accreditation_Contact__c>) Database.query(query); 		
				for(AMS_Accreditation_Contact__c accContact : accContacts) {
					trainedStaffList.add(new Person(accContact, true, index, false, accContact.AMS_Pax_Accreditation_Form__r.SAAM_Case__c));
					mapCasePerStaff.put(index, accContact.AMS_Pax_Accreditation_Form__r.SAAM_Case__c);
					index++;
				}	
			}
		}

		private AMS_Accreditation_Contact__c buildAccreditationContact(AMS_Agency_Regulation__c agReg) {
			AMS_Accreditation_Contact__c accContact = new AMS_Accreditation_Contact__c();
			accContact.Company__c = agReg.Account__c;
			accContact.First_name__c = agReg.First_Name__c;
			accContact.Last_name__c = agReg.Last_Name__c;
			accContact.Position_trained_staff__c = agReg.Position__c;
			accContact.Certificate_Issuer__c = agReg.Issuer__c;
			accContact.Valid_until__c = agReg.Expiry_Date__c;
			accContact.Certificate_Issued_on__c = agReg.Issued_on__c;
			accContact.Email__c = agReg.Email__c;
			accContact.RecordTypeId = AMS_Utils.AccreditationContactTrainedStaffRT;
			accContact.Type_Of_Certificate__c = 'DGR';
			accContact.AgencyRegulation__c = agReg.Id;
			return accContact;
		}
	}

	public class FileConfiguration {
		public String accessId {get;set;}
		public String policy {get;set;}
		public String signedPolicy {get;set;}
		public String amazonURL {get;set;}
		public String maxFileSize {get; set;}
		public String allowedExtensions {get; set;}

		public FileConfiguration() {
			maxFileSize = ISSP_CS__c.getValues('ISSP AMS AMAZON S3 MAX FILE SIZE').Value__c;
			allowedExtensions = ISSP_CS__c.getValues('ISSP AMS AMAZON S3 ALLOWED EXTS').Value__c;
			AmazonCredentials credentials = AmazonCredentials.getCredentials('GenericAttach');
			this.accessId = credentials.AWSAccessKeyId;
			this.amazonURL = credentials.EndpointBaseURL + credentials.Bucket;
			calculePolicy(credentials);
		}

		private void calculePolicy(AmazonCredentials credentials) {
			Datetime expire = system.now().addDays(1);
			String formattedexpire = expire.formatGmt('yyyy-MM-dd')+'T'+
			expire.formatGmt('HH:mm:ss')+'.'+expire.formatGMT('SSS')+'Z';

			String policyString =
					'{ "expiration": "'+formattedexpire+'","conditions": [ {"bucket": "'+
					credentials.Bucket +'" } ,'+
					'{"acl":"private"},'+
					'{"success_action_status": "' + 201 + '" },'+
					'["starts-with", "$key", ""] ]}';
			policy = EncodingUtil.base64Encode(Blob.valueOf(policyString));
			signedPolicy = make_sig(EncodingUtil.base64Encode(Blob.valueOf(policyString)), credentials);
		}

		private String make_sig(string canonicalBuffer, AmazonCredentials credentials) {
			String macUrl ;
			String signingKey = EncodingUtil.base64Encode(Blob.valueOf(credentials.Secret));
			Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(credentials.Secret));
			macUrl = EncodingUtil.base64Encode(mac);
			return macUrl;
		}
	}
}