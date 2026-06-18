add feature where enums outside of unit can be still identified as enum by.
first creating a enum index finding all enum declration parsing all relevant files via lockd.yaml
and then checking if the elemnt name is in the index. should work for some cases.

Also there is a problem when in copyWith(Object some) and internally its double but the call side which is valid
is foo.copyWith(bar: 1); valid but thros inside the generated code because its not double.