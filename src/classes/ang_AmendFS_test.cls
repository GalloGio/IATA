@istest
private class ang_AmendFS_test {
	 @testSetup static void testSetup(){
	 	  // Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', ANG_Enable_NewGen__c = true);
        insert country;
        
        // Create an Airline HQ account
        Account a = new Account(
        	name='acc1',
			Location_Type__c='HE',
			Location_Class__c='P',
			Remittance_frequency__c='M',
			ANG_Accreditation_Model__c ='Cash',
			IATA_ISO_Country__c = country.Id,
        	RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency')
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
        		Subject = 'first case', 
        		AccountId = a.Id, 
        		Status = 'Open', 
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE'),
                Financial_Security_Amount__c=10000,
                Financial_Security_Currency__c='EUR'
        );
        insert c;
                
       
       ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
        	ANG_AccountId__c =a.id,
        	CurrencyIsoCode ='EUR',
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


        attachment att = new attachment(
        		name='attac1',
        		body= Blob.valueOf('empty body'),
        		ParentId=fs.id
        );
        insert att;

	 }


	 TestMethod static void testAmendFS(){

	 	//new minimum fs on rhc == inserted financial security
	 	system.assertEquals([select ANG_Minimum_Financial_Security__c from ANG_RHC_Information__c limit 1].get(0).ANG_Minimum_Financial_Security__c,[select id,ANG_Minimum_Financial_Security__c from Financial_Security__c limit 1].get(0).ANG_Minimum_Financial_Security__c);
	 	ANG_AmendFS plugin = new ANG_AmendFS();
		
		Test.startTest();

	 	Case c = new Case(
        		Subject = 'second case', 
        		AccountId = [select id from account limit 1].get(0).id,
        		Status = 'Open', 
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE'),
                Financial_Security_Amount__c=20000,
                Financial_Security_Currency__c='EUR'
        );
        insert c;

	 	Map<String, Object> inputParams = new Map<String, Object>();
       
        inputParams.put('NewFSAmount',1000);
    	inputParams.put('SelectedCaseId',c.id);
    	inputParams.put('SelectedCurrency','EUR');
      	inputParams.put('FSToCloneId',[select id from Financial_Security__c limit 1].get(0).id);
        inputParams.put('ExpiryDate',system.today());
    	inputParams.put('UnlimitedValidity',false);

    	Process.PluginRequest request = new Process.PluginRequest(inputParams);
    	Process.PluginResult result = plugin.invoke(request);
    	Process.PluginDescribeResult describeresult= plugin.describe();
		
		Test.stopTest();
		
    	string newFSId= String.valueOF(result.outputParameters.get('CreatedFSId'));
    	
    	//new minimum fs on rhc from selected case
    	system.assertEquals([select ANG_Minimum_Financial_Security__c from ANG_RHC_Information__c limit 1].get(0).ANG_Minimum_Financial_Security__c,[select id,ANG_Minimum_Financial_Security__c from Financial_Security__c where id=:newFSId].get(0).ANG_Minimum_Financial_Security__c);
    	
    	//amended fs status set to inactive addendum	
		system.assertEquals([select Security_status__c from Financial_Security__c where id!=:newFSId].get(0).Security_status__c,'Inactive_Addendum');
	 
	 }


	TestMethod static void testAmendFS_BankGuarantee(){

		//new minimum fs on rhc == inserted financial security
		system.assertEquals([select ANG_Minimum_Financial_Security__c from ANG_RHC_Information__c limit 1].get(0).ANG_Minimum_Financial_Security__c,[select id,ANG_Minimum_Financial_Security__c from Financial_Security__c limit 1].get(0).ANG_Minimum_Financial_Security__c);
		ANG_AmendFS plugin = new ANG_AmendFS();

		
		Financial_Security__c fs = [SELECT Id, Security_Type__c FROM Financial_Security__c LIMIT 1];
		fs.Security_Type__c = 'Bank Guarantee';
		update fs;

		Case c = new Case(
			Subject = 'second case', 
			AccountId = [select id from account limit 1].get(0).id,
			Status = 'Open', 
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE'),
			Financial_Security_Amount__c=20000,
			Financial_Security_Currency__c='EUR'
		);
		insert c;
		c = [SELECT Id, CaseNumber FROM Case WHERE Id = :c.Id];

		Test.startTest();

		Map<String, Object> inputParams = new Map<String, Object>();
		inputParams.put('NewFSAmount',1000);
		inputParams.put('SelectedCaseId',c.id);
		inputParams.put('SelectedCurrency','EUR');
		inputParams.put('FSToCloneId',fs.Id);
		inputParams.put('ExpiryDate',system.today());
		inputParams.put('UnlimitedValidity',false);
		inputParams.put('FSValidationCase',c.CaseNumber);

		Process.PluginRequest request = new Process.PluginRequest(inputParams);
		Process.PluginResult result = plugin.invoke(request);
		Process.PluginDescribeResult describeresult= plugin.describe();

		Test.stopTest();

		system.assertEquals('OK',result.outputParameters.get('Result'));

		string newFSId= String.valueOF(result.outputParameters.get('CreatedFSId'));
		Financial_Security__c fsResult = [select id,ANG_Minimum_Financial_Security__c, Security_status__c, Financial_Security_Validation_Case__c, Financial_Security_Validation_Case__r.CaseNumber from Financial_Security__c where id=:newFSId];
		ANG_RHC_Information__c rhcInfoResult = [select ANG_Minimum_Financial_Security__c from ANG_RHC_Information__c limit 1];

		//new minimum fs on rhc from selected case
		system.assertEquals(rhcInfoResult.ANG_Minimum_Financial_Security__c,fsResult.ANG_Minimum_Financial_Security__c);

		//amended fs status with a Security Validation Case
		system.assertEquals(fsResult.Financial_Security_Validation_Case__r.CaseNumber,c.CaseNumber);
	}


}
