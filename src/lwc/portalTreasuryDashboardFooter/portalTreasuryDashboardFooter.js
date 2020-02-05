import { LightningElement, track } from 'lwc';

//URLs
import fxRatesUrl from '@salesforce/label/c.Treasury_Dashboard_FX_Rates_URL';
import bankHolidaysUrl from '@salesforce/label/c.Treasury_Dashboard_Bank_Holidays_URL';
import centralBanksUrl from '@salesforce/label/c.Treasury_Dashboard_Central_Banks_World_Wide_URL';
import marketNewsUrl from '@salesforce/label/c.Treasury_Dashboard_Market_News_URL';
import termsOfUseUrl from '@salesforce/label/c.Treasury_Dashboard_Terms_of_Use_URL';

//labels
import termsOfUse from '@salesforce/label/c.Treasury_Dashboard_Terms_Of_Use';
import fxRates from '@salesforce/label/c.Treasury_Dashboard_FX_Rates';
import bankHolidays from '@salesforce/label/c.Treasury_Dashboard_Bank_Holidays';
import centralBanksWorldWide from '@salesforce/label/c.Treasury_Dashboard_Central_Banks_World_Wide';
import marketNews from '@salesforce/label/c.Treasury_Dashboard_Market_News';

export default class TreasuryDashboardFooter extends LightningElement {

    @ track showModal;

    URLS = {
        fxRatesUrl,
        bankHolidaysUrl,
        centralBanksUrl,
        marketNewsUrl,
        termsOfUseUrl
    };

    labels = {
        termsOfUse,
        fxRates,
        bankHolidays,
        centralBanksWorldWide,
        marketNews
    };

    navigateToFxRates() {
        window.open(this.URLS.fxRatesUrl);
    }

    navigateToBankHolidays() {
        window.open(this.URLS.bankHolidaysUrl);
    }

    navigateToCentralBanksWorldWide() {
        window.open(this.URLS.centralBanksUrl);
    }

    navigateToMarketNews() {
        window.open(this.URLS.marketNewsUrl);
    }

    navigateToTermsOfUse() {
        window.open(this.URLS.termsOfUseUrl);
    }

}
