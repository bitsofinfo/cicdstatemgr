FROM bitsofinfo/cicd-toolbox:3.0.4

RUN python3 -m pip install --index-url https://test.pypi.org/simple/  cicdstatemgr

RUN pip show cicdstatemgr

RUN cicdstatemgr -h

