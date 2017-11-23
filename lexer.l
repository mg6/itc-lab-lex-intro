/* read only single input file */
%option noyywrap


%{

#include <stdlib.h> 
#include <string.h>

YY_BUFFER_STATE fbuf_stack[10];
int fbuf_idx = 0;

char buf[100];
char *s;

int count_include = 0
  , count_paragraph = 0
  , count_word = 0
  , count_sentence = 0
  , sentence_started = 0;

void report_counts() {
  fprintf(stderr, "Counts: files=%d paragraphs=%d words=%d sentences=%d\n",
    count_include + 1,
    count_paragraph,
    count_word,
    count_sentence);
}

%}


%x CMD_SELECT
%x CMD_INCLUDE
%x CMD_ENVIRON

NL        (\r?\n)
WORD      [a-zA-Z0-9]+
SENTENCE  [^.\r\n]+
FOOTNOTE  \.\[[^]]+\]
FULLSTOP  [.\r\n]+

%%

%.*     ;

{NL}+   ; /* discard preceding newlines */
[^\\]   {
          if (count_paragraph < 1) ++count_paragraph;
          REJECT;
        }
{NL}{2,}[^\\] {
          ++count_paragraph;
          REJECT;
        }

\\      BEGIN(CMD_SELECT);

{SENTENCE} {
          if (!sentence_started) {
            sentence_started = 1;
            ++count_sentence;
          }
          REJECT;
        }
{FOOTNOTE} {
          --count_sentence;
          REJECT;
        }
{FULLSTOP} {
          sentence_started = 0;
          REJECT;
        }
{WORD}  {
          ++count_word;
        }
.       ECHO;

<<EOF>> {
          if (fbuf_idx == 0) {
            report_counts();
            yyterminate();
          }
          else {
            yy_delete_buffer(YY_CURRENT_BUFFER);
            yy_switch_to_buffer(fbuf_stack[--fbuf_idx]);
          }
        }

<CMD_SELECT>{

include\{ BEGIN(CMD_INCLUDE); s = buf;
begin\{   BEGIN(CMD_ENVIRON);

}

<CMD_INCLUDE>{

\} {
        *s = 0;
        ++count_include;
        BEGIN(INITIAL);
        fbuf_stack[fbuf_idx++] = YY_CURRENT_BUFFER;
        yyin = fopen(buf, "r");
        yy_switch_to_buffer(yy_create_buffer(yyin, YY_BUF_SIZE));
}
.       *s++ = yytext[0];

}

<CMD_ENVIRON>{

\\end\{[^}]+\}  BEGIN(INITIAL);
.|\n    ;

}

%%


int main(int argc, char **argv)
{
  ++argv, --argc;

  if (argc > 0) {
    if (strcmp(argv[0], "-") == 0) {
      yyin = stdin;
    }
    else {
      yyin = fopen(argv[0], "r");
    }
  }
  else {
    // open default file
    yyin = fopen("p.tex", "r");
  }

  yylex();
  return 0;
}
