public class IECEBC_ETImage {
    
    // get status of image from ExactTarget
    Public static Map<String, Object> getImageStatus(String fileName) {
        // http instances and variables        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        Map<String, Object> status = new Map<String, Object>();
        
        // header
        IECEBC_ETHelper.setSoapRequestHeader(req, 'Retrieve');
        // body 
        // fileName = 'TestAug10.jpg'
        req.setBody(
            IECEBC_ETHelper.createXMLHeader()            
            + IECEBC_ETHelper.retrieveRequestImage(fileName) 
            + IECEBC_ETHelper.createXMLFooter()              
        );  
        //System.debug(req.getBody());
        req.setTimeout(IECEBC_ETInit.TimeOut);        
        //system.debug('ImageStatus request body: ' + req.getBody());
        // get response
        HTTPResponse response = http.send(req);        
        System.debug(response.getBody());
        status.put('IsUploaded', false);
        if (response.getStatusCode() == 200) { 
            status.put('IsUploaded', IECEBC_ETHelper.parse(response, 'IsUploaded') == 'true'); 
            status.put('Width', IECEBC_ETHelper.parse(response, 'FileWidthPX'));
            status.put('Height', IECEBC_ETHelper.parse(response, 'FileHeightPX'));
            status.put('Image_Url', IECEBC_ETHelper.parse(response, 'FileURL'));
            status.put('Thumb_Url', IECEBC_ETHelper.parse(response, 'ThumbURL'));
        }
        // return Image instance
        return status;
    }
    
    // Retrieve all portolios that modified from the given timestamp to now
    // Replace '2016-08-25T00:00:00Z' to formatted timestamp variable 
    @future(callout = true)
    public static void getLastUpdate(String timeStamp){
        String bodyContent = 
            '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">' +
            '<RetrieveRequest>' +
            '<ObjectType>Portfolio</ObjectType>' +
            '<Properties>FileName</Properties>' +
            '<Properties>IsUploaded</Properties>' +
            '<Properties>IsActive</Properties>' +
            '<Properties>FileURL</Properties>' +
            '<Properties>ThumbURL</Properties>' +
            '<Filter xsi:type="SimpleFilterPart">' +
            '<Property>ModifiedDate</Property>' +
            '<SimpleOperator>greaterThan</SimpleOperator>' +
            '<DateValue>' + '2016-08-25T00:00:00Z' + '</DateValue>' +      
            '</Filter>' +
            '</RetrieveRequest>' +
            '</RetrieveRequestMsg>'; 
        
        
        HttpRequest req = new HttpRequest(); 
        Http http = new Http();
        req.setTimeout(IECEBC_ETInit.TimeOut);
        IECEBC_ETHelper.SetSoapRequest(req, 'Retrieve', bodyContent);
        system.debug('Last updated request body :' + req.getBody());
        HttpResponse res = new HttpResponse();
        try{
            res = http.send(req);
        }catch(System.CalloutException e){
        }
        
        system.debug('Last updated Images:' + res.getBody());
        if (res.getStatusCode() == 200) { 
            
            if (IECEBC_ETHelper.parse(res, 'StatusCode') != 'OK') {
                //System.debug(IECEBC_ETHelper.parse(res, 'StatusMessage'));
                //throw new UnexpectedResponse_Exception('Unexpected Response');
            }         
            //sendClassificationId = IECEBC_ETHelper.parse(res, 'ObjectID');
            //system.debug('Send Classification creation finished with id :' + sendClassificationId);
            //return sendClassificationId;
        } else{
            System.debug(res);
            //throw new UnexpectedResponse_Exception('Unexpected Response');
        } 
        
    }    
    
        
    // class define an Image
    public class Image {
        public String Status{get; set;}
        public String URL{get; set;}
    }
    
    // get image status and URL from Portfolio if its IsUploaded == true
    Public static Image getImage(String categoryId, String fileName) {
        // http instances and variables        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        Image img = new Image();
        
        // header
        IECEBC_ETHelper.setSoapRequestHeader(req, 'Retrieve');
        // body 
        // CategoryId =  2723632, fileName = 'TestAug10.jpg'
        req.setBody(
            IECEBC_ETHelper.createXMLHeader()            
            + IECEBC_ETHelper.retrieveRequestPortfolio(categoryId, fileName) // category id of the portfolio folder
            + IECEBC_ETHelper.createXMLFooter()              
        );                
        req.setTimeout(IECEBC_ETInit.TimeOut);        
        
        // get response
        HTTPResponse response = http.send(req);        
        if (response.getStatusCode() == 200) { 
            img.Status = IECEBC_ETHelper.parse(response, 'IsUploaded');
            if(img.Status == 'true'){
                img.URL = IECEBC_ETHelper.parse(response, 'FileURL');
            }
        }
        // return Image instance
        return img;
    }
}