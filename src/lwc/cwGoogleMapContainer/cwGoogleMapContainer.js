import { LightningElement, api,track,wire } from 'lwc';
import resources from '@salesforce/resourceUrl/ICG_Resources';
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";

export default class GoogleMapContainer extends LightningElement {
    lcHost = window.location.hostname;
    vfHost;
    @api label;
    @api mapOptions; 
    @api mapOptionsCenter;
    @track _mapData;
    @track _companyTypeFilter;
    @track urlGMap;
    constructed = false;
    collapsearrow = resources + '/icons/ic-collapse-sidebar--blue.svg';

    @wire(getURL, { page: 'URL_ICG_GoogleMaps' })
    wiredURLResultPage({ data }) {
        if (data) {
            this.urlGMap = data.replace('/s','');
        }
    }

    @api
    get mapData(){
        return this._mapData;
    }
    set mapData(value){
        this._mapData = value;
        if(this.constructed)this.sendToVF(false);
    }
    @api
    get companyTypeFilter(){
        return this._companyTypeFilter;
    }
    set companyTypeFilter(value){
        this._companyTypeFilter = value;
        if(this.constructed)this.sendToVF(false);
    }

    @track currentWith;
    @track currentHeight;
    @api width = '100%';
    @api height = '600px';
    @api collapsedWidth = '100%';
    @api collapsedHeight = '350px';
    @api collapsed;
    initialized = false;

    renderedCallback(){
        if(!this.initialized){
            this.setCurrentHeight(); 
            this.initialized = true;
        }
    }

    sendToVF (loadMapScript, initMap = true) {
        //Prepare message in the format required in VF page
        var message = {
            "loadGoogleMap" : loadMapScript, 
            "mapData": this.mapData, 
            "mapOptions": this.mapOptions,  
            "mapOptionsCenter": this.mapOptionsCenter,
            "isCollapsed" : this.collapsed,
            "initMap" : initMap,
            "companyTypeFilter" : this.companyTypeFilter && this.companyTypeFilter !== 'All' ? this.companyTypeFilter : null
        } ;
        //Send message to VF
        this.sendMessage(message);
    }

    sendMessage(message){
        //Send message to VF
        message.origin = window.location.hostname;
        let vfWindow = this.template.querySelector('[id*=vfFrame').contentWindow;
        vfWindow.postMessage(JSON.parse(JSON.stringify(message)), this.vfHost);
    }
    constructor(){
        super();
        window.addEventListener("message", event => {
            //Can enable origin control for more security
            //if (event.origin != vfOrigin) {
                // Not the expected origin: Reject the message!
                //return;
            //}
            // Handle the message
            if(event.data && event.data.state === 'LOADED'){
                //Set vfHost which will be used later to send message
                this.vfHost = event.data.vfHost;
                
                //Send data to VF page to draw map
                this.sendToVF(true);
                this.constructed = true;
            }else if (event.data.filterByLatLong){
                this.dispatchEvent( new CustomEvent('filterbylatlong',{detail: JSON.stringify(event.data)}));
            }
        }, false);
    }

    get iframeurl () {
        return this.urlGMap + '?lcHost=' + this.lcHost;
    }

    modifyHeight(){
        if(!this.collapsed || this.collapsed === 'false') this.collapsed = true;
        else this.collapsed = false;
        this.setCurrentHeight(); 
    }

    setCurrentHeight(){
        if(!this.collapsed || this.collapsed === 'false'){
            this.currentHeight = this.height;
            this.currentWith = this.width;
        }else{
            this.currentHeight = this.collapsedHeight;
            this.currentWith = this.collapsedWidth;
        }

        if(this.initialized) this.sendToVF(false, false);
    }

    get arrowStyle(){
        let style;
        if(!this.collapsed || this.collapsed === 'false'){
            style= 'rotate90';
        }else{
            style= 'rotate-90';
        }
        return style;
        
    }

    
}