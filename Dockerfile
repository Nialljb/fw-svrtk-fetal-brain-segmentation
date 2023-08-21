# Use the latest Python 3 docker image
FROM nialljb/fw-fetal-segmentation as base

ENV HOME=/root/
ENV FLYWHEEL="/flywheel/v0"
WORKDIR $FLYWHEEL
RUN mkdir -p $FLYWHEEL/input

# Installing the current project (most likely to change, above layer can be cached)
COPY ./ $FLYWHEEL/

# Dev dependencies
# add in any dev dependencies here #

# Configure entrypoint
RUN bash -c 'chmod +rx $FLYWHEEL/run.py' && \
    bash -c 'chmod +rx $FLYWHEEL/app/'
ENTRYPOINT ["python3","/flywheel/v0/run.py"] 
# Flywheel reads the config command over this entrypoint