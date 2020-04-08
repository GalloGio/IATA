import { LightningElement, track } from 'lwc';

import getFavoriteServicesList from '@salesforce/apex/PortalServicesCtrl.getFavoriteServicesList';
import paymentLinkRedirect from '@salesforce/apex/PortalServicesCtrl.paymentLinkRedirect';
import changeIsFavoriteStatus from '@salesforce/apex/PortalServicesCtrl.changeIsFavoriteStatus';
import createPortalApplicationRight from '@salesforce/apex/PortalServicesCtrl.createPortalApplicationRight';
import verifyCompleteL3Data from '@salesforce/apex/PortalServicesCtrl.verifyCompleteL3Data';
import getPortalServiceId from '@salesforce/apex/PortalServicesCtrl.getPortalServiceId';

import { updateRecord } from 'lightning/uiRecordApi';

//Navigation
import { navigateToPage } from 'c/navigationUtils';

//import labels 
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import csp_Request_New_Service from '@salesforce/label/c.csp_Request_New_Service';
import CSP_FavoriteServices_Title from '@salesforce/label/c.CSP_FavoriteServices_Title';
import CSP_Services_AddFavorite from '@salesforce/label/c.CSP_Services_AddFavorite';
import CSP_Services_RemoveFavorite from '@salesforce/label/c.CSP_Services_RemoveFavorite';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class FavoriteServicesLWC extends LightningElement {
    /* Images */
    favoriteIcon = CSP_PortalPath + 'CSPortal/Images/Icons/favorite.png';
    notFavoriteIcon = CSP_PortalPath + 'CSPortal/Images/Icons/not_favorite.png';

    //track variables

    @track maxSize;
    @track showPagination;
    @track sliderIcons;
    @track myClassMobile = 'withPointerTile smallTile slds-m-vertical_x-small aroundLightGrayBorder';
    @track favoriteServicesMobile = [];
    @track sliderWidth = '';
    @track windowWidth = window.innerWidth;

    @track isLoading = true;

    //global variables
    page = 1;
    globaList;
    favoriteServices;
    auxResult;

    // Expose the labels to use in the template.
    label = {
        csp_Request_New_Service,
        CSP_SeeAll,
        CSP_FavoriteServices_Title,
        CSP_Services_AddFavorite,
        CSP_Services_RemoveFavorite
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
                    this.auxResult[i].serviceName=this.auxResult[i].Portal_Application__r.ServiceName__c===undefined?this.auxResult[i].PortalServiceTranslatedName__c:this.auxResult[i].Portal_Application__r.ServiceName__c;
                    if (this.auxResult[i].Portal_Application__r === undefined || this.auxResult[i].Portal_Application__r.Application_icon_URL__c === undefined) {
                        this.auxResult[i].Portal_Application__r.Application_icon_URL__c = '';
                    }
                    if (this.auxResult[i].Application_Start_URL__c === undefined || this.auxResult[i].Application_Start_URL__c === '') {
                        this.auxResult[i].Application_Start_URL__c = '';
                    }
                    if (this.auxResult[i].Portal_Application__r.Application_URL__c === undefined || this.auxResult[i].Portal_Application__r.Application_URL__c === '') {
                        this.auxResult[i].Portal_Application__r.Application_URL__c = '';
                    }
                    if(this.auxResult[i].Portal_Application__r.Application_icon_URL__c !== undefined && this.auxResult[i].Portal_Application__r.Application_icon_URL__c !== ''){
                        this.auxResult[i].imageCSS = 'background: url(' + this.auxResult[i].Portal_Application__r.Application_icon_URL__c + ');';
                    }else{
                        this.auxResult[i].imageCSS = '';
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
                //this.favoriteServicesMobile = this.auxResult;

                //the maxSize of the List
                this.maxSize = this.globaList.length;
                this.sliderWidth = "width:"+(this.windowWidth - 32) * (this.globaList.length) * 0.4 +"px;";

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
                        this.globaList[i][j][k].imageCSS += 'margin:1.5rem;';
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

                pageListAux[0].favoriteDivClass = 'oneRemClass';
                pageListAux[1].favoriteDivClass = 'oneRemClass';
                pageListAux[2].favoriteDivClass = 'halfOneRemClass';
                pageListAux[3].favoriteDivClass = 'oneRemClass';
                pageListAux[4].favoriteDivClass = 'halfOneRemClass';

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
            let listMobile = [];

            pageListAux[0].favoriteDivClass = 'oneRemClass';

            lstAux1.push(pageListAux[0]);

            if (pageListAux.length === 2) {
                pageListAux[1].favoriteDivClass = 'oneRemClass';    
                lstAux2.push(pageListAux[1]);
            }

            if (pageListAux.length === 3) {
                pageListAux[1].favoriteDivClass = 'oneRemClass';
                pageListAux[2].favoriteDivClass = 'oneRemClass';
                lstAux2.push(pageListAux[1]);
                lstAux3.push(pageListAux[2]);
            }

            if (pageListAux.length === 4) {
                pageListAux[1].favoriteDivClass = 'oneRemClass';
                pageListAux[2].favoriteDivClass = 'oneRemClass';
                pageListAux[3].favoriteDivClass = 'halfOneRemClass';
                lstAux2.push(pageListAux[1]);
                lstAux3.push(pageListAux[2]);
                lstAux3.push(pageListAux[3]);
            }

            if (pageListAux.length === 5) {
                pageListAux[1].favoriteDivClass = 'oneRemClass';
                pageListAux[2].favoriteDivClass = 'halfOneRemClass';
                pageListAux[3].favoriteDivClass = 'oneRemClass';
                pageListAux[4].favoriteDivClass = 'halfOneRemClass';
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
        } else {
            this.page = this.maxSize;
            this.favoriteServices = this.globaList[this.page - 1];
        }

        this.sliderIconsRenderer();
    }

    //method that changes the rendering of the services to the next 3 elements on the auxResult list
    handleNext() {
        if (this.page < this.maxSize) {
            this.page = this.page + 1;
            this.favoriteServices = this.globaList[this.page - 1];
        } else {
            this.page = 1;
            this.favoriteServices = this.globaList[this.page - 1];
        }

        this.sliderIconsRenderer();
    }

    //method that controls the loading spinner action
    toggleSpinner() {
        this.isLoading = !this.isLoading;
    }

    //method that controls the redirection of the service's links
    redirect(event) {

        this.toggleSpinner();

        //attributes stored on element that is related to the event
        const appUrlData = event.target.attributes.getNamedItem('data-appurl');
        const appFullUrlData = event.target.attributes.getNamedItem('data-appfullurl');
        const openWindowData = event.target.attributes.getNamedItem('data-openwindow');
        const requestable = event.target.attributes.getNamedItem('data-requestable');
        const recordId = event.target.attributes.getNamedItem('data-recordid');
        const recordName = event.target.attributes.getNamedItem('data-recordname');
        if (recordId !== null) {
            // update Last Visit Date on record only if portal application right exists
            // Create the recordInput object
            const fields = {};
            fields.Id = recordId.value;
            fields.Last_Visit_Date__c = new Date().toISOString();
            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    console.info('Updated Last Visit Date successfully!');
                });
        }
        else{
            const pa = event.target.attributes.getNamedItem('data-application-id');
            createPortalApplicationRight({portalApplicationId:pa.value})
                .then(() => {
                    console.info('Updated Last Visit Date successfully!');
                });
        }


        let myUrl;
        let flag = false;
        if (appUrlData.value !== '') {
            myUrl = appUrlData.value;
            flag = true;
        } else if (appFullUrlData.value !== '') {
            myUrl = appFullUrlData.value;
            flag = true;
        }
        else if (recordName.value === 'Payment Link' || recordName.value === 'Paypal') {
            myUrl = '';
            flag = true;
        }
        if (flag) {
            //verifies if the event target contains all data for correct redirection

            if (openWindowData !== null && openWindowData !== undefined) {
                //determines if the link is to be opened on a new window or on the current
                if (openWindowData.value === "true") {
                    //open new tab with the redirection

                    if (myUrl.startsWith('/')) {

                        window.open(myUrl);
                        this.toggleSpinner();                          

                    } else {
                        if (recordName.value === 'Payment Link' || recordName.value === 'Paypal') {
                            paymentLinkRedirect()
                                .then(result => {
                                    if (result !== undefined && result !== '') {
                                        myUrl = result;
                                        if (!myUrl.startsWith('http')) {
                                            myUrl = window.location.protocol + '//' + myUrl;
                                        }
                                    }
                                    window.open(myUrl);
                                    this.toggleSpinner();
                                });

                        } else if(recordName.value === 'Training Platform (LMS)'){
							getPortalServiceId({ serviceName: recordName.value })
								.then(serviceId => {
									verifyCompleteL3Data({serviceId: serviceId})
									.then(result => {
										if(result !== 'not_complete'){
											window.open(result);
										}
										else{
											//fireEvent(this.pageRef, 'fireL3Registration', serviceId);
											navigateToPage(CSP_PortalPath+'?firstLogin=true&lms=yas');

										}
										this.toggleSpinner();
									})
									.catch(error => {
										this.error = error;
									});
								})
								.catch(error => {
									this.error = error;
							});

						}
						else{
                            if (!myUrl.startsWith('http')) {
                                myUrl = window.location.protocol + '//' + myUrl;
                            }
                            window.open(myUrl);
                            this.toggleSpinner();
                        }
                    }

                } else if (myUrl !== '') {
                    //redirects on the same page
                    //method that redirects the user to the old portal maintaing the same loginId
                    
                    window.open(myUrl,"_self");
                    this.toggleSpinner();

                }
            }
        } else {
            console.info('No link to the service has been set.')
            this.toggleSpinner();
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

    changeIsFavoriteStatus(event){
        this.isLoading = true;
        let par = event.currentTarget.getAttribute('data-id');
        let pa = event.currentTarget.getAttribute('data-application-id');
        let currentFavoriteStatus = event.currentTarget.getAttribute('data-is-favorite');

        if(par === 'undefined'){
            par = null;
        }

        changeIsFavoriteStatus({portalApplicationId:pa, portalApplicationRightId:par, isFavorite: (currentFavoriteStatus === 'false')})
            .then(result => {
                if(result){
                    this.connectedCallback();
                }
            });
    }

}
