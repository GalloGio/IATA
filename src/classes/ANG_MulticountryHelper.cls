public class ANG_MulticountryHelper {
	
	/**
	* Verifies if the immediate parent 
	* associated with the acctId 
	* has the given change code
	* 
	* @param acctId: Id 
	* @param changeCode: String
	* @return Boolean
	*
	*/
	public static Boolean parentHasChangeCode(Id acctId, String changeCode){
		
		integer nbrOfChangeCodes =
			[SELECT
				count()
			 FROM
				Agency_Applied_Change_Code__c
			 WHERE								
			 	 Change_Code__c = :changeCode 	
			 AND Account__c IN 					
			 	(SELECT ParentId				
			 	 FROM Account 					
			 	 WHERE Id = :acctId)
			];

		return nbrOfChangeCodes > 0;
	
	}

	/**
	* Verifies if the IATA Code generation should be allowed
	* 
	* @param oscar: AMS_OSCAR__c
	* @return Boolean
	*
	*/
	public static Boolean allowIATACodeGeneration(AMS_OSCAR__c oscar){
		return 
			(parentHasChangeCode(oscar.Account__c, 'NEW') && 
			 (AMS_Utils.ACTIVEAGENCYSTATUS.contains(oscar.Account__r.Parent.Status__c) || 
			  oscar.Account__r.Parent.Status__c == AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING)
			);
	}

	/**
	* Verifies if the OSCAR approval step should be allowed
	* 
	* @param oscar: AMS_OSCAR__c
	* @return Boolean
	*
	*/
	public static Boolean allowApprovalStep(AMS_OSCAR__c oscar){
		return parentHasChangeCode(oscar.Account__c, 'FIN');
	}


	/**
	* Gets the Remittance frequency from the current AMS Online Accreditation
	*
	* @param accreditationID: ID
	* @return String
	*
	*/
	public static String getPaxRemittanceFrequencyByID(Id accreditationID){
		
		List<AMS_Pax_Accreditation_Form__c> onlineAccred = [SELECT Remittance_frequency__c 
															FROM AMS_Pax_Accreditation_Form__c
															WHERE id = :accreditationID];

		if(!onlineAccred.isEmpty()) return onlineAccred[0].Remittance_frequency__c;

		return '';
	}


	/**
	 * Verifies if an MC HE account has an empty Remittance_frequency__c
	 * NEWGEN-4850
	 * 
	 * @param oscar: AMS_OSCAR__c
	 * @return Boolean
	 */
	public static Boolean accountHEhasRemittenceFrequencyEmpty(AMS_OSCAR__c oscar){
		return ((String.isEmpty(getPaxRemittanceFrequencyByID(oscar.AMS_Online_Accreditation__c)))
			&& oscar.Location_Type__c == AMS_Utils.HE
			&& oscar.Process__c == AMS_Utils.MCAE);
	}

}