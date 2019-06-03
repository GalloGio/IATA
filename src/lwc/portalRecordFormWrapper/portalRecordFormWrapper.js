/**
 * Created by pvavruska on 5/28/2019.
 */

import { LightningElement,api,track } from 'lwc';

import SaveLabel from '@salesforce/label/c.CSP_Save';
import CancelLabel from '@salesforce/label/c.CSP_Cancel';

export default class PortalRecordFormWrapper extends LightningElement {

    @api sectionTitle;
    @api showEdit;
    @api fields;
    @api recordId;
    @api objectName;
    @api showEditModal = false;

    @track isLoading = true;
    @track isLoadingEdit = true;
    @track isSaving = false;

    _labels = {SaveLabel,CancelLabel};
    get labels() {return this._labels;}
    set labels(value) {this._labels = value;}

     openModal(){this.showEditModal = true;}
     closeModal(){this.showEditModal = false;}

     loaded(){this.isLoading = false;}//console.log('loadedview '+this.recordId);
     loadedEdit(){this.isLoadingEdit = false;}//console.log('loadedEdit '+this.recordId);

     handleSucess(event){
         const updatedRecord = event.detail.id;
         console.log('onsuccess: ', updatedRecord);
         //this.isSaving = false;
         }

     handleError(event){
         //this.isSaving = false;
         }

     doSubmit(){
         let form = this.template.querySelector('lightning-record-edit-form');
         if(form){
             console.log(form);
             try{
             form.submit();}catch(e){console.log(e);}
         }else{console.log('NO FORM');}
     }

     onRecordSubmit(event){
         event.preventDefault();
         /*event.preventDefault();
         let eventFields = event.detail.fields;
         console.log('fields: '+JSON.stringify(eventFields));}*/
         this.isSaving = true;
         }
}