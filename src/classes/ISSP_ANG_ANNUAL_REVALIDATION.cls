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
	public Set<String> iataCodesNotOk {get; set;}
	public Map<String, AnnualRevalidation> annualRevalidationsMap {get; set;}

	public String tree {get {
		return generateMenu();
	} set;}

	public static String DEFAULT_ICON = 'glyphicon glyphicon-refresh text-primary';
	public static String OK_ICON = 'glyphicon glyphicon-ok text-success';
	public static String CONFIRMED_ICON = 'glyphicon glyphicon-flag text-danger';
	public static String PROGRESS_ICON = 'glyphicon glyphicon-edit text-danger';

	public static JsonValue SELECTED_FALSE = new Selected(false);
	public static JsonValue SELECTED_TRUE = new Selected(true);
	public static JsonValue OPENED_TRUE = new Opened(true);
	public static JsonValue MULTIPLE_FALSE = new Multiple(false);

	public static Set<String> statusSet = new Set<String> {
		Ams_Utils.ACC_S9_APPROVED,
		Ams_Utils.ACC_S8_CHANGESPROCESSED,
		Ams_Utils.ACC_S0_TERMINATED,
		Ams_Utils.ACC_S5_CASHNOCOMMISSION,
		Ams_Utils.ACC_S6_CASHWITHCOMMISSION
    };

	public String caseId {get; set;}

	public ISSP_ANG_ANNUAL_REVALIDATION() {

		Id caseId  = ApexPages.currentPage().getParameters().get('caseId');

		if (caseId != null && caseId != '') {
			newCase = fetchCase(caseid);
		}

		if (newCase != null) {
			oscar = fetchOscar(newCase.Oscar__c);
			setIataCodesOkNotOk(oscar);
		}

		getContact();

		annualRevalidationsMap = new Map<String, AnnualRevalidation>();

        isStep1 = false;
        isStep2 = false;
        stepNumber = '';

        if (ApexPages.currentPage().getParameters().containsKey('step'))
            stepNumber = ApexPages.currentPage().getParameters().get('step');


		System.debug('alex stepNumber : ' + stepNumber);

        if (stepNumber == '1' || stepNumber == '')
            isStep1 = true;

        system.debug('stepNumber ' + stepNumber);

        if(stepNumber == '2'){
        	isStep2 = true;
        }

	}

	private String generateMenu() {

		Set<Id> aux = new Set<Id>();

		aux.add(con.accountId);

		Map<Id, List<AMS_Agencies_relationhip__c>> h = AMS_HierarchyHelper.getAccountsHierarchies(aux);

		List<AMS_Agencies_relationhip__c> accountsList = new List<AMS_Agencies_relationhip__c>();

   		for(Id key : h.keySet()) {
			accountsList.addAll(h.get(key));
        }

		Set<Id> parents = new Set<Id>();
		Set<Id> childs = new Set<Id>();

		for(AMS_Agencies_relationhip__c r : accountsList) {
			childs.add(r.Child_Account__c);
		}
		for(AMS_Agencies_relationhip__c r : accountsList) {
			if(!childs.contains(r.Parent_Account__c)) {
				parents.add(r.Parent_Account__c);
			}
		}

		System.debug('alex parents : ' + parents);
		System.debug('alex childs : ' + childs);

		List<Account> al = [Select Id,
								   IATACode__c
							  From Account
							 Where Id in :parents
							   And RecordTypeId = :AMS_Utils.RECTYPE_IATAAGENCY
							   And Status__c in :statusSet
							   And Location_Type__c = :AMS_Utils.HE
							   And Sector__c = :Ams_Utils.SECTOR_PASSENGER];

		if(al.size() != 0) {
			Account headEntity = al[0];

			List<Account> childsAccounts = [Select Id,
								   				   IATACode__c
							  				  From Account
							 				 Where Id in :childs
							   				   And RecordTypeId = :AMS_Utils.RECTYPE_IATAAGENCY
							   				   And Status__c in :statusSet
							   				   And Location_Type__c = :AMS_Utils.AE
							   				   And Sector__c = :Ams_Utils.SECTOR_PASSENGER];


			List<AssociateEntity> children = new List<AssociateEntity>();

			for(Account c : childsAccounts) {
				children.add(new AssociateEntity(c.IATACode__c, DEFAULT_ICON, SELECTED_FALSE));
			}

			JSONGenerator gen = JSON.createGenerator(true);

			List<HeadEntity> hier = new List<HeadEntity>();

			HeadEntity he = new HeadEntity(headEntity.IATACode__c, DEFAULT_ICON, children, OPENED_TRUE);

			hier.add(he);

			Data data = new data(hier, MULTIPLE_FALSE);

			gen.writeStartObject();
			gen.writeObjectField('core', data);
			gen.writeEndObject();

			String json = gen.getAsString();

			json = json.replaceAll('\n', '');

			System.debug('alex : ' + json);

			return json;

		} else {
			//
			// Check with Adrian what to do in this case.
			//
		}

		return '{}';
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

	public class Multiple implements JsonValue {
		Boolean multiple {get; set;}

		public Multiple (Boolean multiple) {
			this.multiple = multiple;
		}
	}

    public PageReference goToStep1() {

		System.debug('alex goto step 1');



		/*
		system.debug('agencyCodesConcerned ' + newForm.Scope_of_Change__c);
		if(newForm.Scope_of_Change__c == 'HO - All Branches'){
			newForm.Agency_Codes_Concerned__c = null;
			agencyCodesConcerned.clear();
			update newform;
		}
		*/
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

	public class AnnualRevalidation {
		public String status {get; set;}
		public String iataCode {get; set;}
		public AMS_Pax_Accreditation_Form__c newForm {get; set;}

		public AnnualRevalidation(String status, AMS_Pax_Accreditation_Form__c newForm) {
			this.status = status;
			this.newForm = newForm;
		}
	}

	public void setIataCodesOkNotOk(AMS_OSCAR__c oscar) {

		iataCodesOk = new Set<String>();
		iataCodesNotOk = new Set<String>();

		String[] aux = oscar.IATA_Codes_OK__c.split(',');

		for (String iataCode : aux) {
			iataCodesOk.add(iataCode);
		}

		aux = oscar.IATA_Codes_NOK__c.split(',');

		for (String iataCode : aux) {
			iataCodesNotOk.add(iataCode);
		}
	}

    public static Case fetchCase(String caseId) {
        List <Case> newCases = [Select Id, CaseNumber, Reason1__c, CaseArea__c, Status, BSPCountry__c, Country_concerned_by_the_query__c, Oscar__c,
								   	   Contact.Name, Account.Id, Description, Subject, Account_Concerned__c, Account_Concerned__r.Top_Parent__c, Account.Name,
                                   	   Account.Billing_Address_formated__c, Verification__c, IFAP_Country_ISO__c, Case_Language__c, Region__c, Applicable_to_Which_Version_s__c
                                  From Case
                                 Where Id = :caseId];

        if (newCases.size() > 0) return newCases[0];

		return null;
    }

	public static AMS_OSCAR__c fetchOscar(Id oscarId) {
		List<AMS_OSCAR__c> auxOscars = [Select Id, IATA_Codes_NOK__c, IATA_Codes_OK__c From AMS_OSCAR__c Where Id = :oscarId];

		if (auxOscars.size() > 0) return auxOscars[0];

		return null;
	}
}