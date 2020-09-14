import { LightningElement, api, track, wire } from 'lwc';
import { getUserType, getCase } from "c/tidsUserInfo";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import applicationSubmitted from "@salesforce/apex/TIDS_Controller.applicationSubmitted";
import { NavigationMixin,CurrentPageReference } from 'lightning/navigation';
import { setSectionsDone,getTidsInfo} from "c/tidsUserInfo";


export default class TidsSubmitApplication extends NavigationMixin(LightningElement) {
  @wire(CurrentPageReference) pageRef;

  @api tidsUserInfo;
  @track vettingMode;
  @track rejectButtonShow = false;
  @track tidsCase;
  @track portalUrl = '/csportal/s/';
  @track spinner = false;
  //Modal Window
  @track modalAction;
  @track showConfimationModal=false;
  @track modalDefaultMessage='';
  @track tidsInfo;

  connectedCallback() {
    this.tidsInfo = JSON.parse(JSON.stringify(getTidsInfo()));
    let userType = getUserType();
    this.tidsCase = getCase();
    this.vettingMode = userType === 'vetting' ? true : false;
  }
  handleSendApplication(event) {
	  event.preventDefault();
    this.spinner = true;
    this.showConfimationModal=false;
    console.log('applicationData', JSON.stringify(this.tidsInfo));
    let appType = this.tidsInfo.applicationType;
    let appSections='';
    if (appType === 'chg-business-profile-specialization'){appSections = JSON.stringify(this.tidsInfo);}
    console.log('appSections', appSections);
    console.log('appType', appType);
    applicationSubmitted({caseId: this.tidsCase.Id, applicationData:appSections, applicationType:appType})
    .then(result => {
      this.spinner = false;
      console.log('handleSendApplication result',JSON.stringify(result));
      if (result.hasAnError){
        console.log('handleSendApplication error',result.reason);
        this.modalDefaultMessage='Oops! something happened, please retry.'
        this.modalAction='OK';
        this.showConfimationModal=true;
      }else{
          console.log('setSectionsDone4');
          setSectionsDone([]);
          console.log('setSectionsDone4');
          this.dispatchEvent(
            new ShowToastEvent({
                title: 'Thank you',
                message: 'Your request has been submitted to IATA for review.',
                variant: 'success'
            })
          );
          //this.spinner = false;
          //let action = {type: 'Submitted'};
          //fireEvent(this.pageRef, "applicationDecisionListener", action);
          console.log('setSectionsDone4');
          this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'tids'
            },
          });
      }
     })
    .catch(error => {
      console.log('error',JSON.stringify(error));
      this.oops(error);
    });
  }
  oops(error){
    this.spinner = false;
    console.log('submit application error',error);
    this.modalDefaultMessage='Oops! something happened, please retry.'
    this.modalAction='OK';
    this.showConfimationModal=true;
  }
}