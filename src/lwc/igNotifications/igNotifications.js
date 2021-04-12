import { LightningElement, track, wire, api } from 'lwc';
import { constants, resources, util } from 'c/igUtility';
import { permissions } from 'c/igConstants';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { label } from 'c/igLabels';

import getPermissionsApex from '@salesforce/apex/IGOMPermissions.getPermissions';
import getNotifications from '@salesforce/apex/IGOMNotificationUtil.getNotifications';
import sendManualNotifications from '@salesforce/apex/IGOMNotificationUtil.sendManualNotifications';
import markAsRead from '@salesforce/apex/IGOMNotificationUtil.markAsRead';
import getOwnStations from '@salesforce/apex/IGOMStationUtil.getOwnStations';

export default class IgNotifications extends LightningElement {
	@track label = label;

    // Exposed properties
    @api stationId;

    // Tracked properties
    @track severityFilter = '';
    @track selectedAirlinesFilter = [];
    @track showFilters = false;
    @track showManualNotif = false;

    @wire(getNotifications, { stationId : '$stationId' })
    notifications;

    @wire(getOwnStations)
    ownStations;

    
    @wire(getPermissionsApex, { stationId: '$stationId' })
    userPermissions;

    // Internal properties

    resources = resources;
    constants = constants;

    // Main logic

    selectTab(event) {
        const clickedTab = event.target.closest('.notification-section');
        this.severityFilter = clickedTab.dataset.tab;
    }

    
    toggleAirlineFilters() {
        this.showFilters = !this.showFilters;
    }

    closeFilters() {
        this.showFilters = false;
    }
    
    addFilter(event) {
        event.stopPropagation();
        const divElement = event.target.closest('.form-check');
        const isFilterChecked = divElement.querySelector('input[type="checkbox"]').checked;
        const airlineId = divElement.dataset.id;
        if (!isFilterChecked) {
            const station = this.ownStations.data[airlineId];
            this.selectedAirlinesFilter.push(station);
        } else {
            const index = this.selectedAirlinesFilter.findIndex(station => station.id == airlineId);
            if (index > -1) {
                this.selectedAirlinesFilter.splice(index, 1);
            }
        }
    }

    deleteFilter(event) {
        event.stopPropagation();
        const itemToDeleteId = event.currentTarget.getAttribute('data-id');
        const index = this.selectedAirlinesFilter.findIndex(station => station.id == itemToDeleteId);
        if (index > -1) {
            this.selectedAirlinesFilter.splice(index, 1);
        }
    }

    removedPill(event) {
        event.stopPropagation();
    }

    showModalNotification(){
        this.template.querySelector('c-ig-modal.manual-notification-modal').show();
    }

    // Apex calls

    markAsReadEvent(event) {
        this.readNotification(event.detail);
    }

    async readNotification(id) {
        await markAsRead({
            notificationId: id
        });
        refreshApex(this.notifications);
    }

    async sendManualNotification(){
        const manualNotifElem = this.template.querySelector("c-ig-manual-notification");
        manualNotifElem.setLoading(true);
        const emailInfo = manualNotifElem.getNotificationInformation();
        var message;
        var variant = 'error';
        if(emailInfo.selectedUsers.length === 0){
            this.template.querySelector('c-ig-modal.manual-notification-modal').hide();
            manualNotifElem.setLoading(false);
            return;
        }

        var emptyFields = [];
        if(!emailInfo.subject){
            emptyFields.push('subject');
        }

        if(!emailInfo.body){
            emptyFields.push('body');
        }

        if(emptyFields.length > 0){
            manualNotifElem.markFieldsAsEmpty(emptyFields);
            manualNotifElem.setLoading(false);
            return;
        }

		try {
			await sendManualNotifications({ 
				stationId: this.stationId,
				contactDetailIds: emailInfo.selectedUsers, 
				subject: emailInfo.subject,
				body: emailInfo.body
			});
            message = 'Success';
            variant = 'success';
            manualNotifElem.setLoading(false);
		} catch (error) {
			util.debug.error(error);
            manualNotifElem.setLoading(false);
		}

        this.template.querySelector('c-ig-modal.manual-notification-modal').hide();
        const toastEv = new ShowToastEvent({
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toastEv);
    }

    // Logical properties

    get areNotificationsQueried() { 
        return this.notifications && this.notifications.data;
    }
    get notificationQuantity() { 
        return this.areNotificationsQueried ? this.notifications.data.length : '-';
    }
    get notificationActionRequiredQuantity() { 
        return this.areNotificationsQueried ? this.notifications.data.filter(noti => noti.severity === constants.NOTIFICATION.SEVERITY.VALUES.ACTION_REQUIRED).length : '-';
    }
    get notificationInformativeQuantity() { 
        return this.areNotificationsQueried ? this.notifications.data.filter(noti => noti.severity === constants.NOTIFICATION.SEVERITY.VALUES.INFORMATIVE).length : '-';
    }

    // Data properties

    get notificationsFiltered() {
        let notifications = this.notifications.data;
        // 1. Filter by severity
        if (this.severityFilter !== '') {
            notifications = notifications.filter(noti => noti.severity === this.severityFilter);
        }
        // 2. Filter by content
        if (this.selectedAirlinesFilter.length > 0) {
            const idFilters = this.selectedAirlinesFilter.map(airline => airline.accountRoleId);
            notifications = notifications.filter(noti => idFilters.includes(noti.accountRoleId));
        }
        return notifications;
    }

    get notifiedAirlines() {
        if (this.ownStations && this.ownStations.data && this.notifications && this.notifications.data) {
            const notifiableAirlines = Object.values(this.ownStations.data).filter(station => this.notifications.data.some(noti => noti.accountRoleId === station.accountRoleId));
            return notifiableAirlines.map(airline => ({...airline, checked: this.selectedAirlinesFilter.some(filter => filter.id === airline.id)}));
        }
        return [];
    }

    // Style properties

    get tabAllClass() { 
        let classes = ['notification-section'];
        if (this.severityFilter === '') { 
            classes.push('notification-selected');
        }
        return classes.join(' ');
    }
    get tabActionRequiredClass() { 
        let classes = ['notification-section'];
        if (this.severityFilter === constants.NOTIFICATION.SEVERITY.VALUES.ACTION_REQUIRED) { 
            classes.push('notification-selected');
        }
        return classes.join(' ');
    }
    get tabInformativeClass() { 
        let classes = ['notification-section'];
        if (this.severityFilter === constants.NOTIFICATION.SEVERITY.VALUES.INFORMATIVE) { 
            classes.push('notification-selected');
        }
        return classes.join(' ');
    }
    get tabButtonClass() { 
        let classes = ['button-section'];
        return classes.join(' ');
    }
    get filterAirlineClass() { 
        let classes = ['filters-airline'];
        if (!this.showFilters) { 
            classes.push('hidden');
        }
        return classes.join(' ');
    }
    get placeHolderInputFilters() {
        return this.selectedAirlinesFilter.length === 0 ? 'Filter by airline' : '';
    }
    get isVisibleManualNotifications() {
        return this.userPermissions.data && this.userPermissions.data[permissions.NOTIFY_GAP];
    }
}