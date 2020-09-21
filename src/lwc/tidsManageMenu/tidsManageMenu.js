import { LightningElement, wire, api, track } from 'lwc';
// Pubsub pattern
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent } from "c/tidsPubSub";
import isTidsRequestPending from '@salesforce/apex/TIDSHelper.isTidsRequestPending';

export default class TidsManageMenu extends LightningElement {
  @wire(CurrentPageReference) pageRef;
  @api branchSelected=false;
  @api showNoOption;
  @api accountInfo;
  @api isReinstatement=false;
  @api vbSelected=false;
  @api enableAdministration=false;
  @track isVirtual=false;
  @track isRequestVirtualBranch=false;
  @track modalAction;

  //Modal Window
  @track isRequestExist=false;
  @track showConfimationModal=false;
  @track modalDefaultMessage='There is already a request pending review to allow you access to the TIDS Virtual Branch Service.';
 
  isVirtualAllowed() {
    if (this.accountInfo==undefined) return;
    if (this.accountInfo.Accreditation__r==undefined) return;
    this.isVirtual=true;
  }

  isRequestVirtualBranchAllowed() {
    if (this.isVirtualAllowed()===true){
      this.isRequestVirtualBranch=false;
      console.log('this.isRequestVirtualBranch',this.isRequestVirtualBranch);
    }else{
      if (this.accountInfo==undefined) return;
      if (this.accountInfo.Agency_Profiles__r==undefined) return;
      this.isRequestVirtualBranch=true;
    }
  }


  connectedCallback() {
    this.isVirtualAllowed();
    this.isRequestVirtualBranchAllowed();
  }
  handleAdminHO(event){
    event.preventDefault();
    this.triggerEvent({type:'ADMIN',payload:{detail:this.accountInfo}});
  }
  handleAdminBR(event){
    event.preventDefault();
    this.triggerEvent({type:'ADMIN',payload:{detail:this.accountInfo}});
  }
  
  handleReportChanges(event) {
    event.preventDefault();
    this.triggerEvent({type:'REPORT_CHANGES',payload:{detail:this.accountInfo}});
  }

  handleReportBranchChanges(event) {
    event.preventDefault();
    this.triggerEvent({type:'REPORT_BRANCH_CHANGES',payload:{detail:this.accountInfo}});
  }

  handleAddBranch(event) {
    event.preventDefault();
    this.triggerEvent({type:'ADD_BRANCH',payload:{detail:this.accountInfo}});
  }
  handleReinstate(event) {
    event.preventDefault();
    this.handleRequestReinstate('REINSTATE');
  }
  handleRelinquishHO(event) {
    event.preventDefault();
    this.handleRequestRelinquishment('RELINQUISHHO');
  }
  handleRelinquishVB(event) {
    event.preventDefault();
    this.handleRequestRelinquishment('RELINQUISHVB');
  }
  handleRelinquishBR(event) {
    event.preventDefault();
    this.handleRequestRelinquishment('RELINQUISHBR');
  }
  handleAddVirtualBranch(event) {
    event.preventDefault();
    this.triggerEvent({type:'ADD_VIRTUAL_BRANCH',payload:{detail:this.accountInfo}});
  }
  oops(error){
    fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
    console.log(' fetchRoles error',error);
    this.modalDefaultMessage='Oops! something happened, please retry.'
    this.modalAction='OK';
    this.showConfimationModal=true;
  }
  handleRequestVirtualBranch(event) {
    event.preventDefault();
    console.log('isRequestVirtualBranchExist');
    let accountId = this.accountInfo.Id;
    this.showConfimationModal=false;
    isTidsRequestPending({
      accountId: accountId,
      type:'TIDS – Virtual Branch Access Request'
    }).then(result => {
      console.log(result);
      if (result===''){
        this.triggerEvent({type:'REQUEST_VIRTUAL_BRANCH_SERVICE',payload:{detail:this.accountInfo}});
        return;
      }
      this.modalDefaultMessage='There is already a request pending review to allow you access to the TIDS Virtual Branch Service.';
      this.modalAction='OK';
      this.showConfimationModal=true;
    }).catch(error => {
      this.oops(error);
    })
  }
  handleRequestReinstate(triggertype) {
    console.log('Reinstate type:',triggertype);
    console.log('this.accountInfo',JSON.stringify(this.accountInfo));
    let accountId = this.accountInfo.Id;
    this.showConfimationModal=false;
    isTidsRequestPending({
      accountId: accountId,
      type:'TIDS – Reinstatement'
    }).then(result => {
      console.log(result);
      if (result===''){
          this.triggerEvent({type:triggertype,payload:{detail:this.accountInfo}});
      }else{
        this.modalDefaultMessage='There is already a request pending review to allow your reinstatement.'
        this.modalAction='OK';
        this.showConfimationModal=true;
      }
    }).catch(error => {
      this.oops(error);
    })
  }

  handleRequestRelinquishment(triggertype) {
    console.log('Relinquish type:',triggertype);
    console.log('this.accountInfo',JSON.stringify(this.accountInfo));
    let accountId = this.accountInfo.Id;
    this.showConfimationModal=false;
    isTidsRequestPending({
      accountId: accountId,
      type:'TIDS – Relinquishment'
    }).then(result => {
      console.log(result);
      if (result===''){
        this.triggerEvent({type:triggertype,payload:{detail:this.accountInfo}});
        return;
      }
      this.modalDefaultMessage='There is already a request pending review to allow your relinquishement.'
      this.modalAction='OK';
      this.showConfimationModal=true;
    }).catch(error => {
      this.oops(error);
    })
  }
  handleConfirmationInformation(event){
    this.showConfimationModal=false;
  }
  triggerEvent(action) {
    fireEvent(this.pageRef,'manageMenuListener', action);
  }
}