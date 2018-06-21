#!/usr/bin/env python
from timeit import timeit

tstat = timeit('fn.stat().st_size',
               setup="from pathlib import Path;fn=Path('../LEDcleaner.pdf')",
               number=100000)

print(f'Time to stat filesize: {tstat:.1f} [sec].')

tread = timeit('with fn.open('r') as f: f.seek(1000);',
               setup="from pathlib import Path;fn=Path('../LEDcleaner.pdf')",
               number=100000)

print(f'time to seek: {tread:.1f} [sec].')
