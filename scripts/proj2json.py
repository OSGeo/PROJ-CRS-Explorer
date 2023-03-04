#!/usr/bin/env python

import json
import os

import pyproj
from contextlib import redirect_stdout


if __name__ == '__main__':
    dest_dir = os.getenv('DEST_DIR', '.')
    dest_file = f'{dest_dir}/crslist.json'
    metadata_file = f'{dest_dir}/metadata.txt'

    pyproj.show_versions()
    with open(metadata_file, 'w') as f:
        with redirect_stdout(f):
            pyproj.show_versions()

    crs_list = pyproj.database.query_crs_info(allow_deprecated=True)

    crss = sorted(
        [crs._asdict() for crs in crs_list if crs.area_of_use],
        key=lambda d: d['auth_name'] + d['code'].zfill(7)
    )

    with open(dest_file, 'w') as fp:
        json.dump(crss, fp, indent=2, default=lambda o: str(o).replace('PJType.', ''))

    types = ({'path': 'wkt1', 'version': 'WKT1_GDAL'},
             {'path': 'wkt2', 'version': 'WKT2_2019'})

    for c in crss:
        crs = pyproj.CRS.from_authority(auth_name=c["auth_name"], code=c["code"])
        for t in types:
            wtk_file = f'{dest_dir}/{t["path"]}/{c["auth_name"]}/{c["code"]}.txt'
            if not os.path.exists(os.path.dirname(wtk_file)):
                os.makedirs(os.path.dirname(wtk_file))

            try:
                wkt = crs.to_wkt(version=t["version"], pretty=True)
            except:
                wkt = None
            if not wkt:
                type = str(c["type"]).replace('PJType.', '')
                wkt = (f'Error: {c["auth_name"]}:{c["code"]} cannot be written as {t["version"]}\n'
                        f' type: {type}\n'
                        f' name: {c["name"]}')
            with open(wtk_file, 'w') as fp:
                fp.write(wkt)
                fp.write('\n')
