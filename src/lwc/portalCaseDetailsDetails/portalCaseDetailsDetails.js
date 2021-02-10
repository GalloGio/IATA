import { LightningElement, track,api,wire } from 'lwc';

import { navigateToPage } from 'c/navigationUtils';

import getCaseById from '@salesforce/apex/PortalCasesCtrl.getCaseById';
import getFieldLabels from '@salesforce/apex/CSP_Utils.getSelectedColumns';
import optionBuilder from '@salesforce/apex/PortalCasesCtrl.optionBuilder';


import { getParamsFromPage } from 'c/navigationUtils';

/* Importing labels*/
import AddDocumentsMsg from '@salesforce/label/c.CSP_No_Documents_Message';
import DocumentsLabel from '@salesforce/label/c.ISSP_Documents';
import CaseDetails from '@salesforce/label/c.IDCard_CaseDetails';
import RelatedAccount from '@salesforce/label/c.csp_CreateNewCaseMainPicklistLabel';
import Open from '@salesforce/label/c.Open';

import Email from '@salesforce/label/c.Email';
import CSP_Remittantce_Date from '@salesforce/label/c.CSP_Remittantce_Date';
import CSP_Case_Currency from '@salesforce/label/c.CSP_Case_Currency';
import ISSP_SIDRA_Irregularity_Date from '@salesforce/label/c.ISSP_SIDRA_Irregularity_Date';
import CSP_IATA_Country from '@salesforce/label/c.CSP_IATA_Country';
import CSP_AdditionalDetails from '@salesforce/label/c.csp_AdditionalDetails';
import ISSP_Description from '@salesforce/label/c.ISSP_Description';
import CSP_ContactName from '@salesforce/label/c.Contact_Name';
import CSP_AccountName from '@salesforce/label/c.ICCS_Account_Name_Label';
import CSP_Case_hasInvoicePaid from '@salesforce/label/c.CSP_Case_hasInvoicePaid';

/* PDF Labels */
import ISSP_AMS_Download_PDF_Copy from '@salesforce/label/c.ISSP_AMS_Download_PDF_Copy';
import ISSP_AMS_Download_PDF_NOC from '@salesforce/label/c.ISSP_AMS_Download_PDF_NOC';
import ISSP_Certificate_was_uploaded_satisfactory from '@salesforce/label/c.ISSP_Certificate_was_uploaded_satisfactory';


import PDFICON from '@salesforce/resourceUrl/PDF_icon_large';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const newAE = 'New AE';
const newHE = 'New HE';

export default class PortalCaseDetailsDetails extends LightningElement {

    @track loading = true;
    @track caseDetails;
    @track caseId;
    @track surveyLink;
    @track optionBuilder;

    @track pdfImage = PDFICON;

    @track showAddDocsModal = false;


    @track nrDocs = 0;

    @track showNewDescriptionSection = false;
    @track isCollapsedWhenNewDescriptionInPlace = "slds-p-around_medium ";
    @track trackedIsExpired = false;
    @track trackedIsExpiredDGR = false;
    @track isICollectionCase;

    @api
    get isexpired() {
        return this.trackedIsExpired;
    }
    set isexpired(value) {
        this.trackedIsExpired = value;
	}
    @api
    get isexpireddgr() {
        return this.trackedIsExpiredDGR;
    }
    set isexpireddgr(value) {
        this.trackedIsExpiredDGR = value;
	}
	@track israelCase;
	
	@track caseobres;

    @track labels = {
        AddDocumentsMsg,
        CaseDetails,
        DocumentsLabel,
        RelatedAccount,
        Open,
        ISSP_AMS_Download_PDF_Copy,
        ISSP_Certificate_was_uploaded_satisfactory,
        ISSP_AMS_Download_PDF_NOC,
        Email,
        CSP_Remittantce_Date,
        CSP_Case_Currency,
        ISSP_SIDRA_Irregularity_Date,
        CSP_IATA_Country,
        CSP_AdditionalDetails,
		ISSP_Description,
		CSP_ContactName,
        CSP_AccountName,
        CSP_Case_hasInvoicePaid
    };

    acceptedFormats = '.pdf, .jpeg, .jpg, .png, .ppt, .pptx, .xls, .xlsx, .tif, .tiff, .zip, .doc, .docx';

    @track certificateUploaded = false;

