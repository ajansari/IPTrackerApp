#!/usr/bin/env python3
"""Pre-flight validation for the IP Tracking PTE (runbook Step 05 deliverable).

Run BEFORE compiling each batch (Step 06 action 3). Every rule here encodes either a
Standards requirement or a defect found at Step 04 (see docs/SanityCheck.md).

    python3 scripts/preflight.py                 # validate every .al file under src/
    python3 scripts/preflight.py src/Enums       # validate a subtree (i.e. one batch)
    python3 scripts/preflight.py --list-rules

Exit status 0 = clean, 1 = at least one FAIL.
"""
from __future__ import annotations
import io, json, os, re, sys, zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ---------------------------------------------------------------- Parameters
# Derived from TDD §1 (Project Parameters). Never hardcode elsewhere.
PARAM = {
    "namespace":      "OnlyCopilotFans.IPTracking",
    "object_prefix":  "ocpf ",
    "permset_prefix": "OCPF - ",
    "id_from":        80300,
    "id_to":          80339,
    "api_publisher":  "ocpf",
    "api_group":      "ocpfIpManagement",
    "api_version":    "v1.0",
    "localization":   "W1",
}
MAX_IDENT = 30          # objects, fields, enum values, entity/set names
MAX_IDENT_PERMSET = 20  # SC-01: permissionset identifiers cap at 20, not 30 (AL0305)

OBJ_KINDS = {"enum": "Enum", "table": "Table", "page": "Page",
             "codeunit": "Codeunit", "permissionset": "PermissionSet",
             "query": "Query", "report": "Report", "xmlport": "XmlPort",
             "interface": "Interface", "tableextension": "TableExt",
             "pageextension": "PageExt", "reportextension": "ReportExt",
             "enumextension": "EnumExt"}

RESERVED = {
    "and","array","asserterror","begin","break","case","codeunit","const","div","do","downto",
    "else","end","enum","event","exit","false","for","foreach","function","if","implements","in",
    "interface","internal","label","local","mod","not","of","or","page","pragma","procedure",
    "protected","query","record","repeat","report","table","temporary","then","to","trigger",
    "true","until","var","while","with","xmlport",
}

# ------------------------------------------------------------- Symbol lookup
_SYMBOL_CACHE = os.path.join(ROOT, "scripts", ".symbolcache.json")

def symbol_index() -> dict:
    """{'tables': {name: {'id':, 'ns':, 'fields': {fname: {'id':,'obsolete':}}}}, 'namespaces': [...]}"""
    if os.path.exists(_SYMBOL_CACHE):
        return json.load(open(_SYMBOL_CACHE))
    idx = {"tables": {}, "namespaces": []}
    pkgdir = os.path.join(ROOT, ".alpackages")
    for fn in sorted(os.listdir(pkgdir)):
        if not fn.endswith(".app"):
            continue
        raw = open(os.path.join(pkgdir, fn), "rb").read()[40:]   # strip navx header
        try:
            zf = zipfile.ZipFile(io.BytesIO(raw))
            data = json.loads(zf.read("SymbolReference.json").decode("utf-8-sig"))
        except Exception:
            continue
        def walk(node, ns):
            if ns:
                idx["namespaces"].append(ns)
            for t in (node.get("Tables") or []):
                props = {p["Name"]: p["Value"] for p in (t.get("Properties") or [])}
                fields = {}
                for f in (t.get("Fields") or []):
                    fp = {p["Name"]: p["Value"] for p in (f.get("Properties") or [])}
                    fields[f["Name"]] = {"id": f.get("Id"),
                                         "obsolete": fp.get("ObsoleteState", "No")}
                idx["tables"][t["Name"]] = {"id": t.get("Id"), "ns": ns,
                                            "obsolete": props.get("ObsoleteState", "No"),
                                            "fields": fields}
            for sub in (node.get("Namespaces") or []):
                walk(sub, (ns + "." if ns else "") + sub["Name"])
        walk(data, "")
    idx["namespaces"] = sorted(set(idx["namespaces"]))
    json.dump(idx, open(_SYMBOL_CACHE, "w"))
    return idx

