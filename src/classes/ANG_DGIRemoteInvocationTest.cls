@isTest
public class ANG_DGIRemoteInvocationTest {

	public static void testSetup(){
		/*
		Financial_Institution__c
		pricebook2
		pricebookentry



		criar account
		oscar
		criar fs
		opp


		para depois criar remote invocation e remote invocation artifact
		run

		testar que no final foi criado o Staging fs
		*/
		Financial_Institution__c fi = new Financial_Institution__c(name= 'GDI - Euler Hermes', Region__c = 'Europe', Country__c = 'Portugal', Institution_Type__c = 'Insurance Company');
		insert fi;

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
		insert ctry;

		Product2 prod = new Product2(Name = 'Test', IsActive = true);
		insert prod;

		/*using this instead of Test.getStandardPricebookId() will throw  STANDARD_PRICE_NOT_DEFINED
		pricebook2 pb = new pricebook2(name = 'NewGen Generic', IsActive = true);
		insert pb;*/

        ID standardPBID = Test.getStandardPricebookId();
		insert new pricebookentry(UnitPrice = 20, CurrencyIsoCode = 'EUR', Product2id = prod.id, IsActive = true, Pricebook2Id = standardPBID);


		Account acc = new Account(name = 'account name', Sector__c = 'Travel Agent', Category__c = 'Cargo only', IATACode__c = '1234567',
			Location_Type__c =AMS_Utils.HE, Location_Class__c = AMS_Utils.LC_PASSENGER, recordtypeid = AMS_Utils.RECTYPE_IATAAGENCY, IATA_ISO_Country__c = ctry.id );
		insert acc;


		AMS_OSCAR__c oscar = new AMS_OSCAR__c(STEP1__c = 'In Progress', Account__c = acc.id,Change_effective_as_of__c = Date.today());
		insert oscar;

		Contact contact = new Contact(AccountId = acc.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert contact;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'));
        oscarCase.AccountId = acc.Id;
        oscarCase.ContactId = contact.Id;
        insert oscarCase;


        case cc = new case(AccountId = acc.Id);
        insert cc;
        Financial_Security__c FS = new Financial_Security__c(CURRENCYISOCODE='USD', Account__c=acc.Id, AMOUNT__C=3000, EXPIRY_DATE__C=system.Today().AddDays(100), FINANCIAL_INSTITUTION__c=fi.Id, SECURITY_STATUS__C='Active', Security_Type__c='Bank Guarantee', Region__c ='Europe', Reception_Date__c=system.today(), Reasonforrequest__c='New Application', Reception_Case__c=cc.Id);
        insert FS;

        ID oppRecordtype = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'GDI_FinancialSecurity'); 
        Opportunity opp = new Opportunity(AccountId = acc.id, CloseDate = Date.today(), CurrencyIsoCode = 'USD', Name ='OPP - ' , RecordTypeId = oppRecordtype, StageName = 'Pending', Related_Oscar__c = oscar.id);
        insert opp;
	}


	@isTest
	public static void testNoAccountFound() {

		testSetup();

/*
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
		insert ctry;

		//not assigning the correct recordtype to the account
		Account acc = new Account(name = 'account name', Sector__c = 'Travel Agent', Category__c = 'Cargo only', IATACode__c = '1234567',
			Location_Type__c =AMS_Utils.HE, Location_Class__c = AMS_Utils.LC_PASSENGER, recordtypeid = AMS_Utils.RECTYPE_IATAAGENCY, IATA_ISO_Country__c = ctry.id );
		insert acc;

		Contact c = new Contact(FirstName = 'test', LastName = 'contact', email = 'email@contactmeila.com', AccountId = acc.id);
		insert c;

		Portal_Applications__c pa = new Portal_Applications__c(name = 'IATA EasyPay (EDENRED)');
		insert pa;

		Portal_Application_Right__c par = new Portal_Application_Right__c(Right__c = 'Access Granted', 
			ANG_Portal_Service_Role__c = 'IEP Admin',Contact__c = c.id, Portal_Application__c = pa.id);
		insert par;
		
		try{
				
			//not assigning the correct iata code, trigger will fail
			Remote_Invocation__c re = new Remote_Invocation__c(Internal_ID__c = '111111', 
				Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_EASY_PAY,
				status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING);
			insert re;
            
			Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = re.id, Internal_ID__c = '111111');
			insert artifact;

			//Making the process starting to create the Bank Account Case OSCAR 
			re.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
			update re;
		}catch(Exception e){
			System.assert(e.getMessage().contains('Parent account with the IATA code 111111 not found.'), 'Error Message doesn\'t match: ' +e.getMessage());
		}

		List<AMS_OSCAR__c> oscars = [SELECT id FROM AMS_OSCAR__c];
		System.assertEquals(oscars.size(), 0); */
	}	


}