public with sharing class IECZuoraHelper { 
    private static Zuora.zApi apiInstance = null;
    private static String SessionID = null;
    
    public static Zuora.zApi zApiInstance {
        get {
            if (apiInstance == null) {
                apiInstance = new Zuora.zApi();
                
                try {
                    Zuora.zApi.LoginResult res = apiInstance.zlogin();
                    // keep zuora session id
                    SessionID = res.Session;
                } catch (Zuora.zRemoteException ex) {
                    if (ex.code == 'INVALID_LOGIN') {
                       throw new IECApplicationException('Invalid Zuora Login');
                    }
                } catch (Zuora.zAPIException ex) {
                    throw new IECApplicationException('There was an api exception: ' + ex.getMessage() + '\r\n' + ex.getStackTraceString());
                } catch (Zuora.zForceException ex) {
                    throw new IECApplicationException('There was a z-force exception: ' + ex.getMessage() + '\r\n' + ex.getStackTraceString());
                }
            }
            return apiInstance;
        }
    }
    
    public static String ZuoraSessionID {
    	get {
    		if (SessionID == null) {
    			// trigger login if need to
    			Zuora.zApi z = zApiInstance;
    		}
    		return SessionID;
    	}
    }
    
    public static List<Zuora.zObject> queryApiCall(String zoql) {
        return zApiInstance.zQuery(zoql);
    }
    
    public static Zuora.zApi.SaveResult createApiCall(Zuora.zObject zobj) {
        return createApiCall(new List<Zuora.zObject> { zobj }).get(0);
    }
    
    public static List<Zuora.zApi.SaveResult> createApiCall(List<Zuora.zObject> zobjs) {
        List<Zuora.zApi.SaveResult> results = zApiInstance.zcreate(zobjs);
        return results;
    }
    
    public static Zuora.zApi.SaveResult updateApiCall(Zuora.zObject zobj) {
        return updateApiCall(new List<Zuora.zObject> { zobj }).get(0);
    }
    
    public static List<Zuora.zApi.SaveResult> updateApiCall(List<Zuora.zObject> zobjs) {
        List<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(zobjs);
        return results;
    }
    
    public static Zuora.zApi.DeleteResult deleteApiCall(String ztype, String id) {
        return deleteApiCall(ztype, new String[] { id }).get(0);
    }
    
    public static List<Zuora.zApi.DeleteResult> deleteApiCall(String ztype, String[] ids) {
        List<Zuora.zApi.DeleteResult> results = zApiInstance.zdelete(ztype, ids);
        return results;
    }
    
    public static Zuora.zApi.AmendResult amendApiCall(Zuora.zApi.AmendRequest zAmend) {
        Zuora.zApi.AmendResult result = zApiInstance.zamend(new List<Zuora.zApi.AmendRequest>{zAmend});
		return result;
    }
    
    public static Zuora.zApi.AmendResult amendApiCall(List<Zuora.zApi.AmendRequest> zAmends) {
        Zuora.zApi.AmendResult result = zApiInstance.zamend(zAmends);
		return result;
    }
        
    public static Zuora.zObject createZuoraAccount(Account theAccount, Contact theContact) {
        return createZuoraAccount(theAccount, theContact, IECConstants.PaymentType.CREDIT_CARD, null);
    }
    
    public static Zuora.zObject createZuoraAccount(Account theAccount, Contact theContact, IECConstants.PaymentType ePaymentType, String sPaymentMethodId) {
        Zuora.zObject acc = new Zuora.zObject('Account');
        acc.setValue('Name', theContact.Account.Name);   //*** (Thai 2016-11-17) replace "theAccount"
        
        String trimmedAccountId = (String)theContact.Account.Id;   //*** (Thai 2016-11-17) replace "theAccount"
        if (trimmedAccountId.length() > 15)
            trimmedAccountId = trimmedAccountId.substring(0, 15);
            
        acc.setValue('CrmId', trimmedAccountId);
        acc.setValue('CRMContactID__c', theContact.Id);
        acc.setValue('Currency', theContact.Account.CurrencyIsoCode);   //*** (Thai 2016-11-17) replace "theAccount"
        
        // TODO: check these required fields after the registration process is completed
        //acc.setValue('IATA_Area__c', 'Area 1' /*theAccount.IATA_Area__c*/);
        //acc.setValue('ClientType__c', theAccount.ClientType__c);
        //acc.setValue('SubRegion__c', 'Asia');
        //acc.setValue('CompanyType__c', 'Casino');
        //acc.setValue('ProfitCenter__c', 'DBP003' /*theAccount.Profit_Center__c*/);
        
        // TO CHECK...
        acc.setValue('BillCycleDay', 1);
        acc.setValue('PaymentTerm', 'Net 30');
        acc.setValue('Batch', 'Batch1');
            
        // Bank Transfer
        if (ePaymentType == IECConstants.PaymentType.BANK_TRANSFER) {
        	acc.setValue('AutoPay', false);
            acc.setValue('DefaultPaymentMethodId', IECConstants.PaymentMethod_BankTransfer_ZuoraID);
            acc.setValue('InvoiceTemplateId', IECConstants.InvoiceTemplate_Bank_Transfer_ZuoraID);
        }
        // CHECK
        else if (ePaymentType == IECConstants.PaymentType.CHECK) {
            acc.setValue('AutoPay', false);
            acc.setValue('DefaultPaymentMethodId', IECConstants.PaymentMethod_Check_ZuoraID);
            acc.setValue('InvoiceTemplateId', IECConstants.InvoiceTemplate_Check_ZuoraID);
        }
        // ICH
        else if (ePaymentType == IECConstants.PaymentType.ICH) {
        	acc.setValue('AutoPay', false);
            acc.setValue('DefaultPaymentMethodId', IECConstants.PaymentMethod_ICH_ZuoraID);
            acc.setValue('InvoiceTemplateId', IECConstants.InvoiceTemplate_Other_ZuoraID);
        }
        // Credit card
        else {
        	acc.setValue('AutoPay', true);
			acc.setValue('InvoiceTemplateId', IECConstants.InvoiceTemplate_Credit_Card_ZuoraID);
			if (String.isNotBlank(sPaymentMethodId))
            	acc.setValue('DefaultPaymentMethodId', sPaymentMethodId);
        }
        
        if (String.isNotBlank(theContact.Tax_1_ID__c))
            acc.setValue('Tax1ID__c', (String.isBlank(theContact.VAT_Country_Code__c) ? '' : theContact.VAT_Country_Code__c) + theContact.Tax_1_ID__c);
            
        if (String.isNotBlank(theContact.Tax_2_ID__c))
            acc.setValue('Tax2ID__c', theContact.Tax_2_ID__c);
            
		/* Commented by Samy (2016-03-11) Using the SAP ID from the new Location__c model instead of the old SAP_Account__c
		// Get the SAP Bill-To Id
		List<SAP_Account__c> lstSAPAcc =
			[SELECT SAP_ID__c
			FROM SAP_Account__c
			WHERE Account__c = :theAccount.Id AND  GDP__c  = true ];
				//AND SAP_Account_type__c = :IECConstants.SAPAccount_InvoiceType_Invoices];
		
		if (!lstSAPAcc.isEmpty())
			acc.setValue('SAPBillTo__c', lstSAPAcc.get(0).SAP_ID__c);
		*/
		
		if (String.isNotBlank(theContact.BillTo_Location__r.SAP_Id__c))
			acc.setValue('SAPBillTo__c', theContact.BillTo_Location__r.SAP_Id__c);
		
		if (String.isNotBlank(theContact.BillTo_Location__r.VAT_Number__c))
			acc.setValue('VATID__c', theContact.BillTo_Location__r.VAT_Number__c);

        return acc;
    }
    
    public static Zuora.zObject createZuoraBillToContact(Contact theContact) {
        Zuora.zObject billToContact = new Zuora.zObject('Contact');
        billToContact.setValue('FirstName', theContact.FirstName);
        billToContact.setValue('LastName', theContact.LastName);
        billToContact.setValue('WorkEmail', theContact.Email);
        billToContact.setValue('WorkPhone', theContact.Phone);

        // get the Billing Address associated to the contact
        List<IECAddress__c> lstAddresses = IECUserManager.getAddressByContact(theContact.Id, IECConstants.IECAddress_AddressType_Billing);
		IECAddress__c oBillingAddress = (lstAddresses.size() > 0 ? lstAddresses.get(0) : null);
		
        if (oBillingAddress != null) {
            //*** Thai (2016-11-11) use ISO country code and ISO state code instead of name to mitigate the reject from Zuora
	        billToContact.setValue('Country', (oBillingAddress.ISO_Country_Code__c == null ? oBillingAddress.ISO_Country_Name__c : oBillingAddress.ISO_Country_Code__c));
	        billToContact.setValue('State', (oBillingAddress.ISO_State_Code_SAP__c == null ? oBillingAddress.ISO_State_Name__c : oBillingAddress.ISO_State_Code_SAP__c));
	        billToContact.setValue('City', oBillingAddress.City__c);
	        billToContact.setValue('PostalCode', oBillingAddress.ZipCode__c);
	        billToContact.setValue('Address1', oBillingAddress.Street__c);
        }
        
        return billToContact;
    }
    
    public static Zuora.zObject createZuoraSoldToContact(Contact theContact) {
        Zuora.zObject soldToContact = new Zuora.zObject('Contact');
        soldToContact.setValue('FirstName', theContact.FirstName);
        soldToContact.setValue('LastName', theContact.LastName);
        soldToContact.setValue('WorkEmail', theContact.Email);
        soldToContact.setValue('WorkPhone', theContact.Phone);

        // get the Shipping Address associated to the contact
        List<IECAddress__c> lstAddresses = IECUserManager.getAddressByContact(theContact.Id, IECConstants.IECAddress_AddressType_Shipping);
		IECAddress__c oShippingAddress = (lstAddresses.size() > 0 ? lstAddresses.get(0) : null);
		
        if (oShippingAddress != null) {
            //*** Thai (2016-11-11) use ISO country code and ISO state code instead of name to mitigate the reject from Zuora
	        soldToContact.setValue('Country', (oShippingAddress.ISO_Country_Code__c == null ? oShippingAddress.ISO_Country_Name__c : oShippingAddress.ISO_Country_Code__c));
	        soldToContact.setValue('State', (oShippingAddress.ISO_State_Code_SAP__c == null ? oShippingAddress.ISO_State_Name__c : oShippingAddress.ISO_State_Code_SAP__c));
	        soldToContact.setValue('City', oShippingAddress.City__c);
	        soldToContact.setValue('PostalCode', oShippingAddress.ZipCode__c);
	        soldToContact.setValue('Address1', oShippingAddress.Street__c);
        }
        
        return soldToContact;
    }
    
    public static String getCurrentDate() {
        return DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss', 'UTC');
    }
    
    public static String getFutureDate(DateTime dtFuture) {
        return dtFuture.format('yyyy-MM-dd\'T\'HH:mm:ss', 'UTC');
    }
    
    public Static DateTime GetDateInAmericasNewYorkTZ(DateTime dtCurrent) {
    	// This is the Date and Time in the Zuora User TimeZone
		string zuoraTimeZoneSidId = 'America/New_York';
		
		TimeZone zuoraTimeZone = TimeZone.getTimeZone(zuoraTimeZoneSidId);
		integer offsetToZuoraTimeZone = zuoraTimeZone.getOffset(dtCurrent);
		
		TimeZone tz = UserInfo.getTimeZone();
		integer offsetToUserTimeZone = tz.getOffset(dtCurrent);
		
		// Figure out correct to go from Zuora User DateTime to GMT and then from GMT to Users TimeZone
		integer correction = offsetToUserTimeZone - offsetToZuoraTimeZone;
		
		// Note: Potential issues for TimeZone differences less than a minute
		return dtCurrent.addMinutes(correction / (1000 * 60));
    }
    
    public static List<SelectOption> getZuoraCountriesSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('AF','Afghanistan'));
        options.add(new SelectOption('AX','Aland Islands'));
        options.add(new SelectOption('AL','Albania'));
        options.add(new SelectOption('DZ','Algeria'));
        options.add(new SelectOption('AS','American Samoa'));
        options.add(new SelectOption('AD','Andorra'));
        options.add(new SelectOption('AO','Angola'));
        options.add(new SelectOption('AI','Anguilla'));
        options.add(new SelectOption('AQ','Antarctica'));
        options.add(new SelectOption('AG','Antigua and Barbuda'));
        options.add(new SelectOption('AR','Argentina'));
        options.add(new SelectOption('AM','Armenia'));
        options.add(new SelectOption('AW','Aruba'));
        options.add(new SelectOption('AU','Australia'));
        options.add(new SelectOption('AT','Austria'));
        options.add(new SelectOption('AZ','Azerbaijan'));
        options.add(new SelectOption('BS','Bahamas'));
        options.add(new SelectOption('BH','Bahrain'));
        options.add(new SelectOption('BD','Bangladesh'));
        options.add(new SelectOption('BB','Barbados'));
        options.add(new SelectOption('BY','Belarus'));
        options.add(new SelectOption('BE','Belgium'));
        options.add(new SelectOption('BZ','Belize'));
        options.add(new SelectOption('BJ','Benin'));
        options.add(new SelectOption('BM','Bermuda'));
        options.add(new SelectOption('BT','Bhutan'));
        options.add(new SelectOption('BO','Bolivia'));
        options.add(new SelectOption('BQ','Bonaire, Saint Eustatius and Saba'));
        options.add(new SelectOption('BA','Bosnia and Herzegovina'));
        options.add(new SelectOption('BW','Botswana'));
        options.add(new SelectOption('BV','Bouvet Island'));
        options.add(new SelectOption('BR','Brazil'));
        options.add(new SelectOption('IO','British Indian Ocean Territory'));
        options.add(new SelectOption('BN','Brunei Darussalam'));
        options.add(new SelectOption('BG','Bulgaria'));
        options.add(new SelectOption('BF','Burkina Faso'));
        options.add(new SelectOption('BI','Burundi'));
        options.add(new SelectOption('KH','Cambodia'));
        options.add(new SelectOption('CM','Cameroon'));
        options.add(new SelectOption('CA','Canada'));
        options.add(new SelectOption('CV','Cape Verde'));
        options.add(new SelectOption('KY','Cayman Islands'));
        options.add(new SelectOption('CF','Central African Republic'));
        options.add(new SelectOption('TD','Chad'));
        options.add(new SelectOption('CL','Chile'));
        options.add(new SelectOption('CN','China'));
        options.add(new SelectOption('CX','Christmas Island'));
        options.add(new SelectOption('CC','Cocos (Keeling) Islands'));
        options.add(new SelectOption('CO','Colombia'));
        options.add(new SelectOption('KM','Comoros'));
        options.add(new SelectOption('CG','Congo'));
        options.add(new SelectOption('CD','Congo, the Democratic Republic of the'));
        options.add(new SelectOption('CK','Cook Islands'));
        options.add(new SelectOption('CR','Costa Rica'));
        options.add(new SelectOption('CI','Cote d\'Ivoire'));
        options.add(new SelectOption('HR','Croatia'));
        options.add(new SelectOption('CU','Cuba'));
        options.add(new SelectOption('CW','Curaçao (Cura�ao)'));
        options.add(new SelectOption('CY','Cyprus'));
        options.add(new SelectOption('CZ','Czech Republic'));
        options.add(new SelectOption('DK','Denmark'));
        options.add(new SelectOption('DJ','Djibouti'));
        options.add(new SelectOption('DM','Dominica'));
        options.add(new SelectOption('DO','Dominican Republic'));
        options.add(new SelectOption('EC','Ecuador'));
        options.add(new SelectOption('EG','Egypt'));
        options.add(new SelectOption('SV','El Salvador'));
        options.add(new SelectOption('GQ','Equatorial Guinea'));
        options.add(new SelectOption('ER','Eritrea'));
        options.add(new SelectOption('EE','Estonia'));
        options.add(new SelectOption('ET','Ethiopia'));
        options.add(new SelectOption('FK','Falkland Islands (Malvinas)'));
        options.add(new SelectOption('FO','Faroe Islands'));
        options.add(new SelectOption('FJ','Fiji'));
        options.add(new SelectOption('FI','Finland'));
        options.add(new SelectOption('FR','France'));
        options.add(new SelectOption('GF','French Guiana'));
        options.add(new SelectOption('PF','French Polynesia'));
        options.add(new SelectOption('TF','French Southern Territories'));
        options.add(new SelectOption('GA','Gabon'));
        options.add(new SelectOption('GM','Gambia'));
        options.add(new SelectOption('GE','Georgia'));
        options.add(new SelectOption('DE','Germany'));
        options.add(new SelectOption('GH','Ghana'));
        options.add(new SelectOption('GI','Gibraltar'));
        options.add(new SelectOption('GR','Greece'));
        options.add(new SelectOption('GL','Greenland'));
        options.add(new SelectOption('GD','Grenada'));
        options.add(new SelectOption('GP','Guadeloupe'));
        options.add(new SelectOption('GU','Guam'));
        options.add(new SelectOption('GT','Guatemala'));
        options.add(new SelectOption('GG','Guernsey'));
        options.add(new SelectOption('GN','Guinea'));
        options.add(new SelectOption('GW','Guinea-Bissau'));
        options.add(new SelectOption('GY','Guyana'));
        options.add(new SelectOption('HT','Haiti'));
        options.add(new SelectOption('HM','Heard and McDonald Islands'));
        options.add(new SelectOption('VA','Holy See (Vatican City State)'));
        options.add(new SelectOption('HN','Honduras'));
        options.add(new SelectOption('HK','Hong Kong'));
        options.add(new SelectOption('HU','Hungary'));
        options.add(new SelectOption('IS','Iceland'));
        options.add(new SelectOption('IN','India'));
        options.add(new SelectOption('ID','Indonesia'));
        options.add(new SelectOption('IR','Iran, Islamic Republic of'));
        options.add(new SelectOption('IQ','Iraq'));
        options.add(new SelectOption('IE','Ireland'));
        options.add(new SelectOption('IM','Isle of Man'));
        options.add(new SelectOption('IL','Israel'));
        options.add(new SelectOption('IT','Italy'));
        options.add(new SelectOption('JM','Jamaica'));
        options.add(new SelectOption('JP','Japan'));
        options.add(new SelectOption('JE','Jersey'));
        options.add(new SelectOption('JO','Jordan'));
        options.add(new SelectOption('KZ','Kazakhstan'));
        options.add(new SelectOption('KE','Kenya'));
        options.add(new SelectOption('KI','Kiribati'));
        options.add(new SelectOption('KP','Korea, Democratic People\'s Republic of'));
        options.add(new SelectOption('KR','Korea, Republic of'));
        options.add(new SelectOption('KW','Kuwait'));
        options.add(new SelectOption('KG','Kyrgyzstan'));
        options.add(new SelectOption('LA','Lao People\'s Democratic Republic'));
        options.add(new SelectOption('LV','Latvia'));
        options.add(new SelectOption('LB','Lebanon'));
        options.add(new SelectOption('LS','Lesotho'));
        options.add(new SelectOption('LR','Liberia'));
        options.add(new SelectOption('LY','Libyan Arab Jamahiriya'));
        options.add(new SelectOption('LI','Liechtenstein'));
        options.add(new SelectOption('LT','Lithuania'));
        options.add(new SelectOption('LU','Luxembourg'));
        options.add(new SelectOption('MO','Macao'));
        options.add(new SelectOption('MK','Macedonia, the former Yugoslav Republic of'));
        options.add(new SelectOption('MG','Madagascar'));
        options.add(new SelectOption('MW','Malawi'));
        options.add(new SelectOption('MY','Malaysia'));
        options.add(new SelectOption('MV','Maldives'));
        options.add(new SelectOption('ML','Mali'));
        options.add(new SelectOption('MT','Malta'));
        options.add(new SelectOption('MH','Marshall Islands'));
        options.add(new SelectOption('MQ','Martinique'));
        options.add(new SelectOption('MR','Mauritania'));
        options.add(new SelectOption('MU','Mauritius'));
        options.add(new SelectOption('YT','Mayotte'));
        options.add(new SelectOption('MX','Mexico'));
        options.add(new SelectOption('FM','Micronesia, Federated States of'));
        options.add(new SelectOption('MD','Moldova, Republic of'));
        options.add(new SelectOption('MC','Monaco'));
        options.add(new SelectOption('MN','Mongolia'));
        options.add(new SelectOption('ME','Montenegro'));
        options.add(new SelectOption('MS','Montserrat'));
        options.add(new SelectOption('MA','Morocco'));
        options.add(new SelectOption('MZ','Mozambique'));
        options.add(new SelectOption('MM','Myanmar'));
        options.add(new SelectOption('NA','Namibia'));
        options.add(new SelectOption('NR','Nauru'));
        options.add(new SelectOption('NP','Nepal'));
        options.add(new SelectOption('NL','Netherlands'));
        options.add(new SelectOption('NC','New Caledonia'));
        options.add(new SelectOption('NZ','New Zealand'));
        options.add(new SelectOption('NI','Nicaragua'));
        options.add(new SelectOption('NE','Niger'));
        options.add(new SelectOption('NG','Nigeria'));
        options.add(new SelectOption('NU','Niue'));
        options.add(new SelectOption('NF','Norfolk Island'));
        options.add(new SelectOption('MP','Northern Mariana Islands'));
        options.add(new SelectOption('NO','Norway'));
        options.add(new SelectOption('OM','Oman'));
        options.add(new SelectOption('PK','Pakistan'));
        options.add(new SelectOption('PW','Palau'));
        options.add(new SelectOption('PS','Palestinian Territory, Occupied'));
        options.add(new SelectOption('PA','Panama'));
        options.add(new SelectOption('PG','Papua New Guinea'));
        options.add(new SelectOption('PY','Paraguay'));
        options.add(new SelectOption('PE','Peru'));
        options.add(new SelectOption('PH','Philippines'));
        options.add(new SelectOption('PN','Pitcairn'));
        options.add(new SelectOption('PL','Poland'));
        options.add(new SelectOption('PT','Portugal'));
        options.add(new SelectOption('PR','Puerto Rico'));
        options.add(new SelectOption('QA','Qatar'));
        options.add(new SelectOption('RE','Reunion'));
        options.add(new SelectOption('RO','Romania'));
        options.add(new SelectOption('RU','Russian Federation'));
        options.add(new SelectOption('RW','Rwanda'));
        options.add(new SelectOption('BL','Saint Barthelemy'));
        options.add(new SelectOption('SH','Saint Helena'));
        options.add(new SelectOption('KN','Saint Kitts and Nevis'));
        options.add(new SelectOption('LC','Saint Lucia'));
        options.add(new SelectOption('MF','Saint Martin (French part)'));
        options.add(new SelectOption('PM','Saint Pierre and Miquelon'));
        options.add(new SelectOption('VC','Saint Vincent and the Grenadines'));
        options.add(new SelectOption('WS','Samoa'));
        options.add(new SelectOption('SM','San Marino'));
        options.add(new SelectOption('ST','Sao Tome and Principe'));
        options.add(new SelectOption('SA','Saudi Arabia'));
        options.add(new SelectOption('SN','Senegal'));
        options.add(new SelectOption('RS','Serbia'));
        options.add(new SelectOption('SC','Seychelles'));
        options.add(new SelectOption('SL','Sierra Leone'));
        options.add(new SelectOption('SG','Singapore'));
        options.add(new SelectOption('SX','Sint Maarten'));
        options.add(new SelectOption('SK','Slovakia'));
        options.add(new SelectOption('SI','Slovenia'));
        options.add(new SelectOption('SB','Solomon Islands'));
        options.add(new SelectOption('SO','Somalia'));
        options.add(new SelectOption('ZA','South Africa'));
        options.add(new SelectOption('GS','South Georgia and the South Sandwich Islands'));
        options.add(new SelectOption('ES','Spain'));
        options.add(new SelectOption('LK','Sri Lanka'));
        options.add(new SelectOption('SD','Sudan'));
        options.add(new SelectOption('SR','Suriname'));
        options.add(new SelectOption('SJ','Svalbard and Jan Mayen'));
        options.add(new SelectOption('SZ','Swaziland'));
        options.add(new SelectOption('SE','Sweden'));
        options.add(new SelectOption('CH','Switzerland'));
        options.add(new SelectOption('SY','Syrian Arab Republic'));
        options.add(new SelectOption('TW','Taiwan'));
        options.add(new SelectOption('TJ','Tajikistan'));
        options.add(new SelectOption('TZ','Tanzania, United Republic of'));
        options.add(new SelectOption('TH','Thailand'));
        options.add(new SelectOption('TL','Timor-Leste'));
        options.add(new SelectOption('TG','Togo'));
        options.add(new SelectOption('TK','Tokelau'));
        options.add(new SelectOption('TO','Tonga'));
        options.add(new SelectOption('TT','Trinidad and Tobago'));
        options.add(new SelectOption('TN','Tunisia'));
        options.add(new SelectOption('TR','Turkey'));
        options.add(new SelectOption('TM','Turkmenistan'));
        options.add(new SelectOption('TC','Turks and Caicos Islands'));
        options.add(new SelectOption('TV','Tuvalu'));
        options.add(new SelectOption('UG','Uganda'));
        options.add(new SelectOption('UA','Ukraine'));
        options.add(new SelectOption('AE','United Arab Emirates'));
        options.add(new SelectOption('GB','United Kingdom'));
        options.add(new SelectOption('US','United States'));
        options.add(new SelectOption('UM','United States Minor Outlying Islands'));
        options.add(new SelectOption('UY','Uruguay'));
        options.add(new SelectOption('UZ','Uzbekistan'));
        options.add(new SelectOption('VU','Vanuatu'));
        options.add(new SelectOption('VE','Venezuela'));
        options.add(new SelectOption('VN','Viet Nam'));
        options.add(new SelectOption('VG','Virgin Islands, British'));
        options.add(new SelectOption('VI','Virgin Islands, U.S.'));
        options.add(new SelectOption('WF','Wallis and Futuna'));
        options.add(new SelectOption('EH','Western Sahara'));
        options.add(new SelectOption('YE','Yemen'));
        options.add(new SelectOption('ZM','Zambia'));
        options.add(new SelectOption('ZW','Zimbabwe'));
        return options;
    }
    
    public static String convertCountryNameToCode(String countryName) {
		List<SelectOption> countries = getZuoraCountriesSelectOptions();
		for (SelectOption country : countries) {
			if (country.getLabel() == countryName)
				return country.getValue();
		}
		return countryName;
	}
    
    public static List<SelectOption> getDefaultPaymentMethods() {
		List<SelectOption> options = new List<SelectOption>();
		if (IECCustomer.getCurrentIECCustomer().canPayByICH()) {
			options.add(new SelectOption(IECConstants.PaymentMethod_ICH_ZuoraID, 'ICH'));
		}
		//TODO: Once Bank Transfer is added, restore the comment below
		//options.add(new SelectOption(DEFAULT_PAYMENT_METHOD_ZID_BANKTRANSFER,'Bank Transfer'));
		return options;
	}
    
    public static Zuora.zObject getZuoraAccountBySFAccountId(Id sfAccountId, Id sfContactId) {

        String trimmedSFAccountId = (String)sfAccountId;
        if (trimmedSFAccountId.length() > 15)
            trimmedSFAccountId = trimmedSFAccountId.substring(0, 15);

        List<Zuora.zObject> accountResult = queryApiCall('select Id,AccountNumber,BillToId,DefaultPaymentMethodId,Name,SoldToId,Status from Account where CrmId = \'' + trimmedSFAccountId + '\' and CRMContactID__c = \'' + sfContactId + '\'');
        if (accountResult == null || accountResult.size() == 0) {
            return null;
        }
            
        return accountResult.get(0);
    }
	
	public static Zuora.zApi.SaveResult updateCreditCard(Zuora.zObject zObj) {
		try {
			return updateApiCall(zObj);
		}
		catch (Exception e) {
			throw new IECApplicationException('Could not update Credit Card. Error: ' + e.getMessage());
		}
	}
	
	public static Zuora.zApi.DeleteResult deleteCreditCard(String id) {
		try {
			return deleteApiCall('PaymentMethod', id);
		}
		catch (Exception e) {
			throw new IECApplicationException('Could not delete Credit Card. Error: ' + e.getMessage());
		}
	}
	
	public static Zuora.zApi.SaveResult updateDefaultPaymentMethod(String zuoraAccountZId, String paymentMethodZId) {
		try {
			List<Zuora.zObject> accountList = queryApiCall('select Id, DefaultPaymentMethodId from Account where Id = \'' + zuoraAccountZId + '\'');
			
			if (accountList == null || accountList.size() == 0)
				throw new IECApplicationException('No account found with zId ' + zuoraAccountZId);
			
			Zuora.zObject account = accountList.get(0);
			account.setValue('DefaultPaymentMethodId', paymentMethodZId);
			
			// Adjust the AutoPay and the InvoiceTemplateId field according to the PaymentMethod chosen
			if (paymentMethodZId == IECConstants.PaymentMethod_BankTransfer_ZuoraID) {
				account.setValue('AutoPay', false);
				account.setValue('InvoiceTemplateId', IECConstants.InvoiceTemplate_Bank_Transfer_ZuoraID);
			}
			else if (paymentMethodZId == IECConstants.PaymentMethod_ICH_ZuoraID) {
				account.setValue('AutoPay', false);
				account.setValue('InvoiceTemplateId', IECConstants.InvoiceTemplate_Other_ZuoraID);
			}
			else {
				account.setValue('AutoPay', true);
				account.setValue('InvoiceTemplateId', IECConstants.InvoiceTemplate_Credit_Card_ZuoraID);
			}
			
			return updateApiCall(account);
		}
		catch (Exception e) {
			throw new IECApplicationException('Could not update Default Payment Method. Error: ' + e.getMessage());
		}
	}
    
    /**
	 * Convert the Zuora Payment object into a local Class to be able to display it in the UI
	 */
    public static List<PaymentMethod> convertFromzObjectListToPaymentMethod(List<Zuora.zObject> zPaymentMethods) {
        List<PaymentMethod> pms = new List<PaymentMethod>();
        for (Zuora.zObject pm : zPaymentMethods) {
            pms.add(new PaymentMethod(pm));
        }
        return pms;
    }
    
    public static String getErrorMessagesString(Zuora.zObject[] errors, String sSeparator) {
    	String message = '';
		for (Zuora.zObject error : errors) {
			if (error == null) continue;
			message +=  sSeparator + (String)error.getValue('Message');
		}
		return message;
    }
    
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Push autorenew changes to Zuora in the form of "Amends" 
	public static Zuora.zApi.AmendResult updateZuoraAutoRenew(IECCustomer customer, String subscriptionZId, Boolean autoRenew) {
		return updateZuoraAutoRenew(customer, subscriptionZId, autoRenew, DateTime.now());
	} 
	
	public static Zuora.zApi.AmendResult updateZuoraAutoRenew(IECCustomer customer, String subscriptionZId, Boolean autoRenew, DateTime dtServiceEffectiveDate) {
		try {
        	if (customer != null) {
            	// create amendment
            	Zuora.zObject amend = new Zuora.zObject('Amendment');
            	amend.setValue('Type', 'TermsAndConditions');
            	amend.setValue('AutoRenew', autoRenew);
            	amend.setValue('Name', 'Autorenew change to ' + autoRenew);
            	amend.setValue('SubscriptionId', subscriptionZId);
            	amend.setValue('Status', 'Completed');
            	amend.setValue('CustomerAcceptanceDate', IECZuoraHelper.getCurrentDate());
            	amend.setValue('ServiceActivationDate', IECZuoraHelper.getFutureDate(dtServiceEffectiveDate));
            	amend.setValue('ContractEffectiveDate', IECZuoraHelper.getFutureDate(dtServiceEffectiveDate));
                                                
            	// create amendment request
            	Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
            	amendRequest.amendOptions = new Zuora.zApi.AmendOptions();
            	amendRequest.amendOptions.generateInvoice = false;
            	amendRequest.amendments = new List<Zuora.zObject>{ amend };
            	
            	return (!Test.isRunningTest())
            		? IECZuoraHelper.amendApiCall(amendRequest)
	            	: IECTestUtil.CreateSampleAmendResult();
        	}
        	else 
	        	throw new IECApplicationException('Invalid User');
    	}
		catch(Exception ex) {
			throw new IECApplicationException('Could not updateZuoraAutoRenew. Error: ' + ex.getMessage());
		}
		
		return null;
 	}    
    
    /**
     * Class used to display payment methods
     */
    public class PaymentMethod {
        
        public String  zId { get; private set; }
        public String  name { get; private set; }
        public String  creditCardHolderName { get; private set; }
        public String  creditCardMaskNumber { get; private set; }
        public String  creditCardType { get; private set; }
        public Integer creditCardExpirationMonth { get; private set; }
        public Integer creditCardExpirationYear { get; private set; }
        public Integer numConsecutiveFailures{get; private set;}
        
        /**
         * Constructor
         */
        public PaymentMethod(Zuora.zObject zPm) {
            zId                         = (String)  zPm.getValue('Id');
            name                        = (String)  zPm.getValue('Name');
            creditCardHolderName        = (String)  zPm.getValue('CreditCardHolderName');
            creditCardMaskNumber        = (String)  zPm.getValue('CreditCardMaskNumber');
            creditCardType              = (String)  zPm.getValue('CreditCardType');
            creditCardExpirationMonth   = (Integer) zPm.getValue('CreditCardExpirationMonth');
            creditCardExpirationYear    = (Integer) zPm.getValue('CreditCardExpirationYear');
            numConsecutiveFailures      = (Integer) zPm.getValue('NumConsecutiveFailures');
        }
    }
    
    /**
     * Class used to display subscribe results
     */
    public class SubscriptionResult {
        
        public String productLabel { get; private set; }
        public Boolean success { get; private set; }
        public String transactionNumber { get; private set; }
        public String subscriptionNumber { get; private set; }
        public String cyberSourceReasonCode { get; private set; }
        public String cyberSourceReasonCodeMessage { get; private set; }
        public List<String> listErrorCodeAndMessage { get; private set; }
        public String appUrl { get; private set; }
        
        /**
         * 1st Constructor
         */
        public SubscriptionResult(Zuora.zApi.SubscribeResult oSubscribeResult, String sProductLabel) {
        	
        	this(oSubscribeResult, sProductLabel, '');
        }
        
        /**
         * 2nd Constructor
         */
        public SubscriptionResult(Zuora.zApi.SubscribeResult oSubscribeResult, String sProductLabel, String sAppURL) {
        	
        	productLabel = sProductLabel;
            success = oSubscribeResult.Success;
            transactionNumber = (String.isNotBlank(oSubscribeResult.PaymentTransactionNumber) ? oSubscribeResult.PaymentTransactionNumber : '');
            subscriptionNumber = (String.isNotBlank(oSubscribeResult.SubscriptionNumber) ? oSubscribeResult.SubscriptionNumber : '');
            appUrl = sAppURL;
            //cyberSourceReasonCode = oSubscribeResult.GatewayResponse;
            //cyberSourceReasonCodeMessage = oSubscribeResult.GatewayResponseCode;
            
            listErrorCodeAndMessage = new List<String>();
            if (oSubscribeResult.Success == false) {
            	for (Zuora.zObject error: oSubscribeResult.errors) {
                    //listErrorCodeAndMessage.add((String)error.getValue('Code') + ' : ' + (String)error.getValue('Message'));
                    parseError(error);
                }
            }
        }
        
        /**
         *
         */
        private void parseError(Zuora.zObject oError) {
        	String sErrorCode = (String)oError.getValue('Code');
        	String sErrorMessage = (String)oError.getValue('Message');
        	
        	if (sErrorCode == 'TRANSACTION_FAILED') {
        		String sReasonCodeMessage = sErrorMessage.substring(0, sErrorMessage.indexOf('.')); 
        		cyberSourceReasonCode = sErrorMessage.substring(sErrorMessage.indexOf('.') + 1, sErrorMessage.indexOf('.') + 4); 
        		listErrorCodeAndMessage.add(sReasonCodeMessage + ' (' + cyberSourceReasonCode + ')');
        	}
        	else {
        		listErrorCodeAndMessage.add(sErrorCode + ' : ' + sErrorMessage);
        	}
        }
    }
    
    /**
	 * Class used to display credit card
	 */
	public class CreditCard {

		public String zId { get; private set; }
		public String Name { get; private set; }
		public String CreditCardType { get; private set; }
		public String CreditCardMaskNumber { get; private set; }
		public String CreditCardCVV { get; set; }
		public Integer ExpirationMonth { get; set; }
		public Integer ExpirationYear { get; set; }
		public String HolderName { get; set; }
		public String Country { get; set; }
		public String AddresLine1 { get; set; }
		public String AddresLine2 { get; set; }
		public String City { get; set; }
		public String StateProvince { get; set; }
		public String PostalCode { get; set; }
		public String AccountId { get; set; }
		public String LastTransactionStatus { get; private set; }
		
		public String htmlColor {
			get {
				if (LastTransactionStatus == '' || LastTransactionStatus == 'undefined')
					return 'black';
				//else if (Status == 'Draft' || Status == 'Pending Activation' || Status == 'Pending Acceptance')
				//	return '#FF9632';	// yellow
				else if (LastTransactionStatus == 'Approved')
					return '#5e9741';	// green
				else
					return 'red';
			}
		}
		
		public CreditCard(Zuora.zObject zCreditCard) {
			zId = (String)zCreditCard.getValue('Id');
			Name = (String)zCreditCard.getValue('Name');
			CreditCardType = (String)zCreditCard.getValue('CreditCardType');
			CreditCardMaskNumber = (String)zCreditCard.getValue('CreditCardMaskNumber');
			ExpirationMonth = (Integer)zCreditCard.getValue('CreditCardExpirationMonth');
			ExpirationYear = (Integer)zCreditCard.getValue('CreditCardExpirationYear');
			HolderName = (String)zCreditCard.getValue('CreditCardHolderName');
			Country = (String)zCreditCard.getValue('CreditCardCountry');
			if (Country != null && Country.length() != 2) {
				Country = IECZuoraHelper.convertCountryNameToCode(Country);
			}
			AddresLine1 = (String)zCreditCard.getValue('CreditCardAddress1');
			AddresLine2 = (String)zCreditCard.getValue('CreditCardAddress2');
			City = (String)zCreditCard.getValue('CreditCardCity');
			StateProvince = (String)zCreditCard.getValue('CreditCardState');
			PostalCode = (String)zCreditCard.getValue('CreditCardPostalCode');
			LastTransactionStatus = (String)zCreditCard.getValue('LastTransactionStatus');
			AccountId = (String)zCreditCard.getValue('AccountId');
		}
		
		public Zuora.zObject toZObjectForUpdate() {
			Zuora.zObject zObj = new Zuora.zObject('PaymentMethod');
			zObj.setValue('Id', zId);
			zObj.setValue('CreditCardExpirationMonth', ExpirationMonth);
			zObj.setValue('CreditCardExpirationYear', ExpirationYear);
			zObj.setValue('CreditCardSecurityCode', CreditCardCVV);
			zObj.setValue('CreditCardHolderName', HolderName);
			zObj.setValue('CreditCardCountry', Country);
			zObj.setValue('CreditCardAddress1', AddresLine1);
			zObj.setValue('CreditCardAddress2', AddresLine2);
			zObj.setValue('CreditCardCity', City);
			zObj.setValue('CreditCardState', StateProvince);
			zObj.setValue('CreditCardPostalCode', PostalCode);
			zObj.setValue('AccountId', AccountId);
			return zObj;
		}
	}
	
	 /**
	 * Class used to display InvoiceItems
	 */
	public class InvoiceItem {
		
		public Datetime chargeDate { get; private set; }
		public String chargeName { get; private set; }
		public Datetime serviceStartDate { get; private set; }
		public Datetime serviceEndDate { get; private set; }
		public Decimal unitPrice { get; private set; }
		public Decimal chargeAmount { get; private set; }
		public Decimal processingType { get; private set; }
		
		/**
		 * Constructor
		 */
		public InvoiceItem(Zuora.zObject zInvoiceItem) {
			chargeDate = zInvoiceItem.getValue('ChargeDate') != null ? (Datetime)zInvoiceItem.getValue('ChargeDate') : null;
			chargeName = zInvoiceItem.getValue('ChargeName') != null ? (String)zInvoiceItem.getValue('ChargeName') : null;
			serviceStartDate = zInvoiceItem.getValue('ServiceStartDate') != null ? (Datetime)zInvoiceItem.getValue('ServiceStartDate') : null;
			serviceEndDate = zInvoiceItem.getValue('ServiceEndDate') != null ? (Datetime)zInvoiceItem.getValue('ServiceEndDate') : null;
			unitPrice = zInvoiceItem.getValue('UnitPrice') != null ? (Decimal)zInvoiceItem.getValue('UnitPrice') : null;
			chargeAmount = zInvoiceItem.getValue('ChargeAmount') != null ? (Decimal)zInvoiceItem.getValue('ChargeAmount') : null;
			processingType = zInvoiceItem.getValue('ProcessingType') != null ? (Decimal)zInvoiceItem.getValue('ProcessingType') : null;
		}
	}
	
	
    public static Zuora.zObject getZuoraAccountById(String zuoraId) {

    	system.debug('Inside getZuoraAccountById(' + zuoraId + ')');
    	
        try {
	        List<Zuora.zObject> accountResult = queryApiCall('select Id,AccountNumber,BillToId,Name,SoldToId from Account where Id = \'' + zuoraId + '\'');
    	    
    	    	
    	    if (accountResult == null || accountResult.size() == 0) {
        	    return null;
        	}
            
        	return accountResult.get(0);
    	} catch(Exception ex) {
    		system.debug('Exception: ' + ex.getMessage());
    		return null;
    	}
    }	
    
    public static Zuora.zObject getZuoraContactById(String zuoraId) {
    	
    	system.debug('Inside getZuoraContactById(' + zuoraId + ')');
        
        try {
        	
        	List<Zuora.zObject> contactResult = queryApiCall('select Id, FirstName, LastName, Address1, Address2, City, Country, PostalCode, State, WorkEmail from Contact where Id = \'' + zuoraId + '\'');
        	if (contactResult == null || contactResult.size() == 0) {
            	return null;
    	    }
            
	        return contactResult.get(0);

    	} catch(Exception ex) {
    		system.debug('Exception: ' + ex.getMessage());
    		return null;
    	}
        
    }	
    
    /* NOT USED
    public static void updateZuoraBillingAccountWithContact(Contact oContact, IECAddress__c oBilling, IECAddress__c oShipping) {

		List<Zuora.zObject> lAccountsToUpdate = new List<Zuora.zObject>();
		List<Zuora.zObject> lContactsToUpdate = new List<Zuora.zObject>();
		String accountsId = oContact.AccountId;
			
		
		//Query the Zuora_CustomerAccounts related to updated Contacts			
		List<Zuora__CustomerAccount__c> lBillingAccounts = new List<Zuora__CustomerAccount__c>([select Zuora__Account__c, Id, Name, Zuora__BillToId__c, Zuora__SoldToId__c, Zuora__Zuora_Id__c 
				from Zuora__CustomerAccount__c 
				where Zuora__Account__c = : accountsId limit 1]);

		//IF a Billing Account exists for given contact, then its information is updated
		if (lBillingAccounts != null && lBillingAccounts.size() > 0) {
			
			Zuora__CustomerAccount__c ba = lBillingAccounts.get(0);
			
			//Get zuoraBillingAccount gor given SF BA
			String zuoraBillingAccountId = ba.Zuora__Zuora_Id__c;
			Zuora.zObject zuoraBA = IECZuoraHelper.getZuoraAccountById(zuoraBillingAccountId);
			
			//Get zuoraBillingContact for given SF BA
			String zuoraBillingContactID = ba.Zuora__BillToId__c;
			Zuora.zObject zuoraBC =  IECZuoraHelper.getZuoraContactById(zuoraBillingContactID);
		
			//Get zuoraShippingContact for given SF BA
			String zuoraShippingContactID = ba.Zuora__SoldToId__c;
			Zuora.zObject zuoraSC = (zuoraBillingContactID !=zuoraShippingContactID) ? IECZuoraHelper.getZuoraContactById(zuoraShippingContactID) : null;
		
			//Update zuoraBillingAccount (if neccesary)
			if (zuoraBA != null) {
				String zuoraAccountName = (String) zuoraBA.getValue('Name');
				if (zuoraAccountName != ba.Name) {
					zuoraBA.setValue('Name', ba.Name);
					lAccountsToUpdate.add(zuoraBA);
				}
			}			
			
			//Update zuoraBillingContact (if neccesary)
			boolean bUpdateBillingContact = false;
			if (zuoraBC != null) {
				
				//Check and Update contact's Name / Last Name
				if ((String) zuoraBC.getValue('FirstName') != oContact.FirstName ||
					(String) zuoraBC.getValue('LastName') != oContact.FirstName ) 
				{
					zuoraBC.setValue('FirstName', oContact.FirstName);
					zuoraBC.setValue('LastName', oContact.FirstName);
					bUpdateBillingContact = true;
				}
				
				//Check and Update contact's Shipping Address
				if ((String) zuoraBC.getValue('Address1') != oBilling.Street__c || 
					(String) zuoraBC.getValue('City') != oBilling.City__c || 
					(String) zuoraBC.getValue('Country') != oBilling.Country__c || 
					(String) zuoraBC.getValue('PostalCode') != oBilling.ZipCode__c || 
					(String) zuoraBC.getValue('State') != oBilling.State__c ) 
				{
					zuoraBC.setValue('Address1',oBilling.Street__c);
					zuoraBC.setValue('City',oBilling.City__c);
					zuoraBC.setValue('Country',oBilling.Country__c);
					zuoraBC.setValue('PostalCode',oBilling.ZipCode__c);
					zuoraBC.setValue('State',oBilling.State__c);
			
					bUpdateBillingContact = true;
				}				
			
			
			
				if (bUpdateBillingContact) 
					lContactsToUpdate.add(zuoraBC);
			}		
			
		
			//Update zuoraShippingContact (if neccesary)
			boolean bUpdateShippingContact = false;
			if (zuoraSC != null) {
				
				//Check and Update contact's Name / Last Name
				if ((String) zuoraSC.getValue('FirstName') != oContact.FirstName ||
					(String) zuoraSC.getValue('LastName') != oContact.FirstName ) 
				{
					zuoraSC.setValue('FirstName', oContact.FirstName);
					zuoraSC.setValue('LastName', oContact.FirstName);
					bUpdateShippingContact = true;
				}
				
				//Check and Update contact's Shipping Address
				if ((String) zuoraSC.getValue('Address1') != oShipping.Street__c || 
					(String) zuoraSC.getValue('City') != oShipping.City__c || 
					(String) zuoraSC.getValue('Country') != oShipping.Country__c || 
					(String) zuoraSC.getValue('PostalCode') != oShipping.ZipCode__c || 
					(String) zuoraSC.getValue('State') != oShipping.State__c ) 
				{
					zuoraSC.setValue('Address1',oShipping.Street__c);
					zuoraSC.setValue('City',oShipping.City__c);
					zuoraSC.setValue('Country',oShipping.Country__c);
					zuoraSC.setValue('PostalCode',oShipping.ZipCode__c);
					zuoraSC.setValue('State',oShipping.State__c);
			
					bUpdateShippingContact = true;
				}				
			
				if (bUpdateShippingContact) 
					lContactsToUpdate.add(zuoraBC);
			}				
		}


		//Push all zuora objects to Zuora
		if (lAccountsToUpdate.size() > 0) {
			List<Zuora.zApi.SaveResult> lAccountsResult = IECZuoraHelper.updateApiCall(lAccountsToUpdate);
		}
		
		if (lContactsToUpdate.size() > 0) {
			List<Zuora.zApi.SaveResult> lContactsResult = IECZuoraHelper.updateApiCall(lContactsToUpdate);
		}
			
			
    		
    }
    */

    /**
    * Retrieve PaymentMethod from a list using the ID
    * @param lstPaymentMethods List of payment methods to query within
    * @param zId Zuora ID of payment method required
    */
    public static PaymentMethod GetPaymentMethodById(List<PaymentMethod> lstPaymentMethods, String zId) {
    	if (String.isEmpty(zId) || lstPaymentMethods == null) return null;
    	
    	for (PaymentMethod pm : lstPaymentMethods) {
    		if (pm.zId == zId)
    			return pm;
    	}
    	
    	return null;
    }
    
	@future (callout=true)
	public static void SyncBillingAccountWithContactDetails(List<String> lstBillingAccountZId, List<String> lstTax1ID, List<String> lstTax2ID) {
    	try {
    		List<Zuora.zObject> lstBillingAccount = new List<Zuora.zObject>();
    		
    		for (integer x = 0; x < lstBillingAccountZId.size(); x++) {
    			Zuora.zObject acc = new Zuora.zObject('Account');

				acc.setValue('Id', lstBillingAccountZId.get(x));
				acc.setValue('Tax1ID__c', (String.isBlank(lstTax1ID.get(x)) ? '' : lstTax1ID.get(x)));
				acc.setValue('Tax2ID__c', (String.isBlank(lstTax2ID.get(x)) ? '' : lstTax2ID.get(x)));
 
    			lstBillingAccount.add(acc);
    		}
    		
    		// perform the update
    		List<Zuora.zApi.SaveResult> lstAccountResult = null;
    		
    		if (!Test.isRunningTest())
    			lstAccountResult = IECZuoraHelper.updateApiCall(lstBillingAccount);
    		else
    			lstAccountResult = new List<Zuora.zApi.SaveResult> { IECTestUtil.createSampleSaveResult(!lstBillingAccount.isEmpty()) };
	    			
			// check for errors
			for (Zuora.zApi.SaveResult result : lstAccountResult) {
				if (result.Success) {
					system.debug('DEBUG CALLOUT - billing account sync success for SaveResult id ' + result.Id);
				}
				else {
					for (Zuora.zObject error: result.errors) {
                        throw new IECApplicationException((String)error.getValue('Code') + ': ' + (String)error.getValue('Message'));
                    }
				}
			}
    	}
    	catch (Exception ex) {
    		throw new IECApplicationException('Could not sync Billing Account With Contact information to Zuora: ' + ex.getMessage());
    	}
	}

	@future (callout=true)
	public static void SyncZuoraContact(List<String> lstContactZId, List<String> lstFirstName, List<String> lstLastName, List<String> lstEmail, List<String> lstPhone) {
    	try {
    		List<Zuora.zObject> lstContact = new List<Zuora.zObject>();
    		
    		for (integer x = 0; x < lstContactZId.size(); x++) {
    			Zuora.zObject con = new Zuora.zObject('Contact');

				con.setValue('Id', lstContactZId.get(x));
		        con.setValue('FirstName', (String.isBlank(lstFirstName.get(x)) ? '' : lstFirstName.get(x)));
		        con.setValue('LastName', (String.isBlank(lstLastName.get(x)) ? '' : lstLastName.get(x)));
		        con.setValue('WorkEmail', (String.isBlank(lstEmail.get(x)) ? '' : lstEmail.get(x)));
		        con.setValue('WorkPhone', (String.isBlank(lstPhone.get(x)) ? '' : lstPhone.get(x)));
 
    			lstContact.add(con);
    		}
    		
    		// perform the update
    		List<Zuora.zApi.SaveResult> lstContactResult = null;
    		
    		if (!Test.isRunningTest())
    			lstContactResult = IECZuoraHelper.updateApiCall(lstContact);
    		else
    			lstContactResult = new List<Zuora.zApi.SaveResult> { IECTestUtil.createSampleSaveResult(!lstContact.isEmpty()) };
	    			
			// check for errors
			for (Zuora.zApi.SaveResult result : lstContactResult) {
				if (result.Success) {
					system.debug('DEBUG CALLOUT - Contact sync success for SaveResult id ' + result.Id);
				}
				else {
					for (Zuora.zObject error: result.errors) {
                        throw new IECApplicationException((String)error.getValue('Code') + ': ' + (String)error.getValue('Message'));
                    }
				}
			}
    	}
    	catch (Exception ex) {
    		throw new IECApplicationException('Could not sync Contact information to Zuora: ' + ex.getMessage());
    	}
	}
    
    /**
	 * Future method to allow the update of contact information in Zuora
	 * @param lstAddressId The list of IECAddress__c Ids
	 */
	@future (callout=true)
	public static void syncAddressInformationWithZuora(List<String> lstAddressId) {
		try {
			// build list of object from list of IDs
			List<IECAddress__c> lstAddresses = [select Name, Contact__c, Address_Type__c, State__c, Street__c, City__c, Country__c, ZipCode__c from IECAddress__c where Id IN :lstAddressId];
			
			// sync
			if (lstAddresses != null && lstAddresses.size() > 0)
				syncBillingOrShippingAddress(lstAddresses);
		}
		catch (Exception ex) {
			system.debug('ERROR - IECZuoraHelper.syncAddressInformationWithZuora() : ' + ex.getMessage());
		}
	}
    
    /**
     * Syncs the contact address to the appropriate Zuora contact (billing or shipping)
     * @param lstAddress The IECAddress__c object containing the new information to sync
     */
    public static void syncBillingOrShippingAddress(List<IECAddress__c> lstAddress) {
    	try {
    		List<Zuora.zObject> lstAddressToUpdate = new List<Zuora.zObject>();
    		
    		for (IECAddress__c oAddress : lstAddress) {
    			
	    		if (oAddress.Contact__c == null)
	    			continue;
	    		
	    		// get related Contact
	    		Contact oRelatedContact = IECUserManager.getContactById(oAddress.Contact__c);
	    		if (oRelatedContact == null)
	    			throw new IECApplicationException('Contact with id ' + oAddress.Contact__c + ' not found.');
	    		
	    		// get related Billing Account
	    		Zuora__CustomerAccount__c oBillingAccount = getBillingAccountByContactId(oRelatedContact.Id);
	    		
	    		Zuora.zObject zContact = null;
	    		if (oAddress.Address_Type__c == IECConstants.IECAddress_AddressType_Billing) {
	    			zContact = createZuoraBillToContact(oRelatedContact);
	    			zContact.setValue('Id', oBillingAccount.Zuora__BillToId__c);
	    		}
	    		else if (oAddress.Address_Type__c == IECConstants.IECAddress_AddressType_Shipping) {
	    			zContact = createZuoraSoldToContact(oRelatedContact);
	    			zContact.setValue('Id', oBillingAccount.Zuora__SoldToId__c);
	    		}
	    		
	    		if (zContact != null)
	    			lstAddressToUpdate.add(zContact);
    		}
    		
    		// perform the update
    		List<Zuora.zApi.SaveResult> lstContactUpdateResult =null;
    		
    		if (!Test.isRunningTest())
    			lstContactUpdateResult = IECZuoraHelper.updateApiCall(lstAddressToUpdate);
    		else
    			lstContactUpdateResult = new List<Zuora.zApi.SaveResult> { IECTestUtil.createSampleSaveResult(!lstAddress.isEmpty()) };
	    			
			// check for errors
			for (Zuora.zApi.SaveResult result : lstContactUpdateResult) {
				if (result.Success) {
					system.debug('DEBUG CALLOUT - address sync success for SaveResult id ' + result.Id);
				}
				else {
					for (Zuora.zObject error: result.errors) {
                        throw new IECApplicationException((String)error.getValue('Code') + ': ' + (String)error.getValue('Message'));
                    }
				}
			}
    	}
    	catch (Exception ex) {
    		throw new IECApplicationException('Could not sync address information to Zuora: ' + ex.getMessage());
    	}
    }
    
    /**
     * Returns the Billing Account related to a Contact (if any)
     * @param contactId The Contact Id (full 18 characters)
     * @return The Salesforce object representing the Zuora Billing Account or null if not found
     */
    public static Zuora__CustomerAccount__c getBillingAccountByContactId(Id idContact) {
    	Map<Id, Zuora__CustomerAccount__c> mapContactIdToBillingAccount = getBillingAccountByContactId(new Set<Id> {idContact});
    	return (mapContactIdToBillingAccount == null || mapContactIdToBillingAccount.size() == 0) ? null : mapContactIdToBillingAccount.values().get(0); 
    }

    public static Map<Id, Zuora__CustomerAccount__c> getBillingAccountByContactId(Set<Id> setContactId) {
    	Map<Id, Zuora__CustomerAccount__c> mapContactIdToBillingAccount = new Map<Id, Zuora__CustomerAccount__c>();
    	for (Zuora__CustomerAccount__c zAcc :
    		[SELECT CRMContactID__c
                , Contact__c
                , Zuora__BillToId__c
                , Zuora__SoldToId__c
                , eBroadcast_Product_Access__c
    			, Zuora__Zuora_Id__c
                , Id
     		FROM Zuora__CustomerAccount__c
     		WHERE CRMContactID__c IN :setContactId]) {
			
			mapContactIdToBillingAccount.put(zAcc.Contact__c, zAcc);
		}

    	return (mapContactIdToBillingAccount.size() == 0) ? null : mapContactIdToBillingAccount;
    }
    
    /**
     * Query Zuora to return a PaymentMethod by its id
     * @param sPaymentMethodZuoraId The Zuora Id of the payment method
     * @return A Zuora.zObject representing the PaymentMethod
     */
    public static Zuora.zObject getZuoraPaymentMethodById(String sPaymentMethodZuoraId) {
        try {
            if (String.isBlank(sPaymentMethodZuoraId))
            	return null;
            	
            Zuora.zObject paymentMethod = null;
            
            // if not in test method
            if (!Test.isRunningTest()) {
                List<Zuora.zObject> paymentMethods = IECZuoraHelper.queryApiCall('select Id,Active,Name,CreditCardAddress1,CreditCardAddress2,CreditCardCity,CreditCardCountry,CreditCardExpirationMonth,CreditCardExpirationYear,CreditCardHolderName,CreditCardMaskNumber,CreditCardType,LastTransactionStatus,Type from PaymentMethod where Id = \'' + sPaymentMethodZuoraId + '\'');
                if (paymentMethods ==null || paymentMethods.isEmpty())
                	return null;
                else
                	paymentMethod = paymentMethods.get(0);
            }
            // in test method
            else
                paymentMethod = IECTestUtil.createSampleZuoraPaymentMethod('2sdf98sa7ergsdf98g731l12lkj3', 'A0987654321', 2018, 6);
             
            return paymentMethod;
        } 
        catch (Exception e) {
            throw new IECApplicationException('Could not retreive Payment Methods with Id ' + sPaymentMethodZuoraId + '. Error: ' + e.getMessage());
        }
    }
    
    /**
     * Query Zuora to return a Subscription by its id
     * @param sSubscriptionZuoraId The Zuora Id of the subscription
     * @return A Zuora.zObject representing the Subscription
     */
    public static Zuora.zObject getZuoraSubscriptionById(String sSubscriptionZuoraId) {
        try {
            if (String.isBlank(sSubscriptionZuoraId))
            	return null;
            	
            Zuora.zObject zSubscription = null;
            
            // if not in test method
            if (!Test.isRunningTest()) {
                List<Zuora.zObject> lstSubscriptions = IECZuoraHelper.queryApiCall('select Id, AutoRenew, ContractAcceptanceDate, ContractEffectiveDate, Name, OriginalId, PreviousSubscriptionId, ServiceActivationDate, Status, SubscriptionEndDate, SubscriptionStartDate, TermEndDate, TermStartDate from Subscription where Id = \'' + sSubscriptionZuoraId + '\'');
                if (lstSubscriptions == null || lstSubscriptions.isEmpty())
                	return null;
                else
                	zSubscription = lstSubscriptions.get(0);
            }
            // in test method
            else
                zSubscription = IECTestUtil.createSampleZuoraSubscription('A-S00001014', Datetime.now(), 1, 'Active');
             
            return zSubscription;
        } 
        catch (Exception e) {
            throw new IECApplicationException('Could not retreive Subscription with Id ' + sSubscriptionZuoraId + '. Error: ' + e.getMessage());
        }
    }
    
    /**
     * Query Zuora to return a list of Subscriptions by its Number
     * @param sSubscriptionNumber The Subscription Number
     * @return A Zuora.zObject representing the Subscription
     */
    public static List<Zuora.zObject> getZuoraSubscriptionsByNumber(String sSubscriptionNumber) {
        try {
            if (String.isBlank(sSubscriptionNumber))
            	return null;

            // if not in test method
            if (!Test.isRunningTest()) {
                List<Zuora.zObject> lstSubscriptions = IECZuoraHelper.queryApiCall('select Id, AutoRenew, ContractAcceptanceDate, ContractEffectiveDate, Name, OriginalId, PreviousSubscriptionId, ServiceActivationDate, Status, SubscriptionEndDate, SubscriptionStartDate, TermEndDate, TermStartDate, Version from Subscription where Name = \'' + sSubscriptionNumber + '\'');
                if (lstSubscriptions == null || lstSubscriptions.isEmpty())
                	return null;
                else
                	return lstSubscriptions;
            }
            // in test method
            else
                return new List<Zuora.zObject> { IECTestUtil.createSampleZuoraSubscription('A-S0000420', Datetime.now(), 1, 'Active'),
                	 							 IECTestUtil.createSampleZuoraSubscription('A-S0000420', Datetime.now().addDays(5), 2, 'Active')};
        } 
        catch (Exception e) {
            throw new IECApplicationException('Could not retreive Subscription with Id ' + sSubscriptionNumber + '. Error: ' + e.getMessage());
        }
    }
    
    public static Zuora.zObject CreateZuoraPayment(String sAccZID, String sInvoiceZID, String sPmtMethod, Decimal dAmountPaid, DateTime dtEffective, String sSISInvoiceNumber) {
    	Zuora.zObject pmt = new Zuora.zObject('Payment');
    	pmt.setValue('AccountId', sAccZID);
    	pmt.setValue('Amount', dAmountPaid);
    	pmt.setValue('AppliedInvoiceAmount', dAmountPaid);
    	pmt.setValue('EffectiveDate', getFutureDate(dtEffective));
    	pmt.setValue('InvoiceId', sInvoiceZID);
    	pmt.setValue('PaymentMethodId', ((sPmtMethod == 'ICH') ? IECConstants.PaymentMethod_ICH_ZuoraID : IECConstants.PaymentMethod_BankTransfer_ZuoraID));
    	pmt.setValue('SISInvoiceNumber__c', ((sPmtMethod == 'ICH') ? sSISInvoiceNumber : ''));
    	pmt.setValue('Status', 'Processed');
    	pmt.setValue('Type', 'External');
    	
    	return pmt;
    }
    
	/**
	 * Update the Zuora Subscription PO field
	 * Note: this is not in a future mode to be able to work with changes done during checkout process
	 */
    public static void UpdateSubscriptionPO(String sSubscriptionZId, String sPurchaseOrder) {
		try {
			if (String.isNotBlank(sSubscriptionZId)) {
    			Zuora.zObject sub = new Zuora.zObject('Subscription');
				sub.setValue('Id', sSubscriptionZId);
				sub.setValue('PurchaseOrder__c', sPurchaseOrder);
	    		
	    		// perform the update
	    		Zuora.zApi.SaveResult result = null;
	    		
	    		if (!Test.isRunningTest())
	    			result = IECZuoraHelper.updateApiCall(sub);
	    		else
	    			result = IECTestUtil.createSampleSaveResult(true);
		    			
				// check for errors
				if (result.Success) {
					system.debug('DEBUG CALLOUT - subscription PO update success for SaveResult id ' + result.Id);
				}
				else {
					for (Zuora.zObject error: result.errors) {
                        throw new IECApplicationException((String)error.getValue('Code') + ': ' + (String)error.getValue('Message'));
                    }
				}
	    	}
		}
    	catch (Exception ex) {
    		throw new IECApplicationException('Could not update Subscription PO in Zuora: ' + ex.getMessage());
    	}
    }

	@future (callout=true)
	public static void UpdateSubscriptionPO(List<String> lstSubscriptionZId, String sPurchaseOrder) {
		try {
			if (!lstSubscriptionZId.isEmpty()) {
	    		List<Zuora.zObject> lstSubscription = new List<Zuora.zObject>();
	    		
	    		for (String sSubZId : lstSubscriptionZId) {
	    			Zuora.zObject sub = new Zuora.zObject('Subscription');
					sub.setValue('Id', sSubZId);
					sub.setValue('PurchaseOrder__c', sPurchaseOrder);
	     			lstSubscription.add(sub);
	    		}
	    		
	    		// perform the update
	    		List<Zuora.zApi.SaveResult> results = null;
	    		
	    		if (!Test.isRunningTest())
	    			results = IECZuoraHelper.updateApiCall(lstSubscription);
	    		else
	    			results = new List<Zuora.zApi.SaveResult> { IECTestUtil.createSampleSaveResult(!lstSubscription.isEmpty()) };
		    			
				// check for errors
				for (Zuora.zApi.SaveResult result : results) {
					if (result.Success) {
						system.debug('DEBUG CALLOUT - subscription PO update success for SaveResult id ' + result.Id);
					}
					else {
						for (Zuora.zObject error: result.errors) {
	                        throw new IECApplicationException((String)error.getValue('Code') + ': ' + (String)error.getValue('Message'));
	                    }
					}
				}
	    	}
		}
    	catch (Exception ex) {
    		throw new IECApplicationException('Could not update Subscription PO in Zuora: ' + ex.getMessage());
    	}
	}
}