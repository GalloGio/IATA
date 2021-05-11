public with sharing class CW_AccountDetailCertificationList {
	/**
	 * @description		Get a list of certifications related to this Account
	 * @param			accountId Account Role Detail Id to filter
	 * @param			accountType Account Role Detail Record Type Ids to filter
	 * @return			Map<Boolean, List<wrapperCert>>
	 */
	@AuraEnabled(cacheable=true)
	public static Map<Boolean, List<wrapperCert>> getCertificationList(String accountId, String accountType) {
		List<String> listValidationPrograms = new List<String>();
		if(String.isNotBlank(CW_Utilities.VALIDATION_PROGRAMS)){
			listValidationPrograms = CW_Utilities.VALIDATION_PROGRAMS.split(',');
		}

		Set<String> certificationsNameList = new Set<String>();
		Map<String, ICG_Capability_Assignment_Group__c> accRolDetCerMap = new Map<String, ICG_Capability_Assignment_Group__c>();

		List<ICG_Capability_Assignment_Group__c> asgmtGroup = [SELECT Id, Name, ICG_Certification__r.Name, ICG_Certification__r.Id,
															ICG_Certification__r.Image__c, Expiration_Date__c, Issue_Date__c, Certification_Id__c,
															TOLABEL(CEIV_Scope_List__c), TOLABEL(SFOC_Scope__c) 
																FROM ICG_Capability_Assignment_Group__c 
																WHERE ICG_Account_Role_Detail__r.Id = :accountId
																AND Is_Active__c = true
																AND Is_Expired__c = false
																AND ICG_Certification__r.ValidationPrograms__c IN : listValidationPrograms
																];

		for (ICG_Capability_Assignment_Group__c accRoleCert : asgmtGroup) {
			accRolDetCerMap.put(accRoleCert.ICG_Certification__r.Name, accRoleCert);
		}
		List<ICG_Certification__c> allCertifictations = [SELECT Id, Name, Label__c, Expiration_Period__c, Image__c, Order__c 
										FROM ICG_Certification__c WHERE is_visible__C = true 
												AND Applicable_to__c INCLUDES (:accountType) AND ValidationPrograms__c IN : listValidationPrograms ORDER BY Order__c];

		Map<Boolean, List<wrapperCert>> returnMap = new Map<Boolean, List<wrapperCert>>();
		for (ICG_Certification__c cert : allCertifictations) {
			boolean exists = cert.Name != null && accRolDetCerMap.containsKey(cert.Name);
			Date expDate;
			Date issDate;
			String certId;
			if (exists) {
				expDate = accRolDetCerMap.get(cert.Name).Expiration_Date__c;
				issDate = accRolDetCerMap.get(cert.Name).Issue_Date__c;
				certId = accRolDetCerMap.get(cert.Name).Certification_Id__c;
			}
			if (returnMap.get(exists) == null) {
				returnMap.put(exists, new List<wrapperCert>());
			}
			returnMap.get(exists).add(new wrapperCert(expDate, issDate, certId, cert.Image__c, cert.Id, cert.Name, cert.Label__c, cert.Order__c));
		}
		return returnMap;
	}

	public class wrapperCert {
		@AuraEnabled
		public Date expirationDate { get; set; }
		@AuraEnabled
		public Date issueDate { get; set; }
		@AuraEnabled
		public String certificationId { get; set; }
		@AuraEnabled
		public String image { get; set; }
		@AuraEnabled
		public String id { get; set; }
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public Decimal order { get; set; }

		public wrapperCert(Date expirationDate, Date issueDate, String certificationId, String image, String id, String name, String label, Decimal order) {
			this.expirationDate = expirationDate;
			this.issueDate = issueDate;
			this.certificationId = certificationId;
			this.image = image;
			this.id = id;
			this.name = name;
			this.label = label;
			this.order = order;
		}
	}
}