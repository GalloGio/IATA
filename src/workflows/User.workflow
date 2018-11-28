<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ISSP_Change_email_address</fullName>
        <description>ISSP - Change email address</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_Change_Email_Address</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Change_email_address_cns</fullName>
        <description>ISSP - Change email address - CNS</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>cns_noreply@cnsc.us</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_Change_Email_Address_cns</template>
    </alerts>
    <alerts>
        <fullName>Notify_if_new_admins_are_granted</fullName>
        <description>Notify if new admins are granted</description>
        <protected>false</protected>
        <recipients>
            <recipient>velascop@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SFDC_admin/User_admin_updates</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_user_nickname</fullName>
        <field>CommunityNickname</field>
        <formula>SUBSTITUTE(ContactId + TEXT(TODAY()), &apos;-&apos;, &apos;&apos;)</formula>
        <name>Update user nickname</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>IFAP Portal User deactivation</fullName>
        <actions>
            <name>Update_user_nickname</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.IsActive</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>IFAP Customer Portal User</value>
        </criteriaItems>
        <description>On deactivation the user nickname will be updated to prevent conflicts when a new user with the same nickname is created.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify if new admins</fullName>
        <actions>
            <name>Notify_if_new_admins_are_granted</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>contains</operation>
            <value>admin</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>equals</operation>
            <value>Standard</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.IsActive</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
