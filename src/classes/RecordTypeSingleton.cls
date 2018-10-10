public class RecordTypeSingleton {

    private static RecordTypeSingleton instance = null;
	public Map<String,Map<String,Id>> RtIDsPerDeveloperNamePerObj {get;private set;}

	private RecordTypeSingleton(){
		RtIDsPerDeveloperNamePerObj = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string>{'Account','Contact','Case','Opportunity','Contract','ID_Card_Application__c','EmailTemplate__c','AMS_Country_Specific_Attribute__c', 'AMS_OSCAR__c', 'Agency_Applied_Change_code__c','ANG_Agency_Risk_Calculation__c', 'ANG_RHC_Information__c', 'ANG_Risk_Alert__c', 'Partner_products__c', 'TIP_BIN_Range__c', 'AP_Process_Form__c', 'AMS_Accreditation_Requirement__c','AMS_Settlement_System__c', 'Account_Role__c', 'Account_Contact_Role__c'});
	}
	    
	public static RecordTypeSingleton getInstance(){
		if(instance == null) instance = new RecordTypeSingleton();
	    return instance;
	}
}
