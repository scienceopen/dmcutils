#!/usr/bin/env python
"""
testing possible pytables vs h5py race on write/append
"""
from tempfile import mkstemp
from pathlib import Path
import h5py
from pandas import Series
import numpy as np


def test_h5race(outfn: Path, N: int):
    assert isinstance(N, int)

    ticks = np.random.randint(0, N, N)
    flist = [Path(f'{n:010d}spool.dat') for n in np.random.randint(0, N, N)]

    F = Series(index=ticks, data=[f.name for f in flist])
    F.sort_index(inplace=True)
    print(f'sorted {len(flist)} files vs. time ticks')

# %% writing HDF5 iprintndex
    print(f'writing {outfn}')
    F.to_hdf(outfn, 'filetick', mode='w')
    with h5py.File(outfn, 'a', libver='latest') as f:
        f['path'] = str(flist[0].parent)
# %% test read
    with h5py.File(outfn, 'r', libver='latest') as f:
        print(f['path'].value)


if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser()
    p.add_argument('outfn', nargs='?', default=mkstemp(suffix='.h5')[1])
    p.add_argument('-N', help='number of elements to write',
                   type=int, default=1e6)
    p = p.parse_args()

    test_h5race(p.outfn, int(p.N))
