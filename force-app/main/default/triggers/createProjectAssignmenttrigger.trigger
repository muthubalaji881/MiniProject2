trigger createProjectAssignmenttrigger on Project__c (after insert,after update) {
    if(trigger.isInsert){
         projectcreationclass.createprojectAssignment(trigger.new);
    }
    if(trigger.isUpdate){
         projectcreationclass.updateProjectstage(trigger.new);
         projectcreationclass.sendEmail(trigger.new);
    }
   
   

}