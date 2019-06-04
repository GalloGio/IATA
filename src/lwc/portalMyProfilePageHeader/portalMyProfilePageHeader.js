import { LightningElement, track } from 'lwc';

//Contact Apex Methods
import getContactDetails from '@salesforce/apex/PortalMyProfileCtrl.getContactInfo';

export default class PortalProfilePageHeader extends LightningElement {

    backgroundIcon = '/csportal/s/unsplash.jpeg';

    //Loading && Error
    @track loading = false;
    @track backgroundStyle;
    @track profileDivStyle;
    @track iconLink;
    @track error;

    @track contact = {};


    connectedCallback() {
        this.backgroundStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:170px;'
        this.profileDivStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:170px; width: 196px; height: 196px; position: absolute; top: 72px; left: 32px; border-radius: 50%;  box-shadow: 0px 1px 12px 0px #827f7f; background-color:white;';

        getContactDetails().then(result => {
            //because proxy..
            let resultsAux = JSON.parse(JSON.stringify(result));
            this.contact = resultsAux;
            this.loading = false;
        })
        .catch(error => {
            console.log('PortalFAQPageHeader connectedCallback getCategoryTiles error: ' , error);
            this.loading = false;
        });
        
    }

}