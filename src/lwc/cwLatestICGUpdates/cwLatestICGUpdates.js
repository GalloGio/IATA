import { LightningElement, api } from "lwc";

export default class CwLatestICGUpdates extends LightningElement {
  @api
  buttonUrl;

  @api
  buttonText;

  @api
  certImageUrl = "";

  @api
  prevImageUrl = "";

  @api
  nextImageUrl = "";

  // Filters
  @api
  certificationType = "";

  @api
  certificationName = "";

  @api
  accRoleDetailName = "";

  @api
  accRoleDetailCity = "";

  @api
  accCertId = "";

  previousHandler() {
    this.dispatchEvent(new CustomEvent("previous"));
  }

  nextHandler() {
    this.dispatchEvent(new CustomEvent("next"));
  }
}