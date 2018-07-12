public class AMS_CaseTriggerHandler {
    private static id SIDRALiteRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA_Lite');
	private static id SIDRARTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
    
    private static boolean run = true;
	public static boolean runOnce(){
	    if(run){
			run=false;
			return true;
		}else{
			return run;
	    }
    }
    
    public static void handleAfterInsert(List<Case> Cases){
        list<case> lsSidraLiteCases = new list<case>();
        
        for(case c:cases){
        	if(c.recordtypeid == SIDRALiteRTId || c.recordtypeid==SIDRARTId)
        		lsSidraLiteCases.add(c);
        }
        
        if(!lsSidraLiteCases.isEmpty())
        	SelectAgencyOnSidraCase(lsSidraLiteCases);
    }
    
    public static void SelectAgencyOnSidraCase(list<case> Cases){
    	map<id, id> AccntFromCases = new map<id, id>();
    	
    	for(case c:cases){
    		AccntFromCases.put(c.AccountId, c.id);
    	}
		
		//get all HOId, up to 3 levels of hierarchy
    	map<id, id> mapAccntHO = new map<id, id>();
    	for(Account a:[select id, ParentId, Parent.ParentId, parent.parent.parentId from Account where id in:AccntFromCases.Keyset() order by ParentId, Parent.ParentId, parent.parent.parentId NULLS LAST]){
    		if(a.ParentId==null){	//HO
    			mapAccntHO.put(a.Id, AccntFromCases.get(a.Id));
    			continue;
    		}
    		
    		if(a.ParentId!=null && a.Parent.ParentId==null){	//BR
    			mapAccntHO.put(a.ParentId, AccntFromCases.get(a.Id));
    			continue;
    		}
    		
    		if(a.ParentId!=null && a.Parent.ParentId!=null){	//BR
    			mapAccntHO.put(a.Parent.ParentId, AccntFromCases.get(a.Id));
    			continue;
    		}
    	}
    	
    	system.debug('DTULLO 57 --> ' + mapAccntHO.keyset());
    	set<string> setStatusToInclude = new set<string>{'Approved','Cash basis/no commission','Cash basis/with commission','Changes processed','Listed','Under review'};
    	
    	if(!mapAccntHO.isEmpty()){
    		ID RTId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'CaseRelatedAgencies');
    		list<AMS_Process_Detail__c> lsToInsert = new list<AMS_Process_Detail__c>();
    		for(Account a:[select id, status__c
    						, ParentId, Parent.Status__c
    						, Parent.ParentId, Parent.Parent.Status__c 
    					   from Account 
    					   where (id in:mapAccntHO.keyset()
    					   or parentid in :mapAccntHO.keyset()
    					   or parent.parentId in:mapAccntHO.keyset())
    					   and status__c in:setStatusToInclude]){
    			system.debug('DTULLO 81 --> ' + a.ID + ' - ' + a.Status__c + '; ' + a.ParentId + ' - ' + a.Parent.Status__c + '; ' + a.Parent.ParentId + ' - ' + a.Parent.Parent.Status__c + '; ');
    			if(a.ParentId==null && mapAccntHO.containsKey(a.Id)){ //HO
    				lsToInsert.add(new AMS_Process_Detail__c(Case__c = mapAccntHO.get(a.Id), Account__c = a.Id, RecordTypeId = RTId));
    				continue;
    			}
    			
    			if(a.ParentId!=null && a.Parent.ParentId==null && mapAccntHO.containsKey(a.ParentId)){ //BR
    				lsToInsert.add(new AMS_Process_Detail__c(Case__c = mapAccntHO.get(a.ParentId), Account__c = a.Id, RecordTypeId = RTId));
    				continue;
    			}
    			
    			if(a.ParentId!=null && a.Parent.ParentId!=null && mapAccntHO.containsKey(a.Parent.ParentId)){ //SA
    				lsToInsert.add(new AMS_Process_Detail__c(Case__c = mapAccntHO.get(a.Parent.ParentId), Account__c = a.Id, RecordTypeId = RTId));
    				continue;
    			}
	    	}
	    	
	    	if(!lsToInsert.isEmpty())
	    		insert lsToInsert;
    	}
    }
}