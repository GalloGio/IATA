import { LightningElement, track } from 'lwc';

import getFavoriteServicesList from '@salesforce/apex/PortalServicesCtrl.getFavoriteServicesList';
import goToOldPortalService from '@salesforce/apex/PortalServicesCtrl.goToOldPortalService';
import { updateRecord } from 'lightning/uiRecordApi';

//Navigation
import { navigateToPage } from'c/navigationUtils';

//import labels 
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import csp_Request_New_Service from '@salesforce/label/c.csp_Request_New_Service';

export default class FavoriteServicesLWC extends LightningElement {
    //track variables

    @track maxSize;
    @track showPagination;
    @track sliderIcons;

    @track isLoading = true;

    //global variables
    page = 1;
    globaList;
    favoriteServices;
    auxResult;

    // Expose the labels to use in the template.
    label = {
        csp_Request_New_Service,
        CSP_SeeAll
    };

    //Same as doInit() function on old aura components
    connectedCallback() {

        /* @salesforce/apex/PortalServicesCtrl.getUserServicesList' (shared apex code)
        *  getUserServicesList grabs the Services of the Contact logged in on the portal and stores on the result
        */
        getFavoriteServicesList()
            .then(result => {
                //auxResult stores the results globaly
                this.auxResult = JSON.parse(JSON.stringify(result));
                
                //removes undefined from images
                for (let i = 0; i < this.auxResult.length; i++) {
                    if(this.auxResult[i].Portal_Application__r === undefined || this.auxResult[i].Portal_Application__r.Application_icon_URL__c === undefined){
                        this.auxResult[i].Portal_Application__r.Application_icon_URL__c = '';
                    }
                }


                //Inverts returned List in order to keep the unrequestable links
                //Slices the List in 15 members as a limit (3 pages with 5 tiles each)                
                this.auxResult = this.auxResult.reverse().slice(0, 16);

                //Inverts the list again so the external links go to the end of the list.
                this.auxResult = this.auxResult.reverse();

                //builds the pages collumns and rows/tiles
                this.pageTileBuilder();

                //adds css too all the tiles
                this.pageTileCssBuilder();

                //sets the first page
                this.favoriteServices = this.globaList[0];

                //the maxSize of the List
                this.maxSize = this.globaList.length;

                //show pagination if the number of pages is greater than 1
                this.showPagination = this.maxSize > 1 ? true : false;
                if (this.showPagination) {
                    this.sliderIconsRenderer();
                }

                //stop the spinner.
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
            });
    }

    //method that adds css to the tiles. Tiles can be bigTiles or smallTiles
    pageTileCssBuilder() {
        for (let i = 0; i < this.globaList.length; i++) {
            for (let j = 0; j < this.globaList[i].length; j++) {
                for (let k = 0; k < this.globaList[i][j].length; k++) {
                    if (this.globaList[i][j].length === 1) {
                        this.globaList[i][j][k].myclass = 'withPointerTile bigTile slds-m-vertical_x-small aroundLightGrayBorder';
                    }
                    if (this.globaList[i][j].length === 2) {
                        this.globaList[i][j][k].myclass = 'withPointerTile smallTile slds-m-vertical_x-small aroundLightGrayBorder';
                    }
                }
            }
        }
    }

