set -ex

pushd /tmp
rm -f tform.zip
rm -f terraform

curl -L '@url' -o tform.zip

unzip tform.zip

mkdir -p $home/git3/bin

rm -f ${f.tf_cmd}
mv terraform ${f.tf_cmd}


popd

echo "TERRAFORM INSTALLED SUCCESFULLY"