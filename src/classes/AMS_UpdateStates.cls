/*
*WARNING: This batch is only to run once, to clean the State data on addresses
*delete this batch after the process finished
*/

global class AMS_UpdateStates implements Database.Batchable<sObject> {

    global Iterable<sObject> start(Database.BatchableContext bc) {
        return [select id, State__c, State__r.Name from AMS_Address__c where State__r.Name like '%-BAD' and legacy_system__c <> 'Webstar'];
    }

    global void execute(Database.BatchableContext BC, list<sObject> scope) {

		List<IATA_ISO_State__c> states = IATAIsoStateDAO.getIsoStates();
        Map<String, IATA_ISO_State__c> mapStates = new Map<String, IATA_ISO_State__c>();
        for(IATA_ISO_State__c s:states){
            if(!s.Name.endsWith('-BAD')){
        	   mapStates.put(s.Name,s);
            }
        }
        List<AMS_Address__c> addToUpdate = new List<AMS_Address__c>();
        for(sObject add:scope){
        	AMS_Address__c a = (AMS_Address__c)add;
        	String fixed = a.State__r.Name.replace('-BAD','').toLowerCase();
            String result = '';
        	List<String> teste = fixed.split(' ');
        	for(String t:teste){
        		result += t.substring(0,1).toUpperCase() + t.substring(1,t.length()) + ' ';
        	}
        	result = result = result.substring(0, result.length() - 1);
            system.debug(result);

            //these are the only two discrepancies on the names between the wrong one and the correct one
            if(a.State__r.Name == 'AUSTRALIAN CAPITAL TERR-BAD')
            	result = 'Australian Capital Territory';
            if(a.State__r.Name == 'COM.OF NORTHERN MARIANA IS-BAD')
            	result = 'Com. of Northern Mariana';
            /////////////////////////////////////////////////

        	if(mapStates.get(result) != null){
        		a.State__c = mapStates.get(result).id;
        		addToUpdate.add(a);
        	}
        }
        if(addToUpdate.size() > 0)
        	update addToUpdate;
    }

    global void finish(Database.BatchableContext BC) {

    }
}