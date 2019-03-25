/*
	Class Name: ISSP_AMC_EntityContactData

	Copyright @Right IT Services

	Purpose: Controller Class for ISSP_AMC_EntityContactData.component

	VERSION  	AUTHOR				DATE    		DETAIL/CHANGE REFERENCE
 	1.0		  	João Ferreira		11-09-2018   	INITIAL DEVELOPMENT
*/
public class ISSP_AMC_EntityContactData {
	public String strText { get; set; }
	public String searchHocFirstName { get; set; }
	public String searchHocLastName { get; set; }
	public String searchHocEmail { get; set; }
	public String searchHobFirstName { get; set; }
	public String searchHobLastName { get; set; }
	public String searchHobEmail { get; set; }
	public String currentContactId { get; set; }
	public List<Contact> contactList { get; set; }

	
	
	public Participation_Online_Application__c controllerParticipation {
		get {
			return controllerParticipation;
		}
		set {
			controllerParticipation = value;
			fillDefaultParticipationData();
		}
	}

	public List <SelectOption> countryList { 
        get { 
            vfISSP_FAQ2Case faq2Case = new vfISSP_FAQ2Case();
            return faq2Case.countryList;
        } 
    }
    
    public List <SelectOption> salutationListSIS {
        get {
            if(salutationListSIS == null){
                List <SelectOption> optionList = new List <SelectOption>();
            
                Schema.DescribeFieldResult fieldResult = Participation_Online_Application__c.SIS_Salutation__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

                for( Schema.PicklistEntry f : ple){
                    optionList.add(new SelectOption( f.getValue(),f.getLabel()));
                }
                return optionList;
            }
            return salutationListSIS;
        }
    }
    
    public List <SelectOption> salutationListHOC {
        get {
            if(salutationListHOC == null){
                List <SelectOption> optionList = new List <SelectOption>();
            
                Schema.DescribeFieldResult fieldResult = Participation_Online_Application__c.HOC_Salutation__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

                for( Schema.PicklistEntry f : ple){
                    optionList.add(new SelectOption( f.getValue(),f.getLabel()));
                }
                return optionList;
            }
            return salutationListHOC;
        }
    }
    
        public List <SelectOption> salutationListHOB {
        get {
            if(salutationListHOB == null){
                List <SelectOption> optionList = new List <SelectOption>();
            
                Schema.DescribeFieldResult fieldResult = Participation_Online_Application__c.HOB_Salutation__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

                for( Schema.PicklistEntry f : ple){
                    optionList.add(new SelectOption( f.getValue(),f.getLabel()));
                }
                return optionList;
            }
            return salutationListHOB;
        }
    }

    public Account accountRecord {get;set;}

	

	public ISSP_AMC_EntityContactData() {
	}

	public void selectHocContact() {
		
		Contact contactRecord = getContact(currentContactId);
		if(contactRecord != null) {
			controllerParticipation.HOC_Email__c = contactRecord.Email;
			controllerParticipation.HOC_First_Name__c = contactRecord.FirstName;
			controllerParticipation.HOC_Last_Name__c = contactRecord.LastName;
			controllerParticipation.HOC_Phone__c = contactRecord.Phone;
			controllerParticipation.HOC_Salutation__c = contactRecord.Salutation;
			controllerParticipation.HOC_Title__c = contactRecord.Title;
		}
		
	}

	public void selectHobContact() {
		
		Contact contactRecord = getContact(currentContactId);
		if(contactRecord != null) {
			controllerParticipation.HOB_Email__c = contactRecord.Email;
			controllerParticipation.HOB_First_Name__c = contactRecord.FirstName;
			controllerParticipation.HOB_Last_Name__c = contactRecord.LastName;
			controllerParticipation.HOB_Phone__c = contactRecord.Phone;
			controllerParticipation.HOB_Salutation__c = contactRecord.Salutation;
			controllerParticipation.HOB_Title__c = contactRecord.Title;
		}

	}

	private Contact getContact(id contactId) {	
		Contact contactRecord;
		List<Contact> contactList = [
	    			SELECT 
						id, Name, FirstName, LastName, Email, Fax, Phone, Salutation, Title
	        		FROM 
	        			Contact
	            	WHERE 
	            		Id = :contactId
	        		
			];

		if(contactList != null && contactList.size() > 0) {
			contactRecord = contactList.get(0);
		}
		return contactRecord;

	}

