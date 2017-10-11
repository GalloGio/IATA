public with sharing class AMS_AccreditationContactLookUpController
{
	public String searchString {get;set;}
	public String firstName {get;set;}
	public String lastName {get;set;}
	public String email {get;set;}
	public String accountName {get;set;}
	public String iataCode {get;set;}
	public String objectType {get;set;}
	private String rowNumber;
	private String fieldType;
	public List<ContactPersonWrapper> wrapper {get; set;}
	public List<AccountWrapper> accWrapper {get; set;}
	
	
	public AMS_AccreditationContactLookUpController()
	{
		objectType = System.currentPageReference().getParameters().get('object');
	  	// get the current search string
		searchString = System.currentPageReference().getParameters().get('fieldId');
		firstName = System.currentPageReference().getParameters().get('firstName');
		lastName = System.currentPageReference().getParameters().get('lastName');
		email = System.currentPageReference().getParameters().get('email');
		accountName = System.currentPageReference().getParameters().get('legalName');
		iataCode = System.currentPageReference().getParameters().get('iataCode');
		System.debug('***iataCode: ' + iataCode);
		
		wrapper = new List<ContactPersonWrapper>();
		accWrapper = new List<AccountWrapper>();
		
		
		if(objectType != 'account' && objectType != 'contact')
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Object type (Account or Contact) needs to be defined.'));
			return;
		}
		else if(objectType == 'account')
		{
			
			List<Account> accountList = new List<Account>();
			List<Account> accountListByIataCode = new List<Account>();
			Set<Id> accountListAux = new Set<Id>();

			if((accountName == null || accountName == '') && (iataCode == null || iataCode == ''))
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please fill in the Legal / Registered Name before searching.'));
				return;
			}

			if((accountName != null && accountName != '') && (iataCode != null && iataCode != ''))
			{
				accountList = [select id, Name, Legal_Name__c, IATACode__c from Account where RecordType.DeveloperName = 'IATA_Agency' and (Name like :accountName + '%' or Legal_Name__c like :accountName + '%') and IATACode__c like :iataCode + '%'];
				if(accountList.isEmpty())
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please fill in the Legal / Registered Name with valid values before searching.'));
					return;
				}
			}
 
 			if(accountList.isEmpty())
 			{
 				if(accountName != null && accountName != '')
				{
					accountList = [select id, Name, Legal_Name__c, IATACode__c from Account where RecordType.DeveloperName = 'IATA_Agency' and (Name like :accountName + '%' or Legal_Name__c like :accountName + '%')];
					for(Account ac : accountList)
					{
						accountListAux.add(ac.Id);
					}
				}
				
				if(iataCode != null && iataCode != '')
				{
					accountListByIataCode = [select id, Name, Legal_Name__c, IATACode__c from Account where RecordType.DeveloperName = 'IATA_Agency' and IATACode__c like :iataCode + '%'];
					for(Account acc : accountListByIataCode)
					{
						if(!accountListAux.contains(acc.Id))
						{
							accountList.add(acc);
						}
					}
				}
 			}

			if(accountList.size() == 0)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Selected values did not produce any results.'));
				return;
			}

			if(accountList.size() > 0)
			{
				AccountWrapper aw;
				for(Account acc : accountList)
				{
					aw = new AccountWrapper(acc.Id, acc.Name, acc.Legal_Name__c, acc.IATACode__c);
					accWrapper.add(aw);
				}
			}
		}
		else if(objectType == 'contact')
		{
			if(email == '' && (firstName == '' || lastName == ''))
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please fill in at least First and Last Name or an email address to perform the contact lookup.'));
				return;
			}
			
			String[] values = searchString.split(':');
			rowNumber = values[0];
			fieldType = values[1];
			
			List<Contact> contactList = new List<Contact>();
			List<AMS_Person__c> personList = new List<AMS_Person__c>();
			
			if(firstName != null && lastName != null && email != null)
			{
				contactList = AMS_AccreditationContactHelper.findContactsByNameOrEmail(firstName, lastName, email);
				personList = AMS_AccreditationContactHelper.findPersonsByNameOrEmail(firstName, lastName, email);
			}
			if(contactList.size() > 0)
			{
				ContactPersonWrapper w;
				for(Contact c : contactList)
				{
					w = new ContactPersonWrapper(c.Id, c.FirstName, c.LastName, c.Email, c.Phone);
					wrapper.add(w);
				}
			}
			if(personList.size() > 0)
			{
				ContactPersonWrapper w;
				for(AMS_Person__c p : personList)
				{
					w = new ContactPersonWrapper(p.Id, p.First_Name__c, p.LastName__c, p.Email__c, p.Phone__c);
					wrapper.add(w);
				}
			}
			if(wrapper.size() == 0)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Selected values did not produce any results.'));
				return;
			}
		}
	}
	
	
	public class ContactPersonWrapper
	{
        public String fName {get; set;}
        public String lName {get; set;}
        public String emailAddress {get; set;}
        public String phone {get; set;}
        public String recordId {get; set;}
        
        public ContactPersonWrapper(Id id, String fName, String lName, String email, String phone)
        {
            this.recordId = id;
            this.fName = fName;
            this.lName = lName;
            this.emailAddress = email;
            this.phone = phone;
        }
    }
    
    public class AccountWrapper
	{
        public String name {get; set;}
        public String legalName {get; set;}
        public String registrationNumber {get; set;}
        public String iataCode {get; set;}
        public String recordId {get; set;}
        
        public AccountWrapper(Id id, String accName, String accLegalName, String accIataCode)
        {
            this.recordId = id;
            this.name = accName;
            this.legalName = accLegalName;
            this.iataCode = accIataCode;
        }
    }
}