public with sharing class vfIECHistQuotes extends IECPageController {

	public List<zqu__Quote__c> lstQuotes { get; private set; }
	public zqu__Quote__c oSelectedQuote { get; private set; }
	public String sSelectedQuoteId { get; set; }
	public boolean bShowDownloadPDF { get; set; }
	public Product_Rate_Plan_Information__c oRatePlanInfo { get; private set; }

	private static String sWebServiceSessionId = null;

	public String sUserSessionId {
		get {


			if (sWebServiceSessionId == null) {

				if (!Test.isRunningTest()) {
					// login with a user to have a sessionID (IEC Customer can't generate the PDF because of permission issues)
					partnerSoapSforceCom.Soap spWs = new partnerSoapSforceCom.Soap();
					spWs.endpoint_x = IEC_Settings__c.getOrgDefaults().SF_Partner_Web_Service_endpoint__c;
					partnerSoapSforceCom.LoginResult loginResult = spWs.login(IEC_Settings__c.getOrgDefaults().IEC_Web_Service_Username__c, IEC_Settings__c.getOrgDefaults().IEC_Web_Service_Password__c);

					sWebServiceSessionId = loginResult.SessionID;
				}
				else
					sWebServiceSessionId = IECUtil.NewGuid();
			}

			return sWebServiceSessionId;
		}
	}

	public String sQuoteTemplateZuoraId {
		get {
			return IEC_Settings__c.getOrgDefaults().Quote_Template_Zuora_ID_New_Subscription__c;
		}
	}

	public String sZuoraSessionID {
		get {
			return IECZuoraHelper.ZuoraSessionID;
		}
	}

	public String sZuoraGenerateQuotePDFURL {
		get {
			return IEC_Settings__c.getOrgDefaults().Zuora_Generate_Quote_PDF_URL__c;
		}
	}

	public String sServerURL {
		get {
			return IEC_Settings__c.getOrgDefaults().Server_API_URL__c;
		}
	}

	/**
	 * Constructor
	 */
	public vfIECHistQuotes() {
		try {
			lstQuotes = null;
			oSelectedQuote = null;
			sSelectedQuoteId = null;
			oRatePlanInfo = null;
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
		}
	}

	/**
	 * after page loads, retreive the list of quotes related to the customer
	 */
	public Pagereference pageLoad() {
		try {
			// first check if the user is logged in
			if (IECUserManager.isUserLoggedIn() == false) {
				//Pagereference prLogin = Page.IECLogin;
				//prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
				//prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
				Pagereference prLogin = Page.IEC_Login;
				prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, ApexPages.currentPage().getUrl());
				prLogin.setRedirect(true);
				return prLogin;
			}
			else {
				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();

				//Query for the active subscription list related to the current logged user
				lstQuotes = IECQuoteManager.getQuotesByContactId(loggedCustomer.RelatedContact.Id);
				if (lstQuotes != null && lstQuotes.size() == 0) lstQuotes = null;
			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
		}
		return null;
	}

	/**
	 * Selects a quote from the list
	 */
	public Pagereference selectQuote() {
		oSelectedQuote = null;
		oRatePlanInfo = null;

		try {
			if (String.isBlank(sSelectedQuoteId))
				throw new IECApplicationException('No quote selected');

			// search for quote in the list based on the id
			for(zqu__Quote__c oQuote : lstQuotes) {
				if (oQuote.Id == sSelectedQuoteId) {
					oSelectedQuote = oQuote;
					bShowDownloadPDF = (oQuote.Quote_Validation_Status__c == null || oQuote.Quote_Validation_Status__c == 'Confirmed');
					break;
				}
			}

			if (oSelectedQuote == null)
				throw new IECApplicationException('No Quote found for id ' + sSelectedQuoteId);
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}
		return null;
	}
}
