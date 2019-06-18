import { LightningElement, track } from 'lwc';

//import labels
import CSP_FAQ_HeaderTitle from '@salesforce/label/c.CSP_FAQ_HeaderTitle';

//import navigation methods
import { NavigationMixin } from 'lightning/navigation';
import { getParamsFromPage } from'c/navigationUtils';

import getCategoryTiles from '@salesforce/apex/PortalFAQsCtrl.getCategoryTiles';

export default class PortalFAQPageHeader extends NavigationMixin(LightningElement) {

    label = {
        CSP_FAQ_HeaderTitle
    };

    //links for images
    backgroundIcon = '/csportal/s/CSPortal/Images/Backgrounds/ControlTower.jpg';

    @track iconLink;

    @track category = '';

    @track backgroundStyle;
    @track secondbackground;

    connectedCallback() {
        this.backgroundStyle = 'background-color:#1e32fa;background-size: cover;height:184px;';
        this.secondbackground = 'opacity: 0.1;background-image: linear-gradient(256deg, rgba(0, 0, 0, 0), #000000);'


        //get the parameters for this page
        this.pageParams = getParamsFromPage();

        if(this.pageParams.category !== undefined && this.pageParams.category !== ''){
            //this.category = this.pageParams.category;

            getCategoryTiles({})
            .then(results => {
                //because proxy.......
                let resultsAux = JSON.parse(JSON.stringify(results));

                if(resultsAux !== undefined && resultsAux !== null && resultsAux.length > 0){
                    let i;
                    for(i = 0; i < resultsAux.length; i++){
                        if(resultsAux[i].categoryName === this.pageParams.category){
                            this.category = resultsAux[i].categoryLabel;
                            this.iconLink = '/csportal/s/CSPortal/Images/FAQ/' + this.pageParams.category + '.svg';
                            break;
                        }
                    }
                    this.lstTiles = resultsAux;
                }
            })
            .catch(error => {
                console.log('PortalFAQPageHeader connectedCallback getCategoryTiles error: ' , error);
            });



        }


    }

}