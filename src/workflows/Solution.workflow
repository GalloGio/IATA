<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Solution_update_FAQ_alert</fullName>
        <description>Solution update - alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>guerreirom@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Temporary/Test_for_FAQ</template>
    </alerts>
    <rules>
        <fullName>Solutions - FAQ updates</fullName>
        <actions>
            <name>Solution_update_FAQ_alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Solutions - FAQ updates from iata.org</description>
        <formula>IF( LastModifiedById  == &apos;00520000000iYyx&apos;, true, false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
