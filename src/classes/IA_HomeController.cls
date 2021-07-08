public with sharing class IA_HomeController {
	public static final String APP_NAME = 'Interline agreements';

	public list<String> listMessages {get; set;}
	public Account airlineHQ {get;set;}
	//5 sections available: CONTACTS, MEMOS, ALL, REQ and NEW
	public String showSection {get;set;}

	public String getMapAgreementsByNameJson() {
		return Json.serialize(IA_util.MAP_AGREEMENTS_BY_NAME);
	}

	private User currentUser;

	public IA_HomeController(){
		this.listMessages = new list<String>();
		this.showSection = 'ALL';
		Id userid = UserInfo.getUserId();

		this.currentUser = [
			SELECT Id, UserName, Profile.Name, ContactId, Contact.AccountId, Contact.MITA_Contact__c, Contact.MITA_Contact_Type__c,
				Contact.Account.Name,Contact.Account.ParentId, Contact.Account.Top_Parent__c
			FROM User WHERE ID = :userId];

		// find the related Airline Headquarter
		Id airlineHQId = this.currentUser.Contact.Account.Top_Parent__c ==null? this.currentUser.Contact.AccountId: this.currentUser.Contact.Account.Top_Parent__c;

		List<Account> accs = [
			SELECT Name, Airline_Prefix__c, Airline_designator__c, IATAcode__c, Membership_status__c, MITA_Member__c, BIETA_Member__c, Company_Logo__c,
			MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Cargo__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c,
			BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c,
			BIETA_One_way_Intermodal_Participating__c
			FROM Account
			WHERE Id = :airlineHQId];
		
		if(accs.size()!=1) {
			listMessages.add(Label.ISSP_cannot_open_the_selected_account);
		}else{
			this.airlineHQ = accs[0];
		}
	}

	/**
		Start actions: check rights
	**/
	public PageReference initActions() {
		try {
			String strId = this.currentUser.ContactId;
			Portal_Application_Right__c appRight = [
				Select Id, Terms_Acceptance__c, Terms_Acceptance_Date__c, Right__c
				From Portal_Application_Right__c
				Where ContactId__c = :strId.left(15)
				And Portal_Application__r.Name = :APP_NAME
			];
			// If user has no rights to access to Account statements app then is redirected to Home
			if (appRight.Right__c=='Access Granted') {
				return null;
			}

		} catch(Exception e) {
			//if error happens return to home page
		}
		// default action, return to home page (if no Access granted was found)
		Pagereference pageref = new PageReference(Label.CSP_PortalBaseURL + Label.CSP_PortalPath);
		pageref.setRedirect(true);
		return pageref;
	}

	/**
	 * Get the logo image from the Portal application record
	 */
	public String appLogoURL {
		get {
			if (appLogoURL==null) {
				appLogoURL = [SELECT Id, Application_icon_URL__c FROM Portal_Applications__c WHERE Name = :APP_NAME].Application_icon_URL__c;
			}
			return appLogoURL;
		}
		private set;
	}

	public Boolean getWithdrawPermission() {
		return true;
	}

	public Boolean getApprovePermission() {
		return true;
	}

	public Boolean getRequestPermission() {
		return true;
	}

	public Boolean getEditContactsPermission() {
		return true;
	} 
}