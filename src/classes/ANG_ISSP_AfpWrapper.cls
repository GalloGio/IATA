public with sharing class ANG_ISSP_AfpWrapper {
	private static final String NO = 'fa fa-times fa-2x show wrong';
	private static final String YES = 'fa fa-check fa-2x show check';

	public Boolean isCashless {get; set;}
	public Boolean isCreditCardFlag {get; set;}
	public String isCash {get; set;}
	public String isIEP {get; set;}
	public String isCreditCard {get; set;}
	public String iepLinkLabel {get; set;}
	public String iepLink {get; set;}
	public String modalErrorMessage {get; set;}
	public String modalErrorMessageFlag {get; set;}
	public String cashlessMessage {get; set;}

	public ANG_ISSP_AfpWrapper(Contact contact, List<Agency_Authorization__c> authorizations, List<Portal_Application_Right__c> services) {
		this.isCash = NO;
		this.isIEP = NO;
		this.isCreditCard = NO;
		this.isCreditCardFlag = false;
		this.modalErrorMessage = '';
		this.modalErrorMessageFlag = '';

		this.isCashless = (contact != null && 
						   contact.Account.ANG_Accreditation_Model__c != null && 
						   contact.Account.ANG_Accreditation_Model__c == 'Cashless');

		if(this.isCashless) {
			Boolean hasAccess = false;
			for(Portal_Application_Right__c par: services) {
				System.debug('par.Application_Name__c-->' + par.Application_Name__c);

				if(par.Application_Name__c == Ams_Utils.IATA_ACCREDITATION_AND_CHANGES && par.Right__c == Ams_Utils.PORTAL_APP_ACCESS_GRANTED) {
					hasAccess = true;
					break;
				}
			}
			if(hasAccess) {
				this.cashlessMessage = System.Label.ANG_ISSP_AFP_CashlessMessage;
			} else {
				this.cashlessMessage = System.Label.ANG_ISSP_AFP_CashlessMessageNoAccess;				
			}

			System.debug('this.cashlessMessage--->' + this.cashlessMessage);
		}

		if(authorizations != null) {
			for(Agency_Authorization__c auth : authorizations) {
				if(auth.ANG_FormOfPayment_ID__c == Ams_Utils.CA && !this.isCashless) {					
					this.isCash = YES;
				}
				if(auth.ANG_FormOfPayment_ID__c == Ams_Utils.CC) {
					this.isCreditCard = YES;
					this.isCreditCardFlag = true;
				}
			}
		}

		if(contact.Account.ANG_IEP_Status_FF__c == Ams_Utils.OPEN) {
			this.isIEP = YES;
			Boolean hasAccess = false;
			for(Portal_Application_Right__c par: services) {
				if(par.Application_Name__c.startsWith(System.Label.ANG_ISSP_IATA_EasyPay) && par.Right__c == Ams_Utils.PORTAL_APP_ACCESS_GRANTED) {
					hasAccess = true;
					this.iepLink = par.Application_Start_URL__c;
					break;
				}
			}
			if(hasAccess) {
				this.iepLinkLabel = System.Label.ANG_ISSP_REH_AccessEasyPay;
			} else {
				this.iepLinkLabel = System.Label.ANG_ISSP_Request_Access_IATA_EasyPay;
				this.iepLink = '/ISSP_AvailableServices?MainNav=Services&subNav=Access&mid=M3S1';
			}
		} else if(contact.Account.ANG_IEP_Status_FF__c == Ams_Utils.NO_IEP_ACCOUNT) {

            String currentUserProfileId = UserInfo.getProfileId();
            List <Profile> profileList = [SELECT Name FROM Profile WHERE Id = :currentUserProfileId];

            Boolean isAdmin = false;

            if (!profileList.isEmpty()){
                String currentUserProfileName = profileList[0].Name;               
                if (currentUserProfileName.contains('dmin')) isAdmin = true;
			}

			Boolean isAuthorisedSignatory = (isAdmin && contact.Authorized_Signatory__c); 

            Boolean isIEPAccountEnable = false;

            // A user has accecss to easypay when:
            // If the IEP status is open
            // If the IEP status is not open and is an admin and the account is HO or HE 
            if(contact.Account.ANG_IEP_Status_FF__c == 'Open') {
                isIEPAccountEnable = true;                
            } else if(isAuthorisedSignatory && isAdmin && (contact.Account.Location_Type__c == 'HO' || contact.Account.Location_Type__c == 'HE' || 
                                 (contact.Account.Location_Type__c == 'AO' && contact.Account.Status__c == 'Listed'))) {
                isIEPAccountEnable = true;
            }

            if(!isIEPAccountEnable) {
	            if(contact.Account.Location_Type__c == 'HO' || contact.Account.Top_Parent__r.Location_Type__c == 'HO'){
	                this.modalErrorMessage = Label.ANG_ISSP_IEP_AuthorisedSignatory_HO_auth_msg;
	            }else if(contact.Account.Location_Type__c == 'HE' || contact.Account.Top_Parent__r.Location_Type__c == 'HE'){
	                this.modalErrorMessage = Label.ANG_ISSP_IEP_AuthorisedSignatory_HE_auth_msg;
	            } else if (contact.Account.Location_Type__c == 'AO' || contact.Account.Top_Parent__r.Location_Type__c == 'AO') {
	                this.modalErrorMessage = Label.ANG_ISSP_IEP_AuthorisedSignatory_AO_auth_msg;
	            }
        	}
        	if(modalErrorMessage != '') {
        		this.modalErrorMessageFlag = '-';
        	}		       

			this.iepLinkLabel = System.Label.ANG_ISSP_Open_IATA_EasyPay_Account;

			if(!isIEPAccountEnable) {
				this.iepLink = '#';								
			} else {
				this.iepLink = '/ISSP_AvailableServices?MainNav=Services&subNav=Access&mid=M3S1';				
			}

		}
	}
}