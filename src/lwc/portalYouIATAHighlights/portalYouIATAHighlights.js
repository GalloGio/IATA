import { LightningElement, track } from 'lwc';


/* LABELS */
import CSP_YouIATA_Highlights_Text from '@salesforce/label/c.CSP_YouIATA_Highlights_Text';
import CSP_YouIATA_Highlights from '@salesforce/label/c.CSP_YouIATA_Highlights';


export default class PortalYouIATAHighlights extends LightningElement {

    @track labels = {
        CSP_YouIATA_Highlights_Text,
        CSP_YouIATA_Highlights
    };
}