/****************************************************************************************************
    Created by CGI, Thai 2017-01-23
        Cover code of trigger "Accounts", classes "Account_Dom", "Account_Sel" "Account_Svc"
****************************************************************************************************/
@isTest(seeAllData=false)
private class Account_Svc_Test {


static testMethod void test_AllMethod()
{
	List<Apex_Setting__c> lstSetting = new List<Apex_Setting__c>();
	lstSetting.add(new Apex_Setting__c(Name='Account fields to sync to SAP1', Text_1__c='Name,Phone,Email__c'));
	lstSetting.add(new Apex_Setting__c(Name='Execute Trigger Account', Number_1__c=1));
	insert lstSetting;

	//Generate SAP Settings
	TestDataGenerator.generateSAPSettings();
	
	Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];
	IECAddress__c oAddress = TestDataGenerator.generateAddresses(1, true)[0];
	Location__c oLocation = TestDataGenerator.generateLocations('Sold To', oAddress.Id, oAccount.Id, null, 'sold1');
	
	//*** cover Account_Svc.syncAccountUpdateWithExternalSystems -> no assert since just for call out
	oAccount.Name = oAccount.Name + 'zzz';
	update oAccount;
	
	//*** cover methods in Account_Sel -> no assert since no logic
	Account_Sel cls = new Account_Sel();
	oAccount = cls.getAccountById(oAccount.Id);
	Map<Id, Account> mapId_Account = cls.getAccountById(new Set<Id>{oAccount.Id});
	mapId_Account = cls.getAccountById(mapId_Account.keySet());
} //*** end of "test_AllMethod"


} //*** end of class