;; -*- Gerbil -*-
package: outlook
namespace: outlook
(export main)

(declare (not optimize-dead-definitions))
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

(def config-file "~/.outlook.yaml")
(import (rename-in :gerbil/gambit/os (current-time builtin-current-time)))
(def program-name "outlook")
(def DEBUG (getenv "DEBUG" #f))
(def (dp msg)
  (when DEBUG
    (displayln msg)))

(def interactives
  (hash
   ("search" (hash (description: "Search all email for pattern") (usage: "search <keyword>") (count: 1)))))

(def (main . args)
  (if (null? args)
    (usage))
  (let* ((argc (length args))
	 (verb (car args))
	 (args2 (cdr args)))
    (unless (hash-key? interactives verb)
      (usage))
    (let* ((info (hash-get interactives verb))
	   (count (hash-get info count:)))
      (unless count
	(set! count 0))
      (unless (= (length args2) count)
	(usage-verb verb))
      (apply (eval (string->symbol (string-append "outlook#" verb))) args2))))

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

(def (usage-verb verb)
  (let ((howto (hash-get interactives verb)))
    (displayln "Wrong number of arguments. Usage is:")
    (displayln program-name " " (hash-get howto usage:))
    (exit 2)))

(def (usage)
  (displayln "Usage: outlook <verb>")
  (displayln "Verbs:")
  (for-each
    (lambda (k)
      (displayln (format "~a: ~a" k (hash-get (hash-get interactives k) description:))))
    (sort! (hash-keys interactives) string<?))
  (exit 2))
