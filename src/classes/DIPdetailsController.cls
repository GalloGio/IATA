public with sharing class DIPdetailsController {
	public Case c {public get; private set;}
	public DIP_Details__c dip {get; set;}
	public map<Id, Reinsurer__c> mapReinsurersPerId {get; set;}
	public Reinsurer__c onFocusReinsurer {get; set;}
	public Boolean isAddEditReinsurerMode {get; set;}
	public Boolean isViewReinsurerMode {get; set;}
	public Boolean isEditDetailMode {get; set;}
	public PageReference DIPApproval {
		get {
			return new PageReference('/apex/DIPapprovald?id=' + dip.Id);
		} set;
	}

	public DIPdetailsController (final ApexPages.StandardController controller) {
		if (controller.getRecord().Id != null ) {
			c = (Case)controller.getRecord();

			// Get the DIP details related to this case
			List<DIP_Details__c> lstDIPRecords = [SELECT Id, Aggregate_per_Agent__c, Aggregate_per_Market__c, All_Documents_Received_Date__c, Application_Details_Remarks__c, Cert_to_operate_in_its_country_of_dom__c, Claims_payment_history__c,
														Confirmation_of_financial_strength_rate__c, Cut_through_clause_wording__c, DIP_Status__c, Disclosure_covering_the_last_10_years__c, Final_signed_copies_of_all_agreements__c,
														Information_Sheet_Signed_by_HUB__c, Insurance_policy_insurance_bond_wording__c, Insurer_Contact_Name__c, Insurer_Email__c, Insurer_Name__c, Most_recent_annual_report__c, Non_disclosure_agreement__c,
														Opinion_from_local_counsel__c, Premium_Collection__c, Regulatory_appr_of_reinsurance_agreement__c, Reinsurance_agreement__c, Review_Process_Remarks__c, Review_Start_Date__c,
														Underwriter_s_name_contact_information__c, Approval_Status__c, GPO_Approver_Name__c, Legal_Approver_Name__c
													FROM DIP_Details__c
													WHERE Case__c = :c.Id];

			if (lstDIPRecords.size() == 1) {
				dip = lstDIPRecords[0];

				mapReinsurersPerId = new map<Id, Reinsurer__c>([SELECT Id, Cert_to_operate_in_its_country_of_dom__c, Confirmation_of_financial_strength_rate__c, Coverage_percentage__c, Disclosure_covering_the_last_10_years__c, Final_signed_copies_of_all_agreements__c,
										Information_Sheet_Signed_by_Area_Manager__c, Most_recent_annual_report__c, Non_disclosure_agreement__c, Opinion_from_local_counsel__c, Regulatory_appr_of_reinsurance_agreemen__c,
										Re_insurer_name__c, DIP_Details__c, Remarks__c, Underwriter_s_name_contact_information__c
										FROM Reinsurer__c
										WHERE DIP_Details__c = :dip.Id]);

				isAddEditReinsurerMode = false;
				isViewReinsurerMode = false;
				isEditDetailMode = false;

				onFocusReinsurer = new Reinsurer__c();
			} else if (lstDIPRecords.isEmpty()) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No associated DIP Details record found! Please contact support.'));
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'More than 1 associated DIP Details record found! Please contact support.'));
			}
		} else {
			mapReinsurersPerId = new map<Id, Reinsurer__c>();
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Case ID'));
		}
	}




	public void EditDIP() {
		isEditDetailMode = true;
	}

	public PageReference CancelEditDIP() {
		//isEditCommentsMode = false;

		PageReference retPage = new PageReference('/apex/DIPdetails?id=' + c.Id);
		retPage.setRedirect(true);
		return retPage;
	}

	public PageReference SaveDIP() {
		try {
			update dip;

			PageReference retPage = new PageReference('/apex/DIPdetails?id=' + c.Id);
			retPage.setRedirect(true);
			return retPage;
		} catch (DMLException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0)));
			return null;
		}
	}



	public void AddNewReinsurer() {
		try {
			onFocusReinsurer = new Reinsurer__c(DIP_Details__c = dip.Id);

			isAddEditReinsurerMode = true;
			isViewReinsurerMode = true;
		} catch (DMLException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0)));
		}
	}

	public void ViewReinsurer() {
		if (onFocusReinsurer.Id != null && mapReinsurersPerId.get(onFocusReinsurer.Id) != null) {
			onFocusReinsurer = mapReinsurersPerId.get(onFocusReinsurer.Id);
			isAddEditReinsurerMode = false;
			isViewReinsurerMode = true;
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error selecting the Re-insurer'));
		}
	}

	public void EditReinsurer() {
		if (onFocusReinsurer.Id != null && mapReinsurersPerId.get(onFocusReinsurer.Id) != null) {
			onFocusReinsurer = mapReinsurersPerId.get(onFocusReinsurer.Id);
			isAddEditReinsurerMode = true;
			isViewReinsurerMode = true;
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error selecting the Re-insurer'));
		}
	}

	public PageReference CancelEditReinsurer() {
		//isEditCommentsMode = false;

		PageReference retPage = new PageReference('/apex/DIPdetails?id=' + c.Id);
		retPage.setRedirect(true);
		return retPage;
	}


	public PageReference SaveReinsurer() {
		try {
			upsert onFocusReinsurer;

			PageReference retPage = new PageReference('/apex/DIPdetails?id=' + c.Id);
			retPage.setRedirect(true);
			return retPage;
		} catch (DMLException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0)));
			return null;
		}
	}

}
