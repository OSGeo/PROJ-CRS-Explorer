FROM ghcr.io/osgeo/proj:9.6.2

ARG PYPROJ_VERSION 3.3.0
ENV PYPROJ_VERSIONi=$PYPROJ_VERSION

ENV PROJ_DIR=/usr/
ENV PROJ_DATA=/usr/share/proj/

ENV VIRTUAL_ENV=/home/venv
ENV PATH=$VIRTUAL_ENV/bin:$PATH

ENV DEST_DIR=/home/dist

WORKDIR /home/

COPY conf .
COPY .python-version .
RUN /home/install.sh

COPY proj2json.py .
CMD ["python3", "./proj2json.py"]
