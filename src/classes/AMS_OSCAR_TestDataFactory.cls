public with sharing class AMS_OSCAR_TestDataFactory
{
	public static void createOSCARtestData()
	{
		AMS_Person__c per = new AMS_Person__c(Name = 'teste', User__c = UserInfo.getUserId());
		insert per;

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
        insert stt;
		
		Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');
		Account account = new Account();
		account.Name = 'TestAccount';
		account.Type = 'Airport';
		account.IATACode__c = '1234567';
		insert account;
		
		List<Account> accountList = new List<Account>();
		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency');
		insert a1;
        
		AMS_OSCAR__c OSCAR = new AMS_OSCAR__c(STEP1__c = 'In Progress', Account__c = a1.id);
		insert OSCAR;

		Map<string, Id> caseRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case');

		//Case c = new Case(OSCAR__c = OSCAR.Id, recordtypeid = caseRT.get('OSCAR_Communication'));
		//insert c;
		Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c(Active__c = true, /*Change_Code__c = acc.id,MACREVIEW*/ Account__c = a1.id);
		insert aacc;
		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;
		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = AMS_Utils.getId('Case', 'OSCAR_Communication'));
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;


        //create oscar history custom setting
        List<AMS_OSCAR_HistoryFields__c> customsettings = new List<AMS_OSCAR_HistoryFields__c>();
		customsettings.add(new AMS_OSCAR_HistoryFields__c(Name = 'Welcome_Pack_Sent__c', HasExternalLabel__c = false, FieldName__c ='Welcome Pack Sent'));

		insert customsettings;
	}    
}