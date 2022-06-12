public with sharing class BatchApexExample implements Database.Batchable <SObject> {
   
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String querry = 'select id, Industry from Account';
        return database.getQueryLocator(querry);   
     }
    public void  execute (Database.BatchableContext bc,List<Account> acclist) 
    {

    }
    public void  finish (Database.BatchableContext bc) 
    {

    }
}
