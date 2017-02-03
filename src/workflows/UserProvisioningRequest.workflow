<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SCIM_Email_Alert</fullName>
        <ccEmails>mansourim@iata.org</ccEmails>
        <ccEmails>mr.mehdi.mansouri@gmail.com</ccEmails>
        <description>SCIM Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Exception_Approval_Confimation</template>
    </alerts>
    <alerts>
        <fullName>Send_permission_assignment_confirmation</fullName>
        <description>Send permission assignment confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>SalesforceUserId</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IEC_GDP/Identity_Permission_Granted</template>
    </alerts>
    <rules>
        <fullName>Identity Assign Permission Set</fullName>
        <actions>
            <name>Send_permission_assignment_confirmation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>UserProvisioningRequest.State</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>UserProvisioningRequest.ConnectedAppId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send notification when app permission is granted</fullName>
        <active>false</active>
        <criteriaItems>
            <field>UserProvisioningRequest.State</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>UserProvisioningRequest.ConnectedAppId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
