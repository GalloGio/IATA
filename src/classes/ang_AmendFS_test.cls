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
        		Subject = 'first case', 
        		AccountId = a.Id, 
        		Status = 'Open', 
                RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('ProcessEuropeSCE'),
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

	 	Case c = new Case(
        		Subject = 'second case', 
        		AccountId = [select id from account limit 1].get(0).id,
        		Status = 'Open', 
                RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('ProcessEuropeSCE'),
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

    	string newFSId= String.valueOF(result.outputParameters.get('CreatedFSId'));
    	
    	//new minimum fs on rhc from selected case
    	system.assertEquals([select ANG_Minimum_Financial_Security__c from ANG_RHC_Information__c limit 1].get(0).ANG_Minimum_Financial_Security__c,[select id,ANG_Minimum_Financial_Security__c from Financial_Security__c where id=:newFSId].get(0).ANG_Minimum_Financial_Security__c);
    	
    	//amended fs status set to inactive addendum	
		system.assertEquals([select Security_status__c from Financial_Security__c where id!=:newFSId].get(0).Security_status__c,'Inactive_Addendum');
	 
	 }






}