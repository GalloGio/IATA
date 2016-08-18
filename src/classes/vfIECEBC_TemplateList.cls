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
        EBC_Template__c original = (EBC_Template__c) selectedItem;
        List<EBC_Template__c> copyfrom = new List<EBC_Template__c>();
        copyfrom = [Select id 
                    	,Audience__c
                    	,Billing_Account__c
                    	,RecordTypeId                    	
                    From EBC_Template__c
                    Where id=:selectedItem.Id
                    Limit 1];
        List<Attachment> copya = new List<Attachment>();
        copya =[select id, body, name From attachment Where ParentId=:selectedItem.Id];
        if (copyfrom.size()==0) return null;
        EBC_Template__c copyto = new EBC_Template__c();
        copyto.Name=original.Name;
        for (EBC_Template__c c:copyfrom){
           
            copyto.Audience__c=c.Audience__c;
            
            copyto.Billing_Account__c=c.Billing_Account__c;
            copyto.RecordTypeId=c.RecordTypeId;
            insert copyto;
            List<Attachment> attachments = new List<Attachment>();
            for(attachment a:copya){
                Attachment attachment = new Attachment();
                attachment.name=a.name;
                attachment.body=a.body;
                attachment.ParentId=copyto.id;
                attachments.add(attachment);
            }
            if (attachments.size()>0) insert attachments;
            break;
        }
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
            } else if (newTemplateFieldsValidity != null && newTemplateStepNumber == 4 && !newTemplateFieldsValidity.get('Template_Name__c')) {
                newTemplateStepNumber = 3;
            }
            
            if (newTemplateStepNumber == null) newTemplateStepNumber = 1;
                
            return newTemplateStepNumber;
        }
        set;
    }
    public Map<String, Boolean>  newTemplateFieldsValidity {
        get {
            if (newTemplateFieldsValidity == null) {
                newTemplateFieldsValidity = new Map<String, Boolean>{
                    'Audience__c' => true,
                    'Template_Name__c' => true
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
            if (newTemplateStepNumber == 4 && e.getMessage().contains('Template_Name__c')) newTemplateFieldsValidity.put('Template_Name__c', false);
        }
        
        return null;
    }
    
    public PageReference createTemplate() {
        insert newTemplate;
        isSaved = true;
        
        
        if (!String.isBlank(selectedTemplateId)) {
            Attachment templateAttachment = [Select a.ParentId, a.Name, a.Id, a.ContentType, a.Body From Attachment a Where a.ParentId = :selectedTemplateId AND ContentType = 'application/xml'];
            
            Attachment a = new Attachment();
            a.ParentId = newTemplate.Id;
            a.Body = templateAttachment.Body;
            a.Name = templateAttachment.Name;
            a.ContentType = templateAttachment.ContentType;
            
            insert a;
        }
        
        PageReference pr = new PageReference('/' + newTemplate.Id);
        pr.setRedirect(true);
        
        return pr;
    }
    
    public Id selectedTemplateId { get; set; }
    
}