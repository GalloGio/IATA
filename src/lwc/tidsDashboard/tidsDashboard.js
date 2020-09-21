import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { registerListener } from "c/tidsPubSub";
// Salesforce Apex
import newBranch from '@salesforce/apex/TIDSHelper.newBranch';
import isTidsRequestPending from '@salesforce/apex/TIDSHelper.isTidsRequestPending';
// LWC Components
import { 
	setHeadOfficeInfo,
	getCase,
  getUserInfo,
  setIsAccountHeadOffice,
  setUserInfoIata,
  setAccountSelected
} from 'c/tidsUserInfo';

export default class TidsDashboard extends LightningElement {
  @wire(CurrentPageReference) pageRef;
  @track spinner = false;
  // Display component variables
  @track enableBacktoho=false;
  @track enableRevoke=false;
  @track showReinstate=false;
  @track showAddBranch = false;
  @track showNoOption=false;
  @track showAdministration=false;
  @track enableAdministration=false;
  @track showReinstatement = false;
  @track showHOReinstatement = false;
  @track showAllInformation=false;
  @track showAllBranches=false;
  @track showAllCases=false;
  @track showVirtualBranch = false;
  @track showReportChanges = false;
  @track showViewBranches = false;
  @track showViewCases = false;
  @track showTidsCases = false;
  @track showCurrentAccount=false;
  @track showHelpCenter=false;
  @track showManageMenu=false;
  @track showRelinquish=false;
  @track showRequestVirtualBranchService = false;
  @track branchSelected=false;
  @track vbSelected=false;
  @track showCaseDetailsPage=false;
  @track accountHO;
  @track accountInfo;
  @track caseId;
  @api get bshowManageMenu(){
     return this.showManageMenu;
  }
  set bshowManageMenu(value){
    this.showManageMenu=value;
  }
  connectedCallback() {
    registerListener('manageMenuListener',this.manageMenuListener,this);
    registerListener('spinnerListener',this.spinnerListener,this);
    // Tids View Branches default component
    this.getHeadofficeInformation(); 

  }
  apppermissions(step){
    let userInfo = getUserInfo();
    console.log('role;',JSON.stringify(userInfo));
    let role=userInfo.role;
    console.log('role;',role);
    if (role==='TIDS Branch Administrator'){
      this.enableBacktoho=false;
      this.enableRevoke=false;
      this.showAddBranch = false;
      this.showHOReinstatement = false;
      this.showAllBranches=false;
      this.showAllCases=false;
      this.showViewBranches = false;
      if (step===0) {this.showViewCases = true;}
      this.showTidsCases = false;
      this.showRequestVirtualBranchService = false;
      this.branchSelected=true;
      this.enableAdministration=false;
      this.accountInfo=this.accountHO;
      this.vbSelected= this.accountHO.Location_Type__c === "VB" ? true : false;
      if (this.accountInfo.ParentId!=null){
        if (this.accountInfo.Status__c==='Terminated'){
           this.showNoOption=true;
        }
      }
      // TBD vbSelected=false;
      
    }else if (role==='TIDS Admin HO Primary'){
      this.enableBacktoho=true;
      this.enableAdministration=true;
      this.enableRevoke=true;
    }else if (role==='TIDS Admin HO Secondary'){
      this.enableBacktoho=true;
      this.enableAdministration=true;
      this.enableRevoke=false;
    }
    console.log('role;',role);
    console.log('role enableBacktoho',this.enableBacktoho);
 }

  relinquishmentpending(accountid){
    isTidsRequestPending({
      accountId: accountid,
      type:'Terminated'
    }).then(result => {
      console.log('handleRelinquish result',result,accountid);
      this.showHOReinstatement=false;
      //Alert Relinquishment in process
      if (result===''){
      }else{
        this.showHOReinstatement=true;
        this.dispatchEvent(
          new ShowToastEvent({mode:"dismissable", title: "Alert",message: result,variant: "info"})
        );
      }
      this.showReinstatement =this.showHOReinstatement;
    }).catch(error => {
     console.log('handleRelinquish error',error);
     this.modalDefaultMessage='Oops! something happened, please retry.'
     this.modalAction='OK';
     this.showConfimationModal=true;
    })
  }
  // Component Business Logic
  resetDisplayVariables() {
    this.showReinstate=false;
    this.showAllInformation = false;
    //this.showReinstatement=false;
    this.showRequestVirtualBranchService = false;
    this.showAdministration=false;
    this.showAddBranch = false;
    this.showVirtualBranch = false;
    this.showReportChanges = false;
    this.showViewBranches = false;
    this.showViewCases = false;
    this.showTidsCases = false;
    this.showAllBranches = false;
    this.showAllCases = false;
    this.showCurrentAccount=false;
    this.showRelinquish=false;
    this.showHelpCenter = false;
  }

