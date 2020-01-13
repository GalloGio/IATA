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
														AND RecordTypeId = :RECTYPE_Trainee_YASContDet
														LIMIT 1];

        if(con.isEmpty() || con.size() < 1){
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

		//get registration information
		UserInformationWrapper registrationParameters = (UserInformationWrapper) JSON.deserialize(parameters, UserInformationWrapper.class);

		registrationParameters.Additional_Email = registrationParameters.Additional_Email.replace('@@##', '+');
		registrationParameters.Email = registrationParameters.Email.replace('@@##', '+');
		result.userInfo = JSON.serialize(registrationParameters);


		return result;
	}

	@AuraEnabled
	public static RegistrationResult registration(Contact con, List<String> extraValues){

		RegistrationResult result = new RegistrationResult();
		Savepoint sp = Database.setSavepoint();

		try{

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
			String existingTrainingId = extraValues[13];

			String RECTYPE_Master_AccRole = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');
			String RECTYPE_Master_AccContRole = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Master');
			String RECTYPE_Trainee_YASContDet = RecordTypeSingleton.getInstance().getRecordTypeId('Training_Contact_Role_Details__c', 'Yardstick_Trainee');

			update con;

			//Create Account Role if not existing
			List<Account_Role__c> listAR = [SELECT Id,Account__c,RecordTypeId 
											FROM Account_Role__c 
											WHERE Account__c = :con.AccountId 
											AND Account_Role_Name__c = 'Training' 
											AND Functional_Role__c =  'Training' LIMIT 1];
			Account_Role__c ar = new Account_Role__c();

			if(listAR.size() > 0){
				ar = listAR[0];
			}else{
				ar.Account__c = con.AccountId;
				ar.RecordTypeId = RECTYPE_Master_AccRole;
				ar.Account_Role_Name__c =  'Training';
				ar.Functional_Role__c =  'Training';
				insert ar;
			}

			Set<String> contIds = new Set<String>();
			contIds.add(con.Id);
			if(existingTrainingId != ''){
				contIds.add(existingTrainingId);
			}

			//Getting existing Account Contact Role from the new Contact to set it up to on the old contact
			List<Account_Contact_Role__c> listACR = [SELECT Id,Account_Role__c,Contact__c,Contact_Role_Name__c,RecordTypeId
													FROM Account_Contact_Role__c
													WHERE Contact__c in :contIds
													AND Contact_Role_Name__c = 'Trainee'
													AND Functional_Role__c =  'Training'];
			Account_Contact_Role__c acrNew = new Account_Contact_Role__c();
			Account_Contact_Role__c acrOld = new Account_Contact_Role__c();
			Account_Contact_Role__c acr = new Account_Contact_Role__c();

			for(Account_Contact_Role__c acrItem : listACR){
				if(acrItem.Contact__c == con.Id){
					acrNew = acrItem;
				}else if(acrItem.Contact__c == existingTrainingId){
					acrOld = acrItem;
				}
			}

			if(acrOld != null && acrOld.Id != null){
				acr = acrOld;
				acr.Account_Role__c = ar.Id;
				acr.Contact__c = con.Id;

				update acr;

				delete acrNew;
			}else if(acrNew != null && acrNew.Id != null){
				acr = acrNew;
			}else{
				acr.Account_Role__c = ar.Id;
				acr.Contact__c = con.Id;
				acr.Contact_Role_Name__c = 'Trainee';
				acr.Functional_Role__c =  'Training';
				acr.RecordTypeId = RECTYPE_Master_AccContRole;
				acr.Service_Rendered__c = 'Other';

				insert acr;
			}

			if(existingTrainingId != ''){
				Contact toDeleteContact = new Contact(Id = existingTrainingId);
				delete toDeleteContact;
			}

			//Create Yardstick Contact Role Detail
			List<Training_Contact_Role_Details__c> listYCD = [SELECT Id,RecordTypeId,Account_Contact_Role__c,Username__c,UserId__c,Preferred_Course__c 
																FROM Training_Contact_Role_Details__c 
																WHERE Account_Contact_Role__c = :acr.Id 
																AND RecordtypeId = :RECTYPE_Trainee_YASContDet
																LIMIT 1];
			Training_Contact_Role_Details__c ycd = new Training_Contact_Role_Details__c();

			if(listYCD.size() > 0){
				 ycd = listYCD[0];
				ycd.Username__c = sUsername;
				ycd.UserId__c = sUserId;
				if(sCourse != null && sCourse != ''){
					ycd.Preferred_Course__c = sCourse;
				}

				update ycd;

			}else{
				ycd.Account_Contact_Role__c = acr.Id;
				ycd.RecordTypeId = RECTYPE_Trainee_YASContDet;
				ycd.Username__c = sUsername;
				ycd.UserId__c = sUserId;
				ycd.Preferred_Course__c = sCourse;

				insert ycd;
			}

    		//Create Portal Application Right
    		Portal_Applications__c pa = [SELECT Id, Name FROM Portal_Applications__c WHERE Name = 'Training Platform (LMS)' LIMIT 1];

           	//Create ToS Acceptance
			createToSAcceptance(pa.id, con.Id);

			List<Portal_Application_Right__c> listPAR = [SELECT Id,Portal_Application__c,Right__c,Contact__c,Favourite_Service__c 
															FROM Portal_Application_Right__c 
															WHERE Contact__c = :con.Id 
															AND Portal_Application__c = :pa.id 
															LIMIT 1];
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

			String loggedUserId = UserInfo.getUserId(); 

			PermissionSet psYardstick = [SELECT Id FROM PermissionSet WHERE Name = 'Yardstick' LIMIT 1];

			assignPermissionSet(psYardstick.Id, (Id)loggedUserId);
			
			

			result.isSuccess = true;
			result.message = 'Regitration Completed!';

		}
		catch(Exception e){
			result.isSuccess = false;
			result.message = 'An Error Occurred - '+ e.getStackTraceString() ;
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

			String RECTYPE_Master_AccRole = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');
			String RECTYPE_Master_AccContRole = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Master');
			String RECTYPE_Trainee_YASContDet = RecordTypeSingleton.getInstance().getRecordTypeId('Training_Contact_Role_Details__c', 'Yardstick_Trainee');

			if(contactInfo.flow == 'flow3'){

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
				extraValues.add(contactInfo.existingTrainingId);
				
				return registration(con, extraValues);
			}

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
				extraValues.add(contactInfo.existingTrainingId);

				return registration(con, extraValues);
			}
			if(contactInfo.flow == 'flow4'){

				//Inactivate the registering Contact
				Contact conToInactivate = [SELECT Id,status__c,FirstName,LastName,
													AccountId,Email,Additional_Email__c,Phone,
													OtherPhone,Salutation,Birthdate,Shipping_Address__c
											FROM Contact WHERE Id = :contactInfo.Id];

				conToInactivate.FirstName = conToInactivate.FirstName + ' - inactive';
				conToInactivate.LastName = conToInactivate.LastName + ' - inactive';
				conToInactivate.Email = conToInactivate.Email + '.inactive';
				if(conToInactivate.Additional_Email__c != null && conToInactivate.Additional_Email__c != ''){
					conToInactivate.Additional_Email__c = conToInactivate.Additional_Email__c + '.inactive';
				}

				update conToInactivate;

				Contact con = [SELECT Id,AccountId,Email,Additional_Email__c,Phone,OtherPhone,Salutation,Birthdate,Shipping_Address__c
								FROM Contact WHERE Id = :contactInfo.existingContactId];
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
				extraValues.add(contactInfo.existingTrainingId);

				RegistrationResult regRes = registration(con, extraValues);

				Set<String> contIds = new Set<String>();
				contIds.add(contactInfo.Id);
				contIds.add(con.Id);
	
				if(regRes.isSuccess){

					//Getting existing Account Contact Role from the new Contact to set it up to on the old contact
					List<Account_Contact_Role__c> listACR = [SELECT Id,Account_Role__c,Contact__c,Contact_Role_Name__c,RecordTypeId
															FROM Account_Contact_Role__c
															WHERE Contact__c in :contIds
															AND Contact_Role_Name__c = 'Trainee'
															AND Functional_Role__c =  'Training'];
					Account_Contact_Role__c acrNew = new Account_Contact_Role__c();
					Account_Contact_Role__c acrOld = new Account_Contact_Role__c();

					for(Account_Contact_Role__c acr : listACR){
						if(acr.Contact__c == contactInfo.Id){
							acrNew = acr;
						}else if(acr.Contact__c == contactInfo.existingContactId){
							acrOld = acr;
						}
					}
	
					Set<String> acrIds = new Set<String>();
					acrIds.add(acrNew.Id);
					acrIds.add(acrOld.Id);

					//Create Yardstick Contact Role Detail
					List<Training_Contact_Role_Details__c> listYCD = [SELECT Id,RecordTypeId,Account_Contact_Role__c,Username__c,UserId__c,Preferred_Course__c
																	FROM Training_Contact_Role_Details__c
																	WHERE Account_Contact_Role__c in :acrIds
																	AND RecordTypeId = :RECTYPE_Trainee_YASContDet];
					Training_Contact_Role_Details__c ycdOld = new Training_Contact_Role_Details__c();
					Training_Contact_Role_Details__c ycdNew = new Training_Contact_Role_Details__c();

					for(Training_Contact_Role_Details__c ycd : listYCD){
						if(ycd.Account_Contact_Role__c == acrNew.Id){
							ycdNew = ycd;
						}else if(ycd.Account_Contact_Role__c == acrOld.Id){
							ycdOld = ycd;
						}
					}

					//Check if Training_Contact_Role_Details__c exist on the contact to keep
					if(ycdOld != null){
	
						List<Contact_Role_Certification__c> listCRC = [SELECT Id,Training_Contact_Role_Detail__c
																	FROM Contact_Role_Certification__c
																	WHERE Training_Contact_Role_Detail__c = :ycdNew.Id];

						if(listCRC.size() > 0){
							for(Contact_Role_Certification__c crc : listCRC){
								crc.Training_Contact_Role_Detail__c = ycdOld.Id;
							}
							update listCRC;
						}

						List<Course_Assignment__c> listCA = [SELECT Id,Training_Contact_Role_Detail__c
																	FROM Course_Assignment__c
																	WHERE Training_Contact_Role_Detail__c = :ycdNew.Id];
						
						if(listCA.size() > 0){
							for(Course_Assignment__c ca : listCA){
								ca.Training_Contact_Role_Detail__c = ycdOld.Id;
							}
							update listCA;
						}

						if(ycdNew != null && ycdNew.Id != null){
							delete ycdNew;
						}
						
						
						ycdOld.Username__c = contactInfo.Username != ''? contactInfo.Username : ycdOld.Username__c;
						ycdOld.UserId__c = contactInfo.UserId != ''? contactInfo.UserId : ycdOld.UserId__c;
						ycdOld.Preferred_Course__c = contactInfo.lmsCourse != ''? contactInfo.lmsCourse : ycdOld.Preferred_Course__c;
						update ycdOld;

						
					}else{
						ycdNew.Account_Contact_Role__c = acrOld.Id;
						ycdNew.Username__c = contactInfo.Username != ''? contactInfo.Username : ycdNew.Username__c;
						ycdNew.UserId__c = contactInfo.UserId != ''? contactInfo.UserId : ycdNew.UserId__c;
						ycdNew.Preferred_Course__c = contactInfo.lmsCourse != ''? contactInfo.lmsCourse : ycdNew.Preferred_Course__c;

						update ycdNew; 
					}

					//Delete Account Contact Role from the registering Contact
					if(acrNew != null && acrNew.Id != null){
						delete acrNew;
					}

					Set<String> conIdSet = new Set<String>();
					conIdSet.add(conToInactivate.Id);
					PortalRegistrationFirstLevelCtrl.futureDeactivateUsers(conIdSet);

					regRes.isSuccess = true;
					regRes.message = 'Regitration Completed!';
				}
				return regRes;
			}
			if(contactInfo.flow == 'flow6' || contactInfo.flow == 'flow7'){

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
				extraValues.add(contactInfo.existingTrainingId);

				RegistrationResult regRes = registration(con, extraValues);

				Set<String> contIds = new Set<String>();
				contIds.add(contactInfo.existingContactId);
				contIds.add(con.Id);
		
				if(regRes.isSuccess){

					//Getting existing Account Contact Role to set it up to the new Contact
					List<Account_Contact_Role__c> listACR = [SELECT Id,Account_Role__c,Contact__c,Contact_Role_Name__c,RecordTypeId
															FROM Account_Contact_Role__c
															WHERE Contact__c in :contIds
															AND Contact_Role_Name__c = 'Trainee'
															AND Functional_Role__c =  'Training'];
					Account_Contact_Role__c acrNew;
					Account_Contact_Role__c acrOld;

					for(Account_Contact_Role__c acr : listACR){
						if(acr.Contact__c == con.Id){
							acrNew = acr;
						}else if(acr.Contact__c == contactInfo.existingContactId){
							acrOld = acr;
						}
					}
	
					if(acrNew != null && acrOld != null){
						acrOld.Contact__c = con.Id;
						acrOld.Account_Role__c = acrNew.Account_Role__c;
						update acrOld;

						delete acrNew;
					}



					//Create Yardstick Contact Role Detail
					List<Training_Contact_Role_Details__c> listYCD = [SELECT Id,RecordTypeId,Account_Contact_Role__c,Username__c,UserId__c,Preferred_Course__c
																	FROM Training_Contact_Role_Details__c
																	WHERE Account_Contact_Role__c = :acrOld.Id 
																	AND RecordtypeId = :RECTYPE_Trainee_YASContDet
																	LIMIT 1];
					Training_Contact_Role_Details__c ycd = new Training_Contact_Role_Details__c();

					if(listYCD.size() > 0){
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
			params.existingTrainingId = (inputMap.get('existingTrainingId') != null) ? string.valueOf(inputMap.get('existingTrainingId')) : '';
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
	public static RegistrationResult sendSingleEmail(String contactName, String emailAddr, String flow, String params){
		RegistrationResult result = new RegistrationResult();
		//MAX 150 adresses
		try{

			//Get address
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
				sURL = sURL + '&'+encodedData; 
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

					String sEmail_Confirmation_Body = '';
					if(wUserInfo.hasExistingContactPersonalEmail != null && wUserInfo.hasExistingContactPersonalEmail != '' && Boolean.valueOf( wUserInfo.hasExistingContactPersonalEmail)){
						sEmail_Confirmation_Body = Label.CSP_Verification_L3_Email_PE_1_LMS + 
													Label.CSP_Verification_L3_Email_PE_2_LMS;						
					}else{
						sEmail_Confirmation_Body = Label.CSP_Verification_L3_Email_UE_1_LMS + 
													Label.CSP_Verification_L3_Email_UE_2_LMS + 
													Label.CSP_Verification_L3_Email_UE_3_LMS;						
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
					plainBody = plainBody.replace('[URL]',sURL);
					plainBody = plainBody.replace('[Email]',wUserInfo.Email);
					plainBody = plainBody.replace('[ExistingEmail]',wUserInfo.existingContactEmail);
					
				}else{
					plainBody = plainBody.replace('[CustomerName]', contactName).replace('[URL]',sURL);
				}

			}
			message.setHtmlBody(plainBody);

			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
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
			return result;
		}
		return result;
	}

	@AuraEnabled(cacheable=false)
	public static String validateYasUserId(String userId, String username, String firstname, String lastname){
		
		String sRes = '';
		String fullName = firstname + lastname;
		String fullNameReverse = lastname + firstname;
		fullName = AMS_Utils.cleanSpecialChars(fullName.toUpperCase(), false);
		fullNameReverse = AMS_Utils.cleanSpecialChars(fullNameReverse.toUpperCase(), false);
		Double fullNameSize = fullName.length();
		Double threshold = fullNameSize - ((fullNameSize * 60)/100);
		Integer roundThreshold = Math.round(threshold);

		String RECTYPE_Trainee_YASContDet = RecordTypeSingleton.getInstance().getRecordTypeId('Training_Contact_Role_Details__c', 'Yardstick_Trainee');
		
		List<Training_Contact_Role_Details__c> existingYadLst = new List<Training_Contact_Role_Details__c>(
			[SELECT Id, Account_Contact_Role__r.contact__c, Account_Contact_Role__r.contact__r.firstname, Account_Contact_Role__r.contact__r.lastname 
				FROM Training_Contact_Role_Details__c
				WHERE UserId__c = :userId 
				AND Username__c = :username 
				AND RecordtypeId = :RECTYPE_Trainee_YASContDet
				LIMIT 1]);

		if(!existingYadLst.isEmpty() && existingYadLst.size() > 0){
			Training_Contact_Role_Details__c existingTCRD = existingYadLst[0];
			String existingFullName = existingTCRD.Account_Contact_Role__r.contact__r.firstname + existingTCRD.Account_Contact_Role__r.contact__r.lastname;
			String existingFullNameReverse = existingTCRD.Account_Contact_Role__r.contact__r.lastname + existingTCRD.Account_Contact_Role__r.contact__r.firstname;
			existingFullName = AMS_Utils.cleanSpecialChars(existingFullName.toUpperCase(), false);
			existingFullNameReverse = AMS_Utils.cleanSpecialChars(existingFullNameReverse.toUpperCase(), false);

			//check if names are 80% equal, if not returns -1, if equal or above 80% returns the # of diferences 
			Integer compareResult = fullName.getLevenshteinDistance(existingFullName, roundThreshold);
			Integer compareResultReverse = fullNameReverse.getLevenshteinDistance(existingFullNameReverse, roundThreshold);

			if(compareResult < 0 && compareResultReverse < 0){
				sRes = 'not_matching';	
			}else{

				//check if have active user
				List<User> existingUserLst = new List<User>(
					[SELECT Id FROM User WHERE ContactId = :existingTCRD.Account_Contact_Role__r.contact__c LIMIT 1]);

				if(!existingUserLst.isEmpty() && existingUserLst.size() > 0){
					sRes = 'existing_user';
				}else{
					sRes = existingTCRD.Account_Contact_Role__r.contact__c;	
				}
			}

		}else{
			sRes = 'not_existing';
		}
		return sRes;
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

	@future
    private static void assignPermissionSet(Id yasId, Id userId){
		
		List<PermissionSetAssignment> listPSA = [SELECT Id FROM PermissionSetAssignment 
											WHERE PermissionSetId = :yasId
											AND AssigneeId = :userId]; 
			
		if(listPSA.size() <= 0){
			PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = yasId, AssigneeId = userId);
        	insert psa;	
		}
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
		public String existingTrainingId{get;set;}
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