	public void addMeToHeadOfficeContact() {
		Contact contactRecord = OneIdProfileCompanySettings.getUserContact();
		controllerParticipation.HOC_Email__c = contactRecord.Email;
		controllerParticipation.HOC_First_Name__c = contactRecord.FirstName;
		controllerParticipation.HOC_Last_Name__c = contactRecord.LastName;
		controllerParticipation.HOC_Phone__c = contactRecord.Phone;
		controllerParticipation.HOC_Salutation__c = contactRecord.Salutation;
		controllerParticipation.HOC_Title__c = contactRecord.Title;
    }

    /*public void searchHeadOfficeContact1() {
    	Contact contactInfo = OneIdProfileCompanySettings.getUserContact();
    	String sFirstName = '%';
    	String sLastName = '%';
    	String sEmail = '%';
    	if(!String.isBlank(searchFirstName)) {
    		sFirstName = '%' + searchFirstName + '%';
    	}
    	if(!String.isBlank(searchLastName)) {
    		sLastName = '%' + searchLastName + '%';
    	}
    	if(!String.isBlank(searchEmail)) {
    		sEmail = '%' + searchEmail + '%';
    	}
   		
    	List<Contact> contactList = [
    			SELECT 
					id, Name, FirstName, LastName, Email, Fax, Phone, Salutation, Title, Account.Name
        		FROM 
        			Contact
            	WHERE 
            		Account.Id = :contactInfo.AccountId 
        		AND
        			FirstName LIKE :sFirstName
        		AND 
        			LastName LIKE :sLastName
        		AND 
        			Email LIKE :sEmail
		];

        this.contactList = contactList;
        
    }*/

    public void searchBillingContact() {
		searchContact(searchHobFirstName, searchHobLastName, searchHobEmail);
		System.debug('JCFF searchHobFirstName ' + searchHobFirstName);
		System.debug('JCFF searchHobLastName ' + searchHobLastName);
		System.debug('JCFF searchHobEmail ' + searchHobEmail);
    }

    public void searchHeadOfficeContact() {
		searchContact(searchHocFirstName, searchHocLastName, searchHocEmail);
		System.debug('JCFF searchHocFirstName ' + searchHocFirstName);
		System.debug('JCFF searchHocLastName ' + searchHocLastName);
		System.debug('JCFF searchHocEmail ' + searchHocEmail);
    }

    public void searchContact(String searchFirstName, String searchLastName, String searchEmail ) {
    	Contact contactInfo = OneIdProfileCompanySettings.getUserContact();
    	String sFirstName = '%';
    	String sLastName = '%';
    	String sEmail = '%';
    	if(!String.isBlank(searchFirstName)) {
    		sFirstName = '%' + searchFirstName + '%';
    	}
    	if(!String.isBlank(searchLastName)) {
    		sLastName = '%' + searchLastName + '%';
    	}
    	if(!String.isBlank(searchEmail)) {
    		sEmail = '%' + searchEmail + '%';
    	}
   		
    	List<Contact> contactList = [
    			SELECT 
					id, Name, FirstName, LastName, Email, Fax, Phone, Salutation, Title, Account.Name
        		FROM 
        			Contact
        		
            	//WHERE 
            		//Account.Id = :contactInfo.AccountId 
        		WHERE
        			FirstName LIKE :sFirstName
        		AND 
        			LastName LIKE :sLastName
        		AND 
        			Email LIKE :sEmail
        		LIMIT 100
		];
		System.debug('JCFF sFirstName ' + sFirstName);
		System.debug('JCFF sLastName ' + sLastName);
		System.debug('JCFF sEmail ' + sEmail);
		System.debug('JCFF contactList ' + contactList.size());
        this.contactList = contactList;
        
    }


