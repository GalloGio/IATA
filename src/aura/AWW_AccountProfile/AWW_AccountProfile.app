<aura:application extends="force:slds" controller="AWW_AccountProfileCtrl">
    <aura:attribute name="accountId" type="Id"/>
    <aura:attribute name="accessLevel" type="String" default="no access"/>

    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>

    <aura:if isTrue="{!v.accessLevel == 'no access'}">
        <div class="slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_offline" role="alert">
            <span class="slds-assistive-text">error</span>
            <span class="slds-icon_container slds-icon-utility-error slds-m-right_x-small">
                <lightning:icon iconName="utility:error" size="small" variant="inverse"/>
            </span>
            <h2>
                Your user has no access to this app. Please review your permissions with support.
            </h2>
        </div>
   
        <aura:set attribute="else">
            <c:AWW_AccountProfileContent accountId="{!v.accountId}" canEdit="{!v.accessLevel == 'full'}"/>            
        </aura:set>
    </aura:if>
    
</aura:application>