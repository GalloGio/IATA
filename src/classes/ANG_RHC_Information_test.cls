@isTest
public class ANG_RHC_Information_test{
	@testSetup static void testSetup(){
		  // Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name = 'France', 
            ISO_Code__c = 'FR',
            AIMS_Area_Name__c='France',
            AIMS_Area_ID__c= '1',
            ANG_Enable_NewGen__c = true
        );
        insert country;
        
        // Create an Airline HQ account
        Account a = new Account(
        	name='acc1',
			Location_Type__c='HE',
			Location_Class__c='P',
            Type = 'IATA Cargo Agent',
            IATA_ISO_Country__c=country.id,
            IATACode__c ='1234567',
			Remittance_frequency__c='M',
            billingCountry = 'fr',
			ANG_Accreditation_Model__c ='Cash',
            category__c = 'IATA Passenger Sales Agent',
            sector__c = 'Travel Agent',
            Company_Type__c='A',            
            RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency')
        );
        insert a;
        
        // Create a new Financial Institution
        Financial_Institution__c fi = new Financial_Institution__c(
        	Name = 'Test', 
        	Region__c = 'Europe', 
        	Country__c = 'Portugal', 
        	Institution_Type__c = 'Bank'
        );
        insert fi;

        Contact con =new contact(
                    lastname = 'hodor' ,
                    firstname = 'hodor',
                    phone = '123',
                    accountid = a.id,
                    Financial_Assessment_Contact__c = true
                );
        insert con;
           

       
   
