public with sharing class ANG_ISSP_AfpWrapper {
	private static final String NO = 'glyphicon glyphicon-remove';
	private static final String YES = 'glyphicon glyphicon-ok';
	public static final String DOMESTIC = AMS_Utils.CATEGORY_DOMESTIC_AGENT;
	public static final String INTERNATIONAL = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT;

	private Contact contact {get; set;}
	private Account account {get; set;}
	public Boolean isSearch {get; set;}

	public Boolean isInternational {
		get {
			return account.Category__c == INTERNATIONAL;
		}
		private set;
	}

	public Boolean isDomestic {
		get {
			return account.Category__c == DOMESTIC;
		}
		private set;
	}

	public Boolean isCashless {
		get {
			return (contact != null && account.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASHLESS);
		}
		set;
	}

	public Boolean isCreditCardFlag {
		get {
			return isCreditCardFlag == null ? false : isCreditCardFlag;
		}
		private set;
	}

	public String isCash {
		get {
			return isCash == null ? NO : isCash;
		}
		set;
	}

	public String isIEP {
		get {
			return isIEP == null ? NO : isIEP;
		}
		set;
	}

	public String isCreditCard {
		get {
			return isCreditCard == null ? NO : isCreditCard;
		}
		set;
	}

	public String iepLinkLabel {get; set;}
	public String iepLink {get; set;}

	public String modalErrorMessage {
		get {
			return modalErrorMessage == null ? '' : modalErrorMessage;
		}
		private set;
	}

	public String modalErrorMessageFlag {
		get {
			return modalErrorMessageFlag == null ? '' : modalErrorMessageFlag;
		}
		private set;
	}

	public String cashlessMessage {get; set;}
	public String creditCardMessage {get; set;}

	public Boolean isIEPFlag {
		get {
			return isIEPFlag == null ? false : isIEPFlag;
		}
		private set;
	}

	public Boolean isCashFlag {
		get {
			return isCashFlag == null ? false : isCashFlag;
		}
		private set;
	}

	public Boolean isChinaAgent {
		get {
			return account.IATA_ISO_Country__r.ISO_Code__c == 'CN';
		}
		set;
	}

	public Boolean isBOPFlag {
		get {
			return isBOPFlag == null ? false : isBOPFlag;
		}
		set;
	}

	public Integer authQuantity {
		get {
			return authQuantity == null ? 0 : authQuantity;
		}
		set;
	}

	public Boolean isIndonesiaAgent {
		get {
			return account.IATA_ISO_Country__r.ISO_Code__c == 'ID';
		}
		private set;
	}

	public String iepModel {
		get {
			return account.IATA_ISO_Country__r.ANG_IEP_Model__c == null ? '' : account.IATA_ISO_Country__r.ANG_IEP_Model__c;
		}
		private set;
	}

	public Boolean displayIcons {
		get {
			return (!isChinaAgent && !(isIndonesiaAgent && isInternational));
		}
		private set;
	}

	public ANG_ISSP_AfpWrapper(Contact contact, List<Agency_Authorization__c> authorizations, Account account, Boolean isSearch) {
		this.contact = contact;
		this.account = account;
		this.isSearch = isSearch;

		String availableServicesLink = CSP_Utils.isNewPortalActive() ? CSP_Utils.redirectfromPortalHeader('services?tab=availableServices') : '/ISSP_AvailableServices?MainNav=Services&subNav=Access&mid=M3S1';

		List<Portal_Application_Right__c> services = new List<Portal_Application_Right__c>();

		if (contact != null) {
			services = [SELECT Id, Application_Name__c, Right__c, Application_Start_URL__c
						FROM Portal_Application_Right__c
						WHERE Contact__c = :contact.Id];

			checkAccreditationChangesAccess(services);
		}

		calculateAuthorizationFlags(authorizations);

		if (isChinaAgent) {
			this.iepLink = Label.ANG_ISSP_BOP_China_URL;
		} else if (iepModel == 'Banking Model') {
			this.iepLink = '#';
			this.iepLinkLabel = Label.ANG_ISSP_IEP_ModelBanking_link;
			this.modalErrorMessageFlag = '-';

			if (account.IATA_ISO_Country__r.Iso_Code__c == 'IN') {
				this.modalErrorMessage = Label.ANG_ISSP_IEP_ModelBanking_India_msg;
			}

			if (account.IATA_ISO_Country__r.Iso_Code__c == 'KR') {
				this.modalErrorMessage = Label.ANG_ISSP_IEP_ModelBanking_SouthKorea_msg;
			}
		} else if (account.ANG_IEP_Status_FF__c == Ams_Utils.OPEN) {
			this.isIEP = YES;
			this.isIEPFlag = true;

			if (contact != null) {
				Boolean hasAccess = false;

				for(Portal_Application_Right__c par: services) {
					if(par.Application_Name__c.startsWith(Label.ANG_ISSP_IATA_EasyPay) && par.Right__c == Ams_Utils.PORTAL_APP_ACCESS_GRANTED) {
						hasAccess = true;
						this.iepLinkLabel = Label.ANG_ISSP_REH_AccessEasyPay;
						this.iepLink = par.Application_Start_URL__c;
						break;
					}
				}

				if(!hasAccess) {
					this.iepLinkLabel = Label.ANG_ISSP_Request_Access_IATA_EasyPay;
					this.iepLink = availableServicesLink;
				}
			}
		} else if(account.ANG_IEP_Status_FF__c == Ams_Utils.NO_IEP_ACCOUNT) {
			List<Profile> profileList = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];

			Boolean isAdmin = false;

			if (!profileList.isEmpty() && profileList[0].Name.contains('dmin')){
				isAdmin = true;
			}

			Boolean isAuthorisedSignatory = false;
			if (contact != null) {
				isAuthorisedSignatory = (isAdmin && contact.Authorized_Signatory__c);
			}

			Boolean isIEPAccountEnable = false;

			// A user has accecss to easypay when:
			// If the IEP status is open
			// If the IEP status is not open and is an admin and the account is HO or HE
			if(isAuthorisedSignatory && isAdmin && (account.Location_Type__c == AMS_Utils.HO || account.Location_Type__c == AMS_Utils.HE|| (account.Location_Type__c == AMS_Utils.AO && account.Status__c == AMS_Utils.ACC_S4_LISTED))) {
				isIEPAccountEnable = true;
				this.iepLink = availableServicesLink;
			}

			if(!isIEPAccountEnable) {
				if(account.Location_Type__c == AMS_Utils.HO || account.Top_Parent__r.Location_Type__c == AMS_Utils.HO){
					this.modalErrorMessage = Label.ANG_ISSP_IEP_AuthorisedSignatory_HO_auth_msg;
				}else if(account.Location_Type__c == AMS_Utils.HE || account.Top_Parent__r.Location_Type__c == AMS_Utils.HE){
					this.modalErrorMessage = Label.ANG_ISSP_IEP_AuthorisedSignatory_HE_auth_msg;
				} else if (account.Location_Type__c == AMS_Utils.AO || account.Top_Parent__r.Location_Type__c == AMS_Utils.AO) {
					this.modalErrorMessage = Label.ANG_ISSP_IEP_AuthorisedSignatory_AO_auth_msg;
				}
				this.iepLink = '#';
			}

			if(modalErrorMessage != '') {
				this.modalErrorMessageFlag = '-';
			}

			this.iepLinkLabel = Label.ANG_ISSP_Open_IATA_EasyPay_Account;
		}

		if (isIndonesiaAgent && account.Category__c == INTERNATIONAL) {
			this.iepLink = '#';
			this.modalErrorMessageFlag = '-';
			this.modalErrorMessage = Label.ANG_ISSP_IEP_Indonesia_msg;
		}
	}

	private void checkAccreditationChangesAccess(List<Portal_Application_Right__c> services) {
		Boolean hasAccess = false;

		for(Portal_Application_Right__c par: services) {
			if(par.Application_Name__c == AMS_Utils.IATA_ACCREDITATION_AND_CHANGES && par.Right__c == AMS_Utils.PORTAL_APP_ACCESS_GRANTED) {
				hasAccess = true;
				break;
			}
		}

		if (isCashless) {
			this.cashlessMessage = hasAccess ? Label.ANG_ISSP_AFP_CashlessMessage : Label.ANG_ISSP_AFP_CashlessMessageNoAccess;
		}

		this.creditCardMessage = hasAccess ? Label.ANG_ISSP_AFP_NoCreditCardMessage : Label.ANG_ISSP_AFP_CreditCardNoAccess;
	}

	private void calculateAuthorizationFlags(List<Agency_Authorization__c> authorizations) {
		for(Agency_Authorization__c auth : authorizations) {
			if(auth.ANG_FormOfPayment_ID__c == Ams_Utils.CA && !this.isCashless) {
				this.isCash = YES;
				this.isCashFlag = true;
				this.authQuantity++;
			}

			if(auth.ANG_FormOfPayment_ID__c == Ams_Utils.CC) {
				this.isCreditCard = YES;
				this.isCreditCardFlag = true;
				this.authQuantity++;
			}

			if(auth.ANG_FormOfPayment_ID__c == Ams_Utils.BOP) {
				this.isBOPFlag = true;
				this.authQuantity++;
			}
		}
	}
}