mkdir -p tmp-download
pushd tmp-download
wget -q -r -nd -np -A deb -e robots=off https://apertium.projectjj.com/apt/nightly/pool/main/g/giella-sma/
wget -q -r -nd -np -A deb -e robots=off https://apertium.projectjj.com/apt/nightly/pool/main/g/giella-sme/
wget -q -r -nd -np -A deb -e robots=off https://apertium.projectjj.com/apt/nightly/pool/main/g/giella-smj/
wget -q -r -nd -np -A deb -e robots=off https://apertium.projectjj.com/apt/nightly/pool/main/g/giella-smn/
wget -q -r -nd -np -A deb -e robots=off https://apertium.projectjj.com/apt/nightly/pool/main/g/giella-sms/
popd

for f in tmp-download/*.deb; do
  mkdir tmp
  cd tmp
  ar x ../$f
  tar xf data.tar.gz
  mv usr/share/giella/mobilespellers/* .
  fn=`ls *.zhfst`
  name=`basename "$fn" -mobile.zhfst`.zhfst
  mv *.zhfst ../$name
  cd ..
  rm -r tmp
done

rm -r tmp-download
ls *.zhfst
