#!/usr/bin/env python

import json
import os

import pyproj


if __name__ == '__main__':
    pyproj.show_versions()

    dest_dir = os.getenv('DEST_DIR', '.')
    dest_file = f'{dest_dir}/crslist.json'

    crs_list = pyproj.database.query_crs_info(allow_deprecated=True)

    crss = sorted(
        [crs._asdict() for crs in crs_list if crs.area_of_use],
        key=lambda d: d['auth_name'] + d['code'].zfill(7)
    )

    with open(dest_file, 'w') as fp:
        json.dump(crss, fp, indent=2, default=lambda o: str(o).replace('PJType.', ''))
