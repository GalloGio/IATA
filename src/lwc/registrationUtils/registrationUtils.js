/**
 * Created by ukaya01 on 29/07/2019.
 */
import { LightningElement } from 'lwc';
import getUserLoc from '@salesforce/apex/PortalRegistrationUtils.getUserLocation';
import isSystemAdmin from '@salesforce/apex/PortalRegistrationUtils.isSystemAdmin';
import isDisposableCheckActive from '@salesforce/apex/PortalRegistrationUtils.isDisposableCheckActive';

export default class RegistrationUtils {

    getUserLocation(){

        return new Promise(
            (resolve, reject) => {

                let resp = {};
                resp.isRestricted = false;
                resp.countryCode = 'CH';
                resolve(resp);
            }
            /*
            (resolve, reject) => {
                var request = new XMLHttpRequest();
                request.open('GET', "https://api.ipify.org?format=jsonp=", true);
                request.onload = function () {
                    if (request.status >= 200 && request.status < 400) {
                        getUserLoc({ ipAddress : request.responseText }).then(result => {
                            console.log('getUserLoc: ', result);
                            resolve(result);
                        })
                        .catch(error => {
                            console.log(error);
                            reject(error);
                        });
                   }
                   else {
                       console.log(request.statusText);
                       reject(request.statusText);
                   }
                }
                request.onerror = function () {
                    console.log(request.statusText);
                    reject(request.statusText);
                }
                request.send();
            }
            */
        );
    }

    checkEmailIsDisposable(email){
        return new Promise(
            (resolve, reject) => {
                isDisposableCheckActive().then(result => {
                    if(result == true){
                        var request = new XMLHttpRequest();
                        request.open('GET', "https://disposable.debounce.io/?email=" + email, true);
                        request.onload = function () {
                            console.log('request.responseText: ', request.responseText);
                            if (request.status >= 200 && request.status < 400) {
                                resolve(JSON.parse(request.responseText).disposable);
                            }
                            else {
                               console.log(request.statusText);
                               reject(request.statusText);
                            }
                        }
                        request.onerror = function () {
                            console.log(request.statusText);
                            reject(request.statusText);
                        }
                        request.send();
                    }else{
                        resolve(result);
                    }
                })
                .catch(error => {
                    console.log(error);
                    reject(error);
                });
            }
        );
    }

    checkEmailIsValid(email){
        return new Promise(
            (resolve, reject) => {
                console.log('email : ', email);
                var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                if(!email.match(regExpEmailformat)){
                    resolve(false);
                }else{
                    resolve(true);
                }
            }
        );
    }

    checkUserIsSystemAdmin(){
        return new Promise(
            (resolve, reject) => {
                isSystemAdmin().then(result => {
                    console.log('isSystemAdmin: ', result);
                    resolve(result);
                })
                .catch(error => {
                    console.log(error);
                    reject(error);
                });
            }
        );
    }
}

