/**
 * This class is used in GCS Portal to retrieve related contact and account information of the currently logged Community User,
 * this information can be seen/edited under CompanyProfile(account info) and MyProfile(contact info) pages in the GCS Portal.
 *
 * To be able to dynamically display different fields for each of the Account (company) RecordTypes, list of fields to be display by lightning base components
 * is generated based on Fieldsets. List of FieldWrappers is returned containg information about fieldName, additional access rules on top of FLS and information about
 * which section of the profile that field belongs to.
 *
 * Fieldsets are not used for Contact fields (MyProfile) as the recordType-based layouts are not required there.
 *
 * User stories: MTSL-257 ; MTSL-258 ; MTSL-259 ; MTSL-289 ; MTSL-290 ; MTSL-291 ; MTSL-293 ; MTSL-294
 */

public with sharing class PortalProfileCtrl {

    PRIVATE STATIC FINAL STRING FIELDSET_AIRLINE = 'GCS_Profile_Airline';
    PRIVATE STATIC FINAL STRING FIELDSET_AGENCY = 'GCS_Profile_Agency';
    PRIVATE STATIC FINAL STRING FIELDSET_GSA = 'GCS_Profile_GSA';
    PRIVATE STATIC FINAL STRING FIELDSET_STANDARD = 'GCS_Profile_Standard';
    PRIVATE STATIC FINAL STRING FIELDSET_OTHERS = 'GCS_Profile_Others';
    PRIVATE STATIC FINAL STRING FIELDSET_CONTACT = 'GCS_CompanyContact';

    PRIVATE STATIC FINAL STRING LABEL_BASICS = System.label.csp_Basics_Section_label;
    PRIVATE STATIC FINAL STRING LABEL_COMPANY_CONTACT = System.label.csp_CompanyContact_Section_label;
    PRIVATE STATIC FINAL STRING LABEL_PERSONAL_CONTACT = System.label.csp_Profile_PersonalContact;
    PRIVATE STATIC FINAL STRING LABEL_BUSINESS_CONTACT = System.label.csp_Profile_BusinessContact;
    PRIVATE STATIC FINAL STRING LABEL_ACCESSIBILITY = System.label.csp_Profile_PortalAccessibility;
    PRIVATE STATIC FINAL STRING LABEL_PROFESSIONAL = System.label.csp_Profile_Professional;
    
    PRIVATE STATIC FINAL STRING LABEL_PRIVACYMANAGEMENTTITLE = System.Label.CSP_Profile_PrivacyManagement_Title;
    PRIVATE STATIC FINAL STRING LABEL_PRIVACYMANAGEMENTTEXT = System.label.CSP_Profile_PrivacyManagement_Text;
    PRIVATE STATIC FINAL STRING LABEL_PRIVACYMANAGEMENTLINK = System.label.CSP_Profile_PrivacyManagement_Link;

    PRIVATE STATIC FINAL STRING LABEL_FIRST_NAME = System.label.First_name;
    PRIVATE STATIC FINAL STRING LABEL_LAST_NAME = System.label.Last_name;
    PRIVATE STATIC FINAL STRING LABEL_LOCATION_CODE = System.label.ISSP_IATA_Location_Code;
    PRIVATE STATIC FINAL STRING LABEL_CITY = System.label.City;
    PRIVATE STATIC FINAL STRING LABEL_STATUS = System.label.Status;
    PRIVATE STATIC FINAL STRING LABEL_PORTAL_STATUS = System.label.CSP_Portal_Status;

    PRIVATE STATIC FINAL STRING LABEL_NAME = System.label.ISSP_Local_Groups_Contact_Name;
    PRIVATE STATIC FINAL STRING LABEL_EMAIL = System.label.Email;
    PRIVATE STATIC FINAL STRING LABEL_CONTACT_TYPE = System.label.ISSP_Airline_Contact_Type;
    PRIVATE STATIC FINAL STRING LABEL_LAST_LOGIN = System.label.csp_LastLoginDate;
    PRIVATE STATIC FINAL STRING LABEL_TRADE_NAME = System.label.ISSP_MyProfile_TradeName;
    PRIVATE STATIC FINAL STRING LABEL_ISO_COUNTRY = System.label.Country;


    PRIVATE STATIC FINAL STRING LABEL_INVOICE_CONTACT = System.label.CSP_cpcc_Invoice_Contact;
    PRIVATE STATIC FINAL STRING LABEL_AUTHORISED_SIGNATORY = System.label.CSP_cpcc_Authorised_Signatory;
    PRIVATE STATIC FINAL STRING LABEL_PAYMENT_CONTACT = System.label.CSP_cpcc_BSP_CASS_Payment_Contact;
    PRIVATE STATIC FINAL STRING LABEL_AGENT_CREDIT_RISK = System.label.CSP_cpcc_Agent_Credit_Risk;

    PRIVATE STATIC FINAL INTEGER CONTACT_BATCH= 15;
    PRIVATE STATIC FINAL INTEGER BRANCH_BATCH = 15;

public static final Id RECORDTYPE_AGENCY = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
public static final Id RECORDTYPE_AIRLINE_BR = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');
public static final Id RECORDTYPE_AIRLINE_HQ = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
public static final list<Id> VALID_ACCOUNT_RT = new list<String> {RECORDTYPE_AGENCY, RECORDTYPE_AIRLINE_BR, RECORDTYPE_AIRLINE_HQ};

	public class PortalProfileException extends Exception {}

public static Contact contactInfo = new Contact();

    public static User myUser {
        get {
            if(myUser == null) {
                myUser = CSP_Utils.getLoggedUser();
            }
            return myUser;
        }
        set;
    }

    public static Contact myContact{
        get{
            if(myContact == null){
                myContact = DAL_ISSP.getContact(myUser.ContactId);
            }
            return myContact;
        }

        set;
    }

    public static Boolean isAccountDomain {
		get {
			Boolean issp_AccountDomain = ISSP_AccountDomainPermission__c.getInstance(myUser.Contact.Account.RecordType.DeveloperName) != null;
			Boolean isAdmin = CSP_Utils.isAdmin();

			return issp_AccountDomain && isAdmin;
		}
		set;
	}

	@AuraEnabled
	public static ApexMessageHandling approve(String contactList, String approvalStatus) {
		List<ContactWrapper> filtersWrapper = (List<ContactWrapper>) JSON.deserialize(contactList, List<ContactWrapper>.class);

        Set <Id> contactIds = new Set <Id>();
        for (ContactWrapper thisContactRecord : filtersWrapper){
            if (thisContactRecord.selected){
                contactIds.add(thisContactRecord.contact.Id);
            }
        }

		if (!contactIds.isEmpty()) {
            return processMultiplePortalUserStatusChange(contactIds, approvalStatus, 'Active');
		}

        return new ApexMessageHandling(false, Label.ISSP_SelectOneContact);
	}

	@AuraEnabled
	public static ApexMessageHandling inactivate(String contactList, String reasonToInactive) {
		List<ContactWrapper> filtersWrapper = (List<ContactWrapper>) JSON.deserialize(contactList, List<ContactWrapper>.class);
		Set<Id> contactIds = new Set<Id>();
		String productMessage;

		for (contactWrapper thisContactRecord : filtersWrapper) {
            if (thisContactRecord.selected) {
                if (thisContactRecord.hasProducts) {
                    if (String.isNotBlank(productMessage)) {
                        productMessage = Label.ISSP_InactiveUser_Subscription_Portal;
                    }
                    productMessage = productMessage + '</br>' + thisContactRecord.contact.Name;
                }

            	contactIds.add(thisContactRecord.contact.Id);
            }
		}

		if (String.isNotBlank(productMessage)) {
			return new ApexMessageHandling(false, productMessage);
		} else {
			List <Portal_Application_Right__c> appList =
				[SELECT Id, Application_Name__c, Contact__r.Name, Contact__c
				FROM Portal_Application_Right__c
				WHERE Right__c = 'Access Granted' AND Contact__c IN :contactIds
				AND Portal_Application__r.Critical_Service__c = true
				ORDER BY Contact__c];

			//ACAMBAS - TIP-282 Start
			List <Account_Contact_Role__c> primaryConList =
				[SELECT Id, Contact__c, Contact__r.Name
					FROM Account_Contact_Role__c
					WHERE Contact__c IN :contactIds AND is_primary__c = true];
			//ACAMBAS - TIP-282 End

			if(!appList.isEmpty()) {
				String message = Label.ISSP_UserInactivation_ServiceMsg_4;
				String currentConId;

				for (Portal_Application_Right__c thisAppRight : appList) {
					if (String.isNotBlank(currentConId)) {
						currentConId = thisAppRight.Contact__c;
						message += '<br/> - ' + thisAppRight.Contact__r.Name;
						message += ': ' + thisAppRight.Application_Name__c;
					} else if (currentConId != thisAppRight.Contact__c) {
						currentConId = thisAppRight.Contact__c;
						message += '<br/> - ' + thisAppRight.Contact__r.Name;
						message += ': ' + thisAppRight.Application_Name__c;
					} else {
						message += ', ' + thisAppRight.Application_Name__c;
					}
				}

				message += Label.ISSP_UserInactivation_ServiceMsg_2;
				message += Label.ISSP_UserInactivation_ServiceMsg_3;

				return new ApexMessageHandling(false, message);

			} else if(!primaryConList.isEmpty()) {
				String message = Label.ISSP_UserInactivation_ServiceMsg_4;
				String currentConId;

				for (Account_Contact_Role__c thisPrimaryContact : primaryConList) {
					if (String.isNotBlank(currentConId)) {
						currentConId = thisPrimaryContact.Contact__c;
						message += '<br/> - ' + thisPrimaryContact.Contact__r.Name;
					}
					else if (currentConId != thisPrimaryContact.Contact__c){
						currentConId = thisPrimaryContact.Contact__c;
						message += '<br/> - ' + thisPrimaryContact.Contact__r.Name;
					}
				}

				message += ': ' + Label.ISSP_UserInactivation_ServiceMsg_5;

				return new ApexMessageHandling(false, message);				
			} else {
				return processMultiplePortalUserStatusChange(contactIds, 'Deactivated', reasonToInactive);
			}
		}
    }

	private static ApexMessageHandling processMultiplePortalUserStatusChange(Set<Id> contactIds, String action, String inactivationReason){
        List <Contact> processContactList = [SELECT Id, Name, User_Portal_Status__c, Email FROM Contact WHERE Id IN :contactIds];

        if (!processContactList.isEmpty()) {
            for (Contact thisContact : processContactList) {
                String currentStatus = processContactList[0].User_Portal_Status__c;

                if (currentStatus == '' || currentStatus == null) {
                    currentStatus = 'New user';
                }

                String theAction = ISSP_PortalUserStatusChange.actionsMap.get(currentStatus).get(action);
                Savepoint sPointContact = Database.setSavepoint();

                String theResult = ISSP_PortalUserStatusChange.runAction(thisContact.Id, thisContact.Email, theAction, action, inactivationReason, null);

                if (String.isNotBlank(theResult)) {
                    Database.rollback(sPointContact);
					return new ApexMessageHandling(false, theResult);
                }
            }
        } else {
            return new ApexMessageHandling(false, 'No Contact found.');
        }
		
		return new ApexMessageHandling();
    }        

    /**
    * Todo: Implement contact search.
    * With infinite scrolling, search currently only filters records that are already on the client.
    * In the future - filtering, sorting to call backend methods and return data from the DB.
    */
    @AuraEnabled
    public static List<ContactWrapper> searchAccountContacts(String queryString, Integer offset){
        List<Contact> searchResults = DAL_WithoutSharing.searchContactsByAccountId(myContact.AccountId,offset,CONTACT_BATCH,queryString);
        List<ContactWrapper> wrappers = getContactWrappers(searchResults);
        return wrappers;
    }

    @AuraEnabled
    public static List<ContactWrapper> getAccountContacts(){
        return getAccountContacts(0);
    }


    @AuraEnabled
    public static List<ContactWrapper> getAccountContacts(Integer offset){
        List<Contact> contacts = DAL_WithoutSharing.getContactsByAccountId(myContact.AccountId,offset,CONTACT_BATCH);
        List<ContactWrapper> wrappers = getContactWrappers(contacts);
        return wrappers;
    }

	private static List<ContactWrapper> getContactWrappers(List<Contact> contacts){
		List<ContactWrapper> wrappers = new List<ContactWrapper>();

		if(!contacts.isEmpty()) {
			List<Id> contactIds = new List<Id>();
			Map<Id,Contact> contactIdtoContact = new Map<Id,Contact>();
			for(Contact c :contacts) {
				contactIds.add(c.Id);
				contactIdtoContact.put(c.Id,c);
			}

			List<User> users = new List<User>();
			users = DAL_ISSP.getUsersByContactId(contactIds);

			Map<Id,Id> contactToUser = new Map<Id,Id>();
			for(User u :users) {
				contactToUser.put(u.ContactId,u.Id);
			}

			Map<Id,List<PortalServicesCtrl.ServiceWrapper> > contactToServices = new Map<Id,List<PortalServicesCtrl.ServiceWrapper> >();
			contactToServices = PortalServicesCtrl.getContactsAccessGrantedServices(contactToUser);

			Set<Id> contactsWithIdCard = new Set<Id>();
			for(Id_Card__c idcard : [SELECT Related_Contact__c FROM Id_Card__c WHERE Related_Contact__c IN :contactIds]) {
				contactsWithIdCard.add(idcard.Related_Contact__c);
			}
			
			Set<Id> contactsWithSubscription = new Set<Id>();
			for(IEC_Subscription_History__c subs : [SELECT Related_Contact__c FROM IEC_Subscription_History__c WHERE Related_Contact__c IN :contactIds]) {
				contactsWithSubscription.add(subs.Related_Contact__c);
			}

			ContactWrapper wrapper;
			for(User u :users) {
				wrapper = new ContactWrapper();
				wrapper.contact = contactIdtoContact.get(u.ContactId);
				wrapper.contactUser = u;
				wrapper.services = contactToServices.get(u.ContactId);
				wrapper.selected = false;
				wrapper.hasIdCard = false;
				wrapper.hasProducts = false;

				if(contactsWithIdCard.contains(u.ContactId)) wrapper.hasIdCard = true;
				if(contactsWithSubscription.contains(u.ContactId)) wrapper.hasProducts = true;

				wrappers.add(wrapper);
			}

			for(Contact c: contacts) {
				if(!contactToUser.containsKey(c.Id)) {
					wrapper = new ContactWrapper();
					wrapper.contact = c;
					wrapper.services = new List<PortalServicesCtrl.ServiceWrapper>();
					wrapper.selected = false;
					wrapper.hasIdCard = false;
					wrapper.hasProducts = false;

					if(contactsWithIdCard.contains(c.Id)) wrapper.hasIdCard = true;
					if(contactsWithSubscription.contains(c.Id)) wrapper.hasProducts = true;
					wrappers.add(wrapper);
				}
			}
		}

		return wrappers;
	}


    @AuraEnabled
    public static List<Account> searchCompanyBranches(String queryString, Integer offset){
        List<Account> branches = new List<Account>();
        queryString =queryString+'%';

        branches = [select id,TradeName__c,Name,BillingCity,Status__c,BillingCountry,IATA_ISO_Country__r.Name,IATACode__c,BillingAddress,Phone,Fax
        from account
        where (id =:myContact.AccountId or parentId=:myContact.AccountId or top_parent__c =:myContact.AccountId)
        and (TradeName__c LIKE :queryString OR Name LIKE :queryString OR BillingCity LIKE :queryString OR IATACode__c LIKE :queryString)
        and (Status__c NOT IN ('Terminated','Not accredited', 'No longer a customer', 'New application pending'))
        ORDER BY Name ASC LIMIT:BRANCH_BATCH OFFSET :offset
        ];

        return branches;
    }

    @AuraEnabled
    public static List<Account> getCompanyBranches(){
        return getCompanyBranches(0);
    }

    @AuraEnabled
    public static List<Account> getCompanyBranches(Integer offset){
        List<Account> branches = new List<Account>();

        branches = [select id,TradeName__c,Name,BillingCity,Status__c,BillingCountry,IATA_ISO_Country__r.Name,IATACode__c,BillingAddress,Phone,Fax
        from account where (id =:myContact.AccountId or parentId=:myContact.AccountId or top_parent__c =:myContact.AccountId)
        and (Status__c NOT IN ('Terminated','Not accredited', 'No longer a customer', 'New application pending'))
        ORDER BY Name ASC LIMIT:BRANCH_BATCH OFFSET :offset
        ];

        return branches;
    }

	public class ContactWrapper {
		@AuraEnabled
		public Contact contact;
		@AuraEnabled
		public User contactUser;
		@AuraEnabled
		public List<PortalServicesCtrl.ServiceWrapper> services;
		@AuraEnabled
		public Boolean hasIdCard;
		@AuraEnabled
		public Boolean hasProducts;
		@AuraEnabled
		public Boolean selected;
	}

    public class CardWrapper{

        @AuraEnabled
        public String cardTitle;

        @AuraEnabled
        public List<FieldWrapper> lstFieldWrapper;

        @AuraEnabled
        public Boolean isEditable;

        public CardWrapper(String cardTitleAux, List<FieldWrapper> lstFieldWrapperAux, Boolean isEditableAux){
            this.cardTitle = cardTitleAux;
            this.lstFieldWrapper = lstFieldWrapperAux;
            this.isEditable = isEditableAux;
        }


    }


    // OBJECT - FIELD NAME - EDITABLE - VISIBLE - SECTION;
    public static List<CardWrapper> ContactFields() {

        User loggedUser = CSP_Utils.getLoggedUser();
        contactInfo = DAL_ISSP.getContact(loggedUser.contactId);

        //stores each card
        List<CardWrapper> lstCardWrapper = new List<CardWrapper>();

        //BASICS CARD
        List<FieldWrapper> lstfw1 = new List<FieldWrapper>();
        lstfw1.add(new FieldWrapper('Name',true,true));
        lstfw1.add(new FieldWrapper('Birthdate',true,true));
        lstfw1.add(new FieldWrapper('Title',true,true));
        lstfw1.add(new FieldWrapper('Preferred_Language__c',true,true));
        lstCardWrapper.add(new CardWrapper(LABEL_BASICS, lstfw1, true));

        //PERSONAL CARD
        List<FieldWrapper> lstfw2 = new List<FieldWrapper>();
        lstfw2.add(new FieldWrapper('Email',false,true));
        FieldWrapper fw;
        fw = new FieldWrapper('Phone',true,true);
        fw.isRequired = true;
        lstfw2.add(fw);
        lstfw2.add(new FieldWrapper('MobilePhone',true,true));
        lstfw2.add(new FieldWrapper('MailingCountry',true,true));
        lstfw2.add(new FieldWrapper('MailingCity',true,true));
        lstfw2.add(new FieldWrapper('MailingState',true,true));
        lstfw2.add(new FieldWrapper('MailingStreet',true,true));
        lstfw2.add(new FieldWrapper('MailingPostalCode',true,true));
        lstCardWrapper.add(new CardWrapper(LABEL_PERSONAL_CONTACT, lstfw2, true));

        //ACCESSIBILITY CARD
        List<FieldWrapper> lstfw3 = new List<FieldWrapper>();
        lstfw3.add(new FieldWrapper('User_Portal_Status__c',false,true));
        lstfw3.add(new FieldWrapper('Authorization',false,true));
        lstCardWrapper.add(new CardWrapper(LABEL_ACCESSIBILITY, lstfw3, true));

        //PROFESSIONAL CARD
        List<FieldWrapper> lstfw4 = new List<FieldWrapper>();
        fw = new FieldWrapper('ID_CARD',false,true,true);
        fw.isIdCardInfo = true;
        lstfw4.add(fw);
        fw = new FieldWrapper('Membership_Function__c',false,true,true);
        fw.isJobFunction = true;
        lstfw4.add(fw);
        lstCardWrapper.add(new CardWrapper(LABEL_PROFESSIONAL, lstfw4, true));

        //PRIVACY CARD
        List<FieldWrapper> lstfw5 = new List<FieldWrapper>();
        lstfw5.add(new FieldWrapper(LABEL_PRIVACYMANAGEMENTTITLE, LABEL_PRIVACYMANAGEMENTTEXT, LABEL_PRIVACYMANAGEMENTLINK ));
        lstCardWrapper.add(new CardWrapper(LABEL_PRIVACYMANAGEMENTTITLE, lstfw5, false));

        return lstCardWrapper;
    }

    // OBJECT - FIELD NAME - EDITABLE - VISIBLE - SECTION;
    public static List<CardWrapper> ContactFieldsAcc() {

        //stores each card
        List<CardWrapper> lstCardWrapper = new List<CardWrapper>();

        //BASICS CARD
        List<FieldWrapper> lstfw1 = new List<FieldWrapper>();
        lstfw1.add(new FieldWrapper('Phone_Number__c',true,true));
        lstfw1.add(new FieldWrapper('Phone',true,true));
        lstfw1.add(new FieldWrapper('Fax',true,true));
        lstfw1.add(new FieldWrapper('BillingCountry',false,true));
        lstfw1.add(new FieldWrapper('BillingState',false,true));
        lstfw1.add(new FieldWrapper('BillingStreet',false,true));
        lstfw1.add(new FieldWrapper('BillingPostalCode',false,true));
        lstCardWrapper.add(new CardWrapper(LABEL_BUSINESS_CONTACT, lstfw1, true));

        return lstCardWrapper;
    }

    @AuraEnabled
    public static List<FieldWrapper> getContactFieldsToInsert() {
        return new List<FieldWrapper>{
                new FieldWrapper('FirstName', false),
                new FieldWrapper('LastName', false),
                new FieldWrapper('Email', false),
                new FieldWrapper('MobilePhone', false),
                new FieldWrapper('Phone', false),
                new FieldWrapper('Preferred_Language__c', false)
        };

    }


    public static List<CardWrapper> AccountFields() { return getFieldsByRecordType();}

    @AuraEnabled
    public static List<CardWrapper> getFieldsMap (String type){
        // CHECK IF ITS AN ACCOUNT OR CONTACT!!
        List<CardWrapper> sectionMap = new  List<CardWrapper>();

        List<String[]> fieldsList = new List<String[]>();
        if ( type == 'MyProfile' ){
            sectionMap = ContactFields();
        } else if (type == 'MyProfileAccFields') {
            sectionMap = ContactFieldsAcc();
        } else {
            sectionMap = AccountFields();
        }

        return sectionMap;
    }

    @AuraEnabled
    public static Boolean isGDPOptInDisplayed(){
        Set<String> possibleGDPLocationTypes = new Set<String>{'C', 'D', 'G', 'M', 'P', 'R', 'T', 'V', 'X'};
        return possibleGDPLocationTypes.contains(myContact.Account.Location_Class__c);
    }

    @AuraEnabled
    public static Account getCompanyInfo(String accountId){
        List<Account> accs = [SELECT Id,Name,Logo_File_ID__c,Website,IATACode__c,Email__c,Status__c FROM Account WHERE Id=: accountId];
        if(!accs.isEmpty()){
            return accs[0];
        }

        return null;
    }

    @AuraEnabled
    public static Boolean canEditBasics(){
        String rType = myContact.Account.RecordType.DeveloperName;
        return rType == 'IATA_Agency';
    }

    @AuraEnabled
    public static Boolean hasAnnualRevalidation(){
        String rType = myContact.Account.RecordType.DeveloperName;
        return rType =='IATA_Agency' && hasRevCases();
    }

    @AuraEnabled
    public static boolean hasRevCases(){

        if(myContact.AccountId != null){
            List<Case> revCases = [SELECT Id FROM Case
            WHERE (AccountId = :myContact.AccountId OR AccountId = :myContact.Account.Top_Parent__c)
            AND Reason1__c = 'Annual revalidation'
            AND Status != 'Closed'
            AND Status != 'Closed_Rejected'
            AND Status != 'Closed_Withdrawn'];

            return !revCases.isEmpty();
        }
        return false;
    }


    /**
    *
    * Returns list of FieldWrapper rows to be.
    * List of account fields to display is determined by record type and a relevant fieldset.
    *
    * Field access should be handled by field-level security, here it can be only more restrictive
    *                   with 'editable' attribute when editable by FL security.
    * */
    private static List<CardWrapper> getFieldsByRecordType(){

        String rType = myContact.Account.RecordType.DeveloperName;
        Boolean newGen = myContact.Account.ANG_IsNewGenAgency__c;
        String legalName = myContact.Account.Legal_name__c;

        String fieldsetBasic;
        if(rType == 'IATA_Airline_BR' || rType == 'IATA_Airline'){fieldsetBasic = FIELDSET_AIRLINE;}
        else if(rType == 'IATA_Agency'){fieldsetBasic = FIELDSET_AGENCY;}
        else if(rType == 'IATA_GSA'){fieldsetBasic = FIELDSET_GSA;}
        else if(rType == 'Others'){fieldsetBasic = FIELDSET_OTHERS;}
        else {fieldsetBasic = FIELDSET_STANDARD;}


        Map<String,Schema.FieldSet> fieldsets =  SObjectType.Account.FieldSets.getMap();
        List<Schema.FieldSetMember>  basicsFields = fieldsets.get(fieldsetBasic).getFields();
        List<Schema.FieldSetMember>  contactFields = fieldsets.get(FIELDSET_CONTACT).getFields();


        //stores each card
        List<CardWrapper> lstCardWrapper = new List<CardWrapper>();

        //BASICS CARD
        List<FieldWrapper> lstfw1 = new List<FieldWrapper>();
        for(Schema.FieldSetMember f : basicsFields) {
            Boolean editable = true;
            String fieldName = f.getFieldPath();

            if(fieldName == 'IATACode__c' && (String.isBlank(myContact.Account.Status__c) || myContact.Account.Status__c =='New application pending')){
                continue;
            }

            if((newGen && f.getFieldPath() == 'TradeName__c') || fieldName =='Legal_Name__c' || fieldName =='Sector__c' || fieldName == 'Category__c'){
                editable = false;
            }

            if(f.getFieldPath() == 'Legal_Name__c' && !String.isBlank(legalName) || f.getFieldPath() != 'Legal_Name__c'){
                lstfw1.add(new FieldWrapper(f.getFieldPath(),editable,true));
            }
        }
        lstCardWrapper.add(new CardWrapper(LABEL_BASICS, lstfw1, true));

        if (isAccountDomain) {
			lstfw1.add(new FieldWrapper('AccountDomainPermission',false,false));
		}

        //COMPANY CONTACT CARD
        List<FieldWrapper> lstfw2 = new List<FieldWrapper>();
        for(Schema.FieldSetMember f : contactFields) {
            Boolean editable = true;
            
            if(f.getFieldPath().toLowerCase() == 'billingcountry' || (f.getFieldPath().toLowerCase().contains('billing') && rType != 'Standard_Account')) {
                editable = false;
            }

            if(hasAnnualRevalidation() && ('phone'.equals(f.getFieldPath().toLowerCase())  || 'fax'.equals(f.getFieldPath().toLowerCase())  || 'email__c'.equals(f.getFieldPath().toLowerCase())  || 'website'.equals(f.getFieldPath().toLowerCase()) )) {
                editable = false;
            }

            lstfw2.add(new FieldWrapper(f.getFieldPath(), editable, true));
        }

        if(isGDPOptInDisplayed()){
            lstfw2.add(new FieldWrapper('GDP_Opt_In__c',true,true));
        }
        lstCardWrapper.add(new CardWrapper(LABEL_COMPANY_CONTACT, lstfw2, true));

        return lstCardWrapper;

    }


    /** FIELD WRAPPER HELPER CLASS */
    public class FieldWrapper{
        @AuraEnabled
        public String fieldName;

        @AuraEnabled
        public Boolean editable;

        @AuraEnabled
        public Boolean visible;

        @AuraEnabled
        public Boolean fullSize;

        @AuraEnabled
        public String className;

        @AuraEnabled
        public String label;

        @AuraEnabled
        public Boolean labeled;

        @AuraEnabled
        public Boolean outputOnly;

        @AuraEnabled
        public Boolean changeUserStatus;

        @AuraEnabled
        public Boolean isAccessibility;

        @AuraEnabled
        public Boolean isJobFunction;

        @AuraEnabled
        public Boolean isIdCardInfo;

        @AuraEnabled
        public Boolean isContactServices;

        @AuraEnabled
        public Boolean isLastLogin;

        @AuraEnabled
        public Boolean isRequired;

        @AuraEnabled
        public List<accessibilityWrapper> accessibilityList;

        
        @AuraEnabled
        public String link;

        @AuraEnabled 
        public Boolean isPrivacyManagement;

        @AuraEnabled
        public Boolean isAccountDomainPermission;

        public FieldWrapper(String title, String label, String link){
            this.label = label;
            this.link = link;
            this.isPrivacyManagement = true;
        }

        public FieldWrapper (String fieldName, Boolean fullSize) {
            this.fieldName = fieldName;
            this.fullSize = fullSize;
            this.labeled = false;
        }

        public FieldWrapper (String fieldName, Boolean editable, Boolean visible,Boolean output){
            this.fieldName = fieldName;
            this.editable = editable;
            this.visible = visible;
            this.outputOnly = output;
            this.labeled = false;

            if (fieldName == 'User_Portal_Status__c') {
                this.changeUserStatus = true;
            } else {
                this.changeUserStatus = false;
            }
        }

        public FieldWrapper (String fieldName, Boolean editable, Boolean visible){
            this.fieldName = fieldName;
            this.editable = editable;
            this.visible = visible;
            this.labeled = false;
            this.isAccessibility = (fieldName == 'Authorization' ? true : false);
            this.isAccountDomainPermission = (fieldName == 'AccountDomainPermission' ? true : false);
            if (fieldName == 'Authorization') {
                this.accessibilityList = new List<accessibilityWrapper>{
                        new accessibilityWrapper(false, LABEL_INVOICE_CONTACT, 'Invoicing_Contact__c'),
                        new accessibilityWrapper(false, LABEL_AUTHORISED_SIGNATORY, 'Authorized_Signatory__c'),
                        new accessibilityWrapper(false, LABEL_PAYMENT_CONTACT, 'BSP_CASS_Payment_contact__c')
                };
                
                if ( myUser.profile.Name.touppercase().contains('AIRLINE') ) {
                    this.accessibilityList.add(new accessibilityWrapper(false, LABEL_AGENT_CREDIT_RISK, 'Airline_Credit_Risk_Manager__c'));
                }
            }

            if (fieldName == 'User_Portal_Status__c') {
                this.changeUserStatus = true;
            } else {
                this.changeUserStatus = false;
            }

            this.isContactServices = fieldName == 'ContactServices' ? true : false;

        }
        public FieldWrapper (String fieldName, Boolean editable, Boolean visible,String className, String label){
            this.fieldName = fieldName;
            this.editable = editable;
            this.visible = visible;
            this.className = className;
            this.label = label;

            if(!String.isEmpty(label)){
                this.labeled = true;
            }else{
                this.labeled = false;
            }
        }

    }

    /* checked: false, label: this.labels.Portal_Administrator, APINAME: "PortalAdmin" */

    public class accessibilityWrapper{

        @AuraEnabled
        public Boolean checked;

        @AuraEnabled
        public String label;

        @AuraEnabled
        public String APINAME;

        public accessibilityWrapper (Boolean checked, String label, String APINAME){
            this.checked = (Boolean) contactInfo.get(APINAME);
            this.label = label;
            this.APINAME = APINAME;
        }
    }


    /** Contacts & Branches Sections */

    @AuraEnabled
    public static Map<String,List<FieldWrapper>> getContactsListFields(){

        String rType = myContact.Account.RecordType.DeveloperName;

        String rowsFields = 'ROWS'; //Fields to display in columns of a closed accordion/record list
        String viewFields = 'VIEW'; //Fields to display in open accordion section/record detail
        String editFields = 'EDITS'; //Fields to display/edit in record edit modal dialog


        List<String> toRow;

        if(rType == 'IATA_Agency' && myContact.Account.Status__c != AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING) {
            toRow = new List<String>{'Name','Email','Type_of_Contact__c','LocationCode','PortalStatus'};
        }else{
            toRow = new List<String>{'Name','Email','Type_of_Contact__c','PortalStatus'};
        }

        Map<String,String> fieldLabels = new Map<String,String>();

        FieldWrapper fw;

        fieldLabels.put('FirstName',LABEL_FIRST_NAME);
        fieldLabels.put('LastName',LABEL_LAST_NAME);
        fieldLabels.put('Email',LABEL_EMAIL);
        fieldLabels.put('Type_of_Contact__c',LABEL_CONTACT_TYPE);
        fieldLabels.put('Name',LABEL_NAME);
        fieldLabels.put('LocationCode',LABEL_LOCATION_CODE);
        fieldLabels.put('PortalStatus',LABEL_PORTAL_STATUS);

        for(String fieldName: toRow){
            if(!fieldLabels.containsKey(fieldName)){ fieldLabels.put(fieldName,fieldName);}
        }


        Map<String,List<FieldWrapper>> wrapperMap = new Map<String,List<FieldWrapper>>();

        wrapperMap.put(rowsFields,new List<FieldWrapper>());
        for(String fieldName : toRow){
            wrapperMap.get(rowsFields).add(new FieldWrapper(fieldName,true,true,'underLinded inactive cursorPointer',fieldLabels.get(fieldName)));
        }

        wrapperMap.put(viewFields,new List<FieldWrapper>());
        wrapperMap.put(editFields,new List<FieldWrapper>());

        //VIEW
        wrapperMap.get(viewFields).add(new FieldWrapper('ISSP_Account_Name__c',true,true,true));
        wrapperMap.get(viewFields).add(new FieldWrapper('MobilePhone',true,true));
        wrapperMap.get(viewFields).add(new FieldWrapper('Phone',true,true));
        wrapperMap.get(viewFields).add(new FieldWrapper('User_Portal_Status__c',false,true,true));

        fw = new FieldWrapper('Membership_Function__c',false,true,true);
        fw.isJobFunction = true;
        wrapperMap.get(viewFields).add(fw);
        wrapperMap.get(viewFields).add(new FieldWrapper('ContactServices',false,true));

        //For Airlines & agencies only
        if((rType == 'IATA_Airline_BR' || rType == 'IATA_Airline') || rType == 'IATA_Agency') {
            wrapperMap.get(viewFields).add(new FieldWrapper('BSP_CASS_Payment_contact__c', true, true));
            wrapperMap.get(viewFields).add(new FieldWrapper('Invoicing_Contact__c', true, true));
        }

        wrapperMap.get(viewFields).add(new FieldWrapper('Authorized_Signatory__c',true,true));

        fw = new FieldWrapper('LastLogin',false,true,true);
        fw.isLastLogin = true;
        wrapperMap.get(viewFields).add(fw);


        //EDIT
        wrapperMap.get(editFields).add(new FieldWrapper('ISSP_Account_Name__c',true,true,true));
        //wrapperMap.get(editFields).add(new FieldWrapper('Salutation',true,true)); - Salesforce bug, salutation picklist not loading values
        //wrapperMap.get(editFields).add(new FieldWrapper('ISO_Country__c',true,true,true));
        wrapperMap.get(editFields).add(new FieldWrapper('FirstName',true,true));
        wrapperMap.get(editFields).add(new FieldWrapper('LastName',true,true));
        wrapperMap.get(editFields).add(new FieldWrapper('Title',true,true));
        wrapperMap.get(editFields).add(new FieldWrapper('Email',false,true));
        wrapperMap.get(editFields).add(new FieldWrapper('MobilePhone',true,true));
        fw = new FieldWrapper('Phone',true,true);
        fw.isRequired = true;
        wrapperMap.get(editFields).add(fw);

        //For Airlines & agencies only
        if((rType == 'IATA_Airline_BR' || rType == 'IATA_Airline') || rType == 'IATA_Agency') {
            wrapperMap.get(editFields).add(new FieldWrapper('BSP_CASS_Payment_contact__c', true, true));
            wrapperMap.get(editFields).add(new FieldWrapper('Invoicing_Contact__c', true, true));
        }

        wrapperMap.get(editFields).add(new FieldWrapper('Authorized_Signatory__c',true,true));

        //Airline only
        if(rType == 'IATA_Airline_BR' || rType == 'IATA_Airline'){
            wrapperMap.get(editFields).add(new FieldWrapper('Airline_Credit_Risk_Manager__c',true,true));
        }

        return wrapperMap;

    }

    @AuraEnabled
    public static Map<String,List<FieldWrapper>> getBranchesListFields(){
        String rowsFields = 'ROWS'; //Fields to display in columns of a closed accordion/record list
        String viewFields = 'VIEW'; //Fields to display in open accordion section/record detail
        String editFields = 'EDITS'; //Fields to display/edit in record edit modal dialog

        String sectionBasic = LABEL_BASICS; //Fields to display in open accordion section/record detail - first section
        String sectionBranchContact = 'BranchContact'; //Fields to display in open accordion section/record detail + in edit modal dialog

        String rType = myContact.Account.RecordType.DeveloperName;

        List<String> toView = new List<String>{'Name','Status__c'};
        List<String> toRow = new List<String>{'TradeName__c','LocationCode','IsoCountry','BillingCity','Status__c'};
        List<String> toEdit = new List<String>{'Name','Status__c'};

        Map<String,List<FieldWrapper>> wrapperMap = new Map<String,List<FieldWrapper>>();
        Map<String,String> fieldLabels = new Map<String,String>();


        wrapperMap.put(rowsFields,new List<FieldWrapper>());
        wrapperMap.put(viewFields,new List<FieldWrapper>());
        wrapperMap.put(editFields,new List<FieldWrapper>());


        wrapperMap.put(sectionBranchContact,new List<FieldWrapper>());
        wrapperMap.put(sectionBasic,new List<FieldWrapper>());

        fieldLabels.put('Name',LABEL_NAME);
        fieldLabels.put('TradeName__c',LABEL_TRADE_NAME);
        fieldLabels.put('LocationCode',LABEL_LOCATION_CODE);
        fieldLabels.put('IsoCountry',LABEL_ISO_COUNTRY);
        fieldLabels.put('BillingCity',LABEL_CITY);
        fieldLabels.put('Status__c',LABEL_STATUS);


        for(String fieldName: toView){
            if(!fieldLabels.containsKey(fieldName)){
                fieldLabels.put(fieldName,fieldName);}
        }
        for(String fieldName: toRow){
            if(!fieldLabels.containsKey(fieldName)){
                fieldLabels.put(fieldName,fieldName);}
        }
        for(String fieldName: toEdit){
            if(!fieldLabels.containsKey(fieldName)){
                fieldLabels.put(fieldName,fieldName);}
        }


        wrapperMap.get(sectionBasic).add(new FieldWrapper('Legal_name__c',false,true));
        wrapperMap.get(sectionBasic).add(new FieldWrapper('Sector__c',false,true));
        wrapperMap.get(sectionBasic).add(new FieldWrapper('Category__c',false,true));
        wrapperMap.get(sectionBasic).add(new FieldWrapper('Location_Type__c',false,true));

        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('Email__c',true,true));
        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('Website',true,true));
        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('Phone',true,true));
        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('Fax',true,true));

        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('BillingState',(rType == 'Standard_Account'),true));
        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('BillingStreet',(rType == 'Standard_Account'),true));
        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('BillingPostalCode',(rType == 'Standard_Account'),true));
        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('BillingCountry',false,true));

        for(String fieldName : toRow){
            wrapperMap.get(rowsFields).add(new FieldWrapper(fieldName,true,true,'underLinded inactive cursorPointer',fieldLabels.get(fieldName)));
        }


        wrapperMap.put(viewFields,new List<FieldWrapper>());
        for(String fieldName : toView){
            wrapperMap.get(viewFields).add(new FieldWrapper(fieldName,true,true,'underLinded inactive cursorPointer',fieldLabels.get(fieldName)));
        }

        wrapperMap.put(editFields,new List<FieldWrapper>());
        for(String fieldName : toEdit){
            wrapperMap.get(editFields).add(new FieldWrapper(fieldName,true,true,'underLinded inactive cursorPointer',fieldLabels.get(fieldName)));
        }

        return wrapperMap;
    }

    @AuraEnabled
    public static Boolean checkCanEdit(){
        User loggedUser = CSP_Utils.getLoggedUser();
        if (loggedUser.Contact.User_Portal_Status__c == 'Approved Admin') {
            if (!loggedUser.Profile.Name.contains('Airline') ) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
 
    }

    @AuraEnabled
    public static String goToOldIFAP(Boolean hasContact, String contactId, String contactName){
        Id accountID = (myUser.Contact.Account.Top_Parent__c != null  ? myUser.Contact.Account.Top_Parent__c : myUser.Contact.AccountId);

        if (hasContact){
            return OneIdUtils.getCommunityRedirection (OneIdUtils.Mode.ISSP, 'ISSP_AssignFinancialContact' + '?id=' + accountID + '&vContactId=' + contactId + '&vContactName=' + contactName);
        } else {
            return OneIdUtils.getCommunityRedirection (OneIdUtils.Mode.ISSP, 'ISSP_AssignFinancialContact' + '?id=' + accountID);
        }
    }

    @AuraEnabled
    public static Boolean isAdminAndIATAAgencyAcct(){
        Boolean isIATAAgencyAcct = false;
        Boolean isAdmin = CSP_Utils.isAdmin();

        String categoryAcc = (myUser.Contact.Account.Top_Parent__c == null ? myUser.Contact.Account.Category__c : myUser.Contact.Account.Top_Parent__r.Category__c);

        isIATAAgencyAcct = categoryAcc == 'IATA Passenger Sales Agent' || categoryAcc == 'IATA Cargo Agent';

        return isIATAAgencyAcct && isAdmin;

    }


    @AuraEnabled
    public static String goToPrivacyPortal(){
        return OneIdUtils.getCommunityRedirection (OneIdUtils.Mode.GDPR, '');
    }

    @AuraEnabled
	public static List<Account_Domain__c> getAccountDomains(Id accountId){
		return [SELECT Id, Name, CreatedDate, Account__c, Account__r.Name FROM Account_Domain__c WHERE Account__c =: accountId];
	}

	@AuraEnabled
	public static Boolean isAccountDomain(){
		return isAccountDomain;
	}

	@AuraEnabled
	public static List<Account> getMapHierarchyAccounts(Id contactId) {
		if(contactId == null) 
			return new list<Account>();

		Contact con = [Select id, AccountId from Contact where id = :contactId];

		Account account = [
					Select id, Name,
					ParentId,
					Parent.ParentId,
					Parent.Parent.ParentId,
					Parent.Parent.Parent.ParentId,
					Parent.Parent.Parent.Parent.ParentId
					From Account
					Where id = :con.AccountId ];

				// find the top parent
				Id parentId = null;
				if (account.ParentId == null ) {
					parentId = account.Id;
				} else if (account.Parent.ParentId == null ) {
					parentId = account.ParentId;
				} else if (account.Parent.Parent.ParentId == null ) {
					parentId = account.Parent.ParentId;
				} else if (account.Parent.Parent.Parent.ParentId == null ) {
					parentId = account.Parent.Parent.ParentId;
				} else if (account.Parent.Parent.Parent.Parent.ParentId == null ) {
					parentId = account.Parent.Parent.Parent.ParentId;
				} else {
					parentId = account.Parent.Parent.Parent.Parent.ParentId;
				}

		// Get all account in the hierarchy
		return new List<Account>([
			SELECT Id,Name, Site, IATA_ISO_Country__c, Location_Type__c, BillingStreet, IsPartner,
				BillingCity, BillingPostalCode, BillingState, BillingCountry, IATA_ISO_Country__r.Name
			FROM Account
			WHERE RecordTypeId IN :VALID_ACCOUNT_RT
			AND Status__c != 'Terminated'
			AND Id != :con.AccountId 
			AND ( Id = :parentId
			OR ParentId = :parentId
			OR Parent.ParentId = :parentId
			OR Parent.Parent.ParentId = :parentId
			OR Parent.Parent.Parent.ParentId = :parentId
			OR Parent.Parent.Parent.Parent.ParentId = :parentId)]);
	}

	@AuraEnabled
	public static void relocateContact(Account acc, String contactId) {
        try {
            Contact con = [SELECT Id, AccountId FROM Contact where Id =: contactId];
            
			// set  parent account as partner user 
            if (!acc.IsPartner) {
                acc.IsPartner = true;
                update acc;
            }

            // relocate contact
            con.AccountId = acc.Id;
            update con;

        } catch (DMLException e) {
            System.debug('DML ERROR RelocateContact ' + e.getMessage());
			throw new PortalProfileException(Label.ISSP_Relocate_Failed + ' - ' + e.getMessage());
        } catch (Exception e) {
            System.debug('ERROR RelocateContact ' + e.getMessage());
			throw new PortalProfileException(Label.ISSP_Relocate_Failed + ' - ' + e.getMessage());
        }
    }

}