import { LightningElement, api } from "lwc";
import resources from "@salesforce/resourceUrl/ICG_Resources";

export default class CwCertificationPanel extends LightningElement {
	@api label;

	@api
	title = "IATA Validation Programs";

	@api
	backGroundStyle;

	@api
	assessmentsOpen = false;

	@api
	excellencyOpen = false;

	@api
	operationalOpen = false;

	handleCertificationClicked(event) {
		const certificationSectionClicked = event.detail;

		this.excellencyOpen = false;
		this.operationalOpen = false;
		this.assessmentsOpen = false;

		if (certificationSectionClicked === this.label.certifications_of_compliance) {
			this.operationalOpen = true;
		} else if (certificationSectionClicked === this.label.certification_of_excellence) {
			this.excellencyOpen = true;
		} else if (certificationSectionClicked === "Assessments") {
			this.assessmentsOpen = true;
		}
	}

	get backGroundImage() {
		return "backgroundCertifications";
	}
}