import { LightningElement, api, track } from "lwc";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import pubsub from "c/cwPubSub";

import {
  removeFromComparisonCommon,
  saveComparisonListToLocalStorage
} from 'c/cwUtilities';

import getCapabilitiesFromAccountRoleDetailId_ from "@salesforce/apex/CW_FacilityCapabilitiesController.getCapabilitiesFromAccountRoleDetailId";

const VALID_VIEWS = ["cw-search-result", "cw-facility-page-container"];
const LOCAL_STORAGE_COMPARE_FIELD = "facilitiesToCompare";
const LOCAL_STORAGE_COMPARE_FIELD_DISABLED = "facilitiesToCompareDisabled";
const MAX_ITEMS_TO_COMPARE = 3;

export default class CwCompareFacilityButton extends LightningElement {

  MAX_SECONDS_LOCAL_STORAGE_VALIDATION = 15;

  isRenderedCallback = false;
  @api isDisabled = false;
  @api label;

  //   ==================
  //   Private Properties section
  //   ==================
  @track isFacilityInComparison;

  get facilitiesToCompare() {
    let tmpFacilitiesToCompare =
      JSON.parse(window.localStorage.getItem(LOCAL_STORAGE_COMPARE_FIELD)) ||
      [];

    this.isFacilityInComparison =
      tmpFacilitiesToCompare.find(curFac => curFac.Id === this.facility.Id) !==
      undefined;

    return tmpFacilitiesToCompare;
  }
  set facilitiesToCompare(value) {
    saveComparisonListToLocalStorage(value);
  }

  get isFacilityLoaded() {
    return this.facility !== null;
  } 

  //   ==================
  //   Public Properties section
  //   ==================
  _cssView = "cw-search-result";
  @api
  get cssView() {
    switch (this._cssView) {
      case "cw-facility-page-container":
        return "compare-btn-resp btn btn-primary-yellow " + this._cssView;

      default:
        //cw-search-result
        return "compare-btn-resp btn btn-primary-yellow mt-1 " + this._cssView;
    }
  }
  set cssView(value) {
    if (VALID_VIEWS.includes(value)) {
      this._cssView = value;
    }
  }

  _facility = null;
  @api
  get facility() {
    return this._facility;
  }
  set facility(value) {
    this._facility = value;
  }

  setDisable(valueDisable)
  {
    this.setDisableButton(valueDisable);


    let objDisable = {
      value: valueDisable,
      timestamp: new Date().getTime()
    }

    window.localStorage.setItem(
      LOCAL_STORAGE_COMPARE_FIELD_DISABLED,
      JSON.stringify(objDisable)
    );
  }

  setDisableButton(valueDisable){
    let compareButton = this.template.querySelector('[data-name="btnCompare"]');
    if(compareButton) {
      compareButton.disabled = valueDisable;
      if(valueDisable){
        compareButton.classList.add('disabled-btn');
      }
      else{
		compareButton.classList.remove('disabled-btn');
		this.template.querySelector('.spinnerBtnCmpr').classList.add('hidden');
      }
    }
  }

  @api addRemoveComparisonButton = false;

  _text = "COMPARE";
  @api
  get text() {
    return this._text + " (" + (this.isFacilityInComparison ? "-" : "+") + ")";
  }
  set text(value) {
    this._text = value;
  }

  //   ==================
  //   Events section
  //   ==================
  connectedCallback() {
    this.comparisonUpdatedCallback = this.comparisonUpdated.bind(this);
    this.register();
    this.facilitiesToCompare = this.facilitiesToCompare;
  }

  @api
  register() {
    pubsub.register("localstorageupdated", this.comparisonUpdatedCallback);
  }
  @track comparisonItems = [];
  comparisonUpdatedCallback;
  comparisonUpdated(payload) {
    this.facilitiesToCompare = this.facilitiesToCompare;
    this.setDisable(false);
  }

