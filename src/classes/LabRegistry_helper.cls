public  without sharing class LabRegistry_helper {
	public static final string labRegistryAccnRole = 'Lab Registry';
	public static final string labRegistryServiceName = 'IATA Lab Network';

	/*****
	 * 
	 * Method is used to retrieve all Airlines' HQ to be displayed in IATA Lab Network portal service
	 * 
	 ***/
	@AuraEnabled(cacheable=true)
	public static list<Account> getAirlinesHQ(){
		list<Account> lsAirline = new list<Account>([select id, name, Airline_designator__c, AccountStatus__c, Site, IATA_ISO_Country__r.Name, IATA_ISO_Country__r.ISO_Code__c, Region__c, recordtypeId  from account where recordtype.developername = 'IATA_Airline' order by Name asc]);
		return lsAirline;
	}

	/***
	 * method crates the case used by ITP
	 */
	@AuraEnabled
	public static case CreateCase(string reason, user currentUser){
		if(currentUser == null)
			currentUser = [select id, ContactId, Contact.AccountId, contact.Account.IATA_Iso_Country__r.Region__c, contact.account.name from user where id =: UserInfo.getUserId()];
		
		Case theCase = new case();
			theCase.recordtypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CS_Process_IDFS_ISS');
			theCase.ContactId = currentUser.ContactId;
			theCase.AccountId = currentUser.Contact.AccountId;
			theCase.subject = (labRegistryServiceName + ' - ' + reason + ' for ' + currentUser.contact.account.name).left(255);
			
			theCase.Origin = 'Portal';
			theCase.Region__c = currentUser.contact.Account.IATA_Iso_Country__r.Region__c;
			theCase.CaseArea__c = 'IATA Travel Pass';
			theCase.Reason1__c = reason;
		insert theCase;

		return [select Id, CaseNumber from case where id=:theCase.Id];
	}
	/****
	 * Method used to Save IATA Lab Network survey's answers.
	 * 
	 *  @input: 
	 * 		LAB_Account_Role_Detail__c labRoleDetail: used to store the answers to form
	 * 		list<LAB_Account_Role_Detail__c> lsCountriesLab: used to store how many labs in each country a lab have. each record is child of labRoleDetail
	 * 		list<LAB_Account_Role_Detail__c> lsAirlineAgreement: used to store airlines havign agreement with the lab. Each record is child of labRoleDetail
	 * @output:
	 * 	boolean. True = all good. False, something went wrong
	 * 
	 * Method also creates a case, which is saved on the labRoleDetail detail record
	 * Method created a portal service access with status = access requested
	 * 
	 */

	@AuraEnabled
	public static boolean saveSurveyAnswers(LAB_Account_Role_Detail__c labRoleDetail
											, list<LAB_Account_Role_Detail__c> lsCountriesLab
											, list<LAB_Account_Role_Detail__c> lsAirlineAgreement){
		try {
			user currentUser = [select id, ContactId, Contact.AccountId, contact.Account.IATA_Iso_Country__r.Region__c, contact.account.name from user where id =: UserInfo.getUserId()];
			//Create Account Role
			//check if Account Role with the same type already exists
			Account_Role__c accntRole;

			list<Account_Role__c> lsAccntRole = [select Id from Account_Role__c where Account__c=:currentUser.Contact.AccountId AND Functional_Role__c = :LabRegistry_helper.labRegistryAccnRole];
			if(lsAccntRole == null || lsAccntRole.isEmpty()){
				accntRole = new Account_Role__c();
				accntRole.Account__c = currentUser.Contact.AccountId;
				accntRole.Functional_Role__c = LabRegistry_helper.labRegistryAccnRole;
				accntRole.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');
				insert accntRole;
			}else{
				accntRole = lsAccntRole[0];
			}

			//Create Case
			case theCase = LabRegistry_helper.CreateCase('New access request', currentUser);

			//Create Account Role Detail. Main answers
			labRoleDetail.Onboarding_Case__c = theCase.Id;
			switch on labRoleDetail.Lab_Type__c {
				when 'IT Integrator' {
				    labRoleDetail.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LAB_Account_Role_Detail__c', 'IT_Integrator');
				}	
				when 'Aggregator' {
					labRoleDetail.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LAB_Account_Role_Detail__c', 'Aggregator');
				}
				when 'Independent Lab' {
					labRoleDetail.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LAB_Account_Role_Detail__c', 'Independent_Lab');
				}
				when 'Lab Partner/Network' {
					labRoleDetail.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LAB_Account_Role_Detail__c', 'Lab_Network');
				}
				when else {
					labRoleDetail.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LAB_Account_Role_Detail__c', 'Default');
				}
			}

			labRoleDetail.Account_Role__c = accntRole.Id;
			insert labRoleDetail;

			//Create Account Role details. How many labs per country
			for(LAB_Account_Role_Detail__c countryLabs:lsCountriesLab){
				countryLabs.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LAB_Account_Role_Detail__c', 'Operating_Country');
				countryLabs.Parent_Detail_For_Country__c = labRoleDetail.Id;
			}

			insert lsCountriesLab;

			//Create Account Role details. Airline partnership
			for(LAB_Account_Role_Detail__c airlineAgreements:lsAirlineAgreement){
				airlineAgreements.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LAB_Account_Role_Detail__c', 'Airline_Agreement');
				airlineAgreements.Parent_Detail_For_Airline__c = labRoleDetail.Id;
			}

			insert lsAirlineAgreement;

			//Create Access Requested Portal Application Right
			Portal_Application_Right__c pac = new Portal_Application_Right__c();
			pac.recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Portal_Application_Right__c', 'Application_rigth');
			pac.Contact__c = currentUser.ContactId;
			pac.Portal_Application__c = [select id from Portal_Applications__c where Functional_Role__c=:LabRegistry_helper.labRegistryAccnRole limit 1].Id;
			pac.Right__c = PortalServicesCtrl.PORTAL_ACCESS_REQUESTED;
			insert pac;

			return true;

			
		} catch (Exception e) {
			return false;
		}
	}

	/*****
	 * Method used to retrieve attachments from portal service IATA Lab Network.
	 * Files are shown in the homepage of the portal service.
	 * Note that only the latest attachment matching the file name is retrieved
	 * 
	 * @input:
	 * 		string filename: the name of the file to retrieve.
	 * @outpot:
	 * 		Attachment record
	 * 
	 */

	@AuraEnabled
	public static Attachment getAttachmentFromPortalService(string filename){
		try {
			Portal_Applications__c service = [select id from Portal_Applications__c where Functional_Role__c=:LabRegistry_helper.labRegistryAccnRole limit 1];
			List<Attachment> attachments = [select Id from Attachment WHERE parentId=:service.id and name = :filename order by lastmodifieddate desc LIMIT 1];
			if (attachments.size()>0) {
				return attachments[0];
			}
			return null;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * Invoked by internal users to approve or deny access to the portal service IATA Lab Network
	 * 
	 */

	@AuraEnabled
	public static boolean ApproveDenyApplication(ID PARID, string st){
		try{
			Portal_Application_Right__c PAR = new Portal_Application_Right__c();
			par.Id = PARID;
			par.Right__c = st;
			update PAR;
			return true;
		}catch(Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

	/***
	* Method used to retrieve answers to survey to be displayed to internal users to have them reviewing the application
	* 
	* 	@input:
			string recordId: ID of the case which is linked to the survey (account role detail)
		@output:
			a wrapper of the records.
	*/

	@AuraEnabled
	public static SavedDataWrapper retrieveSavedData(string recordID){
		LabRegistry_helper.SavedDataWrapper oReturn = new LabRegistry_helper.SavedDataWrapper();
		try {
			case theCase = [select contactId, id, Reason1__c, CaseArea__c from case where id =:recordID];
			LAB_Account_Role_Detail__c labRoleDetail = [select
															id
															,How_long_have_you_been_in_the_business__c
															,Lab_Type__c
															,Do_you_manage_booking_for_all_locations__c
															,Do_you_issue_test_results_for_all_lab__c
															,Are_your_labs_part_of_national_platform__c
															,Which_National_Platform__c //if above = YES
															,Existing_partnership_with_airlines__c
															//A FORM
															,Operating_under_brand__c
															,Which_Operating_Brand__c //IF above = YES
															,Type_of_SLAs_in_place__c
															,Nature_of_SLA__c //IF above = YES
															//B FORM
															,Type_of_lab__c
															,National_accreditation_for_all_the_labs__c
															,Additional_certifications_in_place__c
															,Additional_Certifications__c //IF Above = YES
															,Endorsed_by_governments__c
															,Which_Governments__c // IF Above = YES
															,onboarding_case__r.contactId
														from LAB_Account_Role_Detail__c 
														where onboarding_case__c = :recordID];

			list<LAB_Account_Role_Detail__c> lsCountriesLab = [select
																	id
																	,CountryName__c
																	,How_Many_Lab__c
																from LAB_Account_Role_Detail__c 
																where Parent_Detail_For_Country__c =:labRoleDetail.Id] ;

			list<LAB_Account_Role_Detail__c> lsAirlineAgreement = [select id, Airline_Name__c from LAB_Account_Role_Detail__c where Parent_Detail_For_Airline__c =:labRoleDetail.Id] ;
			
			Portal_Application_Right__c PAR = [select id, right__c from Portal_Application_Right__c where Contact__c=:labRoleDetail.onboarding_case__r.contactId and Portal_Application__r.Functional_Role__c=:LabRegistry_helper.labRegistryAccnRole];

			oReturn.labRoleDetail = labRoleDetail;
			oReturn.lsAirlineAgreement = lsAirlineAgreement;
			oReturn.lsCountriesLab = lsCountriesLab;
			oReturn.PAR = PAR;
			oReturn.onboardingCase = theCase;

			return oReturn;
			
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * defines the wrapper returned by the above method
	 */

	public class SavedDataWrapper{
		@AuraEnabled
		public Portal_Application_Right__c PAR;

		@AuraEnabled
		public LAB_Account_Role_Detail__c labRoleDetail;

		@AuraEnabled
		public list<LAB_Account_Role_Detail__c> lsCountriesLab;
		
		@AuraEnabled
		public list<LAB_Account_Role_Detail__c> lsAirlineAgreement;

		@AuraEnabled
		public Case onboardingCase;
	}

	/**
	 * Used to retrieve the account name of the user connected to the portal 
	 */

	@AuraEnabled
	public static string getAccountName(){
		return [Select contact.Account.Name from user where id=:UserInfo.getUserId()].contact.Account.Name;
	}

	/**
	 * Perform Callout to Mulesoft to post files
	 */
	@AuraEnabled
	public static string postFileToMulesoft(string filename, blob fileContent, string fileDataContentType){
		try {
			HttpRequest req = new HttpRequest();
			req.setHeader('Content-Type', 'application/json');
			req.setMethod('POST');
			req.setTimeout(120000);
			req.setEndpoint('callout:Mulesoft_LabRegistry');

			req.setBody('{"fileName": "' + filename + '","fileData": "' + EncodingUtil.base64Decode(EncodingUtil.base64Encode(fileContent)).toString() + '", "fileDataContentType": "' + fileDataContentType + '"}');
			Http h = new Http();
			HttpResponse res = h.send(req);

			return string.valueOf(res);
			
		} catch (Exception e) {
			return e.getCause() + ' - ' + e.getMessage();
		}
	}
}
