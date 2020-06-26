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

	/****************************************************************************
	 * @Method			: getFacilityCertifications
	 * @Created			: 16/01/2020
	 * @Description		: get all certifications related to the facility
	 * @param			: String facilityId - id of the facility
	 * @Returns			: String relatedCertifications - json containing all the related certifications
	 ****************************************************************************/
	@AuraEnabled
	public static string getFacilityCertifications(string facilityId) {
		return (JSON.serialize([SELECT id, Certification_Id__c, Status__c, Issue_Date__c, Expiration_Date__c, ToLabel(CEIV_Scope_List__c), ToLabel(SFOC_Scope__c),ToLabel(IEnVA_Scope__c), ICG_Certification__r.Name, ICG_Certification__r.CreatedDate, ICG_Certification__r.Certification_Type__c,ICG_Certification__r.Expiration_Period__c,ICG_Account_Role_Detail__r.RecordType.DeveloperName  FROM ICG_Capability_Assignment_Group__c WHERE ICG_Account_Role_Detail__c = :facilityId AND Is_Deprecated__c = false AND RecordTypeId =: RT_CERTIFICATION ORDER BY CreatedDate ASC]));
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
	 * @Method			: getFacilityDeprecatedCertifications
	 * @Created			: 22/01/2020
	 * @Description		: get all certifications deprecated related to the facility
	 * @param			: String facilityId - id of the facility
	 * @param			: String certificationId - id of the certification
	 * @Returns			: String relatedCertifications - json containing all the defrecated certifications
	 ****************************************************************************/
	@AuraEnabled
	public static string getFacilityDeprecatedCertifications(string facilityId, string certificationId) {
		return (JSON.serialize([SELECT id, Certification_Id__c, Status__c, Issue_Date__c, Expiration_Date__c, ToLabel(CEIV_Scope_List__c), ToLabel(SFOC_Scope__c),ToLabel(IEnVA_Scope__c), ICG_Certification__r.Name, ICG_Certification__r.CreatedDate, ICG_Certification__r.Certification_Type__c,ICG_Certification__r.Expiration_Period__c,ICG_Account_Role_Detail__r.RecordType.DeveloperName  FROM ICG_Capability_Assignment_Group__c WHERE ICG_Account_Role_Detail__c = :facilityId AND ICG_Certification__c = :certificationId AND RecordTypeId =: RT_CERTIFICATION AND Is_Deprecated__c = true]));
	}

	/****************************************************************************
	 * @Method			: getAllCertifications
	 * @Created			: 16/01/2020
	 * @Description		: get all certifications in the system
	 * @Returns			: String relatedCertifications - json containing all certifications
	 ****************************************************************************/
	@AuraEnabled
	public static string getAllCertifications() {
		List<String> lstDepts = new List<String>();
		List<Group> lstGroup = [SELECT Name FROM Group WHERE Id IN (SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId())];
		for (Group g : lstGroup) {
			lstDepts.add(g.Name);
		}
		return (JSON.serialize([SELECT id,Name,Certification_Type__c, Applicable_to__c,Expiration_Period__c FROM ICG_Certification__c WHERE Department__c IN: lstDepts]));
		
	}

	/****************************************************************************
	 * @Method			: getScopeByCertificationAndStation
	 * @Created			: 25/06/2020
	 * @Description		: get scope filtered by certification and station
	 * @Returns			: Map<String, Map<String,String>> filteredScopesByCertiAndStation - json containing all scopes filtered
	 ****************************************************************************/
	@AuraEnabled(cacheable=true)
	public static string getScopeByCertificationAndStation() {
		List<String> stationType = new List<String>{'Airline','Airport','Freight_Forwarder','Trucker','Shipper'};

		Map<String, List<Map<String,String>>> scopesFiltered = new Map<String, List<Map<String,String>>>();
		List<Map<String,String>> scopeList = new List<Map<String,String>>();
		Map<String,String> ceivScopes = new Map<String,String>();

		ceivScopes.put('label','Administrative');
		ceivScopes.put('value','Administrative');
		scopeList.add(ceivScopes);

		ceivScopes = new Map<String,String>();
		ceivScopes.put('label','Operational');
		ceivScopes.put('value','Operational');
		scopeList.add(ceivScopes);

		for(String station : stationType){			
			scopesFiltered.put(station,scopeList);
		}

		scopeList = new List<Map<String,String>>();
		ceivScopes = new Map<String,String>();
		ceivScopes.put('label','Cargo Facility Operations');
		ceivScopes.put('value','Cargo_Facility_Operations');
		scopeList.add(ceivScopes);
		scopesFiltered.put('Cargo_Handling_Facility',scopeList);

		scopeList = new List<Map<String,String>>();
		ceivScopes = new Map<String,String>();
		ceivScopes.put('label','Ramp Operations');
		ceivScopes.put('value','Ramp_Operations');
		scopeList.add(ceivScopes);
		scopesFiltered.put('Ramp_Handler',scopeList);

		return JSON.serialize(scopesFiltered);		
	}

	/****************************************************************************
	 * @Method			: getNextCertificationID
	 * @Created			: 26/06/2020
	 * @Description		: get the next certification Id value
	 * @Returns			: Map<String, Map<String,String>> filteredScopesByCertiAndStation - json containing all scopes filtered
	 ****************************************************************************/
	@AuraEnabled(cacheable=true)
	public static string getNextCertificationID() {
		List<String> nextNumberList = new List<String>();
		List<Map<String,String>> nextCertificationsID = new List<Map<String,String>>();
		Map<String,String> nextCerti = new Map<String,String>();
		String parseYearSub = String.valueOf(Date.today().year()).substring(2);
		String parseYearAll = String.valueOf(Date.today().year());
		String initValue = '0001';

		try{
			List<ICG_Capability_Assignment_Group__c[]> listLastCerti = new List<ICG_Capability_Assignment_Group__c[]>();
			ICG_Capability_Assignment_Group__c[] getLastCertiID1L = [SELECT Certification_Id__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Name = 'CEIV Live Animals' AND Certification_Id__c LIKE 'CEIV-%' order by Certification_Id__c desc limit 1 ];
			ICG_Capability_Assignment_Group__c[] getLastCertiID2L = [SELECT Certification_Id__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Name = 'CEIV Pharma' AND Certification_Id__c LIKE 'CEIV-%' order by Certification_Id__c desc limit 1 ];
			ICG_Capability_Assignment_Group__c[] getLastCertiID3L = [SELECT Certification_Id__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Name = 'CEIV Fresh' AND Certification_Id__c LIKE 'CEIV-%' order by Certification_Id__c desc limit 1 ];
			ICG_Capability_Assignment_Group__c[] getLastCertiID7L = [SELECT Certification_Id__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Name = 'Smart Facility Operational Capacity' AND Certification_Id__c LIKE 'SFOC-%' order by Certification_Id__c desc limit 1 ];
			ICG_Capability_Assignment_Group__c[] getLastCertiID8L = [SELECT Certification_Id__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Name = 'Smart Facility Remote Validation' AND Certification_Id__c LIKE 'RV-SF-%' order by Certification_Id__c desc limit 1 ];

			listLastCerti.add(getLastCertiID1L);
			listLastCerti.add(getLastCertiID2L);
			listLastCerti.add(getLastCertiID3L);
			listLastCerti.add(getLastCertiID7L);
			listLastCerti.add(getLastCertiID8L);

			String parseCertiID1;
			Integer positionToSub1;
			String nextNumber1;
			Integer addCero=0;
			for(ICG_Capability_Assignment_Group__c[] row : listLastCerti){
				 parseCertiID1='';
			 	 positionToSub1=0;
				 nextNumber1='';
				if(row.size()>0){
					parseCertiID1 = row[0].Certification_Id__c;
					positionToSub1 = parseCertiID1.length()-4;
					nextNumber1 = String.valueOf(Integer.valueOf(row[0].Certification_Id__c.substring(positionToSub1))+1);
					addCero = 4 - nextNumber1.length();
					if(addCero > 0){
						nextNumber1 = nextNumber1.leftPad(4,'0');
					}
			   }
			   else{
				   nextNumber1 = initValue;
			   }
			   nextNumberList.add(nextNumber1);
			}
			
			nextCerti.put('CEIV Live Animals','CEIV-AVI-'+parseYearSub+'-'+nextNumberList.get(0));
			nextCerti.put('CEIV Pharma','CEIV-PIL-'+parseYearSub+'-'+nextNumberList.get(1));
			nextCerti.put('CEIV Fresh','CEIV-PER-'+parseYearSub+'-'+nextNumberList.get(2));

			nextCerti.put('IEnVA Stage 1','IEnVA-QTR-AC-'+parseYearAll);
			nextCerti.put('IEnVA Stage 2','IEnVA-QTR-AC-'+parseYearAll);
			nextCerti.put('United for Wildlife','UfW-QTR-AC-'+parseYearAll);

			nextCerti.put('Smart Facility Operational Capacity','SFOC-'+parseYearSub+'-'+nextNumberList.get(3));
			nextCerti.put('Smart Facility Remote Validation','RV-SF-'+parseYearSub+'-'+nextNumberList.get(4));

			nextCertificationsID.add(nextCerti);
			return JSON.serialize(nextCertificationsID);
		}
		catch(Exception e){
			return JSON.serialize(e.getMessage());
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
	public static Boolean renewCertification(string certificationId, string issuedDate, string expirationDate, string newCertificationId, string scopeValue) {
		try {
			ICG_Capability_Assignment_Group__c ardCertification = [SELECT id, Certification_Id__c, CEIV_Scope_List__c, SFOC_Scope__c,IEnVA_Scope__c, ICG_Certification__c, ICG_Certification__r.Certification_Type__c, ICG_Certification__r.Name, ICG_Account_Role_Detail__c FROM ICG_Capability_Assignment_Group__c WHERE id = :certificationId LIMIT 1];
			ICG_Capability_Assignment_Group__c ardCertificationToInsert = ardCertification.clone();
			ardCertificationToInsert.Issue_Date__c = Date.valueOf(issuedDate);
			ardCertificationToInsert.Expiration_Date__c = Date.valueOf(expirationDate);
            ardCertificationToInsert.Certification_ID__c = newCertificationId;
            ardCertificationToInsert.ICG_Account_Role_Detail__c = ardCertification.ICG_Account_Role_Detail__c;
			if(ardCertificationToInsert.ICG_Certification__r.Name == 'Smart Facility Operational Capacity'){
				ardCertificationToInsert.SFOC_Scope__c = scopeValue;
			} else if (ardCertificationToInsert.ICG_Certification__r.Name.contains('CEIV')) {
				ardCertificationToInsert.CEIV_Scope_List__c = scopeValue;
			}
			else if(ardCertificationToInsert.ICG_Certification__r.Name.contains('IEnvA')){
				ardCertificationToInsert.IEnVA_Scope__c = scopeValue;
			}
			insert ardCertificationToInsert;

			return true;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * @description		method that creates a new ICG_Capability_Assignment_Group__c
	 * @param			jsonCertification <Json with the certification fields>
	 * @return			id <id of the new ICG_Capability_Assignment_Group__c created>
	 */
	@AuraEnabled
	public static string createCertification(string jsonCertification) {
		try {
			ICG_Capability_Assignment_Group__c newCert = (ICG_Capability_Assignment_Group__c) JSON.deserialize(jsonCertification, ICG_Capability_Assignment_Group__c.class);
			insert newCert;
			return newCert.id;
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
	public static Boolean updateFieldEdited(string jsonGroup) {
		try {
			ICG_Capability_Assignment_Group__c updateGroup = (ICG_Capability_Assignment_Group__c) JSON.deserialize(jsonGroup, ICG_Capability_Assignment_Group__c.class);
			update updateGroup;
			return true;
		} catch (Exception e) {
			return false;
		}
	}
}