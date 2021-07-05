public with sharing class CW_CertificationSection {
	@AuraEnabled(cacheable=true)
	public static List<ICG_Certification__c> getCertifications(String certificationType, String certificationName) {
		List<String> listValidationPrograms = CW_Utilities.VALIDATION_PROGRAMS.split(',');
		String query = 'SELECT Id, Description__c, Tech_Order__c, link__c,Name,Label__c,Certification_Type__c,Expiration_Period__c,Image__c FROM ICG_Certification__c WHERE is_visible__c = TRUE AND ValidationPrograms__c IN (\'' + String.join((listValidationPrograms), '\', \'') + '\')';
		if (String.isNotBlank(certificationType)) {
			query += ' AND Certification_Type__c = \'' + certificationType + '\'';
		}
		if (String.isNotBlank(certificationName)) {
			query += ' AND Name = \'' + certificationName + '\'';
		}
		query += ' order by Order__c';
		return Database.query(query);
	}

	@AuraEnabled(cacheable=true)
	public static List<ICG_Capability_Assignment_Group__c> getLatestAccountCertifications() {
		//At least one SFOC
		List<ICG_Capability_Assignment_Group__c> certifications = [SELECT Id, ICG_Certification__r.Image__c, ICG_Certification__r.Name, ICG_Certification__r.Label__c, ICG_Account_Role_Detail__r.Id, ICG_Account_Role_Detail__r.Name, ICG_Account_Role_Detail__r.City_FOR__c FROM ICG_Capability_Assignment_Group__c WHERE recordType.developerName = 'Certification' AND ICG_Certification__c != null and ICG_Account_Role_Detail__r.isApproved__c = true ORDER BY Issue_Date__c DESC NULLS LAST LIMIT 20];
		Boolean containsSfoc = false;
		for (ICG_Capability_Assignment_Group__c crt : certifications) {
			if (crt.ICG_Certification__r.Name == 'smart_facility_operational_capacity')
				containsSfoc = true;
		}
		if (!containsSfoc) {
			List<ICG_Capability_Assignment_Group__c> sfocCert = [SELECT Id, ICG_Certification__r.Image__c, ICG_Certification__r.Name, ICG_Certification__r.Label__c, ICG_Account_Role_Detail__r.Id, ICG_Account_Role_Detail__r.Name, ICG_Account_Role_Detail__r.City_FOR__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Name = 'smart_facility_operational_capacity' and ICG_Account_Role_Detail__r.isApproved__c = true ORDER BY Issue_Date__c DESC NULLS LAST LIMIT 1];
			if (!sfocCert.isEmpty() && !certifications.isEmpty()) {
				certifications[certifications.size() - 1] = sfocCert[0];
			}
		}
		return certifications;
	}
}