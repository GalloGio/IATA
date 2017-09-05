public with sharing class ISSP_ANG_RHC {

	public String accreditationType {get; set;}
	public String riskStatus {get; set;}
	public ANG_ISSP_AfpWrapper afpWrapper {get; set;}
	public Contact contact {get;set;}
	private static final String ICE_SERVICE = ISSP_Portal_Service_Ids__c.getInstance().ICE_E_Statements__c;
	public ANG_RHC_Information__c remittanceFrequency {get;set;}
	public Boolean hasRightAccessIceService { get {
		if (hasRightAccessIceService != null) {
			return hasRightAccessIceService;
		} else {
			hasRightAccessIceService = hasRightAccess(ICE_SERVICE);
			return hasRightAccessIceService;
		} 
	} set;}

	public ISSP_ANG_RHC() {
		init();
		initFormsOfPayment();
		initializeRemittanceFrequency();
		initRiskProfile();
	}

	private Boolean hasRightAccess(String service) {
		if (this.contact != null) {
			List <Portal_Application_Right__c> appRightList = [
				SELECT Id 
				  FROM Portal_Application_Right__c
			     WHERE Contact__c = :this.contact.Id
				   AND Right__c = :AMS_Utils.PORTAL_APP_ACCESS_GRANTED
				   AND Portal_Application__c = :service
			];
			return !appRightList.isEmpty();
		}
		return false;
	}

	private void init() {
		List<User> userList = [SELECT Id, ContactId FROM User WHERE Id = :Userinfo.getUserId()];
		Id contactId = userList.isEmpty() ? null : userList[0].ContactId;
		List<Contact> contactList = [SELECT Id,
											Authorized_Signatory__c,
											Account.Id,
											Account.Remittance_frequency__c,
											Account.ANG_IEP_Status_FF__c,
											Account.ANG_Accreditation_Model__c,
											Account.Location_Type__c,
											Account.Top_Parent__r.Location_Type__c,
											Account.ANG_RiskStatus__c,
											Account.ANG_CashCondition__c
									   FROM Contact
									  WHERE Id = :contactId];		
		this.contact = contactList.isEmpty() ? null : contactList[0];									  
	}	

	private void initFormsOfPayment() {		
		List<Agency_Authorization__c> authorizations;
		List<Portal_Application_Right__c> services;

		if(this.contact != null) {		
			authorizations = [Select Id,
									 ANG_FormOfPayment_ID__c
							    From Agency_Authorization__c
							   Where Account__c =: this.contact.Account.Id
							     And Status__c = 'Active'];

			services = [Select Id,
							   Application_Name__c,
							   Right__c,
							   Application_Start_URL__c
						  From Portal_Application_Right__c
						 Where Contact__c =: this.contact.id];
		}

		this.afpWrapper = new ANG_ISSP_AfpWrapper(this.contact, authorizations, services);
	}

	private void initializeRemittanceFrequency() {
		List<ANG_RHC_Information__c> remittanceFrequencyList = [
			SELECT Id, 
				   ANG_RHC_Amount__c, 
				   ANG_ConsumedRHC__c, 
				   ANG_ConsumedRHC_Percent__c, 
				   ANG_ConsumedRHC_Last_Update__c, 
				   ANG_Financial_Security__c
			  FROM ANG_RHC_Information__c
			 WHERE ANG_AccountId__c = :this.contact.Account.Id
		];
		this.remittanceFrequency = remittanceFrequencyList.isEmpty() ? null : remittanceFrequencyList[0];
	}

	private void initRiskProfile() {

		this.accreditationType = this.Contact.Account.ANG_Accreditation_Model__c;
		this.riskStatus = this.Contact.Account.ANG_RiskStatus__c;

	}	
}