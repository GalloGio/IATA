public with sharing class ANG_ISSP_AfpWrapper {
	private static final String BANKING_MODEL = 'Banking Model';
	public static final String DOMESTIC = AMS_Utils.CATEGORY_DOMESTIC_AGENT;
	public static final String INTERNATIONAL = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT;
	@TestVisible 
	private static final String AVAILABLE_SERVICES_OLD = '/ISSP_AvailableServices?MainNav=Services&subNav=Access&mid=M3S1';

	private Contact contact {get; set;}
	private Account account {get; set;}

	public Boolean isSearch {
		get {
			return contact == null;
		}
		set;
	}

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

	public String iepLinkLabel {get; set;}
	public String iepLink {get; set;}

	public String modalErrorMessage {
		get {
			return modalErrorMessage == null ? '' : modalErrorMessage;
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

	public ANG_ISSP_AfpWrapper(Account account) {
		this.account = account;
		this.isIEPFlag = !isChinaAgent && iepModel != BANKING_MODEL && account.ANG_IEP_Status_FF__c == AMS_Utils.OPEN;
		calculateAuthorizationFlags(account.Id);
	}

	public ANG_ISSP_AfpWrapper(Contact contact, Account account) {
		this.contact = contact;
		this.account = account;

		String availableServicesLink = CSP_Utils.isNewPortalActive() ? CSP_Utils.redirectfromPortalHeader('services?tab=availableServices') : AVAILABLE_SERVICES_OLD;

		calculateAuthorizationFlags(account.Id);

		List<Portal_Application_Right__c> services = [SELECT Id, Application_Name__c, Right__c, Application_Start_URL__c
													FROM Portal_Application_Right__c
													WHERE Contact__c = :contact.Id];

		checkAccreditationChangesAccess(services);

		if (isChinaAgent) {
			this.iepLink = Label.ANG_ISSP_BOP_China_URL;
		} else if (iepModel == BANKING_MODEL) {
			this.iepLink = '#';
			this.iepLinkLabel = Label.ANG_ISSP_IEP_ModelBanking_link;
		} else if (account.ANG_IEP_Status_FF__c == AMS_Utils.OPEN) {
			this.isIEPFlag = true;

			if (contact != null) {
				Boolean hasAccess = false;

				for(Portal_Application_Right__c par: services) {
					if(par.Application_Name__c.startsWith(Label.ANG_ISSP_IATA_EasyPay) && par.Right__c == AMS_Utils.PORTAL_APP_ACCESS_GRANTED) {
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
		} else if(account.ANG_IEP_Status_FF__c == AMS_Utils.NO_IEP_ACCOUNT) {
			List<Profile> profileList = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];

			Boolean isAdmin = false;

			if (!profileList.isEmpty() && profileList[0].Name.contains('dmin')){
				isAdmin = true;
			}

			// A user has accecss to easypay when:
			// If the IEP status is open
			// If the IEP status is not open and is an admin and the account is HO or HE
			if(isAdmin && contact.Authorized_Signatory__c && (account.Location_Type__c == AMS_Utils.HO || account.Location_Type__c == AMS_Utils.HE|| (account.Location_Type__c == AMS_Utils.AO && account.Status__c == AMS_Utils.ACC_S4_LISTED))) {
				this.iepLink = availableServicesLink;
			} else {
				if(account.Location_Type__c == AMS_Utils.HO || account.Top_Parent__r.Location_Type__c == AMS_Utils.HO){
					this.modalErrorMessage = Label.ANG_ISSP_IEP_AuthorisedSignatory_HO_auth_msg;
				} else if(account.Location_Type__c == AMS_Utils.HE || account.Top_Parent__r.Location_Type__c == AMS_Utils.HE){
					this.modalErrorMessage = Label.ANG_ISSP_IEP_AuthorisedSignatory_HE_auth_msg;
				} else if (account.Location_Type__c == AMS_Utils.AO || account.Top_Parent__r.Location_Type__c == AMS_Utils.AO) {
					this.modalErrorMessage = Label.ANG_ISSP_IEP_AuthorisedSignatory_AO_auth_msg;
				}

				this.iepLink = '#';
			}

			this.iepLinkLabel = Label.ANG_ISSP_Open_IATA_EasyPay_Account;
		}

		String modalMessageAux = fetchIEPModalMessageLabel(this.account.Location_Class__c, this.account.IATA_ISO_Country__c);

		if(String.isNotBlank(modalMessageAux)){
			this.iepLink = '#';
			this.modalErrorMessage = modalMessageAux;
		}
	}

	private String fetchIEPModalMessageLabel(String locationClass, Id isoCountry) {
		for (AMS_Country_Specific_Attribute__c attribute: [SELECT Id, IEP_Model_Banking_Message__c, Location_Class__c
														FROM AMS_Country_Specific_Attribute__c
														WHERE RecordTypeId = :RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'EasyPay_Model_Config')
															AND IATA_ISO_Country__c = :isoCountry
															ORDER BY Location_Class__c DESC NULLS LAST]) {

			if (attribute.Location_Class__c == null || attribute.Location_Class__c == locationClass) {
				return AMS_Utils.getCustomLabel(attribute.IEP_Model_Banking_Message__c);
			}
		}

		return null;
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

	private void calculateAuthorizationFlags(Id accountId) {
		for(Agency_Authorization__c auth : [SELECT Id, ANG_FormOfPayment_ID__c
										FROM Agency_Authorization__c
										WHERE Account__c = :accountId
										AND (Status__c = :AMS_Utils.ACTIVE OR Status__c = :AMS_Utils.AUTHORIZED)]) {
			if(auth.ANG_FormOfPayment_ID__c == AMS_Utils.CA && !this.isCashless) {
				this.isCashFlag = true;
				this.authQuantity++;
			}

			if(auth.ANG_FormOfPayment_ID__c == AMS_Utils.CC) {
				this.isCreditCardFlag = true;
				this.authQuantity++;
			}

			if(auth.ANG_FormOfPayment_ID__c == AMS_Utils.BOP) {
				this.isBOPFlag = true;
				this.authQuantity++;
			}
		}
	}
}
