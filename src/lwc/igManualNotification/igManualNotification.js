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
    @track _loading = false;

    @wire(getStationNotifiableContacts, { stationId: '$stationId', notificationType: constants.NOTIFICATION.SEVERITY.VALUES.MANUAL })
    getStationNotifiableContactsInformative({ data, error }) {
        if (data) {
            this._notifiableUsersInform = {
                data: Object.values(data),
                columns: notifiableTableColumns
            };
        }
	}
    
    debouncedNotificationSubjectUpdate = util.debounce((info) => {
        this.subject = info.value;
    }, 100);
    debouncedNotificationBodyUpdate = util.debounce((info) => {
        this.body = info.value;
    }, 100);


    notificationSubjectUpdate(event) {
        event.target.setCustomValidity('');
        this.debouncedNotificationSubjectUpdate({
            value : event.target.value
        });
    }

    notificationBodyUpdate(event) {
        event.target.setCustomValidity('');
        this.debouncedNotificationBodyUpdate({
            value : event.target.value
        });
    }

    get isLoading(){
        return this._loading;
    }

    @api getNotificationInformation(){
        const usersDataTableInfo = this.template.querySelector('[data-name="users-to-notify-informative"]');
        var selectedInfoUserIds;
        if(usersDataTableInfo){
            selectedInfoUserIds = usersDataTableInfo.getSelectedRows().map(row => row.contactId);
        }
        
        //Clear user selection
        usersDataTableInfo.selectedRows=[];
        return {
            selectedUsers: selectedInfoUserIds,
            subject: this.subject,
            body: this.body
        }
    }

    @api markFieldsAsEmpty(fields){
        for (var i = 0; i < fields.length; i++) {
            let targetId = fields[i];
            let target = this.template.querySelector('[data-id="' + targetId + '"]');
            target.setCustomValidity(this.label.custom.ig_blank_field);
            target.reportValidity();
        }
        this._loading = false;
    }

    @api setLoading(isLoading){
        this._loading = isLoading;
        if(!this._loading){
            this.subject = null;
            this.body = null;
        }
    }
}