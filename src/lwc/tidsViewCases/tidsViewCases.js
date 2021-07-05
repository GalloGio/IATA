import { LightningElement, track, api, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import getSortedCases from "@salesforce/apex/TIDSHelper.getSortedCases";
import { fireEvent } from "c/tidsPubSub";

export default class TidsCases extends LightningElement {
		@wire(CurrentPageReference) pageRef;
		// track binds the javascript with the html
		@track cases = [];
		@api accountInfo;
		@api branchSelected;
		@api allRecords=false;
		@api morethanzero=false;
		@track newsearch;
		@track sortCode='CreatedDate';
		@track sortDirection='Desc';
		@track isSearchOn=false;

		// the above is how you would link the javascript to the html
		caseValues() {
				getSortedCases({
					accountIds:this.accountInfo.Id
					,name:this.sortCode
					,order:this.sortDirection
					,search:this.newsearch
					,allrecords:this.allRecords
				}).then(result => {
					this.viewCaseList(result);          
				});
		}
		viewCaseList(result){
			this.morethanzero=false;
			let count=0;
			result.forEach(function(item){
				count++;
				item.showContextMenu=false;
				item.visible=true;
				item.url="/s/case-details?caseId="+item.Id + '&Att=false';
				item.newId='$'+item.Id+'$';
			});
			if (count>0){
				this.morethanzero=true;
			}
			this.cases = result;
		}
		sortCaseList(event){
			var idx = event.currentTarget.id;
			this.sortCode = this.categorize(idx);
			this.sortDirection = this.determineSortDirection(idx);
			getSortedCases({
				accountIds:this.accountInfo.Id
				,name:this.sortCode
				,order:this.sortDirection
				,search:this.newsearch
				,allrecords:this.allRecords
			}).then(result => {
				this.viewCaseList(result);
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
			let field='CaseNumber';
			if (code.includes('Status')){
				field='Status';
			}else if (code.includes('CreatedDate')){
				field='CreatedDate';
			}else if (code.includes('Subject')){
				field='Subject';
			}else if (code.includes('ownerId')){
				field='ownerId';
			}
			return field;
		}
		handlesearchCases(event){
			this.isSearchOn=false;
			let newsearch = event.target.value;
			this.newsearch=newsearch;
		}
		handlegetCases(event){
			event.preventDefault();
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
		 
			getSortedCases({
				accountIds:this.accountInfo.Id
				,name:this.sortCode
				,order:this.sortDirection
				,search:this.newsearch
				,allrecords:this.allRecords
			}).then(result => {
				this.isSearchOn=true;
				fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
				this.viewCaseList(result);
			});
		}
		handlevoidCases(event){
			event.preventDefault();
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
			this.newsearch='';
			getSortedCases({
				accountIds:this.accountInfo.Id
				,name:this.sortCode
				,order:this.sortDirection
				,search:this.newsearch
				,allrecords:this.allRecords
			}).then(result => {
				this.isSearchOn=false;
				fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
				this.viewCaseList(result);
			});
		}
		handleAllCases(event) {
			// Prevents the anchor element from navigating to a URL.
			event.preventDefault();
			this.triggerEvent({type:'ALL_CASES',payload:{detail: null}});
		}
		handleAllCases(event) {
			// Prevents the anchor element from navigating to a URL.
			event.preventDefault();
			this.triggerEvent({type:'ALL_CASES',payload:{detail: null}});
		}
		triggerEvent(action) {
			fireEvent(this.pageRef,'manageMenuListener', action);
		}
		// Make sure the enable or disable the menu when the button is clicked twice.
		// Make sure it happens on the same branch.
		// Make sure we disable any menu that is enabled elsewhere.
		connectedCallback() {
				this.caseValues();
		}
		handleBackToHOClick(event){
			// Prevents the anchor element from navigating to a URL.
			event.preventDefault();
			window.scrollTo(0,0);
			//when selecting a branch the top must become the branch 
			fireEvent(this.pageRef,'manageMenuListener', {type:'SELECT_CANCEL',payload:null});
		}
}