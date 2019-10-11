import { LightningElement, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import file from '@salesforce/resourceUrl/IATA_CSS_guidelines_v1';
import icons from '@salesforce/resourceUrl/icons';

export default class CwHeader extends LightningElement {

    logo = file + '/IATA-CSS-guidelines-v1/assets/iata-logo.svg';
    menuresponsive = icons + '/icons/responsive/ic-menu--open.svg';


    handleClick(event) {
        let targetId = event.target.dataset.targetId;
        let target = this.template.querySelector(`[data-id="${targetId}"]`);
        target.scrollIntoView();
    }

    renderedCallback() {

        Promise.all([
            loadStyle(this, file + '/IATA-CSS-guidelines-v1/css/screen.css'),
            loadScript(this, file + '/IATA-CSS-guidelines-v1/bower_components/jquery/dist/jquery.min.js'),
            loadScript(this, file + '/IATA-CSS-guidelines-v1/bower_components/bootstrap/dist/js/bootstrap.min.js')
        ])

    }

    showresponsivemenu() {
        let menur = this.template.querySelector('.collapse');
        if (menur) {
            this.template.querySelector('.navbar-collapse').classList.remove('collapse');
            this.template.querySelector('.icoresponsivemenu').src = icons + '/icons/responsive/ic-menu--closed.svg';
        } else {
            this.template.querySelector('.navbar-collapse').classList.add('collapse');
            this.template.querySelector('.icoresponsivemenu').src = icons + '/icons/responsive/ic-menu--open.svg';
        }
    }
}