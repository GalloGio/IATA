import { LightningElement, api, track } from 'lwc';

export default class CwSimpleTooltip extends LightningElement {
    @api label;
    @api itemId = "";
    @api tooltipToDisplay = "";
    initialized = false;

    @track _tooltipObject;

    @api 
    get tooltipObject(){
        return this._tooltipObject;
    }

    set tooltipObject(value){
        this._tooltipObject = value;
        if(this._tooltipObject){
            this.updateMargins();
        }
        
    }

    get cssClass(){
        let cssClasses = "slds-nubbin_top-left popover-custom";
        const isTooltipToShow = this.tooltipObject && (this.tooltipToDisplay === this.tooltipObject.item) && (this.tooltipToDisplay === this.itemId);
        const hasText = this.tooltipObject && this.tooltipObject.text;
        cssClasses += hasText && isTooltipToShow ? " slds-popover" : " slds-popover_hide"; 
        return cssClasses;
    }

    get getText(){
        return (this.tooltipObject && this.tooltipObject.text) ? this.tooltipObject.text : "";
    }

    updateMargins(){
        const elements = this.template.querySelector("section[data-item=popover-item]");
        if(elements){
            const marginLeft = this.tooltipObject.marginLeft ? this.tooltipObject.marginLeft : 0;
            const marginTop = this.tooltipObject.marginTop ? this.tooltipObject.marginTop : 0;
            elements.style.marginLeft = marginLeft + "px";
            elements.style.marginTop = marginTop + "px";
        }

    }
}