@isTest
private class ContactsSelectorTest {
	private static String email = 'abc@def.cominvalid';

	@testSetup static void setup(){
		insert new Contact(Email = email, LastName = 'Test Last Name');
	}

	@isTest static void testSelectWithInnerQueryAndConditionSet(){
		List<Contact> contactList = ContactsSelector.selectByConditionSet('Id', 'Email', new Set<String>{ email });
		Map<Id,Contact> contactMap = new Map<Id, Contact>(contactList);
		Contact[] contactArray = ContactsSelector.selectWithInnerQueryAndIdConditionSet('Id', 'Id', contactMap.keySet());

		Test.startTest();
		System.assertEquals(1, contactArray.size(), 'Returned array does not contain on 1 Contact.');
		Test.stopTest();
	}
}