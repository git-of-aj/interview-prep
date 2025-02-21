### stored procedure vs views
- A view does not store data. Every time you query a view, the SQL engine executes the underlying query in the view. For complex queries, this can result in repeated computations, especially if the view contains joins or aggregations.
- A stored procedure is compiled and cached after its first execution, which means repeated calls to the stored procedure are faster than querying a view. It does not need to recompile the SQL each time it’s run.
- but stored procedures can also use control flow statements, such as IF, WHILE, or CASE. 
1. If you need simple, reusable queries (without logic), views are a good choice.
2. If you need complex logic, data manipulation, or performance optimization (especially for repetitive tasks), stored procedures are more efficient.

In summary, while stored procedures without parameters might return similar results to a view, they are more flexible and offer better performance for complex scenarios.
