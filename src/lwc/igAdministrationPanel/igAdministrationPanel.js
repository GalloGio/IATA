import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { constants } from 'c/igConstants';
import { util } from 'c/igUtility';
import { label } from 'c/igLabels';
import userId from '@salesforce/user/Id';
// wire methods
import getUsersInStation from '@salesforce/apex/IGOMCommunityUtil.getUsersInStation';
import getRelatedStations from '@salesforce/apex/IGOMCommunityUtil.getAllRelatedStations';
import getUnrelatedStations from '@salesforce/apex/IGOMCommunityUtil.getUnrelatedStations';

// User role-related methods
import setRole from '@salesforce/apex/IGOMContactRoleDetailUtil.setRoleDetailToContact';
import deleteRole from '@salesforce/apex/IGOMCommunityUtil.deleteContactRoleDetail';
import searchUserInOtherStations from '@salesforce/apex/IGOMCommunityUtil.searchSpecificUserAvoidingStation';

// Station relationship-related methods
import requestStationRelationship from '@salesforce/apex/IGOMAccountRoleRelationshipsUtil.requestStationRelationship';
import deleteRelationship from '@salesforce/apex/IGOMAccountRoleRelationshipsUtil.deleteRelationship';
import updateRelationshipStatus from '@salesforce/apex/IGOMAccountRoleRelationshipsUtil.updateRelationshipStatus';


export default class IgAdministrationPanel extends LightningElement {

	@track label = label;
	@api stationId;

	activeUserId = userId;
	activeUserInfo;

	roleOptions = [
		constants.CONTACT_ROLE_DETAIL.ROLE.VALUES.ACKNOWLEDGER,
		constants.CONTACT_ROLE_DETAIL.ROLE.VALUES.EDITOR,
		constants.CONTACT_ROLE_DETAIL.ROLE.VALUES.ADMIN,
		constants.CONTACT_ROLE_DETAIL.ROLE.VALUES.VIEWER
	];

	usersInStationWiredResult;
	relatedStationsWiredResult;
	unrelatedStationsWiredResult;

	@track usersInStation = [];
	relatedStations = [];
	@track unrelatedStations = [];
	@track stationRequests = [];

	relatedStationIds = [];

	showUsersWithNoRole = false;
	searching = false;
	userSearchParam = '';
	stationSearchParam = '';
	@track searchedUser;

	showRemoveRelationship = false;
	showRequestRelationship = false;

	@wire(getUsersInStation, { stationId: '$stationId' })
	getUsersInStationWired(result) {
		this.usersInStationWiredResult = result;

		if (result.error) {
			util.debug.error('Error getting users in station ', result.error);
			return;
		}
		if (result.data) {
			this.usersInStation = result.data.filter(userData => userData.role !== 'IATA Personnel');;
			// Get current user info
			this.activeUserInfo = result.data.filter(userData => userData.userId === this.activeUserId);
		}
	}

	@wire(getRelatedStations, { stationId: '$stationId' })
	getRelatedStationsWired(result) {
		this.relatedStationIds = [];
		this.relatedStations = [];
		this.relatedStationsWiredResult = result;
		if (result.error) {
			util.debug.error('Error getting related stations ', result.error);
			return;
		}
		if (result.data) {
			let relatedS = JSON.parse(JSON.stringify(result.data));

			if(relatedS.parentStations !== undefined){
				//Sort parent stations to have closeness level
				relatedS.parentStations.sort((stationA, stationB) => (stationA.closenessLv > stationB.closenessLv) ? -1 : ((stationB.closenessLv > stationA.closenessLv) ? 1 : (stationB.name > stationA.name) ? 1 : -1 ));
				this.filterActiveStations(relatedS.parentStations);
			}

			this.relatedStationIds.push(this.stationId);
			this.relatedStations.push(relatedS.own);

			if(relatedS.childStations !== undefined){
				//Sort parent stations to have closeness level
				relatedS.childStations.sort((stationA, stationB) => (stationA.closenessLv > stationB.closenessLv) ? 1 : ((stationB.closenessLv > stationA.closenessLv) ? -1 : (stationB.name > stationA.name) ? 1 : -1 ));
				this.filterActiveStations(relatedS.childStations);
			}
			if(relatedS.groupStations !== undefined){
				//Sort parent stations to have closeness level
				relatedS.groupStations.sort((stationA, stationB) => (stationB.name > stationA.name) ? 1 : -1 );
				this.filterActiveStations(relatedS.groupStations);
			}
		}
	}

	@wire(getUnrelatedStations, { stationId: '$stationId', searchTerm:  this ? this.stationSearchParam : null})
	getUnrelatedStationsWired(result) {
		this.unrelatedStationsWiredResult = result;
		if (result.error) {
			util.debug.error('Error getting unrelated stations ', result.error);
			return;
		}
		if (result.data) {
			this.setUnrelatedStations(result.data);
		}
	}

	filterActiveStations(stationList){
		stationList.forEach(station => {
			//Filter Active stations
			if(station.isActive){
				this.relatedStationIds.push(station.stationInfo.id);
				this.relatedStations.push(station);
			}
		});
	}

	setUnrelatedStations(data){
		this.stationRequests = [];
		this.unrelatedStations = [];
		data.forEach(station =>{
			//If a relationship was requested by related station, show in received relationships
			if(station.isRelatedToActiveStation && station.hasRelationshipRequested && station.requestedByRelatedStation){
				this.stationRequests.push(JSON.parse(JSON.stringify(station)));
			}else{
				this.unrelatedStations.push(JSON.parse(JSON.stringify(station)));
			}
		});
	}

