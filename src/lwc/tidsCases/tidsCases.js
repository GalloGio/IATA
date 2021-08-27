import { LightningElement, track, api, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { navigateToPage } from 'c/navigationUtils';
import { fireEvent } from "c/tidsPubSub";
import getSortedCases from "@salesforce/apex/TIDSHelper.getSortedCases";
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class TidsCases extends LightningElement {
		@wire(CurrentPageReference) pageRef;
		// track binds the javascript with the html
		@track cases=[];
		@api accountInfo;
		@api branchSelected;
		@track newsearch;
		@track sortCode='CaseNumber';
		@track sortDirection='Desc';
		@track isSearchOn=false;

		viewCaseList(result){
			result.forEach(function(item){
				item.newId='$'+item.Id+'$';
				item.url="/s/case-details?caseId="+item.Id + '&Att=false';
				item.visible=true;
			});
			this.cases = result;
		}
		// the above is how you would link the javascript to the html
		caseValues() {
				getSortedCases({
					accountIds:this.accountInfo.Id
					,name:this.sortCode
					,order:this.sortDirection
					,search:this.newsearch
					,allrecords:false
				}).then(result => {
					this.viewCaseList(result);
				});
		}
		// Make sure the enable or disable the menu when the button is clicked twice.
		// Make sure it happens on the same branch.
		// Make sure we disable any menu that is enabled elsewhere.
		connectedCallback() {
				this.caseValues();
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
				,allrecords:false
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
				,allrecords:false
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
		triggerEvent(action) {
			fireEvent(this.pageRef,'manageMenuListener', action);
		}
		handleCaseDetailsPage(event){
			event.preventDefault();
			let idx = event.target.id;
			idx = idx.split('$')[1];
			let selectedcase;
			this.cases.forEach(item => {
				if (item.Id==idx){selectedcase = item;}
			});
			let params = {};
			params.caseId = selectedcase.Id; // PARENT ARTICLE
			this[NavigationMixin.GenerateUrl]({
					type: "standard__namedPage",
					attributes: {
							pageName: "case-details"
					}})
			.then(url => navigateToPage(url, params));
			window.location.href = CSP_PortalPath + "/s/case-details?caseId="+selectedcase.Id + '&Att=true';;
		}
}