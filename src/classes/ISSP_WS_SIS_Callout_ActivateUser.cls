public with sharing class ISSP_WS_SIS_Callout_ActivateUser {

    public static String TEST_RESPONSE='';

    public class RequestData {
        String IcpUserName;
        String IcpPassword;
        String SISMemberID;
        String FederationID;
        
        public String toXML() {
            String xml = '<IcpRequestMessage>';
            xml += '<IcpUserName>' + this.IcpUserName + '</IcpUserName>';
            xml += '<IcpPassword>' + this.IcpPassword + '</IcpPassword>';
            xml += '<SISMemberID>' + this.SISMemberID + '</SISMemberID>';
            xml += '<FederationID>' + this.FederationID + '</FederationID>';
            xml += '</IcpRequestMessage>';
            return xml;
        }
    }

    public class ResponseData {
        public Boolean IsSuccess;
        public String ErrorCode;
        public String ErrorDescription;
        public String requestString;
        public Boolean activation;
        public Id userId;
        public Id contactId;
        
        public ResponseData(Exception e, String requestString, Boolean activation){
            this.IsSuccess = false;
            this.ErrorCode = e.getTypeName();
            this.ErrorDescription = e.getMessage();
            this.requestString = requestString;
            this.activation = activation;
        }
        
        public ResponseData(String xmlString, String requestString, Boolean activation) {
            try {
                this.requestString = requestString;
                this.activation = activation;
                Dom.Document doc = new Dom.Document();
                doc.load(xmlString);
                map<String,String> mapValues = new map<String,String>();
                for (Dom.XmlNode node : doc.getRootElement().getChildElements()) {
                    mapValues.put(node.getName(), node.getText());
                }
                this.IsSuccess = Boolean.valueOf(mapValues.get('IsSuccess'));
                this.ErrorCode = mapValues.get('ErrorCode');
                this.ErrorDescription = mapValues.get('ErrorDescription');
            } catch (Exception e) {
                e.setMessage('Error parsing response ' + xmlString);
            }
        }
    }
    
    public static ResponseData activateUser(User user) {
        return changeUserActivation(user, true);
    }

    public static ResponseData deactivateUser(User user) {
        return changeUserActivation(user, false);
    }

    public static ResponseData changeUserActivation(User user, Boolean activation) {
        String requestString = '';
        try {
            //create request
            RequestData request = new RequestData();
            request.IcpUserName = ISSP_WS_SIS_Callout_Common.getUser();
            request.IcpPassword = ISSP_WS_SIS_Callout_Common.getPass();
            request.SISMemberID = nvl(user.contact.Account.SIS_ID__c);
            request.FederationID = nvl(user.FederationIdentifier);
            requestString = request.toXML();
            
            //make ws call
            ISSP_WS_SIS_Callout.IcpWsInterfaceSoap ws = ISSP_WS_SIS_Callout_Common.getWSInterface();
            String xmlResponse = '';
            if (activation) {
                xmlResponse = Test.isRunningTest()? TEST_RESPONSE: ws.ActivateUser(requestString);
            } else {
                xmlResponse = Test.isRunningTest()? TEST_RESPONSE: ws.DeactivateUser(requestString);
            }
            
            //prepare response
            ResponseData response = new ResponseData(xmlResponse, requestString, activation);
            response.userId = user==null? null: user.Id;
            response.contactId = user==null? null: user.contactId;
            return response;

        } catch (Exception e) {
            ResponseData response = new ResponseData(e, requestString, activation);
            response.userId = user==null? null: user.Id;
            response.contactId = user==null? null: user.contactId;
            return response;
        }
    }
    
    public static ISSP_Web_Service_Log__c createLog(ResponseData responseData) {
        ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
        newLog.Web_Service__c = 'ISSP_WS_SIS_Callout';
        newLog.Method__c = responseData.activation? 'ActivateUser': 'DeactivateUser';
        newLog.System__c = 'SIS';
        newLog.Login_Ip__c = ISSP_WS_SIS_Common.getLoginIP();
        newLog.Input_Description__c = responseData.requestString;
        newLog.Success__c = responseData.IsSuccess;
        newLog.Error_Code__c = responseData.ErrorCode;
        newLog.Error_Message__c = responseData.ErrorDescription;
        newLog.Finished__c = system.now();
        newLog.User__c = responseData.userId;
        newLog.Contact__c = responseData.contactId;
        return newLog;
    }
    
    private static String nvl(String str) {
        return str==null?'':str;
    }
}