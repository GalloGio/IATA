import { LightningElement, wire, api, track } from "lwc";
import getCertificationList from "@salesforce/apex/CW_AccountDetailCertificationList.getCertificationList";
import { loadStyle } from "lightning/platformResourceLoader";
import certImagesResource from "@salesforce/resourceUrl/Certification_Images";

export default class CwAccountDetailCertificationList extends LightningElement {
  @api accountName = "";
  @api title;

  @track orderedImagesList = [];

  error;

  @wire(getCertificationList, { accountName: "$accountName" })
  wiredResults({ error, data }) {
    if (data) {
      let resultMap = JSON.parse(JSON.stringify(data));
      let certificationImages = [];

      Object.keys(resultMap).forEach(function(accountHasCertification) {
        resultMap[accountHasCertification].forEach(function(cert) {
          let image;
          let id = cert.Id;
          let name = cert.Name__c;
          let order = cert.Order__c;

          let certImage = cert.Image__c;
          if (accountHasCertification === "true") {
            image = certImage;
          } else {
            if (certImage.includes("/")) {
              let splittedImage = certImage.split("/");
              image =
                certImagesResource +
                "/grey-" +
                splittedImage[splittedImage.length - 1];
            }
          }

          certificationImages.push({
            Id: id,
            image: image,
            name: name,
            order: order
          });
        });
      });

      this.orderImagesList(certificationImages);
    } else if (error) {
      this.error = error;
    }
  }

  orderImagesList(certificationImages) {
    var itemsOrdered = [];

    let highestOrderValue = 0;
    for (let i = 0; i < certificationImages.length; i++) {
      if(certificationImages[i].order >= highestOrderValue){
        highestOrderValue = certificationImages[i].order;
      }
    }
    for (let j = 1; j <= highestOrderValue; j++) {
      for(let i = 0; i < certificationImages.length; i++){
        if (certificationImages[i].order === (j) ) {
          itemsOrdered.push(certificationImages[i]);
        }
      }
    }

    this.orderedImagesList = itemsOrdered;
  }

  get imagesListInformed() {
    return this.orderedImagesList.length > 0 ? true : false;
  }
}