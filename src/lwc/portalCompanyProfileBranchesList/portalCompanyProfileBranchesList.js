import { LightningElement,track } from 'lwc';

import getBranchesListFields from '@salesforce/apex/PortalProfileCtrl.getBranchesListFields';
import getContactFieldsToInsert from '@salesforce/apex/PortalProfileCtrl.getContactFieldsToInsert';
import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';
import canEditBasics from '@salesforce/apex/PortalProfileCtrl.canEditBasics';
import searchForCompanyBranches from '@salesforce/apex/PortalProfileCtrl.searchForCompanyBranches';

import csp_Find_Branch from '@salesforce/label/c.csp_Find_Branch';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalCompanyProfileBranchesList extends LightningElement {

    //icons
    searchColored = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';

    label = {
        csp_Find_Branch
    };

    @track branchesLoading = true;

    @track branchesFilteringObject = {
        searchInput : '',
        sortField : 'TradeName__c',
        sortDirection : 'ASC'
    };

    /*@track paginationObject = {
        totalItems : 10,
        currentPage : 1,
        pageSize : 10,
        maxPages : 5
    }*/

    @track branchesList = [];
    @track currentPage = 1;
    //@track branchesCount = 0;

    @track branchFields;
    @track fieldsListToCreate = [];
    @track recordid;
    @track accountId;
    @track isFetching = false;
    @track editBasics = false;
    @track openmodel = false;
    @track showCross = false;

    connectedCallback() {

        getBranchesListFields().then(result => {
            let sectionMap = JSON.parse(JSON.stringify(result));
            this.branchFields = sectionMap;
        });

        getContactFieldsToInsert().then(result => {
            this.fieldsListToCreate = result;
        });

        getLoggedUser().then(result => {
            this.loggedUser = JSON.parse(JSON.stringify(result));
            this.objectid = this.loggedUser.Contact.AccountId;
        });
    
        canEditBasics().then(result => {
            this.editBasics = result;
        });

        //init the branches list
        this.resetBranchesList();
    }

    //resets and recalls the first branches page
    resetBranchesList(){
        this.branchesList = [];
        this.branchesFilteringObject.searchInput = '';
        this.currentPage = 1;
        //this.branchesCount = 0;

        this.retrieveBranchesList(this.currentPage);
    }

    //Retrieves a specific branches page
    retrieveBranchesList(requestedPage){
        let requestedPageAux = requestedPage-1;

        searchForCompanyBranches(
            { companybranchFilterWrapper: JSON.stringify(this.branchesFilteringObject), 
            requestedPage: requestedPageAux + '' })
        .then(result => {
            let branchesListAux = JSON.parse(JSON.stringify(result.records));

            //first return contains the total records count
            /*if(requestedPage === 1){
                this.branchesCount = result.totalItemCount;
            }*/

            for (let i = 0; i < branchesListAux.length; i++) {
                let branch = branchesListAux[i];
                branch.LocationCode = branch.IATACode__c;
                if (branch.IATA_ISO_Country__r != null) {
                    branch.IsoCountry = branch.IATA_ISO_Country__r.Name;
                }
            }

            /*this.paginationObject = {
                totalItems : this.branchesCount,
                currentPage : requestedPage,
                pageSize : 10,
                maxPages : 3
            }*/

            this.branchesList = branchesListAux;
            this.branchesLoading = false;
        });
    }

    /*
    //receives the event from the pagination component and requestes the branch page
    handleSelectedPage(event){
        //the event contains the selected page
        let requestedPage = event.detail
        console.log('requestedPage: ', requestedPage);

        this.branchesLoading = true;
        this.retrieveBranchesList(requestedPage);
    }*/

    //event fired when search text changes
    onchangeBranchesSearchText(event){
        let searchtext = event.target.value;

        this.branchesFilteringObject.searchInput = searchtext;

        // Clear the timeout if it has already been set.
        // This will prevent the previous task from executing
        // if it has been less than <MILLISECONDS>
        clearTimeout(this.timeout);

        // Make a new timeout set to go off in 1500ms
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timeout = setTimeout(() => {
            //this.testfunction();

            this.branchesLoading = true;
            this.retrieveBranchesList(1);
            this.showCross = searchtext.length > 0;
        }, 500, this);

    }

    removeTextSearch() {
        this.showCross = false;
        this.branchesLoading = true;
        this.resetBranchesList();
    }

}