/* read only single input file */
%option noyywrap


%{

#include <stdlib.h> 

YY_BUFFER_STATE fbuf_stack[10];
int fbuf_idx = 0;

char buf[100];
char *s;

%}


%x CMD_SELECT
%x CMD_INCLUDE
%x CMD_ENVIRON


%%

%.*     ;
\\      BEGIN(CMD_SELECT);
.       ECHO;
<<EOF>> {
          if (fbuf_idx == 0) {
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


int main()
{
  yyin = fopen("p.tex", "r");
  yylex();
  return 0;
}
