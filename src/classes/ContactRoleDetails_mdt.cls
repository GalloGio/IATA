public with sharing class ContactRoleDetails_mdt {
	public List<Contact_Role_Detail__mdt> records { get; private set; }
    
	public ContactRoleDetails_mdt() {
		records = new List<Contact_Role_Detail__mdt>();
    }

	public ContactRoleDetails_mdt(List<Contact_Role_Detail__mdt> contacRoleDetailMDTList){
		records = contacRoleDetailMDTList.clone();
	}

	//return a 'default' Functional_Role_mdt record (ONLY USED TO DEFAULT AND RETURN MANDATORY FIELDS)
	public List<Contact_Role_Detail__mdt> createDefaultContactRoleDetailMDT(Integer numberOfRecords){
		for(Integer x = 0; x < numberOfRecords; x++){
			Contact_Role_Detail__mdt contactRoleDetail_mdt = (Contact_Role_Detail__mdt) Schema.getGlobalDescribe().get('Contact_Role_Detail__mdt').newSObject();
			contactRoleDetail_mdt.MasterLabel = TestDataFactory_ContactRoleDetails_mdt.DEFAULTMASTERLABEL + x;
			records.add(contactRoleDetail_mdt);
		}
		return records;
	}

	public class ContactRoleDetails_mdtDomainException extends Exception {}
}