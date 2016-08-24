public class vfIECEBC_MosaicoEditor extends vfIECEBC_Controller {
    public ApexPages.StandardController con { get; set; }
    public EBC_Template__c template { get; set; }
    
    public Attachment metadata {
        get;
        set;
    }
    public String getMetadataString() {
        return metadata.Body.toString();
    }
    public Attachment templateJSON {
        get;
        set;
    }
    public String getJSONString() {
        return templateJSON.Body.toString();
    }
    public Attachment templateHTML {
        get;
        set;
    }
    public String getHTMLString() {
        return templateHTML.Body.toString();
    }
    
    public vfIECEBC_MosaicoEditor(ApexPages.StandardController stdController) {        
        this.con = stdController;
        
        this.template = (EBC_Template__c)stdController.getRecord();
        
        for(Attachment a : [Select Id, Name, Body From Attachment Where ParentId = :this.template.Id]) {
            if (a.Name == 'metadata.json') this.metadata = a;
            if (a.Name == 'template.json') this.templateJSON = a;
            if (a.Name == 'template.html') this.templateHTML = a;
        }
    }
}