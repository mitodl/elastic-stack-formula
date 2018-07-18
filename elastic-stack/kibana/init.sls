{% from "elasticsearch/map.jinja" import elasticsearch with context %}

include:
  - .install
  - .configure
  - .service
