import { LightningElement, api, track } from 'lwc';
import getArticles from '@salesforce/apex/PortalFAQsCtrl.getArticles';
import getFAQsInfo from '@salesforce/apex/PortalFAQsCtrl.getFAQsInfo';
import createFeedback from '@salesforce/apex/PortalFAQsCtrl.createFeedback';
import getArticlesFeedback from '@salesforce/apex/PortalFAQsCtrl.getArticlesFeedback';
import randomUUID from '@salesforce/apex/CSP_Utils.randomUUID';
import getSearchArticles from '@salesforce/apex/PortalFAQsCtrl.getSearchArticles';
import getArticleTitle from '@salesforce/apex/PortalFAQsCtrl.getArticleTitle';
import getFaqsList from '@salesforce/apex/PortalFAQsCtrl.getFaqsList';

import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

import CSP_ArticleHelpful from '@salesforce/label/c.CSP_ArticleHelpful';
import CSP_ThanksFeedback from '@salesforce/label/c.CSP_ThanksFeedback';
import CSP_FeedbackTitle from '@salesforce/label/c.CSP_FeedbackTitle';
import CSP_FeedbackBody from '@salesforce/label/c.CSP_FeedbackBody';
import CSP_FeedbackBody2 from '@salesforce/label/c.CSP_FeedbackBody2';
import CSP_Submit from '@salesforce/label/c.CSP_Submit';
import CSP_Cancel from '@salesforce/label/c.CSP_Cancel';
import csp_GoToSupport from '@salesforce/label/c.csp_GoToSupport';
import CSP_SearchFAQ from '@salesforce/label/c.CSP_SearchFAQ';


export default class PortalFAQArticleAccordion extends NavigationMixin(LightningElement) {
    label = {
        CSP_ArticleHelpful,
        CSP_ThanksFeedback,
        CSP_FeedbackTitle,
        CSP_FeedbackBody,
        CSP_FeedbackBody2,
        CSP_Submit,
        CSP_Cancel,
        csp_GoToSupport,
        CSP_SearchFAQ
    }
    @api category;
    @api articleView;
    @track _topic = [];
    @track _subTopic;
    @track childs;
    @track articles;
    @track error;
    @track renderedModal = false;
    @track articleComments = '';
    @track articleIds;
    @track sessionCookie;
    @track childs;
    @track articleInfo;
    @track counter;
    @track renderConfirmation = false;
    @track searchText;

    @api
    get topic() {
        return this._topic;
    }
    set topic(value) {
        if(value !== undefined) {
            let topicAux = JSON.parse(JSON.stringify(value));
            
            if(JSON.parse(JSON.stringify(this._topic)) !== topicAux.topic && this.counter !== topicAux.counter) {
                this._topic = topicAux.topic;
                this.counter = topicAux.counter;

                let actualTopic = [];
                actualTopic.push(this._topic);

                this.createParameter(actualTopic);
            } else {
                let _category = [];
                _category.push(this.category);

                this.createParameter(_category);
            }
        }
    }

    @api
    get subTopic() {
        return this._subTopic;
    }
    set subTopic(value) {
        if(value !== undefined) {
            this._subTopic = [];
            let _subtopic = JSON.parse(JSON.stringify(value));
            this._subTopic.push(_subtopic.subtopic);
    
            this.createParameter(this._subTopic);
        }
    }

    get hasArticles() {
        return this.articles !== undefined && this.articles.length > 0;
    }

    // GET COOKIE SESSION AND INITIALIZE LIST OF ARTICLES
    connectedCallback() {
        let cookie = this.getCookie('PKB2SessionId');

        if(cookie !== null && cookie !== undefined) {
            this.sessionCookie = cookie;
        } else {
            randomUUID()
                .then(results => {
                    this.sessionCookie = results;
                    this.setCookie('PKB2SessionId', this.sessionCookie, 1);
                });
        }
        
        this.redirectionTo();
    }

