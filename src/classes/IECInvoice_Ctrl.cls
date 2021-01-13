/****************************************************************************************************
    Created by CGI, Thai 2015-12-18
        Controller for VF page "IECInvoice"
****************************************************************************************************/
public class IECInvoice_Ctrl {

    public String invoiceData{get;set;}
    public Map<String, String> labels { get; set; }  //*** labels for VF page and messages to use in code

//public String getPDF() { return invoiceData; }
//public Blob getPDF() { return EncodingUtil.base64Decode(invoiceData); }


/****************************************************************************************************
    Created by CGI, Thai 2015-12-18
        Constructor
****************************************************************************************************/
    public IECInvoice_Ctrl() {} //*** end of "IECInvoice_Ctrl"

/****************************************************************************************************
    Created by CGI, Thai 2015-12-18
        Get invoice data - to be called before page load
****************************************************************************************************/
    public PageReference getInvoice()
    {
        //*** get labels & messages
        labels = Utility.buildMapFromString(Label.LabelsVF_IECInvoice, '\n', ':');

        //*** get invoice number from parameter
        String invoiceNumber = ApexPages.currentPage().getParameters().get('invoice');
        if (invoiceNumber == null) {
            invoiceData = labels.get('errMissingInvoice');
        }

        SAP_Digital_Invoice.DT_SFDC_DigitalSignedInvoice_Response response = CallSAPToGetInvoice(invoiceNumber);
        
        if(response==null) return null;
        
        //*** get data from response
        if (response.Error == null) {
            invoiceData = response.EncodedSignedInvoice;
            //Create new Attachment on the Order level
            String attchementId = newAttachment(invoiceNumber,invoiceData);
            if(attchementId == null) return null;

            PageReference pageRef = new PageReference('/servlet/servlet.FileDownload?file=' + attchementId);
            pageRef.setRedirect(true);
            return pageRef;
        } else {
            invoiceData = String.format(labels.get('errCallout'), new List<String>{response.Error.Type_x, response.Error.Code, response.Error.Message});
            //IECErrorLogger.logApexError('IECInvoice_Ctrl.getInvoice', invoiceNumber, String.valueOf(response), true);
        }
        
        return null;
    } //*** end of "getInvoice"


    //NewGen: Make the callout reusable
    public SAP_Digital_Invoice.DT_SFDC_DigitalSignedInvoice_Response CallSAPToGetInvoice(String invoiceNumber){
        return getSAPInvoiceResponse(invoiceNumber);
    }

    //NewGen: Make the callout reusable
    public static SAP_Digital_Invoice.DT_SFDC_DigitalSignedInvoice_Response CallSAPToGetInvoice_Static(String invoiceNumber) {
        return getSAPInvoiceResponse(invoiceNumber);
    }

    private static SAP_Digital_Invoice.DT_SFDC_DigitalSignedInvoice_Response getSAPInvoiceResponse(String invoiceNumber) {
        SAP_Digital_Invoice.HTTPS_Port request = new SAP_Digital_Invoice.HTTPS_Port();
        SAP_Digital_Invoice.DT_SFDC_DigitalSignedInvoice_Response response;
        
        //*** prepare callout header
        if (request.inputHttpHeaders_x == null)
            request.inputHttpHeaders_x = new Map<String,String>(); 
        request.inputHttpHeaders_x.put('Authorization', Utility.getSAPauthorization());
        request.timeout_x = Utility.getIntegerSetting('SAP_CALL_TIMEOUT');
        request.endpoint_x = Utility.fixEndpointDomain(request.endpoint_x);

        //*** call out
        try{
            response = request.SI_SFDC_DigitalSignedInvoice_OB(invoiceNumber);    
        }catch(Exception ex){
            IECErrorLogger.logApexException('IECInvoice/getInvoice', invoiceNumber, ex.getMessage(), ex.getStackTraceString());
            return null;
        }
        
        return response;
    }

    //Create new attachment for the SAP invoice on the order level
    public static String newAttachment(String invoiceNumber, String invoiceData){
        List<OrderItem> orderItems = OrderItem_Sel.getOrderItemsByInvNumb(new set<String>{invoiceNumber});
        
        if(orderItems == null || orderItems.size() == 0) return null;

        Attachment attach = new Attachment();
        attach.Name = orderItems[0].OrderId;
        attach.ParentId = orderItems[0].OrderId;
        attach.ContentType = 'application/pdf';
        attach.Body = EncodingUtil.base64Decode(invoiceData);
        attach.Description = 'SAP invoice to delete by batch';
        insert attach;

        return attach.Id;
    }

} //*** end of class