  // Get Head Office Information
  getHeadofficeInformation() {
		let userInfo = getUserInfo();
    newBranch({contactId: userInfo.ContactId})
    .then(result => {
      this.bshowManageMenu=true;
      this.accountInfo=result.tidsAccount;
      this.accountHO=this.accountInfo;
      this.showTidsCases = true;
      this.showCurrentAccount=true;
      this.showHelpCenter=true;
      this.showViewBranches = true;
      let isHeadOffice = this.accountInfo.Location_Type__c === "HO" ? true : false;
      setIsAccountHeadOffice(isHeadOffice);
      setHeadOfficeInfo(result);
      setAccountSelected(this.accountHO);
      this.relinquishmentpending(this.accountHO.Id);
      this.apppermissions(0);
    })
    .catch(error => {
      console.log(error);
		});
  }

  // Component Listeners
  manageMenuListener(action) {
    //this.branchSelected = false;
    this.resetDisplayVariables();
    switch(action.type) {
      case 'CASEDETAILS':
        this.showCaseDetailsPage=true;
        this.showViewBranches = true;
        this.showViewCases = false;
        this.showTidsCases = true;
        this.showCurrentAccount=true;
        this.caseId = action.payload.detail.Id;
        break;
      case 'ADMIN':
        setAccountSelected(action.payload.detail);
        this.showRelinquish=false;
        this.showAdministration=true;
        this.showHelpCenter = false;
        this.accountInfo=action.payload.detail;
        if (this.accountInfo.Location_Type__c==='VB'){
          this.vbSelected=true;
          this.branchSelected=true;
        }else if (this.accountInfo.Location_Type__c==='BR'){
          this.vbSelected=false;
          this.branchSelected=true;
        }
        console.log('admin',JSON.stringify(this.accountInfo));
        setIsAccountHeadOffice(!this.branchSelected);
        break;
      case 'ALL_INFORMATION':
        setAccountSelected(action.payload.detail);
        this.showAllBranches = false;
        this.showAllCases = false;
        this.showAllInformation = true;
        if (this.accountInfo.Location_Type__c==='HO'){
          this.showReinstatement=this.showHOReinstatement;
        }else if (this.accountInfo.Location_Type__c==='BR'){
          this.branchSelected=true;
        }else if (this.accountInfo.Location_Type__c==='VB'){
          this.branchSelected=true;
          this.vbSelected=true;
        }
        this.showRequestVirtualBranchService = false;
        this.showAddBranch = false;
        this.showCurrentAccount=false;
        this.showReportChanges = false;
        this.showViewBranches = false;
        this.showViewCases = false;
        this.showTidsCases = false;
        this.showHelpCenter = false;
        this.accountInfo=action.payload.detail;
        setIsAccountHeadOffice(!this.branchSelected);
        // Creates the event with the contact ID data.
        //console.log('action.payload.detail',JSON.stringify(action.payload.detail));
        //const selectedEvent = new CustomEvent('selectbranch', { detail: action.payload.detail});
        // Dispatches the event.
        //this.dispatchEvent(selectedEvent);
        break;
      case 'ALL_BRANCHES':
          this.showAllInformation = false;
          this.showAllBranches = true;
          if (this.accountInfo.Location_Type__c==='HO'){
            this.showReinstatement=this.showHOReinstatement;
          }
          this.showRequestVirtualBranchService = false;
          this.showAddBranch = false;
          this.showCurrentAccount=false;
          this.showReportChanges = false;
          this.showViewBranches = false;
          this.showViewCases = false;
          this.showTidsCases = false;
          this.branchSelected=false;
          this.showHelpCenter = false;
          // Creates the event with the contact ID data.
          //console.log('action.payload.detail',JSON.stringify(action.payload.detail));
          //const selectedEvent = new CustomEvent('selectbranch', { detail: action.payload.detail});
          // Dispatches the event.
          //this.dispatchEvent(selectedEvent);
          break;
      case 'ALL_CASES':
          this.showAllInformation = false;
          this.showAllBranches = false;
          this.showAllCases = true;
          if (this.accountInfo.Location_Type__c==='HO'){
            this.showReinstatement=this.showHOReinstatement;
          }else if (this.accountInfo.Location_Type__c==='VB'){
            this.branchSelected=true;
            this.vbSelected=true;
          }else{
            this.branchSelected=true;
            this.vbSelected=false;
          }
          this.showRequestVirtualBranchService = false;
          this.showAddBranch = false;
          this.showCurrentAccount=false;
          this.showReportChanges = false;
          this.showViewBranches = false;
          this.showViewCases = false;
          this.showTidsCases = false;
          this.showHelpCenter = false;
          // Creates the event with the contact ID data.
          //console.log('action.payload.detail',JSON.stringify(action.payload.detail));
          //const selectedEvent = new CustomEvent('selectbranch', { detail: action.payload.detail});
          // Dispatches the event.
          //this.dispatchEvent(selectedEvent);
          break;  
      case 'SELECT_BRANCH':
        setAccountSelected(action.payload.detail);
        this.showAllBranches = false;
        this.showAllCases = false;
        this.showReinstatement = action.payload.showreinstatement;
        
        this.showAllInformation = false;
        this.showRequestVirtualBranchService = false;
        this.showAddBranch = false;
        this.showCurrentAccount=true;
        this.showReportChanges = false;
        this.showViewBranches = false;
        this.showViewCases = true;
        this.showTidsCases = false;
        this.branchSelected=true;
        this.showHelpCenter = true;
        this.vbSelected=false;
        this.accountInfo=action.payload.detail;
        if (this.accountInfo.Location_Type__c==='VB'){
          this.vbSelected=true;
        }
        if (this.accountInfo.ParentId!=null){
            if (this.accountInfo.Parent.Status__c==='Terminated'){
               this.showNoOption=true;
            }
        }
        setIsAccountHeadOffice(!this.branchSelected);
        // Creates the event with the contact ID data.
        //console.log('action.payload.detail',JSON.stringify(action.payload.detail));
        //const selectedEvent = new CustomEvent('selectbranch', { detail: action.payload.detail});
        // Dispatches the event.
        //this.dispatchEvent(selectedEvent);
        break;
      case 'SELECT_HO':
        //setAccountSelected(action.payload.detail);
        this.showAllBranches = false;
        this.showAllCases = false;
        this.showRequestVirtualBranchService = false;
        this.showReinstatement=this.showHOReinstatement;
        this.showAllInformation = false;
        this.showAddBranch = false;
        this.showCurrentAccount=true;
        this.showReportChanges = false;
        this.showViewBranches = true;
        this.showViewCases = false;
        this.showTidsCases = true;
        this.branchSelected=false;
        this.showRelinquish=false;
        this.showHelpCenter = true;
        this.accountInfo=this.accountHO;
        setAccountSelected(this.accountInfo);
        setIsAccountHeadOffice(true);
        //setIsAccountHeadOffice(!this.branchSelected);
        break;  
     case 'SELECT_CANCEL':
       console.log('this.branchSelected',this.branchSelected);
        this.showAllBranches = false;
        this.showAllCases = false;
        if (this.accountInfo.Location_Type__c==='HO'){
          this.showReinstatement=this.showHOReinstatement;
        }
        //
        this.showAllInformation = false;
        this.showRequestVirtualBranchService = false;
        this.showAddBranch = false;
        this.showReportChanges = false;
        this.showRelinquish=false;
        this.showCurrentAccount=true;
        this.showHelpCenter = true;
        this.showViewBranches =!this.branchSelected;
        this.showViewCases = this.branchSelected;
        this.showTidsCases = !this.branchSelected;
        break;  
      case 'REPORT_BRANCH_CHANGES':
        setAccountSelected(action.payload.detail);        
        let isHeadOffice = action.payload.detail.Location_Type__c === "HO" ? true : false;
        this.showAllInformation = false;
        this.showAllCases = false;
        this.showAllBranches = false;
        this.showRequestVirtualBranchService = false;
        this.showAddBranch = false;
        this.showCurrentAccount=false;
        this.showReportChanges = true;
        this.showViewBranches =false;
        this.showViewCases = false;
        this.showTidsCases = false;
        this.showHelpCenter = false;
        this.showRelinquish=false;
        this.accountInfo=action.payload.detail;
        if (this.accountInfo.Location_Type__c==='VB'){
          this.vbSelected=true;
          this.branchSelected=true;
        }else if (this.accountInfo.Location_Type__c==='BR'){
          this.vbSelected=false;
          this.branchSelected=true;
        }  
        setIsAccountHeadOffice(!this.branchSelected);
        break;
      case 'ADD_BRANCH':
        this.showAllCases = false;
        this.showAllBranches = false;
        this.showAllInformation = false;
        this.showRequestVirtualBranchService = false;
        this.showReportChanges = false;
        this.showCurrentAccount=false;
        this.showViewBranches =false;
        this.showViewCases = false;
        this.showTidsCases = false;
        this.showHelpCenter = false;
        this.showVirtualBranch = false;
        this.showRelinquish=false;
        this.showAddBranch = true;
        if (action.payload.detail!=null) this.accountInfo=action.payload.detail;
        break;
      case 'ADD_VIRTUAL_BRANCH':
        this.showAllCases = false;
        this.showAllBranches = false;
        this.showAllInformation = false;
        this.showRequestVirtualBranchService = false;
        this.showReportChanges = false;
        this.showCurrentAccount=false;
        this.showViewBranches =false;
        this.showViewCases = false;
        this.showTidsCases = false;
        this.showHelpCenter = false;
        this.showRelinquish=false;
        this.showVirtualBranch = true;
        this.showAddBranch = true;
        if (action.payload.detail!=null) this.accountInfo=action.payload.detail;
        break;
      case 'REQUEST_VIRTUAL_BRANCH_SERVICE':
        this.showAllCases = false;
        this.showAllBranches = false;
        this.showReinstatement=this.showHOReinstatement;
        this.showAllInformation = false;
        this.showReportChanges = false;
        this.showCurrentAccount=false;
        this.showViewBranches =false;
        this.showViewCases = false;
        this.showTidsCases = false;
        this.showHelpCenter = false;
        this.showVirtualBranch = false;
        this.showAddBranch = false;
        this.showRelinquish=false;
        this.showRequestVirtualBranchService = true;
        if (action.payload.detail!=null) this.accountInfo=action.payload.detail;
        break;
      case 'REINSTATE':
          this.showReinstate=true;
          this.showRequestVirtualBranchService = false;
          this.showRelinquish=false;
          break;
      case 'REINSTATEBR':
          setAccountSelected(action.payload.detail);
          this.showReinstatement = action.payload.showreinstatement;
          this.showReinstate=true;
          this.showRequestVirtualBranchService = false;
          this.showRelinquish=false;
          this.vbSelected=false;
          this.branchSelected=true;
          this.accountInfo=action.payload.detail;
          setIsAccountHeadOffice(false);
          break;
      case 'REINSTATEVB':
          setAccountSelected(action.payload.detail);
          this.showReinstatement = action.payload.showreinstatement;
          this.showReinstate=true;
          this.showRequestVirtualBranchService = false;
          this.showRelinquish=false;
          this.branchSelected=true;
          this.vbSelected=true;
          this.accountInfo=action.payload.detail;
          setIsAccountHeadOffice(false);
          break;
      case 'RELINQUISHHO':
        this.showAllCases = false;
        this.showAllBranches = false;
        this.showReinstatement=this.showHOReinstatement;
        this.showAllInformation = false;
        this.branchSelected=false;
        this.vbSelected=false; 
        this.showReportChanges = false;
        this.showCurrentAccount=false;
        this.showViewBranches =false;
        this.showViewCases = false;
        this.showTidsCases = false;
        this.showHelpCenter = false;
        this.showVirtualBranch = false;
        this.showAddBranch = false;
        this.showRequestVirtualBranchService = false;
        this.showRelinquish=true;
        break;      
      case 'RELINQUISHVB':
        setAccountSelected(action.payload.detail);
        this.showAllCases = false;
        this.showAllBranches = false;
        this.showAllInformation = false;
        this.branchSelected=true;
        this.vbSelected=true; 
        this.showReportChanges = false;
        this.showCurrentAccount=false;
        this.showViewBranches =false;
        this.showViewCases = false;
        this.showTidsCases = false;
        this.showHelpCenter = false;
        this.showVirtualBranch = false;
        this.showAddBranch = false;
        this.showRequestVirtualBranchService = false;
        this.showRelinquish=true;
        this.accountInfo=action.payload.detail;
        break;
      case 'RELINQUISHBR':
        setAccountSelected(action.payload.detail);
        this.showAllCases = false;
        this.showAllBranches = false;
        this.showAllInformation = false;
        this.branchSelected=true;
        this.vbSelected=false; 
        this.showReportChanges = false;
        this.showCurrentAccount=false;
        this.showViewBranches =false;
        this.showViewCases = false;
        this.showTidsCases = false;
        this.showHelpCenter = false;
        this.showVirtualBranch = false;
        this.showAddBranch = false;
        this.showRequestVirtualBranchService = false;
        this.showRelinquish=true;
        this.accountInfo=action.payload.detail;
        break;
      case 'REPORT_CHANGES':
        setAccountSelected(action.payload.detail);
        //this.showReportChanges = action.payload.show;
        this.showAllCases = false;
        this.showAllBranches = false;
        this.showAllInformation = false;
        this.showRequestVirtualBranchService = false;
        this.showReportChanges = false;
        this.showCurrentAccount=false;
        this.showViewBranches =false;
        this.showViewCases = false;
        this.showTidsCases = false;
        this.showHelpCenter = false;
        this.showRelinquish=false;
        this.showReportChanges = true;
        this.accountInfo=action.payload.detail;
        let isHO = action.payload.detail.Location_Type__c === "HO" ? true : false;
        this.branchSelected=!isHO;
        setIsAccountHeadOffice(!this.branchSelected);
        break;
      default: break;
    }
    this.apppermissions(1);
    console.log('this.vbSelected',this.vbSelected);
  }

  spinnerListener(action) {
    this.spinner = action.payload.show;
  }
}