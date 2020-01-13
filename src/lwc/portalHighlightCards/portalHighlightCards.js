import { LightningElement, api, track } from 'lwc';

import getRecommendations from '@salesforce/apex/PortalRecommendationCtrl.getRecommendations';

import CSP_YouIATA_Highlights from '@salesforce/label/c.CSP_YouIATA_Highlights';

export default class PortalHighlightCards extends LightningElement {

    //global variables
    @track maxSize = 3;
    @track page = 1;
    @track sliderIcons = [];
    @track windowWidth = window.innerWidth;
    @track sliderPosition = "left: 0px;";
    @track classCardNumber = "slds-col slds-size_1-of-12 slds-is-relative";

    @track labels = {
        CSP_YouIATA_Highlights
    };

    @track recordsPerPageLocal = 0;

    @track highlightListToIterate = [];
    @track highlightListToIterateMobile = [];
    
    @track highlightList = [];
    @api type;

    @api specialCase;
    @track hideTitle = false;

    @track loading = true;

    @track refrehTimer;
    @track firstPosition;

    @track swipe = "slds-grid slds-wrap slds-align--absolute-center slds-gutters_direct-medium slds-is-relative swipeClass swipeMove";
    @track cardMove = "margin-left: 0; opacity: 1";

    get
    showComponent() {
        return !this.loading && this.highlightList.length > 0;
    } 

    connectedCallback() {
        
        getRecommendations({'type' : this.type}).then(result => {
            let resultsLocal = JSON.parse(JSON.stringify(result));

            resultsLocal.forEach(function (highlight) {
                highlight.imgURL = 'background-image: url("' + highlight.imgURL + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:130px;';
            });

            this.highlightList = resultsLocal;
            this.checkRecordPerPage();
            this.loading = false;

            if (this.type === 'HomePage' && this.windowWidth >= 768) {
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                window.setInterval(() => {
                    this.handleNext();
                }, 10000);
            }
            
        });

        if (this.type === 'Services') {
            this.hideTitle = true;
        }

        /* This event it's to calculate the page resize. Based on page size, the displayed Highlight will change. */
        window.addEventListener('resize', () => {
            this.calculateHighlightPerPage();
        }, this);

    }

    /* Check the number of records to Display per page.*/
    checkRecordPerPage() {
        let windowWidth = window.innerWidth;
        if (windowWidth >= 1024) {
            this.recordsPerPageLocal = 3;
        } else if (windowWidth >= 768) {
            this.recordsPerPageLocal = 2;
        } else {
            this.recordsPerPageLocal = 1;
        }

        let totalRecords = this.highlightList.length;
        let maxSizeLocal = totalRecords / this.recordsPerPageLocal;
        this.page = 1;
        this.maxSize = Math.ceil(maxSizeLocal);

        this.sliderIconsRenderer();
        this.getRecordPerPage();
    }

    calculateHighlightPerPage() {
        this.checkRecordPerPage();
    }

    /* Get the Highlights to Display, based on the page size. */
    getRecordPerPage() {
        let highlightListLocal = JSON.parse(JSON.stringify(this.highlightList));

        let end = (this.page * this.recordsPerPageLocal);
        let start = end - this.recordsPerPageLocal;

        this.highlightListToIterate = highlightListLocal.slice(start, end);
        this.highlightListToIterateMobile = highlightListLocal;
        this.classCardNumber = "slds-col slds-size_1-of-"+(this.highlightListToIterateMobile.length)+" slds-is-relative";
        this.sliderPosition = "width:"+(this.highlightListToIterateMobile.length * this.windowWidth * 0.8)+"px;";

    }

    //method that changes the rendering of the services to the previous 3 elements on the auxResult list
    handlePrevious() {
        if (this.page > 1) {
            this.page = this.page - 1;
        } else {
            this.page = this.maxSize;
        }

        this.sliderIconsRenderer();
        this.getRecordPerPage();
    }

    //method that changes the rendering of the services to the next 3 elements on the auxResult list
    handleNext() {
        if (this.page < this.maxSize) {
            this.page = this.page + 1;
        } else {
            this.page = 1;
        }

        this.sliderIconsRenderer();
        this.getRecordPerPage();
    }

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
}