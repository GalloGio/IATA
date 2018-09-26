public with sharing class ISSP_ANG_RHC {

	public String accreditationType {get; set;}
	public String riskStatus {get; set;}
	public String cashConditions {get; set;}
	public String financialReviewResult {get; set;}	
	public String riskHistoryAssessment {get; set;}	
	public String riskEventStatus {get; set;}
	public List<RiskEvent> riskEventsList;
	public String riskStatusFilter {get; set;}
	public ANG_ISSP_AfpWrapper afpWrapper {get; set;}
	public Boolean isAll {get; set;}
	public Contact contact {get;set;}
	public Id accountIdTP {get; set;}
	public Id accountId {get; set;}
	public Boolean isCashless {get; set;}
	public ANG_ProductComparisonHelper helper {get; set;}
	@TestVisible private static final String ICE_SERVICE = ISSP_Portal_Service_Ids__c.getInstance().ICE_E_Statements__c;
	public ANG_RHC_Information__c rhcInfo {get;set;}
	public Boolean hasRightAccessIceService { get {
		if (hasRightAccessIceService != null) {
			return hasRightAccessIceService;
		} else {
			hasRightAccessIceService = hasRightAccess(ICE_SERVICE);
			return hasRightAccessIceService;
		} 
	} set;}

	public ISSP_ANG_RHC() {
		this.riskStatusFilter = 'Active';
		init();
		initFormsOfPayment();
		initializeRHCInfo();
		initRiskProfile();
		this.helper = new ANG_ProductComparisonHelper('B');
	}

	@TestVisible private Boolean hasRightAccess(String service) {
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
											Account.Top_Parent__c,
											toLabel(Account.Remittance_frequency__c),
											Account.ANG_IEP_Status_FF__c,
											Account.ANG_Accreditation_Model__c,
											Account.Location_Type__c,
											Account.Top_Parent__r.Location_Type__c,
											Account.ANG_RiskStatus__c,
											Account.ANG_CashCondition__c,
											Account.Financial_Review_Result__c,
											Account.ANG_RiskHistoryAssessment__c
									   FROM Contact
									  WHERE Id = :contactId];

		this.contact = contactList.isEmpty() ? null : contactList[0];

		if(this.contact != null) {
			accountId = this.contact.Account.id;
			if(this.contact.Account.Top_Parent__c != null) {
				accountIdTP = this.contact.Account.Top_Parent__c;
			} else {
				accountIdTP = this.contact.Account.id;
			}
		}

		this.isCashless = (this.contact != null && 
				   		   this.contact.Account.ANG_Accreditation_Model__c != null && 
				   		   this.contact.Account.ANG_Accreditation_Model__c == 'Cashless');
	}	

	private void initFormsOfPayment() {
		this.afpWrapper = AMS_Utils.getANG_ISSP_AfpWrapper(this.contact, this.contact.Account, false);
	}

	public void initializeRHCInfo() {
		List<ANG_RHC_Information__c> rhcInfoList = [
			SELECT Id, 
				   ANG_RHC_Amount__c, 
				   ANG_ConsumedRHC__c, 
				   ANG_ConsumedRHC_Percent__c, 
				   ANG_ConsumedRHC_Last_Update__c, 
				   ANG_Financial_Security__c
			  FROM ANG_RHC_Information__c
			 WHERE ANG_AccountId__c = :accountId
		];
		this.rhcInfo = rhcInfoList.isEmpty() ? null : rhcInfoList[0];
	}

	private void initRiskProfile() {

		if(this.Contact.Account.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASH) {
			this.accreditationType = System.Label.ANG_ISSP_ProductStandardAccreditationWithCash;
		} else if(this.Contact.Account.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASHLESS) {
			this.accreditationType = System.Label.ANG_ISSP_ProductStandardAccreditationWithNoCash;
		} else {
			this.accreditationType = this.Contact.Account.ANG_Accreditation_Model__c;
		}

		this.riskStatus = this.Contact.Account.ANG_RiskStatus__c;
		if(this.riskStatus == null) this.riskStatus = '-';

		if(this.Contact.Account.ANG_CashCondition__c)
			this.cashConditions = System.Label.ISSP_Yes;
		else
			this.cashConditions = System.Label.ISSP_No;

		if(this.contact.Account.Financial_Review_Result__c != null && this.contact.Account.Financial_Review_Result__c.startsWith('Unsatisfactory'))
			this.financialReviewResult = System.Label.ISSP_Unsatisfactory;
		else 
			this.financialReviewResult = System.Label.ISSP_Satisfactory;

		this.riskHistoryAssessment = this.Contact.Account.ANG_RiskHistoryAssessment__c;
	}

	public class RiskEvent {
		public String description {get; set;}
		public Date dateAssigned {get; set;}
		public Date dateExpired {get; set;}
		public String iataCode {get; set;}
		public String caseNumber {get; set;}
		public String caseId  {get; set;}
		public String caseNumberLink {get; set;}
		public String status {get; set;}

		public RiskEvent(ANG_Agency_Risk_Event__c event) {
			this.description = event.ANG_Risk_Type__r.ANG_Description__c;
			this.dateAssigned = event.ANG_Issued_Date__c;
			this.dateExpired = event.ANG_expiration_date_ff__c;
			this.iataCode = event.ANG_AccountId__r.IATACode__c;

			if(event.ANG_CaseId__r.CaseNumber != null && event.ANG_CaseId__c != null) {
				this.caseId = event.ANG_CaseId__c;
				this.caseNumber = event.ANG_CaseId__r.CaseNumber;
				this.caseNumberlink = '<a href="/ISSP_Case?caseId=' + this.caseId + '&mid=M1S2">' + this.caseNumber + '</a>';				
			}
		
			this.status = translateStatus(event.ANG_Event_Status__c, event.ANG_Expired__c);
		}

		private String translateStatus(String status, Boolean expired) {
			String retStatus = status;
			if(expired) {
				retStatus = 'Expired';
			} else if(status == 'Inactive_Withdrawn' || status == 'Inactive_Revoked') {
				retStatus = 'Inactive';
			}
			return retStatus;
		}
	}

    public PageReference refreshRiskEventsTable() {
        riskEventsList = null;
        
        return null;
    }

	public List<RiskEvent> getRiskEventList() {
		riskEventsList = new List<RiskEvent>();

		String soqlStr = 'Select ANG_Risk_Type__r.ANG_Description__c,' +
								'ANG_Issued_Date__c,' +
								'ANG_Event_Status__c,' +
								'ANG_expiration_date_ff__c,' +
								'ANG_AccountId__r.IATACode__c,' +
								'ANG_CaseId__c,' +
								'ANG_CaseId__r.CaseNumber,' +
								'ANG_Expired__c,' +
								'ANG_CaseId__r.Visible_on_ISS_Portal__c' +
						  ' From ANG_Agency_Risk_Event__c' +
						 ' Where ANG_HE_AccountId__c = \'' + accountIdTP + '\'';

		this.isAll = false;
		String filter = ' And ';
		if(this.riskStatusFilter == 'Active') {
			filter += 'ANG_Event_Status__c = \'Active\' AND ANG_Expired__c = false';
		} else if(this.riskStatusFilter == 'Expired') {
			filter += 'ANG_Expired__c = true';
		} else if(this.riskStatusFilter == 'Inactive') {
			filter += 'ANG_Event_Status__c in(\'Inactive_Withdrawn\', \'Inactive_Revoked\') AND ANG_Expired__c = false';
		} else if(this.riskStatusFilter == 'All') {
			this.isAll = true;
			filter += 'ANG_Event_Status__c  not in(\'Inactive_CHO\', \'Inactive_TER\',\'Inactive_Migrated\')';
		}

		soqlStr += filter;

		List<ANG_Agency_Risk_Event__c> events = Database.query(soqlStr);

		for(ANG_Agency_Risk_Event__c event : events) {
			//
			// If the case is not visible in the portal then we do not show the link to it.
			//
			if(event.ANG_CaseId__c != null && !event.ANG_CaseId__r.Visible_on_ISS_Portal__c) {
				event.ANG_CaseId__c = null;
			}
			riskEventsList.add(new RiskEvent(event));
		}

		return riskEventsList;
	}
}