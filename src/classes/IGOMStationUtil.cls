/**
 * @description	  Class to contain all the functions related to the IGOM_Account_Role_Detail__c object
 */
public without sharing class IGOMStationUtil {

	/**
	 * DAO Object containing the data from a IGOM_Account_Role_Detail__c record
	 */
	public class Station {
		@AuraEnabled public Id id;
		@AuraEnabled public String name;
		@AuraEnabled public String type;
		@AuraEnabled public Id accountRoleId;
		@AuraEnabled public Id accountId;
		@AuraEnabled public Boolean publishesTemplates;

		@AuraEnabled public String logo { get; set; }
		@AuraEnabled public String city { get; set; }
		@AuraEnabled public String country { get; set; }
		@AuraEnabled public Date lastRevision { get; set; }
		@AuraEnabled public Decimal variations { get; set; }
		@AuraEnabled public String acknowledgements { get; set; }
		public Station(){}
		public Station(IGOM_Account_Role_Detail__c accountRoleDetail) {
			this.id = accountRoleDetail.Id;
			this.name = accountRoleDetail.Account_Role__r.Account__r.Name;
			this.accountRoleId = accountRoleDetail.Account_Role__c;
			this.type = accountRoleDetail.RecordType.Name;
			this.accountId = accountRoleDetail.Account_Role__r.Account__c;
			this.city = accountRoleDetail.City__c;
			this.country = accountRoleDetail.Country__c;
			this.publishesTemplates = false;
		}

		public Station(IGOM_Account_Role_Detail__c accountRoleDetail, Compliance_Review__c lastReview, String acknowledgements) {
			this(accountRoleDetail);

			this.logo = 'none';
			if (lastReview != null) {
				this.lastRevision = lastReview.Effective_Date__c;
				this.variations = lastReview.Compliance_Review_Parts__r.size();
				this.acknowledgements = acknowledgements;
			}
		}
	}

	/**
	 * Apex Object containing the data of a station regarding a relationship with the active (base) station
	 */
	public class RelatedStation {
		@AuraEnabled public Station stationInfo;
		@AuraEnabled public Id relationshipId;

		@AuraEnabled public Id baseStationId;
		@AuraEnabled public Decimal closenessLv;
		@AuraEnabled public Boolean isRelatedToActiveStation;
		@AuraEnabled public Boolean isDirectRelationship;
		@AuraEnabled public Boolean isParentRelationship;
		@AuraEnabled public Boolean isChildRelationship;
		@AuraEnabled public Boolean isGroupRelationship;
		@AuraEnabled public Boolean isActive;
		@AuraEnabled public Boolean isPending;
		@AuraEnabled public Boolean hasRelationshipRequested;
		@AuraEnabled public Boolean acceptsNotifications;

		@AuraEnabled public Boolean requestedByRelatedStation;

		public RelatedStation() {
			this.stationInfo = new Station();
		}
		public RelatedStation(IGOM_Account_Role_Detail__c accountRoleDetail, Decimal closenessLv) {
			this.stationInfo = new Station(accountRoleDetail);

			this.isRelatedToActiveStation = true;
			this.isDirectRelationship = closenessLv == 1;
			this.closenessLv = closenessLv;
		}

		public RelatedStation(IGOM_Account_Role_Detail__c accountRoleDetail, Decimal closenessLv, IGOM_Account_Role_Relationship__c relationship) {
			this(accountRoleDetail, closenessLv);

			this.relationshipId = relationship.Id;
			this.isGroupRelationship = relationship.Type__c == IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL;

			//For a direct relationship these attributes are useful, for other hierarchical relationships, it must be set individually
			this.isParentRelationship = accountRoleDetail.Id == relationship.From__c && relationship.Type__c == IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL;
			this.isChildRelationship = accountRoleDetail.Id == relationship.To__c && relationship.Type__c == IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL;
			
			this.isActive = relationship.Status__c == IGOMConstants.STATION.STATUS.ACTIVE;
			this.isPending = relationship.Status__c == IGOMConstants.STATION.STATUS.PENDING;

			this.baseStationId = accountRoleDetail.Id == relationship.To__c ? relationship.From__c : relationship.To__c;
			this.hasRelationshipRequested = relationship.Status__c == IGOMConstants.STATION.STATUS.PENDING;
			this.acceptsNotifications = relationship.Accepts_Notifications__c;
			this.requestedByRelatedStation = relationship.Requested_By__c == accountRoleDetail.Id;
		}

		public RelatedStation(IGOM_Account_Role_Detail__c accountRoleDetail){
			this.stationInfo = new Station(accountRoleDetail);

			this.isRelatedToActiveStation = false;
			this.isDirectRelationship = false;
			this.isParentRelationship = false;
			this.isChildRelationship = false;
			this.isGroupRelationship = false;
			this.isActive = false;
			this.isPending = false;
			this.hasRelationshipRequested = false;
			this.acceptsNotifications = false;
			this.requestedByRelatedStation = false;
		}
	}

	/**
	 * @description	Recover a list of Station objects by IGOM_Account_Role_Detail__c id.
	 * @param		ids <Active station id>
	 * @return		List<Station> <Station list>
	 */
	public static List<Station> getIGOMAccountRoleDetailByIds(List<Id> ids) {
		List<Station> stations = new List<Station>();
		for (IGOM_Account_Role_Detail__c accountRoleDetail :
			 [SELECT Id, RecordType.Name, Account_Role__r.Account__r.Name, Account_Role__c, Account_Role__r.Account__c, City__c, Country__c FROM IGOM_Account_Role_Detail__c WHERE Id IN :ids])
		{
			stations.add(new Station(accountRoleDetail));
		}
		return stations;
	}

	/**
	 * @description	Recover the stations in which the current user has a role in and map them by their id.
	 * @return		Map<Id, Station> <Station map by their id>
	 */
	private static Map<Id, Station> ownStations;
	@AuraEnabled(cacheable=true)
	public static Map<Id, Station> getOwnStations() {
		if (ownStations == null) {
			// Get the current user
			User currentUser = IGOMCommunityUtil.getCurrentUser();
			if (currentUser.ContactId == null) {
				throw new AuraHandledException(String.format(IGOMConstants.ERRORS.USER_WITHOUT_CONTACT_ERROR, new List<String>{UserInfo.getUserId(), currentUser.Profile.Name}));
			}
			// Get the related IGOM Contact Role details
			List<IGOM_Contact_Role_Detail__c> contactRoleDetails =
				[SELECT Account_Role_Detail__c
					FROM IGOM_Contact_Role_Detail__c
					WHERE Account_Contact_Role__r.Contact__c = :currentUser.ContactId AND
						  Account_Contact_Role__r.Functional_Role__c = :IGOMConstants.GLOBALS.FUNCTIONAL_ROLE_SERVICE];
			if (contactRoleDetails.isEmpty()) {
				throw new AuraHandledException(String.format(IGOMConstants.ERRORS.NO_ROLE_FOR_USER_AND_STATION_ERROR, new List<String>{UserInfo.getUserId(), currentUser.ContactId}));
			}
			// Get the Stations data from the Contact Role
			List<Id> accountRoleDetailIds = new List<Id>();
			for (IGOM_Contact_Role_Detail__c contactRoleDetail : contactRoleDetails) {
				accountRoleDetailIds.add(contactRoleDetail.Account_Role_Detail__c);
			}
			List<Station> stationsList = getIGOMAccountRoleDetailByIds(accountRoleDetailIds);
			// Save and cache the data
			ownStations = new Map<Id, Station>();
			for (Station station : stationsList) {
				ownStations.put(station.id, station);
			}
			// Get if the stations has any children under it (for template vs full publish)
			for (IGOM_Account_Role_Relationship__c igomAccountRoleRelationship : [SELECT From__c FROM IGOM_Account_Role_Relationship__c WHERE From__c IN :accountRoleDetailIds]) {
				ownStations.get(igomAccountRoleRelationship.From__c).publishesTemplates = true;
			}
		}
		return ownStations;
	}

	/**
	 * @description	Recover a station in which the user has a role by its id.
	 * @param		stationId <Active station id>
	 * @return		Station <Station object>
	 */
	public static Station getOwnStation(Id stationId) {
		// Get the passed station Id
		Station station = getOwnStations().get(stationId);
		if (station == null) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.STATION_NOT_RELATED_TO_USER_ERROR, new List<String>{stationId}));
		}
		return station;
	}

	/**
	 * @description	Recover all the stations if the user has the permission to do it, get the owned ones if not. With them take
	 * the latest gap analysis and the acknowledgements that took place on it.
	 * @param		forPage <Page for which the stations are being listed, the values accepted are 'Variations' or 'Dashboard'>
	 * @return		List<Station> <Station in the system>
	 */
	@AuraEnabled(cacheable=true)
	public static List<Station> getStationsData(String forPage) {
		// Check for permissions
		if (forPage == 'Variations') {
			if (!IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_ALL_VARIATIONS) &&
				!IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS)) {
				throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<String>{ 'list stations for variations' }));
			}
		} else if (forPage == 'Dashboard') {
			if (!IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_ALL_DASHBOARD) &&
				!IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD)) {
				throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<String>{ 'list stations for dashboards' }));
			}
		} else {
			throw new AuraHandledException(IGOMConstants.ERRORS.INVALID_PAGE);
		}
		// Get every station detail depending on the permissions
		List<IGOM_Account_Role_Detail__c> igomAccountRoles;
		// Get stations depending on permissions+page
		if ((forPage == 'Variations' && IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_ALL_VARIATIONS)) ||
			(forPage == 'Dashboard' && IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_ALL_DASHBOARD))) {
			igomAccountRoles = [SELECT Id, Account_Role__r.Account__r.Name, RecordType.Name, City__c, Country__c, Account_Role__c, Account_Role__r.Account__c FROM IGOM_Account_Role_Detail__c];
		} else {
			if (forPage == 'Variations') {
				igomAccountRoles =
				[SELECT Id, Account_Role__r.Account__r.Name, RecordType.Name, City__c, Country__c, Account_Role__c, Account_Role__r.Account__c
				 FROM IGOM_Account_Role_Detail__c
				 WHERE Id IN :IGOMPermissions.stationsWithPermission(IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS)];
			} else if (forPage == 'Dashboard') {
				igomAccountRoles =
				[SELECT Id, Account_Role__r.Account__r.Name, RecordType.Name, City__c, Country__c, Account_Role__c, Account_Role__r.Account__c
				 FROM IGOM_Account_Role_Detail__c
				 WHERE Id IN :IGOMPermissions.stationsWithPermission(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD)];
			}
		}
		Set<Id> accountRoleIds = new Set<Id>();
		for(IGOM_Account_Role_Detail__c igomAccountRole : igomAccountRoles) {
			accountRoleIds.add(igomAccountRole.Account_Role__c);
		}
		// Aggregate the notification statuses
		Map<Id, String> acknowledgementsByComplianceReview = new Map<Id, String>();
		List<AggregateResult> acknowledgementQuantities =
					[SELECT Notification_Status__c, Compliance_Review_Part__r.Compliance_Review__c, COUNT(Id) num
					 FROM IGOM_Contact_Role_Procedure_Compliance__c
					 GROUP BY Compliance_Review_Part__r.Compliance_Review__c, Notification_Status__c];
		for (AggregateResult aggr : acknowledgementQuantities) {
			Id compReviewId = (Id)aggr.get('Compliance_Review__c');
			Decimal aggrNum = (Decimal)aggr.get('num');
			if (!acknowledgementsByComplianceReview.containsKey(compReviewId)) {
				acknowledgementsByComplianceReview.put(compReviewId, String.valueOf(aggrNum));
			} else {
				Integer currentNum = Integer.valueOf(acknowledgementsByComplianceReview.get(compReviewId));
				Integer total = Integer.valueOf(aggrNum) + currentNum;
				if (aggr.get('Notification_Status__c') == IGOMConstants.NOTIFICATION.STATUS.ACKNOWLEDGED) {
					acknowledgementsByComplianceReview.put(compReviewId, String.valueOf(aggrNum) + '/' + String.valueOf(total));
				} else {
					acknowledgementsByComplianceReview.put(compReviewId, currentNum + '/' + String.valueOf(total));
				}
			}
		}
		Map<Id, List<Compliance_Review__c>> complianceReviewsByStation = new Map<Id, List<Compliance_Review__c>>();
		// Query the compliance review and its variations to list them
		for(Compliance_Review__c complianceReview :
			[SELECT Id, Name, Effective_Date__c, Station__c,
			 (SELECT Id FROM Compliance_Review_Parts__r
				WHERE Status__c = :IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION AND
				Standard_Document_Part__c NOT IN (SELECT Parent__c FROM Document_Part__c))
			 FROM Compliance_Review__c
			 WHERE Station__c IN :accountRoleIds])
		{
			if (!complianceReviewsByStation.keySet().contains(complianceReview.Station__c)) {
				complianceReviewsByStation.put(complianceReview.Station__c, new List<Compliance_Review__c>());
			}
			complianceReviewsByStation.get(complianceReview.Station__c).add(complianceReview);
		}
		// Get the last review
		List<Station> wrapperList = new List<Station>();
		for (IGOM_Account_Role_Detail__c item : igomAccountRoles) {
			Compliance_Review__c lastReview;
			if (complianceReviewsByStation.containsKey(item.Id)) {
				for (Compliance_Review__c review : complianceReviewsByStation.get(item.Id)) {
					if (lastReview == null || lastReview.Effective_Date__c < review.Effective_Date__c) {
						lastReview = review;
					}
				}
			}
			wrapperList.add(new Station(item, lastReview, lastReview!=null ? acknowledgementsByComplianceReview.get(lastReview.Id) : null));
		}
		return wrapperList;
	}
	
}