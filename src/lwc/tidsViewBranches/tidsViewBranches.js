import { LightningElement, track, api, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSortedBranches from "@salesforce/apex/TIDSHelper.getSortedBranches";
import isTidsRequestPending from '@salesforce/apex/TIDSHelper.isTidsRequestPending';
import { fireEvent } from "c/tidsPubSub";
import { getAccountSelected } from 'c/tidsUserInfo';

export default class TidsViewBranches extends LightningElement {
		@wire(CurrentPageReference) pageRef;
		// track binds the javascript with the html
		@api branchSelected;
		@api allRecords=false;
		@api accountInfo;
		@track morethanzero=false;
		@api isHOReinstatement = false;
		@track branches = [];
		@track showContextMenu = false;
		@track modalAction;
		@track showConfimationModal=false;
		@track modalDefaultMessage='';
		@track isHOAccountTerminated=false;
		@track newsearch;
		@track sortCode='Name';
		@track sortDirection='Desc';
		@track isSearchOn
		
		connectedCallback() {
			 this.accountInfo = getAccountSelected();
			 this.isHOAccountTerminated=false;
			 if (this.accountInfo!=undefined){
					 if (this.accountInfo.Status__c==='Terminated'){this.isHOAccountTerminated=true;}
			 }
			 this.branchValues();
		}
		// <template for:each={branches} for:item="branch">
		// the above is how you would link the javascript to the html
		branchValues() {
			getSortedBranches({
				accountIds:this.accountInfo.Id
				,name:this.sortCode
				,order:this.sortDirection
				,search:this.newsearch
				,allrecords:this.allRecords
			}).then(result => {this.viewBranchList(result);});
		}
		viewBranchList(result){
			this.morethanzero=false;
			let count=0;
			result.forEach(function(item){
				count++;
				if (item.TradeName__c===null || item.TradeName__c==='' || item.TradeName__c===undefined){
					item.TradeName__c='n/a';
				}
				item.showOptionMenu=true;
				item.showContextMenu=false;
				item.showRelinquishment=true;
				item.showReinstatement=false;
				if (item.Status__c=='Terminated'){
						item.showRelinquishment=false;
						item.showReinstatement=true;
						if (item.ParentId!=null){
							if (item.Parent.Status__c=='Terminated'){
								 item.showOptionMenu=false;
							}
						}
				}
				item.isVirtual=false;
				if (item.Location_Type__c==='VB'){
					 item.isVirtual=true;
				}
				item.visible=true;
				item.newId='$'+item.Id+'$';
			});
			if (count>0){
				 this.morethanzero=true;
			}
			this.branches = result;
		}
		sortBranchList(event){
			var idx = event.currentTarget.id;
			this.sortCode = this.categorize(idx);
			this.sortDirection = this.determineSortDirection(idx);
			getSortedBranches({
				accountIds:this.accountInfo.Id
				,name:sortCode,order:sortDirection
				,search:this.newsearch
				,allrecords:this.allRecords
			}).then(result => {
				this.viewBranchList(result);
			});
		}

		determineSortDirection(direction){
			let sorting='Asc';
			if (direction.includes('Desc')){
				sorting='Desc';
			}
			return sorting;
		}
		categorize(code){
			let field='Name, TradeName__c';
			if (code.includes('city')){
				field='BillingCity';
			}else if (code.includes('code')){
				field='IATACode__c';
			}else if (code.includes('status')){
				field='Status__c';
			}
			return field;
		}
		// Make sure the enable or disable the menu when the button is clicked twice.
		// Make sure it happens on the same branch.
		// Make sure we disable any menu that is enabled elsewhere.

		makeRecordVisible(event) {
			this.branches.forEach(item => {
				if (item.Status__c=="Review"){
					item.visible=true;
				} else {
					item.visible=false;
				}
			});
		}
		handlesearchBranches(event){
			this.isSearchOn=false;
			let newsearch = event.target.value;
			this.newsearch=newsearch;
		}
		handlegetBranches(event){
			event.preventDefault();
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
			getSortedBranches({
				accountIds:this.accountInfo.Id
				,name:this.sortCode
				,order:this.sortDirection
				,search:this.newsearch
				,allrecords:this.allRecords
			}).then(result => {
				this.isSearchOn=true;
				fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
				this.viewBranchList(result);
			});
		}
		handlevoidBranches(event){
			event.preventDefault();
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
			this.newsearch='';
			getSortedBranches({
				accountIds:this.accountInfo.Id
				,name:this.sortCode
				,order:this.sortDirection
				,search:this.newsearch
				,allrecords:this.allRecords
			}).then(result => {
				this.isSearchOn=false;
				fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
				this.viewBranchList(result);
			});
		}

		handleAllBranches(event) {
			// Prevents the anchor element from navigating to a URL.
			event.preventDefault();
			this.triggerEvent({type:'ALL_BRANCHES',payload:{detail: null}});
		}
		handleOutClick(event) {
			event.preventDefault();
			this.branches.forEach(item => {
					if (item.showContextMenu){
						item.showContextMenu = false;
					}
			})
		}
		handleClick(event) {
			var idx = event.target.id;
			this.branches.forEach(item => {
				if (idx.includes(item.Id)){
					if (item.showContextMenu == false){
						item.showContextMenu = true;
					} else {
						item.showContextMenu = false;
					}
				} else {
					item.showContextMenu = false;
				}
			})
		}
		oops(error){
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
			this.modalDefaultMessage='Oops! something happened, please retry.'
			this.modalAction='OK';
			this.showConfimationModal=true;
		}
		handleSelectBranchClick(event){
			// Prevents the anchor element from navigating to a URL.
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
			event.preventDefault();
			let idx = event.target.id;
			idx = idx.split('$')[1];
			let selectedbranchAccount;
			this.branches.forEach(item => {
				if (item.Id==idx){
					 selectedbranchAccount = item;
				}
			});
			this.branchSelected=!this.branchSelected;
			let accountId = selectedbranchAccount.Id;
			this.showConfimationModal=false;
			isTidsRequestPending({
				accountId: accountId,
				type:'Terminated'
			}).then(result => {
				//Alert Relinquishment in process
				let isReinstatement=false;
				if (result===''){
				}else {  
					isReinstatement=true;
					this.dispatchEvent(
						new ShowToastEvent({mode: "dismissable", title: "Alert",message: result,variant: "info"})
					);
				}
				let triggertype='SELECT_BRANCH';
				this.triggerEvent({type:triggertype,payload:{showreinstatement:isReinstatement, detail: selectedbranchAccount}});
				fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
			 }).catch(error => {
				this.oops(error);
			})
		}
		handleAdministration(event){
			// Prevents the anchor element from navigating to a URL.
			event.preventDefault();
			let idx = event.target.id;
			idx = idx.split('$')[1];
			let selectedbranchAccount;
			this.branches.forEach(item => {
				if (item.Id==idx){
					 selectedbranchAccount = item;
				}
			});
			this.branchSelected=!this.branchSelected;
			this.triggerEvent({type:'ADMIN',payload:{detail: selectedbranchAccount}});
		}
		handleReportChanges(event) {
			// Prevents the anchor element from navigating to a URL.
			event.preventDefault();
			let idx = event.target.id;
			idx = idx.split('$')[1];
			let selectedbranchAccount;
			this.branches.forEach(item => {
				if (item.Id==idx){
					 selectedbranchAccount = item;
				}
			});
			this.branchSelected=!this.branchSelected;
			this.triggerEvent({type:'REPORT_BRANCH_CHANGES',payload:{detail: selectedbranchAccount}});
		}
		handleReinstate(event) {
			event.preventDefault();
			this.showConfimationModal=false;
			if (this.isHOReinstatement){
				 this.modalDefaultMessage='There is already a request pending review for the Head Office to allow your reinstatement.';
				 this.modalAction='OK';
				 this.showConfimationModal=true;
				 return;
			}
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
			// Prevents the anchor element from navigating to a URL.
			let idx = event.target.id;
			idx = idx.split('$')[1];
			let selectedbranchAccount;
			this.branches.forEach(item => {
				 if (item.Id==idx){
						selectedbranchAccount = item;
				 }
			});
			this.branchSelected=!this.branchSelected;
			let triggertype='REINSTATE';
			if (selectedbranchAccount.Location_Type__c==='VB'){
					triggertype='REINSTATEVB';
			}else if (selectedbranchAccount.Location_Type__c==='BR'){
				triggertype='REINSTATEBR';
			}
			let accountId = selectedbranchAccount.Id;     
			isTidsRequestPending({
				accountId: accountId,
				type:'TIDS – Reinstatement'
			}).then(result => {
			 if (result===''){
					//is the branch in the reinstatement period
					isTidsRequestPending({
						accountId: accountId,
						type:'Terminated'
					}).then(result2 => {
						//Alert Relinquishment in process
						let isReinstatement=false;
						if (result2===''){
						}else{
							isReinstatement=true;
							this.dispatchEvent(
								new ShowToastEvent({mode: "dismissable",title: "Alert",message: result2,variant: "info"})
							);
						}
						this.triggerEvent({type:triggertype,payload:{showreinstatement:isReinstatement, detail: selectedbranchAccount}});
						fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
					 }).catch(error => {
						console.log('error',JSON.stringify(error));
						this.oops(error);
					});
			 }else{
					this.modalDefaultMessage='There is already a request pending review to allow your reinstatement.';
					this.modalAction='OK';
					this.showConfimationModal=true;
			 }
			 fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
			}).catch(error => {
				this.oops(error);
			})
		}

		handleRelinquish(event) {
		 event.preventDefault();
		 this.showConfimationModal=false;
		 if (this.isHOReinstatement){
				this.modalDefaultMessage='There is already a request pending review for the Head Office to allow your relinquishement.';
				this.modalAction='OK';
				this.showConfimationModal=true;
				return;
		 }
		 fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
		 // Prevents the anchor element from navigating to a URL.
		 let idx = event.target.id;
		 idx = idx.split('$')[1];
		 let selectedbranchAccount;
		 this.branches.forEach(item => {
				if (item.Id==idx){
					 selectedbranchAccount = item;
				}
		 });
		 this.branchSelected=true;
		 let triggertype='RELINQUISHBR';
		 if (selectedbranchAccount.Location_Type__c==='VB'){
				 triggertype='RELINQUISHVB';
		 }
		 let accountId = selectedbranchAccount.Id;     
		 isTidsRequestPending({
			 accountId: accountId,
			 type:'TIDS – Relinquishment'
		 }).then(result => {
			if (result===''){
				this.triggerEvent({type:triggertype,payload:{detail: selectedbranchAccount}});
			}else{
				this.modalDefaultMessage='There is already a request pending review to allow your relinquishement.';
				this.modalAction='OK';
				this.showConfimationModal=true;
			}
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
		 }).catch(error => {
			this.oops(error);
		 })
		}
		triggerEvent(action) {
			fireEvent(this.pageRef,'manageMenuListener', action);
		}
		handleAddBranch(event){
			// Prevents the anchor element from navigating to a URL.
			event.preventDefault();
			this.triggerEvent({type:'ADD_BRANCH',payload:{detail:null}});
		}
		
		handleBackToHOClick(event){
			// Prevents the anchor element from navigating to a URL.
			event.preventDefault();
			window.scrollTo(0,0);
			//when selecting a branch the top must become the branch 
			fireEvent(this.pageRef,'manageMenuListener', {type:'SELECT_CANCEL',payload:null});
		}
}