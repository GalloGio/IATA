import { LightningElement, api, track, wire } from 'lwc';
import resources from '@salesforce/resourceUrl/ICG_Resources';
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CwAddressSelectorMapContainer extends LightningElement {

	lcHost = window.location.hostname;
	vfHost;
	_urlGMap;
	@api addressText = '';
	
	@track currentWith;
	@track currentHeight;
	@api width = '100%';
	@api height = '600px';
	@api addressGeo;
	@api collapsedWidth = '100%';
	@api collapsedHeight = '350px';
	@api collapsed;
	@api label;
	@api isInternalUser = false;
	@api shouldHideExpandBtn = false;
	@api shouldShowEditBtn = false;
	@api editMode;
	@track draggable = false;
	initialized = false;
	constructed = false;
	collapsearrow = resources + '/icons/ic-collapse-sidebar--blue.svg';

	get shouldDisplayEditButtons(){
		return this.shouldShowEditBtn && this.editMode;
	}

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
			if(!this.shouldHideExpandBtn){
				this.draggable = true;
			}
		}
	}

	get urlGMap(){
		return  this._urlGMap ? this.isInternalUser ? this.label.icg_https_default_value + location.host+'/apex'+this._urlGMap.substring(this._urlGMap.lastIndexOf('/'), this._urlGMap.length) :  this._urlGMap.replace('/s','') : null;
	}

	prepareForEdit(){
		this.draggable = true;
		this.sendToVF(false, false);
		
		const event = new ShowToastEvent({
			title: 'Information',
			message: 'If the address of the station is not located where the map indicates, please drag the marker to the right place.\nThis will not update the address itself but the geocoordinates of the station.',
			variant: 'Informational',
			mode: 'sticky'
		});
		this.dispatchEvent(event);
	}

	removeEditOption(){
		this.draggable = false;
		this.sendToVF(false, true);
	}
	
	sendToVF (loadMapScript, initialization, initMap = true) {
		//Prepare message in the format required in VF page
		var message = {
			"loadGoogleMap" : loadMapScript, 
			"initMap" : initMap,
			"initialAddress" : this.addressText,
			"draggable": this.draggable,
			"initialization": initialization,
			"initialGeo": this.addressGeo
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
				this.sendToVF(true, true);
				this.constructed = true;
			}
			if(event.data && event.data.latitude){
				const geoEvent = new CustomEvent('setgeocoordinates', {
					detail: { 
						latitude : event.data.latitude,
						longitude : event.data.longitude,
						initialization: event.data.initialization
					}
				});
				this.dispatchEvent(geoEvent);
			}
		}, false);
	}

	get iframeurl () {
		return this.urlGMap ? this.urlGMap + '?lcHost=' + this.lcHost : '';
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

		if(this.initialized) this.sendToVF(false, true, false);
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