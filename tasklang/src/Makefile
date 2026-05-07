# Makefile for TaskLang++

CC     = gcc
CFLAGS = -Wall -g
TARGET = tasklang
LIBS   = -lfl

.PHONY: all test clean

all: $(TARGET)

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

$(TARGET): parser.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $(TARGET) parser.tab.c lex.yy.c $(LIBS)
	@echo "Build successful! Binary: ./$(TARGET)"

test: $(TARGET)
	@echo ""; echo "===== TEST 1: Simple Daily Schedule (valid) ====="
	./$(TARGET) ../tests/test1_daily_schedule.tl
	@echo ""; echo "===== TEST 2: Conditional Workflow (valid) ====="
	./$(TARGET) ../tests/test2_conditional_workflow.tl
	@echo ""; echo "===== TEST 3: Task Dependencies Chain (valid) ====="
	./$(TARGET) ../tests/test3_dependencies.tl
	@echo ""; echo "===== TEST 4: Circular Dependency (semantic error) ====="
	./$(TARGET) ../tests/test4_circular_dependency.tl
	@echo ""; echo "===== TEST 5: Syntax Error (missing semicolons) ====="
	./$(TARGET) ../tests/test5_syntax_error.tl
	@echo ""; echo "===== TEST 6: Weekly Schedule + Retry/Timeout (valid) ====="
	./$(TARGET) ../tests/test6_weekly_retry.tl

clean:
	rm -f lex.yy.c parser.tab.c parser.tab.h $(TARGET)
	@echo "Cleaned."

