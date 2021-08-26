<!--/**
* ===================================================================
* AccountDashboardCTIApp.app
* @author.....: Merkle
* @version....: V0.1
* @date.......: 2021/05/12
* @last change:
* Description.: Container app for AccountDashboardCTI component, to
*               implement in Visualforce Page AccountDashboadCTI.page
* =================================================================
*/-->
<aura:application access="GLOBAL" extends="force:slds">
	<ltng:require styles="{!$Resource.CSP_Stylesheet}" />
	<aura:attribute name="accountId" type="Id" />
	<aura:attribute name="contactId" type="Id" />
	<c:AccountDashboardCTI accountId="{!v.accountId}" contactId="{!v.contactId}" />
</aura:application>
