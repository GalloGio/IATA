public with sharing class PowerBI_Dashboard_CTRL {

    public String embedUrl{get;set;}
    public String accessToken{get;set;}
    public String objectId{get;set;}
    public String tokenType{get;set;}


    public PowerBI_Dashboard_CTRL() {
        this.embedUrl = Apexpages.currentPage().getParameters().get('embedUrl');
        this.accessToken = Apexpages.currentPage().getParameters().get('accessToken');
        this.objectId = Apexpages.currentPage().getParameters().get('objectId');
        this.tokenType = Apexpages.currentPage().getParameters().get('tokenType');
    }


    public PageReference redirect() {
        return null;
    }



}