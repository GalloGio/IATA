<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Application_IEP_Portal_Service_Role_Change</fullName>
        <description>Application IEP Portal Service Role Change</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Notify_contact_Portal_Serv_Role_ChangeVF</template>
    </alerts>
    <alerts>
        <fullName>Application_access_granted</fullName>
        <description>Application access granted</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Notify_contact_of_access_grantedVF</template>
    </alerts>
    <alerts>
        <fullName>Application_access_granted_cns</fullName>
        <description>Application access granted - CNS</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>cns_noreply@cnsc.us</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Notify_contact_of_access_grantedVF_cns</template>
    </alerts>
    <alerts>
        <fullName>Currency_Center_Access_Approved</fullName>
        <description>Currency Center Access Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Currency_center_portal_service_access_granted</template>
    </alerts>
    <alerts>
        <fullName>Currency_Center_Inform_requester</fullName>
        <description>Currency Center Inform requester</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISS_Portal_Notify_of_Currency_Center_service_request</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Alert_Treasury_Dashboard_Manager_of_access_request</fullName>
        <description>ISSP Alert Treasury Dashboard Manager of access request</description>
        <protected>false</protected>
        <recipients>
            <recipient>khattabil@iata.org.prod</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pietranget@iata.org.prod</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_Notify_TD_Manager_of_TD_request_VF</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Alert_contact_of_TD_Premium_request</fullName>
        <description>ISSP Alert contact of TD Premium request</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_Notify_contact_of_TD_Premium_request</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Alert_contact_of_TD_Premium_request_FIRST</fullName>
        <description>ISSP Alert contact of TD Premium request_FIRST</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_Notify_contact_of_TD_Premium_request_First</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Alert_contact_of_Treasury_Dashboard_request</fullName>
        <description>ISSP Alert contact of Treasury Dashboard request</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_Notify_contact_of_T_Dashboard_request</template>
    </alerts>
    <alerts>
        <fullName>KAVI_Access_Granted</fullName>
        <description>KAVI Access Granted</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Kavi_Notify_contact_of_access_grantedVF</template>
    </alerts>
    <alerts>
        <fullName>Notification_that_user_receive_after_an_access_request</fullName>
        <description>Notification that user receive after an access request</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Notify_contact_of_access_requestVF</template>
    </alerts>
    <alerts>
        <fullName>Notification_that_user_receive_after_an_access_request_cns</fullName>
        <description>Notification that user receive after an access request - CNS</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>cns_noreply@cnsc.us</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Notify_contact_of_access_requestVF_cns</template>
    </alerts>
    <alerts>
        <fullName>Notify_Access_denied</fullName>
        <description>Notify Access denied</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Notify_contact_of_access_rejectedVF</template>
    </alerts>
    <alerts>
        <fullName>Notify_Access_denied_by_PortalAdmin</fullName>
        <description>Portal Admin rejects access to Service. Portal User is notified with this Alert.</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Notify_contact_of_access_rejected_VF_ADM</template>
    </alerts>
    <alerts>
        <fullName>Notify_Access_denied_by_PortalAdmin_CNS</fullName>
        <description>Portal Admin rejects access to Service. Portal User is notified with this Alert. - CNS</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>cns_noreply@cnsc.us</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Notify_contact_of_access_rej_VF_ADM_cns</template>
    </alerts>
    <alerts>
        <fullName>Notify_Access_denied_by_internal_user</fullName>
        <description>IATA Internal User rejects access to Service. Portal User is notified with this Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Notify_contact_of_access_rejected_VF_INT</template>
    </alerts>
    <alerts>
        <fullName>Notify_Access_denied_by_internal_user_cns</fullName>
        <description>IATA Internal User rejects access to Service. Portal User is notified with this Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>cns_noreply@cnsc.us</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Notify_contact_of_access_rej_VF_INT_cns</template>
    </alerts>
    <alerts>
        <fullName>Notify_contact_of_access_granted_to_TD_Premium</fullName>
        <description>Notify contact of access granted to TD-Premium</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_Notify_contact_of_TDpremium_granted</template>
    </alerts>
    <alerts>
        <fullName>Notify_contact_of_access_granted_to_Treasury_Dashboard</fullName>
        <description>Notify contact of access granted to Treasury Dashboard</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_Notify_contact_of_T_Dashboard_granted</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_administrators_to_validate_request</fullName>
        <description>Send email to administrators to validate request</description>
        <protected>false</protected>
        <recipients>
            <recipient>Portal Administrator</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Notify_Admin_of_app_requestVF</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_administrators_to_validate_request_cns</fullName>
        <description>Send email to administrators to validate request - CNS</description>
        <protected>false</protected>
        <recipients>
            <recipient>Portal Administrator</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>cns_noreply@cnsc.us</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Notify_Admin_of_app_requestVF_CNS</template>
    </alerts>
    <fieldUpdates>
        <fullName>Activate_Financial_contact</fullName>
        <field>Financial_Assessment_Contact__c</field>
        <literalValue>1</literalValue>
        <name>Activate Financial contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Contact__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Application_Name_Text_Field_Update</fullName>
        <field>Application_Name_Text_Field__c</field>
        <formula>Portal_Application__r.Name</formula>
        <name>Application Name Text Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Application_uniqueness_for_contact</fullName>
        <description>Concatenate the contact ID and Application ID to ensure it&apos;s unique</description>
        <field>Application_uniqueness_for_contact__c</field>
        <formula>Contact__c + Portal_Application__c</formula>
        <name>Application uniqueness for contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Biller_Direct_Rights</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Biller_Direct</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Biller Direct Rights</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deactivate_Financial_contact</fullName>
        <field>Financial_Assessment_Contact__c</field>
        <literalValue>0</literalValue>
        <name>Deactivate Financial contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Contact__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Grant_Access</fullName>
        <description>Change the app right status to &apos;Grant Access&apos;</description>
        <field>Right__c</field>
        <literalValue>Access Granted</literalValue>
        <name>Grant Access</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISS_Portal_SIS_Portal_service_Inactiva</fullName>
        <field>Type_of_Contact__c</field>
        <name>ISS Portal - SIS Portal service Inactiva</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Contact__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Notify_Admin_of_contact_request</fullName>
        <field>Notification_Template__c</field>
        <formula>&quot;NT-0022&quot;</formula>
        <name>Notify Admin of contact request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Notify_Application_access_granted</fullName>
        <field>Notification_Template__c</field>
        <formula>&quot;NT-0021&quot;</formula>
        <name>Notify Application access granted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Portal_app_rigth_Switch_to_edit_RT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Application_rigth</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Portal app rigth Switch to edit RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reject_Access</fullName>
        <description>Set the app right Access to &apos;Access Denied&apos;</description>
        <field>Right__c</field>
        <literalValue>Access Denied</literalValue>
        <name>Reject Access</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Request_Access</fullName>
        <description>Set the Portal application right in request status</description>
        <field>Right__c</field>
        <literalValue>Access Requested</literalValue>
        <name>Request Access</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SIS_User</fullName>
        <field>Type_of_Contact__c</field>
        <literalValue>SIS Super User</literalValue>
        <name>Update SIS User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Contact__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Activate Financial contact</fullName>
        <actions>
            <name>Activate_Financial_contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Portal_Applications__c.Name</field>
            <operation>equals</operation>
            <value>ifap</value>
        </criteriaItems>
        <criteriaItems>
            <field>Portal_Application_Right__c.Right__c</field>
            <operation>equals</operation>
            <value>Access Granted</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Application Name Text Field Update</fullName>
        <actions>
            <name>Application_Name_Text_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates application name text field to be used in roll-up fields.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Application uniqueness for contact</fullName>
        <actions>
            <name>Application_uniqueness_for_contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Biller Direct Rights</fullName>
        <actions>
            <name>Biller_Direct_Rights</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Portal_Applications__c.Name</field>
            <operation>equals</operation>
            <value>Biller Direct</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Deactivate Financial contact</fullName>
        <actions>
            <name>Deactivate_Financial_contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Portal_Applications__c.Name</field>
            <operation>equals</operation>
            <value>ifap</value>
        </criteriaItems>
        <criteriaItems>
            <field>Portal_Application_Right__c.Right__c</field>
            <operation>notEqual</operation>
            <value>Access Granted</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal - SIS Portal service</fullName>
        <actions>
            <name>Update_SIS_User</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Portal_Applications__c.Name</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Portal_Application_Right__c.Right__c</field>
            <operation>equals</operation>
            <value>Access Granted</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal - SIS Portal service Inactivate</fullName>
        <actions>
            <name>ISS_Portal_SIS_Portal_service_Inactiva</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Portal_Applications__c.Name</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Portal_Application_Right__c.Right__c</field>
            <operation>equals</operation>
            <value>Access Denied</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ISSP Notify contact of access granted to Kavi</fullName>
        <actions>
            <name>KAVI_Access_Granted</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Portal_Application_Right__c.Right__c</field>
            <operation>equals</operation>
            <value>Access Granted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Portal_Application_Right__c.Application_Name__c</field>
            <operation>equals</operation>
            <value>Standards Setting Workspace</value>
        </criteriaItems>
        <criteriaItems>
            <field>Portal_Application_Right__c.Kavi_user__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send an email to notify that the request for kavi service has been granted</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP TD Premium Request</fullName>
        <actions>
            <name>ISSP_Alert_Treasury_Dashboard_Manager_of_access_request</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ISSP_Alert_contact_of_TD_Premium_request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Portal_Application_Right__c.Application_Name__c</field>
            <operation>equals</operation>
            <value>Treasury Dashboard - Premium</value>
        </criteriaItems>
        <criteriaItems>
            <field>Portal_Application_Right__c.Right__c</field>
            <operation>equals</operation>
            <value>Access Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Service_TD_Basic__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>Notify contact of access request to TD PREMIUM + The ISS Portal user receives a Treasury Dashboard &quot;commercial&quot; information email that explains specific TD access information</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP TD Premium Request_FIRST</fullName>
        <actions>
            <name>ISSP_Alert_Treasury_Dashboard_Manager_of_access_request</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ISSP_Alert_contact_of_TD_Premium_request_FIRST</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Portal_Application_Right__c.Application_Name__c</field>
            <operation>equals</operation>
            <value>Treasury Dashboard - Premium</value>
        </criteriaItems>
        <criteriaItems>
            <field>Portal_Application_Right__c.Right__c</field>
            <operation>equals</operation>
            <value>Access Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Service_TD_Basic__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <description>Notify contact of access request to TD PREMIUM + The ISS Portal user receives a Treasury Dashboard &quot;commercial&quot; information email that explains specific TD access information</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP Treasury Dashboard Request</fullName>
        <actions>
            <name>ISSP_Alert_Treasury_Dashboard_Manager_of_access_request</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ISSP_Alert_contact_of_Treasury_Dashboard_request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify contact of access request to TD + The ISS Portal user receives a Treasury Dashboard &quot;commercial&quot; information email that explains specific TD access information</description>
        <formula>AND(ISPICKVAL(Right__c, &apos;Access Requested&apos;), Portal_Application__r.Name  =  &apos;Treasury Dashboard&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify contact of access rejected</fullName>
        <actions>
            <name>Notify_Access_denied</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Portal_Application_Right__c.Right__c</field>
            <operation>equals</operation>
            <value>Access Denied</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify contact of access rejected by Portal Admin</fullName>
        <actions>
            <name>Notify_Access_denied_by_PortalAdmin</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Portal_Application_Right__c.Right__c</field>
            <operation>equals</operation>
            <value>Access Denied</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>contains</operation>
            <value>ISS</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify contact of access rejected by internal user</fullName>
        <actions>
            <name>Notify_Access_denied_by_internal_user</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Portal_Application_Right__c.Right__c</field>
            <operation>equals</operation>
            <value>Access Denied</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notContain</operation>
            <value>ISS</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify contact of access request</fullName>
        <actions>
            <name>Notification_that_user_receive_after_an_access_request</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Send_email_to_administrators_to_validate_request</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notify_Admin_of_contact_request</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   TEXT(Right__c) = &apos;Access Requested&apos;,   Portal_Application__r.Name != &apos;Treasury Dashboard&apos;,   Portal_Application__r.Name != &apos;Currency Center&apos;,   OR(     ISBLANK(Contact__r.Community__c),     NOT(BEGINS(Contact__r.Community__c, &apos;CNS&apos;))   ),   OR(     AND(       BEGINS(Portal_Application__r.Name, &apos;IATA EasyPay&apos;),       Contact__r.Account.ANG_IEP_Status_FF__c  = &quot;Open&quot;     ),     NOT(BEGINS(Portal_Application__r.Name, &apos;IATA EasyPay&apos;))   ),   Contact__c = $User.ContactId )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify contact of access request - CNS</fullName>
        <actions>
            <name>Notification_that_user_receive_after_an_access_request_cns</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Send_email_to_administrators_to_validate_request_cns</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Portal_Application_Right__c.Right__c</field>
            <operation>equals</operation>
            <value>Access Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Portal_Applications__c.Name</field>
            <operation>notEqual</operation>
            <value>Treasury Dashboard</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Community__c</field>
            <operation>startsWith</operation>
            <value>CNS</value>
        </criteriaItems>
        <description>NB. due to the Process Builder bug this is done as a workflow: https://success.salesforce.com/issues_view?id=a1p3A000000jkwKQAQ</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify contact of application Access granted</fullName>
        <actions>
            <name>Application_access_granted</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notify_Application_access_granted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND( ISPICKVAL (Right__c , &apos;Access Granted&apos;), NOT ( OR(CONTAINS(Application_Name__c, &apos;Treasury Dashboard&apos;), CONTAINS(Application_Name__c, &apos;Standards Setting Workspace&apos;) )))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Portal app rigth Switch to edit RT</fullName>
        <actions>
            <name>Portal_app_rigth_Switch_to_edit_RT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Portal_Application_Right__c.Right__c</field>
            <operation>equals</operation>
            <value>Access Requested</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
