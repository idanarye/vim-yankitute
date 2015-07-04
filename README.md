INTRODUCTION
============

Yankitute combines the `yank` and `substitute` Vim commands into one. Like
substitute, it searches for a pattern in the buffer and transforms all matches
using a format string supplied by the user. But instead of replacing the text
in the buffer with the transformed matches, it acts like `yank` and copies the
transformed matches into a register.

SYNTAX
======

The syntax resembles Vim's built-in substitute command:
```
:[range]Yankitute[register]/{pattern}/[string]/[flags]/[join]
```

 * `[range]`: The range to search in. Defaults to the current line.
 * `[register]`: A register to put the transformed matches in.
 * `{pattern}`: The pattern to look for - just like in `substitute`.
 * `[string]`: The format string to replace matches with - just like in
   `substitute`. If not supplied, the match is yanked as is.
 * `[flags]`: Currently only one flag is supported - `g`. If the `g` flag is
   given, searches for more than one match in each line. Note that multiple
   matches from the same line will end up in separate lines in the text copied to
   the register.
 * `[flags]`: Just like in `substitute`, except `c` and `n` are not supported.
   If the `g` flag is given, searches for more than one match in each line.
   Note that multiple matches from the same line will end up in separate lines in
   the text copied to the register.
 * `[join]`: Joins the matches together with a join string, instead of placing
   them in separate lines.

"Not supplying an option" means omitting it's leading `/`. If the `/` is there,
the option is supplied - even if it's an empty string. So, if you write
`:%Yankitute/*///`, the `[string]` option is supplied as empty string - meaning
that all matches will be substituted with empty strings - and the `[join]`
option is supplied as an empty string as well - meaning that the results will
be concatenated(=joined with an empty join string).

Like with the built-in `substitute`, the separator `/` can be any character -
even letters.  Keep in mind, however, that Vim will try to parse the first
character as a register. Only if the first character is not a valid register -
like `/`, `$` or `?` - it will be the separator.

The separator can be escaped with a leading `\`.

USAGE EXAMPLE + MOTIVATION
=====

So, let's say we need to build an SQL table to store people's data. The data
will be read from XML files, so we get ourselves a single XML node with all the
fields:
```xml
<person first_name="Jon" last_name="Smith" city="New York"
	phone="+1-123-456-7890" zip_code="12345" age="30"/>
```

We want to create a table with the same fields. So, we start with the basic:
```sql
CREATE TABLE people(oid INT
)
```
But we also need fields. We could copy the node and transform it with Vim's
awesome text editing capabilities - but it's much easier with Yankitute: all we
have to do is mark our XMl node in visual mode and enter the command
`'<,'>Yankitute/\v(\w+)\=/, \1 VARCHAR/g`. This will put in our register:
```
, first_name VARCHAR
, last_name VARCHAR
, city VARCHAR
, phone VARCHAR
, zip_code VARCHAR
, age VARCHAR
```
which we can then simply paste to the table creation command(and change `age`'s type to int):
```sql
CREATE TABLE people(oid int
	, first_name VARCHAR
	, last_name VARCHAR
	, city VARCHAR
	, phone VARCHAR
	, zip_code VARCHAR
	, age INT
)
```

Now we want to write a select statement to select all those fields - all but
the OID. Also, this time we want them all on the same line - which means we
have to use the join option.  We mark the entire table creation command in
visual mode, and enter the command: `'<,'>Yankitute/\v\,\s*(\w+)/\1//, /`.
Notice there is an extra `/` - we need this to add the space after the `,`.
This will put in our register:
```
first_name, last_name, city, phone, zip_code, age
```
which can easily be transformed to
```sql
SELECT first_name, last_name, city, phone, zip_code, age FROM people
```

Finally, we need to send an email to our team with that list of fields. Again,
we mark the entire table creation command in visual mode, but this time we use:
`'<,'>Yankitute*/\v\,\s*(\w+)/\1`. This will put in **the clipboard**:
```
first_name
last_name
city
phone
zip_code
age
```
which allows us to launch our email client, create a new message, and paste
this list from the clipboard.
