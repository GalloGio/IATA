import { LightningElement,track } from 'lwc';

//apex methods
import getProviderPropertiesAndCardsList from '@salesforce/apex/PortalServicesInnovationHubCtrl.getProviderPropertiesAndCardsList';
import getProviderPropertiesAndEditCardsList from '@salesforce/apex/PortalServicesInnovationHubCtrl.getProviderPropertiesAndEditCardsList';
import saveProviderProfile from '@salesforce/apex/PortalServicesInnovationHubCtrl.saveProviderProfile';
import uploadFile from '@salesforce/apex/PortalServicesInnovationHubCtrl.uploadFile';
import saveLogoId from '@salesforce/apex/PortalServicesInnovationHubCtrl.saveLogoId';

//labels
import Comments from '@salesforce/label/c.CSP_CaseMessage_MessageTitle';
import Edit from '@salesforce/label/c.Edit';
import Cancel from '@salesforce/label/c.Cancel';
import Save from '@salesforce/label/c.Save';
import SaveAndSubmit from '@salesforce/label/c.CSP_SaveAndSubmit';
import EditProviderDetails from '@salesforce/label/c.CSP_EditProviderDetails';
import PublishedRecordPreview from '@salesforce/label/c.CSP_PublishedRecordPreview';
import MarkedForReview from '@salesforce/label/c.CSP_MarkedForReview';
import WaitingApproval from '@salesforce/label/c.CSP_WaitingApproval';
import ProviderDraftSaved from '@salesforce/label/c.CSP_ProviderDraftSaved';
import ProviderSaveAndSubmit from '@salesforce/label/c.CSP_ProviderSaveAndSubmit';
import ProviderWrongSubmit from '@salesforce/label/c.CSP_ProviderWrongSubmit';
import ProviderReviewComments from '@salesforce/label/c.CSP_ProviderReviewComments';

export default class PortalServicesInnovationHubEditTab extends LightningElement {

    @track propertiesAndAndCardsList = {};
    @track componentLoading = true;

    @track propertiesAndCardsListEdit = {};
    @track isSaving = false;
    @track hasError = false;
    @track isLoadingEdit = true;
    @track displaySaveTextSuccessModal = true;
    @track viewSubmitWarning = false;
    @track viewPublishedRecord = false;
    @track disableSave = false;
    @track viewComments = false;
    @track comments = '';
    @track markedForReview = false;
    @track mode = '';
    @track fileToUpload = '';
    @track logo = '';

    //modals visibility controllers
    @track showSuccessModal = false;
    @track showErrorModal = false;
    @track showEditModal = false;

    get hasFileToUpload() {
        return this.fileToUpload != null && this.fileToUpload != '';
    }

    get hasLogo() {
        return this.logo != null && this.logo != '';
    }

    labels = {
        Comments,
        Edit,
        Cancel,
        Save,
        SaveAndSubmit,
        EditProviderDetails,
        PublishedRecordPreview,
        MarkedForReview,
        WaitingApproval,
        ProviderDraftSaved,
        ProviderSaveAndSubmit,
        ProviderWrongSubmit,
        ProviderReviewComments,
    }

    //object to include extra fields
    extraFields = {};

    //input file fields
    fileData;

    processViewCards(){
        getProviderPropertiesAndCardsList({})
        .then(result => {
            var properties = JSON.parse(JSON.stringify(result));
            this.propertiesAndAndCardsList = properties;           

            var extraDetails = JSON.parse(properties.extraDetails);
            this.viewSubmitWarning = extraDetails.editButtonStatus === 'Submitted';
            this.viewPublishedRecord = extraDetails.viewStatus === 'Published';
            this.markedForReview = extraDetails.viewComments === 'Yes';
            this.componentLoading = false;
        });
    }

    connectedCallback() {
        this.processViewCards();
    }

    //Methods for the edit modal
    handleOpenEditModalButtonClick(event){
        getProviderPropertiesAndEditCardsList({})
        .then(result => {
            var properties = JSON.parse(JSON.stringify(result));
            this.propertiesAndCardsListEdit = properties;
            
            var extraDetails = JSON.parse(properties.extraDetails);
            this.disableSave = extraDetails.editStatus === 'Submitted';
            this.viewComments = extraDetails.viewComments === 'Yes';
            this.comments = extraDetails.comments;

            this.showEditModal = true;
            this.isLoadingEdit = false;
        });
    }

    handleCancelButtonEditModal(event){
        this.showEditModal = false;
    }

    handleSaveButtonClick(event){
        var buttonName = event.target.dataset.name;

        //set the mode for success popup text
        this.displaySaveTextSuccessModal = buttonName === 'save';
        this.mode = buttonName;
        this.isSaving = true;
    }

    handleSubmitForm(event){

        event.preventDefault();// stop the form from submitting
        var fields = JSON.parse(JSON.stringify(event.detail.fields));

        //get the extra fields (multipick values)
        for (var key of Object.keys(this.extraFields)) {
            fields[key] = this.extraFields[key];
        }
        fields.Id = this.propertiesAndCardsListEdit.recordId;

        //JSON object that contains the input for the apex method
        var inputVariables = {
            innoHubAccountRoleDetailsStr : JSON.stringify(fields),
            mode : this.mode
        };

        //save the form
        saveProviderProfile(inputVariables)
        .then(result => {

            if(this.fileData !== undefined && this.fileData !== null){
                //save the logo file
                var fileDataAux = this.fileData;
                fileDataAux.recordId = result;
                
                uploadFile(fileDataAux)
                .then(resultUpload=>{
                    saveLogoId({providerProfileId : result, contentDocumentId : resultUpload})
                    .then(resultSaveLogo => {
                        this.fileData = null;
                        this.isSaving = false;
                        this.handleCancelButtonEditModal();
                        this.handleSucess();

                    })
                    .catch(errorSaveLogo => {
                        console.log('uploadFile error: ' , errorSaveLogo);
                        this.isSaving = false;
                        this.handleCancelButtonEditModal();
                        this.handleError();
                    });

                })
                .catch(errorUploadFile => {
                    console.log('uploadFile error: ' , errorUploadFile);
                    this.isSaving = false;
                    this.handleCancelButtonEditModal();
                    this.handleError();
                });
            }else{
                this.isSaving = false;
                this.handleCancelButtonEditModal();
                this.handleSucess();
            }
        })
        .catch(error => {
            console.log('handleSubmitForm error: ' , error);
            this.isSaving = false;
            this.handleCancelButtonEditModal();
            this.handleError();
        });
    }

    //Method for input file
    openfileUpload(event) {
        let file = event.target.files[0];
        this.fileToUpload = file.name; 
        let reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1];
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            }
        }
        reader.readAsDataURL(file);
    }

    //Methods for the success modal
    handleSucess(event){
        this.showSuccessModal = true;
    }

    handleCloseSuccessPopup(event){
        this.showSuccessModal = false;
        this.componentLoading = true;
        this.processViewCards();
    }

    //Methods for the error modal
    handleError(event){
        this.showErrorModal = true;
    }

    handleCloseErrorPopup(event){
        this.showErrorModal = false;
        this.componentLoading = true;
        this.processViewCards();
    }

    //contains the event to update the extrafields object with the selected piclists in the provider object
    handleMultipickUpdate(event){
        const eventDetails = JSON.parse(JSON.stringify(event.detail));
        this.extraFields[eventDetails.fieldName] = eventDetails.fieldValue;
    }
    
}