public with sharing class SelectEmailTemplateController {

    public List<EmailTemplate> listTemplate {get; set;}
    public String selectedFolderId {get; set;}
    public sendSingleTrackedEmailController parent {get; set;}

    public Id selectedTemplate {get;set;}

    public SelectEmailTemplateController() {
        try {
            selectedFolderId = UserInfo.getUserId();
            fillListTemplate();
        } catch(Exception e) {}

    }

    public List<SelectOption> getListFolder() {
        list<SelectOption> listOption = new list<SelectOption>();
        listOption.add(new SelectOption(UserInfo.getOrganizationId(), 'Unfiled Public Email Templates'));
        listOption.add(new SelectOption(UserInfo.getUserId(), 'My Personal Email Templates'));
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

    public PageReference fillListTemplate() {
        this.listTemplate = [
            Select TemplateType, Description, Name
            From EmailTemplate
            Where IsActive = true
            and FolderId = :selectedFolderId
            order by Name
        ];
        return null;
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
            return parent.email.ToContact__c;
        } catch (Exception e) {
            return null;
        }
    }

    public void cancel(){
        parent.showTemplatePanel = false;
    }

    public void setTemplate(){
        parent.setTemplate(selectedTemplate);
        parent.showTemplatePanel = false;
    }
}