public class CNS_Payment {

	public Contact con {
		get;
		private set;
	}
	public String communityName {
		get;
		private set;
	}
	public String InvoiceNumber {
		get;
		set;
	}
	public String Amount {
		get;
		set;
	}
	public string ServiceType {
		get;
		set;
	}
	public Map < String,
		String > cyberSrcData {
			get;
			set;
		}

	private String sharedSecret = label.Cybersource_SecurityKey_USD;
	private String profile_id = label.Cybersource_ProfileId_USD;
	private String access_key = label.Cybersource_AccessKey_USD;

	public String calculatedSignature {
		get {
			return machash(buildDataToSign(), sharedSecret);
		}
		set;
	}

	private String machash(String value, String key) {

		return EncodingUtil.base64Encode(Crypto.generateMac('HMacSHA256', Blob.valueOf(value), Blob.valueOf(key)));
	}

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
		Amount = '';
		InvoiceNumber = '';
		ServiceType = '';
		fillCyberSrcData();
	}

	public void fillCyberSrcData() {
		cyberSrcData = new Map < String,
			String > ();

		cyberSrcData.put('profile_id', profile_id);
		cyberSrcData.put('access_key', access_key);
		cyberSrcData.put('signed_date_time', DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
		cyberSrcData.put('transaction_uuid', String.ValueOf(con.Id) + DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
		cyberSrcData.put('currency', 'usd');
		cyberSrcData.put('amount', Amount);
		cyberSrcData.put('reference_number', InvoiceNumber);
		System.debug('fillCyberSrcData' + cyberSrcData);

		// hardcoded values
		cyberSrcData.put('transaction_type', 'sale');
		cyberSrcData.put('locale', 'en');
		cyberSrcData.put('signed_field_names', 'access_key,profile_id,transaction_uuid,signed_field_names,unsigned_field_names,signed_date_time,locale,transaction_type,reference_number,amount,currency');
		//cyberSrcData.put('bill_to_forename', con.FirstName);
		//cyberSrcData.put('bill_to_surname', con.LastName);
		cyberSrcData.put('unsigned_field_names', 'merchant_defined_data1');

		// merchant defined fields
		cyberSrcData.put('merchant_defined_data1', ServiceType);

	}
}