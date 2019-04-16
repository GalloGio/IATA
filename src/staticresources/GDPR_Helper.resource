window._userInfo = (function() {
    var userInfo = {};

    return { //public API

        setPardotID : function(id) {
            userInfo.pardotID = id;
        },
        setSalesforceId : function(id) {
            userInfo.salesforceId = id;
        },
        setEmail : function(email) {
            userInfo.email = email;
        },
        setIndividualID : function(id) {
            userInfo.individualId = id;
        },
        setIndividualObj : function(obj) {
            userInfo.individual = obj;
        },
        setIsGuest : function(isGuest) {
            userInfo.isGuest = isGuest;
        },
        setSubscriptions : function(listId) {
            userInfo.subscriptions = listId;
        },
        setInterests: function(interests) {
            userInfo.interests = interests;
        },
        getUserInfo : function() {
            return userInfo;
        }
    };
}());