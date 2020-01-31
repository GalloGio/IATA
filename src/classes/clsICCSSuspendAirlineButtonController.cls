/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This class is the controller for the ICCSSuspendAirlineButton page. It controls and limits the display of the button to certain profiles only
 *		and handles the airline suspension from ICCS products.
 */

public class clsICCSSuspendAirlineButtonController {
	public Id accountId {public get; private set;}

	public Boolean showSuspendButton {
		public get {
			String currentUserProfile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
			String allowedProfiles = 'System Administrator, FDS ICCS Administrator, FDS ICCS User';

			return allowedProfiles.contains(currentUserProfile);
		} private set;
	}

	public clsICCSSuspendAirlineButtonController (final ApexPages.StandardController controller) {
		accountId = controller.getRecord().Id;
	}

	public PageReference suspendAirline() {
		// Get a list of all active PAs related to the account
		List<Product_Assignment__c> lstProductAssignments = new List<Product_Assignment__c>();
		for(Product_Assignment__c pa: [SELECT Id, Status__c, De_Activation_Date__c FROM Product_Assignment__c WHERE Account__c =: accountId AND Status__c = 'Active']) {
			pa.Status__c = 'Inactive';
			pa.De_Activation_Date__c = date.today();
			lstProductAssignments.add(pa);
		}

	  	if (!lstProductAssignments.isEmpty()) {
	  		Account a = [SELECT Id, ICCS_Membership_Status__c FROM Account WHERE Id = :accountId];
	  		a.ICCS_Membership_Status__c = 'Inactive';
	  		update a ;
	  		update lstProductAssignments;
	  	}


		PageReference curPage = ApexPages.currentPage();
		curPage.getParameters().put('success','true');
		curPage.setRedirect(true);
		return curPage;
	}
}
