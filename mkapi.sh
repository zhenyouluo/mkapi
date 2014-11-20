
#TODO: auto add virtual functions

help(){
  echo "Usage: $0 [-name Name] [-template Template]"
  echo "Or $0 [--name=Name] [--template=Template]"
  exit 0
}

ARGV=$@

while [ $# -gt 0 ]; do
  VAR=
  case "$1" in
  --*=*)
    PAIR=${1##--}
    VAR=${PAIRE%=*}
    VAL=${PAIR##*=}
    ;;
  -*)
    VAR=${1##-}
    shift
    VAL=$1
    ;;
  *)
    break
    ;;
  esac
  if [ -n "VAR" ]; then
    VAR_U=`echo $VAR | tr "[:lower:]" "[:upper:]"`
    echo "$VAR_U"
    eval $VAR_U=$VAL
  fi
  shift
done

[ -n "$NAME" ] || help
[ -n "$TEMPLATE" ] || TEMPLATE=capi
echo "name: $NAME, template: $TEMPLATE"

echo "./mkapi $ARGV >/dev/null"
[ -e mkapi ] || {
  echo "build mkapi first (run make. need clang3.4 sdk)"
  exit 0
}
./mkapi $ARGV >/dev/null

NAME_U=`echo $NAME | tr "[:lower:]" "[:upper:]"`
NAME_L=`echo $NAME | tr "[:upper:]" "[:lower:]"`
YEAR=`date +%Y`

mkdir -p /tmp/mkapi
mv ${NAME}_declarations /tmp/mkapi/declarations
mv ${NAME}_resolvers /tmp/mkapi/resolvers
mv ${NAME}_definitions /tmp/mkapi/definitions

#TODO: author info
echo "generating ${NAME}_api.h..."
#cat $COPY | sed "s/%YEAR%/$YEAR/g" > ${CLASS}.h
cat template/${TEMPLATE}/name_api.h |sed "s/%Name%/$NAME/g" | sed "s/%NAME%/$NAME_U/g"  | sed "s/%name%/$NAME_L/g" \
    |sed "s,%TEMPLATE%,$TEMPLATE,g" \
    |sed -n '/%Declare%/!p;/%Declare%/r/tmp/mkapi/declarations' \
    >${NAME}_api.h
echo "generating ${NAME}_api.cpp..."
cat template/${TEMPLATE}/name_api.cpp |sed "s/%Name%/$NAME/g" | sed "s/%NAME%/$NAME_U/g"  | sed "s/%name%/$NAME_L/g" \
    |sed "s,%TEMPLATE%,$TEMPLATE,g" \
    |sed -n '/%DEFINE_RESOLVER%/!p;/%DEFINE_RESOLVER%/r/tmp/mkapi/resolvers' \
    |sed -n '/%DEFINE%/!p;/%DEFINE%/r/tmp/mkapi/definitions' \
     >${NAME}_api.cpp