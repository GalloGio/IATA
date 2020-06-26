public with sharing class CW_CertificationSection {
	@AuraEnabled(cacheable=true)
	public static List<ICG_Certification__c> getCertifications(String certificationType, String certificationName) {
		String query = 'SELECT Id, Description__c, Tech_Order__c, link__c,Name,Certification_Type__c,Expiration_Period__c,is_visible__C,Image__c FROM ICG_Certification__c WHERE is_visible__C = TRUE';
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
		List<ICG_Capability_Assignment_Group__c> certifications = [SELECT Id, ICG_Certification__r.Image__c, ICG_Certification__r.Name, ICG_Account_Role_Detail__r.Id, ICG_Account_Role_Detail__r.Name, ICG_Account_Role_Detail__r.City_FOR__c FROM ICG_Capability_Assignment_Group__c WHERE recordType.developerName = 'Certification' AND ICG_Certification__c != null ORDER BY Issue_Date__c DESC NULLS LAST LIMIT 20];
		Boolean containsSfoc = false;
		for (ICG_Capability_Assignment_Group__c crt : certifications) {
			if (crt.ICG_Certification__r.Name == 'Smart Facility Operational Capacity')
				containsSfoc = true;
		}
		if (!containsSfoc) {
			List<ICG_Capability_Assignment_Group__c> sfocCert = [SELECT Id, ICG_Certification__r.Image__c, ICG_Certification__r.Name, ICG_Account_Role_Detail__r.Id, ICG_Account_Role_Detail__r.Name, ICG_Account_Role_Detail__r.City_FOR__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Name = 'Smart Facility Operational Capacity' ORDER BY Issue_Date__c DESC NULLS LAST LIMIT 1];
			if (!sfocCert.isEmpty() && !certifications.isEmpty()) {
				certifications[certifications.size() - 1] = sfocCert[0];
			}
		}
		return certifications;
	}
}