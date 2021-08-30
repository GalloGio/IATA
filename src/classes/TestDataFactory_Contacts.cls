@IsTest
public class TestDataFactory_Contacts {
	public static final String DEFAULTEMAIL = 'abc@def.com.invalid';
	public static final String DEFAULTLASTNAME = 'Contact Last Name';

	public static List<Contact> createDefaultContact(Integer numberOfRecords){
		List<Contact> contactList = new List<Contact>();
		for(Integer x = 0; x < numberOfRecords; x++){
			Contact contact = new Contact(Email = DEFAULTEMAIL + x, LastName = DEFAULTLASTNAME);
			contactList.add(contact);
		}
		return contactList;
	}
}