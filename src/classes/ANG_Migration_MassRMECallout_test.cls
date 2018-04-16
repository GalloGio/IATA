@isTest
private class ANG_Migration_MassRMECallout_test {
    @testSetup static void createData() {
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c(Name = 'USA', ISO_Code__c = 'US', CurrencyIsoCode = 'USD');
		insert ctry;

		Account a = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = AMS_utils.RECTYPE_IATAAGENCY, IATACode__c='1234562',Location_Type__c= AMS_Utils.BR, Name='Test2 Agency OK',Short_Name__c='Test1 Agency', Sector__c = AMS_Utils.CATEGORY_TRAVEL_AGENT, Location_Class__c = AMS_Utils.LC_PASSENGER);
		insert a;

		ANG_RHCHelper.createRHCInfo(new Set<Id>{a.Id}, false);
		
		ANG_RHC_Information__c rhcInfo = [select id, ANG_FINANCIAL_SECURITY__C, CurrencyIsoCode from ANG_RHC_Information__c where ANG_AccountId__c =:a.Id];
		rhcInfo.ANG_FINANCIAL_SECURITY__C = 1000;
		rhcInfo.CurrencyIsoCode = 'USD';
		update rhcInfo;
		
		List<ANG_CalloutMapping__c> customsettings = new List<ANG_CalloutMapping__c>();
		customsettings.add(new ANG_CalloutMapping__c(Name = 'BTN_Prov', CalloutClass__c = 'ANG_RME_Alert_Service', Action__c = 'GET', Event_Type__C = 'WebService', Credential__c = '/calculatedrhc/{agencyId}/v1', Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'Button'));
		customsettings.add(new ANG_CalloutMapping__c(Name = 'BTN_Bal',  CalloutClass__c = 'ANG_RME_Alert_Service', Action__c = 'GET', Event_Type__C = 'WebService', Credential__c = '/consumedrhc/{agencyId}/v1/',  Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'Button'));
		insert customsettings;
	}
	
	static testMethod void test_Page_Method(){
		PageReference pageRef = Page.ANG_Migration_MassRMECallout;
		Test.setCurrentPage(pageRef);
		
		ANG_Migration_MassRMECallout ctrl = new ANG_Migration_MassRMECallout();
		
		list<selectOption> lsCntr = ctrl.lsCountry;
		list<selectOption> lsTypeOfCall = ctrl.lsTypeOfCall;
		ANG_Migration_MassRMECallout.WebserviceResult result = ANG_Migration_MassRMECallout.SendRequestToRME(null, null);
		
		PageReference p = ctrl.NewSearch();
		p = ctrl.doNothing();
		ctrl.SearchPerformed();
	}
	
	
	static testMethod void test_ConsumedRHC_OK(){
		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_RME_Amount__c, ANG_RHC_Amount_Provisional__c, ANG_Provisional_RHC_Last_Update__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account limit 1];
		PageReference pageRef = Page.ANG_Migration_MassRMECallout;
		Test.setCurrentPage(pageRef);
		
		ANG_Migration_MassRMECallout ctrl = new ANG_Migration_MassRMECallout();
		
		ANG_Migration_MassRMECallout.RHCMessage message = new ANG_Migration_MassRMECallout.RHCMessage();
		message.iataCode = '1234562';
		message.eventTime = System.now();
		message.consumedRHCAmount = 200;
		message.consumedRHCPercentage = 0.12345;
		message.storedBaseCurrency = acc.RHC_Informations__r[0].CurrencyIsoCode;
		message.storedRHCValue = acc.RHC_Informations__r[0].ANG_RHC_Amount__c;
		
		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		Test.startTest();	
			ANG_Migration_MassRMECallout.RMEResponseWrapper RMEWR = mapMessage('ConsumedRHC', ANG_Migration_MassRMECallout.SendRequestToRME(acc.Id, 'ConsumedRHC'), message, acc);
			ctrl.theSerializedResultFromRME = json.Serialize(new list<ANG_Migration_MassRMECallout.RMEResponseWrapper>{RMEWR});
			PageReference p = ctrl.AfterCallout();
		Test.stopTest();

	}
	
	static testMethod void test_ConsumedRHC_KO_IATACode(){
		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_RME_Amount__c, ANG_RHC_Amount_Provisional__c, ANG_Provisional_RHC_Last_Update__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account limit 1];
		PageReference pageRef = Page.ANG_Migration_MassRMECallout;
		Test.setCurrentPage(pageRef);
		
		ANG_Migration_MassRMECallout ctrl = new ANG_Migration_MassRMECallout();
		
		ANG_Migration_MassRMECallout.RHCMessage message = new ANG_Migration_MassRMECallout.RHCMessage();
		message.iataCode = '11111111';
		message.eventTime = System.now();
		message.consumedRHCAmount = 200;
		message.consumedRHCPercentage = 0.12345;
		message.storedBaseCurrency = acc.RHC_Informations__r[0].CurrencyIsoCode;
		message.storedRHCValue = acc.RHC_Informations__r[0].ANG_RHC_Amount__c;
		
		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		Test.startTest();	
			ANG_Migration_MassRMECallout.RMEResponseWrapper RMEWR = mapMessage('ConsumedRHC', ANG_Migration_MassRMECallout.SendRequestToRME(acc.Id, 'ConsumedRHC'), message, acc);
			ctrl.theSerializedResultFromRME = json.Serialize(new list<ANG_Migration_MassRMECallout.RMEResponseWrapper>{RMEWR});
			PageReference p = ctrl.AfterCallout();
		Test.stopTest();

	}
	
	static testMethod void test_ConsumedRHC_KO_DiffCurrency(){
		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_RME_Amount__c, ANG_RHC_Amount_Provisional__c, ANG_Provisional_RHC_Last_Update__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account limit 1];
		PageReference pageRef = Page.ANG_Migration_MassRMECallout;
		Test.setCurrentPage(pageRef);
		
		ANG_Migration_MassRMECallout ctrl = new ANG_Migration_MassRMECallout();
		
		ANG_Migration_MassRMECallout.RHCMessage message = new ANG_Migration_MassRMECallout.RHCMessage();
		message.iataCode = '1234562';
		message.eventTime = System.now();
		message.consumedRHCAmount = 200;
		message.consumedRHCPercentage = 0.12345;
		message.storedBaseCurrency = 'NOK';
		message.storedRHCValue = acc.RHC_Informations__r[0].ANG_RHC_Amount__c;
		
		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		Test.startTest();	
			ANG_Migration_MassRMECallout.RMEResponseWrapper RMEWR = mapMessage('ConsumedRHC', ANG_Migration_MassRMECallout.SendRequestToRME(acc.Id, 'ConsumedRHC'), message, acc);
			ctrl.theSerializedResultFromRME = json.Serialize(new list<ANG_Migration_MassRMECallout.RMEResponseWrapper>{RMEWR});
			PageReference p = ctrl.AfterCallout();
		Test.stopTest();

	}
	
	static testMethod void test_ConsumedRHC_KO_DiffRHCAmount(){
		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_RME_Amount__c, ANG_RHC_Amount_Provisional__c, ANG_Provisional_RHC_Last_Update__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account limit 1];
		PageReference pageRef = Page.ANG_Migration_MassRMECallout;
		Test.setCurrentPage(pageRef);
		
		ANG_Migration_MassRMECallout ctrl = new ANG_Migration_MassRMECallout();
		
		ANG_Migration_MassRMECallout.RHCMessage message = new ANG_Migration_MassRMECallout.RHCMessage();
		message.iataCode = '1234562';
		message.eventTime = System.now();
		message.consumedRHCAmount = 200;
		message.consumedRHCPercentage = 0.12345;
		message.storedBaseCurrency = acc.RHC_Informations__r[0].CurrencyIsoCode;
		message.storedRHCValue = -1000;
		
		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		Test.startTest();	
			ANG_Migration_MassRMECallout.RMEResponseWrapper RMEWR = mapMessage('ConsumedRHC', ANG_Migration_MassRMECallout.SendRequestToRME(acc.Id, 'ConsumedRHC'), message, acc);
			ctrl.theSerializedResultFromRME = json.Serialize(new list<ANG_Migration_MassRMECallout.RMEResponseWrapper>{RMEWR});
			PageReference p = ctrl.AfterCallout();
		Test.stopTest();

	}
	
	static testMethod void test_ProvisionalRHC_OK(){
		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_RME_Amount__c, ANG_RHC_Amount_Provisional__c, ANG_Provisional_RHC_Last_Update__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account limit 1];
		PageReference pageRef = Page.ANG_Migration_MassRMECallout;
		Test.setCurrentPage(pageRef);
		
		ANG_Migration_MassRMECallout ctrl = new ANG_Migration_MassRMECallout();
		
		ANG_Migration_MassRMECallout.RHCMessage message = new ANG_Migration_MassRMECallout.RHCMessage();
		message.iataCode = '1234562';
		message.eventTime = System.now();
		message.provisionalRHC = 200;
		message.storedBaseCurrency = acc.RHC_Informations__r[0].CurrencyIsoCode;
		message.storedRHCValue = acc.RHC_Informations__r[0].ANG_RHC_Amount__c;
		
		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		Test.startTest();
			ANG_Migration_MassRMECallout.RMEResponseWrapper RMEWR = mapMessage('ProvisionalRHC', ANG_Migration_MassRMECallout.SendRequestToRME(acc.Id, 'ProvisionalRHC'), message, acc);
			ctrl.theSerializedResultFromRME = json.Serialize(new list<ANG_Migration_MassRMECallout.RMEResponseWrapper>{RMEWR});
			PageReference p = ctrl.AfterCallout();
		Test.stopTest();
	}
	
	static testMethod void test_ProvisionalRHC_KO_DiffCurrency() {
		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_RME_Amount__c, ANG_RHC_Amount_Provisional__c, ANG_Provisional_RHC_Last_Update__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account limit 1];
		PageReference pageRef = Page.ANG_Migration_MassRMECallout;
		Test.setCurrentPage(pageRef);
		
		ANG_Migration_MassRMECallout ctrl = new ANG_Migration_MassRMECallout();
		
		ANG_Migration_MassRMECallout.RHCMessage message = new ANG_Migration_MassRMECallout.RHCMessage();
		message.iataCode = '1234562';
		message.eventTime = System.now();
		message.provisionalRHC = 200;
		message.storedBaseCurrency = 'NOK';
		message.storedRHCValue = acc.RHC_Informations__r[0].ANG_RHC_Amount__c;
		
		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		Test.startTest();
			ANG_Migration_MassRMECallout.RMEResponseWrapper RMEWR = mapMessage('ProvisionalRHC', ANG_Migration_MassRMECallout.SendRequestToRME(acc.Id, 'ProvisionalRHC'), message, acc);
			ctrl.theSerializedResultFromRME = json.Serialize(new list<ANG_Migration_MassRMECallout.RMEResponseWrapper>{RMEWR});
			PageReference p = ctrl.AfterCallout();
		Test.stopTest();
	}
	
	static testMethod void test_ProvisionalRHC_KO_IATACode(){
		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_RME_Amount__c, ANG_RHC_Amount_Provisional__c, ANG_Provisional_RHC_Last_Update__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account limit 1];
		PageReference pageRef = Page.ANG_Migration_MassRMECallout;
		Test.setCurrentPage(pageRef);
		
		ANG_Migration_MassRMECallout ctrl = new ANG_Migration_MassRMECallout();
		
		ANG_Migration_MassRMECallout.RHCMessage message = new ANG_Migration_MassRMECallout.RHCMessage();
		message.iataCode = '1111111';
		message.eventTime = System.now();
		message.provisionalRHC = 200;
		message.storedBaseCurrency = acc.RHC_Informations__r[0].CurrencyIsoCode;
		message.storedRHCValue = acc.RHC_Informations__r[0].ANG_RHC_Amount__c;
		
		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		Test.startTest();
			ANG_Migration_MassRMECallout.RMEResponseWrapper RMEWR = mapMessage('ProvisionalRHC', ANG_Migration_MassRMECallout.SendRequestToRME(acc.Id, 'ProvisionalRHC'), message, acc);
			ctrl.theSerializedResultFromRME = json.Serialize(new list<ANG_Migration_MassRMECallout.RMEResponseWrapper>{RMEWR});
			PageReference p = ctrl.AfterCallout();
		Test.stopTest();
	}
	
	static testMethod void test_ProvisionalRHC_KO_DiffAmount(){
		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_RME_Amount__c, ANG_RHC_Amount_Provisional__c, ANG_Provisional_RHC_Last_Update__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account limit 1];
		PageReference pageRef = Page.ANG_Migration_MassRMECallout;
		Test.setCurrentPage(pageRef);
		
		ANG_Migration_MassRMECallout ctrl = new ANG_Migration_MassRMECallout();
		
		ANG_Migration_MassRMECallout.RHCMessage message = new ANG_Migration_MassRMECallout.RHCMessage();
		message.iataCode = '1234562';
		message.eventTime = System.now();
		message.provisionalRHC = 200;
		message.storedBaseCurrency = acc.RHC_Informations__r[0].CurrencyIsoCode;
		message.storedRHCValue = -1000;
		
		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		Test.startTest();
			ANG_Migration_MassRMECallout.RMEResponseWrapper RMEWR = mapMessage('ProvisionalRHC', ANG_Migration_MassRMECallout.SendRequestToRME(acc.Id, 'ProvisionalRHC'), message, acc);
			ctrl.theSerializedResultFromRME = json.Serialize(new list<ANG_Migration_MassRMECallout.RMEResponseWrapper>{RMEWR});
			PageReference p = ctrl.AfterCallout();
		Test.stopTest();
	}
	
	static testMethod void test_ProvisionalRHC_OK_CashCondition(){
		Account acc = [SELECT Id, IATACode__c, (SELECT Id, ANG_CashCondition__c, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_RME_Amount__c, ANG_RHC_Amount_Provisional__c, ANG_Provisional_RHC_Last_Update__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account limit 1];
		PageReference pageRef = Page.ANG_Migration_MassRMECallout;
		Test.setCurrentPage(pageRef);
		
		ANG_Migration_MassRMECallout ctrl = new ANG_Migration_MassRMECallout();
		ANG_RHC_Information__c rhcInfo = acc.RHC_Informations__r[0];
		rhcInfo.ANG_CashCondition__c = true;
		update rhcInfo;
		
		ANG_Migration_MassRMECallout.RHCMessage message = new ANG_Migration_MassRMECallout.RHCMessage();
		message.iataCode = '1234562';
		message.eventTime = System.now();
		message.provisionalRHC = 200;
		message.storedBaseCurrency = acc.RHC_Informations__r[0].CurrencyIsoCode;
		message.storedRHCValue = acc.RHC_Informations__r[0].ANG_RHC_Amount__c;
		
		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		Test.startTest();
			ANG_Migration_MassRMECallout.RMEResponseWrapper RMEWR = mapMessage('ProvisionalRHC', ANG_Migration_MassRMECallout.SendRequestToRME(acc.Id, 'ProvisionalRHC'), message, acc);
			ctrl.theSerializedResultFromRME = json.Serialize(new list<ANG_Migration_MassRMECallout.RMEResponseWrapper>{RMEWR});
			PageReference p = ctrl.AfterCallout();
		Test.stopTest();
	}
	
	static testMethod void test_ProvisionalRHC_OK2(){
		Account acc = [SELECT Id, IATACode__c, (SELECT Id, ANG_CashCondition__c, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_RME_Amount__c, ANG_RHC_Amount_Provisional__c, ANG_Provisional_RHC_Last_Update__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account limit 1];
		PageReference pageRef = Page.ANG_Migration_MassRMECallout;
		Test.setCurrentPage(pageRef);
		
		ANG_Migration_MassRMECallout ctrl = new ANG_Migration_MassRMECallout();
		
		ANG_Migration_MassRMECallout.RHCMessage message = new ANG_Migration_MassRMECallout.RHCMessage();
		message.iataCode = '1234562';
		message.eventTime = System.now();
		message.provisionalRHC = 20000;
		message.storedBaseCurrency = acc.RHC_Informations__r[0].CurrencyIsoCode;
		message.storedRHCValue = acc.RHC_Informations__r[0].ANG_RHC_Amount__c;
		
		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		Test.startTest();
			ANG_Migration_MassRMECallout.RMEResponseWrapper RMEWR = mapMessage('ProvisionalRHC', ANG_Migration_MassRMECallout.SendRequestToRME(acc.Id, 'ProvisionalRHC'), message, acc);
			ctrl.theSerializedResultFromRME = json.Serialize(new list<ANG_Migration_MassRMECallout.RMEResponseWrapper>{RMEWR});
			PageReference p = ctrl.AfterCallout();
		Test.stopTest();
	}
	
	static testMethod void test_RME_KO(){
		Account acc = [SELECT Id, IATACode__c, (SELECT Id, ANG_CashCondition__c, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_RME_Amount__c, ANG_RHC_Amount_Provisional__c, ANG_Provisional_RHC_Last_Update__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account limit 1];
		PageReference pageRef = Page.ANG_Migration_MassRMECallout;
		Test.setCurrentPage(pageRef);
		
		ANG_Migration_MassRMECallout ctrl = new ANG_Migration_MassRMECallout();

		ANG_Migration_MassRMECallout.RHCMessage message = new ANG_Migration_MassRMECallout.RHCMessage();
		message.iataCode = '1234562';
		message.eventTime = System.now();
		message.provisionalRHC = 200;
		message.storedBaseCurrency = acc.RHC_Informations__r[0].CurrencyIsoCode;
		message.storedRHCValue = acc.RHC_Informations__r[0].ANG_RHC_Amount__c;
		
		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(404, JSON.serialize(message)));

		Test.startTest();
			ANG_Migration_MassRMECallout.RMEResponseWrapper RMEWR = mapMessage('ProvisionalRHC', ANG_Migration_MassRMECallout.SendRequestToRME(acc.Id, 'ProvisionalRHC'), message, acc);
			ctrl.theSerializedResultFromRME = json.Serialize(new list<ANG_Migration_MassRMECallout.RMEResponseWrapper>{RMEWR});
			PageReference p = ctrl.AfterCallout();
		Test.stopTest();
	}
	
	private static ANG_Migration_MassRMECallout.RMEResponseWrapper mapMessage(string sType, ANG_Migration_MassRMECallout.WebserviceResult result, ANG_Migration_MassRMECallout.RHCMessage message, account acc){
		ANG_Migration_MassRMECallout.RMEResponseWrapper RMEWR = new ANG_Migration_MassRMECallout.RMEResponseWrapper();
		RMEWR.isSuccess = result.isSuccess;
		RMEWR.description = result.description;
		RMEWR.iatacode = message.iataCode;
		RMEWR.RHCId = acc.RHC_Informations__r[0].Id;
		RMEWR.AccntId = acc.Id;
		RMEWR.sLastUpd = string.valueof(message.eventTime);
		RMEWR.sType = sType;
		if(sType=='ProvisionalRHC'){
			RMEWR.sCurrency = message.storedBaseCurrency;
			RMEWR.ProvAmnt = message.provisionalRHC;
		}else{
			RMEWR.ConsumedRHC = message.consumedRHCAmount;
			RMEWR.ConsumedRHCPerc = message.consumedRHCPercentage*100;
		}
		return RMEWR;
	}
}