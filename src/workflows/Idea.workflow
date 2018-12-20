<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>NewCommentAdded</fullName>
        <description>New Comment Added</description>
        <protected>false</protected>
        <recipients>
            <recipient>liewf@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/NewCommentAdded</template>
    </alerts>
    <alerts>
        <fullName>NewIdeaSubmitted</fullName>
        <description>New Idea Submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>liewf@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/New_Idea_Submitted</template>
    </alerts>
    <rules>
        <fullName>New Comment Added</fullName>
        <actions>
            <name>NewCommentAdded</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( ISCHANGED(NumComments),  OR(CommunityId = &quot;09aw0000000c4uZ&quot;))</formula>
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
            <value>DPC Management Community</value>
        </criteriaItems>
        <description>DPCM ideas 2016</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
