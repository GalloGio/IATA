({    

    handlePreLogin: function (component, event, helper) {
        console.log('helper handlePreLogin');

        //Get parameters
        var username = component.find("username").get("v.value");
        var password =  component.find("password").get("v.value");
        var startUrl = decodeURIComponent(component.get("v.startUrl"));
        var serviceName = component.get("v.serviceName");    

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

        if(component.get("v.serviceName") =='FRED'){
	        var action = component.get("c.getUserInformationFromEmail");
            
            //check if username is available (insert + rollback), 
            //it should not, but we're interested in fred's related information
            var action = component.get("c.getUserInformationFromEmail");
            action.setParams({
                "email":username,
                "serviceName":component.get("v.serviceName")
            });
    
            var isServiceUser;
            var isServiceEligible;
            
            action.setCallback(this, function(resp) {
                var params = resp.getReturnValue();
                console.log('ooo'+params);
                isServiceUser = params.isServiceUser;
                isServiceEligible = params.isServiceEligible;

                if(isServiceUser == false){
					component.set("v.startUrl",'');
					var message;
                    if(isServiceEligible == true){
                        message = $A.get("$Label.c.OneId_LoginUserWithoutFredAccessMessage");
                    }
                    else{
                        message = $A.get("$Label.c.OneId_LoginUserNotEligibleForFredMessage");
                        message += "\n\n" + $A.get("$Label.c.OneId_FRED_Troubleshooting_Link");
                    }
					alert(message);
                }
				helper.handleLogin(component, event);
            });
            $A.enqueueAction(action);       
        }
        else{
            helper.handleLogin(component, event);
        }
    },
    
    handleLogin: function (component, event) {
        console.log('helper handleLogin');
        //Get parameters
        var username = component.find("username").get("v.value");
        var password =  component.find("password").get("v.value");
        var startUrl = decodeURIComponent(component.get("v.startUrl"));
        var serviceName = component.get("v.serviceName");    

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
        
        //Configure apex controller action function
        var action = component.get("c.login");
        
        action.setParams({
            username:username, 
            password:password, 
            startUrl:startUrl,
            serviceName:serviceName
        });
        
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
            }
        });
        $A.enqueueAction(action);
    },
    
   getClientIpAddressAjax : function (component, event) { 
       var url;
       //url='https://oneidconde-customer-portal-iata.cs83.force.com/oneidentity/services/apexrest/OneIdGetHttpContext';
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
    
    getShow90Days : function (component, event) {
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
    
    getIsUsernamePasswordEnabled : function (component, event) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsSelfRegistrationEnabled : function (component, event) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityForgotPasswordUrl : function (component, event) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunitySelfRegisterUrl : function (component, event) {
        var action = component.get("c.getSelfRegistrationUrl");

        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl',rtnValue);
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