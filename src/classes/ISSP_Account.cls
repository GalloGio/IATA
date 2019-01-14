public class ISSP_Account{

    public List<Account> AccountList {get;set;}
    public List<Contact> ContactList {get;set;}
    public Account Account {get;set;}
    public string noirr {get;private set;}
    public boolean isIATAAgencyAcct {get;set;}
    public boolean isIATAAirlineAcct {get;set;}

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    
    public ISSP_Account( ){
        isIATAAgencyAcct = false;
        isIATAAirlineAcct = false;
    
        string AccountId = Apexpages.currentPage().getParameters().get('id');

        AccountList =new List<Account>([select id , Name , Field_Head_Office__c ,Quality__c , Last_SIDRA_Date__c, BillingCountry, BillingCity, BillingStreet, ShippingCountry ,ShippingCity ,ShippingStreet, Phone , Fax , 
                                                Admission_Date__c , TradeName__c , Airline_designator__c, Sector__c, Category__c, Location_Type__c, IATACode__c, IATA_ISO_Country__r.Name, Accumulated_Irregularities__c,
                                                Membership_status__c, Fin_statements_submission_deadline__c, ICAO_designator__c
                                                   From Account
                                                   Where Id =: AccountId ]);
                                                    
        if(AccountList != null && AccountList.size() > 0){
            Account= AccountList [0]; 
        }
        
        if (Account.Sector__c=='Cargo Agent' || Account.Sector__c=='Travel Agent')
            isIATAAgencyAcct = true;
        
        if (Account.Sector__c=='Airline')
            isIATAAirlineAcct = true;
        
        noirr = string.valueof(Account.Accumulated_Irregularities__c);
        
        ContactList =new List<Contact>([select id ,Account.Name, Name , Email , Phone ,OtherPhone, User_Portal_Status__c , Fax, MobilePhone, ISO_Country__c, ISSP_Account_Name__c, Account_HQ_BO__c, IATA_Code__c, Title, Membership_Function__c 
                                                   From Contact
                                                   Where AccountId =: Account.Id]);
    }
    
   
    
}