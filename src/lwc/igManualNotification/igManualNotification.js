import { LightningElement, api, track, wire } from 'lwc';
import { constants, util } from 'c/igUtility';
import { label } from 'c/igLabels';
import getStationNotifiableContacts from '@salesforce/apex/IGOMNotificationUtil.getStationNotifiableContacts';

const notifiableTableColumns = [
    { label: 'Name', fieldName: 'fullname' },
    { label: 'Station', fieldName: 'stationName' },
    { label: 'Role', fieldName: 'origin' }
];

export default class IgManualNotification extends LightningElement {
	@track label = label;

    @api stationId;

    @track _notifiableUsersInform;
    @track subject;
    @track body;

    @wire(getStationNotifiableContacts, { stationId: '$stationId', notificationType: constants.NOTIFICATION.SEVERITY.VALUES.INFORMATIVE })
    getStationNotifiableContactsInformative({ data, error }) {
        console.log('Data ' + JSON.stringify(data));
        if (data) {
            this._notifiableUsersInform = {
                data: Object.values(data),
                columns: notifiableTableColumns
            };
        }
	}

    newFilenameKeyUp(event) {
        this.subject = event.target.value;
        console.log('Subject ' + this.subject);
    }
    
    debouncedNotificationBodyUpdate = util.debounce((info) => {
        this.body = info.value;
    }, 100);

    notificationBodyUpdate(event) {
        this.debouncedNotificationBodyUpdate({
            value : event.target.value
        });
    }
}