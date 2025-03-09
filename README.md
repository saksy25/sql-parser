# SQL Parser

A robust SQL DDL (Data Definition Language) command parser implemented using Lex and Bison that performs lexical, syntax, and semantic analysis on SQL commands.

## Overview

This project implements a parser for SQL DDL commands including CREATE TABLE, DROP TABLE, TRUNCATE TABLE, and ALTER TABLE. The parser validates the syntax and semantics of these commands while maintaining a symbol table to track database schema information.

## Features

- **Lexical Analysis**: Tokenizes SQL commands into meaningful components using Flex
- **Syntax Analysis**: Validates the structure of SQL queries against grammar rules using Bison
- **Semantic Analysis**: Ensures logical correctness by checking table and column existence
- **Symbol Table Management**: Maintains a database schema representation to track tables and columns
- **Support for DDL Commands**:
  - CREATE TABLE with column definitions
  - DROP TABLE for removing tables
  - TRUNCATE TABLE for clearing table contents
  - ALTER TABLE for adding, dropping, or modifying columns

## Project Structure

```
sql-parser/
├── lexer.l           # Flex file for lexical analysis
├── parser.y          # Bison file for grammar rules and semantic actions
├── README.md         # Project documentation
└── examples/         # Sample SQL queries for testing
```

## How It Works

1. **Lexical Analysis** (lexer.l): 
   - Defines patterns for SQL keywords, identifiers, and symbols
   - Converts input into tokens for the parser

2. **Syntax Analysis** (parser.y):
   - Defines grammar rules for SQL DDL commands
   - Includes semantic actions for schema validation

3. **Symbol Table**:
   - Tracks tables and their columns in memory
   - Used for semantic validation of queries

## Building the Project

### Prerequisites

- Flex (Fast Lexical Analyzer)
- Bison (Parser Generator)
- GCC (GNU Compiler Collection)

### Compilation

```bash
# Clone the repository
git clone https://github.com/yourusername/sql-parser.git
cd sql-parser

# run the commands
flex code.l
bison -dy code.y
gcc lex.yy.c y.tab.c -o code.exe
code.exe
```

## Usage

After compiling, run the executable and enter SQL DDL commands at the prompt:

```
Enter SQL command: CREATE TABLE students (id INT, name VARCHAR(50));
Valid CREATE TABLE statement.

Symbol Table:
Table Name      Column Name     Data Type      
--------------------------------------------
Table: students     
                id              INT           
                name            VARCHAR       
```

## Example Commands

### CREATE TABLE

```sql
CREATE TABLE employees (
    id INT,
    name VARCHAR(50),
    salary FLOAT
);
```

### DROP TABLE

```sql
DROP TABLE employees;
```

### TRUNCATE TABLE

```sql
TRUNCATE TABLE employees;
```

### ALTER TABLE

```sql
ALTER TABLE employees ADD COLUMN department VARCHAR(20);
ALTER TABLE employees DROP COLUMN salary;
ALTER TABLE employees MODIFY COLUMN name VARCHAR(100);
```

## Implementation Details

### Lexical Analysis

The lexer (implemented in `code.l`) recognizes:
- SQL keywords (CREATE, TABLE, INT, etc.)
- Identifiers (table and column names)
- Numbers, symbols, and delimiters

### Grammar Rules

The parser (implemented in `code.y`) contains grammar rules for:
- CREATE TABLE statements with column definitions
- DROP and TRUNCATE TABLE statements
- ALTER TABLE statements with different actions (ADD, DROP, MODIFY)

### Symbol Table

The symbol table maintains:
- Table names
- Column names and their data types
- Relationships between tables and columns

## Error Handling

The parser provides detailed error messages for:
- Lexical errors (invalid tokens)
- Syntax errors (malformed queries)
- Semantic errors (references to non-existent tables/columns)

## Future Enhancements

- Support for DML commands (INSERT, UPDATE, DELETE)
- Integration with actual database systems
- Advanced semantic validation (constraints, relationships)
- GUI for interactive query validation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Acknowledgments

- Developed as part of a Compiler Design project at Vishwakarma Institute of Technology, Pune, India
- Based on principles of compiler construction and SQL parsing techniques
