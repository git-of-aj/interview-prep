## 1
### **Definition of Clustered Index in MS SQL**  
A **clustered index** in MS SQL Server is an index that determines the **physical order of data in a table**. There can be only **one clustered index per table** because the rows can be stored in only one order. The primary key of a table is automatically assigned as a clustered index unless specified otherwise.

### **Layman Explanation (Simple Example)**  
Think of a **clustered index** like a **phonebook**:  
- The names (data) are stored **in alphabetical order** (this is the clustered index).  
- If you search for "John Doe," you can directly go to the correct page without scanning the whole book.  
- Since the phonebook is already sorted, no separate index is needed—it is **physically arranged** in a meaningful order.

Similarly, in a SQL table with a **clustered index**, the data is **physically sorted** based on that index, making searches faster when querying by the indexed column.

## 2
The SQL query in the image is:

```sql
Select co.*
from CourseOfferings co
WHERE NOT EXISTS
(SELECT 1 FROM CourseEnrollments ce WHERE co.CourseOfferingId = ce.CourseOfferingId)
AND co.TermCode = 'SP2016'
```

### **Explanation:**
- This query retrieves all columns (`co.*`) from the `CourseOfferings` table.
- It uses a **NOT EXISTS** subquery to check if there are **no matching enrollments** in the `CourseEnrollments` table.
- The subquery:
  - Selects `1` (a simple constant value for efficiency) from `CourseEnrollments`.
  - It checks if there is any `CourseEnrollment` record where `co.CourseOfferingId = ce.CourseOfferingId`.
  - If no matching `CourseOfferingId` exists in `CourseEnrollments`, the course is considered **not enrolled by any student**.
- The `AND co.TermCode = 'SP2016'` filter ensures that **only courses from the Spring 2016 (SP2016) term** are considered.

### **Purpose of the Query:**
This query **finds all courses offered in Spring 2016 that have no student enrollments**, similar to the **LEFT JOIN with IS NULL** approach but using `NOT EXISTS`.

### **Comparison with LEFT JOIN Approach:**
1. **`LEFT JOIN ... WHERE ce.CourseOfferingId IS NULL` (Previous Image Query)**  
   - Retrieves unmatched `CourseOfferings` by checking for `NULL` values in `CourseEnrollments`.
   - Can be **slower** if there are many records, as it scans the entire `CourseEnrollments` table.

2. **`NOT EXISTS (Subquery)` (Current Query)**  
   - Stops checking as soon as a match is found, making it **more efficient** for large datasets.
   - Preferred in cases where `CourseEnrollments` has a **large number of records**.
