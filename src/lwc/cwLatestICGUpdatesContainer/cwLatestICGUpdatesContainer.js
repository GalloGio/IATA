import { LightningElement, wire, api, track } from "lwc";
import getLatestAccountCertifications from "@salesforce/apex/CW_CertificationSection.getLatestAccountCertifications";
import icons from "@salesforce/resourceUrl/icons";

export default class CwLatestICGUpdatesContainer extends LightningElement {
  @api
  title;

  prevImageUrl = icons + "/icons/double_arrow_right.svg";

  nextImageUrl = icons + "/icons/double_arrow_left.svg";

  @track selectedAccCertification = {
    Id: "",
    image: "",
    certName: "",
    accName: "",
    city: "",
    classes: "clickable-box unselected"
  };
  @track resultsList;

  // Filters
  @wire(getLatestAccountCertifications, {})
  wiredResults({ data }) {
    if (data) {
      let result = JSON.parse(JSON.stringify(data));
      let certificationList = [];

      for (let i = 0; i < result.length; i++) {
        let resObject = result[i];

        let accCert = {
          Id: resObject.Id,
          image: resObject.Certification__r.Image__c,
          certName: resObject.Certification__r.Name__c,
          accName: resObject.ICG_Account_Role_Detail__r.Name,
          city: resObject.ICG_Account_Role_Detail__r.City__c,
          classes: "clickable-box unselected"
        };
        certificationList.push(accCert);
      }
      this.resultsList = certificationList;
      this.selectedAccCertification = this.resultsList[0];
      this.updateCss();
    }
  }

  get isaccCertificationResults() {
    if (this.resultsList) {
      return this.resultsList.length > 0;
    }

    return "";
  }

  handleAccCertSelected(event) {
    const accCertId = event.target.dataset.item;
    this.selectedAccCertification = this.resultsList.find(
      accCert => accCert.Id === accCertId
    );

    this.updateCss();
  }

  previousHandler() {
    let index = this.findIndex();

    if (index > -1) {
      if (index === 0) {
        index = this.resultsList.length - 1;
      } else {
        index--;
      }

      this.selectedAccCertification = this.resultsList[index];
      this.updateCss();
    }
  }

  updateCss() {
    this.resultsList.forEach(element => {
      if (this.selectedAccCertification.Id === element.Id) {
        element.classes = "clickable-box selected";
      } else {
        element.classes = "clickable-box unselected";
      }
    });
  }

  nextHandler() {
    let index = this.findIndex();

    if (index > -1) {
      if (index === this.resultsList.length - 1) {
        index = 0;
      } else {
        index++;
      }

      this.selectedAccCertification = this.resultsList[index];
      this.updateCss();
    }
  }

  findIndex() {
    if (!this.selectedAccCertification.Id) return -1;

    return this.resultsList.findIndex(
      result => result.Id === this.selectedAccCertification.Id
    );
  }
}