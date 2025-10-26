# Third Normal Form (3NF)
First Normal Form (1NF)
First normal form (1NF) is the simplest level of normalization. It involves ensuring that each table in the database has a primary key and that each column in the table contains atomic values. In other words, each row in the table should have a unique identifier, and each value in the table should be indivisible.

Let’s take an example to understand this better. Consider a table that stores information about employees. The table might have columns like employee_id, name, address, and phone_number. However, the address column could contain multiple values, like street name, city, state, and zip code.

Press enter or click to view image in full size

Example Table
To bring this table to 1NF, we need to split the address column into separate columns, each containing a single value.

Press enter or click to view image in full size

1NF Output
Second Normal Form (2NF)
Second normal form (2NF) builds on the foundation of 1NF and involves ensuring that each non-key column in a table is dependent on the primary key. In other words, there should be no partial dependencies in the table.

Let’s continue with our employee table example. Suppose we add a column for department to the table. If we find that the value in the department column is dependent on the employee_id and name columns, but not on the phone_number column, we need to split the table into two tables, one for employee information and one for department information.

Press enter or click to view image in full size

2NF Output
Third Normal Form (3NF)
Third normal form (3NF) builds on the foundation of 2NF and involves ensuring that each non-key column in a table is not transitively dependent on the primary key. In other words, there should be no transitive dependencies in the table.

Let’s take another example. Consider a table that stores information about books. The table might have columns like book_id, title, author, and publisher.

However, the publisher column could be dependent on the author column, rather than on the book_id column. To bring this table to 3NF, we need to split it into two tables, one for book information and one for author information.

Press enter or click to view image in full size

3NF Output

