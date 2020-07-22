import { LightningElement, api, track, wire } from "lwc";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
export default class CwPrivateAreaMenuBar extends LightningElement {
    icons = resources + "/icons/";
    urlPublicArea;

    alertsandevents = this.icons + "ic-alerts-and-events.svg";
    facilitymanagement = this.icons + "ic-facility-management.svg";
    myrequest = this.icons + "ic-myrequest.svg";
    validationmanagement = this.icons + "ic-validation-management.svg";
    manageruserpermisions = this.icons + "ic-manage-user-permissions.svg";
    settings = this.icons + "ic-settings.svg";
    collapsearrow = this.icons + "ic-collapse-sidebar--blue.svg";
    menuclosed = this.icons + "ic-hamb-black--closed.svg";
    remotevalidation = this.icons + "ic-remote-validation-icon.svg";

    @api userInfo;
    @track mnuIsOpen = true;
    @api companyAdminSectionText;
    @api label;

    _selectedElement;
    @api
    get selectedElement() {
        return this._selectedElement;
    }
    set selectedElement(value) {
        let elem = this.template.querySelector('[data-action="' + value + '"]');
        if (elem) {
            this.setActiveCss(elem);
        } else {
            let baseClass = "pItem";
            let currentActiveItem = this.template.querySelector(
                '[class="' + baseClass + ' active"]'
            );

            if (currentActiveItem !== null) {
                currentActiveItem.className = baseClass;
            }
            this.setHash();
        }
        this._selectedElement = value;
    }

    @wire(getURL, { page: 'URL_ICG_Home' })
    wiredURLPublicArea({ data }) {
        if (data) {
            this.urlPublicArea = data;
        }
    }

    selectItem(event) {
        const selectedItemEvent = new CustomEvent("menuitemselection", {
            detail: event.currentTarget.dataset.action
        });

        // Dispatches the event.
        this.dispatchEvent(selectedItemEvent);

        //this.setActiveCss(event.target);
    }
    goToHome(event) {
        event.stopPropagation();
        event.preventDefault();
        this.dispatchEvent(new CustomEvent('gotohome'));
    }

    setActiveCss(target) {
        let baseClass = "pItem";
        let currentActiveItem = this.template.querySelector(
            '[class="' + baseClass + ' active"]'
        );

        if (currentActiveItem !== null) {
            currentActiveItem.className = baseClass;
        }

        target.className = baseClass + " active";
        this.setHash(target.dataset.action);
    }
    setHash(hashvalue) {
        window.location.hash = hashvalue ? hashvalue : 'home';
    }

    openNav(event) {
        this.mnuIsOpen = true;

        this.template.querySelector('[class="col-xl-10 col-lg-10 col-md-10 col-sm-10 overView"]').style.display = "";

        this.template.querySelector(
            '[class="collapsed col-md-12 sidebar-private-menu"]'
        ).className = "col-md-12 sidebar-private-menu";

        this.dispatchEvent(new CustomEvent("expandmenu"));
    }

    closeNav(event) {
        this.mnuIsOpen = false;

        let overview = this.template.querySelector('[class="col-xl-10 col-lg-10 col-md-10 col-sm-10 overView"]');
        overview.style.display = "none";

        let sidebar = this.template.querySelector('[class="col-md-12 sidebar-private-menu"]');
        sidebar.className = "collapsed col-md-12 sidebar-private-menu";

        this.dispatchEvent(new CustomEvent("collapsemenu"));
    }

    closeNavResp(event) {
        this.mnuIsOpen = false;

        let overview = this.template.querySelector('[class="col-md-12 sidebar-private-menu"]');
        overview.style.display = "none";
    }

    openNavResp(event) {
        this.mnuIsOpen = true;

        let overview = this.template.querySelector('[class="col-md-12 sidebar-private-menu"]');
        overview.style.display = "";
    }
    renderedCallback() {
        if (this._selectedElement) {
            this.selectedElement = this._selectedElement;
        }
    }
    goToPublicArea() {
        window.location.href = this.urlPublicArea;
    }
}