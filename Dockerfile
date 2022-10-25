FROM golang:1.16-alpine

RUN set -ex && apk --update --no-cache add \
	bash \
	make \
	git \
	protobuf

# install proto tools & packages
WORKDIR /tools

ADD go.mod /tools/go.mod

ADD go.sum /tools/go.sum

RUN go install \
	github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway \
	github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger \
	github.com/golang/protobuf/protoc-gen-go

COPY subdir_clone.sh /usr/local/bin/subdir_clone.sh

RUN chmod +x /usr/local/bin/subdir_clone.sh

WORKDIR /usr/include

RUN subdir_clone.sh https://github.com/protocolbuffers/protobuf/src/google

RUN cp -r /go/pkg/mod/github.com/grpc-ecosystem/grpc-gateway*/third_party/googleapis/google/* ./google/

RUN cp -r /go/pkg/mod/github.com/grpc-ecosystem/grpc-gateway*/protoc-gen-swagger .

RUN go get -d github.com/envoyproxy/protoc-gen-validate ; \
	cd /go/pkg/mod/github.com/envoyproxy/protoc-gen-validate* ; \
	make build ; \
	cp -r validate /usr/include/

RUN go get -u github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc

WORKDIR /defs

COPY gen_proto.sh /usr/local/bin/gen_proto.sh

RUN chmod +x /usr/local/bin/gen_proto.sh

CMD [ "gen_proto.sh" ]

