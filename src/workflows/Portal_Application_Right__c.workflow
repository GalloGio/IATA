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
        <fullName>ISS Portal - SIS Portal service</fullName>
        <actions>
            <name>Update_SIS_User</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
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
        <active>false</active>
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
</Workflow>
