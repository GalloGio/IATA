public with sharing class ISSP_TIP_Enrolment_Controller {

	private static String PROCESS_CASE_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('CS_Process_IDFS_ISS');

    public String applyLanguage {get; set;}
    public String displayLanguage {get; set;}
    public User user {get; set;}
    public Contact con {get; set;}
    public Account account {get; set;}
    private Id accountID {get; set;}
    private Case newCase {get; set;}
    private List <Case> accountCases {get; set;}

    public String conID {get; set;}
    public Contact newContact {get;set;} 
    public List <Contact> contactList {get; set;}

	public ISSP_TIP_Enrolment_Controller() {

		applyLanguage = UserInfo.getLanguage();
        displayLanguage = UserInfo.getLanguage();

        user = DAL_ISSP.getUser(Userinfo.getUserId());
        con = DAL_ISSP.getContact(user.ContactId);
        accountID = con.AccountId;
        fetchHQAccountDetails();
        getISOCountry();

        accountCases = [SELECT ID,Reason,RecordTypeid,RecordType.Name,CaseArea__c,Status,Visible_on_ISS_Portal__c,Subject,Region__c,
    					Origin,BSPCountry__c,Country_concerned_by_the_query__c,Description
    	 				FROM Case 
	    	 				WHERE RecordTypeid = :PROCESS_CASE_RECORD_TYPE_ID 
	    	 				AND Accountid = :account.id 
	    	 				AND Visible_on_ISS_Portal__c = true
							AND Reason = 'Payment Provider Management'
							AND CaseArea__c = 'Transparency in Payments (TIP)' 
							AND Status = 'Draft'
    	 				LIMIT 1]; 

    	fillContactList();
    	newContact = new Contact();
	}

	public Pagereference submitToIATA() {

		//confirm that required fields are fill
		    	//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter value'));
    	
    	if(account.Name == null || account.Name ==''){
    		account.Name.addError('Please fill the Legal name');
   			return null;
		}

		
		
		//confirm that primary contact is choosen
		Boolean hasPrimaryContact = false;
		for(Contact c : contactList){
			if (c.Primary_Contact__c) hasPrimaryContact = true;
		}

		if(!hasPrimaryContact) contactList[0].Primary_Contact__c = true;
		upsert contactList;


		//Update or create case with status Open
		updateCase();
		newcase.Status = 'Open';
		
		//force case auto-response rules to fire
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.EmailHeader.triggerAutoResponseEmail= true;
		newCase.setOptions(dmo);

		update account;
		upsert newCase;


		//------------------ queue exists??-----------------------

		//assign to TIP HO queue
		List<Group> groups =  [SELECT Id FROM Group WHERE Type = 'Queue' AND NAME = 'TIP HO' LIMIT 1];
		
		if(groups == null || groups.isEmpty()) System.debug('ERROR! TIP HO Queue not found proceeding without assign');
		else{
			newCase.OwnerId = groups[0].id;
			upsert newcase;
		}

		//take to acknowledgement page (which page is this?)
		return new Pagereference('/ISSP_TIP_Home'); //wrong page
	}

	public Pagereference saveAsDraft() {

		//create a case
		//update case if already exists one for this

		/*

		Case Reason = Payment Provider Management (new Case Reason to be created)
		Case description = Request for Enlistment as Payment provider [Custom label]
		Subject = Request for Enlistment as Payment provider - <Name of Account>
		Case region / Country set as per user's account [see Accreditation controller]

		origin = portal
		status = draft
		case area = TIP
		visible on iss portal
		iso country
		record type = process
		BSPCountry__c = iata iso country
		newCase.Country_concerned_by_the_query__c = isocountry.Name;

		*/

		updateCase();
		update account;
		upsert newCase;
		return new Pagereference('/ISSP_TIP_Home');
	}

	public void fetchHQAccountDetails () {
        account = [
                        SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Legal_name__c,
                        TradeName__c, Membership_status__c, IATACode__c, Sector__c, Category__c, Due_Diligence_Status__c,
                        Due_Diligence_Remarks__c, Level_of_risk__c, Email__c, Website, Phone, PhoneNational__c, Fax, FaxNational__c,
                        Mobile__c, MobileNational__c , Location_Type__c, ParentId, ShippingStreet, ShippingCity, ShippingState,
                        ShippingPostalCode, ShippingCountry, VAT_Number__c, Short_Name__c, Location_Class__c, IATA_ISO_Country__c,TIP_Documents__c,
                        Iso_State__c, Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c, Solicitation_Flag__c,
                        VAT_Number_2__c, CASS_Number__c,Company_Type__c,RecordType.DeveloperName,Status__c,IATA_ISO_Country__r.ISO_Code__c,ANG_Accreditation_Model__c,
                        IATA_ISO_Country__r.Name, IATA_ISO_Country__r.region__c, TIP_HQ_Location__c
                        FROM Account
                        WHERE Id = :accountID
                                   LIMIT 1
                    ];
    }

    private void updateCase(){

    	newCase = new Case();
		if(accountCases != null && !accountCases.isEmpty()){ newCase = accountCases[0]; }
    	newcase.RecordTypeid = PROCESS_CASE_RECORD_TYPE_ID;
		newcase.Accountid = account.id; 
		newcase.Visible_on_ISS_Portal__c = true;
		newcase.Reason = 'Payment Provider Management';
		newcase.CaseArea__c = 'Transparency in Payments (TIP)'; 
		newcase.Status = 'Draft';
		newcase.Subject = 'Request for Enlistment as Payment provider - ' + account.name;
		newCase.Description = 'Request for Enlistment as Payment provider';
		newcase.Region__c = account.IATA_ISO_Country__r.region__c;
		newcase.Origin = 'Portal';
		newcase.BSPCountry__c = account.IATA_ISO_Country__r.Name;
		newcase.Country_concerned_by_the_query__c = account.IATA_ISO_Country__r.Name;
    }

	public List<SelectOption> getISOCountry() {
        List<SelectOption> options = new List<SelectOption>();		
        for(IATA_ISO_Country__c iso:[select Id,Name,ISO_Code__c, IEC_Zip_Postal_Code_required__c from IATA_ISO_Country__c
                                    where Name != 'All Countries' and Name != 'NO COUNTRY' order by Name]){
            options.add(new SelectOption(iso.Id,iso.Name));
        }
        return options;
    }

    private void fillContactList() {
    	contactList = [SELECT id,Name, Email, FirstName, LastName, Phone, Primary_Contact__c
                FROM Contact
                WHERE Status__c = 'Active'];
    }

    public void updateRadioButtonStatus() {
    	ID contactID = Apexpages.currentPage().getParameters().get('contactID');
    	for (Contact c: contactList) {
    		c.Primary_Contact__c = false;
    		
    		if(c.id == contactID) c.Primary_Contact__c = true;
    	}
    }

    public Pagereference createContact(){

    	Contact conToInsert = newContact.clone();
    	insert conToInsert;
    	contactList.add(conToInsert);
    	newContact = new Contact();
    	return null;
    }
}