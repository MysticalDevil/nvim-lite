; extends

; SQL string injection for Go without depending on go.nvim runtime files.
([
  (interpreted_string_literal_content)
  (raw_string_literal_content)
] @injection.content
  (#match? @injection.content "(SELECT|select|INSERT|insert|UPDATE|update|DELETE|delete).+(FROM|from|INTO|into|VALUES|values|SET|set).*(WHERE|where|GROUP BY|group by)?")
  (#set! injection.language "sql"))

([
  (interpreted_string_literal_content)
  (raw_string_literal_content)
] @injection.content
  (#contains? @injection.content "-- sql" "--sql" "ADD CONSTRAINT" "ALTER TABLE" "ALTER COLUMN"
               "DATABASE" "FOREIGN KEY" "GROUP BY" "HAVING" "CREATE INDEX" "INSERT INTO"
               "NOT NULL" "PRIMARY KEY" "UPDATE SET" "TRUNCATE TABLE" "LEFT JOIN"
               "add constraint" "alter table" "alter column" "database" "foreign key"
               "group by" "having" "create index" "insert into" "not null" "primary key"
               "update set" "truncate table" "left join")
  (#set! injection.language "sql"))
