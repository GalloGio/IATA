import { LightningElement, api, wire,track} from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent,registerListener  } from "c/tidsPubSub";
import getAdministrators from "@salesforce/apex/TIDSHelper.getAdministrators";
import actionAdministrators from "@salesforce/apex/TIDSHelper.actionAdministrators";

export default class TidsAdministration extends LightningElement {
		@wire(CurrentPageReference) pageRef;
		@api enableRevoke=false;
		@api accountInfo;
		@api branchSelected=false;
		@track administrator='';
		@track administrators=[];
		@track roles=[{name:'Abdellah Bellahssan', permission:'Primary Administrator', rule:'HO',id:'1',enabledMenu:false,swap:false},{name:'Luc Debono', permission:'Secondary Administrator', rule:'HO',id:'2',enabledMenu:true,swap:true},{name:'Francis CGI', permission:'Branch Administrator', rule:'BR',id:'3',enabledMenu:true,swap:false}];
		@track branchId;
		@track isSearcheable=true;
		@track isAdministratorAvailable=false;
		@track isAdministratorSelected=false;
		@track administratorsearch=false;
		@track administratorselected={};
		@track administratorselectedname='';
		@track administratorselectedid;
		//Modal Window
		@track modalAction;
		@track isRequestExist=false;
		@track showConfimationModal=false;
		@track modalDefaultMessage='';
		@track idx;
		@track addNow=false;
		@track enableActions=false;
 
		branchSelected(event){
				this.branchSelected=true;
				this.branchId = event.detail;
		}
		handleAddNow(event){
				event.preventDefault();
				this.addNow=true;
				this.administratorselectedname='';
		}
		handleCancel(event){
				// Prevents the anchor element from navigating to a URL.
				event.preventDefault();
				this.addNow=false;
				this.administratorselectedname='';
				this.isAdministratorSelected=false;
				this.administratorsearch=false;
				//when selecting a branch the top must become the branch 
				//fireEvent(this.pageRef,'manageMenuListener', {type:'SELECT_CANCEL',payload:null});
		}
		handleRemove(event){
			// Prevents the anchor element from navigating to a URL.
			event.preventDefault();
			let idx = event.currentTarget.dataset.id;
			this.idx = idx.split('$')[1];
			console.log('this.idx',this.idx);
			this.showConfimationModal=false;
			this.modalDefaultMessage='Please confirm the removal of this user from the list of administrators.';
			this.modalAction='REMOVEADMINISTRATOR';
			this.showConfimationModal=true;
			//when selecting a branch the top must become the branch 
		}
		handleSwap(event){
				// Prevents the anchor element from navigating to a URL.
				event.preventDefault();
				let idx = event.currentTarget.dataset.id;
				this.idx = idx.split('$')[1];
				console.log('this.idx',this.idx);
				this.showConfimationModal=false;
				this.modalDefaultMessage='Please confirm the swap of administrators. Once confirmed, an email will be sent to both parties.';
				this.modalAction='SWAPADMINISTRATOR';
				this.showConfimationModal=true;
				//when selecting a branch the top must become the branch 
			}
		handleAddAdministrator(event){
				event.preventDefault();
				this.addRoles();
		}
		handleBackToHOClick(event){
			// Prevents the anchor element from navigating to a URL.
			event.preventDefault();
			window.scrollTo(0,0);
			//when selecting a branch the top must become the branch 
			fireEvent(this.pageRef,'manageMenuListener', {type:'SELECT_CANCEL',payload:null});
		}

		handleAllInformation(event){
				// Prevents the anchor element from navigating to a URL.
				event.preventDefault();
				//when selecting a branch the top must become the branch 
				fireEvent(this.pageRef,'manageMenuListener', {type:'ALL_INFORMATION',payload:{detail: this.accountInfo }});
			}
		
		cancelAdministrator(props){
				this.showConfimationModal=false;
		}
		changeAdministratorField(event){
				console.log('event.target.name',event.target.name);
				if (event.target.name === "administrator"){
						let name = event.target.value;
						this.fetchAdministrators(name);
				} 
		}
		fetchAdministrators(name){
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
			console.log('fetchAdministrators',name);
			let accountId = this.accountInfo.Id;
			this.showConfimationModal=false;
			this.isAdministratorAvailable=false;
			this.isAdministratorSelected=false;
			console.log('fetchAdministrators accountId',accountId);
			getAdministrators({
				accountId: accountId,
				name:name
			}).then(result => {
				fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
				//Alert Relinquishment in process
				console.log('getAdministrators result',result);
				let administrators=[];
				if (result!=null){
						this.isAdministratorAvailable=true;
						result.forEach(function(item){
								let newid = '$'+item.Id+'$';
								administrators.push({name:item.FirstName +' '+ item.LastName, permission:'Administrator', Id:item.Id, newId:newid});
					 });
				}
				this.administrators=administrators;
			 }).catch(error => {
				fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
				console.log('handleRelinquish error',error);
				this.modalDefaultMessage='Oops! something happened, please retry.'
				this.modalAction='OK';
				this.showConfimationModal=true;
			})
		}
		setAdministratorSearchOn(event){
				this.administratorsearch=true;
				if (this.administrator=='' || this.administrator==undefined){
					 this.administratorId=undefined;
				}
		}
		setAdministratorSearchOff(event){
				this.administratorsearch=false;
				if (this.administrator=='' || this.administrator==undefined){
					this.administratorId=undefined;
				}
		}
		setAdministratorSearchPrevent(event){
				event.preventDefault();
			}
		selectAdministrator(event){
				let idx = event.currentTarget.id;
				idx = '$'+idx.split('$')[1]+'$';
				console.log('event.currentTarget.id',idx);
				let newitem;
				this.isAdministratorSelected=false;
				this.administrators.forEach(function(item){
					 if (item.newId===idx){
							console.log('administratorselected',JSON.stringify(item));
							newitem=item;
					 }
				});
				console.log('administratorselected',newitem!=undefined);
				if (newitem!=undefined) {
						console.log('administratorselected',JSON.stringify(newitem));
						this.isAdministratorSelected=true;
						this.administratorselected = newitem;
						this.administratorselectedname =newitem.name;
						this.administratorselectedid=newitem.Id;
				}
				this.isAdministratorAvailable=false;
				this.administratorsearch=false;
		}