    //method that builds the Tile Pages according to the number of elements of the list
    pageTileBuilder() {
        let counter = 0;
        this.globaList = [];
        let pageListAux = [];
        this.favoriteServices = [];

        for (let i = 0; i < this.auxResult.length; i++) {

            this.auxResult[i].extIconClass = 'slds-current-color extIconClass';
            if (!this.auxResult[i].Portal_Application__r.New_Window__c) {
                this.auxResult[i].extIconClass = 'slds-current-color noExtIconClass';
            }

            pageListAux.push(this.auxResult[i]);
            counter++;

            if (counter === 5) {
                counter = 0;

                let lstAux1 = [];
                let lstAux2 = [];
                let lstAux3 = [];

                lstAux1.push(pageListAux[0]);
                lstAux2.push(pageListAux[1]);
                lstAux2.push(pageListAux[2]);
                lstAux3.push(pageListAux[3]);
                lstAux3.push(pageListAux[4]);

                let pageList = [];
                pageList.push(lstAux1);
                pageList.push(lstAux2);
                pageList.push(lstAux3);

                this.globaList.push(pageList);
                pageListAux = [];
            }

        }

        if (counter > 0) {
            let lstAux1 = [];
            let lstAux2 = [];
            let lstAux3 = [];

            lstAux1.push(pageListAux[0]);

            if (pageListAux.length === 2) {
                lstAux2.push(pageListAux[1]);
            }

            if (pageListAux.length === 3) {
                lstAux2.push(pageListAux[1]);
                lstAux3.push(pageListAux[2]);
            }

            if (pageListAux.length === 4) {
                lstAux2.push(pageListAux[1]);
                lstAux3.push(pageListAux[2]);
                lstAux3.push(pageListAux[3]);
            }

            if (pageListAux.length === 5) {
                lstAux2.push(pageListAux[1]);
                lstAux2.push(pageListAux[2]);
                lstAux3.push(pageListAux[3]);
                lstAux3.push(pageListAux[4]);
            }

            let pageList = [];
            pageList.push(lstAux1);
            pageList.push(lstAux2);
            pageList.push(lstAux3);

            this.globaList.push(pageList);
        }
    }

    //method that changes the rendering of the services to the previous 3 elements on the auxResult list
    handlePrevious() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.favoriteServices = this.globaList[this.page - 1];
        }
        this.sliderIconsRenderer();
    }

    //method that changes the rendering of the services to the next 3 elements on the auxResult list
    handleNext() {
        if (this.page < this.maxSize) {
            this.page = this.page + 1;
            this.favoriteServices = this.globaList[this.page - 1];

        }
        this.sliderIconsRenderer();
    }

    //method that controls the redirection of the service's links
    redirect(event) {

        this.isLoading = true;

        //attributes stored on element that is related to the event
        const appUrlData = event.target.attributes.getNamedItem('data-appurl');
        const appFullUrlData = event.target.attributes.getNamedItem('data-appfullurl');
        const openWindowData = event.target.attributes.getNamedItem('data-openwindow');
        const requestable = event.target.attributes.getNamedItem('data-requestable');
        const recordId = event.target.attributes.getNamedItem('data-recordid');
        
        // update Last Visit Date on record
        // Create the recordInput object
        const fields = {};
        fields.Id = recordId.value;
        fields.Last_Visit_Date__c = new Date().toISOString();
        const recordInput = { fields };

        updateRecord(recordInput)
        .then(() => {
            console.info('Updated Last Visit Date successfully!');
        });
        
        let myUrl = appUrlData.value;
        
        //verifies if the event target contains all data for correct redirection
        if (openWindowData !== undefined) {
            //determines if the link is to be opened on a new window or on the current
            if (openWindowData.value === "true") {
                if (appUrlData.value !== 'undefined') {
                    myUrl = appUrlData.value;
                } else if (appFullUrlData.value !== 'undefined') {
                    myUrl = appFullUrlData.value;
                }

                //start the spinner
                this.toggleSpinner();

                //is this link a requestable Service?
                if (requestable.value === "true") {
                    //method that redirects the user to the old portal maintaing the same loginId
                    goToOldPortalService({ myurl: myUrl })
                        .then(result => {
                            //stop the spinner
                            this.toggleSpinner();
                            //open new tab with the redirection
                            window.open(result);
                        })
                        .catch(error => {
                            //throws error
                            this.error = error;
                        });
                } else {
                    //stop the spinner
                    this.toggleSpinner();
                    //open new tab with the redirection
                        myUrl = window.location.protocol + '//' + window.location.hostname + myUrl;
                    window.open(myUrl);
                }
            } else {
                //redirects on the same page
                window.location.href = myUrl;
            }
            
        }
    }

    //method to rerender the icons between the next and previous buttons
    sliderIconsRenderer() {
        this.sliderIcons = [];
        let className = '';
        for (let i = 0; i < this.maxSize; i++) {
            className = 'slideIcon';
            if (i === this.page - 1) {
                className = 'currentSlideIcon';
            }
            this.sliderIcons.push({ className });
        }
    }

    goToServices() {
        navigateToPage("services");
    }

    goToAvailableServices() {
        navigateToPage("services?tab=availableServices");
    }

}