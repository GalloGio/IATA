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
			Remittance_frequency__c='Monthly',
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
	     
        

        ANG_RHC_Information__c rhcInfo= [select id, CurrencyIsoCode from ANG_RHC_Information__c limit 1];

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
            Remittance_frequency__c='Monthly',
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


}