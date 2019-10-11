<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Update_Authorized_Signatories_Package_Alert</fullName>
        <description>Update Authorized Signatories Package Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Case_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Notification_to_update_Authorized_Signatories_Package_Template</template>
    </alerts>
</Workflow>