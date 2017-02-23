<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EBC_End_User_Unsubscribe</fullName>
        <ccEmails>debonol@iata.org</ccEmails>
        <description>EBC End-User Unsubscribe</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>EBC/EBC_Unsubscribe</template>
    </alerts>
</Workflow>
