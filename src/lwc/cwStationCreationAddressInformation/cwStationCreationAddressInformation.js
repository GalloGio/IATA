import { LightningElement,track,api } from 'lwc';

export default class CwStationCreationAddressInformation extends LightningElement {

    // inputs
    @api account;
    @api address;
    @api addressSuggestions;
    @api countryId;
    @api label;

	@track localAddress;
	@track nextButtonLabel = 'Next Step / Station Information';

    // flag to enable/disable the "Next Step / Confirmation" button
    @track isConfirmationButtonDisabled;

    connectedCallback() {
        this.localAddress = JSON.parse(JSON.stringify(this.address));
        this.dispatchEvent(new CustomEvent('scrolltotop'));
    }

    goBack(){
        this.dispatchEvent(new CustomEvent('back'));
    }

    goNext(){
        this.dispatchEvent(new CustomEvent('next'));
    }

    setValidationStatus(event){
		this.getAddressInformation();
		this.nextButtonLabel = 'Next Step / Station Information';
		if(this.countryId !== this.localAddress.countryId){
			this.localAddress.countryId = this.countryId;
			this.isConfirmationButtonDisabled = true;
			this.nextButtonLabel = 'Country cannot be modified';
		}else{
			if(this.isConfirmationButtonDisabled !== !event.detail){
				this.isConfirmationButtonDisabled = !event.detail;
			}
		}
		this.dispatchEvent(new CustomEvent('completionstatus',{detail : !this.isConfirmationButtonDisabled}));
        
    }

    startLoading(){
        this.dispatchEvent(new CustomEvent('startloading'));
    }

    stopLoading(){
        this.dispatchEvent(new CustomEvent('stoploading'));
    }

    @api
    getAddressInformation(){
        let addressInformation = this.template.querySelector('c-portal-address-form').getAddressInformation();
        this.localAddress = JSON.parse(JSON.stringify(addressInformation));

        return this.localAddress;
    }
}