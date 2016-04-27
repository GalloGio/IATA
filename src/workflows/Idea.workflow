<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>NewCommentAdded</fullName>
        <description>New Comment Added</description>
        <protected>false</protected>
        <recipients>
            <recipient>amandussoc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>curtisp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/NewCommentAdded</template>
    </alerts>
    <alerts>
        <fullName>NewIdeaSubmitted</fullName>
        <description>New Idea Submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>HUBMadrid</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/New_Idea_Submitted</template>
    </alerts>
    <rules>
        <fullName>New Comment Added</fullName>
        <actions>
            <name>NewCommentAdded</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(
ISCHANGED(NumComments), 
OR(CommunityId = &quot;09a200000000UfC&quot;,CommunityId =&quot;09a200000000UBF&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New Idea Submitted</fullName>
        <actions>
            <name>NewIdeaSubmitted</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Idea.CommunityId</field>
            <operation>equals</operation>
            <value>0 Service Centre Europe</value>
        </criteriaItems>
        <description>SCE</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
