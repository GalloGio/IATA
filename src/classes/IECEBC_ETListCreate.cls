public class IECEBC_ETListCreate {
    
    // Create a List in ExactTarget using a "listName" as parameter an return "listID" For verification.
    public static String createList(String listName){
        String listId; 
        Http http = new Http();        
        String bodyContent = 
            '<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
            '<Options/>' + 
            '<Objects xsi:type="List">'+
            '<ObjectID xsi:nil="true"> </ObjectID>'+
            '<ListName>' + IECEBC_ETHelper.xmlEncode(listName) + '</ListName>'+
            '<Type>Public</Type>'+
            '<PartnerKey xsi:nil="true"/>'+
            '</Objects>'+
            '</CreateRequest>';
        
        
        HttpRequest req = new HttpRequest(); 
        req.setTimeout(IECEBC_ETInit.TimeOut);
        IECEBC_ETHelper.SetSoapRequest(req, 'Create', bodyContent);
        
        string bodyRes = '';        
        HttpResponse res = http.send(req);
        bodyRes = res.getBody();
        if (res.getStatusCode() == 200) { 
                       
            listId = IECEBC_ETHelper.parse(res, 'ID');
        }else{
            system.debug('This is a bad request!');
        }     
        system.debug('listId: ' + listId);
        return listId;
    }   
    
    
}