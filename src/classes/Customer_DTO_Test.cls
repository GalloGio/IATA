/****************************************************************************************************
    Created by CGI, Thai 2017-01-31
        Cover code for class "Customer_DTO"
****************************************************************************************************/
@isTest
private class Customer_DTO_Test
{


    @isTest static void test_AllMethod()
    {
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        Contact oContact = new Contact_Sel().getContactById(usr.contactId);
        List<IECAddress__c> addresses = TestDataGenerator.generateAddresses(1, true);

        Map<String, Location__c> mapLocation = new Map<String, Location__c>();
        mapLocation.put('sold', new Location__c(Active__c = true, Type__c = 'Sold To', SAP_Id__c = 'Sold', Address__c = addresses[0].Id, Account__c = oContact.AccountId));
        mapLocation.put('bill', new Location__c(Active__c = true, Type__c = 'Bill To', SAP_Id__c = 'Bill', Address__c = addresses[0].Id, Account__c = oContact.AccountId, Contact__c = oContact.Id, Email__c = oContact.Email, Phone__c = oContact.Phone));
        mapLocation.put('ship', new Location__c(Active__c = true, Type__c = 'Ship To', SAP_Id__c = 'Ship', Address__c = addresses[0].Id, Account__c = oContact.AccountId, Contact__c = oContact.Id, Email__c = oContact.Email, Phone__c = oContact.Phone, Address_Name__c = oContact.Name));
        insert mapLocation.values();

        oContact.BillTo_Location__c = mapLocation.get('bill').Id;
        oContact.ShipTo_Location__c = mapLocation.get('ship').Id;
        update oContact;
        update new Account(Id=oContact.AccountId, SoldTo_Location__c=mapLocation.get('sold').Id, ICH_Member__c=true);

        Account oAccountHQ = TestDataGenerator.generateAccounts(1, false)[0];
        oAccountHQ.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        oAccountHQ.Membership_status__c = IECConstants.Account_MembershipStatus_IATAMember;
        oAccountHQ.IATACode__c = '~1~!~2~@~';
        oAccountHQ.IATA_ISO_Country__c = addresses[0].ISO_Country__c;
        oAccountHQ.Airline_designator__c = 'AA';
        insert oAccountHQ;

    } //*** end of "test_AllMethod"


} //*** end of class