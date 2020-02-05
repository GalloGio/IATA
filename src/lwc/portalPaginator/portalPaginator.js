import { LightningElement,track,api } from 'lwc';


import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalPaginator extends LightningElement {

    paginatorFirstPageEnabled = CSP_PortalPath + 'CSPortal/Images/Paginator/paginatorFirstPageEnabled.svg';
    paginatorFirstPageDisabled = CSP_PortalPath + 'CSPortal/Images/Paginator/paginatorFirstPageDisabled.svg';
    paginatorLastPageEnabled = CSP_PortalPath + 'CSPortal/Images/Paginator/paginatorLastPageEnabled.svg';
    paginatorLastPageDisabled = CSP_PortalPath + 'CSPortal/Images/Paginator/paginatorLastPageDisabled.svg';
    paginatorPreviousPageEnabled = CSP_PortalPath + 'CSPortal/Images/Paginator/paginatorPreviousPageEnabled.svg';
    paginatorPreviousPageDisabled = CSP_PortalPath + 'CSPortal/Images/Paginator/paginatorPreviousPageDisabled.svg';
    paginatorNextPageEnabled = CSP_PortalPath + 'CSPortal/Images/Paginator/paginatorNextPageEnabled.svg';
    paginatorNextPageDisabled = CSP_PortalPath + 'CSPortal/Images/Paginator/paginatorNextPageDisabled.svg';

    //these are the filters passed from the search
    @api
    get paginationObjectParent() {
        return this.paginationObject;
    }
    set paginationObjectParent(value) {
        let paginationObjectAux = JSON.parse(JSON.stringify(value));
        //if anything changes, recalculate the new pages
        if(this.paginationObject.totalItems !== paginationObjectAux.totalItems || this.paginationObject.currentPage !== paginationObjectAux.currentPage || 
            this.paginationObject.pageSize !== paginationObjectAux.pageSize || this.paginationObject.maxPages !== paginationObjectAux.maxPages){
            
            this.paginationObject = paginationObjectAux;
            this.calculatePagesList(paginationObjectAux.totalItems, paginationObjectAux.currentPage, paginationObjectAux.pageSize, paginationObjectAux.maxPages);
        }
    }

    //default value
    @track paginationObject = {
        totalItems : 1,
        currentPage : 1,
        pageSize : 10,
        maxPages : 5
    } 

    @track totalItems = 0;
    @track currentPage = 1;
    @track totalPages = 0;

    @track pages = [];

    calculatePagesList(totalItems, currentPage, pageSize, maxPages ){
        // calculate total pages
        this.totalPages = Math.ceil(totalItems / pageSize);
        this.currentPage = currentPage;
        this.totalItems = totalItems;

        // ensure current page isn't out of range
        if (currentPage < 1) {
            currentPage = 1;
        } else if (currentPage > this.totalPages) {
            currentPage = this.totalPages;
        }

        let startPage, endPage;
        if (this.totalPages <= maxPages) {
            // total pages less than max so show all pages
            startPage = 1;
            endPage = this.totalPages;
        } else {
            // total pages more than max so calculate start and end pages
            let maxPagesBeforeCurrentPage = Math.floor(maxPages / 2);
            let maxPagesAfterCurrentPage = Math.ceil(maxPages / 2) - 1;
            if (currentPage <= maxPagesBeforeCurrentPage) {
                // current page near the start
                startPage = 1;
                endPage = maxPages;
            } else if (currentPage + maxPagesAfterCurrentPage >= this.totalPages) {
                // current page near the end
                startPage = this.totalPages - maxPages + 1;
                endPage = this.totalPages;
            } else {
                // current page somewhere in the middle
                startPage = currentPage - maxPagesBeforeCurrentPage;
                endPage = currentPage + maxPagesAfterCurrentPage;
            }
        }

        // create an array of pages to ng-repeat in the pager control
        let pagesAux = Array.from(Array((endPage + 1) - startPage).keys()).map(i => startPage + i);
        
        this.pages = [];
        for(let i=0; i<pagesAux.length; i++){
            let classAux = this.currentPage === pagesAux[i] ? 'smallBoxSize aroundLightGrayBorder' : 'smallBoxSize';
            this.pages.push({number: pagesAux[i], class: classAux});
        }

    }

    //functions to enable/disable the navigation arrows
    get enableBackwardButtons(){ return this.currentPage > 1 ; }
    get enableForwardButtons(){ return this.currentPage < this.totalPages; }

    get viewFirstPage(){return this.pages !== undefined && this.pages[0] !== undefined && this.pages[0].number !== undefined && this.pages[0].number !== 1 ;}
    get viewFirstThreeDots(){return this.pages !== undefined && this.pages[0] !== undefined && this.pages[0].number !== undefined && this.pages[0].number !== 1 ;}
    get viewLastThreeDots(){return this.pages !== undefined && this.pages[(this.pages.length-1)] !== undefined && this.pages[(this.pages.length-1)].number !== undefined && this.pages[(this.pages.length-1)].number !== this.totalPages && this.currentPage !== this.totalPages;}
    get viewLastPage(){return this.pages !== undefined && this.pages[(this.pages.length-1)] !== undefined && this.pages[(this.pages.length-1)].number !== undefined && this.pages[(this.pages.length-1)].number !== this.totalPages && this.currentPage !== this.totalPages;}

    //functions to navigate to a page
    handleNavigateToFirstPage(){ this.navigateToSelectedPage(1); }
    handleNavigateToPreviousPage(){ this.navigateToSelectedPage(this.currentPage-1); }
    handleNavigateToNextPage(){ this.navigateToSelectedPage(this.currentPage+1); }
    handleNavigateToLastPage(){ this.navigateToSelectedPage(this.totalPages); }
    handleNavigateToSelectedPage(event){ this.navigateToSelectedPage(parseInt(event.target.name)); }

    //fires the event to parent to retrieve the new selected page
    navigateToSelectedPage(page){
        const selectedPage = new CustomEvent('selectedpage', {
            detail: page
        });
        this.dispatchEvent(selectedPage);
    }
}