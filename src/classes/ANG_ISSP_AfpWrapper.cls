public with sharing class ANG_ISSP_AfpWrapper {
	private static final String NO = 'fa fa-times fa-2x show wrong';
	private static final String YES = 'fa fa-check fa-2x show check';

	public Boolean isCashless {get; set;}
	public String isCash {get; set;}
	public String isIEP {get; set;}
	public String isCreditCard {get; set;}
	public String iepLinkLabel {get; set;}
	public String iepLink {get; set;}

	public ANG_ISSP_AfpWrapper(Contact contact, List<Agency_Authorization__c> authorizations, List<Portal_Application_Right__c> services) {
		this.isCash = NO;
		this.isIEP = NO;
		this.isCreditCard = NO;

		System.debug(LoggingLevel.ERROR, 'contact.Account.ANG_Accreditation_Model__c--->' + contact.Account.ANG_Accreditation_Model__c);

		this.isCashless = (contact.Account.ANG_Accreditation_Model__c != null && contact.Account.ANG_Accreditation_Model__c == 'Cashless');

		if(authorizations != null) {
			for(Agency_Authorization__c auth : authorizations) {
				if(auth.ANG_FormOfPayment_ID__c == 'CA') {
					this.isCash = YES;
				}
				if(auth.ANG_FormOfPayment_ID__c == 'CC') {
					this.isCreditCard = YES;
				}
			}
		}
		if(contact.Account.ANG_IEP_Status_FF__c == Ams_Utils.OPEN) {
			this.isIEP = YES;
			for(Portal_Application_Right__c par: services) {
				if(par.Application_Name__c.startsWith('IATA EasyPay') && par.Right__c == 'Access Granted') {
					this.iepLinkLabel = 'IATA EasyPay';
					this.iepLink = par.Application_Start_URL__c;
					break;
				}
			}
		} else if(contact.Account.ANG_IEP_Status_FF__c == Ams_Utils.NO_IEP_ACCOUNT) {
			this.iepLinkLabel = System.Label.ANG_ISSP_Open_IATA_EasyPay_Account;
			this.iepLink = '/ISSP_AvailableServices?MainNav=Services&subNav=Access&mid=M3S1';
		}
	}
}