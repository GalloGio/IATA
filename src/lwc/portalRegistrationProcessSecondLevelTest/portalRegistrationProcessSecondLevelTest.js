/**
 * Created by mmercier on 26.08.2019.
 */

import { LightningElement, track, wire, api} from 'lwc';
import getContactInfo                   from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactInfo';

export default class PortalRegistrationProcessSecondLevelTest extends LightningElement {

    @track openRegistrationModal = false;
    @track contactInfo;
    @track contactFound;

    connectedCallback() {

        // Retrieve Contact information
        getContactInfo()
            .then(result => {
                this.contactInfo = result;
                this.contactFound = this.contactInfo != null;

                if(!this.contactFound){
                    return;
                }
            })
            .catch((error) => {
                alert("Error in getContactInfo : " + error.body.message);
            });
    }

    openSecondLevelRegistration(event){
        this.openRegistrationModal = true;
    }

    closeSecondLevelRegistration(event){
        this.openRegistrationModal = false;
    }
}