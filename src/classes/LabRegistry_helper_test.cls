
@isTest
public class LabRegistry_helper_test {
	static final string LabUserEmail = 'labContact@testLabRegistry.testLabRegistry';
	static final id airlineRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

	@testsetup
	static void createData(){
		insert new Apex_Setting__c(Name='RT valid to reopen attachment trigger', Text_1__c='CasesEurope,Cases_Global,CasesAmericas,CasesMENA,ExternalCasesIDFSglobal,Cases_China_North_Asia, ComplaintIDFS,'
										   +  'Inter_DPCs,Invoicing_Collection_Cases,Cases_SIS_Help_Desk,InternalCasesEuropeSCE,CS_Process_IDFS_ISS,ID_Card_Application');

		Portal_Applications__c pa = new Portal_Applications__c(name = LabRegistry_helper.labRegistryAccnRole, Functional_Role__c=LabRegistry_helper.labRegistryAccnRole);
		insert pa;

		Attachment a = new Attachment(
			IsPrivate = true,
			ParentId = pa.Id,
			Body = Blob.valueOf('Test'),
			Name = 'testAttachment'
		);
		insert a;

		IATA_ISO_Country__c italy = new IATA_ISO_Country__c(ISO_Code__c='IT', Name='Italy', Region__c ='Europe');
		list<IATA_ISO_Country__c> lsCountries = new list<IATA_ISO_Country__c>{
			Italy,
			new IATA_ISO_Country__c(ISO_Code__c='US', Name='United States', Region__c ='Americas'),
			new IATA_ISO_Country__c(ISO_Code__c='AU', Name='Australia', Region__c ='Asia & Pacific'),
			new IATA_ISO_Country__c(ISO_Code__c='ZA', Name='South Africa', Region__c ='Africa & Middle East'),
			new IATA_ISO_Country__c(ISO_Code__c='MO', Name='Macao SAR, China', Region__c ='China & North Asia')};
		
		insert lsCountries;
		
		list<Account> lsAccnt = new list<Account>();

		lsAccnt.add(new account(name = 'Laboratory',  IATA_Iso_Country__c = Italy.Id, sector__c = 'Healthcare Industry', category__c = 'Laboratory', recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account')));
		lsAccnt.add(new account(name = 'Alitalia', recordtypeId = airlineRTId));
		lsAccnt.add(new account(name = 'Air France', recordtypeId = airlineRTId));
		lsAccnt.add(new account(name = 'Lufthansa', recordtypeId = airlineRTId));
		lsAccnt.add(new account(name = 'TAP', recordtypeId = airlineRTId));
		lsAccnt.add(new account(name = 'American Airlines', recordtypeId = airlineRTId));

		insert lsAccnt;

		Account accnt = [select id from Account where name = 'Laboratory'];

		Contact labContact = new Contact(
			accountId = accnt.Id
			,firstName='Lab'
			,lastName='Contact'
			,Email = LabUserEmail
			,Preferred_Language__c = 'English'
		);

		insert labContact;

		Id profileId = [select Id from profile where Name=:'ISS Portal (Partner)'].Id;

		User newUser = new User(alias = 'test',
								email = LabUserEmail,
								emailencodingkey = 'UTF-8',
								firstname = labContact.firstName,
								lastname = labContact.lastname,
								languagelocalekey = 'en_US',
								localesidkey = 'en_US',
								contactId = labContact.Id,
								timezonesidkey = 'Asia/Dubai',
								Username = LabUserEmail,
								PortalRole = '',
								CommunityNickname = 'test User',
								ProfileId = profileId,
								IsActive = true);
		insert newUser;
	}

    @isTest static void testgetAirlinesHQ(){
		system.assertEquals(5, LabRegistry_helper.getAirlinesHQ().size());
	}

	@isTest static void testCreateCase(){
		user runningUser = [select id from user where email=:LabUserEmail];
		case theCase;
		System.runAs(runningUser){
			theCase = LabRegistry_helper.CreateCase('New access request', null);
		}

		system.assertNotEquals(null, theCase);
	}


	@istest static void testGetAttachmentFromPortalService(){
		user runningUser = [select id from user where email=:LabUserEmail];
		
		System.runAs(runningUser){
			system.assertEquals(null, LabRegistry_helper.getAttachmentFromPortalService('asdasdasdsda'));
			system.assertNotEquals(null, LabRegistry_helper.getAttachmentFromPortalService('testAttachment'));
		}
	}

	@istest static void getAccountName(){
		user runningUser = [select id, profile.name, ContactId, Contact.AccountId, contact.Account.IATA_Iso_Country__r.Region__c, contact.account.name from user where contact.email=:LabUserEmail];

		System.runAs(runningUser){
			system.assertNotEquals(null, LabRegistry_helper.getAccountName());
		}
	}

	@isTest static void testsaveSurveyAnswers(){
		user runningUser = [select id, profile.name, ContactId, Contact.AccountId, contact.Account.IATA_Iso_Country__r.Region__c, contact.account.name from user where contact.email=:LabUserEmail];
		set<id> setAccntId = new set<id>();

		for(Account airlines:[select id from Account where RecordTypeId =:airlineRTId])
			setAccntId.add(airlines.id);

		System.runAs(runningUser){
			LAB_Account_Role_Detail__c labRoleDetail = new LAB_Account_Role_Detail__c();
			list<LAB_Account_Role_Detail__c> lsCountriesLab = new list<LAB_Account_Role_Detail__c>();
			list<LAB_Account_Role_Detail__c> lsAirlineAgreement = new list<LAB_Account_Role_Detail__c>();

			for(id airlineId:setAccntId){
				lsAirlineAgreement.add(new LAB_Account_Role_Detail__c(Partner_Airline__c = airlineId));
			}

			for(IATA_Iso_Country__c country:[select id from IATA_Iso_Country__c])
				lsCountriesLab.add(new LAB_Account_Role_Detail__c(Operating_Country__c = country.Id, How_Many_Lab__c=10));
			
			labRoleDetail.How_long_have_you_been_in_the_business__c = '2+ years';
			labRoleDetail.Do_you_manage_booking_for_all_locations__c = 'No';
			labRoleDetail.Do_you_issue_test_results_for_all_lab__c = 'No';
			labRoleDetail.Are_your_labs_part_of_national_platform__c = 'No';
			labRoleDetail.Existing_partnership_with_airlines__c = 'Yes';
			labRoleDetail.Operating_under_brand__c = 'No';
			labRoleDetail.Type_of_SLAs_in_place__c = 'No';
			labRoleDetail.Type_of_lab__c = 'Clinic';
			labRoleDetail.National_accreditation_for_all_the_labs__c = 'No';
			labRoleDetail.Additional_certifications_in_place__c = 'No';
			labRoleDetail.Endorsed_by_governments__c = 'No';

			labRoleDetail.Lab_Type__c = 'Independent Lab';
			system.assertEquals(true, LabRegistry_helper.saveSurveyAnswers(labRoleDetail, lsCountriesLab, lsAirlineAgreement));
			system.assertEquals(1, [select Id from Account_Role__c where Functional_Role__c = :LabRegistry_helper.labRegistryAccnRole].size());
			system.assertEquals(1, [select Id from Case where subject like '%New access request%'].size());
			system.assertEquals(1, [select Id from LAB_Account_Role_Detail__c where recordtype.developername='Independent_Lab'].size());
			system.assertEquals(1, [select Id from Portal_Application_Right__c where Portal_Application__r.Functional_Role__c=:LabRegistry_helper.labRegistryAccnRole].size());
			system.assertEquals(lsCountriesLab.size(), [select Id from LAB_Account_Role_Detail__c where recordtype.developername='Operating_Country'].size());
			system.assertEquals(lsAirlineAgreement.size(), [select Id from LAB_Account_Role_Detail__c where recordtype.developername='Airline_Agreement'].size());
		}

		LabRegistry_helper.SavedDataWrapper oWrap = LabRegistry_helper.retrieveSavedData([select Id from Case where subject like '%New access request%'].Id);
		system.assertNotEquals(null, oWrap);

		system.assertEquals(true, LabRegistry_helper.ApproveDenyApplication([select Id from Portal_Application_Right__c where Portal_Application__r.Functional_Role__c=:LabRegistry_helper.labRegistryAccnRole].Id, 'Access Granted'));

		system.debug('DTULLO AirlineId: ' + setAccntId);
	}

	@isTest static void testSendToMulesoft(){
		test.startTest();
		Test.setMock(HttpCalloutMock.class, new LabRegistry_helper_test.MulesoftMock());
		LabRegistry_helper.postFileToMulesoft('test', blob.valueOf('test'), 'csv');
		test.stopTest();
	}





	public class MulesoftMock implements HttpCalloutMock{
		public HTTPResponse respond(HTTPRequest req){
			HttpResponse res = new HttpResponse();
			res.setStatusCode(200);
			return res;
		}
	}
}
