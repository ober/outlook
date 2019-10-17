;; -*- Gerbil -*-
;;; © ober
;;; Outlook client library

(import
  :gerbil/gambit
  :scheme/base
  :std/format
  :std/generic
  :std/generic/dispatch
  :std/misc/channel
  :std/misc/ports
  :std/net/address
  :std/net/request
  :std/pregexp
  :std/srfi/13
  :std/srfi/19
  :std/srfi/95
  :std/sugar
  :std/text/base64
  :std/text/json
  :std/text/utf8
  :std/text/yaml
  :std/db/dbi
  :std/db/sqlite
  )

(declare (not optimize-dead-definitions))

(def config-file "~/.outlook.yaml")

(import (rename-in :gerbil/gambit/os (current-time builtin-current-time)))

(def (load-config)
  (let ((config (hash)))
    (hash-for-each
     (lambda (k v)
       (hash-put! config (string->symbol k) v))
     (car (yaml-load config-file)))
    config))

(def (search pattern)
  (let-hash (load-config)
    (let* ((db (sql-connect sqlite-open .db))
	   (search (format "%~a%" pattern))
	   (stmt (sql-prepare db "select quote(Record_RecordID),quote(Message_TimeSent),quote(Message_SenderList), quote(Message_RecipientList), quote(Message_DisplayTo), quote(Message_MentionedMe), quote(Message_ThreadTopic), quote(Message_Preview) from mail where Message_Preview like ? or Message_Preview like ? order by Message_TimeSent DESC"))
	   (binding (sql-bind stmt search search))
	   (results (sql-query stmt)))
      (displayln "| Id | Time Sent| Senders List | Recipients | Addressed To| Me? | Topic | Preview|")
      (displayln "|-|")
      (for-each
	(lambda (record)
	  (with ([ id
		   timesent
		   senderlist
		   recipients
		   fancyto
		   me
		   topic
		   body
		   ]
		 (vector->list record))
	    (displayln "|" id
		       "|" timesent
		       "|" senderlist
		       "|" recipients
		       "|" fancyto
		       "|" me
		       "|" topic
		       "|" body
		       "|")))
	results))))
