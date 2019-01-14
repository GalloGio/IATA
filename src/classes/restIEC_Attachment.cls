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
        
        if (req.params != null && req.params.containsKey('client') && req.params.get('client') == 'exacttarget' && objectPrefix == resourcePrefix) {
            EBC_Resource__c resource = [Select Id, Name From EBC_Resource__c Where Id = :aId];
            
            String filename = aId;
            filename += resource.Name.substring(resource.Name.lastIndexOf('.'));
            
            getExactTargetImageStatus(aId, filename);
        }
    }
    
    @future(callout=true)
    public static void getExactTargetImageStatus(Id ebcResourceId, String filename) { 
		Map<String, Object> uploadStatus = IECEBC_ETImage.getImageStatus(filename);
        System.debug(uploadStatus);
        
        EBC_Resource__c resource = new EBC_Resource__c();
        resource.Id = ebcResourceId;
        
        Boolean isUpdated = false;
        if (uploadStatus.containsKey('Image_Url') && !String.isBlank((String)uploadStatus.get('Image_Url'))) {
            resource.Image_URL__c = (String)uploadStatus.get('Image_Url');
            resource.Image_URL__c = resource.Image_URL__c.replace('http://', 'https://');
            isUpdated = true;
        }
        if (uploadStatus.containsKey('Thumb_Url') && !String.isBlank((String)uploadStatus.get('Thumb_Url'))) {
            resource.Thumbnail_URL__c = (String)uploadStatus.get('Thumb_Url');
            resource.Thumbnail_URL__c = resource.Thumbnail_URL__c.replace('http://', 'https://');
            isUpdated = true;
        }
        if (uploadStatus.containsKey('Width') && Integer.valueOf(uploadStatus.get('Width')) != 0) {
            resource.Width__c = Integer.valueOf(uploadStatus.get('Width'));
            isUpdated = true;
        }
        if (uploadStatus.containsKey('Height') && Integer.valueOf(uploadStatus.get('Height')) != 0) {
            resource.Height__c = Integer.valueOf(uploadStatus.get('Height'));
            isUpdated = true;
        }
        
        if (isUpdated) update resource;
    }
}