    public void addMeToBillingContact() {
		Contact contactRecord = OneIdProfileCompanySettings.getUserContact();
		controllerParticipation.HOB_Email__c = contactRecord.Email;
		controllerParticipation.HOB_First_Name__c = contactRecord.FirstName;
		controllerParticipation.HOB_Last_Name__c = contactRecord.LastName;
		controllerParticipation.HOB_Phone__c = contactRecord.Phone;
		controllerParticipation.HOB_Salutation__c = contactRecord.Salutation;
		controllerParticipation.HOB_Title__c = contactRecord.Title;
    }

    private void fillDefaultParticipationData() {
    	Account accountRecord;
    	Contact contactInfo = OneIdProfileCompanySettings.getUserContact();
    	List<Account> accountList = [
    			SELECT 
					id, Name, CurrencyIsoCode, Email__c, BillingCountry, BillingPostalCode, BillingState, BillingCity
	            	, BillingStreet, ShippingCountry, ShippingPostalCode, ShippingState, ShippingCity, ShippingStreet, ParentId, Region__c
	            	, Customer_Type__c, Default_Payment_Type__c, IATA_ISO_Billing_State__c, IATA_ISO_Country__c, IATA_ISO_Shipping_State__c
	            	, VAT_Number__c, Region_formula__c, SoldTo_Location__c, ICH_Member__c
	            	, IATA_ISO_Country__r.ISO_Code__c, IATA_ISO_Billing_State__r.ISO_Code__c, IATA_ISO_Shipping_State__r.ISO_Code__c 
	            	, Parent.Name, Parent.SoldTo_Location__c, TradeName__c, Legal_name__c
        		FROM 
        			Account
            	WHERE 
            		Id = :contactInfo.AccountId];

		if(accountList != null && accountList.size() > 0) {
			accountRecord = accountList.get(0);

			/*controllerParticipation.AOC_country_of_issue__c = accountRecord.;
			controllerParticipation.AOC_Expiry_Date__c = accountRecord.;
			controllerParticipation.AOC_issue_date__c = accountRecord.;
			controllerParticipation.AOC_Issuing_Authority_Name__c = accountRecord.;
			controllerParticipation.AOC_Schedule_Passenger__c = accountRecord.;
			controllerParticipation.Areas_of_Routes_and_Operations__c = accountRecord.;
			controllerParticipation.Authorized_Areas_of_Operations__c = accountRecord.;*/
			controllerParticipation.Billing_City__c = accountRecord.BillingCity;
			//controllerParticipation.Billing_Contact__c = accountRecord.;
			controllerParticipation.Billing_Country__c = accountRecord.BillingCountry;
			controllerParticipation.Billing_Postal_Zip_code__c = accountRecord.BillingPostalCode;
			controllerParticipation.Billing_State_Province__c = accountRecord.BillingState;
			controllerParticipation.Billing_Street_address_1__c = accountRecord.BillingStreet;
			controllerParticipation.Billing_VAT__c = accountRecord.VAT_Number__c;
			/*controllerParticipation.Issued_an_Author_to_provide_transp__c = accountRecord.;
			controllerParticipation.Has_the_airline_been_issued_an_AOC__c = accountRecord.;
			controllerParticipation.Has_the_airline_the_AOC_in_progress__c = accountRecord.;
			controllerParticipation.Head_Office_Contact_Details__c = accountRecord.;*/
			controllerParticipation.HQ_City__c = accountRecord.ShippingCity;
			controllerParticipation.HQ_Country__c = accountRecord.ShippingCountry;
			controllerParticipation.HQ_Postal_Zip_code__c = accountRecord.ShippingPostalCode;
			controllerParticipation.HQ_State_Province__c = accountRecord.ShippingState;
			controllerParticipation.HQ_Street_address_1__c = accountRecord.ShippingStreet;
			controllerParticipation.HQ_VAT__c = accountRecord.VAT_Number__c;
			if(ISSP_AMC_Location_Identifier.isLoc == false){
				controllerParticipation.IATA_ISO_Country__c = accountRecord.IATA_ISO_Country__c;
			}
			//controllerParticipation.Is_the_billing_address_same_the_HQ__c = accountRecord.;
			controllerParticipation.Legal_Name__c = accountRecord.Legal_name__c;
			//controllerParticipation.Name_of_Issuing_Authority__c = accountRecord.;
			controllerParticipation.Name_of_Organization__c = accountRecord.Name;
			

		}
    }
}
