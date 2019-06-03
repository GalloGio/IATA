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

        console.log('navigateTo '+selectedItem);
        this.dispatchEvent(new CustomEvent('navigate',{detail: selectedItem}));
        //document.querySelector(`[data-id="${selectedItem}"]`).scrollIntoView();
       // this.template.querySelector(`[data-id="Basics"]`).scrollIntoView();
        
        //console.log('BLA: ' , this.template.querySelectorAll() );

        //console.log('After querySelectorAll');

    }
    /*
        set activesection(val){
            console.log('setting active session: '+val);
        }
    */

    connectedCallback() {


        if (false) {//if(this.navItems == null || this.navItems.length == 0){
            let navItems = [];
            navItems.push({ label: 'Basics', value: 'Basic', open: true, class: 'selectedItem' });
            navItems.push({ label: 'Company Contact', value: 'CompanyContact', open: false });
            this.navItems = navItems;
        }

    }

}