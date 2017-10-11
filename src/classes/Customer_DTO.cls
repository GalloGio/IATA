public class Customer_DTO 
{
    // Ecommerce Enhancements
    private static Boolean isLoginEvent = false;
    private static Customer_DTO loginEventSingleton = null;
    private static Id loginContactId = null;

    public static void setLoginEvent(Id contactId) {
        isLoginEvent = true;
        loginContactId = contactId;
    }

    public static void resetLoginEvent() {
        isLoginEvent = false;
        loginContactId = null;
    }

    // Ecommerce Enhancements end

    private static Customer_DTO singleton = null;

    public User sfUser { get; set; }
    public Contact sfContact { get; set; }
    public Account sfAccount { get; set; }
    public String customerType { get; set;  }

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
        //if (sfAccount.Customer_Type__c != IECConstants.Account_ClientType_MemberAirline) return false;
        
        //*** not eligible if not portal user
        if (sfContact == null) return false;
        
        //*** get information on contact and account and parent account to determine if eligible
        List<Contact> checks = [select User_IECPortal_Status__c, Account.ParentId, Account.Industry, Account.IATACode__c
                              , Account.RecordType.DeveloperName, Account.Membership_status__c, Account.ICH_Member__c, Account.ACH_Member__c
                              , Account.Parent.RecordType.DeveloperName, Account.Parent.Membership_status__c, Account.Parent.ICH_Member__c, Account.Parent.ACH_Member__c
                         from Contact
                         where Id = :sfContact.Id limit 1];

        if(checks.isEmpty()) return false; 

        Contact check = checks[0];

        
        //*** not eligile if contact is not approved
        if (check.User_IECPortal_Status__c != IECConstants.APPROVED_CONTACT_STATUS) return false;
        
        //*** check if account is eligible
        Boolean isAccountEligible = false;
        if (check.Account.RecordType.DeveloperName == IECConstants.Account_RecordType_BranchAirline || check.Account.RecordType.DeveloperName == IECConstants.Account_RecordType_Airline )
        {
            if ( check.Account.ParentId != null && (check.Account.Parent.ICH_Member__c == true || check.Account.Parent.ACH_Member__c == true))      
                return true;
            if(check.Account.ICH_Member__c == true || check.Account.ACH_Member__c == true)
                return true;
        }
        else
        {      
            if(check.Account.ICH_Member__c == true || check.Account.ACH_Member__c == true)
                return true;
    }
    return false;
}

/*
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
*/

    // Ecommerce Enhancements - new version to hook on login event
    public static Customer_DTO getLoggedCustomer()
    {
        if (isLoginEvent == false) {
            // Existing behaviour (default)
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
        } else {
            // New Behaviour, create simulation of logged in user on login event
            if (loginEventSingleton == null) {
                Customer_DTO customer = getCustomerByContact(loginContactId);

                setCustomerAddresses(customer);
                loginEventSingleton = customer;
            }

            return loginEventSingleton;
        }
    }

    public static Customer_DTO getCustomerByContact(Id contactId) {
        List<User> userList = [SELECT Id, ContactId FROM User WHERE ContactId = :contactId];

        if (userList != null && userList.isEmpty() == false) {
            User user = userList[0];

            return getCustomerByUser(user.Id);
        } else {
            return null;
        }
    }

    // Ecommerce Enhancements end

    public static Customer_DTO getCustomerByUser(Id userId)
    {
        User_Sel uSelector = new User_Sel(); 
        Account_Sel aSelector = new Account_Sel(); 

        Customer_DTO customer = new Customer_DTO(); 
            customer.sfUser = uSelector.getUserDetails(userId); 
            customer.sfContact = Contact_Sel.getContactById(new Set<Id> {customer.sfUser.ContactId}).get(customer.sfUser.ContactId);
            customer.sfAccount = aSelector.getAccountById(customer.sfContact.AccountId);
            customer.customerType = customer.sfAccount.Customer_Type__c;
            if (String.isBlank(customer.customerType))
                customer.customerType = IECConstants.PARAM_CUSTOMERTYPE_DEFAULT;

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