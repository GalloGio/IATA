<aura:application >
	<!-- Account ID parameter - to be received (URL) -->
    <aura:attribute name="accountId" type="String"/>
    
    
    <c:AccountProfileContainer accountId="{!v.accountId}"/>
    
    
</aura:application>