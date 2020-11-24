@isTest
public class CW_EmailManagerTest {


	@TestSetup
	private static void setup(){
		String orgId=UserInfo.getOrganizationId(); 
		Profile pf= [Select Id from profile where Name = 'System Administrator' limit 1]; 
		String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
		Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
		String uniqueName=orgId+dateString+RandomId;

		IATA_ISO_Country__c isoCode = CW_TestDataFactory.newISOCountry();
		insert isoCode;

		Account acc = new Account (Name = 'Account01', IATA_ISO_Country__c = isoCode.Id);
		insert acc;

				
		Airport_Detail__c airport = CW_TestDataFactory.newAirport(isoCode.Id, acc.Id);
		insert airport;

		Account_Role__c accRole = new Account_Role__c(Account_Role_Name__c = 'Test', Account__c = acc.Id);
		insert accRole;

		ICG_Account_Role_Detail__c ard = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		insert ard;

		User uu=new User(firstname = 'IATAICGABCUnique', 
		lastName = 'IATAICGXYZUnique', 
		email = uniqueName + '@test' + orgId + '.org', 
		Username = uniqueName + '@test' + orgId + '.org', 
		EmailEncodingKey = 'ISO-8859-1', 
		Alias = uniqueName.substring(18, 23), 
		TimeZoneSidKey = 'America/Los_Angeles', 
		LocaleSidKey = 'en_US', 
		LanguageLocaleKey = 'en_US', 
		ProfileId = pf.Id,
		License_Cost_Center__c = 'XSMW01JO01'
	   );

		insert uu;

		System.runAs(uu) {

			Group gro = new Group(Name = 'TheTestQueue', type = 'Queue');
			insert gro;
			
			GroupMember member = new GroupMember();
			member.UserOrGroupId = uu.Id;
			member.GroupId = gro.Id;
			insert member;
			
			Group groStakeholders = new Group(Name = 'ICG_Stakeholders');
			insert groStakeholders;
			
			GroupMember stakeholderMember = new GroupMember();
			stakeholderMember.UserOrGroupId = uu.Id;
			stakeholderMember.GroupId = groStakeholders.Id;
			insert stakeholderMember;

			EmailTemplate template = new EmailTemplate();
			template.DeveloperName = 'Approve_Reject_to_company_admin';
			template.Name = 'Test';
			template.FolderId = uu.Id;
			template.TemplateType = 'text';
			template.isActive = true;
			insert template;
		}
	}

	@isTest 
	public static void prepareInternalEmails(){
		Test.startTest();

		ICG_Account_Role_Detail__c station = [Select Id from ICG_Account_Role_Detail__c LIMIT 1];
		List<User> iataAdmins = [Select id, name, email from User where Id IN (Select UserOrGroupId from GroupMember Where Group.Name = 'TheTestQueue')];
		Set<Id> whoIds = new Set<Id>();
		for(User us : iataAdmins){
			whoIds.add(us.Id);
		}
		
		String emailTemplate = 'Approve_Reject_to_company_admin';
		List<Messaging.SingleEmailMessage> emails =  CW_EmailManager.prepareInternalEmails(emailTemplate, station.Id, whoIds);
		System.assert(!emails.isEmpty(), 'No emails were prepared');
		Test.stopTest();
	}

	@isTest 
	public static void prepareInternalEmailsEmpty(){
		Test.startTest();

		String emailTemplate = 'Approve_Reject_to_company_admin';
		List<Messaging.SingleEmailMessage> emails =  CW_EmailManager.prepareInternalEmails(emailTemplate, null, new Set<Id>());
		System.assert(emails.isEmpty(), 'Emails were prepared when it should have been empty');
		Test.stopTest();
	}

	@isTest 
	public static void sendInternalEmails(){
		Test.startTest();

		ICG_Account_Role_Detail__c station = [Select Id from ICG_Account_Role_Detail__c LIMIT 1];
		List<User> iataAdmins = [Select id, name, email from User where Id IN (Select UserOrGroupId from GroupMember where Group.DeveloperName = 'ICG_Stakeholders')];
		Set<Id> whoIds = new Set<Id>();
		for(User us : iataAdmins){
			whoIds.add(us.Id);
		}
		
		String emailTemplate = 'Approve_Reject_to_company_admin';
		List<Messaging.SingleEmailMessage> emails =  CW_EmailManager.prepareInternalEmails(emailTemplate, station.Id, whoIds);
		Boolean result = CW_EmailManager.sendInternalEmails(emails);

		System.assert(!result, 'Emails were not sent successfully');
		Test.stopTest();
	}

	@isTest 
	public static void sendInternalEmailsEmpty(){
		Test.startTest();
		Boolean result = CW_EmailManager.sendInternalEmails(new List<Messaging.SingleEmailMessage>());
		System.assert(!result, 'Emails were successful even when they should not have been sent');
		Test.stopTest();
	}

	@isTest 
	public static void getIataAdminsIds(){
		Test.startTest();
		Set<Id> iataAdmins = CW_EmailManager.getIataAdminsIds();
		System.assert(!iataAdmins.isEmpty(), 'No iata admins were generated');
		Test.stopTest();
	}

	@isTest 
	public static void getCompanyAdminsIds(){
		Test.startTest();
		String accountId = [Select Id from Account Limit 1].Id;
		Contact con = CW_TestDataFactory.testContact(accountId);
		insert con;

		Set<Id> companyAdmins = CW_EmailManager.getCompanyAdminsIds(accountId);
		System.assert(!companyAdmins.isEmpty(), 'No company admins were generated');
		Test.stopTest();
	}
	
}