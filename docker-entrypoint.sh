#!/bin/bash
source /root/.bashrc
conda activate jupyterlab
jupyter lab --ip=0.0.0.0 --no-browser --allow-root