	get usersToDisplay() {
		let usersFilteredBySearch = [...this.usersInStation];
		if (!usersFilteredBySearch) {
			return null;
		}
		// 1. Hide the ones without role
		if (!this.showUsersWithNoRole) {
			usersFilteredBySearch = usersFilteredBySearch.filter(user => user.role !== undefined);
		}

		// 2. Apply search filter
		if (this.searching) {
			//Do search in station
			usersFilteredBySearch = usersFilteredBySearch.filter(user => user.fullName.toUpperCase().includes(this.userSearchParam.toUpperCase()));
			if (usersFilteredBySearch.length === 0 && this.searchedUser){
				usersFilteredBySearch = [this.searchedUser];
			}
		}
		// 3. Order by fullname
		usersFilteredBySearch = usersFilteredBySearch.sort((a,b) => (a.fullName > b.fullName) ? 1 : ((b.fullName > a.fullName) ? -1 : 0));
		return usersFilteredBySearch;
	}

	get roleOptionsCombo(){
		if(this.roleOptions){
			let roles = [];
			this.roleOptions.forEach(role => {
				roles.push({'label': role, 'value': role});
			});
			return roles;
		}
		return null;
	}

	get requestList(){
		return this.stationRequests.length != 0 ? this.stationRequests : null;
	}

	get stationsRelated(){
		return this.relatedStations.length != 0 ? this.relatedStations : null;
	}

	get stationsUnrelated(){
		return this.unrelatedStations.length != 0 ? this.unrelatedStations : null;
	}

	/* Role management methods - START */
	searchUser(event){
		if(event.target.value !== ""){
			this.searching = true;
			this.userSearchParam = event.target.value;
		}else{
			this.searching = false;
			this.userSearchParam = '';
		}
	}

	handleChangeRole(event){
		this.setContactRoleDetail(event);
	}

	handleShowUsersWithoutRole(){
		this.showUsersWithNoRole = !this.showUsersWithNoRole;
	}

	async setContactRoleDetail(event) {
		try {
			let role = event.target.value;
			let contactId = event.target.dataset.contactid;
			await setRole({ roleType: role, contactId: contactId, stationId: this.stationId });
			this.refreshRoles();
		} catch(error) {
			util.debug.error('On role setting ', error);
		}
	}

	async handleDeleteRole(event){
		try {
			let contactId = event.target.dataset.contactid;
			await deleteRole({ stationId: this.stationId, contactId: contactId });
			this.refreshRoles();
		} catch(error) {
			util.debug.error('On role deletion ', error);
		}
	}

	refreshRoles(){
		// Delete search content and parameter's values
		this.searching = false;
		this.userSearchParam = '';
		this.searchedUser = null;

		refreshApex(this.usersInStationWiredResult);
	}
	/* Role management methods - END */


	/* Station relationship management methods - START */
	searchStation(event){
		if(event.target.value !== ""){
			this.searching = true;
			this.stationSearchParam = event.target.value;
		}else{
			this.searching = false;
			this.stationSearchParam = '';
		}
		getUnrelatedStations({ stationId: this.stationId, searchTerm: this.searching ? this.stationSearchParam : null}).then(data =>{
			this.setUnrelatedStations(data);
		});
	}

	async relationshipRequest(type, stationId, reqNotifications){
		await requestStationRelationship({ type:type, stationBaseId:this.stationId, stationObjId: stationId, requestNotifications: reqNotifications});
		// Update unrelated stations
		refreshApex(this.unrelatedStationsWiredResult);
	}

	requestChildRelationship(event){
		let selectedRelationshipRow = event.target.closest('.slds-row');
		let checkboxLightningInput = selectedRelationshipRow.querySelector('lightning-input');
		this.relationshipRequest(constants.ACCOUNT_ROLE_RELATIONSHIP.TYPE.VALUES.CHILD, event.target.dataset.stationid, checkboxLightningInput.checked);
	}

	requestGroupRelationship(event){
		let selectedRelationshipRow = event.target.closest('.slds-row');
		let checkboxLightningInput = selectedRelationshipRow.querySelector('lightning-input');
		this.relationshipRequest(constants.ACCOUNT_ROLE_RELATIONSHIP.TYPE.VALUES.GROUP, event.target.dataset.stationid, checkboxLightningInput.checked);
	}

	async deleteRelationship(event){
		await deleteRelationship({ relationshipId: event.target.dataset.relationshipid});
		// Update relationships and therefore related and unrelated station lists
		refreshApex(this.unrelatedStationsWiredResult);
		refreshApex(this.relatedStationsWiredResult);
	}

	acceptRelationship(event){
		const relationshipId = event.target.dataset.relationshipid;
		let acceptsNotifications = false;

		let selectedRelationshipRow = event.target.closest('.slds-row');
		let checkboxLightningInput = selectedRelationshipRow.querySelector('lightning-input');

		if(checkboxLightningInput !== null && relationshipId === checkboxLightningInput.dataset.relationshipid){
			acceptsNotifications = checkboxLightningInput.checked;
		}
		this.updateRelationshipStatus(constants.ACCOUNT_ROLE_RELATIONSHIP.STATUS.VALUES.ACTIVE, relationshipId, acceptsNotifications);
	}

	denyRelationship(event){
		this.updateRelationshipStatus(constants.ACCOUNT_ROLE_RELATIONSHIP.STATUS.VALUES.INACTIVE, event.target.dataset.relationshipid, false);
	}

	async updateRelationshipStatus(status, relationshipId, acceptsNotifications){
		await updateRelationshipStatus({relationshipId: relationshipId, status: status, acceptsNotifications: acceptsNotifications});
		// Update unrelated and related stations
		refreshApex(this.unrelatedStationsWiredResult);
		refreshApex(this.relatedStationsWiredResult);
	}
	/* Station relationship management methods - END */
}