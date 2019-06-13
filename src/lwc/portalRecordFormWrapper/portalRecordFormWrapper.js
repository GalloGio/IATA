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
    @api editFields;
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
     loadedEdit(){
         this.isLoadingEdit = false;
         this.styleInputs();
     }

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

     get haveEditFields(){
         return this.editFields != null;
     }

     styleInputs(){
         let inputs = this.template.querySelectorAll('lightning-input-field');
          if(inputs){
              if(inputs.length){
                 for(let i = 0;i<inputs.length;i++){
                     //console.log(inputs[i].children)
                     if(!inputs[i].disabled){
                         if(inputs[i].value == null || inputs[i].value.length == 0){

                             if(inputs[i].classList){
                                 inputs[i].classList.add('whiteBackgroundInput');
                             }else{
                                 inputs[i].classList = ['whiteBackgroundInput'];
                             }
                         }else{
                             if(inputs[i].classList){
                                  inputs[i].classList.remove('whiteBackgroundInput');
                              }
                         }
                     }
                 }
              }else{
                  if(!inputs.disabled){
                      if(inputs.value == null || inputs.value.length == 0){
                          if(inputs.classList){
                              inputs.classList.add('whiteBackgroundInput');
                          }else{
                              inputs.classList = ['whiteBackgroundInput'];
                          }
                      }else{
                           if(inputs.classList){
                                inputs.classList.remove('whiteBackgroundInput');
                            }
                      }
                  }
              }

          }
     }
}