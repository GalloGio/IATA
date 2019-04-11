<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ACCA_New_comment_on_case_ISIS2_ISIS2D</fullName>
        <ccEmails>accabspdevelop@acca.com.cn</ccEmails>
        <ccEmails>accaisis2develop@acca.com.cn</ccEmails>
        <ccEmails>yx@acca.com.cn</ccEmails>
        <description>ACCA: New comment on case (ISIS2 &amp; ISIS2D)</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>All/New_Case_Comment</template>
    </alerts>
    <alerts>
        <fullName>ACCA_Notification_on_new_Customer_Service_Request_Comment</fullName>
        <ccEmails>rdpc.support@acca.com.cn</ccEmails>
        <description>ACCA: Notification on new Customer Service Request Comment</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>AMS/New_Case_Comment2</template>
    </alerts>
    <alerts>
        <fullName>ICH_Help_Desk_New_Case_Comment_notification_to_ICH_customer_support</fullName>
        <description>ICH Help Desk - New Case Comment notification to ICH customer support</description>
        <protected>false</protected>
        <recipients>
            <recipient>cerpolett2@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chretienc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>fernandev@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ferratec@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>macneillb@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>reevesj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>saxtonu@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SIS_Help_Desk/SIS_HD_New_Case_Comment</template>
    </alerts>
    <alerts>
        <fullName>New_Comment_Notification_from_Maestro_to_Maestro</fullName>
        <description>New Comment Notification from Maestro to Maestro</description>
        <protected>false</protected>
        <recipients>
            <recipient>AccelyaMaestroPartnerUser</recipient>
            <type>portalRole</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/New_Case_Comment_iata</template>
    </alerts>
    <alerts>
        <fullName>New_comment_notification_on_ACR_ISIS2_D_to_IATA_migration_team</fullName>
        <ccEmails>isis2@iata.org</ccEmails>
        <description>New comment notification on ACR ISIS2-D to IATA migration team</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>All/New_Case_Comment_iata</template>
    </alerts>
    <alerts>
        <fullName>New_comment_on_case</fullName>
        <ccEmails>accabspdevelop@acca.com.cn</ccEmails>
        <description>ACCA: New comment on case</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>All/New_Case_Comment</template>
    </alerts>
    <alerts>
        <fullName>SIS_Help_Desk_New_Case_Comment_notification_to_SIS_customer_support</fullName>
        <description>SIS Help Desk - New Case Comment notification to SIS customer support</description>
        <protected>false</protected>
        <recipients>
            <recipient>IATASISCustomerSupport</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>IATASISHelpDeskAgent</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SIS_Help_Desk/SIS_HD_New_Case_Comment</template>
    </alerts>
    <alerts>
        <fullName>SIS_Help_Desk_New_Case_Comment_notification_to_SIS_customer_support_Aaron</fullName>
        <description>SIS Help Desk - New Case Comment notification to SIS customer support_Aaron</description>
        <protected>false</protected>
        <recipients>
            <recipient>mondragona@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SIS_Help_Desk/SIS_HD_New_Case_Comment</template>
    </alerts>
    <alerts>
        <fullName>SIS_Help_Desk_New_Case_Comment_notification_to_SIS_customer_support_Kale</fullName>
        <description>SIS Help Desk - New Case Comment notification to SIS customer support_Kale</description>
        <protected>false</protected>
        <recipients>
            <recipient>mondragona@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SIS_Help_Desk/SIS_HD_New_Case_Comment</template>
    </alerts>
    <fieldUpdates>
        <fullName>First_contact_with_Client_Now2</fullName>
        <field>First_Contact_with_Client__c</field>
        <formula>now()</formula>
        <name>First contact with Client = Now()</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_DOP7_R_S_feedback_pending_2</fullName>
        <field>R_S_feedback_pending__c</field>
        <literalValue>Completed</literalValue>
        <name>IDFS_SIDRA_DOP7_R&amp;S feedback pending 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_Case_Status_Action_Needed</fullName>
        <field>Status</field>
        <literalValue>Action Needed</literalValue>
        <name>ISSP Case Status = Action Needed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_Re_open_case</fullName>
        <field>Status</field>
        <literalValue>Reopen</literalValue>
        <name>ISSP Re-open case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_Reopened_case_count</fullName>
        <field>Reopened_case__c</field>
        <formula>Parent.Reopened_case__c + 1</formula>
        <name>ISSP Reopened case count</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_Reset_reopen_reason</fullName>
        <field>Reopening_reason__c</field>
        <name>ISSP Reset reopen reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_Set_Case_Comment_to_Private</fullName>
        <field>IsPublished</field>
        <literalValue>0</literalValue>
        <name>ISSP Set Case Comment to Private</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_Comment_From_Connection_User_True</fullName>
        <field>New_Comment_From_Connection_User__c</field>
        <literalValue>1</literalValue>
        <name>New Comment From Connection User - True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_interaction_New_comment2</fullName>
        <field>New_interaction__c</field>
        <literalValue>New Comment</literalValue>
        <name>New interaction = New comment2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_interaction_New_email_comment3</fullName>
        <field>New_interaction__c</field>
        <literalValue>New Email &amp; Comment</literalValue>
        <name>New interaction = New email &amp; comment3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_CS_actions_provide_feedback_com</fullName>
        <field>CS_pending_actions__c</field>
        <literalValue>Check email received</literalValue>
        <name>SIDRA CS actions - provide feedback com</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Helpdesk_Status_action_needed</fullName>
        <field>Status</field>
        <literalValue>Action Needed</literalValue>
        <name>SIS Helpdesk - Status action needed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Kale_case_comment</fullName>
        <field>Proposed_Solution__c</field>
        <formula>CommentBody</formula>
        <name>SIS - Kale case comment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_help_Desk_Case_comment_reassign</fullName>
        <field>Assigned_To__c</field>
        <literalValue>SIS Help Desk Agent</literalValue>
        <name>SIS help Desk - Case comment  reassign</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdatenewcommentforACCA</fullName>
        <description>Update new comment for ACCA checkbox to true when a new comment is added to their case</description>
        <field>New_Comment_for_ACCA__c</field>
        <literalValue>1</literalValue>
        <name>Update new comment for ACCA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>ACCA%3A New comment added by IATA to ACCA</fullName>
        <actions>
            <name>New_comment_on_case</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>CaseComment.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC Systems) - ACCA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>IBSP1</value>
        </criteriaItems>
        <description>Informs ACCA adm team that new case comment has been added by IATA.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ACCA%3A New comment added by IATA to ACCA CS</fullName>
        <actions>
            <name>ACCA_Notification_on_new_Customer_Service_Request_Comment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CaseComment.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACCA Customer Service Request (External),ACCA Customer Service Request (Internal)</value>
        </criteriaItems>
        <description>Informs ACCA CS team that new case comment has been added by IATA.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ACCA%3A New comment added by IATA to ACCA IBSPs%2C IBSPs-D</fullName>
        <actions>
            <name>ACCA_New_comment_on_case_ISIS2_ISIS2D</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CaseComment.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC Systems) - ACCA,Application Change Request (DPC System),Application Change Request (DPC Systems - locked)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>IBSPs,IBSPs-D,IBSP1</value>
        </criteriaItems>
        <description>Informs ACCA adm team that new case comment has been added by IATA.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ACCA%3A Update new comment for ACCA</fullName>
        <actions>
            <name>UpdatenewcommentforACCA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CaseComment.CreatedDate</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACCA Customer Service Request (External),ACCA Customer Service Request (Internal)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Escalate_to_ACCA__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>notContain</operation>
            <value>ACCA</value>
        </criteriaItems>
        <description>Used to ensure ACCA are aware when a new comment is added to their case</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ACR%3A New comment added</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5)</booleanFilter>
        <criteriaItems>
            <field>CaseComment.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC Systems - locked),Application Change Request (DPC Systems) - ACCA</value>
        </criteriaItems>
        <criteriaItems>
            <field>CaseComment.CreatedById</field>
            <operation>notEqual</operation>
            <value>Ron Cole</value>
        </criteriaItems>
        <criteriaItems>
            <field>CaseComment.IsPublished</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>CaseComment.IsPublished</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Informs Ron that new case comment has been added by to an ACR for DPC</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACR%3A New comment notification on ACR IBSPs%2F IBSPs-D to IATA migration team</fullName>
        <actions>
            <name>New_comment_notification_on_ACR_ISIS2_D_to_IATA_migration_team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2) OR (3 AND 4)</booleanFilter>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>IBSPs-D</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC System),Application Change Request (DPC Systems) - ACCA,Application Change Request (DPC Systems - locked),ACCA Bug Fix</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>IBSPs</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACCA Bug Fix</value>
        </criteriaItems>
        <description>Used to notify the IATA migration team when a new comment is added to and ACR with the IBSPs/ IBSPs-D system.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CSR %3A New comment added</fullName>
        <actions>
            <name>New_Comment_From_Connection_User_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CaseComment.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>BSPlink Customer Service Requests (CSR)</value>
        </criteriaItems>
        <criteriaItems>
            <field>CaseComment.CreatedById</field>
            <operation>equals</operation>
            <value>Connection User</value>
        </criteriaItems>
        <description>Flags cases that a new comment was added (used for salesforce to salesforce cases). Will trigger another workflow that sends an email notification to the case owner.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>First Contact with Client</fullName>
        <actions>
            <name>First_contact_with_Client_Now2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CaseComment.IsPublished</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>equals</operation>
            <value>Standard</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Global,Cases - Europe,Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.First_Contact_with_Client__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CaseComment.CreatedById</field>
            <operation>notEqual</operation>
            <value>IATA System</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICH Help Desk -New Case Comment added</fullName>
        <actions>
            <name>ICH_Help_Desk_New_Case_Comment_notification_to_ICH_customer_support</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICH</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_Interactions tracking - New comment</fullName>
        <actions>
            <name>New_interaction_New_comment2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(Parent.OwnerId &lt;&gt; CreatedById , OR( AND(Parent.RecordType.DeveloperName = &quot;SIDRA&quot;, NOT(ISNULL(Parent.Update_AIMS_DEF__c))) ,Parent.RecordType.DeveloperName = &quot;ProcessEuropeSCE&quot; ,Parent.RecordType.DeveloperName = &quot;CS_Process_IDFS_ISS&quot;, Parent.RecordType.DeveloperName = &quot;SEDA&quot;, Parent.RecordType.DeveloperName = &quot;InternalCasesEuropeSCE&quot;, Parent.RecordType.DeveloperName = &quot;IDFS_Airline_Participation_Process&quot;, Parent.RecordType.DeveloperName = &quot;Airline_Coding_Application&quot;, Parent.RecordType.DeveloperName = &quot;ID_Card_Application&quot;, Parent.RecordType.DeveloperName =&quot;IATA_Financial_Review&quot;,Parent.RecordType.DeveloperName = &quot;SIDRA_Lite&quot;,Parent.RecordType.DeveloperName = &quot;OSCAR_Communication&quot;), NOT(ISPICKVAL(Parent.New_interaction__c ,&quot;New email&quot;)) ,NOT(ISPICKVAL(Parent.New_interaction__c ,&quot;New email closed case&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_Interactions tracking - New comment and email</fullName>
        <actions>
            <name>New_interaction_New_email_comment3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(Parent.OwnerId &lt;&gt; CreatedById , OR( AND(Parent.RecordType.DeveloperName = &quot;SIDRA&quot;, NOT(ISNULL(Parent.Update_AIMS_DEF__c))) ,Parent.RecordType.DeveloperName = &quot;CS_Process_IDFS_ISS&quot;, Parent.RecordType.DeveloperName = &quot;ProcessEuropeSCE&quot; ,Parent.RecordType.DeveloperName = &quot;InternalCasesEuropeSCE&quot;, Parent.RecordType.DeveloperName =&quot;IDFS_Airline_Participation_Process&quot;, Parent.RecordType.DeveloperName =&quot;ID_Card_Application&quot;, Parent.RecordType.DeveloperName =&quot;IATA_Financial_Review&quot;, Parent.RecordType.DeveloperName =&quot;SIDRA_Lite&quot;,Parent.RecordType.DeveloperName = &quot;OSCAR_Communication&quot;), OR(ISPICKVAL(Parent.New_interaction__c ,&quot;New email&quot;) ,ISPICKVAL(Parent.New_interaction__c ,&quot;New email closed case&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP Block Public Comment for Internal Cases</fullName>
        <actions>
            <name>ISSP_Set_Case_Comment_to_Private</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,Internal Cases (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>CaseComment.IsPublished</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Don&apos;t allow Public comments to be added to internal cases such as SIDRA &amp; Internal Cases (IDFS)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ISSP Case Reopening Workflow</fullName>
        <actions>
            <name>ISSP_Re_open_case</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ISSP_Reopened_case_count</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ISSP_Reset_reopen_reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( $User.Id &lt;&gt; Parent.Owner:User.Id, ISPICKVAL(Parent.Status, &apos;Closed&apos; ),  OR (  Parent.RecordType.DeveloperName = &apos;CasesEurope&apos;,
        Parent.RecordType.DeveloperName = &apos;Cases_Global&apos;, Parent.RecordType.DeveloperName = &apos;CasesAmericas&apos;,  Parent.RecordType.DeveloperName = &apos;CasesMENA&apos;,  Parent.RecordType.DeveloperName = &apos;ExternalCasesIDFSglobal&apos;,  Parent.RecordType.DeveloperName = &apos;Cases_China_North_Asia&apos;,  Parent.RecordType.DeveloperName = &apos;ComplaintIDFS&apos;,  Parent.RecordType.DeveloperName = &apos;Inter_DPCs&apos;, Parent.RecordType.DeveloperName = &apos;Invoicing_Collection_Cases&apos;, Parent.RecordType.DeveloperName = &apos;Cases_SIS_Help_Desk&apos;, Parent.RecordType.DeveloperName = &apos;InternalCasesEuropeSCE&apos;  ), DATEVALUE(Parent.ClosedDate) &gt; TODAY()-14)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ISSP Change case status to Action Needed</fullName>
        <actions>
            <name>ISSP_Case_Status_Action_Needed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( CreatedById &lt;&gt;  Parent.OwnerId ,  not(Parent.IsClosed),  OR(  Parent.RecordType.Name = &quot;Cases - Global&quot;,   Parent.RecordType.Name = &quot;Cases - Europe&quot;,  Parent.RecordType.Name = &quot;Cases - Americas&quot;,  Parent.RecordType.Name = &quot;Cases - Africa &amp; Middle East&quot;,  Parent.RecordType.Name = &quot;Cases - Asia &amp; Pacific&quot;,  Parent.RecordType.Name = &quot;Cases - China &amp; North Asia&quot;,  Parent.RecordType.Name = &quot;Cases - SIS Help Desk&quot;,   Parent.RecordType.Name = &quot;Complaint (IDFS ISS)&quot;, Parent.RecordType.Name = &quot;Invoicing Collection Cases&quot;, Parent.RecordType.Name = &quot;Cases - IFG&quot; ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New comment added by Maestro user</fullName>
        <actions>
            <name>New_Comment_Notification_from_Maestro_to_Maestro</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>Maestro</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC System),Application Change Request (DPC Systems - locked)</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>Accelya - Maestro Partner User</value>
        </criteriaItems>
        <description>Informs the Maestro users (common user/email address) when a new case comment has been added by their common user account.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SIDRA Comments CS provide feedback</fullName>
        <actions>
            <name>SIDRA_CS_actions_provide_feedback_com</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used in SIDRA Cases when a comment is received from E2C to trigger CS Actions</description>
        <formula>AND( ISNEW(), OR(CreatedById=&apos;00520000000h6AU&apos;, AND(ISPICKVAL(Parent.New_interaction__c,&quot;New Comment&quot;),CONTAINS(Parent.LastModifiedBy.Profile.Name,&quot;ISS Portal&quot;))),  Parent.RecordType.DeveloperName=&quot;SIDRA&quot;,     OR   (ISBLANK(Parent.Update_AIMS_DEF__c),            DATEVALUE(Parent.Update_AIMS_DEF__c)&gt;(TODAY()-1),            ISPICKVAL(Parent.Status,&quot;Closed&quot;),            CONTAINS(Parent.Owner:Queue.QueueName,&quot;Cases&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SIDRA_DOP7_R%26S_feedback to CS - R%26S completed</fullName>
        <actions>
            <name>IDFS_SIDRA_DOP7_R_S_feedback_pending_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used to Request R&amp;S feedback</description>
        <formula>AND( CONTAINS( $UserRole.Name, &quot;R&amp;S&quot;) ,   ISPICKVAL(Parent.R_S_feedback_pending__c, &quot;CS requests feedback&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk -New Case Comment added</fullName>
        <actions>
            <name>SIS_Help_Desk_New_Case_Comment_notification_to_SIS_customer_support</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk -New Case Comment added by customer</fullName>
        <actions>
            <name>SIS_Helpdesk_Status_action_needed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>CaseComment.CommentBody</field>
            <operation>notContain</operation>
            <value>SCP,Resolution,SIS Application Support Team,SIS Support Team</value>
        </criteriaItems>
        <criteriaItems>
            <field>CaseComment.CreatedById</field>
            <operation>contains</operation>
            <value>IATA System</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk -New Case Comment added_Kale</fullName>
        <actions>
            <name>SIS_Help_Desk_New_Case_Comment_notification_to_SIS_customer_support_Aaron</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>CaseComment.CreatedById</field>
            <operation>contains</operation>
            <value>IATA System</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS help Desk - case comment email to kale</fullName>
        <actions>
            <name>SIS_Kale_case_comment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assigned_To__c</field>
            <operation>startsWith</operation>
            <value>Kale</value>
        </criteriaItems>
        <criteriaItems>
            <field>CaseComment.CommentBody</field>
            <operation>contains</operation>
            <value>Dear Kale</value>
        </criteriaItems>
        <criteriaItems>
            <field>CaseComment.CommentBody</field>
            <operation>contains</operation>
            <value>Hi Kale</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
