/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This class is the controller for the ContractButtons VF page. It handles the display of the control buttons according to user rights and the contract renewal actions.
 *
 */

public with sharing class ContractButtonsController {
	public Contract con { get; set; }
	public List<Opportunity> lstFutureOpps { get; set; }

	public Boolean showSMRenewButtons {
		public get {
			String currentUserProfile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
			String allowedProfiles = 'MACS - Administrator,MACS - Customer Care,MACS - Direct Sales,MACS - Events - Worldtek,MACS - Field Sales,MACS - IATAN - TIESS,' +
					'MACS - Marketing & Publishing,MACS - Strategic Partnerships,MACS - Product,System Administrator';

			// Only the Owner can see these buttons, if he/she is a SM and the renewal process has not already been started
			Boolean tmpResult = ( allowedProfiles.contains(currentUserProfile) && con.OwnerId == UserInfo.getUserId() ) ||
								( con.Current_Opportunity__r.OwnerId == UserInfo.getUserId() || con.Current_Opportunity__r.RCRM_Product_Manager__c == UserInfo.getUserId() || con.Current_Opportunity__r.Alternate_RCRM_Product_Manager__c == UserInfo.getUserId() ) &&
								( con.Renewal_Status__c == null || con.Renewal_Status__c == 'Renewed as-is' );

			return tmpResult;
		} private set;
	}

	public Boolean showPMRenewButtons {
		public get {
			String currentUserProfile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
			String allowedProfiles = 'MACS - Administrator,MACS - Customer Care,MACS - Direct Sales,MACS - Events - Worldtek,MACS - Field Sales,MACS - IATAN - TIESS,' +
					'MACS - Marketing & Publishing,MACS - Strategic Partnerships,MACS - Product,System Administrator';

			// Only the Owner can see these buttons, if he/she is a PM and the renewal process has not already been started
			Boolean tmpResult = (allowedProfiles.contains(currentUserProfile) || con.RCRM_Product_Manager__c == UserInfo.getUserId()) &&
								con.OwnerId == UserInfo.getUserId() &&
								(con.Renewal_Status__c == null || con.Renewal_Status__c == 'Renewed as-is' || con.Renewal_Status__c == 'Replaces a previous contract' || con.Renewal_Status__c == '');

			return tmpResult;
		} private set;
	}

	public Boolean showPMCancelButton {
		public get {
			// Only the Owner can see these buttons, if he/she is the PM and the renewal process has not already been started
			Boolean tmpResult = con.RCRM_Product_Manager__c == UserInfo.getUserId() &&
							 	(con.Renewal_Status__c == 'Renewed as-is' || con.Renewal_Status__c == 'Replaces a previous contract' || con.Renewal_Status__c == null || con.Renewal_Status__c == '' );

			return tmpResult;
		} private set;
	}

	public Boolean showRenewalOpportunityLink {
		public get {
			return con.Renewal_Status__c == 'Renewal process started' && !lstFutureOpps.isEmpty() && lstFutureOpps[0] != null;
		} private set;
	}

	public Id RenewalOpportunityId {
		public get {
			return !lstFutureOpps.isEmpty() && lstFutureOpps[0] != null ? lstFutureOpps[0].Id : null;
		} private set;
	}


	public ContractButtonsController (final ApexPages.StandardController controller) {
		if (controller.getRecord().Id != null ) {
			con = [SELECT Id, Renewal_Status__c, OwnerId, RCRM_Product_Manager__c, Current_Opportunity__r.OwnerId, Current_Opportunity__r.RCRM_Product_Manager__c, Current_Opportunity__r.Alternate_RCRM_Product_Manager__c FROM Contract WHERE Id = :controller.getRecord().Id];

			// There should be only 1 future opportunity, but a list is used for the situation where the renewal process has already been started and there is no more
			// 'Future renewal' opportunity
			lstFutureOpps = [SELECT Id FROM Opportunity WHERE Expiring_contract__c = :con.Id AND StageName = 'Future renewal' LIMIT 1];

			// if list is empty (no future opp) and the renewal process has been started, search for the opportunity to link to it
			if (lstFutureOpps.isEmpty() && con.Renewal_Status__c == 'Renewal process started') {
				lstFutureOpps = [SELECT Id FROM Opportunity WHERE Expiring_contract__c = :con.Id AND StageName <> 'Future renewal' AND isClosed = false LIMIT 1];
			}

			// if the list is empty, there's an error
			if (lstFutureOpps.isEmpty() && con.Renewal_Status__c != 'Not renewed' && con.Renewal_Status__c != 'Canceled') {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No future renewal opportunity found. Please contact support or your adminstrator.'));
			}
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Contract'));
		}
	}


	public PageReference InitiateRenewalProcess() {
		lstFutureOpps[0].StageName = '4. Needs confirmed/Proposal stage';
		lstFutureOpps[0].Rejection_reason__c = '[Starting renewal process]';
		update lstFutureOpps[0];

		lstFutureOpps[0].Rejection_reason__c = '';
		update lstFutureOpps[0];

		con.Renewal_Status__c = 'Renewal process started';
		update con;

		PageReference retPage = new PageReference('/' + lstFutureOpps[0].Id);
		retPage.getParameters().put('success','true');
		retPage.getParameters().put('redirid',lstFutureOpps[0].Id);
		retPage.setRedirect(true);
		return retPage;
	}


	public PageReference RenewAsIs() {
		// Trigger the generation of RSLs for the opportunity
		lstFutureOpps[0].StageName = '6. Contract stage';
		lstFutureOpps[0].Rejection_reason__c = '[Starting renewal process]';
		// Mark the opp as validated by the PM, so it can be closed
		lstFutureOpps[0].RCRM_Validation_Status__c = 'Validated by PM';
		lstFutureOpps[0].New_Business_Booking__c = 0;
		update lstFutureOpps[0];

		// Close the opportunity, to trigger the update of the contract & creation of the future renewal opp
		lstFutureOpps[0].StageName = '7. Closed Sales / Sold';
		lstFutureOpps[0].Rejection_reason__c = '';
		update lstFutureOpps[0];


		PageReference retPage = new PageReference('/' + con.Id);
		retPage.getParameters().put('success','true');
		retPage.getParameters().put('redirid',con.Id);
		retPage.setRedirect(true);
		return retPage;
	}

	public PageReference DoNotRenew() {
		lstFutureOpps[0].StageName = 'z. Lost';
		update lstFutureOpps[0];

		con.Renewal_Status__c = 'Not renewed';
		update con;

		PageReference retPage = new PageReference('/' + con.Id);
		retPage.getParameters().put('success','true');
		retPage.getParameters().put('redirid',con.Id);
		retPage.setRedirect(true);
		return retPage;
	}


	public PageReference CancelContract() {
		lstFutureOpps[0].StageName = 'z. Lost';
		update lstFutureOpps[0];

		//con.Renewal_Status__c = 'Not renewed';
		List<Contract> lstContract = new List<Contract>();
		lstContract.add(con);
		RCRMUtil.CancelContracts(lstContract);

		PageReference retPage = new PageReference('/' + con.Id);
		retPage.getParameters().put('success','true');
		retPage.getParameters().put('redirid',con.Id);
		retPage.setRedirect(true);
		return retPage;
	}


}
