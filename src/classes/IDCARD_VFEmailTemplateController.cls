public with sharing class IDCARD_VFEmailTemplateController {


	public String myID {
		get;
		set{myID = value; IDCARD_VFEmailTemplateController();}
	}

	public Boolean isRenewal {get; set;}
	public Boolean isITDIPurchased {get; set;}
	public Boolean isExpedite {get; set;}
	public Boolean isPaymentbyCard {get; set;}
	public Boolean isMassApplication {get; set;}

	public Case caseAux {get; set;}
	public Contact cc {get; set;}

	public Date thisDay { get; set;}
	public Date expDate {get; set;}

	public String emailBody1 {get; set;}
	public String emailBody2 {get; set;}
	public String emailBody3 {get; set;}
	public String text1 {get; set;}
	public String text2 {get; set;}
	public String text3 {get; set;}
	public String text4 {get; set;}
	public String text5 {get; set;}
	public String text6 {get; set;}
	public String greeting {get; set;}
	public String signature {get; set;}
	public String fee {get; set;}
	public String expediteMsg {get; set;}
	public String[] shippingAddress {get; set;}
	public String shippingAddressStr {get; set;}

	public boolean isApprovalConfirm {get;set;}

	public List<ID_Card_Application__c> singleApps {get; set;}

	//EM - INC269266
	public boolean hiderenewal {get;set;}

	public void  IDCARD_VFEmailTemplateController() {

		thisDay = Date.Today();
		isITDIPurchased = false;
		isExpedite = false;
		isPaymentbyCard = false;
		isMassApplication = false;

		try {

			//Confirmation Email
			if (!isRenewal) {

				if(isApprovalConfirm){
					caseAux = [SELECT Related_ID_Card_Application__r.First_Name__c, Related_ID_Card_Application__r.Last_Name__c,
								Related_ID_Card_Application__r.VER_Number__c, Related_ID_Card_Application__r.IATA_Code__c,
								Related_ID_Card_Application__r.IDCard_Prefered_Language__c
								FROM Case WHERE Id = : myID];

					String lang = 'English';
					String l = caseAux.Related_ID_Card_Application__r.IDCard_Prefered_Language__c;
					if (l == 'fr') lang = 'French';
					if (l == 'es') lang = 'Spanish';

					EmailTemplate__c emailTemplate = [SELECT Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Signature_Details__c, greeting_line__c,
													Text_1__c, Text_2__c, Text_3__c, Text_4__c, Text_5__c, Text_6__c FROM EmailTemplate__c
													WHERE RecordType.Name = 'ID Card Application' AND Template_Language__c = :lang AND
													Name LIKE 'ID Card Email Template Approval%'];

					greeting = processText('Approval', emailTemplate.greeting_line__c, null, null, null, caseAux);
					emailBody1 = processText('Approval', emailTemplate.Body_Section_1__c, null, null, null, caseAux);
					emailBody2 = processText('Approval', emailTemplate.Body_Section_2__c, null, null, null, caseAux);
					signature = processText('Approval', emailTemplate.Signature_Details__c, null, null, null, caseAux);

				}else{

					// get Case required fields
					caseAux = [SELECT RecordType.Name, Related_ID_Card_Application__r.Tax_1_Value__c, Related_ID_Card_Application__r.Tax_2_Value__c, Related_ID_Card_Application__r.Tax_1_Name__c,
							Related_ID_Card_Application__r.Tax_2_Name__c, Related_ID_Card_Application__r.Payment_Date__c, Related_ID_Card_Application__r.Payment_Transaction_Number__c,
							Related_ID_Card_Application__r.Payment_Credit_Card_Number__c, Related_ID_Card_Application__r.ID_Card_Fee__c, Related_ID_Card_Application__r.IDCard_Expedite_Delivery_Fee__c,
							Related_ID_Card_Application__r.ITDI_Courses_Fee__c, Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_1__c, Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_2__c,
							Related_ID_Card_Application__r.IDCard_Prefered_Language__c, Related_ID_Card_Application__r.Last_Name__c, Related_ID_Card_Application__r.Physical_Card_Fee__c, Related_ID_Card_Application__r.ID_Card_Fee_Discount__c,
							Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry,
							Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry, Account.Name,
							Account.Short_Name__c, Account.TradeName__c, Related_ID_Card_Application__r.Type_of_application__c, Related_ID_Card_Application__r.First_Name__c, Related_ID_Card_Application__r.Middle_Initial__c,
							Related_ID_Card_Application__c, Related_ID_Card_Application__r.CurrencyIsoCode, Related_ID_Card_Application__r.Applicable_Fee__c, Related_ID_Card_Application__r.IATA_Code__c, CaseNumber,
							Account_Billing_Country__c, Related_ID_Card_Application__r.Displayed_Name__c, Related_ID_Card_Application__r.Terms_and_Conditions_Time_Stamp__c, Related_ID_Card_Application__r.Payment_Amount__c,
							Related_ID_Card_Application__r.Card_Type__c, AccountId FROM Case WHERE Id = : myID];

					//get list of single apps
					singleApps = [SELECT Id, IATA_Code__c, Displayed_Name__c, VER_Number__c, Card_Type__c
								FROM ID_Card_Application__c WHERE Mass_order_Application__c = : caseAux.Related_ID_Card_Application__c];

					isExpedite = (caseAux.Related_ID_Card_Application__r.IDCard_Expedite_Delivery_Fee__c != 0 && caseAux.Related_ID_Card_Application__r.IDCard_Expedite_Delivery_Fee__c != null);
					isITDIPurchased = (caseAux.Related_ID_Card_Application__r.ITDI_Courses_Fee__c != 0 && caseAux.Related_ID_Card_Application__r.ITDI_Courses_Fee__c != null);
					isPaymentbyCard = (caseAux.Related_ID_Card_Application__r.Payment_Transaction_Number__c != '' && caseAux.Related_ID_Card_Application__r.Payment_Transaction_Number__c != null);


					//Get the template to be used based on the prefered language
					String Lang = 'English';
					expediteMsg = ' If you have selected expedite delivery your ID Card will be delivered in 8 business days. ';
					if (caseAux.Related_ID_Card_Application__r.IDCard_Prefered_Language__c == 'fr') {
						Lang = 'French';
						expediteMsg = ' Si vous avez choisi la livraison rapide de votre carte d\'identité celle-ci sera livré dans un delai de 8 jours ouvrables. ';
					}
					if (caseAux.Related_ID_Card_Application__r.IDCard_Prefered_Language__c == 'es') {
						Lang = 'Spanish';
						expediteMsg = ' Si ha seleccionado la entrega por envió rápido, recibirá su tarjeta de identificación en 8 días laborales. ';
					}
					/////////////////////////////////////////////////////
					EmailTemplate__c emailTemplate;

					String emailTemplateQuery = 'SELECT Id, Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Signature_Details__c, Greeting_Line__c, ' +
												'Text_1__c, Text_2__c, Text_3__c, Text_4__c, Text_5__c, Text_6__c FROM EmailTemplate__c ' +
												'WHERE RecordType.Name = \'ID Card Application\' AND Template_Language__c = :Lang ';
					if (caseAux.RecordType.Name == 'ID Card Mass Application') {
						isMassApplication = true;
						if ( isPaymentbyCard){
							emailTemplateQuery +=  ' AND Template_Type__c = \'Mass Confirmation Email\' ';
							emailTemplateQuery +=  ' AND (Name = \'ID Card Email Template English - Mass\' OR Name = \'ID Card Email Template French - Mass\' OR Name = \'ID Card Email Template Spanish - Mass\')';
						}else{ // cheque payment
							emailTemplateQuery +=  ' AND Template_Type__c = \'Mass Confirmation Email Cheque\' ';
							emailTemplateQuery +=  ' AND (Name = \'ID Card Email Template English Cheque - Mass\' OR Name = \'ID Card Email Template French Cheque - Mass\' OR Name = \'ID Card Email Template Spanish Cheque - Mass\')';
						}
					} else {
						isMassApplication = false;
						if ( isPaymentbyCard){
							emailTemplateQuery +=  ' AND Template_Type__c = \'Confirmation Email\' ';
							emailTemplateQuery +=  ' AND (Name = \'ID Card Email Template English\' OR Name = \'ID Card Email Template French\' OR Name = \'ID Card Email Template Spanish\')';
						}else{ // cheque payment
							emailTemplateQuery +=  ' AND Template_Type__c = \'Confirmation Email Cheque\' ';
							emailTemplateQuery +=  ' AND (Name = \'ID Card Email Template English Cheque\' OR Name = \'ID Card Email Template French Cheque\' OR Name = \'ID Card Email Template Spanish Cheque\')';
						}
					}

					emailTemplate = Database.query(emailTemplateQuery);

					//return the shipping address if any of the fields is filled
					shippingAddress = new String[5];
					if (caseAux.Account.ShippingStreet != null || caseAux.Account.ShippingState != null || caseAux.Account.ShippingPostalCode != null || caseAux.Account.ShippingCountry != null || caseAux.Account.ShippingCity != null) {
							shippingAddress[0] = caseAux.Account.ShippingStreet == null ? '' : caseAux.Account.ShippingStreet;
							shippingAddress[1] = caseAux.Account.ShippingCity == null ? '' : caseAux.Account.ShippingCity;
							shippingAddress[2] = caseAux.Account.ShippingState == null ? '' : caseAux.Account.ShippingState;
							shippingAddress[3] = caseAux.Account.ShippingPostalCode == null ? '' : caseAux.Account.ShippingPostalCode;
							shippingAddress[4] = caseAux.Account.ShippingCountry == null ? '' : caseAux.Account.ShippingCountry;
					} else {
							shippingAddress[0] = caseAux.Account.BillingStreet == null ? '' : caseAux.Account.BillingStreet;
							shippingAddress[1] = caseAux.Account.BillingCity == null ? '' : caseAux.Account.BillingCity;
							shippingAddress[2] = caseAux.Account.BillingState == null ? '' : caseAux.Account.BillingState;
							shippingAddress[3] = caseAux.Account.BillingPostalCode == null ? '' : caseAux.Account.BillingPostalCode;
							shippingAddress[4] = caseAux.Account.BillingCountry == null ? '' : caseAux.Account.BillingCountry;
					}
						// Street 1, Street 2 if available, City, State, Country, Postal Code.
					shippingAddressStr = '';
					shippingAddressStr += shippingAddress[0] != '' ? shippingAddress[0] +  ', ' : '';
					shippingAddressStr += shippingAddress[1] != '' ? shippingAddress[1] +  ', ' : '';
					shippingAddressStr += shippingAddress[2] != '' ? shippingAddress[2] +  ', ' : '';
					shippingAddressStr += shippingAddress[3] != '' ? shippingAddress[3] +  ', ' : '';
					shippingAddressStr += shippingAddress[4] != '' ? shippingAddress[4] : '';
					if (!isMassApplication) {
						// ConfirmationV2CC
						if(isPaymentbyCard){
							greeting = processText('ConfirmationV2CC', emailTemplate.Greeting_Line__c, cc, null, null, caseAux);
							emailBody1 = processText('ConfirmationV2CC', emailTemplate.Body_Section_1__c, cc, null, null, caseAux);
							emailBody2 = processText('ConfirmationV2CC', emailTemplate.Body_Section_2__c, cc, null, null, caseAux);
							emailBody3 = processText('ConfirmationV2CC', emailTemplate.Body_Section_3__c, cc, null, null, caseAux);
							text1 = processText('ConfirmationV2CC', emailTemplate.Text_1__c, cc, null, null, caseAux);
							text2 = processText('ConfirmationV2CC', emailTemplate.Text_2__c, cc, null, null, caseAux);
							if((caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_1__c != null && caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_1__c != '' )
							|| (caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_2__c != null && caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_2__c != '') ){
								text3 = processText('ConfirmationV2CC', emailTemplate.Text_3__c, cc, null, null, caseAux);
							}else{
								text3 = '';
							}
							text4 = identifyTextTagsToChange('ConfirmationV2CC', emailTemplate.Text_4__c, cc, null, null, caseAux);
							text5 = processText('ConfirmationV2CC', emailTemplate.Text_5__c, cc, null, null, caseAux);
							text6 = processText('ConfirmationV2CC', emailTemplate.Text_6__c, cc, null, null, caseAux);
							signature = processText('ConfirmationV2CC', emailTemplate.Signature_Details__c, cc, null, null, caseAux);
						}else{
							// ConfirmationV2Cheque
							greeting = processText('ConfirmationV2Cheque', emailTemplate.Greeting_Line__c, cc, null, null, caseAux);
							emailBody1 = processText('ConfirmationV2Cheque', emailTemplate.Body_Section_1__c, cc, null, null, caseAux);
							emailBody2 = processText('ConfirmationV2Cheque', emailTemplate.Body_Section_2__c, cc, null, null, caseAux);
							emailBody3 = processText('ConfirmationV2Cheque', emailTemplate.Body_Section_3__c, cc, null, null, caseAux);
							text1 = processText('ConfirmationV2Cheque', emailTemplate.Text_1__c, cc, null, null, caseAux);
							text2 = processText('ConfirmationV2Cheque', emailTemplate.Text_2__c, cc, null, null, caseAux);
							if((caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_1__c != null && caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_1__c != '' )
							|| (caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_2__c != null && caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_2__c != '') ){
								text3 = processText('ConfirmationV2Cheque', emailTemplate.Text_3__c, cc, null, null, caseAux);
							}else{
								text3 = '';
							}
							text4 = identifyTextTagsToChange('ConfirmationV2Cheque', emailTemplate.Text_4__c, cc, null, null, caseAux);
							text5 = processText('ConfirmationV2Cheque', emailTemplate.Text_5__c, cc, null, null, caseAux);
							text6 = processText('ConfirmationV2Cheque', emailTemplate.Text_6__c, cc, null, null, caseAux);
							signature = processText('ConfirmationV2Cheque', emailTemplate.Signature_Details__c, cc, null, null, caseAux);
						}
					}

					//if ConfirmationV3CC
					else{
						if(isPaymentbyCard){

							emailBody1 = processText('ConfirmationV3CC', emailTemplate.Body_Section_1__c, cc, null, null, caseAux);
							emailBody2 = processText('ConfirmationV3CC', emailTemplate.Body_Section_2__c, cc, null, null, caseAux);
							emailBody3 = processText('ConfirmationV3CC', emailTemplate.Body_Section_3__c, cc, null, null, caseAux);
							text1 = processText('ConfirmationV3CC', emailTemplate.Text_1__c, cc, null, null, caseAux);
							text2 = processText('ConfirmationV3CC', emailTemplate.Text_2__c, cc, null, null, caseAux);
							text3 = identifyTextTagsToChange('ConfirmationV3CC', emailTemplate.Text_3__c, cc, null, null, caseAux);
							text4 = processText('ConfirmationV3CC', emailTemplate.Text_4__c, cc, null, null, caseAux);
							text5 = processText('ConfirmationV3CC', emailTemplate.Text_5__c, cc, null, null, caseAux);
							text6 = processText('ConfirmationV3CC', emailTemplate.Text_6__c, cc, null, null, caseAux);
							greeting = processText('ConfirmationV3CC', emailTemplate.greeting_line__c, cc, null, null, caseAux);
							signature = processText('ConfirmationV3CC', emailTemplate.Signature_Details__c, cc, null, null, caseAux);
						}

						//if ConfirmationV3Cheque
						else{

							emailBody1 = processText('ConfirmationV3Cheque', emailTemplate.Body_Section_1__c, cc, null, null, caseAux);
							emailBody2 = processText('ConfirmationV3Cheque', emailTemplate.Body_Section_2__c, cc, null, null, caseAux);
							emailBody3 = processText('ConfirmationV3Cheque', emailTemplate.Body_Section_3__c, cc, null, null, caseAux);
							text1 = processText('ConfirmationV3Cheque', emailTemplate.Text_1__c, cc, null, null, caseAux);
							text2 = processText('ConfirmationV3Cheque', emailTemplate.Text_2__c, cc, null, null, caseAux);
							text3 = identifyTextTagsToChange('ConfirmationV3Cheque', emailTemplate.Text_3__c, cc, null, null, caseAux);
							text4 = processText('ConfirmationV3Cheque', emailTemplate.Text_4__c, cc, null, null, caseAux);
							text5 = processText('ConfirmationV3Cheque', emailTemplate.Text_5__c, cc, null, null, caseAux);
							text6 = processText('ConfirmationV3Cheque', emailTemplate.Text_6__c, cc, null, null, caseAux);
							greeting = processText('ConfirmationV3Cheque', emailTemplate.greeting_line__c, cc, null, null, caseAux);
							signature = processText('ConfirmationV3Cheque', emailTemplate.Signature_Details__c, cc, null, null, caseAux);
						}
					}


					//set Case Number field in ID Card application to be used in Check out page at the end of Payment
					ID_Card_Application__c tempApp = [Select Case_Number__c from ID_Card_Application__c where Id = : caseAux.Related_ID_Card_Application__c ];
					tempApp.Case_Number__c  = caseAux.CaseNumber;
					Update tempApp;
				}

			}


			//Renewal Email Stuff
			else {

				//get related Contact
				cc = [ SELECT ID_Card_Preferred_Language__c, VER_Number__c, Name, Date_of_Birth__c, Id,
								AccountId, Account.type, Account.BillingStreet, Account.BillingCity, Account.IATACode__c,
								Account.BillingCountry, Account.Name, Account.Short_Name__c
								FROM Contact WHERE Id = :myID ];
				String contactID = cc.Id;
				// get last ID Card
				ID_Card__c idcard = [SELECT Valid_To_Date__c, Related_Contact__r.Account.IDCard_Key_Account__c,FirstName__c,LastName__c,
									Agency_IATA_Code__c,Name_on_ID_Card__c,Date_of_Birth__c,VER_Number__c, Card_Type__c
									FROM ID_Card__c WHERE Related_Contact__r.Id = :contactID AND Card_Status__c = :IDCardUtil.CARDSTATUS_VALID
									AND Valid_To_Date__c != null
									ORDER BY Valid_To_Date__c DESC LIMIT 1];

				//set expiry date of last IDCard
				expDate = idcard.Valid_To_Date__c;

				hiderenewal = (idcard.related_contact__r.account != null && idcard.related_contact__r.account.IDCard_Key_Account__c == true);

				//Get the template to be used based on the prefered language
				String lang = 'English';
				String l = cc.ID_Card_Preferred_Language__c;
				if (l == 'fr') lang = 'French';
				if (l == 'es') lang = 'Spanish';

				//get fee for Renewal
				String acccountType = IDCardUtil.GetAgentTypeFromAccountType(cc.Account.type);
				IATA_ISO_Country__c contactCountry = IDCardUtil.GetIATAISOCountryOfContact(cc.Account.IATACode__c);

				System.debug(loggingLevel.ERROR, '____ [cls IDCARD_VFEmailTemplateController - constructor] contactCountry.name - ' + contactCountry.name);
				System.debug(loggingLevel.ERROR, '____ [cls IDCARD_VFEmailTemplateController - constructor] acccountType - ' + acccountType);
				Price_Table__c[] listPriceTables = [SELECT ID_Card_Fee__c, Type_Class_of_Agent__c, CurrencyIsoCode, Expedite__c, Name, Cost_of_Printer__c
																						FROM Price_Table__c
																						WHERE Type_Class_of_Agent__c = :acccountType AND ISO_Country__c = :contactCountry.Id];
				fee = IDCardUtil.GetApplicableFee(listPriceTables[0], false, false, false, null) + '   ' + listPriceTables[0].CurrencyIsoCode;
				EmailTemplate__c e = [SELECT Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Signature_Details__c,
							Greeting_Line__c, Text_1__c, Text_2__c, Text_3__c, Text_4__c, Text_5__c, Text_6__c
							FROM EmailTemplate__c WHERE RecordType.Name = 'ID Card Application'
							AND Template_Type__c = 'Renewal Notice' AND Template_Language__c = :lang];

				emailBody1 = processText('Renewal', e.Body_Section_1__c, cc, null, idCard, null);
				emailBody2 = processText('Renewal', e.Body_Section_2__c, cc, null, idCard, null);
				emailBody3 = processText('Renewal', e.Body_Section_3__c, cc, null, idCard, null);
				text1 = processText('Renewal', e.Text_1__c, cc, null, idCard, null);
				text2 = processText('Renewal', e.Text_2__c, cc, null, idCard, null);
				text3 = processText('Renewal', e.Text_3__c, cc, null, idCard, null);
				text4 = processText('Renewal', e.Text_4__c, cc, null, idCard, null);
				text5 = processText('Renewal', e.Text_5__c, cc, null, idCard, null);
				text6 = processText('Renewal', e.Text_6__c, cc, null, idCard, null);
				greeting = processText('Renewal', e.greeting_line__c, cc, null, idCard, null);
				signature = processText('Renewal', e.Signature_Details__c, cc, null, idCard, null);

			}
		}

		catch (Exception ex) {
			System.debug(loggingLevel.Debug, '[cls IDCARD_VFEmailTemplateController - IDCARD_VFEmailTemplateController] errorMessage - ' + ex.getMessage());
			signature = ex.getMessage();
		}
	}

	/*
	 * Breaks down each tagged sentence in order to replace
	 * the inner fields for the correct data
	 */
	private String identifyTextTagsToChange(String templateType, String text, Contact contact, Account account, ID_Card__c idCard, Case caseAux){
		String finalText;

		//if is Single Confirmation Credit Card
		if(templateType == 'ConfirmationV2CC' || templateType == 'ConfirmationV2Cheque' ){

			if(caseAux.Related_ID_Card_Application__r.Card_Type__c != null && caseAux.Related_ID_Card_Application__r.Card_Type__c == 'plastic'){
				text = processAndReplaceTag(text, '2A');

				text = processAndReplaceTag(text, '2B');
			}else{
				String processedTextWithTag = processLogicTextTagWithTag(text, '2A');
				text = text.replace(processedTextWithTag, '');

				processedTextWithTag = processLogicTextTagWithTag(text, '2B');
				text = text.replace(processedTextWithTag, '');
			}

			if((caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_1__c != null && caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_2__c != null)
				&& (caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_1__c != '' && caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_2__c != '')){
					text = processAndReplaceTag(text, '3');
			}else{
				String processedTextWithTag = processLogicTextTagWithTag(text, '3');
				text = text.replace(processedTextWithTag, '');
			}

			if(caseAux.Related_ID_Card_Application__r.ID_Card_Fee_Discount__c != null && caseAux.Related_ID_Card_Application__r.ID_Card_Fee_Discount__c != 0){
				text = processAndReplaceTag(text, '4');
			}else{
				String processedTextWithTag = processLogicTextTagWithTag(text, '4');
				text = text.replace(processedTextWithTag, '');
			}

			if(caseAux.Related_ID_Card_Application__r.Tax_1_Name__c != null && caseAux.Related_ID_Card_Application__r.Tax_1_Name__c != '0'){
				text = processAndReplaceTag(text, '5');
			}else{
				String processedTextWithTag = processLogicTextTagWithTag(text, '5');
				text = text.replace(processedTextWithTag, '');
			}

			if(caseAux.Related_ID_Card_Application__r.Tax_2_Name__c != null && caseAux.Related_ID_Card_Application__r.Tax_2_Name__c != '0'){
				text = processAndReplaceTag(text, '6');
			}else{
				String processedTextWithTag = processLogicTextTagWithTag(text, '6');
				text = text.replace(processedTextWithTag, '');
			}

			if((caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_1__c != null && caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_2__c != null)
				&& (caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_1__c != '' && caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_2__c != '')){
					text = processAndReplaceTag(text, '7A');

					text = processAndReplaceTag(text, '7B');
			}else{
				String processedTextWithTag = processLogicTextTagWithTag(text, '7A');
				text = text.replace(processedTextWithTag, '');

				processedTextWithTag = processLogicTextTagWithTag(text, '7B');
				text = text.replace(processedTextWithTag, '');
			}
			//finalText = text;
			finalText = processText(templateType, text, contact, account, idCard, caseAux);
		}

		//for Confirmation Mass Email Credit Card or Confirmation Mass Email Cheque
		if(templateType == 'ConfirmationV3CC' || templateType == 'ConfirmationV3Cheque'){

			if(caseAux.Related_ID_Card_Application__r.ID_Card_Fee_Discount__c != null && caseAux.Related_ID_Card_Application__r.ID_Card_Fee_Discount__c != 0){
				text = processAndReplaceTag(text, '2');
			}else{
				String processedTextWithTag = processLogicTextTagWithTag(text, '2');
				text = text.replace(processedTextWithTag, '');
			}

			if(caseAux.Related_ID_Card_Application__r.Tax_1_Name__c != null && caseAux.Related_ID_Card_Application__r.Tax_1_Name__c != '0'){
				text = processAndReplaceTag(text, '3');
			}else{
				String processedTextWithTag = processLogicTextTagWithTag(text, '3');
				text = text.replace(processedTextWithTag, '');
			}

			if(caseAux.Related_ID_Card_Application__r.Tax_2_Name__c != null && caseAux.Related_ID_Card_Application__r.Tax_2_Name__c != '0'){
				text = processAndReplaceTag(text, '4');
			}else{
				String processedTextWithTag = processLogicTextTagWithTag(text, '4');
				text = text.replace(processedTextWithTag, '');
			}

			if(caseAux.Related_ID_Card_Application__r.Payment_Credit_Card_Number__c != null
			&& caseAux.Related_ID_Card_Application__r.Payment_Credit_Card_Number__c != ''){
				text = processAndReplaceTag(text, '5A');

				text = processAndReplaceTag(text, '5B');
			}else{
				String processedTextWithTag = processLogicTextTagWithTag(text, '5A');
				text = text.replace(processedTextWithTag, '');

				processedTextWithTag = processLogicTextTagWithTag(text, '5B');
				text = text.replace(processedTextWithTag, '');
			}

			//finalText = text;
			finalText = processText(templateType, text, contact, account, idCard, caseAux);
		}

		return finalText;
	}

	/*
	* Searches for a substring contained within the given tag and replaces
	* without the tag
	*/
	private String processAndReplaceTag(String text, String tag){
		String processedTextWithTag = processLogicTextTagWithTag(text, tag);
		String processedTextWithoutTag = processLogicTextTagWithoutTag(text, tag);
		return text.replace(processedTextWithTag, processedTextWithoutTag);
	}

	/*
	* Returns the substring that is contained by the tags
	*/
	private String processLogicTextTagWithoutTag(String text, String tag){

		if(text == null) return '';

		String initTag = '[!' + tag + ']';
		String finalTag = '[' + tag + ']';
		Integer initPos =  text.indexOf(initTag);
		Integer finalPos =  text.indexOf(finalTag);

		if(initPos < 0 || finalPos < 0) return '';

		return text.substring(initPos + initTag.length(), finalPos);
	}

	/*
	* Returns the substring that begins and ends in the given tag including them
	*/
	private String processLogicTextTagWithTag(String text, String tag){

		if(text == null) return '';

		String initTag = '[!' + tag + ']';
		String finalTag = '[' + tag + ']';
		Integer initPos =  text.indexOf(initTag);
		Integer finalPos =  text.indexOf(finalTag);

		if(initPos < 0 || finalPos < 0) return '';

		return text.substring(initPos, finalPos + finalTag.length());
	}

	/*
	* Processes the given text by replacing temporary variables field name
	* with their values from respective object fields.
	*/
	private String processText(String templateType, String text, Contact contact, Account account, ID_Card__c idCard, Case caseAux){
		try{
			String finalText = text != null ? text : '';
			Boolean findNext = true;

			//While have variables to replace
			while(findNext){
				Integer nextReplacePosInit = finalText.indexOf('{!');

				if(nextReplacePosInit > -1){
					Integer nextReplacePosEnd = finalText.indexOf('}')+1;
					String fieldToReplace = finalText.substring(nextReplacePosInit, nextReplacePosEnd);

					finalText = replaceField(templateType, finalText, fieldToReplace, contact, account, idCard, caseAux);
				}else{
					findNext = false;
				}

			}

			return finalText;
		}
		catch(Exception e){
			//Something went wrong, just return unmodified text
			System.debug(loggingLevel.Debug, '[cls IDCARD_VFEmailTemplateController - processText] errorMessage - ' + e.getMessage());
			return text;
		}

	}

	/*
	* Fetch and replace the given object field in the text.
	*/
	private String replaceField(String templateType, String text, String field, Contact contact, Account account, ID_Card__c idCard, Case caseAux){
		String returnText = '';

		//replaces fields for renewal template
		if(templateType == 'Renewal'){
			if(field == '{!ID_Card__c.FirstName__c}') returnText = idCard.FirstName__c;
			if(field == '{!ID_Card__c.LastName__c}') returnText = idCard.LastName__c;
			if(field == '{!ID_Card__c.Valid_To_Date__c}') returnText = idCard.Valid_To_Date__c.format();
			if(field == '{!ID_Card__c.Agency_IATA_Code__c}') returnText = idCard.Agency_IATA_Code__c;
			if(field == '{!ID_Card__c.Name_on_ID_Card__c}') returnText = idCard.Name_on_ID_Card__c;
			if(field == '{!ID_Card__c.Date_of_Birth__c}') returnText = idCard.Date_of_Birth__c.format();
			if(field == '{!ID_Card__c.VER_Number__c}') returnText = idCard.VER_Number__c;
			if(field == '{!ID_Card__c.Fee}') returnText = fee;
		}

		//replaces fields for approval template
		if(templateType == 'Approval'){
			if(field == '{!ID_Card_Application__c.First_Name__c}') returnText = caseAux.Related_ID_Card_Application__r.First_Name__c;
			if(field == '{!ID_Card_Application__c.Last_Name__c}') returnText = caseAux.Related_ID_Card_Application__r.Last_Name__c;
			if(field == '{!ID_Card_Application__c.VER_Number__c}') returnText = caseAux.Related_ID_Card_Application__r.VER_Number__c;
			if(field == '{!ID_Card_Application__c.IATA_Code__c}') returnText = caseAux.Related_ID_Card_Application__r.IATA_Code__c;
		}

		//replaces fields for Single Confirmation Credit Card and Cheque template
		if(templateType == 'ConfirmationV2CC' || templateType == 'ConfirmationV2Cheque'){
			if(field == '{!ID_Card__c.FirstName__c}') returnText = caseAux.Related_ID_Card_Application__r.First_Name__c != null ? caseAux.Related_ID_Card_Application__r.First_Name__c : '';
			if(field == '{!ID_Card__c.LastName__c}') returnText = caseAux.Related_ID_Card_Application__r.Last_Name__c  != null ?  caseAux.Related_ID_Card_Application__r.Last_Name__c : '';
			if(field == '{!ID_Card__c.CurrencyIsoCode}') returnText = caseAux.Related_ID_Card_Application__r.CurrencyIsoCode  != null ? caseAux.Related_ID_Card_Application__r.CurrencyIsoCode : '';
			if(field == '{!Case.CaseNumber}') returnText = caseAux.CaseNumber != null ?  caseAux.CaseNumber : '' ;
			if(field == '{!ID_Card__c.Displayed_Name__c}') returnText = caseAux.Related_ID_Card_Application__r.Displayed_Name__c != null ? caseAux.Related_ID_Card_Application__r.Displayed_Name__c : '';
			if(field == '{!ID_Card__c.Agency_IATA_Code__c}') returnText = caseAux.Related_ID_Card_Application__r.IATA_Code__c != null ? caseAux.Related_ID_Card_Application__r.IATA_Code__c + '' : '';
			if(field == '{!Account.Short_Name__c}') returnText = caseAux.Account.Short_Name__c != null ? caseAux.Account.Short_Name__c : '';
			if(field == '{!Account.ShippingAddress}') returnText = shippingAddressStr != null ? shippingAddressStr : '';
			if(field == '{!ID_Card__c.Terms_and_Conditions_Time_Stamp__c}') returnText = caseAux.Related_ID_Card_Application__r.Terms_and_Conditions_Time_Stamp__c != null ? caseAux.Related_ID_Card_Application__r.Terms_and_Conditions_Time_Stamp__c.date().format() : '';
			if(field == '{!ID_Card__c.Package_of_Travel_Professionals_Course_1__c}') returnText = caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_1__c != null ? caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_1__c : '';
			if(field == '{!ID_Card__c.Package_of_Travel_Professionals_Course_2__c}') returnText = caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_2__c != null ? caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_2__c : '';
				if(field == '{!ID_Card__c.ID_Card_Fee__c}'){
					if(caseAux.Related_ID_Card_Application__r.ID_Card_Fee__c != null && caseAux.Related_ID_Card_Application__r.ID_Card_Fee__c != 0 )
					returnText = String.valueOf(caseAux.Related_ID_Card_Application__r.ID_Card_Fee__c.setScale(2));
					else
						returnText = String.valueOf(Decimal.valueOf('0').setScale(2));
				}
				if(field == '{!ID_Card__c.Physical_Card_Fee__c}'){
					if(caseAux.Related_ID_Card_Application__r.Physical_Card_Fee__c != null && caseAux.Related_ID_Card_Application__r.Physical_Card_Fee__c != 0 )
					returnText = String.valueOf(caseAux.Related_ID_Card_Application__r.Physical_Card_Fee__c.setScale(2));
					else
						returnText = String.valueOf(Decimal.valueOf('0').setScale(2));
				}
				if(field == '{!ID_Card__c.IDCard_Expedite_Delivery_Fee__c}'){
					if(caseAux.Related_ID_Card_Application__r.IDCard_Expedite_Delivery_Fee__c != null && caseAux.Related_ID_Card_Application__r.IDCard_Expedite_Delivery_Fee__c != 0 )
						returnText = String.valueOf(caseAux.Related_ID_Card_Application__r.IDCard_Expedite_Delivery_Fee__c.setScale(2));
					else
						returnText = String.valueOf(Decimal.valueOf('0').setScale(2));
				}
				if(field == '{!ID_Card__c.TDI_Courses_Fee__c}'){
					if(caseAux.Related_ID_Card_Application__r.ITDI_Courses_Fee__c != null && caseAux.Related_ID_Card_Application__r.ITDI_Courses_Fee__c != 0 )
						returnText = String.valueOf(caseAux.Related_ID_Card_Application__r.ITDI_Courses_Fee__c.setScale(2));
					else
						returnText = String.valueOf(Decimal.valueOf('0').setScale(2));
				}
			if(field == '{!ID_Card__c.Tax_1_Name__c}') returnText = caseAux.Related_ID_Card_Application__r.Tax_1_Name__c != null ? caseAux.Related_ID_Card_Application__r.Tax_1_Name__c : '';
			if(field == '{!ID_Card__c.Tax_1_Value__c}') returnText = caseAux.Related_ID_Card_Application__r.Tax_1_Value__c != null ? caseAux.Related_ID_Card_Application__r.Tax_1_Value__c : '';
			if(field == '{!ID_Card__c.Tax_2_Name__c}') returnText = caseAux.Related_ID_Card_Application__r.Tax_2_Name__c != null ? caseAux.Related_ID_Card_Application__r.Tax_2_Name__c : '';
			if(field == '{!ID_Card__c.Tax_2_Value__c}') returnText = caseAux.Related_ID_Card_Application__r.Tax_2_Value__c != null ? caseAux.Related_ID_Card_Application__r.Tax_2_Value__c : '';
			if(field == '{!ID_Card__c.Payment_Amount__c}'){
				if(caseAux.Related_ID_Card_Application__r.Payment_Amount__c != null && caseAux.Related_ID_Card_Application__r.Payment_Amount__c != 0 )
					returnText = String.valueOf(caseAux.Related_ID_Card_Application__r.Payment_Amount__c.setScale(2));
				else
					returnText = String.valueOf(Decimal.valueOf('0').setScale(2));
			}
			if(field == '{!ID_Card__c.Payment_Credit_Card_Number__c}') returnText = caseAux.Related_ID_Card_Application__r.Payment_Credit_Card_Number__c != null ? caseAux.Related_ID_Card_Application__r.Payment_Credit_Card_Number__c : '';
			if(field == '{!ID_Card__c.Payment_Transaction_Number__c}') returnText = caseAux.Related_ID_Card_Application__r.Payment_Transaction_Number__c != null ? caseAux.Related_ID_Card_Application__r.Payment_Transaction_Number__c : '';
		}

		//replaces fields for Confirmation Mass Email Credit Card and Mass Email Cheque
		if(templateType == 'ConfirmationV3CC' || templateType == 'ConfirmationV3Cheque' ){
			if(field == '{!ID_Card__c.FirstName__c}') returnText = caseAux.Related_ID_Card_Application__r.First_Name__c != null ? caseAux.Related_ID_Card_Application__r.First_Name__c : '';
			if(field == '{!ID_Card__c.LastName__c}') returnText = caseAux.Related_ID_Card_Application__r.Last_Name__c  != null ?  caseAux.Related_ID_Card_Application__r.Last_Name__c : '';
			if(field == '{!ID_Card__c.CurrencyIsoCode}') returnText = caseAux.Related_ID_Card_Application__r.CurrencyIsoCode  != null ? caseAux.Related_ID_Card_Application__r.CurrencyIsoCode : '';
			if(field == '{!Case.CaseNumber}') returnText = caseAux.CaseNumber != null ?  caseAux.CaseNumber : '' ;
			if(field == '{!ID_Card__c.Displayed_Name__c}') returnText = caseAux.Related_ID_Card_Application__r.Displayed_Name__c != null ? caseAux.Related_ID_Card_Application__r.Displayed_Name__c : '';
			if(field == '{!ID_Card__c.Agency_IATA_Code__c}') returnText = caseAux.Related_ID_Card_Application__r.IATA_Code__c != null ? caseAux.Related_ID_Card_Application__r.IATA_Code__c + '' : '';
			if(field == '{!Account.Short_Name__c}') returnText = caseAux.Account.Short_Name__c != null ? caseAux.Account.Short_Name__c : '';
			if(field == '{!Account.ShippingAddress}') returnText = shippingAddressStr != null ? shippingAddressStr : '';
			if(field == '{!Account.BillingAddress}') returnText = shippingAddressStr != null ? shippingAddressStr : '';
			if(field == '{!ID_Card__c.Terms_and_Conditions_Time_Stamp__c}') returnText = caseAux.Related_ID_Card_Application__r.Terms_and_Conditions_Time_Stamp__c != null ? caseAux.Related_ID_Card_Application__r.Terms_and_Conditions_Time_Stamp__c.date().format() : '';
			if(field == '{!ID_Card__c.Package_of_Travel_Professionals_Course_1__c}') returnText = caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_1__c != null ? caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_1__c : '';
			if(field == '{!ID_Card__c.Package_of_Travel_Professionals_Course_2__c}') returnText = caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_2__c != null ? caseAux.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_2__c : '';
			if(field == '{!ID_Card__c.ID_Card_Fee__c}'){
				if(caseAux.Related_ID_Card_Application__r.ID_Card_Fee__c != null && caseAux.Related_ID_Card_Application__r.ID_Card_Fee__c != 0 )
					returnText = String.valueOf(caseAux.Related_ID_Card_Application__r.ID_Card_Fee__c.setScale(2));
				else
					returnText = String.valueOf(Decimal.valueOf('0').setScale(2));
			}
			if(field == '{!ID_Card__c.Physical_Card_Fee__c}'){
				if(caseAux.Related_ID_Card_Application__r.Physical_Card_Fee__c != null && caseAux.Related_ID_Card_Application__r.Physical_Card_Fee__c != 0 )
					returnText = String.valueOf(caseAux.Related_ID_Card_Application__r.Physical_Card_Fee__c.setScale(2));
				else
					returnText = String.valueOf(Decimal.valueOf('0').setScale(2));
			}
			if(field == '{!ID_Card__c.IDCard_Expedite_Delivery_Fee__c}'){
				if(caseAux.Related_ID_Card_Application__r.IDCard_Expedite_Delivery_Fee__c != null && caseAux.Related_ID_Card_Application__r.IDCard_Expedite_Delivery_Fee__c != 0 )
					returnText = String.valueOf(caseAux.Related_ID_Card_Application__r.IDCard_Expedite_Delivery_Fee__c.setScale(2));
				else
					returnText = String.valueOf(Decimal.valueOf('0').setScale(2));
			}
			if(field == '{!ID_Card__c.TDI_Courses_Fee__c}'){
				if(caseAux.Related_ID_Card_Application__r.ITDI_Courses_Fee__c != null && caseAux.Related_ID_Card_Application__r.ITDI_Courses_Fee__c != 0 )
					returnText = String.valueOf(caseAux.Related_ID_Card_Application__r.ITDI_Courses_Fee__c.setScale(2));
				else
					returnText = String.valueOf(Decimal.valueOf('0').setScale(2));
			}
			if(field == '{!ID_Card__c.ID_Card_Fee_Discount__c}') returnText = caseAux.Related_ID_Card_Application__r.ID_Card_Fee_Discount__c != null ? caseAux.Related_ID_Card_Application__r.ID_Card_Fee_Discount__c.format() : '';
			if(field == '{!ID_Card__c.Tax_1_Name__c}') returnText = caseAux.Related_ID_Card_Application__r.Tax_1_Name__c != null ? caseAux.Related_ID_Card_Application__r.Tax_1_Name__c : '';
			if(field == '{!ID_Card__c.Tax_1_Value__c}') returnText = caseAux.Related_ID_Card_Application__r.Tax_1_Value__c != null ? caseAux.Related_ID_Card_Application__r.Tax_1_Value__c : '';
			if(field == '{!ID_Card__c.Tax_2_Name__c}') returnText = caseAux.Related_ID_Card_Application__r.Tax_2_Name__c != null ? caseAux.Related_ID_Card_Application__r.Tax_2_Name__c : '';
			if(field == '{!ID_Card__c.Tax_2_Value__c}') returnText = caseAux.Related_ID_Card_Application__r.Tax_2_Value__c != null ? caseAux.Related_ID_Card_Application__r.Tax_2_Value__c : '';
			if(field == '{!ID_Card__c.Payment_Amount__c}'){
				if(caseAux.Related_ID_Card_Application__r.Payment_Amount__c != null && caseAux.Related_ID_Card_Application__r.Payment_Amount__c != 0 )
					returnText = String.valueOf(caseAux.Related_ID_Card_Application__r.Payment_Amount__c.setScale(2));
				else
					returnText = String.valueOf(Decimal.valueOf('0').setScale(2));
			}
			if(field == '{!ID_Card__c.Payment_Credit_Card_Number__c}') returnText = caseAux.Related_ID_Card_Application__r.Payment_Credit_Card_Number__c != null ? caseAux.Related_ID_Card_Application__r.Payment_Credit_Card_Number__c : '';
			if(field == '{!ID_Card__c.Payment_Transaction_Number__c}') returnText = caseAux.Related_ID_Card_Application__r.Payment_Transaction_Number__c != null ? caseAux.Related_ID_Card_Application__r.Payment_Transaction_Number__c : '';
		}

		text = text.replace(field, returnText);
		return text;
	}

}
