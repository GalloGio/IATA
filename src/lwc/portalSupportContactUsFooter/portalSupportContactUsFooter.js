import { LightningElement,api,track } from 'lwc';
 
export default class PortalSupportContactUsFooter extends LightningElement {

    @track _topic;

    @api 
    get topic(){
        return this._topic;
    }
    set topic(val){
        this._topic=val;
    }

    get showGiveFeedback(){
        return this._topic!=null;
    }
    connectedCallback(){
        console.log('done');
    }



}