# ------------------------------------------------------------------ Findings
class Report:
    def __init__(self):
        self.rows = []
    def fail(self, rule, path, line, msg):
        self.rows.append(("FAIL", rule, path, line, msg))
    def warn(self, rule, path, line, msg):
        self.rows.append(("WARN", rule, path, line, msg))
    @property
    def fails(self):
        return [r for r in self.rows if r[0] == "FAIL"]

RULES = {
 "FILE-01": "File name is <ObjectNameWithoutSpaces>.<Type>.al (CodeCop AA0215 / SC-06)",
 "FILE-02": "Exactly one top-level object per file",
 "FILE-03": "4-space indentation, no tabs (Standards §9.2)",
 "FILE-04": "No trailing whitespace; file ends with a newline",
 "NS-01":   "Exactly one namespace, equal to the Parameter 1.1 namespace",
 "NS-02":   "using statements alphabetically sorted (CodeCop AA0477 / SC-05)",
 "NS-03":   "Every using namespace exists in the symbol files (Operating Rule 2)",
 "ID-01":   "Object ID inside the allocated range (Parameter 1.2)",
 "ID-02":   "No duplicate object IDs",
 "NAME-01": "Object identifier <= 30 chars, or <= 20 for permissionset (SC-01 / AL0305)",
 "NAME-02": "Object name carries the Parameter 1.3 prefix",
 "NAME-03": "Field / enum-value identifier <= 30 chars",
 "NAME-04": "No unquoted reserved keyword used as an identifier",
 "TAB-01":  "Table declares DataClassification",
 "TAB-02":  "Every table field declares a Caption",
 "TAB-03":  "Every FlowField is Editable = false (Standards §4.2)",
 "PAGE-01": "Every non-API page field declares ApplicationArea and ToolTip",
 "PAGE-02": "API page declares APIPublisher/APIGroup/APIVersion/EntityName/EntitySetName/ODataKeyFields",
 "PAGE-03": "API page declares exactly one of DelayedInsert = true / Editable = false",
 "API-01":  "APIPublisher and APIGroup are camelCase (CodeCop AA0101 / SC-03)",
 "API-02":  "APIPublisher/APIGroup/APIVersion match Parameter 1.3",
 "CLEAN-01":"No // TODO and no commented-out field definitions (Standards §3.5)",
 "CLEAN-02":"No empty trigger or procedure bodies (Standards §3.5)",
 "SYM-01":  "Referenced standard table/field exists in the symbol file (Operating Rule 2)",
 "SYM-02":  "No referenced standard field is ObsoleteState Pending/Removed",
 "LOC-01":  "W1 build references no localization-range field (Standards Part 5)",
}

# -------------------------------------------------------------------- Checks
DECL_RE = re.compile(
    r'^(?P<kind>tableextension|pageextension|reportextension|enumextension|'
    r'enum|table|page|codeunit|permissionset|query|report|xmlport|interface)'
    r'\s+(?P<id>\d+)\s+(?P<name>"[^"]+"|\w+)', re.M)
FIELD_RE = re.compile(r'^\s{8}field\((?P<num>\w+);\s*(?P<name>"[^"]+"|\w+);', re.M)
# Must not require the declaration to end the line: `field(x; Rec.x) { ... }` on one line
# is legal AL and an end-anchored pattern skips it, silently passing an untooltipped field.
PAGEFIELD_RE = re.compile(r'^(?P<ind>\s+)field\((?P<name>"[^"]+"|\w+);\s*(?P<src>[^)]*)\)', re.M)
ENUMVAL_RE = re.compile(r'^\s+value\(\d+;\s*(?P<name>"[^"]+"|\w+)\)', re.M)
USING_RE = re.compile(r'^using\s+([\w.]+);', re.M)
# Property matcher. NOT anchored to line start: AL allows `{ Caption = 'x'; NotBlank = true; }`
# on one line, and an anchored pattern silently misses every single-line field block.
PROP_RE = lambda p: re.compile(r'(?<![\w.])' + p + r'\s*=\s*(?P<v>[^;]+);', re.M)

