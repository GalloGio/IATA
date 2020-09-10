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

	final static String CEIV_LIVE_ANIMALS = 'CEIV Live Animals';
	final static String CEIV_PHARMA = 'CEIV Pharma';
	final static String CEIV_FRESH = 'CEIV Fresh';
	final static String IENVA_STAGE_1 = 'IEnvA';
	final static String IENVA_STAGE_2 = 'IEnvA Stage 2';
	final static String UNITED_FOR_WILDLIFE = 'United for Wildlife';
	final static String SMART_FACILITY_OPERATIONAL_CAPACITY = 'Smart Facility Operational Capacity';
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
	public static string getFacilityCertifications(string facilityId) {
		List<String> lstDepts = CW_CapabilitiesUtilities.getCertificationsAllowedByDepartments();
		List<ICG_Capability_Assignment_Group__c> returnList = new List<ICG_Capability_Assignment_Group__c>();

		List<ICG_Capability_Assignment_Group__c> activeList = [SELECT id, Certification_Id__c,Is_Booked__c, Status__c, Issue_Date__c, Expiration_Date__c, ToLabel(CEIV_Scope_List__c), ToLabel(SFOC_Scope__c),ToLabel(IENVA_Scope__c), ICG_Certification__r.Name, ICG_Certification__r.CreatedDate, ICG_Certification__r.Certification_Type__c,ICG_Certification__r.Expiration_Period__c,ICG_Account_Role_Detail__r.RecordType.DeveloperName
		  FROM ICG_Capability_Assignment_Group__c WHERE ICG_Account_Role_Detail__c = :facilityId AND
		   Is_Active__c = true AND RecordTypeId =: RT_CERTIFICATION AND ICG_Certification__r.Name IN: lstDepts ORDER BY CreatedDate DESC];
		returnList.addAll(activeList);

		List<ICG_Capability_Assignment_Group__c> upcomingList = [SELECT id, Certification_Id__c,Is_Booked__c, Status__c, Issue_Date__c, Expiration_Date__c, ToLabel(CEIV_Scope_List__c), ToLabel(SFOC_Scope__c),ToLabel(IENVA_Scope__c), ICG_Certification__r.Name, ICG_Certification__r.CreatedDate, ICG_Certification__r.Certification_Type__c,ICG_Certification__r.Expiration_Period__c,ICG_Account_Role_Detail__r.RecordType.DeveloperName
		   FROM ICG_Capability_Assignment_Group__c WHERE ICG_Account_Role_Detail__c = :facilityId AND
			Status__c = 'Upcoming' AND RecordTypeId =: RT_CERTIFICATION AND ICG_Certification__r.Name IN: lstDepts ORDER BY CreatedDate DESC];

		Boolean exist=false;
		for(ICG_Capability_Assignment_Group__c upcoming : upcomingList){
			for(ICG_Capability_Assignment_Group__c active : activeList){
				if(upcoming.ICG_Certification__c == active.ICG_Certification__c){
					exist=true;
				}
			}
			if(!exist){
				returnList.add(upcoming);
			}
			else{
				exist=false;
			}
		}

		List<ICG_Capability_Assignment_Group__c> expiredInactiveList = [SELECT id, Certification_Id__c,Is_Booked__c, Status__c, Issue_Date__c, Expiration_Date__c, ToLabel(CEIV_Scope_List__c), ToLabel(SFOC_Scope__c),ToLabel(IENVA_Scope__c), ICG_Certification__r.Name, ICG_Certification__r.CreatedDate, ICG_Certification__r.Certification_Type__c,ICG_Certification__r.Expiration_Period__c,ICG_Account_Role_Detail__r.RecordType.DeveloperName
		   FROM ICG_Capability_Assignment_Group__c WHERE ICG_Account_Role_Detail__c = :facilityId AND
			Status__c NOT IN ('Active','Upcoming') AND RecordTypeId =: RT_CERTIFICATION AND ICG_Certification__r.Name IN: lstDepts ORDER BY CreatedDate DESC];

		exist=false;
		for(ICG_Capability_Assignment_Group__c expiredInactive : expiredInactiveList){
			for(ICG_Capability_Assignment_Group__c active : returnList){
				if(expiredInactive.ICG_Certification__c == active.ICG_Certification__c){
					exist=true;
				}
			}
			if(!exist){
				returnList.add(expiredInactive);
			}
			else{
				exist=false;
			}
		}

		return (JSON.serialize(returnList));
	}

	/****************************************************************************
	 * @Method			: refreshFacilityCertifications
	 * @Created			: 16/01/2020
	 * @Description		: get all certifications related to the facility
	 * @param			: String facilityId - id of the facility
	 * @Returns			: String relatedCertifications - json containing all the related certifications
	 ****************************************************************************/
	@AuraEnabled
	public static string refreshFacilityCertifications(string facilityId) {
		return getFacilityCertifications(facilityId);
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
	public static string getFacilityNotActiveCertifications(string facilityId, string certificationId, String groupId, String statusInput) {
		List<String> lstDepts = CW_CapabilitiesUtilities.getCertificationsAllowedByDepartments();
        
        String query = 'SELECT Id, Certification_Id__c, Status__c, Issue_Date__c, Expiration_Date__c, ToLabel(CEIV_Scope_List__c), ToLabel(SFOC_Scope__c),ToLabel(IENVA_Scope__c), ICG_Certification__r.Name, ICG_Certification__r.CreatedDate, ICG_Certification__r.Certification_Type__c,ICG_Certification__r.Expiration_Period__c,ICG_Account_Role_Detail__r.RecordType.DeveloperName '+
             'FROM ICG_Capability_Assignment_Group__c WHERE ICG_Account_Role_Detail__c =\''+ facilityId +'\' AND ICG_Certification__c =\''+ certificationId +'\' AND RecordTypeId =\''+ RT_CERTIFICATION +'\' AND Is_Active__c = false AND ICG_Certification__r.Name IN (\'' + String.join((lstDepts), '\', \'') + '\')' + ' AND Status__c IN ('+statusInput+') AND Id !=\''+ groupId +'\' Order by CreatedDate desc';
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
	public static string getAllCertifications() {
		List<String> lstDepts = CW_CapabilitiesUtilities.getCertificationsAllowedByDepartments();
		return (JSON.serialize([SELECT id,Name,Certification_Type__c, Applicable_to__c,Expiration_Period__c FROM ICG_Certification__c WHERE Name IN: lstDepts]));
		
	}
	
	/****************************************************************************
	 * @Method			: getCertificationWithoutCapabilities
	 * @Created			: 14/07/2020
	 * @Description		: get certification that not contains capabilities
	 * @Returns			: List<tring>> certificationList - contains all certification without capabilities
	 ****************************************************************************/
	@AuraEnabled
	public static List<ICG_Certification__c> getCertificationWithoutCapabilities() {
		List<ICG_Certification__c> certificationList = [SELECT Name from ICG_Certification__c where Id not in (select ICG_Certification__c from ICG_Certification_Capability_Assignment__c)];

		return certificationList;
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
		String nextCertificationID;
		String parseYearSub = String.valueOf(Date.today().year()).substring(2);
		String parseYearAll = String.valueOf(Date.today().year());
		String initValue = '0001';

		try{
			ICG_Account_Role_Detail__c accRolDet = [SELECT Account_Role__r.Account__r.ICAO_designator__c FROM ICG_Account_Role_Detail__c WHERE Id =:recordId];
			ICG_Certification__c getCertiToRead = [SELECT Name FROM ICG_Certification__c WHERE Id =:certiSelected];
			ICG_Capability_Assignment_Group__c[] getLastCertiID = [SELECT Certification_Id__c,Name FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Id =:certiSelected AND Certification_Id__c != null order by CreatedDate desc limit 1 ];

			String parseCertiID1;
			Integer positionToSub1;
			String nextNumber1;
			Integer addCero=0;
			String icaoDesignator='';
			Boolean isIenvaORUfW=false;

			if(String.isNotBlank(accRolDet.Account_Role__r.Account__r.ICAO_designator__c)){
				icaoDesignator = accRolDet.Account_Role__r.Account__r.ICAO_designator__c;
			}

			switch on getCertiToRead.Name {
				when 'CEIV Live Animals' {
					nextCertificationID = CEIV_AVI+parseYearSub+'-';
				}
				when 'CEIV Pharma' {
					nextCertificationID = CEIV_PIL+parseYearSub+'-';
				}
				when 'CEIV Fresh' {
					nextCertificationID = CEIV_PER+parseYearSub+'-';
				}
				when 'IEnvA' {
					nextCertificationID = IENVA_QTR_AC+icaoDesignator+'-'+AUDITING_COMPANY+String.valueOf(Date.today().year());
					isIenvaORUfW=true;
				}
				when 'IEnvA Stage 2' {
					nextCertificationID = IENVA_QTR_AC+icaoDesignator+'-'+AUDITING_COMPANY+String.valueOf(Date.today().year());
					isIenvaORUfW=true;
				}
				when 'United for Wildlife' {
					nextCertificationID = UFW_QTR_AC+icaoDesignator+'-'+AUDITING_COMPANY+String.valueOf(Date.today().year());
					isIenvaORUfW=true;
				}
				when 'Smart Facility Operational Capacity' {
					nextCertificationID = SFOC+parseYearSub+'-';
				}
				when 'Smart Facility Remote Validation' {
					nextCertificationID = RV_SF+parseYearSub+'-';
				}
			}
			if(!isIenvaORUfW){
				if(getLastCertiID.size()>0){
					parseCertiID1 = getLastCertiID[0].Certification_Id__c;
					positionToSub1 = parseCertiID1.length()-4;
					nextNumber1 = String.valueOf(Integer.valueOf(getLastCertiID[0].Certification_Id__c.substring(positionToSub1))+1);
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
			ICG_Capability_Assignment_Group__c ardCertification = [SELECT id, Certification_Id__c, CEIV_Scope_List__c, SFOC_Scope__c,IENVA_Scope__c, ICG_Certification__c, ICG_Certification__r.Certification_Type__c, ICG_Certification__r.Name, ICG_Account_Role_Detail__c,RecordTypeId FROM ICG_Capability_Assignment_Group__c WHERE id = :certificationId order by CreatedDate desc LIMIT 1];
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
			else if(ardCertificationToInsert.ICG_Certification__r.Name.contains('IEnvA')){
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