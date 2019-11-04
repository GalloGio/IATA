import { LightningElement, api, track } from 'lwc';

import getRecommendations from '@salesforce/apex/PortalRecommendationCtrl.getRecommendations';

import CSP_YouIATA_Highlights from '@salesforce/label/c.CSP_YouIATA_Highlights';

export default class PortalHighlightCards extends LightningElement {

    //global variables
    @track maxSize = 3;
    @track page = 1;
    @track sliderIcons = [];

    @track labels = {
        CSP_YouIATA_Highlights
    };

    @track recordsPerPage = 0;

    @track highlightListToIterate = [];

    @track highlightList = [];
    @api type;

    @api specialCase;
    @track hideTitle = false;

    @track loading = true;

    @track isForRefreshTimer = false;
    @track refrehTimer;

    @track firstPosition;

    @track swipe = "slds-grid slds-wrap slds-align--absolute-center slds-gutters_direct-medium slds-is-relative swipeClass swipeMove";
    @track cardMove = "margin-left: 0; opacity: 1";

    connectedCallback() {

        getRecommendations({ 'type': this.type }).then(result => {
            let resultsLocal = JSON.parse(JSON.stringify(result));

            resultsLocal.forEach(function (highlight) {
                highlight.imgURL = 'background-image: url("' + highlight.imgURL + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:130px;';
            });

            this.highlightList = resultsLocal;
            this.checkRecordPerPage();
            this.loading = false;

            if (this.type === 'HomePage') {
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                this.refrehTimer = window.setInterval(() => {
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
        let recordsPerPageLocal = 0;
        if (windowWidth >= 1024) {
            recordsPerPageLocal = 3;
        } else if (windowWidth >= 768) {
            recordsPerPageLocal = 2;
        } else {
            recordsPerPageLocal = 1;
        }

        if (this.recordsPerPage !== recordsPerPageLocal) {
            this.recordsPerPage = recordsPerPageLocal;
            let totalRecords = this.highlightList.length;
            let maxSizeLocal = totalRecords / recordsPerPageLocal;
            this.page = 1;
            this.maxSize = Math.ceil(maxSizeLocal);

            this.sliderIconsRenderer();
            this.getRecordPerPage();
        }
    }

    calculateHighlightPerPage() {
        this.checkRecordPerPage();
    }

    /* Get the Highlights to Display, based on the page size. */
    getRecordPerPage() {
        let highlightListLocal = JSON.parse(JSON.stringify(this.highlightList));

        let end = (this.page * this.recordsPerPage);
        let start = end - this.recordsPerPage;

        this.highlightListToIterate = highlightListLocal.slice(start, end);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.cardMove = "margin-left: 0; opacity: 0";
        }, 300);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.cardMove = "margin-left: 0; opacity: 1";
        }, 1300);
    }

    handlePreviousPage() {
        this.isForRefreshTimer = true;
        this.handlePrevious();
    }

    //method that changes the rendering of the services to the previous 3 elements on the auxResult list
    handlePrevious() {
        if (this.page > 1) {
            this.page = this.page - 1;
        } else {
            this.page = this.maxSize;
        }

        if (this.isForRefreshTimer) {
            clearInterval(this.refrehTimer);
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.refrehTimer = window.setInterval(() => {
                this.handleNext();
            }, 10000);

            this.isForRefreshTimer = false;
        }

        this.sliderIconsRenderer();
        this.getRecordPerPage();
    }

    handleNextPage() {
        this.isForRefreshTimer = true;
        this.handleNext();
    }

    //method that changes the rendering of the services to the next 3 elements on the auxResult list
    handleNext() {
        if (this.page < this.maxSize) {
            this.page = this.page + 1;
        } else {
            this.page = 1;
        }

        if (this.isForRefreshTimer) {
            clearInterval(this.refrehTimer);
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.refrehTimer = window.setInterval(() => {
                this.handleNext();
            }, 10000);
            this.isForRefreshTimer = false;
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

    touchStart(event) {
        this.firstPosition = event.touches[0].clientX;
    }

    touchMove(event) {
        let position = event.touches[0].clientX;
        if (this.firstPosition) {
            if (this.firstPosition > position) {
                if ((this.firstPosition - position) > 50) {
                    this.firstPosition = null;
                    this.cardMove = "margin-left: -100vw; opacity: 0.3";
                    this.handleNextPage();
                }
            } else {
                if ((position - this.firstPosition) > 50) {
                    this.firstPosition = null;
                    this.cardMove = "margin-left: 100vw; opacity: 0.3";
                    this.handlePreviousPage();
                }
            }
        }
    }

}