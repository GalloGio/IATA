import { LightningElement, track, api } from 'lwc';

import { navigateToPage } from 'c/navigationUtils';

import getCaseById from '@salesforce/apex/PortalCasesCtrl.getCaseById';
import getFieldLabels from '@salesforce/apex/CSP_Utils.getSelectedColumns';

import getSurveyLink from '@salesforce/apex/PortalCasesCtrl.getSurveyLink';
import optionBuilder from '@salesforce/apex/PortalCasesCtrl.optionBuilder';


import { getParamsFromPage } from 'c/navigationUtils';

/* Importing labels*/
import AddDocumentsMsg from '@salesforce/label/c.CSP_No_Documents_Message';
import DocumentsLabel from '@salesforce/label/c.ISSP_Documents';
import CaseDetails from '@salesforce/label/c.IDCard_CaseDetails';
import RelatedAccount from '@salesforce/label/c.csp_CreateNewCaseMainPicklistLabel';
import ISSP_Survey from '@salesforce/label/c.ISSP_Survey';
import Open from '@salesforce/label/c.Open';

import Email from '@salesforce/label/c.Email';
import CSP_Remittantce_Date from '@salesforce/label/c.CSP_Remittantce_Date';
import CSP_Case_Currency from '@salesforce/label/c.CSP_Case_Currency';
import ISSP_SIDRA_Irregularity_Date from '@salesforce/label/c.ISSP_SIDRA_Irregularity_Date';
import CSP_IATA_Country from '@salesforce/label/c.CSP_IATA_Country';


/* PDF Labels */
import ISSP_AMS_Download_PDF_Copy from '@salesforce/label/c.ISSP_AMS_Download_PDF_Copy';
import ISSP_AMS_Download_PDF_NOC from '@salesforce/label/c.ISSP_AMS_Download_PDF_NOC';


import PDFICON from '@salesforce/resourceUrl/PDF_icon_large';

export default class PortalCaseDetailsDetails extends LightningElement {

    @track loading = true;
    @track caseDetails;
    @track caseId;
    @track surveyLink;
    @track optionBuilder;

    @track pdfImage = PDFICON;

    @track showAddDocsModal = false;


    @track nrDocs = 0;

    @track labels = {
        AddDocumentsMsg,
        CaseDetails,
        DocumentsLabel,
        RelatedAccount,
        ISSP_AMS_Download_PDF_Copy,
        ISSP_AMS_Download_PDF_NOC,
		ISSP_Survey,
        Open,
        Email,
        CSP_Remittantce_Date,
        CSP_Case_Currency,
        ISSP_SIDRA_Irregularity_Date,
        CSP_IATA_Country
    };

    acceptedFormats = ['.pdf', '.jpeg', '.jpg', '.png', '.ppt', '.pptx', '.xls', '.xlsx', '.tif', '.tiff', '.zip'];



    connectedCallback() {
        //get the parameters for this page
        this.pageParams = getParamsFromPage();

        if (this.pageParams.caseId !== undefined) {
            this.caseId = this.pageParams.caseId;
            getCaseById({ caseId: this.pageParams.caseId })
                .then(results => {
                    this.caseDetails = results;

                    optionBuilder({ caseObj: results })
                        .then(result => {
                            this.optionBuilder = result;
                        });

                    this.loading = false;
                    this.getSurveyLink();
                })
                .catch(error => {
                    console.log('error: ', error);
                    this.loading = false;
                });
            const labelsToRetrieve = ["Country_concerned__c", "Topic__c", "Subtopic__c", "Region__c", "Type_of_case_Portal__c", "Description"];
            //load the rest of the field labels

            getFieldLabels({ sObjectType: 'case', sObjectFields: labelsToRetrieve }).then(result => {
                if (result) {
                    let currentLabels = this.labels;
                    Object.keys(result).forEach(el => {       // adds retrieved labels to current label variable               
                        currentLabels[el] = result[el];
                    })
                    this.labels = currentLabels;
                }

            });
        }
        
    }