  handleOnClick() {
	this.template.querySelector('.spinnerBtnCmpr').classList.remove('hidden');
    let objDisabled = JSON.parse(window.localStorage.getItem(LOCAL_STORAGE_COMPARE_FIELD_DISABLED));

    let disabled = false;
    let expiredLocalStorage = false;

    if(objDisabled){

      if(objDisabled.timestamp){
        var dif = new Date().getTime() - objDisabled.timestamp;
        var secondsFromT1toT2 = dif / 1000;
        var secondsBetweenDates = Math.abs(secondsFromT1toT2);

        if(secondsBetweenDates > this.MAX_SECONDS_LOCAL_STORAGE_VALIDATION){
          expiredLocalStorage = true;
        }
      }

      disabled = expiredLocalStorage ? !expiredLocalStorage : objDisabled.value;
    }    

    if(disabled){
      this.showToast(
        "",
        `Compare process is already started, wait a couple of seconds`,
        "warning"
      );
      this.setDisableButton(false);
      return;
    }
    this.setDisable(true);

    if (this.isFacilityInComparison) {
      this.removeFromComparison(this.facility.Id);
    } else {
      this.addToComparison();      
    }
  }

  handleOnClickRemoveAll() {
    this.facilitiesToCompare = [];
    this.notifyComparisonUpdated();
  }

  //   ==================
  //   Functions section
  //   ==================
  addToComparison() {
    if (this.isFacilityLoaded) {
      let facility = JSON.parse(JSON.stringify(this.facility));

      // Check maximun allowed comparations
      if (this.facilitiesToCompare.length < MAX_ITEMS_TO_COMPARE === false) {
        this.showToast(
          "",
          `The maximum number of items (${MAX_ITEMS_TO_COMPARE}) to compare has been reached`,
          "warning"
        );
        this.setDisable(false);
        return;
      }

      // Check same type to compare
      let sameType = true;
      let sameTypeMsg = "";
      this.facilitiesToCompare.forEach(curFac => {
        if (sameType && curFac.recordTypeName !== facility.recordTypeName) {
          sameType = false;
          sameTypeMsg = `You can only compare stations of the same type (${curFac.recordTypeName})`;
        }
      });
      if (!sameType) {
        this.showToast("", sameTypeMsg, "error");
        this.setDisable(false);
        return;
      }

      // If all is ok, add
      if (!this.isFacilityInComparison && sameType) {
        if (facility.capabilities === undefined) {
          this.getCapabilitiesFromAccountRoleDetailId(facility, result => {
            let updatedFacilitiesToCompare = this.facilitiesToCompare;
            facility.capabilities = result;
            updatedFacilitiesToCompare.push(facility);
            this.facilitiesToCompare = updatedFacilitiesToCompare;
            this.notifyComparisonUpdated();
          });
        } else {
          let updatedFacilitiesToCompare = this.facilitiesToCompare;
          updatedFacilitiesToCompare.push(facility);
          this.facilitiesToCompare = updatedFacilitiesToCompare;
          this.notifyComparisonUpdated();
        }
      }
    }
    
  }

  removeFromComparison(idsToRemove) {

    const updatedFacilitiesToCompare = removeFromComparisonCommon(idsToRemove, this.facilitiesToCompare);

    if(updatedFacilitiesToCompare){
      this.facilitiesToCompare = updatedFacilitiesToCompare;
      this.notifyComparisonUpdated();
    }

  }

  showToast(title, message, variant) {
    const evt = new ShowToastEvent({
      title,
      message,
      variant, // info | success | warning | error
      mode: "dismissable" // dismissable | pester | sticky
    });
    this.dispatchEvent(evt);
  }

  getCapabilitiesFromAccountRoleDetailId(facility, thenCallback) {
    getCapabilitiesFromAccountRoleDetailId_({ id: facility.Id }).then(
      thenCallback
    );
  }

  notifyComparisonUpdated() {
    pubsub.fire("localstorageupdated", {
      action: "update",
      localStorageField: LOCAL_STORAGE_COMPARE_FIELD
    });
  }
}