    connectedCallback() {
        //get the parameters for this page
        this.pageParams = getParamsFromPage();

        if (this.pageParams.caseId !== undefined) {
            this.caseId = this.pageParams.caseId;
			this.loadCase();
			
            const labelsToRetrieve = ["Country_concerned__c", "Topic__c", "Subtopic__c", "Region__c", "Type_of_case_Portal__c", "Description", "Airline__c", "Airline_E_mail__c", "Document_number__c", "Amount_disputed__c"];
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
        
        if(this.pageParams.uploaded !== undefined && this.pageParams.uploaded == "true"){
            this.certificateUploaded = true;
        }
        
	}
	
	loadCase() {
		getCaseById({ caseId: this.caseId })
                .then(results => {
                    this.caseDetails = results;

                    this.showNewDescriptionSection = this.caseDetails.RecordType__c === 'Cases - Africa & Middle East'
                        || this.caseDetails.RecordType__c === 'Cases - Americas'
                        || this.caseDetails.RecordType__c === 'Cases - Asia & Pacific'
                        || this.caseDetails.RecordType__c === 'Cases - China & North Asia'
                        || this.caseDetails.RecordType__c === 'Cases - Europe'
                        || this.caseDetails.RecordType__c === 'Cases - Global'
                        || this.caseDetails.RecordType__c === 'Complaint (IDFS ISS)'
                        || this.caseDetails.RecordType__c === 'Process';

					this.israelCase = this.caseDetails.RecordType__c === 'Disputes (Israel only)';

                    this.isCollapsedWhenNewDescriptionInPlace = this.showNewDescriptionSection ? "slds-p-around_medium collapsed " : "slds-p-around_medium ";                
                    this.isICollectionCase = this.caseDetails.RecordType.Name === 'Invoicing Collection Cases'; 

                    optionBuilder({ caseObj: results })
                        .then(result => {
                            this.optionBuilder = result;
                        });

                    this.loading = false;

                    if(this.certificateUploaded == true){
                        const evt = new ShowToastEvent({
                            message: this.labels.ISSP_Certificate_was_uploaded_satisfactory,
                            variant: "success",
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                    }
                    
                })
                .catch(error => {
                    console.log('error: ', error);
                    this.loading = false;
                });
    }

    renderedCallback() {

        if (this.pageParams.Att !== undefined && this.pageParams.Att === "true") {
            //display modal on attachment component
            this.toggleCollapsed('[data-docdiv]', 'collapsed');
            this.toggleCollapsed('[data-docicon]', 'arrowExpanded');
            this.showAddDocsModal = true;
            this.pageParams.Att = "";
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

    get hasPaidInvoice() {
        return this.caseDetails !== undefined && this.caseDetails.Has_the_agent_paid_invoice__c !== undefined && this.caseDetails.RecordType.Name === 'Invoicing Collection Cases';
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
                caseDetailsLocal.Reason1__c.startsWith('New') && !caseDetailsLocal.Reason1__c.startsWith(newAE) && !caseDetailsLocal.Reason1__c.startsWith(newHE);
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
        if (this.caseDetails && this.optionBuilder) {
            return this.caseDetails.Reason1__c === 'Bank Detail Update' || this.caseDetails.Reason1__c.startsWith('CH') || this.caseDetails.Reason1__c.startsWith('CL') || this.caseDetails.Reason1__c === 'Major Change' || this.optionBuilder.isNoticeOfChange;
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
            return this.caseDetails.Reason1__c.startsWith(newHE);
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
            return this.caseDetails.Reason1__c.startsWith(newAE);
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
        if(this.nrDocs == 0 && this.trackedIsExpired){   
            this.template.querySelector('[data-docicon]').setAttribute('class', 'hideDocsIcon');
        } 

    }

    toggleCaseDetailsSection() {
        this.toggleCollapsed('[data-casediv]', 'collapsed');
        this.toggleCollapsed('[data-caseicon]', 'arrowExpanded');
    }

    toggleDocumentsDetailsSection() {
        if(!this.trackedIsExpired){
            this.toggleCollapsed('[data-docdiv]', 'collapsed');
            this.toggleCollapsed('[data-docicon]', 'arrowExpanded');
            this.showAddDocsModal = false;
        } else{
            if(this.nrDocs != 0) {
                this.toggleCollapsed('[data-docdiv]', 'collapsed');
                this.toggleCollapsed('[data-docicon]', 'arrowExpanded');
                this.showAddDocsModal = false;
            }
        }
    }

    toggleDescriptionSection() {
        this.toggleCollapsed('[data-detdiv]', 'collapsed');
        this.toggleCollapsed('[data-deticon]', 'arrowExpanded');
    }

    toggleCollapsed(elem, cssclass) {
        this.template.querySelector(elem).classList.toggle(cssclass);
    }

    handleClick() {
        //display modal on attachment component
        this.showAddDocsModal = true;
    }
	
	handleUpdatedCase(event) {
		this.loadCase();
	}
}