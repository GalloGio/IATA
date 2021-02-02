import { LightningElement,track } from 'lwc';

//apex methods
import getProviderPropertiesAndCardsList from '@salesforce/apex/PortalServicesInnovationHubCtrl.getProviderPropertiesAndCardsList';
import getProviderPropertiesAndEditCardsList from '@salesforce/apex/PortalServicesInnovationHubCtrl.getProviderPropertiesAndEditCardsList';
import saveProviderProfile from '@salesforce/apex/PortalServicesInnovationHubCtrl.saveProviderProfile';

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

    //modals visibility controllers
    @track showSuccessModal = false;
    @track showErrorModal = false;
    @track showEditModal = false;

    //object to include extra fields
    extraFields = {};

    processViewCards(){
        getProviderPropertiesAndCardsList({})
        .then(result => {
            console.log('view card: ',  JSON.parse(JSON.stringify(result)) );

            var properties = JSON.parse(JSON.stringify(result));
            this.propertiesAndAndCardsList = properties;

            var extraDetails = JSON.parse(properties.extraDetails);
            console.log('extraDetails', extraDetails);
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
            console.log('edit card: ',  JSON.parse(JSON.stringify(result)));
            this.propertiesAndCardsListEdit = properties;
            
            var extraDetails = JSON.parse(properties.extraDetails);
            console.log('extraDetails', extraDetails);
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

    handleSubmitForm(event){
        event.preventDefault();// stop the form from submitting
        var fields = JSON.parse(JSON.stringify(event.detail.fields));
        var buttonName = event.target.dataset.buttonname;
        console.log('buttonName: ', buttonName);

        //set the mode for success popup text
        this.displaySaveTextSuccessModal = buttonName === 'save';

        //get the extra fields (multipick values)
        console.log('extraFields', this.extraFields);
        for (var key of Object.keys(this.extraFields)) {
            fields[key] = this.extraFields[key];
        }
        console.log('fields: ', fields);
        fields.Id = this.propertiesAndCardsListEdit.recordId;

        //JSON object that contains the input for the apex method
        var inputVariables = {
            innoHubAccountRoleDetailsStr : JSON.stringify(fields),
            mode : buttonName
        };

        saveProviderProfile(inputVariables)
        .then(result => {
            this.handleCancelButtonEditModal();
            this.handleSucess();
        })
        .catch(error => {
            console.log('handleSubmitForm error: ' , error);
            this.handleCancelButtonEditModal();
            this.handleError();
        });
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