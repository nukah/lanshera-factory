#Lanshera Connection API

##Response codes
* _OK_
* _ERROR_


## Actions
`import (import_id, operation_id, user)`
>
result:
{ 
  operation_id: <id>,
  response: <resp_code>,
  data: <data_code>
}

`add_comment (add_comment_id, operation_id, user, post_id, anum)`
>
result:
{
  operation_id: <id>,
  response: <response_code>,
  data: <data_code>
}