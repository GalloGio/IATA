/**
 * Created by bkaya01 on 17/07/2019.
 */

import { LightningElement, track, api } from 'lwc';

import ISSP_Registration_Privacy   from '@salesforce/label/c.ISSP_Registration_Privacy';
import ISSP_Registration_Legal     from '@salesforce/label/c.ISSP_Registration_Legal';
import csp_Footer_Legal_URL        from '@salesforce/label/c.csp_Footer_Legal_URL';
import csp_Footer_Privacy_URL      from '@salesforce/label/c.csp_Footer_Privacy_URL';

export default class PortalLoginContainer extends LightningElement {

    labels = {
        csp_Footer_Legal_URL,
        csp_Footer_Privacy_URL,
        ISSP_Registration_Legal,
        ISSP_Registration_Privacy
    };
}