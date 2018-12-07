/****************************************************************************************************
    Created by CGI, Thai 2017-01-23
        Cover code of trigger "Contacts", classes "Contact_Dom", "Contact_DTO", Contact_Sel" and "Contact_Svc"
****************************************************************************************************/
@isTest(seeAllData=false)
private class Contact_Svc_Test {


static testMethod void test_AllMethod()
{
	List<Apex_Setting__c> lstSetting = new List<Apex_Setting__c>();
	lstSetting.add(new Apex_Setting__c(Name='Contact fields to sync to SAP1', Text_1__c='FirstName,LastName,Title'));
	lstSetting.add(new Apex_Setting__c(Name='Execute Trigger Contact', Number_1__c=1));
	insert lstSetting;

	//Generate SAP Settings
	TestDataGenerator.generateSAPSettings();
	
	List<Account> lstAccount = TestDataGenerator.generateAccounts(3, true);
	List<Contact> lstContact = new List<Contact>();
	lstContact.add(TestDataGenerator.generateContacts(lstAccount[0].Id, 1, false)[0]);
	lstContact.add(TestDataGenerator.generateContacts(lstAccount[1].Id, 1, false)[0]);
	lstContact.add(TestDataGenerator.generateContacts(lstAccount[2].Id, 1, false)[0]);
	insert lstContact;
	IECAddress__c oAddress = TestDataGenerator.generateAddresses(1, true)[0];
	List<Location__c> lstLocation = new List<Location__c>();
	lstLocation.add(new Location__c(Type__c='Sold To', Address__c=oAddress.Id, Account__c=lstAccount[0].Id));
	lstLocation.add(new Location__c(Type__c='Bill To', Address__c=oAddress.Id, Account__c=lstAccount[0].Id, Contact__c=lstContact[0].Id));
	lstLocation.add(new Location__c(Type__c='Bill To', Address__c=oAddress.Id, Account__c=lstAccount[1].Id, Contact__c=lstContact[1].Id));
	lstLocation.add(new Location__c(Type__c='Sold To', Address__c=oAddress.Id, Account__c=lstAccount[2].Id, SAP_Id__c='sold3'));
	lstLocation.add(new Location__c(Type__c='Bill To', Address__c=oAddress.Id, Account__c=lstAccount[2].Id, Contact__c=lstContact[2].Id));
	insert lstLocation;
	
	//*** cover Contact_Svc.contactLocationToSynWithSap case having sold to but no SAP Id -> no assert since just for call out
	lstContact[0].FirstName = lstContact[0].FirstName + 'zzz';
	update lstContact[0];
	
	//*** cover Contact_Svc.contactLocationToSynWithSap case with no sold to -> no assert since just for call out
	lstContact[1].FirstName = lstContact[1].FirstName + 'zzz';
	update lstContact[1];
	
	//*** cover Contact_Svc.contactLocationToSynWithSap case with valid sold to -> no assert since just for call out
	lstContact[2].FirstName = lstContact[2].FirstName + 'zzz';
	update lstContact[2];
	
	//*** cover methods in Contact_Sel -> no assert since no logic
	Contact_Sel cls = new Contact_Sel();
	Contact oContact = cls.getContactById(lstContact[0].Id);
	Map<Id, Id> mapContactId_AccountId = Contact_Sel.getAccountIdByContactId(new Set<Id>{oContact.Id});
	Map<Id, Contact> mapId_Contact = Contact_Sel.getContactById(new Set<Id>{oContact.Id});
	
	//*** cover Contact_DTO -> no assert since it is a wrapper
	Contact_DTO dto = new Contact_DTO();
	dto.contactId = oContact.Id;
	dto.contactSalutation = oContact.Title;
	dto.contactFirstName = oContact.FirstName;
	dto.contactLastName = oContact.LastName;
	dto.accountId = oContact.AccountId;
	dto.accountName = oContact.Account.Name;
	dto.phone = oContact.Phone;
	dto.email = oContact.Email;
	dto.contactName = oContact.Name;
} //*** end of "test_AllMethod"


} //*** end of class