    renderedCallback() {

        if (this.pageParams.Att !== undefined && this.pageParams.Att === "true") {
            //display modal on attachment component
            this.toggleCollapsed('[data-docdiv]', 'collapsed');
            this.toggleCollapsed('[data-docicon]', 'arrowExpanded');
            this.showAddDocsModal = true;
            this.pageParams.Att = "";
            console.log('open sayz me!');
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
        return this.caseDetails !== undefined && this.caseDetails.Description !== undefined && !(this.caseDetails.RecordType.Name === 'SAAM' || this.caseDetails.RecordType.Name === 'OSCAR Communication' || this.caseDetails.RecordType.Name === 'SIDRA');
    }

    get showNrDocs() {
        return this.nrDocs > 0;
    }
    get hasSurveyLink() {
        return this.surveyLink !== undefined && this.surveyLink.length > 0;
    }

    get hasAccount() {
        return this.caseDetails !== undefined && this.caseDetails.AccountId !== undefined;
    }

    openCompanyProfile() {
        navigateToPage("company-profile");
    }

    get hasContact() {
        return this.caseDetails !== undefined && this.caseDetails.ContactId !== undefined;
    }

    openCompanyProfileContactTab() {
        navigateToPage("company-profile?tab=contact&contactName=" + this.caseDetails.Contact.FirstName + ' ' + this.caseDetails.Contact.LastName);
    }

    get getDisplayPDF() {
        let caseDetailsLocal = this.caseDetails;

        if (this.optionBuilder) {
            return this.optionBuilder.isOnlineOSCARCase && this.optionBuilder.showAccreditation && !this.optionBuilder.isMSOcase && caseDetailsLocal.Reason1__c !== 'FoP Management' && caseDetailsLocal.Reason1__c !== 'PCI DSS Compliant' && caseDetailsLocal.Reason1__c !== 'CLO - Closure' &&
                caseDetailsLocal.Reason1__c !== 'New MSO' && caseDetailsLocal.Reason1__c !== 'Financial review opt-in / opt-out' &&
                caseDetailsLocal.Reason1__c !== 'Annual revalidation';
        }
        return null;
    }

    get getPDF1() {

        let caseDetailsLocal = this.caseDetails;
        if (this.optionBuilder) {
            return this.optionBuilder.isOnlineOSCARCase && this.optionBuilder.showAccreditation &&
                caseDetailsLocal.Reason1__c.startsWith('New') && caseDetailsLocal.Reason1__c !== 'New HE standard' &&
                caseDetailsLocal.Reason1__c !== 'New HE lite' && caseDetailsLocal.Reason1__c !== 'New AE';
        }
        return null;
    }

    get getPDFLink1() {
        if (this.optionBuilder) {
            let link = '';
            if (this.optionBuilder.isTravelAccreditation) {
                link = '/ISSP_AMS_PDF_ApplicationForm?caseId=' + this.caseDetails.Id;
            } else {
                link = '/ISSP_AMS_PDF_CGO?caseId=' + this.caseDetails.Id;
            }

            return link;
        }
        return null;
    }

    get getPDF2_3() {
        if (this.caseDetails) {
            return this.caseDetails.Reason1__c === 'Bank Detail Update' || this.caseDetails.Reason1__c.startsWith('CH') ||
                this.caseDetails.Reason1__c.startsWith('CL') || this.caseDetails.Reason1__c === 'Major Change';
        }
        return null;
    }

    get getPDFLink2_3() {
        if (this.optionBuilder) {
            let link = this.optionBuilder.fullnameNOCFile;
            return link;
        }
        return null;
    }

    get getPDF4() {
        if (this.caseDetails) {
            return this.caseDetails.Reason1__c === 'New HE standard' || this.caseDetails.Reason1__c === 'New HE lite';
        }
        return null;
    }

    get getPDFLink4() {
        if (this.optionBuilder) {
            let link = '/ISSP_AMS_PDF_ANG_PAX_HE?caseId=' + this.caseDetails.Id;
            return link;
        }
        return null;
    }

    get getPDF5() {
        if (this.caseDetails) {
            return this.caseDetails.Reason1__c === 'New AE';
        }
        return null;
    }

    get getPDFLink5() {
        if (this.optionBuilder) {
            let link = '/ISSP_AMS_PDF_ANG_PAX_AE?caseId=' + this.caseDetails.Id;
            return link;
        }
        return null;
    }


    updateNdocs(event) {
        //sets nr of docs in panel
        this.nrDocs = event.detail.ndocs;
    }

    toggleCaseDetailsSection() {
        this.toggleCollapsed('[data-casediv]', 'collapsed');
        this.toggleCollapsed('[data-caseicon]', 'arrowExpanded');
    }

    toggleDocumentsDetailsSection() {
        this.toggleCollapsed('[data-docdiv]', 'collapsed');
        this.toggleCollapsed('[data-docicon]', 'arrowExpanded');
        this.showAddDocsModal = false;
    }

    toggleCollapsed(elem, cssclass) {
        this.template.querySelector(elem).classList.toggle(cssclass);
    }

    handleClick() {
        //display modal on attachment component
        this.showAddDocsModal = true;
    }

    getSurveyLink(){
        getSurveyLink({ caseId: this.caseId })
            .then(result => {
                this.surveyLink = result;
            })
            .catch(error => {
                this.surveyLink = undefined;
            });
    }

}
