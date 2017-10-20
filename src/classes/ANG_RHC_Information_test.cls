@isTest
public class ANG_RHC_Information_test{
	@testSetup static void testSetup(){
		  // Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
        insert country;
        
        // Create an Airline HQ account
        Account a = new Account(
        	name='acc1',
			Location_Type__c='HE',
			Location_Class__c='P',
			Remittance_frequency__c='Monthly',
			ANG_Accreditation_Model__c ='Cash',
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
        
        // create a reception case
        Case c = new Case(
        		Subject = 'rception case', 
        		AccountId = a.Id, 
        		Status = 'Open', 
                RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('InternalCasesEuropeSCE') 
        );
        insert c;
                
       
       ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
        	ANG_AccountId__c =a.id,
        	CurrencyIsoCode ='USD',
        	RecordTypeId = ANG_Risk_Helper.RECTYPE_STDRHCINFO,
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
        
        	Financial_Security__c fs1=[select ANG_ConvertedAmount__c from Financial_Security__c limit 1];
       		system.assertEquals([select ANG_Financial_Security__c from ANG_RHC_Information__c limit 1].ANG_Financial_Security__c,fs1.ANG_ConvertedAmount__c);
        

		account a=[select id from account limit 1];
		case c =[select id from case limit 1];

		Financial_Institution__c fi  =[select id from Financial_Institution__c limit 1];

		

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
        	
        	fs1=[select ANG_ConvertedAmount__c from Financial_Security__c limit 1];
        	Financial_Security__c fs2=[select ANG_ConvertedAmount__c,amount__C from Financial_Security__c where Region__c='Americas' limit 1];

        	system.assertEquals(fs2.amount__C,fs2.ANG_ConvertedAmount__c);
        	system.assertEquals([select ANG_Financial_Security__c from ANG_RHC_Information__c limit 1].ANG_Financial_Security__c,fs1.ANG_ConvertedAmount__c+fs2.ANG_ConvertedAmount__c);
        test.StopTest();
	}
	TestMethod static void updateFinancialSecurityRecordToInactive(){
		Financial_Security__c f1 =[select id,ANG_ConvertedAmount__c from Financial_Security__c limit 1];
		f1.security_Status__C ='Not Active yet';
		update  f1;

		test.StartTest();
		 system.assertEquals([select ANG_Financial_Security__c from ANG_RHC_Information__c limit 1].ANG_Financial_Security__c,0);

		test.StopTest();


	}


}