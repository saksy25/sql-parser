%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

struct Column {
    char name[50];
    char data_type[20];
};

struct Table {
    char name[50];
    struct Column columns[100];
    int column_count;
};

struct Table global_symbol_table[100];
int table_count = 0;
char current_table[50];  // Global variable to store the current table name

void add_table(const char *name);
int add_column_to_table(const char *table_name, const char *column_name, const char *data_type);
int drop_column_from_table(const char *table_name, const char *column_name);
int modify_column_in_table(const char *table_name, const char *column_name, const char *new_data_type);
int table_exists(const char *table_name);
int column_exists_in_table(const char *table_name, const char *column_name);
void check_and_print_drop_table(const char *table_name);
void check_and_truncate_tables(const char **table_names, int count);
void print_symbol_table();
void yyerror(const char *s);
int yylex();

%}

%union {
    char *strval;
    int ival;
}

%type <strval> alter_stmt alter_action
%type <strval> data_type

%token <strval> IDENTIFIER STRING
%token <ival> NUMBER
%token CREATE TABLE INT FLOAT CHAR VARCHAR DROP TRUNCATE ALTER ADD MODIFY COLUMN SEMICOLON

%%

// SQL statement parsing rules
sql_stmt:
    create_stmt { printf("Valid CREATE TABLE statement.\n"); print_symbol_table(); return 0; }
    | drop_stmt { printf("Valid DROP TABLE statement.\n"); print_symbol_table(); return 0; }
    | truncate_stmt { printf("Valid TRUNCATE TABLE statement.\n"); print_symbol_table(); return 0; }
    | alter_stmt SEMICOLON { printf("Valid ALTER TABLE statement.\n"); return 0; }

create_stmt:
    CREATE TABLE table_name '(' column_definitions ')' SEMICOLON {
        strcpy(current_table, "");  // Clear current_table after use
    }
    ;

table_name:
    IDENTIFIER {
        if (table_exists($1)) {
            printf("Error: Table '%s' already exists.\n", $1);
            YYABORT;
        } else {
            add_table($1);
            strcpy(current_table, $1);
        }
    }
    ;

column_definitions:
    column_definition
    | column_definitions ',' column_definition
    ;

column_definition:
    IDENTIFIER data_type {
        if (column_exists_in_table(current_table, $1)) {
            printf("Error: Column '%s' already exists in table '%s'.\n", $1, current_table);
        } else {
            add_column_to_table(current_table, $1, $2);
        }
    }
    ;

data_type:
    INT { $$ = strdup("INT"); }
    | VARCHAR '(' NUMBER ')' { $$ = strdup("VARCHAR"); }
    | FLOAT { $$ = strdup("FLOAT"); }
    | CHAR '(' NUMBER ')' { $$ = strdup("CHAR"); }
    ;

drop_stmt:
    DROP TABLE IDENTIFIER SEMICOLON {
        check_and_print_drop_table($3);
    }
    ;

truncate_stmt:
    TRUNCATE TABLE table_list SEMICOLON
    ;

table_list:
    IDENTIFIER {
        const char *table_array[1] = { $1 };
        check_and_truncate_tables(table_array, 1);
    }
    | IDENTIFIER ',' table_list {
        const char *table_array[100];  // Assuming max 100 tables in table_list
        int i = 0;
        table_array[i++] = $1;
        check_and_truncate_tables(table_array, i);
    }
    ;

alter_stmt:
    ALTER TABLE IDENTIFIER alter_action {
        if (table_exists($3)) {
            $$ = $3;
            printf("Valid ALTER TABLE query on table '%s'.\n", $3);
        } else {
            printf("Error: Table '%s' does not exist.\n", $3);
            YYABORT;
        }
    }
    ;

alter_action:
    ADD COLUMN IDENTIFIER data_type {
        // Call add_column_to_table and check the return value
        if (add_column_to_table($$, $3, $4) != 0) {
            // Column already exists, abort parsing
            YYABORT;  
        } else {
            // Success message
            printf("Valid ALTER TABLE ADD COLUMN query. Column '%s' added to table '%s'.\n", $3, $$);
            print_symbol_table();  // Print the updated symbol table for verification
        }
    }
    | DROP COLUMN IDENTIFIER {
        // Call drop_column_from_table and check the return value
        if (drop_column_from_table($$, $3) != 0) {
            // Column doesn't exist, abort parsing
            printf("Error: Column '%s' does not exist in table '%s'.\n", $3, $$);
            YYABORT;
        } else {
            // Success message
            printf("Valid ALTER TABLE DROP COLUMN query. Column '%s' dropped from table '%s'.\n", $3, $$);
            print_symbol_table();  // Print the updated symbol table for verification
        }
    }
    | MODIFY COLUMN IDENTIFIER data_type {
        if (modify_column_in_table($$, $3, $4) != 0) {
            YYABORT;
        } else {
            printf("Column '%s' in table '%s' modified to data type '%s'.\n", $3, $$, $4);
            print_symbol_table();
        }
    }
    ;

%%

// Function definitions

void add_table(const char *name) {
    strcpy(global_symbol_table[table_count].name, name);
    global_symbol_table[table_count].column_count = 0;
    table_count++;
}

