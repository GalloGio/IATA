public class ISSP_ICCS_ProcessBankAccountController extends ISSP_ICCS_CaseProcessController {

	/* PROCESS TYPE SPECIFIC VARIABLES */

    public ISSP_ICCS_ProcessBankAccountController thisCtrl {get{ return this; }}

	public Integer bankAccountCodeId {get;set;}
	public String bankAccountOperation {get;set;}

	public String bankAccountCodeLabel 				{ get{ return 'Bank Account Code : '; }}
	public String bankAccountNameLabel 				{ get{ return 'Name : '; }}
	public String bankAccountBicLabel 				{ get{ return 'BIC : '; }}
	public String bankAccountNumberLabel 			{ get{ return 'Number : '; }}
	public String bankAccountCurrencyLabel 			{ get{ return 'Currency : '; }}
	public String additionalBankAccountCodesLabel 	{ get{ return 'Codes to create : '; }}

	public String bankAccountCode {get;set;}
	public String bankName {get;set;}
	public String bankBic {get;set;}
	public String bankNumber {get;set;}
	public String bankCurrency {get;set;}
	public String additionalBankAccountCodes {get;set;}


	public List<SelectOption> reasons {get;set;}
	public String selectedReason {get;set;}
	

	/* CONSTRUCTOR */

	public ISSP_ICCS_ProcessBankAccountController(){}


	public override ISSP_ICCS_Utils.CaseProcessType getCaseProcessType(){
		return ISSP_ICCS_Utils.CaseProcessType.BANK_ACCOUNT;
	}

    public override void resetController(ISSP_ICCS_CaseProcessesController caseProcessesController){
    	ISSP_ICCS_ComponentController componentController = caseProcessesController.pageController.componentControllersMap.get(caseProcessesController.pageController.previousComponent);
    	
    	if(componentController instanceof ISSP_ICCS_ServiceMgmtController){
	    	ISSP_ICCS_ServiceMgmtController serviceMgmtController = (ISSP_ICCS_ServiceMgmtController) componentController;

			bankAccountOperation = serviceMgmtController.bankAccountOperationParameter;
			bankAccountCodeId = serviceMgmtController.bankAccountCodeIdParameter;
    	}
    }

	public override void cleanController(){
		bankAccountCodeId = null;
		bankAccountOperation = null;

		bankAccountCode = null;
		bankName = null;
		bankBic = null;
		bankNumber = null;
		bankCurrency = null;
		additionalBankAccountCodes = null;
	
		reasons = null;
		selectedReason = null;
	}

	public override String getCaseProcessName(){
		if(caseProcessesController.cse.Id == null){
			return bankAccountOperation + ' Bank Account';
		}
		else if(caseProcessesController.cse.CaseArea__c == ISSP_ICCS_Utils.CASE_AREA_ADD_BANK_ACCOUNT){
			return 'Create Bank Account';
		}
		else{
			return 'Update Bank Account';
		}
	}

	public override Map<Integer, ISSP_ICCS_CaseProcessesController.Step> getSteps(){
        return new Map<Integer,ISSP_ICCS_CaseProcessesController.Step>{
                1 => new ISSP_ICCS_CaseProcessesController.Step('Step 1 - Upload Bank Account File', 100, 100)};
	}

	public override List<String> getCaseProcessDocuments(){
	    return new List<String>{
        	ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS};
	}

	public override Map<String, ISSP_ICCS_CaseProcessController.TypedDocument> getCaseProcessTypedDocumentMap(){
		return new Map<String, ISSP_ICCS_CaseProcessController.TypedDocument>{
			ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS, true)
		};
	}
    
    public override void fillAdditionalMessages(){
        // step 1
        caseProcessesController.displayMessages.put('selectedReason', false);
        caseProcessesController.displayMessages.put('codeNumberNull', false);
        caseProcessesController.displayMessages.put('codeNumberNotAnInteger', false);
	}
    
    public override Case createCase(){    	
		return new Case(
			Subject = 'ICCS ' + bankAccountOperation + ' Bank Account - ' + caseProcessesController.pageController.topAccount.Name,
			Origin = 'Portal',
			Status = 'Draft',
			Visible_on_ISS_Portal__c = true,
			contactId = caseProcessesController.pageController.portalUserContact.Id,
			AccountId = caseProcessesController.pageController.topAccount.Id,
			Priority = 'Medium',
			RecordTypeId = ISSP_ICCS_Utils.CASE_RECORD_TYPE_BANK_ACCT);
	}

	public override Case retrieveCase(Id caseId){
		return [select	
					Id, 
					CaseNumber, 
					Subject, 
					Status,
					Account.Name,
					IATA_Code__c,
					Contact.Name, 
					Contact.Email, 
					Contact.Phone, 
					Origin,
					CaseArea__c,
					Reason1__c,
					Expected_Deadline__c,
					Description
				from Case 
				where Id =: caseId];
	}

	public override void resetVariables(){
		bankAccountCode = '';
		bankName = '';
		bankBic = '';
		bankNumber = '';
		bankCurrency = '';
		additionalBankAccountCodes = '';

		// No case was created yet
		if(caseProcessesController.cse.Id == null){
		    caseProcessesController.cse.Expected_Deadline__c = Date.today() + 15;

			// Creating a bank account, we'll just need the user to upload a file
			if(bankAccountOperation == 'Create'){
				caseProcessesController.cse.CaseArea__c = ISSP_ICCS_Utils.CASE_AREA_ADD_BANK_ACCOUNT;
			    caseProcessesController.cse.Reason1__c = 'Create';
			}
			// Updating a bank account, the user will have to select the reason, add bank account codes or change bank information, and upload a file in the latter case
			else{
				caseProcessesController.cse.CaseArea__c = ISSP_ICCS_Utils.CASE_AREA_UPD_BANK_ACCOUNT;

				reasons = new List<SelectOption>();
				reasons.add(new SelectOption(ISSP_ICCS_Utils.NONE, ISSP_ICCS_Utils.NONE));
				reasons.add(new SelectOption('Clone Bank Account', 'Clone Bank Account with new Bank Account Code'));
				reasons.add(new SelectOption('Change Request', 'Change Request'));

				// As we are creating a case, the bank account id must be retrievable from the page controller, otherwise, display an error message
				if(bankAccountCodeId == null){
					// display error if bank account could not be found
					caseProcessesController.pageController.setMessage('The Bank Account Code id is null.', false);
					return;
				}

				Boolean bankAcccountCodeRetrieved = false;

				try{
					for(ISSP_ICCS_CoreRest.BankAccountCode bac : caseProcessesController.pageController.coreRest.getBankAccountsCodes()){
						if(bac.id == bankAccountCodeId){

							bankAccountCode = bac.code;
							bankName = bac.bankAccount.bank.name;
							bankBic = bac.bankAccount.bank.bic;
							bankNumber = bac.bankAccount.number_x;
							bankCurrency = bac.bankAccount.currency_x;

							bankAcccountCodeRetrieved = true;
							break;
						}
					}
				}
				catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
					caseProcessesController.pageController.setMessage(e.getMessage(), false);
					return;
				}
				
				if(!bankAcccountCodeRetrieved){
					caseProcessesController.pageController.setMessage('The Bank Account to update could not be retrieved.', false);
					return;
				}
			}
		}
		// opening an existing case
		else{
			// Creating a bank account
			if(caseProcessesController.cse.CaseArea__c == ISSP_ICCS_Utils.CASE_AREA_ADD_BANK_ACCOUNT){
				bankAccountOperation = 'Create';
			}
			// Updating a bank account
			else{
				bankAccountOperation = 'Update';

				reasons = new List<SelectOption>();
				reasons.add(new SelectOption(ISSP_ICCS_Utils.NONE, ISSP_ICCS_Utils.NONE));
				reasons.add(new SelectOption('Clone Bank Account', 'Clone Bank Account with new Bank Account Code'));
				reasons.add(new SelectOption('Change Request', 'Change Request'));

				// Retrieve the core bank account id from the description
				// and the number of bank account codes to create (if set)

				List<String> caseData = caseProcessesController.cse.Description.split('\n');

				if(caseData.size() < 5){
					// ERROR, should not happen
				}
				else{
					bankAccountCode = caseData[0].remove(bankAccountCodeLabel);
					bankName = caseData[1].remove(bankAccountNameLabel);
					bankBic = caseData[2].remove(bankAccountBicLabel);
					bankNumber = caseData[3].remove(bankAccountNumberLabel);
					bankCurrency = caseData[4].remove(bankAccountCurrencyLabel);
					
					if(caseData.size() > 5){
						additionalBankAccountCodes = caseData[5].remove(additionalBankAccountCodesLabel);
					}
				}

				selectedReason = caseProcessesController.cse.Reason1__c;			
			}
		}
	}

    public override Boolean validateStep(){
        Boolean stepValid = true;

		if(bankAccountOperation == 'Create'){
            caseProcessesController.displayMessages.put(ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS, !typedDocumentsMap.get(ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS).documentExists);

            return !caseProcessesController.displayMessages.get(ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS);
		}
		else{
			caseProcessesController.displayMessages.put('selectedReason', selectedReason == ISSP_ICCS_Utils.NONE);
			if(selectedReason == ISSP_ICCS_Utils.NONE){
				return false;
			}
            
			if(selectedReason == 'Clone Bank Account'){
				caseProcessesController.displayMessages.put('codeNumberNull', additionalBankAccountCodes == null || additionalBankAccountCodes == '');
				if(additionalBankAccountCodes == null || additionalBankAccountCodes == ''){
					return false;
				}
				
				try{
					Integer.valueOf(additionalBankAccountCodes);
				}
				catch(Exception e){
					caseProcessesController.displayMessages.put('codeNumberNotAnInteger', true);
					return false;
				}
			}
			else if(selectedReason == 'Change Request'){
	            caseProcessesController.displayMessages.put(ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS, !typedDocumentsMap.get(ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS).documentExists);

	            return !caseProcessesController.displayMessages.get(ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS);
			}
		}
        return true;
    }

	public override void setCaseFieldValues(){
		caseProcessesController.cse.Expected_Deadline__c = caseProcessesController.cse.Expected_Deadline__c != null ? caseProcessesController.cse.Expected_Deadline__c : Date.today() + 15;

		// maybe we won't need to display the description when updating a bank account
		// For the moment, we fill it with the id of the bank account in the core. This way, we can retrieve this information when:
		// - Portal user comes back on an existing case
		// - Custom Service views the case. A VF page will be embedded in the case layout in which we'll display 
		//   information retrieved from the core bayed on that bank account id
		// This field must be read-only in the case layout (will be for both update and create case areas)
		if(bankAccountOperation == 'Update'){
			caseProcessesController.cse.Description = 	bankAccountCodeLabel + bankAccountCode + '\n' +
								bankAccountNameLabel + bankName +  '\n' +
								bankAccountBicLabel + bankBic +  '\n' +
								bankAccountNumberLabel + bankNumber +  '\n' +
								bankAccountCurrencyLabel + bankCurrency;
								
			caseProcessesController.cse.Reason1__c = selectedReason;

			if(selectedReason == 'Clone Bank Account'){
				caseProcessesController.cse.Description += '\n' + additionalBankAccountCodesLabel + additionalBankAccountCodes;
			}
		}
	}

/*	CHECK HOW WE CAN REPLACE THIS

	public override void saveAndLeave(){
		if(additionalBankAccountCodes != null && additionalBankAccountCodes != ''){
			try{
				Integer.valueOf(additionalBankAccountCodes);
			}
			catch(Exception e){
				caseProcessesController.displayMessages.put('codeNumberNotAnInteger', true);
				return;
			}
		}
		super.saveAndLeave();
	}
	*/
}