import { LightningElement, track, api, wire } from 'lwc';
// TIDS User Info
import { 
  getUserInfo
} from 'c/tidsUserInfo';
// Pubsub libraries
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent } from "c/tidsPubSub";
// Salesforce Apex Methods
import createTidsRequestVirtualBranch from '@salesforce/apex/TIDSHelper.createTidsRequestVirtualBranch';
export default class TidsRequestVirtualBranch extends LightningElement {
  @api accountInfo;
  
  @wire(CurrentPageReference) pageRef;
  @track proceedDisabled = true;
  @track cmpName = 'RequestVirtualBranchService';
  @track reason;
  //Modal Window
  @track isRequestExist=false;
  @track showConfimationModal=false;
  @track modalDefaultMessage='Thank you. Your request has been submitted to IATA.';
  @track modalAction = "SELECT_CANCEL";

  connectedCallback() {
  
  }
  
  changeField(event) {
    if (event.target.name === "reason") {
      this.proceedDisabled = false;
      this.reason = event.target.value;
      if (this.reason===undefined || this.reason===''){
        this.proceedDisabled = true;
     }
    }
  }

  handleProceed(event) {
    event.preventDefault();
    fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
    let userInfo = getUserInfo();
    let payload = this.reason;
    let accountId = userInfo.tidsAccount.Id;
    createTidsRequestVirtualBranch({
      accountId: accountId,
      payload: payload
    }).then(result => {
      fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
      this.showConfimationModal=true;
    }).catch(error => {
      console.log(error);
      fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
    })
  }

  handleCancel(event){
    // Prevents the anchor element from navigating to a URL and return to dashboard.
    event.preventDefault();
    fireEvent(this.pageRef,'manageMenuListener', {type:'SELECT_CANCEL',payload:null});
  }
}