import { LightningElement, api, track} from 'lwc';
import { resources, constants, util } from 'c/igUtility';

export default class IgNotificationsItem extends LightningElement {

    // Exposed properties

    @api notification;

    // Tracked properties

    @track showDetail = false;
    @track shownAsRead = false;

    // Internal properties

    resources = resources;

    // Main logic

    viewDetail(event) { 
        this.showDetail = !this.showDetail;
        if (this.showDetail && this.notification.notificationStatus === constants.NOTIFICATION.STATUS.VALUES.UNREAD) {
            this.markAsRead();
        }
    }

    markAsRead() {
        this.shownAsRead = true;
        this.dispatchEvent(new CustomEvent('read', {
            detail: this.notification.id
        }));
    }

    // Displayable properties

    get timeAgo() { 
        return util.date.humanizeSpan(this.notification.notificationDate);
    }
    get readableDate() { 
        return new Date(this.notificationDate).toLocaleString();
    }
    get toggleDetailText() {
        return this.showDetail ? 'Hide detail' : 'View detail';
    }

    // Logical properties

    get isInformative() { 
        return this.notification.severity === constants.NOTIFICATION.SEVERITY.VALUES.INFORMATIVE;
    }
    get isActionRequired() { 
        return this.notification.severity === constants.NOTIFICATION.SEVERITY.VALUES.ACTION_REQUIRED;
    }
    get isManual() { 
        return this.notification.severity === constants.NOTIFICATION.SEVERITY.VALUES.MANUAL;
    }
    get isRead() { 
        return this.shownAsRead || this.notification.notificationStatus !== constants.NOTIFICATION.STATUS.VALUES.UNREAD;
    }

    // Styling properties

    get mainLiClass() {
        let classes = [];
        if (this.isInformative) { 
            classes.push('blue-li');
        } else if (this.isActionRequired) { 
            classes.push('red-li');
        } else if (this.isManual) { 
            classes.push('yellow-li');
        }
        if (this.isRead) {
            classes.push('read');
        } else { 
            classes.push('unread');
        }
        return classes.join(' ');
    }
}