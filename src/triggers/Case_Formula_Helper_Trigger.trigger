trigger Case_Formula_Helper_Trigger on Case_formula_helper__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
    	if(!FormulaField_Helper.isRunningFromCAse){
        	FormulaField_Helper.isRunningFromHelper = true;
	    	FormulaField_Helper.FillHelperFieldsFromKPI(trigger.new);
    	}
    }
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
    	if(!FormulaField_Helper.isRunningFromCAse){
        	FormulaField_Helper.isRunningFromHelper = true;
    		FormulaField_Helper.UpdateCaseLookup(trigger.new);
    	}
    }
}