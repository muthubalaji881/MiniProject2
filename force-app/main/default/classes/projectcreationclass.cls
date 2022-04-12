public with sharing class projectcreationclass {
    public static void createprojectAssignment(List<	Project__c> projList){
        //list to store changes status of emp
    List<Employee__c> chnagedEmps=new  List<Employee__c>();
    List<Employee__c> relatedEmp= new List<Employee__c>();

     if(projList[0].Project_Stage__c=='Draft'  ){
         Integer i=0;
     System.debug('projList'+projList);
     //list to hold multiple project assigmnts
     List<Project_Assignment__c> listPA =new List<Project_Assignment__c>();
     
     //take employees
     List<Employee__c> allEmployee =[select Id from Employee__c where Employee_Status__c='Unassigned'];
     System.debug('allEmployee'+allEmployee);
         for(Employee__c emp:allEmployee){
             if(i<projList[0].Employees_Required__c){
                   System.debug('I'+i);
                 //create proj assignment- object
                 Project_Assignment__c newProjAssignment = new Project_Assignment__c();
                 //set values
                newProjAssignment.Project_Start_Date__c=projList[0].Project_Start_Date__c;
                newProjAssignment.Roll_off_Date__c=projList[0].Project_End_Date__c;
                newProjAssignment.Project__c=projList[0].Id;
                newProjAssignment.Employee__c=emp.Id;
             i++; 
             //add to list
             listPA.add(newProjAssignment);
             }            
      }
     //list of emp Ids
     List<Id> empIds =new List<Id>();
     for(Project_Assignment__c pa:listPA){
         empIds.add(pa.Employee__c);
     }
    //retice the employees from the DB to make the cjhanhges
    relatedEmp =[select Employee_Status__c from Employee__c where ID In:empIds];
         
    for(Employee__c emp:relatedEmp){
         emp.Employee_Status__c='Assigned';
         chnagedEmps.add(emp);
     }
    
   
     
    Insert listPA;
    Upsert chnagedEmps;
         
     }
     
     
      
     
 }
}
