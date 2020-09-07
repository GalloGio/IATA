import { LightningElement, api, track } from "lwc";
import _getCertificationList from "@salesforce/apex/CW_AccountDetailCertificationList.getCertificationList";
import { hideHover, generateCertificationImages } from "c/cwUtilities";
export default class CwAccountDetailCertificationList extends LightningElement {
	@api accountId = "";
	@api accountType = "";
	@api listDetailCertFacility;
	@api title;
	@api titlesize = "font-size-1-1-min-height-35";
	@api underline = "";
	@api hover = false;
	@api showinfo;
	@api padding = "title";
	@api certsCss = "";
	@api label;
	@track orderedImagesList = [];
	isRenderCallbackActionExecuted = false;

	error;

	renderedCallback() {
		if (this.isRenderCallbackActionExecuted) {
			return;
		}

		if (this.listDetailCertFacility) {
			this.readListCertificationList();
		} else {
			this.getCertificationList();
		}
	}

	getCertificationList() {
		_getCertificationList({
			accountId: this.accountId,
			accountType: this.accountType
		})
			.then(response => {
				let resultMap = JSON.parse(JSON.stringify(response));
				let certificationImages = [];
				Object.keys(resultMap).forEach(function(accountHasCertification) {
					resultMap[accountHasCertification].forEach(function(cert) {
						let dateArrayExd = (cert.expirationDate ? cert.expirationDate.split("-"):null);
						let expirationDate = (dateArrayExd ? dateArrayExd[2] + '-' + dateArrayExd[1] + '-' + dateArrayExd[0]:cert.expirationDate);

						let dateArrayIsd = (cert.issueDate ? cert.issueDate.split("-"):null);
						let issueDate = (dateArrayIsd ?dateArrayIsd[2] + '-' + dateArrayIsd[1] + '-' + dateArrayIsd[0]:cert.issueDate);
						
						let scope;
						let certificationId = cert.certificationId;
						let image = cert.image;
						let id = cert.id;
						let name = cert.name;
						let order = cert.order;
						let cssClass = accountHasCertification !== "false" ? "cert-account-img width-100" : "disabled-filter cert-account-img width-100";
						let hasCerts = accountHasCertification !== "false" ? true : false;
						certificationImages.push({
							Id: id,
							image: image,
							name: name,
							order: order,
							issueDate: issueDate,
							expirationDate: expirationDate,
							certificationId: certificationId,
							cssClass: cssClass,
							scope: scope,
							hasCerts: hasCerts,
							expired: false
						});
					});
				});
				this.orderImagesList(certificationImages);
			})
			.catch(error => {
				this.error = error;
			});

		this.isRenderCallbackActionExecuted = true;
	}

	readListCertificationList() {
		let certificationImages = generateCertificationImages(JSON.parse(JSON.stringify(this.listDetailCertFacility)));
		this.orderImagesList(certificationImages);
		this.isRenderCallbackActionExecuted = true;
	}

	orderImagesList(certificationImages) {
		let itemsOrdered = [];

		let highestOrderValue = 0;
		for (let i = 0; i < certificationImages.length; i++) {
			if (certificationImages[i].order >= highestOrderValue) {
				highestOrderValue = certificationImages[i].order;
			}
		}
		for (let j = 1; j <= highestOrderValue; j++) {
			for (let i = 0; i < certificationImages.length; i++) {
				if (certificationImages[i].order === j) {
					itemsOrdered.push(certificationImages[i]);
				}
			}
		}

		this.orderedImagesList = itemsOrdered;
		this.switchIenvaCertification(this.orderedImagesList);
	}

	switchIenvaCertification(orderedImages) {
		let ienvaFiltered = orderedImages;
		for (let i = 0; i < ienvaFiltered.length; i++) {
			if (ienvaFiltered[i].name === "IEnvA") {
				if (ienvaFiltered[i + 1].name === "IEnvA Stage 2" && ienvaFiltered[i + 1].Id !== "NotIncluded") {
					ienvaFiltered.splice(i, 1);
				} else {
					ienvaFiltered.splice(i + 1, 1);
				}
			}
		}
	}

	get imagesListInformed() {
		return this.orderedImagesList.length > 0 ? true : false;
	}

	showExpirationDate(event) {
		let certification = event.target.dataset.item;
		if (certification && certification !== "NotIncluded") {
			const elements = this.template.querySelector("section[data-item=" + certification + "]");
			let bounds = event.target.getBoundingClientRect();
			elements.style.marginLeft = "calc(" + bounds.width / 2 + "px" + " - 1.5rem)";
			elements.style.marginTop = bounds.height + "px";
			const classElement = elements.classList.value;
			if (classElement.includes("_hide")) {
				elements.classList = classElement.replace("slds-popover_hide", "slds-popover");
			}
		}
	}

	hideExpirationDate(event) {
		let item = event.target.dataset.item;
		hideHover(item, this.template);
	}

	get showUnderline() {
		return this.underline !== "";
	}

	get hasHover() {
		return this.hover;
	}

	get specialPadding() {
		return this.padding;
	}

	get gtitlesize() {
		return this.titlesize;
	}
}