FROM bitsofinfo/cicd-toolbox:3.0.4

ARG GIT_TAG=master

RUN echo GIT_TAG=${GIT_TAG}

RUN rm -rf ~/.pip && python3 -m pip install cicdstatemgr==${GIT_TAG}

RUN pip show cicdstatemgr

RUN cicdstatemgr -h

