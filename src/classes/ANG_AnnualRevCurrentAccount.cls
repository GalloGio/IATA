public with sharing class ANG_AnnualRevCurrentAccount {
	public Account account {get; set;} // current account
	public ANG_AnnualRevFormWrapper fw {get; set;} // Contains the form and the owners lists
	public IATA_ISO_Country__c isocountry {get; set;}
	public String status {get; set;} // C  - Confirmed
									 // UP - Update in progress
									 // UC - Update confirmed
									 // O  - Open
	public String roleLabel {get; set;}
	public String ownerLabel {get; set;}
	public String ownerLabelType {get; set;}
	public String roleLabelType {get; set;}
	public String roleLabelTypeAfterChange {get; set;}
	public String ownerLabelTypeAfterChange {get; set;}
	public String roleLabelAfterChange {get; set;}
	public String ownerLabelAfterChange {get; set;}
	public boolean isHOcontact {get; set;}
	public Boolean errorFoundCheckBoxes {get; set;}
	public Boolean errorFound {get; set;}
	public Boolean isReadonly {get; set;}
	public AMS_Accreditation_Contact__c newContact {get; set;}

	public String statusDesc {
		get{
			if(this.status == 'C') {
				return Label.ISSP_ANG_ANNUAL_STATUS_CONFIRMED;
			} else if(this.status == 'UP') {
				return Label.ISSP_ANG_ANNUAL_STATUS_UPDATE_PROGRESS;
			} else if(this.status == 'UC') {
				return Label.ISSP_ANG_ANNUAL_STATUS_UPDATE_COMPLETED;
			} else {
				return Label.ISSP_ANG_ANNUAL_STATUS_OPEN;
			}
		}
		set;
	}

	public ANG_AnnualRevCurrentAccount(Account account, String status, ANG_AnnualRevFormWrapper fw, IATA_ISO_Country__c isocountry, Boolean isHOcontact) {
		this.account = account;
		this.status = status;
		this.fw = fw;
		this.isocountry = isocountry;
		this.isHOcontact = isHOcontact;
		this.errorFoundCheckBoxes = false;
		this.errorFound = false;
		this.newContact = new AMS_Accreditation_Contact__c();
		this.isReadonly = (this.status == 'UC');

		setOwnerAndRoleLabels();
	}

    private void setOwnerAndRoleLabels() {
        if (this.fw.newForm.ISSP_AMS_Legal_Status__c != null) {
            setPageLegalStatusLabels();
			setPageLegalStatusAfterChangeLabels();
        } else {
            roleLabelType = 'manager';
            ownerLabelType = 'owner';
            ownerLabel = Label.ISSP_AMS_Owner;
            roleLabel = Label.ISSP_AMS_Manager;
            roleLabelTypeAfterChange = 'manager';
            ownerLabelTypeAfterChange = 'owner';
            ownerLabelAfterChange = Label.ISSP_AMS_Owner;
            roleLabelAfterChange = Label.ISSP_AMS_Manager;
        }
    }

	private void setPageLegalStatusLabels() {
        roleLabel = Label.ISSP_AMS_Director;
		roleLabelType = 'director';
		String legalstatus = this.fw.newForm.ISSP_AMS_Legal_Status__c.toLowerCase();

        if (legalstatus == 'association'
			|| legalstatus == 'corporation'
			|| legalstatus == 'limited company'
			|| legalstatus == 'trust company') {

			ownerLabelType = 'shareholder';
            ownerLabel = Label.ISSP_AMS_Shareholder;

        } else if (legalstatus == 'co-operative'
				   || legalstatus == 'joint venture'
				   || legalstatus == 'limited partnership'
				   || legalstatus == 'partnership') {

			ownerLabelType = 'partner';
            ownerLabel = Label.ISSP_AMS_Partner;

        } else {
			roleLabelType = 'manager';
			ownerLabelType = 'owner';
            ownerLabel = Label.ISSP_AMS_Owner;
			roleLabel = Label.ISSP_AMS_Manager;
        }
	}

	private void setPageLegalStatusAfterChangeLabels() {
		String legalStatusAfterChange = this.fw.newForm.ISSP_AMS_Legal_Status__c.toLowerCase();

        roleLabelTypeAfterChange = 'director';
        roleLabelAfterChange = Label.ISSP_AMS_Director;
        if (legalStatusAfterChange == 'association'
			|| legalStatusAfterChange == 'corporation'
			|| legalStatusAfterChange == 'limited company'
			|| legalStatusAfterChange == 'trust company') {

            ownerLabelTypeAfterChange = 'shareholder';
            ownerLabelAfterChange = Label.ISSP_AMS_Shareholder;
        } else if (legalStatusAfterChange == 'co-operative'
		           || legalStatusAfterChange == 'joint venture'
				   || legalStatusAfterChange == 'limited partnership'
				   || legalStatusAfterChange == 'partnership') {

            ownerLabelTypeAfterChange = 'partner';
            ownerLabelAfterChange = Label.ISSP_AMS_Partner;
        } else {
            roleLabelTypeAfterChange = 'manager';
            ownerLabelTypeAfterChange = 'owner';
            ownerLabelAfterChange = Label.ISSP_AMS_Owner;
            roleLabelAfterChange = Label.ISSP_AMS_Manager;
        }
    }
}