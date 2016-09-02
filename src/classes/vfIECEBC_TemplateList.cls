public class vfIECEBC_TemplateList extends vfIECEBC_Abstract_List {
    public static Integer ITEMS_PER_PAGE = 2;
    private boolean firsttimepageload=true;
    public vfIECEBC_TemplateList() {
        sortBy='CreatedDate Desc';
    }
      
    public override List<SelectOption> getSortByOptions() {
        List<SelectOption> options = new List<SelectOption>();
        if (getIsFirstTimeLoadPage()) options.add(new SelectOption('CreatedDate DESC','Sort by'));
        options.add(new SelectOption('Audience__c DESC','Audience'));
        options.add(new SelectOption('CreatedDate DESC','Creation Date'));
        options.add(new SelectOption('LastModifiedDate DESC','Last Edited'));
        options.add(new SelectOption('Name ASC','Name'));

        return options;
       
    }
    public PageReference Duplicate(){ 
        EBC_Template__c original = [
            Select
            	Id,
                Name,
	            Audience__c,
	            Parent_Template__c,
	            RecordTypeId
            From EBC_Template__c
            Where
            	Id = :selectedItem.Id
        ];
        List<Attachment> originalAttachments = [Select Id, Name, ContentType, Body From Attachment Where ParentId = :original.Id];
        
        EBC_Template__c newTemplate = new EBC_Template__c();
        newTemplate.Name = ((EBC_Template__c)selectedItem).Name;
        newTemplate.RecordTypeId = original.RecordTypeId;
        newTemplate.Billing_Account__c = billingAccount.Id;
        newTemplate.Audience__c = original.Audience__c; 
        newTemplate.Is_Reusable__c = true;
        newTemplate.Parent_Template__c = original.Parent_Template__c;
        insert newTemplate;
        
        List<Attachment> newAttachments = new List<Attachment>();
        for(Attachment a : originalAttachments) {
            newAttachments.add(new Attachment(
                ParentId = newTemplate.Id,
                Name = a.Name,
                ContentType = a.ContentType,
                Body = a.Body
            ));
        }
        
        if (newAttachments.size() > 0) insert newAttachments;
        
        
        resetQuery();
        return null;
    }
    private String getQuery(Boolean isCountOnly) {
        List<String> fields = new List<String>();
        if (isCountOnly) {
            fields.add('count()');
        } else {
            fields.add('Id');
            fields.add('Name');
            fields.add('Audience__c');
            fields.add('CreatedDate');
            fields.add('LastModifiedDate'); 
            fields.add('Parent_Template__c');
        }
        return 'Select ' + String.join(fields, ',') + ' FROM EBC_Template__c Where IsDeleted=false and Billing_Account__c = \'' + vfIECEBC.billingAccount.Id + '\' AND Is_Reusable__c = true';
        
        //return 'Select ' + String.join(fields, ',') + ' FROM EBC_Template__c Where Is_Reusable__c  = true AND Billing_Account__c = \'' + vfIECEBC.billingAccount.Id + '\'';
    }
    
    public List<EBC_Template__c> getFilters() {
        return (List<EBC_Template__c>)items; 
    }
    public EBC_Template__c getSelectedFilter() {
        return (EBC_Template__c)selectedItem; 
    }
    private Boolean getIsFirstTimeLoadPage() { 
        if (firsttimepageload) {firsttimepageload=false; return true;}
        return false;}
    
    public String newTemplateCustomCode { get; set;} 
    public EBC_Template__c newTemplate {
        get {
            if (newTemplate == null) {
                newTemplate = new EBC_Template__c();
                newTemplate.Billing_Account__c = billingAccount.Id;
            }
            return newTemplate;
        }
        set;
    }
    public Boolean isSaved {
        get {
            if (isSaved == null) isSaved = false;
            return isSaved;
        }
        set;
    }
    public Integer newTemplateStepNumber {
        get {
            if (newTemplateFieldsValidity != null && newTemplateStepNumber == 2 && !newTemplateFieldsValidity.get('Audience__c')) {
                newTemplateStepNumber = 1;
            } else if (newTemplateFieldsValidity != null && newTemplateStepNumber == 4 && !newTemplateFieldsValidity.get('Name')) {
                newTemplateStepNumber = 3;
            }
            
            if (newTemplateStepNumber == null) newTemplateStepNumber = 1;
                
            return newTemplateStepNumber;
        }
        set;
    }
    public void ResetWizard() {
        newTemplateFieldsValidity =null;
        newTemplateStepNumber=null;
    }
    public Map<String, Boolean>  newTemplateFieldsValidity {
        get {
            if (newTemplateFieldsValidity == null) {
                newTemplateFieldsValidity = new Map<String, Boolean>{
                    'Audience__c' => true,
                    'Name' => true
                };
            }
            return newTemplateFieldsValidity;
        }
        set;
    }
    public PageReference validateNewTemplate() {
        newTemplateFieldsValidity = null;
        
        try {
            Savepoint sp = Database.setSavepoint();
            insert newTemplate;
            Database.rollback(sp);
            newTemplate.Id = null;
        } catch(Exception e) { 
            newTemplate.Id = null;
            if (newTemplateStepNumber == 2 && e.getMessage().contains('Audience__c')) newTemplateFieldsValidity.put('Audience__c', false);
            if (newTemplateStepNumber == 4 && e.getMessage().contains('Name')) newTemplateFieldsValidity.put('Name', false);
        }
        
        return null;
    }
    
    public PageReference createTemplate() {
        newTemplate.Is_Reusable__c=true;
        
        EBC_Template__c parentTemplate;
        
        if (!String.isBlank(selectedTemplateId)) {
            parentTemplate = [
                Select
                	Id,
                	Name,
                	RecordType.DeveloperName,
                	Parent_Template__c
                From EBC_Template__c
                Where
                	Id = :selectedTemplateId
            ];
            
            /*if (parentTemplate.RecordType.DeveloperName != 'Global') {
                newTemplate.Parent_Template__c = parentTemplate.Parent_Template__c;
            } else {*/
                newTemplate.Parent_Template__c = parentTemplate.Id;
            //}
        }
        
        insert newTemplate;
        isSaved = true;
        
        PageReference pr;
        
        if (String.isBlank(selectedTemplateId)) {
            Attachment a = new Attachment();
            a.ParentId = newTemplate.Id;
            a.ContentType = 'text/html';
            a.Body = Blob.valueOf(newTemplateCustomCode);
            a.Name = 'template.html';
            insert a;
        }
        
        if (newTemplate.Parent_Template__c != null) {
            pr = new PageReference('/iec/IECEBC_MosaicoEditor');
            pr.getParameters().put('id', newTemplate.Id);
        } else {
            pr = new PageReference('/' + newTemplate.Id);
        }
        
        pr.setRedirect(true);
        
        return pr;
    }
    
    public Id selectedTemplateId { get; set; }
    
}