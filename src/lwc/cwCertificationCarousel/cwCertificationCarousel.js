import { LightningElement, wire, api, track } from "lwc";
import getCertifications from "@salesforce/apex/CW_CertificationSection.getCertifications";

export default class CwCertificationCarousel extends LightningElement {
  @api title;

  @track selectedCertification = {
    Id: "",
    Name: "",
    imagen: "",
    type: "",
    description: "",
    link: "",
    classes: "clickable-box unselected"
  };
  @track resultsList;

  // Filters
  @wire(getCertifications, {
    certificationType: "",
    certificationName: ""
  })
  wiredResults({ data }) {
    if (data) {
      let result = JSON.parse(JSON.stringify(data));
      let certificationList = [];

      for (let i = 0; i < result.length; i++) {
        let resObject = result[i];

        let cert = {
          Id: resObject.Id,
          Name: resObject.Name__c,
          imagen: resObject.Image__c,
          type: resObject.Certification_Type__c,
          description: resObject.Description__c,
          link: resObject.link__c,
          classes: "clickable-box unselected"
        };
        certificationList.push(cert);
      }
      this.resultsList = certificationList;
      this.selectedCertification = this.resultsList[0];
      this.updateCss();
    }
  }

  showCertifiedEntities() {
    let searchList = [];
    let searchObject = { operator: "LIKE", value: this.title };
    searchObject.obj = "ICG_Account_Role_Detail_Certification__c";
    searchObject.field = "Certification__r.Name";
    searchObject.relationfield = "ICG_Account_Role_Detail__c";
    searchList.push(searchObject);
    window.location.href =
      "https://nextlink4-customer-portal-iata.cs85.force.com/identity/s/resultspage?q=" +
      encodeURI(btoa(encodeURI(JSON.stringify(searchList)))).replace("=", "");
  }

  get isCertificationResults() {
    if (this.resultsList) {
      return this.resultsList.length > 0;
    }

    return "";
  }

  handleAccCertSelected(event) {
    const certId = event.target.dataset.item;
    this.selectedCertification = this.resultsList.find(
      cert => cert.Id === certId
    );

    this.updateCss();
  }

  updateCss() {
    this.resultsList.forEach(element => {
      if (this.selectedCertification.Id === element.Id) {
        element.classes = "clickable-box selected";
      } else {
        element.classes = "clickable-box unselected";
      }
    });
  }

  navigateToUrl() {
    let url = this.selectedCertification.link;

    if (!url.includes("http://") && !url.includes("https://")) {
      url = "http://" + url;
    }

    window.open(url);
  }
}