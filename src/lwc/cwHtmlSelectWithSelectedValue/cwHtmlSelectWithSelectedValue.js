import { LightningElement, api, track } from "lwc";

export default class cwHtmlSelectWithSelectedValue extends LightningElement {
  initialized = false;

  @api attribName = "";
  @api attribClass = "";
  @api attribDisabled = false;

  @api selectedValue = "";
  @api items = [];

  @track itemsProcessed = [];

  renderedCallback() {
    if (!this.initialized) {
      this.initialized = true;

      this.itemsProcessed = new Array();
      this.items.forEach(function(item) {
        let newItem = JSON.parse(JSON.stringify(item));
        newItem.selected = newItem.value === this.selectedValue;

        this.itemsProcessed.push(newItem);
      }, this);
    }
  }

  onchange(event) {
    // Creates the event with the data and dispatches.
    const changeEvent = new CustomEvent("change", {
      detail: event
    });
    this.dispatchEvent(changeEvent);
  }
}