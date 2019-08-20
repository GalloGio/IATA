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

    public static Map<Id,List<AMS_Process_Detail__c>> SelectAgencyOnSidraCase(List<Case> cases){
        return SelectAgencyOnSidraCase(cases, new Map<Id,Id>());
    }
    
    public static Map<Id,List<AMS_Process_Detail__c>> SelectAgencyOnSidraCase(List<Case> cases, Map<Id,Id> casePerParent){
    	
        if(casePerParent.isEmpty()){
            Map<Id,Id> accntFromCases = new Map<Id,Id>();
        	
        	for(Case c : cases){
				if(c.AccountId != null)
        			accntFromCases.put(c.AccountId, c.Id);
        	}
    		
    		//get all HOId, up to 3 levels of hierarchy
        	for(Account a : [SELECT Id, ParentId, Parent.ParentId, Parent.Parent.ParentId FROM Account WHERE Id IN:accntFromCases.Keyset() ORDER BY ParentId, Parent.ParentId, Parent.Parent.ParentId NULLS LAST]){
        		if(a.ParentId == null){	//HO
        			casePerParent.put(a.Id, accntFromCases.get(a.Id));
        			continue;
        		}
        		
        		if(a.ParentId!=null && a.Parent.ParentId==null){	//BR
        			casePerParent.put(a.ParentId, accntFromCases.get(a.Id));
        			continue;
        		}
        		
        		if(a.ParentId!=null && a.Parent.ParentId!=null){	//BR
        			casePerParent.put(a.Parent.ParentId, accntFromCases.get(a.Id));
        			continue;
        		}
        	}
        }
    	
    	Set<String> setStatusToInclude = new Set<String>{'Approved','Cash basis/no commission','Cash basis/with commission','Changes processed','Listed','Under review'};
    	
        Map<Id,List<AMS_Process_Detail__c>> hierarchySelectionToInsert = new Map<Id,List<AMS_Process_Detail__c>>();
        
        if(casePerParent.isEmpty()) return hierarchySelectionToInsert;
       
		ID RTId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'CaseRelatedAgencies');
        List<AMS_Process_Detail__c> listToInsert = new List<AMS_Process_Detail__c>();
        Set<Id> casePerParentKeys = casePerParent.keyset();
		
        for(Account a : [SELECT Id, Status__c
						, ParentId, Parent.Status__c
						, Parent.ParentId, Parent.Parent.Status__c 
					   FROM Account 
					   WHERE (Id IN: casePerParentKeys
					   OR ParentId IN: casePerParentKeys
					   OR Parent.ParentId IN: casePerParentKeys)
					   AND Status__c IN: setStatusToInclude]){
			
			if(a.ParentId == null && casePerParent.containsKey(a.Id)){ //HO
                Id cseAux = casePerParent.get(a.Id);
                if(!hierarchySelectionToInsert.containsKey(cseAux))
                    hierarchySelectionToInsert.put(cseAux, new List<AMS_Process_Detail__c>());
				AMS_Process_Detail__c pd = new AMS_Process_Detail__c(Case__c = cseAux, Account__c = a.Id, RecordTypeId = RTId);
                hierarchySelectionToInsert.get(cseAux).add(pd);
                listToInsert.add(pd);
				continue;
			}
			
			if(a.ParentId != null && a.Parent.ParentId == null && casePerParent.containsKey(a.ParentId)){ //BR
                Id cseAux = casePerParent.get(a.ParentId);
				if(!hierarchySelectionToInsert.containsKey(cseAux))
                    hierarchySelectionToInsert.put(cseAux, new List<AMS_Process_Detail__c>());
                AMS_Process_Detail__c pd = new AMS_Process_Detail__c(Case__c = cseAux, Account__c = a.Id, RecordTypeId = RTId);
                hierarchySelectionToInsert.get(cseAux).add(pd);
                listToInsert.add(pd);
				continue;
			}
			
			if(a.ParentId != null && a.Parent.ParentId != null && casePerParent.containsKey(a.Parent.ParentId)){ //SA
                Id cseAux = casePerParent.get(a.Parent.ParentId);
				if(!hierarchySelectionToInsert.containsKey(cseAux))
                    hierarchySelectionToInsert.put(cseAux, new List<AMS_Process_Detail__c>());
                AMS_Process_Detail__c pd = new AMS_Process_Detail__c(Case__c = cseAux, Account__c = a.Id, RecordTypeId = RTId);
                hierarchySelectionToInsert.get(cseAux).add(pd);
				listToInsert.add(pd);
                continue;
			}
    	}
    	
    	if(!hierarchySelectionToInsert.isEmpty())
    		insert listToInsert;

        return hierarchySelectionToInsert;
    }
}