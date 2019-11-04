public without sharing class PortalIftpUtils {

	@AuraEnabled
	public static boolean isCommunity(){
		Id siteId = Site.getSiteId(); // take a look at the apex class Site, you may find more useful method concerning site/community
		if (siteId != null) {
			return true;
		}
		return false;
	}
	
	@AuraEnabled(cacheable=false)
	public static List<Account_Contact_Role__c> getAllITPEmployees(Id accountId){
		//cacheable=false MANDATORY
		List<Account_Contact_Role__c> emps = [SELECT Account__c,Business_Phone__c,Company_Code__c,Contact_Role__c,
													Contact__c, Email__c,First_Name__c,Id,Integration_Status__c,
													Last_Name__c,Name,Personal_Email__c,Contact_Roles__c,
													Position__c,RecordTypeId,Service_Rendered__c,Status__c,Title__c,
													TransferFlag__c,UniqueKey__c, Details__c, Global_ID__c
												FROM Account_Contact_Role__c
												WHERE  Contact__r.accountid = :accountId];
		return emps;
	}

	@AuraEnabled(cacheable=false)
	public static UserInfoRecordsWrapper getUserInfo(){

		Id userId = System.UserInfo.getUserId();

		Id contactRoleId = null;
		String contactRole = null;
		String PortalContactRoles = null;

		User userAcc = [SELECT Id, ContactId, Contact.User_Portal_Status__c, Contact.Accountid,
								Contact.Account.Region_formula__c, Contact.Account.IATA_ISO_Country__r.Name,
								Contact.Account.Recordtype.Name,
								Contact.Account.Recordtype.Developername, Contact.Account.Name, Profile_Name__c
							FROM user
							WHERE Id= :userId];


		Account_Role_Service__c accRoleSrv = [SELECT Id, Account_Role_Services__r.Name,
													Account_Role__c, Account_Role__r.Status__c, Account_Role__r.RecordType.Name
												FROM Account_Role_Service__c
												WHERE Account_Role__r.Account__c = :userAcc.contact.accountid];

		List<Account_Contact_Role__c> lContactRole = [SELECT Id, Contact_Role__c, Contact_Roles__c, Contact_Roles__r.Name
													FROM Account_Contact_Role__c
													WHERE Contact__c = :userAcc.contactId];

		List<Role_Address__c> lRoleAddr = [SELECT Id, Address__c,
												Address__r.City__c,
												Address__r.Code__c,
												Address__r.Description__c,
												Primary__c
											FROM Role_Address__c
											WHERE Account_Contact_Role__r.Contact__c = :userAcc.contactId];

		Portal_Application_Right__c par = [SELECT Right__c, Portal_Application__r.Name
											FROM Portal_Application_Right__c
											WHERE Contact__c = :userAcc.contactId
											AND Portal_Application__r.Name = 'IFTP'
											LIMIT 1];

		if(lContactRole.size() > 0){
			contactRoleId = lContactRole[0].Id;
			contactRole = lContactRole[0].Contact_Role__c;
			PortalContactRoles = lContactRole[0].Contact_Roles__r.Name;
		}

		UserInfoRecordsWrapper userInfo = new UserInfoRecordsWrapper(
			userId,
			userAcc.contact.accountid,
			accRoleSrv.Account_Role__c,
			accRoleSrv.Account_Role__r.Status__c,
			accRoleSrv.Account_Role__r.RecordType.Name,
			accRoleSrv.Id,
			accRoleSrv.Account_Role_Services__r.Name,
			userAcc.contact.account.name,
			userAcc.contact.account.recordtype.developername,
			contactRoleId,
			contactRole,
			PortalContactRoles,
			userAcc.Profile_Name__c,
			userAcc.contact.User_Portal_Status__c,
			par.Portal_Application__r.Name,
			par.Right__c
			);

		if(!lRoleAddr.isEmpty()){
			userInfo.hasAssociatedStations = true;
			for(Role_Address__c rec : lRoleAddr){
				if(rec.Primary__c){
					userInfo.primaryStationCode = rec.Address__r.Code__c;
				}
			}
		}
		userInfo.contactId = userAcc.contactId;
		userInfo.accountRegion = userAcc.Contact.Account.Region_formula__c;
		userInfo.accountCountry = userAcc.Contact.Account.IATA_ISO_Country__r.Name;


		return userInfo;
	}

	@AuraEnabled(cacheable=true)
	public static List<Address__c> getUserStations(){

		List<Address__c> stations = [SELECT Id, City__c, Code__c, Description__c FROM Address__c ORDER BY Code__c];

		return stations;
	}

	@AuraEnabled(cacheable=true)
	public static List<Address__c> getAllStations(){

		List<Address__c> stations = [SELECT Id, City__c, Code__c, Description__c FROM Address__c ORDER BY Code__c];

		return stations;
	}

	/*
	* @description Main method that returns a Stations for a given user

		Account_Role_Relationship__c - relation between Airline and ITP Company
		Account_Role_Service__c - ITP Company or Airline
		Account_Contact_Role__c - Employee

	* @params
	* @return List<Case>
	*/
	@AuraEnabled(cacheable=false)
	public static List<Address__c> getITPStations(Id accountId){
		List<Address__c> stations = [SELECT City__c, Code__c, Description__c
									 FROM Address__c
									 WHERE Id in (
											SELECT Address__c
											FROM Role_Address__c
											WHERE Account_Role_Service__r.Account_Role__r.Account__c = :accountId
											) ];

		return stations;
	}

	@AuraEnabled(cacheable=false)
	public static List<Address__c> getITPStations(){

		Id userId = System.UserInfo.getUserId();

		User userAcc = [Select id, contactId, contact.accountid from user where Id= :userId];

		return getITPStations(userAcc.contact.accountid);
	}

	/*
	* @description Main method that returns a map where the key is the employees' id and the value
	is a list of stations added to that employee(Role Addresses)

	* @params List<Id> employeesIDs
	* @return Map<Id, List<Address__c>>
	*/
	@AuraEnabled(cacheable=true)
	public static Map<Id, List<Address__c>> getEmployeesStations(List<Id> employeesIDs){

		Map<Id, List<Address__c>> ret = new Map<Id, List<Address__c>>();

		List<Role_Address__c> stations = [SELECT Account_Contact_Role__c, Address__c, Address__r.City__c, Address__r.Code__c, Address__r.Description__c
											FROM Role_Address__c
											WHERE Account_Contact_Role__c in :employeesIDs];

		for(Role_Address__c ra : stations){
			List<Address__c> auxaddr = new List<Address__c>();
			if(ret.containsKey(ra.Account_Contact_Role__c)){
				auxaddr = ret.get(ra.Account_Contact_Role__c);
				auxaddr.add( new Address__c(Id = ra.Address__c, Code__c = ra.Address__r.Code__c) );
				ret.put(ra.Account_Contact_Role__c, auxaddr);
			}else{
				auxaddr.add( new Address__c(Id = ra.Address__c, Code__c = ra.Address__r.Code__c) );
				ret.put(ra.Account_Contact_Role__c, auxaddr);
			}
		}

		return ret;
	}

	@AuraEnabled(cacheable=true)
	public static List<Account_Contact_Role__c> getITPEmployees(Id accountId){

		List<Account_Contact_Role__c> emps = [SELECT Account__c,Business_Phone__c,Company_Code__c,Contact_Role__c,
													Contact__c, Email__c,First_Name__c,Id,Integration_Status__c,
													Last_Name__c,Name,Personal_Email__c,Contact_Roles__c,
													Position__c,RecordTypeId,Service_Rendered__c,Status__c,Title__c,
													TransferFlag__c,UniqueKey__c
												FROM Account_Contact_Role__c
												WHERE Status__c <> 'Inactive'
												AND Contact__r.accountid = :accountId];

		return emps;
	}

	@AuraEnabled(cacheable=true)
	public static List<Account_Contact_Role__c> getITPEmployeesWithStationsInfo(Id accountId){

		List<Account_Contact_Role__c> emps = [SELECT Account__c,Business_Phone__c,Company_Code__c,Contact_Role__c,
													Contact__c, Email__c,First_Name__c,Id,Integration_Status__c,
													Last_Name__c,Name,Personal_Email__c,Contact_Roles__c,
													Position__c,RecordTypeId,Service_Rendered__c,Status__c,Title__c,
													TransferFlag__c,UniqueKey__c, Details__c,
													(SELECT Address__c,
														Address__r.City__c,
														Address__r.Code__c,
														Address__r.Description__c,
														Primary__c
													FROM Role_Addresses__r)
												FROM Account_Contact_Role__c
												WHERE Status__c <> 'Inactive'
												AND Contact__r.accountid = :accountId];

		return emps;
	}

	@AuraEnabled(cacheable=true)
	public static Address__c getITPStationEmployees(Id addressId){
		Id userId = System.UserInfo.getUserId();
		User userAcc = [Select id, contactId, contact.accountid from user where Id= :userId];
		return getITPStationEmployees(userAcc.contact.accountid, addressId);
	}

	@AuraEnabled(cacheable=true)
	public static Address__c getITPStationEmployees(Id accountId, Id addressId){

		Address__c station = [SELECT Id, City__c, Code__c, Description__c ,
											(SELECT Account_Contact_Role__r.Account__c,
													Account_Contact_Role__r.Company_Code__c,
													Account_Contact_Role__r.First_Name__c,
													Account_Contact_Role__r.Id,
													Account_Contact_Role__r.Last_Name__c
											FROM Role_Addresses__r
											WHERE Account_Contact_Role__r.Contact__r.accountid = :accountId
											AND Account_Contact_Role__r.Status__c <> 'Inactive')
									 FROM Address__c
									 WHERE Id = :addressId];
		return station;
	}

	@AuraEnabled
	public static List<StationRecordsWrapper> getITPStationsForDatatable(Id accountId){

		List<StationRecordsWrapper> retStations = new List<StationRecordsWrapper>();


		List<Role_Address__c> stations = [SELECT id, name, Description__c, Airport_Details__c, Address__c, Address__r.City__c, Address__r.Code__c, Address__r.Description__c, Account_Role_Service__r.Name
											FROM Role_Address__c
											WHERE Account_Role_Service__r.Account_Role__r.Account__c = :accountId];

		for(Role_Address__c ra : stations){

			StationRecordsWrapper srw = new StationRecordsWrapper(
				ra.Id,
				ra.Description__c,
				ra.Address__r.Code__c,
				ra.Address__r.City__c,
				ra.Address__r.Description__c,
				ra.Address__c
				);
			srw.name = ra.name;
			srw.arsname = ra.Account_Role_Service__r.Name;
			retStations.add(srw);
		}

		return retStations;
	}

	@AuraEnabled
	public static List<StationRecordsWrapper> getITPStationsForDatatable(){
        Id userId = System.UserInfo.getUserId();
        User userAcc = [Select id, contactId, contact.accountid from user where Id= :userId];
        return getITPStationsForDatatable(userAcc.contact.accountid);
    }

	/*
	* @description
		Account_Role_Relationship__c - relation between Airline and ITP Company
		Account_Role_Service__c - ITP Company or Airline
		Account_Contact_Role__c - Employee
	* @params
	* @return List<Role_Address__c>
	*/

	@AuraEnabled(cacheable=false)
	public static Map<String, List<Role_Address__c>> getAirlineITPsByStation(){
		Id userId = System.UserInfo.getUserId();

		User userAcc = [Select id, contactId, contact.accountid from user where Id= :userId];

		List<Role_Address__c> companies = [SELECT   Account_Role_Relationship__r.To__r.Account__c,
													Account_Role_Relationship__r.To__r.Account__r.name,
													Address__r.Code__c,
													Address__r.Description__c
											FROM Role_Address__c
											WHERE Account_Role_Relationship__r.From__r.Account__c = :userAcc.contact.accountid
											AND Address__c != null];

		Map<String, List<Role_Address__c>> ItpByStationsMap = new Map<String, List<Role_Address__c>>();
		for(Role_Address__c rec: companies){
			if(ItpByStationsMap.containsKey(rec.Address__r.Code__c)){
				List<Role_Address__c> innerList = ItpByStationsMap.get(rec.Address__r.Code__c);
				innerList.add(rec);
				ItpByStationsMap.put(rec.Address__r.Code__c, innerList);
			} else {
				List<Role_Address__c> innerList = new List<Role_Address__c>();
				innerList.add(rec);
				ItpByStationsMap.put(rec.Address__r.Code__c, innerList);
			}
		}
		return ItpByStationsMap;
	}

	/*
	* @description Main method that returns a Stations for a given user

		Account_Role_Relationship__c - relation between Airline and ITP Company
		Account_Role_Service__c - ITP Company or Airline
		Account_Contact_Role__c - Employee


	* @params
	* @return List<Role_Address__c>
	*/
	@AuraEnabled(cacheable=true)
	public static List<Role_Address__c> getITPConnectedToAirlineByStation(String stationCode){

		Id userId = System.UserInfo.getUserId();

		User userAcc = [Select id, contactId, contact.accountid from user where Id= :userId];

		List<Role_Address__c> companies = [SELECT Account_Role_Relationship__r.To__r.Account__c, Account_Role_Relationship__r.To__r.Account__r.name
											FROM Role_Address__c
											WHERE Account_Role_Relationship__r.From__r.Account__c = :userAcc.contact.accountid
											AND Address__r.Code__c = :stationCode ];
		return companies;
	}


	@AuraEnabled(cacheable=true)
	public static List<Role_Address__c> getITPConnectedToAirlineByStations(List<String> stationsCodes){

		Id userId = System.UserInfo.getUserId();

		User userAcc = [Select id, contactId, contact.accountid from user where Id= :userId];

		List<Role_Address__c> companies = [SELECT Account_Role_Relationship__r.To__r.Account__c, Account_Role_Relationship__r.To__r.Account__r.name, Address__r.Code__c
											FROM Role_Address__c
											WHERE Account_Role_Relationship__r.From__r.Account__c = :userAcc.contact.accountid
											AND Address__r.Code__c in :stationsCodes ];

		return companies;
	}


	@AuraEnabled(cacheable=true)
	public static List<Account_Role_Relationship__c> getITPConnectedToAirline(){

		Id userId = System.UserInfo.getUserId();

		User userAcc = [Select id, contactId, contact.accountid from user where Id= :userId];

		List<Account_Role_Relationship__c> companies = [SELECT To__r.Account__r.name
											FROM Account_Role_Relationship__c
											WHERE From__r.Account__c = :userAcc.contact.accountid];

		return companies;
	}

	@AuraEnabled(cacheable=true)
	public static List<Account> getAllITP(){

		String RECTYPE_ITP_AccRole = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'IFTP');

		List<Account_Role__c> accRoleCompanies = [SELECT Account__c
													FROM Account_Role__c
													WHERE RecordTypeId = :RECTYPE_ITP_AccRole
													AND Account_Roles__r.Category__c = 'ITP'
													AND Account_Roles__r.Sector__c = 'Airline Supplier'];

		Set<Id> accIds = new Set<Id>();
		for(Account_Role__c ar : accRoleCompanies ){
			accIds.add(ar.Account__c);
		}

		List<Account> companies = [SELECT name
											FROM Account
											WHERE Id IN :accIds
											AND Sector__c = 'Airline Supplier'
											AND Category__c = 'Fuel Supplier'];

		return companies;
	}

	/*
	* @params
	* @return List<Certification__c>
	*/
	@AuraEnabled(cacheable=true)
	public static List<Certification__c> getCertificationTypes(String certificationType){

		List<Certification__c> certifications = new List<Certification__c>();

		if(certificationType != null && certificationType != ''){
			certifications = [SELECT Id, Name
								FROM Certification__c
								WHERE Type__c = :certificationType
								AND Id IN (SELECT Certification__c
											FROM IFTP_Certification_Detail__c
											WHERE General_Training__c != NULL) ORDER BY Name];
		}else{
			certifications = [SELECT Id, Name
								FROM Certification__c
								WHERE Id IN (SELECT Certification__c
											FROM IFTP_Certification_Detail__c
											WHERE General_Training__c != NULL)
								ORDER BY Name ];
		}

		return certifications;
	}

	/*
	* @params
	* @return List<IFTP_Certification_Detail__c>
	*/
	@AuraEnabled(cacheable=true)
	public static List<IFTP_Certification_Detail__c> getCertificationTypesWithLevel(String certificationType){

		List<Certification__c> certifications = new List<Certification__c>();
		List<IFTP_Certification_Detail__c> certificationsWithLevel = new List<IFTP_Certification_Detail__c>();

		if(certificationType != null && certificationType != ''){
			certificationsWithLevel = [SELECT Certification__c, Certification__r.Name, Prerequisite_Level__c
										FROM IFTP_Certification_Detail__c
										WHERE General_Training__c like 'No'];
		}else{
			certificationsWithLevel = [SELECT Certification__c, Certification__r.Name, Prerequisite_Level__c
										FROM IFTP_Certification_Detail__c
										ORDER BY Name];
		}

		return certificationsWithLevel;
	}


	@AuraEnabled (cacheable=false)
	public static InsertStationWrapper updateStation(List<Object> dataToSave, String origin){
		List<Role_Address__c> stationsToUpdate = new List<Role_Address__c>();
		InsertStationWrapper irw;
		List<Address__c> ITPStationsInDatabase = getITPStations();

		for(Object rec : dataToSave){
			Role_Address__c auxStation = (Role_Address__c)JSON.deserialize(JSON.serialize(rec ), Role_Address__c.class);

			Boolean existsStationInDatabase = false;
			for(Address__c addr : ITPStationsInDatabase){
				if(addr.id == auxStation.Address__c){
					existsStationInDatabase = true;

				}
			}
			if(existsStationInDatabase){
				stationsToUpdate.add(auxStation);
			} else {
				irw = new InsertStationWrapper('The station you tried to update, is no longer a station of this ITP.', false);
			}
		}

		if(stationsToUpdate.size() > 0){
			update stationsToUpdate;
			irw = new InsertStationWrapper('Station\' notes updated successfully.', true);
		}
		return irw;
	}

	@AuraEnabled (cacheable=false)
	public static InsertStationWrapper insertStation(Id accountId, List<Object> dataToSave){
		InsertStationWrapper isw;
		try{

			List<Role_Address__c> stationsToInsert = new List<Role_Address__c>();

			List<Address__c> ITPStationsInDatabase = getITPStations(accountId);

			for(Object rec : dataToSave){
				Role_Address__c auxStation = (Role_Address__c)JSON.deserialize(JSON.serialize(rec ), Role_Address__c.class);
				Boolean existsStation = false;
				for(Address__c addr: ITPStationsInDatabase){
					if(addr.Id == auxStation.Address__c){
						existsStation = true;
						isw = new InsertStationWrapper( 'Station has already been added.', true);
					}
				}
				if(!existsStation){
					stationsToInsert.add(auxStation);
				}
			}

			Savepoint sp = Database.setSavepoint();
			try{
				//insert stationsToInsert;
				if(stationsToInsert.size() > 0){
					upsert stationsToInsert;
					isw = new InsertStationWrapper( 'Station added successfully', true);
					isw.stationsToInsertList = stationsToInsert;
				}
			}
			catch (DMLException e) {
					Database.rollback(sp);
					isw = new InsertStationWrapper( 'Failed: An error has occured while saving data', false);
			}
		}
		catch (Exception e){
			isw = new InsertStationWrapper( 'Failed: An error has occured while saving data', false);
		}

		return isw;
	}

	@AuraEnabled (cacheable=false)
	public static List<ImportResultsWrapper> importStationsCSVFile(Id fileId){
		List<ImportResultsWrapper> results = new List<ImportResultsWrapper>();
		try{

			UserInfoRecordsWrapper ui = getUserInfo();

			//SELECT Id, City__c, Code__c, Description__c FROM Address__c
			List<Address__c> allAddr = getAllStations();
			List<Address__c> userAddr = getITPStations();

			Map<String, Address__c> mAllAddr = new Map<String, Address__c>();
			Map<String, Address__c> mUserAddr = new Map<String, Address__c>();

			for(Address__c addr : allAddr){
				mAllAddr.put(addr.Code__c, addr);
			}
			for(Address__c addr : userAddr){
				mUserAddr.put(addr.Code__c, addr);
			}

			ContentVersion cv=[select id,ContentDocumentId,versiondata from Contentversion where ContentDocumentId=:fileId AND IsLatest = true ];
			//ContentVersion cv=[select id,ContentDocumentId,versiondata from Contentversion where ContentDocumentId='0690Q000000MH4TQAW' AND IsLatest = true ];
			Blob csvFileBody =cv.VersionData;
			String csvAsString= csvFileBody.toString();
			List<String> csvFileLines= csvAsString.split('\n');

			//Remove Empty Lines
			Integer index = 0;
			while(index < csvFileLines.size()){
				if(String.isBlank(csvFileLines[index])){
					csvFileLines.remove(index);
				} else {
					index++;
				}
			}
			//Remove duplicated station code
			Set<String> stationCodesSet = new Set<String>();
			for(Integer i=1;i<csvFileLines.size();i++){
				String code = csvFileLines[i].trim();
				stationCodesSet.add(code);
			}

			List<Role_Address__c> stationsToInsert = new List<Role_Address__c>();
			for(String code: stationCodesSet){
				//string[] csvRecordData = csvFileLines[i].split(',');

				//String code = csvFileLines[i].trim();

				if(mUserAddr.containsKey(code)){
					Address__c addr = mUserAddr.get(code);
					ImportResultsWrapper irw = new ImportResultsWrapper(
						code,
						addr.Description__c,
						'Code already existing',
						'Failed'
					);

					results.add(irw);
				}else if(mAllAddr.containsKey(code)){
					Address__c addr = mAllAddr.get(code);
					stationsToInsert.add(
							new Role_Address__c( Address__c= addr.Id,
													Name= ui.accountName + ' ' + addr.Description__c,
													Account_Role_Service__c= ui.accountRoleSrv));

					ImportResultsWrapper irw = new ImportResultsWrapper(
						code,
						addr.Description__c,
						'Code ready to import',
						'Failed'
					);

					results.add(irw);
				}else{
					ImportResultsWrapper irw = new ImportResultsWrapper(code, '', 'Code with error or non-existing', 'Failed');
					results.add(irw);
				}

			}

			if(stationsToInsert.size() > 0){
				insert stationsToInsert;

				for(ImportResultsWrapper r : results){
					if(r.result !=  'Code already existing' && r.result != 'Code with error or non-existing'){
						r.result = 'Code imported with Success';
						r.resultStatus = 'Succeeded';
					}
				}
			}
		}
		catch (Exception e){
			//ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importin data Please make sure input csv file is correct');
			//ApexPages.addMessage(errorMessage);
			ImportResultsWrapper irw = new ImportResultsWrapper('', '', 'An error has occured while importin data Please make sure input csv file is correct', 'Failed');
			results.add(irw);

		}
		// Remove file from salesforce
		List<ContentDocument> fileList = new List<ContentDocument>();
		fileList.add(new ContentDocument(id = fileId));
		delete fileList;
		return results;
	}

	@AuraEnabled (cacheable=false)
	public static List<ImportResultsWrapper> importEmployeesCSVFile(Id fileId){
		List<ImportResultsWrapper> results = new List<ImportResultsWrapper>();
		/* List<IFTP_History__c> populated with     -> one record for each employee inserted
													-> one record for each station associated to the employee (role_address__c record inserted)
													-> one record for each station removed from the employee (role_address__c record deleted) */
		List<IFTP_History__c> IftpHistoryRecordsToBeInserted = new List<IFTP_History__c>();
		List<IFTP_History__c> IftpHistoryStartWorkingItp = new List<IFTP_History__c>();
		List<IFTP_History__c> IftpHistoryStartWorkingStation = new List<IFTP_History__c>();
		List<IFTP_History__c> IftpHistoryStopWorkingStation = new List<IFTP_History__c>();
		List<IFTP_History__c> IftpHistoryLoseProficiency = new List<IFTP_History__c>();

		try{

			String RECTYPE_ITP = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'ITP');

			UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();

			List<Account_Contact_Role__c> accEmps = getAllITPEmployees(ui.accountId);
			List<Address__c> allAddr = getAllStations();
			List<Address__c> userAddr = getITPStations(ui.accountId);


			Map<String, Account_Contact_Role__c> mAccEmps = new Map<String, Account_Contact_Role__c>();
			Map<String, Address__c> mAllAddr = new Map<String, Address__c>();
			Map<String, Address__c> mUserAddr = new Map<String, Address__c>();

			for(Account_Contact_Role__c emp : accEmps){
				if(String.isNotBlank(emp.Company_Code__c)){
					mAccEmps.put(emp.Company_Code__c, emp);
				}
			}
			for(Address__c addr : allAddr){
				mAllAddr.put(addr.Code__c, addr);
			}
			for(Address__c addr : userAddr){
				mUserAddr.put(addr.Code__c, addr);
			}

			ContentVersion cv=[select id,ContentDocumentId,versiondata from Contentversion where ContentDocumentId=:fileId AND IsLatest = true ];
			Blob csvFileBody =cv.VersionData;
			String csvAsString= csvFileBody.toString();

			List<String> csvFileLines= csvAsString.split('\n');

			//Remove Empty Lines
			Integer index = 0;
			while(index < csvFileLines.size()){
				if(String.isBlank(csvFileLines[index])){
					csvFileLines.remove(index);
				} else {
					index++;
				}
			}

			List<String> allMessages;


			Map<String, List<String>> mapEmployeeInfoByEmployeeCode = new Map<String, List<String>>();
			for(Integer i=1;i<csvFileLines.size();i++){
				string[] csvRecordData = csvFileLines[i].split(',');
				if(String.isNotBlank(clearString(csvRecordData[0])) && mapEmployeeInfoByEmployeeCode.containsKey(clearString(csvRecordData[0]))){
						ImportResultsWrapper irw = new ImportResultsWrapper(
							clearString(csvRecordData[0]),
							clearString(csvRecordData[1])+ ' ' + clearString(csvRecordData[2]),
							'Employee Code duplicated in import CSV file. ',
							'Failed');
						irw.firstName = clearString(csvRecordData[1]);
						irw.lastName = clearString(csvRecordData[2]);
						results.add(irw);

						List<String> duplicatedRecord = mapEmployeeInfoByEmployeeCode.get(clearString(csvRecordData[0]));

						ImportResultsWrapper irw2 = new ImportResultsWrapper(
							clearString(duplicatedRecord[0]),
							clearString(duplicatedRecord[1]) + ' ' + clearString(duplicatedRecord[2]),
							'Employee Code duplicated in import CSV file. ',
							'Failed');
						irw2.firstName = clearString(duplicatedRecord[1]);
						irw2.lastName = clearString(duplicatedRecord[2]);
						results.add(irw2);
						mapEmployeeInfoByEmployeeCode.remove(clearString(csvRecordData[0]));

				} else {
					if(String.isNotBlank(clearString(csvRecordData[0]))){
						mapEmployeeInfoByEmployeeCode.put(clearString(csvRecordData[0]), csvRecordData);
					}
				}
			}

			List<Contact> contactsToInsert = new List<Contact>();
			List<Contact> contactsToUpdate = new List<Contact>();
			List<Account_Contact_Role__c> accContRoleToInsert = new List<Account_Contact_Role__c>();
			List<Account_Contact_Role__c> accContRoleToUpdate = new List<Account_Contact_Role__c>();
			Map<String, Set<String>> mapEmployeeStationCodes = new Map<String, Set<String>>();
			List<Role_Address__c> roleAdressToInsert = new List<Role_Address__c>();
			List<Role_Address__c> roleAddressesToUpdatePrimaryStation = new List<Role_Address__c>();
			List<Role_Address__c> existingRoleAddresses = new List<Role_Address__c>();

			for(Integer i=1;i<csvFileLines.size();i++){
				string[] csvRecordData = csvFileLines[i].split(',');
				if(csvRecordData != null && csvRecordData.size() > 0){
					// Save errors
					allMessages = new List<String>();

					//Employee Code,First Name,Last Name,Coordinator,Business Email
					String companyCode = clearString(csvRecordData[0]);
					String firstName = clearString(csvRecordData[1]);
					String lastName = clearString(csvRecordData[2]);
					String title = clearString(csvRecordData[3]);
					String phone = clearString(csvRecordData[4]);
					if(String.isBlank(phone)){
						phone = '00';
					}

					String details = clearString(csvRecordData[5]);

					// Check mandatory fields
					if(String.isBlank(companyCode)){
						allMessages.add('Employee Code is missing; ');
					}
					if(String.isBlank(firstName)){
						allMessages.add('First Name is missing; ');
					}
					if(String.isBlank(lastName)){
						allMessages.add('Last Name is missing; ');
					}

					// stations: Removes double quotes from string
					String stationsCodesString = clearString(csvRecordData[6]);

					if(String.isBlank(stationsCodesString)){
						allMessages.add('No station associated; ');
					} else {
						if(allMessages.size() == 0){
							// stations: Splits string into separated station codes
							List<String> auxstationsCodes = new List<String>();
							Set<String> stationsCodes = new Set<String>();
							auxstationsCodes = stationsCodesString.split(';');
							if(auxstationsCodes.size() > 0){

								// stations: trim codes and remove duplicates
								for(String code: auxstationsCodes){
									stationsCodes.add(code.trim());
								}
								// Check if ITP has station
								Boolean addrInITPAddrs = false;
								Boolean toBeMapped = true;
								for(String code: stationsCodes){
									addrInITPAddrs = false;
									toBeMapped = true;
									if(mUserAddr.containsKey(code)){
										addrInITPAddrs = true;
									}
									if(!addrInITPAddrs){
										Boolean exists = false;
										if(mAllAddr.containsKey(code)){
											exists = true;
										}

										if(exists){
											allMessages.add(code + ' not a station of this ITP; ');
										} else {
											allMessages.add(code + ' is not a valid station code; ');

										}
										toBeMapped = false;
									}
								}
								if(toBeMapped){
									mapEmployeeStationCodes.put(companyCode, stationsCodes);
								}
							}
						}
					}

					if(allMessages.size() > 0){
						String aux = 'Failed: ';
						for(String s: allMessages){
							aux = aux + s;
						}
						ImportResultsWrapper irw = new ImportResultsWrapper(
							companyCode,
							firstName + ' ' + lastName,
							aux,
							'Failed');
						irw.firstName = firstName;
						irw.lastName = lastName;

						results.add(irw);
					}

					if(allMessages.isEmpty() && mapEmployeeInfoByEmployeeCode.containsKey(companyCode)){
						Contact cont = new Contact();
						Account_Contact_Role__c accContRole = new Account_Contact_Role__c();

						cont.FirstName = firstName;
						cont.LastName = lastName;
						cont.AssistantName = companyCode;
						cont.AccountId = ui.accountId;
						cont.Title = title;
						cont.Phone = phone;
						cont.Status__c = 'Active';

						accContRole.Company_Code__c = companyCode;
						accContRole.Service_Rendered__c = 'IFTP';
						accContRole.Status__c = 'Active';
						accContRole.RecordTypeId = RECTYPE_ITP;
						accContRole.Account_Role__c = ui.accountRole;
						accContRole.Contact_Role__c = 'ITP Trainee';
						accContRole.Details__c = details;

						Boolean isInsert = false;
						IFTP_History__c ihrec;
						if(mAccEmps.containsKey(companyCode)){
							cont.Id = mAccEmps.get(companyCode).Contact__c;
							contactsToUpdate.add(cont);

							accContRole.Id = mAccEmps.get(companyCode).Id;
							accContRoleToUpdate.add(accContRole);
							if(mAccEmps.get(companyCode).Status__c.equalsIgnoreCase('Inactive')){
								ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Start_Working_for_ITP,
																		accContRole.Company_Code__c,
																		cont.FirstName,
																		cont.LastName);
								IftpHistoryStartWorkingItp.add(ihrec);
							}
						} else{
							contactsToInsert.add(cont);
							accContRoleToInsert.add(accContRole);
							isInsert = true;
							ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Start_Working_for_ITP,
																		accContRole.Company_Code__c,
																		cont.FirstName,
																		cont.LastName);
							IftpHistoryStartWorkingItp.add(ihrec);
						}

						ImportResultsWrapper irw = new ImportResultsWrapper(
							companyCode,
							firstName + ' ' + lastName,
							'Code ready to import',
							'Failed'
						);
						irw.firstName = firstName;
						irw.lastName = lastName;

						if(isInsert){
							irw.typeDMLOperation = 'Insert';
						} else {
							irw.typeDMLOperation = 'Update';
						}
						results.add(irw);
					}
				}
			}

			if(contactsToInsert.size() > 0 || contactsToUpdate.size() > 0){

				Savepoint sp = Database.setSavepoint();
				try {
					if(contactsToInsert.size() > 0){
						insert contactsToInsert;
						Map<String, Contact> contByCodeMap = new Map<String, Contact>();
						for(Contact c : contactsToInsert){
							contByCodeMap.put(c.AssistantName, c);
						}

						for(Account_Contact_Role__c acr : accContRoleToInsert){
							if(contByCodeMap.containsKey(acr.Company_Code__c)){
								acr.Contact__c = contByCodeMap.get(acr.Company_Code__c).Id;
							}
						}
						insert accContRoleToInsert;
					}

					if(contactsToUpdate.size() > 0){
						// Update Contacts
						update contactsToUpdate;

						// Update Account_Contact_Role__c
						update accContRoleToUpdate;
						// Get information on employee-stations relationships for employees in contactsToUpdate list
						existingRoleAddresses = [SELECT Id,
														Account_Contact_Role__c,
														Account_Contact_Role__r.First_Name__c,
														Account_Contact_Role__r.Last_Name__c,
														Account_Contact_Role__r.Company_Code__c,
														Address__r.Code__c,
														Address__r.City__c,
														Primary__c
													FROM Role_Address__c
													WHERE Account_Contact_Role__c IN :accContRoleToUpdate];
					}
					// Insert in Role_Address__C (all records, from inserted and updateed contacts)
					for(String key: mapEmployeeStationCodes.keySet()){
						Id accountContactRoleID;
						Set<String> stationsCodes = new Set<String>();
						Boolean isUpdateEmployee = true;
						if(mAccEmps.containsKey(key)){
							accountContactRoleID = mAccEmps.get(key).Id;
							isUpdateEmployee = true;
						} else{
							if(contactsToInsert.size() > 0){
								for(Account_Contact_Role__c acr : accContRoleToInsert){
									if( acr.Company_Code__c == key ){
										accountContactRoleID = acr.Id;
										isUpdateEmployee = false;
										break;
									}
								}
							}

						}

						stationsCodes = mapEmployeeStationCodes.get(key);
						if(accountContactRoleID != null){
							Boolean isFirstStation = true;
							for(String code: stationsCodes ){
								Boolean exists = false;
								if(isUpdateEmployee){
									// Check if station to be added is already a station of that employee
									Integer j = 0;
									while(j < existingRoleAddresses.size()){
										if(existingRoleAddresses[j].Address__r.Code__c.equalsIgnoreCase(code) && existingRoleAddresses[j].Account_Contact_Role__r.Company_Code__c.equalsIgnoreCase(key)){
											exists = true;
											if(isFirstStation){
												if(!existingRoleAddresses[j].Primary__c){
													existingRoleAddresses[j].Primary__c = true;
													roleAddressesToUpdatePrimaryStation.add(existingRoleAddresses[j]);
												}
												isFirstStation = false;
											} else{
												if(existingRoleAddresses[j].Primary__c){
													existingRoleAddresses[j].Primary__c = false;
													roleAddressesToUpdatePrimaryStation.add(existingRoleAddresses[j]);
												}
											}
											existingRoleAddresses.remove(j);
											break;
										} else {
											j++;
										}
									}
								}
								if(!exists){
									if( mAllAddr.containsKey(code)){
										Address__c station = mAllAddr.get(code);
										Role_Address__c roleAddressAux = new Role_Address__c();
										roleAddressAux.Account_Contact_Role__c = accountContactRoleID;
										roleAddressAux.Address__c = station.Id;
										roleAddressAux.Primary__c = false;
										if(isFirstStation){
											roleAddressAux.Primary__c = true;
											isFirstStation = false;
										}
										roleAdressToInsert.add(roleAddressAux);
										break;
									}
								}
							}
						}
					}
					insert roleAdressToInsert;

					if(roleAddressesToUpdatePrimaryStation.size() > 0){
						update roleAddressesToUpdatePrimaryStation;
					}

					// Create and Insert records on IFTP_History
					// For Stations the Employee start working in
					List<Role_Address__c> roleAdressInserted = [SELECT Id,
														Account_Contact_Role__c,
														Account_Contact_Role__r.First_Name__c,
														Account_Contact_Role__r.Last_Name__c,
														Account_Contact_Role__r.Company_Code__c,
														Address__r.Code__c,
														Address__r.City__c
													FROM Role_Address__c
													WHERE id IN :roleAdressToInsert];
					for(Role_Address__c rolAddr: roleAdressInserted){
						IFTP_History__c ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Start_Working_at_Station,
																		rolAddr.Account_Contact_Role__r.Company_Code__c,
																		rolAddr.Account_Contact_Role__r.First_Name__c,
																		rolAddr.Account_Contact_Role__r.Last_Name__c,
																		rolAddr.Address__r.Code__c,
																		rolAddr.Address__r.City__c
																		);
						IftpHistoryStartWorkingStation.add(ihrec);
					}

					// For stations the employee is no longer working in
					// Insert record on IFTP_History__c with Stop working at Station
					for(Role_Address__c rolAddr: existingRoleAddresses){
						IFTP_History__c ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Stop_Working_at_Station,
																		rolAddr.Account_Contact_Role__r.Company_Code__c,
																		rolAddr.Account_Contact_Role__r.First_Name__c,
																		rolAddr.Account_Contact_Role__r.Last_Name__c,
																		rolAddr.Address__r.Code__c,
																		rolAddr.Address__r.City__c
																		);
						IftpHistoryStopWorkingStation.add(ihrec);
					}
					// For every proficiency related record, of the employee in the station he stopped working
					// get role_address__c records
					List<Role_Address__c> roleAdressToBeDeleted = new List<Role_Address__c>();
					List<String> employeeeCodesList = new List<String>();
					List<String> addressCodesList = new List<String>();
					for(Role_Address__c rolAddr: existingRoleAddresses){
						addressCodesList.add(rolAddr.Address__r.Code__c);
						employeeeCodesList.add(rolAddr.Account_Contact_Role__r.Company_Code__c);
					}
					List<Role_Address__c> proficiencyRecords = [SELECT Id,
																		Contact_Role_Certification__r.Account_Contact_Role__c,
																		Contact_Role_Certification__r.Account_Contact_Role__r.First_Name__c,
																		Contact_Role_Certification__r.Account_Contact_Role__r.Last_Name__c,
																		Contact_Role_Certification__r.Account_Contact_Role__r.Company_Code__c,
																		Address__r.Code__c,
																		Address__r.City__c,
																		Contact_Role_Certification__r.Certification__r.Name,
																		Proficiency_level__c,
																		Proficiency_Granted_By__c
																FROM Role_Address__c
																WHERE Address__r.Code__c IN :addressCodesList
																AND Contact_Role_Certification__r.Account_Contact_Role__r.Company_Code__c IN :employeeeCodesList];
					for(Role_Address__c rolAddr: existingRoleAddresses){
						roleAdressToBeDeleted.add(rolAddr);
						for(Role_Address__c proficiencyRec: proficiencyRecords){
							if(rolAddr.Address__r.Code__c.equalsIgnoreCase(proficiencyRec.Address__r.Code__c)
							&& rolAddr.Account_Contact_Role__r.Company_Code__c.equalsIgnoreCase(proficiencyRec.Contact_Role_Certification__r.Account_Contact_Role__r.Company_Code__c))
							roleAdressToBeDeleted.add(proficiencyRec);
							IFTP_History__c ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Loose_Proficiency,
																			proficiencyRec.Contact_Role_Certification__r.Account_Contact_Role__r.Company_Code__c,
																			proficiencyRec.Contact_Role_Certification__r.Account_Contact_Role__r.First_Name__c,
																			proficiencyRec.Contact_Role_Certification__r.Account_Contact_Role__r.Last_Name__c,
																			proficiencyRec.Address__r.Code__c,
																			proficiencyRec.Address__r.City__c,
																			proficiencyRec.Contact_Role_Certification__r.Certification__r.Name,
																			proficiencyRec.Proficiency_level__c,
																			proficiencyRec.Proficiency_Granted_By__c
																			);
							IftpHistoryLoseProficiency.add(ihrec);

						}
					}

					// delete records from role_address__c
					// station related to employee records and employee proficiency related to station records
					delete roleAdressToBeDeleted;
					//insert all history records
					IftpHistoryRecordsToBeInserted.addAll(IftpHistoryLoseProficiency);
					IftpHistoryRecordsToBeInserted.addAll(IftpHistoryStopWorkingStation);
					IftpHistoryRecordsToBeInserted.addAll(IftpHistoryStartWorkingItp);
					IftpHistoryRecordsToBeInserted.addAll(IftpHistoryStartWorkingStation);

					if(IftpHistoryRecordsToBeInserted.size() > 0){
						portalIftpHistoryManagement.insertIntoIftpHistory(IftpHistoryRecordsToBeInserted);
					}

					for(ImportResultsWrapper r : results){
						if(r.result ==  'Code ready to import'){
							if(r.typeDMLOperation.equalsIgnoreCase('Insert')){
								r.result = 'Employee Data Imported with Success.';
								r.resultStatus = 'Succeeded';
							} else {
								if(r.typeDMLOperation.equalsIgnoreCase('Update')){
									r.result = 'Employee Data Updated with Success.';
									r.resultStatus = 'Succeeded';
								}
							}

						}
					}

				} catch (DMLException e) {
					System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - importEmployeesCSVFile] DMLException - ' + e );
					System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - importEmployeesCSVFile] DMLException - ' + e.getStackTraceString() );
					Database.rollback(sp);

					ImportResultsWrapper irw = new ImportResultsWrapper('', '', 'An error has occurred while importing data. Please make sure input CSV file is correct.', 'Failed');
					results.add(irw);
				}

			}
		}
		catch (Exception e){
			//ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importin data Please make sure input csv file is correct');
			//ApexPages.addMessage(errorMessage);
			String errorMessage = 'An error has occurred while importing data. Please make sure input CSV file is correct.';
			if(e.getMessage().contains('BLOB is not a valid UTF-8 string')){
				errorMessage = 'The input CSV file is not in a correct format. Please import CSV with UTF-8 format';
			}
			System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - importEmployeesCSVFile] Exception - ' + e );
			System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - importEmployeesCSVFile] Exception - ' + e.getStackTraceString() );

			ImportResultsWrapper irw = new ImportResultsWrapper('', '',errorMessage , 'Failed');
			results.add(irw);

		}

		// Remove file from salesforce
		List<ContentDocument> fileList = new List<ContentDocument>();
		fileList.add(new ContentDocument(id = fileId));
		delete fileList;
		return results;
	}


	@AuraEnabled (cacheable=false)
	public static List<ImportResultsWrapper> inactivateEmployeesCSVFile(Id fileId){
		List<ImportResultsWrapper> results = new List<ImportResultsWrapper>();

		try{
			ContentVersion cv=[select id,ContentDocumentId,versiondata from Contentversion where ContentDocumentId=:fileId AND IsLatest = true ];
			Blob csvFileBody =cv.VersionData;
			String csvAsString= csvFileBody.toString();
			List<String> csvFileLines= csvAsString.split('\n');

			Integer index = 0;
			while(index < csvFileLines.size()){
				if(String.isNotBlank(clearString(csvFileLines[index]))){
					csvFileLines[index] = clearString(csvFileLines[index]);
				}
				if(String.isBlank(csvFileLines[index])){
					csvFileLines.remove(index);
				} else {
					index++;
				}
			}

			if (!csvFileLines.isEmpty()){

				UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();
				List<Account_Contact_Role__c> accEmps = getAllITPEmployees(ui.accountId);

				List<Account_Contact_Role__c> accContRoleToInactive = new List<Account_Contact_Role__c>();
				List<Contact> contactsToInactive = new List<Contact>();
				List<Role_Address__c> roleAdressToBeDeleted = new List<Role_Address__c>();
				List<IFTP_History__c> IftpHistoryRecordsToBeInserted = new List<IFTP_History__c>();
				List<IFTP_History__c> IftpHistoryStoptWorkingItp = new List<IFTP_History__c>();
				List<IFTP_History__c> IftpHistoryStopWorkingStation = new List<IFTP_History__c>();
				List<IFTP_History__c> IftpHistoryLoseProficiency = new List<IFTP_History__c>();

				Map<String, Account_Contact_Role__c> mapEmployeesByCompanyCode = new Map<String, Account_Contact_Role__c>();
				for(Account_Contact_Role__c rec: accEmps){
					if(String.isNotBlank(rec.Company_Code__c)){
						mapEmployeesByCompanyCode.put(rec.Company_Code__c, rec);
					}
				}
				for(Integer x = 1; x < csvFileLines.size(); x++){
					if(mapEmployeesByCompanyCode.containsKey(csvFileLines[x])){
						if(mapEmployeesByCompanyCode.get(csvFileLines[x]).Status__c.compareTo('Inactive') == 0){
							ImportResultsWrapper irwDeleted = new ImportResultsWrapper(csvFileLines[x], '', 'Employee already deleted.', 'Failed');
							irwDeleted.lastName = mapEmployeesByCompanyCode.get(csvFileLines[x]).Last_Name__c;
							irwDeleted.firstName = mapEmployeesByCompanyCode.get(csvFileLines[x]).First_Name__c;
							results.add(irwDeleted);
						} else {
							accContRoleToInactive.add(mapEmployeesByCompanyCode.get(csvFileLines[x]));
							ImportResultsWrapper irwForDeletion = new ImportResultsWrapper(
								csvFileLines[x],'','Employee ready for deletion.','Failed');
							irwForDeletion.lastName = mapEmployeesByCompanyCode.get(csvFileLines[x]).Last_Name__c;
							irwForDeletion.firstName = mapEmployeesByCompanyCode.get(csvFileLines[x]).First_Name__c;
							results.add(irwForDeletion);
						}

					} else {
						ImportResultsWrapper irw = new ImportResultsWrapper(
							csvFileLines[x],
							'',
							'Failed: Employee code doesn\'t exist.',
							'Failed'
						);
						results.add(irw);
					}
				}

				for(Account_Contact_Role__c rec: accContRoleToInactive){
					rec.Status__c = 'Inactive';
					Contact contactToUpdate = new Contact();
					contactToUpdate.Id = rec.Contact__c;
					contactToUpdate.Status__c = rec.Status__c;
					contactsToInactive.add(contactToUpdate);
					IFTP_History__c ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Stop_Working_for_ITP,
																								rec.Company_Code__c,
																								rec.First_Name__c,
																								rec.Last_Name__c);
					IftpHistoryStoptWorkingItp.add(ihrec);
				}
				roleAdressToBeDeleted = [SELECT Id,
												Account_Contact_Role__c,
												Account_Contact_Role__r.First_Name__c,
												Account_Contact_Role__r.Last_Name__c,
												Account_Contact_Role__r.Company_Code__c,
												Contact_Role_Certification__r.Account_Contact_Role__c,
												Contact_Role_Certification__r.Account_Contact_Role__r.First_Name__c,
												Contact_Role_Certification__r.Account_Contact_Role__r.Last_Name__c,
												Contact_Role_Certification__r.Account_Contact_Role__r.Company_Code__c,
												Address__r.Code__c,
												Address__r.City__c,
												Contact_Role_Certification__r.Certification__r.Name,
												Proficiency_level__c,
												Proficiency_Granted_By__c
											FROM Role_Address__c
											WHERE Account_Contact_Role__c IN :accContRoleToInactive
											OR Contact_Role_Certification__r.Account_Contact_Role__c IN :accContRoleToInactive];
				for(Role_Address__c rolAddr: roleAdressToBeDeleted){
					IFTP_History__c ihrec;
					if(String.isNotBlank(rolAddr.Account_Contact_Role__r.Company_Code__c)){
						ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Stop_Working_at_Station,
																		rolAddr.Account_Contact_Role__r.Company_Code__c,
																		rolAddr.Account_Contact_Role__r.First_Name__c,
																		rolAddr.Account_Contact_Role__r.Last_Name__c,
																		rolAddr.Address__r.Code__c,
																		rolAddr.Address__r.City__c
																		);
						IftpHistoryStopWorkingStation.add(ihrec);
					} else {
						ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Loose_Proficiency,
																			rolAddr.Contact_Role_Certification__r.Account_Contact_Role__r.Company_Code__c,
																			rolAddr.Contact_Role_Certification__r.Account_Contact_Role__r.First_Name__c,
																			rolAddr.Contact_Role_Certification__r.Account_Contact_Role__r.Last_Name__c,
																			rolAddr.Address__r.Code__c,
																			rolAddr.Address__r.City__c,
																			rolAddr.Contact_Role_Certification__r.Certification__r.Name,
																			rolAddr.Proficiency_level__c,
																			rolAddr.Proficiency_Granted_By__c
																			);
						IftpHistoryLoseProficiency.add(ihrec);
					}
				}

				//query database account_contact_role where company_code in list and accountid: useraccountid, get account_contact_role.id and contact.id
				//update status = inactive
				if(contactsToInactive.size() > 0 || accContRoleToInactive.size() > 0){
					Savepoint sp = Database.setSavepoint();
					try{
						update contactsToInactive;
						update accContRoleToInactive;
						// delete records from role_address__c
						// station related to employee records and employee proficiency related to station records
						delete roleAdressToBeDeleted;
						//insert all history records
						IftpHistoryRecordsToBeInserted.addAll(IftpHistoryLoseProficiency);
						IftpHistoryRecordsToBeInserted.addAll(IftpHistoryStopWorkingStation);
						IftpHistoryRecordsToBeInserted.addAll(IftpHistoryStoptWorkingItp);
						portalIftpHistoryManagement.insertIntoIftpHistory(IftpHistoryRecordsToBeInserted);

						for(ImportResultsWrapper r : results){
							if(r.result ==  'Employee ready for deletion.'){
								r.result = 'Employee deleted with success.';
								r.resultStatus = 'Succeeded';
							}
						}

					} catch (DMLException e) {
						System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - importEmployeesCSVFile] DMLException - ' + e );
						System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - importEmployeesCSVFile] DMLException - ' + e.getStackTraceString() );
						Database.rollback(sp);

						ImportResultsWrapper irw = new ImportResultsWrapper('','','An error has occurred while deleting employees data. Please make sure input CSV file is correct.', 'Failed');
						results.add(irw);
					}
				}
			}
		}
		catch (Exception e){
			System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - importEmployeesCSVFile] Exception - ' + e );
			System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - importEmployeesCSVFile] Exception - ' + e.getStackTraceString() );
			String errorMessage = 'An error has occurred while deleting employees data. Please make sure input CSV file is correct.';
			if(e.getMessage().contains('BLOB is not a valid UTF-8 string')){
				errorMessage = 'The input CSV file is not in a correct format. Please import CSV with UTF-8 format';
			}
			ImportResultsWrapper irw = new ImportResultsWrapper('', '', errorMessage, 'Failed');
			results.add(irw);
		}

		// Remove file from salesforce
		List<ContentDocument> fileList = new List<ContentDocument>();
		fileList.add(new ContentDocument(id = fileId));
		delete fileList;

		return results;
	}


	@AuraEnabled (cacheable=false)
	public static Boolean manageUploadGlobalOJT(Id fileId){
		return manageUploadOJTFile('Global', fileId, null, null);
	}

	@AuraEnabled (cacheable=false)
	public static Boolean manageUploadStationOJT(Id fileId, Id recordID, String stationInfo){
		return manageUploadOJTFile('Station', fileId, recordID, stationInfo);
	}
	/*
		Method: manageUploadOJTFile
		For this method is necessary to have a library on Salesforce to place the file, in order to
		allow sharing (pdf download).
		To acomplish this make sure to have the library created, with permissions for a specific
		public group (that contains all the necessary groups of users) as 'Portal Partner', and keep the id
		of the library in a custom setting as follows: custom settings->ISS cs -> 'IFTP-DocumentLibrary'

	*/
	@AuraEnabled (cacheable=false)
	public static Boolean manageUploadOJTFile(String type, Id fileId, Id recordID, String stationInfo){
		Boolean result = true;
		try{
			UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();
			Id ownerId = [Select Id FROM group WHERE Type = 'Queue' and Name = 'IFTP'].Id;

			ID ProcessRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CS_Process_IDFS_ISS');

			Savepoint sp = Database.setSavepoint();
			try {
				if(type.equalsIgnoreCase('Station')){
					Role_Address__c rolAddr = new Role_Address__c();
					rolAddr.id = recordID;
					rolAddr.OJT_File_Id__c = fileId;
					rolAddr.OJT_file_validated__c = false;
					update rolAddr;
				} else {
					if(type.equalsIgnoreCase('Global')){
						Account_Role__c accRole = new Account_Role__c();
						accRole.id = ui.accountRole;
						accRole.OJT_file_id__c = fileId;
						accRole.OJT_file_validated__c = false;
						update accRole;
					}
				}
				if(!Test.isRunningTest()){
					ContentDocumentLink cdl = new ContentDocumentLink();
					cdl.ContentDocumentId = fileId;
					cdl.ShareType = 'I';
					cdl.Visibility = 'AllUsers';
					cdl.LinkedEntityId = ISSP_CS__c.getValues('IFTP-DocumentLibrary').Value__c;
					insert cdl;
				}

				//Create case for upload file validation
				ContentVersion cversion = [select id, title, versiondata, fileType from ContentVersion where ContentDocumentId = :fileId AND IsLatest = true  LIMIT 1];
				String description;
				String subject;
				if(type.equalsIgnoreCase('Station')){
					description = 'Request Station OJT File Validation: \n' + 'Station: ' + stationInfo + ' \n';
					subject = 'Request Station OJT File Validation';
				} else {
					if(type.equalsIgnoreCase('Global')){
						description = 'Request Global OJT File Validation \n';
						subject = 'Request Global OJT File Validation';
					}
				}
				Case transferCase = new Case();
				transferCase.recordtypeID = ProcessRTId;
				transferCase.AccountId = ui.accountId;
				transferCase.OwnerId = ownerId;
				transferCase.Subject = subject;
				transferCase.Description = description;
				transferCase.ContactId = ui.contactId;
				transferCase.Status = 'Open';
				transferCase.Visible_on_ISS_Portal__c = true;
				transferCase.CaseArea__c = 'IATA Fuelling Training Portal (IFTP)';
				transferCase.Reason1__c  = 'IFTP OJT File Validation';
				transferCase.Region__c = ui.accountRegion;
				transferCase.BSPCountry__c = ui.accountCountry;
				insert transferCase;

				Attachment att = new Attachment();
				att.ParentId = transferCase.Id;
				att.Name = cversion.title + '.' + cversion.fileType;
				att.Body = cversion.VersionData;
				insert att;
			}
			catch (DMLException e) {
				result = false;
				System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - manageUploadOJTFile] DMLException - ' + e );
				System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - manageUploadOJTFile] DMLException - ' + e.getStackTraceString() );
				Database.rollback(sp);
				try{
					List<ContentDocument> fileList = new List<ContentDocument>();
					fileList.add(new ContentDocument(id = fileId));
					delete fileList;
				}
				catch (DMLException eDML) {
					result = false;
					System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - manageUploadOJTFile] DMLException delete fileList - ' + eDML );
					System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - manageUploadOJTFile] DMLException delete fileList - ' + eDML.getStackTraceString());
				}
			}
		}
		catch (Exception ex){
			result = false;
			System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - manageUploadOJTFile] Exception - ' + ex );
			System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - manageUploadOJTFile] Exception - ' + ex.getStackTraceString() );
		}
		return result;
	}

	public class ImportResultsWrapper {

		@AuraEnabled
		public String code {get;set;}
		@AuraEnabled
		public String firstName {get;set;}
		@AuraEnabled
		public String lastName {get;set;}
		@AuraEnabled
		public String description {get;set;}
		@AuraEnabled
		public String result {get;set;}
		@AuraEnabled
		public String typeDMLOperation {get;set;}
		@AuraEnabled
		public String resultStatus {get;set;}

		public ImportResultsWrapper(String code, String description, String result, String resultStatus){
			this.code = code;
			this.description = description;
			this.result = result;
			this.resultStatus = resultStatus;
		}

	}

	public class StationRecordsWrapper {

		@AuraEnabled
		public Id id {get;set;}
		@AuraEnabled
		public String name {get;set;}
		@AuraEnabled
		public String description {get;set;}
		@AuraEnabled
		public String code {get;set;}
		@AuraEnabled
		public String city {get;set;}
		@AuraEnabled
		public String airportDescription {get;set;}
		@AuraEnabled
		public Id addressId {get;set;}
		@AuraEnabled
		public String arsname {get;set;}

		public StationRecordsWrapper(){}

		public StationRecordsWrapper(Id id, String description, String code, String city, String airportDescription, Id addressId){
			this.id = id;
			this.description = description;
			this.code = code;
			this.city = city;
			this.airportDescription = airportDescription;
			this.addressId = addressId;
		}

	}

	public class UserInfoRecordsWrapper {

		@AuraEnabled
		public Id id {get;set;}
		@AuraEnabled
		public Id accountId {get;set;}
		@AuraEnabled
		public Id accountRole {get;set;}
		@AuraEnabled
		public String accountRoleStatus {get;set;}
		@AuraEnabled
		public String accountRoleType {get;set;}
		@AuraEnabled
		public Id accountRoleSrv {get;set;}
		@AuraEnabled
		public String accountRoleSrvName {get;set;}
		@AuraEnabled
		public String accountName {get;set;}
		@AuraEnabled
		public String accountRecordType {get;set;}
		@AuraEnabled
		public Id contactRoleId {get;set;}
		@AuraEnabled
		public String contactRole {get;set;}
		@AuraEnabled
		public String portalContactRole {get;set;}
		@AuraEnabled
		public String profile {get;set;}
		@AuraEnabled
		public String userPortalStatus {get;set;}
		@AuraEnabled
		public String primaryStationCode {get;set;}
		@AuraEnabled
		public String contactId {get;set;}
		@AuraEnabled
		public Boolean hasAssociatedStations {get;set;}
		@AuraEnabled
		public String accountRegion {get;set;}
		@AuraEnabled
		public String accountCountry {get;set;}
		@AuraEnabled
		public String PortalApplication {get;set;}
		@AuraEnabled
		public String PortalApplicationStatus {get;set;}

		public UserInfoRecordsWrapper(  Id id,
										Id accountId,
										Id accountRole,
										String accountRoleStatus,
										String accountRoleType,
										Id accountRoleSrv,
										String accountRoleSrvName,
										String accountName,
										String accountRecordType,
										Id contactRoleId,
										String contactRole,
										String portalContactRole,
										String profile,
										String userPortalStatus,
										String PortalApplication,
										String PortalApplicationStatus){
			this.id = id;
			this.accountId = accountId;
			this.accountRole = accountRole;
			this.accountRoleStatus = accountRoleStatus;
			this.accountRoleType = accountRoleType;
			this.accountRoleSrv = accountRoleSrv;
			this.accountRoleSrvName = accountRoleSrvName;
			this.accountName = accountName;
			this.accountRecordType = accountRecordType;
			this.contactRoleId = contactRoleId;
			this.contactRole = contactRole;
			this.portalContactRole = portalContactRole;
			this.profile = profile;
			this.userPortalStatus = userPortalStatus;
			this.PortalApplication = PortalApplication;
			this.PortalApplicationStatus = PortalApplicationStatus;
			this.hasAssociatedStations = false;

		}

	}

	public class InsertStationWrapper {
		@AuraEnabled
		public String result_message {get;set;}
		@AuraEnabled
		public Boolean succeeded {get;set;}
		@AuraEnabled
		public List<Role_Address__c> stationsToInsertList {get;set;}

		public InsertStationWrapper(String result_message, Boolean succeeded){
			this.result_message = result_message;
			this.succeeded = succeeded;
			this.stationsToInsertList = new List<Role_Address__c>();
		}
	}

	@AuraEnabled(cacheable=false)
	public static Boolean removeProficiency(String roleAddressId){

			Role_Address__c roleAddress = [SELECT Id,
											Contact_Role_Certification__r.Account_Contact_Role__r.Company_Code__c,
											Contact_Role_Certification__r.Account_Contact_Role__r.First_Name__c,
											Contact_Role_Certification__r.Account_Contact_Role__r.Last_Name__c, Address__r.City__c,
											Address__r.Code__c, Contact_Role_Certification__r.Certification__r.Name,
											Proficiency_level__c, Proficiency_Granted_By__c
										  FROM Role_Address__c WHERE Id=:roleAddressId];

		if(roleAddress.Proficiency_level__c == 'No'){
			throw new AuraHandledException('Proficiency level is already set to No');
		}
		if(roleAddress.Contact_Role_Certification__r == null){
			throw new AuraHandledException('This action is not applicable to this role address because it has no Contact Role Certification.');
		}

		try{

			roleAddress.Proficiency_level__c = 'No';
			update roleAddress;

			IFTP_History__c iftpH = new IFTP_History__c();
			iftpH.Event_Type__c = String.valueOf(portalIftpHistoryManagement.Employee_Loose_Proficiency);
			iftpH.ITP_Name__c = 'IATA INTERNAL USER';
			iftpH.Employee_Code__c = roleAddress.Contact_Role_Certification__r.Account_Contact_Role__r.Company_Code__c;
			iftpH.Employee_First_Name__c = roleAddress.Contact_Role_Certification__r.Account_Contact_Role__r.First_Name__c;
			iftpH.Employee_Last_Name__c = roleAddress.Contact_Role_Certification__r.Account_Contact_Role__r.Last_Name__c;
			iftpH.Address_Code__c = roleAddress.Address__r.Code__c;
			iftpH.Address_City__c = roleAddress.Address__r.City__c;
			iftpH.Certification_Name__c = roleAddress.Contact_Role_Certification__r.Certification__r.Name;
			iftpH.Proficiency_Level__c = roleAddress.Proficiency_level__c;
			iftpH.Proficiency_Granted_By__c = roleAddress.Proficiency_Granted_By__c;
			iftpH.Logged_User__c = 'IATA INTERNAL USER' ;

			insert iftpH;

		}catch(Exception ex){
			System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - removeProficiency] Exception - ' + ex );
			System.debug(LoggingLevel.Error, '____ [cls PortalIftpUtils - removeProficiency] Exception - ' + ex.getStackTraceString() );
			return false;
		}

		return true;

	}

	@AuraEnabled(cacheable=false)
	public static String getRedirectURL(){

		String baseUrl = Site.getBaseSecureUrl();
		String pathPrefix = Site.getPathPrefix().replace('/s', '');
		List<AppMenuItem> ami = [SELECT StartUrl FROM AppMenuItem WHERE Name = 'Absorb' LIMIT 1];
		system.assert(!ami.isEmpty(), 'Connected app Absorb does not exist.');

		return baseUrl + pathPrefix + ami[0].StartUrl;

	}
	private static String clearString(String s){
		return s.remove('"').trim();
	}
}