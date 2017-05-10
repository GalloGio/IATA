public without sharing class SelectEmailTemplateController {

	public String selectedTemplateId {get; set; }
	public list<EmailTemplate> listTemplate {get; set;}
	public String selectedFolderId {get; set;}
	public sendSingleTrackedEmailController parent {get; set;}

	public SelectEmailTemplateController() {
		try {
			this.selectedFolderId = [Select Id
				From Folder
				where type = 'Email'
				order by Name
				limit 1].Id;
			fillListTemplate();
		} catch(Exception e) {}

	}

	public list<SelectOption> getListFolder() {
		list<SelectOption> listOption = new list<SelectOption>();
		for ( Folder folder: [
				Select Id, Name
				From Folder f
				where type = 'Email'
				order by Name
		]) {
			listOption.add( new SelectOption(folder.Id, folder.Name) );
		}
		return listOption;
	}

	public void fillListTemplate() {
		this.listTemplate = [
			Select TemplateType, Description, Name
			From EmailTemplate
			Where IsActive = true
			and FolderId = :selectedFolderId
		];
	}

	public String getCurrentUrl() {
		Pagereference pageref = Page.sendSingleTrackedEmail;
		pageref.getParameters().put('case',ApexPages.currentPage().getParameters().get('case'));
		String toContact = getToContact();
		if (toContact != null) {
			pageref.getParameters().put('toContact',toContact);
		}
		return pageref.getUrl();
	}

	private String getToContact() {
		try {
			return this.parent.email.ToContact__c;
		} catch (Exception e) {
			return null;
		}
	}

}