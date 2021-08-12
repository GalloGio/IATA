public class CNS_Payment {

    public Contact con {
        get;
        private set;
    }
    public String communityName {
        get;
        private set;
    }
    public String invoiceNumber {
        get;
        set;
    }
    public String amount {
        get;
        set;
    }
    public string serviceType {
        get;
        set;
    }
    public string security_key {
        get;
        set;
    }
    public string profile_id {
        get;
        set;
    }
    public string access_key {
        get;
        set;
    }
    public string url {
        get;
        set;
    }
    public Map < String,
        String > cyberSrcData {
            get;
            set;
        }

    public String calculatedSignature {
        get {
            return machash(buildDataToSign(), security_key);
        }
        set;
    }

    @TestVisible
    private String machash(String value, String key) {

        return EncodingUtil.base64Encode(Crypto.generateMac('HMacSHA256', Blob.valueOf(value), Blob.valueOf(key)));
    }

    @TestVisible
    private String buildDataToSign() {
        String dataToSign = '';

        List < String > signedFieldNames = String.valueOf(cyberSrcData.get('signed_field_names')).split(',');

        for (String signedFieldName: signedFieldNames) {
            dataToSign += (dataToSign == '' ? '' : ',') + signedFieldName + '=' + String.valueOf(cyberSrcData.get(signedFieldName));
        }

        return dataToSign;
    }

    public List < Selectoption > getListServiceType() {
        List < Selectoption > sOption = new List < selectoption > ();
        sOption.add(new selectOption('', '- None -'));
        sOption.add(new selectOption('CNS Fees', 'CNS Fees'));
        sOption.add(new selectOption('Endorsement Fees', 'Endorsement Fees'));
        sOption.add(new selectOption('Other', 'Other'));
        return sOption;
    }

    public CNS_Payment() {
        User u = [select Id, Name, Contact.Id, Contact.Account.IATACode__c, Contact.CNS_Contact__c from User where Id =: UserInfo.getUserId()];
        con = [select Id, FirstName, LastName, Email, Account.Name, Account.Country_ISO_Code__c, Account.IATACode__c, Contact.CNS_Contact__c from Contact where Id =: u.Contact.Id];
        this.communityName = 'IATA';
        if (u.Contact.CNS_Contact__c) this.communityName = 'CNS';
        amount = '';
        invoiceNumber = '';
        serviceType = '';
        getCyberSourceParameters();
        fillCyberSrcData();
    }

    public void getCyberSourceParameters() {

        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        CNS_Payment__c cs = [select Name, PROD_AccessKey__c, PROD_ProfileId__c, PROD_SecurityKey__c, PROD_SecurityKey_2__c, PROD_URL__c,
            QA_AccessKey__c, QA_ProfileId__c, QA_SecurityKey__c, QA_SecurityKey_2__c, QA_URL__c from CNS_Payment__c limit 1
        ];
        if (runningInASandbox) {
            security_key = cs.QA_SecurityKey__c + cs.QA_SecurityKey_2__c;
            profile_id = cs.QA_ProfileId__c;
            access_key = cs.QA_AccessKey__c;
            url = cs.QA_URL__c;
        } else {
            security_key = cs.PROD_SecurityKey__c + cs.PROD_SecurityKey_2__c;
            profile_id = cs.PROD_ProfileId__c;
            access_key = cs.PROD_AccessKey__c;
            url = cs.PROD_URL__c;
        }
    }
    public void fillCyberSrcData() {
        cyberSrcData = new Map < String,
            String > ();

        cyberSrcData.put('profile_id', profile_id);
        cyberSrcData.put('access_key', access_key);
        cyberSrcData.put('signed_date_time', DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT'));
        cyberSrcData.put('transaction_uuid', String.ValueOf(con.Id) + DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT'));
        cyberSrcData.put('currency', 'usd');
        cyberSrcData.put('amount', amount);
        cyberSrcData.put('reference_number', invoiceNumber);

        // hardcoded values
        cyberSrcData.put('transaction_type', 'sale');
        cyberSrcData.put('locale', 'en');
        cyberSrcData.put('signed_field_names', 'access_key,profile_id,transaction_uuid,signed_field_names,unsigned_field_names,signed_date_time,locale,transaction_type,reference_number,amount,currency');
        //cyberSrcData.put('bill_to_forename', con.FirstName);
        //cyberSrcData.put('bill_to_surname', con.LastName);
        cyberSrcData.put('unsigned_field_names', 'merchant_defined_data1');

        // merchant defined fields
        cyberSrcData.put('merchant_defined_data1', serviceType);
	}
	
}