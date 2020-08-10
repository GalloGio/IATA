import { LightningElement,track } from 'lwc';

import getRecomendationDetails from '@salesforce/apex/PortalRecommendationCtrl.getRecomendationDetails';
 
export default class PortalContentHeaderImg extends LightningElement {
    
    @track page='FeaturedService';
    @track showWhite=true;
    @track serviceTitle;

    connectedCallback(){
        let contentName =location.pathname.substring(location.pathname.lastIndexOf("/") + 1);

        getRecomendationDetails({urlName:contentName})
        .then(result=>{
            this.serviceTitle=result.RecommendationTitle__c;
        })
        .catch(Error=>{
			 this.serviceTitle='';
        });

    }

}