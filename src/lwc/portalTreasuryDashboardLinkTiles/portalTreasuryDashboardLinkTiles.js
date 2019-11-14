
import { LightningElement, track } from 'lwc';

//labels
import TreasuryDashboardLinks from '@salesforce/label/c.Treasury_Dashboard_Links';
import userGuide from '@salesforce/label/c.Treasury_Dashboard_User_Guide';
import currencyCenter from '@salesforce/label/c.Treasury_Dashboard_Currency_Center';
import iccs from '@salesforce/label/c.Treasury_Dashboard_ICCS';
import iccsLong from '@salesforce/label/c.Treasury_Dashboard_ICCS_Long';
import ich from '@salesforce/label/c.Treasury_Dashboard_ICH';
import ichLong from '@salesforce/label/c.Treasury_Dashboard_ICH_Long';
import bsp from '@salesforce/label/c.Treasury_Dashboard_BSP';
import bspLong from '@salesforce/label/c.Treasury_Dashboard_BSP_Long';
import cass from '@salesforce/label/c.Treasury_Dashboard_CASS';
import cassLong from '@salesforce/label/c.Treasury_Dashboard_CASS_Long';
import exchangeRates from '@salesforce/label/c.Treasury_Dashboard_Exchange_Rates';
import exchangeRatesLong from '@salesforce/label/c.Treasury_Dashboard_Exchange_Rates_Long';


