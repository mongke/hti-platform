#!/usr/bin/env python3
"""Convert the esukh team's 'Data preparation For Esukh.docx' into the canonical
columns-doc text that jobs/make_phase1.py --columns-doc already parses:

    tableName   (N columns)
    col, col, col

Only the UNCONDITIONAL part of each "Allowed to pass:" list is taken: anything
after the first ';' is a condition the team has not discharged ("after the
approved service/state fields are separated out"), so it is not an approval.
"""
import re, sys, zipfile, xml.etree.ElementTree as ET

W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
LABELS = ("Desc:", "Allowed to pass:", "Хасах", "Холбоос", "Тодруулах", "Нэмсэн")
# "tableName: (N columns)"  |  "NN. tableName (N columns)"
HDR = re.compile(r'^(?:\d+\.\s*)?([A-Za-z][A-Za-z0-9_]*)\s*:?\s*\((\d+)\s+columns?\)\s*$')
IDENT = re.compile(r'^[A-Za-z][A-Za-z0-9_]*$')

def paras(path):
    root = ET.fromstring(zipfile.ZipFile(path).read('word/document.xml'))
    for p in root.iter(f'{W}p'):
        t = ''.join(x.text or '' for x in p.iter(f'{W}t')).strip()
        if t:
            yield t

def main(src, dest):
    entries, cur, field, buf = [], None, None, []

    def flush():
        if cur and field == 'allow':
            cur['allow'] = ' '.join(buf)

    for line in paras(src):
        m = HDR.match(line)
        if m:
            flush()
            cur = {'table': m.group(1), 'declared': int(m.group(2)), 'allow': None}
            entries.append(cur)
            field, buf = None, []
            continue
        if cur is None:
            continue
        if line.startswith('Allowed to pass:'):
            flush()
            field, buf = 'allow', [line[len('Allowed to pass:'):].strip()]
            continue
        if any(line.startswith(l) for l in LABELS):
            flush()
            field, buf = None, []
            continue
        if field == 'allow':
            buf.append(line.strip())          # wrapped continuation line
    flush()

    out, stats = [], {'ok': 0, 'all': [], 'none': [], 'cond': []}
    for e in entries:
        raw = e['allow']
        if not raw:
            stats['none'].append(e['table'])
            continue
        if 'Бүх багана' in raw:               # "all columns" - never emitted as '*'
            stats['all'].append(e['table'])
            continue
        head, _, tail = raw.partition(';')
        if tail.strip():
            stats['cond'].append(e['table'])
        cols = []
        for tok in head.split(','):
            tok = tok.strip().rstrip('.').strip()
            tok = tok.split('-')[0].strip()   # strip Mongolian case suffix: "fileType-ийг"
            if IDENT.match(tok) and tok not in cols:
                cols.append(tok)
        if not cols:
            stats['none'].append(e['table'])
            continue
        out.append(f"{e['table']}   ({len(cols)} columns)\n{', '.join(cols)}")
        stats['ok'] += 1

    with open(dest, 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(out) + '\n')

    print(f"entries found          : {len(entries)}")
    print(f"emitted with columns   : {stats['ok']}")
    print(f"'all columns' (refused): {len(stats['all'])} {stats['all']}")
    print(f"no allow list          : {len(stats['none'])} {stats['none']}")
    print(f"had trailing condition : {len(stats['cond'])} (conditional part dropped)")

main(sys.argv[1], sys.argv[2])
