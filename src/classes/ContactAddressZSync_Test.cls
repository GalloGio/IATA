/****************************************************************************************************
    Created by CGI, Thai 2017-01-23
        Cover code of classes "ContactAddressZSync", "ContactAddressZSync_Batch" and "ContactAddressZSync_Queueable"
****************************************************************************************************/
@isTest(seeAllData=true)
private class ContactAddressZSync_Test {


static testMethod void test_AllMethod()
{
	User oUser = IECTestUtil.createSampleGuestUserAndLogin();
	Contact oContact = new Contact_Sel().getContactById(oUser.contactId);
	List<IECAddress__c> lstAddress = TestDataGenerator.generateAddresses(3, true);
	List<Location__c> lstLocation = new List<Location__c>();
	lstLocation.add(new Location__c(Type__c='Sold To', Address__c=lstAddress[0].Id, Account__c=oContact.AccountId, SAP_Id__c='sold1'));
	lstLocation.add(new Location__c(Type__c='Bill To', Address__c=lstAddress[0].Id, Account__c=oContact.AccountId, Contact__c=oContact.Id, SAP_Id__c='bill1'));
	lstLocation.add(new Location__c(Type__c='Ship To', Address__c=lstAddress[0].Id, Account__c=oContact.AccountId, Contact__c=oContact.Id, SAP_Id__c='ship1'));
	lstLocation.add(new Location__c(Type__c='Ship To', Address__c=lstAddress[1].Id, Account__c=oContact.AccountId, Contact__c=oContact.Id, SAP_Id__c='ship2'));
	lstLocation.add(new Location__c(Type__c='Ship To', Address__c=lstAddress[2].Id, Account__c=oContact.AccountId, Contact__c=oContact.Id, SAP_Id__c='ship3'));
	insert lstLocation;

	//*** cover "ContactAddressZSync" via "ContactAddressZSync_Batch" and "ContactAddressZSync_Queueable" -> no assert since just for call out
	Location_Sel cls = new Location_Sel();
	Set<Id> setSourceId = new Set<Id>();
	for (Integer i1 = 1; i1 < lstLocation.size(); i1++)
		setSourceId.add(lstLocation[i1].Id);
	List<Location__c> lstTestLocation = cls.getLocations(setSourceId);
	Test.startTest();
		Database.ExecuteBatch(new ContactAddressZSync_Batch(setSourceId, 'Location'));
		system.enqueueJob(new ContactAddressZSync_Queueable(lstTestLocation, setSourceId, 'Location'));
	Test.stopTest();

	//*** cover methods in CustomerAccount_Sel -> no assert since no logic
	Map<Id, Zuora__CustomerAccount__c> mapId_ZuoraAccount = CustomerAccount_Sel.getZuoraCustmerAccount(new Set<Id>{oContact.Id});
} //*** end of "test_AllMethod"


} //*** end of class