//URLs
import userGuideURL from '@salesforce/label/c.Treasury_Dashboard_User_Guide_URL';
import currencyCenterURL from '@salesforce/label/c.Treasury_Dashboard_Currency_Center_URL';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalTreasuryDashboardLinkTiles extends LightningElement {

    @track labels = {
        TreasuryDashboardLinks,
        userGuide,
        currencyCenter,
        iccs,
        iccsLong,
        ich,
        ichLong,
        bsp,
        bspLong,
        cass,
        cassLong,
        exchangeRates,
        exchangeRatesLong
    }

    URLS = {
        userGuideURL,
        currencyCenterURL
    };

    @track lstTiles = [];
    @track modalHeader;
    @track modalBody;
    @track openModal;


    @track loading = true;
    iconLink = CSP_PortalPath + 'CSPortal/Images/Support/Documents.svg';

    connectedCallback() {
        let links = this.createLinks();
        let tempLinks = [];
        let iconLinksAux = this.iconLink;

        Object.keys(links).forEach(function (el) {
            tempLinks.push({ name : links[el].name, imageURL: iconLinksAux });
        });

        this.lstTiles = tempLinks;
        this.loading = false;
    }


    createLinks() {
        let links = [];
        links.push({name: this.labels.userGuide, address: 'isspAddress'});
        links.push({name: this.labels.currencyCenter, address: 'gadmAddress'});
        links.push({name: this.labels.iccs, address: 'gadmAddress'});
        links.push({name: this.labels.ich, address: 'gadmAddress'});
        links.push({name: this.labels.bsp, address: 'gadmAddress'});
        links.push({name: this.labels.cass, address: 'gadmAddress'});
        links.push({name: this.labels.exchangeRates, address: 'gadmAddress'});
        return links;
    }


    linkClicked(event) {
        let selectedLink = event.target.dataset.item;
        console.log('selectedLink:: ', selectedLink);
        if(selectedLink) {
            if (selectedLink === this.labels.userGuide) {
                this.navigateToUserGuide();
            } else if (selectedLink === this.labels.currencyCenter) {
                this.navigateToCurrencyCenter();
            }else if (selectedLink === this.labels.iccs) {
                this.showModal(selectedLink);
            } else if (selectedLink === this.labels.ich) {
                this.showModal(selectedLink);
            } else if (selectedLink === this.labels.bsp) {
                this.showModal(selectedLink);
            } else if (selectedLink === this.labels.cass) {
                this.showModal(selectedLink);
            } else if (selectedLink === this.labels.exchangeRates) {
                this.showModal(selectedLink);
            }
        }

    }


    navigateToUserGuide() {
        window.open(this.URLS.userGuideURL);
    }

    navigateToCurrencyCenter() {
        window.open(this.URLS.currencyCenterURL);
    }

    showModal(name) {
        if(name) {
            if(name === this.labels.iccs) {
                this.openModalWindow(this.labels.iccsLong, this.iccsBodyText);
            } else if (name === this.labels.ich) {
                this.openModalWindow(this.labels.ichLong, this.ichBodyText);
            } else if (name === this.labels.bsp) {
                this.openModalWindow(this.labels.bspLong, this.bspBodyText);
            } else if(name === this.labels.cass) {
                this.openModalWindow(this.labels.cassLong, this.cassBodyText);
            } else if (name === this.labels.exchangeRates) {
                this.openModalWindow(this.labels.exchangeRatesLong, this.exchangeRatesBodyText);
            }
        }

    }

    openModalWindow(headerText, bodyText) {
        this.modalHeader = headerText;
        this.modalBody = bodyText;
        this.openModal = true;
        document.body.style.overflow = 'hidden';
    }

    closeModal() {
        this.openModal = false;
        document.body.style.overflow = 'auto';
    }

    iccsBodyText = '<h4>Simplifying the business of airline treasury.</h4>' +
                    '<p>ICCS is <b>the global cash management service</b> that enables airline Treasurers to centrally control and repatriate their world-wide sales funds. It is currently used by over 336 airlines of varying sizes and had a throughput in 2018 of USD 40 billion.</p>' +
                    '</br><h4>ICCS benefits</h4>' +
                    '<ul>' +
                    '<li>Centralized control of global funds repatriation.</li>' +
                    '<li>Advanced access to receivables information allowing for more effective cash planning.</li>' +
                    '<li>Reduced time spent on international banking activities resulting in manpower savings.</li>' +
                    '<li>Accelerated repatriation of foreign sales funds resulting in improved working capital management and reduced foreign exchange risk.</li>' +
                    '<li>Decreased currency conversion costs gained from optimal foreign exchange rates.</li>' +
                    '<li>Reduced banking fees and transfer charges.</li>' +
                    '</ul>' +
                    '<p><a href="https://www.iata.org/services/finance/iccs/Pages/index.aspx" target="_New">Find out how ICCS works</a>' +
                    '</p>' +
                    '</br><h5><b>General Sales Agent (GSA) Sales</b></h5>' +
                    '<p>Learn more about how airlines can clear their foreign <a href="http://www.iata.org/services/finance/iccs/Documents/iccs_gsa_service.pdf" target="_New">GSA sales</a> (pdf) proceeds through the ICCS process.</p>' +
                    '</br><h5><b>Credit Card Sales</b></h5>' +
                    '<p>Learn more about how airlines can clear their foreign <a href="http://www.iata.org/services/finance/iccs/Documents/iccs_cc_service.pdf" target="_New">Credit Card Sales</a> (pdf) proceeds through the ICCS process.</p>';

    ichBodyText = '<p>The IATA Clearing House (ICH) provides fast, secure and cost effective billing and settlement services in multiple currencies for the air transport industry.</p>' +
                   '</br><p>It enables the world\'s airlines and airline-associated companies <q>suppliers</q> to settle their Passenger, Cargo, UATP and Miscellaneous/Non-Transportation billings by applying the principles of set-off/netting thus reducing cost, risk and increasing speed.</p>' +
                   '</br><p>The ICH also offers a dispute mechanism of billings and protection in case of default, bankruptcy, and cessation of operations. </p>' +
                   '</br><p>In 2018, the ICH processed $62.1 billion and had a financial settlement success rate of 99.999%.</p>' +
                   '</br><p>ICH is tightly linked to "SIS" Simplified Invoicing and Settlement, IATA\'s electronic invoicing system being the only entry point.</p>' +
                   '</br><p>The ICH, now 72 years old, is the hub of a global system covering more than 460 participants with 305+ airline members, and 155+ non-airline members "suppliers" (companies that do substantial business in the airline industry such as Ground Handlers, MRO\'s, Caterers, IT companies, GDS\' etc.). </p>' +
                   '</br><p>ICH obtained in January 2019 the Service Organization Control Type II Audit Certification (SOC 2), being an audit on controls relating to security, availability, processing integrity and confidentiality.</p>' +
                   '</br><p><a href="https://www.iata.org/services/finance/clearinghouse/Pages/index.aspx" target="_New">ICH Corporate Website</a></p>' +
                   '</br><p><a href="http://www.iata.org/services/finance/clearinghouse/Documents/ich-members-list.pdf" target="_New">ICH Member List</a> (pdf)</p>';

    bspBodyText = '<p>BSP is a system designed to facilitate and simplify the selling, reporting and remitting procedures of IATA Accredited Passenger Sales Agents, as well as improve financial control and cash flow for BSP Airlines.</p>' +
                   '<p>A truly worldwide system: there are BSP operations in some 180 countries and territories. The system currently serves more than 370 participating airlines with an on-time settlement rate of 99.999%. In 2017, IATA\'s BSP processed $236.3 billion.</p>' +
                   '</br><h4>Benefits of a BSP Simplification</h4>' +
                   '<ul>' +
                   '<li>Agents issue one sales report and remit one amount to a central point</li>' +
                   '<li>Airlines receive one settlement covering all agents</li>' +
                   '<li>Simplifies and reduces work through the use of electronic ticketing on behalf of all BSP Airlines</li>' +
                   '<li>Agents\' sales are reported electronically</li>' +
                   '</ul>' +
                   '<h4>Savings</h4>' +
                   '<ul>' +
                   '<li>Less resources required for billing and collection </li>' +
                   '<li>Electronic distribution of billing reports, and generation of debit/credit memos (ADMs/ACMs) via <a href="http://www.iata.org/services/finance/bsp/Pages/bsplink.aspx" target="_New">BSPlink</a>' +
                   '</li>' +
                   '</ul>' +
                   '<h4>Enhanced Control</h4>' +
                   '<ul>' +
                   '<li>Increased financial control thanks to centralization and grouping</li>' +
                   '<li>Consolidated document flow, permitting accelerated quality controls</li>' +
                   '<li>Overall process monitoring by a neutral body</li>' +
                   '</ul>' +
                   '<h4>Participation in a BSP Airlines</h4>' +
                   '<p>Participation in a BSP is open to all airlines (IATA members and non-members) serving the country or area concerned.</p>' +
                   '</br><h4>IATA Accredited Agents</h4>' +
                   '<p>All IATA Accredited Agents in the BSP country of operation are automatically eligible for participation in a BSP. When a new BSP commences operations in a country, all Agents are notified by IATA and invited to participate.</p>' +
                   '</br><h4>General Sales Agents (GSAs) and Airport Handling Agents (AHA)</h4>' +
                   '<p>GSAs and AHAs may participate in a BSP (in the same way as Accredited Agents), on nomination by the airline they represent, and subject to the airline entering into a standard agreement. </p>' +
                   '<p>To obtain the local participation criteria and conditions, please contact <a title="" href="http://www.iata.org/customer-portal/Pages/index.aspx" target="_New">customer service</a> for your region.</p>';

    cassBodyText = '<p>Cargo Account Settlement Systems (CASS) is designed to simplify the billing and settling of accounts between airlines and freight forwarders. It operates through <a href="http://www.iata.org/services/finance/Pages/casslink.aspx" target="_New">CASSlink</a>, an advanced global web-enabled e-billing solution.</p>' +
                    '</br><p>At the end of 2018, CASS was processing in 85 CASS Export operations, 9 CASS Import & Terminal Charges collectively serving over 500 Airlines, GSSAs and Ground Handling Companies and settling a combined $32 billion. The on-time settlement rate was 99.996%.</p>' +
                    '</br><h4>CASS advantages</h4>' +
                    '<p>CASS yields a two-fold solution as it replaces:</p>' +
                    '</br><p>a) Airlines\' traditional paper based invoicing</p>' +
                    '</br><p>b) Agents\' manual controlling of those invoices, while all benefit from:</p>' +
                    '<ul>' +
                    '<li>Streamlined invoicing and collection of sales revenue processes</li>' +
                    '<li>A neutral settlement office</li>' +
                    '<li>Total flexibility to manage data centrally or from any field office with CASSLink\'s web-based application</li>' +
                    '<li>The elimination of invoices\' loss or fail to deliver thanks to electronic production and distribution</li>' +
                    '<li>Enhanced financial control and improved cash flow as the CASS rate of success in collecting funds is virtually 100%</li>' +
                    '</ul>' +
                    '<h4>CASS implementation</h4>' +
                    '<p>Any market may host a CASS operation as long as there is enough volume, i.e., more than one airline/freight forwarder. IATA conducts a market assessment to identify all potential participants, operational practices, and the cost of operating. The implementation is then subject to that market\'s group of airlines\' decision to join and bear the cost of operating the CASS.</p>' +
                    '</br><h4>Participation and costs</h4>' +
                    '<p>IATA accredited agents join CASS at no cost whereas non-IATA agents or other intermediaries may join at a cost determined locally. If you are a freight forwarder and want to know more about participation in CASS, contact your local CASS Manager or get in touch with your regional <a href="http://www.iata.org/customer-portal/Pages/index.aspx" target="_new">customer service</a>.</p>' +
                    '</br><p>All airlines are eligible to participate. Entry fees are $2,500 for IATA member Airlines and $3,500 for non-member Airlines or GSA\'s. All other costs are shared equally based on the respective volumes airlines process through the system. For Airlines or GSA\'s wanting more information or to join CASS, please contact <a href="http://www.iata.org/customer-portal/Pages/index.aspx" target="_new">Customer Service</a>.</p>' +
                    '</br><p>To find out more about participation in CASS, go to the <a href="http://www.iata.org/services/finance/Documents/isssp-cargo-manual.pdf" target="_New">IATA Settlement Systems Service Provisions (Cargo) Manual</a> (pdf).</p>';

    exchangeRatesBodyText = '<p>International air transport depends on the ability to establish tariffs, use the service of interline partners and to settle amounts due for interlining traffic in the agreed settlement currency. In order to establish selling fares and to perform interline invoicing and settlement, airlines must have rates of exchange between world currencies. Rules have been developed and maintained so that exchange rates are monitored against base currencies such as USD, GBP, EURO.</p>' +
                          '</br><p>There are five sets of rates that are produced for airlines.</p>' +
                          '</br><h4>Call Day Rates (CDR)</h4>' +
                          '<p>Call Day Rates are the rates for one day each period, seven days after the <q>advice day</q> that the IATA Clearing House accepts or makes payments. CDR\'s are calculated by taking an average of the buying and selling rates on the day of payment. These rates are used to ensure that ICH customers are not exposed to any currency exchange risk on miscellaneous interline billings that may occur between the time an invoice is billed through the ICH and the time that it is settled.</p>' +
                          '</br><h4>Five Day Rates (FDR)</h4>' +
                          '<p>Five day rates are the average of the exchange rates for the five banking days ending on the 25th of each month. This calculation is based on the average between the buying and selling rates and the rates are expressed in USD, EUR, and GBP. FDR\'s are used by ICH members to convert interline billing into the billing currency. The previous month\'s FDR\'s are used for the current month\'s interline billing. The process developed to calculate the FDR\'s also contains a function to identify differentials of over 10% between one month and the next.</p>' +
                          '</br><h4>Monthly Mean Rates (MMR)</h4>' +
                          '<p>If the calculation of a Five Day Rate (FDR) demonstrates a differential of over 10%, the ICH also produces an alternative rate by calculating the average of that currency\'s exchange rate for the entire month. This alternative rate is called the Monthly Mean Rate and is used by ICH members to adjust their cargo and passenger invoices.</p>' +
                          '</br><h4>IATA Rates of Exchange (IROE)</h4>' +
                          '<p>IATA Rates of Exchange (also referred to as NUC) provides monthly updates of rates of exchange used by the industry for fare/rate construction. They are built based on the average of the five banking days ending on the 10th of each month. Subscriptions to the Exchange Rate files can be purchased at the following link: <a href="https://www.iata.org/services/finance/Pages/xrates.aspx" target="_New">IATA Exchange Rates</a>.</p>' +
                          '</br><h4>IATA Consolidated Exchange Rates (ICER)</h4>' +
                          '<p>IATA Consolidated Exchange Rates provides daily updates of exchange rates (also referred to as BSR) to be used when converting fares, taxes, and fees to alternate currencies where required for pricing and ticketing transactions. The ICER rates are provided on a daily basis (Monday through Friday).</p>';
}