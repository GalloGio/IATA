public with sharing class ObjectiveHandler {
	// this map has all parent Ids in the current list of Objectives
	// and all children for these parents
	private static map<Id,list<Objective__c>> mapParentObjectives;
	// this map has current objective's children grouped by its parent Id
	private static map<Id,list<Objective__c>> mapChildrenObjectives;
	// this map contains all accounts related with the objectives
	private static map<Id,Account> mapAccount;


	/** BEFORE **/
	public static void beforeInsert(list<Objective__c> listNew) {
		populateMapParentObjectives(listNew);
		populateMapChildren(listNew);
		populateMapAccount(listNew);

		setObjectiveName( listNew );
		updateAllSubobjectivesCreated( listNew );
	}

	public static void beforeUpdate(list<Objective__c> listNew, list<Objective__c> listOld) {
		populateMapParentObjectives(listNew);
		populateMapChildren(listNew);
		populateMapAccount(listNew);

		updateObjectiveName( listNew, listOld );
		updateAllSubobjectivesCreated( listNew );
	}

	public static void beforeDelete(list<Objective__c> listOld) {
		populateMapParentObjectives(listOld, false);
		populateMapChildren(listOld);
	}

	/** AFTER **/
	public static void afterInsert(list<Objective__c> listNew) {
		updateParentCurrentValue();
		updateAllSubobjectivesCreatedinParent(listNew);
	}

	public static void afterUpdate(list<Objective__c> listNew, list<Objective__c> listOld) {
		updateParentCurrentValue();
		updateAllSubobjectivesCreatedinParent(listNew);
	}

	public static void afterDelete(list<Objective__c> listOld) {
		updateParentCurrentValue();
		updateAllSubobjectivesCreatedinParent(listOld);
	}


	/**
		fill the map for Parent Objectives
	**/
	public static void populateMapParentObjectives( list<Objective__c> listObjective) {
		populateMapParentObjectives(listObjective, true);
	}
	public static void populateMapParentObjectives( list<Objective__c> listObjective, Boolean inlcudeCurrent) {
		list<Id> listParentObjectiveId = new list<Id>();
		for (Objective__c objective: listObjective) {
			listParentObjectiveId.add(objective.Parent_Objective__c);
		}

		mapParentObjectives = new map<Id,list<Objective__c>>();
		list<Objective__c> listChildren = [
			Select Id, Current__c, Forecast__c, Parent_Objective__c, Area__c, Region__c
			from Objective__c
			where Parent_Objective__c in :listParentObjectiveId
			and id not in :listObjective
		];
		for (Objective__c child: listChildren) {
			list<Objective__c> value = mapParentObjectives.get(child.Parent_Objective__c);
			if (value == null ) {
				value = new list<Objective__c>();
			}
			value.add(child);
			mapParentObjectives.put(child.Parent_Objective__c, value);
		}
		// add objectives avoided in the previous query
		for (Objective__c child: listObjective) {
			list<Objective__c> value = mapParentObjectives.get(child.Parent_Objective__c);
			if (value == null ) {
				value = new list<Objective__c>();
			}
			// if included add to the map, if not an empty list will be added
			if (inlcudeCurrent) {
				value.add(child);
			}
			mapParentObjectives.put(child.Parent_Objective__c, value);
		}
		listChildren.addAll(listObjective);
	}

	/**
		fill the map of children objectives
	**/
	public static void populateMapChildren(list<Objective__c> listObjective) {
		//create a map for children
		mapChildrenObjectives = new map<Id,list<Objective__c>>();
		for (Objective__c child: [
			Select Id, Region__c, Area__c, Parent_Objective__c
			from Objective__c
			where Parent_Objective__c in :listObjective]
		) {
			list<Objective__c> values = mapChildrenObjectives.get(child.Parent_Objective__c);
			if (values == null ) {
				values = new list<Objective__c>();
			}
			values.add(child);
			mapChildrenObjectives.put(child.Parent_Objective__c, values);
		}
	}

	/**
		fill the map of Accounts related with objectives
	**/
	public static void populateMapAccount(list<Objective__c> listObjective) {
		list<Id> listAccountId = new list<Id>();
		for (Objective__c objective: listObjective ) {
			listAccountId.add(objective.Account__c);
		}
		mapAccount = new map<Id,Account>(
			[Select id, Name from Account where id in :listAccountId]
		);
	}


	/**
		Set the name of the objective when is created
	**/
	public static void setObjectiveName(list<Objective__c> listNew) {
		for (Objective__c objective: listNew) {
			objective.Description__c = objective.Name;
			objective.Name = getObjectiveName(objective);
		}
	}

	/**
		Set the name of the objective when is updated
	**/
	public static void updateObjectiveName(list<Objective__c> listNew, list<Objective__c> listOld) {
		for (Integer i = 0; i<listNew.size(); i++) {
			Objective__c newObjective = listNew.get(i);
			Objective__c oldObjective = listOld.get(i);
			if (newObjective.Name != oldObjective.Name) {
				newObjective.Description__c = newObjective.Name;
			}
			newObjective.Name = getObjectiveName(newObjective);
		}
	}

	/**
		gets a formatted name for the objective based on its recordtype
	**/
	private static String getObjectiveName(Objective__c objective) { 
		if (objective.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Division')) {
			return nvl(objective.Division__c) + '-' + objective.Description__c + '-' + objective.Forecast_Deadline__c.year();

		} else if (objective.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Region')) {
			return nvl(objective.Division__c) + '-' + nvl(objective.Region__c) + '-' + objective.Description__c + '-' + objective.Forecast_Deadline__c.year();

		} else if (objective.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Area')) {
			return nvl(objective.Division__c) + '-' + nvl(objective.Area__c) + '-' + objective.Description__c + '-' + objective.Forecast_Deadline__c.year();

		} else if (objective.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Account')) {
			try {
				Account account = mapAccount.get(objective.Account__c);
				String objName = nvl(objective.Division__c) + '-' + account.Name + '-' + objective.Description__c + '-' +objective.Forecast_Deadline__c.year();
				if( objName.length() > 80){
					Integer lengthToRemove = objName.length() - 80;
					Integer accountNameLength = (account.Name.length()) - lengthToRemove;
					return nvl(objective.Division__c) + '-' + account.Name.substring(0,accountNameLength) + '-' + objective.Description__c + '-' +objective.Forecast_Deadline__c.year();
				}
				return objName;
			} catch (Exception e ) {
				return nvl(objective.Division__c) + '-' + objective.Description__c + '-' +objective.Forecast_Deadline__c.year();
			}
		}
		return objective.Description__c;
	}

	private static String nvl(String input) {
		return input==null?'':input;
	}

	/**
		Update in parent if all regions or areas selected in the field are created
		This function only applies in if the parent changes
	**/
	public static void updateAllSubobjectivesCreated( list<Objective__c> listObjective) {

		for (Objective__c objective: listObjective) {
			list<String> listStrings = new list<String>();
			set<String> setStrings = new set<String>();

			if (objective.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Division')) {
				listStrings = nvl(objective.Cascade_To_Region__c).split(';');
				list<Objective__c> listChildren = mapChildrenObjectives.get(objective.Id);
				if ( listChildren != null ) {
					for ( Objective__c child: mapChildrenObjectives.get(objective.Id) ) {
						if ( child != null) {
							setStrings.add(child.Region__c);
						}
					}
				}
				Boolean newValueOnParent = listContainsSet(listStrings, setStrings);
				objective.All_Regions_Created__c = newValueOnParent;
			}

			if (objective.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Region')) {
				listStrings = nvl(objective.Cascade_To_Area__c).split(';');
				list<Objective__c> listChildren = mapChildrenObjectives.get(objective.Id);
				if ( listChildren != null ) {
					for ( Objective__c child: mapChildrenObjectives.get(objective.Id) ) {
						if ( child != null) {
							setStrings.add(child.Area__c);
						}
					}
				}
				Boolean newValueOnParent = listContainsSet(listStrings, setStrings);
				objective.All_Areas_Created__c = newValueOnParent;
			}

		}
	}

	/**
		check if all elements in the list are in the set
	**/
	public static Boolean listContainsSet( list<String> listString, set<String> setString) {
		for (String listElem : listString ) {
			if ( listElem!=null && listElem != '' && ! setString.contains(listElem) ) {
				// if we found an element in parent not in the children we return false
				return false;
			}
		}
		return true;
	}

	/**
		Update in parent if all regions or areas selected in the field are created
		This funcion only applies in if the children changes
	**/
	public static void updateAllSubobjectivesCreatedinParent( list<Objective__c> listNew) {
		map<Id,Objective__c> mapParent = new map<Id,Objective__c>([
			Select Id, All_Regions_Created__c, Cascade_To_Region__c, Cascade_To_Area__c, All_Areas_Created__c
			from Objective__c
			where id = :mapParentObjectives.keyset()
		]);

		list<Objective__c> listToUpdate = new list<Objective__c>();

		for ( Objective__c objective: listNew) {

			if (objective.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Region')) {

				Objective__c parent = mapParent.get(objective.Parent_Objective__c);
				if (parent!= null ) {
					list<Objective__c> listChildren = mapParentObjectives.get(parent.Id);
					if (listChildren != null) {
						set<String> setRegions = new set<String>();
						for ( Objective__c child : listChildren) {
							setRegions.add(child.Region__c);
						}
						list<String> listRegions = nvl(parent.Cascade_To_Region__c).split(';');
						Boolean newValueOnParent = listContainsSet(listRegions, setRegions);
						if ( parent.All_Regions_Created__c != newValueOnParent ) {
							parent.All_Regions_Created__c = newValueOnParent;
							listToUpdate.add(parent);
						}
					}
				}
			} else if (objective.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Area')) {

				Objective__c parent = mapParent.get(objective.Parent_Objective__c);
				if (parent!= null ) {
					list<Objective__c> listChildren = mapParentObjectives.get(parent.Id);
					if (listChildren != null) {
						set<String> setAreas = new set<String>();
						for ( Objective__c child : listChildren) {
							setAreas.add(child.Area__c);
						}
						list<String> listAreas = nvl(parent.Cascade_To_Area__c).split(';');
						Boolean newValueOnParent = listContainsSet(listAreas, setAreas);
						if ( parent.All_Areas_Created__c != newValueOnParent ) {
							parent.All_Areas_Created__c = newValueOnParent;
							listToUpdate.add(parent);
						}
					}
				}
			}
		}
		if (!listToUpdate.isEmpty()) update listToUpdate;
	}

	/**
		Update the parent value with a sum of all children
	**/
	public static void updateParentCurrentValue() {
		list<Objective__c> listParent = [
			Select Id, Children_Current_Value__c, Forecast__c
			from Objective__c
			where id in :mapParentObjectives.keyset()
		];

		for (Objective__c parent: listParent ) {
			parent.Children_Current_Value__c = 0;
			parent.Children_Forecast__c = 0;
			for ( Objective__c child : mapParentObjectives.get(parent.Id) ) {
				parent.Children_Current_Value__c += child.Current__c==null?0:child.Current__c;
				parent.Children_Forecast__c += child.Forecast__c==null?0:child.Forecast__c;
			}
		}

		if(!listParent.isEmpty()) update listParent;
	}

}
