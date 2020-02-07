import { LightningElement, api } from 'lwc';

export default class IataContentSection extends LightningElement {
    @api title;
    @api subtitle;
}