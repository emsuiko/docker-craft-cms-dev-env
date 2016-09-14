#!/bin/bash
echo "Procompile all resources..."
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
cd /local/public
bower --allow-root install
cd /local
pug -E twig -P -o craft/templates resources/jade
sass resources/sass/styles.sass public/css/styles.css
postcss --use autoprefixer -o public/css/styles.css public/css/styles.css
cd /local/resources/js
for i in *.js; do uglifyjs ${i} --compress --mangle --output ../../public/js/${i}; done
cd /local
rsync -r /local/resources/twig/ /local/craft/templates/
rsync -r /local/resources/css/ /local/public/css/
