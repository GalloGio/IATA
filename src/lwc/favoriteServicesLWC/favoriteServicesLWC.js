import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getUserServicesList from '@salesforce/apex/PortalServicesCtrl.getUserServicesList';

export default class FavoriteServicesLWC extends NavigationMixin(LightningElement) {
    //track variables
    @track favoriteServices;
    @track maxSize;
    @track showPagination;
    @track sliderIcons;

    //api variables
    @api isLoaded = false;

    //global variables
    page = 1;

    //Same as doInit() function on old aura components
    connectedCallback() {
        //toggles the loading spinner on/off
        this.toggleSpinner();

        /* @salesforce/apex/PortalServicesCtrl.getUserServicesList' (shared apex code)
        *  getUserServicesList grabs the Services of the Contact logged in on the portal and stores on the result
        */
        getUserServicesList({ searchKey: '' })
            .then(result => {
                // eslint-disable-next-line no-console
                console.log(JSON.parse(JSON.stringify(result)));

                //auxResult stores the results globaly
                this.auxResult = JSON.parse(JSON.stringify(result));

                //adds css to the tiles to control which have a pointer
                this.auxResult.forEach(function (value) {
                    if (value.Right__c === "Access Granted") {
                        value.classcss = 'withPointerTile';
                    } else {
                        value.classcss = 'noPointerTile';
                    }
                });

                //favoriteServices stores the first 3 elements of the result using slice() starting at the given start argument, and ends at, but does not include, the given end argument
                this.favoriteServices = this.auxResult.slice(0, 3);

                //maxSize stores the number of slides with a max. of 3
                this.maxSize = Math.ceil(parseFloat(this.auxResult.length / 3)) >= 3 ? 3 : Math.ceil(parseFloat(this.auxResult.length / 3));

                //showPagination controls the rendering of the slider buttons
                this.showPagination = this.maxSize > 1 ? true : false;

                //method that controls how the slider icons render
                if (this.showPagination) {
                    this.sliderIconsRenderer();
                }

                //toggles the loading spinner on/off
                this.toggleSpinner();
            })
            .catch(error => {
                //throws error
                this.error = error;
            });
    }

    //method that changes the rendering of the services to the previous 3 elements on the auxResult list
    handlePrevious() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.favoriteServices = this.auxResult.slice(this.page - 1, this.page + 2);
        }
        this.sliderIconsRenderer();
    }

    //method that changes the rendering of the services to the next 3 elements on the auxResult list
    handleNext() {
        if (this.page < this.maxSize) {
            this.page = this.page + 1;
            this.favoriteServices = this.auxResult.slice(this.page + 1, this.page + 4);

        }
        this.sliderIconsRenderer();
    }

    //method that controls the loading spinner action
    toggleSpinner() {
        this.isLoaded = !this.isLoaded;
    }

    //method that controls the redirection of the service's links
    redirect(event) {

        //attributes stored on element that is related to the event
        const appurlData = event.target.attributes.getNamedItem('data-appurl');
        const rightData = event.target.attributes.getNamedItem('data-right');
        const openWindowData = event.target.attributes.getNamedItem('data-openwindow');

        //verifies if the event target contains all data for correct redirection
        if (appurlData !== undefined && rightData !== undefined && openWindowData !== undefined) {
            const appurlStr = appurlData.value;
            const rightStr = rightData.value;
            const openWindowStr = openWindowData.value;

            //determines if the link is to be opened on a new window or on the current
            if (rightStr === "Access Granted") {
                if (openWindowStr === "true") {
                    window.open(appurlStr);
                } else {
                    this.toggleSpinner();
                    window.location.href = appurlStr;
                }
            }
        }
    }

    //method to render the icons between the next and previous buttons
    sliderIconsRenderer() {
        this.sliderIcons = [];
        for (let i = 0; i < this.maxSize; i++) {
            let vari = '';
            if (i === this.page - 1) {
                vari = 'warning';
            }
            this.sliderIcons.push({ variant: vari });
        }
    }
}