def unq(s: str) -> str:
    return s[1:-1] if s.startswith('"') else s

def block_of(text: str, start: int) -> str:
    """Return the {...} block that begins at/after `start`."""
    i = text.find("{", start)
    if i < 0:
        return ""
    depth, j = 0, i
    while j < len(text):
        if text[j] == "{":
            depth += 1
        elif text[j] == "}":
            depth -= 1
            if depth == 0:
                return text[i:j + 1]
        j += 1
    return text[i:]

def lineno(text: str, pos: int) -> int:
    return text.count("\n", 0, pos) + 1

def display_path(path: str) -> str:
    rel = os.path.relpath(path, ROOT)
    return path if rel.startswith("..") else rel

def check_file(path: str, rep: Report, seen_ids: dict, sym: dict):
    rel = display_path(path)
    text = open(path, encoding="utf-8").read()

    # ---- FILE-03 / FILE-04
    for n, ln in enumerate(text.splitlines(), 1):
        if "\t" in ln:
            rep.fail("FILE-03", rel, n, "tab character")
        stripped = len(ln) - len(ln.lstrip(" "))
        if ln.strip() and stripped % 4:
            rep.fail("FILE-03", rel, n, f"indent {stripped} is not a multiple of 4")
        if ln != ln.rstrip():
            rep.fail("FILE-04", rel, n, "trailing whitespace")
    if text and not text.endswith("\n"):
        rep.fail("FILE-04", rel, len(text.splitlines()), "no final newline")

    # ---- NS-01
    ns = re.findall(r'^namespace\s+([\w.]+);', text, re.M)
    if len(ns) != 1:
        rep.fail("NS-01", rel, 1, f"expected exactly 1 namespace, found {len(ns)}")
    elif ns[0] != PARAM["namespace"]:
        rep.fail("NS-01", rel, 1, f"namespace '{ns[0]}' != '{PARAM['namespace']}'")

    # ---- NS-02 / NS-03
    usings = USING_RE.findall(text)
    if usings != sorted(usings):
        rep.fail("NS-02", rel, 1, f"using not sorted: {usings} -> {sorted(usings)}")
    for u in usings:
        if u not in sym["namespaces"]:
            rep.fail("NS-03", rel, 1, f"namespace '{u}' not found in symbol files")

    # ---- CLEAN-01
    for n, ln in enumerate(text.splitlines(), 1):
        if re.search(r'//\s*TODO', ln, re.I):
            rep.fail("CLEAN-01", rel, n, "// TODO")
        if re.match(r'^\s*//\s*field\(', ln):
            rep.fail("CLEAN-01", rel, n, "commented-out field definition")
    # ---- CLEAN-02
    for m in re.finditer(r'(trigger\s+\w+\([^)]*\)|procedure\s+\w+\([^)]*\)[^\n]*)\s*\n\s*begin\s*\n\s*end;', text):
        rep.fail("CLEAN-02", rel, lineno(text, m.start()), "empty trigger/procedure body")

    # ---- declarations
    decls = list(DECL_RE.finditer(text))
    if len(decls) != 1:
        rep.fail("FILE-02", rel, 1, f"expected 1 top-level object, found {len(decls)}")
    for d in decls:
        kind, oid, name = d.group("kind"), int(d.group("id")), unq(d.group("name"))
        ln = lineno(text, d.start())
        body = block_of(text, d.end())

        # ---- FILE-01
        expected = f"{name.replace(' ', '').replace('-', '')}.{OBJ_KINDS[kind]}.al"
        if os.path.basename(path) != expected:
            rep.fail("FILE-01", rel, ln, f"file should be named '{expected}'")

        # ---- ID-01 / ID-02
        if not (PARAM["id_from"] <= oid <= PARAM["id_to"]):
            rep.fail("ID-01", rel, ln, f"id {oid} outside {PARAM['id_from']}-{PARAM['id_to']}")
        if oid in seen_ids:
            rep.fail("ID-02", rel, ln, f"id {oid} already used by {seen_ids[oid]}")
        seen_ids[oid] = rel

        # ---- NAME-01 / NAME-02
        limit = MAX_IDENT_PERMSET if kind == "permissionset" else MAX_IDENT
        if len(name) > limit:
            rep.fail("NAME-01", rel, ln,
                     f"{kind} name '{name}' is {len(name)} chars, limit {limit}")
        pref = PARAM["permset_prefix"] if kind == "permissionset" else PARAM["object_prefix"]
        if not name.startswith(pref):
            rep.fail("NAME-02", rel, ln, f"'{name}' does not start with '{pref}'")

        # ---- NAME-03 / NAME-04 (fields, enum values)
        idents = [(unq(m.group("name")), lineno(text, m.start()), m.group("name").startswith('"'))
                  for m in FIELD_RE.finditer(body)]
        idents += [(unq(m.group("name")), lineno(text, m.start()), m.group("name").startswith('"'))
                   for m in ENUMVAL_RE.finditer(body)]
        for ident, iln, quoted in idents:
            if len(ident) > MAX_IDENT:
                rep.fail("NAME-03", rel, iln, f"identifier '{ident}' is {len(ident)} chars")
            if not quoted and ident.lower() in RESERVED:
                rep.fail("NAME-04", rel, iln, f"reserved keyword '{ident}' unquoted")

        if kind == "table":
            check_table(rel, text, body, ln, rep, sym)
        elif kind == "page":
            check_page(rel, text, body, ln, rep)

