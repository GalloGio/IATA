import { LightningElement,track } from 'lwc';
 
export default class PortalGiveFeedback extends LightningElement {

    @track isExpanded=false;


    expandCmp(){
        this.isExpanded=true;
    }
}