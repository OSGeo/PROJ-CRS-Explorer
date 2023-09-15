#!/usr/bin/env python

import json
import os

import pyproj
from contextlib import redirect_stdout

def url_to_xml(prefix, file):
    str  = f'    <url>\n'
    str += f'        <loc>{prefix}{file}</loc>\n'
    str += f'    </url>\n'
    return str


if __name__ == '__main__':
    dest_dir = os.getenv('DEST_DIR', '.')
    dest_file = f'{dest_dir}/crslist.json'
    metadata_file = f'{dest_dir}/metadata.txt'
    sitemap_file = f'{dest_dir}/sitemap.xml'

    pyproj.show_versions()
    with open(metadata_file, 'w') as f:
        with redirect_stdout(f):
            pyproj.show_versions()

    crs_list = pyproj.database.query_crs_info(allow_deprecated=True)

    crss = sorted(
        [crs._asdict() for crs in crs_list if crs.area_of_use],
        key=lambda d: d['auth_name'] + d['code'].zfill(7)
    )


    print('\nAnalysis of duplicated codes')
    codes = [d['auth_name'] + ':' + d['code'] for d in crss]
    unique = []
    for code in codes:
        if code in unique:
            print(code + ' is duplicated')
        else:
            unique.append(code)


    with open(dest_file, 'w') as fp:
        json.dump(crss, fp, indent=2, default=lambda o: str(o).replace('PJType.', ''))

    types = ({'path': 'wkt1', 'version': 'WKT1_GDAL'},
             {'path': 'wkt2', 'version': 'WKT2_2019'})

    urls = []
    for c in crss:
        crs = pyproj.CRS.from_authority(auth_name=c["auth_name"], code=c["code"])
        for t in types:
            url = f'{t["path"]}/{c["auth_name"]}/{c["code"]}.txt'
            if not url in urls:
                urls.append(url)
            wtk_file = f'{dest_dir}/{url}'
            if not os.path.exists(os.path.dirname(wtk_file)):
                os.makedirs(os.path.dirname(wtk_file))

            try:
                output_axis_rule = True if crs.is_projected else None
                wkt = crs.to_wkt(version=t["version"], pretty=True, output_axis_rule=output_axis_rule)
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

    url_prefix = 'https://crs-explorer.proj.org/'
    sitemap_str = '<?xml version="1.0" encoding="utf-8"?>\n'
    sitemap_str += '<urlset xmlns="https://www.sitemaps.org/schemas/sitemap/0.9">\n'
    sitemap_str += url_to_xml(url_prefix, '')
    sitemap_str += url_to_xml(url_prefix, 'metadata.txt')
    for url in urls:
        sitemap_str += url_to_xml(url_prefix, url)
    sitemap_str += '</urlset>\n'

    with open(sitemap_file, 'w') as sitemap:
        sitemap.write(sitemap_str)
