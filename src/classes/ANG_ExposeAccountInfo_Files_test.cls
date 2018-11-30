@isTest
private class ANG_ExposeAccountInfo_Files_test {
	
    @testSetup static void setup() {

    	List<AWSKey__c> keys = new List<AWSKey__c>();
    	keys.add(new AWSKey__c(
    		Name = 'IFAP_DEV',
    		Bucket__c = 'test',
    		AWS_ENDPOINT_URL__c = 'https://test1.com/'));
       	keys.add(new AWSKey__c(
    		Name = 'IFAP_PROD',
    		Bucket__c = 'test',
    		AWS_ENDPOINT_URL__c = 'https://test2.com/'));
       	insert keys;

        List<Amazon_Cred__c> amazon_Creds =  new List<Amazon_Cred__c>();
        amazon_Creds.add(new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'IFAP_PROD' , Dev_Configuration__c = 'IFAP_DEV'));
        amazon_Creds.add(new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'IFAP_PROD' , Dev_Configuration__c = 'IFAP_DEV'));
        insert amazon_Creds;

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true, AIMS_Area_ID__c = '3');
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
        insert stt;
        
        Account account = new Account();
        account.Name = 'Main HE Account H1';
        account.Sector__c = 'Travel Agent';
        account.IATACode__c = '12345678';
        account.Category__c = 'IATA Passenger Sales Agent';
        account.Location_Class__c = 'P';
        account.Location_Type__c = 'HE';
        account.ANG_Accreditation_Model__c = 'Cashless';
        account.IATA_ISO_Country__c = ctry.Id;
        account.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        account.BillingCountry = 'US';
        account.GDI_Status__c = 'Open';
        insert account;

        Contact newContact1 = new Contact();
        newContact1.FirstName = 'Tony';
        newContact1.LastName = 'Barracuda';
        newContact1.Email = 'Tony.Barracuda123456789@test.com';
        newContact1.Financial_Assessment_Contact__c = true;
        insert newContact1;

        Case cse = new Case(
        	RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case','IATA_Financial_Review'),
        	IFAP_Financial_Year__c = string.ValueOf(system.today().year()),
        	AccountId = account.Id,
        	Origin = 'asd',
        	Subject = 'test',
        	Description = 'test',
        	Status = 'Open',
        	ContactId =  newContact1.Id,
        	Financial_Review_Result__c = 'Satisfactory - New Financial Security',
        	IFAP_Country_ISO__c = ctry.ISO_Code__c,
        	Deadline_Date__c = Date.today() + 30,
        	Financial_Review_Type__c = 'Annual',
			Assessment_Performed_Date__c = system.today()
        );
        insert cse;


        AmazonFile__c aFile = new AmazonFile__c(Name ='file',Full_Name_Unique__c = 'IFAP/FinancialDocument/test', case__c = cse.id, Category__c = 'Contractual', Subcategory__c = 'Signatory Authority');
        insert aFile;

    }
	
	@isTest static void test_exposeAccountInfo_Files() {

		RestResponse response = new RestResponse();
		RestContext.response = response;

		ANG_ExposeAccountInfo_Files.ANG_ExposeAccountInfo_Files(new Account(IATAcode__c = '12345678'), 'FinancialStatement','Agency','GDI');
	}
}