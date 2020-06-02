FROM jupyter/minimal-notebook:65761486d5d3 

MAINTAINER Marijn van Vliet <w.m.vanvliet@gmail.com>

# Install core debian packages
USER root
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -yq dist-upgrade \
    && apt-get install -yq --no-install-recommends \
    openssh-client \
    vim \ 
    curl \
    gcc \
    && apt-get clean

# Xvfb
RUN apt-get install -yq --no-install-recommends \
    xvfb \
    x11-utils \
    libx11-dev \
    qt5-default \
    && apt-get clean

ENV DISPLAY=:99

# Switch to notebook user
USER $NB_UID

# Upgrade the package managers
RUN pip install --upgrade pip
RUN npm i npm@latest -g

# Install Python packages
RUN pip install vtk && \
    pip install numpy && \
    pip install scipy && \
    pip install pyqt5 && \
    pip install xvfbwrapper && \
    pip install mayavi && \
    pip install ipywidgets && \
    pip install ipyevents && \
    pip install pillow && \
    pip install scikit-learn && \
    pip install nibabel && \
    pip install https://github.com/nipy/PySurfer/archive/master.zip && \
    pip install mne &&\
    pip install numpy-stl &&\
    pip install seaborn

# Install Jupyter notebook extensions
RUN pip install RISE && \
    jupyter nbextension install rise --py --sys-prefix && \
    jupyter nbextension enable rise --py --sys-prefix && \
    jupyter nbextension install mayavi --py --sys-prefix && \
    jupyter nbextension enable mayavi --py --sys-prefix && \
    npm cache clean --force

# Clone the repository. First fetch the hash of the latest commit, which will
# invalidate docker's cache when new things are pushed to the repository. See:
# https://stackoverflow.com/questions/36996046
ADD https://api.github.com/repos/mriosrivas/linear_algebra/git/refs/heads/master version.json
RUN git init . && \
    git remote add origin https://github.com/mriosrivas/linear_algebra.git && \
    git pull origin master

# Download a minimized verion of the MNE-sample dataset
# RUN wget "https://github.com/wmvanvliet/snl_workshop_2019/releases/download/0.1/sample-min.zip" -O sample-min.zip
# RUN unzip sample-min.zip -d notebooks/data
# RUN rm sample-min.zip

# Configure the MNE raw browser window to use the full width of the notebook
RUN ipython -c "import mne; mne.set_config('MNE_BROWSE_RAW_SIZE', '9.8, 7')"

# Add an x-server to the entrypoint. This is needed by Mayavi
ENTRYPOINT ["tini", "-g", "--", "xvfb-run"] 

