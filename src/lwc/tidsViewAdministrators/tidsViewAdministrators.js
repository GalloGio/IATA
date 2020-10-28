import { LightningElement, track, api, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import getAdministrators from "@salesforce/apex/TIDSHelper.getAdmin";
export default class TidsViewAdministrators extends LightningElement {
		@wire(CurrentPageReference) pageRef;
		// track binds the javascript with the html
		@api branchSelected=false;
		@track roles = {Primary:'Retrieving...', Secondary:'Retrieving...'};
		
		newaccountId;
		@api get accountId() {
				return this.newaccountId;
		}
		set accountId(value) {
			if (value===undefined || value===null) return;
			this.newaccountId = value;
			if (this.baccountId===this.newaccountId) return;
			this.baccountId=value;
			this.getmyAdministrators();
		}

		baccountId;

		getmyAdministrators(){
			this.baccountId=this.newaccountId;
			this.roles = {Primary:'Retrieving...', Secondary:'Retrieving...'};
			getAdministrators({
				accountId: this.newaccountId
			}).then(result => {
				//fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
				//Alert Relinquishment in process
				console.log('getAdministrators result',JSON.stringify(result));
				let administrators= {Primary:'', Secondary:''};
				if (result!=null){
						result.forEach(function(item){
								if (item.Access_Status_Reason__c==='TIDS Admin HO Secondary'){
										administrators.Secondary=item.Contact__r.FirstName +' '+ item.Contact__r.LastName;
								}else{
									administrators.Primary=item.Contact__r.FirstName +' '+ item.Contact__r.LastName;
								}
					 });
				}
				administrators.Secondary=this.setNone(administrators.Secondary);
				administrators.Primary=this.setNone(administrators.Primary);
				this.roles=administrators;
			 }).catch(error => {
				 console.log('error',error); 
				 this.roles = {Primary:'', Secondary:''};
			
			})
			
		}
		setNone(value){
			if (value==='' || value===null || value===undefined) {
				 value='n/a';
			}
			return value;
		}
		connectedCallback() {
			console.log('connectedCallback',this.baccountId);
			//if (this.baccountId!=this.accountId) this.getmyAdministrators();
		}
		
}