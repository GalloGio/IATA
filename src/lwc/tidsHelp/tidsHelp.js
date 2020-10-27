import { LightningElement,track } from 'lwc';
import tidsAssetsPath from "@salesforce/resourceUrl/tidsAssets";

export default class TidsHelp extends LightningElement {
  @track helpIcon = tidsAssetsPath + '/assets/help.png';
  connectedCallback() {
    
  }
}