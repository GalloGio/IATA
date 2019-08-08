/**
 * Created by pvavruska on 5/27/2019.
 */

import { LightningElement, api, track } from 'lwc';

export default class PortalCompanyProfileInfoNav extends LightningElement {

    @api navItems;
    @api
    get activesection() {
        return this._activesection;
    }

    set activesection(value) {
        this._activesection = value;
        this.selectSection(value);
    }

    selectSection(selectedItem) {
        let navItems = this.navItems;
        let newItems = [];

        navItems.forEach(function (item) {
            let newItem = { label: item.label, value: item.value, open: false };

            if (selectedItem === item.value) {
                newItem.class = 'selectedItem';
                newItem.open = true;
            }

            newItems.push(newItem);
        });

        this.navItems = [];
        this.navItems = newItems;
    }

    itemSelected(event) {
        let selectedItem = event.target.attributes.getNamedItem('data-item').value;
        this.selectSection(selectedItem);
        this.dispatchEvent(new CustomEvent('navigate',{detail: selectedItem}));

    }
}