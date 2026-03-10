; Python injections merged locally so we don't depend on `; extends` behavior.

(call
  function: (attribute
    object: (identifier) @_re)
  arguments: (argument_list
    (string
      (string_content) @injection.content))
  (#eq? @_re "re")
  (#set! injection.language "regex"))

(call
  function: (attribute
    object: (identifier) @_re)
  arguments: (argument_list
    (concatenated_string
      [
        (string
          (string_content) @injection.content)
        (comment)
      ]+))
  (#eq? @_re "re")
  (#set! injection.language "regex"))

((binary_operator
  left: (string
    (string_content) @injection.content)
  operator: "%")
  (#set! injection.language "printf"))

((comment) @injection.content
  (#set! injection.language "comment"))

; SQL assignment like `SCHEMA_SQL = """..."""`.
(
  (expression_statement
    (assignment
      left: (identifier) @_name
      right: (string
        (string_content) @injection.content)))
  (#lua-match? @_name "^[%u%d_]*[Ss][Qq][Ll]$")
  (#set! injection.language "sql"))

(
  (expression_statement
    (assignment
      left: (identifier) @_name
      right: (parenthesized_expression
        (concatenated_string
          (string
            (string_content) @injection.content)+))))
  (#lua-match? @_name "^[%u%d_]*[Ss][Qq][Ll]$")
  (#set! injection.combined)
  (#set! injection.language "sql"))

; SQL passed directly to DB execute-style calls.
(
  (expression_statement
    (call
      function: (attribute
        attribute: (identifier) @_fn)
      arguments: (argument_list
        (string
          (string_content) @injection.content)
        . (_)*)))
  (#any-of? @_fn "execute" "executemany" "executescript")
  (#set! injection.language "sql"))

(
  (expression_statement
    (call
      function: (attribute
        attribute: (identifier) @_fn)
      arguments: (argument_list
        (parenthesized_expression
          (concatenated_string
            (string
              (string_content) @injection.content)+))
        . (_)*)))
  (#any-of? @_fn "execute" "executemany" "executescript")
  (#set! injection.combined)
  (#set! injection.language "sql"))
