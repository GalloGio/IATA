public class vfIECEBC_TemplateCreation 
{
    public List<EBC_Template__c> globalTemplates {get;set;}
    public Map<Id,String> globalTemplatesThumbnails {get;set;}
    public List<EBC_Template__c> userEditableTemplates {get;set;}
    public Id selectedTemplate{get;set;}
    public vfIECEBC_TemplateCreation()
    {
        globalTemplates = new List<EBC_Template__c>();
        globalTemplatesThumbnails = new Map<Id,String>();
        userEditableTemplates = new List<EBC_Template__c>();
        selectedTemplate = null;
        getGlobalTemplates();
        getUserSavedTemplates();  
    }
    public void getGlobalTemplates()
    {
        if(globalTemplates.size()<1)
        {
            RecordType globalRecordType = [Select Id,DeveloperName
                                          from RecordType
                                          where sObjectType = 'EBC_Template__c'
                                          and developerName = 'Global'
                                          Limit 1];
            globalTemplates = [Select Id,TypeOfTemplate__c,Template_Name__c,Is_Reusable__c
                               from EBC_Template__c
                               where Is_Reusable__c = true
                               and RecordtypeId =: globalRecordType.Id
                               and No_of_attachments__c = 2];
            
            set<Id> attachmentParentIds = new set<Id>();
            for(EBC_Template__c parser:globalTemplates)
            {
                attachmentParentIds.add(parser.Id);
            }
            List<Attachment> globalTemplatesThumbnailsList = [Select Id,Name,ParentId
                                         from Attachment
                                         where ParentId in:attachmentParentIds
                                         and ContentType != 'application/xml'];
            for(Attachment parser:globalTemplatesThumbnailsList)
            {
                globalTemplatesThumbnails.put(parser.ParentId , parser.Id);
            }
        }
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
    public void getUserSavedTemplates()
    {
        if(userEditableTemplates.size()<1)
        {
            RecordType userCustomRecordType = [Select Id,DeveloperName
                                          from RecordType
                                          where sObjectType = 'EBC_Template__c'
                                          and developerName != 'Global'
                                          Limit 1];
            userEditableTemplates = [Select Id,Is_Reusable__c,Template_Name__c,TypeOfTemplate__c
                                     from EBC_Template__c
                                     where Is_Reusable__c = true
                                     and OwnerId =: userinfo.getUserId()
                                     and RecordTypeId =: userCustomRecordType.Id
                                     and No_of_attachments__c = 1];
        }
    }
}