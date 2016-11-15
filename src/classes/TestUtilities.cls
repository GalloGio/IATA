public class TestUtilities {
	
	
    
    public static void setupSkill(id anId, String aName){
    	Skill__c aSkill = new Skill__c(Name=aName,Skill_Types__c=anId);
    	insert aSkill;
    }
    

    public static void setupSkillType(String aName,String aCaseField){
    	Skill_Types__c aSkillType = new Skill_Types__c(Skill_Weight__c=1,Name=aName,Case_Location__c=aCaseField);
    	insert aSkillType;
    }
    
    
    
    public static void setupDefaultSystemSettings() {
    	if ([select count() from System_Settings__c where Active__c = true] == 0) {
	    	System_Settings__c settings = new System_Settings__c(
	    		Name = 'Test Settings',
	    		Skill_P3_Weighting__c = 1.4,
				Skill_P2_Weighting__c = 1.2,
				Skill_P1_Weighting__c = 1.0, 
				Open_Case_Workload_Weighting__c = 1.0,
				In_Progress_Case_Workload_Weighting__c = 0.5,
				Active__c = true
	    	);
	    	insert settings;
    	}
    }
   
}