    // DEFINE WHICH METHOD TO LOAD BASED ON CATEGORY, A SPECIFIC ARTICLE OR FROM SEARCH PARAM
    redirectionTo() {
        if(this.category !== undefined) {
            this.renderFAQs(); // RENDER ARTICLES FROM DEEPEST SUBTOPICS
        } else if(this.articleView !== undefined) {
            if(this.articleView.q !== undefined) {
                this.searchText = this.articleView.q;
                let filteringObject = {};
                filteringObject.searchText = this.articleView.q;
    
                /* SAME METHOD USED IN SEARCH FUNCTIONALITY
                RETRIEVE ARTICLES WITH SEARCH TERMS OCURRIENCES IN TITLE AND SUMMARY FIELDS */
                getFaqsList({ refinedSearchSerialized : JSON.stringify(filteringObject), moreFields : true })
                    .then(results => {
                        this.articles = [];
                        if(results.length) {
                            this.handleCallback(results, this.articleView.id1);
                        }
                    });            
            } else {
                /* GET ARTICLE TITLE FROM ITS ID, TO BE USED IN THE SOSL SEARCH */
                getArticleTitle({ articleId : this.articleView.id1 })
                    .then(resultsTitle => {
                        let articleTitle = resultsTitle;
    
                        this.renderSearchArticles(articleTitle);
                    });
            }
        }
    }

    // RELATED TO SUPPORT VIEW CATEGORY PAGE, GETTING THE DEEPEST SUBTOPICS TO RENDER ARTICLES FOR A SPECIFIC CATEGORY
    renderFAQs() {
        getFAQsInfo()
            .then(results => {
                let result = JSON.parse(JSON.stringify(results));
                let childs = [];
                
                let tempCategoryName = this.category; //Contains selected category from portalFAQPage
        
                Object.keys(result).forEach(function (el) {
                    if(tempCategoryName === result[el].categoryName) {
                        Object.keys(result[el].childs).forEach(function (elAux) {
                            childs.push(result[el].childs[elAux]);
                        });
                    }
                });
                this.childs = childs;
                this.createParameter(childs);
    
                this.loading = false;
            });        
    }

    // SOSL SEARCH TO RETRIEVE RELATED ARTICLES FOR A GIVEN SEARCH PARAM
    renderSearchArticles(searchParam) {
        getSearchArticles({ searchTerm : searchParam })
            .then(resultsArticles => {
                this.articles = [];
                if(resultsArticles.length) {
                    this.handleCallback(resultsArticles, this.articleView.id2);
                }
            });
    }

    // HANDLE CALLBACK TO BUILD ARTICLE'S LIST, WITH AN OPEN ARTICLE, ARTICLE'S FEEDBACK AND A LIST OF RELATED ARTICLES
    handleCallback(results, relatedArticleId) {
        let res = JSON.parse(JSON.stringify(results));
    
        this.articleIds = [];
        let tempArticles = [];
        let tempArticleIds;
        let articleSelected = {};                   

        tempArticleIds = '(';

        Object.keys(res).forEach(function (el) {                      
            if(relatedArticleId !== undefined && relatedArticleId === res[el].Id) { // OPENS THE ARTICLE PREVIOUSLY CLICKED THAT CAME FROM RELATED ARTICLES LIST OR SEARCH LIST
                tempArticles.push({ id: res[el].Id, number: res[el].ArticleNumber, label: res[el].Title, value: res[el].Answer__c, open: true, feedback: false });
                articleSelected = {
                    title : res[el].Title, 
                    id : res[el].Id
                };
            } else {
                tempArticles.push({ id: res[el].Id, number: res[el].ArticleNumber, label: res[el].Title, value: res[el].Answer__c, open: false, feedback: false });
            }
            tempArticleIds += (el === '0') ? '\'' + res[el].Id + '\'' : ', \'' + res[el].Id + '\'';
        });

        tempArticleIds += ')';

        this.articles = tempArticles;
        this.articleIds = tempArticleIds; // SET OF IDS USED TO SEARCH ARTICLE'S FEEDBACK
        this.articleInfo = articleSelected; // RENDER RELATED ARTICLES

        this.articlesFeedback();        
    }

    // CREATE THE RIGHT PATTERN TO BE USED IN A SOQL QUERY TO RETRIEVE ARTICLES
    createParameter(params) {        
        let selectedParams = [];
        selectedParams = '(';

        for(let i = 0; i < params.length; i++) {
            selectedParams += (i === 0) ? params[i] + '__c' : ', ' + params[i] + '__c';
        }
        selectedParams += ')';
        
        this.getArticlesFromParams(selectedParams);
    }

