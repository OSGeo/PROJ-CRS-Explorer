ARG VERSION
FROM ghcr.io/osgeo/proj:$VERSION

ARG PYPROJ_VERSION 3.3.0
ENV PYPROJ_VERSION $PYPROJ_VERSION

ENV PROJ_DIR      /usr/
ENV PROJ_DATA     /usr/share/proj/

ENV VIRTUAL_ENV   /home/venv
ENV PATH          $VIRTUAL_ENV/bin:$PATH

ENV DEST_DIR      /home/dist

WORKDIR /home/

COPY conf .
RUN /home/install.sh

COPY proj2json.py .
CMD ["python3.8", "./proj2json.py"]
