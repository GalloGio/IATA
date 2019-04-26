import { LightningElement,api } from 'lwc';
import getDirectionLink from '@salesforce/apex/OneIdUtils.getCommunityRedirection';
import redirectToLoginPage from '@salesforce/apex/csp_redirectorController.redirectToLogin';
import { getParamsFromPage } from'c/navigationUtils';
    

export default class Redirector extends LightningElement {
    @api serviceName;
    @api startUrl;    
    @api community;    
    
    renderedCallback(){

        let com=getParamsFromPage();
        console.log(com);
        
        redirectToLoginPage({ 
            servicename: this.serviceName, 
            startUrl: null,
            retURL: '',
            communityName:com.communityName
         })
            .then(link => {
                    console.log(link);
                    window.open(link,'_top');
            });
    }
    


}