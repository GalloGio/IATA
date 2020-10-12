import { LightningElement, api, wire,track} from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent } from "c/tidsPubSub";

export default class TidsCurrentAccount extends LightningElement {
		@wire(CurrentPageReference) pageRef;
		@api accountInfo;
		@api branchSelected=false;
		@api vbSelected=false;
		@api enableBacktoho=false;
		@track branchId;
		branchSelected(event){
			this.branchSelected=true;
			this.branchId = event.detail;
		}

		handleBackToHOClick(event){
			// Prevents the anchor element from navigating to a URL.
			event.preventDefault();
			window.scrollTo(0,0);
			var idx = event.target.id;
			this.branchSelected=!this.branchSelected;
			//when selecting a branch the top must become the branch 
			fireEvent(this.pageRef,'manageMenuListener', {type:'SELECT_HO',payload:{detail: idx }});
		}

		handleAllInformation(event){
				// Prevents the anchor element from navigating to a URL.
				event.preventDefault();
				//when selecting a branch the top must become the branch 
				fireEvent(this.pageRef,'manageMenuListener', {type:'ALL_INFORMATION',payload:{detail: this.accountInfo }});
			}

		// Make sure the enable or disable the menu when the button is clicked twice.
		// Make sure it happens on the same branch.
		// Make sure we disable any menu that is enabled elsewhere.
		connectedCallback() {
				//this.branchSelected=true;
		}

}