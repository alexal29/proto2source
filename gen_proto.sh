#!/bin/bash -e

printUsage() {
    echo "gen_proto.sh: generates grpc and protobuf @ Alex"
    echo " "
    echo "Usage: gen_proto.sh -f service/domain.proto -o output/generated"
    echo " "
    echo "options:"
    echo " -h, --help                     Show help"
    echo " -f FILE                        The proto source file to generate"
    echo " -d DIR                         Scans the given directory for all proto files"
}

PROTO_INCLUDE="-I /defs"
REPO=$(cd /defs; ls -d */ | head -1)
REPO=${REPO%?}

while test $# -gt 0; do
    case "$1" in
        -h|--help)
            printUsage
            exit 0
            ;;
        -f)
            shift
            if test $# -gt 0; then
                FILE=$1
            else
                echo "no input file specified"
                exit 1
            fi
            shift
            ;;
        -d)
            shift
            if test $# -gt 0; then
                PROTO_DIR=$1
            else
                echo "no directory specified"
                exit 1
            fi
            shift
            ;;
        -o) shift
            OUT_DIR=$1
            shift
            ;;
        -i) shift
            PROTO_INCLUDE="$PROTO_INCLUDE -I /defs/$REPO/$1"
            shift
            ;;
        *)
            break
            ;;
    esac
done

if [[ -z $FILE && -z $PROTO_DIR ]]; then
    echo "Error: target proto file or directory required"
    printUsage
    exit 1
fi

if [[ -z $OUT_DIR ]]; then
    OUT_DIR=/defs
fi

if [[ ! -d $OUT_DIR ]]; then
    mkdir -p $OUT_DIR
fi

if [ ! -z $FILE ]; then
    PROTO_TARGET="/defs/$REPO/$FILE"
    PROTO_DIR=${FILE%/*}
else
    PROTO_TARGET="/defs/$REPO/$PROTO_DIR/*.proto"
fi

protoc $PROTO_INCLUDE \
    --go_out $OUT_DIR \
    --go_opt plugins=grpc \
    --grpc-gateway_out $OUT_DIR \
    --grpc-gateway_opt logtostderr=true \
    --swagger_out $OUT_DIR \
    --swagger_opt logtostderr=true \
    --validate_out "lang=go:$OUT_DIR" \
    --doc_out /defs/$REPO/$PROTO_DIR \
    --doc_opt "html,docs.html" \
    $PROTO_TARGET