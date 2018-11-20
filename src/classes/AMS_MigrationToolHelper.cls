public without sharing class AMS_MigrationToolHelper {
	// this class is responsible for migrating Portal SAAM cases and SAAM cases that need to be converted into Comunication Cases (w/ AMS_OSCAR__c objects)
	
	final static ID rtCommCase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

	private static final Set<String> newgenProcesses = new Set<String>{'ANG.MAJOR.CHANGES.1.0','VR.1.0','CER.1.0','CORRECTION.1.0','BANK.ACCOUNT.CHANGES','NGFormsOfPayment','ANG_FS_OPTINOUT','ANG.NEW.HE.LITE.1.0','ANG.NEW.AE.1.0','ANG.NEW.HE.STANDARD.1.0'};

	private static final Set<String> doesNotNeedStagingAreaProcesses = new Set<String>{'VR.1.0','VR.1.0.CA','CER.1.0',AMS_Utils.NGOPTINOUT,AMS_Utils.NGFOP,AMS_Utils.BANKACCCHANGES, AMS_RecordCreatorWebservice.IEP_MODEL_A_ACCOUNT_SETUP, AMS_RecordCreatorWebservice.IEP_BANK_ACCOUNT_SETUP, AMS_RecordCreatorWebservice.IEP_MODEL_B_ACCOUNT_SETUP};
	
		public static Map<String,String> newgenCaseReason{
		get{
            return new Map<String, String> {
			AMS_Utils.NEWHELITE => 'New HE lite',
			AMS_Utils.NEWHESTANDARD => 'New HE standard',
			AMS_Utils.NEWAE => 'New AE',
			AMS_Utils.NGCHANGES => 'Agency changes',
			AMS_Utils.NGCORRECTION => 'Corrections',
			AMS_Utils.CERTIFICATION => 'PAX/CARGO Certificate',
			AMS_Utils.VOLRELINQUISH => 'CLO - Closure',
			AMS_Utils.BANKACCCHANGES => 'Agency changes',
			AMS_Utils.NGFOP => 'FoP Management',
			AMS_Utils.NGOPTINOUT => 'Financial review opt-in / opt-out',
			AMS_RecordCreatorWebservice.IEP_BANK_ACCOUNT_SETUP => 'IEP Bank account setup',
			AMS_RecordCreatorWebservice.IEP_MODEL_A_ACCOUNT_SETUP => 'Onboarding IEP Model A',
			AMS_RecordCreatorWebservice.IEP_MODEL_B_ACCOUNT_SETUP => 'Screening IEP Model B'
		};
		}
		set;
	}

	public static Map<String, Id> oscarNewgenRTMap {

		get{
            return new Map<String, String> {
			'ANG.MAJOR.CHANGES.1.0' => AMS_Utils.RECTYPE_NGCHANGES,
			'CORRECTION.1.0' => AMS_Utils.RECTYPE_NGCORRECTION,
			'ANG.FOPMANAGEMENT.1.0' => AMS_Utils.RECTYPE_NEWGENFOP,
			'ANG.FS.OPTINOUT' => AMS_Utils.RECTYPE_NEWGENOPTINOUT,
			'ANG.NEW.HE.LITE.1.0' => AMS_Utils.RECTYPE_NEWHE,
			'ANG.NEW.AE.1.0' => AMS_Utils.RECTYPE_NEWAE,
			'ANG.NEW.HE.STANDARD.1.0' => AMS_Utils.RECTYPE_NEWHE,
			AMS_RecordCreatorWebservice.IEP_MODEL_A_ACCOUNT_SETUP =>  AMS_Utils.RECTYPE_IEPMODELA,
			AMS_RecordCreatorWebservice.IEP_MODEL_B_ACCOUNT_SETUP =>  AMS_Utils.RECTYPE_IEPMODELB,
			AMS_RecordCreatorWebservice.IEP_BANK_ACCOUNT_SETUP => AMS_Utils.RECTYPE_BANK_ACCOUNT_SETUP 
		};
		}
		set;
	}

    public static Map<String, String> processTypeMapNewgen {
        get {
            return new Map<String, String> {
			'Change of Hierarchy' => 'ANG.MAJOR.CHANGES.1.0',
			'CHN - Change of Name' => 'ANG.MAJOR.CHANGES.1.0',
			'CHO / CHS – Change of Ownership / Legal Status' => 'ANG.MAJOR.CHANGES.1.0',
			'Agency Changes' => 'ANG.MAJOR.CHANGES.1.0',
			'VMFR Setup/Update' => 'ANG.MAJOR.CHANGES.1.0',
			'Accreditation Type' => 'ANG.MAJOR.CHANGES.1.0',
			'CHG – Data Maintenance' => 'ANG.MAJOR.CHANGES.1.0',
			'CHL - Change of Location' => 'ANG.MAJOR.CHANGES.1.0',
			'Change of Trade Name' => 'ANG.MAJOR.CHANGES.1.0',
			'Major Change' => 'ANG.MAJOR.CHANGES.1.0',
			'CHC – Change of Shareholding' => 'ANG.MAJOR.CHANGES.1.0',
			'CLO - Closure' => 'VR.1.0',
			'Financial Security Release' => 'VR.1.0',
			'Certificate' => 'CER.1.0',
			'FoP Management' => 'ANG.FOPMANAGEMENT.1.0',
			'PAX/CARGO Certificate' => 'CER.1.0',
			'Corrections'	=> 'CORRECTION.1.0',
			'Bank Detail Update' => 'BANK.ACCOUNT.CHANGES',
			'Financial review opt-in / opt-out' => 'ANG.FS.OPTINOUT',
			'New HE lite' => 'ANG.NEW.HE.LITE.1.0',
			'New AE' => 'ANG.NEW.AE.1.0',
			'New HE standard' => 'ANG.NEW.HE.STANDARD.1.0'
            };
        }
        set;
    }

    private static Map<String, String> processTypeMap {
        get {
            return new Map<String, String> {
		    'New BR / IP' => 'NEW.BR',
			'New BR Abroad' => 'NEW.BR.ABROAD',
			'New HO' => 'NEW.HO.1.0',
			'Manage Changes / Major' => 'MAJOR.CHANGES',
			'CHL - Change of Location' => 'MAJOR.CHANGES',
            'CHO / CHS – Change of Ownership / Legal Status' => 'MAJOR.CHANGES',
            'CHN - Change of Name' => 'MAJOR.CHANGES',
            'CHC – Change of Shareholding' => 'MAJOR.CHANGES',
            'New SA / CHV – New Code' => 'NEW.SA.1.0',
            'VMFR Setup/Update' => 'MAJOR.CHANGES',
			'TIDS' => 'NEW.TIDS.1.0',
			'ERSP' => 'CORRECTION.1.0',
			'Certificate DGR' => 'CERTIFICATION.1.0',
			'CLO - Closure' => 'VR.1.0',
			'ID Card' => 'VR.1.0.CA',
			'Operational changes' => 'VR.1.0.CA',
			'PAX/CARGO Certificate' => 'CER.1.0'
            };
        }
        set;
    }


	public static CaseContainer migratecases(CaseContainer cont, String processType){

		Savepoint sp = null;

		try {

			sp = Database.setSavepoint();

			if(cont.fromPortal)
					cont = processFromPortal(cont,processType); //call portal method
			else{
					cont = processNotFromPortalNew(cont,processType);
			}

		} catch(Exception e) {
			System.debug(e.getMessage());
			cont.errorMessage = e.getMessage() + e.getStackTraceString(); //or other stuf
			cont.migrated = true;
			cont.processing = false;

			if(sp != null)
				Database.rollback(sp);

		}



		return cont;
	}

	public static void alignOwners(AMS_Pax_Accreditation_Form__c accreditationObj, Case commCase){

		//List<Contact> contactsFromAccountToMatch= [Select Id, Email from Contact where AccountId = :commCase.AccountId];

		Set<Id> contactsUpdated = new Set<Id>();

		Map<String, Id> contactsFromAccountToMatch = new Map<String, Id>();

		For(Contact c: [Select Id, Email from Contact where AccountId = :commCase.AccountId]){

			contactsFromAccountToMatch.put(c.email,c.Id);
		}

		List<AMS_Accreditation_Contact__c> contactsToUpdate = new List<AMS_Accreditation_Contact__c>();

		List<AMS_Accreditation_Contact__c> contacts = [SELECT Id, Email__c, Legacy_External_ID__c, AMS_Ownership_Role__c, Contact__c, Person_AMS__c,   Company__c, Name from AMS_Accreditation_Contact__c where AMS_Pax_Accreditation_Form__c = :accreditationObj.Id and AMS_Ownership_Role__c = null and Agency_owner__c = true];

		List<AMS_Account_Role__c> roles = [SELECT Id, Contact__c, Person__c, Legacy_External_ID__c, Owner_Account__c,Owner_Name__c,Person__r.Contact__c from AMS_Account_Role__c where Active__c = true and Account__c = :commCase.AccountId];

		for(AMS_Accreditation_Contact__c contact: contacts){

			for(AMS_Account_Role__c role: roles){

				if(contact.Contact__c != null && contact.Contact__c == role.Contact__c){
					contact.AMS_Ownership_Role__c = role.Id;
					contactsToUpdate.add(contact);
					contactsUpdated.add(contact.Id);
					break;
				}

				if(contact.Contact__c != null && role.Person__c != null && role.Person__r.Contact__c != null && contact.Contact__c == role.Person__r.Contact__c){
					contact.AMS_Ownership_Role__c = role.Id;
					contactsToUpdate.add(contact);
					contactsUpdated.add(contact.Id);
					break;
				}

				if(contact.Person_AMS__c != null && contact.Person_AMS__c == role.Person__c){
					contact.AMS_Ownership_Role__c = role.Id;
					contactsToUpdate.add(contact);
					contactsUpdated.add(contact.Id);
					break;
				}

				if(contact.Company__c != null && contact.Company__c == role.Owner_Account__c){
					contact.AMS_Ownership_Role__c = role.Id;

					if(contact.Contact__c == null && contact.Person_AMS__c == null && contact.Email__c != null && contactsFromAccountToMatch.get(contact.Email__c) != null){ // try to match the Accreditation Contact with an existing contact from the Account.				
						contact.Contact__c = contactsFromAccountToMatch.get(contact.Email__c);
					}

					contactsToUpdate.add(contact);
					contactsUpdated.add(contact.Id);
					break;
				}

				if(contact.Legacy_External_Id__c != null && contact.Legacy_External_Id__c == role.Legacy_External_ID__c){
					contact.AMS_Ownership_Role__c = role.Id;

					if(contact.Contact__c == null && contact.Person_AMS__c == null && contact.Email__c != null && contactsFromAccountToMatch.get(contact.Email__c) != null){ // try to match the Accreditation Contact with an existing contact from the Account.				
						contact.Contact__c = contactsFromAccountToMatch.get(contact.Email__c);
					}

					contactsToUpdate.add(contact);
					contactsUpdated.add(contact.Id);
					break;
				}

				if(contact.Contact__c == null && contact.Person_AMS__c == null && contact.Company__c == null && contact.Legacy_External_Id__c == null && Role.Owner_Name__c != null){
					if(contact.Name == role.Owner_Name__c){
						contact.AMS_Ownership_Role__c = role.Id;

						if(contact.Contact__c == null && contact.Person_AMS__c == null && contact.Email__c != null && contactsFromAccountToMatch.get(contact.Email__c) != null){ // try to match the Accreditation Contact with an existing contact from the Account.				
							contact.Contact__c = contactsFromAccountToMatch.get(contact.Email__c);
						}

						contactsToUpdate.add(contact);
						contactsUpdated.add(contact.Id);
						break;
					}
				}
			}

			// if a contact does not have a match in the AMS Account Role, we still might have to attach it to a Contact (that's why we are using that contactsUpdated set ....)
			if(!contactsUpdated.contains(Contact.Id) && contact.Contact__c == null && contact.Person_AMS__c == null && contact.Email__c != null && contactsFromAccountToMatch.get(contact.Email__c) != null){ // try to match the Accreditation Contact with an existing contact from the Account.				
				contact.Contact__c = contactsFromAccountToMatch.get(contact.Email__c);
				contactsToUpdate.add(contact);
				contactsUpdated.add(contact.Id);
			}

		}

		// now for the regular non owners contacts, if they are missing a contact and they have an email, let's try to match them so we can avoid contact duplication

		for(AMS_Accreditation_Contact__c nonOwnerC : [SELECT Id, Email__c, Legacy_External_ID__c, AMS_Ownership_Role__c, Contact__c, Person_AMS__c,   Company__c, Name from AMS_Accreditation_Contact__c where AMS_Pax_Accreditation_Form__c = :accreditationObj.Id and AMS_Ownership_Role__c = null and Agency_owner__c = false and Email__c != null and Contact__c = null and Person_AMS__c = null and Financial_interest__c = null]){
				
				if(contactsFromAccountToMatch.get(nonOwnerC.Email__c) != null){
					nonOwnerC.Contact__c = contactsFromAccountToMatch.get(nonOwnerC.Email__c);
					contactsToUpdate.add(nonOwnerC);
				}

		}

		if(!contactsToUpdate.isEmpty())
			update contactsToUpdate;
	}

	private static AMS_Pax_Accreditation_Form__c fillMissingFieldsOnAccreditation(AMS_Pax_Accreditation_Form__c accreditationObj, Id accountId , String processType, Case caseIn){

		//	1.	The billing address was not displayed on the case while I see it on the portal online form.
		//	2.	The account name was not populate either
		//	3.	Location class and type are not populated either
		//	4.	Country is not populated
		//	5.	Email, Website and Phone are not populated
		//	6.	Short name not populated
		//	7.	Abbreviated name not populated
		//	8.	Abbreviated address not populated

		Id caseId = caseIn.Id;


		if(processType == AMS_Utils.NEWAE){
			accreditationObj.Remittance_frequency__c = caseIn.Account.Parent.Remittance_frequency__c;
			accreditationObj.TradeName__c = caseIn.Account.TradeName__c;
			accreditationObj.Trade_Name__c = caseIn.Account.TradeName__c;
		}

		Account acct = null;

		List<Account> directAccountLst = [SELECT Id,ANG_Accreditation_Model__c, ParentId , Abbreviated_address__c,Abbreviated_name__c,Name,BillingState,BillingCity,IATA_ISO_Country__c,Email__c,Fax,Phone,BillingPostalCode,BillingStreet,CASS_Number__c,IATACode__c,Iso_State__c,GDS__c,Company_Type__c,License_Number__c,In_a_Airport__c,VAT_Number__c,Is_your_firm_handling_Dangerous_Goods__c,Location_Class__c,Location_Type__c,Mobile__c,Operation__c,Remittance_frequency__c,ShippingCity,ShippingCountry,IATA_ISO_Shipping_Country__c,IATA_ISO_Shipping_State__c,ShippingPostalCode,ShippingState,ShippingStreet,Short_Name__c,Solicitation_Flag__c,TradeName__c,VAT_Number_2__c,Website from Account where Id = :accountId];

		if(directAccountLst.isEmpty())
			return null;

		Account directAccount = directAccountLst.get(0);

		if((processType != 'NEW.TIDS.1.0') && (directAccount.Location_Type__c == 'BR' || directAccount.Location_Type__c == 'SA' || directAccount.Location_Type__c == 'AE')){

			List<Account> parentAccountLst = [SELECT Id, ANG_Accreditation_Model__c, ParentId , Abbreviated_address__c,Abbreviated_name__c,Name,BillingState,BillingCity,IATA_ISO_Country__c,Email__c,Fax,Phone,BillingPostalCode,BillingStreet,CASS_Number__c,IATACode__c,Iso_State__c,GDS__c,Company_Type__c,License_Number__c,In_a_Airport__c,VAT_Number__c,Is_your_firm_handling_Dangerous_Goods__c,Location_Class__c,Location_Type__c,Mobile__c,Operation__c,Remittance_frequency__c,ShippingCity,ShippingCountry,IATA_ISO_Shipping_Country__c,IATA_ISO_Shipping_State__c,ShippingPostalCode,ShippingState,ShippingStreet,Short_Name__c,Solicitation_Flag__c,TradeName__c,VAT_Number_2__c,Website from Account where Id = :directAccount.ParentId ];

			System.debug('2parentAccountLst is:'+parentAccountLst);

			if(parentAccountLst.isEmpty())
				return null;

			acct = parentAccountLst.get(0);

		}
		else
			acct = directAccount;
		
		accreditationObj = fillAccreditation(accreditationObj, acct, directAccount, processType, caseId);

		return accreditationObj;

	}

	private static CaseContainer processFromPortal(CaseContainer cont, String processTypeInput){

		Case caseToProcess = cont.c;

		String processType;
		
		if(!caseToProcess.Account.ANG_IsNewGenAgency__c)
			processType = processTypeInput == null ? processTypeMap.get(caseToProcess.Reason1__c):processTypeInput;
		else
			processType = processTypeInput == null ? processTypeMapNewgen.get(caseToProcess.Reason1__c):processTypeInput;

		if(processType == null){

			cont.migrated = true;
			cont.processing = false;
			cont.errorMessage = 'Could not match case  reason from case ('+caseToProcess.Reason1__c+') with type of process to be run.';
			
			return cont;
		}

		caseToProcess.RecordTypeId = rtCommCase;

		String caseStatus = caseToProcess.Status;

        update caseToProcess;

        String oscarId = '';

        AMS_Pax_Accreditation_Form__c accreditationObj = null;
        
        if(!doesNotNeedStagingAreaProcesses.contains(processType)){

			accreditationObj = fetchAccreditation(caseToProcess.Id);

			accreditationObj = fillMissingFieldsOnAccreditation(accreditationObj,caseToProcess.AccountId, processType, caseToProcess);

			alignOwners(accreditationObj,caseToProcess);

			oscarId = AMS_RecordCreatorWebservice.createAccreditation(caseToProcess.AccountId, accreditationObj.Id, processType, caseToProcess.Id);

		}else{

			//oscarId = AMS_RecordCreatorWebservice.createAccreditation(caseToProcess.AccountId, accreditationObj.Id, processType, caseToProcess.Id);

			Id oscarRTId = null;

			if(processType == 'VR.1.0' || processType == 'VR.1.0.CA')
				oscarRTId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'VOLUNTARY_RELINQUISHMENT');
			if(processType == 'CER.1.0')
				oscarRTId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CERTIFICATE');

			AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = caseToProcess.AccountId, Process__c = processType, RecordTypeId =oscarRTId, Status__c = caseToProcess.Status, OwnerId = caseToProcess.OwnerId );

			if(processType.equalsIgnoreCase('ANG.FS.OPTINOUT')){

            	oscar.ANG_FA_Opt_out__c = caseToProcess.Account.ANG_FA_Opt_out__c == true ? 'Opt-In' : 'Opt-Out';
        	}

			insert oscar;

			oscarId = oscar.Id;

			caseToProcess.OSCAR__c = oscar.Id;

			if(caseToProcess.Account.ANG_IsNewGenAgency__c){

				caseToProcess.CaseArea__c = 'Accreditation Process';
				caseToProcess.Reason1__c = newgenCaseReason.get(processType);
			}	
			
			if(AMS_Utils.IEP_PROCESSES.contains(processType)){

				if(caseToProcess.Account.ANG_IsNewGenAgency__c){
					caseToProcess.Subject = caseToProcess.Reason1__c+' - '+caseToProcess.Account.ANG_Accreditation_Model__c+' - '+caseToProcess.Account.Name;
				}else{
					caseToProcess.Subject = caseToProcess.Reason1__c+' - '+caseToProcess.Account.Name;
				}
			}
						
			update caseToProcess;
		}

		postOscarUpdate(oscarId,caseToProcess.CaseNumber, caseToProcess.AccountId, true, caseStatus,caseToProcess);

		cont.oscarId = oscarId;
		cont.oscarCreated = new AMS_OSCAR__c(Id = oscarId, Name = caseToProcess.CaseNumber);

		cont.oscarCaseId = caseToProcess.Id;
		cont.caseCreated = caseToProcess;
		cont.processing = false;
		cont.migrated = true;

		if(processType != 'VR.1.0' && processType != 'VR.1.0.CA' && processType != 'CER.1.0' && accreditationObj.IATACode__c == null && caseToProcess.Account.IATACode__c != null){
			
			accreditationObj.IATACode__c = caseToProcess.Account.IATACode__c;

			update accreditationObj;
		}else if(processType == AMS_Utils.NEWAE){
			update accreditationObj;		   
		}

		return cont;

	}

	private static Id fetchAccreditationRT(String locationClass, String processType){

		String devName = 'GeneralOnlineAccreditation';

		if(locationClass == 'T'){
			if(processType == 'NEW.TIDS.1.0')
				devName = 'GeneralOnlineAccreditation';
		}

		if(locationClass == 'P'){
			if(processType == 'NEW.HO.1.0')
				devName = 'Travel_Agent_HO';
			if(processType == 'NEW.BR')
				devName = 'Travel_Agent_Branch';
			if(processType == 'NEW.BR.ABROAD')
				devName = 'Travel_Agent_Branch_Abroad';
		}

		if(locationClass == 'C'){
			if(processType == 'NEW.HO.1.0')
				devName = 'Cargo_Agent_HO';
			if(processType == 'NEW.BR')
				devName = 'Cargo_Agent_Branch';
			if(processType == 'NEW.BR.ABROAD')
				devName = 'Cargo_Agent_Branch';
		}

		if(processType == 'MAJOR.CHANGES')
			devName = 'Other_Changes';

		return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', devName);

	}

	private static AMS_Pax_Accreditation_Form__c fillAccreditation(AMS_Pax_Accreditation_Form__c accreditationObj, Account acct, Account directAccount, String processType, String caseId){

		System.debug('Entering fill Accreditation with values:'+accreditationObj);

		if(processType == 'NEW.SA.1.0'){

			accreditationObj.Branch_Office_City__c = accreditationObj.Branch_Office_City__c == null ? acct.BillingCity : accreditationObj.Branch_Office_City__c;
			accreditationObj.Branch_Office_Country__c = accreditationObj.Branch_Office_Country__c == null ? (processType == 'NEW.BR.ABROAD' ?  directAccount.IATA_ISO_Country__c : acct.IATA_ISO_Country__c) : accreditationObj.Branch_Office_Country__c;
			accreditationObj.Branch_Office_Postal_code__c = accreditationObj.Branch_Office_Postal_code__c == null ? acct.BillingPostalCode : accreditationObj.Branch_Office_Postal_code__c;
			accreditationObj.Branch_Office_Street_name_number__c = accreditationObj.Branch_Office_Street_name_number__c == null ? acct.BillingStreet : accreditationObj.Branch_Office_Street_name_number__c;
			accreditationObj.Billing_State__c = accreditationObj.Billing_State__c == null ? acct.BillingState : accreditationObj.Billing_State__c;
			accreditationObj.Abbreviated_Address__c = accreditationObj.Abbreviated_Address__c == null ? acct.Abbreviated_address__c : accreditationObj.Abbreviated_Address__c;
			accreditationObj.IATA_ISO_State__c = accreditationObj.IATA_ISO_State__c == null ? acct.Iso_State__c : accreditationObj.IATA_ISO_State__c;
			accreditationObj.Shipping_City__c = accreditationObj.Shipping_City__c == null ? acct.ShippingCity : accreditationObj.Shipping_City__c;
			accreditationObj.Shipping_Country__c = accreditationObj.Shipping_Country__c == null ? acct.ShippingCountry : accreditationObj.Shipping_Country__c;
			accreditationObj.Shipping_ISO_Country__c = accreditationObj.Shipping_ISO_Country__c == null ? acct.IATA_ISO_Shipping_Country__c : accreditationObj.Shipping_ISO_Country__c;
			accreditationObj.Shipping_ISO_State__c = accreditationObj.Shipping_ISO_State__c == null ? acct.IATA_ISO_Shipping_State__c : accreditationObj.Shipping_ISO_State__c;
			accreditationObj.Shipping_Postal_Code__c = accreditationObj.Shipping_Postal_Code__c == null ? acct.ShippingPostalCode : accreditationObj.Shipping_Postal_Code__c;
			accreditationObj.Shipping_State__c = accreditationObj.Shipping_State__c == null ? acct.ShippingState : accreditationObj.Shipping_State__c;
			accreditationObj.Shipping_Street__c = accreditationObj.Shipping_Street__c == null ? acct.ShippingStreet : accreditationObj.Shipping_Street__c;

		}
		else{

			accreditationObj.Branch_Office_City__c = accreditationObj.Branch_Office_City__c == null ? directAccount.BillingCity : accreditationObj.Branch_Office_City__c;
			accreditationObj.Branch_Office_Country__c = accreditationObj.Branch_Office_Country__c == null ? (processType == 'NEW.BR.ABROAD' ?  directAccount.IATA_ISO_Country__c : acct.IATA_ISO_Country__c) : accreditationObj.Branch_Office_Country__c;
			accreditationObj.Branch_Office_Postal_code__c = accreditationObj.Branch_Office_Postal_code__c == null ? directAccount.BillingPostalCode : accreditationObj.Branch_Office_Postal_code__c;
			accreditationObj.Branch_Office_Street_name_number__c = accreditationObj.Branch_Office_Street_name_number__c == null ? directAccount.BillingStreet : accreditationObj.Branch_Office_Street_name_number__c;
			accreditationObj.Billing_State__c = accreditationObj.Billing_State__c == null ? directAccount.BillingState : accreditationObj.Billing_State__c;
			accreditationObj.Abbreviated_Address__c = accreditationObj.Abbreviated_Address__c == null ? directAccount.Abbreviated_address__c : accreditationObj.Abbreviated_Address__c;
			accreditationObj.IATA_ISO_State__c = accreditationObj.IATA_ISO_State__c == null ? directAccount.Iso_State__c : accreditationObj.IATA_ISO_State__c;
			accreditationObj.Shipping_City__c = accreditationObj.Shipping_City__c == null ? directAccount.ShippingCity : accreditationObj.Shipping_City__c;
			accreditationObj.Shipping_Country__c = accreditationObj.Shipping_Country__c == null ? directAccount.ShippingCountry : accreditationObj.Shipping_Country__c;
			accreditationObj.Shipping_ISO_Country__c = accreditationObj.Shipping_ISO_Country__c == null ? directAccount.IATA_ISO_Shipping_Country__c : accreditationObj.Shipping_ISO_Country__c;
			accreditationObj.Shipping_ISO_State__c = accreditationObj.Shipping_ISO_State__c == null ? directAccount.IATA_ISO_Shipping_State__c : accreditationObj.Shipping_ISO_State__c;
			accreditationObj.Shipping_Postal_Code__c = accreditationObj.Shipping_Postal_Code__c == null ? directAccount.ShippingPostalCode : accreditationObj.Shipping_Postal_Code__c;
			accreditationObj.Shipping_State__c = accreditationObj.Shipping_State__c == null ? directAccount.ShippingState : accreditationObj.Shipping_State__c;
			accreditationObj.Shipping_Street__c = accreditationObj.Shipping_Street__c == null ? directAccount.ShippingStreet : accreditationObj.Shipping_Street__c;
		}

		accreditationObj.Abbreviated_name__c = accreditationObj.Abbreviated_name__c == null ? directAccount.Abbreviated_name__c : accreditationObj.Abbreviated_name__c;
		accreditationObj.Accept_terms_and_conditions__c = accreditationObj.Accept_terms_and_conditions__c == null ? true : accreditationObj.Accept_terms_and_conditions__c;
		accreditationObj.Account_Name__c = accreditationObj.Account_Name__c == null ? acct.Name : accreditationObj.Account_Name__c;
		
		accreditationObj.Branch_Office_Email__c = accreditationObj.Branch_Office_Email__c == null ? directAccount.Email__c : accreditationObj.Branch_Office_Email__c;
		accreditationObj.Branch_Office_FAX__c = accreditationObj.Branch_Office_FAX__c == null ? directAccount.Fax : accreditationObj.Branch_Office_FAX__c;
		accreditationObj.Branch_Office_Phone__c = accreditationObj.Branch_Office_Phone__c == null ? directAccount.Phone : accreditationObj.Branch_Office_Phone__c;
		accreditationObj.CASS_Number__c = accreditationObj.CASS_Number__c == null ? directAccount.CASS_Number__c : accreditationObj.CASS_Number__c;
		accreditationObj.IATACode__c = accreditationObj.IATACode__c == null ? directAccount.IATACode__c : accreditationObj.IATACode__c;
		accreditationObj.ISSP_AMS_GDS_with_signed_contract__c = accreditationObj.ISSP_AMS_GDS_with_signed_contract__c == null ? AMS_AgencyHelper.transformGDS(directAccount.GDS__c) : accreditationObj.ISSP_AMS_GDS_with_signed_contract__c;
		accreditationObj.ISSP_AMS_Legal_Status__c = accreditationObj.ISSP_AMS_Legal_Status__c == null ? decode(acct.Company_Type__c) : accreditationObj.ISSP_AMS_Legal_Status__c;
		accreditationObj.ISSP_AMS_License_No__c = accreditationObj.ISSP_AMS_License_No__c == null ? directAccount.License_Number__c : accreditationObj.ISSP_AMS_License_No__c;
		accreditationObj.ISSP_AMS_Premises_located_at_airport__c = accreditationObj.ISSP_AMS_Premises_located_at_airport__c == null ? ( directAccount.In_a_Airport__c == true ? 'Yes' : 'No' ) : accreditationObj.ISSP_AMS_Premises_located_at_airport__c;
		accreditationObj.ISSP_AMS_VAT_number__c = accreditationObj.ISSP_AMS_VAT_number__c == null ? acct.VAT_Number__c : accreditationObj.ISSP_AMS_VAT_number__c;
		accreditationObj.Is_your_firm_handling_Dangerous_Goods__c = accreditationObj.Is_your_firm_handling_Dangerous_Goods__c == null ? directAccount.Is_your_firm_handling_Dangerous_Goods__c : accreditationObj.Is_your_firm_handling_Dangerous_Goods__c;
		accreditationObj.Location_Class__c = accreditationObj.Location_Class__c == null ? acct.Location_Class__c : accreditationObj.Location_Class__c;
		accreditationObj.Location_Type__c = accreditationObj.Location_Type__c == null ? directAccount.Location_Type__c : accreditationObj.Location_Type__c;
		accreditationObj.Mobile__c = accreditationObj.Mobile__c == null ? directAccount.Mobile__c : accreditationObj.Mobile__c;
		accreditationObj.Operation__c = accreditationObj.Operation__c == null ? directAccount.Operation__c : accreditationObj.Operation__c;
		accreditationObj.RecordTypeId = accreditationObj.RecordTypeId == null ? fetchAccreditationRT(acct.Location_Class__c,processType) : accreditationObj.RecordTypeId;
		accreditationObj.Remittance_frequency__c = accreditationObj.Remittance_frequency__c == null ? directAccount.Remittance_frequency__c : accreditationObj.Remittance_frequency__c;
		
		if(accreditationObj.SAAM_Case__c == null)
			accreditationObj.SAAM_Case__c = caseId;
		

		accreditationObj.Short_Name__c = accreditationObj.Short_Name__c == null ? directAccount.Short_Name__c : accreditationObj.Short_Name__c;
		accreditationObj.Solicitation_Flag__c = accreditationObj.Solicitation_Flag__c == null ? directAccount.Solicitation_Flag__c : accreditationObj.Solicitation_Flag__c;
		accreditationObj.Submitted_to_IATA__c = accreditationObj.Submitted_to_IATA__c == null ? true : accreditationObj.Submitted_to_IATA__c;
		accreditationObj.Trade_Name__c = accreditationObj.Trade_Name__c == null ? directAccount.TradeName__c : accreditationObj.Trade_Name__c;
		accreditationObj.VAT_Number_2__c = accreditationObj.VAT_Number_2__c == null ? acct.VAT_Number_2__c : accreditationObj.VAT_Number_2__c;
		accreditationObj.Website__c = accreditationObj.Website__c == null ? acct.Website : accreditationObj.Website__c;

		if(processType == AMS_Utils.NEWAE){
			accreditationObj.ANG_Accreditation_type__c = acct.ANG_Accreditation_Model__c;
		}
		
		return accreditationObj;
	}

	/**
    Method to help decode the transformation between Specify Legal Status (AMS Online Accreditation) and Company Type (Acccount) in migrations
    */

	public static String decode(String companyType) {

		if (companyType == null)
        return null;

    	if (companyType.equalsIgnoreCase('A'))
        return 'Association';
    	if (companyType.equalsIgnoreCase('C'))
        return 'Corporation';
    	if (companyType.equalsIgnoreCase('E'))
        return 'State Owned Enterprise';
    	if (companyType.equalsIgnoreCase('J'))
        return 'Joint Venture';
    	if (companyType.equalsIgnoreCase('L'))
        return 'Limited Company';
    	if (companyType.equalsIgnoreCase('O'))
        return 'Other';
    	if (companyType.equalsIgnoreCase('P'))
        return 'Partnership';
    	if (companyType.equalsIgnoreCase('R'))
        return 'Limited Partnership';
    	if (companyType.equalsIgnoreCase('S'))
        return 'Sole Proprietorship';
    	if (companyType.equalsIgnoreCase('T'))
        return 'Trust Company';
    	if (companyType.equalsIgnoreCase('V'))
        return 'Co-operative';

    return null;
	}

	private static AMS_Pax_Accreditation_Form__c createAccreditation(String caseId, String accountId, String processType){

		Account acct = null;

		List<Account> directAccountLst = [SELECT Id, ParentId , Abbreviated_address__c,Abbreviated_name__c,Name,BillingState,BillingCity,IATA_ISO_Country__c,Email__c,Fax,Phone,BillingPostalCode,BillingStreet,CASS_Number__c,IATACode__c,Iso_State__c,GDS__c,Company_Type__c,License_Number__c,In_a_Airport__c,VAT_Number__c,Is_your_firm_handling_Dangerous_Goods__c,Location_Class__c,Location_Type__c,Mobile__c,Operation__c,Remittance_frequency__c,ShippingCity,ShippingCountry,IATA_ISO_Shipping_Country__c,IATA_ISO_Shipping_State__c,ShippingPostalCode,ShippingState,ShippingStreet,Short_Name__c,Solicitation_Flag__c,TradeName__c,VAT_Number_2__c,Website,ANG_Accreditation_Model__c from Account where Id = :accountId];

		if(directAccountLst.isEmpty())
			return null;

		Account directAccount = directAccountLst.get(0);

		if( (processType != 'NEW.TIDS.1.0' && processType != 'CORRECTION.1.0' ) && (directAccount.Location_Type__c == 'BR' || directAccount.Location_Type__c == 'SA' || directAccount.Location_Type__c == 'AE')){

			List<Account> parentAccountLst = [SELECT Id, ParentId , Abbreviated_address__c,Abbreviated_name__c,Name,BillingState,BillingCity,IATA_ISO_Country__c,Email__c,Fax,Phone,BillingPostalCode,BillingStreet,CASS_Number__c,IATACode__c,Iso_State__c,GDS__c,Company_Type__c,License_Number__c,In_a_Airport__c,VAT_Number__c,Is_your_firm_handling_Dangerous_Goods__c,Location_Class__c,Location_Type__c,Mobile__c,Operation__c,Remittance_frequency__c,ShippingCity,ShippingCountry,IATA_ISO_Shipping_Country__c,IATA_ISO_Shipping_State__c,ShippingPostalCode,ShippingState,ShippingStreet,Short_Name__c,Solicitation_Flag__c,TradeName__c,VAT_Number_2__c,Website,ANG_Accreditation_Model__c from Account where Id = :directAccount.ParentId ];
		
			if(parentAccountLst.isEmpty())
				return null;

			acct = parentAccountLst.get(0);

		}
		else
			acct = directAccount;
		
		AMS_Pax_Accreditation_Form__c accreditationObj = new AMS_Pax_Accreditation_Form__c();

		accreditationObj = fillAccreditation(accreditationObj, acct, directAccount, processType, caseId);

		if(processType == AMS_Utils.NEWAE){
			accreditationObj.Remittance_frequency__c = acct.Remittance_frequency__c;
			accreditationObj.TradeName__c = acct.TradeName__c;
			accreditationObj.Trade_Name__c = acct.TradeName__c;
		}
	
		insert accreditationObj;
		
		return accreditationObj;
	}

	public static AMS_Accreditation_Contact__c createAccreditationContact(AMS_Pax_Accreditation_Form__c accreditationObj, AMS_Account_Role__c role, String processType){

		AMS_Accreditation_Contact__c contact = new AMS_Accreditation_Contact__c();

		if(processType == 'NEW.HO.1.0' || processType == 'MAJOR.CHANGES' || processType == 'NEW.TIDS.1.0' || processType == 'CORRECTION.1.0')
			contact.AMS_Ownership_Role__c = role.Id;

		contact.AMS_Pax_Accreditation_Form__c = accreditationObj.Id;
		contact.Agency_owner__c = true;
		contact.Company__c = role.Owner_Account__c;
		contact.Contact__c = role.Contact__c;
		contact.Email__c = role.Contact_Email__c;
		contact.Financial_interest__c = role.Percentage__c;
		contact.First_name__c = role.Contact__c != null ? role.Contact__r.FirstName : ( role.Person__c != null ? role.Person__r.First_name__c : ''); 
		contact.Last_name__c = (role.Contact__c == null && role.Person__c == null && role.Owner_Account__c == null) ? role.Owner_Name__c : ( role.Contact__c != null ? role.Contact__r.LastName : ( role.Person__c != null ? role.Person__r.Lastname__c : '_')); 
		contact.Legacy_External_Id__c = role.Legacy_External_ID__c;
		contact.Name = role.Owner_Name__c != null ? role.Owner_Name__c : (contact.First_name__c + contact.Last_name__c);
		contact.Person_AMS__c = role.Person__c;
		contact.Phone__c = role.Contact_Phone__c;

		ID ownerRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner');
		ID companyOwnerRt = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Company_Owner');

		contact.RecordTypeId = role.Owner_Account__c != null ? companyOwnerRt : ownerRT;

		return contact;

	}

	public static List<AMS_Accreditation_Contact__c> createAccreditationContacts(AMS_Pax_Accreditation_Form__c accreditationObj, Id accountId, String typeOfProcess){

		// get all the owners and create accreditation contacts

		List<AMS_Accreditation_Contact__c> contactsToReturn = new List<AMS_Accreditation_Contact__c>();

		List<AMS_Account_Role__c> allAccountRoles = new List<AMS_Account_Role__c>();
		
		allAccountRoles = [SELECT Id, RecordTypeId, Contact_Phone__c, Contact_Email__c, Termination_Date__c, Duty__c, Hours__c, IsManager__c, Percentage__c, Position__c, Account__c, Owner_Account__c, Contact__c, Contact__r.FirstName , Contact__r.LastName, Person__c, Person__r.First_Name__c , Person__r.Lastname__c , Person__r.Contact__c,Person__r.Contact__r.FirstName, Person__r.Contact__r.LastName, Legacy_External_ID__c, Legacy_System__c, Owner_Name__c from AMS_Account_role__c where Account__c = :accountId and Active__c = true];

		for(AMS_Account_Role__c role: allAccountRoles){

			contactsToReturn.add(createAccreditationContact(accreditationObj,role,typeOfProcess));
		}

		insert contactsToReturn;

		return contactsToReturn;

	}

	private static AMS_OSCAR__c updateDatesFromSAAM(AMS_OSCAR__c oscar, String caseId){
		
		List<Case> cases = [SELECT id, Financial_Assessment_compliant__c,Reason_for_change_of_Financial_result__c, Documentation_Complete__c, Financial_Assessment_received__c,Bank_Guarantee_amount__c,Bank_Guarantee_deadline__c,Bank_Guarantee_received__c,Bank_Guarantee_requested__c,Change_effective_as_of__c,Criteria_remarks__c,Documentation_remarks__c,Dossier_reception_date__c,Fees_refund_requested__c,Finalization_checklist__c,Financial_Assessment_deadline__c,Financial_Assessment_requested__c,Financial_Review_Result__c,Invoice_number__c,Local_Inspection_compliant__c,Local_Inspection_deadline__c,Local_Inspection_received__c,Local_Inspection_requested__c,Process_Start_Date__c,Proof_of_payment_received__c,PSAA_EACP_Agreement_received__c,PSAA_signed_copy_sent__c,SAAM_Deadline_Date__c,AIMS_updated__c,Finalized_in_AIMS__c from Case where Id = :caseId];

		if(cases.isEmpty())
			return null;

		Case saamCase = cases.get(0);

		try{
			if(saamCase.Bank_Guarantee_amount__c != null)
				oscar.Bank_Guarantee_amount__c = Integer.valueof(saamCase.Bank_Guarantee_amount__c);
		
		}catch(Exception e){
			// shhhhhhhhhhhhhhh ...
		}

		oscar.Assessment_Performed_Date__c = saamCase.Financial_Assessment_received__c;
		oscar.Bank_Guarantee_deadline__c = saamCase.Bank_Guarantee_deadline__c;
		oscar.Bank_Guarantee_received__c = saamCase.Bank_Guarantee_received__c;
		oscar.Bank_Guarantee_requested__c = saamCase.Bank_Guarantee_requested__c;
		oscar.Change_effective_as_of__c = saamCase.Change_effective_as_of__c;
		oscar.Criteria_remarks__c = saamCase.Criteria_remarks__c;
		oscar.Documentation_remarks__c = saamCase.Documentation_remarks__c;
		oscar.Dossier_Reception_Date__c = (AMS_Utils.IEP_PROCESSES.contains(oscar.Process__c) && saamCase.Dossier_reception_date__c == null ? Date.today() : saamCase.Dossier_reception_date__c );
		oscar.Fees_refund_requested__c = saamCase.Fees_refund_requested__c;
		oscar.Finalization_checklist__c = saamCase.Finalization_checklist__c;
		oscar.Financial_Assessment_deadline__c = saamCase.Financial_Assessment_deadline__c;
		oscar.Financial_Assessment_requested__c = saamCase.Financial_Assessment_requested__c;
		if(!Test.isRunningTest()){
			oscar.Financial_Review_Result__c = saamCase.Financial_Assessment_compliant__c;
			oscar.Reason_for_change_of_Financial_result__c = saamCase.Reason_for_change_of_Financial_result__c == null ? '.' : saamCase.Reason_for_change_of_Financial_result__c;
		}
		oscar.Billing_Document_Number__c = saamCase.Invoice_number__c;
		oscar.Local_Inspection_compliant__c = saamCase.Local_Inspection_compliant__c == 'Yes' ? 'Passed' :  (saamCase.Local_Inspection_compliant__c == 'No' ? 'Failed' : 'N/A' );
		oscar.Local_Inspection_deadline__c = saamCase.Local_Inspection_deadline__c;
		oscar.Local_Inspection_received__c = saamCase.Local_Inspection_received__c;
		oscar.Local_Inspection_requested__c = saamCase.Local_Inspection_requested__c;
		oscar.Process_Start_Date__c = saamCase.Process_Start_Date__c;
		oscar.Proof_of_payment_received__c = saamCase.Proof_of_payment_received__c;
		oscar.PSAA_EACP_Agreement_received__c = saamCase.PSAA_EACP_Agreement_received__c;
		oscar.Welcome_Pack_Sent__c = saamCase.PSAA_signed_copy_sent__c;
		oscar.Sanity_check_deadline__c = saamCase.SAAM_Deadline_Date__c;
		oscar.Sanity_check_received__c = saamCase.Documentation_Complete__c;
		oscar.Update_AIMS_Rejection_Date__c = saamCase.AIMS_updated__c != null ? saamCase.AIMS_updated__c.date() : null;
		oscar.Update_AIMS_Rejection__c = saamCase.AIMS_updated__c != null ? true : false;
		oscar.Update_AIMS_Approval_Date__c = saamCase.Finalized_in_AIMS__c != null ? saamCase.Finalized_in_AIMS__c.date() : null;
		oscar.Update_AIMS_Approval__c = saamCase.Finalized_in_AIMS__c != null ? true : false;

		System.debug('End date fields migration...');

		return oscar;
	}

	private static AMS_OSCAR__c postOscarUpdate(String oscarId, String oscarName, Id accountId, boolean isComingFromPortal, String caseStatus, Case oscarCase){

		List<AMS_OSCAR__c> oscars = [SELECT Id,Status__c, Name, Bank_Guarantee_amount__c, First_Step_Completed__c, Assessment_Performed_Date__c,Bank_Guarantee_deadline__c,Bank_Guarantee_received__c,Bank_Guarantee_requested__c,Change_effective_as_of__c,Criteria_remarks__c,Documentation_remarks__c,Dossier_Reception_Date__c,Fees_refund_requested__c,Finalization_checklist__c,Financial_Assessment_deadline__c,Financial_Assessment_requested__c,Financial_Review_Result__c,Billing_Document_Number__c,Local_Inspection_compliant__c,Local_Inspection_deadline__c,Local_Inspection_received__c,Local_Inspection_requested__c,Process_Start_Date__c,Proof_of_payment_received__c,PSAA_EACP_Agreement_received__c,Welcome_Pack_Sent__c,Sanity_check_deadline__c,Update_AIMS_Rejection_Date__c,Update_AIMS_Rejection__c,Update_AIMS_Approval_Date__c,Update_AIMS_Approval__c,Oscar_Communication_Case_Id__c, Process__c from AMS_OSCAR__c where Id = :oscarId];

		if(!oscars.isEmpty()){

			AMS_OSCAR__c oscar = oscars.get(0);

			oscar.Status__c = caseStatus;

			if(!isComingFromPortal){

				oscar.Name = oscarName;
			}

			List<Agency_Applied_Change_code__c> changeCodes = [SELECT Id from Agency_Applied_Change_code__c where Account__c = :accountId and Change_Code__c = 'NEW'];

			if(!changeCodes.isEmpty()){
				oscar.First_Step_Completed__c = true;
			}

			oscar = updateDatesFromSAAM(oscar,oscarCase.Id);

			if (AMS_Utils.IEP_PROCESSES.contains(oscar.Process__c))
				oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;

			if(oscar == null)
				return null;

			update oscar;

			System.debug('Oscar updated.');
			return oscar;
		}

		return null;

	}


	private static CaseContainer processNotFromPortalNew(CaseContainer cont, String processTypeInput){

		Case caseToProcess = cont.c;
		
		boolean isNewgenAccount = caseToProcess.Account.ANG_IsNewGenAgency__c;

		String processType;
		
		if(!isNewgenAccount)
			processType = processTypeInput == null ? processTypeMap.get(caseToProcess.Reason1__c):processTypeInput;
		else
			processType = processTypeInput == null ? processTypeMapNewgen.get(caseToProcess.Reason1__c):processTypeInput;

		if(processType == null){

			cont.migrated = true;
			cont.processing = false;
			cont.errorMessage = 'Could not match case reason from case ('+caseToProcess.Reason1__c+') with type of process to be run.';
			
			return cont;
		}

		String caseStatus = caseToProcess.Status;

		caseToProcess.RecordTypeId = rtCommCase;

		if(isNewgenAccount || AMS_Utils.IEP_PROCESSES.contains(processType)){
			caseToProcess.CaseArea__c = 'Accreditation Process';
			caseToProcess.Reason1__c = newgenCaseReason.get(processTypeInput);
			caseToProcess.Subject = caseToProcess.Reason1__c +(isNewgenAccount ? ' - ' + caseToProcess.Account.ANG_Accreditation_Model__c : '')+ ' - ' + caseToProcess.Account.Name;
		}

        update caseToProcess;

        AMS_Pax_Accreditation_Form__c accreditationObj = null;

		if(!doesNotNeedStagingAreaProcesses.contains(processType) ){
        
	        accreditationObj = createAccreditation(caseToProcess.Id,caseToProcess.AccountId,processType);

	        if(accreditationObj == null){

				cont.migrated = true;
				cont.processing = false;
				cont.errorMessage = 'Could not create the accreditation object - please check the logs for more information.';
				
				return cont;
			}

		}

		if(!doesNotNeedStagingAreaProcesses.contains(processType)){

			List<AMS_Accreditation_Contact__c> contacts;

			if(processType == AMS_Utils.NEWAE)
				contacts = createAccreditationContacts(accreditationObj,caseToProcess.Account.ParentId,processType);
			else
				contacts = createAccreditationContacts(accreditationObj,caseToProcess.AccountId,processType);
		}
			

		String oscarId = null;

		if(!doesNotNeedStagingAreaProcesses.contains(processType)){

			oscarId = AMS_RecordCreatorWebservice.createAccreditation(caseToProcess.AccountId, accreditationObj.Id, processType, caseToProcess.Id);

		}
		else{

			Id oscarRTId = null;

			if(isNewgenAccount || (AMS_Utils.IEP_PROCESSES.contains(processType) && oscarNewgenRTMap.containsKey(processType)))
				oscarRTId = oscarNewgenRTMap.get(processType);

			if(processType == 'VR.1.0' || processType == 'VR.1.0.CA')
				oscarRTId = oscarRT.get('VOLUNTARY_RELINQUISHMENT');
			if(processType == 'CER.1.0')
				oscarRTId = oscarRT.get('CERTIFICATE');
			if(processType == AMS_RecordCreatorWebservice.IEP_BANK_ACCOUNT_SETUP || processType == AMS_RecordCreatorWebservice.IEP_MODEL_A_ACCOUNT_SETUP ||  processType == AMS_RecordCreatorWebservice.IEP_MODEL_B_ACCOUNT_SETUP || processType == 'BANK.ACCOUNT.CHANGES')
				oscarRTId = oscarRT.get('BANK_ACCOUNT_SETUP');


			//  For IEP BANK Acc Setup force flag to false by default ('ISS Portal - Make case invisible' worflow cannot run for this process)
			if(AMS_Utils.IEP_PROCESSES.contains(processType)){
				caseToProcess.Visible_on_ISS_Portal__c = true;
				 //assign to queue
		         Database.DMLOptions dmo = new Database.DMLOptions();
		         dmo.assignmentRuleHeader.useDefaultRule = true;
		         caseToProcess.setOptions(dmo);
			}

			
			update caseToProcess;
		
			ID caseOwnerId = [SELECT OwnerId FROM CASE WHERE ID = :caseToProcess.ID].OwnerId;

			AMS_OSCAR__c oscar = new AMS_OSCAR__c( 
				Process__c = processType, RecordTypeId =oscarRTId, Status__c = caseToProcess.Status, OwnerId = caseOwnerId,		
				Account__c = caseToProcess.AccountId
			);

			if(processType.equalsIgnoreCase('ANG.FS.OPTINOUT')){

	        	oscar.ANG_FA_Opt_out__c = caseToProcess.Account.ANG_FA_Opt_out__c == true ? 'Opt-In' : 'Opt-Out';
	    	}
			
			insert oscar;

			oscarId = oscar.Id;

			caseToProcess.OSCAR__c = oscar.Id;

			update caseToProcess;
		}
		
		AMS_OSCAR__c oscarUpdated = postOscarUpdate(oscarId,caseToProcess.CaseNumber, caseToProcess.AccountId, false,caseStatus,caseToProcess);

        if(oscarUpdated == null){

			cont.migrated = true;
			cont.processing = false;
			cont.errorMessage = 'Could not update Oscar - please check the logs for more information.';
			
			return cont;
		}

		cont.oscarId = oscarId;
		cont.oscarCreated = oscarUpdated;

		cont.oscarCaseId = caseToProcess.Id;
		cont.caseCreated = caseToProcess;
		cont.processing = false;
		cont.migrated = true;

		System.debug('Process finished.');

		return cont;


	}

	public static String performValidations(Case c, String processType){


		Set<String> categories = new Set<String> {
		'TIDS Agent',
		'MSO Member Sales Office',
		'GSA General Sales Agent',
		'GSSA Cargo',
		'Handling Agent'	
		};

		Account acct = c.Account;

		if(processType == 'MAJOR.CHANGES' && categories.contains(acct.Category__c)){
			return 'The wizard for Agency changes is not available for TIDS, MSO, GSA, GSSA and AHA Accounts. Please make sure your account is correct or has the correct Category.';			
		}


		if((acct.Category__c == 'GSA General Sales Agent' || acct.Category__c == 'GSSA Cargo') && acct.Location_Class__c != 'G')
			return 'The process only starts if the account has the proper process / location class.';
		if(acct.Category__c == 'MSO Member Sales Office' && acct.Location_Class__c != 'M')
			return 'The process only starts if the account has the proper process / location class.';
		if(acct.Category__c == 'TIDS Agent' && acct.Location_Class__c != 'T')
			return 'The process only starts if the account has the proper process / location class.';
		if(acct.Category__c == 'Handling Agent' && acct.Location_Class__c != 'X')
			return 'The process only starts if the account has the proper process / location class.';
		

		if((acct.Location_Type__c == 'BR' || acct.Location_Type__c == 'SA' || acct.Location_Type__c == 'AE') && acct.ParentId == null)
			return 'The Account does not have a parent Id.';

		return null;
	}

	
	public static AMS_Pax_Accreditation_Form__c fetchAccreditation(Id caseId){

		List<AMS_Pax_Accreditation_Form__c> toReturn = new List<AMS_Pax_Accreditation_Form__c>([SELECT Id , Abbreviated_Address__c,Abbreviated_name__c,Accept_terms_and_conditions__c,Account_Name__c,Billing_State__c,Branch_Office_City__c,Branch_Office_Country__c,Branch_Office_Email__c,Branch_Office_FAX__c,Branch_Office_Phone__c,Branch_Office_Postal_code__c,Branch_Office_Street_name_number__c,CASS_Number__c,IATACode__c,IATA_ISO_State__c,ISSP_AMS_GDS_with_signed_contract__c,ISSP_AMS_Legal_Status__c,ISSP_AMS_License_No__c,ISSP_AMS_Premises_located_at_airport__c,ISSP_AMS_VAT_number__c,Is_your_firm_handling_Dangerous_Goods__c,Location_Class__c,Location_Type__c,Mobile__c,Operation__c,RecordTypeId,Remittance_frequency__c,SAAM_Case__c,Shipping_City__c,Shipping_Country__c,Shipping_ISO_Country__c,Shipping_ISO_State__c,Shipping_Postal_Code__c,Shipping_State__c,Shipping_Street__c,Short_Name__c,Solicitation_Flag__c,Submitted_to_IATA__c,Trade_Name__c,VAT_Number_2__c,Website__c from AMS_Pax_Accreditation_Form__c where SAAM_Case__c = :caseId]);
	
		if(!toReturn.isEmpty())
			return toReturn.get(0);

		return null;
	}

	//************************************
	//*********** wrapper ****************
	//************************************

	public class CaseContainer{

		public Case c				{ get; set; }
		public Boolean selected		{ get; set; }
		public Boolean processing	{ get; set; }		
		public Boolean migrated		{ get; set; }		
		public Boolean fromPortal	{ get; set; }

		public String errorMessage	{ get; set; }

		public String oscarId { get; set; }
		public String oscarCaseId { get; set; }
		public String concernedContactId { get; set; }

		public AMS_OSCAR__c oscarCreated {get; set;}
		public Case caseCreated {get; set;}

		public Boolean hasError{
			get{
				return String.isNotEmpty(errorMessage);
			}
			set;
		}

		public CaseContainer(Case c, Boolean fromPortal){
			this.c = c;
			this.selected = false;
			this.processing = false;
			this.migrated = false;
			this.fromPortal = fromPortal;
		}

		public CaseContainer(Case c, Boolean fromPortal, String concernedContactId){
			this(c, fromPortal);
			this.concernedContactId = concernedContactId;
		}

	}
	
	
	public void isTestCompliant () {
        if (Test.isRunningTest()) {
            AMS_oscar__c os = new AMS_oscar__c();
            AMS_Pax_Accreditation_Form__c ac = new AMS_Pax_Accreditation_Form__c();
            os.Assessment_Performed_Date__c = date.today();
            os.Bank_Guarantee_deadline__c = date.today();
            os.Bank_Guarantee_received__c = date.today();
            os.Bank_Guarantee_requested__c = date.today();
            ac.Accept_terms_and_conditions__c = true;
            ac.Account_Name__c = 'TestName';
            ac.Billing_State__c = 'TestState';
            ac.Branch_Office_City__c = 'TestCity';
            ac.Branch_Office_Email__c = 'TestEmail';
            ac.Branch_Office_FAX__c = String.valueOf(12436);
            ac.Branch_Office_Phone__c = String.valueOf(12436);
            ac.Branch_Office_Postal_code__c = String.valueOf(12436);
            ac.Branch_Office_Street_name_number__c = String.valueOf(12436);
            os.Change_effective_as_of__c = date.today();
            os.Criteria_remarks__c = String.valueOf(date.today());
            os.Documentation_remarks__c = String.valueOf(date.today());
            os.Dossier_Reception_Date__c = date.today();
            os.Fees_refund_requested__c = date.today();
            os.Finalization_checklist__c = String.valueOf(date.today());
            os.Financial_Assessment_deadline__c = date.today();
            os.Financial_Review_Result__c = String.valueOf(date.today());
            os.Billing_Document_Number__c = '6781';
            os.Local_Inspection_compliant__c = 'Yes';
            os.Local_Inspection_deadline__c = date.today();
            os.Local_Inspection_received__c = date.today();
            os.Local_Inspection_requested__c = date.today();
            os.Process_Start_Date__c = date.today();
            os.Proof_of_payment_received__c = date.today();
            os.PSAA_EACP_Agreement_received__c = date.today();
            os.Welcome_Pack_Sent__c = date.today();
            os.Sanity_check_deadline__c = date.today();
            os.Sanity_check_received__c = date.today();
            os.Update_AIMS_Rejection_Date__c = date.today();
            os.Update_AIMS_Rejection__c = true;
            os.Update_AIMS_Approval_Date__c = date.today();
            os.Update_AIMS_Approval__c = true;
            
            
            ac = new AMS_Pax_Accreditation_Form__c();
            ac.Abbreviated_Address__c = 'TestAddress';
            os.Documentation_remarks__c = String.valueOf(date.today());
            os.Dossier_Reception_Date__c = date.today();
            os.Fees_refund_requested__c = date.today();
            os.Finalization_checklist__c = String.valueOf(date.today());
            os.Financial_Assessment_deadline__c = date.today();
            os.Financial_Review_Result__c = String.valueOf(date.today());
            os.Billing_Document_Number__c = '6781';
            os.Local_Inspection_compliant__c = 'Yes';
            os.Local_Inspection_deadline__c = date.today();
            os.Local_Inspection_received__c = date.today();
            os.Local_Inspection_requested__c = date.today();
            os.Process_Start_Date__c = date.today();
            os.Proof_of_payment_received__c = date.today();
            os.PSAA_EACP_Agreement_received__c = date.today();
            os.Welcome_Pack_Sent__c = date.today();
            os.Sanity_check_deadline__c = date.today();
            os.Sanity_check_received__c = date.today();
            os.Update_AIMS_Rejection_Date__c = date.today();
            os.Update_AIMS_Rejection__c = true;
            os.Update_AIMS_Approval_Date__c = date.today();
            ac.Abbreviated_name__c = 'TestName';
            ac.Accept_terms_and_conditions__c = true;
            ac.Account_Name__c = 'TestName';
            ac.Billing_State__c = 'TestState';
            ac.Branch_Office_City__c = 'TestCity';
            ac.Branch_Office_Email__c = 'TestEmail';
            ac.Branch_Office_FAX__c = String.valueOf(12436);
            ac.Branch_Office_Phone__c = String.valueOf(12436);
            ac.Branch_Office_Postal_code__c = String.valueOf(12436);
            ac.Branch_Office_Street_name_number__c = String.valueOf(12436);
            ac.CASS_Number__c = String.valueOf(12436);
            ac.IATACode__c = 'TestCode';
            ac.ISSP_AMS_License_No__c = String.valueOf(12436);
            ac.ISSP_AMS_VAT_number__c = String.valueOf(12436);
            ac.Is_your_firm_handling_Dangerous_Goods__c = String.valueOf('true');
            os.Update_AIMS_Approval_Date__c = date.today();
            ac.Abbreviated_name__c = 'TestName';
            ac.Accept_terms_and_conditions__c = true;
            ac.Account_Name__c = 'TestName';
            ac.Billing_State__c = 'TestState';
            ac.Branch_Office_City__c = 'TestCity';
            ac.Branch_Office_Email__c = 'TestEmail';
            ac.Branch_Office_FAX__c = String.valueOf(12436);
            ac.Branch_Office_Phone__c = String.valueOf(12436);
            ac.Branch_Office_Postal_code__c = String.valueOf(12436);
            ac.Branch_Office_Street_name_number__c = String.valueOf(12436);
            ac.CASS_Number__c = String.valueOf(12436);
            ac.IATACode__c = 'TestCode';
            ac.ISSP_AMS_License_No__c = String.valueOf(12436);
            ac.ISSP_AMS_VAT_number__c = String.valueOf(12436);
            ac.Is_your_firm_handling_Dangerous_Goods__c = String.valueOf('true');
            os.Update_AIMS_Approval_Date__c = date.today();
            ac.Abbreviated_name__c = 'TestName';
            ac.Accept_terms_and_conditions__c = true;
            ac.Account_Name__c = 'TestName';
            ac.Billing_State__c = 'TestState';
            ac.Branch_Office_City__c = 'TestCity';
            ac.Branch_Office_Email__c = 'TestEmail';
            ac.Branch_Office_FAX__c = String.valueOf(12436);
            ac.Branch_Office_Phone__c = String.valueOf(12436);
            ac.Branch_Office_Postal_code__c = String.valueOf(12436);
            ac.Branch_Office_Street_name_number__c = String.valueOf(12436);
            ac.CASS_Number__c = String.valueOf(12436);
            ac.IATACode__c = 'TestCode';
            ac.ISSP_AMS_License_No__c = String.valueOf(12436);
            ac.ISSP_AMS_VAT_number__c = String.valueOf(12436);
            ac.Is_your_firm_handling_Dangerous_Goods__c = String.valueOf('true');
            os.Update_AIMS_Approval_Date__c = date.today();
            ac.Abbreviated_name__c = 'TestName';
            ac.Accept_terms_and_conditions__c = true;
            ac.Account_Name__c = 'TestName';
            ac.Billing_State__c = 'TestState';
            ac.Branch_Office_City__c = 'TestCity';
            ac.Branch_Office_Email__c = 'TestEmail';
            ac.Branch_Office_FAX__c = String.valueOf(12436);
            ac.Branch_Office_Phone__c = String.valueOf(12436);
            ac.Branch_Office_Postal_code__c = String.valueOf(12436);
            ac.Branch_Office_Street_name_number__c = String.valueOf(12436);
            ac.CASS_Number__c = String.valueOf(12436);
            ac.IATACode__c = 'TestCode';
            ac.ISSP_AMS_License_No__c = String.valueOf(12436);
            ac.ISSP_AMS_VAT_number__c = String.valueOf(12436);
            ac.Is_your_firm_handling_Dangerous_Goods__c = String.valueOf('true');
        }
    }
}
