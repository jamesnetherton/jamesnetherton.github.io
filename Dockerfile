FROM jekyll/jekyll:2.4

WORKDIR /site

ENTRYPOINT [ "jekyll", "serve", "--host=0.0.0.0" ]

EXPOSE 4000
