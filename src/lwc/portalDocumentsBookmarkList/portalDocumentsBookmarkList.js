import { LightningElement,track,wire,api } from 'lwc';

import toggleBookmarkDocument from '@salesforce/apex/PortalDocumentsController.toggleBookmarkDocument';
import getBookmarkedList from '@salesforce/apex/PortalDocumentsController.getBookmarkedDocuments';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getContentDistribution from '@salesforce/apex/CSP_Utils.getContentDistribution';
import CSP_Search_Documents_ProdType from '@salesforce/label/c.CSP_Search_Documents_ProdType';
import IDCard_Description from '@salesforce/label/c.IDCard_Description';
import CSP_Documents_PubliCountry from '@salesforce/label/c.CSP_Documents_PubliCountry';
import CSP_Search_NoResults_text1 from '@salesforce/label/c.CSP_Search_NoResults_text1';
import CSP_Search_NoResults_text2 from '@salesforce/label/c.CSP_Search_NoResults_text2';
import CSP_DocumentType from '@salesforce/label/c.CSP_DocumentType';
import CSP_LastUpdate from '@salesforce/label/c.CSP_LastUpdate';
import CSP_Documents from '@salesforce/label/c.CSP_Documents';
import CSP_Track from '@salesforce/label/c.CSP_Track';
import CSP_NoBookmarksText1 from '@salesforce/label/c.CSP_NoBookmarksText1';
import CSP_NoBookmarksText2 from '@salesforce/label/c.CSP_NoBookmarksText2';
import CSP_DocumentBookmarkAdded from '@salesforce/label/c.CSP_DocumentBookmarkAdded';
import CSP_DocumentBookmarkRemoved from '@salesforce/label/c.CSP_DocumentBookmarkRemoved';
import CSP_Success from '@salesforce/label/c.CSP_Success';

import CurrencyCenter_Open from '@salesforce/label/c.CurrencyCenter_Open';

