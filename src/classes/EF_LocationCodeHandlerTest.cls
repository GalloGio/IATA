@isTest
public with sharing class EF_LocationCodeHandlerTest {
	static void setup()
	{
			EF_TestDataFactory.skipContractCreationValidationRule();
			EF_TestDataFactory.createBaseDataWithoutLocCurr();
			EF_TestDataFactory.createLocationCodes();
	}

	@isTest static void addLocationCodeOnContractAndBa() {
		System.runAs(EF_TestDataFactory.getEfProfileAndRole(1, 2))
		{
			setup();
			Contract contract = [select Id, AccountId, Account.Name from Contract where Account.Name = 'Test Account Client2'];
			Account customer = [select Id, Name from Account where Name = 'Test Account customer2'];
			Account client = [select Id, Name from Account where Name = 'Test Account client2'];
			List<EF_Related_Records__c> rrLocations = [select id, name, Location_Code_Details__c from EF_Related_Records__c where name like 'ABC%'];

			List<EF_Location_Code__c> contractLocationCodes = new List<EF_Location_Code__c>();
			for(EF_Related_Records__c rr : rrLocations)
			{
				contractLocationCodes.add(new EF_Location_Code__c(Location_Code__c = rr.Id, Contract__c = contract.Id));
			}
			insert contractLocationCodes;

			EF_Billing_Agreement__c ba = new EF_Billing_Agreement__c();
			ba.Client__c= client.Id;
			ba.Airline__c = customer.Id;
			ba.Contract__c = contract.Id;
			insert ba;

			List<EF_Location_Code__c> baLocationCodes = new List<EF_Location_Code__c>();
			baLocationCodes = contractLocationCodes.clone();
			for(EF_Location_Code__c baCode : baLocationCodes)
			{
				baCode.EF_Airline_Billing_Agreement__c = ba.Id;
				baCode.Contract__c = null;
				baCode.Id = null;
			}

			try
			{
				insert baLocationCodes;
			} catch(Exception e)
			{
				System.assert(false, 'Should have not thrown an error.');
			}
		}
	}


	@isTest static void addLocationOnBaNotOnContract_expectFailure() {
		System.runAs(EF_TestDataFactory.getEfProfileAndRole(1, 2))
		{
			setup();
			Contract contract = [select Id, AccountId, Account.Name from Contract where Account.Name = 'Test Account Client2'];
			Account customer = [select Id, Name from Account where Name = 'Test Account customer2'];
			Account client = [select Id, Name from Account where Name = 'Test Account client2'];
			List<EF_Related_Records__c> rrLocations = [select id, name, Location_Code_Details__c, RecordTypeId from EF_Related_Records__c where name like 'ABC%'];

			List<EF_Location_Code__c> contractLocationCodes = new List<EF_Location_Code__c>();
			for(EF_Related_Records__c rr : rrLocations)
			{
				contractLocationCodes.add(new EF_Location_Code__c(Location_Code__c = rr.Id, Contract__c = contract.Id));
			}
			insert contractLocationCodes;

			EF_Billing_Agreement__c ba = new EF_Billing_Agreement__c();
			ba.Client__c= client.Id;
			ba.Airline__c = customer.Id;
			ba.Contract__c = contract.Id;
			insert ba;

			// add Location Code that doesn't exist on Contract to the BA and expect failure
			Id locCodeId = rrLocations.get(0).RecordTypeId;
			EF_Related_Records__c rr4 = new EF_Related_Records__c(Name='ABC4', Location_Code_Details__c = 'Details 4', RecordTypeId=locCodeId);
			insert rr4;

			List<EF_Location_Code__c> baLocationCodes = new List<EF_Location_Code__c>();
			baLocationCodes = contractLocationCodes.clone();
			for(EF_Location_Code__c baCode : baLocationCodes)
			{
				baCode.EF_Airline_Billing_Agreement__c = ba.Id;
				baCode.Contract__c = null;
				baCode.Id = null;
			}
			baLocationCodes.add(new EF_Location_Code__c(EF_Airline_Billing_Agreement__c=ba.Id, Location_Code__c=rr4.Id));

			try
			{
				insert baLocationCodes;
				System.assert(false, 'Test should have thrown an error, because the rr4 Location Code record does not exist on relevant Contract');
			} catch(Exception e){}
		}
	  }
}
