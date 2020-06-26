import { LightningElement, api } from 'lwc';

export default class CwOtherValidationProgram extends LightningElement {
    @api title;
    @api titlesize="font-size-1-1-min-height-35";
    @api underline ="";



    get showUnderline() {
        return this.underline !== "";
      }
      get gtitlesize(){
        return this.titlesize;
    }


}