public class ISSP_WS_WorldTracer {

    public class requestInfo{
        public String recordType;
        public String referenceNumber;
        public String airlineCode;
        public String stationCode;
        public String agentID;

        public requestInfo(String recordType, String referenceNumber, String airlineCode, String stationCode, String agentID){
            this.recordType = recordType;
            this.referenceNumber = referenceNumber;
            this.airlineCode = airlineCode;
            this.stationCode = stationCode;
            this.agentID = agentID;
        }
    }


    public static Integer readBaggageInformation(RequestInfo requestData){
        Integer resCode = 404;
        HttpRequest req = createRequestHeaders();

        string soapXml =
        '<?xml version="1.0" encoding="UTF-8"?>'+
        '<WTR_ReadRecordRQ xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:iata="http://www.iata.org/IATA/2007/00" xmlns:common="http://sita.aero/wtr/common/7/0" xmlns="http://sita.aero/WTR_ReadRecordRQ/7/0" xsi:schemaLocation="http://sita.aero/WTR_ReadRecordRQ/7/0 WTR_ReadRecordRQ.xsd" ModuleID="WT" Version="0.0" Target="Production">'+
            '<POS>'+
                '<iata:Source AirlineVendorID='+requestData.airlineCode+'> </iata:Source>'+
            '</POS>'+
            '<RecordID>'+
                '<common:RecordType>'+requestData.recordType+'</common:RecordType>'+
                '<common:RecordReference ReferenceNumber='+requestData.referenceNumber+' AirlineCode='+requestData.airlineCode+' StationCode='+requestData.stationCode+'/>'+
            '</RecordID>'+
            '<AgentID>'+requestData.agentID+'</AgentID>'+
        '</WTR_ReadRecordRQ>';

        system.debug('SoapXml = ' + soapXml);

        try{
            req.setBody(soapXml);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            system.debug('res.getBody(): ' + res.getBody());
            system.debug('res.getStatusCode(): ' + res.getStatusCode());
            resCode = res.getStatusCode();
            parse(res.getBody());
        }
        catch(Exception e){
            system.debug('Error message: ' + e.getMessage());
        }

        return resCode;
    }


    private static HttpRequest createRequestHeaders(){
        HttpRequest req = new HttpRequest();
        req.setClientCertificateName('wtrcertificate');
        //req.setEndpoint('http://www.webservices-qa.worldblatracer.sita.aero');
        req.setMethod('GET');
        req.setTimeout(120000);
        req.setHeader('content-type', 'text/xml; charset=UTF-8');
        req.setHeader('Transfer-Encoding', 'chunked');

        return req;
    }



    public static Void parse(String toParse) {

        DOM.Document doc = new DOM.Document();     
        try {
            doc.load(toParse);   
            system.debug('Doc toParse: ' + toParse);
            DOM.XMLNode root = doc.getRootElement();
            system.debug('Parsed xml: '+walkThrough(root)); 
        } catch (System.XMLException e) {  // invalid XML
            system.debug('Invalid XML message: ' + e.getMessage());
        }
    }

    private static String walkThrough(DOM.XMLNode node) {
        String result = '\n';
        if (node.getNodeType() == DOM.XMLNodeType.COMMENT) {
            return 'Comment (' +  node.getText() + ')';
        }
        if (node.getNodeType() == DOM.XMLNodeType.TEXT) {
            return 'Text (' + node.getText() + ')';
        }
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            result += 'Element: ' + node.getName();
            if (node.getText().trim() != '') {
              result += ', text=' + node.getText().trim();
            }
            if (node.getAttributeCount() > 0) {
              for (Integer i = 0; i< node.getAttributeCount(); i++ ) {
                result += ', attribute #' + i + ':' + node.getAttributeKeyAt(i) + '=' + node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i));
              } 
            }
            for (Dom.XMLNode child: node.getChildElements()) {
              result += walkThrough(child);
            }
            return result;
        }
        return '';  //should never reach here

      }


}