    // GET SPECIFIC ARTICLES FOR A GIVEN CATEGORY/TOPIC/SUBTOPIC
    getArticlesFromParams(selectedParams) {
        getArticles({ selectedParams : selectedParams })
            .then(result => {
                this.articles = [];
                if(result.length) {
                    let res = JSON.parse(JSON.stringify(result));

                    this.articleIds = [];
                    let tempArticles = [];
                    let tempArticleIds;
                    tempArticleIds = '(';
    
                    Object.keys(res).forEach(function (el) {
                        tempArticles.push({ id: res[el].Id, number: res[el].ArticleNumber, label: res[el].Title, value: res[el].Answer__c, open: false, feedback: false });
                        tempArticleIds += (el === '0') ? '\'' + res[el].Id + '\'' : ', \'' + res[el].Id + '\'';
                    });
                    tempArticleIds += ')';
    
                    this.articles = tempArticles;
                    this.articleIds = tempArticleIds; // SET OF IDS USED TO SEARCH ARTICLE'S FEEDBACK
    
                    this.articlesFeedback();
                }                
            });        
    }
    
    // GET ARTICLE'S FEEDBACKS ACCORDING TO SESSION COOKIE AND ARTICLES BEING DISPLAYED
    articlesFeedback() {
        getArticlesFeedback({ articleIds : this.articleIds, sessionCookie : this.sessionCookie })
            .then(result => {
                let res = JSON.parse(JSON.stringify(result));

                let articleVals = JSON.parse(JSON.stringify(this.articles));
        
                for(let i = 0; i < articleVals.length; i++) {
                    for(let j = 0; j < res.length; j++) {
                        if(articleVals[i].id === res[j].Article_ID__c) {
                            articleVals[i].feedback = true;
                            break;
                        }                        
                    }
                }
        
                this.articles = articleVals;
            });
    }

    // HANDLE FOR SELECTED ARTICLE
    articleSelected(event) {    
        let articleTitle = event.target.attributes.getNamedItem('data-item').value;
        let articleId = event.target.attributes.getNamedItem('data-id').value;
        this.articleInfo = { // RENDER RELATED ARTICLES
            title : articleTitle, 
            id : articleId
        };        

        let articleVals = JSON.parse(JSON.stringify(this.articles));
        
        Object.keys(articleVals).forEach(function (el) {
            if(articleTitle === articleVals[el].label && articleVals[el].open === false) {
                articleVals[el].open = true;
            } else {
                articleVals[el].open = false;
            }
        });
           
        this.articles = articleVals;
    }

    onInputchange(event) {
        if(event.target.value !== '') {
            this.searchText = event.target.value;

            clearTimeout(this.timeout);

            this.timeout = setTimeout(() => {
                if(this.searchText.length > 3) {
                    this.renderSearchArticles(this.searchText);
                }
            }, 1300, this);
        } else {
            this.redirectionTo();
        }
    }

    feedbackComments(event) {
        this.articleComments = event.target.value;
    }

    feedbackStatus(event) {
        this.articleId = event.target.attributes.getNamedItem('data-item').value;
        this.articleNumber = event.target.attributes.getNamedItem('data-number').value;
        this.articleTitle = event.target.attributes.getNamedItem('data-title').value;
        this.isDeferred = event.target.attributes.getNamedItem('data-option').value;

        if(!this.renderedModal) this.saveFeedback();
    }

    saveFeedback() {
        createFeedback({ 
            articleId : this.articleId,
            articleNumber: this.articleNumber ,
            articleTitle: this.articleTitle,
            feedbackSource: 'Search',
            feedbackComments: this.articleComments,
            sessionId: this.sessionCookie,
            isDeferred: this.isDeferred
        })
            .then(result => {
                this.renderConfirmation = true;      
                let articleVals = JSON.parse(JSON.stringify(this.articles));
        
                for(let i = 0; i < articleVals.length; i++) {
                    if(articleVals[i].id === this.articleId) {
                        articleVals[i].feedback = true;
                        break;
                    }
                }
        
                this.articles = articleVals; 
                if(this.renderedModal) this.renderModal();
            })
            .catch(error => {
                if(this.renderedModal) this.renderModal();
            }
        );
    }
    
    renderModal(event) {
        this.renderedModal = !this.renderedModal;
        
        if(this.renderedModal) this.feedbackStatus(event);
    }

    redirectSupport() {
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "support"
            }})
        .then(url => navigateToPage(url, {}));
    }

    setCookie(name, value, days) {
        let expires = "";
        if (days) {
          let date = new Date();
          date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
          expires = "; expires=" + date.toUTCString();
        }
        document.cookie = name + "=" + (value || "") + expires + "; path=/";
    }
      
    getCookie(name) {
        let nameEQ = name + "=";
        let ca = document.cookie.split(';');
        for (let i = 0; i < ca.length; i++) {
          let c = ca[i];
          while (c.charAt(0) === ' ') c = c.substring(1, c.length);
          if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
        }
        return null;
    } 
}