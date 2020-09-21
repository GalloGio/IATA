import { LightningElement, wire, api } from 'lwc';

import tidsTitle from '@salesforce/label/c.tids_title';
import tidsFormSubtitle from '@salesforce/label/c.tids_form_subtitle_description';
import tidsFormDescription from '@salesforce/label/c.tids_form_description';
import tidsFormBeforeStartTitle from '@salesforce/label/c.tids_form_before_start_title';
import tidsFormBeforeStartDescription from '@salesforce/label/c.tids_form_before_start_description';
import tidsFormStepsTitle from '@salesforce/label/c.tids_form_steps_title';
import tidsFormDocumentsAvailable from '@salesforce/label/c.tids_form_documents_available';
import tidsFormTCLegend from '@salesforce/label/c.tids_form_tc_legend';
import tidsFormTCLinkLabel from '@salesforce/label/c.tids_form_tc_link_label';
import tidsFormServiceButton from '@salesforce/label/c.tids_form_service_button';

// Show alert message using ShowToastEvent
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

// Publish pattern
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/tidsPubSub';
import { getUserInfo } from 'c/tidsUserInfo';

export default class TidsWelcome extends LightningElement {
  @wire(CurrentPageReference) pageRef;

  steps = ['Documentation supporting legal form of business and ownership of the business entity'
  ,'Copy of business registration including tax registration/other business registration number','Bank letter stating that you maintain a bank account in the name of the business','One letter of recommendation from an IATA Airline or GDS or a major industry supplier','Step5'];
  documents = ['Document 1','Document 2','Document 3','Document 4','Document 5','Document 6'];

  @api allDocuments;
  @api termsandConditions;
  @api disableButton;

  label = {
    tidsTitle,
    tidsFormSubtitle,
    tidsFormDescription,
    tidsFormBeforeStartTitle,
    tidsFormBeforeStartDescription,
    tidsFormStepsTitle,
    tidsFormDocumentsAvailable,
    tidsFormTCLegend,
    tidsFormTCLinkLabel,
    tidsFormServiceButton
  }

  connectedCallback() {
    this.disableButton = true;
    let myUserInfo = getUserInfo();
  }

  handleOnClick(event) {
    if ( event.target.name === 'allDocuments' ) {
      this.allDocuments = event.target.checked;
    } else if ( event.target.name === 'termsAndConditions' ) {
      this.termsandConditions = event.target.checked;
    }
    this.disableButton = this.allDocuments && this.termsandConditions ? false : true;
  }

  handleGoToServices(event) {
    if( this.termsandConditions !== false && this.allDocuments !== false ) {
      fireEvent(this.pageRef, 'formListener', {section: 'form'});
    } else {
      const eventToast = new ShowToastEvent({
        "title": "Warning!",
        "variant": "warning",
        "message": "All documents and Terms and Condition must be selected."
      });
      this.dispatchEvent(eventToast);
    }
  }

}