import { LightningElement,api } from 'lwc';
export default class CwCertification extends LightningElement {
    
    @api certification;
    @api certificationStyle = 'certification-title';
    handleClick(event) {
        // Prevents the anchor element from navigating to a URL.
        event.preventDefault();

        // Creates the event with the contact ID data.
        const openTextEvent = new CustomEvent('selected', { detail: this.certification.Id });

        // Dispatches the event.
        this.dispatchEvent(openTextEvent);
    }

    renderedCallback() {

        Promise.all([

        ])

    }
}