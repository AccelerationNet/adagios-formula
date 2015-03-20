adagios-formula
================

Formula to install and configure Adagios_ on a debian-based system. Mostly tested to work against my `shinken-formula`_

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

.. _Adagios: https://github.com/opinkerfi/adagios
.. _shinken-formula: https://github.com/AccelerationNet/shinken-formula

Available states
================

.. contents::
    :local:

``adagios``
------------

Installs adagios from pip, configures according to pillar settings.

Modifies your nagios config to reference the spot where adagios will
write files.