def check_table(rel, text, body, ln, rep, sym):
    if not PROP_RE("DataClassification").search(body):
        rep.fail("TAB-01", rel, ln, "table has no DataClassification")
    for m in FIELD_RE.finditer(body):
        fname = unq(m.group("name"))
        fblock = block_of(body, m.end())
        fln = lineno(text, text.find(m.group(0)))
        if not PROP_RE("Caption").search(fblock):
            rep.fail("TAB-02", rel, fln, f"field \"{fname}\" has no Caption")
        if re.search(r'FieldClass\s*=\s*FlowField', fblock):
            ed = PROP_RE("Editable").search(fblock)
            if not ed or ed.group("v").strip().lower() != "false":
                rep.fail("TAB-03", rel, fln, f"FlowField \"{fname}\" is not Editable = false")
    check_symbols(rel, text, body, rep, sym)

def check_symbols(rel, text, body, rep, sym):
    """Validate every reference to a non-project (standard) table/field."""
    refs = set()
    for m in re.finditer(r'TableRelation\s*=\s*("?[\w .]+?"?)\.("[^"]+"|\w+)', body):
        refs.add((unq(m.group(1).strip()), unq(m.group(2)), lineno(text, m.start())))
    for m in re.finditer(r'CalcFormula\s*=\s*\w+\(("?[\w .]+?"?)\.("[^"]+"|\w+)', body):
        refs.add((unq(m.group(1).strip()), unq(m.group(2)), lineno(text, m.start())))
    for tname, fname, rln in refs:
        if tname.startswith(PARAM["object_prefix"].strip()):
            continue                                    # own object, compiler will check
        t = sym["tables"].get(tname)
        if not t:
            rep.fail("SYM-01", rel, rln, f"table '{tname}' not found in symbol files")
            continue
        f = t["fields"].get(fname)
        if not f:
            rep.fail("SYM-01", rel, rln, f"field '{tname}.{fname}' not found in symbol files")
            continue
        if f["obsolete"] in ("Pending", "Removed"):
            rep.fail("SYM-02", rel, rln,
                     f"'{tname}.{fname}' is ObsoleteState {f['obsolete']}")
        if PARAM["localization"] == "W1" and f["id"] and f["id"] >= 10000:
            rep.fail("LOC-01", rel, rln,
                     f"'{tname}.{fname}' id {f['id']} is a localization-range field; "
                     f"build is {PARAM['localization']}")

