public class vfIECEBC_TemplateCreation extends vfIECEBC_Controller 
{
    public String audience { get; set; }
    
    public List<EBC_Template__c> globalTemplates {
        get {
            
            if(globalTemplates == null) {
                globalTemplates = [
                    SELECT
                        Id,
                        Template_Name__c,
                        (Select Id, Name From Attachments where Name = '/edres/_full.png')
                    FROM EBC_Template__c
                    WHERE
                        Recordtype.DeveloperName = 'Global' AND 
                        Audience__c = :audience
                ];
            }
            
            return globalTemplates;
        }
        set;
    }
    public Id selectedTemplate{get;set;}
    public vfIECEBC_TemplateCreation()
    {
        selectedTemplate = null;
        //getUserSavedTemplates();  
    }
}