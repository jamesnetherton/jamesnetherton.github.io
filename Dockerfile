FROM jekyll/jekyll:3.8

WORKDIR /site

ENTRYPOINT [ "jekyll", "serve", "--host", "0.0.0.0" ]

EXPOSE 4000

