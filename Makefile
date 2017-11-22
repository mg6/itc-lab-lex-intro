all: lab

lex.yy.c: lexer.l
	lex $<

lab: lex.yy.c
	cc $< -o $@

clean:
	- rm lex.yy.c

.PHONY: all clean
