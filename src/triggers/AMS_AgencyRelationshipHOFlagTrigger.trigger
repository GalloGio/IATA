trigger AMS_AgencyRelationshipHOFlagTrigger on AMS_Agencies_relationhip__c (before insert, before update) {

	List<AMS_Agencies_relationhip__c> agParentToBeChecked = new List<AMS_Agencies_relationhip__c>();
	List<AMS_Agencies_relationhip__c> agChildToBeChecked = new List<AMS_Agencies_relationhip__c>();
	List<AMS_Agencies_relationhip__c> agToUpdate = new List<AMS_Agencies_relationhip__c>();

	Map<Id, List<AMS_Agencies_relationhip__c>> mAgParentToBeChecked = new Map<Id, List<AMS_Agencies_relationhip__c>>();
	Map<Id, List<AMS_Agencies_relationhip__c>> mAgChildToBeChecked = new Map<Id, List<AMS_Agencies_relationhip__c>>();

	SET<Id> setAgencyParentKeys = new SET<Id>();
	SET<Id> setRelationshipKeys = new SET<Id>();

	Id rtMain = Schema.SObjectType.AMS_Agencies_Hierarchy__c.getRecordTypeInfosByName().get('MAIN').getRecordTypeId();
	

	if(Trigger.isInsert || Trigger.isUpdate){
		for(AMS_Agencies_relationhip__c agRel : Trigger.new){
			setAgencyParentKeys.add(agRel.Parent_agency__c);
			setRelationshipKeys.add(agRel.Id);
		}

	    //get relationship where the agencies are parents
	    agParentToBeChecked = [SELECT Child_Agency__c,Hierarchy__r.Hierarchy_Name__c,HO_Flag__c,Id,Name,Parent_agency__c FROM AMS_Agencies_relationhip__c 
	    						where Parent_agency__c in :setAgencyParentKeys 
	    						and id not in :setRelationshipKeys
	    						and Hierarchy__r.RecordTypeId = :rtMain];

		//get relationship where the agencies are Childrens
	    agChildToBeChecked = [SELECT Child_Agency__c,Hierarchy__r.Hierarchy_Name__c,HO_Flag__c,Id,Name,Parent_agency__c FROM AMS_Agencies_relationhip__c 
	    						where Child_Agency__c in :setAgencyParentKeys 
	    						and id not in :setRelationshipKeys
	    						and Hierarchy__r.RecordTypeId = :rtMain];

	    for(AMS_Agencies_relationhip__c agRel : agParentToBeChecked){
	    	List<AMS_Agencies_relationhip__c> auxAgRel = mAgParentToBeChecked.get(agRel.Parent_agency__c);
	    	if(auxAgRel != Null && auxAgRel.size() > 0){
	    		auxAgRel.add(agRel);
	    		mAgParentToBeChecked.remove(agRel.Parent_agency__c);

    			mAgParentToBeChecked.put(agRel.Parent_agency__c,auxAgRel);
    		}
    		else{
    			auxAgRel = new List<AMS_Agencies_relationhip__c>();
    			auxAgRel.add(agRel);
    			mAgParentToBeChecked.put(agRel.Parent_agency__c,auxAgRel);	
    		}
			
		}	

		for(AMS_Agencies_relationhip__c agRel : agChildToBeChecked){
			List<AMS_Agencies_relationhip__c> auxAgRel = mAgChildToBeChecked.get(agRel.Child_Agency__c);
	    	if(auxAgRel != Null && auxAgRel.size() > 0){
	    		auxAgRel.add(agRel);
	    		mAgChildToBeChecked.remove(agRel.Child_Agency__c);
    			mAgChildToBeChecked.put(agRel.Child_Agency__c,auxAgRel);
    		}
    		else{
    			auxAgRel = new List<AMS_Agencies_relationhip__c>();
    			auxAgRel.add(agRel);
    			mAgChildToBeChecked.put(agRel.Child_Agency__c,auxAgRel);	
    		}
		}

		Boolean bHOFlag = False;

		//Logic for Insert/Update
		if(Trigger.isInsert || Trigger.isUpdate){
		 	
		 	for(AMS_Agencies_relationhip__c agRel : Trigger.new){
			
				//Check if Parent and not a children! if so HO_FLAG = true
		 		if(mAgParentToBeChecked.containsKey(agRel.Parent_agency__c) && !mAgChildToBeChecked.containsKey(agRel.Parent_agency__c)){ 
		 			bHOFlag = True;
		 		}else if(mAgParentToBeChecked.containsKey(agRel.Parent_agency__c) && mAgChildToBeChecked.containsKey(agRel.Parent_agency__c)){
		 			bHOFlag = False;

		 			List<AMS_Agencies_relationhip__c> auxAgParentToBeChecked = mAgParentToBeChecked.get(agRel.Parent_agency__c);

		 			for(AMS_Agencies_relationhip__c auxAgRel: auxAgParentToBeChecked){

						if(auxAgRel.HO_Flag__c != Null && !auxAgRel.HO_Flag__c.equalsIgnoreCase(String.valueOf(bHOFlag))){
				 			auxAgRel.HO_Flag__c = String.valueOf(bHOFlag);

							if(auxAgRel.Id != agRel.Id){
				 				agToUpdate.add(auxAgRel);
				 			}else{
				 				agRel.HO_Flag__c = String.valueOf(bHOFlag);
				 			}
				 		}
		 			} 
		 		}

		 		if(agRel.HO_Flag__c == Null || !agRel.HO_Flag__c.equalsIgnoreCase(String.valueOf(bHOFlag))){
		 			agRel.HO_Flag__c = String.valueOf(bHOFlag);
		 		}
			}

			if(agToUpdate != Null && agToUpdate.size() > 0){
 				update agToUpdate;
 			}
		}
    }
}