import { LightningElement, track, api, wire } from 'lwc';
// TIDS User Info
import { 
  getUserInfo
} from 'c/tidsUserInfo';
// Pubsub libraries
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent,registerListener,unregisterListener } from "c/tidsPubSub";
// Salesforce Apex Methods
import createTidsRequestRelinquish from '@salesforce/apex/TIDSHelper.createTidsRequestRelinquish';
export default class TidsRequestVirtualBranch extends LightningElement {
  @api accountInfo;
  
  @wire(CurrentPageReference) pageRef;
  @api branchSelected=false;
  @api vbSelected=false;
  @track proceedDisabled = true;
  @track cmpName = 'RequestVirtualBranchService';
  @track reason;
  @track counter=0;
  //Modal Window
  @track isRequestExist=false;
  @track showConfimationModal=false;
  @track msgpayload;
  @track modalDefaultMessage='Be aware, you are about to relinquish the TIDS participation. Please Confirm?';
  @track modalAction = "RELINQUISH";

  connectedCallback() {
    //unregisterListener("relinquishNow", this.relinquishNow, this);
    registerListener('relinquishNow',this.relinquishNow,this);
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
  
  relinquishNow(props){
    this.counter++;
    console.log('counter',this.counter);
    console.log('props',JSON.stringify(props));
    fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
    let applicationtp='ho';
    console.log('this.branchSelected',this.branchSelected);
    console.log('this.vbSelected',this.vbSelected);
    console.log('this.accountInfo',JSON.stringify(this.accountInfo));
    let loctype = this.accountInfo.Location_Type__c;
    console.log('loctype ver3',loctype);
    if (loctype==="BR"){
       applicationtp='br';
    }else if (loctype==="VB"){
      applicationtp='vb';
    }
    this.showConfimationModal=false;
    console.log('applicationtp',applicationtp);
    createTidsRequestRelinquish({
        accountId: props.payload.accountId,
        reason: props.payload.reason,
        applicationType:applicationtp
      }).then(result => {
        console.log('relinquish ok');
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
}