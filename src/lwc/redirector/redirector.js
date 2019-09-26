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
            let xhr = new XMLHttpRequest();

            xhr.open('GET', 'https://api.ipify.org?format=jsonp='); // returns user Ip Address
            xhr.send();

            xhr.onload = function() {
                if (xhr.status == 200) { //             
                    redirectToLoginPage({ 
                        servicename: this.serviceName, 
                        startUrl: null,
                        retURL: '',
                        communityName:com.communityName,
                        ipAddress:xhr.response
                     })
                        .then(link => {
                                window.open(link,'_top');
                        });
                }
            };
        
        
    }
    


}