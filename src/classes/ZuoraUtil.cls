public class ZuoraUtil 
{
    public static final String ZCHARGE_MODEL_FLAT_FEE               = 'Flat Fee';
    public static final String ZCHARGE_MODEL_PER_UNIT               = 'Per Unit';
    public static final String ZCHARGE_MODEL_VOLUME                 = 'Volume';
    public static final String ZCHARGE_MODEL_TIERED                 = 'Tiered';
    public static final String ZCHARGE_MODEL_DISCOUNT_FIXED_AMOUNT  = 'Discount-Fixed Amount';
    public static final String ZCHARGE_MODEL_DISCOUNT_PERCENTAGE    = 'Discount-Percentage';
    public static final String TERM_TYPE = 'TERMED';
    public static final Integer INVOICE_PREVIEW_TERM = 12;
    public static final Integer SUBSCRIPTION_TERM = 12;

    public static Zuora.zApi zconnection{
        
        get {
            System.debug('aqui zconnection ' + zconnection);
            if (zconnection == null){
                zconnection = new Zuora.zApi(); 
                zconnection.zlogin();
            }
            System.debug('### get zconnection ' + zconnection);
            return zconnection;
        }
        set {
            zconnection = value;
            System.debug('### set zconnection ' + zconnection);
        }

    }

	public static List<Zuora.zObject> zquery(String zoql, String ztype, Integer nb) 
	{
        List<Zuora.zObject> zobjects = (Test.isRunningTest()) ? TestDataGenerator.generateZObjects(nb, ztype) : zconnection.zquery(zoql);
        return zobjects;
	}

	public static List<Zuora.zApi.SaveResult> zcreate(List<Zuora.zObject> zobjects,  Boolean calloptions) 
	{  system.debug('### zcreate zobjects :: '+zobjects);
    	List<Zuora.zApi.SaveResult> results = (Test.isRunningTest()) ? TestDataGenerator.generateSaveResults(zobjects, 'create') : zconnection.zcreate(zobjects, calloptions);
    	system.debug('### results zcreate :: ' + results);
        return results;
	}

	public static List<Zuora.zApi.SaveResult> zupdate(List<Zuora.zObject> zobjects) 
	{system.debug('### zupdate zobjects :: '+zobjects);

    	List<Zuora.zApi.SaveResult> results = (Test.isRunningTest()) ? TestDataGenerator.generateSaveResults(zobjects, 'update') : zconnection.zupdate(zobjects); 
    	system.debug('### results zupdate :: ' + results);
        return results;
	}

    public static List<Zuora.zApi.SubscribeResult> zsubscribe(List<Zuora.zApi.SubscribeRequest> requests)
    {   system.debug('### zsubscribe requests :: '+requests);
        List<Zuora.zApi.SubscribeResult> results = (Test.isRunningTest()) ? TestDataGenerator.generateSubscribeResults(requests) :  zconnection.zsubscribe(requests);
        system.debug('### results zsubscribe :: ' + results);
        return results;
    }

    public static List<Zuora.zApi.DeleteResult> zdelete(String ztype, String[] ids)
    {   system.debug('### zdelete :: '+ztype+' - '+ids);
        List<Zuora.zApi.DeleteResult> results = (Test.isRunningTest()) ? TestDataGenerator.generateDeleteResults(ids) :  zconnection.zdelete(ztype,ids);
        system.debug('### results ztype :: ' + ztype);
        system.debug('### results ids :: ' + ids);
        system.debug('### results zdelete :: ' + results);
        return results;
    }

    public static List<Zuora.zObject> getPaymentMethodsFromZuora(String zuoraAccountId) {
        String zoql = 'select Id,NumConsecutiveFailures,Active,PaymentMethodStatus,Name,CreditCardAddress1,CreditCardAddress2,CreditCardCity,CreditCardCountry,CreditCardExpirationMonth,CreditCardExpirationYear,CreditCardHolderName,CreditCardMaskNumber,CreditCardType,LastTransactionStatus,LastTransactionDateTime,Type from PaymentMethod where PaymentMethodStatus=\'Active\' and AccountId = \'' + zuoraAccountId + '\'';
        if (String.isNotBlank(zuoraAccountId)) 
        {
            try{return (Test.isRunningTest())? TestDataGenerator.generatePaymentMethods(zuoraAccountId,1) : zconnection.zquery(zoql);}
            catch(Exception ex){throw new IECApplicationException('Could not retreive Payment Methods for accountId ' + zuoraAccountId + '. Error: ' + ex.getMessage());}
        }
        else return null;
    }

    public static List<Zuora.zObject> getPaymentMethodDetails(String paymentId) {
        String zoql = 'select Id,NumConsecutiveFailures,Active,PaymentMethodStatus,Name,CreditCardAddress1,CreditCardAddress2,CreditCardCity,CreditCardCountry,CreditCardExpirationMonth,CreditCardExpirationYear,CreditCardHolderName,CreditCardMaskNumber,CreditCardType,LastTransactionStatus,LastTransactionDateTime,Type from PaymentMethod where PaymentMethodStatus=\'Active\' and Id = \'' + paymentId + '\'';
        if (String.isNotBlank(paymentId)) 
        {
            try{
                return Test.isRunningTest() ? TestDataGenerator.generatePaymentMethodDetails(paymentId) : zconnection.zquery(zoql);
            }catch(Exception ex){
                throw new IECApplicationException('Could not retreive Payment Method details for id ' + paymentId + '. Error: ' + ex.getMessage());}
        }
        else return null;
    }

    //Generate Zuora default payment method
    public static void getDefaultPaymentMethod(){
        List<String> pm = new List<String>();
        pm.add('Bank Transfer');pm.add('Other');
        pm.add('ACH');pm.add('Check');

        List<String> whereItems = new List<String>();
        for(String i: pm)
            whereItems.add('name = \'' + i + '\'');

        String query = 'select id,Name from paymentmethod where ' + String.join(whereItems, ' OR ');
        List<Zuora.zObject> lstPayments = (!Test.isRunningTest())? IECZuoraHelper.queryApiCall(query): TestDataGenerator.generatePaymentMethods(pm);
        
        for(Zuora.zObject p : lstPayments){
            String id = (String)p.getValue('Id');
            String name = (String)p.getValue('Name');
            System.debug('Name : ' + name + ' +++ Id : ' + id );
        }   
    }

    //createZuoraBillToContact 
    public static Zuora.zObject createZuoraBillToContact(Contact billTo){
       
        Zuora.zObject billToContact = new Zuora.zObject('Contact');

        if (billToContact != null) {
            billToContact.setValue('FirstName', billTo.FirstName);
            billToContact.setValue('LastName', billTo.LastName);
            billToContact.setValue('WorkEmail', billTo.BillTo_Location__r.Email__c);
            billToContact.setValue('WorkPhone', billTo.BillTo_Location__r.Phone__c);

            //*** Thai (2016-11-10) use ISO country code and ISO state code instead of name to mitigate the reject from Zuora
            billToContact.setValue('Country', (billTo.BillTo_Location__r.ISO_Country_Code__c == null ? billTo.BillTo_Location__r.ISO_Country_Name__c : billTo.BillTo_Location__r.ISO_Country_Code__c));
            billToContact.setValue('State', (billTo.BillTo_Location__r.ISO_State_Code_SAP__c == null ? billTo.BillTo_Location__r.ISO_State_Name__c : billTo.BillTo_Location__r.ISO_State_Code_SAP__c));
            billToContact.setValue('City', billTo.BillTo_Location__r.City__c);
            billToContact.setValue('PostalCode', billTo.BillTo_Location__r.ZipCode__c);
            billToContact.setValue('Address1', billTo.BillTo_Location__r.Street__c);
        }

        return billToContact;
    }

    //createZuoraSoldToContact
    public static Zuora.zObject createZuoraSoldToContact(Contact soldTo,Order order) {

        //*** Thai (2016-11-10) change the source of information from sold to contact and use ISO country code and ISO state code instead of name to mitigate the reject from Zuora
        Zuora.zObject soldToContact = new Zuora.zObject('Contact');
        if(soldTo != null){
            soldToContact.setValue('FirstName', soldTo.FirstName);
            soldToContact.setValue('LastName', soldTo.LastName);
            soldToContact.setValue('WorkEmail', soldTo.ShipTo_Location__r.Email__c);
            soldToContact.setValue('WorkPhone', soldTo.ShipTo_Location__r.Phone__c);

            soldToContact.setValue('Country', (soldTo.ShipTo_Location__r.ISO_Country_Code__c == null ? soldTo.ShipTo_Location__r.ISO_Country_Name__c : soldTo.ShipTo_Location__r.ISO_Country_Code__c));
            soldToContact.setValue('State', (soldTo.ShipTo_Location__r.ISO_State_Code_SAP__c == null ? soldTo.ShipTo_Location__r.ISO_State_Name__c : soldTo.ShipTo_Location__r.ISO_State_Code_SAP__c));
            soldToContact.setValue('City', soldTo.ShipTo_Location__r.City__c);
            soldToContact.setValue('PostalCode', soldTo.ShipTo_Location__r.ZipCode__c);
            soldToContact.setValue('Address1', soldTo.ShipTo_Location__r.Street__c);
        }
        return soldToContact;
    }

    //Wrapper to get the payment method base on the Zuora AccountId
    public class zAccountPaymentMethod{
        //public zAccountPaymentMethod(){}
        public String zAccountId{get;set;}
        public String zPaymentMethod{get;set;}
        public String zPaymentMethodName{get;set;}
    }


    /****************************************************************************************************
        Created by Thai 2016-04-14
            Validate if REST call in using anonymous user is from Zuora
    ****************************************************************************************************/
    public static Boolean isRESTCalledFromZuora(String requestIPAddress, Map<String, String> requestHeader)
    {
        Boolean isFromZuora = false;
        try
        {
            String strZuoraIP = (',' + Utility.getSeqTextSetting('Zuora Outbound IP Address', ',') + ',').replace(' ', '');
            if (strZuoraIP.contains(',' + requestIPAddress + ','))
                isFromZuora = true;
            else
                for (String headerName : requestHeader.keySet())
                    //if (headerName == 'X-Salesforce-SIP')
                        if (strZuoraIP.contains(',' + requestHeader.get(headerName) + ','))
                        {
                            isFromZuora = true;
                            break;
                        }
        }
        catch (Exception e) {}

        return isFromZuora;
    } //*** end of "isRESTCalledFromZuora"
   
    public static List<Zuora.zObject> getCreditCardsByAccountZId(String zuoraAccountZId) {
        try {
            List<Zuora.zObject> creditCards = IECZuoraHelper.queryApiCall('select Id,Name,CreditCardType,CreditCardSecurityCode,CreditCardMaskNumber,CreditCardExpirationMonth,CreditCardExpirationYear,CreditCardHolderName,CreditCardCountry,CreditCardCity,CreditCardAddress1,CreditCardAddress2,CreditCardState,CreditCardPostalCode,LastTransactionStatus, Type from PaymentMethod where AccountId = \'' + zuoraAccountZId + '\' and Type =\'CreditCard\'');
            return creditCards;
        }
        catch (Exception e) {throw new IECApplicationException('Could not retreive Credit Cards for account ' + zuoraAccountZId + '. Error: ' + e.getMessage());}
    }

    public static Zuora.zObject getZuoraAccountBySFAccountId(Id sfAccountId, Id sfContactId) {

        String trimmedSFAccountId = (String)sfAccountId;
        if (trimmedSFAccountId.length() > 15)
            trimmedSFAccountId = trimmedSFAccountId.substring(0, 15);

        String zoql = 'select Id,AccountNumber,BillToId,DefaultPaymentMethodId,Name,SoldToId,Status from Account where CrmId = \'' + trimmedSFAccountId + '\' and CRMContactID__c = \'' + sfContactId + '\'';

        List<Zuora.zObject> accountResult =  zquery(zoql,'Account',1);
        //queryApiCall('select Id,AccountNumber,BillToId,DefaultPaymentMethodId,Name,SoldToId,Status from Account where CrmId = \'' + trimmedSFAccountId + '\' and CRMContactID__c = \'' + sfContactId + '\'');
        if (accountResult == null || accountResult.size() == 0) return null;
        return accountResult.get(0);
    }


}