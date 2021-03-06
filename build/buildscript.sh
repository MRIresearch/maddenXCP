
#!/bin/bash
if [ ! -d xcpEngine ]
then
   git clone https://github.com/PennBBL/xcpEngine.git
fi
cd xcpEngine

# Checkout version 1.2.3 and specific commit
git checkout -f 7cf8ed798a1ca074075874eceefbc1f210cafbb1

# copy over custom R files
cp ../../customR/* ./utils

# replace DOCKERURL and VERSION with yours
DOCKERURL=aacazxnat/xcpengine-madden
VERSION=1.0
docker build -t ${DOCKERURL}:${VERSION} .
docker push ${DOCKERURL}:${VERSION}
