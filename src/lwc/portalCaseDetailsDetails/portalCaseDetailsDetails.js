import { LightningElement, track, api} from 'lwc';
import getCaseById from '@salesforce/apex/PortalCasesCtrl.getCaseById';
import getFieldLabels from '@salesforce/apex/CSP_Utils.getSelectedColumns';

import { getParamsFromPage } from 'c/navigationUtils';

/* Importing labels*/ 
import AddDocumentsMsg from '@salesforce/label/c.CSP_No_Documents_Message';
import DocumentsLabel from '@salesforce/label/c.ISSP_Documents';
import CaseDetails from '@salesforce/label/c.IDCard_CaseDetails';
import RelatedAccount from '@salesforce/label/c.csp_CreateNewCaseMainPicklistLabel';

export default class PortalCaseDetailsDetails extends LightningElement {

    @track loading = true;
    @track caseDetails;
    @track caseId;

    @track showAddDocsModal = false;


    @track nrDocs=0;

    @track label= {
        AddDocumentsMsg,
        CaseDetails,
        DocumentsLabel,
        RelatedAccount
    };

    @track fieldLabels={};

    connectedCallback() {        
        //get the parameters for this page
        this.pageParams = getParamsFromPage();

        if (this.pageParams.caseId !== undefined) {
            this.caseId = this.pageParams.caseId;            
            getCaseById({ caseId: this.pageParams.caseId })
                .then(results => {
                    this.caseDetails = results;
                    this.loading = false;
                })
                .catch(error => {
                    console.log('error: ', error);
                    this.loading = false;
                });  
            const labelsToRetrieve=["Country_concerned__c","Topic__c","Subtopic__c","Region__c","Type_of_case_Portal__c","Description"];      
            getFieldLabels({sObjectType:'case',sObjectFields:labelsToRetrieve}).then(result=>{
                console.log(result);
                if(result){
                    this.fieldLabels=result;                   
                }
            });
        }
    }

    get hasTopic() {
        return this.caseDetails !== undefined && this.caseDetails.Topic__c !== undefined;
    }

    get hasSubtopic() {
        return this.caseDetails !== undefined && this.caseDetails.Subtopic__c !== undefined;
    }

    get hasRegion() {
        return this.caseDetails !== undefined && this.caseDetails.Region__c !== undefined;
    }

    get hasCountryConcerned() {
        return this.caseDetails !== undefined && this.caseDetails.Country_concerned__c !== undefined;
    }

    get hasAccountConcerned() {
        return this.caseDetails !== undefined && this.caseDetails.Account_Concerned__r !== undefined && this.caseDetails.Account_Concerned__r.IATACode__c !== undefined;
    }

    get hasTypeOfCasePortal() {
        return this.caseDetails !== undefined && this.caseDetails.Type_of_case_Portal__c !== undefined;
    }

    get hasDescription() {
        return this.caseDetails !== undefined && this.caseDetails.Description !== undefined;
    }
    get showNrDocs() {
        return this.nrDocs>0;
    }

    updateNdocs(event){   
        //sets nr of docs in panel
        this.nrDocs= event.detail.ndocs;
    }

    toggleCaseDetailsSection() {
        this.toggleCollapsed('[data-casediv]','collapsed');
        this.toggleCollapsed('[data-caseicon]','arrowExpanded');
    }

    toggleDocumentsDetailsSection() {
        this.toggleCollapsed('[data-docdiv]','collapsed');
        this.toggleCollapsed('[data-docicon]','arrowExpanded');
        this.showAddDocsModal = false;
    }

    toggleCollapsed(elem,cssclass){
        this.template.querySelector(elem).classList.toggle(cssclass);
    }

    handleClick(){
        //display modal on attachment component
        this.showAddDocsModal=true;
    }

}