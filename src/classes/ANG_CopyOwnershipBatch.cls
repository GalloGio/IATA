global class ANG_CopyOwnershipBatch implements Database.Batchable<sObject>, Database.Stateful {

	List<String> idlist = new List<String>();
	Case saamCase = new Case();
	Map<String, IATA_ISO_Country__c> isoCountryMap = new Map<String, IATA_ISO_Country__c>();
	String heIataCode;
	List<AMS_Accreditation_Contact__c> contacts = new List<AMS_Accreditation_Contact__c>();

	public ANG_CopyOwnershipBatch(String strParam, Case cse, Map<String, IATA_ISO_Country__c> cMap, String heCode, List<AMS_Accreditation_Contact__c> contactsList) {
		idlist = strParam.split(',');
		saamCase = cse;
		isoCountryMap = cMap;
		heIataCode = heCode;
		contacts = contactsList;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([SELECT Id, Name, TradeName__c, IATACode__c, ANG_Accreditation_Model__c,
										 BillingStreet, BillingCity, BillingState, BillingCountry, Email__c,
										 Website, Phone, Mobile__c, Fax, BillingPostalCode, Company_Type__c,
										 Country_ISO_Code__c, VAT_Number__c, Short_Name__c, Location_Class__c,
										 Location_Type__c, IATA_ISO_Country__c, Iso_State__c, ShippingCountry,
										 ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity,
										 Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c,
										 Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Sector__c, Category__c,
										 License_Number__c, GDS__c, Site,
										 IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_State__c
										 FROM Account
										 WHERE Id =: idlist]);
	}

	global void execute(Database.BatchableContext BC, List<Account> scope) {

		List<String> formsToCopyTo = new List<String>();
		List<AMS_Pax_Accreditation_Form__c> formsToInsert = new List<AMS_Pax_Accreditation_Form__c>();
		List<String> accsWithForms = new List<String>();
		List<String> existingFormsIds = new List<String>();
		List<AMS_Accreditation_Contact__c> contactsToInsert = new List<AMS_Accreditation_Contact__c>();

		for(AMS_Pax_Accreditation_Form__c accForm : [SELECT Id, IATACode__c, HO_Account__c
													 FROM AMS_Pax_Accreditation_Form__c
													 WHERE RecordTypeId =: RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Annual_Revalidation')
													 AND Status__c =: 'InProgress'
													 AND SAAM_Case__c =: saamCase.Id
													 AND HO_Account__c =: scope]){
														 accsWithForms.add(accForm.HO_Account__c);
														 existingFormsIds.add(accForm.Id);
													 }

		List<AMS_Accreditation_Contact__c> contactsToDelete = [SELECT Id
															   FROM AMS_Accreditation_Contact__c
															   WHERE AMS_Pax_Accreditation_Form__c =: existingFormsIds];
		if(contactsToDelete.size() > 0) {
			delete contactsToDelete;
		}

		System.debug('scope ' + scope);
		System.debug('accs with forms ' + accsWithForms);
		System.debug('idlist' + idlist);

		for(Account a : scope) {
			System.debug(accsWithForms.contains(a.Id));
			if(!accsWithForms.contains(a.Id)) {

				AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();

				newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Annual_Revalidation');

				newForm.SAAM_Case__c = saamCase.Id;

				if(a.Sector__c.equalsIgnoreCase(AMS_Utils.SECTOR_PASSENGER))
					newForm.Operation_Type__c = 'Travel_Agent';
				else
					newForm.Operation_Type__c = 'Cargo_Agent';

				if (saamCase.IFAP_Country_ISO__c == 'CN' && a.Sector__c.equalsIgnoreCase(AMS_Utils.SECTOR_PASSENGER)) {
					if (a.Category__c == 'Domestic Agent') {
						newForm.Operation_Type__c = 'Travel_Agent - Domestic';
						newForm.Local_Agent_Type__c = 'Domestic';
					} else {
						newForm.Operation_Type__c = 'Travel_Agent - International';
						newForm.Local_Agent_Type__c = 'International';
					}
				}

				newForm.HO_Account__c = a.Id;

				IATA_ISO_Country__c isoCountry = isoCountryMap.get(a.Country_ISO_Code__c);

				Map<String, String> mapAccountToAccrFormFields;

				mapAccountToAccrFormFields = new Map<String, String> {'Name' => 'Account_Name__c', 'IATACode__c' => 'IATACode__c', 'Short_Name__c' => 'Short_Name__c',
					'Location_Class__c' => 'Location_Class__c', 'Location_Type__c' => 'Location_Type__c', 'TradeName__c' => 'Trade_Name__c',
					'BillingStreet' => 'Branch_Office_Street_name_number__c', 'BillingPostalCode' => 'Branch_Office_Postal_code__c', 'BillingState' => 'State_Province__c', 'BillingCity' => 'Branch_Office_City__c',
					'IATA_ISO_Country__c' => 'ISO_Country__c', 'IATA_ISO_Country__c' => 'Branch_Office_Country__c', 'Iso_State__c' => 'IATA_ISO_State__c', 'ShippingCountry' => 'Shipping_Country__c', 'ShippingStreet' => 'Shipping_Street__c',
					'ShippingPostalCode' => 'Shipping_Postal_Code__c', 'ShippingState' => 'Shipping_State__c', 'ShippingCity' => 'Shipping_City__c', 'Email__c' => 'Branch_Office_Email__c',
					'Website' => 'Website__c', 'Phone' => 'Branch_Office_Phone__c', 'Fax' => 'Branch_Office_FAX__c', 'Mobile__c' => 'Mobile__c', 'Abbreviated_name__c' => 'Abbreviated_name__c',
					'Abbreviated_Address__c' => 'Abbreviated_Address__c', 'Remittance_frequency__c' => 'Remittance_frequency__c', 'Solicitation_Flag__c' => 'Solicitation_Flag__c',
					'VAT_Number_2__c' => 'VAT_Number_2__c', 'CASS_Number__c' => 'CASS_Number__c', 'VAT_Number__c' => 'ISSP_AMS_VAT_number__c', 'ANG_Accreditation_Model__c' => 'ANG_Accreditation_type__c',
					'License_Number__c' => 'ISSP_AMS_License_No__c', 'GDS__c' => 'ISSP_AMS_GDS_with_signed_contract__c', 'IATA_ISO_Shipping_Country__c' => 'Shipping_ISO_Country__c',
					'IATA_ISO_Shipping_State__c' => 'Shipping_ISO_State__c', 'Company_Type__c' => 'ISSP_AMS_Legal_Status__c'
					};

						for (String accountApiName : mapAccountToAccrFormFields.keyset()) {
							newForm.put(mapAccountToAccrFormFields.get(accountApiName), a.get(accountApiName));
						}

				if (isoCountry.EU_Country__c) {
					if (a.VAT_Number__c != null)
						newForm.ISSP_AMS_VAT_number_input__c = a.VAT_Number__c.substring(2);
					if (a.VAT_Number_2__c != null)
						newForm.ISSP_AMS_VAT_number_2_input__c = a.VAT_Number_2__c.substring(2);
				} else {
					newForm.ISSP_AMS_VAT_number_input__c = a.VAT_Number__c;
					newForm.ISSP_AMS_VAT_number_2_input__c = a.VAT_Number_2__c;
				}

				newform.Website__c = a.Website;
				newForm.Branch_Office_Phone_National__c = a.Phone;
				newForm.MobileNational__c = a.Mobile__c;
				newForm.Branch_Office_Fax_National__c = a.FAX;

				newForm.Scope_of_Change__c = (a.IataCode__c == heIataCode) ? 'HO Only' : 'Selected Branches Only'; //Set default
				newForm.Is_change_legal_name__c = true;
				newForm.Is_change_location__c = true;
				newForm.Is_change_ownership_or_shareholding__c = true;

				newForm.IataCode__c = a.IataCode__c;

				newForm.ISSP_AMS_Legal_Status__c = ISSP_AMS_Accreditation.mapCompanyTypes(a.Company_Type__c);

				if(newForm.ISSP_AMS_Legal_Status__c == null) {
					newForm.ISSP_AMS_Legal_Status__c = '';
				}

				newForm.Status__c = 'InProgress';
				newForm.Notify_Change_Ownership__c = true;

				formsToInsert.add(newForm);
			}
		}
		insert formsToInsert;
		for(AMS_Pax_Accreditation_Form__c form : formsToInsert) {
			formsToCopyTo.add(form.Id);
		}
		formsToCopyTo.addall(existingFormsIds);

		for(String formId : formsToCopyTo) {
			for(AMS_Accreditation_Contact__c contact : contacts) {
				AMS_Accreditation_Contact__c clonedRecord = contact.clone();
				clonedRecord.AMS_Pax_Accreditation_Form__c = formId;
				contactsToInsert.add(clonedRecord);
			}
		}

		insert contactsToInsert;
	}

	global void finish(Database.BatchableContext BC) {
	}
}
