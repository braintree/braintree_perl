#!/bin/bash

rm -rf ~/perl5
eval $(perl -Mlocal::lib) && rake --trace
