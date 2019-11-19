public without sharing class PortalRegistrationThirdLevelLMSCtrl {
	public PortalRegistrationThirdLevelLMSCtrl() {

	}

	public class returnWrapper{
		@AuraEnabled
		public String userInfo {get;set;}
	}
	public class RegistrationResult{
		@AuraEnabled
		public Boolean isSuccess{get;set;}
		@AuraEnabled
		public String message{get;set;}
	}

	@AuraEnabled
	public static Training_Contact_Role_Details__c getLMSContactInfo(String lms) {
		User loggedUser = CSP_Utils.getLoggedUser();

		String RECTYPE_lms = '';
		String RECTYPE_Trainee_YASContDet = RecordTypeSingleton.getInstance().getRecordTypeId('Training_Contact_Role_Details__c', 'Yardstick_Trainee');

		if(lms == 'yas'){
			RECTYPE_lms = RECTYPE_Trainee_YASContDet;
		}

		Training_Contact_Role_Details__c tcrd = new Training_Contact_Role_Details__c();


		List<Training_Contact_Role_Details__c> con = [SELECT Id, Username__c, UserId__c, Preferred_Course__c, RecordTypeId
														FROM Training_Contact_Role_Details__c
														WHERE Account_Contact_Role__r.Contact__c = :loggedUser.contactId
														LIMIT 1];

		if(con.isEmpty()){
			return null;
		}

		return con[0];
	}

	@AuraEnabled
	public static returnWrapper getParameters(String urlExtension){
		returnWrapper result  = new returnWrapper();
		PageReference pageRef = new PageReference(urlExtension);
		String parameters     = pageRef.getParameters().get('c');
		parameters            = Encodingutil.urlDecode(PortalPasswordHandler.DecryptString(parameters), 'UTF-8');


		System.debug('pageRef.getParameters().get(c): ' + pageRef.getParameters().get('c'));
		System.debug('parameters: ' + parameters);

		//get registration information
		UserInformationWrapper registrationParameters = (UserInformationWrapper) JSON.deserialize(parameters, UserInformationWrapper.class);

		System.debug('registrationParameters: ' + registrationParameters);
		System.debug('registrationParameters.Additional_Email: ' + registrationParameters.Additional_Email);
		System.debug('registrationParameters.Email: ' + registrationParameters.Email);
		registrationParameters.Additional_Email = registrationParameters.Additional_Email.replace('@@##', '+');
		registrationParameters.Email = registrationParameters.Email.replace('@@##', '+');
		System.debug('registrationParameters.Additional_Email: ' + registrationParameters.Additional_Email);
		System.debug('registrationParameters.Email: ' + registrationParameters.Email);
		result.userInfo = JSON.serialize(registrationParameters);


		return result;
	}

	@AuraEnabled
	public static RegistrationResult registration(Contact con, List<String> extraValues){

		// System.debug('ACCOUNT : ' + acc);
		// Boolean success = OneId_RegistrationProcessController.registration(acc,con, 'ISSP', true);

		// if(!success){
		//     return false;
		// }
		RegistrationResult result = new RegistrationResult();
		Savepoint sp = Database.setSavepoint();

		try{
			System.debug('[PortalRegistrationThirdLevelLMSCtrl] registration : INIT ');
			System.debug('[PortalRegistrationThirdLevelLMSCtrl] registration : extraValues : ' + extraValues);
			System.debug('[PortalRegistrationThirdLevelLMSCtrl] registration : con : ' + con);

			String sUsername = extraValues[0];
			String sUserId = extraValues[1];
			String sCourse = extraValues[2];
			String sStreet = extraValues[3];
			String sZipCode = extraValues[4];
			String sCountryId = extraValues[5];
			String sStateId = (extraValues[6] != null && extraValues[6] != '') ? extraValues[6] : extraValues[7];
			String sStateName = extraValues[7];
			String sCityId = extraValues[8];
			String sCity = extraValues[9];
			Boolean isPoBox = Boolean.valueOf(extraValues[10]);
			String serviceid = extraValues[11];
			String sStreet2 = extraValues[12];

			System.debug('CHECK sStreet2: ' + sStreet2);

			String RECTYPE_Master_AccRole = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');
			String RECTYPE_Master_AccContRole = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Master');
			// String RECTYPE_Trainee_YASContDet = RecordTypeSingleton.getInstance().getRecordTypeId('Yardstick_Contact_Details__c', 'Yardstick_Trainee');
			String RECTYPE_Trainee_YASContDet = RecordTypeSingleton.getInstance().getRecordTypeId('Training_Contact_Role_Details__c', 'Yardstick_Trainee');


			List<Address__c> listAddr = [SELECT City_Reference__c, City__c, Country_Reference__c, Country__c,
											Id,PO_Box__c,Postal_Code__c,State_Reference__c,State__c,Street__c, Street2__c
										FROM Address__c
										WHERE Id = :con.Shipping_Address__c LIMIT 1];
			Address__c addr = new Address__c();

			//Check State
			if(sStateId != ''){
				List<IATA_ISO_State__c> listStates = [SELECT Id,ISO_Code__c,Name,Valid_for_Address__c
										FROM IATA_ISO_State__c
										WHERE Id = :sStateId
										OR ISO_Code__c = :sStateId LIMIT 1];
				if(listStates.size() > 0){
					addr.State_Reference__c = listStates[0].Id;
					addr.State__c = listStates[0].Name;
				}else{
					addr.State__c = sStateId;
				}
			}

			addr.PO_Box__c = isPoBox;
			addr.Street__c = (sStreet != null) ? sStreet : '';
			addr.Street2__c = (sStreet2 != null) ? sStreet2 : '';
			addr.Postal_Code__c = (sZipCode != null) ? sZipCode : '';
			addr.Country_Reference__c = (sCountryId != null && sCountryId != '') ? sCountryId : null;
			addr.City_Reference__c = (sCityId != null && sCityId != '') ? sCityId : null;
			addr.City__c = (sCity != null && sCity != '') ? sCity : null;
			addr.Type__c = 'Shipping';

			if(listAddr.size() > 0){
				System.debug('Address__c already exists, update!!!');
				addr.Id = listAddr[0].Id;

				update addr;
			}else{
				System.debug('NEW Account_Role__c!!!');

				insert addr;
			}

			con.Shipping_Address__c = addr.Id;

			//Update Contact
			update con;

			//Create Account Role if not existing

			List<Account_Role__c> listAR = [SELECT Id,Account__c,RecordTypeId FROM Account_Role__c WHERE Account__c = :con.AccountId AND Account_Role_Name__c = 'Yardstick' LIMIT 1];
			Account_Role__c ar = new Account_Role__c();

			if(listAR.size() > 0){
				System.debug('Account_Role__c already exists!!!');
				ar = listAR[0];
			}else{
				System.debug('NEW Account_Role__c!!!');
				ar.Account__c = con.AccountId;
				ar.RecordTypeId = RECTYPE_Master_AccRole;
				ar.Account_Role_Name__c =  'Yardstick';
				insert ar;
			}
			System.debug('Account_Role__c - ar: ' + ar);

			//Create Account Contact Role if not existing
			List<Account_Contact_Role__c> listACR = [SELECT Id,Account_Role__c,Contact__c,Contact_Role_Name__c,RecordTypeId FROM Account_Contact_Role__c WHERE Contact__c = :con.Id AND Contact_Role_Name__c = 'Yardstick' LIMIT 1];
			Account_Contact_Role__c acr = new Account_Contact_Role__c();

			if(listACR.size() > 0){
				System.debug('Account_Contact_Role__c already exists!!!');
				acr = listACR[0];
			}else{
				System.debug('NEW Account_Contact_Role__c!!!');
				acr.Account_Role__c = ar.Id;
				acr.Contact__c = con.Id;
				acr.Contact_Role_Name__c = 'Yardstick';
				acr.RecordTypeId = RECTYPE_Master_AccContRole;
				acr.Service_Rendered__c = 'Other';

				insert acr;
			}
			System.debug('Account_Contact_Role__c - acr: ' + acr);

			//Create Yardstick Contact Role Detail
			List<Training_Contact_Role_Details__c> listYCD = [SELECT Id,RecordTypeId,Account_Contact_Role__c,Username__c,UserId__c,Preferred_Course__c FROM Training_Contact_Role_Details__c WHERE Account_Contact_Role__c = :acr.Id LIMIT 1];
			Training_Contact_Role_Details__c ycd = new Training_Contact_Role_Details__c();

			if(listYCD.size() > 0){
			   System.debug('Training_Contact_Role_Details__c already exists!!!');
				 ycd = listYCD[0];
				ycd.Username__c = sUsername;
				ycd.UserId__c = sUserId;
				ycd.Preferred_Course__c = sCourse;

				update ycd;

			}else{
				System.debug('NEW Training_Contact_Role_Details__c!!!');
				ycd.Account_Contact_Role__c = acr.Id;
				ycd.RecordTypeId = RECTYPE_Trainee_YASContDet;
				ycd.Username__c = sUsername;
				ycd.UserId__c = sUserId;
				ycd.Preferred_Course__c = sCourse;

				insert ycd;
			}
			System.debug('Training_Contact_Role_Details__c - ycd: ' + ycd);

			//Create Portal Application Right
			Portal_Applications__c pa = [SELECT Id, Name FROM Portal_Applications__c WHERE Name = 'Training Platform (LMS)' LIMIT 1];

		   	//Create ToS Acceptance
			createToSAcceptance(pa.id, con.Id);

			List<Portal_Application_Right__c> listPAR = [SELECT Id,Portal_Application__c,Right__c,Contact__c,Favourite_Service__c FROM Portal_Application_Right__c WHERE Contact__c = :con.Id AND Portal_Application__c = :pa.id LIMIT 1];
			Portal_Application_Right__c portalApplicationRight = new Portal_Application_Right__c();

			if(listPAR.size() > 0){
				portalApplicationRight = listPAR[0];
			}else{
				portalApplicationRight = new Portal_Application_Right__c(
							Portal_Application__c = pa.id,
							Right__c = 'Access Granted',
							Contact__c = con.Id,
							Favourite_Service__c = true
						);
				insert portalApplicationRight;
			}

			Contact updatedContact = [SELECT Id, Name, Email, AccountId, Account.TradeName__c, Account.Legal_name__c, Account.Billing_Address_formated__c, Account.Phone, Account.Sector__c, Account.Category__c
										FROM Contact WHERE Id =: con.Id];

			//GCS_AccountCreation.sendEmailNotification(updatedContact);
			System.debug('SUCCESS : ');
			result.isSuccess = true;
			result.message = 'Regitration Completed!';

		}
		catch(Exception e){
			result.isSuccess = false;
			result.message = 'An Error Occurred - '+ e.getStackTraceString() ;
			System.debug('[PortalRegistrationThirdLevelLMSCtrl] registration : Exception : ' + e);
			System.debug('[PortalRegistrationThirdLevelLMSCtrl] registration : Exception stack : ' + e.getStackTraceString());
			Database.rollback(sp);
			return result;
		}
		return result;
	}



	@AuraEnabled
	public static RegistrationResult completeRegistration(String params){

		RegistrationResult result = new RegistrationResult();

		try{
			UserInformationWrapper contactInfo = getDataToMail(params);

			System.debug('[PortalRegistrationThirdLevelLMSCtrl] completeRegistration : contactInfo : ' + contactInfo);
			System.debug('[PortalRegistrationThirdLevelLMSCtrl] completeRegistration : contactInfo.Email : ' + contactInfo.Email);
			System.debug('[PortalRegistrationThirdLevelLMSCtrl] completeRegistration : contactInfo.Additional_Email : ' + contactInfo.Additional_Email);
			System.debug('[PortalRegistrationThirdLevelLMSCtrl] completeRegistration : contactInfo.flow : ' + contactInfo.flow);


			if(contactInfo.flow == 'flow3'){

				Contact con = [SELECT Id,AccountId,Email,Additional_Email__c,Phone,OtherPhone,Salutation,Birthdate,Shipping_Address__c FROM Contact WHERE Id = :contactInfo.Id];
				con.Email = contactInfo.Additional_Email;
				con.Additional_Email__c = contactInfo.Email;
				con.Shipping_Address__c = contactInfo.Shipping_Address != ''? contactInfo.Shipping_Address : null;
				con.Phone = contactInfo.Phone;
				con.OtherPhone = contactInfo.OtherPhone;
				con.Salutation = contactInfo.Salutation;
				con.Birthdate = Date.valueOf(contactInfo.Birthdate);

				List<String> extraValues = new List<String>();
				extraValues.add(contactInfo.Username);
				extraValues.add(contactInfo.UserId);
				extraValues.add(contactInfo.lmsCourse);
				extraValues.add(contactInfo.street);
				extraValues.add(contactInfo.zip);
				extraValues.add(contactInfo.countryId);
				extraValues.add(contactInfo.stateId);
				extraValues.add(contactInfo.stateName);
				extraValues.add(contactInfo.cityId);
				extraValues.add(contactInfo.cityName);
				extraValues.add(contactInfo.isPoBox);
				extraValues.add(contactInfo.serviceid);
				extraValues.add(contactInfo.street2);

				return registration(con, extraValues);
			}
			// if(contactInfo.flow == 'flow4' || contactInfo.flow == 'flow6'){

			//     //Get user to Merge
			//     Contact con = [SELECT Id,AccountId,Email,Additional_Email__c,Phone,OtherPhone,Salutation,Birthdate,Shipping_Address__c
			//                     FROM Contact WHERE Id = :contactInfo.existingContactId];
			//     con.FirstName = contactInfo.FirstName;
			//     con.LastName = contactInfo.LastName;
			//     con.Email = contactInfo.Additional_Email;
			//     con.Additional_Email__c = contactInfo.Email;
			//     con.Shipping_Address__c = contactInfo.Shipping_Address != ''? contactInfo.Shipping_Address : null;
			//     con.Phone = contactInfo.Phone;
			//     con.OtherPhone = contactInfo.OtherPhone;
			//     con.Salutation = contactInfo.Salutation;
			//     if(contactInfo.User_Portal_Status != null && contactInfo.User_Portal_Status == 'Pending'){
			//         con.User_Portal_Status__c = 'Pending Approval';
			//     }
			//     con.Birthdate = Date.valueOf(contactInfo.Date_of_Birth);

			//     Contact conToInactivate = [SELECT Id,status__c,FirstName,LastName,
			//                                         AccountId,Email,Additional_Email__c,Phone,
			//                                         OtherPhone,Salutation,Birthdate,Shipping_Address__c
			//                                 FROM Contact WHERE Id = :contactInfo.Id];

			//     conToInactivate.FirstName = conToInactivate.FirstName + ' - inactive';
			//     conToInactivate.LastName = conToInactivate.LastName + ' - inactive';
			//     conToInactivate.Email = conToInactivate.Email + '.inactive';
			//     if(conToInactivate.Additional_Email__c != null && conToInactivate.Additional_Email__c != ''){
			//         conToInactivate.Additional_Email__c = conToInactivate.Additional_Email__c + '.inactive';
			//     }

			//     // conToInactivate.status__c = 'Inactive';
			//     update conToInactivate;

			//     Set<String> conIdSet = new Set<String>();
			//     conIdSet.add(conToInactivate.Id);
			//     PortalRegistrationFirstLevelCtrl.futureDeactivateUsers(conIdSet);


			//     List<String> extraValues = new List<String>();
			//     extraValues.add(contactInfo.Username);
			//     extraValues.add(contactInfo.UserId);
			//     extraValues.add(contactInfo.lmsCourse);
			//     extraValues.add(contactInfo.street);
			//     extraValues.add(contactInfo.zip);
			//     extraValues.add(contactInfo.countryId);
			//     extraValues.add(contactInfo.stateId);
			//     extraValues.add(contactInfo.stateName);
			//     extraValues.add(contactInfo.cityId);
			//     extraValues.add(contactInfo.cityName);
			//     extraValues.add(contactInfo.isPoBox);

			//     return registration(con, extraValues);
			// }
			if(contactInfo.flow == 'flow5'){
				Contact con = [SELECT Id,AccountId,Email,Additional_Email__c,Phone,OtherPhone,Salutation,Birthdate,Shipping_Address__c FROM Contact WHERE Id = :contactInfo.Id];
				con.Email = contactInfo.Email;
				con.Additional_Email__c = contactInfo.Additional_Email;
				con.Shipping_Address__c = contactInfo.Shipping_Address != ''? contactInfo.Shipping_Address : null;
				con.Phone = contactInfo.Phone;
				con.OtherPhone = contactInfo.OtherPhone;
				con.Salutation = contactInfo.Salutation;
				con.Birthdate = Date.valueOf(contactInfo.Birthdate);


				List<String> extraValues = new List<String>();
				extraValues.add(contactInfo.Username);
				extraValues.add(contactInfo.UserId);
				extraValues.add(contactInfo.lmsCourse);
				extraValues.add(contactInfo.street);
				extraValues.add(contactInfo.zip);
				extraValues.add(contactInfo.countryId);
				extraValues.add(contactInfo.stateId);
				extraValues.add(contactInfo.stateName);
				extraValues.add(contactInfo.cityId);
				extraValues.add(contactInfo.cityName);
				extraValues.add(contactInfo.isPoBox);
				extraValues.add(contactInfo.serviceid);
				extraValues.add(contactInfo.street2);

				return registration(con, extraValues);
			}
			if(contactInfo.flow == 'flow4' || contactInfo.flow == 'flow6' || contactInfo.flow == 'flow7'){

				Contact con = [SELECT Id,AccountId,Email,Additional_Email__c,Phone,OtherPhone,Salutation,Birthdate,Shipping_Address__c
								FROM Contact WHERE Id = :contactInfo.Id];
				con.Email = contactInfo.Email;
				con.Additional_Email__c = contactInfo.Additional_Email;
				con.Shipping_Address__c = contactInfo.Shipping_Address != ''? contactInfo.Shipping_Address : null;
				con.Phone = contactInfo.Phone;
				con.OtherPhone = contactInfo.OtherPhone;
				con.Salutation = contactInfo.Salutation;
				con.Birthdate = Date.valueOf(contactInfo.Birthdate);


				List<String> extraValues = new List<String>();
				extraValues.add(contactInfo.Username);
				extraValues.add('');
				extraValues.add(contactInfo.lmsCourse);
				extraValues.add(contactInfo.street);
				extraValues.add(contactInfo.zip);
				extraValues.add(contactInfo.countryId);
				extraValues.add(contactInfo.stateId);
				extraValues.add(contactInfo.stateName);
				extraValues.add(contactInfo.cityId);
				extraValues.add(contactInfo.cityName);
				extraValues.add(contactInfo.isPoBox);
				extraValues.add(contactInfo.serviceid);
				extraValues.add(contactInfo.street2);

				RegistrationResult regRes = registration(con, extraValues);

				Set<String> contIds = new Set<String>();
				contIds.add(contactInfo.existingContactId);
				contIds.add(con.Id);
				System.debug('[PortalRegistrationThirdLevelLMSCtrl] completeRegistration : contIds : ' + contIds);


				if(regRes.isSuccess){


					//Getting existing Account Contact Role to set it up to the new Contact
					List<Account_Contact_Role__c> listACR = [SELECT Id,Account_Role__c,Contact__c,Contact_Role_Name__c,RecordTypeId
															FROM Account_Contact_Role__c
															WHERE Contact__c in :contIds
															AND Contact_Role_Name__c = 'Yardstick'];
					Account_Contact_Role__c acrNew = new Account_Contact_Role__c();
					Account_Contact_Role__c acrOld = new Account_Contact_Role__c();

					System.debug('[PortalRegistrationThirdLevelLMSCtrl] completeRegistration : listACR : ' + listACR);

					for(Account_Contact_Role__c acr : listACR){
						if(acr.Contact__c == con.Id){
							acrNew = acr;
						}else if(acr.Contact__c == contactInfo.existingContactId){
							acrOld = acr;
						}
					}
					System.debug('[PortalRegistrationThirdLevelLMSCtrl] completeRegistration : acrNew : ' + acrNew);
					System.debug('[PortalRegistrationThirdLevelLMSCtrl] completeRegistration : acrOld : ' + acrOld);

					if(acrNew != null && acrOld != null){
						// acr = listACR[0];

						acrOld.Contact__c = con.Id;
						acrOld.Account_Role__c = acrNew.Account_Role__c;
						update acrOld;

						delete acrNew;
					}



					//Create Yardstick Contact Role Detail
					List<Training_Contact_Role_Details__c> listYCD = [SELECT Id,RecordTypeId,Account_Contact_Role__c,Username__c,UserId__c,Preferred_Course__c
																	FROM Training_Contact_Role_Details__c
																	WHERE Account_Contact_Role__c = :acrOld.Id LIMIT 1];
					Training_Contact_Role_Details__c ycd = new Training_Contact_Role_Details__c();

					if(listYCD.size() > 0){
					System.debug('Training_Contact_Role_Details__c already exists!!!');
						ycd = listYCD[0];
						ycd.Username__c = contactInfo.Username != ''? contactInfo.Username : ycd.Username__c;
						ycd.UserId__c = contactInfo.UserId != ''? contactInfo.UserId : ycd.UserId__c;
						ycd.Preferred_Course__c = contactInfo.lmsCourse != ''? contactInfo.lmsCourse : ycd.Preferred_Course__c;

						update ycd;
					}

					Contact conToInactivate = [SELECT Id,status__c,FirstName,LastName,
														AccountId,Email,Additional_Email__c,Phone,
														OtherPhone,Salutation,Birthdate,Shipping_Address__c
												FROM Contact WHERE Id = :contactInfo.existingContactId];

					conToInactivate.FirstName = conToInactivate.FirstName + ' - inactive';
					conToInactivate.LastName = conToInactivate.LastName + ' - inactive';
					conToInactivate.Email = conToInactivate.Email + '.inactive';
					if(conToInactivate.Additional_Email__c != null && conToInactivate.Additional_Email__c != ''){
						conToInactivate.Additional_Email__c = conToInactivate.Additional_Email__c + '.inactive';
					}

					// conToInactivate.status__c = 'Inactive';
					update conToInactivate;

					Set<String> conIdSet = new Set<String>();
					conIdSet.add(conToInactivate.Id);
					PortalRegistrationFirstLevelCtrl.futureDeactivateUsers(conIdSet);

					regRes.isSuccess = true;
					regRes.message = 'Regitration Completed!';
				}
				return regRes;
			}
		}
		catch(Exception e){
			result.isSuccess = false;
			result.message = 'An Error Occurred - '+ e.getStackTraceString() ;
			System.debug('[PortalRegistrationThirdLevelLMSCtrl] registration : Exception : ' + e);
			System.debug('[PortalRegistrationThirdLevelLMSCtrl] registration : Exception stack : ' + e.getStackTraceString());
			return result;
		}
		return result;
	}


	@AuraEnabled
	public static UserInformationWrapper getDataToMail(string registrationForm){


		try{

			Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(registrationForm);

			UserInformationWrapper params = new UserInformationWrapper();
			params.Email     = (inputMap.get('Email') != null) ? string.valueOf(inputMap.get('Email')) : '';
			params.Additional_Email = (inputMap.get('Additional_Email__c') != null) ? string.valueOf(inputMap.get('Additional_Email__c')) : '';
			if(params.Additional_Email == ''){
				params.Additional_Email = (inputMap.get('Additional_Email') != null) ? string.valueOf(inputMap.get('Additional_Email')) : '';
			}
			params.FirstName = (inputMap.get('FirstName') != null) ? string.valueOf(inputMap.get('FirstName')) : '';
			params.LastName  = (inputMap.get('LastName') != null) ? string.valueOf(inputMap.get('LastName')) : '';
			params.Birthdate   = (inputMap.get('Birthdate') != null) ? string.valueOf(inputMap.get('Birthdate')) : '';
			params.Date_of_Birth   = (inputMap.get('Date_of_Birth__c') != null) ? string.valueOf(inputMap.get('Date_of_Birth__c')) : '';
			if(params.Date_of_Birth == ''){
				params.Date_of_Birth = (inputMap.get('Date_of_Birth') != null) ? string.valueOf(inputMap.get('Date_of_Birth')) : '';
			}
			params.Phone   = (inputMap.get('Phone') != null) ? string.valueOf(inputMap.get('Phone')) : '';
			params.language   = (inputMap.get('language') != null) ? string.valueOf(inputMap.get('language')) : '';
			params.Id   = (inputMap.get('Id') != null) ? string.valueOf(inputMap.get('Id')) : '';
			params.AccountId   = (inputMap.get('AccountId') != null) ? string.valueOf(inputMap.get('AccountId')) : '';
			params.OtherPhone   = (inputMap.get('OtherPhone') != null) ? string.valueOf(inputMap.get('OtherPhone')) : '';
			params.Salutation   = (inputMap.get('Salutation') != null) ? string.valueOf(inputMap.get('Salutation')) : '';
			params.Title   = (inputMap.get('Title') != null) ? string.valueOf(inputMap.get('Title')) : '';
			params.UserId   = (inputMap.get('UserId') != null) ? string.valueOf(inputMap.get('UserId')) : '';
			params.Username   = (inputMap.get('Username') != null) ? string.valueOf(inputMap.get('Username')) : '';
			params.User_Portal_Status   = (inputMap.get('User_Portal_Status__c') != null) ? string.valueOf(inputMap.get('User_Portal_Status__c')) : '';
			if(params.User_Portal_Status == ''){
				params.User_Portal_Status = (inputMap.get('User_Portal_Status') != null) ? string.valueOf(inputMap.get('User_Portal_Status')) : '';
			}
			params.existingContactId = (inputMap.get('existingContactId') != null) ? string.valueOf(inputMap.get('existingContactId')) : '';
			params.existingContactName = (inputMap.get('existingContactName') != null) ? string.valueOf(inputMap.get('existingContactName')) : '';
			params.existingContactEmail = (inputMap.get('existingContactEmail') != null) ? string.valueOf(inputMap.get('existingContactEmail')) : '';
			params.existingContactAccount = (inputMap.get('existingContactAccount') != null) ? string.valueOf(inputMap.get('existingContactAccount')) : '';
			params.lms  = (inputMap.get('lms') != null) ? string.valueOf(inputMap.get('lms')) : '';
			params.lmsCourse  = (inputMap.get('lmsCourse') != null) ? string.valueOf(inputMap.get('lmsCourse')) : '';
			params.hasExistingContact = (inputMap.get('hasExistingContact') != null) ? string.valueOf(inputMap.get('hasExistingContact')) : '';
			params.hasExistingContactPersonalEmail = (inputMap.get('hasExistingContactPersonalEmail') != null) ? string.valueOf(inputMap.get('hasExistingContactPersonalEmail')) : '';
			params.hasExistingUser = (inputMap.get('hasExistingUser') != null) ? string.valueOf(inputMap.get('hasExistingUser')) : '';
			params.hasExistingUserPersonalEmail = (inputMap.get('hasExistingUserPersonalEmail') != null) ? string.valueOf(inputMap.get('hasExistingUserPersonalEmail')) : '';
			params.flow = (inputMap.get('flow') != null) ? string.valueOf(inputMap.get('flow')) : '';

			params.Shipping_Address = (inputMap.get('Shipping_Address__c') != null) ? string.valueOf(inputMap.get('Shipping_Address__c')) : '';
			if(params.Shipping_Address == ''){
				params.Shipping_Address = (inputMap.get('Shipping_Address') != null) ? string.valueOf(inputMap.get('Shipping_Address')) : '';
			}
			params.isPoBox = (inputMap.get('isPoBox') != null) ? string.valueOf(inputMap.get('isPoBox')) : '';
			params.countryId = (inputMap.get('countryId') != null) ? string.valueOf(inputMap.get('countryId')) : '';
			params.countryCode = (inputMap.get('countryCode') != null) ? string.valueOf(inputMap.get('countryCode')) : '';
			params.countryName = (inputMap.get('countryName') != null) ? string.valueOf(inputMap.get('countryName')) : '';
			params.stateId = (inputMap.get('stateId') != null) ? string.valueOf(inputMap.get('stateId')) : '';
			params.stateName = (inputMap.get('stateName') != null) ? string.valueOf(inputMap.get('stateName')) : '';
			params.cityId = (inputMap.get('cityId') != null) ? string.valueOf(inputMap.get('cityId')) : '';
			params.cityName = (inputMap.get('cityName') != null) ? string.valueOf(inputMap.get('cityName')) : '';
			params.street = (inputMap.get('street') != null) ? string.valueOf(inputMap.get('street')) : '';
			params.zip = (inputMap.get('zip') != null) ? string.valueOf(inputMap.get('zip')) : '';
			params.serviceid = (inputMap.get('serviceid') != null) ? string.valueOf(inputMap.get('serviceid')) : '';
			params.street2 = (inputMap.get('street2') != null) ? string.valueOf(inputMap.get('street2')) : '';
			System.debug('CHECK params.street2: ' + params.street2);
			return params;

		}catch(Exception e){


			return null;
		}

	}

	public static string generateEncoded(UserInformationWrapper params){


		string paramsJson = JSON.serialize(params);
		paramsJson = paramsJson.replace('+', PortalPasswordHandler.plusReplacer);
		string encryptedStr = PortalPasswordHandler.EncryptString(paramsJson);
		String encodedPart = 'c=' + EncodingUtil.urlEncode(encryptedStr, 'UTF-8');

		return encodedPart;

	}




	@AuraEnabled
	// public static List<Boolean> sendSingleEmail(Id contactId){
	public static RegistrationResult sendSingleEmail(String contactName, String emailAddr, String flow, String params){
		RegistrationResult result = new RegistrationResult();
		//MAX 150 adresses
		try{

			System.debug('contactName: ' + contactName);
			System.debug('emailAddr: ' + emailAddr);
			System.debug('flow: ' + flow);
			System.debug('params: ' + params);

			//Get address
			// Contact contact = [SELECT Name, Email FROM CONTACT WHERE Id = :contactId];
			// String address = contact.Email;
			String address = emailAddr;

			if(address == null){
				result.isSuccess = false;
				result.message = 'An Error Occurred!';
				return result;
			}

			Id networkId = [SELECT Id FROM Network WHERE Name = 'CS Portal'].Id;
			string sURL = Network.getLoginURL(networkId).substring(0,Network.getLoginURL(networkId).indexOf('login'));
			sURL = sURL + '?lmsflow='+flow;

			UserInformationWrapper wUserInfo = getDataToMail(params);
			String encodedData = generateEncoded(wUserInfo);
			if(encodedData != ''){
				sURL = sURL + '&'+encodedData; //&c=wwrtweref
			}

			String sEmailTemplateName = 'CSP_Verification_L3_Email_LMS_VF';
			if(( wUserInfo.hasExistingContact != null && wUserInfo.hasExistingContact != '' && Boolean.valueOf( wUserInfo.hasExistingContact)) ||
					(wUserInfo.hasExistingContactPersonalEmail != null && wUserInfo.hasExistingContactPersonalEmail != '' && Boolean.valueOf( wUserInfo.hasExistingContactPersonalEmail) ) ){
				sEmailTemplateName = 'CSP_Verification_L3_EmailUserExistLMS_VF';
			}

			//Get email template and orgWideEmail
			EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
											FROM EmailTemplate
											WHERE DeveloperName = :sEmailTemplateName];
			OrgWideEmailAddress orgWideEmail  = [SELECT Id,Address FROM OrgWideEmailAddress WHERE Address='noreply@iata.org' Limit 1];

			// Id userId = [Select Id FROM User WHERE ContactId = :contactId].Id;

			//Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			// Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, userId, null);
			Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null, null);

			message.setReplyTo('noreply@iata.org');
			message.setUseSignature(false);
			message.setBccSender(false);
			message.setSaveAsActivity(false);
			message.setTemplateID(emailTemplate.Id);
			if(orgWideEmail != null){
				message.setOrgWideEmailAddressId(orgWideEmail.Id);
			}else{
				message.setSenderDisplayName('IATA Noreply');
			}

			// message.setTargetObjectId(userId);
			message.setToAddresses(new List<String>{address});


			String plainBody = message.getPlainTextBody();

			if(plainBody != null) {
				if(( wUserInfo.hasExistingContact != null && wUserInfo.hasExistingContact != '' && Boolean.valueOf( wUserInfo.hasExistingContact)) ||
					(wUserInfo.hasExistingContactPersonalEmail != null && wUserInfo.hasExistingContactPersonalEmail != '' && Boolean.valueOf( wUserInfo.hasExistingContactPersonalEmail) ) ){
					String headerImageName = Label.CSP_Email_Header_Image;
					String footerImageName = Label.CSP_Email_Footer_Image;
					String headerImageUrl;
					String footerImageUrl;
					Map<String,Id> docNameIdMap = new Map<String,Id>();

					// {!$Label.CSP_Email_Confirmation_Body_Part_1a}
					String sEmail_Confirmation_Body = '';
					if(wUserInfo.hasExistingContactPersonalEmail != null && wUserInfo.hasExistingContactPersonalEmail != '' && Boolean.valueOf( wUserInfo.hasExistingContactPersonalEmail)){
						sEmail_Confirmation_Body = Label.CSP_Email_Confirmation_Body_Part_1a;
					}else{
						sEmail_Confirmation_Body = Label.CSP_Email_Confirmation_Body_Part_1b;
					}


					for(Document doc : [Select id, name From Document Where name = :headerImageName or name= :footerImageName]){
						docNameIdMap.put(doc.name,doc.id);
					}

					if(docNameIdMap.get(headerImageName) != null) headerImageUrl = URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' )+'/servlet/servlet.ImageServer?id='+docNameIdMap.get(headerImageName)+'&oid='+userinfo.getorganizationid();
					if(docNameIdMap.get(footerImageName) != null) footerImageUrl = URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' )+'/servlet/servlet.ImageServer?id='+docNameIdMap.get(footerImageName)+'&oid='+userinfo.getorganizationid();

					Map<String, String> mapBodyParams = new map<String, String>{
							'{!HeaderUrl}'                                   => headerImageUrl,
							'{!FooterUrl}'                                   => footerImageUrl,
							'{!Receiving_User.FirstName}'                    => contactName,
							'{!Community_Url}'                               => sURL,
							'{!$Label.CSP_Email_Here}'                       => Label.CSP_Email_Here,
							'{!$Label.ISSP_Email_do_not_reply}'              => Label.ISSP_Email_do_not_reply,
							'{!$Label.CSP_Dear}'                             => Label.CSP_Dear,
							'{!$Label.CSP_Email_Welcome_Part_1}'             => Label.CSP_Email_Welcome_Part_1,
							'{!$Label.CSP_Email_Welcome_Part_2}'             => Label.CSP_Email_Welcome_Part_2,
							'{!$Label.CSP_Email_Welcome_Part_3}'             => Label.CSP_Email_Welcome_Part_3,
							'{!$Label.CSP_Email_Welcome_Part_4}'             => Label.CSP_Email_Welcome_Part_4,
							'{!$Label.CSP_Email_Welcome_Part_5}'             => Label.CSP_Email_Welcome_Part_5,
							'{!$Label.CSP_Email_Signature_Part_1}'           => Label.CSP_Email_Signature_Part_1,
							'{!$Label.CSP_Email_Signature_Part_2}'           => Label.CSP_Email_Signature_Part_2,
							'{!ExistingContactName}'                         => wUserInfo.existingContactName,
							'{!ExistingContactEmail}'                        => wUserInfo.existingContactEmail,
							'{!ExistingContactAccount}'                      => wUserInfo.existingContactAccount,
							'{!ExistingContactUsername}'                     => sEmail_Confirmation_Body

					};

					for(String key : mapBodyParams.keySet()) {
						plainBody = plainBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
					}
				}else{
					// plainBody = plainBody.replace('[CustomerName]', contact.Name).replace('[URL]','"'+ url +'" target="_blank"');
					plainBody = plainBody.replace('[CustomerName]', contactName).replace('[URL]',sURL);
				}

			}
			message.setHtmlBody(plainBody);

System.debug('message: '+message);
			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
System.debug('messages: '+messages);
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

			if (results[0].success){
				result.isSuccess = true;
				result.message = 'Send Mail Successfull!';
			} else {
				result.isSuccess = false;
				result.message = 'An Error Occurred!';
			}
		}catch(Exception e ){
			result.isSuccess = false;
			result.message = 'An Error Occurred - '+ e.getStackTraceString() ;
			System.debug('[PortalRegistrationThirdLevelLMSCtrl] registration : Exception : ' + e);
			System.debug('[PortalRegistrationThirdLevelLMSCtrl] registration : Exception stack : ' + e.getStackTraceString());
			return result;
		}
		return result;
	}

	@AuraEnabled
	public static Boolean validateYasUserId(String userId){
		List<Training_Contact_Role_Details__c> existingYadLst = new List<Training_Contact_Role_Details__c>(
			[SELECT
				Id
			 FROM
				Training_Contact_Role_Details__c
			 WHERE
				UserId__c = :userId
			]
		);

		if(!existingYadLst.isEmpty()){
			return false;
		}
		return true;
	}

	public static void createToSAcceptance(Id serviceId, Id contactId){

		List<Term_and_Condition__c> tos = [SELECT Id FROM Term_and_Condition__c WHERE NewGenApp_PortalService__c =:serviceId AND Is_Latest__c = true AND Status__c = 'Final'];
		system.assert(tos.size() == 1, 'Terms of Service data integrity compromised. Found none more than one active ToS for the service.');

		//check if the tos has already been accepted
		List<Term_and_Condition_Acceptance__c> tosAccept = [SELECT Id, Is_Accepted__c FROM Term_and_Condition_Acceptance__c WHERE Term_Condition__c =:tos[0].Id AND Contact__c =: contactId];

		if(tosAccept.isEmpty()){
			Term_and_Condition_Acceptance__c tosNew = new Term_and_Condition_Acceptance__c();
			tosNew.Is_Accepted__c = true;
			tosNew.Date_Accepted__c = Date.today();
			tosNew.Term_Condition__c = tos[0].Id;
			tosNew.Contact__c = contactId;

			insert tosNew;
		}
		else{
			if(!tosAccept[0].Is_Accepted__c){
				tosAccept[0].Is_Accepted__c = true;
				tosAccept[0].Date_Accepted__c = Date.today();
				update tosAccept[0];
			}
		}
	}

	@AuraEnabled
	public static Boolean getLMSTermAndConditionAcceptance(String serviceId, Id contactId) {

		if(serviceId == 'yas'){
			Portal_Applications__c pa = [SELECT Id, Name FROM Portal_Applications__c WHERE Name = 'Training Platform (LMS)' LIMIT 1];
			serviceId = pa.Id;
		}

		List<Term_and_Condition__c> tos = [SELECT Id FROM Term_and_Condition__c WHERE NewGenApp_PortalService__c =:serviceId AND Is_Latest__c = true AND Status__c = 'Final'];
		system.assert(tos.size() == 1, 'Terms of Service data integrity compromised. Found none more than one active ToS for the service.');

		//check if the tos has already been accepted
		List<Term_and_Condition_Acceptance__c> tosAccept = [SELECT Id, Is_Accepted__c FROM Term_and_Condition_Acceptance__c WHERE Term_Condition__c =:tos[0].Id AND Contact__c =: contactId];

		if(tosAccept.isEmpty()){
			return false;
		}

		return tosAccept[0].Is_Accepted__c;
	}

	public class UserInformationWrapper{
		public string Email{get;set;}
		public string Additional_Email{get;set;}
		public string Shipping_Address{get;set;}
		public string FirstName{get;set;}
		public string LastName{get;set;}
		public string Date_of_Birth{get;set;}
		public string Birthdate{get;set;}
		public string Phone{get;set;}
		public string language{get;set;}
		public string Id{get;set;}
		public string AccountId{get;set;}
		public string OtherPhone{get;set;}
		public string Salutation {get;set;}
		public string Title {get;set;}
		public string UserId {get;set;}
		public string Username {get;set;}
		public string User_Portal_Status {get;set;}

		public String lms{get;set;}
		public String lmsCourse{get;set;}
		public String serviceid{get;set;}
		public String existingContactId{get;set;}
		public String existingContactName{get;set;}
		public String existingContactEmail{get;set;}
		public String existingContactAccount{get;set;}
		public String hasExistingContact{get;set;}
		public String hasExistingContactPersonalEmail{get;set;}
		public String hasExistingUser{get;set;}
		public String hasExistingUserPersonalEmail{get;set;}
		public String flow{get;set;}

		public String isPoBox{get;set;}
		public String countryId{get;set;}
		public String countryCode{get;set;}
		public String countryName{get;set;}
		public String stateId{get;set;}
		public String stateName{get;set;}
		public String cityId{get;set;}
		public String cityName{get;set;}
		public String street{get;set;}
		public String street2{get;set;}
		public String zip{get;set;}

	}


}