import { LightningElement, wire, api, track } from "lwc";
import getCertifications from "@salesforce/apex/CW_CertificationSection.getCertifications";

export default class CwCertificationSection extends LightningElement {
	@api label;

	@api title;

	@api certificationEmptyText = "";

	@api columsLimit;

	@api backGroundStyle;

	@api shouldBeOpen;

	@track selectedCertification;

	@track textStyle;

	@track certificationMapInfo;

	@track error;

	@track result;

	@track showinfoInbound;

	@track certificaId;

	// Filters
	// Type of the certification
	@api certificationType = "";

	// Name of the certification
	@api certificationName = "";

	maxCertLenght = 3;

	// Filters
	@wire(getCertifications, {
		certificationType: "$certificationType",
		certificationName: "$certificationName"
	})
	wiredResults({ error, data }) {
		if (data) {
			this.result = JSON.parse(JSON.stringify(data));
			let certificationList = [];
			let certificationRow = [];
			let certificationMap = [];

			// Value by Default --> 5
			// MAX LIMIT COLUMS --> 6 (Because of the styling of the html)
			let columsLimit = this.columsLimit !== "" && this.columsLimit !== undefined ? parseInt(this.columsLimit) : 5;
			let rows = this.result.length / columsLimit;

			for (let i = 0; i < this.result.length; i++) {
				//TODO INIT - TEMPORAL FIX until us related to new fields will be done
				if (this.result[i].Name === "IEnvA Stage 2") {
					continue;
				}
				// TODO END
				certificationList.push({
					Id: this.result[i].Id,
					Name: this.result[i].Name,
					imagen: this.result[i].Image__c,
					link: this.result[i].link__c,
					description: this.result[i].Description__c,
					techOrder: this.result[i].Tech_Order__c,
					expirationDate: this.result[i].Expiration_Period__c
				});
			}
			this.result.sort((a, b) => (a.Tech_Order__c > b.Tech_Order__c ? 1 : -1));
			certificationList.sort((a, b) => (a.techOrder > b.techOrder ? 1 : -1));

			let i = 0;
			for (let n = 0; n < rows; n++) {
				for (i; i < columsLimit; i++) {
					if (certificationList[i] != null && certificationList[i] !== undefined) {
						certificationRow.push(certificationList[i]);
					}
				}
				certificationMap.push({ row: n, data: certificationRow });
				certificationRow = [];
				columsLimit += this.columsLimit !== "" && this.columsLimit !== undefined ? parseInt(this.columsLimit) : 5;
			}
			this.certificationMapInfo = certificationMap;
			// this.selectedCertification = this.result[0];
		} else if (error) {
			this.error = error;
			this.certificationMap = undefined;
		}
	}

	get isCertificationResults() {
		return this.certificationMapInfo.length > 0;
	}

	getCertificationDetail(event) {
		event.preventDefault();
		this.textStyle = "bg-blue width-100";

		const certificationId = event.detail;
		if (this.selectedCertification === undefined) {
			this.selectedCertification = this.result.find(certification => certification.Id === certificationId);
		} else {
			if (this.selectedCertification === this.result.find(certification => certification.Id === certificationId)) {
				this.selectedCertification = false;
			} else {
				this.selectedCertification = this.result.find(certification => certification.Id === certificationId);
			}
		}
		// For Styling
		if (this.selectedCertification !== undefined && this.selectedCertification !== false) {
			const maxSize = this.result.length <= 3 ? this.result.length : 3;
			const forCounter = this.result.length > maxSize ? this.result.length : maxSize;
			for (let i = 0; i < forCounter; i++) {
				if (this.result[i].Id === certificationId) {
					let counter = i >= maxSize ? i - 1 : i;
					this.textStyle = "box-position" + (counter + 1) + "of" + maxSize + " width-100";
				}
			}
		}

		const titleToSend = this.title;

		this.dispatchEvent(
			new CustomEvent("certificationclicked", {
				detail: titleToSend
			})
		);
	}

	renderedCallback() {
		Promise.all([]);

		if (!this.shouldBeOpen) {
			this.selectedCertification = undefined;
		}
	}

	handleTextContainerClose() {
		this.selectedCertification = undefined;
	}

	showInfoCertification(event) {
		this.showinfoInbound = true;
		this.certificaId = event.target.dataset.item;
	}

	hideInfoCertification(event) {
		this.certificaId = event.target.dataset.item;
		this.showinfoInbound = false;
	}
}