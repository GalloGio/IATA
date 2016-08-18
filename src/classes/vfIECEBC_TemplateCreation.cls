public class vfIECEBC_TemplateCreation extends vfIECEBC_Controller 
{
    public String audience { get; set; }
    
    public List<EBC_Template__c> globalTemplates {
        get {
            
            if(globalTemplates == null) {
            	System.debug('Select Id,TypeOfTemplate__c,Template_Name__c,Is_Reusable__c from EBC_Template__c where Is_Reusable__c = true and Recordtype.DeveloperName = \'Global\' and No_of_attachments__c = 2 and Audience__c = \'' + audience + '\'');
                globalTemplates = [
                    SELECT
                    Id,
                    TypeOfTemplate__c,
                    Template_Name__c,
                    Is_Reusable__c,
                    (Select Id, Name From Attachments where ContentType != 'application/xml')
                    FROM EBC_Template__c
                    WHERE Is_Reusable__c = true
                    AND Recordtype.DeveloperName = 'Global'
                    AND No_of_attachments__c = 2
                    AND Audience__c = :audience
                ];
            }
            
            return globalTemplates;
        }
        set;
    }
    public List<EBC_Template__c> userEditableTemplates {
        get {  
            if (userEditableTemplates == null) {
                userEditableTemplates = [Select Id,Is_Reusable__c,Template_Name__c,TypeOfTemplate__c,
                    (Select Id, Name From Attachments where ContentType != 'application/xml')
                                         from EBC_Template__c
                                         where Is_Reusable__c = true
                                         and OwnerId =: userinfo.getUserId()
                                         and RecordType.DeveloperName != 'Global'
                                         and No_of_attachments__c = 1
                                         and Audience__c = :audience
                                        ];
            }
            return userEditableTemplates;
        }
        set;
    }
    public Id selectedTemplate{get;set;}
    public vfIECEBC_TemplateCreation()
    {
        selectedTemplate = null;
        //getUserSavedTemplates();  
    }
    public PageReference redirectUserToTemplate()
    {
        EBC_Template__c template = [Select Id,TypeOfTemplate__c
                                    from EBC_Template__c
                                    where id =:selectedTemplate];
        PageReference pageRef = new PageReference('/apex/'+template.TypeOfTemplate__c+'?id='+selectedTemplate);
        pageRef.setRedirect(true);
        return pageRef;
    }
}