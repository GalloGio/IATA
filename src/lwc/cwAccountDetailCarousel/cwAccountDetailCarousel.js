import { LightningElement, wire, api, track } from "lwc";
import getFacilityFiles_ from "@salesforce/apex/CW_AccountDetailCarousel.getFacilityFiles";
import hideImageSelected_ from "@salesforce/apex/CW_AccountDetailCarousel.hideImageSelected";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import swipe from "c/cwSwipe";
import {refreshApex} from '@salesforce/apex';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CwAccountDetailCarousel extends LightningElement {
	localRecordId = "";
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
	@track positionMiniatureMap = new Map();
	isLoading = false;

	isRenderedCallback = false;

	error = "";
	@track index = 0;
	@track currentImagePosition = 0;
	@api editMode = false;
	@track showFileUploadCarousel = false;
	@track showFileHideCarousel=false;
	indexMap = 1;
	lastIndexMap = 0;
    
    get showAsCreateStation() {
		return this.localRecordId == "";
	}

	@api
	get recordId(){
		return this.localRecordId;
	}
	set recordId(value){
	if(this.localRecordId != value)
		this.localRecordId = value;
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

	get listImagesLength(){
		return this.listImages.length;
	}

	getFacilityFiles(id) {
		this.isLoading = true;
		getFacilityFiles_({ recordId: id })
			.then(result => {
				this.data = result;
				if (this.data) {
					let imagesList = JSON.parse(JSON.stringify(this.data));
					let listMiniature = [];
					let index = 1;
					let indexMap = 1;
					imagesList.forEach(img => {						
						img.url = img.urlImage;

						if(index !== 4*indexMap ){
							listMiniature.push(img);
							if(index === imagesList.length){
								this.positionMiniatureMap.set(indexMap,listMiniature);
							}
						}
						else{
							listMiniature.push(img);
							this.positionMiniatureMap.set(indexMap,listMiniature);
							indexMap++;
							listMiniature = [];
						}
						index++;
					});
					this.lastIndexMap = indexMap;

					if (imagesList !== undefined && imagesList.length > 0) {
						this.urlImageModal = imagesList[0].url;
					}

					this.listImages = imagesList;
					this.listMiniature = this.positionMiniatureMap.get(1);
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
			.catch(err => console.error(err))
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
			this.indexMap = this.indexMap - 1;
			this.listMiniature = this.positionMiniatureMap.get(this.indexMap);
			if(this.indexMap === 1){
				this.template.querySelector(".chevronup").hidden = true;
				this.template.querySelector(".div-chevronup").hidden = true;
			}			
			this.template.querySelector(".chevrondown").hidden = false;
			this.template.querySelector(".div-chevrondown").hidden = false;
		} else {
			this.indexMap = this.indexMap + 1;
			this.listMiniature = this.positionMiniatureMap.get(this.indexMap);
			this.template.querySelector(".chevronup").hidden = false;
			this.template.querySelector(".div-chevronup").hidden = false;
			if(this.indexMap === this.lastIndexMap){
				this.template.querySelector(".chevrondown").hidden = true;
				this.template.querySelector(".div-chevrondown").hidden = true;
			}
			
		}
	}

	moveList(event) {
		let arrow = event && event.target ? event.target.dataset.item : event;
		let position = this.currentImagePosition;

		if (arrow === "rightArrow") {
			if (position < this.listImagesLength-1) {
				this.indicatorClicked = this.listImages[position + 1].id;
			} else {
				this.indicatorClicked = this.listImages[0].id;
			}
		} else {
			if (position > 0) {
				this.indicatorClicked = this.listImages[position - 1].id;
			} else {
				this.indicatorClicked = this.listImages[this.listImagesLength-1].id;
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
						if (swipedir === "left") this.moveList("rightArrow");
						if (swipedir === "right") this.moveList("leftArrow");
					});
				});
			}
		}
	}
}