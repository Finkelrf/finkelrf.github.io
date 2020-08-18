docker run --rm -p 8000:8000 \
  --volume="$PWD:/srv/jekyll" \
  -it tocttou/jekyll:3.5 \
  jekyll serve --watch --port 8000