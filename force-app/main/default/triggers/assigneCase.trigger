trigger assigneCase on Case (before insert , after insert) {

Set<Id> withCont = new Set<Id>();
Set<Id> withoutCont = new Set<Id>();
List<Contact > conToCreate = new List<Contact >();
List<Case> caseToUpdate = new List<Case>();

  If(Trigger.IsInsert && Trigger.isBefore){
        for(Case casecon: Trigger.New){
          if(casecon.contact!=null){
               casecon.ownerid= UserInfo.getUserId();
            }
      }
  }  else if(Trigger.IsInsert && Trigger.isAfter){
  
         for(Case casecon: Trigger.New){
           if(casecon.contact==null){
                Contact con = new Contact(CaseId__c=casecon.id);
                conToCreate.add(con );
            }
      }
    if(conToCreate.size()>0){
        insert conToCreate;
    }
   for(Contact  con : conToCreate){
        Case tempCase = Trigger.NewMap.get(con.CaseId__c);
        tempCase.contactid = con.id; 
        caseToUpdate.add(tempCase);
   } 
   if(caseToUpdate.size()>0){
     update caseToUpdate;
   }
  }


}