int add_column_to_table(const char *table_name, const char *column_name, const char *data_type) {
    // Loop through the symbol table to find the table
    for (int i = 0; i < table_count; i++) {
        if (strcmp(global_symbol_table[i].name, table_name) == 0) {
            // Ensure the column doesn't already exist (secondary check)
            for (int j = 0; j < global_symbol_table[i].column_count; j++) {
                if (strcmp(global_symbol_table[i].columns[j].name, column_name) == 0) {
                    printf("Error: Column '%s' already exists in table '%s'.\n", column_name, table_name);
                    return 1;  // Indicate error (column already exists)
                }
            }

            // Add the column since it doesn't exist
            int col_count = global_symbol_table[i].column_count;
            strcpy(global_symbol_table[i].columns[col_count].name, column_name);
            strcpy(global_symbol_table[i].columns[col_count].data_type, data_type);
            global_symbol_table[i].column_count++;
            return 0;  // Indicate success
        }
    }
    return 1;  // Indicate error (table not found)
}

int drop_column_from_table(const char *table_name, const char *column_name) {
    for (int i = 0; i < table_count; i++) {
        if (strcmp(global_symbol_table[i].name, table_name) == 0) {
            for (int j = 0; j < global_symbol_table[i].column_count; j++) {
                if (strcmp(global_symbol_table[i].columns[j].name, column_name) == 0) {
                    // Shift columns to "remove" the target column
                    for (int k = j; k < global_symbol_table[i].column_count - 1; k++) {
                        global_symbol_table[i].columns[k] = global_symbol_table[i].columns[k + 1];
                    }
                    global_symbol_table[i].column_count--;
                    return 0;  // Indicate success
                }
            }
        }
    }
    return 1;
}

int modify_column_in_table(const char *table_name, const char *column_name, const char *new_data_type) {
    for (int i = 0; i < table_count; i++) {
        if (strcmp(global_symbol_table[i].name, table_name) == 0) {
            for (int j = 0; j < global_symbol_table[i].column_count; j++) {
                if (strcmp(global_symbol_table[i].columns[j].name, column_name) == 0) {
                    if (strcmp(global_symbol_table[i].columns[j].data_type, new_data_type) == 0) {
                        // If column already exists with the same data type
                        printf("Error: Column '%s' in table '%s' already has data type '%s'.\n", column_name, table_name, new_data_type);
                        return 1;
                    } else {
                        // Modify the column only if the data type is different
                        strcpy(global_symbol_table[i].columns[j].data_type, new_data_type);
                        printf("Column '%s' in table '%s' has been modified to data type '%s'.\n", column_name, table_name, new_data_type);
                        return 0;
                    }
                }
            }
            printf("Error: Column '%s' does not exist in table '%s'.\n", column_name, table_name);
            return 1;
        }
    }
    return 1;
}

int table_exists(const char *table_name) {
    for (int i = 0; i < table_count; i++) {
        if (strcmp(global_symbol_table[i].name, table_name) == 0) {
            return 1;
        }
    }
    return 0;
}

int column_exists_in_table(const char *table_name, const char *column_name) {
    for (int i = 0; i < table_count; i++) {
        if (strcmp(global_symbol_table[i].name, table_name) == 0) {
            for (int j = 0; j < global_symbol_table[i].column_count; j++) {
                if (strcmp(global_symbol_table[i].columns[j].name, column_name) == 0) {
                    return 1;
                }
            }
        }
    }
    return 0;
}

// Function to check if the specified table exists and print appropriate message
void check_and_print_drop_table(const char *table_name) {
    for (int i = 0; i < table_count; i++) {
        if (strcmp(global_symbol_table[i].name, table_name) == 0) {
            printf("Table '%s' exists in database.\n", table_name);

            // Remove table by shifting all subsequent tables in the symbol table array
            for (int j = i; j < table_count - 1; j++) {
                global_symbol_table[j] = global_symbol_table[j + 1];
            }
            table_count--;
            return;
        }
    }
    printf("Error: Table '%s' does not exist in the database.\n", table_name);
    exit(EXIT_FAILURE);  // Exit the program if the table doesn't exist
}

// Function to check if all tables exist and truncate them
void check_and_truncate_tables(const char **table_names, int count) {
    for (int i = 0; i < count; i++) {
        int found = 0;
        for (int j = 0; j < table_count; j++) {
            if (strcmp(global_symbol_table[j].name, table_names[i]) == 0) {
                // Clear columns but keep the table
                global_symbol_table[j].column_count = 0;
                found = 1;
                break;
            }
        }
        if (!found) {
            printf("Error: Table '%s' does not exist in the database.\n", table_names[i]);
            exit(EXIT_FAILURE);  // Exit the program if the table doesn't exist
        }
    }
    printf("Valid TRUNCATE TABLE query.\n");
}

void print_symbol_table() {
    printf("\nSymbol Table:\n");
    printf("%-15s%-15s%-15s\n", "Table Name", "Column Name", "Data Type");
    printf("--------------------------------------------\n");
    for (int i = 0; i < table_count; i++) {
        printf("Table: %-15s\n", global_symbol_table[i].name);
        for (int j = 0; j < global_symbol_table[i].column_count; j++) {
            printf("%-15s%-15s%-15s\n", "", global_symbol_table[i].columns[j].name, global_symbol_table[i].columns[j].data_type);
        }
    }
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    while (1) {
        printf("Enter SQL command: ");
        if (yyparse() == 0) {
            continue;  // If no errors, prompt for another command
        } else {
            break;  // If there's an error, stop execution
        }
    }
    return 0;
}
