import { LightningElement, track } from 'lwc';
import { getParamsFromPage } from'c/navigationUtils';

export default class PortalPublicKBArticlePage extends LightningElement {
    @track article = {};
    renderas = false;

    connectedCallback() {
        //get the parameters for this page
        let pageParams = getParamsFromPage();
        
        if(pageParams !== undefined) {
            if(pageParams.id1 !== undefined) this.article.id1 = pageParams.id1;
            if(pageParams.id2 !== undefined) this.article.id2 = pageParams.id2;
            if(pageParams.q !== undefined) this.article.q = decodeURIComponent((pageParams.q+'').replace(/\+/g, '%20'));
            if(pageParams.language !== undefined) this.article.language = pageParams.language;
            let articleRef=window.location.pathname.substring(location.pathname.lastIndexOf("/") + 1);
            if(articleRef !== undefined) this.article.UrlName = articleRef;
        }      
    }
}