import { refreshApex } from '@salesforce/apex';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalDocumentsBookmarkList extends LightningElement {

    @track label = {
        CSP_Search_Documents_ProdType,
        IDCard_Description,
        CSP_Documents_PubliCountry,
        CSP_Search_NoResults_text1,
        CSP_Search_NoResults_text2,
        CSP_DocumentType,
        CSP_LastUpdate,
        CSP_Documents,
        CSP_Track,
        CSP_NoBookmarksText1,
        CSP_NoBookmarksText2,
        CSP_DocumentBookmarkAdded,
        CSP_DocumentBookmarkRemoved,
        CSP_Success,
        CurrencyCenter_Open
    };

    @track bookmarkData;//  wire result 
    @track documentsList=[]; // list of the documents being displayed in the frontend
    @track loadingDocs=false; // flag to control if the documents are being loaded

    @track currentPageNr=1; // Number of the current page in the list

    @track totalNrPages=0; // Total Number of pages with results
    @track keyword=''; //search key word currently being searched for


    @track hasResults=false; //flag to control if the user has any bookmarked document
    @track searchMode=false; //flag to control if in search mode( when the users inserts for a search word)

    @track noSearchResults=true; // flag to control if the service return any value

    @track searchIconNoResultsUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchNoResult.svg';
    @track downloadIcon = CSP_PortalPath + 'CSPortal/Images/Icons/download.svg';
    @track NoResultsIcon = CSP_PortalPath + 'CSPortal/Images/Icons/Bookmark_NoResults.svg';

    @track paginationObject = { //Object with the pagination details to initialize the paginator cmp
        totalItems:10,
        currentPage: 1,
        pageSize: 10,
        maxPages: 3
    }

    //Retrieves the list of the bookmark documents
    @wire( getBookmarkedList,{searchKey:'$keyword', requestedPage:'$currentPageNr'})
    wireGetBookmarList(result){
        this.bookmarkData=result;
        if(result.data){
            let docList=JSON.parse(result.data.recordsString);
            docList.forEach(elem=>{
                elem.bookMarked=true;
                elem.Country_of_publication__c=elem.Country_of_publication__c?elem.Country_of_publication__c.split(";").join(", ") : '';
                elem.LastModifiedDate=new Date(elem.LastModifiedDate).toLocaleDateString();
            });
            
            this.searchMode= this.keyword.length>0;
            this.hasResults=docList.length>0 || this.searchMode;

            this.noSearchResults=docList.length==0 && this.searchMode;

            this.documentsList=docList;
            this.loadingDocs=false;
            this.totalNrPages= Math.ceil(result.data.totalItemCount/10);
            this.paginationObject={
                totalItems:result.data.totalItemCount,
                currentPage: this.currentPageNr,
                pageSize: 10,
                maxPages: this.totalNrPages
            };            
        }

    }

    // Invocable method for when the component needs to refresh the document list
    @api refreshList(){
        this.loadingDocs=true;
        this.currentPageNr=1;
        refreshApex(this.bookmarkData);
    }


    renderedCallback(){        
        this.toggleUnderline(this.documentsList.length>1);
    }



    //Underline all columns in the list with the exception of the last line
    toggleUnderline(add){

        this.template.querySelectorAll('.cellDefault').forEach((elem, key, arr)=>{
            if (key <= (arr.length - 5)){ 
                if(add) elem.classList.add('underLined');               
            } else {
                elem.classList.remove('underLined');
            }
        });

    }


    //open the document accordeon
    openRecordDetail(event) {
        let recordIndex = event.target.dataset.item;
        this.documentsList.forEach(function (el) {   
            if(recordIndex === el.Id && !el.open) {
                el.open = true;
            } else {
                el.open = false;
            }
           
        });
    }

    //controls when to display the pagination cmp
    get showPaginator(){
        return this.totalNrPages>1;
    }

    //handles the search event
    startSearch(event){
       this.loadingDocs=true;
       this.keyword=event.detail.key;
    }

    //Handles view document action
    viewDocument(event) {
        this.loadingDocs = true;
        let url = event.target.dataset.url;
        if(url !== undefined && url.length>0){
             url = url.trim();
            if(url.substring(0,4) !== 'http')
                url = 'https://' + url; 
            window.open(url, '_blank'); 

        } else{
        getContentDistribution({ documentName: event.target.dataset.name, documentId: event.target.dataset.item })
            .then(results => {
                window.open(results.DistributionPublicUrl, '_blank');
                });
        }
        this.loadingDocs = false;
    }

    //Handles dowload document action
    downloadDocument(event) {
		let url = event.target.dataset.url;

        if(url !== undefined && url.length>0){
            this.viewDocument(event);
        } else{
			this.loadingDocs = true;
			getContentDistribution({ documentName: event.target.dataset.name, documentId: event.target.dataset.item })
				.then(results => {
					window.open(results.ContentDownloadUrl, '_self');
					this.loadingDocs = false;});
		  }
    }

    //Handles bookmark document action
    bookmarkDoc(event){
        let doc=event.target.dataset.item;
        let selectDoc =this.documentsList.find(element => element.ContentDocumentId == doc);    
        selectDoc.bkloading=true;
        toggleBookmarkDocument({
            docId:doc
        }).then(val=>{
            //toggles current bookmark option
            selectDoc.bookMarked=!selectDoc.bookMarked;
            //fires toast message
            const event = new ShowToastEvent({
                title: this.label.CSP_Success,
                variant:'success',
                mode:'pester',
                message: selectDoc.bookMarked ? this.label.CSP_DocumentBookmarkAdded:this.label.CSP_DocumentBookmarkRemoved.replace('#doc',selectDoc.Title),
            });
            this.dispatchEvent(event);
            selectDoc.bkloading=false;

            //fire event to request other tables to be refreshed
            this.dispatchEvent(new CustomEvent('refreshlist'));

        })
        .catch(error => {
            console.error(error);
            selectDoc.bkloading=false;
        });
    }

    //switch to the all documents tab
    goToAllDocs(){
        this.dispatchEvent(new CustomEvent('switchtotab',{ detail : { tab:'allTab' }} ));
    }

    //swtich to all documents to specific section/ filter
    goToCategory(event){
        let categ=event.target.dataset.doccategory;
        let prodcateg=event.target.dataset.prodcategory;

        this.dispatchEvent(new CustomEvent('switchtotab',{ detail : { tab:'allTab',category:categ,prodCategory:prodcateg }} ));
    }

    //catches event from pagination cmp to display/request selected page
    handleSelectedPage(event) {
        //the event contains the selected page
        this.loadingDocs = true;
        let requestedPage = event.detail;
        this.currentPageNr = requestedPage;
        let paginationObjectAux = JSON.parse(JSON.stringify(this.paginationObject));
        paginationObjectAux.currentPage = requestedPage;
        this.paginationObject = paginationObjectAux;      
	}

}