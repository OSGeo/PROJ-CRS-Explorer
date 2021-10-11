import pyproj
import json

crs_list = pyproj.database.query_crs_info(allow_deprecated = True)
crss = sorted([crs._asdict() for crs in crs_list if crs.area_of_use], key = lambda d: d['auth_name'] + d['code'].zfill(7))

with open("crslist.json", "w") as fp:
    json.dump(crss, fp, indent = 2, default = lambda o: str(o).replace('PJType.', ''))

pyproj.show_versions()
