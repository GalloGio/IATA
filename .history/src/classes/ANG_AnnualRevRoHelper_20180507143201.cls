public with sharing class ANG_AnnualRevRoHelper {
	public ANG_AnnualRevRoCurrentAccount ca {get; set;}
	public AMS_Pax_Accreditation_Form__c newForm {
		get {return this.ca.fw.newForm;}
		set;
	}
	public Account currentAccount {
		get {return this.ca.account;}
		set;
	}
	public List<AMS_Accreditation_Contact__c> previousOwners {
		get {return this.ca.fw.previousOwners;}
		set;
	}
	public List<AMS_Accreditation_Contact__c> currentOwners {
		get {return this.ca.fw.currentOwners;}
		set;
	}
	public List<AMS_Accreditation_Contact__c> previousCompanies {
		get {return this.ca.fw.previousCompanies;}
		set;
	}
	public List<AMS_Accreditation_Contact__c> currentCompanies {
		get {return this.ca.fw.currentCompanies;}
		set;
	}
	public String roleLabel {get; set;}
	public String ownerLabel {get; set;}



	// CONSTRUCTOR
	public ANG_AnnualRevRoHelper(ANG_AnnualRevRoCurrentAccount ca) {
		this.ca = ca;

		System.debug('alex inside helper current account : ' + ca.account.iata_code__c);

        roleLabel = Label.ISSP_AMS_Director;

		System.debug('alex this.ca.fw.newForm : ' + this.ca.fw.newForm);

        if (this.ca.fw.newForm.ISSP_AMS_Legal_Status__c == 'association'
			|| this.ca.fw.newForm.ISSP_AMS_Legal_Status__c == 'corporation'
			|| this.ca.fw.newForm.ISSP_AMS_Legal_Status__c == 'limited company'
			|| this.ca.fw.newForm.ISSP_AMS_Legal_Status__c == 'trust company') {

            ownerLabel = Label.ISSP_AMS_Shareholder;

        } else if (this.ca.fw.newForm.ISSP_AMS_Legal_Status__c == 'co-operative'
				   || this.ca.fw.newForm.ISSP_AMS_Legal_Status__c == 'joint venture'
				   || this.ca.fw.newForm.ISSP_AMS_Legal_Status__c == 'limited partnership'
				   || this.ca.fw.newForm.ISSP_AMS_Legal_Status__c == 'partnership') {

            ownerLabel = Label.ISSP_AMS_Partner;

        } else {
            ownerLabel = Label.ISSP_AMS_Owner;
			roleLabel = Label.ISSP_AMS_Manager;
        }
	}


}