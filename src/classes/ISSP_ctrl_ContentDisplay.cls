public class ISSP_ctrl_ContentDisplay{
    
    public List<ContentVersion> ContentVersion_Lst {get;set;}
    public ContentVersion ConVer{get;set;}
    public String csHost {get;set;}
    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}

    public ISSP_ctrl_ContentDisplay(){
    
        string ContentVersionId= Apexpages.currentPage().getParameters().get('id');
        ISSP_CS__c cs = ISSP_CS__c.getInstance('Host');
        String csHost = cs.value__c;
        ContentVersion_Lst =new List<ContentVersion>([select id, Title, Description, FileType,OwnerId,Owner.Name, VersionNumber ,ContentUrl,
                                                         TagCsv ,ContentDocumentId , Country_of_publication__c , Document_Category__c ,ContentSize
                                                   From ContentVersion 
                                                   Where IsLatest = true 
                                                   And ContentDocumentId =: ContentVersionId]);
                                                   
        if(ContentVersion_Lst  != null && ContentVersion_Lst .size() > 0){
            ConVer = ContentVersion_Lst  [0];
        }
    }


}