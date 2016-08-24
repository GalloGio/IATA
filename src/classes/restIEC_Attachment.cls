@RestResource(urlMapping='/Resources/*')
global without sharing class restIEC_Attachment {
    public static String attachmentPrefix { get { return Attachment.sobjecttype.getDescribe().getKeyPrefix(); } }
    public static String resourcePrefix { get { return EBC_Resource__c.sobjecttype.getDescribe().getKeyPrefix(); } }
    public static String templatePrefix { get { return EBC_Template__c.sobjecttype.getDescribe().getKeyPrefix(); } }
    
    public static Boolean isEBCResource(Id recordId) {
        return String.valueOf(recordId).left(3) == resourcePrefix; 
    }
    public static Boolean isEBCTemplate(Id recordId) {
        return String.valueOf(recordId).left(3) == templatePrefix;
    }
    
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        Matcher m = Pattern.compile('^.*/((' + attachmentPrefix + '|' + resourcePrefix + '|' + templatePrefix + ')[a-zA-Z0-9]{12,15})(/.*)?$').matcher(req.requestURI);
        m.matches();
        
        String aId = (String)m.group(1);
        String objectPrefix = (String)m.group(2);
        String pathSuffix = (String)m.group(3);
        if (pathSuffix == '/') pathSuffix = null;

        Attachment a;
        
        if (objectPrefix == attachmentPrefix) {
            a = [SELECT Id, ParentId, Name, Body, ContentType FROM Attachment WHERE Id = :aId];
            if (!isEBCResource(a.ParentId)) {
	            res.statusCode = 401;
                return ;
            }
        } else if (objectPrefix == resourcePrefix) {
            a = [SELECT Id, ParentId, Name, Body, ContentType FROM Attachment WHERE ParentId = :aId];
        } else if (objectPrefix == templatePrefix) {
            if (String.isBlank(pathSuffix)) pathSuffix = '/template.html';
            
            a = [SELECT Id, ParentId, Name, Body, ContentType FROM Attachment WHERE ParentId = :aId AND Name = :pathSuffix];
        } else {
            res.statusCode = 400;
            return ;
        }
        
        res.responseBody = a.Body;
        res.addHeader('Content-Type', a.ContentType);
    }
}