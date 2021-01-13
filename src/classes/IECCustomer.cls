/**
 * Represents a logged in IEC customer (linked to a Contact)
 */
public without sharing class IECCustomer { 

    private static IECCustomer singleton = null;
    private List<Zuora.zObject> m_creditCards = null;
    private List<Zuora.zObject> m_subscriptions = null;
    private List<Zuora.zObject> m_paymentMethods = null;
    private List<Zuora__ZInvoice__c> m_invoices = null;
    private List<Zuora__Payment__c> m_payments = null;
    private IECUtil.PaymentMethodType m_DefaultPaymentMethod = null;
    private String m_clientType = null;
    private Boolean bClientTypeLoaded = false;

    public Account RelatedAccount { get; private set; }
    public Contact RelatedContact { get; private set; }
    public Zuora__CustomerAccount__c RelatedBillingAccount { get; private set; }
    public User RelatedUser { get; private set; }
    //public Boolean IsMember { get; private set; }
    public Boolean AccountExistsInZuora { get; private set; }
    public Zuora.zObject RelatedZuoraAccount { get; private set; }
    
    /**
     * Default payment method of the customer
     */
    public IECUtil.PaymentMethodType DefaultPaymentMethodType { 
        get {
            if (AccountExistsInZuora == false)
                return null;
            else {
                if (m_DefaultPaymentMethod == null) {
                    analysePaymentMethods();
                }
                return m_DefaultPaymentMethod;
            }
        }
        private set; 
    }

    /**
     * List of Payment methods associated to the customer
     */
    public List<Zuora.zObject> PaymentMethods { 
        get {
            if (AccountExistsInZuora == false)
                return null;
            else {
                if (m_paymentMethods == null) {
                	if (!Test.isRunningTest()) {
                    	m_paymentMethods = IECSubscriptionManager.getPaymentMethodsFromZuora((String)RelatedZuoraAccount.getValue('Id'));
                	}
                	else {
                		m_paymentMethods = new List<Zuora.zObject>();
                		m_paymentMethods.add(IECTestUtil.createSampleZuoraPaymentMethod('111', (String)RelatedZuoraAccount.getValue('Id'), 2010, 1));
                		m_paymentMethods.add(IECTestUtil.createSampleZuoraPaymentMethod('222', (String)RelatedZuoraAccount.getValue('Id'), 2100, 1));
                		m_paymentMethods.add(IECTestUtil.createSampleZuoraPaymentMethod('333', (String)RelatedZuoraAccount.getValue('Id'), 2200, 1));
                	}
                    analysePaymentMethods();
                }
                return m_paymentMethods;
            }
        }
        private set;
    }
    
    /**
     * List of Credit Cards associated to the customer
     */
    public List<Zuora.zObject> CreditCards { 
        get {
            if (AccountExistsInZuora == false)
                return null;
            else {
                if (m_creditCards == null) {
                	if (!Test.isRunningTest()) {
	                    m_creditCards = IECSubscriptionManager.getCreditCardsByAccountZId((String)RelatedZuoraAccount.getValue('Id'));
                	}
                	else {
                		m_creditCards = new List<Zuora.zObject>();
                		m_creditCards.add(IECTestUtil.createSampleZuoraPaymentMethod('111', (String)RelatedZuoraAccount.getValue('Id'), 2010, 1));
                		m_creditCards.add(IECTestUtil.createSampleZuoraPaymentMethod('222', (String)RelatedZuoraAccount.getValue('Id'), 2100, 1));
                		m_creditCards.add(IECTestUtil.createSampleZuoraPaymentMethod('333', (String)RelatedZuoraAccount.getValue('Id'), 2200, 1));
                	}
                }
                return m_creditCards;
            }
        }
        private set;
    }
    
    /**
     * List of Invoices associated to the customer
     */
    public List<Zuora__ZInvoice__c> Invoices { 
        get {
            if (AccountExistsInZuora == false)
                return null;
            else {
                if (m_invoices == null) {
                    m_invoices = IECSubscriptionManager.getInvoicesByBillingAccount(RelatedBillingAccount.Id, true);
                }
                return m_invoices;
            }
        }
        private set; 
    }
    
    /**
     * List of Payments associated to the customer
     */
    public List<Zuora__Payment__c> Payments { 
        get {
            if (AccountExistsInZuora == false)
                return null;
            else {
                if (m_payments == null) {
                    m_payments = IECSubscriptionManager.getPaymentsByBillingAccount(RelatedBillingAccount.Id);
                }
                return m_payments;
            }
        }
        private set; 
    }
    
    /**
     *
     */
    public String ClientType { 
    	get {
    		if (bClientTypeLoaded == false) {
    			m_clientType = determineClientType();
    			bClientTypeLoaded = true;
    		}
    		return m_clientType;
    	}
    }
    
    /**
     * Private constructor
     * 2015-11-09 Thai: make public in order to allow CSR initiate customer for different actions
     */
    public IECCustomer(Id ContactId) {
        
        RelatedContact = IECUserManager.getContactById(ContactId);
        RelatedAccount = IECUserManager.getAccountById(RelatedContact.AccountId);
        RelatedUser = IECUserManager.getUserByContactId(ContactId);

        if (!Test.isRunningTest()) {
            RelatedZuoraAccount = IECZuoraHelper.getZuoraAccountBySFAccountId(RelatedContact.AccountId, RelatedContact.Id);
            RelatedBillingAccount = IECZuoraHelper.getBillingAccountByContactId(ContactId); 
        }
        else {
        	RelatedZuoraAccount = IECTestUtil.createSampleZuoraAccount('99999', RelatedContact.AccountId, RelatedContact.Id);
        	RelatedBillingAccount = IECZuoraHelper.getBillingAccountByContactId(ContactId); 
        }

        AccountExistsInZuora = (RelatedZuoraAccount != null);
        
    }
    
    /**
     * Returns an IECCustomer representing the customer (if logged in).
     * Returns null if not logged in.
     */
    public static IECCustomer getCurrentIECCustomer() {
        
        Id idContact = IECUserManager.getContactId();
        if (idContact == null)
            return null;
        else {
            if (singleton == null) 
                singleton = new IECCustomer(IECUserManager.getContactId());
            return singleton;
        }
    }

    public Boolean refreshZuoraAccount() {
        try {
            if (RelatedZuoraAccount != null) {
            	if (!Test.isRunningTest())
                	RelatedZuoraAccount = IECZuoraHelper.getZuoraAccountBySFAccountId(RelatedContact.AccountId, RelatedContact.Id);
                return true;
            }
            return false;
        }
        catch (Exception ex) {
            throw ex;
        }
    }

    public Boolean refreshRelatedContact() {
        try {
            if (RelatedContact != null) {
               	RelatedContact = IECUserManager.getContactById(RelatedContact.Id);
                return true;
            }
            return false;
        }
        catch (Exception ex) {
            throw ex;
        }
    }
    
    public void refreshZuoraPaymentMethods() {
        try {
			// Force payment methods to reload
			m_creditCards = null;
			m_paymentMethods = null;
        }
        catch (Exception ex) {
            throw ex;
        }
    }
    
    // Used only for simulating adding new card for test purposes
    public void addTestCreditCard(Zuora.zObject card) {
    	if (CreditCards != null)
    		m_creditCards.add(card);    	
    }
    
    /**
     * Checks if the customer can pay by ICH based on its account or parent account
     * @return True if the customer can pay by ICH
     */
    public Boolean canPayByICH() {
    	try {
    		// first validate if the customer is part of a Member Airline account
    		if (ClientType != IECConstants.Account_ClientType_MemberAirline)
    			return false;
    		
    		// check if Parent Account have access to ICH
    		if (RelatedAccount.ParentId != null) {
    			Account oParentAccount = IECUserManager.getAccountById(RelatedAccount.ParentId);
    			if (oParentAccount != null && oParentAccount.ICH_Member__c)
    				return true;
    		}
    		
			// Make that there is a SAP Account configured
			List<SAP_Account__c> lstSAPAcc =
				[SELECT SAP_ID__c
				FROM SAP_Account__c
				WHERE Account__c = :RelatedAccount.Id AND  GDP__c  = true ];
					//AND SAP_Account_type__c = :IECConstants.SAPAccount_InvoiceType_Invoices];
			
			if (lstSAPAcc.size() == 0 || lstSAPAcc.get(0).SAP_ID__c == null) {
    			return false;
    		}    		
    		
    		// check if Account have access to ICH
    		Account oAccount = IECUserManager.getAccountById(RelatedAccount.Id);
    		return (oAccount != null && oAccount.ICH_Member__c);
    	}
		catch (Exception ex) {
			throw new IECApplicationException('Error while validating ICH availability: ' + ex.getMessage());
		}
    }

    /////////////////////////////////////////////////////
    // Private methods
    
    private void analysePaymentMethods() {
        Boolean defaultPMFound = false;
        for (Zuora.zObject pm : PaymentMethods) {
            IECUtil.PaymentMethodType pmType = IECUtil.toPaymentMethodEnum((String)pm.getValue('Type'));
            
            // flag default payment method
            if ((String)pm.getValue('Id') == (String)RelatedZuoraAccount.getValue('DefaultPaymentMethodId')) {
                m_DefaultPaymentMethod = pmType;
                defaultPMFound = true;
            }
        }
        
        if (defaultPMFound == false) {
            if ((String)RelatedZuoraAccount.getValue('DefaultPaymentMethodId') == IECConstants.PaymentMethod_BankTransfer_ZuoraID)
                m_DefaultPaymentMethod = IECUtil.PaymentMethodType.BANK_TRANSFER;
            else if ((String)RelatedZuoraAccount.getValue('DefaultPaymentMethodId') == IECConstants.PaymentMethod_ICH_ZuoraID)
                m_DefaultPaymentMethod = IECUtil.PaymentMethodType.ICH;
        }

        return;
    }
    
    private String determineClientType() {
    	try {
    		// 2016-04-26: Samy: Replace logic for determining Client Type by using logic from Phase 3A
            //String sCustomerType = User_Sel.getCustomerType(UserInfo.getUserId());
    		String sCustomerType = User_Sel.getCustomerType((UserInfo.getUserType() == 'PowerPartner') ? UserInfo.getUserId() : RelatedContact.Id);

    		return (sCustomerType == 'Member Airline') ? IECConstants.Account_ClientType_MemberAirline : IECConstants.Account_ClientType_ThirdParty;

		}
		catch (Exception ex) {
			throw new IECApplicationException('Error while determining client type: ' + ex.getMessage());
		}
    }
}