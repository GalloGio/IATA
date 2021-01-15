import { LightningElement,track } from 'lwc';

//apex methods
import getProviderPropertiesAndCardsList from '@salesforce/apex/PortalServicesInnovationHubCtrl.getProviderPropertiesAndCardsList';

export default class PortalServicesInnovationHubEditTab extends LightningElement {

    @track propertiesAndAndCardsList = {};
    @track componentLoading = true;

    @track propertiesAndCardsListEdit = {};

    //modals visibility controllers
    @track showSuccessModal = false;
    @track showErrorModal = false;
    @track showEditModal = false;

    connectedCallback() {

        getProviderPropertiesAndCardsList({})
        .then(result => {
            this.propertiesAndAndCardsList = JSON.parse(JSON.stringify(result));
            this.componentLoading = false;
        });

    }

    renderedCallback(){
        let cenas2 = JSON.parse(JSON.stringify(this.template.querySelector('lightning-output-field')));
        console.log('renderedcallback', cenas2);
    }

    handleOpenEditModalButtonClick(event){
        getProviderPropertiesAndEditCardsList({})
        .then(result => {
            this.propertiesAndAndCardsList = JSON.parse(JSON.stringify(result));
            this.showEditModal = true;
        });
    }

    handleCancelButtonEditModal(event){

    }

    handleSaveButtonEditModal(event){

    }

    handleSubmitButtonEditModal(event){

    }
    
}