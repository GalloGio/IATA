/**
 * Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

public virtual class UnitOfWork {

	/**
	 * UnitOfWork Exception
	 **/
	public class UnitOfWorkException extends Exception {}
    
    public List<Schema.SObjectType> sObjects = new List<Schema.SObjectType>();
    public Map<String, List<SObject>> newRecordsByType = new Map<String, List<SObject>>();
    public Map<String, Map<Id, SObject>> updatedRecordByType = new Map<String, Map<Id, SObject>>();
    public Map<String, Map<Id, SObject>> deletedRecordsByType = new Map<String, Map<Id, SObject>>();
    public Map<String, Relationships> relationshipsByType = new Map<String, Relationships>();

    public UnitOfWork(List<Schema.SObjectType> sObjectTypes){

    	sObjects = sObjectTypes.clone();

    	for(Schema.SObjectType sObjectType : sObjects){
    	    registerType(sObjectType);
    	}
    }

    // default implementations for commitWork events
    public virtual void onRegisterType(Schema.SObjectType sObjectType) {}
    public virtual void onCommitWorkStarting() {}
    public virtual void onDMLStarting() {}
    public virtual void onDMLFinished() {}
    public virtual void onCommitWorkFinished(Boolean wasSuccessful) {}

    private void registerType(Schema.SObjectType sObjectType){

    	String objectName = sObjectType.getDescribe().getName();
        newRecordsByType.put(objectName, new List<SObject>());
        updatedRecordByType.put(objectName, new Map<Id, SObject>());
        deletedRecordsByType.put(objectName, new Map<Id, SObject>());
        relationshipsByType.put(objectName, new Relationships());

        // give derived class opportunity to register the type
        onRegisterType(sObjectType);
    }

    /**
     * Register a newly created SObject instance to be inserted when commitWork is called
     *
     * @param record A newly created SObject instance to be inserted during commitWork
     **/
    public void registerNew(SObject record){
        registerNew(record, null, null);
    }

    public void registerNew(List<SObject> records){
        for(SObject record : records){
            registerNew(record, null, null);
        }
    }

    /**
     * Register a newly created SObject instance to be inserted when commitWork is called,
     *   you may also provide a reference to the parent record instance (should also be registered as new separatly)
     *
     * @param record A newly created SObject instance to be inserted during commitWork
     * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
     * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separatly)
     **/
    public void registerNew(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord){
        if(record.Id != null)
            throw new UnitOfWorkException('Only new records can be registered as new');
        String sObjectType = record.getSObjectType().getDescribe().getName();
        if(!newRecordsByType.containsKey(sObjectType))
            throw new UnitOfWorkException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));
        newRecordsByType.get(sObjectType).add(record);
        if(relatedToParentRecord!=null && relatedToParentField!=null)
            registerRelationship(record, relatedToParentField, relatedToParentRecord);
    }

    /**
     * Register a relationship between two records that have yet to be inserted to the database. This information will be
     *  used during the commitWork phase to make the references only when related records have been inserted to the database.
     *
     * @param record An existing or newly created record
     * @param relatedToField A SObjectField referene to the lookup field that relates the two records together
     * @param relatedTo A SOBject instance (yet to be commited to the database)
     */
    public void registerRelationship(SObject record, Schema.sObjectField relatedToField, SObject relatedTo){
        String sObjectType = record.getSObjectType().getDescribe().getName();
        if(!newRecordsByType.containsKey(sObjectType))
            throw new UnitOfWorkException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));
        relationshipsByType.get(sObjectType).add(record, relatedToField, relatedTo);
    }

    /**
     * Register a list of existing records to be updated during the commitWork method
     *
     * @param record Record to be updated
     * @param dirtyFields The list of updated fields
     **/
    public void registerDirty(SObject record, List<SObjectField> dirtyFields){
        if(record.Id == null)
            throw new UnitOfWorkException('New records cannot be registered as dirty');
        String sObjectType = record.getSObjectType().getDescribe().getName();
        if(!updatedRecordByType.containsKey(sObjectType))
            throw new UnitOfWorkException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));

        if (!updatedRecordByType.get(sObjectType).containsKey(record.Id)){
            // Register the record as dirty
            updatedRecordByType.get(sObjectType).put(record.Id, record);
        }
        else{
            // Update the registered record's fields
            SObject registeredRecord = updatedRecordByType.get(sObjectType).get(record.Id);

            for (SObjectField dirtyField : dirtyFields) {
                registeredRecord.put(dirtyField, record.get(dirtyField));
            }

            updatedRecordByType.get(sObjectType).put(record.Id, registeredRecord);
        }
    }

    /**
     * Register a list of existing records to be updated during the commitWork method
     *
     * @param records A list of existing records
     * @param dirtyFields The list of updated fields
     **/
    public void registerDirty(List<SObject> records, List<SObjectField> dirtyFields){
        for(SObject record : records){
            this.registerDirty(record, dirtyFields);
        }
    }

    /**
     * Register an existing record to be deleted during the commitWork method
     *
     * @param record An existing record
     **/
    public void registerDeleted(SObject record){
        if(record.Id == null)
            throw new UnitOfWorkException('New records cannot be registered for deletion');
        String sObjectType = record.getSObjectType().getDescribe().getName();
        if(!deletedRecordsByType.containsKey(sObjectType))
            throw new UnitOfWorkException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));
        deletedRecordsByType.get(sObjectType).put(record.Id, record);
    }

    /**
     * Register a list of existing records to be deleted during the commitWork method
     *
     * @param records A list of existing records
     **/
    public void registerDeleted(List<SObject> records){
        for(SObject record : records){
            this.registerDeleted(record);
        }
    }

    /**
     * Takes all the work that has been registered with the UnitOfWork and commits it to the database
     **/
    public void commitWork(){
        // notify we're starting the commit work
        onCommitWorkStarting();

        // Wrap the work in its own transaction
        Savepoint sp = Database.setSavePoint();
        Boolean wasSuccessful = false;
        try
        {
            // notify we're starting the DML operations
            onDMLStarting();
            // Insert by type


            /*******
            TODO TODO TODO
            Change SObject type to wrapper to improve describe performance
            **/
            for(Schema.SObjectType sObjectType : sObjects)
            {
                String sobjectName = sObjectType.getDescribe().getName();
                if(relationshipsByType.containsKey(sobjectName)) relationshipsByType.get(sobjectName).resolve();
                if(newRecordsByType.containsKey(sobjectName)) insert newRecordsByType.get(sobjectName);
            }

            if(!updatedRecordByType.isEmpty()){
            	// Update by type
            	for(Schema.SObjectType sObjectType : sObjects){

            		String sobjectName = sObjectType.getDescribe().getName();
            	    if(updatedRecordByType.containsKey(sobjectName)) update updatedRecordByType.get(sobjectName).values();
            	}
            }
            
           
            // Delete by type (in reverse dependency order)
            Integer objectIdx = sObjects.size() - 1;
            while(objectIdx>=0){

            	String objectName = sObjects[objectIdx--].getDescribe().getName();
                if(deletedRecordsByType.containsKey(objectName)) delete deletedRecordsByType.get(objectName).values();
            }

            // notify we're done with DML
            onDMLFinished();

            // mark tracker to indicate success
            wasSuccessful = true;
        }
        catch (Exception e){
            // Rollback
            Database.rollback(sp);
            // Throw exception on to caller
            throw e;
        }
        finally
        {
            // notify we're done with commit work
            onCommitWorkFinished(wasSuccessful);
        }
    }

    private class Relationships{
        private List<Relationship> relationshipsByType = new List<Relationship>();

        public void resolve(){
            // Resolve relationships
            for(Relationship relationship : relationshipsByType){
                relationship.Record.put( relationship.RelatedToField, relationship.RelatedTo.Id);
            }

        }

        public void add(SObject record, Schema.sObjectField relatedToField, SObject relatedTo){
            // Relationship to resolve
            Relationship relationship = new Relationship();
            relationship.Record = record;
            relationship.RelatedToField = relatedToField;
            relationship.RelatedTo = relatedTo;
            relationshipsByType.add(relationship);
        }

    }

    private class Relationship{
        public SObject Record;
        public Schema.sObjectField RelatedToField;
        public SObject RelatedTo;
    }
}