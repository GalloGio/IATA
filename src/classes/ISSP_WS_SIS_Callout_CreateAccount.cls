public with sharing class ISSP_WS_SIS_Callout_CreateAccount {

    public static final list<String> LIST_FIELD_NAMES = new list<String>{
        'IATACode__c','SIS_Status__c','Name',
        'SIS_Sub_Status__c','TradeName__c','VAT_Number_2__c','VAT_Number__c',
        'BillingStreet','BillingState','BillingPostalCode','BillingLongitude','BillingLatitude','BillingCountry','BillingCity'
    };
    public static String TEST_RESPONSE='';

    public class RequestData {
        public String IcpUserName;
        public String IcpPassword;
        public String MemberCodeNumeric;
        public String MemberCodeAlpha;
        public String LegalName;
        public String CommercialName;
        public String ISMembershipStatus;
        public String ISMembershipSubStatus;
        public String RegistrationID;
        public String TaxVatRegistrationNumber;
        public String AddTaxVatRegistrationNumber;
        public String AddressLine1;
        public String AddressLine2;
        public String AddressLine3;
        public String CityName;
        public String SubDivisionName;
        public String PostalCode;
        public String CountryCode;
        
        public String toXML() {
            String xml = '<IcpRequestMessage>';
            xml += '<IcpUserName>' + this.IcpUserName + '</IcpUserName>';
            xml += '<IcpPassword>' + this.IcpPassword + '</IcpPassword>';
            xml += '<MemberCodeNumeric>' + this.MemberCodeNumeric + '</MemberCodeNumeric>';
            xml += '<MemberCodeAlpha>' + this.MemberCodeAlpha + '</MemberCodeAlpha>';
            xml += '<LegalName>' + this.LegalName + '</LegalName>';
            xml += '<CommercialName>' + this.CommercialName + '</CommercialName>';
            xml += '<ISMembershipStatus>' + this.ISMembershipStatus + '</ISMembershipStatus>';
            xml += '<ISMembershipSubStatus>' + this.ISMembershipSubStatus + '</ISMembershipSubStatus>';
            xml += '<RegistrationID>' + this.RegistrationID + '</RegistrationID>';
            xml += '<TaxVatRegistrationNumber>' + this.TaxVatRegistrationNumber + '</TaxVatRegistrationNumber>';
            xml += '<AddTaxVatRegistrationNumber>' + this.AddTaxVatRegistrationNumber + '</AddTaxVatRegistrationNumber>';
            xml += '<AddressLine1>' + this.AddressLine1 + '</AddressLine1>';
            xml += '<AddressLine2>' + this.AddressLine2 + '</AddressLine2>';
            xml += '<AddressLine3>' + this.AddressLine3 + '</AddressLine3>';
            xml += '<CityName>' + this.CityName + '</CityName>';
            xml += '<SubDivisionName>' + this.SubDivisionName + '</SubDivisionName>';
            xml += '<PostalCode>' + this.PostalCode + '</PostalCode>';
            xml += '<CountryCode>' + this.CountryCode + '</CountryCode>';
            xml += '</IcpRequestMessage>';
            return xml;
        }
    }

    public class ResponseData {
        public Boolean IsSuccess;
        public String SISMemberID;
        public String ErrorCode;
        public String ErrorDescription;
        public String requestString;
        public Account account;
        
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
                this.ErrorCode = mapValues.get('ErrorCode');
                this.ErrorDescription = mapValues.get('ErrorDescription');
            } catch (Exception e) {
                e.setMessage('Error parsing response ' + xmlString);
                this.IsSuccess = false;
                this.ErrorCode = e.getTypeName();
                this.ErrorDescription = e.getMessage();
                this.requestString = requestString;
            }
        }
    }

    public static ResponseData createAccount(Account account) {
        String requestString = '';
        try {
            //create request
            RequestData request = new RequestData();
            request.IcpUserName = ISSP_WS_SIS_Callout_Common.getUser();
            request.IcpPassword = ISSP_WS_SIS_Callout_Common.getPass();
            request.MemberCodeNumeric = nvl(account.IATACode__c).toUpperCase();
            request.MemberCodeAlpha = 'XB';
            request.LegalName = ISSP_WS_SIS_Callout_Common.cleanSpecialChars(account.Name);
            String tradeName = ISSP_WS_SIS_Callout_Common.cleanSpecialChars(account.TradeName__c);
            request.CommercialName = tradeName==''? request.LegalName: tradeName;
            request.ISMembershipStatus = nvl(account.SIS_Status__c);
            request.ISMembershipSubStatus = nvl(account.SIS_Sub_Status__c);
            request.RegistrationID = '';
            request.TaxVatRegistrationNumber = nvl(account.VAT_Number__c);
            request.AddTaxVatRegistrationNumber = nvl(account.VAT_Number_2__c);
            // fix to avoid compilation problem with BillingAddress field
            Address billingAddress = (Address)account.get('BillingAddress');
            if (billingAddress==null) {
                request.AddressLine1 = '';
                request.AddressLine2 = '';
                request.AddressLine3 = '';
                request.CityName = '';
                request.SubDivisionName = '';
                request.PostalCode = '';
                request.CountryCode = '';
            } else {
                String fullAddress = ISSP_WS_SIS_Callout_Common.addressToString(billingAddress);
                request.AddressLine1 = fullAddress.mid(0,70);
                request.AddressLine2 = fullAddress.mid(70,70);
                request.AddressLine3 = fullAddress.mid(140,70);
                request.CityName = ISSP_WS_SIS_Callout_Common.cleanSpecialChars(account.BillingCity);
                request.SubDivisionName = ISSP_WS_SIS_Callout_Common.cleanSpecialChars(account.BillingState);
                request.PostalCode = nvl(account.BillingPostalCode);
                request.CountryCode = nvl(account.Country_ISO_Code__c).toUpperCase();
            }
            requestString = request.toXML();
            
            //make ws call
            ISSP_WS_SIS_Callout.IcpWsInterfaceSoap ws = ISSP_WS_SIS_Callout_Common.getWSInterface();
            String xmlResponse = Test.isRunningTest()? TEST_RESPONSE: ws.CreateAccount(requestString);

            //prepare response
            ResponseData response = new ResponseData(xmlResponse, requestString);
            response.account = account;
            return response;

        } catch (Exception e) {
            ResponseData response = new ResponseData(e, requestString);
            response.account = account;
            return response;
        }
    }
    
    public static ISSP_Web_Service_Log__c createLog(ResponseData responseData) {
        ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
        newLog.Web_Service__c = 'ISSP_WS_SIS_Callout';
        newLog.Method__c = 'CreateAccount';
        newLog.System__c = 'SIS';
        newLog.Login_Ip__c = ISSP_WS_SIS_Common.getLoginIP();
        newLog.Input_Description__c = responseData.requestString;
        newLog.Success__c = responseData.IsSuccess;
        newLog.Error_Code__c = nvl(responseData.ErrorCode).left(255);
        newLog.Error_Message__c = nvl(responseData.ErrorDescription).left(255);
        newLog.Finished__c = system.now();
        newLog.account__c = responseData.account==null? null: responseData.account.Id;
        return newLog;
    }
    
    private static String nvl(String str) {
        return str==null?'':str;
    }
}