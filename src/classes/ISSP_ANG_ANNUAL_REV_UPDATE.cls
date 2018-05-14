public with sharing class ISSP_ANG_ANNUAL_REV_UPDATE {
	public ANG_AnnualRevCurrentAccount ca {get; set;}
	public ISSP_AMS_Accreditation ctrl {get; set;}
	public string editContactId {get; set;}

	public ISSP_ANG_ANNUAL_REV_UPDATE() {
		ctrl = new ISSP_AMS_Accreditation();
		//if(ca.fw.newForm != null)
		//	ctrl.newForm = ca.fw.newForm;
		//ctrl.iatacode = ca.account.iataCode__c;
	}

	public void createAgencyContact() {
		ctrl.createAgencyContact();
	}

	public void editAgencyContact() {
		ctrl.editContactId = editContactId;
		ctrl.editAgencyContact();
	}

    public void cancelAgentUpdate() {
        //Need to clear pointer to newContact on cancel of update; to avoid replacing contact on adding New Person
        ctrl.newContact = new AMS_Accreditation_Contact__c();
        ctrl.iatacode = '';
        ctrl.contactSaved = false;
    }
}