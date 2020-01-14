/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This class is the controller for the RCRMOpportunityControlButtons VF page. It handles the display of the control buttons and the validation of the Opportunity
 *		by the Product Manager or the Alternate Product Manager.
 *
 */

public with sharing class RCRMOpportunityControlButtonsController {
	public Opportunity opp {public get; private set;}

	public Boolean showSendForValidationButton {
		public get {
			String currentUserProfile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
			String allowedProfiles = 'MACS - Administrator,MACS - Product,MACS - Customer Care,MACS - Direct Sales,MACS - Events - Worldtek,MACS - Field Sales,MACS - IATAN - TIESS,' +
					'MACS - Marketing & Publishing,MACS - Strategic Partnerships,System Administrator,GDP - Administrator,IATA - Sales Director';
			String validStatuses = 'No validation yet,Rejected by PM';

			// show button if stage 6; only show to the opportunity owner; don't show if the owner is the product manager (if PM handles the renewal, he won't send it
			// to himself for validation, he will directly validate the sale)
			Boolean tmpResult =  opp.OwnerId == UserInfo.getUserId() &&
								 ( opp.RCRM_Validation_Status__c == null ||
								 validStatuses.contains(opp.RCRM_Validation_Status__c) ) &&
								 opp.StageName == '6. Contract stage' &&
								 allowedProfiles.contains(currentUserProfile);

			return tmpResult;
		} private set;
	}

	public Boolean showValidateButton {
		public get {
			String currentUserProfile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
			String allowedProfiles = 'MACS - Product,System Administrator';

			//allowedProfiles.contains(currentUserProfile)
			Boolean tmpResult = ( opp.RCRM_Product_Manager__c == UserInfo.getUserId() || opp.Alternate_RCRM_Product_Manager__c == UserInfo.getUserId() ) &&
								opp.StageName == '6. Contract stage' &&
								(
									opp.RCRM_Validation_Status__c == 'Sent to PM for validation' ||
									( opp.RCRM_Validation_Status__c == 'No validation yet' && opp.OwnerId == UserInfo.getUserId() )
								);

			return tmpResult;
		} private set;
	}
	public Boolean showRejectButton {
		public get {
			Boolean tmpResult = showValidateButton && opp.OwnerId != UserInfo.getUserId();

			return tmpResult;
		} private set;
	}

	public Boolean rejectReasonValidationError {
		public get {
			return opp.Rejection_reason__c == null || opp.Rejection_reason__c.trim() == '';
		} private set;
	}

	public Boolean amountValidationError {
		public get {
			// get the RSLs related to the opportunity
			List<Revenue_Stream_Line__c> lstRelatedRSLs = [SELECT Id, Annualized_value__c, Opportunity__c FROM Revenue_Stream_Line__c WHERE Opportunity__c = :opp.Id];

			Double rslTotal = 0;
			// calculate the RSL total
			for (Revenue_Stream_Line__c rsl : lstRelatedRSLs) {
				rslTotal += rsl.Annualized_value__c;
			}

			// get the total opportunity amount only from OLIs with RCRM products
			Double RcrmOLIsTotal = 0;
			List<OpportunityLineItem> lstAllRcrmOLIs = [SELECT Id, UnitPrice, Quantity FROM OpportunityLineItem WHERE Product2.RCRM_Product__c = true AND OpportunityId = :opp.Id];
			for (OpportunityLineItem oli : lstAllRcrmOLIs) {
				RcrmOLIsTotal += oli.UnitPrice * oli.Quantity;
			}

			return RcrmOLIsTotal != rslTotal;
		} private set;
	}

	public Boolean productFamilyValidationError {
		public get {
			// get the RSLs related to the opportunity
			List<OpportunityLineItem> lstAllRcrmOLIs = [SELECT Id, Product2.Family FROM OpportunityLineItem WHERE Product2.RCRM_Product__c = true AND OpportunityId = :opp.Id];

			Boolean res = false;
			for (OpportunityLineItem oli : lstAllRcrmOLIs) {
				if (oli.Product2.Family != opp.Product_Family__c) {
					res = true;
				}
			}

			return res;
		} private set;
	}

	public Boolean datesValidationError {
		public get {
			// check the contract dates have been filled

			return opp.Start_Date__c == null || opp.Current_Cycle_End_Date__c == null || opp.Renewal_duration_in_months__c == null;
		} private set;
	}



	public RCRMOpportunityControlButtonsController (final ApexPages.StandardController controller) {
		if (controller.getRecord().Id != null ) {
			opp = [SELECT Id, StageName, RCRM_Validation_Status__c, Renewal_under_Sales_Responsibility__c, RCRM_Product_Manager__c, Alternate_RCRM_Product_Manager__c, OwnerId, Amount,
						Product_Family__c, Early_Renewal__c, Start_Date__c, Current_Cycle_End_Date__c, Renewal_duration_in_months__c, Rejection_reason__c
						FROM Opportunity WHERE Id = :controller.getRecord().Id];
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Opportunity'));
		}
	}

	public PageReference sendForValidation() {
		try {
			opp.RCRM_Validation_Status__c = 'Sent to PM for validation';
			update opp;

			PageReference curPage = ApexPages.currentPage();
			curPage.getParameters().put('success','true');
			curPage.setRedirect(true);
			return curPage;
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
			return null;
		}
	}

	public PageReference ValidateSale() {
		// Validates the sale and closes the Opportunity
		try {
			opp.RCRM_Validation_Status__c = 'Validated by PM';
			opp.StageName = '7. Closed Sales / Sold';
			update opp;

			PageReference curPage = ApexPages.currentPage();
			curPage.getParameters().put('success','true');
			curPage.setRedirect(true);
			return curPage;
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
			return null;
		}


	}

	public PageReference RejectSale() {
		try {
			opp.RCRM_Validation_Status__c = 'Rejected by PM';
			update opp;

			PageReference curPage = ApexPages.currentPage();
			curPage.getParameters().put('success','true');
			curPage.setRedirect(true);
			return curPage;
		}  catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
			return null;
		}
	}
}
