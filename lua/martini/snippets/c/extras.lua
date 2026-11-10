-- =========================================================
-- lua/martini/snippets/c/extras.lua
-- Snippets de C que NÃO existem no friendly-snippets (esses usam
-- gatilhos como "main", "for", "if" — os daqui têm nomes próprios,
-- pra não duplicar na lista). Foco: estrutura do programa, entrada
-- e saída, repetição, funções/tipos, vetores, memória e arquivos.
-- Sintaxe: $1, $2 = pontos de parada (Ctrl+j avança); ${1:texto} =
-- valor padrão; $0 = onde o cursor termina; o mesmo número repetido
-- espelha o texto digitado. "\\n" no corpo = "\n" no código C.
-- =========================================================
local ls = require("luasnip")
local p = ls.parser.parse_snippet

return {

  -- ── Estrutura do programa ──
  p({ trig = "imain", dscr = "int main() { ... return 0; }" }, [[
int main() {
	$0
	return 0;
}]]),

  p({ trig = "prog", dscr = "programa completo: #include <stdio.h> + main" }, [[
#include <stdio.h>

int main() {
	$0
	return 0;
}]]),

  p({ trig = "imaina", dscr = "int main(int argc, char *argv[])" }, [[
int main(int argc, char *argv[]) {
	$0
	return 0;
}]]),

  p({ trig = "inc", dscr = "#include <...>" }, [[
#include <${1:stdio}.h>]]),

  p({ trig = "incl", dscr = "#include \"...\" (arquivo local)" }, [[
#include "${1:arquivo}.h"]]),

  p({ trig = "def", dscr = "#define NOME valor" }, [[
#define ${1:NOME} ${2:valor}]]),

  p({ trig = "guard", dscr = "header guard (#ifndef/#define/#endif)" }, [[
#ifndef ${1:NOME_H}
#define $1

$0

#endif /* $1 */]]),


  -- ── Entrada e saída ──
  p({ trig = "pf", dscr = "printf(\"...\\n\");" }, [[
printf("${1:texto}\\n");$0]]),

  p({ trig = "pfv", dscr = "printf(\"rótulo: %d\\n\", variável);" }, [[
printf("${1:texto}: %${2:d}\\n", ${3:variavel});$0]]),

  p({ trig = "sf", dscr = "scanf(\"%d\", &x);" }, [[
scanf("%${1:d}", &${2:variavel});$0]]),

  p({ trig = "lei", dscr = "ler um int: printf + scanf" }, [[
int ${1:n};
printf("${2:Digite um número}: ");
scanf("%d", &$1);$0]]),

  p({ trig = "lef", dscr = "ler um float: printf + scanf" }, [[
float ${1:x};
printf("${2:Digite um valor}: ");
scanf("%f", &$1);$0]]),

  p({ trig = "les", dscr = "ler uma linha de texto com fgets" }, [[
char ${1:s}[${2:100}];
printf("${3:Digite o texto}: ");
fgets($1, sizeof($1), stdin);
$1[strcspn($1, "\\n")] = '\\0';$0]]),


  -- ── Repetição e decisão ──
  p({ trig = "fori", dscr = "for (int i = 0; i < n; i++)" }, [[
for (int ${1:i} = 0; $1 < ${2:n}; $1++) {
	$0
}]]),

  p({ trig = "forr", dscr = "for decrescente (n até 1)" }, [[
for (int ${1:i} = ${2:n}; $1 >= ${3:1}; $1--) {
	$0
}]]),

  p({ trig = "forn", dscr = "dois for aninhados (linha/coluna)" }, [[
for (int ${1:i} = ${2:1}; $1 <= ${3:n}; $1++) {
	for (int ${4:j} = ${5:1}; $4 <= ${6:$1}; $4++) {
		$0
	}
}]]),

  p({ trig = "wh", dscr = "while (...) { ... }" }, [[
while (${1:condicao}) {
	$0
}]]),

  p({ trig = "dow", dscr = "do { ... } while (...);" }, [[
do {
	$0
} while (${1:condicao});]]),

  p({ trig = "ife", dscr = "if / else" }, [[
if (${1:condicao}) {
	$2
} else {
	$0
}]]),

  p({ trig = "sw", dscr = "switch com case, break e default" }, [[
switch (${1:variavel}) {
	case ${2:1}:
		$0
		break;
	default:
		break;
}]]),


  -- ── Funções e tipos ──
  p({ trig = "fn", dscr = "função: tipo nome(parâmetros) { ... }" }, [[
${1:int} ${2:nome}(${3:int a, int b}) {
	$0
}]]),

  p({ trig = "fnv", dscr = "função void" }, [[
void ${1:nome}(${2:void}) {
	$0
}]]),

  p({ trig = "swap", dscr = "função swap com ponteiros" }, [[
void swap(int *a, int *b) {
	int tmp = *a;
	*a = *b;
	*b = tmp;
}]]),

  p({ trig = "st", dscr = "typedef struct { ... } Nome;" }, [[
typedef struct {
	${2:int campo;}
	$0
} ${1:Nome};]]),

  p({ trig = "en", dscr = "typedef enum { ... } Nome;" }, [[
typedef enum {
	${2:VALOR_A},
	$0
} ${1:Nome};]]),


  -- ── Vetores, memória e arquivos ──
  p({ trig = "vec", dscr = "vetor + for para percorrer" }, [[
int ${1:v}[${2:10}];
for (int i = 0; i < $2; i++) {
	$0
}]]),

  p({ trig = "mat", dscr = "matriz: dois for percorrendo linhas e colunas" }, [[
int ${1:m}[${2:3}][${3:3}];
for (int i = 0; i < $2; i++) {
	for (int j = 0; j < $3; j++) {
		$0
	}
}]]),

  p({ trig = "mal", dscr = "malloc com checagem de NULL" }, [[
${1:int} *${2:p} = malloc(${3:n} * sizeof(*$2));
if ($2 == NULL) {
	fprintf(stderr, "erro: sem memória\\n");
	return 1;
}
$0]]),

  p({ trig = "fr", dscr = "free(p); p = NULL;" }, [[
free(${1:p});
$1 = NULL;$0]]),

  p({ trig = "fop", dscr = "fopen com checagem + fclose" }, [[
FILE *${1:f} = fopen("${2:arquivo.txt}", "${3:r}");
if ($1 == NULL) {
	perror("fopen");
	return 1;
}
$0
fclose($1);]]),

  p({ trig = "cmp", dscr = "comparador de int para qsort" }, [[
int ${1:comparar}(const void *a, const void *b) {
	return (*(const int *)a - *(const int *)b);
}]]),

}
