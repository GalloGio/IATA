import { LightningElement, api } from "lwc";
import certImagesResource from "@salesforce/resourceUrl/Certification_Images";

export default class CwCertificationPanel extends LightningElement {
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

    if (certificationSectionClicked === "Operational Certifications")
      this.operationalOpen = true;
    else if (certificationSectionClicked === "Certifications of Excellency")
      this.excellencyOpen = true;
    else if (certificationSectionClicked === "Assessments")
      this.assessmentsOpen = true;
  }

  get backGroundImage() {
    let imageUrl = certImagesResource + "/background-certifications.png";
    return "background-image:url(" + imageUrl + ")";
  }
}