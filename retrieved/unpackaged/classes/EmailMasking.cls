public with sharing class EmailMasking {  
   Public static String strFields;  
   Public static Boolean onlycustm;
   Public static Boolean onlystndrd;
   

    
    @AuraEnabled(cacheable=true)
   public static Map<String, String> fetchObjMap(Boolean cusObj, Boolean stndrdObj ) {
  
        Map<String,String> objMap = new Map<String,String>();
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
       // Boolean cusObj =true;
       // Boolean stndrdObj=false;
        for(String globalDescribeKey : globalDescribeMap.keySet()) {
            
            // * Getting the current sObject type
            Schema.SObjectType currentSObjectType = globalDescribeMap.get(globalDescribeKey);
        
            // * Getting the current sObject description result from sObject Type
                Schema.DescribeSObjectResult currentSObjectResult = currentSObjectType.getDescribe();
                
         
           if(cusObj){
               if(currentSObjectResult.isCustom()){
                  objMap.put(currentSObjectResult.getName(),currentSObjectResult.getLabel());
               }
           }
         // system.debug('stndrdObj:::'+stndrdObj);
          if(stndrdObj){
             if(!currentSObjectResult.isCustom()){
                  objMap.put(currentSObjectResult.getName(),currentSObjectResult.getLabel());
               }
           }
        }
        system.debug('objMap::'+objMap);
       return objMap ;
   }   
    


    
    
@AuraEnabled(cacheable=true)
    public static Map<String,String> getFieldMapAPI( List<String> searchKey,Map<String,List<string>> fieldsName) {   
       system.debug('>>>'+searchKey);
       system.debug('>>>'+fieldsName);
        Map<String,List<string>> fieldsNames = fieldsName;     
       Map<String,String> errorMap= new Map<String,String>();
       
       if(fieldsName==null || fieldsName.size()==0){
          errorMap.put('Message','Please Choose At least one Field');
          return errorMap; // new Map<String,String>('error': 'Enter At least one Object Name');
       }
       if(searchKey.size()==0 || searchKey == null){
           
           errorMap.put('Message','Enter At least one Object Name');
          return errorMap; // new Map<String,String>('error': 'Enter At least one Object Name');
        }else{
          Map<String,sObjectType> sObjMap = sObjDscrbMap(searchKey);
             
             if(sObjMap!=null){
                 
               Map<String, Map<String,Schema.SObjectField>> sObjFldMap= getFieldsAPI(sObjMap);
                 
                 if(sObjFldMap!=null){
                    return getObjFields(sObjFldMap,fieldsNames);
                 }else{
                   errorMap.put('Error','Fields Not Found');
                   return errorMap;
                 }
             }else{
                errorMap.put('Error','No Object is Not Found');
                return errorMap;
             }
          } 
    }
    
    public static Map<String,sObjectType> sObjDscrbMap(List<String> searchKey){
      
       Map<String,sObjectType> sObjMap= new Map<String,sObjectType> ();
      
       for(String obj: searchKey){
           sObjectType objDscrb = Schema.getGlobalDescribe().get(obj);
           sObjMap.put(obj,objDscrb);
       }
       
       if(sObjMap.size()>0 || sObjMap==null){
           return sObjMap;
       }else{
           return null;
       }
    }
    
    public static Map<String, Map<String,Schema.SObjectField>> getFieldsAPI(Map<String,sObjectType> sObjMap){
        Map<String,Map<String,Schema.SObjectField>> sObjFldMap = new Map<String, Map<String,Schema.SObjectField>>();
        
         Map<String,Schema.SObjectField> mfields = new Map<String,Schema.SObjectField>(); 
         for(String obj: sObjMap.keySet() ){
          system.debug('obj>>>>'+obj);
         system.debug(sObjMap.get(obj));
           mfields = sObjMap.get(obj).getDescribe().fields.getMap();
           sObjFldMap.put(obj,mfields);
        }
        
      if(sObjFldMap!=null && sObjFldMap.size()>0){
       return sObjFldMap;
      }else{
        return null;
       }
   }
   
   public static Map<String, String> getObjFields( Map<String, Map<String,Schema.SObjectField>> sObjFldMap, Map<String,List<string>> fieldsNames){
      system.debug('fieldsNames:::'+fieldsNames);
       Map<String,List<string>> RqurdFields= new  Map<String,List<string>>() ;  
          List<String> labelFldMap= new  List<String>();
          List<String> APIFldMap= new  List<String>();
        for(string keyfld: fieldsNames.keySet()){
           for(String fldL: fieldsNames.get('Label')){
              system.debug('fldL::'+fldL);
               if(String.isBlank(fldL) || String.isEmpty(fldL) ){
                   system.debug('fldL1::'+fldL);
                }else{
                system.debug('fldL2::'+fldL);
                  labelFldMap.add(fldL);
                  RqurdFields.put('Label',labelFldMap);
                }
           }
           for(String fldL: fieldsNames.get('API')){
              system.debug('fldL::'+fldL);
               
                system.debug('fldL2::'+fldL);
                  APIFldMap.add(fldL.toUpperCase());
                  RqurdFields.put('API',APIFldMap);
           }
            
            
        }
      
       Map<String,String>  strFieldsMap=new Map<String,String>();
       String strFields='';
       system.debug('RqurdFields:::'+RqurdFields);
      if(RqurdFields==null || RqurdFields.size()==0){
          Map<String,String> errorMap= new Map<String,String>();
          errorMap.put('Message','Fields Name not Provided');
          return errorMap;
      }   
      for( String obj : sObjFldMap.keySet()){
          Map<String,Schema.SObjectField> mfields = sObjFldMap.get(obj);
          strFields='';
           for(Schema.SObjectField field : mfields.values()){
                  if(RqurdFields!=null &&((RqurdFields.get('API')!=null && RqurdFields.get('API').contains(String.ValueOf(field.getDescribe().getType()).toUpperCase())))){
                   system.debug('labelsize:::'+RqurdFields.get('Label'));  
                         
                  // system.debug('FLD:::'+RqurdFields+'>>>'+String.ValueOf(field.getDescribe().getType())+'>>>'+RqurdFields.get('API').contains(String.ValueOf(field.getDescribe().getType())));                      
                        if(strFields==null){
                           strFields = field.getDescribe().getName();
                        }else{
                           if(strFields==''){
                             strFields +=  field.getDescribe().getName();
                           }else{
                             strFields += ', ' + field.getDescribe().getName();
                           }
                           
                        }
                    }else if(RqurdFields.get('Label')!=null && RqurdFields.get('Label').size()>0){
                         
                         for(String label: RqurdFields.get('Label')){
                              Boolean flag = false;
                              system.debug('Label:::'+label);
                              system.debug('Label:::'+field.getDescribe().getLabel().contains(label));
                              system.debug('Label:::'+field.getDescribe().getLabel());
                              String labelRecd = label.trim();
                              String labelToMatch = field.getDescribe().getLabel();
                              labelToMatch = labelToMatch.deleteWhitespace();
                              system.debug('label recd-> ' +labelRecd);
                              system.debug('get Label-> ' +labelToMatch);
                              if(labelToMatch!=null && labelToMatch!='' && labelToMatch.containsIgnoreCase(labelRecd)) {
                                 flag = true;
                              }
                              system.debug('value of flag is->' +flag);
                              if( label!=''&& label!=null && (field.getDescribe().getLabel().containsIgnoreCase(label) || flag == true)){
                                    if(strFields==null){
                                           strFields = field.getDescribe().getName();
                                        }else{
                                           if(strFields==''){
                                             strFields +=  field.getDescribe().getName();
                                           }else{
                                             strFields += ', ' + field.getDescribe().getName();
                                           }
                                        }
                                   break;     
                                }
                       }
                    }
                }
               system.debug('strFields:::'+strFields);
              if(strFields==null || strFields==''){
                   strFields='Required Fields Not Found';
                   strFieldsMap.put(obj,strFields);
                }else{
                   strFieldsMap.put(obj,strFields);
                }
         }  
    return  strFieldsMap; 
  
   
   }
   
   
  /*  
     
    @AuraEnabled(cacheable=true)
    public static String getFieldAPI(String searchKey) { // This method to be replaced by getFieldMapAPI
       system.debug('>>>'+searchKey);
        if(searchKey=='' || searchKey == null){
          return 'Enter At least one Object Name';
        }else {
            sObjectType objDscrb = Schema.getGlobalDescribe().get(searchKey);
            if(objDscrb==null){
               return 'Object Not Found';
            }else {
                Map<String,Schema.SObjectField> mfields = objDscrb.getDescribe().fields.getMap();
                 strFields='';
                  if(mfields==null || mfields.size()==0 ){
                          return 'Fields Not Found';
                  } else { 
                      for(Schema.SObjectField field : mfields.values())
                            {
                                if(Schema.DisplayType.EMAIL == field.getDescribe().getType() || Schema.DisplayType.PHONE == field.getDescribe().getType())
                                    
                                    if(strFields==null){
                                       strFields = field.getDescribe().getName();
                                    }else{
                                       if(strFields==''){
                                         strFields +=  field.getDescribe().getName();
                                       }else{
                                         strFields += ', ' + field.getDescribe().getName();
                                       }
                                       
                                    }
                            }
                          //  system.debug('strFields:::'+strFields);
                            if(strFields==null || strFields==''){
                               strFields='No Fields Found';
                            }
                          
                        return strFields;
                   } 
            }
       } 
    }
       
   @AuraEnabled(cacheable=true)
   public static List<String> fetchObjList(Boolean cusObj, Boolean stndrdObj ) {
   system.debug('fetchObj:::'+cusObj);
   system.debug('stndrdObj:::'+stndrdObj);
        List<String> objList = new List<String>();
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
       // Boolean cusObj =true;
       // Boolean stndrdObj=false;
        for(String globalDescribeKey : globalDescribeMap.keySet()) {
            
            // * Getting the current sObject type
            Schema.SObjectType currentSObjectType = globalDescribeMap.get(globalDescribeKey);
        
            // * Getting the current sObject description result from sObject Type
                Schema.DescribeSObjectResult currentSObjectResult = currentSObjectType.getDescribe();
          system.debug('cusObj:::'+cusObj);
           if(cusObj){
               if(currentSObjectResult.isCustom()){
                  objList.add(currentSObjectResult.getName());
               }
           }
          system.debug('stndrdObj:::'+stndrdObj);
          if(stndrdObj){
             if(!currentSObjectResult.isCustom()){
                  objList.add(currentSObjectResult.getName());
               }
           }
        }
        system.debug('objList::'+objList);
       return objList ;
   }
    
   public static Map<String,String> createObjFldMap(List<String> objList){
      Map<String,String> objMap= new  Map<String,String>();
      for(String objstr: objList ){
         String fldString='';
         fldString = getFieldAPI(objstr);
          objMap.put(objstr,fldString); 
      } 
      return objMap;
   }
   
     @AuraEnabled(cacheable=true)
  public static List<Account> getAccounts() {
  return [SELECT Id, Name, Phone FROM Account];
  }
   
  @AuraEnabled(cacheable=true)
    public static List<Contact> getContactList() {
        return [
            SELECT Id, Name, Title, Phone, Email
            FROM Contact
            LIMIT 10
        ];
    }  */
    

}