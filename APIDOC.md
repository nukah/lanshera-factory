#Lanshera Connection API

##Response codes
* _OK_
* _ERROR_


## Actions
`import (operation_id, username, password)`
>
result:
{ 
  operation_id: INTEGER,
  response: {
    :success => BOOL,
    :data => {
        'skip' => INTEGER,
        'events' => LIST {
            'itemid' => INTEGER,
            'subject' => TEXT,
            'event' => TEXT,
            'ditemid' => TEXT,
            'eventtime' => DATETIME,
            'logtime' => DATETIME,
            'anum' => INTEGER,
            'url' => TEXT,
            'event_timestamp' => UNIXTIME,
            'reply_count' => INTEGER,
            'security' => TEXT
        }
    }
  }
}

`add_comment (operation_id, username, password, journal, post_id, subject, text)`
>
result:
{
  operation_id: INTEGER,
  response: {
    :success => BOOL,
    :data => {
        'dtalkid' => INTEGER,
        'commentlink' => TEXT,
        'status' => TEXT,
    }
  }
}
