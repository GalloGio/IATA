public class vfIECEBC_TemplateList extends vfIECEBC_Abstract_List {
    public static Integer ITEMS_PER_PAGE = 2;
    private boolean firsttimepageload=true; 
    public vfIECEBC_TemplateList() { 
        sortBy='CreatedDate Desc'; 
    }
      
    public override List<SelectOption> getSortByOptions() {
        List<SelectOption> options = new List<SelectOption>();
        if (getIsFirstTimeLoadPage()) options.add(new SelectOption('CreatedDate DESC','Sort by'));
        options.add(new SelectOption('Name ASC','Template Name'));
        options.add(new SelectOption('Audience__c ASC','Template Audience'));
        options.add(new SelectOption('CreatedDate ASC','Created Date - Ascending'));
        options.add(new SelectOption('CreatedDate DESC','Created Date - Descending'));
        options.add(new SelectOption('LastModifiedDate ASC','Last Edited - Ascending'));
        options.add(new SelectOption('LastModifiedDate DESC','Last Edited - Descending'));

        return options;
    }
    public boolean flagTabBasicTemplate {get { if (flagTabBasicTemplate==null) flagTabBasicTemplate=true; return flagTabBasicTemplate;} set;}
    public boolean flagTabUseHtml{ get{ if (flagTabUseHtml==null) flagTabUseHtml=false; return flagTabUseHtml;} set;}
    public void TabBasicTemplate(){
        flagTabBasicTemplate=true;
        flagTabUseHtml=false;
    }
    public void TabUseHtml(){
        flagTabBasicTemplate=false;
        flagTabUseHtml=true;
    }
    
    public static EBC_Template__c duplicate(Id templateId, String name, Id billingAccountId, Boolean isReusable) {
        EBC_Template__c original = [
            Select
                Id,
                Name,
                Audience__c,
                Parent_Template__c,
                RecordTypeId
            From EBC_Template__c
            Where
                Id = :templateId
        ];
        
        EBC_Template__c newTemplate = new EBC_Template__c();
        newTemplate.Name = name;
        newTemplate.RecordTypeId = original.RecordTypeId;
        newTemplate.Billing_Account__c = billingAccountId;
        newTemplate.Audience__c = original.Audience__c; 
        newTemplate.Is_Reusable__c = isReusable;
        newTemplate.Parent_Template__c = original.Parent_Template__c;
        insert newTemplate;
        
        List<Attachment> originalAttachments = [Select Id, Name, ContentType, Body From Attachment Where ParentId = :original.Id];
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
        
        List<EBC_Template_Resource__c > originalTemplateResources = [Select Id, EBC_Resource__c From EBC_Template_Resource__c Where EBC_Template__c = :original.Id];
        List<EBC_Template_Resource__c > newTemplateResources = new List<EBC_Template_Resource__c>();
        for(EBC_Template_Resource__c a : originalTemplateResources) {
            newTemplateResources.add(new EBC_Template_Resource__c(
                EBC_Resource__c = a.EBC_Resource__c,
                EBC_Template__c = newTemplate.Id
            ));
        }
        
        if (newTemplateResources.size() > 0) insert newTemplateResources;
        
        return newTemplate;
    }
    
    public PageReference Duplicate(){ 
        EBC_Template__c nTemplate = duplicate(selectedItem.Id, ((EBC_Template__c)selectedItem).Name, billingAccount.Id, true);
        
        PageReference pr = new PageReference('/apex/IECEBC_TemplateEdit?id=' + nTemplate.Id);
        pr.setRedirect(true);
        return pr;
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
    
    
    public EBC_Template__c customHtmlTemplate {
        get {
            
            if(customHtmlTemplate == null) {
                customHtmlTemplate = [
                    SELECT
                        Id,
                        Name,
                        (Select Id, Name From Attachments where Name = '/edres/_full.png')
                    FROM EBC_Template__c
                    WHERE
                        Recordtype.DeveloperName = 'Global' AND 
                        Audience__c = :newTemplate.Audience__c AND
                        External_Id__c LIKE 'customhtml-%'
                    LIMIT 1
                ];
            }
            
            return customHtmlTemplate;
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
            //is there any issue
           
            
        
        }
       String ErrorMessage=''; 
       if (newTemplateStepNumber == 3 && String.isEmpty(selectedTemplateId)) ErrorMessage='Please select a Template before proceeding.';
        //is there any issue
           
       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ErrorMessage);
        if (!ErrorMessage.equals('')) {ApexPages.addMessage(myMsg); newTemplateStepNumber =2;}
        
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
            pr = new PageReference('/apex/IECEBC_TemplateEdit');
            pr.getParameters().put('id', newTemplate.Id);
        } else {
            pr = new PageReference('/' + newTemplate.Id);
        }
        
        pr.setRedirect(true);
        
        return pr;
    }
    
    public Id selectedTemplateId { get; set; }
    private Set<String> SelectionAllowed {
        get {
            if (SelectionAllowed==null) {
                List<SelectOption> options = new List<SelectOption>();
        
               
                SelectionAllowed = new Set<String>();
                //SelectionAllowed.add('IATA Numeric Codes');
                //SelectionAllowed.add('IATA/IATAN ID Cardholders');
                List<Zuora__CustomerAccount__c> balist = New List<Zuora__CustomerAccount__c>();
                balist=[Select Id
                                ,eBroadcast_Audience_Selection__c
                            From Zuora__CustomerAccount__c
                            where Id=:vfIECEBC.billingAccount.Id];
                if (balist.size()==0) return SelectionAllowed;
                //Read Values
                if ( balist[0].eBroadcast_Audience_Selection__c==null) return SelectionAllowed;
                String[] loadinfo = balist[0].eBroadcast_Audience_Selection__c.Split(';');
                if (loadinfo!=null) SelectionAllowed.addAll(loadinfo);
                
            }
            
            return SelectionAllowed;
        }
        private set;
    }
    public Boolean isIDCARDSelectionAllowed {
        get {
            isIDCARDSelectionAllowed=false;
            if (SelectionAllowed.Contains('IATA/IATAN ID Cardholders')) isIDCARDSelectionAllowed=true;
            return isIDCARDSelectionAllowed;
        }
        private set;
    }
    
}