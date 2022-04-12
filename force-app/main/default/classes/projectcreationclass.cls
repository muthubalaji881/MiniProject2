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
    public static void updateProjectstage(List<Project__c> projList){
        if(projList[0].Project_Stage__c=='Canceled' || projList[0].Project_Stage__c=='Delivered' ){
            
          List<Project_Assignment__c> listPA =[select Employee__c from Project_Assignment__c where Project__c=:projList[0].Id];
          List<Employee__c> relatedEmp= new List<Employee__c>();
            List<Id> empIds =new List<Id>();
            for(Project_Assignment__c pa:listPA){
            empIds.add(pa.Employee__c);
        }
       //retice the employees from the DB to make the cjhanhges
       relatedEmp =[select Employee_Status__c from Employee__c where ID In:empIds]; 
            
        List<Employee__c> chnagedEmps=new  List<Employee__c>();      
            
        for(Employee__c emp:relatedEmp){
            emp.Employee_Status__c='Unassigned';
            chnagedEmps.add(emp);
        }
         
 
      
          Upsert chnagedEmps;
        }
        
    }



   //Send email to the employees once the project is delivered/cancelled
   public static void sendEmail(List<Project__c> projList){
    if(projList[0].Project_Stage__c=='Canceled' || projList[0].Project_Stage__c=='Delivered'){
        System.debug('Condition passed');
        //Query on Project Assignment record to find the project that has been Delivered/Canceled, from which Employees can be fetched
        List<Project_Assignment__c> projAssgList =[SELECT Id,Name,Project__c,Employee__c 
                                                   FROM Project_Assignment__c WHERE Project__c=:projList[0].Id];
        //List of employees who are assigned to the particular project
        List<Employee__c> assignedEmpList = new List<Employee__c>();
        //Collect the Employee ids to whom the email needs to be sent
        List<Id> empIds = new List<Id>();
        for(Project_Assignment__c pa:projAssgList){
            empIds.add(pa.Employee__c);
        }
        assignedEmpList = [SELECT Id, Name, Employee_Status__c, Email__c
                           FROM Employee__c WHERE Id IN:empIds];
        //Send email method
        for(Employee__c emp:assignedEmpList){
            List<String> emailIds = new List<String>();
            List<Messaging.SingleEmailMessage> emailList= new List<Messaging.SingleEmailMessage>();
            emailIds.add(emp.Email__c);

            //send email logic

            if(emp.Email__c!=null)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSenderDisplayName('Marval Project Management');
                mail.setSubject('Aces Project Management: Project Update');
                String body = 'Hi '+emp.Name+', <br/>';
                body+='Your Project Has been Completed.<br/><br/>';
                body+='Thank you!';
                mail.setHtmlBody(body);
                mail.toAddresses = new String[]{emp.Email__c};
                emailList.add(mail);
                system.debug('Email: '+emailList);
            }
            //Error tracking logic
            if(emailList.size()>0)
            {
                Messaging.SendEmailResult[]  emailresults = Messaging.sendEmail(emailList);
                if(emailresults[0].success){
                    System.debug( 'email sent successfully');
                }
                else{
                    System.debug('The email failed to send: '+ emailresults[0].errors[0].message);
                }
            } 
            
        }
}
   }
}