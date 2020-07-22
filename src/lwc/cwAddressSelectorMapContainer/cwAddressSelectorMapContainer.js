import { LightningElement, api, track, wire } from 'lwc';
import resources from '@salesforce/resourceUrl/ICG_Resources';
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";

export default class CwAddressSelectorMapContainer extends LightningElement {

	lcHost = window.location.hostname;
	vfHost;
	_urlGMap;
	@api addressText = 'carril de castell 17, 29016, Málaga';
	
	@track currentWith;
    @track currentHeight;
    @api width = '100%';
    @api height = '600px';
    @api collapsedWidth = '100%';
    @api collapsedHeight = '350px';
	@api collapsed;
    @api label;
    @api isInternalUser = false;
	initialized = false;
	constructed = false;
    collapsearrow = resources + '/icons/ic-collapse-sidebar--blue.svg';

	@wire(getURL, { page: 'URL_ICG_AddressSelectorMap' })
    wiredURLResultPage(result) {
        if (result.data) {
            this._urlGMap = result.data;
        }
	}

	renderedCallback(){
        if(!this.initialized){
            this.setCurrentHeight(); 
            this.initialized = true;
        }
    }

    get urlGMap(){
        return  this._urlGMap ? this.isInternalUser ? 'https://'+location.host+'/apex'+this._urlGMap.substring(this._urlGMap.lastIndexOf('/'), this._urlGMap.length) :  this._urlGMap.replace('/s','') : null;
    }
	
	sendToVF (loadMapScript, initMap = true) {
        //Prepare message in the format required in VF page
        var message = {
            "loadGoogleMap" : loadMapScript, 
			"initMap" : initMap,
			"initialAddress" : this.addressText        
		};
        //Send message to VF
        this.sendMessage(message);
    }

    sendMessage(message){
        //Send message to VF
        message.origin = window.location.hostname;
        let vfWindow = this.template.querySelector('[id*=vfFrame').contentWindow;
        if(vfWindow) vfWindow.postMessage(JSON.parse(JSON.stringify(message)), this.vfHost);
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
			}
			if(event.data && event.data.latitude){
				const geoEvent = new CustomEvent('setgeocoordinates', {
					detail: { 
						latitude : event.data.latitude,
						longitude : event.data.longitude
					}
				});
				this.dispatchEvent(geoEvent);
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