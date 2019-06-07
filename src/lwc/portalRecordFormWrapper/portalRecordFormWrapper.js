/**
 * Created by pvavruska on 5/28/2019.
 */

import { LightningElement,api,track } from 'lwc';

import SaveLabel from '@salesforce/label/c.CSP_Save';
import CancelLabel from '@salesforce/label/c.CSP_Cancel';

export default class PortalRecordFormWrapper extends LightningElement {

    @api sectionClass;
    @api headerClass;
    @api sectionTitle;
    @api showEdit;
    @api fields;
    @api recordId;
    @api objectName;
    @api showEditModal = false;
    @api isLoading;

    @track isLoading = true;
    @track isLoadingEdit = true;
    @track isSaving = false;

    _labels = {SaveLabel,CancelLabel};
    get labels() {return this._labels;}
    set labels(value) {this._labels = value;}

     openModal(){this.showEditModal = true;}
     closeModal(){this.showEditModal = false;}

     loaded(){this.isLoading = false;}
     loadedEdit(){this.isLoadingEdit = false;}

     handleSucess(event){
         const updatedRecord = event.detail.id;
         this.isSaving = false;
         this.closeModal();
     }

     handleError(event){
         this.isSaving = false;
     }

     onRecordSubmit(event){
         this.isSaving = true;
     }
}