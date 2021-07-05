/**

This controller is used on ID CArd Manageöent part to manage Pending Mass operation.

It is based on List of application for current account
*/
global without sharing class IDCard_AdmPendingOpsController extends IDCardAbstractController {

	/**
	List of pneding operation:
	Mass_order_application__c = null and recordTypeId =Single
	 and IATA_code__c = currentIATACode and Application_Status__c = 'Pending'
	*/
	public Promotion__c promotion {get; set;}
	public map<integer, ApplicationWrapper> mapAppWrap	{get; set;}

	private map<integer, id> mapAppID;

	public class ApplicationWrapper{
		public string appCounter {get;set;}
		public string AppName {get; set;}
		public id appId	{get;set;}
		public ID_Card_Application__c ICA {get;set;}
		public string appStatus {get; set;} //DoNothing, Validate, Unvalidate

		public contact AppContact {get; set;}
		public string ContactVerNum	{get; set;}

		public boolean IsApplicationValid	{get; set;}

		private list<string> lsFields = TransformationHelper.selectAllWritableFieldsByCurrentUser('ID_Card_Application__c');

		public ApplicationWrapper(integer appCounter, ID_Card_Application__c app){
			if(!this.lsFields.contains('RecordTypeId')) lsFields.add('recordtypeId');

			this.appCounter = string.valueOf(appCounter);
			ID_Card_Application__c WrapICA = new ID_Card_Application__c();
			for(string field:lsFields)
				WrapICA.put(field, app.get(field));
			
			this.ICA = WrapICA;
			this.AppName = app.Name;
			this.appId = app.Id;
			this.appStatus = 'doNothing';

			if (!Test.isRunningtest() && app.Photo__c == null || app.Photo__c == '')    this.IsApplicationValid=false;
			else this.isApplicationValid = true;
		}
	}
	/**
	Contact informaetion per pending applicatioj
	*/
	public Map<String, ContactProxy> contactsPerApplication {get; set;}

	private String ccurrency = null;


	/**
	applciation list whcih shluldbe processed
	*/
	public set<integer> setValidApplicationId {get;set;}

	/**
	Pending application whcich should be rejected
	*/
	public set<integer> setRejectedApplicationId {get;set;}

	/*
	Global and calculated var priunted on page

	*/

	public Map<String, Decimal> discountPerKeyAccount {get; set;}
	private Map<String, Account> taxesPerKeyAccount;

	public String appsCurrency  {get; set;}
	public Double tPrice  {get; set;}
	public Double vatPrice  {get; set;}
	public Double deliveryPrice  {get; set;}
	public Integer rejectedSize  {get; set;}
	public Double expediteFees  {get; set;}
	public Double idCardFee {get; set;}
	public Double coursesFee {get; set;}
	public Double discountFee {get; set;}
	public String promotionCode {get; set;}

	private double massAppDeliveryFee = 0;

	public Map<String, String> cyberSrcData {get; set;}

	/** use for filtering */
	private Id singeAppRT = null;

	/* information for each pending information*/

	public Map<String, Boolean> isNotDigitalOnly {get; set;}

	public List<SelectOption> cardTypeList {
		get {
			if (cardTypeList == null) {
				cardTypeList = new List<SelectOption>{};
				cardTypeList.add(new SelectOption('digital', Label.IDCard_CardType_DigCard));
				cardTypeList.add(new SelectOption('plastic', Label.IDCard_CardType_PhysCard));
			}
			return cardTypeList;
		}
		private set;
	}

	/*selected payment mode*/
	public String paymentMode  {get; set;}

	/**for payment*/
	private String orderNumber = null;

	/** Signature for the payment form**/
	public String calculatedSignature {get; set;}

	public boolean selectAll {get; set;}

	/** vars used for mexpedite fees.**/
	public boolean fastExpedition {get; set{
			fastExpedition = false;
		}
	}

	public Map<String, IATA_ISO_Country__c> countriesPerIATACode = new Map<String, IATA_ISO_Country__c>();

	public Map<String, String> countriesPerIATACode2 = new Map<String, String>();

	public boolean IsExpediteAvailable {get; set;}

	private  Map<String, Price_Table__c > pricePerCountry = null;

	private  Map<String, String> accountTypesPerIATACode = new Map<String, String>();

	public Map<String, Promotion__c> mapPromotion {get; set;}

	/*Constructor*/
	public IDCard_AdmPendingOpsController() {
		initialize(true);
		mapPromotion = new Map<String, Promotion__c>();
		List<Promotion__c> listPromotion = [Select Promotion_Value__c, Promotion_Duration_Valid_Up_to__c, Promotion_Duration_Valid_From__c, Promotion_Code__c, Type_of_Application__c From Promotion__c LIMIT 50000];
		for(Promotion__c p : listPromotion) {
			mapPromotion.put(p.Promotion_Code__c, p);
		}
		selectall = false;
		//init vars
		appsCurrency = '-';
		vatPrice = 0;
		tPrice = 0;
		rejectedSize = 0;
		deliveryPrice = 0;
		expediteFees = 0;
		idCardFee = 0;
		coursesFee = 0;
		discountFee = 0;
		cyberSrcData = null;
		fastExpedition =  false;
		cyberSrcData = new Map<String, String>();
		promotion = new Promotion__c();
		setRejectedApplicationId = new Set<Integer>();
		setValidApplicationId = new Set<Integer>();
		contactsPerApplication = new Map<String, ContactProxy>();
		isNotDigitalOnly = new Map<String, Boolean>();
		discountPerKeyAccount = new Map<String, Decimal>();
		taxesPerKeyAccount = new Map<String, Account>();
		mapAppID = new map<integer, id>();
		mapAppWrap = new map<integer, ApplicationWrapper>();
		Promotion__c validPromotion = null;
		singeAppRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');

		system.debug('[IDCard_AdmPendingOpsController] LOAD LIST');
		try {
			if (keyContactAndDelegateForAccountList.keySet().size() > 0)
				loadList();
			else
				mustRedirect = true;
		} catch (Exception ex) {
			system.debug('[ERROR] ' + ex.getStackTraceString());
			throw ex;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage() ));
		}
	}

	/*Initialize lsit of pendoing application*/
	private  void  loadList() {

		//clear exsiting
		mapAppWrap.clear();
		contactsPerApplication.clear();
		setRejectedApplicationId.clear();
		setValidApplicationId.clear();

		system.debug('[IDCard_AdmPendingOpsController]load list');

		String iataCodeSubstring = '';
		boolean b = false;
		for (String aCode : keyContactAndDelegateForAccountList.keySet()) {
			iataCodeSubstring = iataCodeSubstring + (b ? ' or IATA_code__c = ' : ' IATA_code__c = ') + ' \'' + aCode + '\' ';
			b = true;
		}

		for(Account acc : [SELECT Id, IATACode__c, RecordTypeId, ID_Card_Key_Account_Discount__c, BillingCountry, BillingState FROM Account WHERE IATACode__c in :keyContactAndDelegateForAccountList.keySet()]){
			discountPerKeyAccount.put(acc.IATACode__c, acc.ID_Card_Key_Account_Discount__c);
			if(acc.RecordTypeId == AMS_Utils.RECTYPE_IATAAGENCY){
				taxesPerKeyAccount.put(acc.IATACode__c, acc);
			}
		}
		

		system.debug('[IDCard_AdmPendingOpsController]load list iataCodeSubstring=' + iataCodeSubstring);
		string IdCardApplicationQuery = 'SELECT ' + TransformationHelper.getAllFields(Schema.SObjectType.ID_Card_Application__c.fields.getMap()) +
										'  FROM ID_Card_Application__c  ' +
										'  WHERE Mass_order_application__c = null and recordTypeId = \'' + singeAppRT + '\'' +
										' and (' + iataCodeSubstring + ') and Application_Status__c = \'Pending\' ';


		Set<String> iataCodes = new Set<String>();
		Map<String, ID_Card_Application__c> tmpMap = new Map<String, ID_Card_Application__c>();

		for(ID_Card_Application__c app:database.query(IdCardApplicationQuery)){
			iataCodes.add(app.IATA_Code__C);
			
			integer appCounter = mapAppWrap.size()+1;

			mapAppID.put(appCounter, app.Id);
			mapAppWrap.put(appCounter, new ApplicationWrapper(appCounter, app));
			

			if (app.Ver_Number__c != null) {
				tmpMap.put(app.Ver_Number__c, app);
			} else {
				system.debug('[IDCard_AdmPendingOpsController] nO VERNUM FOR APP ' + app.iD);
				contactsPerApplication.put(app.id, new ContactProxy(null, app));
			}
		}

		if (mapAppWrap.size() > 0) {
			List<Contact> contacts = [select Id, UIR__C, Salutation,  FirstName, LastName, Name,  Title, VER_Number_2__c, Email , AccountID,
									  IATA_Code__c, Date_of_Birth__c, Gender__c, Phone, Start_Date_Agency_Month__c, Hours_per_week__c,
									  Middle_Initial__c, Position__c, Start_Date_Agency_Year__c, Start_Date_Industry__c, Duties__c
									  from Contact where VER_Number_2__c in :tmpMap.keyset()];
			system.debug('[IDCard_AdmPendingOpsController]Contact found from applications :' + contacts.size());
			for (Contact c : contacts) {
				contactsPerApplication.put(tmpMap.get(c.VER_Number_2__c).id, new ContactProxy(c, tmpMap.get(c.VER_Number_2__c)));
			}

			for(integer i:mapAppWrap.keyset()){
				if (contactsPerApplication.get(mapAppWrap.get(i).appId) == null) {
					system.debug('[IDCard_AdmPendingOpsController] Warning  failed to find a contact for VERNUM ' + mapAppWrap.get(i).ICA.Ver_Number__c);
					contactsPerApplication.put(mapAppWrap.get(i).appId, new ContactProxy(null, mapAppWrap.get(i).ICA));
				}
			}
			system.debug('[IDCard_AdmPendingOpsController]returned contact per element ' + contactsPerApplication.size());
		} else {
			system.debug('[IDCard_AdmPendingOpsController]No applciaion returned returned');
		}

		//
		List<Account> accs = IdCArdUtil.GetAccountListFromIATACodes(iataCodes);
		system.debug('[PENDING FEE] Separated IATACode : ' + iataCodes.size());
		for (Account acc : accs) {

			system.debug('[PENDING FEE] find account for IATACode ' + acc.IATACode__C + '  ID :  ' + acc.Id + ' coutnry ' + acc.BillingCountry + ' TYPE: ' + acc.type);
			accountTypesPerIATACode.put(acc.IATACode__C, IDCardUtil.GetAgentTypeFromAccountType(acc.type));
			countriesPerIATACode2.put(acc.IATACode__C, acc.IATA_ISO_Country__c);
		}
		countriesPerIATACode = IDCarDUtil.GetIATAISOCountryFromAccounts(accs) ;

		pricePerCountry = new Map<String , Price_Table__c>();
		List<Price_Table__c> pts = [Select p.ID_Card_Fee__c, p.Expedite__c, p.Mass_Purchase_exp__c,  p.IATA_Package__c,  p.Type_Class_of_Agent__c , p.ISO_Country__c, p.ISO_Country__r.ISO_Code__c,p.Name, p.Cost_of_Printer__c From Price_Table__c p];
		for (Price_Table__c pt : pts) {
			system.debug('[MASS APP FEE] find record ofr mass feees: class: ' + pt.Type_Class_of_Agent__c + ' country id :' + pt.ISO_Country__c + ' fee: ' + pt.Mass_Purchase_exp__c);
			pricePerCountry.put(pt.ISO_Country__c+'-'+pt.Type_Class_of_Agent__c, pt);
		}

		for(integer i:mapAppWrap.keyset()){
			Price_Table__c priceTable = pricePerCountry.get(countriesPerIATACode2.get(mapAppWrap.get(i).ICA.IATA_Code__c)+'-'+accountTypesPerIATACode.get(mapAppWrap.get(i).ICA.IATA_Code__c));
			if(IDCard_MobileAppRenewalService.US_COUNTRY_ISO_CODES.contains(priceTable.ISO_Country__r.ISO_Code__c)){
				isNotDigitalOnly.put(mapAppWrap.get(i).appId, false);
			} else {
				isNotDigitalOnly.put(mapAppWrap.get(i).appId, true);
			}
		}

		calculateAllPrices();
	}
	/*
	Processing action:
		set status to rejected
		process as a mass update application
	*/
	public Pagereference createMassUpdateIdCardApplication() {
		//nothing selected
		cyberSrcData = new Map<String, String>()     ;
		if ((setValidApplicationId.size() + setRejectedApplicationId.size()) == 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.IDCard_Pending_Apps_Missing_Args));
			return null;
		}
		//unvalidate
		set<id> contact2deleteIids = new set<id>();
		set<id> setRejectAppIDToDelete = new set<id>();
		for(integer i:setRejectedApplicationId){
			ApplicationWrapper rejApp = mapAppWrap.get(i);
			//rejApp.ICA.Application_Status__c = 'Rejected';
			if (rejApp.ICA.VER_Number__c != null && rejApp.ICA.VER_Number__c.startsWith('Z')) {
				ContactProxy cp = contactsPerApplication.get(rejApp.appId);
				if (cp.verNum.startsWith('Z') && string.isNotBlank(cp.Id)){
					contact2deleteIids.add(cp.Id);
				}
			}
			setRejectAppIDToDelete.add(rejApp.appId);
		}
		if(!setRejectAppIDToDelete.isEmpty()) IDCardUtilWithoutSharing.deleteApplications(setRejectAppIDToDelete);

		// delete contact with tmp ver num too
		if (!contact2deleteIids.isEmpty()) IDCardUtilWithoutSharing.deleteContacts(contact2deleteIids);
		
		ID_Card_Application__c massUpdateApplication = null;
		if (setValidApplicationId.size() > 0) {
			if (paymentMode == null || paymentMode.equals( '')) {
				system.debug('[Mass creation] No payment information provided');
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.IDCard_Pending_Apps_Missing_Args));
				return null;
			}
			Account acc = [select Id, name, ShippingState, Type, ID_Card_KeyAccount_features__c, IATACode__c from Account where IATACode__c = :iataCodeParameter];
			/*
						List<Account> accs = [select Id, name,ShippingState, Type, ID_Card_KeyAccount_features__c,IATACode__c from Account where IATACode__c in :keyContactAndDelegateForAccountLis.keySet()];
			Map<String , Account> accountPerIataCode = new Map<String,Account>();
			for(Account a:accs)
				accountPerIataCodeput(a.IATACode__c, a);
			*/
			Contact currentContact = [select UIR__c, AccountId, Salutation, Id, FirstName, LastName, Name,  Title, VER_Number_2__c, Email ,
									  IATA_Code__c, Date_of_Birth__c, Gender__c, Phone, Start_Date_Agency_Month__c, Hours_per_week__c,
									  Middle_Initial__c, Position__c, Start_Date_Agency_Year__c, Start_Date_Industry__c, Duties__c, IDCard_Email__c
									  from Contact where Ver_Number_2__c = :vernumParameter limit 1];
			//switch account status will be paid by wire / check or by CB
			List<ID_Card_Application__c> tmpLst = new List<ID_Card_Application__c>();
			for(integer i:setValidApplicationId){
				ID_Card_Application__c tmpApp = mapAppWrap.get(i).ICA;
				//tmpApp.id = mapAppWrap.get(i).appId;
				tmpLst.add(tmpApp);
			}
			massUpdateApplication = IDCardApplicationFactory.createMassIDCardApplication(currentContact, tmpLst);
			for (ID_Card_Application__c idca : tmpLst) {
				if (idca != null)
					massUpdateApplication.CurrencyIsoCode = idca.CurrencyIsoCode;
					massUpdateApplication.ID_Card_Fee_Discount__c = discountFee;
					if(promotion.Promotion_Code__c != null && promotion.Promotion_Code__c != ''){
						massUpdateApplication.Promotion_Code__c = promotion.Promotion_Code__c;
					}
				break;
			}

			system.debug('[Mass creation] entering creation');
			insert massUpdateApplication ;

			string IdCardApplicationQuery = 'SELECT ' + TransformationHelper.getAllFields(Schema.SObjectType.ID_Card_Application__c.fields.getMap()) +
											'  FROM ID_Card_Application__c  ' +
											'  WHERE Id =  \'' + massUpdateApplication.Id + '\'';

			List<ID_Card_Application__c>tmpL = (list<ID_Card_Application__c>)(database.query(IdCardApplicationQuery));

			massUpdateApplication = tmpL[0];
			//apply specific mass app dfees
			if (massAppDeliveryFee > 0) {
				massUpdateApplication.IDCard_Expedite_Delivery_Fee__c = massAppDeliveryFee;
				massUpdateApplication.Applicable_Fee__c += massAppDeliveryFee;
			}
			system.debug('[Mass creation] id created : ' + massUpdateApplication.Id);
			for(integer i:setValidApplicationId){
				if(validatePromotion(mapAppWrap.get(i).ICA) != null){
					mapAppWrap.get(i).ICA.Promotion_Code__c = promotion.Promotion_Code__c;
				}
				mapAppWrap.get(i).ICA.Application_Status__c = 'Unpaid';
				mapAppWrap.get(i).ICA.Mass_order_Application__c = massUpdateApplication.id;
				mapAppWrap.get(i).ICA.Single_Application_Processing_Step__c = IDcardUtil.single_application_status_waiting;
				if (paymentMode.toLowerCase().contains('credit card'))
					mapAppWrap.get(i).ICA.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_CC;
				else if (paymentMode.toLowerCase().contains('wire'))
					mapAppWrap.get(i).ICA.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_CHECK;

			}

			map<id, ID_Card_Application__c> mapToCommit = new map<id, ID_Card_Application__c>();
			for(integer i:setValidApplicationId)
				mapToCommit.put(mapAppWrap.get(i).appId, mapAppWrap.get(i).ICA);
			
			//update validatedApplication.values();
			IDCardUtilWithoutSharing.saveCommittedICAS(mapToCommit);

			IATA_ISO_Country__c contactCountry = IDCardUtil.GetIATAISOCountryOfContact(iataCodeParameter);
			system.debug('[Mass creation] contact country : ' + contactCountry);
			orderNumber = 'ID' + contactCountry.ISO_Code__c + '-' + massUpdateApplication.Name.substring(5, massUpdateApplication.Name.length());

			Pagereference checkoutPage = Page.IDCard_CheckoutConfirmation;
			checkoutPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(massUpdateApplication.Id));
			if (paymentMode.toLowerCase().contains('credit card')) {
				system.debug('[Mass creation] Credit card asked: for Id  : ' + massUpdateApplication.Id);
				checkoutPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(massUpdateApplication.Id));
				fillcyberSourceData(acc, currentContact, massUpdateApplication, contactCountry, IDCardApplicationFactory.getPriceTables( IDCardUtil.GetAgentTypeFromAccountType(acc.type), contactCountry.Id)[0]);
				massUpdateApplication.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_CC;
				massUpdateApplication.Application_Status__c = 'Pending';
				//update massUpdateApplication;
				IDCardUtilWithoutSharing.saveCommittedICA(massUpdateApplication, massUpdateApplication.id);
				//return null;
			} else if (paymentMode.toLowerCase().contains('wire')) {
				system.debug('[Mass creation] WIRE asked: for Id  : ' + massUpdateApplication.Id);
				checkoutPage.getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE, IDCardUtil.EncryptEncodeParameter('true'));
				checkoutPage.getParameters().put('req_reference_number', massUpdateApplication.Name);
				massUpdateApplication.Application_Status__c = 'Pending';
				massUpdateApplication.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_CHECK;
				//update massUpdateApplication;
				IDCardUtilWithoutSharing.saveCommittedICA(massUpdateApplication, massUpdateApplication.id);
				checkoutPage.setRedirect(true);
				return checkoutPage;
			}
		}
		loadList();
		return null;
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

	/**


	*/
	private void fillcyberSourceData(Account acc , Contact currentContact , ID_Card_Application__c massUpdateApplication, IATA_ISO_Country__c contactCountry, Price_Table__c priceTable ) {
		system.debug('[Mass creation] fillcyberSourceData acc : ' + acc.Id + ' contatc ' + currentContact.Id + ' mass: ' + massUpdateApplication.Id + ' COUNTRY ' + contactCountry + ' PrcieTable' + priceTable.Id);

		cyberSrcData = new Map<String, String>()     ;

		String sharedSecret;

		if (massUpdateApplication.CurrencyIsoCode == 'CAD') {
			cyberSrcData.put('profile_id', label.Cybersource_ProfileId);
			cyberSrcData.put('access_key', label.Cybersource_AccessKey);
			sharedSecret = label.Cybersource_SecurityKey;
		} else {
			// USD
			cyberSrcData.put('profile_id', label.Cybersource_ProfileId_USD);
			cyberSrcData.put('access_key', label.Cybersource_AccessKey_USD);
			sharedSecret = label.Cybersource_SecurityKey_USD;
		}

		cyberSrcData.put('signed_date_time', DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
		cyberSrcData.put('transaction_uuid', String.ValueOf(massUpdateApplication.Id) + DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));

		cyberSrcData.put('currency', massUpdateApplication.CurrencyIsoCode);
		cyberSrcData.put('amount', String.valueOf(massUpdateApplication.Applicable_Fee__c != null ? massUpdateApplication.Applicable_Fee__c.setscale(2) : 0));
		cyberSrcData.put('reference_number', orderNumber);

		// hardcoded values
		cyberSrcData.put('transaction_type', 'sale');
		cyberSrcData.put('locale', 'en');
		cyberSrcData.put('signed_field_names', 'access_key,profile_id,transaction_uuid,signed_field_names,unsigned_field_names,signed_date_time,locale,transaction_type,reference_number,amount,currency');
		cyberSrcData.put('unsigned_field_names', 'bill_to_forename,bill_to_surname,merchant_defined_data1,merchant_defined_data2,merchant_defined_data3,merchant_defined_data4,merchant_defined_data5,merchant_defined_data6,merchant_defined_data7,merchant_defined_data8,merchant_defined_data9,merchant_defined_data10,merchant_defined_data11,merchant_defined_data12,merchant_defined_data13,merchant_defined_data14');

		// merchant defined fields
		cyberSrcData.put('bill_to_forename', currentContact.FirstName != null ? currentContact.FirstName : '');
		cyberSrcData.put('bill_to_surname', currentContact.LastName);
		cyberSrcData.put('merchant_defined_data1', acc.Name);
		cyberSrcData.put('merchant_defined_data2', iataCodeParameter != null ? iataCodeParameter : '');
		cyberSrcData.put('merchant_defined_data3', acc.ShippingState != null ? acc.ShippingState : '');
		cyberSrcData.put('merchant_defined_data4', 'ID Card - Mass application order');
		cyberSrcData.put('merchant_defined_data5', String.valueOf(massUpdateApplication.Applicable_Fee__c != null ? massUpdateApplication.Applicable_Fee__c : 0));
		cyberSrcData.put('merchant_defined_data6', String.valueOf(massUpdateApplication.ITDI_Courses_Fee__c != null ? massUpdateApplication.ITDI_Courses_Fee__c : 0));
		cyberSrcData.put('merchant_defined_data7', String.valueOf(massUpdateApplication.IDCard_Expedite_Delivery_Fee__c != null ? massUpdateApplication.IDCard_Expedite_Delivery_Fee__c : 0));
		cyberSrcData.put('merchant_defined_data8', '#1: ' + massUpdateApplication.Package_of_Travel_Professionals_Course_1__c + ' - #2: ' + massUpdateApplication.Package_of_Travel_Professionals_Course_2__c);
		cyberSrcData.put('merchant_defined_data9', contactCountry.ISO_Code__c != null ? contactCountry.ISO_Code__c : '');
		cyberSrcData.put('merchant_defined_data10', priceTable.Profit_Center__c != null ? priceTable.Profit_Center__c : '');
		cyberSrcData.put('merchant_defined_data11', massUpdateApplication.Tax_1_Name__c != null ? massUpdateApplication.Tax_1_Name__c : '');
		cyberSrcData.put('merchant_defined_data12', massUpdateApplication.Tax_1_Value__c != null ? massUpdateApplication.Tax_1_Value__c : '');
		cyberSrcData.put('merchant_defined_data13', massUpdateApplication.Tax_2_Name__c != null ? massUpdateApplication.Tax_2_Name__c : '');
		cyberSrcData.put('merchant_defined_data14', massUpdateApplication.Tax_2_Value__c != null ? massUpdateApplication.Tax_2_Value__c : '');

		// calculate the signature
		calculatedSignature = machash(buildDataToSign(), sharedSecret);

		for (String k : cyberSrcData.keySet())
			system.debug('[Mass creation]  cyberSrcData[' + k + '] = ' + cyberSrcData.get(k));
	}



	/*List of payment mode*/
	public list<SelectOption> getPaymentModeItems() {
		list<SelectOption> options = new list<SelectOption>();
		//List<Account> cs = [select Id, name, ID_Card_KeyAccount_features__c,IATACode__c from Account where IATACode__c in :keyContactAndDelegateForAccountList.keySet()];
		String ms = '';

		for (Account c :  [select Id, name, ID_Card_KeyAccount_features__c, IATACode__c from Account where IATACode__c in :keyContactAndDelegateForAccountList.keySet()])
			ms += c.ID_Card_KeyAccount_features__c + ';';
		if (String.isempty(ms))
			options.add(new SelectOption('Credit Card', 'Credit Card'));
		else
			for (String  s : ms.split(';', -2)) {
				if (s.toLowercase().contains('payment')) {
					boolean f = false;
					for (Selectoption so : options)
						if (so.getLabel().equals(s))
							f = true;
					if (!f)
						options.add(new SelectOption(s, s));
				}
			}
		if (options.size() ==  0)
			options.add(new SelectOption('Credit Card', 'Credit Card'));
		return options;
	}


	public  Pagereference validateAllApplication() {
		setRejectedApplicationId.clear();
		selectAll = !selectAll;
		for(integer i:mapAppWrap.keyset()){
			if (mapAppWrap.get(i).IsApplicationValid){
				if (isApplicationExpediteAvailable(mapAppWrap.get(i).ICA))
					mapAppWrap.get(i).ICA.IDCard_Expedite_Delivery__c = fastExpedition;
				if (selectAll)
					setValidApplicationId.add(i);
				else
					setValidApplicationId.remove(i);
			}
		}
		rejectedSize = setRejectedApplicationId.size();
		testIsExpediteAvailable();
		calculateAllPrices();
		return null;
	}

	/**
	Ajax call: process validation
	*/
	public Pagereference validationApplication() {
		string pageId = Apexpages.currentPage().getParameters().get('id');
		integer id = -1;
		if(pageId!=null) id = integer.valueOf(pageId);
		system.debug('add ' + id);
		setRejectedApplicationId.remove(id);

		ApplicationWrapper currentSelectedApp = mapAppWrap.get(id);
		
		if(currentSelectedApp!= null && currentSelectedApp.IsApplicationValid){
			if (ccurrency == null) //initialized after the first app getting Approved
				ccurrency = currentSelectedApp.ICA.CurrencyIsoCode;
			
			if(ccurrency != currentSelectedApp.ICA.CurrencyIsoCode){
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You cannot add card in different currencies in the purchase.' ));
				system.debug('[ERROR] You cannot add card in different currencies in the purchase.');
				return null;
			}

			if (isApplicationExpediteAvailable(currentSelectedApp.ICA) )
				mapAppWrap.get(id).ICA.IDCard_Expedite_Delivery__c = fastExpedition;

			setValidApplicationId.add(id);
		}

		system.debug(LoggingLevel.ERROR,'[validationApplication] Calculated price using  ' + setValidApplicationId.size());
		rejectedSize = setRejectedApplicationId.size();

		testIsExpediteAvailable();
		calculateAllPrices();
		return null;
	}

	/**
	Ajax call: reject application
	*/
	public  Pagereference unvalidationApplication() {
		string pageId = Apexpages.currentPage().getParameters().get('id');
		integer id = pageId==null?-1:integer.valueOf(pageId);

		setValidApplicationId.remove(id);
		setRejectedApplicationId.add(id);
		
		if (setValidApplicationId.size() == 0)
			ccurrency = null;
		system.debug('Calculated price using  ' + setValidApplicationId.size());
		rejectedSize = setRejectedApplicationId.size();
		selectAll = false;
		calculateAllPrices();
		testIsExpediteAvailable();
		return null;
	}

	/**
	Ajax call: do not nothing on application
	*/
	public  Pagereference doNotProcessApplication() {
		string pageId = Apexpages.currentPage().getParameters().get('id');
		integer id = pageID==null?-1:integer.valueOf(pageId);
		
		setValidApplicationId.remove(id);
		setRejectedApplicationId.remove(id);
		if (setValidApplicationId.size() == 0)
			ccurrency = null;
		rejectedSize = setRejectedApplicationId.size();
		selectAll = false;
		calculateAllPrices();
		testIsExpediteAvailable();
		return null;
	}

	/*Calculate price from selected pending application*/
	public void calculateAllPrices() {

		appsCurrency = '-';
		vatPrice = 0;
		tPrice = 0;
		deliveryPrice = 0;
		expediteFees = 0 ;
		massAppDeliveryFee = 0;
		idCardFee = 0;
		coursesFee = 0;
		discountFee = 0;
		Promotion__c validPromotion = null;

		for(integer i:mapAppWrap.keyset()){
			ID_Card_Application__c app = mapAppWrap.get(i).ICA;

			Account theAccount = taxesPerKeyAccount.get(app.IATA_Code__c);										
			Map<String, String> taxes = IDCardTaxUtil.GetTaxes(theAccount.BillingState, theAccount.BillingCountry);
			List<String> taxNames = new List<String>();
			taxNames.addAll(taxes.keySet());

			app.ID_Card_Fee_Discount__c = 0;
			Price_Table__c priceTable = pricePerCountry.get(countriesPerIATACode2.get(app.IATA_Code__c)+'-'+accountTypesPerIATACode.get(app.IATA_Code__c));
			Boolean isITDIPackage = false;
				if(app.Package_of_Travel_Professionals_Course_1__c != null){
					isITDIPackage = true;
				} else if(app.Package_of_Travel_Professionals_Course_2__c != null){
					isITDIPackage = true;
				}
			Boolean isReissue = (app.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE);
			Boolean isToPrint = (app.Card_Type__c == 'plastic');
			if(IDCard_MobileAppRenewalService.US_COUNTRY_ISO_CODES.contains(priceTable.ISO_Country__r.ISO_Code__c)){
				app.Card_Type__c = 'digital';
				isToPrint = false;
			}

			Map<String, decimal> detailledFees = new Map<String, decimal>();
			Decimal discountPercentage = discountPerKeyAccount.get(app.IATA_Code__c);

			if(discountPercentage != null && discountPercentage != 0){
				Promotion__c discount = new Promotion__c(Promotion_Value__c = discountPercentage);
				app.Applicable_Fee__c = IDCardUtil.GetApplicableFee(priceTable, isReissue, false, isITDIPackage, discount, isToPrint);

			} else {
				app.Applicable_Fee__c = IDCardUtil.GetApplicableFee(priceTable, isReissue, false, isITDIPackage, null, isToPrint);
			}

			if(setValidApplicationId.isEmpty()){
				validPromotion = validatePromotion(app);
			}			
			else if(setValidApplicationId.contains(i)){
				validPromotion = validatePromotion(app);
				detailledFees = IDCardUtil.GetDetailledFees(priceTable, isReissue, false, isITDIPackage, validPromotion, null, isToPrint);
				app.ID_Card_Fee__c = detailledFees.get('IDCardFee');
				app.IDCard_Expedite_Delivery_Fee__c = detailledFees.get('ExpediteFee');
				app.ITDI_Courses_Fee__c = detailledFees.get('ITDIFee');
				app.Physical_Card_Fee__c = detailledFees.get('PhysCardFee');
				app.ID_Card_Fee_Discount__c = detailledFees.get('Discount');

				app.ID_Card_Fee_Discount__c += ((app.ID_Card_Fee__c + app.Physical_Card_Fee__c) - (app.ID_Card_Fee__c + app.Physical_Card_Fee__c) * ((100 - (discountPercentage == null ? 0 : discountPercentage)) / 100));
				app.ID_Card_Fee__c = app.ID_Card_Fee__c * ((100 - (discountPercentage == null ? 0 : discountPercentage)) / 100);
				app.Physical_Card_Fee__c = app.Physical_Card_Fee__c * ((100 - (discountPercentage == null ? 0 : discountPercentage)) / 100);
				app.Applicable_Fee__c = app.ID_Card_Fee__c + app.Physical_Card_Fee__c + app.IDCard_Expedite_Delivery_Fee__c + app.ITDI_Courses_Fee__c;  
				
				if (taxNames.size() == 1){
					String name1 = taxNames.get(0);
					String percentage1 = taxes.get(name1);
					app.Tax_1_Name__c = name1 + '(' + percentage1 + '%)' ;
					app.Tax_1_Value__c = IDCardTaxUtil.CalculateTaxes(percentage1, String.ValueOf(app.Applicable_Fee__c)) + ' '+ app.CurrencyIsoCode;
				}
				else if (taxNames.size() == 2){
					String name1 = taxNames.get(0);
					String percentage1 = taxes.get(name1);
					String name2 = taxNames.get(1);
					String percentage2 = taxes.get(name2);

					app.Tax_1_Name__c = name1 + '(' + percentage1 + '%)' ;
					app.Tax_2_Name__c = name2 + '(' + percentage2 + '%)' ;

					Decimal totalTaxPercentage = Decimal.valueOf(percentage1) + Decimal.valueOf(percentage2);
					Decimal totalTaxAmount = Decimal.valueOf(IDCardTaxUtil.CalculateTaxes(String.valueOf(totalTaxPercentage), String.ValueOf(app.Applicable_Fee__c)));

					Decimal taxAmount1 = totalTaxAmount / totalTaxPercentage * Decimal.valueOf(percentage1);
					Decimal taxAmount2 = totalTaxAmount / totalTaxPercentage * Decimal.valueOf(percentage2);

					app.Tax_1_Value__c = taxAmount1.setScale(2) + ' ' + app.CurrencyIsoCode;
					app.Tax_2_Value__c = taxAmount2.setScale(2) + ' ' + app.CurrencyIsoCode;
				}

				if (app.ID_Card_Fee__c != null)
					tPrice += app.Applicable_Fee__c;

				if(app.Card_Type__c == 'plastic') deliveryPrice += app.Physical_Card_Fee__c;
				idCardFee += app.ID_Card_Fee__c;
				coursesFee += app.ITDI_Courses_Fee__c;
				discountFee += app.ID_Card_Fee_Discount__c;

				if (app.CurrencyIsoCode != null)
					appsCurrency = app.CurrencyIsoCode;

			
			}

			mapAppWrap.get(i).ICA = app;
		}
		tPrice += massAppDeliveryFee;

		// I'll use the same method that will be used at save time
		Contact currentContact = [select UIR__c, AccountId, Salutation, Id, FirstName, LastName, Name,  Title, VER_Number_2__c, Email ,
									  IATA_Code__c, Date_of_Birth__c, Gender__c, Phone, Start_Date_Agency_Month__c, Hours_per_week__c,
									  Middle_Initial__c, Position__c, Start_Date_Agency_Year__c, Start_Date_Industry__c, Duties__c, IDCard_Email__c,
									  Account.CurrencyIsoCode
									  from Contact where Ver_Number_2__c = :vernumParameter limit 1];
		//switch account status will be paid by wire / check or by CB
		List<ID_Card_Application__c> tmpLst = new List<ID_Card_Application__c>();
		for(integer i:mapAppWrap.keySet()){
			ID_Card_Application__c tmpApp = mapAppWrap.get(i).ICA;
			//tmpApp.id = mapAppWrap.get(i).appId;
			tmpLst.add(tmpApp);
		}
		ID_Card_Application__c app = IDCardApplicationFactory.createMassIDCardApplication(currentContact, tmpLst);
		vatPrice = Double.valueOf(Decimal.valueOf(Double.valueOf(app.Tax_1_Value__c.split(' ', 0)[0])).setScale(2) +
								  Decimal.valueOf(Double.valueOf(app.Tax_2_Value__c.split(' ', 0)[0])).setScale(2));


	}

	public void processAllDigital(){
		for(integer i:mapAppWrap.keyset())
			mapAppWrap.get(i).ICA.Card_Type__c = 'digital';
		
		calculateAllPrices();
	}


	private void testIsExpediteAvailable() {
		IsExpediteAvailable = false;
		for(integer i:mapAppWrap.keyset()){
			if (isApplicationExpediteAvailable(mapAppWrap.get(i).ICA)) {
				IsExpediteAvailable = true;
				break;
			}
		}
	}

	private boolean isApplicationExpediteAvailable(ID_Card_Application__c app) {

		for (Price_Table__c pt : pricePerCountry.values()) {
			system.debug('[PENDING OPP CTRL] APP  : ' + app.Id + ' Test with agent tyep =  ' + accountTypesPerIATACode.get(app.IATA_Code__c) + ' country :' + countriesPerIATACode.get(app.IATA_Code__c));

			if (countriesPerIATACode.get(app.IATA_Code__c) != null && pt.ISO_Country__c == countriesPerIATACode.get(app.IATA_Code__c).ID && pt.Type_Class_of_Agent__c == accountTypesPerIATACode.get(app.IATA_Code__c)) {
				system.debug('[PENDING OPP CTRL] find an app which involve to add mass expedite feee :' + app.Id + '  FEE:' + pt.Mass_Purchase_exp__c);
				return true;
			}
		}
		return false;
	}



	public class ContactProxy {

		public String Name {get; set;}

		public String Id {get; set;}

		public String FirstName {get; set;}

		public String LastName {get; set;}

		public boolean exist  {get; set;}

		public String verNum {get; set;}

		public  ContactProxy(Contact c, ID_Card_Application__c app) {

			Name = app.Displayed_Name__c;
			ID = '';
			FirstName = '';
			LastName = '';
			exist = false;
			verNum = '';

			if (c != null) {
				if (c.Name != null)
					Name = c.Name;
				Id = c.Id;
				LastName = c.LastName;
				firstName = c.firstName;
				if (c.VER_Number_2__c != null)
					verNum = c.VER_Number_2__c;
				exist = c.Id != null;
			} else if (app.VER_Number__c != null)
				verNum = app.VER_Number__c;
		}

	}
	public Promotion__c validatePromotion (ID_Card_Application__c app) {
		boolean isError = true;
		//////////////////////////
		// validate the promotion
		// Promotion code must exists, must be associated to the corresponding Price Table and be between the validity period
		if (promotion.Promotion_Code__c != null && promotion.Promotion_Code__c != '') {
			Promotion__c promo = mapPromotion.get(promotion.Promotion_Code__c);
			if (promo == null) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.Format(Label.ID_Card_Invalid_Promotion_Code, new String[] {promotion.Promotion_Code__c})));
				return null;
			}
			 String[] typeOfAppInPromoCode =  promo.Type_of_Application__c.split(';');

				for(String typeOfApp : typeOfAppInPromoCode){
					if(typeOfApp == app.Type_of_Application__c) {
						isError = false;
						break;
					}
				}

			if (promo.Promotion_Duration_Valid_Up_to__c < Date.today()) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ID_Card_Promotion_Code_No_Longer_Valid));
				return null;
			} else if (promo.Promotion_Duration_Valid_From__c > Date.today()) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ID_Card_Promotion_Code_Not_Yet_Valid));
				return null;
			}
			if (isError) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, String.Format(Label.ID_Card_Invalid_Promotion_Code_3, new String[] {promotion.Promotion_Code__c})));
				return null;
			}
			return promo;
		}
		return null;
	}

}