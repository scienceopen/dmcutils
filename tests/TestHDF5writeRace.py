#!/usr/bin/env python
"""
testing possible pytables vs h5py race on write/append
"""
from pathlib import Path
import h5py
from pandas import Series
import numpy as np

N=int(1e6)

outfn='/run/shm/test.h5'

ticks = np.random.randint(0,N,N)
flist = [Path(f'{n:010d}spool.dat') for n in np.random.randint(0,N,N)]

F = Series(index=ticks, data=[f.name for f in flist])
F.sort_index(inplace=True)
print(f'sorted {len(flist)} files vs. time ticks')

# %% writing HDF5 iprintndex
print(f'writing {outfn}')
F.to_hdf(outfn, 'filetick', mode='w')
with h5py.File(outfn, 'a', libver='latest') as f:
    f['path'] = str(flist[0].parent)