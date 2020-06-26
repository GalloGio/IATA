import { LightningElement, wire, api, track } from "lwc";
import getFacilityFiles_ from "@salesforce/apex/CW_AccountDetailCarousel.getFacilityFiles";
import hideImageSelected_ from "@salesforce/apex/CW_AccountDetailCarousel.hideImageSelected";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import swipe from "c/cwSwipe";
import {refreshApex} from '@salesforce/apex';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
/*import getImagesExamples_ from "@salesforce/apex/CW_AccountDetailCarousel.getImagesExamples";*/

export default class CwAccountDetailCarousel extends LightningElement {
	_recordId = "";
	@api title = "";
	@api underline = "";
	@api titlesize = "h4";
	@api label;
	@track listImages = [];
	@track listMiniature = [];
	@track moreListImages = [];
	@track lessListImages = [];
	@track indicatorClicked;
	@track positionCarousel = "slds-carousel__panels translate-x-0";
	@track modalCarouselOpen = false;
	@track urlImageModal = null;
	isLoading = false;

	isRenderedCallback = false;

	error = "";
	@track index = 0;
	@track currentImagePosition = 0;
	@api editMode = false;
	@track showFileUploadCarousel = false;
	@track showFileHideCarousel=false;

	@api
	get recordId(){
		return this._recordId;
	}
	set recordId(value){
	if(this._recordId != value)
		this._recordId = value;
		refreshApex(this.getFacilityFiles(value));
	}

