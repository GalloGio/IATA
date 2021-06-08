/**
 * @author			Jorge Corral <jorge.corral@adesso.es>
 * @description		Class to contain all the functions related to the IGOM_Account_Role_Relationship__c object
 * @history			2020/12/11  |  Jorge Corral <jorge.corral@adesso.es>  |  Class Creation, applyForRelationship method implemented.
 */
public without sharing class IGOMAccountRoleRelationshipsUtil {

	/**
	 * APEX Object containing all the stations related to a base station
	 */
	public class AllRelationships{
		@AuraEnabled public IGOMStationUtil.Station own {get;set;}

		@AuraEnabled public List<IGOMStationUtil.RelatedStation> parentStations {get;set;}
		@AuraEnabled public List<IGOMStationUtil.RelatedStation> childStations {get;set;}
		@AuraEnabled public List<IGOMStationUtil.RelatedStation> groupStations {get;set;}

		public List<IGOM_Account_Role_Relationship__c> involvedRelationships {get;set;}
		public AllRelationships(){
			this.parentStations = new List<IGOMStationUtil.RelatedStation>();
			this.childStations = new List<IGOMStationUtil.RelatedStation>();
			this.groupStations = new List<IGOMStationUtil.RelatedStation>();
			this.involvedRelationships = new List<IGOM_Account_Role_Relationship__c>();
		}

		public boolean isParentStation(Id parentStationId) {
			for (IGOMStationUtil.RelatedStation parentStation : this.parentStations) {
				if (parentStation.baseStationId == parentStationId) {
					return true;
				}
			}
			return false;
		}

		public Set<Id> getInvolvedRelationships(){
			Set<Id> rels = new Set<Id>();
			for(IGOM_Account_Role_Relationship__c rel : this.involvedRelationships) {
				rels.add(rel.Id);
			}
			return rels;
		}

		public Set<Id> getParentIdsByClosenessLv(Integer closenessLv){
			Set<Id> stationSet = new Set<Id>();
			for(IGOMStationUtil.RelatedStation station : this.parentStations) {
				if (station.closenessLv == closenessLv) {
					stationSet.add(station.stationInfo.id);
				}
			}
			return stationSet;
		}

		public Set<Id> getChildrenIdsByClosenessLv(Integer closenessLv){
			Set<Id> stationSet = new Set<Id>();
			for(IGOMStationUtil.RelatedStation station : this.childStations) {
				if (station.closenessLv == closenessLv) {
					stationSet.add(station.stationInfo.id);
				}
			}
			return stationSet;
		}
	}

	/**
	 * @description Retrieve all parents and children on a hierarchical relationship + all the group members
	 * if the account roles where on a group relationship for a specified station.
	 * @author Jorge Corral <jorge.corral@adesso.es>
	 * @param stationId <Id of the IGOM Account Role Detail from which all the relationships want to be extracted from>
	 * @return AllRelationships <Every relationship in the system for the given station>
	 */
	public static AllRelationships getAllRelationships(Id stationId){
		AllRelationships accountRoleRelationships = new AllRelationships();
		Map<Id, Set<Id>> fromToMap = new Map<Id, Set<Id>>();
		Map<Id, Set<Id>> toFromMap = new Map<Id, Set<Id>>();
		Set<Id> groupStations = new Set<Id>();
		Map<List<Id>, Id> relationshipIdByFromToMap = new Map<List<Id>, Id>();
		Map<Id, IGOM_Account_Role_Relationship__c> relationshipByIdMap = new Map<Id, IGOM_Account_Role_Relationship__c>();
		Set<Id> stationsInRelationships = new Set<Id>();
		stationsInRelationships.add(stationId);
		for(IGOM_Account_Role_Relationship__c rel : [SELECT Id, From__c, To__c, Type__c, Status__c, Requested_By__c, Accepts_Notifications__c
		FROM IGOM_Account_Role_Relationship__c WHERE Status__c != :IGOMConstants.STATION.STATUS.PENDING]){
			//If relationship is not a group, put relationships into hierarchical maps
			if(rel.Type__c != IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL){
				//Create a map to link all the from-to relationships
				fromToMap = addRelationshipToMap(fromToMap, rel, true);

				//Create a map to link all the to-from relationships
				toFromMap = addRelationshipToMap(toFromMap, rel, false);
			}else{
				//Put only the stations related to stationId in group
				Id id = getStationRelatedToBase(stationId, rel);
				if(id != null){
					groupStations.add(id);
				}
			}
			//Map the relationship id based on the related account roles
			relationshipIdByFromToMap.put(new List<Id>{rel.From__c, rel.To__c}, rel.Id);
			//Create a map to link each relationship with its id
			relationshipByIdMap.put(rel.Id, rel);
			//Create a set of all the stations involved in the relationships
			stationsInRelationships.add(rel.From__c);
			stationsInRelationships.add(rel.To__c);
		}
		//Query all the account role details in the system
		Map<Id, IGOM_Account_Role_Detail__c> roleDetailsByRoleId = new Map<Id, IGOM_Account_Role_Detail__c>();
		for(IGOM_Account_Role_Detail__c roleDetail: [SELECT Id, Account_Role__r.Account__r.Name, Account_Role__c, RecordType.Name, Account_Role__r.Account__c, City__c, Country__c FROM IGOM_Account_Role_Detail__c WHERE Id IN :stationsInRelationships]){
			roleDetailsByRoleId.put(roleDetail.Id, roleDetail);
		}
		accountRoleRelationships.own = new IGOMStationUtil.Station((IGOM_Account_Role_Detail__c) getFromMap(roleDetailsByRoleId, stationId));
		//Add parent stations as parents and register relationship coverage
		if(toFromMap.keySet().contains(stationId)){
			addRelationships(accountRoleRelationships, stationId, toFromMap.get(stationId), roleDetailsByRoleId, relationshipIdByFromToMap, relationshipByIdMap, 1, 'Parent');
		}
		//Add children stations as children and register relationship coverage
		if(fromToMap.keySet().contains(stationId)){
			addRelationships(accountRoleRelationships, stationId, fromToMap.get(stationId), roleDetailsByRoleId, relationshipIdByFromToMap, relationshipByIdMap, 1, 'Child');
		}
		//Add group stations and register relationship coverage
		if(!groupStations.isEmpty()){
			addRelationships(accountRoleRelationships, stationId, groupStations, roleDetailsByRoleId, relationshipIdByFromToMap, relationshipByIdMap, 1, 'Group');
		}
		Set<Id> accRolesToFind_Parent = accountRoleRelationships.getParentIdsByClosenessLv(1);
		Set<Id> accRolesToFind_Child = accountRoleRelationships.getChildrenIdsByClosenessLv(1);
		Integer closenessLevel = 2;
		while (accRolesToFind_Parent.size() != 0 || accRolesToFind_Child.size() != 0){
			Set<Id> accRolesToFind_Parent_temp = accRolesToFind_Parent;
			Set<Id> accRolesToFind_Child_temp = accRolesToFind_Child;
			accRolesToFind_Parent = new Set<Id>();
			accRolesToFind_Child = new Set<Id>();
			for(Id parentId : accRolesToFind_Parent_temp){
				if(toFromMap.keySet().contains(parentId)){
					addRelationships(accountRoleRelationships, parentId, toFromMap.get(parentId), roleDetailsByRoleId, relationshipIdByFromToMap, relationshipByIdMap, closenessLevel, 'Parent');
				}
			}
			for(Id childId : accRolesToFind_Child_temp){
				if(fromToMap.keySet().contains(childId)){
					addRelationships(accountRoleRelationships, childId, fromToMap.get(childId), roleDetailsByRoleId, relationshipIdByFromToMap, relationshipByIdMap, closenessLevel, 'Child');
				}
			}
			accRolesToFind_Parent = accountRoleRelationships.getParentIdsByClosenessLv(closenessLevel);
			accRolesToFind_Child = accountRoleRelationships.getChildrenIdsByClosenessLv(closenessLevel);
			closenessLevel++;
		}
		return accountRoleRelationships;
	}

	/**
	 * @description	Method to add all the relationships of a specific type
	 * @param		accountRoleRelationships <AllRelationships object where to add the relationships>
	 * @param		stationId <Base station Id>
	 * @param		stationIdsToFind <Stations that are related to base station>
	 * @param		relationshipIdByFromToMap <Precalculated map of the IGOM_Account_Role_Relationship__c id by relationship From__c and To__c fields>
	 * @param		relationshipByIdMap <Precalculated map of the IGOM_Account_Role_Relationship__c record by its id>
	 * @param		closenessLv <Number of the closeness between the base station and the related station>
	 * @param		type <Indicator of what type of station relationship could be calling this method>
	 */
	private static void addRelationships(AllRelationships accountRoleRelationships, Id stationId, Set<Id> stationIdsToFind, Map<Id, IGOM_Account_Role_Detail__c> roleDetailsByRoleId,
	Map<List<Id>, Id> relationshipIdByFromToMap, Map<Id, IGOM_Account_Role_Relationship__c> relationshipByIdMap, Integer closenessLv, String type){
		for(Id idStation : stationIdsToFind){
			Id relId = relationshipIdByFromToMap.keySet().contains(new List<Id>{stationId, idStation}) ? relationshipIdByFromToMap.get(new List<Id>{stationId, idStation}):
			relationshipIdByFromToMap.get(new List<Id>{idStation, stationId});
			if(!accountRoleRelationships.getInvolvedRelationships().contains(relId)){
				IGOM_Account_Role_Relationship__c relationship = relationshipByIdMap.get(relId);
				accountRoleRelationships.involvedRelationships.add(relationship);

				IGOMStationUtil.RelatedStation relatedStation = new IGOMStationUtil.RelatedStation((IGOM_Account_Role_Detail__c)
				getFromMap(roleDetailsByRoleId, idStation), closenessLv, relationship);
				if(type != 'Group'){
					relatedStation.isChildRelationship = type == 'Child';
					relatedStation.isParentRelationship = type == 'Parent';
				}
				switch on type {
					when 'Child' {
						accountRoleRelationships.childStations.add(relatedStation);
					}
					when 'Parent' {
						accountRoleRelationships.parentStations.add(relatedStation);
					}
					when else {
						accountRoleRelationships.groupStations.add(relatedStation);
					}
				}
			}
		}
	}

	/**
	 * @description	Request a relationship from a base station to an objective station for a specific relationship type.
	 * @param		type <Relationship request type.>
	 * 'Parent':	base station is requesting for the other station to be its parent.
	 * 'Child':		base station is requesting for the other station to be its child.
	 * 'Group':		base station is requesting to have a group relationship with other station.
	 * @param		stationBaseId <Station requesting the relationship>
	 * @param		stationObjId <Station record>
	 * @param		requestNotifications <Indicate if the base station is requesting the relationship accepting their side of the notifications. This will let the
	 * non-base account to decide if they also want to accept notifications, if base station does not accept notifications, then non-base station will not need to
	 * decide>
	*/
	@AuraEnabled
	public static void requestStationRelationship(String type, Id stationBaseId, Id stationObjId, Boolean requestNotifications){
		IGOM_Account_Role_Relationship__c relationship = getRelationshipBetweenStations(stationBaseId, stationObjId);
		if(relationship == null){
			relationship = new IGOM_Account_Role_Relationship__c();
		}

		relationship.From__c = type == IGOMConstants.STATION.RELATIONSHIP_TYPE.PARENT ? stationObjId : stationBaseId;
		relationship.To__c = type == IGOMConstants.STATION.RELATIONSHIP_TYPE.PARENT ? stationBaseId : stationObjId;
		relationship.Type__c = type == IGOMConstants.STATION.RELATIONSHIP_TYPE.GROVP ? IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL : IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL;
		relationship.Status__c = IGOMConstants.STATION.STATUS.PENDING;
		relationship.Requested_By__c = stationBaseId;
		relationship.Accepts_Notifications__c = requestNotifications;
		upsert relationship;

		IGOMStationUtil.Station ownStation =IGOMStationUtil.getOwnStation(stationBaseId);
		//Create a list of emails for the admins of the station that is receiving the relationship request
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		for (IGOM_Contact_Role_Detail__c contactRoleDetail:
			 [SELECT Id, Account_Contact_Role__r.Contact__c, Account_Role_Detail__r.Account_Role__r.Account__r.Name
			  FROM IGOM_Contact_Role_Detail__c WHERE Account_Role_Detail__c = :stationObjId AND Role__c = :IGOMConstants.ROLES.ADMIN]){
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				email.setTargetObjectId(contactRoleDetail.Account_Contact_Role__r.Contact__c);
				email.setSubject(contactRoleDetail.Account_Role_Detail__r.Account_Role__r.Account__r.Name + ': New relationship request on IGOM');
				email.setPlainTextBody('You have received a request from ' + ownStation.name +
				'.\n\nPlease log into IGOM portal to manage this request: ' + IGOMConstants.METADATA.COMMUNITY_URL);
				emails.add(email);
		}

		if (!emails.isEmpty() && !Test.isRunningTest()) {
			Messaging.sendEmail(emails);
		}
	}

	/**
	 * @description Retrieve all the stations that are not related to a specific station. Retrieves also those stations
	 * that have a request from the stationId pending because they are still not related.
	 * @author Jorge Corral <jorge.corral@adesso.es>
	 * @param relatedStations <Set of ids of the sations that are already related to the station id to avoid looking for them>
	 * @param stationId <Base station, the one used to find it's unrelated stations>
	 * @param searchTerm <When applicable, a search term for the unrelated stations>
	 * @return List<IGOMStationUtil.RelatedStation> <The list of unrelated stations in a RelatedStation object format>
	 */
	public static List<IGOMStationUtil.RelatedStation> getUnrelatedStations(Set<Id> relatedStations, Id stationId, String searchTerm){
		Map<Id, IGOM_Account_Role_Detail__c> stationsWithIds = new Map<Id, IGOM_Account_Role_Detail__c>();
		String protectedSearchTerm = searchTerm != null ? searchTerm + '%' : '%';
		for(IGOM_Account_Role_Detail__c station : [SELECT Id, Account_Role__r.Account__r.Name, Account_Role__r.Account_Name__c, Account_Role__c, Name, RecordType.Name, Account_Role__r.Account__c, City__c, Country__c
		FROM IGOM_Account_Role_Detail__c WHERE Id NOT IN :relatedStations AND Id != :stationId AND Account_Role__r.Account_Name__c LIKE :protectedSearchTerm ORDER BY Account_Role__r.Account_Name__c LIMIT 10]){
			stationsWithIds.put(station.Id, station);
		}

		List<IGOMStationUtil.RelatedStation> unrelatedStations = new List<IGOMStationUtil.RelatedStation>();
		List<Id> stationIds = new List<Id>(stationsWithIds.keySet());
		//Query all the relationships to create RelatedStations that are pending
		for(IGOM_Account_Role_Relationship__c relationship : [SELECT Id, From__c, To__c, Status__c, Type__c, Requested_By__c, Accepts_Notifications__c
		FROM IGOM_Account_Role_Relationship__c WHERE Status__c = :IGOMConstants.STATION.STATUS.PENDING AND
		((From__c IN :stationIds AND To__c = :stationId) OR (From__c = :stationId AND To__c IN :stationIds))]){
			//Find station in relationship
			Id stationInPendingRelationship = getStationRelatedToBase(stationId, relationship);

			//Created related station
			IGOMStationUtil.RelatedStation relatedStation_temp = new IGOMStationUtil.RelatedStation(stationsWithIds.get(stationInPendingRelationship), 1, relationship);
			relatedStation_temp.baseStationId = stationId;
			unrelatedStations.add(relatedStation_temp);

			//Remove id from station ids that do not have a relationship
			for(Integer i = stationIds.size()-1; i >= 0; i--){
				if(stationIds.get(i) == stationInPendingRelationship){
					stationIds.remove(i);
				}
			}
		}

		//Create RelatedStations from the stations that are not related to base station
		for(Id idStation : stationIds){
			IGOMStationUtil.RelatedStation relatedStation_temp = new IGOMStationUtil.RelatedStation(stationsWithIds.get(idStation));
			relatedStation_temp.baseStationId = stationId;
			unrelatedStations.add(relatedStation_temp);
		}
		return unrelatedStations;
	}

	/**
	 * @description Generic method to retrieve a sObject from a map based on an Id
	 * @author Jorge Corral <jorge.corral@adesso.es>
	 * @param objMap <Map from which to get the sObject>
	 * @param id <Key to get the object>
	 * @return sObject <Found sObject, throw an exception when not found>
	 */
	private static sObject getFromMap(Map<Id, sObject> objMap, Id id){
		if(objMap.containsKey(id) && objMap.get(id) != null){
			return objMap.get(id);
		}else{
			throw new AccountRoleRelationshipServiceException(String.format(IGOMConstants.ERRORS.MAP_NO_ID_ERROR, new List<Object>{id}));
		}
	}

	/**
	 * @description	method to insert a relationship in a station relationship map.
	 * @param		existingMap <Map where the relationship will be added>
	 * @param		rel <Relationship to be added>
	 * @param		useFromAsBase <Use realtinoship From__c field to identify the base station>
	 * @return		Map<Id ,Set<Id>> <Map with added item>
	 */
	private static Map<Id ,Set<Id>> addRelationshipToMap(Map<Id ,Set<Id>> existingMap, IGOM_Account_Role_Relationship__c rel, Boolean useFromAsBase){
		Set<Id> toSet;
		if(useFromAsBase){
			toSet = existingMap.get(rel.From__c) != null ? existingMap.get(rel.From__c) : new Set<Id>();
			toSet.add(rel.To__c);
			existingMap.put(rel.From__c, toSet);
		}else{
			toSet = existingMap.get(rel.To__c) != null ? existingMap.get(rel.To__c) : new Set<Id>();
			toSet.add(rel.From__c);
			existingMap.put(rel.To__c, toSet);
		}
		return existingMap;
	}

	/**
	 * @description	method to get the station related to a base station.
	 * @param		baseStId <Base station id>
	 * @param		rel <Relationship to be added>
	 * @param		useFromAsBase <Use realtinoship From__c field to identify the base station>
	 * @return		Map<Id ,Set<Id>> <Map with added item>
	 */
	private static Id getStationRelatedToBase(Id baseStId, IGOM_Account_Role_Relationship__c rel){
		if(rel.From__c == baseStId){
			return rel.To__c;
		}else if(rel.To__c == baseStId){
			return rel.From__c;
		}else{
			return null;
		}
	}

	/**
	 * @description	Find if a relationship between two station exists.
	 * @author Jorge Corral <jorge.corral@adesso.es>
	 * @param stationAId <Station A>
	 * @param stationBId <Station B>
	 * @return IGOM_Account_Role_Relationship__c <The relationship between the stations if exists>
	 */
	public static IGOM_Account_Role_Relationship__c getRelationshipBetweenStations(Id stationAId, Id stationBId){
		List<IGOM_Account_Role_Relationship__c> relationshipsBetweenStations = [SELECT Id, Status__c FROM IGOM_Account_Role_Relationship__c
		WHERE (From__c = :stationAId AND To__c = :stationBId) OR (From__c = :stationBId AND To__c = :stationAId)];
		if(relationshipsBetweenStations.size() > 1){
			List<IGOM_Account_Role_Relationship__c> relationshipsToDelete = new List<IGOM_Account_Role_Relationship__c>();
			for(IGOM_Account_Role_Relationship__c rel : relationshipsBetweenStations){
				//An active relationship should not exist
				if(rel.Status__c == IGOMConstants.STATION.STATUS.ACTIVE){
					throw new AccountRoleRelationshipServiceException(IGOMConstants.ERRORS.RELATIONSHIP_ALREADY_EXISTS_ERROR);
				}
				//Create a list of relationships to delete. Keep only one relationship.
				relationshipsToDelete.add(rel);
			}
			relationshipsToDelete.remove(0);
			if(!relationshipsToDelete.isEmpty()){
				delete relationshipsToDelete;
			}
			return relationshipsBetweenStations.get(0);
		}else{
			return !relationshipsBetweenStations.isEmpty() ? relationshipsBetweenStations.get(0) : null;
		}
	}

	/**
	 * @description	Cancel a realtionship.
	 * @param		relationshipId <Id of the relationship>
	 */
	@AuraEnabled
	public static void deleteRelationship(Id relationshipId){
		delete new IGOM_Account_Role_Relationship__c(Id = relationshipId);
	}

	/**
	 * @description	Deactivate a realtionship request.
	 * @param		relationshipId <Id of the relationship>
	 * @param		status <Status of the relationship>
	 */
	@AuraEnabled
	public static void updateRelationshipStatus(Id relationshipId, String status, Boolean acceptsNotifications){
		update new IGOM_Account_Role_Relationship__c(Id = relationshipId, Status__c = status, Accepts_Notifications__c = acceptsNotifications);
	}

	public class AccountRoleRelationshipServiceException extends Exception{}
}