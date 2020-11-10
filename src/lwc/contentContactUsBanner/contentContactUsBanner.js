import { LightningElement,track } from 'lwc';
import getRecomendationDetails  from '@salesforce/apex/PortalRecommendationCtrl.getRecomendationDetails';
 
export default class ContentContactUsBanner extends LightningElement {


    @track renderCmp=false;

    connectedCallback() {
        let reco=window.location.pathname.substring(location.pathname.lastIndexOf("/") + 1);

        getRecomendationDetails({urlName:reco}).then(val=>{           
            this.renderCmp=val.Is_More_Info_Banner_Visible__c;
        });

    }

}