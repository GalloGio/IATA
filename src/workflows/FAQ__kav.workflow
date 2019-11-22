<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>User_Notification_when_Validation_Status_Validated</fullName>
        <description>User Notification when Validation Status=Validated</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FAQ/FAQ_Validated</template>
    </alerts>
    <fieldUpdates>
        <fullName>Check_New_Article</fullName>
        <description>Update the field to unchecked</description>
        <field>New_Articles__c</field>
        <literalValue>0</literalValue>
        <name>Check New Article</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Not_validated</fullName>
        <field>ValidationStatus</field>
        <literalValue>Not Validated</literalValue>
        <name>Not validated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pending_Review</fullName>
        <field>ValidationStatus</field>
        <literalValue>Pending publication</literalValue>
        <name>Pending Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pending_approval</fullName>
        <field>ValidationStatus</field>
        <literalValue>Pending publication</literalValue>
        <name>Pending approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Categories</fullName>
        <field>Categories__c</field>
        <name>Reset Categories</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Queues</fullName>
        <field>Queues__c</field>
        <name>Reset Queues</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Validated</fullName>
        <field>ValidationStatus</field>
        <literalValue>Validated</literalValue>
        <name>Validated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Validated_step1</fullName>
        <field>ValidationStatus</field>
        <literalValue>Validated</literalValue>
        <name>Validated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <knowledgePublishes>
        <fullName>Publish_as_a_new_version</fullName>
        <action>PublishAsNew</action>
        <label>Publish as a new version</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
</Workflow>