def check_page(rel, text, body, ln, rep):
    # Page-level properties live before `layout`. Searching the whole body would pick up
    # field-level Editable/Caption and misreport them as page properties.
    head = re.split(r'^\s*layout\b', body, maxsplit=1, flags=re.M)[0]
    ptype = PROP_RE("PageType").search(head)
    ptype = ptype.group("v").strip() if ptype else ""
    if ptype == "API":
        for p in ("APIPublisher", "APIGroup", "APIVersion", "EntityName",
                  "EntitySetName", "ODataKeyFields"):
            if not PROP_RE(p).search(head):
                rep.fail("PAGE-02", rel, ln, f"API page has no {p}")
        odk = PROP_RE("ODataKeyFields").search(head)
        if odk and odk.group("v").strip() != "SystemId":
            rep.fail("PAGE-02", rel, ln, "ODataKeyFields must be SystemId")
        di = PROP_RE("DelayedInsert").search(head)
        ed = PROP_RE("Editable").search(head)
        di_on = bool(di and di.group("v").strip().lower() == "true")
        ed_off = bool(ed and ed.group("v").strip().lower() == "false")
        if di_on == ed_off:
            rep.fail("PAGE-03", rel, ln,
                     "API page needs exactly one of DelayedInsert = true / Editable = false")
        for prop, want, rule in (("APIPublisher", PARAM["api_publisher"], "API-02"),
                                 ("APIGroup", PARAM["api_group"], "API-02"),
                                 ("APIVersion", PARAM["api_version"], "API-02")):
            m = PROP_RE(prop).search(head)
            if m:
                got = m.group("v").strip().strip("'")
                if got != want:
                    rep.fail(rule, rel, ln, f"{prop} '{got}' != Parameter 1.3 '{want}'")
                if prop in ("APIPublisher", "APIGroup"):
                    if not got or not got[0].islower() or "_" in got or got.isupper():
                        rep.fail("API-01", rel, ln, f"{prop} '{got}' is not camelCase")
        for prop in ("EntityName", "EntitySetName"):
            m = PROP_RE(prop).search(head)
            if m and len(m.group("v").strip().strip("'")) > MAX_IDENT:
                rep.fail("NAME-03", rel, ln, f"{prop} exceeds {MAX_IDENT} chars")
    else:
        for m in PAGEFIELD_RE.finditer(body):
            fblock = block_of(body, m.end())
            fln = lineno(text, text.find(m.group(0)))
            fname = unq(m.group("name"))
            if not PROP_RE("ApplicationArea").search(fblock):
                rep.fail("PAGE-01", rel, fln, f"page field '{fname}' has no ApplicationArea")
            if not PROP_RE("ToolTip").search(fblock):
                rep.fail("PAGE-01", rel, fln, f"page field '{fname}' has no ToolTip")

# --------------------------------------------------------------------- Main
def main(argv):
    if "--list-rules" in argv:
        for k, v in RULES.items():
            print(f"{k:9s} {v}")
        return 0
    targets = [a for a in argv[1:] if not a.startswith("-")] or [os.path.join(ROOT, "src")]
    files = []
    for t in targets:
        t = t if os.path.isabs(t) else os.path.join(ROOT, t)
        if os.path.isfile(t):
            files.append(t)
        else:
            for dirpath, _, names in os.walk(t):
                files += [os.path.join(dirpath, n) for n in names if n.endswith(".al")]
    files.sort()
    if not files:
        print("pre-flight: no .al files found — nothing to validate (scaffold is empty).")
        return 0
    sym = symbol_index()
    rep, seen = Report(), {}
    for f in files:
        check_file(f, rep, seen, sym)
    width = max((len(r[2]) for r in rep.rows), default=0)
    for sev, rule, path, line, msg in rep.rows:
        print(f"{sev}  {rule:9s} {path:{width}s}:{line:<4d} {msg}")
    print(f"\npre-flight: {len(files)} file(s), {len(RULES)} rules, "
          f"{len(rep.fails)} failure(s), {len(rep.rows) - len(rep.fails)} warning(s)")
    return 1 if rep.fails else 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))