	showToast(title, message, variant) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant
		});
		this.dispatchEvent(event);
	}

	//icons
	icon = {
		bluearrow: resources + "/icons/single_arrow_left.svg",
		plus: resources + "/icons/icon-plus.svg",
		minus: resources + "/icons/icon-minus.svg"
	};

	initialized = false;
	firstload = false;
	initializedswipe = false;
	initializedswipepopup = false;

	getFacilityFiles(id) {
		this.isLoading = true;
		getFacilityFiles_({ recordId: id })
			.then(result => {
				this.data = result;
				if (this.data) {
					let imagesList = JSON.parse(JSON.stringify(this.data));
					let listMiniature = [];
					let index = 0;
					imagesList.forEach(img => {
						img.url = "data:image/" + img.fileExtension + ";base64," + img.image;
						if (index < 4) {
							listMiniature.push(img);
						}
						index++;
					});

					if (imagesList !== undefined && imagesList.length > 0) {
						this.urlImageModal = imagesList[0].url;
					}

					this.listImages = imagesList;
					this.listMiniature = listMiniature;
					this.index = index;
					this.error = undefined;
					this.initializeSwipe();

					// Creates the event with the data and dispatches.
					const newEvent = new CustomEvent("dataloaded", {
						detail: {
							data: this.data
						}
					});
					this.dispatchEvent(newEvent);
				}
			})
			.catch(err => alert(err.message))
			.finally(() => {
				this.isLoading = false;
			});
	}

	renderedCallback() {
		if (!this.isRenderedCallback) {
			this.getFacilityFiles(this.recordId);
			this.isRenderedCallback = true;
		}

		this.initialized = true;

		if (this.initialized && !this.firstload) {
			if (this.template.querySelector(".chevronup") && this.template.querySelector(".div-chevronup")) {
				this.template.querySelector(".chevronup").hidden = true;
				this.template.querySelector(".div-chevronup").hidden = true;
				this.firstload = true;
			}
		}

		this.initializeSwipe();
		this.initializeSwipePopups();
	}

	evaluateDisplayFileUpload() {
		if (!this.showFileUploadCarousel) {
			this.showFileUploadCarousel = true;
		} else {
			this.showFileUploadCarousel = false;
			this.getFacilityFiles(this.recordId);
		}
	}

	evaluateHideImage(){
		if (this.showFileHideCarousel === false) {
			this.showFileHideCarousel = true;
		}
		else{
			this.showFileHideCarousel = false;
		}
	}

	makeActionToImage(){
		let img = this.listImages[this.currentImagePosition]
		this.hideImageSelected(img.id);

		this.showFileHideCarousel = false;
	}

	hideImageSelected(imageId){
		this.isLoading = true;
		hideImageSelected_({ imageId })
			.then(res => {
				let result = JSON.parse(res);
				if (result.success) {										
					this.showToast("Success", "Image delete from Carousel", "success");
					this.getFacilityFiles(this.recordId);
				}
				else{
					this.showToast("Error", result.message, "error");
				}
			})
			.finally(() => {
				this.isLoading = false;
			});
	}

	handleIndicator(event) {
		//Image selected
		this.indicatorClicked = event.target.dataset.item;
		//const elements = this.template.querySelector("a[data-item="+this.indicatorClicked+"]");
		this.updateContentList();
	}

	updateContentList() {
		let i = 0;
		this.listImages.forEach(element => {
			if (element.id === this.indicatorClicked) {
				element.indicatorClass = "slds-carousel__indicator-action slds-is-active";
				element.tabindex = "0";
				element.hidden = "true";
				element.panelClass = "slds-carousel__panel panelSelected carousel-size";
				this.positionCarousel = element.position;
				this.urlImageModal = element.url;
				this.currentImagePosition = i;
			} else {
				element.indicatorClass = "slds-carousel__indicator-action";
				element.tabindex = "-1";
				element.hidden = "false";
				element.panelClass = "slds-carousel__panel carousel-size";
			}
			i++;
		});
	}

	openModal() {
		this.modalCarouselOpen = true;
	}

	closeModal() {
		this.modalCarouselOpen = false;
		this.initializedswipepopup = false;
	}

	showShadow() {
		let elementShadow = this.template.querySelector(".slds-modal__content");
		elementShadow.classList.value = "slds-modal__content shadow-image";
	}

	hideShadow() {
		let elementShadow = this.template.querySelector(".slds-modal__content");
		elementShadow.classList.value = "slds-modal__content";
	}

	get hasMorePictures() {
		return this.listImages.length > 4 ? true : false;
	}

	get lisImagesSize() {
		let lenghtResults = true;
		if (this.initialized) {
			lenghtResults = false;
			if (this.initialized && this.listImages.length > 0) {
				lenghtResults = true;
			}
		}
		return lenghtResults;
	}

	moveListMiniature(event) {
		let arrow = event.target.dataset.item;
		if (arrow === "upArrow") {
			this.listMiniature.pop();
			let auxLIst = [];
			auxLIst.push(this.listImages[0]);
			this.listMiniature.forEach(element => {
				auxLIst.push(element);
			});
			this.listMiniature = auxLIst;
			this.template.querySelector(".chevronup").hidden = true;
			this.template.querySelector(".div-chevronup").hidden = true;
			this.template.querySelector(".chevrondown").hidden = false;
			this.template.querySelector(".div-chevrondown").hidden = false;
		} else {
			this.listMiniature.splice(0, 1);
			this.listMiniature.push(this.listImages[4]);
			this.template.querySelector(".chevronup").hidden = false;
			this.template.querySelector(".div-chevronup").hidden = false;
			this.template.querySelector(".chevrondown").hidden = true;
			this.template.querySelector(".div-chevrondown").hidden = true;
		}
	}

	moveList(event) {
		let arrow = event && event.target ? event.target.dataset.item : event;
		let position = this.currentImagePosition;
		if (arrow === "rightArrow") {
			if (this.currentImagePosition < 4) {
				this.indicatorClicked = this.listImages[position + 1].id;
			} else {
				this.indicatorClicked = this.listImages[0].id;
			}
		} else {
			if (this.currentImagePosition > 0) {
				this.indicatorClicked = this.listImages[position - 1].id;
			} else {
				this.indicatorClicked = this.listImages[4].id;
			}
		}
		this.updateContentList();
	}

	get showUnderline() {
		return this.underline !== "";
	}

	get gtitlesize() {
		return this.titlesize;
	}
	initializeSwipe() {
		if (!this.initializedswipe) {
			let swipedivs = this.template.querySelectorAll(".swipediv");
			if (swipedivs && swipedivs.length > 0) {
				this.initializedswipe = true;
				swipedivs.forEach(swipediv => {
					swipe.swipedetect(swipediv, swipedir => {
						// swipedir contains either "none", "left", "right", "top", or "down"
						if (swipedir === "left") this.moveList("rightArrow");
						if (swipedir === "right") this.moveList("leftArrow");
						if (swipedir === "none") {
							this.openModal();
						}
					});
				});
			}
		}
	}
	initializeSwipePopups() {
		if (!this.initializedswipepopup) {
			let swipedivs = this.template.querySelectorAll(".swipedivpopup");
			if (swipedivs && swipedivs.length > 0) {
				this.initializedswipepopup = true;
				swipedivs.forEach(swipediv => {
					swipe.swipedetect(swipediv, swipedir => {
						// swipedir contains either "none", "left", "right", "top", or "down"
						if (swipedir === "left") this.moveList("rightArrow");
						if (swipedir === "right") this.moveList("leftArrow");
					});
				});
			}
		}
	}
}