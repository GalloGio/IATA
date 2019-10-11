import { LightningElement, api } from "lwc";

export default class CwTextContainer extends LightningElement {
  // logo = file + '/IATA-CSS-guidelines-v1/assets/iata-logo.svg';

  @api
  title = "Default title";

  @api
  titleColor = "";
  get getTitleColor() {
    return "color: " + this.titleColor;
  }
  // @api
  // styletitle = '';

  @api
  text ="";

  @api
  text2 = "";

  @api
  text3 = "";

  // @api
  // styletext = '';
  @api textColor = "";
  get getTextColor() {
    return "color: " + this.textColor;
  }

  @api
  buttonColor = "";

  // @api
  // buttomname = '';

  @api
  buttonText = "";

  @api
  buttonTextTwo = "";

  @api
  closeButton = "";

  // @api
  // urlbuttom = '';
  @api
  buttonUrl = "";

  @api
  buttonTarget = "_blank";

  @api
  buttonPosition = "left";

  // @api
  // stylebuttom = '';

  // @api
  // background = 'bg-white';
  @api
  backgroundColor = "";

  get getMainStyle() {
    return "background-color: " + this.backgroundColor + "; padding:25px;";
  }
  // get hasButton() {
  //     if(this.buttomname !=='')
  //         return true;
  //     return false;
  // }

  renderedCallback() {
    Promise.all([
    ]);
  }

  closeTextContainer() {
    this.dispatchEvent(new CustomEvent("closetextcontainer"));
  }

  navigateToUrl() {
    let url;

    if (
      !this.buttonUrl.includes("http://") &&
      !this.buttonUrl.includes("https://")
    ) {
      url = "http://" + this.buttonUrl;
    } else {
      url = this.buttonUrl;
    }

    window.open(url);
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

  get showButton() {
    return this.buttonText !== "";
  }

  get showButtonTwo() {
    return this.buttonTextTwo !== "";
  }

  get showCloseButton() {
    return this.closeButton !== "";
  }

  get showp1() {
    return this.text !== "";
  }
  get showp2() {
    return this.text2 !== "";
  }
  get showp3() {
    return this.text3 !== "";
  }
}