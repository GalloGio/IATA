import { LightningElement, api } from 'lwc';
export default class PortalMfaActivationQrCode extends LightningElement {
    @api qrCode;
	@api secret;
    @api translations;
    @api isPadded = false;

	/* HTML attributes - START */

    get orClass(){
        return "slds-col slds-size_1-of-6 absolute-center";
    }

    get qrCodeImgSource(){
        if(!this.qrCode){
            this.qrCode = window.location.href;
        }else{
            this.qrCode = this.qrCode.replace('w=200', 'w=1200');
            this.qrCode = this.qrCode.replace('h=200', 'h=1200');
        }
        return this.qrCode;
    }

    get labels(){
        return this.translations;
    }
	/* HTML attributes - END */
}