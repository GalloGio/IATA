import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import Id from "@salesforce/user/Id";
import allMyTidsCases from "@salesforce/apex/TIDSHelper.allMyTidsCases";
import actionApplication from "@salesforce/apex/TIDSHelper.actionApplication";
import assignToCaseOwner from "@salesforce/apex/TIDSHelper.assignToCaseOwner";
import USER_ID from "@salesforce/user/Id";

export default class TidsVetting extends NavigationMixin(LightningElement) {
	@track cases = [];
	@track userId = null;
	@track spinner = false;
	@track openModal = false;
	@track selectedTab;
	@track url = "/c/tids.app?caseId=";
	@track tidsCase;

	//Modal Window
	@track modalAction;
	@track showConfimationModal = false;
	@track modalDefaultMessage = "";

	//Pagination Code
	@track needsPagination = false;
	@track page = 1;
	perpage = 50;
	@track pages = [];
	set_size = 50;
	//Pagination Code

	connectedCallback() {
		this.init();
	}

	init() {
		this.userId = Id;
		this.getFilteredTidsCases("All");
	}

	navigateToView(event) {
		//let caseid = event.currentTarget.key;
		event.preventDefault();
		let caseid = event.target.dataset.targetId;
		console.log("case Id", caseid);
		this[NavigationMixin.Navigate]({
			type: "standard__recordPage",
			attributes: {
				recordId: caseid,
				objectApiName: "Case",
				actionName: "view"
			}
		});
	}
	navigateToEdit(event) {
		//let caseid = event.currentTarget.key;
		event.preventDefault();
		let caseid = event.target.dataset.targetId;
		console.log("case Id", caseid);
		this[NavigationMixin.Navigate]({
			type: "standard__recordPage",
			attributes: {
				recordId: caseid,
				objectApiName: "Case",
				actionName: "edit"
			}
		});
	}
	pickVetting(event) {
		event.preventDefault();
		this.spinner = true;
		console.log("My");
		this.showConfimationModal = false;
		let caseid = event.target.dataset.targetId;
		assignToCaseOwner({ caseId: caseid })
			.then((results) => {
				if (results.hasAnError === false) {
					this.oops(results.reason);
					this.runVetting(caseid);
				} else {
					this.modalDefaultMessage =
						"The ownership transfer is not allowed for this case for this reason: " +
						results.message;
					this.modalAction = "OK";
					this.showConfimationModal = true;
				}
				this.spinner = false;
			})
			.catch((error) => {
				this.oops(error);
			});
	}
	//Select the tab and do the rest
	tabselect(evt) {
		this.selectedTab = evt.target.label;
		console.log(this.selectedTab);
		this.page = 1;
		this.perpage = 50;
		this.pages = [];
		this.set_size = 50;
		this.getFilteredTidsCases(this.selectedTab);
	}

	// Get TIDS Cases
	getFilteredTidsCases(myfilter) {
		this.showConfimationModal = false;
		this.spinner = true;
		console.log("My");
		allMyTidsCases({ filter: myfilter })
			.then((results) => {
				this.cases = this.mappingCases(results);
				this.spinner = false;
			})
			.catch((error) => {
				this.oops(error);
			});
	}

	startVetting(event) {
		event.preventDefault();
		this.spinner = true;
		this.showConfimationModal = false;
		let caseid = event.target.dataset.targetId;
		actionApplication({ caseId: caseid, action: "vetting" })
			.then((result) => {
				console.log("result", JSON.stringify(result));
				this.spinner = false;
				if (result.hasAnError) {
					this.oops(result.reason);
					this.modalDefaultMessage =
						"This Application/Request was either recalled by the applicant or is currently being processed by an IATA Staff. Please refresh your screen to see the current status of this Application/Request.";
					this.modalAction = "OK";
					this.showConfimationModal = true;
				} else {
					this.runVetting(caseid);
				}
			})
			.catch((error) => {
				this.oops(error);
			});
	}
	runVetting(caseid) {
		this.spinner = true;
		this.showConfimationModal = false;
		let payload = this.cases;
		let pageurl = "";
		payload.forEach((item) => {
			if (item.Id === caseid) {
				item.resumevetting = true;
				item.startvetting = false;
				pageurl = item.Url;
			}
		});
		this.spinner = false;
		this.cases = payload;
		this[NavigationMixin.Navigate]({
			type: "standard__webPage",
			attributes: {
				url: pageurl
			}
		});
	}

	mappingCases(payload) {
		payload.forEach((item) => {
			item.startvetting = true;
			item.assigntome = false;
			item.resumevetting = false;
			item.allowvetting = true;
			let caseStatus = item.Status;

			caseStatus = caseStatus.toLowerCase();
			if (
				item.Reason1__c === "TIDS – Relinquishment" ||
				item.Reason1__c === "TIDS – Reinstatement" ||
				item.Reason1__c === "TIDS – VB Service Request"
			) {
				item.allowvetting = false;
			}

			if (
				caseStatus === "approved" ||
				caseStatus === "draft" ||
				caseStatus === "closed" ||
				caseStatus === "pending customer"
			) {
				item.startvetting = false;
				//console.log('item.Status',item.Status);
			} else {
				//console.log('USER_ID',USER_ID,item.OwnerId);
				//console.log('item',JSON.stringify(item));
				//make sure it is the same ownerid
				if (caseStatus === "review in progress") {
					item.startvetting = false;
					if (USER_ID !== item.OwnerId) {
						item.assigntome = true;
					} else {
						item.resumevetting = true;
					}
				}
			}
			item.Url = this.url + item.Id;
		});
		this.setPages(payload);
		return payload;
	}

	oops(error) {
		this.spinner = false;
		console.log(" fetchRoles error", error);
		this.modalDefaultMessage = "Oops! something happened, please retry.";
		this.modalAction = "OK";
		this.showConfimationModal = true;
	}

	//Pagination code
	get pagesList() {
		let mid = Math.floor(this.set_size / 2) + 1;
		if (this.page > mid) {
			return this.pages.slice(this.page - mid, this.page + mid - 1);
		}
		return this.pages.slice(0, this.set_size);
	}
	pageData = () => {
		let page = this.page;
		let perpage = this.perpage;
		let startIndex = page * perpage - perpage;
		let endIndex = page * perpage;
		this.needsPagination = true;
		if (perpage > this.cases.length) {
			this.needsPagination = false;
		}
		return this.cases.slice(startIndex, endIndex);
	};

	setPages = (data) => {
		let numberOfPages = Math.ceil(data.length / this.perpage);
		this.pages = [];
		for (let index = 1; index <= numberOfPages; index++) {
			let isCurrentPage = false;
			if (this.page == index) isCurrentPage = true;
			this.pages.push({ indexPage: index, isCurrentPage: isCurrentPage });
		}
	};

	get hasPrev() {
		if (this.pages.length == 2 && this.page == 1) return true;
		return this.page <= 1;
	}

	get hasNext() {
		if (this.pages.length == 2 && this.page == 2) return true;
		return this.page >= this.pages.length;
	}

	onNext = () => {
		++this.page;
	};

	onPrev = () => {
		--this.page;
	};

	onPageClick = (e) => {
		this.page = parseInt(e.target.dataset.id, 10);
	};

	get currentPageData() {
		return this.pageData();
	}
}
