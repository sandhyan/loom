Definitions.

D   = [0-9]
L   = [A-Za-z]
WS  = ([\000-\s]|%.*)
C   = (<|<=|=|=>|>)

Rules.

in     : {token,{set,TokenLine,list_to_atom(TokenChars)}}.
or     : {token,{union,TokenLine,list_to_atom(TokenChars)}}.
and    : {token,{intersection,TokenLine,list_to_atom(TokenChars)}}.
{C}    : {token,{comparator,TokenLine,list_to_atom(TokenChars)}}.
{L}+   : {token,{var,TokenLine,list_to_atom(TokenChars)}}.
{D}+   : {token,{integer,TokenLine,list_to_integer(TokenChars)}}.
[(),]  : {token,{list_to_atom(TokenChars),TokenLine}}.
{WS}+  : skip_token.

Erlang code.