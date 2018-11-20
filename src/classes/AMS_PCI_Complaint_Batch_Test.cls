@isTest
private class AMS_PCI_Complaint_Batch_Test {

	@testSetup static void setup() {		

		ID certRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CERTIFICATION'); //FM AMSU-113
		
		DateTime dt = system.now()+90;
		Date d = date.newinstance(dt.year(), dt.month(), dt.day());
		
		System.debug('d: ' + d);

		

		List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', Region__c = 'Americas');
		countrylist.add(isoc1);
		insert countrylist;
		
		List<Account> agencylist = new List<Account>();
		Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Account a1 = new Account(Name='Test1 Agency', RecordtypeId=agencyRT,
			IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true, 
			IATACode__c = '12345678', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED, 
			Is_PCI_compliant__c = 'No', ANG_PCI_compliance_expiry_date__c = d);
		agencylist.add(a1);

		insert agencylist;

        Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1_2', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'testmauz@testmauz.com', BSP_CASS_Payment_contact__c = true, User_Portal_Status__c = 'Approved Admin');
        Contact co2 = new Contact(AccountId = a1.id, Firstname = 'teste2_3', Lastname='test2', Phone = '911111112', MobilePhone = '911111112', Email = 'test2mauz@testmauz.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved Admin');
        Contact co3 = new Contact(AccountId = a1.id, Firstname = 'teste3_4', Lastname='test3', Phone = '911111113', MobilePhone = '911111113', Email = 'test3@test.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved');
		
		List<Contact> cos = new List<Contact>{co1,co2}; 
		insert cos;

        User testUser1 = createPortalUser(co1);
        co1.OwnerId = testUser1.Id;
        update co1;

        User testUser2 = createPortalUser(co2);
        co2.OwnerId = testUser2.Id;
        update co2;

        

        

		//AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = acc1.Id, recordTypeID == certRT);
		//AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = AMS_Utils.RECTYPE_CERT, Account__c = acc1.Id,
		//                            Process__c = AMS_Utils.PCI_COMPLIANT, Status__c='Accepted_Future Date', ANG_PCI_compliance_expiry_date__c = acc1.ANG_PCI_compliance_expiry_date__c);

	}
	
	@isTest
	static void runStartTest() {		
		Test.startTest();
		AMS_PCI_Complaint_Batch.start('0 1 * * * ?', 1);
		AMS_PCI_Complaint_Batch.ErrorWrapper err = new AMS_PCI_Complaint_Batch.ErrorWrapper(null, 'test');
		Id accountId = err.accountId;
		String message = err.message;

		//AMS_PCI_Complaint_Batch batch = new AMS_PCI_Complaint_Batch();
		List<AMS_PCI_Complaint_Batch.ResultWrapper> resChunk = new List<AMS_PCI_Complaint_Batch.ResultWrapper>();
		try {
			DateTime dt = system.now();
			Date d2 = date.newinstance((dt.year() + 1), dt.month(), dt.day());
			Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
			List<Account> agencylist = [SELECT Id, Name, Is_PCI_compliant__c, ANG_PCI_compliance_expiry_date__c, Abbreviated_address__c, Abbreviated_name__c, BillingState, BillingCity, IATA_ISO_Country__c, Email__c, Fax, Phone, BillingPostalCode, BillingStreet, CASS_Number__c, IATACode__c, Iso_State__c, License_Number__c, VAT_Number__c, Is_your_firm_handling_Dangerous_Goods__c, Location_Class__c,Location_Type__c, Mobile__c, Operation__c, Remittance_frequency__c, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet, Short_Name__c, Solicitation_Flag__c, TradeName__c, VAT_Number_2__c, Website, BillingCountry, Region_formula__c, Legal_name__c, IATA_ISO_Country__r.Name, IATA_ISO_Country__r.ISO_Code__c, Company_Type__c, Status__c FROM Account WHERE RecordtypeId=:agencyRT];
			System.debug('agencylist: ' + agencylist);
		    AMS_PCI_Complaint_Batch.validateCandidatesForRenewal(agencylist, resChunk, false);

		    List<AMS_OSCAR__c> oscars = [SELECT Id, Is_PCI_compliant__c, Process__c, Account__c, Location_Class__c, ANG_PCI_compliance_expiry_date__c, Status__c, STEP6__c, Oscar_Communication_Case_Id__c FROM AMS_OSCAR__c WHERE  Process__c = :AMS_Utils.PCI_COMPLIANT AND RecordTypeId = :AMS_Utils.RECTYPE_CERT AND Status__c = 'Accepted_Future Date'];

		    loadCredentials();
		    List<AmazonFile__c> listFile = new List<AmazonFile__c>();
		    for(AMS_OSCAR__c oscar : oscars){
		    	AmazonFile__c aFile = new AmazonFile__c(
		        	Full_Name_Unique__c = 'test name',
		        	Case__c = oscar.Oscar_Communication_Case_Id__c
		    	);
		    	listFile.add(aFile);
		    }
		    insert listFile;

		    System.debug('oscars: ' + oscars);
		    for(AMS_OSCAR__c oscar : oscars){
		    	if(oscar.Is_PCI_compliant__c == null ){
		    		oscar.Is_PCI_compliant__c = 'No';
		    	}else if(oscar.Is_PCI_compliant__c == 'No' ){
		    		oscar.Is_PCI_compliant__c = 'Yes';
		    	}else if(oscar.Is_PCI_compliant__c == 'No' ){
		    		oscar.Is_PCI_compliant__c = 'Nil CC';
		    	}
		    	oscar.STEP6__c = 'Passed';
		    	oscar.ANG_PCI_compliance_expiry_date__c = d2;
		    }
		    update oscars;  

		    AMS_OSCAR__c o0 = oscars[0];
		    AMS_OSCAR__c o1 = o0.clone(true, true, true, true);
		    AMS_OSCAR__c o2 =  o0.clone(true, true, true, true); 
		    o1.Is_PCI_compliant__c = 'Yes';
		    o1.Process__c = AMS_Utils.PCI_COMPLIANT;
		    o1.STEP6__c = AMS_Utils.PASSED;
		    o2.STEP6__c = 'Not Started';

		    List<AMS_OSCAR__c> l1 = new List<AMS_OSCAR__c> {o1};
		    Map<Id,AMS_OSCAR__c> m1 = new Map<Id, AMS_OSCAR__c> {o2.Id => o2};

		    system.debug('o1: ' + o1);
		    system.debug('o2: ' + o2);
		    AMS_OscarTriggerHandler.updateAccountPCICompliant(l1, m1);  

		} catch(Exception e) {
		    for(AMS_PCI_Complaint_Batch.ResultWrapper r : resChunk) {
		        r.message = e.getMessage();
		        r.cse = null;
		    }         
		}
		Test.stopTest();	
	}

