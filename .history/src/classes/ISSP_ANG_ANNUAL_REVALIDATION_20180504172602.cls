public with sharing class ISSP_ANG_ANNUAL_REVALIDATION {
	public String communityName { get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
	public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
	public Contact con {get; set;}
	public String step1GoToNumber {get; set;}
	public String stepNumber {get; set;}
	public Boolean isStep1 {get; set;}
	public Boolean isStep2 {get; set;}
	public Case newCase {get; set;}
	public AMS_OSCAR__c oscar {get; set;}
	public Set<String> iataCodesOk {get; set;}
	public Set<String> iataCodesConfirmed {get; set;}
	public Set<String> iataCodesInProgress {get; set;}
	public Map<String, formWrapper> formsMap {get; set;}
	public Map<String, Account> accountsMap {get; set;}
	public String jsonTree {get; set;}
	public Set<Id> parents {get; set;}
	public Set<Id> childs {get; set;}
	public Account headEntity {get; set;}
	List<Account> childsAccounts {get; set;}

	public String tree {get {
		return jsonTree;
	} set;}

	public static String DEFAULT_ICON = 'glyphicon glyphicon-refresh text-primary';
	public static String OK_ICON = 'glyphicon glyphicon-ok text-success';
	public static String CONFIRMED_ICON = 'glyphicon glyphicon-flag text-danger';
	public static String PROGRESS_ICON = 'glyphicon glyphicon-edit text-danger';

	public static String OPEN_STATUS = 'O';
	public static String COMPLETED_STATUS = 'C';
	public static String UPDATE_PROGRESS_STATUS = 'UP';
	public static String UPDATE_COMPLETED_STATUS = 'UC';

	public static JsonValue SELECTED_FALSE = new Selected(false);
	public static JsonValue SELECTED_TRUE = new Selected(true);
	public static JsonValue OPENED_TRUE = new Opened(true);
	public static JsonValue MULTIPLE_FALSE = new Multiple(false);
	public static JsonValue SELECTED_OPENED = new SelectedOpened(true, true);
	public ANG_AnnualRevRoCurrentAccount currentAccount {get; set;}

	public ANG_AnnualRevRoHelper helper {get {return new ANG_AnnualRevRoHelper(currentAccount);} set;}

	public static Set<String> statusSet = new Set<String> {
		Ams_Utils.ACC_S9_APPROVED,
		Ams_Utils.ACC_S8_CHANGESPROCESSED,
		Ams_Utils.ACC_S0_TERMINATED,
		Ams_Utils.ACC_S5_CASHNOCOMMISSION,
		Ams_Utils.ACC_S6_CASHWITHCOMMISSION
    };

	public String caseId {get; set;}
	public String currentIataCode {get; set;}
	public boolean setHe {get; set;}

	//
	// INNER CLASSES
	//
	public class FormWrapper {
		public AMS_Pax_Accreditation_Form__c newForm {get; set;}
		public List<AMS_Accreditation_Contact__c> previousOwners {get; set;}
		public List<AMS_Accreditation_Contact__c> previousCompanies {get; set;}
		public List<AMS_Accreditation_Contact__c> currentOwners {get; set;}
		public List<AMS_Accreditation_Contact__c> currentCompanies {get; set;}

		public FormWrapper(AMS_Pax_Accreditation_Form__c newForm,
                           List<AMS_Accreditation_Contact__c> previousOwners,
                           List<AMS_Accreditation_Contact__c> previousCompanies,
                           List<AMS_Accreditation_Contact__c> currentOwners,
                           List<AMS_Accreditation_Contact__c> currentCompanies) {

			this.previousOwners = previousOwners;
			this.previousCompanies = previousCompanies;
			this.currentOwners = currentOwners;
			this.currentCompanies = currentCompanies;
		}
	}

	public class Data {
		public JsonValue multiple {get; set;}
		public List<HeadEntity> data {get; set;}

		public Data(List<HeadEntity> data, JsonValue multiple) {
			this.data = data;
			this.multiple = multiple;
		}
	}

	public class HeadEntity {
		public String text {get; set;}
		public String icon {get; set;}
		public JsonValue state {get; set;}
		public List<AssociateEntity> children {get; set;}

		public HeadEntity (String text, String icon, List<AssociateEntity> children, JsonValue state) {
			this.text = text;
			this.icon = icon;
			this.children = children;
			this.state = state;
		}
	}

	public class AssociateEntity {
		public String text {get; set;}
		public String icon {get; set;}
		public JsonValue state {get; set;}

		public AssociateEntity (String text, String icon, JsonValue state) {
			this.text = text;
			this.icon = icon;
			this.state = state;
		}
	}

	public interface JsonValue {

	}

	public class Opened implements JsonValue {
		Boolean opened {get; set;}

		public Opened (Boolean opened) {
			this.opened = opened;
		}
	}

	public class Selected implements JsonValue {
		Boolean selected {get; set;}

		public Selected (Boolean selected) {
			this.selected = selected;
		}
	}

	public class SelectedOpened implements JsonValue {
		Boolean selected {get; set;}
		Boolean opened {get; set;}

		public SelectedOpened (Boolean selected, Boolean opened) {
			this.selected = selected;
			this.opened = opened;
		}
	}

	public class Multiple implements JsonValue {
		Boolean multiple {get; set;}

		public Multiple (Boolean multiple) {
			this.multiple = multiple;
		}
	}

	//
	// ---------------------------------------
	//

	public ISSP_ANG_ANNUAL_REVALIDATION() {

		this.setHe = true;

		accountsMap = new Map<String, Account>();

		String caseId  = ApexPages.currentPage().getParameters().get('caseId');

		if (caseId != null && caseId != '') {
			newCase = fetchCase(caseid);
		}

		if (newCase != null) {
			oscar = fetchOscar(newCase.Oscar__c);

			setFormsMap();

			setIataCodesOkNotOk(oscar);

		}

		getContact();

		setParentsAndChilds();

		setAccounts();

        isStep1 = false;
        isStep2 = false;
        stepNumber = '';

        if (ApexPages.currentPage().getParameters().containsKey('step')) {
            stepNumber = ApexPages.currentPage().getParameters().get('step');
		}

		System.debug('alex stepNumber : ' + stepNumber);

        if (stepNumber == '1' || stepNumber == '')
            isStep1 = true;

        system.debug('stepNumber ' + stepNumber);

        if(stepNumber == '2'){
        	isStep2 = true;
        }

		jsonTree = generateMenu();

	}

	private String generateMenu() {

		//currentAccount = new ANG_AnnualRevRoCurrentAccount();

		String currentIataCode = '';
		JsonValue jsonValue;

		if(currentAccount != null) {
			currentIataCode = currentAccount.account.IataCode__c;
		}


		System.debug('alex parents : ' + parents);
		System.debug('alex childs : ' + childs);

		List<AssociateEntity> children = new List<AssociateEntity>();

		for(Account c : childsAccounts) {
			if(currentIataCode == c.IATACode__c) {
				jsonValue = SELECTED_TRUE;
			} else {
				jsonValue = SELECTED_FALSE;
			}

			children.add(new AssociateEntity(c.IATACode__c, getIcon(c.IATACode__c), jsonValue));
		}

		JSONGenerator gen = JSON.createGenerator(true);

		List<HeadEntity> hier = new List<HeadEntity>();

		if(currentIataCode == '' || (currentIataCode == headEntity.IATACode__c)) {
			jsonValue = SELECTED_OPENED;
		} else {
			jsonValue = OPENED_TRUE;
		}

		HeadEntity he = new HeadEntity(headEntity.IATACode__c, getIcon(headEntity.IATACode__c), children, jsonValue);

System.debug('alex generateMenu');

		if(this.setHe) {
			this.currentAccount = new ANG_AnnualRevRoCurrentAccount(accountsMap.get(headEntity.IATACode__c), getStatus(headEntity.IATACode__c), getForm(headEntity.IATACode__c));
		}

		hier.add(he);

		Data data = new data(hier, MULTIPLE_FALSE);

		gen.writeStartObject();
		gen.writeObjectField('core', data);
		gen.writeEndObject();

		String json = gen.getAsString();

		json = json.replaceAll('\n', '');

		System.debug('alex : ' + json);

		this.setHe = false;

		return json;
	}

	private void setParentsAndChilds() {
		Set<Id> aux = new Set<Id>();

		aux.add(con.accountId);

		Map<Id, List<AMS_Agencies_relationhip__c>> h = AMS_HierarchyHelper.getAccountsHierarchies(aux);

		List<AMS_Agencies_relationhip__c> accountsList = new List<AMS_Agencies_relationhip__c>();

   		for(Id key : h.keySet()) {
			accountsList.addAll(h.get(key));
        }

		parents = new Set<Id>();
		childs = new Set<Id>();

		for(AMS_Agencies_relationhip__c r : accountsList) {
			childs.add(r.Child_Account__c);
		}
		for(AMS_Agencies_relationhip__c r : accountsList) {
			if(!childs.contains(r.Parent_Account__c)) {
				parents.add(r.Parent_Account__c);
			}
		}
	}

	private void setAccounts() {

		this.headEntity = new Account();

		List<Account> al = getAccounts(parents, AMS_Utils.RECTYPE_IATAAGENCY, statusSet, AMS_Utils.HE, Ams_Utils.SECTOR_PASSENGER);

		if(al.size() != 0) {
			this.headEntity = al[0];

			this.accountsMap.put(headEntity.IATACode__c, headEntity);

			this.childsAccounts = getAccounts(childs, AMS_Utils.RECTYPE_IATAAGENCY, statusSet, AMS_Utils.AE, Ams_Utils.SECTOR_PASSENGER);

			for(Account c : childsAccounts) {
				this.accountsMap.put(c.IATACode__c, c);
			}
		} else {
			//
			// Check with Adrian what to do in this case.
			//
		}

	}

	public void setFormsMap() {
		formsMap = new Map<String, FormWrapper>();

        List <AMS_Pax_Accreditation_Form__c> newForms = [
                    SELECT Id, Name, SAAM_Case__c, HO_Account__r.IATACode__c, Submitted_to_IATA__c, CurrencyIsoCode, IATACode__c, ISSP_AMS_Bank_account__c, ISSP_AMS_Date_license_granted__c, ISSP_AMS_Date_Registration_granted__c, ISSP_AMS_GDS_with_signed_contract__c,
                    ISSP_AMS_Gross_Amnt_First_year__c, ISSP_AMS_Gross_Amnt_Second_year__c, ISSP_AMS_IATA_Registered_Cargo_Agent__c, ISSP_AMS_Legal_Reg_Name_Address__c, ISSP_AMS_Legal_Status__c,
                    ISSP_AMS_License_No__c, ISSP_AMS_Min_Paidup_capital__c, ISSP_AMS_Online_Agency_Application__c, ISSP_AMS_Online_Agency_URL__c, ISSP_AMS_Paidup_capital__c, Total_International_Sales__c,
                    ISSP_AMS_Pax_Office_Open_Date__c, ISSP_AMS_Cargo_Office_Open_Date__c, ISSP_AMS_Premises_located_at_airport__c, ISSP_AMS_Previous_default__c, ISSP_AMS_Prev_default_explanation__c, ISSP_AMS_Principal_business_Org__c, Branch_Office_Phone_National__c, Branch_Office_Fax_National__c,
                    ISSP_AMS_Registered_Capital__c, ISSP_AMS_IBAN__c, ISSP_AMS_SWIFT__c, ISSP_AMS_Trade_Reg_No__c, ISSP_AMS_VAT_number__c, ISSP_AM_Means_Identified_Travel_Agency__c, ISSP_AMS_where_incorporated__c,
                    ISSP_AMS_Entity_with_listed_shares__c, ISSP_AMS_when_incorporated__c, ISSP_AMS_Portal_admin__c, ISSP_AMS_Invoicing_Contact__c, Cargo_Agent_Account__c, ISSP_AMS_Total_Ownership__c, Validation_ERRORS__c, IsGSA__c, INVALID_Tax_number__c,
                    International_Sales_in_last_Year__c, Sales_Period_From__c, Sales_Period_To__c, Branch_Office_City__c, Branch_Office_Phone__c, Branch_Office_Street_name_number__c, Branch_Office_Country__c, Branch_Office_Country__r.name, Branch_Office_Email__c,
                    Branch_Office_Fax__c, Branch_Office_Postal_code__c, Wholly_managed_by_this_Head_Office__c, Wholly_owned_by_this_Head_Office__c, AMS_Agency_Id__c, ISSP_Branch_AccountId__c, ISSP_AMS_Date_of_incorporation__c,
                    ISSP_AMS_Date_of_Association__c, ISSP_AMS_Business_Activities__c, ISSP_AMS_Is_Make_Declarations__c, ISSP_AMS_Nominee_Trustee__c, ISSP_AMS_VAT_number_input__c, ISSP_AMS_Number_of_Years_Traded__c, ISSP_AMS_Type_of_License__c,
                    ISSP_AMS_State_Names_Addresses__c, ISSP_AMS_Is_Applicant_Parent__c, ISSP_AMS_For_whom_Nominee__c, ISSP_AMS_Date_legal_establishment__c, Give_full_details__c, List_the_airport_s_to_be_authorized__c, Does_your_firm_intend_to_request__c,
                    Operation_Type__c, Has_your_firm_ever_held_a_Cargo_Agency__c, Date_issued__c, Name_under_which_it_was_issued__c, Reason_for_cancellation__c, Is_your_firm_an_approved_IATA_Passenger__c, IATA_Agents_Numeric_Code__c,
                    Does_the_air_transportation_which_your__c, State_the_percentage_of_your_gross__c, Does_your_firm_sell_air_cargo__c, What_percentage_of_your_sales__c, Is_your_firm_a_General_Sales_Agent_GSA__c, List_carriers__c,
                    Been_found_guilty_of_infringements__c, Been_a_sole_proprietor__c, Been_director_or_had_a_financial__c, Agents_Numeric_Code_of_your_Head_Office__c, Been_involved_in_a_bankruptcy__c, Does_your_firm_now_share_or_intend__c,
                    If_yes_are_you_fully_and_legally__c, Is_there_any_relationship__c, Is_your_firm_acting_as_agent_for_surface__c, Is_your_firm_affiliated_directly__c, Provide_details__c, Rail__c, Steamship__c, Trucking__c,
                    Were_all_IATA_Members_fully_repaid__c, Has_your_form_ever_held_CASS_Assoc_etc__c, CASS_Assoc_Code__c, CASS_Date_issued__c, CASS_Name_under_which_it_was_issued__c, State_full_name_of_such_Agent__c, Is_your_firm_insured_to_cover__c,
                    Explain_fully_stating_name__c, Does_your_firm_operate_a_cargo_cartage__c, CASS_Reason_for_cancellation__c, Does_your_firm_use_its_own_vehicles__c, Is_your_firm_a_member_of_a_national__c, Give_the_name_of_the_association_s__c, IATA_Cargo_Code__c, Type_of_Operation__c,
                    ISSP_AMS_Amount_of_credit_requested__c, ISSP_AMS_Bank_Address_1__c, ISSP_AMS_Bank_Account_Number_1__c, ISSP_AMS_Bank_Address_2__c, ISSP_AMS_Bank_Account_Number_2__c, ISSP_AMS_Bank_Address_3__c, ISSP_AMS_Bank_Account_Number_3__c, Total_Charges_Specialized_Traffic__c, Total_Number_of_Consignments__c,
                    Total_Tons_Special_Traffic__c, Total_Percentage_Specialized_Traffic__c, Total_Freight_Charges_monetary_value__c, Total_Freight_weight_Kgs__c, No_Consignments_Last_Year__c, Total_Projected_Value_Freight__c, Total_Projected_Weight_Kilos__c, Total_Projected_Number_Consignments__c, Specialize_in_particular_traffic_type__c,
                    DG_Number_of_Consignments__c, Live_Animals_No_of_Consignments__c, Other_Number_of_Consignments__c, DG_Tons__c, Live_Animals_Tons__c, Other_Tons__c, DG_Air_Freight_Charges__c, Live_Animals_Air_Freight_Charges__c, Other_Air_Freight_Charges__c, DG_Percentage__c, Live_Animals_Percentage__c, Other_Percentage__c, CGO_Region_Selection__c,
                    CGO_Region_Consignment_Selection__c, CGO_Region_Consignment_Total__c, CGO_Region_Percentage_Selection__c, CGO_Region_Percentage_Total__c, CGO_Region_Tons_Selection__c, CGO_Region_Tons_Total__c, CGO_Region_AirFreight_Total__c, CGO_Region_AirFreight_Selection__c, Total_SOIS_Prepaid_Collected__c, Total_SOIS_Charges_Collected__c, Total_SOIS_Weight__c,
                    Separate_user_access__c, Head_Office_have_access__c, Billing_payment_Head_Office__c, Billing_payment_Branch_Office__c, Billing_payment_Another_Branch__c, Branch_Office_Code__c, Payment_Via_Bank_Transfer__c, Payment_Via_Direct_Debit__c, Local_Legally_Registered_Name__c, Local_Physical_Address_Street__c, Local_Physical_Address_City__c, Local_Physical_Address_Postal_Code__c,
                    Local_Physical_Address_Province__c, Local_Physical_Address_Area__c, Local_Postal_Address_Street__c, Local_Postal_Address_City__c, Local_Postal_Address_Postal_Code__c, Local_Postal_Address_Province__c, Local_Postal_Address_Area__c, Local_Agent_Type__c, Accept_terms_and_conditions__c, Type_of_Cargo_Agent__c, Est_Future_Sales__c, Registered_to_hot_files__c, Agent_Type__c,
                    Is_change_bank_account_details__c, Is_change_legal_name__c, Is_change_location__c, Is_change_ownership_or_shareholding__c, State_Province__c, Mobile__c, MobileNational__c, Local_Physical_Address_Country__c, Local_Address_Country__c, Is_this_Branch_becoming_a_Head_Office__c, Is_this_Head_Office_becoming_a_Branch__c, Please_provide_details_for_the_change__c, Provide_details_for_change_affect_staff__c,
                    Provide_explanation_for_change_locations__c, Will_such_change_affect_locations__c, Will_such_change_affect_the_managers__c, Will_such_change_affect_the_premises__c, Will_the_change_of_ownership_cause__c, Effective_Date_Of_Change__c, Give_details_for_authorization_to_act__c, Give_details_for_the_change_of_ownership__c, Have_any_having_authorization_to_act__c, Issued_share_capital__c,
                    Specify_Legal_Status_After_Change__c, Issued_share_capital_After_Change__c, Trade_Name__c, ISSP_AMS_Curr_Entity_with_listed_shares__c, ISSP_AMS_Total_Current_Ownership__c, ISSP_AMS_Total_Previous_Ownership__c, Is_your_firm_handling_Dangerous_Goods__c, Country__c, Account_Name__c,Scope_of_Change__c,Agency_Codes_Concerned__c,Billing_State__c,Website__c,
                    Confirm_Legal_Details_are_correct__c,Notify_Change_Legal_Details__c,Confirm_Location_Details_are_correct__c,Notify_Change_Location__c,Confirm_Ownership_details_are_correct__c,Notify_Change_Ownership__c,Map_Company_Type_to_Legal_Status__c,New_Head_Office_IATA_Code__c,Shipping_Street__c,Shipping_City__c,Shipping_Postal_Code__c,Shipping_State__c,HO_Account__c,RecordTypeId,
                    IATAN_Code__c,IATA_Registered_IATAN_Agent__c,Enable_Credit_Card_FOP__c,IATAN_Agent_Account__c,AE_separate_Legal_Entity__c,ANG_AE_SameLegal__c,ANG_Accreditation_Model_to_Change__c, Notify_Change_Accreditation_Type__c, Confirm_accreditation_type_are_correct__c, Last_Scope_Of_Change__c, ANG_Accreditation_type__c,
                    SAAM_Case__r.Reason1__c, Status__c
                    FROM AMS_Pax_Accreditation_Form__c
                    WHERE SAAM_Case__c = :newCase.Id
                ];

        if (newForms.size() > 0) {

			Set<Id> formsIds = new Set<Id>();
			for (AMS_Pax_Accreditation_Form__c form : newForms) {
				formsIds.add(form.id);
			}

			List<AMS_Accreditation_Contact__c> auxPreviousOwners = getPreviousOwners(formsIds);
			List<AMS_Accreditation_Contact__c> auxCurrentOwners = getCurrentOwners(formsIds);
			List<AMS_Accreditation_Contact__c> auxCurrentCompanies = getCurrentCompanies(formsIds);
			List<AMS_Accreditation_Contact__c> auxPreviousCompanies = getPreviousCompanies(formsIds);


    getFormPreviousOwners(newForm.id, auxPreviousOwners), getFormCurrentOwners(newForm.id, auxCurrentOwners), getFormCurrentCompanies(newForm.id, auxCurrentCompanies), getFormPreviousCompanies(newForm.id, auxPreviousCompanies) {


			for (AMS_Pax_Accreditation_Form__c newForm : newForms) {
				formsMap.put(form.IATACode__c, new FormWrapper(newForm, getFormPreviousOwners(newForm.id, auxPreviousOwners),
                                                                        getFormCurrentOwners(newForm.id, auxCurrentOwners),
																		getFormCurrentCompanies(newForm.id, auxCurrentCompanies),
																		getFormPreviousCompanies(newForm.id, auxPreviousCompanies));
			}
        }
	}

	public PageReference loadIataCode() {
		System.debug('alex loadIataCode : ' + currentIataCode);

		this.currentAccount = new ANG_AnnualRevRoCurrentAccount(accountsMap.get(currentIataCode), getStatus(currentIataCode), getForm(currentIataCode));

		return null;
	}

	public PageReference confirmDetails() {
		System.debug('alex confirmDetails : ' + currentIataCode);

		System.debug('alex before this.oscar.IATA_Codes_OK__c : ' + this.oscar.IATA_Codes_OK__c);

		if(this.oscar.IATA_Codes_OK__c == null || this.oscar.IATA_Codes_OK__c == '') {
			this.oscar.IATA_Codes_OK__c = currentIataCode;
		} else {
			this.oscar.IATA_Codes_OK__c += ',' + currentIataCode;
		}

		System.debug('alex this.oscar.IATA_Codes_OK__c : ' + this.oscar.IATA_Codes_OK__c);

		try{
			update oscar;

			iataCodesOk.add(currentIataCode);

			jsonTree = generateMenu();

		} catch(DmlException de) {
			// All stays the same.
		}

		return null;
	}

	public PageReference discardDetails() {
		System.debug('alex confirmDetails : ' + currentIataCode);

		System.debug('alex before this.oscar.IATA_Codes_OK__c : ' + this.oscar.IATA_Codes_OK__c);

		this.oscar.IATA_Codes_OK__c = this.oscar.IATA_Codes_OK__c.replaceAll(',' + currentIataCode + ',', '');
		this.oscar.IATA_Codes_OK__c = this.oscar.IATA_Codes_OK__c.replaceAll(currentIataCode + ',', '');
		this.oscar.IATA_Codes_OK__c = this.oscar.IATA_Codes_OK__c.replaceAll(',' + currentIataCode, '');
		this.oscar.IATA_Codes_OK__c = this.oscar.IATA_Codes_OK__c.replaceAll(currentIataCode, '');

		System.debug('alex this.oscar.IATA_Codes_OK__c : ' + this.oscar.IATA_Codes_OK__c);

		try{
			update oscar;

			iataCodesOk.remove(currentIataCode);

			jsonTree = generateMenu();

		} catch(DmlException de) {
			// All stays the same.
		}

		return null;
	}

	public PageReference updateDetails() {
		System.debug('alex updateDetails : ' + currentIataCode);

		return null;
	}

    public PageReference goToStep1() {

		System.debug('alex goto step 1');

        return new PageReference('/ISSP_ANG_ANNUAL_REVALIDATION?caseId=' + newCase.Id + '&step=1' + commParam);
    }

    public PageReference goToStep2() {

		System.debug('alex goto step 2');

		this.isStep1 = false;
		this.isStep2 = true;
        return new PageReference('/ISSP_ANG_ANNUAL_REVALIDATION?caseId=' + newCase.Id + '&step=2' + commParam);
    }

	public PageReference save() {

		System.debug('alex save');

		return goToStep2();
	}

    public PageReference submitForm(){


    	return null;
    }

    public Pagereference saveDraft(){
    	//save();
    	return new Pagereference('/ISSP_Homepage');
    }

    /**
		Cancel METHOD
    **/
    public PageReference cancel(){

        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        if (retURL == null) {
            return new Pagereference('/ISSP_Homepage?mid=M0S1' +commParam);
        } else {
            return new Pagereference(retURL);
        }
    }

	public void getContact(){
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        con = DAL_ISSP.getContact(user.ContactId);
    }

	private void setIataCodesOkNotOk(AMS_OSCAR__c oscar) {

		iataCodesOk = new Set<String>();
		iataCodesConfirmed = new Set<String>();
		iataCodesInProgress = new Set<String>();

		if(oscar.IATA_Codes_OK__c == null) oscar.IATA_Codes_OK__c = '';

		String[] aux = oscar.IATA_Codes_OK__c.split(',');

		for (String iataCode : aux) {
			iataCodesOk.add(iataCode);
		}

		for(String iataCode : formsMap.keySet()) {
			AMS_Pax_Accreditation_Form__c form = formsMap.get(iataCode);

			if(form.status__c == 'InProgress') {
				iataCodesInProgress.add(iataCode);
			}
			if(form.status__c == 'Confirmed') {
				iataCodesConfirmed.add(iataCode);
			}
		}
	}

	private static List<Account> getAccounts(Set<Id> accountIds, String recordType, Set<String> statusSet, String locationType, String sector) {
		return [Select Id, Name, TradeName__c, IATACode__c, ANG_Accreditation_Model__c,
					   BillingStreet, BillingCity, BillingState, BillingCountry, Email__c,
					   Website, Phone, Mobile__c, FAX, BillingPostalCode, Company_Type__c
				  From Account
				 Where Id in :accountIds
				   And RecordTypeId = :recordType
				   And Status__c in :statusSet
				   And Location_Type__c = :locationType
				   And Sector__c = :sector];
	}

	private String getIcon(String iataCode) {
		if (iataCodesOk.contains(iataCode)) {
			return OK_ICON;
		} else if (iataCodesConfirmed.contains(iataCode)) {
			return CONFIRMED_ICON;
		} else if (iataCodesInProgress.contains(iataCode)) {
			return PROGRESS_ICON;
		} else {
			return DEFAULT_ICON;
		}
	}

	private String getStatus(String iataCode) {
		if (iataCodesOk.contains(iataCode)) {
			return COMPLETED_STATUS;
		} else if (iataCodesConfirmed.contains(iataCode)) {
			return UPDATE_COMPLETED_STATUS;
		} else if (iataCodesInProgress.contains(iataCode)) {
			return UPDATE_PROGRESS_STATUS;
		} else {
			return OPEN_STATUS;
		}
	}

    private static Case fetchCase(String caseId) {
        List <Case> newCases = [Select Id, CaseNumber, Reason1__c, CaseArea__c, Status, BSPCountry__c, Country_concerned_by_the_query__c, Oscar__c,
								   	   Contact.Name, Account.Id, Description, Subject, Account_Concerned__c, Account_Concerned__r.Top_Parent__c, Account.Name,
                                   	   Account.Billing_Address_formated__c, Verification__c, IFAP_Country_ISO__c, Case_Language__c, Region__c, Applicable_to_Which_Version_s__c
                                  From Case
                                 Where Id = :caseId];

        if (newCases.size() > 0) return newCases[0];

		return null;
    }

	private static AMS_OSCAR__c fetchOscar(Id oscarId) {
		List<AMS_OSCAR__c> auxOscars = [Select Id, IATA_Codes_NOK__c, IATA_Codes_OK__c From AMS_OSCAR__c Where Id = :oscarId];

		if (auxOscars.size() > 0) return auxOscars[0];

		return null;
	}

	private AMS_Pax_Accreditation_Form__c getForm(String iataCode) {

		System.debug('alex getForm');

		if(formsMap.containsKey(iataCode)) {
			return formsMap.get(iataCode);
		} else {
			AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();

			account a = accountsMap.get(iataCode);

			newForm.HO_Account__c = a.id;

			newForm.ISSP_AMS_Legal_Status__c = ISSP_AMS_Accreditation.mapCompanyTypes(a.Company_Type__c);

			setOwners();

			System.debug('alex newForm : ' + newForm);

			return newForm;
		}
	}

    private static List<AMS_Accreditation_Contact__c> getPreviousOwners(Set<Id> newFormIds) {
		return [Select AMS_Pax_Accreditation_Form__c, Name, First_name__c, Last_name__c, Salutation__c, Agency_owner__c, Agency_role__c, Email__c,Phone__c,
                       Financial_interest__c, Contact_Id__c, Contact__c, AMS_OwnershipId__c, AMS_ContactId__c, Local_First_name__c, Local_Last_name__c, Number_Of_Shares__c,
                       AddressStreet__c, AddressCity__c, AddressCountry__c, AddressPostcode__c, Time_devoted_to_Agency_business__c
                  From AMS_Accreditation_Contact__c
                 Where AMS_Pax_Accreditation_Form__c in :newFormIds
				   And RecordType.DeveloperName = 'Previous_Owner'
                 Order By Name ASC];
    }

	private static List<AMS_Accreditation_Contact__c> getCurrentOwners(Set<Id> newFormIds) {
		return [Select Name, First_name__c, Last_name__c, Salutation__c, Agency_owner__c, Agency_role__c, Email__c,Phone__c,
                       Financial_interest__c, Contact_Id__c, AMS_OwnershipId__c, AMS_ContactId__c, Local_First_name__c, Local_Last_name__c, Number_Of_Shares__c,
                       AddressStreet__c, AddressCity__c, AddressCountry__c, AddressPostcode__c, Time_devoted_to_Agency_business__c
                  From AMS_Accreditation_Contact__c
                 Where AMS_Pax_Accreditation_Form__c in :newFormIds
				   And RecordType.DeveloperName = 'Current_Owner'
                 Order By Name ASC];
    }

	private static List<AMS_Accreditation_Contact__c> getCurrentCompanies(Set<Id> newFormIds) {
		return [Select AMS_Pax_Accreditation_Form__c, Name, Financial_interest__c, Registration_number__c, IATAcode__c
                  From AMS_Accreditation_Contact__c
                 Where AMS_Pax_Accreditation_Form__c in :newFormIds
				   And RecordType.DeveloperName = 'Current_Company_Owner'
                 Order By Name ASC];
    }

	private static List<AMS_Accreditation_Contact__c> getPreviousCompanies(Set<Id> newFormIds) {
		return [Select AMS_Pax_Accreditation_Form__c, Name, Financial_interest__c, Registration_number__c, IATAcode__c
                  From AMS_Accreditation_Contact__c
                 WHERE AMS_Pax_Accreditation_Form__c in :newFormIds
				   And RecordType.DeveloperName = 'Previous_Company_Owner'
                 Order By Name ASC];
    }

    private static List<AMS_Accreditation_Contact__c> getFormPreviousOwners(Id formId, List<AMS_Accreditation_Contact__c> previousOwners) {
		List<AMS_Accreditation_Contact__c> aux = new List<AMS_Accreditation_Contact__c>();
		for(AMS_Accreditation_Contact__c ac : previousOwners) {
			if(ac.AMS_Pax_Accreditation_Form__c == formId) {
				aux.add(ac);
			}
		}
		return aux;
    }

	private static List<AMS_Accreditation_Contact__c> getFormCurrentOwners(Id formId, List<AMS_Accreditation_Contact__c> currentOwners) {
		List<AMS_Accreditation_Contact__c> aux = new List<AMS_Accreditation_Contact__c>();
		for(AMS_Accreditation_Contact__c ac : currentOwners) {
			if(ac.AMS_Pax_Accreditation_Form__c == formId) {
				aux.add(ac);
			}
		}
		return aux;
    }

	private static List<AMS_Accreditation_Contact__c> getFormCurrentCompanies(Id formId, List<AMS_Accreditation_Contact__c> currentCompanies) {
		List<AMS_Accreditation_Contact__c> aux = new List<AMS_Accreditation_Contact__c>();
		for(AMS_Accreditation_Contact__c ac : currentCompanies) {
			if(ac.AMS_Pax_Accreditation_Form__c == formId) {
				aux.add(ac);
			}
		}
		return aux;
    }

	private static List<AMS_Accreditation_Contact__c> getFormPreviousCompanies(Id formId, List<AMS_Accreditation_Contact__c> previousCompanies) {
		List<AMS_Accreditation_Contact__c> aux = new List<AMS_Accreditation_Contact__c>();
		for(AMS_Accreditation_Contact__c ac : previousCompanies) {
			if(ac.AMS_Pax_Accreditation_Form__c == formId) {
				aux.add(ac);
			}
		}
		return aux;
    }

	public String getDEFAULT_ICON() {
		return DEFAULT_ICON;
	}
	public String getOK_ICON() {
		return OK_ICON;
	}
	public String getCONFIRMED_ICON() {
		return CONFIRMED_ICON;
	}
	public String getPROGRESS_ICON() {
		return PROGRESS_ICON;
	}
}