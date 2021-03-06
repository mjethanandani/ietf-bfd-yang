#!/bin/sh

#
# First check to see if you need to create/update your yang repository of
# all IETF published YANG models.
#
# rsync -avz --delete rsync.ietf.org::iana/yang-parameters ../../

for i in yang/*\@$(date +%Y-%m-%d).yang
do
    name=$(echo $i | cut -f 1 -d '.')
    echo "Validating and generating tree for $name.yang"
    if test "${name#^example}" = "$name"; then
        response=`pyang --lint --strict --canonical -p ../ -f tree --max-line-length=72 --tree-line-length=69 $name.yang > $name-tree.txt.tmp`
    else
        response=`pyang --ietf --strict --canonical -p ../ -f tree --max-line-length=72 --tree-line-length=69 $name.yang > $name-tree.txt.tmp`
    fi

    if [ $? -ne 0 ]; then
        printf "$name.yang failed pyang validation\n"
        printf "$response\n\n"
        echo
        exit 1
    fi

    fold -w 71 $name-tree.txt.tmp > $name-tree.txt
    response=`yanglint -p ../../ $name.yang`
    if [ $? -ne 0 ]; then
        printf "$name.yang failed yanglint validation\n"
        printf "$response\n\n"
        echo
        exit 1
    fi
done
rm yang/*-tree.txt.tmp

echo "Validating examples"

echo "example-ip-sh.xml"
response=`yanglint -s -i -t auto -p ../../ yang/ietf-bfd-ip-sh\@$(date +%Y-%m-%d).yang dependencies/iana-if-type.yang ../src/yang/example-ip-sh.xml`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi

echo "example-ip-mh.xml"
response=`yanglint -s -i -t auto -p ../../ yang/ietf-bfd-ip-mh\@$(date +%Y-%m-%d).yang dependencies/iana-if-type.yang ../src/yang/example-ip-mh.xml`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi

echo "example-lag.xml"
response=`yanglint -s -i -t auto -p ../../ yang/ietf-bfd-lag\@$(date +%Y-%m-%d).yang dependencies/iana-if-type.yang ../src/yang/example-lag.xml`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi

echo "example-mpls.xml"
response=`yanglint -s -i -t auto -p ../../ yang/ietf-bfd-mpls\@$(date +%Y-%m-%d).yang dependencies/iana-if-type.yang ../src/yang/example-mpls.xml`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
