public class AMS_AddressHelper {

	//FM 14-10-2015 - INC:10933
	public static void updateBillingShippingAddressesOnAccount(List<AMS_Address__c> news){
		List<Id> agencyIds = new List<Id>();
		List<Id> addressIds = new List<Id>();

		for(AMS_Address__c add : news){
			agencyIds.add(add.Account__c);
			addressIds.add(add.Id);
		}
		Map<Id,AMS_Address__c> addWithCountryState = new Map<Id,AMS_Address__c>(
													[SELECT Country__r.ISO_code__c,Country__r.Name, Country__r.AIMS_Area_Name__c,State__r.Name, State__r.ISO_Code__c, TTY__c,
													 State__c, Website__c, Email__c, Telephone_Int__c, Telephone_STD__c, Telephone__c, Fax_Int__c, Fax_STD__c, Fax__c,
													 Address_1__c, Address_2__c, Address_3__c, City__c, AMS_ZipCode__c, Address_Type__c
													 FROM AMS_Address__c WHERE Id IN :addressIds]);

		Map<Id,Account> mapAgencies = new Map<Id,Account>([SELECT Id,TTY__c, BillingStreet, BillingPostalCode, BillingCity, BillingState, BillingCountry,
																	   ShippingStreet, ShippingPostalCode, ShippingCity, ShippingState, ShippingCountry,
																	   Iso_State__c
																	   FROM Account
																	   WHERE Id IN :agencyIds]);

		Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
		for(AMS_Address__c add : news){
			AMS_Address__c addCS = addWithCountryState.get(add.id);
			Account theAgency = mapAgencies.get(add.Account__c);

			if(theAgency!=null){
				if(add.Address_Type__c.contains('Shipping') )
					theAgency = copyShippingAddressInfo(theAgency, addCS);
				if(add.Address_Type__c.contains('Billing') )
					theAgency = copyBillingAddressInfo(theAgency, addCS);
				if(add.Address_Type__c.contains('Primary') )
					theAgency = copyBillingAddressInfo(theAgency, addCS);

				//theAgency.Primary_address__c = add.id;
				if(accountsToUpdate.get(theAgency.id)==null)
					accountsToUpdate.put(theAgency.id, theAgency);
			}
		}
		update accountsToUpdate.values();

	}
	//FM 14-10-2015 - END

	public static Account copyBillingAddressInfo(Account theAccount, AMS_Address__c add){
		if(theAccount==null)return null;
		theAccount.BillingStreet = (add.Address_1__c==null?'':add.Address_1__c + ' ')  +
								   (add.Address_2__c==null?'':add.Address_2__c + ' ')  +
								   (add.Address_3__c==null?'':add.Address_3__c) ;
		theAccount.BillingCity = add.City__c;
		theAccount.BillingCountry = add.Country__r.Name;
		//theAccount.BillingState = addCS.State__r.Name;
		theAccount.BillingState = getValideState(add);
		theAccount.BillingPostalCode = add.AMS_ZipCode__c;
		if(add.Address_Type__c.contains('Primary')){
			theAccount.TTY__c = add.TTY__c;
		}
		theAccount.website =   add.Website__c;
		theAccount.Email__c=   add.Email__c;
		theAccount.Phone=   (add.Telephone_Int__c == null?'':add.Telephone_Int__c+' ')
									+ (add.Telephone_STD__c==null?'':add.Telephone_STD__c)
									+ (add.Telephone__c==null?'':add.Telephone__c);
		theAccount.Fax=   (add.Fax_Int__c==null?'':add.Fax_Int__c + ' ')
									+ (add.Fax_STD__c==null?'':add.Fax_STD__c)
									+ (add.Fax__c==null?'':add.Fax__c);

		return theAccount;
	}

	public static Account copyShippingAddressInfo(Account theAccount, AMS_Address__c add){
		if(theAccount==null)return null;
		theAccount.ShippingStreet = (add.Address_1__c==null?'':add.Address_1__c + ' ')  +
								   (add.Address_2__c==null?'':add.Address_2__c + ' ')  +
								   (add.Address_3__c==null?'':add.Address_3__c) ;
		theAccount.ShippingCity = add.City__c;
		theAccount.ShippingCountry = add.Country__r.Name;
		theAccount.ShippingState = getValideState(add);
		theAccount.ShippingPostalCode = add.AMS_ZipCode__c;

		return theAccount;
	}


	public static String getValideState(AMS_Address__c add){
		if((add.State__c != null && add.Country__c != null) && (add.State__r.Name == add.Country__r.AIMS_Area_Name__c || add.State__r.Name == add.State__r.ISO_Code__c || add.State__r.Name == add.Country__r.ISO_Code__c))
			return '';
		else
			return add.State__r.Name;
	}

}
