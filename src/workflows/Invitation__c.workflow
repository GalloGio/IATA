<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Service_Invitation</fullName>
        <description>Service Invitation</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CS_Portal/Service_Invitation</template>
    </alerts>
</Workflow>
