### [views](https://learn.microsoft.com/en-us/sql/relational-databases/views/views?view=sql-server-ver16)
- A view is a virtual table whose contents are fed into it by `your query`. The rows and columns of data come from tables referenced in the query
- Just like a Normal table, it has rows & columns.
- The query that defines the view can be from `one or more tables` or from other views in the `current or other databases`. Like kinda dashboard to see monthly sales from every where.
- Views can be used as security mechanisms by letting users access data through the view, without granting users permissions to directly access the underlying tables of the query.
- provide a backward compatible interface to emulate a table that used to exist but whose schema has changed. 
### Stored Procedure
its like functions in programming language (define input, output, logic etc)
### stored procedure vs views
- A view does not store data. Every time you query a view, the SQL engine executes the underlying query in the view. For complex queries, this can result in repeated computations, especially if the view contains joins or aggregations.
- A stored procedure is compiled and cached after its first execution, which means repeated calls to the stored procedure are faster than querying a view. It does not need to recompile the SQL each time it’s run.
- but stored procedures can also use control flow statements, such as IF, WHILE, or CASE. 
1. If you need simple, reusable queries (without logic), views are a good choice.
2. If you need complex logic, data manipulation, or performance optimization (especially for repetitive tasks), stored procedures are more efficient.

In summary, while stored procedures without parameters might return similar results to a view, they are more flexible and offer better performance for complex scenarios.
