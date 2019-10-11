// import { LightningElement } from 'lwc';
import { LightningElement, track, wire, api } from 'lwc';
//api
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import demoFiles from '@salesforce/resourceUrl/demo_resource';
import getMoreInfo from '@salesforce/apex/CW_SearchResultController.getMoreInfo';

export default class CwSearchResult extends LightningElement {
    
    searchbylocation = demoFiles + '/demo_resource/search-by-location.svg';

    @track moreInfo;
    //+ apis para pasar variables
    @api input;

    @wire(getMoreInfo, {})
    wiredLocations({ data }) {
        if (data) {
            this.moreInfo = JSON.parse(data);
        }
    }

    

    handleCompare() {
        // eslint-disable-next-line no-console
        console.log('handleCompare, incoming next sprint');
    }
    handleMoreInfo() {
        // eslint-disable-next-line no-console
        console.log('handleMoreInfo, incoming next sprint');
    }
}