	static testMethod void test2() {		
		Test.startTest();
		AMS_PCI_Complaint_Batch.stop();
		Test.stopTest();
	}
	
	private static void loadCredentials() {
	    Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
	    Amazon_Cred__c GenericAttach =  new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
	    Amazon_Cred__c recycleBin =  new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
	    List<Amazon_Cred__c> creds = new List<Amazon_Cred__c>();
	    creds.add(Amazon_Cred);
	    creds.add(GenericAttach);
	    creds.add(recycleBin);
	    insert creds;


	    list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
	        new AWSKey__c(
	            name = 'adevconf',
	            Key__c = 'asd', 
	            Secret__c = 'asd',  
	            IAS_configuration_name__c = 'asdas', 
	            IAS_Access_Point__c = 'asd',
	            Bucket__c = 'asd',
	            AWS_ENDPOINT_URL__c = 'asd')
	    };
	    insert AWS_KEYs;
	}

        public static User createPortalUser(Contact con) {
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + con.Firstname;
            String conId15 = con.Id;
            //conId15 = conId15.substring(0,15);
            String UserNameStr=uniqueName+ string.valueof(randomInt) + '@test' + orgId + '.org';
            String ComNickNameStr=con.email.substring(0, con.email.indexOf('@'))+randomInt;//Datetime.now().formatLong().substring(10,15);
            system.debug('basto1p TEST UserName='+UserNameStr);
            system.debug('basto1p TEST ComNickNameStr='+ComNickNameStr);
           User newUser = new User(alias = 'dsfsdfds', 
                                    email = con.email, 
                                    emailencodingkey = 'UTF-8', 
                                    firstname = con.firstName, 
                                    lastname = con.lastname, 
                                    languagelocalekey = 'en_US', 
                                    localesidkey = 'en_US', 
                                    contactId = con.Id,
                                    FederationIdentifier = conId15,
                                    timezonesidkey = 'Asia/Dubai',
                                    Username = con.Email,
                                    PortalRole = 'Manager',
                                    CommunityNickname = ComNickNameStr,
                                    ProfileId = ISSP_Constant.TEST_User_ProfileID,
                                    IsActive = true);
            insert newUser;
            return newUser;
        }

}
