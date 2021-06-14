@IsTest
public class TestDataFactory_ContactRoleDetails_mdt {
	public static final String DEFAULTMASTERLABEL = 'Service_RoleName';
	
	public static List<Contact_Role_Detail__mdt> createDefaultContactRoleDetail_mdt(Integer numberOfRecords){
		ContactRoleDetails_mdt contactRoleDetails_mdt = new ContactRoleDetails_mdt();
		return contactRoleDetails_mdt.createDefaultContactRoleDetailMDT(numberOfRecords);
	}
}