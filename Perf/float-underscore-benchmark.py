#!/usr/bin/env python3
"""Alternating float-underscore compaction timings, with complete result checks."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess
import tempfile


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('baseline',type=Path);p.add_argument('candidate',type=Path)
    p.add_argument('--samples',type=int,default=9);p.add_argument('--cpu',type=int,default=13)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    if a.samples<3:p.error('at least three samples required')
    os.sched_setaffinity(0,{a.cpu})
    shells=[s.resolve(strict=True) for s in [a.baseline,a.candidate]]
    worker=Path(__file__).resolve().with_name('float-underscore-workload.zsh')
    sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    identities={str(p):sha(p) for p in [*shells,worker,Path(__file__)]}
    rows=[]
    with tempfile.TemporaryDirectory(prefix='psh-float-underscore-') as temporary:
        rss=Path(temporary)/'rss'
        for underscores,tail,iterations in [(0,0,10000),(4,0,10000),(64,0,3000),(1024,0,100),(16384,0,3),(64,4096,100)]:
            expr='1'+'_'*underscores+'.25+named_value+(side+=1)'+'+0'*tail
            samples=[[],[]];state=None
            for sample in range(a.samples):
                for host in ([0,1] if sample%2==0 else [1,0]):
                    r=subprocess.run(['/usr/bin/time','-f','%M','-o',str(rss),str(shells[host]),'-df',str(worker),expr,str(iterations)],
                        env={'PATH':'/usr/bin:/bin','LC_ALL':'C.UTF-8'},capture_output=True,timeout=120)
                    if r.returncode or r.stderr:raise RuntimeError((host,r.returncode,r.stderr))
                    elapsed,observed=r.stdout.split(b'\n',1)
                    if state is None:state=observed
                    assert state and state==observed
                    samples[host].append(dict(batch_ms=float(elapsed)*1000,peak_rss_kib=int(rss.read_text())))
            row=dict(underscores=underscores,tail_additions=tail,iterations=iterations,samples=samples,
                     median_ms=[statistics.median(v['batch_ms'] for v in s) for s in samples],
                     state_sha256=hashlib.sha256(state).hexdigest())
            rows.append(row);print(underscores,tail,row['median_ms'],flush=True)
    assert identities=={p:sha(Path(p)) for p in identities}
    a.output.write_text(json.dumps(dict(identity=identities,samples=a.samples,cpu=a.cpu,cases=rows,
        scope='Internal arithmetic batch time; GNU time peak RSS covers full process; synthetic syntax workload'),indent=2)+'\n')


if __name__=='__main__':main()
