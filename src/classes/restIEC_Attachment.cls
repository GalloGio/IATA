@RestResource(urlMapping='/Resources/*')
global without sharing class restIEC_Attachment {
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String aId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Attachment a = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE Id = :aId];
        
        res.responseBody = a.Body;
        res.addHeader('Content-Type', a.ContentType);
    }
}