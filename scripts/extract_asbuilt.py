#!/usr/bin/env python3
"""Extract as-built object/field/relationship facts from src/ for Steps 11-12.
Generated from the code, never from memory (runbook Step 12 action 1)."""
import re, glob, json, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
objs = []

DECL = re.compile(r'^(tableextension|pageextension|table|page|enum|permissionset)\s+(\d+)\s+"([^"]+)"(?:\s+extends\s+"?([\w .]+?)"?)?\s*$', re.M)

for path in sorted(glob.glob(os.path.join(ROOT, "src/**/*.al"), recursive=True)):
    txt = open(path).read()
    m = DECL.search(txt)
    if not m: continue
    kind, oid, name, ext = m.group(1), int(m.group(2)), m.group(3), m.group(4)
    o = {"id": oid, "kind": kind, "name": name, "extends": ext,
         "file": os.path.relpath(path, ROOT), "props": {}, "fields": [], "relations": []}
    head = txt[:txt.find("fields") if "fields" in txt else len(txt)]
    for p in ("PageType","SourceTable","UsageCategory","CardPageId","DelayedInsert","ODataKeyFields",
              "APIPublisher","APIGroup","APIVersion","EntityName","EntitySetName","Caption",
              "DataClassification","LookupPageId","DrillDownPageId","InsertAllowed","DeleteAllowed","Extensible"):
        v = re.search(rf'^\s*{p} = ([^;]+);', head, re.M)
        if v: o["props"][p] = v.group(1).strip().strip("'\"")

    if kind in ("table","tableextension"):
        for fm in re.finditer(r'field\((\d+); "([^"]+)"; ([^)]+)\)\s*\{(.*?)\n        \}', txt, re.S):
            fid, fname, ftype, body = int(fm.group(1)), fm.group(2), fm.group(3).strip(), fm.group(4)
            f = {"id": fid, "name": fname, "type": ftype}
            for fp in ("Caption","FieldClass","Editable","NotBlank","MinValue","InitValue","AutoIncrement","DataClassification"):
                v = re.search(rf'{fp} = ([^;]+);', body)
                if v: f[fp] = v.group(1).strip().strip("'")
            tr = re.search(r'TableRelation = ([^;]+);', body)
            if tr:
                f["TableRelation"] = " ".join(tr.group(1).split())
                o["relations"].append({"field": fname, "to": f["TableRelation"]})
            cf = re.search(r'CalcFormula = ([^;]+);', body)
            if cf: f["CalcFormula"] = " ".join(cf.group(1).split())
            o["fields"].append(f)

    if kind == "page" and o["props"].get("PageType") == "API":
        for fm in re.finditer(r'field\((\w+); Rec\.("([^"]+)"|\w+)\)\s*\{(.*?)\n\s{16}\}', txt, re.S):
            api_id, src = fm.group(1), (fm.group(3) or fm.group(2))
            body = fm.group(4)
            cap = re.search(r"Caption = '([^']*)'", body)
            ed = re.search(r'Editable = (\w+);', body)
            o["fields"].append({"api": api_id, "source": src,
                                "caption": cap.group(1) if cap else "",
                                "writable": not (ed and ed.group(1) == "false")})
    if kind == "enum":
        for vm in re.finditer(r'value\((\d+); ("([^"]+)"|\w+)\)\s*\{\s*Caption = \'([^\']*)\';', txt):
            o["fields"].append({"ordinal": int(vm.group(1)),
                                "value": vm.group(3) or vm.group(2), "caption": vm.group(4)})
    if kind == "permissionset":
        o["fields"] = [{"grant": g} for g in re.findall(r'tabledata "([^"]+)" = (\w+)', txt)]
    objs.append(o)

json.dump(objs, open(os.path.join(ROOT, "scripts/.asbuilt.json"), "w"), indent=1)
print(f"extracted {len(objs)} objects")
for k in ("table","tableextension","page","pageextension","enum","permissionset"):
    n = [o for o in objs if o["kind"]==k]
    print(f"  {k:<15} {len(n)}")
