import { LightningElement, wire, api } from 'lwc';
import { resources, util } from 'c/igUtility';
import { constants, permissions } from 'c/igConstants';
import getUserData from '@salesforce/apex/IGOMCommunityUtil.getUserData';
import getOwnStations from '@salesforce/apex/IGOMStationUtil.getOwnStations';
import getNotifications from '@salesforce/apex/IGOMNotificationUtil.getNotifications';
import getPermissionsApex from '@salesforce/apex/IGOMPermissions.getPermissions';

export default class IgUserMenu extends LightningElement {

    @api activeStationId;

    resources = resources;
    stationList;

    @wire(getNotifications, { stationId : '$activeStationId' })
    notifications;

    @wire(getPermissionsApex)
    permissions;

    @wire(getUserData)
    userData;

    @wire(getOwnStations)
    getOwnStationsWired({ data, error }) {
        if (data) {
            this.stationList = Object.values(data);
        }
    }

    onStationChange(event) {
        const select = event.target;
        const stationChangeEvent = new CustomEvent('stationchange', {
            detail: {
                stationId: select.value
            }
        });
        this.dispatchEvent(stationChangeEvent);
    }

    renderCurrentStation() {
        if (this.template) {
            const selectDocument = this.template.querySelector('select[data-field="document"]');
            if (selectDocument) {
                selectDocument.value = this.activeStationId;
            }
        }
    }

    renderedCallback() {
        this.renderCurrentStation();
    }

    gotoNotifications() {
        const selectedItemEvent = new CustomEvent('menuitemselection', {
            detail: {
                itemName: 'Notifications',
                automatic: true
            }
        });
        this.dispatchEvent(selectedItemEvent);
    }

    get hasUnreadNotifications() {
        return this.notifications && this.notifications.data && this.notifications.data.some(notification => notification.notificationStatus === constants.NOTIFICATION.STATUS.VALUES.UNREAD);
    }

    get notificationCount() {
        return this.hasUnreadNotifications ? this.notifications.data.filter(notification => notification.notificationStatus === constants.NOTIFICATION.STATUS.VALUES.UNREAD).length : undefined;
    }

    get hasNotificationsPermission() {
        return this.permissions && this.permissions.data && this.permissions.data[permissions.CHECK_NOTIFICATIONS];
    }
    
}