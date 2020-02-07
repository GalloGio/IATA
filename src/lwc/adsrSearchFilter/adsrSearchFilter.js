import { LightningElement, track, wire } from 'lwc';
import getRegions from '@salesforce/apex/ADSRController.getRegions';
import getMarkets from '@salesforce/apex/ADSRController.getMarkets';
import getAgents from '@salesforce/apex/ADSRController.getAgents';

export default class AdsrSearchFilter extends LightningElement {

    @track regionValue = null;
    @track marketsValue = [];
    @track agentValue = null;
    @track activeSearchType = 'market';

    @track regionOptions = [];
    @track marketOptions = [];

    @wire(getRegions)
    wiredRegionOptions({ error, data }) {
        if(data){
            this.regionOptions = data;
        }
        else {
            this.regionOptions = [];
        }
    }

    get searchByOptions() {
        return [
            { label: 'Market', value: 'market' },
            { label: 'Agent', value: 'agent' }
        ];
    }

    handleChange(event) {
        if("region" === event.target.name){
            this.regionValue = event.detail.value;
            this.marketsValue = [];
            getMarkets({region: this.regionValue})
                .then(data => {
                    this.marketOptions = data;
                })
                .catch(error => {
                    this.marketOptions = [];
                }
            );
        }
        else if("searchBy" === event.target.name){
            this.activeSearchType = event.detail.value;
        }
        /*else if("markets" === event.target.name){
            this.marketsValue = event.detail.value;
        }*/
        else if("agent" === event.target.name){
            this.agentValue = event.detail.value;
        }
    }

    handleSearch(event){
        console.log('search')
        console.log(JSON.parse(JSON.stringify(event.detail)));
    }

    get disabledMarkets(){
        return this.marketOptions === undefined || this.marketOptions === null || this.marketOptions.length === 0 || this.activeSearchType !== "market";
    }

    get disabledAgent(){
        return this.activeSearchType !== "agent";
    }

}