/*-----------------------------------------------------------------------------------------------------------//
 * Class Name	: CW_CertificationsManagerController
 * Date		  : 16/01/2020
 * Description   : Class containing controller methods for certifications manager lightning web component
 *-----------------------------------------------------------------------------------------------------------
 *	  Modification Log :
 *-----------------------------------------------------------------------------------------------------------
 *	 Modification Date				  Modification Description
 *		16/01/2020						Initial version
 *-----------------------------------------------------------------------------------------------------------*/

public with sharing class CW_CertificationsManagerController {
	final static String RT_CERTIFICATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Certification');

	final static String CEIV_LIVE_ANIMALS = 'ceiv_live_animals';
	final static String CEIV_PHARMA = 'ceiv_pharma';
	final static String CEIV_FRESH = 'ceiv_fresh';
	final static String IENVA_STAGE_1 = 'ienva_stage_1';
	final static String IENVA_STAGE_2 = 'ienva_stage_2';
	final static String UNITED_FOR_WILDLIFE = 'united_for_wildlife';
	final static String SMART_FACILITY_OPERATIONAL_CAPACITY = 'smart_facility_operational_capacity';
	final static String SMART_FACILITY_REMOTE_VALIDATION = 'Smart Facility Remote Validation';

	final static String CEIV_AVI = 'CEIV-AVI-';
	final static String CEIV_PIL = 'CEIV-PIL-';
	final static String CEIV_PER = 'CEIV-PER-';
	final static String IENVA_QTR_AC = 'IEnvA-';
	final static String UFW_QTR_AC = 'UfW-';
	final static String SFOC = 'SFOC-';
	final static String RV_SF = 'RV-SF-';

	final static String AUDITING_COMPANY = 'AC-';
	
	final static String ADMINSTRATIVE = 'Administrative';
	final static String OPERATIONAL = 'Operational';
	final static String CARGO_FACILITY_OPERATIONS = 'Cargo Facility Operations';
	final static String RAMP_OPERATIONS = 'Ramp Operations';
	final static String CARGO_HANDLING_FACILITY = 'Cargo_Handling_Facility';
	final static String RAMP_HANDLER = 'Ramp_Handler';
	final static String LABEL = 'label';
	final static String VALUE = 'value';

	final static String MD_RECORDTYPES_ACCROLEDET = 'RecordTypes_AccountRoleDetail';
	final static String MD_SCOPES_BY_RECORDTYPE = 'Scopes_by_AccRoleDet_RT';

	public static Map<String, List<String>> getRecordTypeFromAccRolDet() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : CW_FacilityCapabilitiesController.getCapabilityConfigurationMetadataByType(MD_RECORDTYPES_ACCROLEDET)) {
			output.put(currentConfig.Key__c, (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.split(';'));
		}

		return output;
	}

	public static Map<String, List<String>> getScopesByAccRoleDetRecordTypes() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : CW_FacilityCapabilitiesController.getCapabilityConfigurationMetadataByType(MD_SCOPES_BY_RECORDTYPE)) {
			output.put(currentConfig.Key__c, (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.split(';'));
		}

		return output;
	}

	/****************************************************************************
	 * @Method			: getFacilityCertifications
	 * @Created			: 16/01/2020
	 * @Description		: get all certifications related to the facility
	 * @param			: String facilityId - id of the facility
	 * @Returns			: String relatedCertifications - json containing all the related certifications
	 ****************************************************************************/
	@AuraEnabled
	public static string getFacilityCertifications(String facilityId, String stationRT, String validationPrograms) {
		List<String> listValidationPrograms = new List<String>();
		if(String.isNotBlank(validationPrograms)){
			listValidationPrograms = validationPrograms.split(',');
		}

		List<ICG_Capability_Assignment_Group__c> returnList = new List<ICG_Capability_Assignment_Group__c>();

		List<ICG_Capability_Assignment_Group__c> groupList = [SELECT id, Certification_Id__c,Is_Booked__c, Status__c, Issue_Date__c, Expiration_Date__c, ToLabel(CEIV_Scope_List__c), ToLabel(SFOC_Scope__c),ToLabel(IENVA_Scope__c), ICG_Certification__r.Name, ICG_Certification__r.Label__c, ICG_Certification__r.CreatedDate, ICG_Certification__r.Certification_Type__c,ICG_Certification__r.Expiration_Period__c,ICG_Account_Role_Detail__r.RecordType.DeveloperName, Is_Active__c
			FROM ICG_Capability_Assignment_Group__c WHERE ICG_Account_Role_Detail__c = :facilityId AND
			RecordTypeId =: RT_CERTIFICATION AND ICG_Certification__r.ValidationPrograms__c IN : listValidationPrograms ORDER BY Status__c ASC];

		List<ICG_Capability_Assignment_Group__c> orderedList = sortGroupListByStatus(groupList);
		
		for(ICG_Capability_Assignment_Group__c item : groupList){
			if (item.Is_Active__c){
				returnList.add(item);
			}
			else{
				if (item.Status__c == 'Upcoming'){
					if(!containsCerti(item,returnList)){
						returnList.add(item);
					}
				}
				else {
					if(!containsCerti(item,returnList)){
						returnList.add(item);
					}
				}
			}
			
		}

		return (JSON.serialize(returnList));
	}
	
	 /****************************************************************************
	 * @Method			: sortGroupListByStatus
	 * @Created			: 19/09/2020
	 * @Description		: return sorted list
	 * @param			: List<ICG_Capability_Assignment_Group__c> groupList
	 * @Returns			: List<ICG_Capability_Assignment_Group__c> orderedList - sorted list
	 ****************************************************************************/
	private static List<ICG_Capability_Assignment_Group__c> sortGroupListByStatus(List<ICG_Capability_Assignment_Group__c> groupList){
		List<ICG_Capability_Assignment_Group__c> orderedList= new List<ICG_Capability_Assignment_Group__c>();
		
		for(ICG_Capability_Assignment_Group__c g : groupList){
			if(g.Status__c == 'Active'){
				orderedList.add(g);
			}
		}
		for(ICG_Capability_Assignment_Group__c g : groupList){
			if(g.Status__c == 'Upcoming'){
				orderedList.add(g);
			}
		}
		for(ICG_Capability_Assignment_Group__c g : groupList){
			if(g.Status__c != 'Active' && g.Status__c != 'Upcoming'){
				orderedList.add(g);
			}
		}
		
		return orderedList;
	}
	
	/****************************************************************************
	 * @Method			: containsCerti
	 * @Created			: 19/09/2020
	 * @Description		: return if certification exist in list
	 * @param			: ICG_Capability_Assignment_Group__c item - group to find, List<ICG_Capability_Assignment_Group__c> returnList
	 * @Returns			: Boolean result - Indicates yes the list contains to the element.
	 ****************************************************************************/
	private static Boolean containsCerti(ICG_Capability_Assignment_Group__c item,List<ICG_Capability_Assignment_Group__c> returnList){
		Boolean result=false;
		
		for(ICG_Capability_Assignment_Group__c elem : returnList){
			if(elem.ICG_Certification__c == item.ICG_Certification__c){
				result=true;
			}
		}

		return result;
	}

	/****************************************************************************
	 * @Method			: refreshFacilityCertifications
	 * @Created			: 16/01/2020
	 * @Description		: get all certifications related to the facility
	 * @param			: String facilityId - id of the facility
	 * @Returns			: String relatedCertifications - json containing all the related certifications
	 ****************************************************************************/
	@AuraEnabled
	public static string refreshFacilityCertifications(string facilityId,String stationRT,String validationPrograms) {
		return getFacilityCertifications(facilityId,stationRT,validationPrograms);
	}


	/****************************************************************************
	 * @Method			: getFacilityUpcomingCertifications
	 * @Created			: 22/01/2020
	 * @Description		: get all certifications upcoming related to the facility
	 * @param			: String facilityId - id of the facility
	 * @param			: String certificationId - id of the certification
	 * @Returns			: String relatedCertifications - json containing all the upcoming certifications
	 ****************************************************************************/
	@AuraEnabled
	public static string getFacilityNotActiveCertifications(string facilityId, string certificationId, String groupId, String statusInput, String stationRT, String validationPrograms) {
		List<String> listValidationPrograms = new List<String>();
		if(String.isNotBlank(validationPrograms))
		{
			listValidationPrograms = validationPrograms.split(',');
		}

		String query = 'SELECT Id, Certification_Id__c, Status__c, Issue_Date__c, Expiration_Date__c, ToLabel(CEIV_Scope_List__c), ToLabel(SFOC_Scope__c),ToLabel(IENVA_Scope__c), ICG_Certification__r.Name, ICG_Certification__r.Label__c, ICG_Certification__r.CreatedDate, ICG_Certification__r.Certification_Type__c,ICG_Certification__r.Expiration_Period__c,ICG_Account_Role_Detail__r.RecordType.DeveloperName '+
			 'FROM ICG_Capability_Assignment_Group__c WHERE ICG_Account_Role_Detail__c =\''+ facilityId +'\' AND ICG_Certification__c =\''+ certificationId +'\' AND RecordTypeId =\''+ RT_CERTIFICATION +'\' AND Is_Active__c = false AND Status__c IN ('+statusInput+') AND Id !=\''+ groupId +'\' AND ICG_Certification__r.ValidationPrograms__c IN (\'' + String.join(listValidationPrograms, '\', \'') + '\') order by CreatedDate desc';
		List<ICG_Capability_Assignment_Group__c> firtsList = (List<ICG_Capability_Assignment_Group__c>) Database.query(query);
		
		return (JSON.serialize(firtsList));
	}

	/****************************************************************************
	 * @Method			: getAllCertifications
	 * @Created			: 16/01/2020
	 * @Description		: get all certifications in the system
	 * @Returns			: String relatedCertifications - json containing all certifications
	 ****************************************************************************/
	@AuraEnabled
	public static string getAllCertifications(String stationRT,String validationPrograms) {
		List<String> listValidationPrograms = new List<String>();
		if(String.isNotBlank(validationPrograms)){
			listValidationPrograms = validationPrograms.split(',');
		}

		List<String> lstDepts = CW_CapabilitiesUtilities.getCertificationsAllowedByDepartments(stationRT,validationPrograms);

		return (JSON.serialize([SELECT id,Name, Label__c,Certification_Type__c, Applicable_to__c,Expiration_Period__c, ValidationPrograms__c FROM ICG_Certification__c WHERE Name IN: lstDepts AND ValidationPrograms__c IN : listValidationPrograms]));
		
	}
	
	/****************************************************************************
	 * @Method			: getCertificationWithoutCapabilities
	 * @Created			: 14/07/2020
	 * @Description		: get certification that not contains capabilities
	 * @Returns			: List<tring>> certificationList - contains all certification without capabilities
	 ****************************************************************************/
	@AuraEnabled
	public static List<ICG_Certification__c> getCertificationWithoutCapabilities(String recordId, String validationPrograms) {
		List<String> listValidationPrograms = new List<String>();
		if(String.isNotBlank(validationPrograms))
		{
			listValidationPrograms = validationPrograms.split(',');
		}
		
		// Get the record type of the station and the categories availables fot this record type
		String stationRT = [SELECT RecordType.DeveloperName FROM ICG_Account_Role_Detail__c WHERE Id =: recordId].RecordType.DeveloperName.toLowerCase();
		Map<String, List<String>> categoriesByAccountRoleDetailRecordType = CW_FacilityCapabilitiesController.getMapCategoriesByAccountRoleDetailRecordType();
		List<String> allowedCategories = new List<String>();
		if (String.isNotBlank(stationRT) && categoriesByAccountRoleDetailRecordType.containsKey(stationRT)) {
			allowedCategories = categoriesByAccountRoleDetailRecordType.get(stationRT);
		}

		// Get all ICG_Certification_Capability_Assignment__c records with allowedCategories
		List<String> assignedCertifications = new List<String>();
		for(ICG_Certification_Capability_Assignment__c certCA : [SELECT ICG_Certification__c FROM ICG_Certification_Capability_Assignment__c WHERE Category__c IN :allowedCategories]){
			if (!assignedCertifications.contains(certCA.ICG_Certification__c)) {
				assignedCertifications.add(certCA.ICG_Certification__c);
			}
		}
		return [SELECT Name, Label__c from ICG_Certification__c WHERE Id NOT IN :assignedCertifications AND ValidationPrograms__c IN: listValidationPrograms];
	}

	/****************************************************************************
	 * @Method			: getScopeByCertificationAndStation
	 * @Created			: 25/06/2020
	 * @Description		: get scope filtered by certification and station
	 * @Returns			: Map<String, Map<String,String>> filteredScopesByCertiAndStation - json containing all scopes filtered
	 ****************************************************************************/
	@AuraEnabled(cacheable=true)
	public static string getScopeByCertificationAndStation() {
		List<List<String>> recordTypesList = new List<List<String>>();
		Map<String, List<String>> recordTypesFromAccRoleDet = getRecordTypeFromAccRolDet();		
		Map<String, List<String>> scopesByAccRoleDet = getScopesByAccRoleDetRecordTypes();

		List<String> recordTypes1 = recordTypesFromAccRoleDet.get('RecordTypes_AccRoleDet_1');
		List<String> recordTypes2 = recordTypesFromAccRoleDet.get('RecordTypes_AccRoleDet_2');
		List<String> recordTypes3 = recordTypesFromAccRoleDet.get('RecordTypes_AccRoleDet_3');
		recordTypesList.add(recordTypes1);
		recordTypesList.add(recordTypes2);
		recordTypesList.add(recordTypes3);

		Map<String, List<Map<String,String>>> scopesFiltered = new Map<String, List<Map<String,String>>>();
		List<Map<String,String>> scopeList;
		Map<String,String> ceivScopes;
		
		for(List<String> recordTypes : recordTypesList){
			for(String rt : recordTypes){
				scopeList = new List<Map<String,String>>();
				for(String scope : scopesByAccRoleDet.get(rt)){
						ceivScopes = new Map<String,String>();
						ceivScopes.put(LABEL,scope.replace('_', ' '));
						ceivScopes.put(VALUE,scope);
						scopeList.add(ceivScopes);	
				}
				if(!scopesFiltered.containsKey(rt)){
					scopesFiltered.put(rt,scopeList);
				}
			}
		}

		return JSON.serialize(scopesFiltered);
	}

	/****************************************************************************
	 * @Method			: getNextCertificationID
	 * @Created			: 26/06/2020
	 * @Description		: get the next certification Id value
	 * @Returns			: Map<String, Map<String,String>> filteredScopesByCertiAndStation - json containing all scopes filtered
	 ****************************************************************************/
	@AuraEnabled
	public static string getNextCertificationID(String certiSelected, String recordId) {
		String nextCertificationID = '';
		String parseYearSub = String.valueOf(Date.today().year()).substring(2);
		String parseYearAll = String.valueOf(Date.today().year());
		String initValue = '0001';

		try{
			ICG_Account_Role_Detail__c accRolDet = [SELECT Account_Role__r.Account__r.ICAO_designator__c FROM ICG_Account_Role_Detail__c WHERE Id =:recordId];
			ICG_Certification__c getCertiToRead = [SELECT Name, Label__c FROM ICG_Certification__c WHERE Id =:certiSelected];
			ICG_Capability_Assignment_Group__c[] getLastCertiID = [SELECT Certification_Id__c,Name FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Id =:certiSelected AND Certification_Id__c != null];

			String certiIdSelected;
			String parseCertiID1;
			Integer positionToSub1;
			Integer parseValue;
			String nextNumber1;
			Integer addCero=0;
			String icaoDesignator='';
			Boolean isIenvaORUfW=false;

			if(String.isNotBlank(accRolDet.Account_Role__r.Account__r.ICAO_designator__c)){
				icaoDesignator = accRolDet.Account_Role__r.Account__r.ICAO_designator__c;
			}

			if (getCertiToRead.Name == CEIV_LIVE_ANIMALS) {
				nextCertificationID = CEIV_AVI+parseYearSub+'-';
			}
			else if (getCertiToRead.Name == CEIV_PHARMA) {
				nextCertificationID = CEIV_PIL+parseYearSub+'-';
			}
			else if (getCertiToRead.Name == CEIV_FRESH) {
				nextCertificationID = CEIV_PER+parseYearSub+'-';
			}
			else if (getCertiToRead.Name == IENVA_STAGE_1 || getCertiToRead.Name == IENVA_STAGE_2 || getCertiToRead.Name == UNITED_FOR_WILDLIFE) {
				nextCertificationID = (getCertiToRead.Name == UNITED_FOR_WILDLIFE ? UFW_QTR_AC : IENVA_QTR_AC) +icaoDesignator+'-'+AUDITING_COMPANY+String.valueOf(Date.today().year());
				isIenvaORUfW=true;
			}
			else if (getCertiToRead.Name == SMART_FACILITY_OPERATIONAL_CAPACITY) {
				nextCertificationID = SFOC+parseYearSub+'-';
			}
			else if (getCertiToRead.Name == SMART_FACILITY_REMOTE_VALIDATION) {
				nextCertificationID = RV_SF+parseYearSub+'-';
			}

			if(!isIenvaORUfW){
				if(!getLastCertiID.isEmpty()){
					certiSelected = getLastCertiID[0].Certification_Id__c;
					positionToSub1 = certiSelected.length()-4;
					parseValue = Integer.valueOf(getLastCertiID[0].Certification_Id__c.substring(positionToSub1));
					String certiToCompare;
					Integer positionToCompare;
					Integer pivoteValue;
					for(ICG_Capability_Assignment_Group__c g : getLastCertiID){
						certiToCompare = g.Certification_Id__c;
						positionToCompare = certiToCompare.length()-4;
						pivoteValue = Integer.valueOf(certiToCompare.substring(positionToCompare));
						if(pivoteValue > parseValue){
							parseValue = pivoteValue;
						}
					}

					nextNumber1 = String.valueOf(parseValue+1);
					addCero = 4 - nextNumber1.length();
					if(addCero > 0){
						nextNumber1 = nextNumber1.leftPad(4,'0');
					}
				}
				else{
					nextNumber1 = initValue;
				}
				nextCertificationID += nextNumber1;
			}
			
			return nextCertificationID;
		}
		catch(Exception e){
			return JSON.serialize(e.getMessage()+e.getLineNumber()+e.getStackTraceString());
		}
	}

	/****************************************************************************
	 * @Method			: renewCertification
	 * @Created			: 17/01/2020
	 * @Description		: delete selected certification
	 * @param			: String facilityId - id of the facility
	 * @param			: String certificationId - id of the certification
	 * @Returns			: void
	 ****************************************************************************/
	@AuraEnabled
	public static String renewCertification(string certificationId, string issuedDate, string expirationDate, string newCertificationId, string scopeValue) {
		String result;
		try {
			ICG_Capability_Assignment_Group__c ardCertification = [SELECT id, Certification_Id__c, CEIV_Scope_List__c, SFOC_Scope__c,IENVA_Scope__c, ICG_Certification__c, ICG_Certification__r.Certification_Type__c, ICG_Certification__r.Name, ICG_Certification__r.Label__c, ICG_Account_Role_Detail__c,RecordTypeId FROM ICG_Capability_Assignment_Group__c WHERE id = :certificationId order by CreatedDate desc LIMIT 1];
			ICG_Capability_Assignment_Group__c ardCertificationToInsert = ardCertification.clone();
			ardCertificationToInsert.Issue_Date__c = Date.valueOf(issuedDate);
			ardCertificationToInsert.Expiration_Date__c = Date.valueOf(expirationDate);
			ardCertificationToInsert.Certification_ID__c = newCertificationId;
			ardCertificationToInsert.ICG_Account_Role_Detail__c = ardCertification.ICG_Account_Role_Detail__c;
			if(ardCertificationToInsert.ICG_Certification__r.Name == SMART_FACILITY_OPERATIONAL_CAPACITY){
				ardCertificationToInsert.SFOC_Scope__c = scopeValue;
			} else if (ardCertificationToInsert.ICG_Certification__r.Name.contains('CEIV')) {
				ardCertificationToInsert.CEIV_Scope_List__c = scopeValue;
			}
			else if(ardCertificationToInsert.ICG_Certification__r.Name.contains('ienva_stage_')){
				ardCertificationToInsert.IENVA_Scope__c = scopeValue;
			}
			insert ardCertificationToInsert;

			return ardCertificationToInsert.id;
		} catch (Exception e) {
			return e.getMessage();
		}
	}

	/**
	 * @description		method that creates a new ICG_Capability_Assignment_Group__c
	 * @param			jsonCertification <Json with the certification fields>
	 * @return			id <id of the new ICG_Capability_Assignment_Group__c created>
	 */
	@AuraEnabled
	public static ICG_Capability_Assignment_Group__c createCertification(string jsonCertification) {
		try {
			ICG_Capability_Assignment_Group__c newCert = (ICG_Capability_Assignment_Group__c) JSON.deserialize(jsonCertification, ICG_Capability_Assignment_Group__c.class);
			newCert.RecordTypeId = RT_CERTIFICATION;
			insert newCert;
			return newCert;
		} catch (Exception e) {
			return null;
		}
	}

	/**
	 * @description		method that update a existing ICG_Capability_Assignment_Group__c
	 * @param			jsonGroup <Json with the group fields>
	 * @return			boolean with the result
	 */
	@AuraEnabled
	public static Boolean updateFieldEdited(List<String> jsonGroup) {
		try {
			List<ICG_Capability_Assignment_Group__c> updateListGroup = new List<ICG_Capability_Assignment_Group__c>();
			//Extract all group field from input
			for (String field : jsonGroup) {
				ICG_Capability_Assignment_Group__c updateGroup = (ICG_Capability_Assignment_Group__c) JSON.deserialize(field, ICG_Capability_Assignment_Group__c.class);
				updateListGroup.add(updateGroup);
			}
			update updateListGroup;
			return true;
		} catch (Exception e) {
			return false;
		}
	}
}