		displayRoles(result, isswap){
				this.isAdministratorSelected=false;
				this.administratorselected = null;
				this.administratorselectedname = null;
				this.administratorselectedid=null;
				let issearched=true;
				if (!this.enableRevoke && isswap){
					this.enableRevoke=true;
				}
				let enablerevoke = this.enableRevoke;
				let myroles=[];
				let enableaction = false;
				if (result!=null){
						result.forEach(function(item){
								let newid = '$'+item.Contact__c+'$';
								let myperm='Branch Administrator';
								let showcontext=true;
								enableaction=true;
								let showswap=false;
								let fullname = item.Contact__r.FirstName +' '+ item.Contact__r.LastName;
								
								if (item.Access_Status_Reason__c==='TIDS Admin HO Primary'){
										myperm='Primary Administrator';
										showcontext=false;
										enableaction=false;
								}else if (item.Access_Status_Reason__c==='TIDS Admin HO Secondary'){
										myperm='Secondary Administrator';
										showcontext=true;
										showswap=true;
										issearched=false;
										enableaction=true;
								}else {
										issearched=false;
								}
								myroles.push({name:fullname , permission:myperm, Id:item.Contact__c, newId:newid, showSwap:showswap, enabledMenu:showcontext, isSearcheable:false, enableRevoke:enablerevoke});
					 });
					 this.isSearcheable=issearched;
				}
				this.enableActions = enableaction;
				this.roles=myroles;
				this.isAdministratorSelected=false;
				this.administratorsearch=false;
				this.administrators=[];
				this.addNow=false;
				console.log('roles',JSON.stringify(myroles));
				fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
		}
		oops(error){
				fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
				console.log('fetchRoles error',JSON.stringify(error));
				this.modalDefaultMessage='Oops! something happened, please retry.'
				this.modalAction='OK';
				this.showConfimationModal=true;
		}
		addRoles(){
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});  
			console.log('fetchRoles: add');
			let accountId = this.accountInfo.Id;
			this.showConfimationModal=false;
			console.log('fetchRoles accountId',accountId,this.administratorselectedid,this.branchSelected);
			actionAdministrators({
				accountId: accountId,
				contactId: this.administratorselectedid,
				actiontype:'add',
				isbranch:this.branchSelected
			}).then(result => {
				//Alert Relinquishment in process
				console.log('actionAdministrators result',JSON.stringify(result));
				this.displayRoles(result,false);
			 }).catch(error => {
				this.oops(error);
			})
		}
		removeRoles(props){
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
			console.log('fetchRoles: remove');
			let accountId = this.accountInfo.Id;
			this.showConfimationModal=false;
			console.log('fetchRoles accountId',accountId);
			actionAdministrators({
				accountId: accountId,
				contactId: this.idx,
				actiontype:'remove',
				isbranch:this.branchSelected
			}).then(result => {
				//Alert Relinquishment in process
				console.log('actionAdministrators result',JSON.stringify(result));
				this.displayRoles(result,false);
			 }).catch(error => {
				this.oops(error);
			})
		}
		swapRoles(props){
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
			console.log('fetchRoles: get');
			let accountId = this.accountInfo.Id;
			this.showConfimationModal=false;
			console.log('fetchRoles accountId',accountId);
			actionAdministrators({
				accountId: accountId,
				contactId: this.idx,
				actiontype:'swap',
				isbranch:this.branchSelected
			}).then(result => {
				//Alert Relinquishment in process
				console.log('actionAdministrators result',JSON.stringify(result));
				this.displayRoles(result, true);
			 }).catch(error => {
				this.oops(error);
			})
		}
		fetchRoles(){
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
			console.log('fetchRoles: get');
			let accountId = this.accountInfo.Id;
			this.showConfimationModal=false;
			console.log('fetchRoles accountId',accountId);
			actionAdministrators({
				accountId: accountId,
				contactId: null,
				actiontype:'get',
				isbranch:this.branchSelected
			}).then(result => {
				//Alert Relinquishment in process
				console.log('actionAdministrators result',JSON.stringify(result));
				this.displayRoles(result,false);
			 }).catch(error => {
				this.oops(error);
			})
		 }
		
		
		// Make sure the enable or disable the menu when the button is clicked twice.
		// Make sure it happens on the same branch.
		// Make sure we disable any menu that is enabled elsewhere.
		connectedCallback() {
				//this.branchSelected=true;
				console.log('connectedCallback');
				registerListener('removeAdministrator',this.removeRoles,this);
				registerListener('cancelAdministrator',this.cancelAdministrator,this);
				registerListener('swapAdministrator',this.swapRoles,this);
				console.log('fetchRoles');
				this.fetchRoles();
		}
}