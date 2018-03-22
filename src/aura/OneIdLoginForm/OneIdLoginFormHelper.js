({
    
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },

    handleLogin: function (component, event, helpler) {
        console.log('helper handleLogin');

        //Get parameters
        var username = '';
        username = component.find("username").get("v.value");
        var password = '';
        password = component.find("password").get("v.value");
        var startUrl = component.get("v.startUrl");
        
        console.log('username ' + username);
        //console.log('password ' + password);
        
        component.set("v.errorMessage",'');
        component.set("v.showError",false);
        
        if(username == ''){
            component.set("v.errorMessage",$A.get("$Label.c.OneId_Username_ErrorBlank"));
            component.set("v.showError",true);
            
            return;
        }
        else if (password == ''){
            component.set("v.errorMessage",$A.get("$Label.c.OneId_Password_ErrorBlank"));
            component.set("v.showError",true);
            
            return;
        }
        
        console.log('helper handleLogin1');
        component.set("v.errorMessage",'');
        component.set("v.showError",false);
        
        
        //Configure apex controller action function
        var action = component.get("c.login");
        
        startUrl = decodeURIComponent(startUrl);
        
        action.setParams({username:username, 
                          password:password, 
                          startUrl:startUrl});
        
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                console.log('handleLogin.Callback rtnValue='+rtnValue);
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
            }
        });
        $A.enqueueAction(action);
    },
    
   getClientIpAddressAjax : function (component, event, helpler) { 
       var siteCompleteUrl=component.get('v.siteCompleteUrl');
       var url;
       //url='https://oneidconde-customer-portal-iata.cs83.force.com/oneidentity/services/apexrest/OneIdGetHttpContext';
       //url=siteCompleteUrl+'/services/apexrest/OneIdGetHttpContext';
       url=$A.get("$Label.c.OneId_URL_javaScript") + '/services/apexrest/OneIdGetHttpContext';
       
       console.log('URL web service REST to get IP Adress: '+url);      
       
       $.ajax({
            url: url,
            type: 'GET',
            //async: true,//Asynchronous
            async: false,//Synchronous
            //dataType: 'json',
            //crossDomain: true,
            beforeSend: function (request)
            {
                //request.setRequestHeader("HeaderName", "HeaderValue");
                console.log('In AJAX beforeSend');
            },
            success : function(result)
            {
                //process the result
                console.log('In AJAX success: '+result);
                
                //For Assynchronous mode
                //$("#clientIpAddressAjax").val(result).trigger('change');
                //console.log('ajax succes GET after SET html INPUT - clientIpAddressAjax='+$("#clientIpAddressAjax").val());
                
                //If ajax schyncronous componetn context exists here so can be used
                component.set('v.clientIpAddress',result);
                console.log('ajax succes GET after SET component val - component.v.clientIpAddress='+component.get('v.clientIpAddress'));
            },
            error : function(jqXHR, textStatus, errorThrown) {
                console.log('error');
                console.log('Error: '+jqXHR.status);
                console.log('ErrorThrown: '+errorThrown)
            } 
         });
    },
    
    /*getSanctionCountry : function (component, event, helpler, clientIpAddress) {

        //Configure apex controller action function
        var action = component.get("c.getSanctionCountry");
        
        console.log('getSanctionCountry.Begin - IpAddress to pass: '+clientIpAddress);
        action.setParams({clientIpAddress:clientIpAddress});
        
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            console.log('getSanctionCountry.Callback getSanctionCountry='+JSON.stringify(rtnValue));
            if (rtnValue !== null) {
                component.set('v.sanctionCountry',rtnValue);
            }else{
                console.log('getSanctionCountry.Callback is null');
            }
        });
        $A.enqueueAction(action);
    },*/
    
    getShow90Days : function (component, event, helpler) {
        var action = component.get("c.getShow90Days");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            console.log('getShow90Days.Callback rtnValue='+JSON.stringify(rtnValue));
            if (rtnValue !== null) {
                component.set('v.show90Days',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsUsernamePasswordEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsSelfRegistrationEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityForgotPasswordUrl : function (component, event, helpler) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunitySelfRegisterUrl : function (component, event, helpler) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getSiteCompleteUrl : function (component, event, helpler) {
        var action = component.get("c.getSiteCompleteUrl");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            console.log('getSiteCompleteUrl.Callback rtnValue='+JSON.stringify(rtnValue));
            if (rtnValue !== null) {
                component.set('v.siteCompleteUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    onchangeClientIpAddressAjax: function(cmp, event, helper) {
        alert("Changed field!");
        console.log("Changed field!");
    },

    getFindLocation : function (ip, component) {
    console.log('getFindLocation....');      
        var action = component.get("c.getFindLocation");
        
        action.setParams({"saveLog" : true,
                         "ipAddress" : ip});        
        
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (state === "SUCCESS") {
            console.log('success');                     
                component.set("v.sanctionCountry",response.getReturnValue());                
            }            
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });        
        $A.enqueueAction(action);
    }
})