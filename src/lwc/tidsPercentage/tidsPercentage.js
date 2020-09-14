import { LightningElement, wire, track, api } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent } from "c/tidsPubSub";

import { specialCharsValidation } from 'c/tidsUserInfo';

export default class TidsPercentage extends LightningElement {
  @api options;
  @api fieldName;
  @api rule ={
    visible: false,
    disabled: false,
    required: false,
    regex:'',
    name:'',
    translation_english:'',
    translation_japanese:'',
    translation_spanish:'',
    translation_portuguese:'',
    translation_french:'',
    translation_chinese:''
  };

  @track total = 0;
  @track totalError;
  @track specialCharsError = false;
  maximum = 100;
  @track defaultClass = "row items-total";
  @track blueClass = "row items-total items-valid";
  @track cmpClass;

  @track values;
  @api get values() {
    return this.values;
  }
  @track percentageAutoComplete = false;

  @wire(CurrentPageReference) pageRef;

  connectedCallback() {
    this.init();
  }

  init() {
    this.totalError = false;
    this.values = JSON.parse(JSON.stringify(this.options));
    this.percentageAutoComplete = this.values.length === 2 ? true : false;
    this.total = this.totalCalculation(this.values);
    this.cmpClass = this.total === 100 ? this.blueClass : this.defaultClass;
  }
  handleOnfocus(event) {
    let fieldSelected = event.target.name;
    console.log('handleOnfocus:select all',fieldSelected);
    let input =this.template.querySelector("lightning-input");
    console.log('handleOnfocus:select all',input);
    input.select();
  }
  handleOnchange(event) {
    this.total = 0;
    this.specialCharsError = false;
    let haveSpecialChars = specialCharsValidation(event.target.value);
    
    if(haveSpecialChars) {
      let index = this.values.findIndex(value => value.label === event.target.name);
      this.values[index].value = 0;
      this.specialCharsError = true;
      let result = {
        fieldName: this.fieldName,
        valid: this.total === 100 ? true: false,
        values: this.values
      }
      fireEvent(this.pageRef, "percentageListener", result);
      return;
    }

    if(event.target.value <= 100) {
      if(this.percentageAutoComplete) {
        let fieldSelected = event.target.name;
        let index = this.values.findIndex(value => value.label === fieldSelected);
        if(index === 0) {
          this.values[0].value =  Number(event.target.value);
          this.values[1].value = Number(event.target.value) === 100 ? 0 : 100 - Number(event.target.value);
        } else if(index === 1) {
          this.values[1].value =  Number(event.target.value);
          this.values[0].value = Number(event.target.value) === 100 ? 0 : 100 - Number(event.target.value);
        }
      } else {
        this.values.find(v => v.label === event.target.name).value = Number(
          event.target.value
        );
      }
    } else {
      let index = this.values.findIndex(value => value.label === event.target.name);
      this.values[index].value = Number(event.target.value);  
    }

    this.total = this.totalCalculation(this.values);
    this.totalError = this.total > this.maximum ? true : false;
    this.cmpClass = this.total === 100 ? this.blueClass : this.defaultClass;
    
    let result = {
      fieldName: this.fieldName,
      valid: this.total === 100 ? true: false,
      values: this.values
    }

    fireEvent(this.pageRef, "percentageListener", result);
  }

  totalCalculation(props) {
    let result = 0;
    Array.from(props).forEach(file => {
      result += file.value;
    });
    return result;
  }

  totalValidation(value) {
    let result = true;
    this.total = Number(this.total) + Number(value);
    if (this.total > this.maximum) {
      result = false;
    }
    return result;
  }
}