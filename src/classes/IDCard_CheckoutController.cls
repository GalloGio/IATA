public without sharing class IDCard_CheckoutController extends IDCardAbstractController {

		public String Language {get; set;}

		public String Tax1 {get;set;}
		public String Tax1Value {get;set;}
		public String Tax2 {get;set;}
		public String Tax2Value {get;set;}

		public String amount {get;set;}
		public String curr {get;set;}
		public String orderNumber {get;set;}
		public String billToFirstName {get;set;}
		public String billToLastName {get;set;}

		public Map<String,String> cyberSrcData {get; set;}

		public String accountName {get;set;}
		public String accountIATACode {get;set;}
		public String accountState {get;set;}
		public String description {get;set;}
		public String orderPage_transactionType {get; set;}
		public String merchantID {get; set;}
		public String orderPage_timestamp {get; set;}
		public String orderPage_version {get; set;}
		public String orderPage_serialNumber {get; set;}
		public string idCardFee {get; set;}

		public Double vatPrice {get; set;}

		public string itdiCourseFee {get; set;}
		public string expediteDeliveryFee {get; set;}
		public string itdiSelCourseNames {get; set;}
		public string agencyCountryCode {get; set;}
		public String profitCenter{get; set;}
		public Boolean CanPayByCheque {get;set;}

		public ID_Card_Application__c idCardApplication {get; private set;}

		public string applicationId {get; set;}

		private String accountType;

		private Account theAccount;

		private String sharedSecret;
		private String profile_id;
		private String access_key;

		public String calculatedSignature {
				get{
						return machash(buildDataToSign(), sharedSecret);
				} set;}


		public String confirmationString {
				get {
						if (idCardApplication != null) {
								if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_NEW)
										return Label.IDCard_CheckoutPage_Message_NewApplication;
								else if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE)
										return Label.IDCard_CheckoutPage_Message_ReplaceApplication;
								else if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_RENEWAL)
										return Label.IDCard_CheckoutPage_Message_RenewApplication;
								else if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REPLACEMENT)
										return Label.IDCard_CheckoutPage_Message_ChangeApplication;
								else
										return '';
						}
						else
								return '';
				}
		}

		public Boolean IsExpediteDeliveryAddedtoIDCardPrice {
				get {

								IATA_ISO_Country__c contactCountry = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(theAccount.BillingCountry)[0];
								Price_Table__c[] listPriceTables = [Select p.Expedite_Delivery_added_to_IDCard_Price__c From Price_Table__c p where p.Type_Class_of_Agent__c = :accountType and p.ISO_Country__r.Id = :contactCountry.Id];
								if (listPriceTables == null || listPriceTables.size() == 0) {
										throw new IDCardApplicationException(String.Format(Label.IDCard_No_Price_Table_Found, new String[] {'<i>' + contactCountry.ISO_Code__c + '</i>', '<i>' + accountType + '</i>'}));
								}
								else
										return listPriceTables[0].Expedite_Delivery_added_to_IDCard_Price__c;

				}
		}

			public boolean displayPopup {get; set;}

		/**
		 * Constructor
		 */
		public IDCard_CheckoutController() {
				initialize();
				CanPayByCheque= false;

				try {
						// retreive ID Card Application from URL param
						if (System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPID) == null)
								throw new IDCardApplicationException('Missing parameter ' + IDCardUtil.PARAM_APPID);
						applicationId = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPID));

						// retreive error msg if any (coming from CheckoutConfirmation)
						if (System.currentPageReference().getParameters().get(IDCardUtil.PARAM_ERRMSG) != null) {
								String errMsg = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_ERRMSG));
								ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
						}

						try {

							idCardApplication = IDCardUtilWithoutSharing.retrieveCommittedICA(applicationId);
							
							System.debug('****************************************************** IDCard Fees ' + idCardApplication.ITDI_Courses_Fee__c);

							Account a = [ Select BillingState, BillingCountry from Account where IATACode__c =: idCardApplication.IATA_Code__c limit 1];

							Map<String,String> taxes =  IDCardTaxUtil.GetTaxes(a.BillingState,a.BillingCountry);
							if(taxes.keySet().Size()==1){
										vatPrice = Double.valueOf(Decimal.valueOf(Double.valueOf(idCardApplication.Tax_1_Value__c.split(' ', 0)[0])).setScale(2));

							}else if(taxes.keySet().Size()==2){
										vatPrice = Double.valueOf(Decimal.valueOf(Double.valueOf(idCardApplication.Tax_1_Value__c.split(' ', 0)[0])).setScale(2) +
															Decimal.valueOf(Double.valueOf(idCardApplication.Tax_2_Value__c.split(' ', 0)[0])).setScale(2));

								}
						}
						catch (Exception ex) {
								throw new IDCardApplicationException(Label.IDCard_IDCardAppNotFound);
						}
						// get related Account
						theAccount = [Select a.BillingCountry,a.type, a.ShippingState, a.Name From Account a where a.IATACode__c = :idCardApplication.IATA_Code__c limit 1];



						 ////Checks if User can pay by Cheque
						 // Map the account agent type to the Price Table agent type
						 accountType = IDCardUtil.GetAgentTypeFromAccountType(theAccount.type);
						 IATA_ISO_Country__c contactCountry =  IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(theAccount.BillingCountry)[0];
						 Price_Table__c[] listPriceTables = [Select p.Can_Pay_by_Cheque__c, p.CurrencyIsoCode, p.Profit_Center__c From Price_Table__c p where p.Type_Class_of_Agent__c = :accountType and p.ISO_Country__r.Id = :contactCountry.Id];
						 CanPayByCheque = listPriceTables[0].Can_Pay_by_Cheque__c;
						 if (listPriceTables[0].Profit_Center__c != null && listPriceTables[0].Profit_Center__c != '')
								profitCenter = listPriceTables[0].Profit_Center__c;
						 else
								profitCenter = '';



						// set application and account values
						Double d = idCardApplication.Applicable_Fee__c;
						if(d == null || d < 0 || d == 0)
								amount =  '0.00';
						else amount = String.valueOf(idCardApplication.Applicable_Fee__c);

 
						//####set ISO Country name as part of order name:
						//this is a workaround for SAP since their logic was built on wrong assumption
						// order number must have ID+ISOCode as a prefix
						//remove IDCA- from the idCardApplication.Name
						orderNumber = 'ID'+contactCountry.ISO_Code__c + '-'+ IDCardUtilWithoutSharing.ICAName.substring(5, IDCardUtilWithoutSharing.ICAName.length());




						billToFirstName = idCardApplication.First_Name__c;
						billToLastName = idCardApplication.Last_Name__c;
						accountName = theAccount.Name;
						accountIATACode = idCardApplication.IATA_Code__c;
						accountState = theAccount.ShippingState;
						curr = idCardApplication.CurrencyIsoCode;
						idCardFee = String.valueOf(idCardApplication.ID_Card_Fee__c);
						itdiCourseFee = String.valueOf(idCardApplication.ITDI_Courses_Fee__c);
						expediteDeliveryFee = String.valueOf(idCardApplication.IDCard_Expedite_Delivery_Fee__c);
						itdiSelCourseNames = '#1: ' + idCardApplication.Package_of_Travel_Professionals_Course_1__c + ' - #2: ' + idCardApplication.Package_of_Travel_Professionals_Course_2__c;
						agencyCountryCode = contactCountry.ISO_Code__c;

						// set description
						if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_NEW)
								description = 'ID Card - New application';
						else if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE)
								description = 'ID Card - Reissue';
						else if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_RENEWAL)
								description = 'ID Card - Renewal';
						else if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REPLACEMENT)
								description = 'ID Card - Replacement';

						if(listPriceTables[0].CurrencyIsoCode == 'CAD')
						{
								//CAD
								profile_id = label.Cybersource_ProfileId;
								access_key = label.Cybersource_AccessKey;
								sharedSecret = label.Cybersource_SecurityKey;
						}
						else
						{
								// USD
								profile_id = label.Cybersource_ProfileId_USD;
								access_key = label.Cybersource_AccessKey_USD;
								sharedSecret = label.Cybersource_SecurityKey_USD;
						}

						// set Cybersource fields
						fillCyberSrcData();

						orderPage_version = '7';

				}
				catch (Exception ex) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
				}
		}




		public void closePopup() {
				displayPopup = false;
		}
		public void showPopup() {
				displayPopup = true;
		}


		private String machash(String value, String key) {
				//return EncodingUtil.base64Encode(Crypto.generateMac('HMacSHA1', Blob.valueOf(value), Blob.valueOf(key)));
				return EncodingUtil.base64Encode(Crypto.generateMac('HMacSHA256', Blob.valueOf(value), Blob.valueOf(key)));
		}

		private String buildDataToSign() {
				String dataToSign = '';

				List<String> signedFieldNames = String.valueOf(cyberSrcData.get('signed_field_names')).split(',');

				for (String signedFieldName : signedFieldNames) {
						dataToSign += (dataToSign == '' ? '' : ',') + signedFieldName + '=' + String.valueOf(cyberSrcData.get(signedFieldName));
				}

				return dataToSign;
		}

		public Pagereference buyNow() {
				try {
						showPopup();
						orderPage_timestamp = String.valueOf(System.currentTimeMillis());
						//String theData = merchantID + amount + curr + orderPage_timestamp + orderPage_transactionType;
						calculatedSignature = machash(buildDataToSign(), sharedSecret);
						// Update idCardApplication__c with the profit center information
						idCardApplication.Profit_Center__c = profitCenter;
						//update idCardApplication;
						IDCardUtilWithoutSharing.saveCommittedICA(idCardApplication, ApplicationID);
						return null;
				}
				catch (Exception ex) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
						return null;
				}
		}

		private void fillCyberSrcData() {
				cyberSrcData = new Map<String,String>();

				cyberSrcData.put('profile_id', profile_id);
				cyberSrcData.put('access_key', access_key);
				cyberSrcData.put('signed_date_time', DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
				cyberSrcData.put('transaction_uuid', String.ValueOf(applicationId) + DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
				cyberSrcData.put('currency', curr);
				cyberSrcData.put('amount', amount);
				cyberSrcData.put('reference_number', orderNumber);

				// hardcoded values
				cyberSrcData.put('transaction_type', 'sale');
				cyberSrcData.put('locale', 'en');
				cyberSrcData.put('signed_field_names', 'access_key,profile_id,transaction_uuid,signed_field_names,unsigned_field_names,signed_date_time,locale,transaction_type,reference_number,amount,currency');
				cyberSrcData.put('unsigned_field_names', 'bill_to_forename,bill_to_surname,merchant_defined_data1,merchant_defined_data2,merchant_defined_data3,merchant_defined_data4,merchant_defined_data5,merchant_defined_data6,merchant_defined_data8,merchant_defined_data9,merchant_defined_data11,merchant_defined_data12,merchant_defined_data13,merchant_defined_data14');
				//,merchant_defined_data7,merchant_defined_data10

				// merchant defined fields
				cyberSrcData.put('bill_to_forename', billToFirstName != null ? billToFirstName : '');
				cyberSrcData.put('bill_to_surname', billToLastName != null ? billToLastName : '');
				cyberSrcData.put('merchant_defined_data1', accountName != null ? accountName : '');
				cyberSrcData.put('merchant_defined_data2', accountIATACode != null ? accountIATACode : '');
				cyberSrcData.put('merchant_defined_data3', accountState != null ? accountState : '');
				cyberSrcData.put('merchant_defined_data4', description != null ? description : '');
				cyberSrcData.put('merchant_defined_data5', idCardFee != null ? idCardFee : '');
				cyberSrcData.put('merchant_defined_data6', itdiCourseFee != null ? itdiCourseFee : '');
				//cyberSrcData.put('merchant_defined_data7', expediteDeliveryFee != null ? expediteDeliveryFee : '');
				cyberSrcData.put('merchant_defined_data8', itdiSelCourseNames != null ? itdiSelCourseNames : '');
				cyberSrcData.put('merchant_defined_data9', agencyCountryCode != null ? agencyCountryCode : '');
				//cyberSrcData.put('merchant_defined_data10', profitCenter != null ? profitCenter : '');
				cyberSrcData.put('merchant_defined_data11', Tax1 != null ? Tax1 : '');
				cyberSrcData.put('merchant_defined_data12', Tax1Value != null ? Tax1Value : '');
				cyberSrcData.put('merchant_defined_data13', Tax2 != null ? Tax2 : '');
				cyberSrcData.put('merchant_defined_data14', Tax2Value != null ? Tax2Value : '');

		}

		public Pagereference payByCheque(){

			Pagereference confPage = Page.IDCard_CheckoutConfirmation;

		 //set param to show that its a payment by cheque
		 String temp = CanPayByCheque+'';
		 confPage.getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE,IDCardUtil.EncryptEncodeParameter(temp));
		 confPage.getParameters().put('req_reference_number',IDCardUtilWithoutSharing.ICAName);
		 //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, idCardApplication.Name));

		 // Update idCardApplication__c with the profit center information
		 idCardApplication.Profit_Center__c = profitCenter;
		 //update idCardApplication;
		 IDCardUtilWithoutSharing.saveCommittedICA(idCardApplication, ApplicationId);
		 return confPage;


		}


		public Pagereference freeOrder(){

			Pagereference confPage = Page.IDCard_CheckoutConfirmation;

		 //set param to show that its a payment by cheque
		 String temp = amount;
		 confPage.getParameters().put(IDCardUtil.ISFOC,IDCardUtil.EncryptEncodeParameter(temp));
		 confPage.getParameters().put('req_reference_number',IDCardUtilWithoutSharing.ICAName);
		 //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, idCardApplication.Name));

		 // Update idCardApplication__c with the profit center information
		 idCardApplication.Profit_Center__c = profitCenter;
		 //update idCardApplication;
		 IDCardUtilWithoutSharing.saveCommittedICA(idCardApplication, applicationId);
		 return confPage;


		}

		public Pagereference back() {

						Pagereference confPage;
						if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE|| idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_RENEWAL)
						{
								confPage = Page.IDCard_ApplicationForm_RR;
								confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(idCardApplication.VER_Number__c));
						}
						else
						{
								confPage = Page.IDCard_ApplicationForm_NR;
								if(idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REPLACEMENT)
										confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(idCardApplication.VER_Number__c));
						}
						confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(idCardApplication.IATA_Code__c));
						confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(idCardApplication.Type_of_application__c));

						confPage.getParameters().put(IDCardUtil.PAGE_PART,IDCardUtil.EncryptEncodeParameter('3'));
						confPage.getParameters().put(IDCardUtil.PARAM_APPID,IDCardUtil.EncryptEncodeParameter(applicationID));
						confPage.setRedirect(true);
						return confPage;

	 }

	/*
	 public String getAmount(){
				Double d = Double.valueOf(amount);
				if(d<0 || d==0)
						return '0.0';
				return amount;
	 }
		*/
}
