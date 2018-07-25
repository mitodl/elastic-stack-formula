=============
elastic-stack
=============

Deploy, configure, and manage the various components of the Elastic Stack (e.g. Elasticsearch, Kibana, Beats, Logstash)

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.


Available states
================

.. contents::
    :local:

``elastic-stack``
-----------------

By default this will execute the `elastic-stack.repository` state

``elastic-stack.repository``
----------------------

This will enable the elastic stack repository for the specified 'version' (e.g. 6.x by default). All of the sub-packages rely on this state being executed and will include it as part of their install state.

``elastic-stack.elasticsearch``
----------------------

This is a sub-package for installing, configuring, and managing the Elasticsearch service and its plugins

``elastic-stack.kibana``
----------------------

This is a sub-package for installing, configuring, and managing the Kibana service and its plugins

``elastic-stack.beats``
----------------------

This is a sub-package for installing, configuring, and managing the various Beats agents and their associated modules

``elastic-stack.elastalert``
----------------------

This is a sub-package for installing, configuring, and managing the Elastalert service for monitoring the contents of Elasticsearch and generating notifications based on periodic queries.


Template
========

This formula was created from a cookiecutter template.

See https://github.com/mitodl/saltstack-formula-cookiecutter.
