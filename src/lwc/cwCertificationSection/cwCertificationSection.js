import { LightningElement, wire, api, track } from "lwc";
import getCertifications from "@salesforce/apex/CW_CertificationSection.getCertifications";

export default class CwCertificationSection extends LightningElement {
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

  // Filters
  // Type of the certification
  @api certificationType = "";

  // Name of the certification
  @api certificationName = "";

  // Filters
  @wire(getCertifications, {
    certificationType: "$certificationType",
    certificationName: "$certificationName"
  })
  wiredResults({ error, data }) {
    if (data) {
      console.log("JSON.stringify(data)", JSON.stringify(data));
      this.result = JSON.parse(JSON.stringify(data));
      let certificationList = [];
      let certificationRow = [];
      let certificationMap = [];

      // Value by Default --> 5
      // MAX LIMIT COLUMS --> 6 (Because of the styling of the html)
      let columsLimit =
        this.columsLimit !== "" && this.columsLimit !== undefined
          ? parseInt(this.columsLimit)
          : 5;
      let rows = this.result.length / columsLimit;

      for (let i = 0; i < this.result.length; i++) {
        certificationList.push({
          Id: this.result[i].Id,
          Name: this.result[i].Name__c,
          imagen: this.result[i].Image__c,
          link: this.result[i].link__c,
          description: this.result[i].Description__c
        });
      }

      let i = 0;
      for (let n = 0; n < rows; n++) {
        for (i; i < columsLimit; i++) {
          if (
            certificationList[i] != null &&
            certificationList[i] !== undefined
          ) {
            certificationRow.push(certificationList[i]);
          }
        }
        certificationMap.push({ row: n, data: certificationRow });
        certificationRow = [];
        columsLimit +=
          this.columsLimit !== "" && this.columsLimit !== undefined
            ? parseInt(this.columsLimit)
            : 5;
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
    this.textStyle = "bg-blue";
    const certificationId = event.detail;
    if (this.selectedCertification === undefined) {
      this.selectedCertification = this.result.find(
        certification => certification.Id === certificationId
      );
    } else {
      if (
        this.selectedCertification ===
        this.result.find(certification => certification.Id === certificationId)
      ) {
        this.selectedCertification = false;
      } else {
        this.selectedCertification = this.result.find(
          certification => certification.Id === certificationId
        );
      }
    }
    // For Styling
    if (
      this.selectedCertification !== undefined &&
      this.selectedCertification !== false
    ) {
      for (let i = 0; i < this.result.length; i++) {
        if (this.result[i].Id === certificationId) {
          this.textStyle = "box-position" + (i + 1) + "of" + this.result.length;
        }
      }
    }

    const titleToSend = this.title;

    event.preventDefault();
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

  get backGroundImage() {
    return "background-image:url('https://iata--nextlink1--c.cs83.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=0684E000000DiVQ&operationContext=CHATTER&contentId=05T4E000000FYmd')";
  }
}