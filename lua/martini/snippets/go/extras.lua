-- =========================================================
-- lua/martini/snippets/go/extras.lua
-- Snippets Go que NÃO existem no friendly-snippets nem nos snippets
-- próprios (iferr, forr, main, test, struct). Inclui gof e fni
-- (antes em goroutine.lua). Foco: concorrência,
-- erros, context, HTTP/JSON e testes.
-- Sintaxe: $1, $2 = pontos de parada (Ctrl+j avança); ${1:texto} =
-- valor padrão; $0 = onde o cursor termina; o mesmo número repetido
-- espelha o texto digitado.
-- =========================================================
local ls = require("luasnip")
local p = ls.parser.parse_snippet

return {
  -- ── Concorrência ─────────────────────────────────────────
  p(
    { trig = "gof", dscr = "go func() { ... }()" },
    [[
go func() {
	$0
}()]]
  ),

  p(
    { trig = "fni", dscr = "func() { ... }() (anônima, chamada na hora)" },
    [[
func() {
	$0
}()]]
  ),

  p(
    { trig = "wg", dscr = "WaitGroup: lançar N goroutines e esperar" },
    [[
var wg sync.WaitGroup
for i := 0; i < ${1:n}; i++ {
	wg.Add(1)
	go func() {
		defer wg.Done()
		$0
	}()
}
wg.Wait()]]
  ),

  p(
    { trig = "lock", dscr = "Mutex: Lock + defer Unlock" },
    [[
${1:mu}.Lock()
defer $1.Unlock()
$0]]
  ),

  p(
    { trig = "once", dscr = "sync.Once" },
    [[
var once sync.Once
once.Do(func() {
	$0
})]]
  ),

  p(
    { trig = "prod", dscr = "Produtor: canal preenchido por goroutine, fechado no fim" },
    [[
${1:ch} := make(chan ${2:int})
go func() {
	defer close($1)
	for i := 0; i < ${3:10}; i++ {
		$1 <- i
	}
}()
$0]]
  ),

  p(
    { trig = "selt", dscr = "select com timeout (time.After)" },
    [[
select {
case ${1:v} := <-${2:ch}:
	$3
case <-time.After(${4:time.Second}):
	$0
}]]
  ),

  p(
    { trig = "selc", dscr = "select com ctx.Done()" },
    [[
select {
case <-ctx.Done():
	return ctx.Err()
case ${1:v} := <-${2:ch}:
	$0
}]]
  ),

  p(
    { trig = "tick", dscr = "Ticker: repetir a cada intervalo" },
    [[
ticker := time.NewTicker(${1:time.Second})
defer ticker.Stop()
for range ticker.C {
	$0
}]]
  ),

  p(
    { trig = "deff", dscr = "defer func() { ... }()" },
    [[
defer func() {
	$0
}()]]
  ),

  p(
    { trig = "rec", dscr = "defer + recover de panic" },
    [[
defer func() {
	if r := recover(); r != nil {
		${1:fmt.Println("recuperado:", r)}
	}
}()
$0]]
  ),

  -- ── Context ──────────────────────────────────────────────
  p(
    { trig = "ctxt", dscr = "context.WithTimeout + defer cancel" },
    [[
ctx, cancel := context.WithTimeout(${1:context.Background()}, ${2:time.Second})
defer cancel()
$0]]
  ),

  p(
    { trig = "ctxc", dscr = "context.WithCancel + defer cancel" },
    [[
ctx, cancel := context.WithCancel(${1:context.Background()})
defer cancel()
$0]]
  ),

  -- ── Erros ────────────────────────────────────────────────
  p(
    { trig = "errw", dscr = "fmt.Errorf com %w (embrulhar erro)" },
    [[
fmt.Errorf("${1:contexto}: %w", ${2:err})]]
  ),

  p(
    { trig = "erris", dscr = "errors.Is" },
    [[
if errors.Is(${1:err}, ${2:ErrNome}) {
	$0
}]]
  ),

  p(
    { trig = "erras", dscr = "errors.As" },
    [[
var ${1:alvo} *${2:MeuErro}
if errors.As(${3:err}, &$1) {
	$0
}]]
  ),

  p(
    { trig = "errnew", dscr = "Erro sentinela: var ErrX = errors.New" },
    [[
var Err${1:Nome} = errors.New("${2:mensagem}")]]
  ),

  p(
    { trig = "errt", dscr = "Tipo de erro próprio com método Error()" },
    [[
type ${1:MeuErro} struct {
	${2:Msg} string
}

func (e *$1) Error() string {
	return e.$2
}]]
  ),

  -- ── Entrada / saída ──────────────────────────────────────
  p(
    { trig = "scanl", dscr = "bufio.Scanner lendo linha a linha" },
    [[
scanner := bufio.NewScanner(${1:os.Stdin})
for scanner.Scan() {
	linha := scanner.Text()
	$0
}
if err := scanner.Err(); err != nil {
	${2:return err}
}]]
  ),

  p(
    { trig = "tempo", dscr = "Medir tempo de execução" },
    [[
inicio := time.Now()
$0
fmt.Println("tempo:", time.Since(inicio))]]
  ),

  -- ── HTTP / JSON ──────────────────────────────────────────
  p(
    { trig = "jsonw", dscr = "Responder JSON em handler HTTP" },
    [[
w.Header().Set("Content-Type", "application/json")
if err := json.NewEncoder(w).Encode(${1:dados}); err != nil {
	http.Error(w, err.Error(), http.StatusInternalServerError)
}]]
  ),

  p(
    { trig = "jsonr", dscr = "Ler JSON do corpo da requisição" },
    [[
var ${1:dados} ${2:Tipo}
if err := json.NewDecoder(r.Body).Decode(&$1); err != nil {
	http.Error(w, err.Error(), http.StatusBadRequest)
	return
}
$0]]
  ),

  -- ── Testes ───────────────────────────────────────────────
  p(
    { trig = "subt", dscr = "Subteste: t.Run" },
    [[
t.Run("${1:nome}", func(t *testing.T) {
	$0
})]]
  ),

  -- ── Linguagem ────────────────────────────────────────────
  p(
    { trig = "swt", dscr = "Type switch" },
    [[
switch v := ${1:x}.(type) {
case ${2:int}:
	$0
default:
	_ = v
}]]
  ),

  p(
    { trig = "gen", dscr = "Função genérica" },
    [[
func ${1:Nome}[${2:T} ${3:any}](${4:x} $2) ${5:$2} {
	$0
}]]
  ),

  p(
    { trig = "strr", dscr = "Método String() (fmt.Stringer)" },
    [[
func (${1:t} ${2:Tipo}) String() string {
	return $0
}]]
  ),

  p(
    { trig = "rint", dscr = "for i := range N (Go 1.22+)" },
    [[
for ${1:i} := range ${2:10} {
	$0
}]]
  ),
}
