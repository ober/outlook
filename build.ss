#!/usr/bin/env gxi
;; -*- Gerbil -*-

(import :std/build-script)

(defbuild-script
  '("outlook/client"
    (static-exe: "outlook/outlook"
                 "-ld-options" "-lsqlite3 -L/usr/local/opt/sqlite3/lib -lyaml -lssl -lz -L/usr/local/opt/openssl/lib/ -L/usr/local/lib"
                 "-cc-options" "-I/usr/local/opt/sqlite3/include -I/usr/local/opt/openssl/include -I/usr/local/include")))
