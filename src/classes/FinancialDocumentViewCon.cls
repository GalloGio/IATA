public class FinancialDocumentViewCon {

	private List<ENZ__FTPAttachment__c> docs;
	public Case cse;

	public Boolean portalUser {get; set;}
	public String caseStatus {get; set;}

	public FinancialDocumentViewCon (ApexPages.StandardController controller) {

		try{

			User[] users = [Select u.UserType From User u where u.Id =: UserInfo.getUserId()];
			if (users != null && users.size() > 0){
				if (users[0].UserType == 'PowerPartner'){
					portalUser = true;
				}
				else{
					portalUser = false;
				}
			}
			else{
				portalUser = false;
			}
			system.debug('portal User: ' + portalUser);

			this.cse= (Case)controller.getRecord();
			this.cse = [Select id, Status,CaseNumber,ArchivedDate__c  from Case where id = :cse.id];
			caseStatus = this.cse.Status;
		   }
		   catch(Exception e){
		   String temp = ApexPages.currentPage().getParameters().get('fieldValue');
		   this.cse = [Select id, Status,CaseNumber,ArchivedDate__c from Case where id = :temp];
		   }
	}

	public List<ENZ__FTPAttachment__c> getDocs()
	{
		System.debug('**** Getting New documents');
		docs= [Select Name from ENZ__FTPAttachment__c where Case__c  = :cse.id];
		return docs;

	}
	public Case getCse()
	{
		return cse;
	}

	public String getLocale() {

	User[] users = [Select u.LanguageLocaleKey From User u where u.Id =: UserInfo.getUserId()];

	if (users != null && users.size() > 0)
	  return users[0].LanguageLocaleKey;
	else
	  return '';

  }


	public PageReference refreshDocs() {
	System.debug('****** Refreshing page');
	return null;
	}

}
