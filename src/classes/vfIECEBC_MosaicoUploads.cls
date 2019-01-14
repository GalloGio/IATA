@RestResource(urlMapping='/MosaicoUploads/*')
global class vfIECEBC_MosaicoUploads extends vfIECEBC_Controller {
    public static User getUserBySessionId() {
        return [Select Id, ContactId, Contact.AccountId from User where id = :UserInfo.getUserId()];
    }
    public static Zuora__CustomerAccount__c getBillingAccountByUser() {
        return [
            Select
                Id,
                eBroadcast_Trusted_Sender__c,
                eBroadcast_Email_Balance__c,
                Zuora__Account__c,
                ClientType__c,
                Contact__r.IATA_Code__c
            FROM Zuora__CustomerAccount__c 
            WHERE
            	Contact__c = :getUserBySessionId().ContactId
            LIMIT 1];
    }
    
//jQuery('.fileupload').fileupload({multipart: false})
    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        Zuora__CustomerAccount__c billingAccount = getBillingAccountByUser();
        
        Matcher m = Pattern.compile('^attachment; filename="(.*)"$').matcher(req.headers.get('Content-Disposition'));
        m.matches();
        Attachment a = new Attachment (
            Body = req.requestBody,
            ContentType = req.headers.get('Content-Type'),
            Name = m.group(1),
            OwnerId = UserInfo.getUserId(),
            IsPrivate = true
        );
        String errorMessage = '';
        try {
            IECEBC_Utility.createResourceForAttachment(a, billingAccount);
            insert a;
            
            res.responseBody = Blob.valueOf(getResourcesJSON(billingAccount.Id, a.ParentId));
        } catch(IECEBC_Utility.Resource_Invalid_Attachment_Exception e) {
            errorMessage = e.getMessage();
        } catch(IECEBC_Utility.Attachment_Size_Exceeds_Capacity_Exception e) {
            errorMessage = e.getMessage();
        } catch(Exception e) {
            errorMessage = 'Unknown error';
        }
       
        if (errorMessage!='') {
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'files' => new List<Object>{
                    new Map<String, Object>{
                        'name' => a.Name,
                        'size' => EncodingUtil.base64Encode(req.requestBody).length(),
                        'error' => errorMessage
                    }
                }
            }));
        }
        a=new Attachment();
    }

    
    
    public static String getResourcesJSON(Id billingAccountId) {
        return getResourcesJSON(billingAccountId, null);
    }
    public static String getResourcesJSON(Id billingAccountId, Id resourceId) {
        String resQuery = 'SELECT Id, Name, Image_Size__c, (Select Id, ParentId From Attachments) FROM EBC_Resource__c Where Billing_Account__c = \'' + billingAccountId + '\'';
        if (resourceId != null) resQuery += ' AND Id = \'' + resourceId + '\'';
        List<EBC_Resource__c> atts = Database.query(resQuery);

        List<Object> files = new List<Object>();
        for(EBC_Resource__c a : atts) {
            files.add(new Map<String, Object>{
                'name' => a.Name, 
                    'size' => a.Image_Size__c,
                    'url' => 'services/apexrest/Resources/' + a.Attachments[0].Id,
                    'thumbnailUrl' => 'services/apexrest/Resources/' + a.Attachments[0].Id
                    });
        }
        
        Map<String, Object> body = new Map<String, Object>{'files' => files};
            
        return JSON.serialize(body);
    }
    
    @HttpGet
    global static void doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        Zuora__CustomerAccount__c billingAccount = getBillingAccountByUser();
                                                                           
		res.responseBody = Blob.valueOf(getResourcesJSON(billingAccount.Id));
    }
}