       Case c = new Case(
                Origin = 'asd',
                IFAP_Area__c = 'asda',
                Financial_Review_Type__c ='bla',
                IFAP_Financial_Year__c =  String.valueOF(date.today().year()),
                Deadline_Date__c = date.today().addDays(40),
                contactid = con.id,
                AccountId = a.id,
                Assessment_Performed_Date__c = date.today(),
                Financial_Security_Currency__c= 'EUR',
                Financial_Security_Amount__c=10000                              
            );
       insert c;
       
       ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
        	ANG_AccountId__c =a.id,
        	CurrencyIsoCode ='USD',
        	RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
        	ANG_Financial_Security__c=0
        );
        insert rhcInfo;


         Financial_Security__c fs = new Financial_Security__c(
        	Region__c = 'Europe', 
        	Security_status__c = 'Active', 
        	Account__c = a.Id, 
        	CurrencyIsoCode = 'EUR', 
        	Security_Type__c='CCG',
        	Amount__c = 100,
            Expiry_date__c = Date.today().addYears(2), 
            Financial_Institution__c = fi.Id,
            Validity_Start_Date__c = Date.today().addDays(-2), 
            Reception_Case__c = c.Id, 
            Reception_Date__c = Date.today(), 
            Reasonforrequest__c = 'New Application'
        );
        insert fs;

        
        AMS_ChangeCodes__c ccPca= new AMS_ChangeCodes__c(
            Name = 'PCA',
            Integration_RecId__c='2',
            Change_Code__c='PCA',
            Reason_Code__c='',
            Reason_Code_Description__c='description',
            Account_status_change__c=''        
        );
        
         AMS_ChangeCodes__c ccPcr= new AMS_ChangeCodes__c(
            Name ='PCR',
            Change_Code__c='PCR',
            Integration_RecId__c='1',
            Reason_Code__c='',
            Reason_Code_Description__c='description',
            Account_status_change__c=''        
        );
        
        insert new list<AMS_ChangeCodes__c>{ccPcr,ccPca};

	}

	TestMethod static void insertNewFSRecordAndUpdatedRHC(){

        // RHC total ammount equals to convertedValue due only record
        ANG_RHC_Information__c rhc1=[select ANG_Financial_Security__c,ANG_Minimum_Financial_Security__c,CurrencyIsoCode from ANG_RHC_Information__c limit 1];
    	Financial_Security__c fs1=[select ANG_ConvertedAmount__c,ANG_Minimum_Financial_Security__c,CurrencyIsoCode from Financial_Security__c limit 1];
        system.assertEquals(rhc1.ANG_Financial_Security__c,fs1.ANG_ConvertedAmount__c);
   		system.assertEquals(rhc1.ANG_Minimum_Financial_Security__c,ANG_Risk_Helper.currencyConverter(fs1.CurrencyIsoCode,fs1.ANG_Minimum_Financial_Security__c,rhc1.CurrencyIsoCode));
        

		account a=[select id from account limit 1];

		Financial_Institution__c fi  =[select id from Financial_Institution__c limit 1];

		Case c = new Case(
                Origin = 'asd',
                IFAP_Area__c = 'asda',
                Financial_Review_Type__c ='bla',
                IFAP_Financial_Year__c =  String.valueOF(date.today().year()),
                Deadline_Date__c = date.today().addDays(40),                
                AccountId = a.id,
                Assessment_Performed_Date__c = date.today(),
                Financial_Security_Currency__c= 'EUR',
                Financial_Security_Amount__c=20000                              
            );
       
        insert c;

         // Create a new Financial Security
        Financial_Security__c fs = new Financial_Security__c(
        	Region__c = 'Americas', 
        	Security_status__c = 'Active', 
        	Account__c = a.Id, 
        	CurrencyIsoCode = 'EUR', 
        	Security_Type__c='CCG',
        	Amount__c = 100,
            Expiry_date__c = Date.today().addYears(2), 
            Financial_Institution__c = fi.Id,
            Validity_Start_Date__c = Date.today().addDays(-2), 
            Reception_Case__c = c.Id, 
            Reception_Date__c = Date.today(), 
            Reasonforrequest__c = 'New Application'
        );
        insert fs;
	     
        

        ANG_RHC_Information__c rhcInfo= [select id, CurrencyIsoCode,ANG_Minimum_Financial_Security__c from ANG_RHC_Information__c limit 1];

        test.StartTest();
            rhcInfo.CurrencyIsoCode=fs.CurrencyIsoCode;
        	update rhcInfo;
        	
        	fs1=[select ANG_ConvertedAmount__c,ANG_Minimum_Financial_Security__c from Financial_Security__c limit 1];
        	Financial_Security__c fs2=[select ANG_ConvertedAmount__c,amount__c,ANG_Minimum_Financial_Security__c from Financial_Security__c where Region__c='Americas' limit 1];
            ANG_RHC_Information__c rhcRec=[select ANG_Financial_Security__c,ANG_Minimum_Financial_Security__c from ANG_RHC_Information__c limit 1];
        	system.assertEquals(fs2.amount__C,fs2.ANG_ConvertedAmount__c);
            system.assertEquals(rhcRec.ANG_Financial_Security__c,fs1.ANG_ConvertedAmount__c+fs2.ANG_ConvertedAmount__c);
        	system.assertEquals(rhcRec.ANG_Minimum_Financial_Security__c,fs2.ANG_Minimum_Financial_Security__c);
        
        test.StopTest();
	}
	TestMethod static void updateFinancialSecurityRecordToInactive(){
        test.StartTest();
    		Financial_Security__c f1 =[select id,ANG_ConvertedAmount__c,security_Status__C from Financial_Security__c limit 1];
    		f1.security_Status__C ='Not Active yet';
    		update  f1;

		
		  system.assertEquals([select ANG_Financial_Security__c from ANG_RHC_Information__c limit 1].ANG_Financial_Security__c,0);

		test.StopTest();


	}
    TestMethod static void updateFinancialSecurityChangeCase(){
        account a=[select id from account limit 1];
        Case c = new Case(
            Origin = 'asd',
            IFAP_Area__c = 'asda',
            Financial_Review_Type__c ='bla',
            IFAP_Financial_Year__c =  String.valueOF(date.today().year()),
            Deadline_Date__c = date.today().addDays(40),                
            AccountId = a.id,
            Assessment_Performed_Date__c = date.today(),
            Financial_Security_Currency__c= 'USD',
            Financial_Security_Amount__c=40000                              
        );

        insert c;
        test.StartTest();
            Financial_Security__c f1 =[select id,ANG_ConvertedAmount__c,security_Status__C from Financial_Security__c limit 1];
            f1.Reception_Case__c = c.Id;
            update  f1;

            f1 =[select id,ANG_ConvertedAmount__c,security_Status__C,ANG_Minimum_Financial_Security__c from Financial_Security__c limit 1];
            ANG_RHC_Information__c rhcRec=[select ANG_Financial_Security__c,ANG_Minimum_Financial_Security__c from ANG_RHC_Information__c limit 1];
            system.assertEquals(f1.ANG_Minimum_Financial_Security__c,rhcRec.ANG_Minimum_Financial_Security__c);

        test.StopTest();


    }
    TestMethod static void createFinancialSecurityNotCreatingAnRHCInfoRecord(){
         Account a = new Account(
            name='acc1',
            Location_Type__c='HO',
            Location_Class__c='P',
            Type = 'IATA Cargo Agent',
            IATA_ISO_Country__c=[select id from IATA_ISO_Country__c limit 1].get(0).id,
            IATACode__c ='1234567',
            Remittance_frequency__c='M',
            billingCountry = 'fr',
            ANG_Accreditation_Model__c ='Cash',
            category__c = 'IATA Passenger Sales Agent',
            sector__c = 'Travel Agent',
            Company_Type__c='A',
            RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency')         
        );
        insert a;

        Case c = new Case(
            Origin = 'asd',
            IFAP_Area__c = 'asda',
            Financial_Review_Type__c ='bla',
            IFAP_Financial_Year__c =  String.valueOF(date.today().year()),
            Deadline_Date__c = date.today().addDays(40),                
            AccountId = a.id,
            Assessment_Performed_Date__c = date.today(),
            Financial_Security_Currency__c= 'USD',
            Financial_Security_Amount__c=40000                              
        );

        insert c;
        
           
        Financial_Security__c fs = new Financial_Security__c(
            Region__c = 'Americas', 
            Security_status__c = 'Active', 
            Account__c = a.Id, 
            CurrencyIsoCode = 'EUR', 
            Security_Type__c='CCG',
            Amount__c = 100,
            Expiry_date__c = Date.today().addYears(2), 
            Financial_Institution__c = [select id from Financial_Institution__c limit 1 ].get(0).id,
            Validity_Start_Date__c = Date.today().addDays(-2), 
            Reception_Case__c = c.Id, 
            Reception_Date__c = Date.today(), 
            Reasonforrequest__c = 'New Application'
        );
        insert fs;

        test.StartTest();
            system.assertEquals(0,[select count() from ANG_RHC_Information__c where ANG_AccountId__c=: a.id]);

        test.StopTest();
    }

    @isTest static void testRHCInfoIncrement() {

        Account a = [Select Id from Account LIMIT 1];

        IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c];

        Id accountRT = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency');

        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgencyAE');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','AE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Sector__C','Travel Agent');
        fieldsOfObject.put('Category__C','IATA Passenger Sales Agent');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('ParentId',a.Id);

        Account ae = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);
        insert ae;

        AMS_Agencies_Hierarchy__c H1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');
        insert H1;
        
        List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = a.Id, Child_Account__c = ae.Id, HO_Flag__c = 'true'));

        insert rels;

        Id formOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');

        List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();

        authorizations.add(new Agency_Authorization__c(Account__c = a.Id, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Active', RecordTypeId = formOfPaymentRT));
        authorizations.add(new Agency_Authorization__c(Account__c = a.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = formOfPaymentRT));
        authorizations.add(new Agency_Authorization__c(Account__c = a.Id, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Active', RecordTypeId = formOfPaymentRT));
        authorizations.add(new Agency_Authorization__c(Account__c = ae.Id, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Active', RecordTypeId = formOfPaymentRT));
        authorizations.add(new Agency_Authorization__c(Account__c = ae.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = formOfPaymentRT));
        authorizations.add(new Agency_Authorization__c(Account__c = ae.Id, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Active', RecordTypeId = formOfPaymentRT));

        insert authorizations;

        Test.startTest();
         
        ANG_RHC_Information__c rhcInfo = [ Select Id from ANG_RHC_Information__c];

        ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
                recordtypeid=ANG_RHCHelper.RECTYPE_RISKALERT_RHC,
                ANG_Account__c=a.Id,
                ANG_RHC_Information__c=rhcInfo.id,
                ANG_Direction__c='UP',
                ANG_Threshold_Level__c='100%'
            );

        insert ara;

        authorizations = [Select Id , Status__c,Account__c,  ANG_FormOfPayment_ID__c from Agency_Authorization__c];

        for(Agency_Authorization__c aa: authorizations){

            if(aa.ANG_FormOfPayment_ID__c == 'CA'){
                System.assertEquals('Non-Active',aa.Status__c);
            }else
                System.assertEquals('Active',aa.Status__c);
        }


         ANG_Risk_Alert__c ara2 = new ANG_Risk_Alert__c(
                recordtypeid=ANG_RHCHelper.RECTYPE_RISKALERT_RHC,
                ANG_Account__c=a.Id,
                ANG_RHC_Information__c=rhcInfo.id,
                ANG_Direction__c='DOWN',
                ANG_Threshold_Level__c='100%'
            );

        insert ara2;
        
        authorizations = [Select Id , Status__c,Account__c,  ANG_FormOfPayment_ID__c from Agency_Authorization__c];

        for(Agency_Authorization__c aa: authorizations){

            if(aa.ANG_FormOfPayment_ID__c == 'CA')
                System.assertEquals('Active',aa.Status__c);
        }
        
        Test.stopTest();

    }
}