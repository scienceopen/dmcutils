#!/usr/bin/env python
import pytest
from pathlib import Path
import dmcutils.neospool as neo

rdir = Path(__file__).parents[1]
inifn = rdir / 'data' / 'spool' / 'acquisitionmetadata.ini'


def test_neoparam():
    param = neo.spoolparam(inifn)
    assert param['superx'] == 640
    assert param['supery'] == 320
    assert param['nframefile'] == 20
    assert param['stride'] == 1296
    assert param['framebytes'] == 416016
    assert param['bpp'] == 16


if __name__ == '__main__':
    pytest.main()
