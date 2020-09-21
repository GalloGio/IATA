import { LightningElement, track, api, wire } from 'lwc';
// TIDS User Info
import { 
  getUserInfo
} from 'c/tidsUserInfo';
// Pubsub libraries
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent,registerListener,unregisterListener } from "c/tidsPubSub";
// Salesforce Apex Methods
import createTidsRequestReinstate from '@salesforce/apex/TIDSHelper.createTidsRequestReinstate';
export default class TidsReinstate extends LightningElement {
  @api accountInfo;
  
  @wire(CurrentPageReference) pageRef;
  @api branchSelected=false;
  @api vbSelected=false;
  @track proceedDisabled = true;
  @track cmpName = 'ReinstateService';
  @track reason;
  //Modal Window
  @track isRequestExist=false;
  @track showConfimationModal=false;
  @track msgpayload;
  @track inputmsg="";
  @track modalDefaultMessage='Be aware, you are about to reinstate the TIDS participation. Please Confirm?';
  @track modalAction = "REINSTATE";

  connectedCallback() {
    this.setinputmsg();
    //unregisterListener("reinstateNow", undefined, undefined); 
    registerListener('reinstateNow',this.reinstateNow,this);
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
    let userInfo = getUserInfo();
    let accountId = userInfo.tidsAccount.Id;
    if (this.accountInfo!=undefined){
       if (this.accountInfo.Id!=undefined){
        accountId=this.accountInfo.Id;
       }
    }
    console.log('this.accountInfo',JSON.stringify(this.accountInfo));
    this.msgpayload = {
        accountId: accountId,
        reason: this.reason
      }
    this.showConfimationModal=true;
  }

  reinstateNow(props){
    console.log('props',JSON.stringify(props));
    fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
    let applicationtp='ho';
    if (this.branchSelected){
        applicationtp='br';
        if (this.vbSelected){applicationtp='vb';}
    }
    this.showConfimationModal=false;
    console.log('applicationtp',applicationtp);
    createTidsRequestReinstate({
        accountId: props.payload.accountId,
        reason: props.payload.reason,
        applicationType:applicationtp
      }).then(result => {
        console.log('reinstatement ok');
        fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
        this.modalDefaultMessage='Thank you! Your request has been posted and will need to be approved by IATA Staff.';
        this.showConfimationModal=true;
        this.modalAction = "OK_CANCEL";
      }).catch(error => {
        console.log(error);
        fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
        this.modalDefaultMessage='Sorry we have not been able to post your request, try later.';
        this.showConfimationModal=true;
        this.modalAction = "OK_CANCEL";
      });
  }
  handleCancel(event){
    // Prevents the anchor element from navigating to a URL and return to dashboard.
    event.preventDefault();
    console.log('this.branchSelected',this.branchSelected);
    fireEvent(this.pageRef,'manageMenuListener', {type:'SELECT_CANCEL',payload:null});
  }
  setinputmsg(){
    this.inputmsg="Please describe why you are requesting a reinstatement of your TIDS Participation:";
    if (this.branchSelected){
        this.inputmsg="Please describe why you are requesting a reinstatement of your TIDS Branch Office:";
        if (this.vbSelected){
          this.inputmsg="Please describe why you are requesting a reinstatement of your TIDS Virtual Branch:";
        }
    }
  }
}