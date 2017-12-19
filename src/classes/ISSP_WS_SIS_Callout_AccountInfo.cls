public with sharing class ISSP_WS_SIS_Callout_AccountInfo {

    public static String TEST_RESPONSE='';

    public class RequestData {
        String IcpUserName;
        String IcpPassword;
        String SISMemberID;
        
        public String toXML() {
            String xml = '<IcpRequestMessage>';
            xml += '<IcpUserName>' + this.IcpUserName + '</IcpUserName>';
            xml += '<IcpPassword>' + this.IcpPassword + '</IcpPassword>';
            xml += '<SISMemberID>' + this.SISMemberID + '</SISMemberID>';
            xml += '</IcpRequestMessage>';
            return xml;
        }
    }
    
    public class ResponseData {
        public Boolean IsSuccess;
        public String SISMemberID;
        public String MemberAccountingCode;
        public String MemberDesignator;
        public String ISMembershipStatus;
        public String IsMembershipSubStatus;
        public String ISEntryDate;
        public String ICHMembershipStatus;
        public String ACHMembershipStatus;
        public String ErrorCode;
        public String ErrorDescription;
        public String requestString;
        
        public ResponseData(Exception e, String requestString){
            this.IsSuccess = false;
            this.ErrorCode = e.getTypeName();
            this.ErrorDescription = e.getMessage();
            this.requestString = requestString;
        }
        
        public ResponseData(String xmlString, String requestString) {
            try {
                this.requestString = requestString;
                Dom.Document doc = new Dom.Document();
                doc.load(xmlString);
                map<String,String> mapValues = new map<String,String>();
                for (Dom.XmlNode node : doc.getRootElement().getChildElements()) {
                	mapValues.put(node.getName(), node.getText());
                }
                this.IsSuccess = Boolean.valueOf(mapValues.get('IsSuccess'));
                this.SISMemberID = mapValues.get('SISMemberID');
                this.MemberAccountingCode = mapValues.get('MemberAccountingCode');
                this.MemberDesignator = mapValues.get('MemberDesignator');
                this.ISMembershipStatus = mapValues.get('ISMembershipStatus');
                this.IsMembershipSubStatus = mapValues.get('IsMembershipSubStatus');
                this.ISEntryDate = mapValues.get('ISEntryDate');
                this.ICHMembershipStatus = mapValues.get('ICHMembershipStatus');
                this.ACHMembershipStatus = mapValues.get('ACHMembershipStatus');
                this.ErrorCode = mapValues.get('ErrorCode');
                this.ErrorDescription = mapValues.get('ErrorDescription');
            } catch (Exception e) {
                this.IsSuccess = false;
                this.ErrorCode = 'Error parsing response';
                this.ErrorDescription = e.getMessage();
                e.setMessage('Error parsing response ' + xmlString);
            }
        }
    }
    
    public static ResponseData RetrieveAccountInformation(String SISMemberID) {
        String requestString = '';
        try {
            //create request
            RequestData request = new RequestData();
            request.IcpUserName = ISSP_WS_SIS_Callout_Common.getUser();
            request.IcpPassword = ISSP_WS_SIS_Callout_Common.getPass();
            request.SISMemberID = SISMemberID;
            requestString = request.toXML();
            
            //make ws call
            ISSP_WS_SIS_Callout.IcpWsInterfaceSoap ws = ISSP_WS_SIS_Callout_Common.getWSInterface();
            String xmlResponse = Test.isRunningTest()? TEST_RESPONSE: ws.RetrieveAccountInformation(requestString);
            System.debug('RetrieveAccountInformation xmlResponse: ' + xmlResponse);
            //prepare response
            ResponseData response = new ResponseData(xmlResponse, requestString);
            System.debug('RetrieveAccountInformation Response: ' + response);
            return response;

        } catch (Exception e) {
            ResponseData response = new ResponseData(e, requestString);
            return response;
        }
    }
    
    public static ISSP_Web_Service_Log__c createLog(ResponseData responseData) {
        ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
        newLog.Web_Service__c = 'ISSP_WS_SIS_Callout';
        newLog.Method__c = 'RetrieveAccountInformation';
        newLog.System__c = 'SIS';
        newLog.Input_Description__c = responseData.requestString;
        newLog.Success__c = responseData.IsSuccess;
        newLog.Error_Code__c = responseData.ErrorCode;
        newLog.Error_Message__c = responseData.ErrorDescription;
        newLog.Finished__c = system.now();
        return newLog;
    }

}