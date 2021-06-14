FROM alpine/gcloud:310.0.0
ENV HOME /
ENV PATH /google-cloud-sdk/bin:$PATH
RUN apk add --update --no-cache nano jq
COPY . /datapipeline
WORKDIR /datapipeline
ENTRYPOINT ["/bin/bash"]