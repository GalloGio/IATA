public with sharing class AMS_MigrationToolHelper {
	// this class is responsible for migrating Portal SAAM cases and SAAM cases that need to be converted into Comunication Cases (w/ AMS_OSCAR__c objects)
	
	final static ID rtCommCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();

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
            'CHC – Change of Shareholding' => 'MAJOR.CHANGES'
            };
        }
        set;
    }


	public static CaseContainer migratecases(CaseContainer cont){

		Savepoint sp = null;

		try {

			sp = Database.setSavepoint();

			if(cont.fromPortal)
					cont = processFromPortal(cont); //call portal method
			else{
					cont = processNotFromPortalNew(cont);
			}

		} catch(Exception e) {
			System.debug(e.getMessage());
			cont.errorMessage = e.getMessage(); //or other stuff
			cont.migrated = true;
			cont.processing = false;

			if(sp != null)
				Database.rollback(sp);

		}



		return cont;
	}

	private static void alignOwners(AMS_Pax_Accreditation_Form__c accreditationObj, Case commCase){

		List<AMS_Accreditation_Contact__c> contactsToUpdate = new List<AMS_Accreditation_Contact__c>();

		List<AMS_Accreditation_Contact__c> contacts = [SELECT Id, Legacy_External_ID__c, AMS_Ownership_Role__c, Contact__c, Person_AMS__c,   Company__c, Name from AMS_Accreditation_Contact__c where AMS_Pax_Accreditation_Form__c = :accreditationObj.Id and AMS_Ownership_Role__c = null and Agency_owner__c = true];

		List<AMS_Account_Role__c> roles = [SELECT Id, Contact__c, Person__c, Legacy_External_ID__c, Owner_Account__c,Owner_Name__c,Person__r.Contact__c from AMS_Account_Role__c where Active__c = true and Account__c = :commCase.AccountId];

		for(AMS_Accreditation_Contact__c contact: contacts){

			for(AMS_Account_Role__c role: roles){

				if(contact.Contact__c != null && contact.Contact__c == role.Contact__c){
					contact.AMS_Ownership_Role__c = role.Id;
					contactsToUpdate.add(contact);
					break;
				}

				if(contact.Contact__c != null && role.Person__c != null && role.Person__r.Contact__c != null && contact.Contact__c == role.Person__r.Contact__c){
					contact.AMS_Ownership_Role__c = role.Id;
					contactsToUpdate.add(contact);
					break;
				}

				if(contact.Person_AMS__c != null && contact.Person_AMS__c == role.Person__c){
					contact.AMS_Ownership_Role__c = role.Id;
					contactsToUpdate.add(contact);
					break;
				}

				if(contact.Company__c != null && contact.Company__c == role.Owner_Account__c){
					contact.AMS_Ownership_Role__c = role.Id;
					contactsToUpdate.add(contact);
					break;
				}

				if(contact.Legacy_External_Id__c != null && contact.Legacy_External_Id__c == role.Legacy_External_ID__c){
					contact.AMS_Ownership_Role__c = role.Id;
					contactsToUpdate.add(contact);
					break;
				}

				if(contact.Contact__c == null && contact.Person_AMS__c == null && contact.Company__c == null && contact.Legacy_External_Id__c == null && Role.Owner_Name__c != null){
					if(contact.Name == role.Owner_Name__c){
						contact.AMS_Ownership_Role__c = role.Id;
						contactsToUpdate.add(contact);
						break;
					}
				}
			}

		}

		if(!contactsToUpdate.isEmpty())
			update contactsToUpdate;
	}

	private static CaseContainer processFromPortal(CaseContainer cont){

		Case caseToProcess = cont.c;

		caseToProcess.RecordTypeId = rtCommCase;

		String caseStatus = caseToProcess.Status;

        update caseToProcess;
        
		AMS_Pax_Accreditation_Form__c accreditationObj = fetchAccreditation(caseToProcess.Id);

		String processType = processTypeMap.get(caseToProcess.Reason1__c);

		if(processType == null){

			cont.migrated = true;
			cont.processing = false;
			cont.errorMessage = 'Could not match case reason from case ('+caseToProcess.Reason1__c+') with type of process to be run.';
			
			return cont;
		}

		alignOwners(accreditationObj,caseToProcess);

		String oscarId = AMS_RecordCreatorWebservice.createAccreditation(caseToProcess.AccountId, accreditationObj.Id, processType, caseToProcess.Id);

		postOscarUpdate(oscarId,caseToProcess.CaseNumber, caseToProcess.AccountId, true, caseStatus,caseToProcess);

		cont.oscarId = oscarId;
		cont.oscarCreated = new AMS_OSCAR__c(Id = oscarId, Name = caseToProcess.CaseNumber);

		cont.oscarCaseId = caseToProcess.Id;
		cont.caseCreated = caseToProcess;
		cont.processing = false;
		cont.migrated = true;

		if(accreditationObj.IATACode__c == null && caseToProcess.Account.IATACode__c != null){
			
			accreditationObj.IATACode__c = caseToProcess.Account.IATACode__c;
			
			update accreditationObj;
		}

		return cont;

	}

	private static Id fetchAccreditationRT(String locationClass, String processType){

		String devName = 'General Online Accreditation';

		if(locationClass == 'P'){
			if(processType == 'NEW.HO.1.0')
				devName = 'Travel Agent - HO';
			if(processType == 'NEW.BR')
				devName = 'Travel Agent - Branch';
			if(processType == 'NEW.BR.ABROAD')
				devName = 'Travel Agent - Branch Abroad';
		}

		if(locationClass == 'C'){
			if(processType == 'NEW.HO.1.0')
				devName = 'Cargo Agent - HO';
			if(processType == 'NEW.BR')
				devName = 'Cargo Agent - Branch';
			if(processType == 'NEW.BR.ABROAD')
				devName = 'Cargo Agent - Branch';
		}

		if(processType == 'MAJOR.CHANGES')
			devName = 'Other Changes';

		return Schema.SObjectType.AMS_Pax_Accreditation_Form__c.getRecordTypeInfosByName().get(devName).getRecordTypeId();

	}

	private static AMS_Pax_Accreditation_Form__c createAccreditation(String caseId, String accountId, String processType){

		Account acct = null;

		List<Account> directAccountLst = [SELECT Id, ParentId , Abbreviated_address__c,Abbreviated_name__c,Name,BillingState,BillingCity,IATA_ISO_Country__c,Email__c,Fax,Phone,BillingPostalCode,BillingStreet,CASS_Number__c,IATACode__c,Iso_State__c,GDS__c,Company_Type__c,License_Number__c,In_a_Airport__c,VAT_Number__c,Is_your_firm_handling_Dangerous_Goods__c,Location_Class__c,Location_Type__c,Mobile__c,Operation__c,Remittance_frequency__c,ShippingCity,ShippingCountry,IATA_ISO_Shipping_Country__c,IATA_ISO_Shipping_State__c,ShippingPostalCode,ShippingState,ShippingStreet,Short_Name__c,Solicitation_Flag__c,TradeName__c,VAT_Number_2__c,Website from Account where Id = :accountId];

		if(directAccountLst.isEmpty())
			return null;

		Account directAccount = directAccountLst.get(0);

		if(directAccount.Location_Type__c == 'BR' || directAccount.Location_Type__c == 'SA'){

			List<Account> parentAccountLst = [SELECT Id, ParentId , Abbreviated_address__c,Abbreviated_name__c,Name,BillingState,BillingCity,IATA_ISO_Country__c,Email__c,Fax,Phone,BillingPostalCode,BillingStreet,CASS_Number__c,IATACode__c,Iso_State__c,GDS__c,Company_Type__c,License_Number__c,In_a_Airport__c,VAT_Number__c,Is_your_firm_handling_Dangerous_Goods__c,Location_Class__c,Location_Type__c,Mobile__c,Operation__c,Remittance_frequency__c,ShippingCity,ShippingCountry,IATA_ISO_Shipping_Country__c,IATA_ISO_Shipping_State__c,ShippingPostalCode,ShippingState,ShippingStreet,Short_Name__c,Solicitation_Flag__c,TradeName__c,VAT_Number_2__c,Website from Account where Id = :directAccount.ParentId ];

			if(parentAccountLst.isEmpty())
				return null;

			acct = parentAccountLst.get(0);

		}
		else
			acct = directAccount;
		
		AMS_Pax_Accreditation_Form__c accreditationObj = new AMS_Pax_Accreditation_Form__c();

		accreditationObj.Abbreviated_Address__c = acct.Abbreviated_address__c;
		accreditationObj.Abbreviated_name__c = directAccount.Abbreviated_name__c;
		accreditationObj.Accept_terms_and_conditions__c = true;
		accreditationObj.Account_Name__c = acct.Name;
		accreditationObj.Billing_State__c = directAccount.BillingState;
		accreditationObj.Branch_Office_City__c = acct.BillingCity;

		accreditationObj.Branch_Office_Country__c = processType == 'NEW.BR.ABROAD' ?  directAccount.IATA_ISO_Country__c : acct.IATA_ISO_Country__c;
		
		accreditationObj.Branch_Office_Email__c = directAccount.Email__c;
		accreditationObj.Branch_Office_FAX__c = directAccount.Fax;
		accreditationObj.Branch_Office_Phone__c = directAccount.Phone;
		accreditationObj.Branch_Office_Postal_code__c = acct.BillingPostalCode;
		accreditationObj.Branch_Office_Street_name_number__c = acct.BillingStreet;
		accreditationObj.CASS_Number__c = directAccount.CASS_Number__c;
		accreditationObj.IATACode__c = directAccount.IATACode__c;
		accreditationObj.IATA_ISO_State__c = acct.Iso_State__c;
		accreditationObj.ISSP_AMS_GDS_with_signed_contract__c = AMS_AgencyHelper.transformGDS(directAccount.GDS__c);
		accreditationObj.ISSP_AMS_Legal_Status__c = acct.Company_Type__c;
		accreditationObj.ISSP_AMS_License_No__c = directAccount.License_Number__c;
		accreditationObj.ISSP_AMS_Premises_located_at_airport__c = directAccount.In_a_Airport__c == true ? 'Yes' : 'No';
		accreditationObj.ISSP_AMS_VAT_number__c = acct.VAT_Number__c;
		accreditationObj.Is_your_firm_handling_Dangerous_Goods__c = directAccount.Is_your_firm_handling_Dangerous_Goods__c;
		accreditationObj.Location_Class__c = acct.Location_Class__c;
		accreditationObj.Location_Type__c = directAccount.Location_Type__c;
		accreditationObj.Mobile__c = directAccount.Mobile__c;
		accreditationObj.Operation__c = directAccount.Operation__c;
		accreditationObj.RecordTypeId = fetchAccreditationRT(acct.Location_Class__c,processType);
		accreditationObj.Remittance_frequency__c = directAccount.Remittance_frequency__c;
		accreditationObj.SAAM_Case__c = caseId;
		accreditationObj.Shipping_City__c = directAccount.ShippingCity;
		accreditationObj.Shipping_Country__c = directAccount.ShippingCountry;
		accreditationObj.Shipping_ISO_Country__c = acct.IATA_ISO_Shipping_Country__c;
		accreditationObj.Shipping_ISO_State__c = acct.IATA_ISO_Shipping_State__c;
		accreditationObj.Shipping_Postal_Code__c = acct.ShippingPostalCode;
		accreditationObj.Shipping_State__c = directAccount.ShippingState;
		accreditationObj.Shipping_Street__c = acct.ShippingStreet;
		accreditationObj.Short_Name__c = directAccount.Short_Name__c;
		accreditationObj.Solicitation_Flag__c = directAccount.Solicitation_Flag__c;
		accreditationObj.Submitted_to_IATA__c = true;
		accreditationObj.Trade_Name__c = directAccount.TradeName__c;
		accreditationObj.VAT_Number_2__c = acct.VAT_Number_2__c;
		accreditationObj.Website__c = acct.Website;

		insert accreditationObj;

		return accreditationObj;
	}

	private static AMS_Accreditation_Contact__c createAccreditationContact(AMS_Pax_Accreditation_Form__c accreditationObj, AMS_Account_Role__c role, String processType){

		AMS_Accreditation_Contact__c contact = new AMS_Accreditation_Contact__c();

		if(processType == 'NEW.HO.1.0' || processType == 'MAJOR.CHANGES')
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

		ID ownerRT = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Current Owner').getRecordTypeId();
		ID companyOwnerRt = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Current Company Owner').getRecordTypeId();

		contact.RecordTypeId = role.Owner_Account__c != null ? companyOwnerRt : ownerRT;

		return contact;

	}

	private static List<AMS_Accreditation_Contact__c> createAccreditationContacts(AMS_Pax_Accreditation_Form__c accreditationObj, Id accountId, String typeOfProcess){

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

	private static AMS_OSCAR__c updateDatesFromSAAM(AMS_OSCAR__c oscar, Case saamCase){
		

		System.debug('Starting to migrate date fields...');

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
		oscar.Dossier_Reception_Date__c = saamCase.Dossier_reception_date__c;
		oscar.Fees_refund_requested__c = saamCase.Fees_refund_requested__c;
		oscar.Finalization_checklist__c = saamCase.Finalization_checklist__c;
		oscar.Financial_Assessment_deadline__c = saamCase.Financial_Assessment_deadline__c;
		oscar.Financial_Assessment_requested__c = saamCase.Financial_Assessment_requested__c;
		oscar.Financial_Review_Result__c = saamCase.Financial_Review_Result__c;
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
		oscar.Update_AIMS_Rejection_Date__c = saamCase.AIMS_updated__c != null ? saamCase.AIMS_updated__c.date() : null;
		oscar.Update_AIMS_Rejection__c = saamCase.AIMS_updated__c != null ? true : false;
		oscar.Update_AIMS_Approval_Date__c = saamCase.Finalized_in_AIMS__c != null ? saamCase.Finalized_in_AIMS__c.date() : null;
		oscar.Update_AIMS_Approval__c = saamCase.Finalized_in_AIMS__c != null ? true : false;

		System.debug('End date fields migration...');

		return oscar;
	}

	private static void postOscarUpdate(String oscarId, String oscarName, Id accountId, boolean isComingFromPortal, String caseStatus, Case oscarCase){

		List<AMS_OSCAR__c> oscars = [SELECT Id, Name, First_Step_Completed__c from AMS_OSCAR__c where Id = :oscarId];

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

			oscar = updateDatesFromSAAM(oscar,oscarCase);

			update oscar;

			System.debug('Oscar updated.');

			System.debug('Oscar:'+oscar);
		}

	}


	private static CaseContainer processNotFromPortalNew(CaseContainer cont){

		Case caseToProcess = cont.c;

		String processType = processTypeMap.get(caseToProcess.Reason1__c);

		if(processType == null){

			cont.migrated = true;
			cont.processing = false;
			cont.errorMessage = 'Could not match case reason from case ('+caseToProcess.Reason1__c+') with type of process to be run.';
			
			return cont;
		}

		String caseStatus = caseToProcess.Status;

		caseToProcess.RecordTypeId = rtCommCase;

        update caseToProcess;

        AMS_Pax_Accreditation_Form__c accreditationObj = createAccreditation(caseToProcess.Id,caseToProcess.AccountId,processType);

        if(accreditationObj == null){

			cont.migrated = true;
			cont.processing = false;
			cont.errorMessage = 'Could not create the accreditation object - please check the logs for more information.';
			
			return cont;
		}

		List<AMS_Accreditation_Contact__c> contacts = createAccreditationContacts(accreditationObj,caseToProcess.AccountId,processType);

		String oscarId = AMS_RecordCreatorWebservice.createAccreditation(caseToProcess.AccountId, accreditationObj.Id, processType, caseToProcess.Id);

		postOscarUpdate(oscarId,caseToProcess.CaseNumber, caseToProcess.AccountId, false,caseStatus,caseToProcess);

		cont.oscarId = oscarId;
		cont.oscarCreated = new AMS_OSCAR__c(Id = oscarId, Name = caseToProcess.CaseNumber);

		cont.oscarCaseId = caseToProcess.Id;
		cont.caseCreated = caseToProcess;
		cont.processing = false;
		cont.migrated = true;

		System.debug('Process finished.');

		return cont;


	}

	private static CaseContainer processNotFromPortal(CaseContainer cont){
		
		Case caseToProcess = cont.c;

		AMS_Pax_Accreditation_Form__c accreditationObj = fetchAccreditation(caseToProcess.Id);

		String processType = processTypeMap.get(caseToProcess.Reason1__c);

		if(processType == null){

			cont.migrated = true;
			cont.processing = false;
			cont.errorMessage = 'Could not match case reason from case ('+caseToProcess.Reason1__c+') with type of process to be run.';
			
			return cont;
		}


		String resultValidations = performValidations(caseToProcess,processType);

		Map<String, Object> flowVarMap = new Map<String, Object>();
      	
      	flowVarMap.put('accountId', caseToProcess.AccountId);
      	flowVarMap.put('Type_of_OSCAR_process_in', processType);
      	flowVarMap.put('ContactChooserEmailInput_in', caseToProcess.Contact.Email);
      	

      	System.debug('Starting with flow ...');
		
		Flow.Interview.OSCAR_Wizard_SIMPLEX_Automatic_v2_0 wizardFlow = new Flow.Interview.OSCAR_Wizard_SIMPLEX_Automatic_v2_0(flowVarMap);
		wizardFlow.start();

		System.debug('Flow has ended...');

		String oscarCaseId = (String)(wizardFlow.getVariableValue('OscarCaseId'));
		String oscarId = (String)(wizardFlow.getVariableValue('OscarId'));

		Case caseCreated = (Case)(wizardFlow.getVariableValue('CaseCreatedObject'));
		AMS_OSCAR__c oscarCreated = (AMS_OSCAR__c)(wizardFlow.getVariableValue('CreatedOscarObject'));


		System.debug('Oscar case id is ' + oscarCaseId);
		System.debug('Oscar id is ' + oscarId);
		
		caseToProcess.ParentId = oscarCaseId;

		update caseToProcess;

		System.debug('Case updated.');

		cont.oscarId = oscarId;
		cont.oscarCaseId = oscarCaseId;
		cont.oscarCreated = oscarCreated;
		cont.caseCreated = caseCreated;
		cont.processing = false;
		cont.migrated = true;

		if(accreditationObj == null)
			accreditationObj = fetchAccreditation(oscarCaseId);

		if(accreditationObj.IATACode__c == null && caseToProcess.Account.IATACode__c != null){
			
			accreditationObj.IATACode__c = caseToProcess.Account.IATACode__c;
			
			update accreditationObj;
		}

		System.debug('Process finished.');

		return cont;
		
		return null;
	}

	private static String performValidations(Case c, String processType){


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
		

		if((acct.Location_Type__c == 'BR' || acct.Location_Type__c == 'SA' ) && acct.ParentId == null)
			return 'The Account does not have a parent Id.';

		return null;
	}


	private static AMS_Pax_Accreditation_Form__c fetchAccreditation(Id caseId){

		List<AMS_Pax_Accreditation_Form__c> toReturn = new List<AMS_Pax_Accreditation_Form__c>([SELECT Id , IATACode__c from AMS_Pax_Accreditation_Form__c where SAAM_Case__c = :caseId]);
	
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
	}
}