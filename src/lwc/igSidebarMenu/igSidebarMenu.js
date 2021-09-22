import { LightningElement, api, wire, track} from 'lwc';
import { util, resources } from 'c/igUtility';
import { permissions } from 'c/igConstants';
import { label } from 'c/igLabels';
import getPermissionsApex from '@salesforce/apex/IGOMPermissions.getPermissions';

export default class IgSidebarMenu extends LightningElement {
    
    @track label = label;

    // Exposed properties
    @api stationId;

    // Internal properties
    resources = resources;
    autoselectFirstItem = true;
    @track permissions;

    // Main logic
    selectItem(event) {
        const menuItem = event.target.closest('.sidebar-item');
        const selectedItemEvent = new CustomEvent('menuitemselection', {
            detail: {
                itemName: menuItem.dataset.action,
                automatic: false
            }
        });
        this.dispatchEvent(selectedItemEvent);
    }

    @wire(getPermissionsApex, { stationId: '$stationId' })
    getPermissionsApexWired({ data, error }) {
        if (data) {
            this.permissions = data;
            if (this.autoselectFirstItem) {
                this.autoselectFirstItem = false;
                const selectedItemEvent = new CustomEvent('menuitemselection', {
                    detail: {
                        itemName: this.firstVisibleMenu,
                        automatic: true
                    }
                });
                this.dispatchEvent(selectedItemEvent);
            }
        }
    }

    // Logical properties
    get firstVisibleMenu() {
        if (this.isVisibleMenuDashboard) {
            return 'Dashboard';
        } else if (this.isVisibleMenuGAPAnalysis) {
            return 'GAP Analysis';
        } else if (this.isVisibleMenuNotifications) {
            return 'Notifications';
        } else if (this.isVisibleMenuVariationReport) {
            return 'Variation report';
        } else if (this.isVisibleMenuIGOMDocumentDescription) {
            return 'IGOM Document Description';
        } else if (this.isVisibleMenuStationAdministration) {
            return 'Station administration';
        }
        return;
    }
    get isVisibleMenuDashboard() {
        return this.permissions && 
                (this.permissions[permissions.VIEW_ALL_DASHBOARD] ||
                 this.permissions[permissions.VIEW_OWN_DASHBOARD]);
    }
    get isVisibleMenuGAPAnalysis() {
        return this.permissions && 
                (this.permissions[permissions.CREATE_GAP] ||
                 this.permissions[permissions.EDIT_GAP]);
    }
    get isVisibleMenuNotifications() {
        return this.permissions && this.permissions[permissions.CHECK_NOTIFICATIONS];
    }
    get isVisibleMenuVariationReport() {
        return this.permissions && 
                (this.permissions[permissions.VIEW_ALL_VARIATIONS] ||
                 this.permissions[permissions.VIEW_OWN_VARIATIONS]);
    }
    get isVisibleMenuIGOMDocumentDescription() {
        return this.permissions && 
                (this.permissions[permissions.VIEW_LAST_MANUAL] ||
                 this.permissions[permissions.VIEW_ALL_MANUALS] ||
                 this.permissions[permissions.UPLOAD_MANUAL]);
    }
    get isVisibleMenuStationAdministration() {
        return this.permissions && this.permissions[permissions.MANAGE_STATION];
    }
}