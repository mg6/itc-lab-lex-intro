# Lex Intro

An assignment for Introduction to Compilers university course.

## Description

In LaTeX files, it is possible to join many files using `\include{path}` command. Write a program, which will calculate statistics concerning:
- number of used files
- number of typed words
- number of typed sentences
- number of paragraphs (in LaTeX, two or more consecutive end of lines in file correspond to a new paragraph)

Additional constraints:
- the program should not count statistics in comment region. The comment starts after `%` symbol and finishes with the end of line.
- the program should also omit text inside commands:
```tex
\begin{any letter}
here you may find almost all possible signs.
\end{any letter}
```

- the program should not print out anything, except the statistics after processing all files.

## License

See LICENSE file for information.
