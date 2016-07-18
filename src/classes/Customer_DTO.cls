public class Customer_DTO 
{
	private static Customer_DTO singleton = null;

	public User sfUser { get; set; }
    public Contact sfContact { get; set; }
    public Account sfAccount { get; set; }
    public String customerType { get; set; }

    public Address_DTO soldTo{get;set;}
    public Address_DTO billTo{get;set;}
    public List<Address_DTO> shipTos{get;set;}

    public Zuora__CustomerAccount__c zBillingAccount { get{
        if(zBillingAccount == null){
            Map<Id,Zuora__CustomerAccount__c> sfAccId_ZcustAccount = CustomerAccount_Sel.getZuoraCustmerAccount(new Set<Id>{sfContact.Id});
            zBillingAccount = (Test.isRunningTest()) ? IECZuoraHelper.getBillingAccountByContactId(sfContact.Id) : sfAccId_ZcustAccount.get(sfContact.Id);
        }
        return zBillingAccount;
    } set; }

    public Zuora.zObject zAccount{get{
        if(zAccount == null){
            zAccount = (Test.isRunningTest()) ? IECTestUtil.createSampleZuoraAccount('99999', sfAccount.Id, sfContact.Id) : IECZuoraHelper.getZuoraAccountBySFAccountId(sfAccount.Id, sfContact.Id);   
        }
        return zAccount;
    }set;}

    public List<IEC_CreditCard_DTO> creditCards {get{
        if(creditCards == null){
            loadCreditCards();
        }
        return creditCards;
    }set;}

    public void loadCreditCards()
    {
        creditCards = new List<IEC_CreditCard_DTO>(); 

        try
        {
            List<Zuora.zObject> z_creditCards = new List<Zuora.zObject>();
            
            if (!Test.isRunningTest()) {
                if(zAccount != null) z_creditCards = IECSubscriptionManager.getCreditCardsByAccountZId((String)zAccount.getValue('Id'));
            }
            else {
                z_creditCards.add(IECTestUtil.createSampleZuoraPaymentMethod('111', (String)zAccount.getValue('Id'), 2010, 1));
                z_creditCards.add(IECTestUtil.createSampleZuoraPaymentMethod('222', (String)zAccount.getValue('Id'), 2100, 1));
                z_creditCards.add(IECTestUtil.createSampleZuoraPaymentMethod('333', (String)zAccount.getValue('Id'), 2200, 1));
            }

            for(Zuora.zObject zCard : z_creditCards)
            {
                creditCards.add(new IEC_CreditCard_DTO(zAccount, zCard));
            }
        }
        catch(Exception ex)
        {
            System.debug('Error fetching credit cards::'+ex.getMessage());
        }   

    }

    public void loadActiveCreditCards()
    {
        creditCards = new List<IEC_CreditCard_DTO>(); 

        List<Zuora.zObject> z_creditCards = new List<Zuora.zObject>();
        
        if (!Test.isRunningTest()) {
            if(zAccount != null) z_creditCards = IECSubscriptionManager.getCreditCardsByAccountZId((String)zAccount.getValue('Id'));
        }
        else {
            z_creditCards.add(IECTestUtil.createSampleZuoraPaymentMethod('111', (String)zAccount.getValue('Id'), 2010, 1));
            z_creditCards.add(IECTestUtil.createSampleZuoraPaymentMethod('222', (String)zAccount.getValue('Id'), 2100, 1));
            z_creditCards.add(IECTestUtil.createSampleZuoraPaymentMethod('333', (String)zAccount.getValue('Id'), 2200, 1));
        }

        for(Zuora.zObject zCard : z_creditCards)
        {
            IEC_CreditCard_DTO cc = new IEC_CreditCard_DTO(zAccount, zCard);
           
            if(!cc.isExpired) 
                creditCards.add(cc);
        }
    }


    public Boolean canPayByICH()
    {
        // first validate if the customer is part of a Member Airline account
        if (sfAccount.Customer_Type__c != IECConstants.Account_ClientType_MemberAirline) return false;
            
        
        // check if Parent Account have access to ICH
        if (sfAccount.ParentId != null) 
        {
            Account oParentAccount = IECUserManager.getAccountById(sfAccount.ParentId);
            if (oParentAccount != null && oParentAccount.ICH_Member__c) return true;
        }
        
        // Make sure that there is a SAP Account configured
        List<SAP_Account__c> lstSAPAcc = [SELECT SAP_ID__c FROM SAP_Account__c WHERE Account__c = :sfAccount.Id AND  GDP__c  = true ];
        if (lstSAPAcc.size() == 0 || lstSAPAcc.get(0).SAP_ID__c == null) return false;
        
        // check if Account have access to ICH
        return (sfAccount != null && sfAccount.ICH_Member__c);
    }

    public static Customer_DTO getLoggedCustomer()
    {
    	//-- If logged user 
    	if(UserInfo.getUserType() == 'PowerPartner')
    	{
    		if(singleton == null)
	    	{
	    		Customer_DTO customer = getCustomerByUser(UserInfo.getUserId());  
                
                //-- Build Customer addresses 
                setCustomerAddresses(customer);
				singleton = customer; 
	    	}

	    	return singleton;
    	}
    	//-- Non logged user 
    	else
    	{
    		return null; 
    	}	
    }

    public static Customer_DTO getCustomerByUser(Id userId)
    {
        User_Sel uSelector = new User_Sel(); 
        Account_Sel aSelector = new Account_Sel(); 

        Customer_DTO customer = new Customer_DTO(); 
            customer.sfUser = uSelector.getUserDetails(userId); 
            customer.sfContact = Contact_Sel.getContactById(new Set<Id> {customer.sfUser.ContactId}).get(customer.sfUser.ContactId);
            customer.sfAccount = aSelector.getAccountById(customer.sfContact.AccountId);
            customer.customerType = customer.sfAccount.Customer_Type__c;

        return customer;
    }


    public static void setCustomerAddresses(Customer_DTO customer)
    {
        Location_Sel lSelector = new Location_Sel();
        Id contactId = customer.sfContact.Id;
                
        Location__c soldToLocation = lSelector.getSoldToLocationByContactId(new Set<Id>{contactId}).get(contactId);
        customer.soldTo = Address_DTO.format2DTO(soldToLocation);

        List<Location__c> locations =  lSelector.getContactsLocations(new Set<Id>{contactId}).values();
        for(Location__c loc : locations)
        {
            if(loc.Type__c == IECConstants.BILLTO)
            {
                customer.billTo = Address_DTO.format2DTO(loc);
            }
            else if(loc.Type__c == IECConstants.SHIPTO)
            {
                if(customer.shipTos == null)
                {
                    customer.shipTos = new List<Address_DTO>();
                }
                
                customer.shipTos.add(Address_DTO.format2DTO(loc));
            }
        }
    }

    public static void saveBillToAddress(Customer_DTO customer)
    {
        update customer.sfContact; 

    }
}