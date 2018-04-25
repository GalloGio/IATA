public class FormulaField_Helper {
	//public static Boolean isKPICreationRunning = false;
	public static boolean isRunningFromCAse = false;
	public static boolean isRunningFromHelper = false; 
	
	public static void CreateHelperRecord (list<case> lsCase){
		map<id,id> mapRecordCreated = new map<id,id>();
		list<Case_formula_helper__c> lsObjToCreate = new list<Case_formula_helper__c>();
		
		for(case c:lsCase){
			if(string.isBlank(c.Case_formula_helper__c))
				lsObjToCreate.add(New Case_formula_helper__c(case__c = c.Id, UniqueId__c = c.Id));
		}
		
		if(!lsObjToCreate.isEmpty()){
			Database.UpsertResult [] cr = Database.upsert(lsObjToCreate, Case_formula_helper__c.Fields.UniqueId__c, false);
			
			for(Case_formula_helper__c rec:lsObjToCreate)
				mapRecordCreated.put(rec.Case__c, rec.Id);
				
			for(case c:lsCase){
				if(string.isBlank(c.Case_formula_helper__c))
					c.Case_formula_helper__c = mapRecordCreated.get(c.Id);
			}
		}
	}
	
	
	public static void UpdateCaseLookup(list<Case_formula_helper__c> lsHelper){
		map<id,id> MapCaseHelper = new map<id,id>();
		for(Case_formula_helper__c h:lsHelper)
			if(!string.isBlank(h.case__c) && !string.isBlank(h.id))
				mapCaseHelper.put(h.case__c, h.Id);
		
		list<case> lsCasesToUpd = new list<case>();
		for(case c:[select id, Case_formula_helper__c from case where id in:mapCaseHelper.keyset()]){
			if(string.isEmpty(c.Case_formula_helper__c)){
				c.Case_formula_helper__c = mapCaseHelper.get(c.Id);
				lsCasesToUpd.add(c);
			}
		}
		
		if(!lsCasesToUpd.isEmpty()) update lsCasesToUpd;
	}
	
	
	public static void FillHelperFieldsFromKPI(list<Case_formula_helper__c> lsHelper){
		
		list<Formula_Field_Helper_Config__mdt> lsConfig = [select id, Helper_Type__c, Field_to_check__c, Values_to_check__c, result__c from Formula_Field_Helper_Config__mdt where ObjectName__c='Case'];
		set<id> setCaseId = new set<id>();
		for(Case_formula_helper__c h:lsHelper)
			if(!string.isBlank(h.case__c))
				setCaseId.add(h.case__c);
		
		map<id, case> mapCases = new map<id, case>([select id, recordtypeId, Reason1__c, Case_formula_helper__c from case where id in:setCaseId]);
		
		for(Case_formula_helper__c theHelp:lsHelper){
			if(mapCases.containsKey(theHelp.case__c))
				theHelp = FillHelperFields(lsConfig, mapCases.get(theHelp.case__c), theHelp);
		}
	}
	
	
	public static void FillHelperFieldsFromCase(list<case> lsCase){
		list<Formula_Field_Helper_Config__mdt> lsConfig = [select id, Helper_Type__c, Field_to_check__c, Values_to_check__c, result__c from Formula_Field_Helper_Config__mdt where ObjectName__c='Case'];
		list<Case_formula_helper__c> lsObjToCreate = new list<Case_formula_helper__c>();
		
		for(case c:lsCase){
			lsObjToCreate.add(FillHelperFields(lsConfig, c, new Case_formula_helper__c()));
		}
		if(!lsObjToCreate.isEmpty())
			Database.UpsertResult [] cr = Database.upsert(lsObjToCreate, Case_formula_helper__c.Fields.UniqueId__c, false);
	}
	
	
	private static Case_formula_helper__c FillHelperFields(list<Formula_Field_Helper_Config__mdt> lsConfig, case c, Case_formula_helper__c theHelp){
		theHelp.UniqueId__c = c.Id;
		theHelp.case__c = c.Id;
		
		//Reset to default values
		theHelp.AccProcessType_Reason1_Helper__c = '';
		theHelp.KPI1_Reason1_Helper__c	= 0;
		theHelp.KPI1_RecordType_Helper__c	= 0;
		theHelp.KPI2_Reason1_Helper__c	= 0;
		theHelp.KPI2_RecordType_Helper__c	= 0;
		theHelp.ProcessAge_Reason1_Helper__c	= 0;
		
		//compute if necessary to update values
		for(Formula_Field_Helper_Config__mdt conf:lsConfig){
			
			if(string.isNotBlank(c.Reason1__c)){
				if(conf.Helper_Type__c=='KPI1_Reason1' && conf.Values_to_check__c.toUpperCase().split(';').contains(c.Reason1__c.toUpperCase()))
					theHelp.KPI1_Reason1_Helper__c = integer.valueOf(conf.result__c);
				
				if(conf.Helper_Type__c=='ProcessAge_Reason1' && conf.Values_to_check__c.toUpperCase().split(';').contains(c.Reason1__c.toUpperCase()))
				theHelp.ProcessAge_Reason1_Helper__c = integer.valueOf(conf.result__c);
			
				if(conf.Helper_Type__c=='AccProcType_Reason1' && conf.Values_to_check__c.toUpperCase().split(';').contains(c.Reason1__c.toUpperCase()))
					theHelp.AccProcessType_Reason1_Helper__c = conf.result__c;
				
				if(conf.Helper_Type__c=='KPI2_Reason1' && conf.Values_to_check__c.toUpperCase().split(';').contains(c.Reason1__c.toUpperCase()))
				theHelp.KPI2_Reason1_Helper__c = integer.valueOf(conf.result__c);
			}
			
			if(string.isNotBlank(c.RecordTypeId)){
				if(conf.Helper_Type__c=='KPI1_RecordType' && conf.Values_to_check__c.toUpperCase().split(';').contains(RTName('Case',c.RecordTypeId).toUpperCase()))
					theHelp.KPI1_RecordType_Helper__c = integer.valueOf(conf.result__c);
				
				if(conf.Helper_Type__c=='KPI2_RecordType' && conf.Values_to_check__c.toUpperCase().split(';').contains(RTName('Case',c.RecordTypeId).toUpperCase()))
					theHelp.KPI2_RecordType_Helper__c = integer.valueOf(conf.result__c);
			}
		}
		
		return theHelp;
	}
	
	private static string RTName(string theObject, id RTId){
    	if(RTId==null)	return null;
    	return Schema.getGlobalDescribe().get(theObject).getDescribe().getRecordTypeInfosById().get(RTId).getName();
    }
}